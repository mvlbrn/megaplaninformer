unit unit_utils;

interface
uses classes;
type
  TByteArr = array of byte;
  TStringArr = array of String;

  function RFC2822Date(const LocalDate: TDateTime; const IsDST: Boolean): string;
  function md5(s: string): string;
  function bintostr(const bin: array of byte): string;

  procedure regWriteString(key:string; value:string);
  procedure regWriteBool(key:string; value:boolean);
  procedure regWriteInt(key:string; value:integer);
  function regReadString(key: string; default: string = ''): string;
  function regReadBool(key: string; default: Boolean = false): boolean;
  function regReadInt(key: string; default: Integer = -1): Integer;
  function Explode(separator: String; text: String): TStringList;
  function DoubleExplode(separator, separator2: String; text: String): TStringList;
  function ExplodeToArray(separator: String; text: String): TStringArr;
implementation

uses IdHashMessageDigest, Windows, SysUtils, Variants, Registry;

const
  reg_path = 'SOFTWARE\Megainformer';

function bintostr(const bin: array of byte): string;
const HexSymbols = '0123456789ABCDEF';
var i: integer;
begin
  SetLength(Result, 2*Length(bin));
  for i :=  0 to Length(bin)-1 do begin
    Result[1 + 2*i + 0] := HexSymbols[1 + bin[i] shr 4];
    Result[1 + 2*i + 1] := HexSymbols[1 + bin[i] and $0F];
  end;
  Result := lowercase(result);
end;

function RFC2822Date(const LocalDate: TDateTime; const IsDST: Boolean): string;
const
  // Days of week and months of year: must be in English for RFC882
  Days: array[1..7] of string = (
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  );
  Months: array[1..12] of string = (
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  );
var
  Day, Month, Year: Word;             // parts of LocalDate
  TZ : Windows.TIME_ZONE_INFORMATION; // time zone information
  Bias: Integer;                      // bias in seconds
  BiasTime: TDateTime;                // bias in hrs / mins to display
  GMTOffset: string;                  // bias as offset from GMT
begin
  // get year, month and day from date
  SysUtils.DecodeDate(LocalDate, Year, Month, Day);
  // compute GMT Offset bias
  Windows.GetTimeZoneInformation(TZ);
  Bias := TZ.Bias;
  if IsDST then
    Bias := Bias + TZ.DaylightBias
  else
    Bias := Bias + TZ.StandardBias;
  BiasTime := SysUtils.EncodeTime(Abs(Bias div 60), Abs(Bias mod 60), 0, 0);
  if Bias < 0 then
    GMTOffset := '+' + SysUtils.FormatDateTime('hhnn', BiasTime)
  else
    GMTOffset := '-' + SysUtils.FormatDateTime('hhnn', BiasTime);
  // build final string
  Result := Days[DayOfWeek(LocalDate)] + ', '
    + SysUtils.IntToStr(Day) + ' '
    + Months[Month] + ' '
    + SysUtils.IntToStr(Year) + ' '
    + SysUtils.FormatDateTime('hh:nn:ss', LocalDate) + ' '
    + GMTOffset;
end;

function md5(s: string): string;
begin
  Result := '';
  with TIdHashMessageDigest5.Create do
  try
    Result := LowerCase(HashStringAsHex(s));
    //AnsiLowerCase(AsHex(HashValue(s)));
  finally
    Free;
  end;
end;

procedure regWriteString(key:string; value:string);
var Reg: TRegistry;
begin
   Reg:= TRegistry.Create;
   try
     Reg.RootKey := HKEY_CURRENT_USER;
     if Reg.OpenKey(reg_path, TRUE) then
     begin
       Reg.WriteString(key, value);
     end;
   finally
     Reg.Free;
   end;
end;

procedure regWriteBool(key:string; value:boolean);
var Reg: TRegistry;
begin
   Reg:= TRegistry.Create;
   try
     Reg.RootKey := HKEY_CURRENT_USER;
     if Reg.OpenKey(reg_path, TRUE) then
     begin
       Reg.WriteBool(key, value);
     end;
   finally
     Reg.Free;
   end;
end;

procedure regWriteInt(key:string; value:integer);
var Reg: TRegistry;
begin
   Reg:= TRegistry.Create;
   try
     Reg.RootKey := HKEY_CURRENT_USER;
     if Reg.OpenKey(reg_path, TRUE) then
     begin
       Reg.WriteInteger(key, value);
     end;
   finally
     Reg.Free;
   end;
end;


function regReadString(key: string; default: string = ''): string;
var Reg: TRegistry;
begin
  Result:=default;
  Reg:= TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(reg_path, TRUE) then
      begin
        if Reg.ValueExists(key) then
          Result:= Reg.ReadString(key);
      end;
    finally
    Reg.Free;
    end;
end;

function regReadBool(key: string; default: Boolean = false): boolean;
var Reg: TRegistry;
begin
  Result:=default;
  Reg:= TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(reg_path, TRUE) then
      begin
        if Reg.ValueExists(key) then
          Result:= Reg.ReadBool(key);
      end;
    finally
    Reg.Free;
    end;
end;

function regReadInt(key: string; default: Integer = -1): Integer;
var Reg: TRegistry;
begin
  Result:=default;
  Reg:= TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(reg_path, TRUE) then
      begin
        if Reg.ValueExists(key) then
          Result:= Reg.ReadInteger(key);
      end;
    finally
    Reg.Free;
    end;
end;

function Explode(separator: String; text: String): TStringList;
var
  ts: TStringList;
  i_pos: Integer;
  text_new: String;
  s_item: String;
begin
  ts := TStringList.Create;
  text_new := text;
  while (text_new <> '') do begin
    i_pos := Pos(separator, text_new);
    if i_pos = 0 then begin
      s_item := text_new;
      text_new := '';
    end
    else begin
      s_item := Copy(text_new, 1, i_pos - 1);
      text_new := Copy(text_new, i_pos + Length(separator), Length(text_new) - i_pos);
    end;
    ts.Values[IntToStr(ts.Count)] := Trim(s_item);
  end;
  Result := ts;
end;

function ExplodeToArray(separator: String; text: String): TStringArr;
var
  a:TStringArr;
  i_pos: Integer;
  text_new: String;
  s_item: String;
  num: integer;
begin
  num:=0;
  text_new := text;
  while (text_new <> '') do begin
    i_pos := Pos(separator, text_new);
    if i_pos = 0 then begin
      s_item := text_new;
      text_new := '';
    end
    else begin
      s_item := Copy(text_new, 1, i_pos - 1);
      text_new := Copy(text_new, i_pos + Length(separator), Length(text_new) - i_pos);
    end;
    inc(num);
    SetLength(a, num);
    a[num-1] := Trim(s_item);
  end;
  Result := a;
end;


function DoubleExplode(separator, separator2: String; text: String): TStringList;
var
  ts: TStringList;
  i_pos: Integer;
  text_new: String;
  s_item: String;
begin
  try
    ts := TStringList.Create;
    text_new := text;
    while (text_new <> '') do begin
      i_pos := Pos(separator, text_new);
      if i_pos = 0 then begin
        s_item := text_new;
        text_new := '';
      end
      else begin
        s_item := Copy(text_new, 1, i_pos - 1);
        text_new := Copy(text_new, i_pos + Length(separator), Length(text_new) - i_pos);
      end;
      ts.Values[Trim(Copy(s_item, 1, Pos(separator2, s_item)-1))] := Trim(Copy(s_item, Pos(separator2,s_item)+length(separator2), Length(s_item)));
    end;
  except
    ts.Free;
    ts := nil
  end;

  Result := ts;
end;

end.
