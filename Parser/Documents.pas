unit Documents;

interface

uses Classes;

var
  DocumentList: TList;

implementation

uses SysUtils, Blocks, Scope;

var NativeDocument: TDocument;

procedure DeclareType(Name: PAnsiChar); inline;
var
  AType: PType;
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

  DeclareType('handle');
  DeclareType('string');
  DeclareType('integer');
  DeclareType('real');


finalization
  DocumentList.Free;
  NativeDocument.Free;

end.
