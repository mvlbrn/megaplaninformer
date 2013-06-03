program megainformer;

uses
  Forms,
  unit_main in 'unit_main.pas' {main},
  unit_utils in 'unit_utils.pas',
  unit_login in 'unit_login.pas' {login},
  unit_messages in 'unit_messages.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Megainformer';
  Application.CreateForm(Tmain, main);
  if TLogin.Execute then
    Application.Run;
end.
