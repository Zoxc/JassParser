unit ScannerKeywordsHashedStringList;

interface

uses SysUtils;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Scanner, Tokens, IniFiles;

var Table: THashedStringList;


procedure IdentifierProc;
var
  C: Char;
  Index: Integer;

  S: AnsiString;
begin
  Token.Token := ttIdentifier;

  C := Input^;

  while C in Ident do
    begin
      Inc(Input);

      C := Input^;
    end;

  SetLength(S, Token.Length);
  Move(Token.Start, PAnsiChar(S)^,  Token.Length);

  Index := Table.IndexOf(S);

  if Index = -1 then
    Exit;

  Token.Token := TTokenType(Table.Objects[Index]);
end;


procedure InitKeywords;
var i: TTokenType;
begin
  Table := THashedStringList.Create;
  
  for i := ttGlobals to High(TTokenType) do
    Table.AddObject(TokenName[i], TObject(i));
end;

end.
