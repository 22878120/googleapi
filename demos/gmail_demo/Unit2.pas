<<<<<<< HEAD:demos/gmail_demo/Unit2.pas
unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, GMailSMTP;

type
  TForm2 = class(TForm)
    Label7: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label8: TLabel;
    ListBox2: TListBox;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    GMailSMTP1: TGMailSMTP;
    Label1: TLabel;
    Edit1: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    Edit2: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    Edit3: TEdit;
    btn1: TButton;
    btn2: TButton;
    lbl5: TLabel;
    Edit4: TEdit;
    lbl6: TLabel;
    Edit5: TEdit;
    chk1: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.btn1Click(Sender: TObject);
begin
if OpenDialog1.Execute then
  begin
    ListBox2.Items.Add(OpenDialog1.FileName);
    GMailSMTP1.AttachFiles.Add(OpenDialog1.FileName);
    ShowMessage('����� ���� �������� � ���������');
  end;
end;

procedure TForm2.btn2Click(Sender: TObject);
begin
if ListBox2.ItemIndex>0 then
  begin
    GMailSMTP1.AttachFiles.Delete(ListBox2.ItemIndex);
    ListBox2.Items.Delete(ListBox2.ItemIndex);
    ShowMessage('���� ������ �� ���������');
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  GMailSMTP1.AddText(Memo1.Text);
  Memo1.Lines.Clear;
  ShowMessage('�������� ��������� ������� ��������');
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  GMailSMTP1.AddHTML(Memo1.Text);
  Memo1.Lines.Clear;
  ShowMessage('�������� ��������� ������� ��������');
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
GMailSMTP1.Login:=Edit4.Text;
GMailSMTP1.Password:=Edit5.Text;
GMailSMTP1.FromEmail:=Edit1.Text;
GMailSMTP1.Recipients.Clear;
GMailSMTP1.Recipients.Add(Edit2.Text);
if GMailSMTP1.SendMessage(Edit3.Text, chk1.Checked) then
  ShowMessage('������ ����������')
else
  ShowMessage('�������� �� �������')
end;

end.
=======
unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, GMailSMTP;

type
  TForm2 = class(TForm)
    Label7: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label8: TLabel;
    ListBox2: TListBox;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    GMailSMTP1: TGMailSMTP;
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  GMailSMTP1.AddText(Memo1.Text);
  Memo1.Lines.Clear;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  GMailSMTP1.AddHTML(Memo1.Text);
  Memo1.Lines.Clear;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
GMailSMTP1.SendMessage('Test', false);
end;

procedure TForm2.N3Click(Sender: TObject);
begin
if OpenDialog1.Execute then
  begin
    ListBox2.Items.Add(OpenDialog1.FileName);
    GMailSMTP1.AttachFiles.Add(OpenDialog1.FileName)
  end;
end;

procedure TForm2.N4Click(Sender: TObject);
begin
if ListBox2.ItemIndex>0 then
  begin
    GMailSMTP1.AttachFiles.Delete(ListBox2.ItemIndex);
    ListBox2.Items.Delete(ListBox2.ItemIndex);
  end;
end;

end.
>>>>>>> remotes/origin/NMD:demos/gmail/Unit2.pas
