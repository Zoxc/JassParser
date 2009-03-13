unit ScannerKeywordsJumpTableGenerator;

interface

uses SysUtils, IniFiles, Classes;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Dialogs, Scanner, Tokens, SearchCode, HashExplorer, ComCtrls;

type
  PKeywordArray = ^TKeywordArray;
  TKeywordArray = record
    Hash: Byte;
    Node: TTreeNode;
    Lengths: array of TTokenType;
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

procedure Compare(Start, Stop: PAnsiChar); register; assembler;
asm
  sub edx, eax;
  cmp edx, 4
  je @comp1
  ret

@comp1:
  push ecx

  mov cl, [eax+0]
  cmp cl, 't'
  jne @ret

  movzx ecx, [eax+1]
  cmp cl, 'e'
  jne @ret

  movzx ecx, [eax+2]
  cmp cl, 's'
  jne @ret

  movzx ecx, [eax+3]
  cmp cl, 't'
  jne @ret

  mov [Token.Token], 1

@ret:
  pop ecx
end;

procedure InitKeywords;
var
  i: TTokenType;
  Hash: Byte;
  Keyword: PAnsiChar;
  x, y,Len,z, kl: Integer;
  Test: TList;
begin
  Test := TList.Create;
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
      SearchForm.Memo.Lines.Add('procedure IdentifierHash' + IntToHex(Hashes[x].Hash, 2) + '(Start, Stop: PAnsiChar); assembler;');
      SearchForm.Memo.Lines.Add('asm');
      SearchForm.Memo.Lines.Add('  sub edx, eax');

      Test.Clear;

      for y := 0 to High(Hashes[x].Keywords) do
        begin
          len := StrLen(TokenName[Hashes[x].Keywords[y]]);
          if Test.IndexOf(Pointer(len)) = -1 then
            Test.Add(Pointer(len));
        end;

      for y := 0 to Test.Count -1 do
        begin
          SearchForm.Memo.Lines.Add(' ');
          SearchForm.Memo.Lines.Add('  cmp edx, ' + IntToStr(Integer(Test[y])));
          SearchForm.Memo.Lines.Add('  je @Compare' + IntToStr(Integer(Test[y]))+'_0');
        end;

      SearchForm.Memo.Lines.Add(' ');

      for z := 0 to Test.Count -1 do
        begin
          len := 0;
          
          for y := 0 to High(Hashes[x].Keywords) do
            if StrLen(TokenName[Hashes[x].Keywords[y]]) = Cardinal(Test[z]) then
              Inc(len);

          SearchForm.Memo.Lines.Add('@Compare' + IntToStr(Integer(Test[z]))+'_' + IntToStr(len)+':');
        end;

      SearchForm.Memo.Lines.Add('  ret');


      for z := 0 to Test.Count -1 do
        begin
          len := 0;
          for y := 0 to High(Hashes[x].Keywords) do
            if StrLen(TokenName[Hashes[x].Keywords[y]]) = Cardinal(Test[z]) then
              begin
                SearchForm.Memo.Lines.Add('');
                SearchForm.Memo.Lines.Add('@Compare' + IntToStr(Integer(Test[z]))+'_' + IntToStr(len)+':');

                Keyword := TokenName[Hashes[x].Keywords[y]];
                kl := 0;

                while Keyword^ <> #0 do
                  begin
                    SearchForm.Memo.Lines.Add('');
                    SearchForm.Memo.Lines.Add('  mov cl, [eax+'+IntToStr(kl)+']');
                    SearchForm.Memo.Lines.Add('  cmp cl, ''' + Keyword^ + '''');
                    SearchForm.Memo.Lines.Add('  jne @Compare' + IntToStr(Integer(Test[z]))+'_' + IntToStr(len + 1));
                    Inc(kl);
                    Inc(Keyword);
                  end;
                
                SearchForm.Memo.Lines.Add('');
                SearchForm.Memo.Lines.Add('  mov [Token.Token], '+ IntToStr(Integer(Hashes[x].Keywords[y])));
                SearchForm.Memo.Lines.Add('  ret');

                Inc(len);
              end;
          end;
      SearchForm.Memo.Lines.Add('end;');
      SearchForm.Memo.Lines.Add('');
    end;


  SearchForm.Memo.Lines.Add('procedure InitKeywords;');
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
  Test.Free;
end;



end.
