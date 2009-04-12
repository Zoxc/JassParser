unit ScannerHandlers;

interface

uses SysUtils;

procedure EqualProc;
procedure CommaProc;
procedure ParentOpenProc;
procedure ParentCloseProc;
procedure SquareOpenProc;
procedure SquareCloseProc;
procedure AddProc;
procedure SubProc;
procedure MulProc;
procedure WhiteProc;
procedure UnknownProc;
procedure NumProc;
procedure CarrigeReturnProc;
procedure LineFeedProc;
procedure NullProc;
procedure ZeroProc;
procedure RealProc; inline;
procedure ExclamationProc;
procedure GreaterProc;
procedure LessProc;
procedure StringProc;
procedure RawIdProc;
procedure HexProc; inline;
 
implementation

uses Scanner, Tokens;

procedure Single(TokenType: TTokenType); inline;
begin
  Token.Token := TokenType;
  Inc(Input);
  Token.Stop := Input;
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

procedure EqualProc;
begin
  Inc(Input);

  if Input^ = '=' then
    begin
      Inc(Input);
      Token.Token := ttEqual;
    end
  else
    Token.Token := ttAssign;

  Token.Stop := Input;
end;

procedure ExclamationProc;
begin
  Inc(Input);

  if Input^ = '=' then
    begin
      Inc(Input);
      
      Token.Stop := Input;
      Token.Token := ttNotEqual;
    end
  else
    UnknownProc;
end;

procedure LessProc;
begin
  Inc(Input);

  if Input^ = '=' then
    begin
      Inc(Input);
      
      Token.Token := ttLessOrEqual
    end
  else
      Token.Token := ttLess;

  Token.Stop := Input;
end;

procedure GreaterProc;
begin
  Inc(Input);

  if Input^ = '=' then
    begin
      Inc(Input);

      Token.Token := ttGreaterOrEqual
    end
  else
      Token.Token := ttGreater;

  Token.Stop := Input;
end;

procedure RealProc;
begin
  Inc(Input);

  if Input^ in Num then
    begin
      while Input^ in Num do
        Inc(Input);

      Token.Token := ttReal;
      Token.Stop := Input;
    end
  else
    begin
      Token.Token := ttReal;
      Token.Stop := Input;

      TErrorInfo.Create(eiInvalidReal).Report;
    end;
end;

procedure HexProc; inline;
begin
  Inc(Input);

  if Input^ in Hex then
    begin
      while Input^ in Hex do
        Inc(Input);

      Token.Stop := Input;
      Token.Token := ttHex;
    end
  else
    begin
      Token.Stop := Input;
      Token.Token := ttHex;

      TErrorInfo.Create(eiInvalidHex).Report;
    end;
end;

procedure ZeroProc;
begin
    Inc(Input);

    case Input^ of
      'x', 'X': HexProc;

      '.':
        begin
          Inc(Input);

          while Input^ in Num do
            Inc(Input);

          Token.Token := ttReal;
          Token.Stop := Input;
        end;

      '0'..'9': // Octal
        begin
          while Input^ in Octal do
            Inc(Input);

          if Input^ in Num then
            begin
              while Input^ in Num do
                Inc(Input);

              Token.Token := ttOctal;
              Token.Stop := Input;

              TErrorInfo.Create(eiInvalidOctal).Report;
            end
          else
            begin
              Token.Token := ttOctal;
              Token.Stop := Input;
            end;
        end;

      else // Single 0 should be a regular number
        begin
          Token.Token := ttNumber;
          Token.Stop := Input;
        end;
    end;
end;

procedure NumProc;
begin
  Inc(Input);
  
  while Input^ in Num do
    Inc(Input);

  if Input^ = '.' then
    RealProc      
  else
    begin
      Token.Token := ttNumber;
      Token.Stop := Input;
    end;
end;

procedure UnknownProc;
begin
  while @JumpTable[Byte(Input^)] = @UnknownProc do
    Inc(Input);

  Token.Stop := Input;
  Token.Token := ttNone;

  with TErrorInfo.Create(eiInvalidChars)^ do
    begin
      Info := Token.StrNew;
      Report;
    end;
  
  Next;
end;

procedure WhiteProc;
begin
  while Input^ in White do
    Inc(Input);

  Next;
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

procedure SquareOpenProc;
begin
  Single(ttSquareOpen);
end;

procedure SquareCloseProc;
begin
  Single(ttSquareClose);
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

procedure RawIdProc;
var
  RawLength: Cardinal;
begin
  Inc(Input);

  Token.Token := ttRawId;
  RawLength := 0;

  while not (Input^ in ['''', #10, #13, #0]) do
    begin
      if (RawLength > 4) and (Input^ in White) then
        begin
          Token.Stop := Input;

          TErrorInfo.Create(eiUnterminatedRawId).Report;

          Exit;
        end;

      Inc(RawLength);
      Inc(Input);
    end;

  if Input^ = '''' then
    begin
      Inc(Input);

      Token.Stop := Input;


      if not (RawLength in [1, 4]) then
         with TErrorInfo.Create(eiInvalidRawId)^ do
          begin
            RawIdLength := RawLength;

            Report;
          end;
    end
  else
    begin
      Token.Stop := Input;

      TErrorInfo.Create(eiUnterminatedRawId).Report;
    end;
end;

procedure StringProc;
var
  Temp, LineStart: PAnsiChar;
  Line: Integer;
begin
  Inc(Input);

  LineStart := Token.LineStart;
  Line := Token.Line;
  
  Token.Token := ttString;

  while True do
    begin
      case Input^ of
        #0:
          begin
            Token.Stop := Input;
            Token.LineStart := LineStart;
            Token.Line := Line;

            TErrorInfo.Create(eiUnterminatedString).Report;

            Exit;
          end;
        '"':
          begin
            Inc(Input);
      
            Token.Stop := Input;

            Exit;
          end;
        #10:
          begin
            Inc(Token.Line);

            Token.LineStart := PAnsiChar(Cardinal(Input)) + 1;
          end;
        #13:
          begin
            Inc(Token.Line);

            Inc(Input);

            if Input^ <> #10 then
              Dec(Input);

            Token.LineStart := PAnsiChar(Cardinal(Input)) + 1;
          end;
        '\':
          begin
            Inc(Input);
            case Input^ of
              'b', 't', 'r', 'n', 'f', '\':;
              else
                begin
                  Temp := Token.Start;

                  Token.Start := PAnsiChar(Cardinal(Input) - 1);
                  Token.Stop := PAnsiChar(Cardinal(Input) + 1);

                  with TErrorInfo.Create(eiInvalidStringEscape)^ do
                    begin
                      EscapeChar := Input^;
                      Report;
                    end;

                  Token.Start := Temp;
                end;
            end;
          end;
        end;

      Inc(Input);
    end;
end;

end.
