unit Expressions;

interface

uses Scopes, SysUtils, Blocks, Scanner, Tokens, TypesUtils;

var
  CurrentConstant: Boolean = False;
  CurrentGlobal: Boolean = False;
  CurrentLocal: Boolean = False;
  CurrentDeclaration: PIdentifier = nil;

function ParseFunctionCall(var Range: TRangeInfo; Func: PFunction): PType;

function ParseVariable(var Range: TRangeInfo; Variable: PVariable): PType;

procedure ParseRootExpression(ExpectedType: PType); inline;
function ParseExpression(var Range: TRangeInfo): PType;

implementation

procedure ParseArrayIndex(var Range: TRangeInfo);
begin
  Match(ttSquareOpen, Range);
  ParseExpression(Range);
  Match(ttSquareClose, Range);
end;

function ParseVariable(var Range: TRangeInfo; Variable: PVariable): PType;
var
  VarToken: TTokenInfo;
begin
  VarToken := Token;

  if Variable <> nil then
    begin
      if CurrentDeclaration = Variable then
        with TErrorInfo.Create(eiUsedInDeclaration)^ do
          begin
            Identifier := Variable;

            Report;
          end
      else if (not Variable.Initialized) and (vfLocal in Variable.Flags) then
        with TErrorInfo.Create(eiUninitializedVariable, ecWarning)^ do
          begin
            Identifier := Variable;

            Report;
          end
      {else if CurrentConstant and (not (vfConstant in Variable.Flags)) and (not (vfLocal in Variable.Flags)) and (not (vfParameter in Variable.Flags)) then
        with TErrorInfo.Create(eiVariableInConstant)^ do
          begin
            Identifier := Variable;

            Report;
          end}
    end;

  Next(Range);

  if Variable <> nil then
    Result := Variable.VariableType
  else
    Result := nil;

  if Token.Token = ttSquareOpen then
    begin
      if (Variable <> nil) and (not (vfArray in Variable.Flags)) then
        with TErrorInfo.Create(eiVariableNotArray, VarToken)^ do
          begin
            Identifier := Variable;

            Report;
          end;

        ParseArrayIndex(Range);
    end
  else if (Variable <> nil) and (vfArray in Variable.Flags) then
    with TErrorInfo.Create(eiVariableArray, VarToken)^ do
      begin
        Identifier := Variable;

        Report;
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

function ParseFunctionParameters(var Range: TRangeInfo; Func: PFunction): Integer;
var
  RangeInfo: TRangeInfo;
begin
  if Matches(ttParentOpen, Range) then
    begin
      Result := 0;

      if Token.Token <> ttParentClose then
        begin
          RangeInfo.Create;
          Compitable(ParseExpression(RangeInfo), FindParamType(Func, Result), RangeInfo);

          Inc(Result);

          while Token.Token = ttComma do
            begin
              Next;

              RangeInfo.Create;
              Compitable(ParseExpression(RangeInfo), FindParamType(Func, Result), RangeInfo);
              Inc(Result);
            end;
        end;

      Range.Expand(RangeInfo);

      Match(ttParentClose, Range);
    end
  else
    Result := -1;
end;

function ParseFunctionCall(var Range: TRangeInfo; Func: PFunction): PType;
var ParamCount: Integer;
  FuncToken: TTokenInfo;
begin
  FuncToken := Token;

  if Func <> nil then
    begin
      if CurrentGlobal and (not Func.Native) then
        with TErrorInfo.Create(eiFunctionInGlobal)^ do
          begin
            Identifier := Func;

            Report;
          end
      {else if CurrentConstant and (not Func.Constant) then
        with TErrorInfo.Create(eiFunctionInConstant)^ do
          begin
            Identifier := Func;

            Report;
          end}
      else if CurrentLocal and (Func = CurrentFunc) then
        TErrorInfo.Create(eiRecursiveLocals)^.Report;
    end;

  Next(Range);

  if Func <> nil then
    Result := Func.Header.Returns
  else
    Result := nil;

  ParamCount := ParseFunctionParameters(Range, Func);

  if ParamCount = -1 then
    TErrorInfo.Create(eiNoFunctionParams, FuncToken)^.Report
  else
    if (Func <> nil) and (Length(Func.Header.Parameters) <> ParamCount) then
      with TErrorInfo.Create(eiParameterCount, FuncToken)^ do
        begin
          CalledFunction := Func;
          ParameterCount := ParamCount;
          Report;
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
  ErrorInfo: PErrorInfo;
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
        RangeInfo.Create;
        Next(RangeInfo);

        if Token.Token = ttIdentifier then
          begin
            RangeInfo.Expand;

            Identifier := CurrentScope.FindFunction(False);

            if Identifier <> nil then
              begin
                with PFunction(Identifier)^ do
                  if Length(Header.Parameters) <> 0 then
                    begin
                      ErrorInfo := TErrorInfo.Create(eiCodeParams, RangeInfo);
                      ErrorInfo.Identifier := Identifier;
                      ErrorInfo.Report;
                    end;
              end;
              
            Next(RangeInfo);
          end
        else
          Match(ttIdentifier);

        Range.Expand(RangeInfo);
        Result := CodeConstant;
      end;
    
    ttNull:
      begin
        Next(Range);

        Result := HandleConstant;
      end;

    ttIdentifier:
      begin
        Range.Expand;
        
        Identifier := CurrentScope^.Find(True);
        
        if Identifier = nil then
          with TErrorInfo.Create(eiUndeclaredIdentifier)^ do
            begin
              Info := Token.StrNew;
              
              Report;

              Scanner.Next(Range);

              case Token.Token of
                ttParentOpen: ParseFunctionParameters(Range, nil);
                ttSquareOpen: ParseArrayIndex(Range);
              end;
            end
        else
          case Identifier.IdentifierType of
            //itType: ParseLocal(PType(Identifier));
            itVariable: Result := ParseVariable(Range, PVariable(Identifier));
            itFunction: Result := ParseFunctionCall(Range, PFunction(Identifier));
            else
              begin
                UnexpectedIdentifier(Identifier);
                Range.Expand;
                
                case Token.Token of
                  ttParentOpen: ParseFunctionParameters(Range, nil);
                  ttSquareOpen: ParseArrayIndex(Range);
                end;
              end;
          end;
      end;

    ttTrue, ttFalse:
      begin
        Next(Range);

        Result := BooleanConstant;
      end;
      
    ttNumber, ttOctal, ttHex, ttRawId:
      begin
        Next(Range);

        Result := IntegerConstant;
      end;

    ttString:
      begin
        Next(Range);

        Result := StringConstant;
      end;

    ttReal:
      begin
        Next(Range);

        Result := RealConstant;
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
    ResultBase, ResultOld: PType;
  begin
    if NewType = nil then
      Exit;

    if Result = nil then
      begin
        Result := NewType;
        Exit;
      end;

    Base := NewType.BaseType;

    if not ((Base = IntegerConstant) or (Base = IntegerType) or (Base = RealConstant) or (Base = RealType) or (AddOp and ((Base = StringConstant) or (Base = StringType)))) then
      with TErrorInfo.Create(eiArithmetic, RangeInfo)^ do
        begin
          Identifier := NewType;

          Result := nil;

          Report;

          Exit;
        end;

    ResultBase := Result.BaseType;


    if IntConstToRealOperators(Base, ResultBase) then
      TErrorInfo.Create(eiImplicitIntegerConstToReal, RangeInfo, ecHint).Report;

    ResultOld := Result;

    if (Base = RealType) or (Base = RealConstant) then
      Result := NewType;

    if CompitableOperators(Base, ResultBase) then
      Exit;

    if Base <> ResultBase then
      with TErrorInfo.Create(eiConvertType, RangeInfo)^ do
        begin
          FromType := NewType;
          ToType := ResultOld;

          Report;

          Exit;
        end;
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

    if IntConstToRealOperators(Base, CompareBase) then
      TErrorInfo.Create(eiImplicitIntegerConstToReal, RangeInfo, ecHint).Report;

    if CompitableOperators(Base, CompareBase) then
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
