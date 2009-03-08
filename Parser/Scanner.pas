unit Scanner;

interface

uses SysUtils, Classes, Tokens, Scope, Errors;

type
  PDocumentInfo = ^TDocumentInfo;
  PTokenInfo = ^TTokenInfo;

  TTokenInfo = record
    Token: TTokenType;
    Start: PAnsiChar;
    Stop: PAnsiChar;
    Document: PDocumentInfo;
    Line: Cardinal;
    LineStart: PAnsiChar;
    Error: Boolean;
    Hash: TParserHash;
    function Length: Cardinal; inline;
    function StrNew: PAnsiChar;
  end;

  TDocumentInfo = record
    Name: String;
    Children: PDocumentInfo;
    Errors: PErrorInfo;
    Start: PAnsiChar;
    Stop: PAnsiChar;
    Owner: PDocumentInfo;
    Line: Cardinal;
    LineStart: PAnsiChar;

    Next: PDocumentInfo;

    Input: PAnsiChar;
    procedure Free;
  end;

var
  Token: TTokenInfo;
  Input: PAnsiChar;
  Document: PDocumentInfo;
  JumpTable: array [0..255] of TProcedure;

const
  White = [#1..#9, #11..#12, #14..#32];

  Alpha = ['A'..'Z', 'a'..'z'];

  Num =  ['0'..'9'];

  Ident = Alpha + Num + ['_'];

  Operators = ['/', '*', '+', '-', '{', '}', '(', ')', ',', ';', ':', '='];

  LineEnd = [#10, #13, #0];

  Known = Ident + White + Operators + LineEnd;

function Parse(Text: PAnsiChar): PDocumentInfo;
procedure Next; inline;
procedure NextLine; inline;

function GetLength(Start, Stop: PAnsiChar): Cardinal; inline;

function Match(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean; inline;

function HashString(Text: PAnsiChar): TParserHash;

procedure Init;

implementation

uses Dialogs, ScannerKeywordsSearch;

function HashString(Text: PAnsiChar): TParserHash;
begin
  {$OVERFLOWCHECKS OFF}
  {$RANGECHECKS OFF}
  Result := 0;

  while Text^ <> #0 do
    begin
      Result := Result + Byte(Text^);
      Inc(Text);
    end;

  {$OVERFLOWCHECKS ON}
  {$RANGECHECKS ON}
end;

function Parse(Text: PAnsiChar): PDocumentInfo;
begin  
  New(Document);
  Document.Children := nil;
  Document.Errors := nil;
  Document.Input := Text;
  Document.Owner := nil;
  Document.Name := 'Test';

  Input := Text;

  Token.Token := ttNone;
  Token.Document := Document;
  Token.Line := 0;
  Token.LineStart := Text;

  Result := Document;

  Next;
end;

procedure TDocumentInfo.Free;
var
  ErrorInfo, ErrorDummy: PErrorInfo;
  DocumentInfo, DocumentDummy: PDocumentInfo;
begin
  DocumentInfo := Children;

  while DocumentInfo <> nil do
    begin
      DocumentDummy := DocumentInfo;
      DocumentInfo := DocumentInfo.Next;
      DocumentDummy.Free;
    end;

  ErrorInfo := Errors;

  while ErrorInfo <> nil do
    begin
      ErrorDummy := ErrorInfo;
      ErrorInfo := ErrorInfo.Next ;
      ErrorDummy.Free;
    end;

  Name := '';

  if Owner <> nil then
    StrDispose(Input);

  Dispose(@Self);
end;

function TTokenInfo.StrNew: PAnsiChar;
var StrLen, Len: Cardinal;
begin
  Len := Length;
  StrLen := Len + 1;
  GetMem(Result, StrLen);
  Move(Start^, Result^, StrLen);
  Result[Len] := #0;
end;

function TTokenInfo.Length: Cardinal;
begin
  Result := Cardinal(Stop) - Cardinal(Start);
end;

function GetLength(Start, Stop: PAnsiChar): Cardinal;
begin
  Result := Cardinal(Stop) - Cardinal(Start);
end;

function TokenString(const Token: TTokenInfo): string; inline;
begin
  SetLength(Result, Token.Length);
  Move(Token.Start^, PChar(Result)^, Token.Length);
end;

function Match(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean;
begin
  if Token.Token <> AToken then
    begin
      Expected(AToken, Skip);

      Result := False;
    end
  else
    begin
      if GoNext then
        begin
          {if Token.Token in [ttLine, ttEnd] then
            Token.Error := False
          else}
            Next;
        end;
      Result := True;
    end;
end;

procedure Single(TokenType: TTokenType); inline;
begin
  Token.Token := TokenType;
  Inc(Input);
  Token.Stop := Input;
end;

procedure NextLine;
begin
  if Token.Token = ttEnd then
    Exit;
    
  Match(ttLine);

  while Token.Token = ttLine do
    Next;
end;

procedure GoToLineEnd; inline;
begin
  while not (Input^ in LineEnd) do
    Inc(Input);
end;

procedure CreateDocument(Name: String; Data: PAnsiChar; Stop: PAnsiChar);
var Doc: PDocumentInfo;
begin
  New(Doc);
  Doc.Name := Name;
  Doc.Children := nil;
  Doc.Errors := nil;
  Doc.Start := Token.Start;
  Doc.Stop := Stop;
  Doc.Owner := Document;
  Doc.Line := Token.Line;
  Doc.LineStart := Token.LineStart;

  Doc.Input := Data;

  Input := Data;

  Token.Line := 0;
  Token.LineStart := Data;

  Doc.Next := Document.Children;
  Document.Children := Doc;

  Document := Doc;
  Token.Document := Doc;
end;

procedure Next;
begin
    while Input^ in White do
      Inc(Input);

    Token.Start := Input;

    if Token.Error then
      Token.Error := False;

    JumpTable[Byte(Input^)];
end;

procedure NullProc;
begin
  if Document.Owner <> nil then
    begin
      Token.Line := Document.Line;
      Token.LineStart := Document.LineStart;
      
      Input := Document.Stop;

      Document := Document.Owner;
      Token.Document := Document;
      
      Next;
    end
  else
    Token.Token := ttEnd;
end;

procedure LineFeedProc;
begin
  Token.Token := ttLine;
  Inc(Input);

  Inc(Token.Line);
  Token.Stop := Input;
  Token.LineStart := Input;
end;

procedure CarrigeReturnProc;
begin
  Token.Token := ttLine;
  Inc(Input);

  if Input^ = #10 then
    Inc(Input);

  Inc(Token.Line);
  Token.Stop := Input;
  Token.LineStart := Input;
end;

procedure CommentProc;
var
  s: String;

const
  TestStr = 'Hello,'#10#10'This is a dummy child with errors.';
begin
  Inc(Input);

  // Is it a comment?
  if Input^ = '/' then
    begin
      Inc(Input);

      // Is it a command?
      if (Input^ = '!') and (Token.Token in [ttNone, ttLine]) then
        begin
          Inc(Input);

          if Input^ in White then // It was a command!
            begin
              GoToLineEnd;

              s := TestStr;

              s := s + #10 + 'You found this on line ' + IntToStr(Token.Line) + ' on ' + Document.Name + '.';

              CreateDocument('Some command', StrNew(PAnsiChar(S)), Input);
            end
          else
            GoToLineEnd;

        end
      else
        GoToLineEnd;

      Next;
    end
  else // Nah it was just pure old division
    begin
      Token.Token := ttDiv;
      Token.Stop := Input;
    end;
end;

procedure NumProc;
begin
  Inc(Input);
  
  Token.Token := ttNumber;

  while Input^ in Num do
    Inc(Input);

  if Input^ in Ident then
    begin
      while Input^ in Ident do
        Inc(Input);

      Token.Token := ttIdentifier;
      Token.Stop := Input;

      Error(NewError(eiNumInIdent));
    end
  else
    Token.Stop := Input;
end;

procedure EqualProc;
begin
  Single(ttEqual);
end;

procedure UnknownProc;
var ErrorInfo: PErrorInfo;
begin
  while @JumpTable[Byte(Input^)] = @UnknownProc do
    Inc(Input);

  Token.Stop := Input;

  ErrorInfo := NewError(eiInvalidChars);
  ErrorInfo.Characters := Token.StrNew;
  Error(ErrorInfo);

  Next;
end;

procedure Init;
var i: AnsiChar;
begin
  InitKeywords;

  // Setup jumptable

  // Set all to unknown
  for i := #0 to #255 do
    JumpTable[Byte(i)] := UnknownProc;

  // Identifiers
  for i := 'A' to 'Z' do
    JumpTable[Byte(i)] := IdentifierProc;

  for i := 'a' to 'z' do
    JumpTable[Byte(i)] := IdentifierProc;

  JumpTable[Byte('_')] := IdentifierProc;

  // Numbers
  for i := '0' to '9' do
    JumpTable[Byte(i)] := NumProc;

  // Others
  JumpTable[Byte(#0)] := NullProc;
  JumpTable[Byte(#10)] := LineFeedProc;
  JumpTable[Byte(#13)] := CarrigeReturnProc;
  JumpTable[Byte('/')] := CommentProc;
  JumpTable[Byte('=')] := EqualProc;
end;

end.
