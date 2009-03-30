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
  cmp edx, 9
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
 dd @Return
 dd @Check06
 dd @Check07
 dd @Return
 dd @Return
 dd @Return
 dd @Check0B
 dd @Return
 dd @Return
 dd @Return
 dd @Return
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
 dd @Return
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
 dd @Return
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
 dd @Return
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
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Check87
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
 dd @Return
 dd @Check9C
 dd @Check9D
 dd @Return
 dd @Return
 dd @CheckA0
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
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
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @Return
 dd @CheckBA
 dd @CheckBB
 dd @Return
 dd @Return
 dd @Return
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
 dd @Return
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
 dd @Return
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
 dd @Return
 dd @Return
 dd @CheckF7
 dd @Return
 dd @Return
 dd @Return
 dd @CheckFB
 dd @Return
 dd @Return
 dd @Return
 dd @Return

@Check06:
  cmp edx, 3
  je @Compare06_5_0
  ret

@Check07:
  cmp edx, 3
  je @Compare07_5_0
  ret

@Check0B:
  cmp edx, 3
  je @Compare0B_5_0
  ret

@Check13:
  cmp edx, 5
  je @Compare13_7_0
  ret

@Check18:
  cmp edx, 3
  je @Compare18_5_0
  ret

@Check1B:
  cmp edx, 8
  je @Compare1B_10_0
  ret

@Check1F:
  cmp edx, 3
  je @Compare1F_5_0
  ret

@Check33:
  cmp edx, 1
  je @Compare33_3_0
  ret

@Check4C:
  cmp edx, 1
  je @Compare4C_3_0
  ret

@Check51:
  cmp edx, 1
  je @Compare51_3_0
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

@Check78:
  cmp edx, 4
  je @Compare78_6_0
  ret

@Check87:
  cmp edx, 4
  je @Compare87_6_0
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

@CheckA9:
  cmp edx, 2
  je @CompareA9_4_0
  ret

@CheckAF:
  cmp edx, 2
  je @CompareAF_4_0
  ret

@CheckBA:
  cmp edx, 2
  je @CompareBA_4_0
  ret

@CheckBB:
  cmp edx, 2
  je @CompareBB_4_0
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

@CheckE1:
  cmp edx, 0
  je @CompareE1_2_0
  ret

@CheckE4:
  cmp edx, 5
  je @CompareE4_7_0
  ret

@CheckF1:
  cmp edx, 5
  je @CompareF1_7_0
  ret

@CheckF7:
  cmp edx, 5
  je @CompareF7_7_0
  ret

@CheckFB:
  cmp edx, 5
  je @CompareFB_7_0
  ret
 
@Compare06_5_1:
  ret

@Compare06_5_0:
  // Match endif
  mov eax, dword ptr[ecx]; cmp eax, $69646E65; jne @Compare06_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $66; jne @Compare06_5_1

  mov [Token.Token], ttendif
  ret

 
@Compare07_5_1:
  ret

@Compare07_5_0:
  // Match debug
  mov eax, dword ptr[ecx]; cmp eax, $75626564; jne @Compare07_5_1
  mov al, byte ptr [ecx + 4]; cmp al, $67; jne @Compare07_5_1

  mov [Token.Token], ttdebug
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

 
@Compare33_3_1:
  ret

@Compare33_3_0:
  // Match and
  movzx eax, word ptr [ecx]; cmp eax, $6E61; jne @Compare33_3_1
  mov al, byte ptr [ecx + 2]; cmp al, $64; jne @Compare33_3_1

  mov [Token.Token], ttand
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
  ret

@Compare51_3_0:
  // Match not
  movzx eax, word ptr [ecx]; cmp eax, $6F6E; jne @Compare51_3_1
  mov al, byte ptr [ecx + 2]; cmp al, $74; jne @Compare51_3_1

  mov [Token.Token], ttnot
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

 
@Compare6C_8_1:
  ret

@Compare6C_8_0:
  // Match exitwhen
  mov eax, dword ptr[ecx]; cmp eax, $74697865; jne @Compare6C_8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $6E656877; jne @Compare6C_8_1

  mov [Token.Token], ttexitwhen
  ret

 
@Compare78_6_1:
  ret

@Compare78_6_0:
  // Match elseif
  mov eax, dword ptr[ecx]; cmp eax, $65736C65; jne @Compare78_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6669; jne @Compare78_6_1

  mov [Token.Token], ttelseif
  ret

 
@Compare87_6_1:
  ret

@Compare87_6_0:
  // Match native
  mov eax, dword ptr[ecx]; cmp eax, $6974616E; jne @Compare87_6_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6576; jne @Compare87_6_1

  mov [Token.Token], ttnative
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

 
@CompareC0_4_1:
  ret

@CompareC0_4_0:
  // Match true
  mov eax, dword ptr[ecx]; cmp eax, $65757274; jne @CompareC0_4_1

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

 
@CompareF1_7_1:
  ret

@CompareF1_7_0:
  // Match endloop
  mov eax, dword ptr[ecx]; cmp eax, $6C646E65; jne @CompareF1_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6F6F; jne @CompareF1_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $70; jne @CompareF1_7_1

  mov [Token.Token], ttendloop
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

 
@CompareFB_7_1:
  ret

@CompareFB_7_0:
  // Match extends
  mov eax, dword ptr[ecx]; cmp eax, $65747865; jne @CompareFB_7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $646E; jne @CompareFB_7_1
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @CompareFB_7_1

  mov [Token.Token], ttextends
  ret


{$ENDREGION}
end;

procedure InitKeywords;
begin
end;

end.
