program ConsoleParser;

{$APPTYPE CONSOLE}

uses
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

var i, Errors, TotalErrors, TotalLines: Cardinal;
  FileDocument: PDocument;
  FileStream: TFileStream;
  FileMemory: PAnsiChar;
  Name: string;

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

begin
  try
    Init;
    ExitCode := 0;
    TotalErrors := 0;
    TotalLines := 0;

    ReportMemoryLeaksOnShutdown := True;
    
    for i := 1 to ParamCount do
      begin
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
            FileDocument.Info.Name := ExtractRelativePath(GetCurrentDir, ParamStr(i));
            ParseDocument(FileDocument^);

            Name := ExtractRelativePath(GetCurrentDir, ParamStr(i));

            Errors := 0;

            ReportErrors(FileDocument.Info, '', Errors);

            TotalErrors := TotalErrors + Errors;
            TotalLines := TotalLines + Token.Line;

            if Errors = 0 then
              WriteLn(Format('Parse successful: %8u lines: %s', [Token.Line, FileDocument.Info.Name]))
            else if Errors = 1 then
              WriteLn(FileDocument.Info.Name, ' failed with ' + IntToStr(Errors) + ' error')
            else if Errors > 1 then
              WriteLn(FileDocument.Info.Name, ' failed with ' + IntToStr(Errors) + ' errors');

          finally
            FreeAndNil(FileStream);
            FreeMem(FileMemory);
          end;

          DocumentList.Add(FileDocument);
        except
          on E:Exception do
            Writeln(E.Classname, ': ', E.Message);
        end;
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
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
