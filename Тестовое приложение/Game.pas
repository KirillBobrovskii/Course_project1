unit Game;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Arcanoid, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label3: TLabel;
    ComboBox1: TComboBox;
    Label4: TLabel;
    ComboBox2: TComboBox;
    Label5: TLabel;
    ComboBox3: TComboBox;
    Label6: TLabel;
    ComboBox4: TComboBox;
    Label1: TLabel;
    MyArcanoid1: TMyArcanoid;
    procedure Label1Click(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Colors:array [0..7] of TColor;
implementation

{$R *.dfm}
/////////////������ ������� ����////////////////
procedure TForm1.Button1Click(Sender: TObject);
begin
  MyArcanoid1.StartArcanoid;
end;
//////////////////////////////////////////////////

///////////////����� ����� ������/////////////////
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  MyArcanoid1.PlayerColor:=Colors[Combobox1.ItemIndex];
end;
//////////////////////////////////////////////////

////////////////����� ����� ����//////////////////
procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  MyArcanoid1.BallColor:=Colors[Combobox2.ItemIndex];
end;
//////////////////////////////////////////////////

///////////////����� ����� ������/////////////////
procedure TForm1.ComboBox3Change(Sender: TObject);
begin
  MyArcanoid1.PlatformsColor:=Colors[Combobox3.ItemIndex];
end;
///////////////////////////////////////////////////

/////////////////����� ����� ����//////////////////
procedure TForm1.ComboBox4Change(Sender: TObject);
begin
  MyArcanoid1.Color:=Colors[Combobox4.ItemIndex];
end;
//////////////////////////////////////////////////

//////////��������� ������� �����������///////////
procedure TForm1.FormCreate(Sender: TObject);
begin
  Colors[0]:=clRed; Colors[1]:=clYellow; Colors[2]:=clGreen; Colors[3]:=clBlue;
  Colors[4]:=clPurple; Colors[5]:=clGray; Colors[6]:=clBlack; Colors[7]:=clWhite;
end;
procedure TForm1.Label1Click(Sender: TObject);
begin
  Label1.Caption:='����:'+IntToStr(MyArcanoid1.Count);
end;

//////////////////////////////////////////////////

end.
