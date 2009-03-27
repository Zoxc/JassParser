unit Scopes;

interface

uses Tokens;

type
  TParserHash = Byte;
  
  TIdentifierType = (itUnknown, itUndeclared, itType, itVariable, itFunction);

  PIdentifier = ^TIdentifier;
  PScope = ^TScope;
  PType = ^TType;
  PVariable = ^TVariable;
  PFunctionHeader = ^TFunctionHeader;
  PFunction = ^TFunction;
  
  TIdentifier = object
    Name: PAnsiChar;
    Next: PIdentifier;
    IdentifierType: TIdentifierType;
    procedure Free;
  end;

  TType = object(TIdentifier)
    Extends: PIdentifier;
  end;

  TVariableFlag = (vfArray, vfParameter, vfConstant);
  TVariableFlags = set of TVariableFlag;


  TVariable = object(TIdentifier)
    Flags: TVariableFlags;
    VariableType: PType;
  end;

  TFunctionHeader = record
    Parameters: array of PVariable;
    Returns: PType;
  end;

  TFunction = object(TIdentifier)
    Header: TFunctionHeader;
    Native: Boolean;
    Constant: Boolean;
    Scope: PScope;
  end;

  TScope = object
    private
      FBuckets: array [TParserHash] of PIdentifier;
      FIncomplete: PIdentifier;
    public
      Parent: PScope;
      procedure Init;
      procedure Add(Identifier: PIdentifier);
      procedure Declare(Identifier: PIdentifier);
      function DeclareType: PType;
      function DeclareVariable: PVariable;
      function DeclareFunction: PFunction;
      function Find(Recursive: Boolean = True): PIdentifier; overload;
      function Find(IdentifierType: TIdentifierType): PIdentifier; overload;
      function FindType(DoSkip: Boolean = True): PType;
      function FindVariable(DoSkip: Boolean = True): PVariable;
      function FindFunction(DoSkip: Boolean = True): PFunction;
      procedure Free;
  end;

const
  IdentifierName: array [TIdentifierType] of PAnsiChar = (
    'unknown', 'undeclared', 'type', 'variable', 'function'
  );

implementation

uses Windows, SysUtils, Dialogs, Scanner, Documents, Blocks;

procedure TIdentifier.Free;
begin
  case IdentifierType of
    itFunction:
      begin
        with PFunction(@Self)^ do
          begin
            SetLength(Header.Parameters, 0);
            Scope.Free;
            Dispose(Scope);
          end;
      end;
  end;

  Dispose(Name);
  Dispose(@Self);
end;

procedure TScope.Init;
begin
  FillChar(FBuckets[0], SizeOf(PIdentifier) * Length(FBuckets), 0);
  FIncomplete := nil;
end;

procedure TScope.Add(Identifier: PIdentifier);
var
  Current, Dummy: PIdentifier;
  Length: Cardinal;
  Start: PAnsiChar;
  Hash: TParserHash;
begin
  Hash := HashString(Identifier.Name);

  Current := FBuckets[Hash];

  if Current <> nil then
    begin
      Length := StrLen(Identifier.Name);
      Start := Identifier.Name;

      repeat
        if StrLComp(Start, Current.Name, Length) = 0 then
          begin
            Identifier.Free;
            raise Exception.Create(Start + ' is already declared');
          end;

        Dummy := Current.Next;

        if Dummy = nil then
          begin
            Current.Next := Identifier;
            Identifier.Next := nil;
            Exit;
          end;

        Current := Dummy;
      until False;

    end
  else
    begin
      FBuckets[Hash] := Identifier;
      Identifier.Next := nil;
    end;
end;

procedure TScope.Declare(Identifier: PIdentifier);
var
  Current, Dummy: PIdentifier;
  Length: Cardinal;
  Start: PAnsiChar;
  ErrorInfo: PErrorInfo;

begin
  if not Match(ttIdentifier, False) then
    begin
      Identifier.Name := nil;
      Identifier.Next := FIncomplete;
      FIncomplete := Identifier;
      
      Exit;
    end;
    
  Current := FBuckets[Token.Hash];

  if Current <> nil then
    begin
      Length := Token.Length;
      Start := Token.Start;

      repeat
        if StrLComp(Start, Current.Name, Length) = 0 then
          begin
            ErrorInfo := TErrorInfo.Create(eiRedeclared);
            ErrorInfo.Identifier := Current;
            ErrorInfo.Report;

            Identifier.Name := nil;
            Identifier.Next := FIncomplete;
            FIncomplete := Identifier;

            Next;
            Exit;
          end;

        Dummy := Current.Next;

        if Dummy = nil then
          begin
            Identifier.Name := Token.StrNew;
            Current.Next := Identifier;
            Identifier.Next := nil;

            Next;
            Exit;
          end;

        Current := Dummy;
      until False;
      
    end
  else
    begin
      Identifier.Name := Token.StrNew;
      FBuckets[Token.Hash] := Identifier;
      Identifier.Next := nil;
      
      Next;
    end;
end;

function TScope.DeclareType: PType;
begin
  New(Result);
  Result.IdentifierType := itType;
  Declare(Result);
end;

function TScope.DeclareVariable: PVariable;
begin
  New(Result);
  Result.IdentifierType := itVariable;
  Declare(Result);
end;

function TScope.DeclareFunction: PFunction;
begin
  New(Result);

  New(Result.Scope);
  Result.Scope.Init;
  Result.Scope.Parent := Blocks.Scope;

  Result.Header.Returns := nil;
  Result.IdentifierType := itFunction;
  Declare(Result);
end;

function TScope.Find(Recursive: Boolean): PIdentifier;
var
  i: Integer;
  Current: PIdentifier;
  Length: Cardinal;
  Start: PAnsiChar;
begin
  Current := FBuckets[Token.Hash];

  if Current <> nil then
    begin
      Length := Token.Length;
      Start := Token.Start;

      repeat
        if StrLComp(Start, Current.Name, Length) = 0 then
          begin
            Result := Current;
            Exit;
          end;

        Current := Current.Next;
      until Current = nil;
    end;

  Result := nil;

  if (Result = nil) and Recursive then
    begin
      if Parent <> nil then
        Result := Parent.Find(True)
      else
        begin
          for i := 0 to DocumentList.Count - 1 do
            begin
              Result := PScope(DocumentList[i]).Find(False);
              if Result <> nil then
                Exit;
            end;  
        end;
    end;
end;

function TScope.Find(IdentifierType: TIdentifierType): PIdentifier;
var ErrorInfo: PErrorInfo;
begin
  Result := Find;

  if Result = nil then
    begin
        ErrorInfo := TErrorInfo.Create(eiUndeclaredIdentifier);
        ErrorInfo.Info := Token.StrNew;
        ErrorInfo.Report;
    end
  else
    if Result.IdentifierType <> IdentifierType then
      begin
        ErrorInfo := TErrorInfo.Create(eiExpectedIdentifier);
        
        ErrorInfo.ExpectedIdentifier := IdentifierType;
        ErrorInfo.FoundIdentifier := Result.IdentifierType;
        ErrorInfo.InfoPointer := Result.Name;

        ErrorInfo.Report;
      end;
end;

function TScope.FindType(DoSkip: Boolean = True): PType;
begin
  if not Match(ttIdentifier, False) then
    begin
      Result := nil;
      Exit;
    end;
    
  Result := PType(Find(itType));
  
   if DoSkip then
    Next;
end;

function TScope.FindVariable(DoSkip: Boolean = True): PVariable;
begin
  if not Match(ttIdentifier, False) then
    begin
      Result := nil;
      Exit;
    end;
    
  Result := PVariable(Find(itVariable));
  
  if DoSkip then
    Next;
end;

function TScope.FindFunction(DoSkip: Boolean = True): PFunction;
begin
  if not Match(ttIdentifier, False) then
    begin
      Result := nil;
      Exit;
    end;
    
  Result := PFunction(Find(itFunction));

  if DoSkip then
    Next;
end;

procedure FreeIdentifierList(const Identifier: PIdentifier);
var
  Current, Dummy: PIdentifier;
begin
  Current := Identifier;

  while Current <> nil do
    begin
      Dummy := Current;

      Current := Current.Next;

      Dummy.Free;
    end;
end;

procedure TScope.Free;
var
  Hash: TParserHash;
begin
  FreeIdentifierList(FIncomplete);

  for Hash := Low(Hash) to High(Hash) do
    FreeIdentifierList(FBuckets[Hash]);
end;

end.
