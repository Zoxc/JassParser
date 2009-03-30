unit Documents;

interface

uses Classes, Scopes;

var
  DocumentList: TList;

implementation

uses SysUtils, Blocks, TypesUtils;

var
  NativeDocument: TDocument;
  NullTypeList: TList;

procedure DeclareType(var AType: PType; Name: PAnsiChar); inline;
var
  Length: Cardinal;
begin
  New(AType);
  AType.Extends := nil;
  AType.IdentifierType := itType;

  Length := StrLen(Name) + 1;
  GetMem(AType.Name, Length);
  Move(Name^, AType.Name^, Length);

  NativeDocument.Add(AType);
end;

procedure DeclareNullType(var AType: PType; Name: PAnsiChar); inline;
begin
  New(AType);
  AType.Extends := nil;
  AType.Next := nil;
  AType.IdentifierType := itType;
  AType.Name := 'null';
end;

initialization
  NullTypeList := TList.Create;
  
  DocumentList := TList.Create;
  DocumentList.Add(@NativeDocument);
  NativeDocument.Init;

  DeclareType(HandleType, 'handle');
  DeclareType(StringType, 'string');
  DeclareType(IntegerType, 'integer');
  DeclareType(RealType, 'real');
  DeclareType(BooleanType, 'boolean');
  DeclareType(CodeType, 'code');

  DeclareType(HandleConstant, 'null');
  DeclareType(StringConstant, 'string constant');
  DeclareType(IntegerConstant, 'integer constant');
  DeclareType(RealConstant, 'real constant');
  DeclareType(BooleanConstant, 'boolean constant');
  DeclareType(CodeConstant, 'code constant');

  DeclareType(NothingType, 'nothing');

finalization
  DocumentList.Free;
  NativeDocument.Free;

  while NullTypeList.Count > 0 do
    begin
      PType(NullTypeList[0]).Free;
      NullTypeList.Delete(0);
    end;

  NullTypeList.Free;
end.
