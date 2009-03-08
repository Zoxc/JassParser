unit ScannerKeywordsSearchGenerator;

interface

uses SysUtils, IniFiles;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Dialogs, Scanner, Tokens, SearchCode, HashExplorer, ComCtrls;

type
  PKeywordArray = ^TKeywordArray;
  TKeywordArray = record
    Hash: Byte;
    Node: TTreeNode;
    Keywords: array of TTokenType;
  end;

var
  Hashes: array of TKeywordArray;

procedure IdentifierProc;
begin
end;

procedure AddEntry(Hash: Byte; TokenType: TTokenType);
var i: Integer;

  procedure Add;
  begin
    SetLength(Hashes[i].Keywords, Length(Hashes[i].Keywords) + 1);
    Hashes[i].Keywords[High(Hashes[i].Keywords)] := TokenType;
    
    HashEx.TreeView.Items.AddChild(Hashes[i].Node, TokenName[TokenType]);
    Hashes[i].Node.Expand(False);
  end;

begin
  for i := 0 to High(Hashes) do
    if Hashes[i].Hash = Hash then
      begin
        Add;
        Exit;
      end;

  i := Length(Hashes);
  SetLength(Hashes, i + 1);
  Hashes[i].Hash := Hash;
  Hashes[i].Node := HashEx.TreeView.Items.AddChild(nil, IntToHex(Hash, 2));
  Add;
end;

procedure InitKeywords;
var
  i: TTokenType;
  Hash: Byte;
  Keyword: PAnsiChar;
  x, y: Integer;
begin
  for i := ttGlobals to High(TTokenType) do
    begin
      Hash := 0;
      Keyword := TokenName[i];

      {$RANGECHECKS OFF}
      {$OVERFLOWCHECKS OFF}
      while Keyword^ <> #0 do
        begin
          Hash := Hash + Byte(Keyword^);
          {Hash := Hash + (Hash shl 10);
          Hash := Hash xor (Hash shr 6);}

          Inc(Keyword);
        end;
      
      {Hash := Hash + (Hash shl 3);
      Hash := Hash xor (Hash shr 11);
      Hash := Hash + (Hash shl 15);}
      {$OVERFLOWCHECKS ON}
      {$RANGECHECKS ON}

      AddEntry(Hash, i);
    end;

  for x := 0 to High(Hashes) do
    begin
      SearchForm.Memo.Lines.Add('procedure IdentifierHash' + IntToHex(Hashes[x].Hash, 2) + '(Start, Stop: PAnsiChar);');
      SearchForm.Memo.Lines.Add('var');
      SearchForm.Memo.Lines.Add('  Length: Cardinal;');
      SearchForm.Memo.Lines.Add('begin');
      SearchForm.Memo.Lines.Add(' Length := Cardinal(Stop) - Cardinal(Start);');

      for y := 0 to High(Hashes[x].Keywords) do
        begin
          SearchForm.Memo.Lines.Add('');

          if y = 0 then
            SearchForm.Memo.Lines.Add(' if StrLComp(Start, ''' + TokenName[Hashes[x].Keywords[y]] + ''', Length) = 0 then')
          else
            SearchForm.Memo.Lines.Add(' else if StrLComp(Start, ''' + TokenName[Hashes[x].Keywords[y]] + ''', Length) = 0 then');

          SearchForm.Memo.Lines.Add('   begin');
          SearchForm.Memo.Lines.Add('     Token.Token := TTokenType(' + IntToStr(Integer(Hashes[x].Keywords[y])) + ');');
          SearchForm.Memo.Lines.Add('     Exit;');

          if y = High(Hashes[x].Keywords) then
            SearchForm.Memo.Lines.Add('   end;')
          else
            SearchForm.Memo.Lines.Add('   end')
        end;
      SearchForm.Memo.Lines.Add('end;');
      SearchForm.Memo.Lines.Add('');
    end;

  SearchForm.Memo.Lines.Add('procedure InitIdentifierJumpTable;');
  SearchForm.Memo.Lines.Add('var i: Byte;');
  SearchForm.Memo.Lines.Add('begin');
  SearchForm.Memo.Lines.Add('  for i := 0 to 255 do');
  SearchForm.Memo.Lines.Add('    IdentifierJumpTable[i] := nil;');
  SearchForm.Memo.Lines.Add('');

  for x := 0 to High(Hashes) do
      SearchForm.Memo.Lines.Add(' IdentifierJumpTable[$' + IntToHex(Hashes[x].Hash, 2) + '] := IdentifierHash' + IntToHex(Hashes[x].Hash, 2) + ';');

  SearchForm.Memo.Lines.Add('end;');

  SearchForm.Show;
  HashExplorer.HashEx.Show;
end;

end.
