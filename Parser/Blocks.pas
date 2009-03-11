unit Blocks;

interface

uses SysUtils, Scope, Classes;

type
  PDocument = ^TDocument;
  TDocument = object(TScope)
  end;

procedure ParseType;
procedure ParseGlobals;
procedure ParseDocument(var ADocument: TDocument);

var
  Document: PDocument;
  Scope: PScope;

implementation

uses Scanner, Tokens, Dialogs, Errors;

procedure ParseGlobal;
var GlobalType: PType;
  Global: PVariable;
  IsArray: Boolean;
  IsConstant: Boolean;
  GlobalInfo: TTokenInfo;
begin
  IsConstant := Matches(ttConstant);

  GlobalType := Scope.FindType;

  IsArray := Matches(ttArray);

  if IsConstant then
    GlobalInfo := Token;

  Global := Scope.DeclareVariable;
  Global.VariableType := GlobalType;
  Global.Flags := [];

  if IsArray then
    Include(Global.Flags, vfArray);

  if IsConstant then
    Include(Global.Flags, vfConstant);

  if Matches(ttEqual) then
    begin
    
    end
  else if IsConstant then
    with TErrorInfo.Create(eiConstantNeedInit, GlobalInfo)^ do
      begin
        Info := GlobalInfo.StrNew;
        Report;
      end;     

  EndOfLine;
end;

procedure ParseGlobals;
begin
  Match(ttGlobals);

  EndOfLine;

  repeat

    case Token.Token of
      ttConstant, ttIdentifier: ParseGlobal;
      ttLine: Next;
      ttEndGlobals, ttEnd: Break;
      else Unexpected;
    end;

  until False;
   
  Match(ttEndGlobals);
end;

procedure ParseType;
var NewType, Extends: PType;
begin
  Match(ttType);

  NewType := Document.DeclareType;

  Match(ttExtends);

  Extends := Document.FindType;
  NewType.Extends := Extends;

  EndOfLine;
end;

procedure ParseHeader(var Header: TFunctionHeader);
var
  i: Integer;
  ParamType: PType;
  More: Boolean;
begin
  Match(ttTakes);

  if not Matches(ttNothing) then
    begin
      i := High(Header.Parameters);
      
      repeat

        i := i + 1;
        SetLength(Header.Parameters, i + 1);

        ParamType := Scope.FindType;
        Header.Parameters[i] := Scope.DeclareVariable;
        Header.Parameters[i].VariableType := ParamType;

        More := Token.Token = ttComma;

        if More then
          Next; // Skip comma

      until not More;
    end;

  Match(ttReturns);

  if not Matches(ttNothing) then
    Header.Returns := Scope.FindType;
end;

procedure ParseFunction;
var
  IsConstant: Boolean;
  IsNative: Boolean;
  Func: PFunction;
  AScope: PScope;
begin
  IsConstant := Matches(ttConstant);

  IsNative := Matches(ttNative);
  
  if not IsNative then
    Match(ttFunction);

  Func := Scope.DeclareFunction;
  Func.Native := IsNative;
  Func.Constant := IsConstant;


  AScope := Scope;
  Scope := Func.Scope;

  ParseHeader(Func.Header);

  Scope := AScope;

  EndOfLine;
end;

procedure ParseDocument(var ADocument: TDocument);
begin
  Document := @ADocument;
  Document.Parent := nil;
  Scope := Document;
  
  repeat

    case Token.Token of
      ttConstant, ttNative, ttFunction: ParseFunction;
      ttType: ParseType;
      ttGlobals: ParseGlobals;
      ttLine: Next;
      ttEnd: Break; // Do nothing
      else Unexpected;
    end;

  until False;

  Document := nil;
  Scope := nil;
end;

end.
