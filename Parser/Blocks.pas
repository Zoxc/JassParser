unit Blocks;

interface

uses SysUtils, Scope, Classes;

type
  PDocument = ^TDocument;
  TDocument = object(TScope)
  end;

procedure ParseType;
procedure ParseGlobals;
procedure ParseDocument(var ADocument: TDocument);

var
  Document: PDocument;
  Scope: PScope;

implementation

uses Scanner, Tokens, Dialogs, Errors;

procedure ParseGlobals;
begin
  Match(ttGlobals);
  
  NextLine;

  Match(ttEndGlobals, True);
end;

procedure ParseType;
var NewType, Extends: PType;
begin
  Match(ttType);

  NewType := Document.DeclareType;

  Match(ttExtends);

  Extends := Document.FindType;

  if NewType <> nil then
    NewType.Extends := Extends;

  NextLine;
end;

procedure ParseDocument(var ADocument: TDocument);
begin
  Document := @ADocument;
  Document.Parent := nil;
  
  repeat

    case Token.Token of
      ttType: ParseType;
      ttGlobals: ParseGlobals;
      ttLine: Next;
      ttEnd:; // Do nothing
      else Unexpected;
    end;

  until Token.Token = ttEnd;

  Document := nil;
end;

end.
