unit ScannerKeywordsHash;

interface

uses SysUtils;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Dialogs, Scanner, Tokens, HashExplorer, ComCtrls;

const
  HashTableSize = 80;

type
  TKeywordHashEntry = record
    Node: TTreeNode;
    Keywords: array [0..1] of PAnsiChar;
    Tokens: array [0..1] of TTokenType;
  end;

var
  Keywords: array[0..HashTableSize - 1] of TKeywordHashEntry;


procedure IdentifierProc;
var
  Hash, X: Cardinal;
  C: Char;
  KeywordPointer: PPAnsiChar;
  Keyword: PAnsiChar;
begin
  Token.Token := ttIdentifier;
  Hash := 0;

  C := Input^;

  {$RANGECHECKS OFF}
  {$OVERFLOWCHECKS OFF}

  while C in Ident do
    begin
      Hash := Hash + Ord(C);

      Inc(Input);

      C := Input^;
    end;

  Hash := Hash mod Cardinal(HashTableSize);

  {$OVERFLOWCHECKS ON}
  {$RANGECHECKS ON}

  KeywordPointer := @Keywords[Hash].Keywords[0];

  Keyword := KeywordPointer^;
  X := 0;
  
  while Keyword <> nil do
    begin
      if StrLComp(Token.Start, Keyword, Token.Length) = 0 then
        begin
          Token.Token := Keywords[Hash].Tokens[X];
          Exit;
        end;
        
      Inc(KeywordPointer);
      Inc(X);
      Keyword := KeywordPointer^;
    end;
end;


procedure InitKeywords;
var
  i, x: Integer;
  Hash: Cardinal;
  Keyword: TTokenType;
  KeywordString: PAnsiChar;
begin
  for i := 0 to HashTableSize - 1 do
    begin
      Keywords[i].Node := HashEx.TreeView.Items.AddChild(nil, IntToStr(i));
      
      for x := 0 to High(Keywords[i].Keywords) do
        begin
          Keywords[i].Keywords[x] := nil;
        end;
    end;
    
  for Keyword := ttGlobals to High(TTokenType) do
    begin
      Hash := 0;
      KeywordString := TokenName[Keyword];

      {$RANGECHECKS OFF}
      {$OVERFLOWCHECKS OFF}
      while KeywordString^ <> #0 do
        begin
          Hash := Hash + Ord(KeywordString^);

          Inc(KeywordString);
        end;

      Hash := Hash mod Cardinal(HashTableSize);
      {$RANGECHECKS ON}
      {$OVERFLOWCHECKS ON}

      x := 0;

      while Keywords[Hash].Keywords[x] <> nil do
        begin
          Inc(x);

          if x > High(Keywords[Hash].Keywords) then
            begin
            ShowMessage('Too many collisions on ' + Keywords[Hash].Keywords[0]);
            Exit;
            end;
        end;

      HashEx.TreeView.Items.AddChild(Keywords[Hash].Node, TokenName[Keyword]);

      Keywords[Hash].Node.Expand(False);

      Keywords[Hash].Keywords[x] := TokenName[Keyword];
      Keywords[Hash].Tokens[x] := Keyword;
    end;

  HashEx.Show;
end;

end.
