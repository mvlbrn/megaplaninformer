unit unit_login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, pngimage;

type
  Tlogin = class(TForm)
    edit_host: TLabeledEdit;
    edit_user: TLabeledEdit;
    edit_pass: TLabeledEdit;
    btn_login: TButton;
    Shape1: TShape;
    auto: TCheckBox;
    timer: TTimer;
    procedure btn_loginClick(Sender: TObject);
    procedure edit_hostKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure autoClick(Sender: TObject);
    procedure timerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    class function Execute : boolean;
  end;

var
  login: Tlogin;

implementation
uses unit_main, unit_utils;
{$R *.dfm}

procedure Tlogin.autoClick(Sender: TObject);
begin
  if not TCheckBox(Sender).Checked then
    timer.Enabled := false;
  regWriteBool('auto', TCheckBox(sender).Checked);
end;

procedure Tlogin.btn_loginClick(Sender: TObject);
var response:string;
begin
  timer.Enabled := false;
  enabled := false;
  config_host:=edit_host.Text;
  config_username := edit_user.Text;
  config_userpassword := edit_pass.Text;

  regWriteString('host', config_host);
  regWriteString('user', config_username);
  regWriteString('pass', config_userpassword);
  regWriteBool('auto', auto.Checked);

  try
    try
      response:=main.http.Get('https://'+config_host+'/BumsCommonApiV01/User/authorize.xml?Login='+config_username+'&Password='+md5(config_userpassword));
    except
      On e: Exception do
        response:='<?xml version="1.0" encoding="utf-8"?><response><status><code>fail</code><message>Ошибка при запросе: '+E.Message+'</message></status><data/></response>';
    end;
  finally
    main.xml.LoadFromXML(response);
  end;

  if main.xml.DocumentElement.ChildNodes['status'].ChildNodes['code'].text = 'ok' then
  begin
    main.log.Lines.Add('Успешно вошли в систему');
    megaplan_access_id  := main.xml.DocumentElement.ChildNodes['data'].ChildNodes['access_id'].text;
    megaplan_secret_key := main.xml.DocumentElement.ChildNodes['data'].ChildNodes['secret_key'].text;
    timerenabled := true;
    main.timer.Enabled:=timerenabled;
    main.timer.OnTimer(nil);
    ModalResult := mrOk;
  end
  else
  begin
    MessageBox(Application.Handle, PWideChar(main.xml.DocumentElement.ChildNodes['status'].ChildNodes['message'].text), 'Ошибка', mb_Ok);
    Application.Terminate;
  end;
end;

procedure Tlogin.edit_hostKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    btn_loginClick(Sender);
end;

class function TLogin.Execute: boolean;
 begin
   with TLogin.Create(nil) do
   try
     Result := ShowModal = mrOk;
   finally
     Free;
   end;
 end;

 procedure Tlogin.FormCreate(Sender: TObject);
begin
  auto.checked := regReadBool('auto', false);
  autopopup := regReadBool('auto', true);
  edit_host.Text := regReadString('host');
  edit_user.Text := regReadString('user');
  edit_pass.Text := regReadString('pass');
  main.popup_tray.Items[1].Checked := regReadBool('autopopup', true);
  timer.Enabled := auto.Checked;
  main.tray.PopupMenu.Items[0].Checked:=autopopup;
end;

procedure Tlogin.timerTimer(Sender: TObject);
begin
  btn_login.Click;
end;

end.
