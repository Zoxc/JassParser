unit ScannerKeywordsLengthTable;

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
  cmp edx, 12
  ja @Return
  jmp dword ptr [@JumpTable + edx * 4]

@Return:
  ret

@JumpTable:
 dd @Return
 dd @Return
 dd @Check_2
 dd @Check_3
 dd @Check_4
 dd @Check_5
 dd @Check_6
 dd @Check_7
 dd @Check_8
 dd @Check_9
 dd @Check_10
 dd @Check_11
 dd @Check_12

@Check_2:
  sub al, $CF
  cmp al, $12
  jbe @Check_2_InRange
  ret

@Check_2_InRange:
  cmp al, $00
  je @Check_2_CF
  cmp al, $12
  je @Check_2_E1
  ret

@Check_3:
  sub al, $33
  cmp al, $1E
  jbe @Check_3_InRange
  ret

@Check_3_InRange:
  cmp al, $00
  je @Check_3_33
  cmp al, $19
  je @Check_3_4C
  cmp al, $1E
  je @Check_3_51
  ret

@Check_4:
  cmp al, $9C
  je @Check_4_9C
  cmp al, $A9
  je @Check_4_A9
  cmp al, $AF
  je @Check_4_AF
  cmp al, $BA
  je @Check_4_BA
  cmp al, $BE
  je @Check_4_BE
  cmp al, $C0
  je @Check_4_C0
  cmp al, $C2
  je @Check_4_C2
  ret

@Check_5:
  sub al, $06
  cmp al, $19
  jbe @Check_5_InRange
  ret

@Check_5_InRange:
  cmp al, $00
  je @Check_5_06
  cmp al, $05
  je @Check_5_0B
  cmp al, $09
  je @Check_5_0F
  cmp al, $12
  je @Check_5_18
  cmp al, $14
  je @Check_5_1A
  cmp al, $19
  je @Check_5_1F
  ret

@Check_6:
  cmp al, $78
  je @Check_6_78
  cmp al, $7F
  je @Check_6_7F
  cmp al, $81
  je @Check_6_81
  cmp al, $87
  je @Check_6_87
  cmp al, $88
  je @Check_6_88
  cmp al, $A0
  je @Check_6_A0
  cmp al, $A5
  je @Check_6_A5
  ret

@Check_7:
  cmp al, $05
  je @Check_7_05
  cmp al, $13
  je @Check_7_13
  cmp al, $E4
  je @Check_7_E4
  cmp al, $F1
  je @Check_7_F1
  cmp al, $F5
  je @Check_7_F5
  cmp al, $F7
  je @Check_7_F7
  cmp al, $FB
  je @Check_7_FB
  ret

@Check_8:
  cmp al, $3B
  je @Check_8_3B
  cmp al, $51
  je @Check_8_51
  cmp al, $58
  je @Check_8_58
  cmp al, $5E
  je @Check_8_5E
  cmp al, $66
  je @Check_8_66
  cmp al, $6A
  je @Check_8_6A
  cmp al, $6C
  je @Check_8_6C
  cmp al, $70
  je @Check_8_70
  ret

@Check_9:
  cmp al, $B1
  je @Check_9_B1
  cmp al, $B8
  je @Check_9_B8
  cmp al, $DC
  je @Check_9_DC
  ret

@Check_10:
  sub al, $1B
  cmp al, $11
  jbe @Check_10_InRange
  ret

@Check_10_InRange:
  cmp al, $00
  je @Check_10_1B
  cmp al, $11
  je @Check_10_2C
  ret

@Check_11:
  sub al, $9D
  cmp al, $07
  jbe @Check_11_InRange
  ret

@Check_11_InRange:
  cmp al, $00
  je @Check_11_9D
  cmp al, $07
  je @Check_11_A4
  ret

@Check_12:
  sub al, $E8
  cmp al, $11
  jbe @Check_12_InRange
  ret

@Check_12_InRange:
  cmp al, $00
  je @Check_12_E8
  cmp al, $11
  je @Check_12_F9
  ret

@Check_2_CF:

  // Match if
  movzx eax, word ptr [ecx]; cmp eax, $6669; jne @Check_2_CF_1

  mov [Token.Token], 54
@Check_2_CF_1:
  ret

@Check_2_E1:

  // Match or
  movzx eax, word ptr [ecx]; cmp eax, $726F; jne @Check_2_E1_1

  mov [Token.Token], 41
@Check_2_E1_1:
  ret

@Check_3_33:

  // Match and
  movzx eax, word ptr [ecx]; cmp eax, $6E61; jne @Check_3_33_1
  mov al, byte ptr [ecx + 2]; cmp al, $64; jne @Check_3_33_1

  mov [Token.Token], 39
@Check_3_33_1:
  ret

@Check_3_4C:

  // Match set
  movzx eax, word ptr [ecx]; cmp eax, $6573; jne @Check_3_4C_1
  mov al, byte ptr [ecx + 2]; cmp al, $74; jne @Check_3_4C_1

  mov [Token.Token], 37
@Check_3_4C_1:
  ret

@Check_3_51:

  // Match not
  movzx eax, word ptr [ecx]; cmp eax, $6F6E; jne @Check_3_51_1
  mov al, byte ptr [ecx + 2]; cmp al, $74; jne @Check_3_51_1

  mov [Token.Token], 40
@Check_3_51_1:
  ret

@Check_4_9C:

  // Match call
  mov eax, dword ptr[ecx]; cmp eax, $6C6C6163; jne @Check_4_9C_1

  mov [Token.Token], 38
@Check_4_9C_1:
  ret

@Check_4_A9:

  // Match else
  mov eax, dword ptr[ecx]; cmp eax, $65736C65; jne @Check_4_A9_1

  mov [Token.Token], 57
@Check_4_A9_1:
  ret

@Check_4_AF:

  // Match then
  mov eax, dword ptr[ecx]; cmp eax, $6E656874; jne @Check_4_AF_1

  mov [Token.Token], 56
@Check_4_AF_1:
  ret

@Check_4_BA:

  // Match loop
  mov eax, dword ptr[ecx]; cmp eax, $706F6F6C; jne @Check_4_BA_1

  mov [Token.Token], 59
@Check_4_BA_1:
  ret

@Check_4_BE:

  // Match stub
  mov eax, dword ptr[ecx]; cmp eax, $62757473; jne @Check_4_BE_1

  mov [Token.Token], 64
@Check_4_BE_1:
  ret

@Check_4_C0:

  // Match uses
  mov eax, dword ptr[ecx]; cmp eax, $73657375; jne @Check_4_C0_1

  mov [Token.Token], 35
@Check_4_C0_1:
  ret

@Check_4_C2:

  // Match type
  mov eax, dword ptr[ecx]; cmp eax, $65707974; jne @Check_4_C2_1

  mov [Token.Token], 27
@Check_4_C2_1:
  ret

@Check_5_06:

  // Match endif
  mov eax, dword ptr[ecx]; cmp eax, $69646E65; jne @Check_5_06_1
  mov al, byte ptr [ecx + 4]; cmp al, $66; jne @Check_5_06_1

  mov [Token.Token], 55
@Check_5_06_1:
  ret

@Check_5_0B:

  // Match local
  mov eax, dword ptr[ecx]; cmp eax, $61636F6C; jne @Check_5_0B_1
  mov al, byte ptr [ecx + 4]; cmp al, $6C; jne @Check_5_0B_1

  mov [Token.Token], 53
@Check_5_0B_1:
  ret

@Check_5_0F:

  // Match needs
  mov eax, dword ptr[ecx]; cmp eax, $6465656E; jne @Check_5_0F_1
  mov al, byte ptr [ecx + 4]; cmp al, $73; jne @Check_5_0F_1

  mov [Token.Token], 34
@Check_5_0F_1:
  ret

@Check_5_18:

  // Match takes
  mov eax, dword ptr[ecx]; cmp eax, $656B6174; jne @Check_5_18_1
  mov al, byte ptr [ecx + 4]; cmp al, $73; jne @Check_5_18_1

  mov [Token.Token], 22
@Check_5_18_1:
  ret

@Check_5_1A:

  // Match scope
  mov eax, dword ptr[ecx]; cmp eax, $706F6373; jne @Check_5_1A_1
  mov al, byte ptr [ecx + 4]; cmp al, $65; jne @Check_5_1A_1

  mov [Token.Token], 42
@Check_5_1A_1:
  ret

@Check_5_1F:

  // Match array
  mov eax, dword ptr[ecx]; cmp eax, $61727261; jne @Check_5_1F_1
  mov al, byte ptr [ecx + 4]; cmp al, $79; jne @Check_5_1F_1

  mov [Token.Token], 29
@Check_5_1F_1:
  ret

@Check_6_78:

  // Match elseif
  mov eax, dword ptr[ecx]; cmp eax, $65736C65; jne @Check_6_78_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6669; jne @Check_6_78_1

  mov [Token.Token], 58
@Check_6_78_1:
  ret

@Check_6_7F:

  // Match public
  mov eax, dword ptr[ecx]; cmp eax, $6C627570; jne @Check_6_7F_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6369; jne @Check_6_7F_1

  mov [Token.Token], 63
@Check_6_7F_1:
  ret

@Check_6_81:

  // Match method
  mov eax, dword ptr[ecx]; cmp eax, $6874656D; jne @Check_6_81_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $646F; jne @Check_6_81_1

  mov [Token.Token], 49
@Check_6_81_1:
  ret

@Check_6_87:

  // Match native
  mov eax, dword ptr[ecx]; cmp eax, $6974616E; jne @Check_6_87_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6576; jne @Check_6_87_1

  mov [Token.Token], 26
@Check_6_87_1:
  ret

@Check_6_88:

  // Match static
  mov eax, dword ptr[ecx]; cmp eax, $74617473; jne @Check_6_88_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6369; jne @Check_6_88_1

  mov [Token.Token], 65
@Check_6_88_1:
  ret

@Check_6_A0:

  // Match return
  mov eax, dword ptr[ecx]; cmp eax, $75746572; jne @Check_6_A0_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6E72; jne @Check_6_A0_1

  mov [Token.Token], 52
@Check_6_A0_1:
  ret

@Check_6_A5:

  // Match struct
  mov eax, dword ptr[ecx]; cmp eax, $75727473; jne @Check_6_A5_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $7463; jne @Check_6_A5_1

  mov [Token.Token], 47
@Check_6_A5_1:
  ret

@Check_7_05:

  // Match keyword
  mov eax, dword ptr[ecx]; cmp eax, $7779656B; jne @Check_7_05_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $726F; jne @Check_7_05_1
  mov al, byte ptr [ecx + 6]; cmp al, $64; jne @Check_7_05_1

  mov [Token.Token], 67
@Check_7_05_1:
  ret

@Check_7_13:

  // Match returns
  mov eax, dword ptr[ecx]; cmp eax, $75746572; jne @Check_7_13_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6E72; jne @Check_7_13_1
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @Check_7_13_1

  mov [Token.Token], 23
@Check_7_13_1:
  ret

@Check_7_E4:

  // Match globals
  mov eax, dword ptr[ecx]; cmp eax, $626F6C67; jne @Check_7_E4_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6C61; jne @Check_7_E4_1
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @Check_7_E4_1

  mov [Token.Token], 18
@Check_7_E4_1:
  ret

@Check_7_F1:

  // Match endloop
  mov eax, dword ptr[ecx]; cmp eax, $6C646E65; jne @Check_7_F1_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6F6F; jne @Check_7_F1_1
  mov al, byte ptr [ecx + 6]; cmp al, $70; jne @Check_7_F1_1

  mov [Token.Token], 60
@Check_7_F1_1:
  ret

@Check_7_F5:

  // Match library
  mov eax, dword ptr[ecx]; cmp eax, $7262696C; jne @Check_7_F5_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $7261; jne @Check_7_F5_1
  mov al, byte ptr [ecx + 6]; cmp al, $79; jne @Check_7_F5_1

  mov [Token.Token], 30
@Check_7_F5_1:
  ret

@Check_7_F7:

  // Match nothing
  mov eax, dword ptr[ecx]; cmp eax, $68746F6E; jne @Check_7_F7_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $6E69; jne @Check_7_F7_1
  mov al, byte ptr [ecx + 6]; cmp al, $67; jne @Check_7_F7_1

  mov [Token.Token], 24
@Check_7_F7_1:
  ret

@Check_7_FB:

  // Match extends
  mov eax, dword ptr[ecx]; cmp eax, $65747865; jne @Check_7_FB_1
  movzx eax, word ptr [ecx + 4]; cmp eax, $646E; jne @Check_7_FB_1
  mov al, byte ptr [ecx + 6]; cmp al, $73; jne @Check_7_FB_1

  mov [Token.Token], 28
  ret

@Check_7_FB_1:

  // Match private
  mov eax, dword ptr[ecx]; cmp eax, $76697270; jne @Check_7_FB_2
  movzx eax, word ptr [ecx + 4]; cmp eax, $7461; jne @Check_7_FB_2
  mov al, byte ptr [ecx + 6]; cmp al, $65; jne @Check_7_FB_2

  mov [Token.Token], 62
@Check_7_FB_2:
  ret

@Check_8_3B:

  // Match delegate
  mov eax, dword ptr[ecx]; cmp eax, $656C6564; jne @Check_8_3B_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $65746167; jne @Check_8_3B_1

  mov [Token.Token], 66
@Check_8_3B_1:
  ret

@Check_8_51:

  // Match endscope
  mov eax, dword ptr[ecx]; cmp eax, $73646E65; jne @Check_8_51_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $65706F63; jne @Check_8_51_1

  mov [Token.Token], 43
@Check_8_51_1:
  ret

@Check_8_58:

  // Match defaults
  mov eax, dword ptr[ecx]; cmp eax, $61666564; jne @Check_8_58_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $73746C75; jne @Check_8_58_1

  mov [Token.Token], 46
@Check_8_58_1:
  ret

@Check_8_5E:

  // Match readonly
  mov eax, dword ptr[ecx]; cmp eax, $64616572; jne @Check_8_5E_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $796C6E6F; jne @Check_8_5E_1

  mov [Token.Token], 68
@Check_8_5E_1:
  ret

@Check_8_66:

  // Match function
  mov eax, dword ptr[ecx]; cmp eax, $636E7566; jne @Check_8_66_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $6E6F6974; jne @Check_8_66_1

  mov [Token.Token], 20
@Check_8_66_1:
  ret

@Check_8_6A:

  // Match constant
  mov eax, dword ptr[ecx]; cmp eax, $736E6F63; jne @Check_8_6A_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $746E6174; jne @Check_8_6A_1

  mov [Token.Token], 25
@Check_8_6A_1:
  ret

@Check_8_6C:

  // Match operator
  mov eax, dword ptr[ecx]; cmp eax, $7265706F; jne @Check_8_6C_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $726F7461; jne @Check_8_6C_1

  mov [Token.Token], 51
  ret

@Check_8_6C_1:

  // Match exitwhen
  mov eax, dword ptr[ecx]; cmp eax, $74697865; jne @Check_8_6C_2
  mov eax, dword ptr[ecx + 4]; cmp eax, $6E656877; jne @Check_8_6C_2

  mov [Token.Token], 61
@Check_8_6C_2:
  ret

@Check_8_70:

  // Match requires
  mov eax, dword ptr[ecx]; cmp eax, $75716572; jne @Check_8_70_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $73657269; jne @Check_8_70_1

  mov [Token.Token], 33
@Check_8_70_1:
  ret

@Check_9_B1:

  // Match interface
  mov eax, dword ptr[ecx]; cmp eax, $65746E69; jne @Check_9_B1_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $63616672; jne @Check_9_B1_1
  mov al, byte ptr [ecx + 8]; cmp al, $65; jne @Check_9_B1_1

  mov [Token.Token], 44
@Check_9_B1_1:
  ret

@Check_9_B8:

  // Match endmethod
  mov eax, dword ptr[ecx]; cmp eax, $6D646E65; jne @Check_9_B8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $6F687465; jne @Check_9_B8_1
  mov al, byte ptr [ecx + 8]; cmp al, $64; jne @Check_9_B8_1

  mov [Token.Token], 50
@Check_9_B8_1:
  ret

@Check_9_DC:

  // Match endstruct
  mov eax, dword ptr[ecx]; cmp eax, $73646E65; jne @Check_9_DC_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $63757274; jne @Check_9_DC_1
  mov al, byte ptr [ecx + 8]; cmp al, $74; jne @Check_9_DC_1

  mov [Token.Token], 48
@Check_9_DC_1:
  ret

@Check_10_1B:

  // Match endglobals
  mov eax, dword ptr[ecx]; cmp eax, $67646E65; jne @Check_10_1B_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $61626F6C; jne @Check_10_1B_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $736C; jne @Check_10_1B_1

  mov [Token.Token], 19
@Check_10_1B_1:
  ret

@Check_10_2C:

  // Match endlibrary
  mov eax, dword ptr[ecx]; cmp eax, $6C646E65; jne @Check_10_2C_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $61726269; jne @Check_10_2C_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $7972; jne @Check_10_2C_1

  mov [Token.Token], 32
@Check_10_2C_1:
  ret

@Check_11_9D:

  // Match endfunction
  mov eax, dword ptr[ecx]; cmp eax, $66646E65; jne @Check_11_9D_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $74636E75; jne @Check_11_9D_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $6F69; jne @Check_11_9D_1
  mov al, byte ptr [ecx + 10]; cmp al, $6E; jne @Check_11_9D_1

  mov [Token.Token], 21
@Check_11_9D_1:
  ret

@Check_11_A4:

  // Match initializer
  mov eax, dword ptr[ecx]; cmp eax, $74696E69; jne @Check_11_A4_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $696C6169; jne @Check_11_A4_1
  movzx eax, word ptr [ecx + 8]; cmp eax, $657A; jne @Check_11_A4_1
  mov al, byte ptr [ecx + 10]; cmp al, $72; jne @Check_11_A4_1

  mov [Token.Token], 36
@Check_11_A4_1:
  ret

@Check_12_E8:

  // Match endinterface
  mov eax, dword ptr[ecx]; cmp eax, $69646E65; jne @Check_12_E8_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $7265746E; jne @Check_12_E8_1
  mov eax, dword ptr[ecx + 8]; cmp eax, $65636166; jne @Check_12_E8_1

  mov [Token.Token], 45
@Check_12_E8_1:
  ret

@Check_12_F9:

  // Match library_once
  mov eax, dword ptr[ecx]; cmp eax, $7262696C; jne @Check_12_F9_1
  mov eax, dword ptr[ecx + 4]; cmp eax, $5F797261; jne @Check_12_F9_1
  mov eax, dword ptr[ecx + 8]; cmp eax, $65636E6F; jne @Check_12_F9_1

  mov [Token.Token], 31
@Check_12_F9_1:
  ret

{$ENDREGION}
end;

procedure InitKeywords;
begin
end;

end.
