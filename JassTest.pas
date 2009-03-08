unit JassTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SciScintillaBase, SciScintillaMemo, SciScintilla, Scanner,
  ActnList, Menus, SciStreamDefault, Errors, Blocks, ExtCtrls, ToolTip;

type
  TJassForm = class(TForm)
    Scintilla: TScintilla;
    Button1: TButton;
    Errors: TListBox;
    Button2: TButton;
    Label1: TLabel;
    PopupMenu: TPopupMenu;
    Openchild1: TMenuItem;
    ActionList1: TActionList;
    Action: TAction;
    Label2: TLabel;
    Button3: TButton;
    HintTimer: TTimer;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ActionUpdate(Sender: TObject);
    procedure ActionExecute(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure HintTimerTimer(Sender: TObject);
    procedure ScintillaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScintillaExit(Sender: TObject);
    procedure ScintillaCharAdded(Sender: TObject; const ch: Integer);
    procedure ScintillaVScroll(Sender: TObject; const scrollCode: Integer);
    procedure FormDeactivate(Sender: TObject);
    procedure ScintillaMouseLeave(Sender: TObject);
    procedure ScintillaMouseEnter(Sender: TObject);
  private
    { Private declarations }
  public
    DocInfo: PDocumentInfo;
    ToolTip: TToolTip;
    X, Y: Integer;
    Over: Boolean;
    
    function ErrorFromPosition(Position: Cardinal): PErrorInfo;
    function DocumentFromPosition(Position: Cardinal): PDocumentInfo;
  end;

procedure ApplyErrors(const Document: TDocumentInfo; Scintilla: TScintillaBase); overload;
procedure ApplyErrors(const Document: TDocumentInfo; ListBox: TCustomListBox); overload;

procedure ShowDocument(const Document: TDocumentInfo);

var
  JassForm: TJassForm;
  Doc: PDocument;
  
implementation

uses uTimer, Math;

{$R *.dfm}

function TJassForm.DocumentFromPosition(Position: Cardinal): PDocumentInfo;
var
  Document: PDocumentInfo;
begin
  Result := nil;

  if DocInfo = nil then
    Exit;

  Document := DocInfo.Children;

  while Document <> nil do
    begin
      if (GetLength(DocInfo.Input, Document.Start) <= Position) and (Position <= GetLength(DocInfo.Input, Document.Stop)) then
        begin
         Result := Document;
         Exit;
        end;
        
      Document := Document.Next;
    end;
end;

function TJassForm.ErrorFromPosition(Position: Cardinal): PErrorInfo;
var
  Pos: Cardinal;
  ErrorInfo: PErrorInfo;
begin
  Result := nil;

  if DocInfo = nil then
    Exit;

  ErrorInfo := DocInfo.Errors;
  while ErrorInfo <> nil do
    begin
      Pos := Cardinal(ErrorInfo.Start) - Cardinal(DocInfo.Input);

      if (Pos <= Position) and (Position < Pos + ErrorInfo.Length) then
        begin
         Result := ErrorInfo;
         Exit;
        end;

      ErrorInfo := ErrorInfo.Next;
    end;
end;

procedure TJassForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ToolTip.Free;
  
  if (Doc <> nil) and (DocInfo.Owner = nil) then
    begin
      DocInfo.Free;

      Doc.Free;
      Dispose(Doc);

      DocInfo := nil;
      Doc := nil;
    end;
end;

procedure TJassForm.FormCreate(Sender: TObject);
begin
  ToolTip := TToolTip.Create(Scintilla);
end;

procedure TJassForm.FormDeactivate(Sender: TObject);
begin
  ToolTip.Hide;
end;

procedure TJassForm.FormShow(Sender: TObject);
begin
  Init;
end;

procedure TJassForm.HintTimerTimer(Sender: TObject);
var Position: Integer;
    Error: PErrorInfo;
    Start, Stop: Cardinal;
    Rect: TRect;
begin
  if (not Over) or (not Self.Active) then
    Exit;
    
  Position := Scintilla.PositionFromPointClose(X, Y);

  if Position = -1 then
    Exit;

  Error := ErrorFromPosition(Position);

  if (Error = nil) or (Error.Length = 0) then
    Exit;

  Start := Cardinal(Error.Start) - Cardinal(DocInfo.Input);
  Stop := Start + Error.Length;

  Rect.Left := Min(X, Scintilla.PointXFromPosition(Start) - 2);
  Rect.Right := Max(X, Scintilla.PointXFromPosition(Stop) + 2);
  Rect.Top := Min(Y, Scintilla.PointYFromPosition(Start) - 2);
  Rect.Bottom := Max(Y, Rect.Top + Scintilla.TextHeight(Scintilla.LineFromPosition(Start) + 1) + 2);

  ToolTip.Show(Rect.Left, Rect.Bottom + 5, Rect, Error.ToString);
end;

procedure TJassForm.ScintillaCharAdded(Sender: TObject; const ch: Integer);
begin
  ToolTip.Hide;
end;

procedure TJassForm.ScintillaExit(Sender: TObject);
begin
  ToolTip.Hide;
end;

procedure TJassForm.ScintillaMouseEnter(Sender: TObject);
begin
  Over := True;
end;

procedure TJassForm.ScintillaMouseLeave(Sender: TObject);
begin
  ToolTip.Hide;
  Over := False;
end;

procedure TJassForm.ScintillaMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Self.X := X;
  Self.Y := Y;

  if (not ToolTip.Activated) or ToolTip.Outside(X, Y) then
    begin
      ToolTip.Hide;
      HintTimer.Enabled := True;
    end;
end;

procedure TJassForm.ScintillaVScroll(Sender: TObject;
  const scrollCode: Integer);
begin
  ToolTip.Hide;
end;

procedure ShowDocument(const Document: TDocumentInfo);
var Form: TJassForm;
begin
  Form := TJassForm.Create(Application);
  Form.OnShow := nil;
  Form.Caption := 'Showing ' + Document.Name;
  Form.Scintilla.SetText(Document.Input);
  Form.Button2.Hide;
  Form.Button3.Hide;
  Form.Label1.Hide;
  Form.Label2.Hide;
  Form.DocInfo := @Document;
  ApplyErrors(Document, Form.Errors);
  ApplyErrors(Document, Form.Scintilla);
  Form.ShowModal;
  Form.Free;
end;

procedure ApplyErrors(const Document: TDocumentInfo; ListBox: TCustomListBox); overload;
var
  i: Integer;
  ErrorInfo: PErrorInfo;
begin
  ListBox.Items.BeginUpdate;
  ListBox.Items.Clear;
  {$OVERFLOWCHECKS OFF}

  ErrorInfo := Document.Errors;
  i := 0;
  
  while ErrorInfo <> nil do
    begin
      if i > 20 then
        begin
          ListBox.Items.Add('Too many errors, trimmed');
          ListBox.Items.EndUpdate;
          Exit;
        end;
      ListBox.Items.Insert(0, 'Error [' + IntToStr(ErrorInfo.Line + 1) + ': ' + IntToStr(Cardinal(ErrorInfo.Start) - Cardinal(ErrorInfo.LineStart) + 1) + '] ' + ErrorInfo.ToString);

      Inc(i);

      ErrorInfo := ErrorInfo.Next;
    end;
  {$OVERFLOWCHECKS ON}
  ListBox.Items.EndUpdate;
end;

procedure ApplyErrors(const Document: TDocumentInfo; Scintilla: TScintillaBase);
var
  i: Integer;
  ErrorInfo: PErrorInfo;
begin
  Scintilla.IndicSetStyle(9, 1);
  Scintilla.IndicSetFore(9, clRed);
  Scintilla.SetIndicatorCurrent(9);
  Scintilla.IndicatorClearRange(0, Scintilla.GetLength);

  ErrorInfo := Document.Errors;
  i := 0;

  while ErrorInfo <> nil do
    begin
      if i > 10000 then
        Exit;
            
      Scintilla.IndicatorFillRange(Cardinal(ErrorInfo.Start) - Cardinal(Document.Input), ErrorInfo.Length);

      Inc(i);

      ErrorInfo := ErrorInfo.Next;
    end;
end;

procedure TJassForm.ActionExecute(Sender: TObject);
begin
  ToolTip.Hide;
  ShowDocument(DocumentFromPosition(Scintilla.GetSelectionStart)^);
end;

procedure TJassForm.ActionUpdate(Sender: TObject);
begin
  if Scintilla.GetSelectionStart = Scintilla.GetSelectionEnd then
    TAction(Sender).Enabled := DocumentFromPosition(Scintilla.GetSelectionStart) <> nil
  else
    TAction(Sender).Enabled := False;
end;

procedure TJassForm.Button1Click(Sender: TObject);
begin
Close;
end;

procedure TJassForm.Button2Click(Sender: TObject);
var Data: String;
begin
  if Doc <> nil then
    begin
      DocInfo.Free;

      Doc.Free;
      Dispose(Doc);

      DocInfo := nil;
      Doc := nil;
    end;
    
  Data := Scintilla.Lines.Text;

  StoreTime;

  DocInfo := Parse(PChar(Data));

  New(Doc);
  Doc.Init;
  ParseDocument(Doc^);

  Label1.Caption := 'Time: ' + GetTime + ' ms';

  StoreTime;

  ApplyErrors(DocInfo^, Errors);
  ApplyErrors(DocInfo^, Scintilla);

  Label2.Caption := 'GUI: ' + GetTime + ' ms';
end;

procedure TJassForm.Button3Click(Sender: TObject);
begin
  Scintilla.StreamClass := TSciStreamDefault;
  Scintilla.Lines.LoadFromFile('Demo.j');
  Button2Click(nil);
end;

end.
