object login: Tlogin
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1042#1093#1086#1076
  ClientHeight = 271
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 8
    Top = 8
    Width = 225
    Height = 249
  end
  object edit_host: TLabeledEdit
    Left = 24
    Top = 40
    Width = 200
    Height = 27
    Alignment = taCenter
    EditLabel.Width = 170
    EditLabel.Height = 23
    EditLabel.Caption = #1040#1076#1088#1077#1089' '#1074' '#1052#1077#1075#1072#1087#1083#1072#1085#1077
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -19
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnKeyPress = edit_hostKeyPress
  end
  object edit_user: TLabeledEdit
    Left = 24
    Top = 104
    Width = 200
    Height = 27
    Alignment = taCenter
    EditLabel.Width = 123
    EditLabel.Height = 23
    EditLabel.Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -19
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnKeyPress = edit_hostKeyPress
  end
  object edit_pass: TLabeledEdit
    Left = 24
    Top = 168
    Width = 200
    Height = 27
    Alignment = taCenter
    EditLabel.Width = 65
    EditLabel.Height = 23
    EditLabel.Caption = #1055#1072#1088#1086#1083#1100
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -19
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 2
    OnKeyPress = edit_hostKeyPress
  end
  object btn_login: TButton
    Left = 56
    Top = 227
    Width = 123
    Height = 25
    Caption = #1042#1086#1081#1090#1080
    ModalResult = 1
    TabOrder = 3
    OnClick = btn_loginClick
  end
  object auto: TCheckBox
    Left = 82
    Top = 201
    Width = 97
    Height = 17
    Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080
    TabOrder = 4
    OnClick = autoClick
  end
  object timer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = timerTimer
    Left = 192
    Top = 208
  end
end
