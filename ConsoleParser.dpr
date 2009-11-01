program ConsoleParser;

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  SysUtils,
  Scanner in 'Parser\Scanner.pas',
  Tokens in 'Parser\Tokens.pas',
  ScannerKeywordsJumpTable in 'Parser\ScannerKeywordsJumpTable.pas',
  Statements in 'Parser\Statements.pas',
  Documents in 'Parser\Documents.pas',
  Expressions in 'Parser\Expressions.pas',
  TypesUtils in 'Parser\TypesUtils.pas',
  ScannerHandlers in 'Parser\ScannerHandlers.pas',
  Scopes in 'Parser\Scopes.pas',
  Blocks in 'Parser\Blocks.pas';

var i, ParamStart, Errors, TotalErrors, TotalLines: Cardinal;
  FileDocument: PDocument;
  FileStream: TFileStream;
  FileMemory: PAnsiChar;
  DoImplictRealCatch: Boolean;
  EmulatePJASS: Boolean;

  procedure SetResult(Result: TErrorClass);
  begin
    if EmulatePJASS then
      begin
        case Result of
          ecError, ecException:
            ExitCode := 1;
        end;
      end
    else
      begin
        if Integer(Result) > ExitCode then
          ExitCode := Integer(Result);
      end;
  end;
  
  procedure ReportErrors(Doc: PDocumentInfo; Name: String; var Number: Cardinal);
  var
    ErrorInfo: PErrorInfo;
  begin
    ErrorInfo := Doc.Errors;

    while ErrorInfo <> nil do
      begin
        SetResult(ErrorInfo.ErrorClass);

        if ErrorInfo.ErrorType = eiChildErrors then
          ReportErrors(ErrorInfo.Child, Name + Doc.Name + ':', Number)
        else
          begin
            if EmulatePJASS then
              WriteLn(Doc.Name, ':' + IntToStr(ErrorInfo.Line + 1) + ': ' + ErrorInfo.ToString)
            else
              WriteLn('[' + ErrorClassNames[ErrorInfo.ErrorClass] + '] ' + Name + Doc.Name, '(' + IntToStr(ErrorInfo.Line + 1) + ': ' + IntToStr(Cardinal(ErrorInfo.Start) - Cardinal(ErrorInfo.LineStart) + 1) + '-' + IntToStr(Cardinal(ErrorInfo.Start) - Cardinal(ErrorInfo.LineStart) + 1 + ErrorInfo.Length) + '): ' + ErrorInfo.ToString);

            Inc(Number);
          end;

        ErrorInfo := ErrorInfo.Next;
      end;
  end;

function IsCommandLine: Boolean;
var Cmd: String;
begin
  Cmd := ParamStr(ParamStart);
  Result := (Cmd = '--implicit-reals') or (Cmd = '-ir')
    or (Cmd = '--report-leaks')
    or (Cmd = '--return-bug') or (Cmd = '-rb')
    or (Cmd = '--pjass')
    or (Cmd = '--help');
end;

procedure ParseCommandLine;
var Cmd: String;
begin
  Cmd := ParamStr(ParamStart);

  if (Cmd = '--implicit-reals') or (Cmd = '-ir') then
    DoImplictRealCatch := True
  else if Cmd = '--report-leaks' then
    ReportMemoryLeaksOnShutdown := True
  else if Cmd = '--pjass' then
    EmulatePJASS := True
  else if (Cmd = '--return-bug') or (Cmd = '-rb') then
    DoReturnBug := True

  else if Cmd = '--help' then
    begin
      Writeln('JassParserCLI 0.1.12');
      Writeln('-------------');
      Writeln('JassParserCLI <options> <documents>');
      Writeln('');
      Writeln('--implicit-reals and -ir: Reports implicit conversion from integer constants to reals');
      Writeln('--pjass: Emulate PJASS CLI');
      Writeln('--report-leaks: Reports memory leaks at shutdown');
      Writeln('--return-bug and -rb: This will emulate the return bug');
      Writeln('--help: Shows this info');
      Abort;
    end;

  Inc(ParamStart);
end;

begin
  try
    Init;
    ExitCode := 0;
    TotalErrors := 0;
    TotalLines := 0;

    DoImplictRealCatch := False;
    DoReturnBug := False;
    EmulatePJASS := False;

    ParamStart := 1;

    while IsCommandLine do
      ParseCommandLine;

    try
      for i := ParamStart to ParamCount do
        begin
          Errors := 0;

          ImplictRealCatch := DoImplictRealCatch and (LowerCase(ExtractFileName(ParamStr(i))) <> 'blizzard.j');
        
          try
            FileStream := TFileStream.Create(ParamStr(i), fmOpenRead);
            FileMemory := nil;

            try
              GetMem(FileMemory, FileStream.Size + 1);

              PAnsiChar(Cardinal(FileMemory) + FileStream.Size)^ := #0;
              FileStream.Read(FileMemory^, FileStream.Size);

              New(FileDocument);
              FileDocument.Init;
              FileDocument.Info := Parse(FileMemory);
              FileDocument.Info.Name := ParamStr(i);
              ParseDocument(FileDocument^);

              ReportErrors(FileDocument.Info, '', Errors);

            finally
              FreeAndNil(FileStream);
              FreeMem(FileMemory);
            end;

            DocumentList.Add(FileDocument);
          
          except
            on E:Exception do
              begin
                Errors := Errors + 1;

                if EmulatePJASS then
                  WriteLn(ParamStr(i), ':' + IntToStr(Token.Line + 1) + ': ' + E.Classname, ': ', E.Message)
                else
                  WriteLn('[Exception] ' + ParamStr(i), '(' + IntToStr(Token.Line + 1) + ': ' + IntToStr(Cardinal(Token.Start) - Cardinal(Token.LineStart) + 1) + '-' + IntToStr(Cardinal(Token.Stop) - Cardinal(Token.LineStart) + 1) + '): ' + E.Classname, ': ', E.Message);

                SetResult(ecException);
              end;
          end;

          TotalErrors := TotalErrors + Errors;
          TotalLines := TotalLines + Token.Line;

          if EmulatePJASS then
            begin
              if Errors = 0 then
                WriteLn(Format('Parse successful: %8u lines: %s', [Token.Line, ParamStr(i)]))
              else if Errors = 1 then
               WriteLn(ParamStr(i), ' failed with ' + IntToStr(Errors) + ' error')
             else if Errors > 1 then
                WriteLn(ParamStr(i), ' failed with ' + IntToStr(Errors) + ' errors');
            end;
        end;

      if EmulatePJASS then
        begin
          if TotalErrors = 0 then
           WriteLn(Format('Parse successful: %8u lines: %s', [TotalLines, '<total>']))
          else if TotalErrors = 1 then
            WriteLn('Parse failed: ' + IntToStr(TotalErrors) + ' error total')
          else if TotalErrors > 1 then
            WriteLn('Parse failed: ' + IntToStr(TotalErrors) + ' errors total');
        end;
      
      for i := 1 to DocumentList.Count - 1 do
        with PDocument(DocumentList[i])^ do
          begin
            Info.Free;
            Free;
            Dispose(DocumentList[i]);
          end;

    except
      on E: Exception do
        begin
          MessageBox(0, PChar(E.Classname + ': ' + E.Message), 'JassParser', 0);
          
          SetResult(ecException);
        end;
    end;

  except
  end;
end.
