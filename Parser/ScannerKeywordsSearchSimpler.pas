unit ScannerKeywordsSearchSimpler;

interface

uses SysUtils, IniFiles;

procedure IdentifierProc;
procedure InitKeywords;

implementation

uses Dialogs, Scanner, Tokens, SearchCode, HashExplorer, ComCtrls;

type
  PKeywordArray = ^TKeywordArray;
  TKeywordArray = record
    Hash: Cardinal;
    Node: TTreeNode;
    Keywords: array of TTokenType;
  end;

var
  Hashes: array of TKeywordArray;

procedure IdentifierProc;
var
  Hash, Length: Cardinal;
  C: Char;
  Start: PAnsiChar;

begin
  Token.Token := ttIdentifier;
  Hash := 0;

  C := Input^;

  {$RANGECHECKS OFF}
  {$OVERFLOWCHECKS OFF}
  while C in Ident do
    begin
      Hash := Hash + Byte(C);
      Hash := Hash + (Hash shl 10);
      Hash := Hash xor (Hash shr 6);

      Inc(Input);

      C := Input^;
    end;

  Hash := Hash + (Hash shl 3);
  Hash := Hash xor (Hash shr 11);
  Hash := Hash + (Hash shl 15);

  Token.Stop := Input;
  {$OVERFLOWCHECKS ON}
  {$RANGECHECKS ON}


  {$REGION 'FindKeywords'}

case Hash of
  $6D418C7C:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'globals', Length) = 0 then
        begin
          Token.Token := TTokenType(18);
          Exit;
        end;
    end;

  $AF28C760:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endglobals', Length) = 0 then
        begin
          Token.Token := TTokenType(19);
          Exit;
        end;
    end;

  $18C6A9A2:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'function', Length) = 0 then
        begin
          Token.Token := TTokenType(20);
          Exit;
        end;
    end;

  $791CF138:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endfunction', Length) = 0 then
        begin
          Token.Token := TTokenType(21);
          Exit;
        end;
    end;

  $631DE6AB:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'takes', Length) = 0 then
        begin
          Token.Token := TTokenType(22);
          Exit;
        end;
    end;

  $AC563553:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'returns', Length) = 0 then
        begin
          Token.Token := TTokenType(23);
          Exit;
        end;
    end;

  $E8EE69B5:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'constant', Length) = 0 then
        begin
          Token.Token := TTokenType(24);
          Exit;
        end;
    end;

  $48391B87:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'native', Length) = 0 then
        begin
          Token.Token := TTokenType(25);
          Exit;
        end;
    end;

  $3165B05D:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'type', Length) = 0 then
        begin
          Token.Token := TTokenType(26);
          Exit;
        end;
    end;

  $0AB8480E:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'extends', Length) = 0 then
        begin
          Token.Token := TTokenType(27);
          Exit;
        end;
    end;

  $7BD097A8:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'array', Length) = 0 then
        begin
          Token.Token := TTokenType(28);
          Exit;
        end;
    end;

  $D1C14EE5:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'library', Length) = 0 then
        begin
          Token.Token := TTokenType(29);
          Exit;
        end;
    end;

  $2896F8B8:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endlibrary', Length) = 0 then
        begin
          Token.Token := TTokenType(30);
          Exit;
        end;
    end;

  $EE8E3EEC:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'requires', Length) = 0 then
        begin
          Token.Token := TTokenType(31);
          Exit;
        end;
    end;

  $9B7F29E3:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'needs', Length) = 0 then
        begin
          Token.Token := TTokenType(32);
          Exit;
        end;
    end;

  $CA65CDD9:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'uses', Length) = 0 then
        begin
          Token.Token := TTokenType(33);
          Exit;
        end;
    end;

  $48CD671D:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'initializer', Length) = 0 then
        begin
          Token.Token := TTokenType(34);
          Exit;
        end;
    end;

  $950781AF:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'set', Length) = 0 then
        begin
          Token.Token := TTokenType(35);
          Exit;
        end;
    end;

  $6273D2ED:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'call', Length) = 0 then
        begin
          Token.Token := TTokenType(36);
          Exit;
        end;
    end;

  $6BEDA11E:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'and', Length) = 0 then
        begin
          Token.Token := TTokenType(37);
          Exit;
        end;
    end;

  $CA20FF85:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'not', Length) = 0 then
        begin
          Token.Token := TTokenType(38);
          Exit;
        end;
    end;

  $EF9461CA:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'or', Length) = 0 then
        begin
          Token.Token := TTokenType(39);
          Exit;
        end;
    end;

  $33202F8F:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'scope', Length) = 0 then
        begin
          Token.Token := TTokenType(40);
          Exit;
        end;
    end;

  $9EB12945:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endscope', Length) = 0 then
        begin
          Token.Token := TTokenType(41);
          Exit;
        end;
    end;

  $6F8EF1CC:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'interface', Length) = 0 then
        begin
          Token.Token := TTokenType(42);
          Exit;
        end;
    end;

  $5A0F70E3:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endinterface', Length) = 0 then
        begin
          Token.Token := TTokenType(43);
          Exit;
        end;
    end;

  $CE497FA4:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'defaults', Length) = 0 then
        begin
          Token.Token := TTokenType(44);
          Exit;
        end;
    end;

  $50BC0B6A:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'struct', Length) = 0 then
        begin
          Token.Token := TTokenType(45);
          Exit;
        end;
    end;

  $C165C347:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endstruct', Length) = 0 then
        begin
          Token.Token := TTokenType(46);
          Exit;
        end;
    end;

  $DBD7C7AD:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'method', Length) = 0 then
        begin
          Token.Token := TTokenType(47);
          Exit;
        end;
    end;

  $1A4F7914:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endmethod', Length) = 0 then
        begin
          Token.Token := TTokenType(48);
          Exit;
        end;
    end;

  $AA661628:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'operator', Length) = 0 then
        begin
          Token.Token := TTokenType(49);
          Exit;
        end;
    end;

  $1AB2E0F7:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'return', Length) = 0 then
        begin
          Token.Token := TTokenType(50);
          Exit;
        end;
    end;

  $474BA0A6:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'local', Length) = 0 then
        begin
          Token.Token := TTokenType(51);
          Exit;
        end;
    end;

  $BEBC8707:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'if', Length) = 0 then
        begin
          Token.Token := TTokenType(52);
          Exit;
        end;
    end;

  $C55C3C4E:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endif', Length) = 0 then
        begin
          Token.Token := TTokenType(53);
          Exit;
        end;
    end;

  $E8E4D8BB:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'then', Length) = 0 then
        begin
          Token.Token := TTokenType(54);
          Exit;
        end;
    end;

  $A2F0E9D5:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'else', Length) = 0 then
        begin
          Token.Token := TTokenType(55);
          Exit;
        end;
    end;

  $A9A5BFEE:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'elseif', Length) = 0 then
        begin
          Token.Token := TTokenType(56);
          Exit;
        end;
    end;

  $4C633D07:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'loop', Length) = 0 then
        begin
          Token.Token := TTokenType(57);
          Exit;
        end;
    end;

  $6C655EAC:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'endloop', Length) = 0 then
        begin
          Token.Token := TTokenType(58);
          Exit;
        end;
    end;

  $27EF3B9E:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'exitwhen', Length) = 0 then
        begin
          Token.Token := TTokenType(59);
          Exit;
        end;
    end;

  $AF1B1814:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'private', Length) = 0 then
        begin
          Token.Token := TTokenType(60);
          Exit;
        end;
    end;

  $BB44BA6C:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'public', Length) = 0 then
        begin
          Token.Token := TTokenType(61);
          Exit;
        end;
    end;

  $B594CBD3:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'stub', Length) = 0 then
        begin
          Token.Token := TTokenType(62);
          Exit;
        end;
    end;

  $6022B445:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'static', Length) = 0 then
        begin
          Token.Token := TTokenType(63);
          Exit;
        end;
    end;

  $B0A9C84C:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'delegate', Length) = 0 then
        begin
          Token.Token := TTokenType(64);
          Exit;
        end;
    end;

  $116041A0:
    begin
      Start := Token.Start;
      Length := Cardinal(Token.Stop) - Cardinal(Start);
      if StrLComp(Start, 'keyword', Length) = 0 then
        begin
          Token.Token := TTokenType(65);
          Exit;
        end;
    end;

end;



  {$ENDREGION}


  {
  if Hash < KeywordLow then Exit;
  if Hash > KeywordHigh then Exit;

  for i := ttGlobals to High(TTokenType) do
   if (KeywordChecksums[i] = Hash) and (StrLComp(Token.Start, TokenName[i], Token.Length) = 0) then
      begin
        Token.Token := i;
        Exit;
      end;    }
end;

procedure AddEntry(Hash: Cardinal; TokenType: TTokenType);
var i: Integer;

  procedure Add;
  begin
    SetLength(Hashes[i].Keywords, Length(Hashes[i].Keywords) + 1);
    Hashes[i].Keywords[High(Hashes[i].Keywords)] := TokenType;
    
    HashEx.TreeView.Items.AddChild(Hashes[i].Node, TokenName[TokenType]);
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
  Hashes[i].Node := HashEx.TreeView.Items.AddChild(nil, IntToHex(Hash, 8));
  Add;
end;

procedure InitKeywords;
var
  i: TTokenType;
  Hash: Cardinal;
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
          Hash := Hash + (Hash shl 10);
          Hash := Hash xor (Hash shr 6);

          Inc(Keyword);
        end;
      
      Hash := Hash + (Hash shl 3);
      Hash := Hash xor (Hash shr 11);
      Hash := Hash + (Hash shl 15);
      {$OVERFLOWCHECKS ON}
      {$RANGECHECKS ON}

      AddEntry(Hash, i);
    end;

  SearchForm.Memo.Lines.Add('case Hash of');

  for x := 0 to High(Hashes) do
    begin
      SearchForm.Memo.Lines.Add('  $' + IntToHex(Hashes[x].Hash, 8) + ':');
      SearchForm.Memo.Lines.Add('    begin');
      SearchForm.Memo.Lines.Add('      Start := Token.Start;');
      SearchForm.Memo.Lines.Add('      Length := Cardinal(Token.Stop) - Cardinal(Start);');

      for y := 0 to High(Hashes[x].Keywords) do
        begin
          SearchForm.Memo.Lines.Add('      if StrLComp(Start, ''' + TokenName[Hashes[x].Keywords[y]] + ''', Length) = 0 then');
          SearchForm.Memo.Lines.Add('        begin');
          SearchForm.Memo.Lines.Add('          Token.Token := TTokenType(' + IntToStr(Integer(Hashes[x].Keywords[y])) + ');');
          SearchForm.Memo.Lines.Add('          Exit;');
          SearchForm.Memo.Lines.Add('        end;');
          SearchForm.Memo.Lines.Add('');
        end;
      SearchForm.Memo.Lines.Add('    end;');
      SearchForm.Memo.Lines.Add('');
    end;

  SearchForm.Memo.Lines.Add('end;');

  SearchForm.Show;
  HashExplorer.HashEx.Show;
end;

end.
