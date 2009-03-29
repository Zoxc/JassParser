unit Documents;

interface

uses Classes, Scopes;

var
  DocumentList: TList;

implementation

uses SysUtils, Blocks, TypesUtils;

var NativeDocument: TDocument;

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

var
  NullTypeVar: TType;
  NothingTypeVar: TType;

initialization
  DocumentList := TList.Create;
  DocumentList.Add(@NativeDocument);
  NativeDocument.Init;

  DeclareType(HandleType, 'handle');
  DeclareType(StringType, 'string');
  DeclareType(IntegerType, 'integer');
  DeclareType(RealType, 'real');
  DeclareType(BooleanType, 'boolean');
  DeclareType(CodeType, 'code');

  NullType := @NullTypeVar;
  NullType.Extends := nil;
  NullType.Next := nil;
  NullType.IdentifierType := itType;
  NullType.Name := 'null';

  NothingType := @NothingTypeVar;
  NothingType.Extends := nil;
  NothingType.Next := nil;
  NothingType.IdentifierType := itType;
  NothingType.Name := 'nothing';

finalization
  DocumentList.Free;
  NativeDocument.Free;

end.
