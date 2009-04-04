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

  TRangeInfo = record
    Stop: PAnsiChar;
    Start: PAnsiChar;
    Document: PDocumentInfo;
    Line: Cardinal;
    LineStart: PAnsiChar;
    function Length: Cardinal; inline;
    procedure Create; inline;
    procedure Expand; overload; inline;
    procedure Expand(var Range: TRangeInfo); overload; inline;
  end;

  TDocumentInfo = record
    Name: String;
    Children: PDocumentInfo;
    Errors, LastError: PErrorInfo;
    Start: PAnsiChar;
    Stop: PAnsiChar;
    Owner: PDocumentInfo;
    Line: Cardinal;
    LineStart: PAnsiChar;

    Next: PDocumentInfo;

    Input: PAnsiChar;
    procedure Free;
    procedure GenerateChildErrors;
  end;

  TErrorType = (eiInvalidChars, eiNumInIdent, eiExpectedToken, eiUnexpectedToken,
    eiChildErrors, eiRedeclared, eiExpectedIdentifier, eiUndeclaredIdentifier,
    eiConstantNeedInit, eiUnexpectedIdentifier, eiParameterCount,
    eiWrongReturn, eiDoubleEquals, eiExitWhen, eiInvalidReal, eiInvalidHex,
    eiInvalidOctal, eiUnterminatedRawId, eiInvalidRawId, eiUnterminatedString,
    eiInvalidStringEscape, eiLostLocal, eiArithmetic, eiConvertType,
    eiBoolean, eiUsedInDeclaration, eiUninitializedVariable, eiVariableInConstant,
    eiFunctionInGlobal, eiArrayInitiation, eiFunctionInConstant,
    eiConstantAssignment, eiVariableAssignmentInConstant, eiVariableNotArray,
    eiVariableArray, eiCodeArray, eiConstantLocal, eiCodeParams,
    eiRecursiveLocals, eiNoFunctionParams);

  TErrorInfo = record
    Start: PAnsiChar;
    Length: Cardinal;

    Line: Cardinal;
    LineStart: PAnsiChar;

    Info, InfoPointer: PAnsiChar;

    Next, Prev: PErrorInfo;

    class function Create(const ErrorType: TErrorType): PErrorInfo; overload; static;
    class function Create(const ErrorType: TErrorType; const Token: TTokenInfo): PErrorInfo; overload; static;
    class function Create(const ErrorType: TErrorType; const Range: TRangeInfo): PErrorInfo; overload; static;
    procedure Free;

    procedure Report;
    procedure Pull;
    
    function ToString: String;

    case ErrorType: TErrorType of
      eiUnexpectedToken: (UnexpectedToken: TTokenType);

      eiExpectedToken: (ExpectedToken: TTokenType; FoundToken: TTokenType);

      eiChildErrors: (Child: Pointer);

      eiRedeclared, eiUnexpectedIdentifier, eiWrongReturn, eiArithmetic,
      eiUsedInDeclaration, eiUninitializedVariable, eiVariableInConstant,
      eiFunctionInGlobal, eiArrayInitiation, eiFunctionInConstant,
      eiConstantAssignment, eiVariableAssignmentInConstant, eiVariableNotArray,
      eiVariableArray: (Identifier: PIdentifier);

      eiParameterCount: (CalledFunction: PFunction; ParameterCount: Integer);

      eiInvalidRawId: (RawIdLength: Cardinal);

      eiInvalidStringEscape: (EscapeChar: AnsiChar);

      eiExpectedIdentifier: (ExpectedIdentifier: TIdentifierType; FoundIdentifier: TIdentifierType);

      eiConvertType: (FromType, ToType: PType);
  end;

var
  Token: TTokenInfo;
  Input: PAnsiChar;
  Document: PDocumentInfo;
  JumpTable: array [0..255] of TProcedure;

{ Error handling }

function Match(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean; overload; inline;
function Matches(AToken: TTokenType; GoNext: Boolean = True; Skip: Boolean = False): Boolean; overload; inline;

function Match(AToken: TTokenType; var Range: TRangeInfo; GoNext: Boolean = True; Skip: Boolean = False): Boolean; overload; inline;
function Matches(AToken: TTokenType; var Range: TRangeInfo; GoNext: Boolean = True; Skip: Boolean = False): Boolean; overload; inline;

procedure Expected(TokenType: TTokenType; DoSkip: Boolean = False);
procedure Unexpected(DoSkip: Boolean = True);
procedure UnexpectedIdentifier(Identifier: PIdentifier; DoSkip: Boolean = True);

{ Parsing }

function Parse(Text: PAnsiChar): PDocumentInfo;
procedure Next; inline; overload;
procedure Next(var Range: TRangeInfo); inline; overload;
procedure EndOfLine; inline;

function GetLength(Start, Stop: PAnsiChar): Cardinal; inline;


function HashString(Text: PAnsiChar): TParserHash;

procedure Init;

function ComparePChar(Start, Stop: PAnsiChar; Str: PAnsiChar): Boolean; inline;

implementation

uses ScannerKeywordsJumpTable, ScannerHandlers, TypesUtils;

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

function ComparePChar(Start, Stop: PAnsiChar; Str: PAnsiChar): Boolean;
begin
  Result := False;
  
  while Start^ = Str^ do
    begin
      if Cardinal(Start) >= Cardinal(Stop) then
        Exit;
        
      Inc(Start);
      Inc(Str);

      if Str^ = #0 then
        begin
          Result := True;
          Exit;
        end;
    end;
end;

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

  if Document.Errors = nil then
    Document.Errors := ErrorInfo
  else
    Document.LastError.Next := ErrorInfo;

  Document.LastError := ErrorInfo;

  if Document.Owner <> nil then
    ChildErrors(Document.Owner, Document);
end;

{ TRangeInfo }

procedure TRangeInfo.Create;
begin
  Start := Token.Start;
  Stop := Token.Stop;
  Document := Token.Document;
  Line := Token.Line;
  LineStart := Token.LineStart;

  if Token.Token = ttLine then
    begin
      Dec(Line);
      Start := Token.Stop;
      LineStart := Token.Start;
    end;
end;

procedure TRangeInfo.Expand;
begin
  Stop := Token.Stop;
end;

procedure TRangeInfo.Expand(var Range: TRangeInfo);
begin
  Stop := Range.Stop;
end;

function TRangeInfo.Length: Cardinal;
begin
  Result := Cardinal(Stop) - Cardinal(Start);
end;


{ TErrorInfo }

procedure TErrorInfo.Pull;
begin
  if Token.Document.Errors = @Self then
    Token.Document.Errors := Next;

  if Token.Document.LastError = @Self then
    Token.Document.LastError := Prev;

  if Prev <> nil then
    Prev.Next := Next;

  if Next <> nil then
    Next.Prev := Prev;

  Free;
end;

procedure TErrorInfo.Report;
begin
  if Token.Error then
    begin
      Free;
      Exit;
    end;

  Token.Error := True;

  //if Token.Document.Owner <> nil then
   // ChildErrors(Token.Document.Owner, Token.Document);

  Next := nil;

  if Token.Document.Errors = nil then
    Token.Document.Errors := @Self;

  Prev := Token.Document.LastError;

  if Token.Document.LastError <> nil then
    Token.Document.LastError.Next := @Self;
  
  Token.Document.LastError := @Self;
end;

class function TErrorInfo.Create(const ErrorType: TErrorType; const Range: TRangeInfo): PErrorInfo;
begin
  New(Result);
  Result.ErrorType := ErrorType;

  Result.Start := Range.Start;
  Result.Length := Range.Length;
  Result.Line := Range.Line;
  Result.LineStart := Range.LineStart;
  Result.Info := nil;
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

    eiConvertType: Result := 'Unable to convert type ''' + FromType.Name + ''' to type ''' + ToType.Name + '''';
    eiBoolean: Result := 'Cannot perform logic operations on type ''' + Identifier.Name + '''';
    eiArithmetic: Result := 'Cannot perform arithmetic operations on type ''' + Identifier.Name + '''';
    eiExitWhen: Result := '''exitwhen'' without a loop';
    eiDoubleEquals: Result := 'You need two equal signs to do a equality test';
    eiNumInIdent: Result := 'Identifiers can''t begin with numerals';
    eiInvalidReal: Result := 'Invalid floating point number';
    eiInvalidHex: Result := 'Invalid hex number';
    eiLostLocal: Result := 'Local variable declarations must be at the start of a function';
    eiInvalidOctal: Result := 'Invalid octal number';
    eiChildErrors: Result := PDocumentInfo(Child).Name + ' has errors';
    eiConstantLocal: Result := 'Local variables can not be constant';
    eiNoFunctionParams: Result := 'Function calls must have a parameter list';
    eiRecursiveLocals: Result := 'Recursive function calls are not permitted in local declarations';
    eiCodeParams: Result := 'Function ''' + Identifier.Name + ''' passed as code can''t have parameters';
    eiRedeclared: Result := '''' + Identifier.Name + ''' has already been declared as a ' + InfoPointer;
    eiArrayInitiation: Result := 'Array variable ''' + Identifier.Name + ''' can''t be initialized';
    eiUsedInDeclaration: Result := '''' + Identifier.Name + ''' is used in it''s own declaration';
    eiVariableNotArray: Result := 'Variable ''' + Identifier.Name + ''' is not an array';
    eiVariableArray: Result := 'Variable ''' + Identifier.Name + ''' is an array';
    eiVariableInConstant: Result := 'Variable ''' + Identifier.Name + ''' is not constant';
    eiCodeArray: Result := 'Type ''code'' can''t be used to create an array';
    eiVariableAssignmentInConstant: Result := 'Can''t assign to variable ''' + Identifier.Name + ''' in a constant function';
    eiFunctionInConstant: Result := 'Function ''' + Identifier.Name + ''' is not constant';
    eiFunctionInGlobal: Result := 'User function ''' + Identifier.Name + ''' can''t be used in globals';
    eiUninitializedVariable: Result := '''' + Identifier.Name + ''' is used before it''s initialized';
    eiExpectedIdentifier: Result := 'Expected ''' + IdentifierName[ExpectedIdentifier] + ''', but found ''' + InfoPointer + ''' (' + IdentifierName[FoundIdentifier] + ')';
    eiUndeclaredIdentifier: Result := 'Undeclared identifier ''' + Info + '''';
    eiConstantNeedInit: Result := 'Constant variable ''' + Info + ''' needs initialization';
    eiUnexpectedIdentifier: Result := 'Unexpected identifier ''' + Identifier.Name + ''' (' + IdentifierName[Identifier.IdentifierType] + ')';
    eiParameterCount: Result := 'Function ''' + CalledFunction.Name + ''' needs ' + IntToStr(System.Length(CalledFunction.Header.Parameters)) + ' parameters, but found ' + IntToStr(ParameterCount);
    eiUnterminatedRawId: Result := 'The raw id was not terminated';
    eiUnterminatedString: Result := 'The string was not terminated';
    eiInvalidStringEscape: Result := '''' + EscapeChar + ''' is not a valid string escape character';
    eiInvalidRawId: Result := 'Raw id with size ' + IntToStr(RawIdLength) + ' found, but the length must be 4 or 1';

    eiWrongReturn:
      if PFunction(Identifier).Header.Returns = NothingType then
        Result := 'Cannot return a value from function ''' + Identifier.Name + ''''
      else
        Result := 'Cannot return without a value from function ''' + Identifier.Name + '''';
        
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
  Document.LastError := nil;
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

procedure TDocumentInfo.GenerateChildErrors;
var
  DocumentInfo: PDocumentInfo;
begin
  DocumentInfo := Children;

  while DocumentInfo <> nil do
    begin
      if DocumentInfo.Errors <> nil then
         with TErrorInfo.Create(eiChildErrors)^ do
          begin
            Child := DocumentInfo;
            Start := DocumentInfo.Start;
            Length := GetLength(DocumentInfo.Start, DocumentInfo.Stop);
            Line := DocumentInfo.Line;
            LineStart := DocumentInfo.LineStart;

            Report;
          end;

      DocumentInfo.GenerateChildErrors;
      DocumentInfo := DocumentInfo.Next;
    end;
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

function Matches(AToken: TTokenType; var Range: TRangeInfo; GoNext: Boolean = True; Skip: Boolean = False): Boolean; inline; overload;
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
            Next(Range);
        end;
      Result := True;
    end;
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

function Match(AToken: TTokenType; var Range: TRangeInfo; GoNext: Boolean = True; Skip: Boolean = False): Boolean; inline; overload;
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
          Next(Range);
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
  Doc.LastError := nil;
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

procedure Next(var Range: TRangeInfo);
begin
  Range.Expand;
  Next;
end;

procedure Next;
begin
    Token.Start := Input;

    if Token.Error then
      Token.Error := False;

    JumpTable[Byte(Input^)];
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
  for i := '1' to '9' do
    JumpTable[Byte(i)] := NumProc;

  JumpTable[Byte('0')] := ZeroProc;
  JumpTable[Byte('.')] := RealProc;
  JumpTable[Byte('$')] := HexProc;

  // White
  for i := #1 to #9 do
    JumpTable[Byte(i)] := WhiteProc;

  JumpTable[Byte(#11)] := WhiteProc;
  JumpTable[Byte(#12)] := WhiteProc;

  for i := #14 to #32 do
    JumpTable[Byte(i)] := WhiteProc;

  // Comparasions
  JumpTable[Byte('=')] := EqualProc;
  JumpTable[Byte('!')] := ExclamationProc;
  JumpTable[Byte('<')] := LessProc;
  JumpTable[Byte('>')] := GreaterProc;

  // Others
  JumpTable[Byte(#0)] := NullProc;
  JumpTable[Byte(#10)] := LineFeedProc;
  JumpTable[Byte(#13)] := CarrigeReturnProc;

  JumpTable[Byte('"')] := StringProc;
  JumpTable[Byte('''')] := RawIdProc;
  
  JumpTable[Byte('/')] := CommentProc;
  JumpTable[Byte(',')] := CommaProc;

  JumpTable[Byte('(')] := ParentOpenProc;
  JumpTable[Byte(')')] := ParentCloseProc;

  JumpTable[Byte('[')] := SquareOpenProc;
  JumpTable[Byte(']')] := SquareCloseProc;

  // Math

  JumpTable[Byte('+')] := AddProc;
  JumpTable[Byte('-')] := SubProc;
  JumpTable[Byte('*')] := MulProc;
end;

end.
