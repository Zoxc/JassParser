unit Errors;

interface

uses Tokens, Scope;

type
  TErrorType = (eiInvalidChars, eiNumInIdent, eiExpectedToken, eiUnexpectedToken,
    eiChildErrors, eiRedeclared, eiExpectedIdentifier, eiUndeclaredIdentifier);

  PErrorInfo = ^TErrorInfo;
  TErrorInfo = record
    Start: PAnsiChar;
    Length: Cardinal;
    
    Line: Cardinal;
    LineStart: PAnsiChar;

    Next: PErrorInfo;

    function ToString: String;
    procedure Free;
    
    case ErrorType: TErrorType of
      eiInvalidChars: (Characters: PAnsiChar);
      eiUnexpectedToken: (UnexpectedToken: TTokenType; UnexpectedTokenString: PAnsiChar);
      eiExpectedToken: (ExpectedToken: TTokenType; FoundToken: TTokenType; FoundTokenString: PAnsiChar);
      eiChildErrors: (Child: Pointer);
      eiRedeclared: (Identifier: PIdentifier);
      eiExpectedIdentifier: (ExpectedIdentifier: TIdentifierType; FoundIdentifier: TIdentifierType;  FoundIdentifierString: PAnsiChar);
      eiUndeclaredIdentifier: (IdentifierString: PAnsiChar);
  end;

function NewError(const ErrorType: TErrorType): PErrorInfo;
procedure Error(const ErrorInfo: PErrorInfo);
procedure Expected(TokenType: TTokenType; Skip: Boolean = False);
procedure Unexpected(Skip: Boolean = True);

implementation

uses Scanner;

procedure Expected(TokenType: TTokenType; Skip: Boolean = False);
var ErrorInfo: PErrorInfo;
begin
  ErrorInfo := NewError(eiExpectedToken);
  ErrorInfo.FoundToken := Token.Token;
  ErrorInfo.ExpectedToken := TokenType;

  if Token.Token in [ttIdentifier, ttNumber] then
    ErrorInfo.FoundTokenString := Token.StrNew
  else
    ErrorInfo.FoundTokenString := nil;
    
  Error(ErrorInfo);

  if Skip then
    Next;
end;

procedure Unexpected(Skip: Boolean = True);
var ErrorInfo: PErrorInfo;
begin
  ErrorInfo := NewError(eiUnexpectedToken);
  ErrorInfo.UnexpectedToken := Token.Token;

  if Token.Token in [ttIdentifier, ttNumber] then
    ErrorInfo.UnexpectedTokenString := Token.StrNew
  else
    ErrorInfo.UnexpectedTokenString := nil;

  Error(ErrorInfo);

   if Skip then
      Next;
end;

procedure ChildErrors(Document, Child: PDocumentInfo);
var ErrorInfo: PErrorInfo;
begin
  if Child.Errors <> nil then
    Exit;

  New(ErrorInfo);
  ErrorInfo.ErrorType := eiChildErrors;
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

procedure Error(const ErrorInfo: PErrorInfo);
begin
  if Token.Error then
    begin
      ErrorInfo.Free;
      Exit;
    end;

  //Token.Error := True;

  if Token.Document.Owner <> nil then
    ChildErrors(Token.Document.Owner, Token.Document);

  ErrorInfo.Next := Token.Document.Errors;
  Token.Document.Errors := ErrorInfo;
end;

function NewError(const ErrorType: TErrorType): PErrorInfo;
begin
  New(Result);
  Result.ErrorType := ErrorType;

  Result.Start := Token.Start;
  Result.Length := Token.Length;
  Result.Line := Token.Line;

  if Token.Token = ttLine then
    begin
      Dec(Result.Line);
      Result.LineStart := Token.Start;
    end;

  Result.LineStart := Token.LineStart;
end;

function TErrorInfo.ToString: String;
begin
  case ErrorType of
    eiInvalidChars:
      if Length > 1 then
        Result := 'Unknown characters ''' + Characters + ''''
      else
        Result := 'Unknown character ''' + Characters + '''';

    eiNumInIdent: Result := 'Identifiers can''t begin with numerals';
    eiChildErrors: Result := PDocumentInfo(Child).Name + ' has errors';
    eiRedeclared: Result := '''' + Identifier.Name + ''' has already been declared';
    eiExpectedIdentifier: Result := 'Excepted ''' + IdentifierName[ExpectedIdentifier] + ''', but found ''' + FoundIdentifierString + ''' (' + IdentifierName[FoundIdentifier] + ')';
    eiUndeclaredIdentifier: Result := 'Undeclared identifier ''' + IdentifierString + '''';
    
    eiExpectedToken:
      if FoundTokenString = nil then
        Result := 'Excepted ''' + TokenName[ExpectedToken] + ''', but found ''' + TokenName[FoundToken] + ''''
      else
        Result := 'Excepted ''' + TokenName[ExpectedToken] + ''', but found ''' + FoundTokenString + ''' (' + TokenName[FoundToken] + ')';



    eiUnexpectedToken:
      if UnexpectedTokenString = nil then
        Result := 'Unexpected ''' + TokenName[UnexpectedToken] + ''''
      else
        Result := 'Unexpected ''' + UnexpectedTokenString + ''' (' + TokenName[UnexpectedToken] + ')';

    else Result := 'Unknown Error';
  end;
end;

procedure TErrorInfo.Free;
begin
  case ErrorType of
    eiExpectedToken:
      if FoundTokenString <> nil then
        Dispose(FoundTokenString);

    eiUnexpectedToken:
      if UnexpectedTokenString <> nil then
        Dispose(UnexpectedTokenString);

    eiUndeclaredIdentifier: Dispose(IdentifierString);
    eiInvalidChars: Dispose(Characters);
  end;

  Dispose(@Self);
end;

end.
