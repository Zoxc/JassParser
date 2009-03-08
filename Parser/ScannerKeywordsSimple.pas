unit ScannerKeywordsSimple;

interface

uses SysUtils;

procedure IdentifierProc;
procedure InitKeywords; inline;

implementation

uses Scanner, Tokens;

procedure IdentifierProc;
var
  i: TTokenType;
  C: Char;
begin
  Token.Token := ttIdentifier;

  C := Input^;

  while C in Ident do
    begin
      Inc(Input);

      C := Input^;
    end;

  for i := ttGlobals to High(TTokenType) do
   if (StrLComp(Token.Start, TokenName[i], Token.Length) = 0) then
      begin
        Token.Token := i;
        Exit;
      end;     
end;


procedure InitKeywords;
begin
end;

end.
