unit Blocks;

interface

uses SysUtils, Scopes, Classes, Tokens;

type
  PDocument = ^TDocument;
  TDocument = object(TScope)
  end;

procedure ParseType;
procedure ParseGlobals;
procedure ParseDocument(var ADocument: TDocument);

const
  BlockEnders = [ttEnd, ttEndFunction, ttGlobals, ttFunction, ttNative, ttConstant];

var
  CurrentDocument: PDocument;
  CurrentScope: PScope;
  CurrentFunc: PFunction;

implementation

uses Scanner, Dialogs, Statements, Expressions;

procedure ParseGlobal;
var GlobalType: PType;
  Global: PVariable;
  IsArray: Boolean;
  IsConstant: Boolean;
  GlobalInfo: TTokenInfo;
begin
  IsConstant := Matches(ttConstant);

  GlobalType := CurrentScope.FindType;

  IsArray := Matches(ttArray);

  if IsConstant then
    GlobalInfo := Token;

  Global := CurrentScope.DeclareVariable;
  Global.VariableType := GlobalType;
  Global.Flags := [];

  if IsArray then
    Include(Global.Flags, vfArray);

  if IsConstant then
    Include(Global.Flags, vfConstant);

  if Matches(ttAssign) then
    ParseExpression
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

        More := Token.Token = ttComma;

        if More then
          Next; // Skip comma

      until not More;
    end;

  Match(ttReturns);

  if not Matches(ttNothing) then
    Header.Returns := CurrentScope.FindType;
end;

procedure ParseFunction;
var
  IsConstant: Boolean;
  IsNative: Boolean;
  Func: PFunction;
  Scope: PScope;
begin
  IsConstant := Matches(ttConstant);

  IsNative := Matches(ttNative);
  
  if not IsNative then
    Match(ttFunction);

  Func := CurrentScope.DeclareFunction;
  Func.Native := IsNative;
  Func.Constant := IsConstant;

  CurrentFunc := Func;

  Scope := CurrentScope;
  CurrentScope := Func.Scope;
  CurrentLoop := 0;

  ParseHeader(Func.Header);

  if not IsNative then
    begin
      while not (Token.Token in BlockEnders) do
        ParseStatement;

      Match(ttEndFunction);
    end;

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

  CurrentDocument := nil;
  CurrentScope := nil;
end;

end.
