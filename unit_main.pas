unit unit_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdCookieManager, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, StdCtrls, ExtCtrls, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, xmldom, XMLIntf, msxmldom, XMLDoc,
  IdCoder, IdCoder3to4, IdCoderMIME, Grids, Menus, unit_messages, ImgList, IdMultipartFormData;

type
  Tmain = class(TForm)
    http: TIdHTTP;
    cookie: TIdCookieManager;
    log: TMemo;
    ssl: TIdSSLIOHandlerSocketOpenSSL;
    xml: TXMLDocument;
    messages: TStringGrid;
    tray: TTrayIcon;
    popup_tray: TPopupMenu;
    Dsjl1: TMenuItem;
    timer: TTimer;
    popup_messages: TPopupMenu;
    MenuItem1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure messagesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure trayDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Dsjl1Click(Sender: TObject);
    procedure timerTimer(Sender: TObject);
    procedure messagesKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure messagesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure messagesDblClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);

    procedure debug(str:string);
  private
    msg: TMessageHistory;
    function MegaplanSign(Method,ContentMD5,ContentType,Date,Host,Uri :string): string;
    function MegaplanSignTest(Method,ContentMD5,ContentType,Date,Host,Uri :string): string;

    function MegaplanGet(Uri :string): string;
    function MegaplanPost(Uri: string; PostData: TIdMultiPartFormDataStream): string;
    function MegaplanParseNotifications(xmlstr :string): string;
    function messageExist(id: string): integer;

    procedure MessagesRefresh;
  public
    { Public declarations }
  end;

var
  main: Tmain;

  config_url: string;
  config_username, config_userpassword, config_host: string;

  megaplan_access_id  : string;
  megaplan_secret_key : string;
  timerenabled: boolean;

implementation

uses IdHashMessageDigest, IdHeaderList, IdDateTimeStamp, MSXML, unit_utils, IdHMACSHA1, IdGlobal,
  unit_login, ShellAPI;

{$R *.dfm}

function tmain.messageExist(id: string): integer;
var i:integer;
begin
  result := -1;
  for i := 0 to messages.RowCount-1 do
    if messages.Cells[1,i] = id then
      result:=i;
end;

procedure Tmain.messagesDblClick(Sender: TObject);
var m:PMessage;
  url: string;
begin
  with Sender as TStringGrid do
  begin
    m := msg.msg[StrToInt(Cells[Col,Row])];
    if m.subject.ttype = 'comment' then
      url := 'http://'+config_host+'/task/'+IntToStr(m.content.subject.id)+'/card/#c'+IntToStr(m.subject.id)
    else
      url := 'http://'+config_host+'/task/'+IntToStr(m.subject.id)+'/card/';

    ShellExecute(0, 'open', PWideChar(url), nil, nil, SW_SHOWNORMAL);
  end;
end;

procedure Tmain.messagesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var FRect: TRect;
    m    : PMessage;
    str  : string;
begin
    with TStringGrid(Sender) do
      if ACol=0  then
      begin
        Canvas.Brush.Color := $00FFFFFF;
        Canvas.FillRect(Rect);

        FRect := Rect;
        Inc(FRect.Left, 2);
        Inc(FRect.Top, 2);
        Dec(FRect.Right, 2);
        Dec(FRect.Bottom, 2);

        try
          m := msg.msg[StrToint(Cells[ACol, ARow])];
        except
          on E: Exception do
          begin
            m := New(PMessage);
            m.subject.ttype:='empty';
          end;
        end;
        Canvas.Pen.Color := 0;
        if m.subject.ttype = 'comment' then
          Canvas.Brush.Color := $00AAFFAA
        else
          Canvas.Brush.Color := $00F5F5F5;

        Canvas.FillRect(FRect);
        Inc(FRect.Left, 2);
        Inc(FRect.Top, 2);

        //Empty
        if (m.subject.ttype = 'empty') then
         str := 'Сообщений нет';

        //Comment
        if (m.subject.ttype = 'comment') then
         str := m.time_created+', ' + m.content.subject.name + #13#10 +m.content.author.name + ' оставил(а) комментарий: ' + m.content.text;

        //Task
        if (m.subject.ttype = 'task') then
          str := m.time_created + ' ' +m.subject.name + #13#10 + m.content.roottext;


        RowHeights[ARow] := DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_WORDBREAK or DT_CALCRECT)+4;
        DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_NOPREFIX or DT_WORDBREAK);
      end;
end;

procedure Tmain.messagesKeyPress(Sender: TObject; var Key: Char);
begin
  if ord(key) = VK_ESCAPE then
    Hide;

  if ord(key) = VK_F5 then
    MessagesRefresh;
end;

procedure Tmain.messagesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var R,C:integer;
begin
  if Button<>mbRight then
    exit;

  TStringGrid(Sender).MouseToCell(X, Y, C, R);

  if (r<0) or (c<0) then
    exit;

  with Sender as TStringGrid do
  begin
    Col := C;
    Row := R;
  end;

  popup_messages.Popup(5+main.Left+TStringGrid(Sender).Left+X, 10+main.top + TStringGrid(Sender).Top + Y);
end;

procedure Tmain.MessagesRefresh;
begin
  if enabled then
  begin
    MegaplanParseNotifications(MegaplanGet('/BumsCommonApiV01/Informer/notifications.xml'));
  end;
end;

procedure Tmain.timerTimer(Sender: TObject);
var str:string;
begin
  MessagesRefresh;
end;

procedure Tmain.trayDblClick(Sender: TObject);
begin
  main.Visible := True;
  main.BringToFront;
  BringWindowToTop(Application.Handle);
  ShowWindow(Application.MainForm.Handle, SW_RESTORE);
  SetForegroundWindow(Main.Handle);
end;

function Tmain.MegaplanSign(Method,ContentMD5,ContentType,Date,Host,Uri:string): string;
var str: string;
  hash: TIdBytes;

begin
  str:=Method+#10+ContentMD5+#10+ContentType+#10+Date+#10+Host+Uri;
  with TIdHMACSHA1.Create do
  try
    Key := toBytes(megaplan_secret_key);
    hash := HashValue(toBytes(str));
  finally
    Free;
  end;
  debug('hash1='+bintostr(hash));
  result:=TIdEncoderMIME.EncodeBytes(toBytes(bintostr(hash)));
end;

function Tmain.MegaplanSignTest(Method,ContentMD5,ContentType,Date,Host,Uri:string): string;
var str: string;
  hash: TIdBytes;

begin
  str:=Method+#10+ContentMD5+#10+ContentType+#10+Host+Uri;
  with TIdHMACSHA1.Create do
  try
    Key := toBytes(megaplan_secret_key);
    hash := HashValue(toBytes(str));
  finally
    Free;
  end;
  debug('hash2='+bintostr(hash));
  result:=TIdEncoderMIME.EncodeBytes(toBytes(bintostr(hash)));
end;

procedure Tmain.MenuItem1Click(Sender: TObject);
var m: PMessage;
    data: TIdMultiPartFormDataStream;
begin
  m := msg.msg[StrToInt(messages.Cells[messages.Col, messages.Row])];

  //Parameters
  data := TIdMultiPartFormDataStream.Create();
  data.AddFormField('Ids',IntToStr(m.id));
  MegaplanPost('/BumsCommonApiV01/Informer/deactivateNotification.xml', data);
  MessagesRefresh;
end;

function Tmain.MegaplanGet(Uri :string): string;
var DateRFC: string;
    sign:string;
    response:string;
    msg: string;
begin
  daterfc:= RFC2822Date(Now(), false);
  sign:=MegaplanSign('GET', '', '', DateRFC, config_host, Uri);

  http.Request.CustomHeaders.Clear;
  http.Request.CustomHeaders.AddValue('Date', daterfc);
  http.Request.CustomHeaders.AddValue('Accept', 'application/json');
  http.Request.CustomHeaders.AddValue('X-Authorization', megaplan_access_id+':'+sign);

  try
    response:=http.Get('https://'+config_host+uri);
  except
    on E:Exception do
    begin
      MessageBox(Handle, PWideChar(E.Message), 'Ошибка загрузки', mb_OK);
    end;
  end;
  MegaplanGet:=response;
end;

procedure RemoveRowStringGrid(var StringGrid: TStringGrid; Which: integer);
var
  i: integer;
begin
    for i := StringGrid.Row to StringGrid.RowCount - 1 do
    begin
      StringGrid.Rows[i] := StringGrid.Rows[i + 1];
    end;
    StringGrid.RowCount := StringGrid.RowCount - 1;
end;

function Tmain.MegaplanParseNotifications(xmlstr :string): string;
var i      : integer;
  row      : integer;
  newcount : integer;
  m        : PMessage;
begin

  newcount := msg.Parse(xmlstr);

  if newcount<0 then
  begin
    debug('Ошибка разбора пакета со списком сообщений');
    exit;
  end;

  row:=0;
  messages.Enabled:=false;
  messages.RowCount := 1;
  messages.Cells[0,0] := 'Сообщений нет';

  for i := 0 to msg.count-1 do
  begin
    m := msg.msg[i];
    messages.RowCount := row+1;
    messages.Cells[0, row] := IntToStr(i);
    inc(row);
  end;

  if newcount >0  then
  begin
    tray.BalloonTitle := 'Ух ты!';
    tray.BalloonHint  := 'Новые сообщения: ' + IntToStr(newcount);
    tray.BalloonTimeout := 10;
    tray.ShowBalloonHint;
  end;
  messages.Enabled:=true;
  messages.Repaint;
end;

function Tmain.MegaplanPost(Uri: string; PostData: TIdMultiPartFormDataStream): string;
var
  DateRFC: string;
  sign, response, p1, p2: string;
  http: TIdHTTP;
  http_io: TIdSSLIOHandlerSocketOpenSSL;
  params,parameter: TStringArr;
  i:integer;
begin
  http_io := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  http := TIdHTTP.Create(nil);
  http.IOHandler := http_io;

  daterfc:= RFC2822Date(Now(), false);
  sign:=MegaplanSign('POST', '', 'application/x-www-form-urlencoded', DateRFC, config_host,Uri);
  http.Request.CustomHeaders.Clear;
  http.Request.CustomHeaders.AddValue('Date', daterfc);
  http.Request.CustomHeaders.AddValue('Accept', 'application/json');
  http.Request.CustomHeaders.AddValue('X-Authorization', megaplan_access_id+':'+sign);
  http.Request.CustomHeaders.AddValue('Content-Type', 'application/x-www-form-urlencoded');
  //http.Request.CustomHeaders.AddValue('PostData', PostData);
  try
    response:=http.Post('https://'+config_host+uri, postdata);
  finally
    http.Free;
    http_io.Free;
  end;
  debug(response);
end;

procedure Tmain.debug(str: string);
var sl:TStringList;
    s:string;
    i:integer;
begin
  //log.lines.Add(str);
end;

procedure Tmain.Dsjl1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tmain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=False;
  main.hide;
end;

procedure Tmain.FormCreate(Sender: TObject);
begin
  Width := messages.Width + 6;
  Height := messages.Height +6;
  timerenabled := false;
  messages.ColWidths[0]:=messages.Width-4;
  msg := TMessageHistory.Create;

  Left:=screen.WorkAreaWidth-width;
  Top:=screen.WorkAreaHeight-Height;
end;

procedure Tmain.FormShow(Sender: TObject);
begin
  Left:=screen.WorkAreaWidth-width;
  Top:=screen.WorkAreaHeight-Height;
end;

end.
