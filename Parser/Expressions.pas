unit Expressions;

interface

uses Scopes, SysUtils, Blocks, Scanner, Tokens, TypesUtils;

var
  ConstantExpression: Boolean;

function ParseConstantExpression(var Range: TRangeInfo): PType;

function ParseFunctionCall(var Range: TRangeInfo; Func: PFunction): PType;
//procedure ParseConstantFunctionCall(Func: PFunction);

function ParseVariable(var Range: TRangeInfo; Variable: PVariable): PType;
//procedure ParseVariable(Func: PFunction);

procedure ParseRootExpression(ExpectedType: PType); inline;
function ParseExpression(var Range: TRangeInfo): PType;

implementation

function ParseVariable(var Range: TRangeInfo; Variable: PVariable): PType;
var
  VarToken: TTokenInfo;
  RangeInfo: TRangeInfo;
begin
  VarToken := Token;

  Next(Range);

  if Variable <> nil then
    Result := Variable.VariableType
  else
    Result := nil;

  if Matches(ttSquareOpen, Range) then
    begin
      RangeInfo.Create;
      ParseExpression(RangeInfo);
      Range.Expand(RangeInfo);

      Match(ttSquareClose, Range);
    end;
end;

function FindParamType(Func: PFunction; ParamCount: Integer): PType; inline;
begin
  Result := nil;

  if Func = nil then
    Exit;

  if High(Func.Header.Parameters) < ParamCount then
    Exit;

  Result := Func.Header.Parameters[ParamCount].VariableType;
end;

function ParseFunctionCall(var Range: TRangeInfo; Func: PFunction): PType;
var ParamCount: Integer;
  FuncToken: TTokenInfo;
  RangeInfo: TRangeInfo;
begin
  FuncToken := Token;

  Next(Range);

  if Func <> nil then
    Result := Func.Header.Returns
  else
    Result := nil;

  ParamCount := 0;

  if Match(ttParentOpen, Range) then
    begin

      if Token.Token <> ttParentClose then
        begin
          RangeInfo.Create;
          Compitable(ParseExpression(RangeInfo), FindParamType(Func, ParamCount), RangeInfo);
          Range.Expand(RangeInfo);
          Inc(ParamCount);

          while Token.Token = ttComma do
            begin
              Next(Range);

              RangeInfo.Create;
              Compitable(ParseExpression(RangeInfo), FindParamType(Func, ParamCount), RangeInfo);
              Range.Expand(RangeInfo);
              Inc(ParamCount);
            end;

        end;
        
      Match(ttParentClose, Range);

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
function ParseFactor(var Range: TRangeInfo): PType;
var Identifier: PIdentifier;
  RangeInfo: TRangeInfo;
begin
  Result := nil;
  
  case Token.Token of
    ttNot:
      begin
        RangeInfo.Create;
        Next(RangeInfo);

        Result := ParseFactor(RangeInfo);
        Result := CompitableBoolean(Result, RangeInfo);

        Range.Expand(RangeInfo);
      end;
      
    ttAdd, ttSub:
      begin
        RangeInfo.Create;
        Next(RangeInfo);

        Result := ParseFactor(RangeInfo);
        Result := CompitableArithmetic(Result, RangeInfo);

        Range.Expand(RangeInfo);
      end;

    ttFunction:
      begin
        Next(Range);

        if Token.Token = ttIdentifier then
          begin
            Range.Expand;
            
            CurrentScope.FindFunction;
          end
        else
          Match(ttIdentifier);

        Result := CodeType;
      end;
    
    ttNull:
      begin
        Next(Range);

        Result := NullType;
      end;

    ttIdentifier:
      begin
        Range.Expand;
        
        Identifier := CurrentScope^.Find(True);
        
        if Identifier = nil then
          Unexpected
        else
          case Identifier.IdentifierType of
            //itType: ParseLocal(PType(Identifier));
            itVariable: Result := ParseVariable(Range, PVariable(Identifier));
            itFunction: Result := ParseFunctionCall(Range, PFunction(Identifier));
            else UnexpectedIdentifier(Identifier);
          end;
      end;

    ttTrue, ttFalse:
      begin
        Next(Range);

        Result := BooleanType;
      end;
      
    ttNumber, ttOctal, ttHex, ttRawId:
      begin
        Next(Range);

        Result := IntegerType;
      end;

    ttString:
      begin
        Next(Range);

        Result := StringType;
      end;

    ttReal:
      begin
        Next(Range);

        Result := RealType;
      end;

    ttParentOpen:
      begin
        Next(Range);

        Result := ParseExpression(Range);

        Match(ttParentClose, Range);
      end;

    else Expected(ttExpression);
  end;
end;

function ParseArithmetic(var Range: TRangeInfo): PType;
var
  AddOp: Boolean;
  RangeInfo: TRangeInfo;

  procedure ValidateResult(NewType: PType);
  var
    Base: PType;
    ResultBase: PType;
  begin
    if NewType = nil then
      Exit;

    if Result = nil then
      begin
        Result := NewType;
        Exit;
      end;

    Base := NewType.BaseType;

    if not ((Base = RealType) or (Base = IntegerType) or (AddOp and (Base = StringType))) then
      with TErrorInfo.Create(eiArithmetic, RangeInfo)^ do
        begin
          Identifier := NewType;

          Result := nil;

          Report;

          Exit;
        end;

    ResultBase := Result.BaseType;

    if ((Base = IntegerType) and (ResultBase = RealType)) or
      ((Base = RealType) and (ResultBase = IntegerType)) then
      Exit;

    if Base <> ResultBase then
      with TErrorInfo.Create(eiConvertType, RangeInfo)^ do
        begin
          FromType := NewType;
          ToType := Result;
          
          Report;

          Exit;
        end;

    if Base = RealType then
      Result := NewType;
  end;

begin
  RangeInfo.Create;
  
  Result := ParseFactor(RangeInfo);

  if Token.Token in [ttAdd, ttSub, ttMul, ttDiv] then
    begin
      AddOp := Token.Token = ttAdd;
      
      ValidateResult(Result);

      repeat
          if (not AddOp) and (Result.BaseType = StringType) then
            Result := nil;
             
          Next(RangeInfo);

          RangeInfo.Create;

          ValidateResult(ParseFactor(RangeInfo));

          AddOp := Token.Token = ttAdd;

      until not (Token.Token in [ttAdd, ttSub, ttMul, ttDiv]);
    end;
    
  Range.Expand(RangeInfo);
end;

function ParseComparison(var Range: TRangeInfo): PType;
var
  RangeInfo: TRangeInfo;
  CompareType: PType;
  Arithmetic: Boolean;

  procedure ValidateResult(NewType: PType);
  var
    Base, CompareBase: PType;
  begin
    if NewType = nil then
      Exit;

    if CompareType = nil then
      begin
        CompareType := NewType;
        Exit;
      end;

    Base := NewType.BaseType;

    if Arithmetic then
      CompitableArithmetic(NewType, RangeInfo);

    CompareBase := CompareType.BaseType;

    if ((Base = NullType) and (CompareBase = HandleType)) or
      ((Base = NullType) and (CompareBase = StringType)) or
      ((Base = NullType) and (CompareBase = CodeType)) or
      ((Base = IntegerType) and (CompareBase = RealType)) or
      ((Base = RealType) and (CompareBase = IntegerType)) then
      Exit;

    if Base <> CompareBase then
      with TErrorInfo.Create(eiConvertType, RangeInfo)^ do
        begin
          FromType := NewType;
          ToType := CompareType;
          
          Report;

          Exit;
        end;
  end;

begin
  RangeInfo.Create;

  Result := ParseArithmetic(RangeInfo);

  if Token.Token in [ttEqual, ttAssign, ttGreaterOrEqual, ttGreater, ttLess, ttLessOrEqual, ttNotEqual] then
    begin
      Arithmetic := Token.Token in [ttGreaterOrEqual, ttGreater, ttLess, ttLessOrEqual];
      
      CompareType := Result;
      Result := BooleanType;

      ValidateResult(CompareType);
      
      repeat
        if Token.Token = ttAssign then
          TErrorInfo.Create(eiDoubleEquals).Report;

        Next(RangeInfo);

        RangeInfo.Create;

        ValidateResult(ParseArithmetic(RangeInfo));

        Arithmetic := Token.Token in [ttGreaterOrEqual, ttGreater, ttLess, ttLessOrEqual];
      until not (Token.Token in [ttEqual, ttAssign, ttGreaterOrEqual, ttGreater, ttLess, ttLessOrEqual, ttNotEqual]);
    end;

  Range.Expand(RangeInfo);
end;

function ParseConstantExpression(var Range: TRangeInfo): PType;
var Old: Boolean;
begin
  Old := ConstantExpression;
  ConstantExpression := True;

  Result := ParseExpression(Range);

  ConstantExpression := Old;
end;

function ParseExpression(var Range: TRangeInfo): PType;
var RangeInfo: TRangeInfo;
begin
  RangeInfo.Create; 
  Result := ParseComparison(RangeInfo);

  if Token.Token in [ttAnd, ttOr] then
    begin
      CompitableBoolean(Result, RangeInfo);

      repeat
        Next(RangeInfo);

        Result := CompitableBoolean(ParseComparison(RangeInfo), RangeInfo);
      until not (Token.Token in [ttAnd, ttOr]);
    end;

  Range.Expand(RangeInfo);
end;

procedure ParseRootExpression(ExpectedType: PType); inline;
var Range: TRangeInfo;
begin
  Range.Create;
  Compitable(ParseExpression(Range), ExpectedType, Range);
end;

end.
