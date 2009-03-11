unit ScannerKeywordsSearch;

interface

uses SysUtils;

procedure IdentifierProc;
procedure InitKeywords;

implementation

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

uses Scanner, Tokens, Scope;

var
  IdentifierJumpTable: array [TParserHash] of procedure(Start, Stop: PAnsiChar);

procedure IdentifierProc;
var
  Hash: TParserHash;
  C: Char;
  Start: PAnsiChar;
  Proc: procedure(Start, Stop: PAnsiChar);
begin
  Token.Token := ttIdentifier;
  Hash := 0;

  Start := Input;

  C := Input^;


  while C in Ident do
    begin
      Hash := Hash + Byte(C);

      Inc(Input);

      C := Input^;
    end;

  Token.Stop := Input;
  Token.Hash := Hash;

  Proc := IdentifierJumpTable[Hash];

  if @Proc = nil then
    Exit;

  Proc(Start, Input);  
end;

{$REGION 'JumpTable'}
procedure IdentifierHashE4(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'globals', Length) = 0 then
   begin
     Token.Token := TTokenType(18);
     Exit;
   end;
end;

procedure IdentifierHash1B(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endglobals', Length) = 0 then
   begin
     Token.Token := TTokenType(19);
     Exit;
   end;
end;

procedure IdentifierHash66(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'function', Length) = 0 then
   begin
     Token.Token := TTokenType(20);
     Exit;
   end;
end;

procedure IdentifierHash9D(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endfunction', Length) = 0 then
   begin
     Token.Token := TTokenType(21);
     Exit;
   end;
end;

procedure IdentifierHash18(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'takes', Length) = 0 then
   begin
     Token.Token := TTokenType(22);
     Exit;
   end;
end;

procedure IdentifierHash13(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'returns', Length) = 0 then
   begin
     Token.Token := TTokenType(23);
     Exit;
   end;
end;

procedure IdentifierHashF7(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'nothing', Length) = 0 then
   begin
     Token.Token := TTokenType(24);
     Exit;
   end;
end;

procedure IdentifierHash6A(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'constant', Length) = 0 then
   begin
     Token.Token := TTokenType(25);
     Exit;
   end;
end;

procedure IdentifierHash87(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'native', Length) = 0 then
   begin
     Token.Token := TTokenType(26);
     Exit;
   end;
end;

procedure IdentifierHashC2(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'type', Length) = 0 then
   begin
     Token.Token := TTokenType(27);
     Exit;
   end;
end;

procedure IdentifierHashFB(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'extends', Length) = 0 then
   begin
     Token.Token := TTokenType(28);
     Exit;
   end

 else if StrLComp(Start, 'private', Length) = 0 then
   begin
     Token.Token := TTokenType(62);
     Exit;
   end;
end;

procedure IdentifierHash1F(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'array', Length) = 0 then
   begin
     Token.Token := TTokenType(29);
     Exit;
   end;
end;

procedure IdentifierHashF5(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'library', Length) = 0 then
   begin
     Token.Token := TTokenType(30);
     Exit;
   end;
end;

procedure IdentifierHashF9(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'library_once', Length) = 0 then
   begin
     Token.Token := TTokenType(31);
     Exit;
   end;
end;

procedure IdentifierHash2C(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endlibrary', Length) = 0 then
   begin
     Token.Token := TTokenType(32);
     Exit;
   end;
end;

procedure IdentifierHash70(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'requires', Length) = 0 then
   begin
     Token.Token := TTokenType(33);
     Exit;
   end;
end;

procedure IdentifierHash0F(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'needs', Length) = 0 then
   begin
     Token.Token := TTokenType(34);
     Exit;
   end;
end;

procedure IdentifierHashC0(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'uses', Length) = 0 then
   begin
     Token.Token := TTokenType(35);
     Exit;
   end;
end;

procedure IdentifierHashA4(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'initializer', Length) = 0 then
   begin
     Token.Token := TTokenType(36);
     Exit;
   end;
end;

procedure IdentifierHash4C(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'set', Length) = 0 then
   begin
     Token.Token := TTokenType(37);
     Exit;
   end;
end;

procedure IdentifierHash9C(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'call', Length) = 0 then
   begin
     Token.Token := TTokenType(38);
     Exit;
   end;
end;

procedure IdentifierHash33(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'and', Length) = 0 then
   begin
     Token.Token := TTokenType(39);
     Exit;
   end;
end;

procedure IdentifierHash51(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'not', Length) = 0 then
   begin
     Token.Token := TTokenType(40);
     Exit;
   end

 else if StrLComp(Start, 'endscope', Length) = 0 then
   begin
     Token.Token := TTokenType(43);
     Exit;
   end;
end;

procedure IdentifierHashE1(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'or', Length) = 0 then
   begin
     Token.Token := TTokenType(41);
     Exit;
   end;
end;

procedure IdentifierHash1A(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'scope', Length) = 0 then
   begin
     Token.Token := TTokenType(42);
     Exit;
   end;
end;

procedure IdentifierHashB1(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'interface', Length) = 0 then
   begin
     Token.Token := TTokenType(44);
     Exit;
   end;
end;

procedure IdentifierHashE8(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endinterface', Length) = 0 then
   begin
     Token.Token := TTokenType(45);
     Exit;
   end;
end;

procedure IdentifierHash58(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'defaults', Length) = 0 then
   begin
     Token.Token := TTokenType(46);
     Exit;
   end;
end;

procedure IdentifierHashA5(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'struct', Length) = 0 then
   begin
     Token.Token := TTokenType(47);
     Exit;
   end;
end;

procedure IdentifierHashDC(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endstruct', Length) = 0 then
   begin
     Token.Token := TTokenType(48);
     Exit;
   end;
end;

procedure IdentifierHash81(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'method', Length) = 0 then
   begin
     Token.Token := TTokenType(49);
     Exit;
   end;
end;

procedure IdentifierHashB8(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endmethod', Length) = 0 then
   begin
     Token.Token := TTokenType(50);
     Exit;
   end;
end;

procedure IdentifierHash6C(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'operator', Length) = 0 then
   begin
     Token.Token := TTokenType(51);
     Exit;
   end

 else if StrLComp(Start, 'exitwhen', Length) = 0 then
   begin
     Token.Token := TTokenType(61);
     Exit;
   end;
end;

procedure IdentifierHashA0(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'return', Length) = 0 then
   begin
     Token.Token := TTokenType(52);
     Exit;
   end;
end;

procedure IdentifierHash0B(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'local', Length) = 0 then
   begin
     Token.Token := TTokenType(53);
     Exit;
   end;
end;

procedure IdentifierHashCF(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'if', Length) = 0 then
   begin
     Token.Token := TTokenType(54);
     Exit;
   end;
end;

procedure IdentifierHash06(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endif', Length) = 0 then
   begin
     Token.Token := TTokenType(55);
     Exit;
   end;
end;

procedure IdentifierHashAF(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'then', Length) = 0 then
   begin
     Token.Token := TTokenType(56);
     Exit;
   end;
end;

procedure IdentifierHashA9(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'else', Length) = 0 then
   begin
     Token.Token := TTokenType(57);
     Exit;
   end;
end;

procedure IdentifierHash78(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'elseif', Length) = 0 then
   begin
     Token.Token := TTokenType(58);
     Exit;
   end;
end;

procedure IdentifierHashBA(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'loop', Length) = 0 then
   begin
     Token.Token := TTokenType(59);
     Exit;
   end;
end;

procedure IdentifierHashF1(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'endloop', Length) = 0 then
   begin
     Token.Token := TTokenType(60);
     Exit;
   end;
end;

procedure IdentifierHash7F(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'public', Length) = 0 then
   begin
     Token.Token := TTokenType(63);
     Exit;
   end;
end;

procedure IdentifierHashBE(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'stub', Length) = 0 then
   begin
     Token.Token := TTokenType(64);
     Exit;
   end;
end;

procedure IdentifierHash88(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'static', Length) = 0 then
   begin
     Token.Token := TTokenType(65);
     Exit;
   end;
end;

procedure IdentifierHash3B(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'delegate', Length) = 0 then
   begin
     Token.Token := TTokenType(66);
     Exit;
   end;
end;

procedure IdentifierHash05(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'keyword', Length) = 0 then
   begin
     Token.Token := TTokenType(67);
     Exit;
   end;
end;

procedure IdentifierHash5E(Start, Stop: PAnsiChar);
var
  Length: Cardinal;
begin
 Length := Cardinal(Stop) - Cardinal(Start);

 if StrLComp(Start, 'readonly', Length) = 0 then
   begin
     Token.Token := TTokenType(68);
     Exit;
   end;
end;

procedure InitKeywords;
var i: Byte;
begin
  for i := 0 to 255 do
    IdentifierJumpTable[i] := nil;

 IdentifierJumpTable[$E4] := IdentifierHashE4;
 IdentifierJumpTable[$1B] := IdentifierHash1B;
 IdentifierJumpTable[$66] := IdentifierHash66;
 IdentifierJumpTable[$9D] := IdentifierHash9D;
 IdentifierJumpTable[$18] := IdentifierHash18;
 IdentifierJumpTable[$13] := IdentifierHash13;
 IdentifierJumpTable[$F7] := IdentifierHashF7;
 IdentifierJumpTable[$6A] := IdentifierHash6A;
 IdentifierJumpTable[$87] := IdentifierHash87;
 IdentifierJumpTable[$C2] := IdentifierHashC2;
 IdentifierJumpTable[$FB] := IdentifierHashFB;
 IdentifierJumpTable[$1F] := IdentifierHash1F;
 IdentifierJumpTable[$F5] := IdentifierHashF5;
 IdentifierJumpTable[$F9] := IdentifierHashF9;
 IdentifierJumpTable[$2C] := IdentifierHash2C;
 IdentifierJumpTable[$70] := IdentifierHash70;
 IdentifierJumpTable[$0F] := IdentifierHash0F;
 IdentifierJumpTable[$C0] := IdentifierHashC0;
 IdentifierJumpTable[$A4] := IdentifierHashA4;
 IdentifierJumpTable[$4C] := IdentifierHash4C;
 IdentifierJumpTable[$9C] := IdentifierHash9C;
 IdentifierJumpTable[$33] := IdentifierHash33;
 IdentifierJumpTable[$51] := IdentifierHash51;
 IdentifierJumpTable[$E1] := IdentifierHashE1;
 IdentifierJumpTable[$1A] := IdentifierHash1A;
 IdentifierJumpTable[$B1] := IdentifierHashB1;
 IdentifierJumpTable[$E8] := IdentifierHashE8;
 IdentifierJumpTable[$58] := IdentifierHash58;
 IdentifierJumpTable[$A5] := IdentifierHashA5;
 IdentifierJumpTable[$DC] := IdentifierHashDC;
 IdentifierJumpTable[$81] := IdentifierHash81;
 IdentifierJumpTable[$B8] := IdentifierHashB8;
 IdentifierJumpTable[$6C] := IdentifierHash6C;
 IdentifierJumpTable[$A0] := IdentifierHashA0;
 IdentifierJumpTable[$0B] := IdentifierHash0B;
 IdentifierJumpTable[$CF] := IdentifierHashCF;
 IdentifierJumpTable[$06] := IdentifierHash06;
 IdentifierJumpTable[$AF] := IdentifierHashAF;
 IdentifierJumpTable[$A9] := IdentifierHashA9;
 IdentifierJumpTable[$78] := IdentifierHash78;
 IdentifierJumpTable[$BA] := IdentifierHashBA;
 IdentifierJumpTable[$F1] := IdentifierHashF1;
 IdentifierJumpTable[$7F] := IdentifierHash7F;
 IdentifierJumpTable[$BE] := IdentifierHashBE;
 IdentifierJumpTable[$88] := IdentifierHash88;
 IdentifierJumpTable[$3B] := IdentifierHash3B;
 IdentifierJumpTable[$05] := IdentifierHash05;
 IdentifierJumpTable[$5E] := IdentifierHash5E;
end;

{$ENDREGION}

end.
