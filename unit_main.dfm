object main: Tmain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #1052#1077#1075#1072#1080#1085#1092#1086#1088#1084#1077#1088
  ClientHeight = 632
  ClientWidth = 571
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object log: TMemo
    Left = 1
    Top = 391
    Width = 568
    Height = 242
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object messages: TStringGrid
    Left = 1
    Top = 2
    Width = 568
    Height = 356
    ColCount = 1
    DefaultColWidth = 128
    DefaultRowHeight = 60
    DoubleBuffered = True
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine]
    ParentDoubleBuffered = False
    ScrollBars = ssVertical
    TabOrder = 1
    OnDblClick = messagesDblClick
    OnDrawCell = messagesDrawCell
    OnKeyPress = messagesKeyPress
    OnMouseDown = messagesMouseDown
  end
  object btn_refresh: TButton
    Left = 8
    Top = 364
    Width = 75
    Height = 25
    Caption = 'btn_refresh'
    TabOrder = 2
    OnClick = btn_refreshClick
  end
  object debug_results: TCheckBox
    Left = 472
    Top = 368
    Width = 97
    Height = 17
    Caption = 'Debug results'
    TabOrder = 3
  end
  object http: TIdHTTP
    IOHandler = ssl
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.CharSet = 'UTF-8'
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Megainformer/0.1 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    CookieManager = cookie
    Left = 8
    Top = 400
  end
  object cookie: TIdCookieManager
    Left = 48
    Top = 400
  end
  object ssl: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 88
    Top = 400
  end
  object xml: TXMLDocument
    Options = [doNodeAutoCreate, doNodeAutoIndent, doAttrNull, doAutoPrefix, doNamespaceDecl]
    Left = 128
    Top = 400
    DOMVendorDesc = 'MSXML'
  end
  object tray: TTrayIcon
    BalloonFlags = bfError
    Icon.Data = {
      0000010001001010000001002000680400001600000028000000100000002000
      0000010020000000000000040000000000000000000000000000000000000000
      0002000000030000000400000005000000050000000500000005000000040000
      0004000000020000000200000002000000010000000100000001000000000000
      00040000000B0000000D000000100000001000000010000000110000000E0000
      0008000000050000000400000003000000020000000200000001000000010000
      00070000002A0000004700000050000000500000005200000050000000460000
      00310000001A0000000E00000008000000040000000300000002000000010000
      000400C0837800BA7EA700B67DD500B97FDF00B87EE000B97FDF00A572C2020D
      095D000000460000002F0000001D0000000E0000000900000004000000020000
      00043FB88E3A66CCA8B687D5BAF092DBC3FD94DDC5FF93DCC4FE89D5BDF76E98
      8CB60000005B0000004C0000003600000021000000110000000A000000050000
      000800000014BDC1C19CE5EAEBFFE4E9EBFFE4E9EBFFE4E9EBFFE4E9EBFFE1E6
      E8FFA6ABAEBD292A2B460000002B0000001C0000001000000009000000050000
      000E000000194142423BDADCDFF1E6EBECFFE6EBEDFFE4E9EBFFE4E9EBFFE4E9
      EBFFE4E9EBFFC4C9CCD6484A4C28000000110000000B00000007000000040000
      0009000000107B7E8259C0C0C3E8C8C8CAEADBDDDEF5EBEEEFFDE8ECEEFFE5E9
      EBFFE4E9EBFFE4E9EBFFC8CDD1D79DA3A7370000000500000003000000020000
      0003C1C3C786E3E3E7FFEEEDF1FFE8E7E9F9DEDDDFF1CFCED0E8D3D3D5ECE9EB
      EDF9EBEFF0FFE6EBEDFFE4E9EBFFD4D9DCEFA4AAB0370000000100000001CACC
      D075EDECEFFFF0EFF2FFF0EFF2FFF0EFF2FFF0EFF2FFF1F0F3FFECEBEEFDE1E0
      E3F3DEDEDFF1E7E8EAF5EBEEF0FDE8ECEEFFD5DADDF4BAC0C461000000000000
      0001F2F1F39FF2F1F3FFF1F0F3FFF1F0F3FFF1F0F3FFF0EFF2FFF0EFF2FFF0EF
      F2FFF0EFF2FFEEEDF1FFE7E7E9F9ECEDEEF9F0F3F4FFE2E6E8FFBEC4C8740000
      000000000000F4F4F680F4F4F6FFF4F3F6FFF4F3F5FFF3F3F5FFF3F2F5FFF3F2
      F4FFF2F1F4FFF2F1F4FFF1F1F3FFF1F0F3FFF2F1F4FFF3F3F5FFF1F2F4FF0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000C0FF0000C07F0000C03F0000E01F0000E00F00008007
      00008003000080010000C0000000FFFF0000FFFF0000FFFF0000FFFF0000}
    PopupMenu = popup_tray
    Visible = True
    OnDblClick = trayDblClick
    Left = 512
    Top = 400
  end
  object popup_tray: TPopupMenu
    Left = 464
    Top = 400
    object N2: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      OnClick = N2Click
    end
    object autoopen: TMenuItem
      AutoCheck = True
      Caption = #1040#1074#1090#1086#1086#1090#1082#1088#1099#1090#1080#1077
      OnClick = autoopenClick
    end
    object Dsjl1: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      OnClick = Dsjl1Click
    end
  end
  object timer: TTimer
    Interval = 30000
    OnTimer = timerTimer
    Left = 416
    Top = 400
  end
  object popup_messages: TPopupMenu
    Left = 352
    Top = 400
    object MenuItem1: TMenuItem
      Caption = #1042' '#1087#1088#1086#1095#1080#1090#1072#1085#1085#1099#1077
      OnClick = MenuItem1Click
    end
    object N1: TMenuItem
      Caption = #1055#1086#1084#1077#1090#1080#1090#1100' '#1074#1089#1077' '#1082#1072#1082' '#1087#1088#1086#1095#1080#1090#1072#1085#1085#1099#1077
      OnClick = N1Click
    end
  end
end
