unit Expressions;

interface

uses Scopes;

procedure Expression;
procedure ConstantExpression;

procedure FunctionCall(Func: PFunction);
procedure ConstantFunctionCall(Func: PFunction);

implementation

uses SysUtils, Blocks, Scanner, Tokens;

var
  Constant: Boolean;

procedure FunctionCall(Func: PFunction);
begin
  if Func.Scope = Scope then
    with TErrorInfo.Create(eiRecursive)^ do
      begin
        Identifier := Func;
        Report;
      end;

  Next;
end;

procedure ConstantFunctionCall(Func: PFunction);
var Old: Boolean;
begin
  Old := Constant;
  Constant := True;

  FunctionCall(Func);

  Constant := Old;
end;

procedure Factor;
var Identifier: PIdentifier;
begin
  case Token.Token of
    ttAdd, ttSub:
      begin
        Next;
        Expression;
      end;
    
    ttNull:
      begin
        Next;
      end;

    ttIdentifier:
      begin
        Identifier := Scope^.Find(True);
        
        if Identifier = nil then
          Unexpected
        else
          case Identifier.IdentifierType of
            //itType: ParseLocal(PType(Identifier));
            //itVariable: ParseSet(PVariable(Identifier));
            itFunction: FunctionCall(PFunction(Identifier));
            else UnexpectedIdentifier(Identifier);
          end;
      end;

    ttTrue, ttFalse:
      begin
        Next;
      end;
      
    ttNumber:
      begin
        Next;
      end;

    ttParentOpen:
      begin
        Next;

        Expression;

        Match(ttParentClose);
      end;

    else Unexpected(False);
  end;
end;

procedure Arithmetic;
begin
  Factor;

  while Token.Token in [ttAdd, ttSub, ttMul, ttDiv] do
    begin
      Next;

      Factor;
    end;
end;

procedure Comparison;
begin
  Arithmetic;

  while Token.Token in [ttCompare] do
    begin
      Next;

      Arithmetic;
    end;
end;

procedure ConstantExpression;
var Old: Boolean;
begin
  Old := Constant;
  Constant := True;

  Expression;

  Constant := Old;
end;

procedure Expression;
begin
  if Token.Token = ttNot then
    Next;

  Comparison;

  while Token.Token in [ttAnd, ttOr] do
    begin
      Next;
      
      if Token.Token = ttNot then
        Next;

      Comparison;
    end;
end;

end.
