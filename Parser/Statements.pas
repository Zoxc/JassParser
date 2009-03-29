unit Statements;

interface

uses SysUtils;

procedure ParseStatement;

var
  CurrentLoop: Integer;

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
    LocalType := CurrentScope.FindType;

  IsArray := Matches(ttArray);

  Local := CurrentScope.DeclareVariable;
  Local.VariableType := LocalType;
  Local.Flags := [];

  if IsArray then
    Include(Local.Flags, vfArray);

  if Matches(ttAssign) then
      ParseExpression;

  EndOfLine;
end;

procedure ParseSet(Identifier: PVariable);
var
  Variable: PVariable;
begin
  Matches(ttDebug); Match(ttSet);

  if Identifier <> nil then
    begin
      Variable := Identifier;
      Next;
    end
  else
    Variable := CurrentScope.FindVariable;

  if Matches(ttSquareOpen) then
    begin
      ParseExpression;
      
      Match(ttSquareClose);
    end;

  Match(ttAssign);

  ParseExpression;

  EndOfLine;
end;

procedure ParseCall(Identifier: PFunction);
var
  Func: PFunction;
begin
  Matches(ttDebug); Match(ttCall);

  if Identifier <> nil then
    Func := Identifier
  else
    Func := CurrentScope.FindFunction(False);

  ParseFunctionCall(Func);

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
begin
  ReturnToken := Token;
      
  Match(ttReturn);

  if Token.Token = ttLine then
    begin
      if CurrentFunc.Header.Returns <> nil then
        with TErrorInfo.Create(eiWrongReturn, ReturnToken)^ do
          begin
            Identifier := CurrentFunc;
            Report;
          end;
    end
  else
    begin
      if CurrentFunc.Header.Returns = nil then
        with TErrorInfo.Create(eiWrongReturn, ReturnToken)^ do
          begin
            Identifier := CurrentFunc;
            Report;
          end;

      ParseExpression;
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

  ParseExpression;

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
          
          ParseExpression;

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

  ParseExpression;

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
    ttLocal: ParseLocal(nil);
    ttSet: ParseSet(nil);
    ttCall: ParseCall(nil);
    ttIdentifier: ParseIdentifier;
    ttReturn: ParseReturn;
    ttIf: ParseIf;
    ttLoop: ParseLoop;
    ttExitwhen: ParseExitWhen;
    ttLine: Next;
    else Unexpected;
  end;
end;

end.
