unit ScannerKeywordsJumpTable;

interface

uses SysUtils;

procedure IdentifierProc;
procedure InitKeywords; inline;

implementation

uses Scanner, Tokens, Scopes;

procedure IdentifierProc; assembler;
asm // Hash in al. Input in cl. Input Pointer in edx. Input Start on stack.
  mov edx, Input // Load input

  push edx // Push start on stack

  movzx eax, byte ptr [edx] // Read first input to hash
  inc edx // Next char

  mov cl, byte ptr [edx] // Load second char
  
  jmp @Loop_Check;

@Loop:
  add al, ch // Hash += Input
  inc edx  // Increase input pointer
  mov cl, byte ptr [edx] // Read input

@Loop_Check:
  // Check if cl is a valid char
  mov ch, cl
  add cl,$d0
  sub cl,$0a
  jb @Loop
  add cl,$f9
  sub cl,$1a
  jb @Loop
  sub cl,$04
  jz @Loop
  add cl,$fe
  sub cl,$1a
  jb @Loop

  mov [Input], edx

  // Store token information
  mov [Token.Token], ttIdentifier
  mov [Token.Hash], al
  mov [Token.Stop], edx

  pop ecx

  // Get the string length
  sub edx, ecx

  // Does the length match some keyword?
{$REGION 'Generated'}
  sub edx, 2
  cmp edx, 10
  jbe @CheckKeywords
  ret

@CheckKeywords:
  jmp dword ptr [@JumpTable + eax * 4]

@Empty:
  ret

  // Align jumptable
  nop
  nop
  
@JumpTable:
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check05
 dd @Check06
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check0B
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check0F
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check13
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check18
 dd @Empty
 dd @Check1A
 dd @Check1B
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check1F
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check2C
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check33
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check3B
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check4C
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check51
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check58
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check5E
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check66
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check6A
 dd @Empty
 dd @Check6C
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check70
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check78
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check7F
 dd @Empty
 dd @Check81
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check87
 dd @Check88
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Check9C
 dd @Check9D
 dd @Empty
 dd @Empty
 dd @CheckA0
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckA4
 dd @CheckA5
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckA9
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckAF
 dd @Empty
 dd @CheckB1
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckB8
 dd @Empty
 dd @CheckBA
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckBE
 dd @Empty
 dd @CheckC0
 dd @Empty
 dd @CheckC2
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckCF
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckDC
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckE1
 dd @Empty
 dd @Empty
 dd @CheckE4
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckE8
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckF1
 dd @Empty
 dd @Empty
 dd @Empty
 dd @CheckF5
 dd @Empty
 dd @CheckF7
 dd @Empty
 dd @CheckF9
 dd @Empty
 dd @CheckFB
 dd @Empty
 dd @Empty
 dd @Empty
 dd @Empty

@Check05:
  cmp edx, 5
  je @Compare05_7_0
  ret

@Check06:
  cmp edx, 3
  je @Compare06_5_0
  ret

@Check0B:
  cmp edx, 3
  je @Compare0B_5_0
  ret

@Check0F:
  cmp edx, 3
  je @Compare0F_5_0
  ret

@Check13:
  cmp edx, 5
  je @Compare13_7_0
  ret

@Check18:
  cmp edx, 3
  je @Compare18_5_0
  ret

@Check1A:
  cmp edx, 3
  je @Compare1A_5_0
  ret

@Check1B:
  cmp edx, 8
  je @Compare1B_10_0
  ret

@Check1F:
  cmp edx, 3
  je @Compare1F_5_0
  ret

@Check2C:
  cmp edx, 8
  je @Compare2C_10_0
  ret

@Check33:
  cmp edx, 1
  je @Compare33_3_0
  ret

@Check3B:
  cmp edx, 6
  je @Compare3B_8_0
  ret

@Check4C:
  cmp edx, 1
  je @Compare4C_3_0
  ret

@Check51:
  cmp edx, 6
  je @Compare51_8_0
  cmp edx, 1
  je @Compare51_3_0
  ret

@Check58:
  cmp edx, 6
  je @Compare58_8_0
  ret

@Check5E:
  cmp edx, 6
  je @Compare5E_8_0
  ret

@Check66:
  cmp edx, 6
  je @Compare66_8_0
  ret

@Check6A:
  cmp edx, 6
  je @Compare6A_8_0
  ret

@Check6C:
  cmp edx, 6
  je @Compare6C_8_0
  ret

@Check70:
  cmp edx, 6
  je @Compare70_8_0
  ret

@Check78:
  cmp edx, 4
  je @Compare78_6_0
  ret

@Check7F:
  cmp edx, 4
  je @Compare7F_6_0
  ret

@Check81:
  cmp edx, 4
  je @Compare81_6_0
  ret

@Check87:
  cmp edx, 4
  je @Compare87_6_0
  ret

@Check88:
  cmp edx, 4
  je @Compare88_6_0
  ret

@Check9C:
  cmp edx, 2
  je @Compare9C_4_0
  ret

@Check9D:
  cmp edx, 9
  je @Compare9D_11_0
  ret

@CheckA0:
  cmp edx, 4
  je @CompareA0_6_0
  ret

@CheckA4:
  cmp edx, 9
  je @CompareA4_11_0
  ret

@CheckA5:
  cmp edx, 4
  je @CompareA5_6_0
  ret

@CheckA9:
  cmp edx, 2
  je @CompareA9_4_0
  ret

@CheckAF:
  cmp edx, 2
  je @CompareAF_4_0
  ret

@CheckB1:
  cmp edx, 7
  je @CompareB1_9_0
  ret

@CheckB8:
  cmp edx, 7
  je @CompareB8_9_0
  ret

@CheckBA:
  cmp edx, 2
  je @CompareBA_4_0
  ret

@CheckBE:
  cmp edx, 2
  je @CompareBE_4_0
  ret

@CheckC0:
  cmp edx, 2
  je @CompareC0_4_0
  ret

@CheckC2:
  cmp edx, 2
  je @CompareC2_4_0
  ret

@CheckCF:
  cmp edx, 0
  je @CompareCF_2_0
  ret

@CheckDC:
  cmp edx, 7
  je @CompareDC_9_0
  ret

@CheckE1:
  cmp edx, 0
  je @CompareE1_2_0
  ret

@CheckE4:
  cmp edx, 5
  je @CompareE4_7_0
  ret

@CheckE8:
  cmp edx, 10
  je @CompareE8_12_0
  ret

@CheckF1:
  cmp edx, 5
  je @CompareF1_7_0
  ret

@CheckF5:
  cmp edx, 5
  je @CompareF5_7_0
  ret

@CheckF7:
  cmp edx, 5
  je @CompareF7_7_0
  ret

@CheckF9:
  cmp edx, 10
  je @CompareF9_12_0
  ret

@CheckFB:
  cmp edx, 5
  je @CompareFB_7_0
  ret
 
@Compare05_7_1:
  ret

@Compare05_7_0:

  mov al, [ecx+0]; cmp al, 'k'; jne @Compare05_7_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare05_7_1
  mov al, [ecx+2]; cmp al, 'y'; jne @Compare05_7_1
  mov al, [ecx+3]; cmp al, 'w'; jne @Compare05_7_1
  mov al, [ecx+4]; cmp al, 'o'; jne @Compare05_7_1
  mov al, [ecx+5]; cmp al, 'r'; jne @Compare05_7_1
  mov al, [ecx+6]; cmp al, 'd'; jne @Compare05_7_1

  mov [Token.Token], 67
  ret

 
@Compare06_5_1:
  ret

@Compare06_5_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare06_5_1
  mov al, [ecx+1]; cmp al, 'n'; jne @Compare06_5_1
  mov al, [ecx+2]; cmp al, 'd'; jne @Compare06_5_1
  mov al, [ecx+3]; cmp al, 'i'; jne @Compare06_5_1
  mov al, [ecx+4]; cmp al, 'f'; jne @Compare06_5_1

  mov [Token.Token], 55
  ret

 
@Compare0B_5_1:
  ret

@Compare0B_5_0:

  mov al, [ecx+0]; cmp al, 'l'; jne @Compare0B_5_1
  mov al, [ecx+1]; cmp al, 'o'; jne @Compare0B_5_1
  mov al, [ecx+2]; cmp al, 'c'; jne @Compare0B_5_1
  mov al, [ecx+3]; cmp al, 'a'; jne @Compare0B_5_1
  mov al, [ecx+4]; cmp al, 'l'; jne @Compare0B_5_1

  mov [Token.Token], 53
  ret

 
@Compare0F_5_1:
  ret

@Compare0F_5_0:

  mov al, [ecx+0]; cmp al, 'n'; jne @Compare0F_5_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare0F_5_1
  mov al, [ecx+2]; cmp al, 'e'; jne @Compare0F_5_1
  mov al, [ecx+3]; cmp al, 'd'; jne @Compare0F_5_1
  mov al, [ecx+4]; cmp al, 's'; jne @Compare0F_5_1

  mov [Token.Token], 34
  ret

 
@Compare13_7_1:
  ret

@Compare13_7_0:

  mov al, [ecx+0]; cmp al, 'r'; jne @Compare13_7_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare13_7_1
  mov al, [ecx+2]; cmp al, 't'; jne @Compare13_7_1
  mov al, [ecx+3]; cmp al, 'u'; jne @Compare13_7_1
  mov al, [ecx+4]; cmp al, 'r'; jne @Compare13_7_1
  mov al, [ecx+5]; cmp al, 'n'; jne @Compare13_7_1
  mov al, [ecx+6]; cmp al, 's'; jne @Compare13_7_1

  mov [Token.Token], 23
  ret

 
@Compare18_5_1:
  ret

@Compare18_5_0:

  mov al, [ecx+0]; cmp al, 't'; jne @Compare18_5_1
  mov al, [ecx+1]; cmp al, 'a'; jne @Compare18_5_1
  mov al, [ecx+2]; cmp al, 'k'; jne @Compare18_5_1
  mov al, [ecx+3]; cmp al, 'e'; jne @Compare18_5_1
  mov al, [ecx+4]; cmp al, 's'; jne @Compare18_5_1

  mov [Token.Token], 22
  ret

 
@Compare1A_5_1:
  ret

@Compare1A_5_0:

  mov al, [ecx+0]; cmp al, 's'; jne @Compare1A_5_1
  mov al, [ecx+1]; cmp al, 'c'; jne @Compare1A_5_1
  mov al, [ecx+2]; cmp al, 'o'; jne @Compare1A_5_1
  mov al, [ecx+3]; cmp al, 'p'; jne @Compare1A_5_1
  mov al, [ecx+4]; cmp al, 'e'; jne @Compare1A_5_1

  mov [Token.Token], 42
  ret

 
@Compare1B_10_1:
  ret

@Compare1B_10_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare1B_10_1
  mov al, [ecx+1]; cmp al, 'n'; jne @Compare1B_10_1
  mov al, [ecx+2]; cmp al, 'd'; jne @Compare1B_10_1
  mov al, [ecx+3]; cmp al, 'g'; jne @Compare1B_10_1
  mov al, [ecx+4]; cmp al, 'l'; jne @Compare1B_10_1
  mov al, [ecx+5]; cmp al, 'o'; jne @Compare1B_10_1
  mov al, [ecx+6]; cmp al, 'b'; jne @Compare1B_10_1
  mov al, [ecx+7]; cmp al, 'a'; jne @Compare1B_10_1
  mov al, [ecx+8]; cmp al, 'l'; jne @Compare1B_10_1
  mov al, [ecx+9]; cmp al, 's'; jne @Compare1B_10_1

  mov [Token.Token], 19
  ret

 
@Compare1F_5_1:
  ret

@Compare1F_5_0:

  mov al, [ecx+0]; cmp al, 'a'; jne @Compare1F_5_1
  mov al, [ecx+1]; cmp al, 'r'; jne @Compare1F_5_1
  mov al, [ecx+2]; cmp al, 'r'; jne @Compare1F_5_1
  mov al, [ecx+3]; cmp al, 'a'; jne @Compare1F_5_1
  mov al, [ecx+4]; cmp al, 'y'; jne @Compare1F_5_1

  mov [Token.Token], 29
  ret

 
@Compare2C_10_1:
  ret

@Compare2C_10_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare2C_10_1
  mov al, [ecx+1]; cmp al, 'n'; jne @Compare2C_10_1
  mov al, [ecx+2]; cmp al, 'd'; jne @Compare2C_10_1
  mov al, [ecx+3]; cmp al, 'l'; jne @Compare2C_10_1
  mov al, [ecx+4]; cmp al, 'i'; jne @Compare2C_10_1
  mov al, [ecx+5]; cmp al, 'b'; jne @Compare2C_10_1
  mov al, [ecx+6]; cmp al, 'r'; jne @Compare2C_10_1
  mov al, [ecx+7]; cmp al, 'a'; jne @Compare2C_10_1
  mov al, [ecx+8]; cmp al, 'r'; jne @Compare2C_10_1
  mov al, [ecx+9]; cmp al, 'y'; jne @Compare2C_10_1

  mov [Token.Token], 32
  ret

 
@Compare33_3_1:
  ret

@Compare33_3_0:

  mov al, [ecx+0]; cmp al, 'a'; jne @Compare33_3_1
  mov al, [ecx+1]; cmp al, 'n'; jne @Compare33_3_1
  mov al, [ecx+2]; cmp al, 'd'; jne @Compare33_3_1

  mov [Token.Token], 39
  ret

 
@Compare3B_8_1:
  ret

@Compare3B_8_0:

  mov al, [ecx+0]; cmp al, 'd'; jne @Compare3B_8_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare3B_8_1
  mov al, [ecx+2]; cmp al, 'l'; jne @Compare3B_8_1
  mov al, [ecx+3]; cmp al, 'e'; jne @Compare3B_8_1
  mov al, [ecx+4]; cmp al, 'g'; jne @Compare3B_8_1
  mov al, [ecx+5]; cmp al, 'a'; jne @Compare3B_8_1
  mov al, [ecx+6]; cmp al, 't'; jne @Compare3B_8_1
  mov al, [ecx+7]; cmp al, 'e'; jne @Compare3B_8_1

  mov [Token.Token], 66
  ret

 
@Compare4C_3_1:
  ret

@Compare4C_3_0:

  mov al, [ecx+0]; cmp al, 's'; jne @Compare4C_3_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare4C_3_1
  mov al, [ecx+2]; cmp al, 't'; jne @Compare4C_3_1

  mov [Token.Token], 37
  ret

 
@Compare51_8_1:
@Compare51_3_1:
  ret

@Compare51_8_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare51_8_1
  mov al, [ecx+1]; cmp al, 'n'; jne @Compare51_8_1
  mov al, [ecx+2]; cmp al, 'd'; jne @Compare51_8_1
  mov al, [ecx+3]; cmp al, 's'; jne @Compare51_8_1
  mov al, [ecx+4]; cmp al, 'c'; jne @Compare51_8_1
  mov al, [ecx+5]; cmp al, 'o'; jne @Compare51_8_1
  mov al, [ecx+6]; cmp al, 'p'; jne @Compare51_8_1
  mov al, [ecx+7]; cmp al, 'e'; jne @Compare51_8_1

  mov [Token.Token], 43
  ret

@Compare51_3_0:

  mov al, [ecx+0]; cmp al, 'n'; jne @Compare51_3_1
  mov al, [ecx+1]; cmp al, 'o'; jne @Compare51_3_1
  mov al, [ecx+2]; cmp al, 't'; jne @Compare51_3_1

  mov [Token.Token], 40
  ret

 
@Compare58_8_1:
  ret

@Compare58_8_0:

  mov al, [ecx+0]; cmp al, 'd'; jne @Compare58_8_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare58_8_1
  mov al, [ecx+2]; cmp al, 'f'; jne @Compare58_8_1
  mov al, [ecx+3]; cmp al, 'a'; jne @Compare58_8_1
  mov al, [ecx+4]; cmp al, 'u'; jne @Compare58_8_1
  mov al, [ecx+5]; cmp al, 'l'; jne @Compare58_8_1
  mov al, [ecx+6]; cmp al, 't'; jne @Compare58_8_1
  mov al, [ecx+7]; cmp al, 's'; jne @Compare58_8_1

  mov [Token.Token], 46
  ret

 
@Compare5E_8_1:
  ret

@Compare5E_8_0:

  mov al, [ecx+0]; cmp al, 'r'; jne @Compare5E_8_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare5E_8_1
  mov al, [ecx+2]; cmp al, 'a'; jne @Compare5E_8_1
  mov al, [ecx+3]; cmp al, 'd'; jne @Compare5E_8_1
  mov al, [ecx+4]; cmp al, 'o'; jne @Compare5E_8_1
  mov al, [ecx+5]; cmp al, 'n'; jne @Compare5E_8_1
  mov al, [ecx+6]; cmp al, 'l'; jne @Compare5E_8_1
  mov al, [ecx+7]; cmp al, 'y'; jne @Compare5E_8_1

  mov [Token.Token], 68
  ret

 
@Compare66_8_1:
  ret

@Compare66_8_0:

  mov al, [ecx+0]; cmp al, 'f'; jne @Compare66_8_1
  mov al, [ecx+1]; cmp al, 'u'; jne @Compare66_8_1
  mov al, [ecx+2]; cmp al, 'n'; jne @Compare66_8_1
  mov al, [ecx+3]; cmp al, 'c'; jne @Compare66_8_1
  mov al, [ecx+4]; cmp al, 't'; jne @Compare66_8_1
  mov al, [ecx+5]; cmp al, 'i'; jne @Compare66_8_1
  mov al, [ecx+6]; cmp al, 'o'; jne @Compare66_8_1
  mov al, [ecx+7]; cmp al, 'n'; jne @Compare66_8_1

  mov [Token.Token], 20
  ret

 
@Compare6A_8_1:
  ret

@Compare6A_8_0:

  mov al, [ecx+0]; cmp al, 'c'; jne @Compare6A_8_1
  mov al, [ecx+1]; cmp al, 'o'; jne @Compare6A_8_1
  mov al, [ecx+2]; cmp al, 'n'; jne @Compare6A_8_1
  mov al, [ecx+3]; cmp al, 's'; jne @Compare6A_8_1
  mov al, [ecx+4]; cmp al, 't'; jne @Compare6A_8_1
  mov al, [ecx+5]; cmp al, 'a'; jne @Compare6A_8_1
  mov al, [ecx+6]; cmp al, 'n'; jne @Compare6A_8_1
  mov al, [ecx+7]; cmp al, 't'; jne @Compare6A_8_1

  mov [Token.Token], 25
  ret

 
@Compare6C_8_2:
  ret

@Compare6C_8_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare6C_8_1
  mov al, [ecx+1]; cmp al, 'x'; jne @Compare6C_8_1
  mov al, [ecx+2]; cmp al, 'i'; jne @Compare6C_8_1
  mov al, [ecx+3]; cmp al, 't'; jne @Compare6C_8_1
  mov al, [ecx+4]; cmp al, 'w'; jne @Compare6C_8_1
  mov al, [ecx+5]; cmp al, 'h'; jne @Compare6C_8_1
  mov al, [ecx+6]; cmp al, 'e'; jne @Compare6C_8_1
  mov al, [ecx+7]; cmp al, 'n'; jne @Compare6C_8_1

  mov [Token.Token], 61
  ret

@Compare6C_8_1:

  mov al, [ecx+0]; cmp al, 'o'; jne @Compare6C_8_2
  mov al, [ecx+1]; cmp al, 'p'; jne @Compare6C_8_2
  mov al, [ecx+2]; cmp al, 'e'; jne @Compare6C_8_2
  mov al, [ecx+3]; cmp al, 'r'; jne @Compare6C_8_2
  mov al, [ecx+4]; cmp al, 'a'; jne @Compare6C_8_2
  mov al, [ecx+5]; cmp al, 't'; jne @Compare6C_8_2
  mov al, [ecx+6]; cmp al, 'o'; jne @Compare6C_8_2
  mov al, [ecx+7]; cmp al, 'r'; jne @Compare6C_8_2

  mov [Token.Token], 51
  ret

 
@Compare70_8_1:
  ret

@Compare70_8_0:

  mov al, [ecx+0]; cmp al, 'r'; jne @Compare70_8_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare70_8_1
  mov al, [ecx+2]; cmp al, 'q'; jne @Compare70_8_1
  mov al, [ecx+3]; cmp al, 'u'; jne @Compare70_8_1
  mov al, [ecx+4]; cmp al, 'i'; jne @Compare70_8_1
  mov al, [ecx+5]; cmp al, 'r'; jne @Compare70_8_1
  mov al, [ecx+6]; cmp al, 'e'; jne @Compare70_8_1
  mov al, [ecx+7]; cmp al, 's'; jne @Compare70_8_1

  mov [Token.Token], 33
  ret

 
@Compare78_6_1:
  ret

@Compare78_6_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare78_6_1
  mov al, [ecx+1]; cmp al, 'l'; jne @Compare78_6_1
  mov al, [ecx+2]; cmp al, 's'; jne @Compare78_6_1
  mov al, [ecx+3]; cmp al, 'e'; jne @Compare78_6_1
  mov al, [ecx+4]; cmp al, 'i'; jne @Compare78_6_1
  mov al, [ecx+5]; cmp al, 'f'; jne @Compare78_6_1

  mov [Token.Token], 58
  ret

 
@Compare7F_6_1:
  ret

@Compare7F_6_0:

  mov al, [ecx+0]; cmp al, 'p'; jne @Compare7F_6_1
  mov al, [ecx+1]; cmp al, 'u'; jne @Compare7F_6_1
  mov al, [ecx+2]; cmp al, 'b'; jne @Compare7F_6_1
  mov al, [ecx+3]; cmp al, 'l'; jne @Compare7F_6_1
  mov al, [ecx+4]; cmp al, 'i'; jne @Compare7F_6_1
  mov al, [ecx+5]; cmp al, 'c'; jne @Compare7F_6_1

  mov [Token.Token], 63
  ret

 
@Compare81_6_1:
  ret

@Compare81_6_0:

  mov al, [ecx+0]; cmp al, 'm'; jne @Compare81_6_1
  mov al, [ecx+1]; cmp al, 'e'; jne @Compare81_6_1
  mov al, [ecx+2]; cmp al, 't'; jne @Compare81_6_1
  mov al, [ecx+3]; cmp al, 'h'; jne @Compare81_6_1
  mov al, [ecx+4]; cmp al, 'o'; jne @Compare81_6_1
  mov al, [ecx+5]; cmp al, 'd'; jne @Compare81_6_1

  mov [Token.Token], 49
  ret

 
@Compare87_6_1:
  ret

@Compare87_6_0:

  mov al, [ecx+0]; cmp al, 'n'; jne @Compare87_6_1
  mov al, [ecx+1]; cmp al, 'a'; jne @Compare87_6_1
  mov al, [ecx+2]; cmp al, 't'; jne @Compare87_6_1
  mov al, [ecx+3]; cmp al, 'i'; jne @Compare87_6_1
  mov al, [ecx+4]; cmp al, 'v'; jne @Compare87_6_1
  mov al, [ecx+5]; cmp al, 'e'; jne @Compare87_6_1

  mov [Token.Token], 26
  ret

 
@Compare88_6_1:
  ret

@Compare88_6_0:

  mov al, [ecx+0]; cmp al, 's'; jne @Compare88_6_1
  mov al, [ecx+1]; cmp al, 't'; jne @Compare88_6_1
  mov al, [ecx+2]; cmp al, 'a'; jne @Compare88_6_1
  mov al, [ecx+3]; cmp al, 't'; jne @Compare88_6_1
  mov al, [ecx+4]; cmp al, 'i'; jne @Compare88_6_1
  mov al, [ecx+5]; cmp al, 'c'; jne @Compare88_6_1

  mov [Token.Token], 65
  ret

 
@Compare9C_4_1:
  ret

@Compare9C_4_0:

  mov al, [ecx+0]; cmp al, 'c'; jne @Compare9C_4_1
  mov al, [ecx+1]; cmp al, 'a'; jne @Compare9C_4_1
  mov al, [ecx+2]; cmp al, 'l'; jne @Compare9C_4_1
  mov al, [ecx+3]; cmp al, 'l'; jne @Compare9C_4_1

  mov [Token.Token], 38
  ret

 
@Compare9D_11_1:
  ret

@Compare9D_11_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @Compare9D_11_1
  mov al, [ecx+1]; cmp al, 'n'; jne @Compare9D_11_1
  mov al, [ecx+2]; cmp al, 'd'; jne @Compare9D_11_1
  mov al, [ecx+3]; cmp al, 'f'; jne @Compare9D_11_1
  mov al, [ecx+4]; cmp al, 'u'; jne @Compare9D_11_1
  mov al, [ecx+5]; cmp al, 'n'; jne @Compare9D_11_1
  mov al, [ecx+6]; cmp al, 'c'; jne @Compare9D_11_1
  mov al, [ecx+7]; cmp al, 't'; jne @Compare9D_11_1
  mov al, [ecx+8]; cmp al, 'i'; jne @Compare9D_11_1
  mov al, [ecx+9]; cmp al, 'o'; jne @Compare9D_11_1
  mov al, [ecx+10]; cmp al, 'n'; jne @Compare9D_11_1

  mov [Token.Token], 21
  ret

 
@CompareA0_6_1:
  ret

@CompareA0_6_0:

  mov al, [ecx+0]; cmp al, 'r'; jne @CompareA0_6_1
  mov al, [ecx+1]; cmp al, 'e'; jne @CompareA0_6_1
  mov al, [ecx+2]; cmp al, 't'; jne @CompareA0_6_1
  mov al, [ecx+3]; cmp al, 'u'; jne @CompareA0_6_1
  mov al, [ecx+4]; cmp al, 'r'; jne @CompareA0_6_1
  mov al, [ecx+5]; cmp al, 'n'; jne @CompareA0_6_1

  mov [Token.Token], 52
  ret

 
@CompareA4_11_1:
  ret

@CompareA4_11_0:

  mov al, [ecx+0]; cmp al, 'i'; jne @CompareA4_11_1
  mov al, [ecx+1]; cmp al, 'n'; jne @CompareA4_11_1
  mov al, [ecx+2]; cmp al, 'i'; jne @CompareA4_11_1
  mov al, [ecx+3]; cmp al, 't'; jne @CompareA4_11_1
  mov al, [ecx+4]; cmp al, 'i'; jne @CompareA4_11_1
  mov al, [ecx+5]; cmp al, 'a'; jne @CompareA4_11_1
  mov al, [ecx+6]; cmp al, 'l'; jne @CompareA4_11_1
  mov al, [ecx+7]; cmp al, 'i'; jne @CompareA4_11_1
  mov al, [ecx+8]; cmp al, 'z'; jne @CompareA4_11_1
  mov al, [ecx+9]; cmp al, 'e'; jne @CompareA4_11_1
  mov al, [ecx+10]; cmp al, 'r'; jne @CompareA4_11_1

  mov [Token.Token], 36
  ret

 
@CompareA5_6_1:
  ret

@CompareA5_6_0:

  mov al, [ecx+0]; cmp al, 's'; jne @CompareA5_6_1
  mov al, [ecx+1]; cmp al, 't'; jne @CompareA5_6_1
  mov al, [ecx+2]; cmp al, 'r'; jne @CompareA5_6_1
  mov al, [ecx+3]; cmp al, 'u'; jne @CompareA5_6_1
  mov al, [ecx+4]; cmp al, 'c'; jne @CompareA5_6_1
  mov al, [ecx+5]; cmp al, 't'; jne @CompareA5_6_1

  mov [Token.Token], 47
  ret

 
@CompareA9_4_1:
  ret

@CompareA9_4_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @CompareA9_4_1
  mov al, [ecx+1]; cmp al, 'l'; jne @CompareA9_4_1
  mov al, [ecx+2]; cmp al, 's'; jne @CompareA9_4_1
  mov al, [ecx+3]; cmp al, 'e'; jne @CompareA9_4_1

  mov [Token.Token], 57
  ret

 
@CompareAF_4_1:
  ret

@CompareAF_4_0:

  mov al, [ecx+0]; cmp al, 't'; jne @CompareAF_4_1
  mov al, [ecx+1]; cmp al, 'h'; jne @CompareAF_4_1
  mov al, [ecx+2]; cmp al, 'e'; jne @CompareAF_4_1
  mov al, [ecx+3]; cmp al, 'n'; jne @CompareAF_4_1

  mov [Token.Token], 56
  ret

 
@CompareB1_9_1:
  ret

@CompareB1_9_0:

  mov al, [ecx+0]; cmp al, 'i'; jne @CompareB1_9_1
  mov al, [ecx+1]; cmp al, 'n'; jne @CompareB1_9_1
  mov al, [ecx+2]; cmp al, 't'; jne @CompareB1_9_1
  mov al, [ecx+3]; cmp al, 'e'; jne @CompareB1_9_1
  mov al, [ecx+4]; cmp al, 'r'; jne @CompareB1_9_1
  mov al, [ecx+5]; cmp al, 'f'; jne @CompareB1_9_1
  mov al, [ecx+6]; cmp al, 'a'; jne @CompareB1_9_1
  mov al, [ecx+7]; cmp al, 'c'; jne @CompareB1_9_1
  mov al, [ecx+8]; cmp al, 'e'; jne @CompareB1_9_1

  mov [Token.Token], 44
  ret

 
@CompareB8_9_1:
  ret

@CompareB8_9_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @CompareB8_9_1
  mov al, [ecx+1]; cmp al, 'n'; jne @CompareB8_9_1
  mov al, [ecx+2]; cmp al, 'd'; jne @CompareB8_9_1
  mov al, [ecx+3]; cmp al, 'm'; jne @CompareB8_9_1
  mov al, [ecx+4]; cmp al, 'e'; jne @CompareB8_9_1
  mov al, [ecx+5]; cmp al, 't'; jne @CompareB8_9_1
  mov al, [ecx+6]; cmp al, 'h'; jne @CompareB8_9_1
  mov al, [ecx+7]; cmp al, 'o'; jne @CompareB8_9_1
  mov al, [ecx+8]; cmp al, 'd'; jne @CompareB8_9_1

  mov [Token.Token], 50
  ret

 
@CompareBA_4_1:
  ret

@CompareBA_4_0:

  mov al, [ecx+0]; cmp al, 'l'; jne @CompareBA_4_1
  mov al, [ecx+1]; cmp al, 'o'; jne @CompareBA_4_1
  mov al, [ecx+2]; cmp al, 'o'; jne @CompareBA_4_1
  mov al, [ecx+3]; cmp al, 'p'; jne @CompareBA_4_1

  mov [Token.Token], 59
  ret

 
@CompareBE_4_1:
  ret

@CompareBE_4_0:

  mov al, [ecx+0]; cmp al, 's'; jne @CompareBE_4_1
  mov al, [ecx+1]; cmp al, 't'; jne @CompareBE_4_1
  mov al, [ecx+2]; cmp al, 'u'; jne @CompareBE_4_1
  mov al, [ecx+3]; cmp al, 'b'; jne @CompareBE_4_1

  mov [Token.Token], 64
  ret

 
@CompareC0_4_1:
  ret

@CompareC0_4_0:

  mov al, [ecx+0]; cmp al, 'u'; jne @CompareC0_4_1
  mov al, [ecx+1]; cmp al, 's'; jne @CompareC0_4_1
  mov al, [ecx+2]; cmp al, 'e'; jne @CompareC0_4_1
  mov al, [ecx+3]; cmp al, 's'; jne @CompareC0_4_1

  mov [Token.Token], 35
  ret

 
@CompareC2_4_1:
  ret

@CompareC2_4_0:

  mov al, [ecx+0]; cmp al, 't'; jne @CompareC2_4_1
  mov al, [ecx+1]; cmp al, 'y'; jne @CompareC2_4_1
  mov al, [ecx+2]; cmp al, 'p'; jne @CompareC2_4_1
  mov al, [ecx+3]; cmp al, 'e'; jne @CompareC2_4_1

  mov [Token.Token], 27
  ret

 
@CompareCF_2_1:
  ret

@CompareCF_2_0:

  mov al, [ecx+0]; cmp al, 'i'; jne @CompareCF_2_1
  mov al, [ecx+1]; cmp al, 'f'; jne @CompareCF_2_1

  mov [Token.Token], 54
  ret

 
@CompareDC_9_1:
  ret

@CompareDC_9_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @CompareDC_9_1
  mov al, [ecx+1]; cmp al, 'n'; jne @CompareDC_9_1
  mov al, [ecx+2]; cmp al, 'd'; jne @CompareDC_9_1
  mov al, [ecx+3]; cmp al, 's'; jne @CompareDC_9_1
  mov al, [ecx+4]; cmp al, 't'; jne @CompareDC_9_1
  mov al, [ecx+5]; cmp al, 'r'; jne @CompareDC_9_1
  mov al, [ecx+6]; cmp al, 'u'; jne @CompareDC_9_1
  mov al, [ecx+7]; cmp al, 'c'; jne @CompareDC_9_1
  mov al, [ecx+8]; cmp al, 't'; jne @CompareDC_9_1

  mov [Token.Token], 48
  ret

 
@CompareE1_2_1:
  ret

@CompareE1_2_0:

  mov al, [ecx+0]; cmp al, 'o'; jne @CompareE1_2_1
  mov al, [ecx+1]; cmp al, 'r'; jne @CompareE1_2_1

  mov [Token.Token], 41
  ret

 
@CompareE4_7_1:
  ret

@CompareE4_7_0:

  mov al, [ecx+0]; cmp al, 'g'; jne @CompareE4_7_1
  mov al, [ecx+1]; cmp al, 'l'; jne @CompareE4_7_1
  mov al, [ecx+2]; cmp al, 'o'; jne @CompareE4_7_1
  mov al, [ecx+3]; cmp al, 'b'; jne @CompareE4_7_1
  mov al, [ecx+4]; cmp al, 'a'; jne @CompareE4_7_1
  mov al, [ecx+5]; cmp al, 'l'; jne @CompareE4_7_1
  mov al, [ecx+6]; cmp al, 's'; jne @CompareE4_7_1

  mov [Token.Token], 18
  ret

 
@CompareE8_12_1:
  ret

@CompareE8_12_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @CompareE8_12_1
  mov al, [ecx+1]; cmp al, 'n'; jne @CompareE8_12_1
  mov al, [ecx+2]; cmp al, 'd'; jne @CompareE8_12_1
  mov al, [ecx+3]; cmp al, 'i'; jne @CompareE8_12_1
  mov al, [ecx+4]; cmp al, 'n'; jne @CompareE8_12_1
  mov al, [ecx+5]; cmp al, 't'; jne @CompareE8_12_1
  mov al, [ecx+6]; cmp al, 'e'; jne @CompareE8_12_1
  mov al, [ecx+7]; cmp al, 'r'; jne @CompareE8_12_1
  mov al, [ecx+8]; cmp al, 'f'; jne @CompareE8_12_1
  mov al, [ecx+9]; cmp al, 'a'; jne @CompareE8_12_1
  mov al, [ecx+10]; cmp al, 'c'; jne @CompareE8_12_1
  mov al, [ecx+11]; cmp al, 'e'; jne @CompareE8_12_1

  mov [Token.Token], 45
  ret

 
@CompareF1_7_1:
  ret

@CompareF1_7_0:

  mov al, [ecx+0]; cmp al, 'e'; jne @CompareF1_7_1
  mov al, [ecx+1]; cmp al, 'n'; jne @CompareF1_7_1
  mov al, [ecx+2]; cmp al, 'd'; jne @CompareF1_7_1
  mov al, [ecx+3]; cmp al, 'l'; jne @CompareF1_7_1
  mov al, [ecx+4]; cmp al, 'o'; jne @CompareF1_7_1
  mov al, [ecx+5]; cmp al, 'o'; jne @CompareF1_7_1
  mov al, [ecx+6]; cmp al, 'p'; jne @CompareF1_7_1

  mov [Token.Token], 60
  ret

 
@CompareF5_7_1:
  ret

@CompareF5_7_0:

  mov al, [ecx+0]; cmp al, 'l'; jne @CompareF5_7_1
  mov al, [ecx+1]; cmp al, 'i'; jne @CompareF5_7_1
  mov al, [ecx+2]; cmp al, 'b'; jne @CompareF5_7_1
  mov al, [ecx+3]; cmp al, 'r'; jne @CompareF5_7_1
  mov al, [ecx+4]; cmp al, 'a'; jne @CompareF5_7_1
  mov al, [ecx+5]; cmp al, 'r'; jne @CompareF5_7_1
  mov al, [ecx+6]; cmp al, 'y'; jne @CompareF5_7_1

  mov [Token.Token], 30
  ret

 
@CompareF7_7_1:
  ret

@CompareF7_7_0:

  mov al, [ecx+0]; cmp al, 'n'; jne @CompareF7_7_1
  mov al, [ecx+1]; cmp al, 'o'; jne @CompareF7_7_1
  mov al, [ecx+2]; cmp al, 't'; jne @CompareF7_7_1
  mov al, [ecx+3]; cmp al, 'h'; jne @CompareF7_7_1
  mov al, [ecx+4]; cmp al, 'i'; jne @CompareF7_7_1
  mov al, [ecx+5]; cmp al, 'n'; jne @CompareF7_7_1
  mov al, [ecx+6]; cmp al, 'g'; jne @CompareF7_7_1

  mov [Token.Token], 24
  ret

 
@CompareF9_12_1:
  ret

@CompareF9_12_0:

  mov al, [ecx+0]; cmp al, 'l'; jne @CompareF9_12_1
  mov al, [ecx+1]; cmp al, 'i'; jne @CompareF9_12_1
  mov al, [ecx+2]; cmp al, 'b'; jne @CompareF9_12_1
  mov al, [ecx+3]; cmp al, 'r'; jne @CompareF9_12_1
  mov al, [ecx+4]; cmp al, 'a'; jne @CompareF9_12_1
  mov al, [ecx+5]; cmp al, 'r'; jne @CompareF9_12_1
  mov al, [ecx+6]; cmp al, 'y'; jne @CompareF9_12_1
  mov al, [ecx+7]; cmp al, '_'; jne @CompareF9_12_1
  mov al, [ecx+8]; cmp al, 'o'; jne @CompareF9_12_1
  mov al, [ecx+9]; cmp al, 'n'; jne @CompareF9_12_1
  mov al, [ecx+10]; cmp al, 'c'; jne @CompareF9_12_1
  mov al, [ecx+11]; cmp al, 'e'; jne @CompareF9_12_1

  mov [Token.Token], 31
  ret

 
@CompareFB_7_2:
  ret

@CompareFB_7_0:

  mov al, [ecx+0]; cmp al, 'p'; jne @CompareFB_7_1
  mov al, [ecx+1]; cmp al, 'r'; jne @CompareFB_7_1
  mov al, [ecx+2]; cmp al, 'i'; jne @CompareFB_7_1
  mov al, [ecx+3]; cmp al, 'v'; jne @CompareFB_7_1
  mov al, [ecx+4]; cmp al, 'a'; jne @CompareFB_7_1
  mov al, [ecx+5]; cmp al, 't'; jne @CompareFB_7_1
  mov al, [ecx+6]; cmp al, 'e'; jne @CompareFB_7_1

  mov [Token.Token], 62
  ret

@CompareFB_7_1:

  mov al, [ecx+0]; cmp al, 'e'; jne @CompareFB_7_2
  mov al, [ecx+1]; cmp al, 'x'; jne @CompareFB_7_2
  mov al, [ecx+2]; cmp al, 't'; jne @CompareFB_7_2
  mov al, [ecx+3]; cmp al, 'e'; jne @CompareFB_7_2
  mov al, [ecx+4]; cmp al, 'n'; jne @CompareFB_7_2
  mov al, [ecx+5]; cmp al, 'd'; jne @CompareFB_7_2
  mov al, [ecx+6]; cmp al, 's'; jne @CompareFB_7_2

  mov [Token.Token], 28
  ret
{$ENDREGION}
end;

procedure InitKeywords;
begin
end;

end.
