program Project;

uses
  Forms,
  Blocks in 'Parser\Blocks.pas',
  uTimer in '..\Common\uTimer.pas',
  JassTest in 'JassTest.pas' {JassForm},
  Scanner in 'Parser\Scanner.pas',
  ScannerKeywordsHash in 'Parser\ScannerKeywordsHash.pas',
  ScannerKeywordsSimple in 'Parser\ScannerKeywordsSimple.pas',
  HashExplorer in 'HashExplorer.pas' {HashEx},
  SearchCode in 'SearchCode.pas' {SearchForm},
  ScannerKeywordsJumpTable in 'Parser\ScannerKeywordsJumpTable.pas',
  ScannerKeywordsHashedStringList in 'Parser\ScannerKeywordsHashedStringList.pas',
  Scopes in 'Parser\Scopes.pas',
  Tokens in 'Parser\Tokens.pas',
  ToolTip in 'ToolTip.pas',
  Documents in 'Parser\Documents.pas',
  Statements in 'Parser\Statements.pas',
  ScannerKeywordsLengthTable in 'Parser\ScannerKeywordsLengthTable.pas',
  ScannerKeywordsLengthTableGenerator in 'Parser\ScannerKeywordsLengthTableGenerator.pas',
  GeneratorCommon in 'Parser\GeneratorCommon.pas',
  ScannerKeywordsJumpTableGenerator in 'Parser\ScannerKeywordsJumpTableGenerator.pas',
  Expressions in 'Parser\Expressions.pas',
  ScannerHandlers in 'Parser\ScannerHandlers.pas',
  TypesUtils in 'Parser\TypesUtils.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TJassForm, JassForm);
  Application.CreateForm(THashEx, HashEx);
  Application.CreateForm(TSearchForm, SearchForm);
  Application.Run;
end.
