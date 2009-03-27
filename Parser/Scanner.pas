unit Scanner;

interface

uses SysUtils, Classes, Tokens, Scopes;

type
  PDocumentInfo = ^TDocumentInfo;
  PTokenInfo = ^TTokenInfo;
  PErrorInfo = ^TErrorInfo;
  
  TTokenInfo = record
    Token: TTokenType;
    Hash: TParserHash;
    Stop: PAnsiChar;
    Start: PAnsiChar;
    Document: PDocumentInfo;
    Line: Cardinal;
    LineStart: PAnsiChar;
    Error: Boolean;
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

  TErrorType = (eiInvalidChars, eiNumInIdent, eiExpectedToken, eiUnexpectedToken,
    eiChildErrors, eiRedeclared, eiExpectedIdentifier, eiUndeclaredIdentifier,
    eiConstantNeedInit, eiUnexpectedIdentifier, eiRecursive);

  TErrorInfo = record
    Start: PAnsiChar;
    Length: Cardinal;
    
    Line: Cardinal;
    LineStart: PAnsiChar;

    Info, InfoPointer: PAnsiChar;

    Next: PErrorInfo;

    class function Create(const ErrorType: TErrorType): PErrorInfo; overload; static;
    class function Create(const ErrorType: TErrorType; const Token: TTokenInfo): PErrorInfo; overload; static;
    procedure Free;

    procedure Report;
    function ToString: String;

    case ErrorType: TErrorType of
      eiUnexpectedToken: (UnexpectedToken: TTokenType);
      eiExpectedToken: (ExpectedToken: TTokenType; FoundToken: TTokenType);
      eiChildErrors: (Child: Pointer);
      eiRedeclared, eiUnexpectedIdentifier, eiRecursive: (Identifier: PIdentifier);
      eiExpectedIdentifier: (ExpectedIdentifier: TIdentifierType; FoundIdentifier: TIdentifierType);
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

{ Error handling }
function Match(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean; inline;
function Matches(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean; inline;
procedure Expected(TokenType: TTokenType; DoSkip: Boolean = False);
procedure Unexpected(DoSkip: Boolean = True);
procedure UnexpectedIdentifier(Identifier: PIdentifier; DoSkip: Boolean = True);

function Parse(Text: PAnsiChar): PDocumentInfo;
procedure Next; inline;
procedure EndOfLine; inline;

function GetLength(Start, Stop: PAnsiChar): Cardinal; inline;


function HashString(Text: PAnsiChar): TParserHash;

procedure Init;

implementation

uses Dialogs, ScannerKeywordsJumpTable;

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

{ Error handling }

procedure Expected(TokenType: TTokenType; DoSkip: Boolean = False);
var ErrorInfo: PErrorInfo;
begin
  ErrorInfo := TErrorInfo.Create(eiExpectedToken);
  ErrorInfo.FoundToken := Token.Token;
  ErrorInfo.ExpectedToken := TokenType;

  if Token.Token in [ttIdentifier, ttNumber] then
    ErrorInfo.Info := Token.StrNew;
    
  ErrorInfo.Report;

  if DoSkip then
    Next;
end;

procedure Unexpected(DoSkip: Boolean = True);
var ErrorInfo: PErrorInfo;
begin
  ErrorInfo := TErrorInfo.Create(eiUnexpectedToken);
  ErrorInfo.UnexpectedToken := Token.Token;

  if Token.Token in [ttIdentifier, ttNumber] then
    ErrorInfo.Info := Token.StrNew;

  ErrorInfo.Report;

  if DoSkip then
    Next;
end;

procedure UnexpectedIdentifier(Identifier: PIdentifier; DoSkip: Boolean = True);
var ErrorInfo: PErrorInfo;
begin
  ErrorInfo := TErrorInfo.Create(eiUnexpectedIdentifier);
  ErrorInfo.Identifier := Identifier;
  ErrorInfo.Report;

  if DoSkip then
    Next;
end;

procedure ChildErrors(Document, Child: PDocumentInfo);
var ErrorInfo: PErrorInfo;
begin
  if Child.Errors <> nil then
    Exit;

  ErrorInfo := TErrorInfo.Create(eiChildErrors);
  ErrorInfo.Child := Child;
  ErrorInfo.Start := Child.Start;
  ErrorInfo.Length := GetLength(Child.Start, Child.Stop);
  ErrorInfo.Line := Child.Line;
  ErrorInfo.LineStart := Child.LineStart;
  
  ErrorInfo.Next := Document.Errors;
  Document.Errors := ErrorInfo;

  if Document.Owner <> nil then
    ChildErrors(Document.Owner, Document);
end;

{ TErrorInfo }

procedure TErrorInfo.Report;
begin
  if Token.Error then
    begin
      Free;
      Exit;
    end;

  //Token.Error := True;

  if Token.Document.Owner <> nil then
    ChildErrors(Token.Document.Owner, Token.Document);

  Next := Token.Document.Errors;
  Token.Document.Errors := @Self;
end;

class function TErrorInfo.Create(const ErrorType: TErrorType; const Token: TTokenInfo): PErrorInfo;
begin
  New(Result);
  Result.ErrorType := ErrorType;

  Result.Start := Token.Start;
  Result.Length := Token.Length;
  Result.Line := Token.Line;
  Result.LineStart := Token.LineStart;
  Result.Info := nil;

  if Token.Token = ttLine then
    begin
      Dec(Result.Line);
      Result.Start := Token.Stop;
      Result.Length := 0;
      Result.LineStart := Token.Start;
    end;
end;

class function TErrorInfo.Create(const ErrorType: TErrorType): PErrorInfo;
begin
  Result := Create(ErrorType, Token);
end;

function TErrorInfo.ToString: String;
begin
 case ErrorType of
    eiInvalidChars:
      if Length > 1 then
        Result := 'Invalid characters ''' + Info + ''''
      else
        Result := 'Invalid character ''' + Info + '''';

    eiNumInIdent: Result := 'Identifiers can''t begin with numerals';
    eiChildErrors: Result := PDocumentInfo(Child).Name + ' has errors';
    eiRedeclared: Result := '''' + Identifier.Name + ''' has already been declared';
    eiExpectedIdentifier: Result := 'Expected ''' + IdentifierName[ExpectedIdentifier] + ''', but found ''' + InfoPointer + ''' (' + IdentifierName[FoundIdentifier] + ')';
    eiUndeclaredIdentifier: Result := 'Undeclared identifier ''' + Info + '''';
    eiConstantNeedInit: Result := 'Constant variable ''' + Info + ''' needs initialization';
    eiUnexpectedIdentifier: Result := 'Unexpected identifier ''' + Identifier.Name + ''' (' + IdentifierName[Identifier.IdentifierType] + ')';
    eiRecursive: Result := 'Function ''' + Identifier.Name + ''' can''t recursively call itself';
    
    eiExpectedToken:
      if Info = nil then
        Result := 'Expected ''' + TokenName[ExpectedToken] + ''', but found ''' + TokenName[FoundToken] + ''''
      else
        Result := 'Expected ''' + TokenName[ExpectedToken] + ''', but found ''' + Info + ''' (' + TokenName[FoundToken] + ')';

    eiUnexpectedToken:
      if Info = nil then
        Result := 'Unexpected ''' + TokenName[UnexpectedToken] + ''''
      else
        Result := 'Unexpected ''' + Info + ''' (' + TokenName[UnexpectedToken] + ')';

    else Result := 'Unknown Error';
  end;
end;

procedure TErrorInfo.Free;
begin
  if Info <> nil then
    Dispose(Info);

  Dispose(@Self);
end;

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
      ErrorInfo := ErrorInfo.Next;
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

function Matches(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean;
begin
  if Token.Token <> AToken then
      Result := False
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

procedure EndOfLine;
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
    begin
      Token.Token := ttEnd;
      Token.Stop := Input;
    end;
end;

procedure LineFeedProc;
begin
  Token.Token := ttLine;
  Token.Start := Token.LineStart;
  Token.Stop := Input;

  Inc(Input);

  Inc(Token.Line);

  Token.LineStart := Input;
end;

procedure CarrigeReturnProc;
begin
  Token.Token := ttLine;
  Token.Start := Token.LineStart;
  Token.Stop := Input;

  Inc(Input);

  if Input^ = #10 then
    Inc(Input);

  Inc(Token.Line);

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

      TErrorInfo.Create(eiNumInIdent).Report;
    end
  else
    Token.Stop := Input;
end;

procedure UnknownProc;
var ErrorInfo: PErrorInfo;
begin
  while @JumpTable[Byte(Input^)] = @UnknownProc do
    Inc(Input);

  Token.Stop := Input;

  ErrorInfo := TErrorInfo.Create(eiInvalidChars);
  ErrorInfo.Info := Token.StrNew;
  ErrorInfo.Report;
  
  Next;
end;

procedure WhiteProc;
begin
  while Input^ in White do
    Inc(Input);

  Next;
end;

procedure EqualProc;
begin
  Inc(Input);

  if Input^ = '=' then
    begin
      Inc(Input);
      Token.Token := ttCompare;
    end
  else
    Token.Token := ttEqual;

  Token.Stop := Input;
end;

procedure CommaProc;
begin
  Single(ttComma);
end;

procedure ParentOpenProc;
begin
  Single(ttParentOpen);
end;

procedure ParentCloseProc;
begin
  Single(ttParentClose);
end;

procedure AddProc;
begin
  Single(ttAdd);
end;

procedure SubProc;
begin
  Single(ttSub);
end;

procedure MulProc;
begin
  Single(ttMul);
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

  // White
  for i := #1 to #9 do
    JumpTable[Byte(i)] := WhiteProc;

  JumpTable[Byte(#11)] := WhiteProc;
  JumpTable[Byte(#12)] := WhiteProc;

  for i := #14 to #32 do
    JumpTable[Byte(i)] := WhiteProc;

  // Others
  JumpTable[Byte(#0)] := NullProc;
  JumpTable[Byte(#10)] := LineFeedProc;
  JumpTable[Byte(#13)] := CarrigeReturnProc;
  
  JumpTable[Byte('/')] := CommentProc;
  JumpTable[Byte('=')] := EqualProc;
  JumpTable[Byte(',')] := CommaProc;

  JumpTable[Byte('(')] := ParentOpenProc;
  JumpTable[Byte(')')] := ParentCloseProc;

  JumpTable[Byte('+')] := AddProc;
  JumpTable[Byte('-')] := SubProc;
  JumpTable[Byte('*')] := MulProc;
end;

end.
