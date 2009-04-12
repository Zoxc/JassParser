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
  Name: string;
  DoImplictRealCatch: Boolean;

  procedure ReportErrors(Doc: PDocumentInfo; Name: String; var Number: Cardinal);
  var
    ErrorInfo: PErrorInfo;
  begin
    ErrorInfo := Doc.Errors;

    while ErrorInfo <> nil do
      begin
        ExitCode := 1;

        if ErrorInfo.ErrorType = eiChildErrors then
          ReportErrors(ErrorInfo.Child, Name + Doc.Name + ':', Number)
        else
          begin
            WriteLn(Name + Doc.Name, ':' + IntToStr(ErrorInfo.Line + 1) + ': ' + ErrorInfo.ToString);
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
  else if Cmd = '--help' then
    begin
      Writeln('JassParserCLI 0.1.8');
      Writeln('-------------');
      Writeln('JassParserCLI <options> <documents>');
      Writeln('');
      Writeln('--implicit-reals and -ir: Reports implicit conversion from integer constants to reals');
      Writeln('--report-leaks: Reports memory leaks at shutdown');
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

              Name := ExtractRelativePath(GetCurrentDir, ParamStr(i));

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
                WriteLn(ParamStr(i), ':' + IntToStr(Token.Line + 1) + ': ' + E.Classname, ': ', E.Message);
                ExitCode := -1;
              end;
          end;

          TotalErrors := TotalErrors + Errors;
          TotalLines := TotalLines + Token.Line;

          if Errors = 0 then
            WriteLn(Format('Parse successful: %8u lines: %s', [Token.Line, ParamStr(i)]))
          else if Errors = 1 then
            WriteLn(ParamStr(i), ' failed with ' + IntToStr(Errors) + ' error')
          else if Errors > 1 then
            WriteLn(ParamStr(i), ' failed with ' + IntToStr(Errors) + ' errors');
        end;

      if TotalErrors = 0 then
        WriteLn(Format('Parse successful: %8u lines: %s', [TotalLines, '<total>']))
      else if TotalErrors = 1 then
        WriteLn('Parse failed: ' + IntToStr(TotalErrors) + ' error total')
      else if TotalErrors > 1 then
        WriteLn('Parse failed: ' + IntToStr(TotalErrors) + ' errors total');

      for i := 1 to DocumentList.Count - 1 do
        with PDocument(DocumentList[i])^ do
          begin
            Info.Free;
            Free;
            Dispose(DocumentList[i]);
          end;

    except
      on E:Exception do
        begin
          MessageBox(0, PChar(E.Classname + ': ' + E.Message), 'JassParser', 0);
          ExitCode := -1;
        end;
    end;

  except
  end;
end.
