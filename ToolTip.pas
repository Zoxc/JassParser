unit ToolTip;

interface

uses Windows, Classes, Controls, CommCtrl;

type
  TToolTip = class
    private
      FControl: TWinControl;
      FHandle: THandle;
      FActivated: Boolean;
      FText: String;
      FRect: TRect;
      FToolInfo: TToolInfo;
    public
      constructor Create(const AControl: TWinControl);
      destructor Destroy; override;
      function Outside(X, Y: Integer): Boolean; 
      procedure Show(X, Y: Integer; const Rect: TRect; Text: String);
      procedure Hide;
      property Activated: Boolean read FActivated write FActivated;
  end;

implementation

constructor TToolTip.Create(const AControl: TWinControl);
begin
  inherited Create;

  FActivated := False;
  FControl := AControl;
  FHandle := CreateWindowEx(WS_EX_TOPMOST, TOOLTIPS_CLASS, nil, WS_POPUP or TTS_NOPREFIX or TTS_ALWAYSTIP, 0, 0, 0, 0, FControl.Handle, 0, HInstance, nil);

  ZeroMemory(@FToolInfo, SizeOf(TToolInfo));
  FToolInfo.cbSize := SizeOf(TToolInfo);
  FToolInfo.uFlags := TTF_IDISHWND or TTF_ABSOLUTE or TTF_TRACK;
  FToolInfo.hwnd := 0;
  FToolInfo.hinst := HInstance;
  FToolInfo.lpszText := '';
  FToolInfo.uId := 0;
  //FToolInfo.Rect := FControl.ClientRect;

  SendMessage(FHandle, TTM_ADDTOOL, 0, Integer(@FToolInfo));
end;

destructor TToolTip.Destroy;
begin
  Hide;
  
  DestroyWindow(FHandle);
  
  inherited Destroy;
end;

function TToolTip.Outside(X, Y: Integer): Boolean;
begin
  Result := (X < FRect.Left) or (X > FRect.Right) or (Y < FRect.Top) or (Y > FRect.Bottom);
end;

procedure TToolTip.Hide;
begin
  if FActivated then
    begin
      FActivated := False;
      SendMessage(FHandle, TTM_TRACKACTIVATE, 0, Integer(@FToolInfo));
    end;
end;

procedure TToolTip.Show(X, Y: Integer; const Rect: TRect; Text: String);
var APoint: TPoint;
begin
  FActivated := True;

  FText := Text;

  FToolInfo.lpszText := PChar(FText);
  FRect := Rect;

  APoint := FControl.ClientToScreen(Point(X, Y));
  
  SendMessage(FHandle, TTM_SETTOOLINFOA, 0, Integer(@FToolInfo));
  SendMessage(FHandle, TTM_TRACKPOSITION, 0, MAKELONG(APoint.x, APoint.y));
  SendMessage(FHandle, TTM_TRACKACTIVATE, 1, Integer(@FToolInfo));
end;

end.
