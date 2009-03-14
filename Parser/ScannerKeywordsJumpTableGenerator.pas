unit ScannerKeywordsJumpTableGenerator;

interface

uses SysUtils, IniFiles, Classes;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Dialogs, Scanner, Tokens, SearchCode, HashExplorer, ComCtrls, Math;

type
  PKeywordArray = ^TKeywordArray;
  TKeywordArray = record
    Hash: Byte;
    Node: TTreeNode;
    Lengths: array of TTokenType;
    Keywords: array of TTokenType;
  end;

  PKeywordPair = ^TKeywordPair;
  TKeywordPair = record
    Hash: Byte;
    Keyword: TTokenType;
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

function Compare(Item1, Item2: Pointer): Integer;
begin
  Result := PKeywordPair(Item1).Hash -  PKeywordPair(Item2).Hash;
end;

procedure InitKeywords;
var
  i: TTokenType;
  Hash: Byte;
  Keyword: PAnsiChar;
  x, y,Len,z, kl, lenlow, lenhigh: Integer;
  Test: TList;
  Pair: PKeywordPair;

  procedure FindHash;
  var i: Integer;
  begin
    for i := 0 to High(Hashes) do
      if Hashes[i].Hash = x then
        begin
          y := i;
          Exit;
        end;
    y := -1;
  end;
begin
  Test := TList.Create;

  lenlow := High(Integer);
  lenhigh := Low(Integer);

  for i := ttGlobals to High(TTokenType) do
    begin
      Hash := 0;
      Keyword := TokenName[i];
      lenlow := Min(lenlow, StrLen(Keyword));
      lenhigh := Max(lenhigh, StrLen(Keyword));

      {$RANGECHECKS OFF}
      {$OVERFLOWCHECKS OFF}
      while Keyword^ <> #0 do
        begin
          Hash := Hash + Byte(Keyword^);

          Inc(Keyword);
        end;

      {$OVERFLOWCHECKS ON}
      {$RANGECHECKS ON}

      New(Pair);
      Pair.Hash := Hash;
      Pair.Keyword := i;


      Test.Add(Pair);
    end;

  Test.Sort(@Compare);

  for x := 0 to Test.Count - 1 do
    begin
      AddEntry(PKeywordPair(Test[x]).Hash, PKeywordPair(Test[x]).Keyword);
      Dispose(Test[x]);
    end;

  SearchForm.Memo.Lines.Add('  sub edx, ' + IntToStr(lenlow));
  SearchForm.Memo.Lines.Add('  cmp edx, ' + IntToStr(lenhigh - lenlow));
  SearchForm.Memo.Lines.Add('  jbe @CheckKeywords');
  SearchForm.Memo.Lines.Add('  ret');
  SearchForm.Memo.Lines.Add('');
  SearchForm.Memo.Lines.Add('@CheckKeywords:');
  SearchForm.Memo.Lines.Add('  jmp dword ptr [JumpTable + eax * 4]');
  SearchForm.Memo.Lines.Add('');
  SearchForm.Memo.Lines.Add('@Return:');
  SearchForm.Memo.Lines.Add('  ret');
  SearchForm.Memo.Lines.Add('');
  SearchForm.Memo.Lines.Add('@JumpTable:');

  for x := 0 to 255 do
    begin
      FindHash;
      if y = -1 then
        SearchForm.Memo.Lines.Add(' dd @Return')
      else
        SearchForm.Memo.Lines.Add(' dd @Check' + IntToHex(x, 2));
    end;

  // Generate length checks

  for x := 0 to High(Hashes) do
    begin
      SearchForm.Memo.Lines.Add('');
      SearchForm.Memo.Lines.Add('@Check' + IntToHex(Hashes[x].Hash, 2) + ':');

      Test.Clear;

      for y := 0 to High(Hashes[x].Keywords) do
        begin
          len := StrLen(TokenName[Hashes[x].Keywords[y]]);
          if Test.IndexOf(Pointer(len)) = -1 then
            Test.Add(Pointer(len));
        end;

      for y := 0 to Test.Count -1 do
        begin
          SearchForm.Memo.Lines.Add('  cmp edx, ' + IntToStr(Integer(Test[y]) - lenlow));
          SearchForm.Memo.Lines.Add('  je @Compare' + IntToHex(Hashes[x].Hash, 2) + '_' + IntToStr(Integer(Test[y]))+'_0');
        end;

      SearchForm.Memo.Lines.Add('  ret');
    end;

  // Full comparasions
  
  for x := 0 to High(Hashes) do
    begin
      Test.Clear;

      for y := 0 to High(Hashes[x].Keywords) do
        begin
          len := StrLen(TokenName[Hashes[x].Keywords[y]]);
          if Test.IndexOf(Pointer(len)) = -1 then
            Test.Add(Pointer(len));
        end;

      SearchForm.Memo.Lines.Add(' ');

      for z := 0 to Test.Count -1 do
        begin
          len := 0;
          
          for y := 0 to High(Hashes[x].Keywords) do
            if StrLen(TokenName[Hashes[x].Keywords[y]]) = Cardinal(Test[z]) then
              Inc(len);

          SearchForm.Memo.Lines.Add('@Compare' + IntToHex(Hashes[x].Hash, 2) + '_' + IntToStr(Integer(Test[z]))+'_' + IntToStr(len)+':');
        end;

      SearchForm.Memo.Lines.Add('  ret');


      for z := 0 to Test.Count -1 do
        begin
          len := 0;
          for y := 0 to High(Hashes[x].Keywords) do
            if StrLen(TokenName[Hashes[x].Keywords[y]]) = Cardinal(Test[z]) then
              begin
                SearchForm.Memo.Lines.Add('');
                SearchForm.Memo.Lines.Add('@Compare' + IntToHex(Hashes[x].Hash, 2) + '_' + IntToStr(Integer(Test[z]))+'_' + IntToStr(len)+':');

                Keyword := TokenName[Hashes[x].Keywords[y]];
                kl := 0;

                SearchForm.Memo.Lines.Add('');

                while Keyword^ <> #0 do
                  begin
                    SearchForm.Memo.Lines.Add('  mov al, [ecx+'+IntToStr(kl)+']; cmp al, ''' + Keyword^ + '''; jne @Compare' + IntToHex(Hashes[x].Hash, 2) + '_' + IntToStr(Integer(Test[z]))+'_' + IntToStr(len + 1));
                    Inc(kl);
                    Inc(Keyword);
                  end;
                
                SearchForm.Memo.Lines.Add('');
                SearchForm.Memo.Lines.Add('  mov [Token.Token], '+ IntToStr(Integer(Hashes[x].Keywords[y])));
                SearchForm.Memo.Lines.Add('  ret');

                Inc(len);
              end;
          end;
        SearchForm.Memo.Lines.Add('');
    end;

  SearchForm.Show;
  HashExplorer.HashEx.Show;
  Test.Free;
end;



end.
