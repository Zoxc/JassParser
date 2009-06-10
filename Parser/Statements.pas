unit Statements;

interface

uses SysUtils, Scanner;

procedure ParseStatement;

var
  DoReturnBug: Boolean;
  CurrentLoop: Integer;
  CurrentReturnError: PErrorInfo;
  NoLocals: Boolean;
  NoReturn: Boolean;

implementation

uses Blocks, Scopes, Tokens, Expressions, TypesUtils;

procedure ParseLocal(Identifier: PType);
var LocalType: PType;
  Local: PVariable;
  LocalInfo: TTokenInfo;
  IsArray: Boolean;
begin
  if Token.Token = ttConstant then
    begin
      TErrorInfo.Create(eiConstantLocal).Report;
      Next;
    end;

  if NoLocals then
    TErrorInfo.Create(eiLostLocal).Report;

  Match(ttLocal);

  if Identifier <> nil then
    begin
      LocalType := Identifier;
      Next;
    end
  else
    LocalType := CurrentScope.FindType;

  IsArray := Matches(ttArray);

  if IsArray then
    LocalInfo := Token;

  if IsArray and (LocalType.BaseType = CodeType) then
    TErrorInfo.Create(eiCodeArray, LocalInfo).Report;

  Local := CurrentScope.DeclareVariable;
  Local.VariableType := LocalType;
  Local.Flags := [vfLocal];

  if IsArray then
    begin
      Include(Local.Flags, vfArray);
      Local.Initialized := True;
    end;

  if Matches(ttAssign) then
    begin
       if IsArray then
        with TErrorInfo.Create(eiArrayInitiation, LocalInfo)^ do
          begin
            Identifier := Local;

            Report;
          end;
          
      Local.Initialized := True;

      CurrentLocal := True;
      CurrentDeclaration := Local;
      ParseRootExpression(LocalType);
      CurrentDeclaration := nil;
      CurrentLocal := False;
    end;

  EndOfLine;
end;

procedure ParseSet(Identifier: PVariable);
var
  Variable: PVariable;
  VarToken: TTokenInfo;
begin
  Matches(ttDebug); Match(ttSet);

  VarToken := Token;

  if Identifier <> nil then
    begin
      Variable := Identifier;
      Next;
    end
  else
    Variable := CurrentScope.FindVariable;

  if (Variable <> nil) and CurrentConstant and (not (vfLocal in Variable.Flags)) and (not (vfParameter in Variable.Flags)) then
    with TErrorInfo.Create(eiVariableAssignmentInConstant, VarToken)^ do
      begin
        Identifier := Variable;

        Report;
      end;
      
  if Matches(ttSquareOpen) then
    begin
      if (Variable <> nil) and (not (vfArray in Variable.Flags)) then
        with TErrorInfo.Create(eiVariableNotArray, VarToken)^ do
          begin
            Identifier := Variable;

            Report;
          end;
          
      ParseRootExpression(IntegerType);
        
      Match(ttSquareClose);
    end
  else if (Variable <> nil) and (vfArray in Variable.Flags) then
    with TErrorInfo.Create(eiVariableArray, VarToken)^ do
      begin
        Identifier := Variable;

        Report;
      end;

  Match(ttAssign);

  if Variable <> nil then
    begin
      ParseRootExpression(Variable.VariableType);
      Variable.Initialized := True;
    end
  else
    ParseRootExpression(nil);

  EndOfLine;
end;

procedure ParseCall(Identifier: PFunction);
var
  Func: PFunction;
  Range: TRangeInfo;
begin
  Matches(ttDebug); Match(ttCall);

  if Identifier <> nil then
    Func := Identifier
  else
    Func := CurrentScope.FindFunction(False);

  ParseFunctionCall(Range, Func);

  EndOfLine;
end;

procedure ParseIdentifier;
var Identifier: PIdentifier;
begin
  Identifier := CurrentScope^.Find(True);

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

procedure ParseReturn;
var
  ReturnToken: TTokenInfo;
  Range: TRangeInfo;
begin
  ReturnToken := Token;

  if DoReturnBug and (CurrentReturnError <> nil) then
    CurrentReturnError.Pull;

  NoReturn := False;
      
  Match(ttReturn, True, True);

  if Token.Token = ttLine then
    begin
      if CurrentFunc.Header.Returns <> NothingType then
        with TErrorInfo.Create(eiWrongReturn, ReturnToken)^ do
          begin
            Identifier := CurrentFunc;
            Report;
          end;
    end
  else
    begin
      if CurrentFunc.Header.Returns = NothingType then
        with TErrorInfo.Create(eiWrongReturn, ReturnToken)^ do
          begin
            Identifier := CurrentFunc;
            Report;
          end;

      Range.Create;

      if CurrentFunc.Header.Returns = NothingType then
        CurrentReturnError := Compitable(ParseExpression(Range), nil, Range, DoReturnBug)
      else
        CurrentReturnError := Compitable(ParseExpression(Range), CurrentFunc.Header.Returns, Range, DoReturnBug);
    end;

  EndOfLine;
end;

procedure ParseIf;
const 
  IfEnders = BlockEnders + [ttEndIf, ttElse, ttElseIf];
var
  FoundElse: Boolean;
begin
  Matches(ttDebug); Match(ttIf);

  ParseRootExpression(BooleanType);

  Match(ttThen);

  EndOfLine;

  while not (Token.Token in IfEnders) do
    ParseStatement;

  FoundElse := False;

  while Token.Token in [ttElse, ttElseIf] do
    begin
      if Token.Token = ttElseIf then
        begin
          if FoundElse then
            Unexpected(False);
            
          Next;
          
          ParseRootExpression(BooleanType);

          Match(ttThen)
        end
      else
        begin
          if FoundElse then
            Unexpected(False);

          FoundElse := True;
          Next;
        end;

      EndOfLine;

      while not (Token.Token in IfEnders) do
        ParseStatement;
    end;

  Match(ttEndIf);
  
  EndOfLine;
end;

procedure ParseExitWhen;
begin
  if CurrentLoop <= 0 then
    TErrorInfo.Create(eiExitWhen).Report;

  Match(ttExitwhen);

  ParseRootExpression(BooleanType);

  EndOfLine;
end;

procedure ParseLoop;
const 
  LoopEnders = BlockEnders + [ttEndLoop];
begin
  Match(ttLoop);
  EndOfLine;

  Inc(CurrentLoop);

  while not (Token.Token in LoopEnders) do
    ParseStatement;

  Dec(CurrentLoop);

  Match(ttEndLoop);
  EndOfLine;
end;

procedure ParseStatement;
var DebugToken: TTokenInfo;
begin
  if (Token.Token <> ttLocal) and (Token.Token in [ttDebug, ttSet, ttCall, ttIdentifier, ttReturn, ttReturns, ttIf, ttLoop, ttExitwhen]) then
    NoLocals := True;
    
  case Token.Token of
    ttDebug:
      begin
        DebugToken := Token;
        Next;

        case Token.Token of
          ttSet: ParseSet(nil);
          ttCall: ParseCall(nil);
          ttIf: ParseIf;
          ttLoop: ParseLoop;
          else
            with TErrorInfo.Create(eiUnexpectedToken, DebugToken)^ do
              begin
                UnexpectedToken := ttDebug;

                Report;
              end;
        end;
      end;
    ttLocal, ttConstant: ParseLocal(nil);
    ttSet: ParseSet(nil);
    ttCall: ParseCall(nil);
    ttIdentifier: ParseIdentifier;
    ttReturn, ttReturns: ParseReturn;
    ttIf: ParseIf;
    ttLoop: ParseLoop;
    ttExitwhen: ParseExitWhen;
    ttLine: Next;
    else Unexpected;
  end;
end;

end.
