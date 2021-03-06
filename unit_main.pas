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
    btn_refresh: TButton;
    N1: TMenuItem;
    autoopen: TMenuItem;
    debug_results: TCheckBox;
    N2: TMenuItem;
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
    procedure btn_refreshClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure autoopenClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    msg: TMessageHistory;
    function MegaplanSign(Method,ContentMD5,ContentType,Date,Host,Uri :string): string;
    function MegaplanSignDebug(Method,ContentMD5,ContentType,Date,Host,Uri:string): string;
    function MegaplanGet(Uri :string): string;
    function MegaplanPost(Uri: string; PostData: TIdMultiPartFormDataStream): string;
    function MegaplanParseNotifications(xmlstr :string): string;
    function messageExist(id: string): integer;
    procedure mainshow();
    procedure _relocate();
    procedure _resize();
    procedure _offline();
    procedure _online();

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
  offline, autopopup: boolean;

implementation

uses IdHashMessageDigest, IdHeaderList, IdDateTimeStamp, MSXML, unit_utils, IdHMACSHA1, IdGlobal,
  unit_login, ShellAPI, System.Types, System.UITypes;

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
    id:integer;
    error: boolean;
begin
  id := -1;
  debug('Cell='+messages.Cells[messages.Col, messages.Row]);
  error:=false;
  //Check if value is integer
  try
    id:=StrToInt(TStringGrid(Sender).Cells[TStringGrid(Sender).Col,TStringGrid(Sender).Row]);
  except
    error:=true;
  end;
  //If conversion was bad - exit

  if (error) then
    exit;

  with Sender as TStringGrid do
  begin
    m := msg.msg[id];
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
      if (ACol=0) and (ARow < msg.Count)  then
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
        begin
         str := '��������� ���';
         //RowHeights[ARow] := DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_WORDBREAK or DT_CALCRECT)+4;
         DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_NOPREFIX or DT_WORDBREAK);
        end;

        //Comment
        if (m.subject.ttype = 'comment') then
        begin
          str := m.time_created+', ' + m.content.subject.name + #13#10 + m.content.author.name + ' �������(�) �����������: ' + m.content.text;
          //RowHeights[ARow] := DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_WORDBREAK or DT_CALCRECT)+4;
          DrawText(Canvas.Handle, str, -1, FRect, DT_NOPREFIX or DT_WORDBREAK);
        end;

        //Task
        if (m.subject.ttype = 'task') then
        begin
          str := m.time_created + ' ' +m.subject.name + #13#10 + m.content.roottext;
          //RowHeights[ARow] := DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_WORDBREAK or DT_CALCRECT)+4;
          DrawText(Canvas.Handle, str+#13#10, -1, FRect, DT_NOPREFIX or DT_WORDBREAK);
        end;
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

procedure Tmain.N1Click(Sender: TObject);
var
    i:integer;
    data: TIdMultiPartFormDataStream;
begin
  if MessageDlg('�������� ��� ���������?', mtConfirmation , mbOKCancel, 0) <> mrOk then
  exit;

  //Crete post array
  data := TIdMultiPartFormDataStream.Create();

  for i:=0 to msg.count-1 do
    data.AddFormField('Ids['+inttostr(i)+']',IntToStr(msg.msg[i].id));

  //Parameters
  MegaplanPost('/BumsCommonApiV01/Informer/deactivateNotification.xml', data);
  data.free;
  MessagesRefresh;
end;

procedure Tmain.N2Click(Sender: TObject);
begin
  MessagesRefresh;
end;

procedure Tmain._offline;
begin
  {$IFDEF DEBUG}
  tray.BalloonTitle:='������';
  tray.BalloonHint:='��� ���������� ������� ��������� ������';
  tray.BalloonTimeout := 10;
  tray.BalloonFlags := bfError;
  tray.ShowBalloonHint;
  {$ENDIF}
  //
end;

procedure Tmain._online;
begin
  //
end;

procedure Tmain._relocate;
begin
  Left:=screen.WorkAreaWidth-width;
  Top:=screen.WorkAreaHeight-Height;
end;

procedure Tmain._resize;
var count: integer;
    i, height : integer;
begin
  count := messages.RowCount;
  if (count>5) then
    count := 5;

  height := 0;
  for i := 0 to count-1 do
  begin
    height := height + messages.RowHeights[i]+3;
  end;
  messages.Height := height;

  {$IFNDEF DEBUG}
  main.Width := messages.Width + 6;
  main.Height:=GetSystemMetrics(SM_CYCAPTION)+ messages.top + messages.Height+4;
  {$ENDIF}
end;

procedure Tmain.timerTimer(Sender: TObject);
begin
  MessagesRefresh;
end;

procedure Tmain.trayDblClick(Sender: TObject);
begin
  tray.BalloonTimeout := 0;
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
  result:=TIdEncoderMIME.EncodeBytes(toBytes(bintostr(hash)));
end;

function Tmain.MegaplanSignDebug(Method,ContentMD5,ContentType,Date,Host,Uri:string): string;
var str: string;
  hash: TIdBytes;

begin
  str:=Method+#10+ContentMD5+#10+ContentType+#10+''+#10+Host+Uri;
  with TIdHMACSHA1.Create do
  try
    Key := toBytes(megaplan_secret_key);
    hash := HashValue(toBytes(str));
  finally
    Free;
  end;
  result:=TIdEncoderMIME.EncodeBytes(toBytes(bintostr(hash)));
end;

procedure Tmain.MenuItem1Click(Sender: TObject);
var m: PMessage;
    id:integer;
    error: boolean;
    data: TIdMultiPartFormDataStream;
begin
  id := -1;
  debug('Cell='+messages.Cells[messages.Col, messages.Row]);
  error:=false;
  //Check if value is integer
  try
    id:=StrToInt(messages.Cells[messages.Col, messages.Row]);
  except
    error:=true;
  end;
  //If conversion was bad - exit

  if (error) then
    exit;
  m := msg.msg[id];

  //Parameters
  debug('id='+inttostr(m.id));
  data := TIdMultiPartFormDataStream.Create();
  data.AddFormField('Ids[0]',IntToStr(m.id));
  MegaplanPost('/BumsCommonApiV01/Informer/deactivateNotification.xml', data);
  MessagesRefresh;
end;

function Tmain.MegaplanGet(Uri :string): string;
var DateRFC: string;
    sign:string;
    response:string;
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
    on e:exception do
    begin
      debug(e.message);
      _offline;
    end;
  end;
  MegaplanGet:=response;
  if (length(response)>0) then
    _online;

    if debug_results.Checked then debug('got: '+response);
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
begin
  newcount := msg.Parse(xmlstr);

  if newcount<0 then
  begin
    debug('������ ������� ������ �� ������� ���������');
    exit;
  end;

  row:=0;
  messages.RowCount := 1;
  messages.Cells[0,0] := '��������� ���';

  for i := 0 to msg.count-1 do
    begin
      messages.RowCount := row+1;
      messages.Cells[0, row] := IntToStr(i);
      inc(row);
    end;

  if newcount >0  then
  begin
    tray.BalloonTitle := '�� ��!';
    tray.BalloonHint  := '����� ���������: ' + IntToStr(newcount);
    tray.BalloonTimeout := 3;
    tray.BalloonFlags := bfInfo;
    tray.ShowBalloonHint;

    if (autopopup) then
      mainshow;
  end;
  _resize;
  _relocate;
  messages.Update;
end;

function Tmain.MegaplanPost(Uri: string; PostData: TIdMultiPartFormDataStream): string;
var
  DateRFC: string;
  sign, response: string;
  http: TIdHTTP;
  http_io: TIdSSLIOHandlerSocketOpenSSL;
  post_sl :TStringList;
begin
  http_io := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  http := TIdHTTP.Create(nil);
  http.IOHandler := http_io;

  //daterfc:= RFC2822Date(Now(), false);
  //sign:=MegaplanSignDebug('POST', '', 'application/x-www-form-urlencoded', DateRFC, config_host,Uri);

  daterfc:= 'Wed, 24 Jul 2013 12:59:45 +0700';
  sign:=MegaplanSignDebug('POST', '', 'application/x-www-form-urlencoded', DateRFC, config_host,Uri);

  http.Request.CustomHeaders.Clear;
  http.Request.CustomHeaders.AddValue('Date', daterfc);
  http.Request.CustomHeaders.AddValue('Accept', 'application/json');
  http.Request.CustomHeaders.AddValue('X-Authorization', megaplan_access_id+':'+sign);
  http.Request.CustomHeaders.AddValue('Content-Type', 'application/x-www-form-urlencoded');

  try
    try
      log.Lines.Add('POST HEADERS:');
      log.Lines.AddStrings(http.Request.CustomHeaders);
      log.Lines.Add('POST DATA:');
      post_sl:=TStringList.Create;
      post_sl.LoadFromStream(postdata);
      log.Lines.AddStrings(post_sl);
      post_sl.Free;
      log.Lines.Add('');

      response:=http.Post('https://'+config_host+uri, postdata);
    except
      on e:exception do
      begin
        debug(e.message);
        _offline;
      end;
    end;
  finally
    if assigned(http) then http.Free;
    if assigned(http_io) then http_io.Free;
  end;
  if (length(response)>0) then
    _online;

  if debug_results.Checked then debug(response);
end;

procedure Tmain.autoopenClick(Sender: TObject);
begin
  autopopup := TMenuItem(Sender).Checked;
  regWriteBool('autopopup', TMenuItem(sender).Checked);
end;

procedure Tmain.btn_refreshClick(Sender: TObject);
begin
  MessagesRefresh;
end;

procedure Tmain.debug(str: string);
begin
{$IFDEF DEBUG}
  log.lines.Add(str);
{$ENDIF}
end;

procedure Tmain.Dsjl1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tmain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  {$IFNDEF DEBUG}
  CanClose:=False;
  main.hide;
  {$endif}
end;

procedure Tmain.FormCreate(Sender: TObject);
begin
  timerenabled := false;
  messages.ColWidths[0]:=messages.Width-4;
  msg := TMessageHistory.Create;

  resize;
end;

procedure Tmain.FormShow(Sender: TObject);
begin
  resize;
  Left:=screen.WorkAreaWidth-width;
  Top:=screen.WorkAreaHeight-Height;
end;

procedure Tmain.mainshow;
begin
  resize;

  ShowWindow(main.Handle, SW_SHOWNOACTIVATE);
  main.Visible := True;
  main.BringToFront;
  //BringWindowToTop(Application.Handle);
  //ShowWindow(Application.MainForm.Handle, SW_RESTORE);
  //SetForegroundWindow(Main.Handle);
  _relocate;
end;

end.
