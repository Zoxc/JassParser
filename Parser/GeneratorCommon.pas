unit GeneratorCommon;

interface

uses SysUtils, IniFiles, Classes;

procedure CompareKeyword(Str: PAnsiChar; Pointer, QuitLabel: string);

implementation

uses Dialogs, Scanner, Tokens, SearchCode, HashExplorer, ComCtrls, Math;

procedure CompareKeyword(Str: PAnsiChar; Pointer, QuitLabel: string);
var Len, Index: Integer;
  Value: Cardinal;
  IndexStr: String;
begin
  Len := StrLen(Str);
  Index := 0;

  SearchForm.Memo.Lines.Add('  // Match ' + Str);

  while Len > 0 do
    begin
      if Index = 0 then
        IndexStr := ''
      else
        IndexStr := ' + '+ IntToStr(Index);

      if Len div 4 > 0 then
        begin
          Value := PInteger(@Str[Index])^;
          SearchForm.Memo.Lines.Add('  mov eax, dword ptr[' + Pointer + IndexStr  +']; cmp eax, $' + IntToHex(Value, 8) + '; jne ' + QuitLabel);
          Inc(Index, 4);
          Dec(Len, 4);
        end
      else if Len div 2 > 0 then
        begin
          Value := PWord(@Str[Index])^;
          SearchForm.Memo.Lines.Add('  movzx eax, word ptr [' + Pointer + IndexStr +']; cmp eax, $' + IntToHex(Value, 4) + '; jne ' + QuitLabel);
          Inc(Index, 2);
          Dec(Len, 2);
        end
      else
        begin
          Value := Byte(Str[Index]);
          SearchForm.Memo.Lines.Add('  mov al, byte ptr [' + Pointer + IndexStr +']; cmp al, $' + IntToHex(Value, 2) + '; jne ' + QuitLabel);
          Inc(Index);
          Dec(Len);
        end
    end;
end;



end.
