unit TypesUtils;

interface

uses Scopes, Scanner;

var
  HandleType: PType;
  StringType: PType;
  IntegerType: PType;
  RealType: PType;
  BooleanType: PType;
  CodeType: PType;

  HandleConstant: PType;
  StringConstant: PType;
  IntegerConstant: PType;
  RealConstant: PType;
  BooleanConstant: PType;
  CodeConstant: PType;

  NothingType: PType;

  ImplictRealCatch: Boolean = False;

function CompitableOperators(AFromType, AToType: PType): Boolean; inline;
function CompitableBaseTypes(AFromType, AToType: PType): Boolean; inline;

function Compitable(AFromType, AToType: PType; var Range: TRangeInfo; Weak: Boolean = False): PErrorInfo; inline;
function CompitableBoolean(AType: PType; var Range: TRangeInfo): PType; inline;
function CompitableArithmetic(AType: PType; var Range: TRangeInfo): PType;

function IntConstToRealOperators(AFromType, AToType: PType): Boolean; inline;
function IntConstToReal(AFromType, AToType: PType): Boolean; inline;

implementation

function IntConstToRealOperators(AFromType, AToType: PType): Boolean;
begin
  Result := IntConstToReal(AFromType, AToType) or IntConstToReal(AToType, AFromType);
end;

function IntConstToReal(AFromType, AToType: PType): Boolean;
begin
  Result := ImplictRealCatch and (((AFromType = IntegerConstant) and (AToType = RealConstant)) or
    ((AFromType = IntegerConstant) and (AToType = RealType)));
end;

function CompitableOperators(AFromType, AToType: PType): Boolean;
begin
  Result := CompitableBaseTypes(AFromType, AToType) or CompitableBaseTypes(AToType, AFromType);
end;


function CompitableBaseTypes(AFromType, AToType: PType): Boolean;
begin
  Result := False;
  
  if ((AFromType = HandleConstant) and (AToType = HandleType)) or
    ((AFromType = HandleConstant) and (AToType = StringType)) or
    ((AFromType = HandleConstant) and (AToType = StringConstant)) or
    ((AFromType = HandleConstant) and (AToType = BooleanType)) or
    ((AFromType = HandleConstant) and (AToType = BooleanConstant)) or
    ((AFromType = HandleConstant) and (AToType = IntegerType)) or
    ((AFromType = HandleConstant) and (AToType = IntegerConstant)) or
    ((AFromType = HandleConstant) and (AToType = CodeType)) or
    ((AFromType = CodeConstant) and (AToType = CodeType)) or
    ((AFromType = BooleanConstant) and (AToType = BooleanType)) or
    ((AFromType = StringConstant) and (AToType = StringType)) or
    ((AFromType = IntegerConstant) and (AToType = IntegerType)) or
    ((AFromType = IntegerConstant) and (AToType = RealConstant)) or
    ((AFromType = IntegerConstant) and (AToType = RealType)) or
    ((AFromType = RealConstant) and (AToType = RealType)) or
    ((AFromType = IntegerType) and (AToType = RealConstant)) or
    ((AFromType = IntegerType) and (AToType = RealType)) then
      Result := True;
end;

function CompitableArithmetic(AType: PType; var Range: TRangeInfo): PType;
var Base: PType;
begin
  if AType = nil then
    begin
      Result := nil;
      Exit;
    end;

  Result := AType;
  Base := AType.BaseType;

  if not ((Base = IntegerConstant) or (Base = IntegerType) or (Base = RealConstant) or (Base = RealType)) then
    with TErrorInfo.Create(eiArithmetic, Range)^ do
      begin
        Identifier := AType;
        Report;

        Result := nil;
      end;
end;

function CompitableBoolean(AType: PType; var Range: TRangeInfo): PType;
var Base: PType;
begin

  if AType = nil then
    begin
      Result := nil;
      Exit;
    end;

  Result := AType;
  Base := AType.BaseType;

  if not ((Base = BooleanType) or (Base = BooleanConstant)) then
    with TErrorInfo.Create(eiBoolean, Range)^ do
      begin
        Identifier := AType;
        Report;

        Result := nil;
      end;
end;

function Compitable(AFromType, AToType: PType; var Range: TRangeInfo; Weak: Boolean): PErrorInfo;
var BaseFromType, BaseToType: PType;
begin
  Result := nil;
  
  if (AFromType = nil) or (AToType = nil) or (AFromType = AToType) then
      Exit;
      
  BaseFromType := AFromType;

  while BaseFromType.Extends <> nil do
    begin
      if BaseFromType.Extends = AToType then
        Exit;

      BaseFromType := BaseFromType.Extends;
    end;

  BaseToType := AToType.BaseType;

  if Weak and (BaseFromType = BaseToType) then
      Exit;

  if IntConstToReal(BaseFromType, BaseToType) then
    TErrorInfo.Create(eiImplicitIntegerConstToReal, Range, ecHint).Report;

  if CompitableBaseTypes(BaseFromType, BaseToType) then
      Exit;

  Result := TErrorInfo.Create(eiConvertType, Range);
  Result.FromType := AFromType;
  Result.ToType := AToType;
  Result.Report;
end;

end.
