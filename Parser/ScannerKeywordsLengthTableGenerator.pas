unit ScannerKeywordsLengthTableGenerator;

interface

uses SysUtils, IniFiles, Classes;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Dialogs, Scanner, Tokens, SearchCode, HashExplorer, ComCtrls, Math, GeneratorCommon;

type
  PKeywordInfo = ^TKeywordInfo;
  TKeywordInfo = record
    Node: TTreeNode;
    StrLength: Integer;
    Str: PAnsiChar;
    Hash: Byte;
    Keyword: TTokenType;
  end;

  PHash = ^THash;
  THash = record
    Hash: Byte;
    StrLength: Integer;
    Node: TTreeNode;
    Keywords: array of PKeywordInfo;
  end;

  PLength = ^TLength;
  TLength = record
    StrLength: Integer;
    Node: TTreeNode;
    LowHash, HighHash: Byte;
    Hashes: array of THash;
  end;

var
  Lengths: array of TLength;
  LengthsHigh: Integer;

procedure IdentifierProc;
begin
end;

procedure AddKeyword(Hash: PHash; Info: PKeywordInfo);
var i: Integer;
begin
  for i := 0 to High(Hash.Keywords) do
    if (Hash.Keywords[i] = Info) then
      begin
        ShowMessage(Info.Str + ' is twince in (Length: ' + IntToStr(Info.StrLength)+ ', Hash: ' + IntToHex(Info.Hash, 2) + ')');
        Exit;
      end;
      
  i := Length(Hash.Keywords);
  SetLength(Hash.Keywords, i + 1);
  Info.Node := HashEx.TreeView.Items.AddChild(Hash.Node, Info.Str);
  Hash.Keywords[i] := Info;
end;

procedure AddHash(ALength: PLength; Info: PKeywordInfo);
var i: Integer;
begin
  for i := 0 to High(ALength.Hashes) do
    if (ALength.Hashes[i].Hash = Info.Hash) then
      begin
        AddKeyword(@ALength.Hashes[i], Info);
        ALength.LowHash := Min(Info.Hash, ALength.LowHash);
        ALength.HighHash := Max(Info.Hash, ALength.HighHash);
        Exit;
      end;
      
  i := Length(ALength.Hashes);
  SetLength(ALength.Hashes, i + 1);
  ALength.Hashes[i].Hash := Info.Hash;
  ALength.Hashes[i].StrLength := Info.StrLength;
  ALength.Hashes[i].Node := HashEx.TreeView.Items.AddChild(ALength.Node, IntToHex(Info.Hash, 2));
  ALength.LowHash := Min(Info.Hash, ALength.LowHash);
  ALength.HighHash := Max(Info.Hash, ALength.HighHash);
  AddKeyword(@ALength.Hashes[i], Info);
end;

procedure AddEntry(Info: PKeywordInfo);
var i: Integer;
begin
  for i := 0 to High(Lengths) do
    if Lengths[i].StrLength = Info.StrLength then
      begin
        AddHash(@Lengths[i], Info);
        Lengths[i].Node.Expand(True);
        Exit;
      end;
      
  i := Length(Lengths);
  SetLength(Lengths, i + 1);
  Lengths[i].LowHash := High(Byte);
  Lengths[i].HighHash := Low(Byte);
  Lengths[i].StrLength := Info.StrLength;
  Lengths[i].Node := HashEx.TreeView.Items.AddChild(nil, IntToStr(Info.StrLength));
  AddHash(@Lengths[i], Info);
  Lengths[i].Node.Expand(True);
end;

function Compare(Item1, Item2: Pointer): Integer;
begin
  Result := PKeywordInfo(Item1).StrLength -  PKeywordInfo(Item2).StrLength;
  
  if Result = 0 then
    Result := PKeywordInfo(Item1).Hash -  PKeywordInfo(Item2).Hash;
end;

procedure GenerateHash(Hash: PHash);
var
  i: Integer;
  
  function GetLabel: string; overload;
  begin
    Result := '@Check_' + IntToStr(Hash.StrLength) + '_' + IntToHex(Hash.Hash, 2);
  end;

  function GetLabel(Index: Integer): string; overload;
  begin
    Result := GetLabel + '_' + IntToStr(Index);
  end;

  function EvadeLabel: string;
  begin
    Result := GetLabel(i + 1);
  end;
begin
  SearchForm.Memo.Lines.Add('');
  SearchForm.Memo.Lines.Add(GetLabel + ':');

  for i := 0 to High(Hash.Keywords) do
    begin
        if i <> 0 then
          begin
            SearchForm.Memo.Lines.Add('');
            SearchForm.Memo.Lines.Add(GetLabel(i) + ':');
          end;
          
        SearchForm.Memo.Lines.Add('');
        CompareKeyword(TokenName[Hash.Keywords[i].Keyword], 'ecx', EvadeLabel);

        SearchForm.Memo.Lines.Add('');
        SearchForm.Memo.Lines.Add('  mov [Token.Token], '+ IntToStr(Integer(Hash.Keywords[i].Keyword)));

        if i <> High(Hash.Keywords) then
          SearchForm.Memo.Lines.Add('  ret');
    end;

  SearchForm.Memo.Lines.Add(GetLabel(Length(Hash.Keywords)) + ':');
  SearchForm.Memo.Lines.Add('  ret');
end;

procedure GenerateLengths;
var
  i, x: Integer;
  Length: PLength;

    procedure FindLength;
    var x: Integer;
    begin
      for x := 0 to High(Lengths) do
        if Lengths[x].StrLength = i then
          begin
            Length := @Lengths[x];
            Exit;
          end;
      Length := nil;
    end;
begin
  for i := 0 to LengthsHigh do
    begin
      FindLength;
      if Length = nil then
        SearchForm.Memo.Lines.Add(' dd @Return')
      else
        SearchForm.Memo.Lines.Add(' dd @Check_' + IntToStr(Length.StrLength));
    end;

  for i := 0 to LengthsHigh do
    begin
      FindLength;
      if Length <> nil then
        begin
          SearchForm.Memo.Lines.Add('');
          SearchForm.Memo.Lines.Add('@Check_' + IntToStr(Length.StrLength) + ':');

          if Length.HighHash - Length.LowHash < $20 then
            begin
              SearchForm.Memo.Lines.Add('  sub al, $' + IntToHex(Length.LowHash, 2));
              SearchForm.Memo.Lines.Add('  cmp al, $' + IntToHex(Length.HighHash - Length.LowHash, 2));
              SearchForm.Memo.Lines.Add('  jbe @Check_' + IntToStr(Length.StrLength) + '_InRange');
              SearchForm.Memo.Lines.Add('  ret');
              SearchForm.Memo.Lines.Add('');
              SearchForm.Memo.Lines.Add('@Check_' + IntToStr(Length.StrLength) + '_InRange:');

              for x := 0 to High(Length.Hashes) do
                begin
                  SearchForm.Memo.Lines.Add('  cmp al, $' + IntToHex(Length.Hashes[x].Hash - Length.LowHash, 2));
                  SearchForm.Memo.Lines.Add('  je @Check_' + IntToStr(Length.StrLength) + '_' + IntToHex(Length.Hashes[x].Hash, 2));
                end;
            end
          else
            for x := 0 to High(Length.Hashes) do
              begin
                SearchForm.Memo.Lines.Add('  cmp al, $' + IntToHex(Length.Hashes[x].Hash, 2));
                SearchForm.Memo.Lines.Add('  je @Check_' + IntToStr(Length.StrLength) + '_' + IntToHex(Length.Hashes[x].Hash, 2));
              end;

          SearchForm.Memo.Lines.Add('  ret');
        end;
    end;

  for i := 0 to LengthsHigh do
    begin
      FindLength;
      if Length <> nil then
        for x := 0 to High(Length.Hashes) do
          GenerateHash(@Length.Hashes[x]);
    end;
end;

procedure InitKeywords;
var
  i: TTokenType;
  Hash: Byte;
  Keyword: PAnsiChar;
  x: Integer;
  Test: TList;
  Info: PKeywordInfo;

begin
  Test := TList.Create;

  LengthsHigh := Low(Integer);

  for i := ttGlobals to High(TTokenType) do
    begin
      Hash := 0;
      Keyword := TokenName[i];
      LengthsHigh := Max(LengthsHigh, StrLen(Keyword));
      
      {$RANGECHECKS OFF}
      {$OVERFLOWCHECKS OFF}
      while Keyword^ <> #0 do
        begin
          Hash := Hash + Byte(Keyword^);

          Inc(Keyword);
        end;

      {$OVERFLOWCHECKS ON}
      {$RANGECHECKS ON}

      New(Info);
      Info.Str := TokenName[i];
      Info.Hash := Hash;
      Info.Keyword := i;
      Info.StrLength := StrLen(TokenName[i]);
      Test.Add(Info);
    end;

  Test.Sort(@Compare);

  for x := 0 to Test.Count - 1 do
      AddEntry(Test[x]);

  SearchForm.Memo.Lines.Add('  cmp edx, ' + IntToStr(LengthsHigh));
  SearchForm.Memo.Lines.Add('  ja @Return');
  SearchForm.Memo.Lines.Add('  jmp dword ptr [@JumpTable + edx * 4]');
  SearchForm.Memo.Lines.Add('');
  SearchForm.Memo.Lines.Add('@Return:');
  SearchForm.Memo.Lines.Add('  ret');
  SearchForm.Memo.Lines.Add('');
  SearchForm.Memo.Lines.Add('@JumpTable:');

  GenerateLengths;

  SearchForm.Show;
  HashExplorer.HashEx.Show;
  Test.Free;
end;



end.
