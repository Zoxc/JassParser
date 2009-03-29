unit Expressions;

interface

uses Scopes;

procedure ParseExpression;
procedure ParseConstantExpression;

procedure ParseFunctionCall(Func: PFunction);
//procedure ParseConstantFunctionCall(Func: PFunction);

procedure ParseVariable(Variable: PVariable);
//procedure ParseVariable(Func: PFunction);

implementation

uses SysUtils, Blocks, Scanner, Tokens;

var
  Constant: Boolean;

procedure ParseVariable(Variable: PVariable);
var
  VarToken: TTokenInfo;
begin
  VarToken := Token;

  Next;

  if Matches(ttSquareOpen) then
    begin
      ParseExpression;
      
      Match(ttSquareClose);
    end;
end;

procedure ParseFunctionCall(Func: PFunction);
var ParamCount: Integer;
  FuncToken: TTokenInfo;
begin
  FuncToken := Token;

  Next;

  ParamCount := 0;

  if Match(ttParentOpen) then
    begin
      if Token.Token <> ttParentClose then
        begin
          ParseExpression;

          Inc(ParamCount);

          while Token.Token = ttComma do
            begin
              Next;
              Inc(ParamCount);
              ParseExpression;
            end;

        end;
      Match(ttParentClose);

      if (Func <> nil) and (Length(Func.Header.Parameters) <> ParamCount) then
        with TErrorInfo.Create(eiParameterCount, FuncToken)^ do
          begin
            CalledFunction := Func;
            ParameterCount := ParamCount;
            Report;
          end;
    end;
end;
{
procedure ParseConstantFunctionCall(Func: PFunction);
var Old: Boolean;
begin
  Old := Constant;
  Constant := True;

  ParseFunctionCall(Func);

  Constant := Old;
end;
}
procedure ParseFactor;
var Identifier: PIdentifier;
begin
  case Token.Token of
    ttAdd, ttSub:
      begin
        Next;
        ParseExpression;
      end;

    ttFunction:
      begin
        Next;
        CurrentScope.FindFunction;
      end;
    
    ttNull:
      begin
        Next;
      end;

    ttIdentifier:
      begin
        Identifier := CurrentScope^.Find(True);
        
        if Identifier = nil then
          Unexpected
        else
          case Identifier.IdentifierType of
            //itType: ParseLocal(PType(Identifier));
            itVariable: ParseVariable(PVariable(Identifier));
            itFunction: ParseFunctionCall(PFunction(Identifier));
            else UnexpectedIdentifier(Identifier);
          end;
      end;

    ttTrue, ttFalse:
      begin
        Next;
      end;
      
    ttNumber, ttOctal, ttHex, ttRawId:
      begin
        Next;
      end;

    ttString:
      begin
        Next;
      end;

    ttReal:
      begin
        Next;
      end;

    ttParentOpen:
      begin
        Next;

        ParseExpression;

        Match(ttParentClose);
      end;

    else Expected(ttExpression);
  end;
end;

procedure ParseArithmetic;
begin
  ParseFactor;

  while Token.Token in [ttAdd, ttSub, ttMul, ttDiv] do
    begin
      Next;

      ParseFactor;
    end;
end;

procedure ParseComparison;
begin
  ParseArithmetic;

  while Token.Token in [ttEqual, ttAssign, ttGreaterOrEqual, ttGreater, ttLess, ttLessOrEqual, ttNotEqual] do
    begin
      if Token.Token = ttAssign then
        TErrorInfo.Create(eiDoubleEquals).Report;
        
      Next;

      ParseArithmetic;
    end;
end;

procedure ParseConstantExpression;
var Old: Boolean;
begin
  Old := Constant;
  Constant := True;

  ParseExpression;

  Constant := Old;
end;

procedure ParseExpression;
begin
  if Token.Token = ttNot then
    Next;

  ParseComparison;

  while Token.Token in [ttAnd, ttOr] do
    begin
      Next;
      
      if Token.Token = ttNot then
        Next;

      ParseComparison;
    end;
end;

end.
