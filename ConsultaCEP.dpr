program ConsultaCEP;

uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uConsultaCEP in 'uConsultaCEP.pas',
  uConsultaCEPManager in 'uConsultaCEPManager.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
