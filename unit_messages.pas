unit unit_messages;

interface
uses Classes, Generics.Collections, StdCtrls;

type
  TMessageSubject = record
    id    : longint;
    name  : string;
    ttype : string
  end;

  TMessageAuthor = record
    id   : longint;
    name : string;
  end;

  TMessageContent = record
    subject  : TMessageSubject;
    author   : TMessageAuthor;
    text     : string;
    roottext : string;
  end;

  PMessage = ^TMessage;
  TMessage = record
    id           : longint;
    name         : string;
    flag         : boolean;
    subject      : TMessageSubject;
    content      : TMessageContent;
    time_created : string;
  end;

  TMessageHistory = class
  public
    msg: TList<PMessage>;

    function Count: integer;

    Constructor Create;
    Destructor Destroy;

    function Find(id:longint): integer;
    function Parse(xmlstr: string): integer;
    function Dump: string;
  private

  end;


implementation

uses unit_main, MSXML, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils;

const b2s: array[boolean] of string = ('false', 'true');

Constructor TMessageHistory.Create;
begin
  msg := TList<PMessage>.Create;
end;

Destructor TMessageHistory.Destroy;
begin
  msg.Free;
end;

function TMessageHistory.Dump: string;
var m: PMessage;
begin
  result := '';
  for m in msg do
    begin
      result := result + '---' + #13#10;
      result := result + 'subject.id=' + IntToStr(m.subject.id) + #13#10;
      result := result + 'subject.name=' + m.subject.name + #13#10;
      result := result + 'subject.ttype=' + m.subject.ttype + #13#10;

      result := result + 'content.subject.id=' + IntToStr(m.content.subject.id) + #13#10;
      result := result + 'content.subject.name=' + m.content.subject.name + #13#10;
      result := result + 'content.subject.ttype=' + m.content.subject.ttype + #13#10;

      result := result + 'content.author.id=' + IntToStr(m.content.author.id) + #13#10;
      result := result + 'content.author.name=' + m.content.author.name + #13#10;

      result := result + 'content.text=' + m.content.text + #13#10;
      result := result + 'content.rottext=' + m.content.roottext + #13#10;
    end;
end;

function TMessageHistory.Find(id: longint): integer;
var m: TMessage;
    i:integer;
begin
  result := -1;
  try
    for I := 0 to msg.Count-1 do
    if msg.Items[i].id = id then
      result := i;
  except

  end;
end;

function TMessageHistory.Parse(xmlstr: string): integer;
var i  : integer;
  xml  : IXMLDocument;
  node : IXmlNode;
  row  : integer;
  count: integer;
  m    : PMessage;
begin
  //Pre parse count
  count := msg.Count;
  //Flag set to false. After parse, all elements withflag=false would be deleted
  for m in msg do
  begin
    m.flag:=false;
  end;

  xml := TXMLDocument.Create(nil);
  xml.LoadFromXML(xmlstr);

  //If gon an errornous answer
  try
    if xml.DocumentElement.ChildNodes['status'].ChildNodes['code'].text <> 'ok' then
      result:=-1;
  except
    result:=-1;
  end;
  if (result<0) then
    exit;

  for I := 0 to xml.DocumentElement.ChildNodes['data'].ChildNodes['notifications'].ChildNodes.Count - 1 do
  begin
    node := xml.DocumentElement.ChildNodes['data'].ChildNodes['notifications'].ChildNodes[I];
    row:=Find(StrToInt(node.ChildNodes['id'].text));

    //Acurate row selection
    if row <0 then
    begin
        m := New(PMessage);
        m.flag := true;
        m.id := 0;
        try
          //notification
          m.id   := StrToInt(node.ChildNodes['id'].text);
          m.name := node.ChildNodes['name'].text;
          m.time_created := node.ChildNodes['time_created'].text;

          m.subject.id   := StrToInt(node.ChildNodes['subject'].ChildNodes['id'].text);
          m.subject.name := node.ChildNodes['subject'].ChildNodes['name'].text;
          m.subject.ttype := node.ChildNodes['subject'].ChildNodes['type'].text;

          if (m.subject.ttype='comment') then
          begin
            m.content.subject.id   := StrToInt(node.ChildNodes['content'].ChildNodes['subject'].ChildNodes['id'].text);
            m.content.subject.name := node.ChildNodes['content'].ChildNodes['subject'].ChildNodes['name'].text;
            m.content.subject.ttype := node.ChildNodes['content'].ChildNodes['subject'].ChildNodes['type'].text;

            m.content.author.id   := StrToInt(node.ChildNodes['content'].ChildNodes['author'].ChildNodes['id'].text);
            m.content.author.name := node.ChildNodes['content'].ChildNodes['author'].ChildNodes['name'].text;

            m.content.text := node.ChildNodes['content'].ChildNodes['text'].text;
          end;

          if (m.subject.ttype='task') then
            m.content.roottext := node.ChildNodes['content'].text;

          if (m.subject.ttype='task') then
            m.content.roottext := node.ChildNodes['content'].text;
        except
          on e:exception do
            main.log.lines.add('error xml parse: '+e.Message);
        end;
        msg.Add(m);
    end
    else begin
      msg[row].flag := true;
    end;
  end;

  //If we have new messages
  if count < msg.count then
    result := msg.Count - count
  else
    result := 0;

  //Delete messages, if they was not in parse list
  i:=0;
  while i<msg.Count do
  begin
    if msg[i].flag=false then
    begin
      msg.Delete(i)
    end
    else
      inc(i);
  end;
end;

function mystrtoint(id: integer; str:string; log: tmemo): longint;
begin
  try
    result:=StrToInt(str);
  except
    on e:exception do
      log.Lines.Add('mystrtoint: '+inttostr(id)+' :'+e.message);

  end;
end;

function TMessageHistory.Count: integer;
begin
  result := msg.Count;
end;

end.
