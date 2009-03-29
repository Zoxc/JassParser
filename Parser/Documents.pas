unit Documents;

interface

uses Classes, Scopes;

var
  DocumentList: TList;
  HandleType: PType;
  StringType: PType;
  IntegerType: PType;
  RealType: PType;
  BooleanType: PType;
  CodeType: PType;

implementation

uses SysUtils, Blocks;

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


finalization
  DocumentList.Free;
  NativeDocument.Free;

end.
