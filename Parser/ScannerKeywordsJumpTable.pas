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

@Return:
  ret

@JumpTable:
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check05
 dd @Check06
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check0B
 dd @Return
 dd @Return
 dd @Return
 dd @Check0F
 dd @Return
 dd @Return
 dd @Return
 dd @Check13
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check18
 dd @Return
 dd @Check1A
 dd @Check1B
 dd @Return
 dd @Return
 dd @Return
 dd @Check1F
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check2C
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check33
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check3B
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check4C
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check51
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check58
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check5E
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check66
 dd @Return
 dd @Return
 dd @Return
 dd @Check6A
 dd @Return
 dd @Check6C
 dd @Return
 dd @Return
 dd @Return
 dd @Check70
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check78
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check7F
 dd @Return
 dd @Check81
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check87
 dd @Check88
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check9C
 dd @Check9D
 dd @Return
 dd @Return
 dd @CheckA0
 dd @Return
 dd @Return
 dd @Return
 dd @CheckA4
 dd @CheckA5
 dd @Return
 dd @Return
 dd @Return
 dd @CheckA9
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckAF
 dd @Return
 dd @CheckB1
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckB8
 dd @Return
 dd @CheckBA
 dd @CheckBB
 dd @Return
 dd @Return
 dd @CheckBE
 dd @Return
 dd @CheckC0
 dd @Return
 dd @CheckC2
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckCF
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckDC
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckE1
 dd @Return
 dd @Return
 dd @CheckE4
 dd @Return
 dd @Return
 dd @Return
 dd @CheckE8
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckF1
 dd @Return
 dd @Return
 dd @Return
 dd @CheckF5
 dd @Return
 dd @CheckF7
 dd @Return
 dd @CheckF9
 dd @Return
 dd @CheckFB
 dd @Return
 dd @Return
 dd @Return
 dd @Return

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
  cmp edx, 1
  je @Compare51_3_0
  cmp edx, 6
  je @Compare51_8_0
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

@CheckBB:
  cmp edx, 2
  je @CompareBB_4_0
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
  // Match keyword
  mov eax, dword ptr[ecx]; cmp eax, $7779656B; jne @Compare05_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $726F; jne @Compare05_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $64; jne @Compare05_7_1

  mov [Token.Token], ttkeyword
  ret

 
@Compare06_5_1:
  ret

@Compare06_5_0:
  // Match endif
  mov eax, dword ptr[ecx]; cmp eax, $69646E65; jne @Compare06_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $66; jne @Compare06_5_1

  mov [Token.Token], ttendif
  ret

 
@Compare0B_5_2:
  ret

@Compare0B_5_0:
  // Match false
  mov eax, dword ptr[ecx]; cmp eax, $736C6166; jne @Compare0B_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $65; jne @Compare0B_5_1

  mov [Token.Token], ttfalse
  ret

@Compare0B_5_1:
  // Match local
  mov eax, dword ptr[ecx]; cmp eax, $61636F6C; jne @Compare0B_5_2
  mov al, byte ptr [ecx + 4]; cmp al, $6C; jne @Compare0B_5_2

  mov [Token.Token], ttlocal
  ret

 
@Compare0F_5_1:
  ret

@Compare0F_5_0:
  // Match needs
  mov eax, dword ptr[ecx]; cmp eax, $6465656E; jne @Compare0F_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $73; jne @Compare0F_5_1

  mov [Token.Token], ttneeds
  ret

 
@Compare13_7_1:
  ret

@Compare13_7_0:
  // Match returns
  mov eax, dword ptr[ecx]; cmp eax, $75746572; jne @Compare13_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6E72; jne @Compare13_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @Compare13_7_1

  mov [Token.Token], ttreturns
  ret

 
@Compare18_5_1:
  ret

@Compare18_5_0:
  // Match takes
  mov eax, dword ptr[ecx]; cmp eax, $656B6174; jne @Compare18_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $73; jne @Compare18_5_1

  mov [Token.Token], tttakes
  ret

 
@Compare1A_5_1:
  ret

@Compare1A_5_0:
  // Match scope
  mov eax, dword ptr[ecx]; cmp eax, $706F6373; jne @Compare1A_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $65; jne @Compare1A_5_1

  mov [Token.Token], ttscope
  ret

 
@Compare1B_10_1:
  ret

@Compare1B_10_0:
  // Match endglobals
  mov eax, dword ptr[ecx]; cmp eax, $67646E65; jne @Compare1B_10_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $61626F6C; jne @Compare1B_10_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $736C; jne @Compare1B_10_1

  mov [Token.Token], ttendglobals
  ret

 
@Compare1F_5_1:
  ret

@Compare1F_5_0:
  // Match array
  mov eax, dword ptr[ecx]; cmp eax, $61727261; jne @Compare1F_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $79; jne @Compare1F_5_1

  mov [Token.Token], ttarray
  ret

 
@Compare2C_10_1:
  ret

@Compare2C_10_0:
  // Match endlibrary
  mov eax, dword ptr[ecx]; cmp eax, $6C646E65; jne @Compare2C_10_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $61726269; jne @Compare2C_10_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $7972; jne @Compare2C_10_1

  mov [Token.Token], ttendlibrary
  ret

 
@Compare33_3_1:
  ret

@Compare33_3_0:
  // Match and
  movzx eax, word ptr [ecx]; cmp eax, $6E61; jne @Compare33_3_1
  mov al, byte ptr [ecx + 2]; cmp al, $64; jne @Compare33_3_1

  mov [Token.Token], ttand
  ret

 
@Compare3B_8_1:
  ret

@Compare3B_8_0:
  // Match delegate
  mov eax, dword ptr[ecx]; cmp eax, $656C6564; jne @Compare3B_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $65746167; jne @Compare3B_8_1

  mov [Token.Token], ttdelegate
  ret

 
@Compare4C_3_1:
  ret

@Compare4C_3_0:
  // Match set
  movzx eax, word ptr [ecx]; cmp eax, $6573; jne @Compare4C_3_1
  mov al, byte ptr [ecx + 2]; cmp al, $74; jne @Compare4C_3_1

  mov [Token.Token], ttset
  ret

 
@Compare51_3_1:
@Compare51_8_1:
  ret

@Compare51_3_0:
  // Match not
  movzx eax, word ptr [ecx]; cmp eax, $6F6E; jne @Compare51_3_1
  mov al, byte ptr [ecx + 2]; cmp al, $74; jne @Compare51_3_1

  mov [Token.Token], ttnot
  ret

@Compare51_8_0:
  // Match endscope
  mov eax, dword ptr[ecx]; cmp eax, $73646E65; jne @Compare51_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $65706F63; jne @Compare51_8_1

  mov [Token.Token], ttendscope
  ret

 
@Compare58_8_1:
  ret

@Compare58_8_0:
  // Match defaults
  mov eax, dword ptr[ecx]; cmp eax, $61666564; jne @Compare58_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $73746C75; jne @Compare58_8_1

  mov [Token.Token], ttdefaults
  ret

 
@Compare5E_8_1:
  ret

@Compare5E_8_0:
  // Match readonly
  mov eax, dword ptr[ecx]; cmp eax, $64616572; jne @Compare5E_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $796C6E6F; jne @Compare5E_8_1

  mov [Token.Token], ttreadonly
  ret

 
@Compare66_8_1:
  ret

@Compare66_8_0:
  // Match function
  mov eax, dword ptr[ecx]; cmp eax, $636E7566; jne @Compare66_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $6E6F6974; jne @Compare66_8_1

  mov [Token.Token], ttfunction
  ret

 
@Compare6A_8_1:
  ret

@Compare6A_8_0:
  // Match constant
  mov eax, dword ptr[ecx]; cmp eax, $736E6F63; jne @Compare6A_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $746E6174; jne @Compare6A_8_1

  mov [Token.Token], ttconstant
  ret

 
@Compare6C_8_2:
  ret

@Compare6C_8_0:
  // Match exitwhen
  mov eax, dword ptr[ecx]; cmp eax, $74697865; jne @Compare6C_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $6E656877; jne @Compare6C_8_1

  mov [Token.Token], ttexitwhen
  ret

@Compare6C_8_1:
  // Match operator
  mov eax, dword ptr[ecx]; cmp eax, $7265706F; jne @Compare6C_8_2
  mov eax, dword ptr[ecx + 4]; cmp eax, $726F7461; jne @Compare6C_8_2

  mov [Token.Token], ttoperator
  ret

 
@Compare70_8_1:
  ret

@Compare70_8_0:
  // Match requires
  mov eax, dword ptr[ecx]; cmp eax, $75716572; jne @Compare70_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $73657269; jne @Compare70_8_1

  mov [Token.Token], ttrequires
  ret

 
@Compare78_6_1:
  ret

@Compare78_6_0:
  // Match elseif
  mov eax, dword ptr[ecx]; cmp eax, $65736C65; jne @Compare78_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6669; jne @Compare78_6_1

  mov [Token.Token], ttelseif
  ret

 
@Compare7F_6_1:
  ret

@Compare7F_6_0:
  // Match public
  mov eax, dword ptr[ecx]; cmp eax, $6C627570; jne @Compare7F_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6369; jne @Compare7F_6_1

  mov [Token.Token], ttpublic
  ret

 
@Compare81_6_1:
  ret

@Compare81_6_0:
  // Match method
  mov eax, dword ptr[ecx]; cmp eax, $6874656D; jne @Compare81_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $646F; jne @Compare81_6_1

  mov [Token.Token], ttmethod
  ret

 
@Compare87_6_1:
  ret

@Compare87_6_0:
  // Match native
  mov eax, dword ptr[ecx]; cmp eax, $6974616E; jne @Compare87_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6576; jne @Compare87_6_1

  mov [Token.Token], ttnative
  ret

 
@Compare88_6_1:
  ret

@Compare88_6_0:
  // Match static
  mov eax, dword ptr[ecx]; cmp eax, $74617473; jne @Compare88_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6369; jne @Compare88_6_1

  mov [Token.Token], ttstatic
  ret

 
@Compare9C_4_1:
  ret

@Compare9C_4_0:
  // Match call
  mov eax, dword ptr[ecx]; cmp eax, $6C6C6163; jne @Compare9C_4_1

  mov [Token.Token], ttcall
  ret

 
@Compare9D_11_1:
  ret

@Compare9D_11_0:
  // Match endfunction
  mov eax, dword ptr[ecx]; cmp eax, $66646E65; jne @Compare9D_11_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $74636E75; jne @Compare9D_11_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $6F69; jne @Compare9D_11_1
  mov al, byte ptr [ecx + 10]; cmp al, $6E; jne @Compare9D_11_1

  mov [Token.Token], ttendfunction
  ret

 
@CompareA0_6_1:
  ret

@CompareA0_6_0:
  // Match return
  mov eax, dword ptr[ecx]; cmp eax, $75746572; jne @CompareA0_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6E72; jne @CompareA0_6_1

  mov [Token.Token], ttreturn
  ret

 
@CompareA4_11_1:
  ret

@CompareA4_11_0:
  // Match initializer
  mov eax, dword ptr[ecx]; cmp eax, $74696E69; jne @CompareA4_11_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $696C6169; jne @CompareA4_11_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $657A; jne @CompareA4_11_1
  mov al, byte ptr [ecx + 10]; cmp al, $72; jne @CompareA4_11_1

  mov [Token.Token], ttinitializer
  ret

 
@CompareA5_6_1:
  ret

@CompareA5_6_0:
  // Match struct
  mov eax, dword ptr[ecx]; cmp eax, $75727473; jne @CompareA5_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $7463; jne @CompareA5_6_1

  mov [Token.Token], ttstruct
  ret

 
@CompareA9_4_1:
  ret

@CompareA9_4_0:
  // Match else
  mov eax, dword ptr[ecx]; cmp eax, $65736C65; jne @CompareA9_4_1

  mov [Token.Token], ttelse
  ret

 
@CompareAF_4_1:
  ret

@CompareAF_4_0:
  // Match then
  mov eax, dword ptr[ecx]; cmp eax, $6E656874; jne @CompareAF_4_1

  mov [Token.Token], ttthen
  ret

 
@CompareB1_9_1:
  ret

@CompareB1_9_0:
  // Match interface
  mov eax, dword ptr[ecx]; cmp eax, $65746E69; jne @CompareB1_9_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $63616672; jne @CompareB1_9_1
  mov al, byte ptr [ecx + 8]; cmp al, $65; jne @CompareB1_9_1

  mov [Token.Token], ttinterface
  ret

 
@CompareB8_9_1:
  ret

@CompareB8_9_0:
  // Match endmethod
  mov eax, dword ptr[ecx]; cmp eax, $6D646E65; jne @CompareB8_9_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $6F687465; jne @CompareB8_9_1
  mov al, byte ptr [ecx + 8]; cmp al, $64; jne @CompareB8_9_1

  mov [Token.Token], ttendmethod
  ret

 
@CompareBA_4_1:
  ret

@CompareBA_4_0:
  // Match loop
  mov eax, dword ptr[ecx]; cmp eax, $706F6F6C; jne @CompareBA_4_1

  mov [Token.Token], ttloop
  ret

 
@CompareBB_4_1:
  ret

@CompareBB_4_0:
  // Match null
  mov eax, dword ptr[ecx]; cmp eax, $6C6C756E; jne @CompareBB_4_1

  mov [Token.Token], ttnull
  ret

 
@CompareBE_4_1:
  ret

@CompareBE_4_0:
  // Match stub
  mov eax, dword ptr[ecx]; cmp eax, $62757473; jne @CompareBE_4_1

  mov [Token.Token], ttstub
  ret

 
@CompareC0_4_2:
  ret

@CompareC0_4_0:
  // Match uses
  mov eax, dword ptr[ecx]; cmp eax, $73657375; jne @CompareC0_4_1

  mov [Token.Token], ttuses
  ret

@CompareC0_4_1:
  // Match true
  mov eax, dword ptr[ecx]; cmp eax, $65757274; jne @CompareC0_4_2

  mov [Token.Token], tttrue
  ret

 
@CompareC2_4_1:
  ret

@CompareC2_4_0:
  // Match type
  mov eax, dword ptr[ecx]; cmp eax, $65707974; jne @CompareC2_4_1

  mov [Token.Token], tttype
  ret

 
@CompareCF_2_1:
  ret

@CompareCF_2_0:
  // Match if
  movzx eax, word ptr [ecx]; cmp eax, $6669; jne @CompareCF_2_1

  mov [Token.Token], ttif
  ret

 
@CompareDC_9_1:
  ret

@CompareDC_9_0:
  // Match endstruct
  mov eax, dword ptr[ecx]; cmp eax, $73646E65; jne @CompareDC_9_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $63757274; jne @CompareDC_9_1
  mov al, byte ptr [ecx + 8]; cmp al, $74; jne @CompareDC_9_1

  mov [Token.Token], ttendstruct
  ret

 
@CompareE1_2_1:
  ret

@CompareE1_2_0:
  // Match or
  movzx eax, word ptr [ecx]; cmp eax, $726F; jne @CompareE1_2_1

  mov [Token.Token], ttor
  ret

 
@CompareE4_7_1:
  ret

@CompareE4_7_0:
  // Match globals
  mov eax, dword ptr[ecx]; cmp eax, $626F6C67; jne @CompareE4_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6C61; jne @CompareE4_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @CompareE4_7_1

  mov [Token.Token], ttglobals
  ret

 
@CompareE8_12_1:
  ret

@CompareE8_12_0:
  // Match endinterface
  mov eax, dword ptr[ecx]; cmp eax, $69646E65; jne @CompareE8_12_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $7265746E; jne @CompareE8_12_1
  mov eax, dword ptr[ecx + 8]; cmp eax, $65636166; jne @CompareE8_12_1

  mov [Token.Token], ttendinterface
  ret

 
@CompareF1_7_1:
  ret

@CompareF1_7_0:
  // Match endloop
  mov eax, dword ptr[ecx]; cmp eax, $6C646E65; jne @CompareF1_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6F6F; jne @CompareF1_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $70; jne @CompareF1_7_1

  mov [Token.Token], ttendloop
  ret

 
@CompareF5_7_1:
  ret

@CompareF5_7_0:
  // Match library
  mov eax, dword ptr[ecx]; cmp eax, $7262696C; jne @CompareF5_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $7261; jne @CompareF5_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $79; jne @CompareF5_7_1

  mov [Token.Token], ttlibrary
  ret

 
@CompareF7_7_1:
  ret

@CompareF7_7_0:
  // Match nothing
  mov eax, dword ptr[ecx]; cmp eax, $68746F6E; jne @CompareF7_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6E69; jne @CompareF7_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $67; jne @CompareF7_7_1

  mov [Token.Token], ttnothing
  ret

 
@CompareF9_12_1:
  ret

@CompareF9_12_0:
  // Match library_once
  mov eax, dword ptr[ecx]; cmp eax, $7262696C; jne @CompareF9_12_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $5F797261; jne @CompareF9_12_1
  mov eax, dword ptr[ecx + 8]; cmp eax, $65636E6F; jne @CompareF9_12_1

  mov [Token.Token], ttlibrary_once
  ret

 
@CompareFB_7_2:
  ret

@CompareFB_7_0:
  // Match private
  mov eax, dword ptr[ecx]; cmp eax, $76697270; jne @CompareFB_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $7461; jne @CompareFB_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $65; jne @CompareFB_7_1

  mov [Token.Token], ttprivate
  ret

@CompareFB_7_1:
  // Match extends
  mov eax, dword ptr[ecx]; cmp eax, $65747865; jne @CompareFB_7_2
  movzx eax, word ptr [ecx + 4]; cmp eax, $646E; jne @CompareFB_7_2
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @CompareFB_7_2

  mov [Token.Token], ttextends
  ret


{$ENDREGION}
end;

procedure InitKeywords;
begin
end;

end.
