unit ScannerKeywordsJumpTable;

interface

uses SysUtils;

procedure IdentifierProc;
procedure InitKeywords;

implementation

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

uses Scanner, Tokens, Scopes;

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
procedure IdentifierHashE4(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_1:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'g'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'l'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 'o'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'b'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'a'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'l'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 's'
  jne @Compare7_1

  mov [Token.Token], 18
  ret
end;

procedure IdentifierHash1B(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 10
  je @Compare10_0
 
@Compare10_1:
  ret

@Compare10_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare10_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare10_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare10_1

  mov cl, [eax+3]
  cmp cl, 'g'
  jne @Compare10_1

  mov cl, [eax+4]
  cmp cl, 'l'
  jne @Compare10_1

  mov cl, [eax+5]
  cmp cl, 'o'
  jne @Compare10_1

  mov cl, [eax+6]
  cmp cl, 'b'
  jne @Compare10_1

  mov cl, [eax+7]
  cmp cl, 'a'
  jne @Compare10_1

  mov cl, [eax+8]
  cmp cl, 'l'
  jne @Compare10_1

  mov cl, [eax+9]
  cmp cl, 's'
  jne @Compare10_1

  mov [Token.Token], 19
  ret
end;

procedure IdentifierHash66(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_1:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'f'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'u'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'n'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 'c'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 't'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'i'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 'o'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 'n'
  jne @Compare8_1

  mov [Token.Token], 20
  ret
end;

procedure IdentifierHash9D(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 11
  je @Compare11_0
 
@Compare11_1:
  ret

@Compare11_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare11_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare11_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare11_1

  mov cl, [eax+3]
  cmp cl, 'f'
  jne @Compare11_1

  mov cl, [eax+4]
  cmp cl, 'u'
  jne @Compare11_1

  mov cl, [eax+5]
  cmp cl, 'n'
  jne @Compare11_1

  mov cl, [eax+6]
  cmp cl, 'c'
  jne @Compare11_1

  mov cl, [eax+7]
  cmp cl, 't'
  jne @Compare11_1

  mov cl, [eax+8]
  cmp cl, 'i'
  jne @Compare11_1

  mov cl, [eax+9]
  cmp cl, 'o'
  jne @Compare11_1

  mov cl, [eax+10]
  cmp cl, 'n'
  jne @Compare11_1

  mov [Token.Token], 21
  ret
end;

procedure IdentifierHash18(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 5
  je @Compare5_0
 
@Compare5_1:
  ret

@Compare5_0:

  mov cl, [eax+0]
  cmp cl, 't'
  jne @Compare5_1

  mov cl, [eax+1]
  cmp cl, 'a'
  jne @Compare5_1

  mov cl, [eax+2]
  cmp cl, 'k'
  jne @Compare5_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare5_1

  mov cl, [eax+4]
  cmp cl, 's'
  jne @Compare5_1

  mov [Token.Token], 22
  ret
end;

procedure IdentifierHash13(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_1:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'r'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'u'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'r'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'n'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 's'
  jne @Compare7_1

  mov [Token.Token], 23
  ret
end;

procedure IdentifierHashF7(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_1:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'n'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'o'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'h'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'n'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 'g'
  jne @Compare7_1

  mov [Token.Token], 24
  ret
end;

procedure IdentifierHash6A(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_1:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'c'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'o'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'n'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 's'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 't'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'a'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 'n'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 't'
  jne @Compare8_1

  mov [Token.Token], 25
  ret
end;

procedure IdentifierHash87(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 'n'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 'a'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 'i'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'v'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 'e'
  jne @Compare6_1

  mov [Token.Token], 26
  ret
end;

procedure IdentifierHashC2(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 't'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 'y'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 'p'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare4_1

  mov [Token.Token], 27
  ret
end;

procedure IdentifierHashFB(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_2:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'x'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'n'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'd'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 's'
  jne @Compare7_1

  mov [Token.Token], 28
  ret

@Compare7_1:

  mov cl, [eax+0]
  cmp cl, 'p'
  jne @Compare7_2

  mov cl, [eax+1]
  cmp cl, 'r'
  jne @Compare7_2

  mov cl, [eax+2]
  cmp cl, 'i'
  jne @Compare7_2

  mov cl, [eax+3]
  cmp cl, 'v'
  jne @Compare7_2

  mov cl, [eax+4]
  cmp cl, 'a'
  jne @Compare7_2

  mov cl, [eax+5]
  cmp cl, 't'
  jne @Compare7_2

  mov cl, [eax+6]
  cmp cl, 'e'
  jne @Compare7_2

  mov [Token.Token], 62
  ret
end;

procedure IdentifierHash1F(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 5
  je @Compare5_0
 
@Compare5_1:
  ret

@Compare5_0:

  mov cl, [eax+0]
  cmp cl, 'a'
  jne @Compare5_1

  mov cl, [eax+1]
  cmp cl, 'r'
  jne @Compare5_1

  mov cl, [eax+2]
  cmp cl, 'r'
  jne @Compare5_1

  mov cl, [eax+3]
  cmp cl, 'a'
  jne @Compare5_1

  mov cl, [eax+4]
  cmp cl, 'y'
  jne @Compare5_1

  mov [Token.Token], 29
  ret
end;

procedure IdentifierHashF5(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_1:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'l'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'i'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 'b'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'r'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'a'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'r'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 'y'
  jne @Compare7_1

  mov [Token.Token], 30
  ret
end;

procedure IdentifierHashF9(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 12
  je @Compare12_0
 
@Compare12_1:
  ret

@Compare12_0:

  mov cl, [eax+0]
  cmp cl, 'l'
  jne @Compare12_1

  mov cl, [eax+1]
  cmp cl, 'i'
  jne @Compare12_1

  mov cl, [eax+2]
  cmp cl, 'b'
  jne @Compare12_1

  mov cl, [eax+3]
  cmp cl, 'r'
  jne @Compare12_1

  mov cl, [eax+4]
  cmp cl, 'a'
  jne @Compare12_1

  mov cl, [eax+5]
  cmp cl, 'r'
  jne @Compare12_1

  mov cl, [eax+6]
  cmp cl, 'y'
  jne @Compare12_1

  mov cl, [eax+7]
  cmp cl, '_'
  jne @Compare12_1

  mov cl, [eax+8]
  cmp cl, 'o'
  jne @Compare12_1

  mov cl, [eax+9]
  cmp cl, 'n'
  jne @Compare12_1

  mov cl, [eax+10]
  cmp cl, 'c'
  jne @Compare12_1

  mov cl, [eax+11]
  cmp cl, 'e'
  jne @Compare12_1

  mov [Token.Token], 31
  ret
end;

procedure IdentifierHash2C(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 10
  je @Compare10_0
 
@Compare10_1:
  ret

@Compare10_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare10_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare10_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare10_1

  mov cl, [eax+3]
  cmp cl, 'l'
  jne @Compare10_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare10_1

  mov cl, [eax+5]
  cmp cl, 'b'
  jne @Compare10_1

  mov cl, [eax+6]
  cmp cl, 'r'
  jne @Compare10_1

  mov cl, [eax+7]
  cmp cl, 'a'
  jne @Compare10_1

  mov cl, [eax+8]
  cmp cl, 'r'
  jne @Compare10_1

  mov cl, [eax+9]
  cmp cl, 'y'
  jne @Compare10_1

  mov [Token.Token], 32
  ret
end;

procedure IdentifierHash70(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_1:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'r'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'q'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 'u'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'r'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 's'
  jne @Compare8_1

  mov [Token.Token], 33
  ret
end;

procedure IdentifierHash0F(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 5
  je @Compare5_0
 
@Compare5_1:
  ret

@Compare5_0:

  mov cl, [eax+0]
  cmp cl, 'n'
  jne @Compare5_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare5_1

  mov cl, [eax+2]
  cmp cl, 'e'
  jne @Compare5_1

  mov cl, [eax+3]
  cmp cl, 'd'
  jne @Compare5_1

  mov cl, [eax+4]
  cmp cl, 's'
  jne @Compare5_1

  mov [Token.Token], 34
  ret
end;

procedure IdentifierHashC0(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 'u'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 's'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 'e'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 's'
  jne @Compare4_1

  mov [Token.Token], 35
  ret
end;

procedure IdentifierHashA4(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 11
  je @Compare11_0
 
@Compare11_1:
  ret

@Compare11_0:

  mov cl, [eax+0]
  cmp cl, 'i'
  jne @Compare11_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare11_1

  mov cl, [eax+2]
  cmp cl, 'i'
  jne @Compare11_1

  mov cl, [eax+3]
  cmp cl, 't'
  jne @Compare11_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare11_1

  mov cl, [eax+5]
  cmp cl, 'a'
  jne @Compare11_1

  mov cl, [eax+6]
  cmp cl, 'l'
  jne @Compare11_1

  mov cl, [eax+7]
  cmp cl, 'i'
  jne @Compare11_1

  mov cl, [eax+8]
  cmp cl, 'z'
  jne @Compare11_1

  mov cl, [eax+9]
  cmp cl, 'e'
  jne @Compare11_1

  mov cl, [eax+10]
  cmp cl, 'r'
  jne @Compare11_1

  mov [Token.Token], 36
  ret
end;

procedure IdentifierHash4C(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 3
  je @Compare3_0
 
@Compare3_1:
  ret

@Compare3_0:

  mov cl, [eax+0]
  cmp cl, 's'
  jne @Compare3_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare3_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare3_1

  mov [Token.Token], 37
  ret
end;

procedure IdentifierHash9C(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 'c'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 'a'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 'l'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 'l'
  jne @Compare4_1

  mov [Token.Token], 38
  ret
end;

procedure IdentifierHash33(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 3
  je @Compare3_0
 
@Compare3_1:
  ret

@Compare3_0:

  mov cl, [eax+0]
  cmp cl, 'a'
  jne @Compare3_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare3_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare3_1

  mov [Token.Token], 39
  ret
end;

procedure IdentifierHash51(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 3
  je @Compare3_0
 
  cmp edx, 8
  je @Compare8_0
 
@Compare3_1:
@Compare8_1:
  ret

@Compare3_0:

  mov cl, [eax+0]
  cmp cl, 'n'
  jne @Compare3_1

  mov cl, [eax+1]
  cmp cl, 'o'
  jne @Compare3_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare3_1

  mov [Token.Token], 40
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 's'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 'c'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'o'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 'p'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 'e'
  jne @Compare8_1

  mov [Token.Token], 43
  ret
end;

procedure IdentifierHashE1(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 2
  je @Compare2_0
 
@Compare2_1:
  ret

@Compare2_0:

  mov cl, [eax+0]
  cmp cl, 'o'
  jne @Compare2_1

  mov cl, [eax+1]
  cmp cl, 'r'
  jne @Compare2_1

  mov [Token.Token], 41
  ret
end;

procedure IdentifierHash1A(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 5
  je @Compare5_0
 
@Compare5_1:
  ret

@Compare5_0:

  mov cl, [eax+0]
  cmp cl, 's'
  jne @Compare5_1

  mov cl, [eax+1]
  cmp cl, 'c'
  jne @Compare5_1

  mov cl, [eax+2]
  cmp cl, 'o'
  jne @Compare5_1

  mov cl, [eax+3]
  cmp cl, 'p'
  jne @Compare5_1

  mov cl, [eax+4]
  cmp cl, 'e'
  jne @Compare5_1

  mov [Token.Token], 42
  ret
end;

procedure IdentifierHashB1(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 9
  je @Compare9_0
 
@Compare9_1:
  ret

@Compare9_0:

  mov cl, [eax+0]
  cmp cl, 'i'
  jne @Compare9_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare9_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare9_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare9_1

  mov cl, [eax+4]
  cmp cl, 'r'
  jne @Compare9_1

  mov cl, [eax+5]
  cmp cl, 'f'
  jne @Compare9_1

  mov cl, [eax+6]
  cmp cl, 'a'
  jne @Compare9_1

  mov cl, [eax+7]
  cmp cl, 'c'
  jne @Compare9_1

  mov cl, [eax+8]
  cmp cl, 'e'
  jne @Compare9_1

  mov [Token.Token], 44
  ret
end;

procedure IdentifierHashE8(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 12
  je @Compare12_0
 
@Compare12_1:
  ret

@Compare12_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare12_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare12_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare12_1

  mov cl, [eax+3]
  cmp cl, 'i'
  jne @Compare12_1

  mov cl, [eax+4]
  cmp cl, 'n'
  jne @Compare12_1

  mov cl, [eax+5]
  cmp cl, 't'
  jne @Compare12_1

  mov cl, [eax+6]
  cmp cl, 'e'
  jne @Compare12_1

  mov cl, [eax+7]
  cmp cl, 'r'
  jne @Compare12_1

  mov cl, [eax+8]
  cmp cl, 'f'
  jne @Compare12_1

  mov cl, [eax+9]
  cmp cl, 'a'
  jne @Compare12_1

  mov cl, [eax+10]
  cmp cl, 'c'
  jne @Compare12_1

  mov cl, [eax+11]
  cmp cl, 'e'
  jne @Compare12_1

  mov [Token.Token], 45
  ret
end;

procedure IdentifierHash58(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_1:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'd'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'f'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 'a'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 'u'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'l'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 't'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 's'
  jne @Compare8_1

  mov [Token.Token], 46
  ret
end;

procedure IdentifierHashA5(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 's'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 't'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 'r'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 'u'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'c'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 't'
  jne @Compare6_1

  mov [Token.Token], 47
  ret
end;

procedure IdentifierHashDC(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 9
  je @Compare9_0
 
@Compare9_1:
  ret

@Compare9_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare9_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare9_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare9_1

  mov cl, [eax+3]
  cmp cl, 's'
  jne @Compare9_1

  mov cl, [eax+4]
  cmp cl, 't'
  jne @Compare9_1

  mov cl, [eax+5]
  cmp cl, 'r'
  jne @Compare9_1

  mov cl, [eax+6]
  cmp cl, 'u'
  jne @Compare9_1

  mov cl, [eax+7]
  cmp cl, 'c'
  jne @Compare9_1

  mov cl, [eax+8]
  cmp cl, 't'
  jne @Compare9_1

  mov [Token.Token], 48
  ret
end;

procedure IdentifierHash81(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 'm'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 'h'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'o'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 'd'
  jne @Compare6_1

  mov [Token.Token], 49
  ret
end;

procedure IdentifierHashB8(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 9
  je @Compare9_0
 
@Compare9_1:
  ret

@Compare9_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare9_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare9_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare9_1

  mov cl, [eax+3]
  cmp cl, 'm'
  jne @Compare9_1

  mov cl, [eax+4]
  cmp cl, 'e'
  jne @Compare9_1

  mov cl, [eax+5]
  cmp cl, 't'
  jne @Compare9_1

  mov cl, [eax+6]
  cmp cl, 'h'
  jne @Compare9_1

  mov cl, [eax+7]
  cmp cl, 'o'
  jne @Compare9_1

  mov cl, [eax+8]
  cmp cl, 'd'
  jne @Compare9_1

  mov [Token.Token], 50
  ret
end;

procedure IdentifierHash6C(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_2:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'o'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'p'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 'r'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 'a'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 't'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 'o'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 'r'
  jne @Compare8_1

  mov [Token.Token], 51
  ret

@Compare8_1:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare8_2

  mov cl, [eax+1]
  cmp cl, 'x'
  jne @Compare8_2

  mov cl, [eax+2]
  cmp cl, 'i'
  jne @Compare8_2

  mov cl, [eax+3]
  cmp cl, 't'
  jne @Compare8_2

  mov cl, [eax+4]
  cmp cl, 'w'
  jne @Compare8_2

  mov cl, [eax+5]
  cmp cl, 'h'
  jne @Compare8_2

  mov cl, [eax+6]
  cmp cl, 'e'
  jne @Compare8_2

  mov cl, [eax+7]
  cmp cl, 'n'
  jne @Compare8_2

  mov [Token.Token], 61
  ret
end;

procedure IdentifierHashA0(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 'r'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 't'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 'u'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'r'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 'n'
  jne @Compare6_1

  mov [Token.Token], 52
  ret
end;

procedure IdentifierHash0B(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 5
  je @Compare5_0
 
@Compare5_1:
  ret

@Compare5_0:

  mov cl, [eax+0]
  cmp cl, 'l'
  jne @Compare5_1

  mov cl, [eax+1]
  cmp cl, 'o'
  jne @Compare5_1

  mov cl, [eax+2]
  cmp cl, 'c'
  jne @Compare5_1

  mov cl, [eax+3]
  cmp cl, 'a'
  jne @Compare5_1

  mov cl, [eax+4]
  cmp cl, 'l'
  jne @Compare5_1

  mov [Token.Token], 53
  ret
end;

procedure IdentifierHashCF(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 2
  je @Compare2_0
 
@Compare2_1:
  ret

@Compare2_0:

  mov cl, [eax+0]
  cmp cl, 'i'
  jne @Compare2_1

  mov cl, [eax+1]
  cmp cl, 'f'
  jne @Compare2_1

  mov [Token.Token], 54
  ret
end;

procedure IdentifierHash06(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 5
  je @Compare5_0
 
@Compare5_1:
  ret

@Compare5_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare5_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare5_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare5_1

  mov cl, [eax+3]
  cmp cl, 'i'
  jne @Compare5_1

  mov cl, [eax+4]
  cmp cl, 'f'
  jne @Compare5_1

  mov [Token.Token], 55
  ret
end;

procedure IdentifierHashAF(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 't'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 'h'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 'e'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 'n'
  jne @Compare4_1

  mov [Token.Token], 56
  ret
end;

procedure IdentifierHashA9(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 'l'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 's'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare4_1

  mov [Token.Token], 57
  ret
end;

procedure IdentifierHash78(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 'l'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 's'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 'f'
  jne @Compare6_1

  mov [Token.Token], 58
  ret
end;

procedure IdentifierHashBA(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 'l'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 'o'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 'o'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 'p'
  jne @Compare4_1

  mov [Token.Token], 59
  ret
end;

procedure IdentifierHashF1(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_1:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'e'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'n'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 'd'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'l'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'o'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'o'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 'p'
  jne @Compare7_1

  mov [Token.Token], 60
  ret
end;

procedure IdentifierHash7F(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 'p'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 'u'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 'b'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 'l'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 'c'
  jne @Compare6_1

  mov [Token.Token], 63
  ret
end;

procedure IdentifierHashBE(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 4
  je @Compare4_0
 
@Compare4_1:
  ret

@Compare4_0:

  mov cl, [eax+0]
  cmp cl, 's'
  jne @Compare4_1

  mov cl, [eax+1]
  cmp cl, 't'
  jne @Compare4_1

  mov cl, [eax+2]
  cmp cl, 'u'
  jne @Compare4_1

  mov cl, [eax+3]
  cmp cl, 'b'
  jne @Compare4_1

  mov [Token.Token], 64
  ret
end;

procedure IdentifierHash88(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 6
  je @Compare6_0
 
@Compare6_1:
  ret

@Compare6_0:

  mov cl, [eax+0]
  cmp cl, 's'
  jne @Compare6_1

  mov cl, [eax+1]
  cmp cl, 't'
  jne @Compare6_1

  mov cl, [eax+2]
  cmp cl, 'a'
  jne @Compare6_1

  mov cl, [eax+3]
  cmp cl, 't'
  jne @Compare6_1

  mov cl, [eax+4]
  cmp cl, 'i'
  jne @Compare6_1

  mov cl, [eax+5]
  cmp cl, 'c'
  jne @Compare6_1

  mov [Token.Token], 65
  ret
end;

procedure IdentifierHash3B(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_1:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'd'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'l'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 'g'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'a'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 't'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 'e'
  jne @Compare8_1

  mov [Token.Token], 66
  ret
end;

procedure IdentifierHash05(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 7
  je @Compare7_0
 
@Compare7_1:
  ret

@Compare7_0:

  mov cl, [eax+0]
  cmp cl, 'k'
  jne @Compare7_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare7_1

  mov cl, [eax+2]
  cmp cl, 'y'
  jne @Compare7_1

  mov cl, [eax+3]
  cmp cl, 'w'
  jne @Compare7_1

  mov cl, [eax+4]
  cmp cl, 'o'
  jne @Compare7_1

  mov cl, [eax+5]
  cmp cl, 'r'
  jne @Compare7_1

  mov cl, [eax+6]
  cmp cl, 'd'
  jne @Compare7_1

  mov [Token.Token], 67
  ret
end;

procedure IdentifierHash5E(Start, Stop: PAnsiChar); assembler;
asm
  sub edx, eax
 
  cmp edx, 8
  je @Compare8_0
 
@Compare8_1:
  ret

@Compare8_0:

  mov cl, [eax+0]
  cmp cl, 'r'
  jne @Compare8_1

  mov cl, [eax+1]
  cmp cl, 'e'
  jne @Compare8_1

  mov cl, [eax+2]
  cmp cl, 'a'
  jne @Compare8_1

  mov cl, [eax+3]
  cmp cl, 'd'
  jne @Compare8_1

  mov cl, [eax+4]
  cmp cl, 'o'
  jne @Compare8_1

  mov cl, [eax+5]
  cmp cl, 'n'
  jne @Compare8_1

  mov cl, [eax+6]
  cmp cl, 'l'
  jne @Compare8_1

  mov cl, [eax+7]
  cmp cl, 'y'
  jne @Compare8_1

  mov [Token.Token], 68
  ret
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
