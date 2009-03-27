unit Statements;

interface

uses SysUtils;

procedure ParseStatements;

implementation

uses Blocks, Scopes, Scanner, Tokens, Expressions;

procedure ParseLocal(Identifier: PType);
var LocalType: PType;
  Local: PVariable;
  IsArray: Boolean;
begin
  Match(ttLocal);

  if Identifier <> nil then
    begin
      LocalType := Identifier;
      Next;
    end
  else
    LocalType := Scope.FindType;

  IsArray := Matches(ttArray);

  Local := Scope.DeclareVariable;
  Local.VariableType := LocalType;
  Local.Flags := [];

  if IsArray then
    Include(Local.Flags, vfArray);

  if Matches(ttEqual) then
      Expression;

  EndOfLine;
end;

procedure ParseSet(Identifier: PVariable);
var
  Variable: PVariable;
begin
  Match(ttSet);

  if Identifier <> nil then
    begin
      Variable := Identifier;
      Next;
    end
  else
    Variable := Scope.FindVariable;

  Match(ttEqual);

  Expression;

  EndOfLine;
end;

procedure ParseCall(Identifier: PFunction);
var
  Func: PFunction;
begin
  Match(ttCall);

  if Identifier <> nil then
    Func := Identifier
  else
    Func := Scope.FindFunction(False);

  FunctionCall(Func);

  Match(ttEqual);

  EndOfLine;
end;

procedure ParseIdentifier;
var Identifier: PIdentifier;
begin
  Identifier := Scope^.Find(True);

  if Identifier = nil then
    Unexpected
  else
    case Identifier.IdentifierType of
      itType: ParseLocal(PType(Identifier));
      itVariable: ParseSet(PVariable(Identifier));
      itFunction: ParseCall(PFunction(Identifier));
      else UnexpectedIdentifier(Identifier);
    end;
end;

procedure ParseStatements;
begin
  repeat
    case Token.Token of
      ttLocal: ParseLocal(nil);
      ttSet: ParseSet(nil);
      ttCall: ParseCall(nil);
      ttIdentifier: ParseIdentifier;
      ttEnd, ttEndFunction, ttGlobals, ttFunction, ttNative, ttConstant, ttEndLoop: Break;
      ttLine: Next;
      else Unexpected;
    end;
  until False;
end;

end.
