unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, CPort, Vcl.StdCtrls,
  VCLTee.TeEngine, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series,
  VCLTee.TeeSpline, Vcl.Samples.Spin, Math;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComPort1: TComPort;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    Button3: TButton;
    Lhiz: TLabel;
    Lyon: TLabel;
    dogrultu: TRadioButton;
    acisal: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OnRxChar(Sender: TObject; Count: Integer);
    procedure Paint(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure acisalClick(Sender: TObject);
    



  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
const
CenterX:integer=250;
CenterY:integer=280;

var
ileri:bool=True;
uzaklik:integer;
onceki:integer;
X:integer=250;
Y:integer=250;
MoveToX:integer=250;
MoveToY:integer=250;
aci:integer=0;
radar:bool=True;

//function NumaraAyir(str:string):string;
//var
//a:char;
//begin
//  for a in str do
//  if a in ['0'..'9'] then
//  Result:= Result + a;
//end;



procedure TForm1.acisalClick(Sender: TObject);
begin
PaintBox1.Invalidate;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
ComPort1.ShowSetupDialog;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
if ComPort1.Connected then
begin
ComPort1.Close;
Label1.Visible:=False;
Button2.Caption:= 'Ac';
end
else
begin
ComPort1.Open;
Label1.Visible:=True;
Button2.Caption:= 'Kapat';
aci:=0;
ileri:=True;
radar:= True;
ComPort1.WriteStr('190');
end;
end;



procedure TForm1.Button3Click(Sender: TObject);
begin
if radar then
begin
  aci:= SpinEdit1.Value;
  radar:= False;
  Button3.Caption:= 'Radar';
  ComPort1.WriteStr(IntToStr(aci));
  Lhiz.Visible:=True;
  Lyon.Visible:= True;
  SpinEdit1.Enabled:= False;
end
else
begin
  aci:=-10;
  radar:= True;
  ileri:= True;
  Button3.Caption:= 'Hýz Ölç';
  ComPort1.WriteStr('190');
  Lhiz.Visible:=False;
  Lyon.Visible:= False;
  SpinEdit1.Enabled:=True;
end;
end;

procedure TForm1.OnRxChar(Sender: TObject; Count: Integer);
const
sure:double=0.10;

var
str:string;
yon:string;
hiz:double;

begin
ComPort1.ReadStr(str,Count);
str:= str.Trim;
uzaklik:= StrToInt(str);
if uzaklik > 200 then
uzaklik:=200;

if radar then
begin

  if ileri then
    begin
     aci:=aci+10;
    if aci=190 then
      begin
     aci:=180;
     ileri:=False;
     end;
   end
  else
  begin
    aci:=aci-10;
    if aci=-10 then
     begin
       aci:=0;
       ileri:=True;
     end;
  end;
end
else
begin

 hiz:= (uzaklik - onceki) / sure ;
 onceki:= uzaklik;
 hiz:= hiz / Power(10,2);
 if hiz >0 then
 begin
   yon:= 'uzaklasiyor ';
 end else if hiz < 0 then
 begin
  yon:= 'yakinlasiyor ';
 end else yon:= '';
 hiz:= abs(hiz);
 Lyon.Caption:= yon;
 Lhiz.Caption:=FloatToStr(hiz) + ' m/s';
end;

if dogrultu.Checked then
begin
PaintBox1.Invalidate;
X:=Round(Cos(aci*pi/180)*uzaklik)+CenterX;
Y:=Round(-Sin(aci*pi/180)*uzaklik)+CenterY;
MoveToX:= CenterX;
MoveToY:= CenterY;

end else

begin
X:=Round(Cos((aci+5)*pi/180)*uzaklik)+CenterX;
Y:=Round(-Sin((aci+5)*pi/180)*uzaklik)+CenterY;
MoveToX:=Round(Cos((aci-5)*pi/180)*uzaklik)+CenterX;
MoveToY:=Round(-Sin((aci-5)*pi/180)*uzaklik)+CenterY;
if (aci =180) or (aci =0) then PaintBox1.Invalidate;
if radar = false then PaintBox1.Invalidate;

end;

Label1.Left:= Round(Cos(aci*pi/180)*240)+250;
Label1.Top:= Round(-Sin(aci*pi/180)*240)+265;
Label1.Caption:= IntToStr(uzaklik);
Label2.Caption:= IntToStr(aci) + ' °';
Paint(Sender);
end;



procedure TForm1.Paint(Sender: TObject);

begin
PaintBox1.Canvas.Pen.Width:=3;
PaintBox1.Canvas.MoveTo(MoveToX,MoveToY);
PaintBox1.Canvas.LineTo(X,Y);
end;


end.
