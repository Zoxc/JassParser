unit Blocks;

interface

uses SysUtils, Scopes, Classes, Tokens, Scanner;

type
  PDocument = ^TDocument;
  TDocument = object(TScope)
    Info: PDocumentInfo;
  end;

procedure ParseType;
procedure ParseGlobals;
procedure ParseDocument(var ADocument: TDocument);

const
  BlockEnders = [ttEnd, ttEndFunction, ttGlobals, ttFunction, ttNative];

var
  CurrentDocument: PDocument;
  CurrentScope: PScope;
  CurrentFunc: PFunction;

implementation

uses Dialogs, Statements, Expressions, Documents, TypesUtils;

procedure ParseGlobal;
var GlobalType: PType;
  Global: PVariable;
  IsArray: Boolean;
  GlobalInfo: TTokenInfo;
begin
  CurrentConstant := Matches(ttConstant);

  GlobalType := CurrentScope.FindType;

  IsArray := Matches(ttArray);

  if CurrentConstant or IsArray then
    GlobalInfo := Token;

  Global := CurrentScope.DeclareVariable;
  Global.VariableType := GlobalType;

  if IsArray then
    Include(Global.Flags, vfArray);

  if CurrentConstant then
    Include(Global.Flags, vfConstant);

  if Matches(ttAssign) then
    begin
      if IsArray then
        with TErrorInfo.Create(eiArrayInitiation, GlobalInfo)^ do
          begin
            Identifier := Global;
            
            Report;
          end;

      CurrentDeclaration := Global;
      CurrentGlobal := True;

      ParseRootExpression(GlobalType);

      CurrentGlobal := False;
      CurrentDeclaration := nil;
    end
  else if CurrentConstant then
    with TErrorInfo.Create(eiConstantNeedInit, GlobalInfo)^ do
      begin
        Info := GlobalInfo.StrNew;
        Report;
      end;

  CurrentConstant := False;

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

  NewType := CurrentScope.DeclareType;

  Match(ttExtends);

  Extends := CurrentScope.FindType;
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

        ParamType := CurrentScope.FindType;
        Header.Parameters[i] := CurrentScope.DeclareVariable;
        Header.Parameters[i].VariableType := ParamType;
        Header.Parameters[i].Initialized := True;
        Header.Parameters[i].Flags := [vfParameter];
        
        More := Token.Token = ttComma;

        if More then
          Next; // Skip comma

      until not More;
    end;

  Match(ttReturns);

  if not Matches(ttNothing) then
    Header.Returns := CurrentScope.FindType
  else
    Header.Returns := NothingType;
end;

procedure ParseFunction;
var
  IsNative: Boolean;
  Func: PFunction;
  Scope: PScope;
begin
  CurrentConstant := Matches(ttConstant);

  IsNative := Matches(ttNative);
  
  if not IsNative then
    Match(ttFunction);

  Func := CurrentScope.DeclareFunction;
  Func.Native := IsNative;
  Func.Constant := CurrentConstant;

  CurrentFunc := Func;

  Scope := CurrentScope;
  CurrentScope := Func.Scope;
  CurrentLoop := 0;
  CurrentReturnError := nil;
  NoLocals := False;
  NoReturn := True;

  ParseHeader(Func.Header);

  if not IsNative then
    begin
      while not (Token.Token in BlockEnders) do
        ParseStatement;

      if NoReturn and (Func.Header.Returns <> nil) and (Func.Header.Returns <> NothingType) then
        Match(ttReturn);

      Match(ttEndFunction);
    end;

  CurrentConstant := False;
  CurrentScope := Scope;
  CurrentFunc := nil;
  CurrentLoop := 0;

  EndOfLine;
end;

procedure ParseDocument(var ADocument: TDocument);
begin
  CurrentDocument := @ADocument;
  CurrentDocument.Parent := nil;
  CurrentScope := CurrentDocument;

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

  ADocument.Info.GenerateChildErrors;

  CurrentDocument := nil;
  CurrentScope := nil;
end;

end.
