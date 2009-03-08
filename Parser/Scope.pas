unit Scope;

interface

uses Tokens;

type
  TParserHash = Byte;
  
  TIdentifierType = (itUnknown, itUndeclared, itType);

  PIdentifier = ^TIdentifier;
  TIdentifier = object
    Name: PAnsiChar;
    Next: PIdentifier;
    IdentifierType: TIdentifierType;
    procedure Free;
  end;

  PType = ^TType;
  TType = object(TIdentifier)
    Extends: PIdentifier;
  end;

  PScope = ^TScope;
  TScope = object
    private
      FBuckets: array [TParserHash] of PIdentifier;
    public
      Parent: PScope;
      procedure Init;
      procedure Add(Identifier: PIdentifier);
      function Declare(IdentifierType: TIdentifierType; Size: Cardinal): PIdentifier;
      function DeclareType: PType;
      function Find(Recursive: Boolean): PIdentifier; overload;
      function Find(IdentifierType: TIdentifierType): PIdentifier; overload;
      function FindType: PType;
      procedure Free;
  end;

const
  IdentifierName: array [TIdentifierType] of PAnsiChar = (
    'unknown', 'undeclared', 'type'
  );

implementation

uses Windows, SysUtils, Dialogs, Scanner, Errors, Documents, Blocks;

procedure TIdentifier.Free;
begin
  Dispose(Name);
  Dispose(@Self);
end;

procedure TScope.Init;
begin
  FillChar(FBuckets[0], SizeOf(PIdentifier) * Length(FBuckets), 0);
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

function TScope.Declare(IdentifierType: TIdentifierType; Size: Cardinal): PIdentifier;
var
  Current, Dummy: PIdentifier;
  Length: Cardinal;
  Start: PAnsiChar;
  ErrorInfo: PErrorInfo;
begin
  Current := FBuckets[Token.Hash];

  if Current <> nil then
    begin
      Length := Token.Length;
      Start := Token.Start;

      repeat
        if StrLComp(Start, Current.Name, Length) = 0 then
          begin
            ErrorInfo := NewError(eiRedeclared);
            ErrorInfo.Identifier := Current;
            Error(ErrorInfo);
            Result := nil;
            Exit;
          end;

        Dummy := Current.Next;

        if Dummy = nil then
          begin
            GetMem(Result, Size);
            Result.IdentifierType := IdentifierType;
            Result.Name := Token.StrNew;
            Current.Next := Result;
            Result.Next := nil;
            Exit;
          end;

        Current := Dummy;
      until False;
      
    end
  else
    begin
      GetMem(Result, Size);
      Result.IdentifierType := IdentifierType;
      Result.Name := Token.StrNew;
      FBuckets[Token.Hash] := Result;
      Result.Next := nil;
    end;
end;

function TScope.DeclareType: PType;
begin
  if not Match(ttIdentifier, False) then
    begin
      Next;
      Result := nil;
      Exit;
    end;
    
  Result := PType(Declare(itType, SizeOf(TType)));
  
  Next;
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

      if StrLComp(Start, Current.Name, Length) = 0 then
        begin
          Result := Current;
          Exit;
        end;
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
  Result := Find(True);

  if Result = nil then
    begin
        ErrorInfo := NewError(eiUndeclaredIdentifier);
        ErrorInfo.IdentifierString := Token.StrNew;
        Error(ErrorInfo);
    end
  else
    if Result.IdentifierType <> IdentifierType then
      begin
        ErrorInfo := NewError(eiExpectedIdentifier);
        
        ErrorInfo.ExpectedIdentifier := IdentifierType;
        ErrorInfo.FoundIdentifier := Result.IdentifierType;
        ErrorInfo.FoundIdentifierString := Result.Name;

        Error(ErrorInfo);
      end;
end;

function TScope.FindType: PType;
begin
  if not Match(ttIdentifier, False) then
    begin
      Next;
      Result := nil;
      Exit;
    end;
    
  Result := PType(Find(itType));
  
  Next;
end;

procedure TScope.Free;
var Hash: TParserHash;
  Identifier, Dummy: PIdentifier;
begin
  for Hash := Low(Hash) to High(Hash) do
    begin
      Identifier := FBuckets[Hash];
      while Identifier <> nil do
        begin
          Dummy := Identifier;

          Identifier := Identifier.Next;

          Dummy.Free;
        end;
    end;
end;

end.
