unit Arcanoid;

interface
uses  WinTypes, WinProcs, Messages, Classes, Graphics, Controls, ExtCtrls, SysUtils, Math;
const Step=4;//��� ����������� ��������� (������)
const N=5;//���������� ������ �� �����������
const M=5;//���������� ������ �� ���������
type
  TNotifyEvent=procedure(Sender:TObject) of Object;
type TMyArcanoid=class(TGraphicControl)
  private
    ////��������� (�����)////
    FPlayerColor:TColor;//���� ��������� (������)
    FPlayerX:Integer;//���������� �������� ������ ���� ��������� (������) �� ��� X
    FPlayerY:Integer;//���������� �������� ������ ���� ��������� (������) �� ��� Y
    FPlayerWidth:Integer;//������ ��������� (������)
    FPlayerHeight:Integer;//������ ��������� (������)
    FOnMove: boolean;//�������� �������� ����
    /////////////////////////
    ///////////���///////////
    FBallColor:TColor;//���� ����
    FBallX:Real;//���������� ������ ���� �� ��� X
    FBallY:Integer;//���������� ������ ���� �� ��� Y
    FBallRadius:Integer;//������ ����
    FBallSpeedX:Real;//������ ���� ����������� ���� �� ��� X
    FBallSpeedY:Integer;//������ ���� ����������� ���� �� ��� Y
    /////////////////////////
    /////////������//////////
    FPlatformX:array [0..N-1] of Integer;//������ ��� �������� ������� ����� ���� ������ �� ��� X
    FPlatformY:array [0..N-1] of Integer;//������ ��� �������� ������� ����� ���� ������ �� ��� Y
    FPlatforms:array [0..N-1,0..M-1] of Boolean;//������ ��� �������� ���������� � ���, ����� �� ������������ ��������� ������ ��� ���
    FPlatformsColor:TColor;//���� ������
    /////////////////////////
    ////////�������//////////
    FScore:TNotifyEvent;
    /////////////////////////
    //////////������/////////
    FTimer: TTimer;
    /////////////////////////
  protected
    procedure Paint; override;//��������� ���������
    procedure WMLBttonDown(var M: Tmessage); message wm_LButtonDown;//������� �� ������ ����
    procedure WMLBttonUp(var M: Tmessage); message wm_LButtonUp;//������� ������ ����
    procedure WMMove(var M: TMessage); message WM_MOUSEMOVE;//����������� ����
    /////////////////���������(�����)//////////////////
    procedure SetPlayerX(Value: Integer); virtual;//������������ ����� ���������� �������� ������ ���� ��������� (������)
    procedure SetPlayerColor(Value: TColor); virtual;//��������� ����� ��������� (������)
    ///////////////////////////////////////////////////
    ///////////////////////���/////////////////////////
    procedure SetBallX(Value: Real); virtual;//������������ ����� ���������� ������ ���� �� ��� X
    procedure SetBallY(Value: Integer); virtual;//������������ ����� ���������� ������ ���� �� ��� Y
    procedure BallMove; virtual;//����������� ����*
    procedure SetBallColor(Value: TColor); virtual;//���� ����
    ///////////////////////////////////////////////////
    //////////////////////������///////////////////////
    function BallAndPlatformsConflict:Boolean; virtual;//������������ ������������ ���� � �������*
    procedure SetPlatformsColor(Value: TColor); virtual;//���� ������
    ///////////////////////////////////////////////////
    ////////////////////////����///////////////////////
    procedure StartPositionPlayer; virtual;//����������� ��������� (������) � �������� ���������
    function CountFalsePlatforms:Integer; virtual;//������� ������ ������
    ///////////////////////////////////////////////////
    //////////////////////������///////////////////////
    procedure DoTimer(Sender: TObject);
    destructor Destroy;
    ///////////////////////////////////////////////////
    /////////////////////�������///////////////////////
    procedure DoScore;
    ///////////////////////////////////////////////////
    constructor Create(AOwner: TComponent); override;//���������� ������������
  public
    //////////////////////������///////////////////////
    procedure StartArcanoid; virtual;
    ///////////////////////////////////////////////////
  published
    property PlayerColor: TColor read FPlayerColor write SetPlayerColor;
    property BallColor: TColor read FBallColor write SetBallColor;
    property PlatformsColor: TColor read FPlatformsColor write SetPlatformsColor;
    property Color;
    property Score: TNotifyEvent read FScore write FScore;
    property Count: Integer read CountFalsePlatforms;
end;

procedure Register;
implementation
///////////////////////////////////////////
constructor TMyArcanoid.Create(AOwner: TComponent);
var
  i,j:Integer;
begin
  inherited Create(AOwner);
  ControlStyle:=ControlStyle+[csFramed, csOpaque];
  Width:=300;//������ ����������� ����������
  Height:=400;//������ ����������� ����������
  Color:=clGreen;//���� ���� ����������� ����������
  /////���������(�����)////
  FPlayerColor:=clBlue;//���� ��������� (������)
  FPlayerX:=Width div 2 - 30;//��������� ���������� �������� ������ ���� ��������� (������) �� ��� X
  FPlayerY:=Height-50;//��������� ���������� �������� ������ ���� ��������� (������) �� ��� Y
  FPlayerWidth:=60;//������ ��������� (������)
  FPlayerHeight:=15;//������ ��������� (������)
  FOnMove:=False;
  /////////////////////////
  ///////////���///////////
  FBallColor:=clRed;//���� ����
  FBallX:=Width div 2;//��������� ���������� ������ ���� �� ��� X
  FBallY:=Height-60;//��������� ���������� ������ ���� �� ��� Y
  FBallRadius:=10;//������ ����
  FBallSpeedX:=0;//������ ���� ���������� ���� �� ��� X
  FBallSpeedY:=3;//������ ���� ���������� ���� �� ��� Y
  /////////////////////////
  /////////������//////////
  FPlatformsColor:=clYellow;//���� ������
  //���������� ������� ������� ����� ����� ����� �� ��� X//
  for i:=0 to N-1 do
  begin
    FPlatformX[i]:=i*FPlayerWidth;
  end;
  /////////////////////////////////////////////////////////
  //���������� ������� ������� ����� ����� ����� �� ��� Y//
  for i:=0 to M-1 do
  begin
    FPlatformY[i]:=i*FPlayerHeight;
  end;
  /////////////////////////////////////////////////////////
  //��������� � ���, ��� ��� ������ ������ ���� ����������/
  for i:=0 to M-1 do
  begin
    for j:=0 to N-1 do
    begin
      FPlatforms[i,j]:=true;
    end;
  end;
  /////////////////////////////////////////////////////////
  //////////������//////////
  FTimer:=TTimer.Create(nil);
  FTimer.Interval:=1;
  FTimer.OnTimer:=DoTimer;
  FTimer.Enabled:=False;
  /////////////////////////
end;
////////////////////////////////////////////////////
/////////////////���������(�����)///////////////////
procedure TMyArcanoid.SetPlayerX(Value:Integer);//������� ����� ���������� ���������
begin
  if (Value+FPlayerWidth>Width) then
  begin
    Value:=Width-FPlayerWidth;
  end else
  begin
    if (Value<0) then
    begin
      Value:=0;
    end;
  end;
  if (FPlayerX<>Value) then
  begin
      FPlayerX:=Value;
  end;
end;
procedure TMyArcanoid.WMLBttonDown(var M: Tmessage);//������� ������ ����
var Mes: TMessage;
begin
  if (FTimer.Enabled=True)and(((M.LParamLo>=FPlayerX)and(M.LParamLo<=FPlayerX+FPlayerWidth))and((M.LParamHi>=FPlayerY)and(M.LParamHi<=FPlayerY+FPlayerHeight))) then
  begin
    inherited;
    if (M.LParamLo<32768) then
    begin
      SetPlayerX(M.LParamLo-FPlayerWidth div 2);
    end else
    begin
      SetPlayerX(0);
    end;
    FOnMove:=True;
  end;
end;
procedure TMyArcanoid.WMLBttonUp(var M: Tmessage);//������� ������ ����
var Mes1: TMessage;
begin
  inherited;
  FOnMove:=False;
end;
procedure TMyArcanoid.WMMove(var M: TMessage);//����������� ����
begin
  if (FOnMove)and(FTimer.Enabled=True) then
  begin
    if (M.LParamLo<32768) then
    begin
      SetPlayerX(M.LParamLo-FPlayerWidth div 2);
    end else
    begin
      SetPlayerX(0);
    end;
  end;
end;
procedure TMyArcanoid.SetPlayerColor(Value: TColor);//��������� ����� ������
begin
  if (Value<>FPlayerColor) then
  begin
    FPlayerColor:=Value;
    Refresh;
  end;
end;
////////////////////////////////////////////////////
////////////////////////���/////////////////////////
procedure TMyArcanoid.SetBallX(Value:Real);//��������� ���������� ���� �� ��� X
begin
  if (FBallX<>Value) then
  begin
      FBallX:=Value;
      Refresh;
  end;
end;
procedure TMyArcanoid.SetBallY(Value:Integer);//��������� ���������� ���� �� ��� Y
begin
  if (FBallY<>Value) then
  begin
      FBallY:=Value;
      Refresh;
  end;
end;
procedure TMyArcanoid.BallMove;//����������� ����
begin
    if (FBallSpeedX<=0)and(FBallX-FBallRadius<=0) then//������������ � ����� �������
    begin
      FBallSpeedX:=FBallSpeedX*-1;
    end else
    begin
      if (FBallSpeedX>=0)and(FBallX+FBallRadius>=Width) then//������������ � ������ �������
      begin
        FBallSpeedX:=FBallSpeedX*-1;
      end;
    end;
    if (FBallY-FBallRadius<=0) then//������������ � ������� �������
    begin
      FBallSpeedY:=FBallSpeedY*-1;
    end else
    begin
      //������������ � ����������
      if (FBallSpeedY>0)and(FBallY+FBallRadius>=FPlayerY)and(FBallX+FBallRadius>=FPlayerX)and(FBallX-FBallRadius<=FPlayerX+FPlayerWidth)and(FBallY-FBallRadius<FPlayerY) then
      begin
        FBallSpeedY:=FBallSpeedY*-1;
        if (FBallX<FPlayerX+FPlayerWidth/2) then//����������� � ����� ������ ���������
        begin
          FBallSpeedX:=(((FPlayerX+FPlayerWidth/2)-FBallX)/10)*-1;
        end else
        begin
          FBallSpeedX:=(FBallX-(FPlayerX+FPlayerWidth/2))/10;//����������� � ������ ������ ���������
        end;
      end;
    end;
    FBallX:=FBallX+FBallSpeedX;
    SetBallX(FBallX);
    SetBallY(FBallY+FBallSpeedY);
end;
procedure TMyArcanoid.SetBallColor(Value: TColor);//��������� ����� ����
begin
  if (Value<>FBallColor) then
  begin
    FBallColor:=Value;
    Refresh;
  end;
end;
////////////////////////////////////////////////////
///////////////////////������///////////////////////
function TMyArcanoid.BallAndPlatformsConflict:Boolean;//������������ ���� � �������
var
  i,j:Integer;
begin
  for i:=0 to M-1 do
  begin
    for j:=0 to N-1 do
    begin
      if (FPlatforms[i,j]=True) then
      begin
        //������������ � ������ ������
        if (FBallSpeedY<0)and(FBallX>=FPlatformX[j])and(FBallX<=FPlatformX[j]+FPlayerWidth)and(FBallY-FBallRadius<=FPlatformY[i]+FPlayerHeight)and(FBallY+FBallRadius>FPlatformY[i]+FPlayerHeight) then
        begin
          FBallSpeedY:=FBallSpeedY*-1;
          FPlatforms[i,j]:=False;
          Result:=True;
        end else
        begin
          //������������ � ������� ������
          if (FBallSpeedY>0)and(FBallX>=FPlatformX[j])and(FBallX<=FPlatformX[j]+FPlayerWidth)and(FBallY+FBallRadius>=FPlatformY[i])and(FBallY-FBallRadius<FPlatformY[i]) then
          begin
            FBallSpeedY:=FBallSpeedY*-1;
            FPlatforms[i,j]:=False;
            Result:=True;
          end;
        end;
        //������������ � ������ ������
        if (FBallSpeedX<0)and(FBallY<=FPlatformY[i]+FPlayerHeight)and(FBallY>=FPlatformY[i])and(FBallX-FBallRadius<=FPlatformX[j]+FPlayerWidth)and(FBallX+FBallRadius>FPlatformX[j]+FPlayerWidth) then
        begin
          if (FBallSpeedX>=0)and(FBallSpeedX<=0.9) then
          begin
            FBallSpeedY:=FBallSpeedY*-1;
          end;
          FBallSpeedX:=FBallSpeedX*-1;
          FPlatforms[i,j]:=False;
          Result:=True;
        end else
        begin
          //������������ � ����� ������
          if (FBallSpeedX>0)and(FBallY<=FPlatformY[i]+FPlayerHeight)and(FBallY>=FPlatformY[i])and(FBallX+FBallRadius>=FPlatformX[j])and(FBallX-FBallRadius<FPlatformX[j]) then
          begin
            if (FBallSpeedX>=0)and(FBallSpeedX<=0.9) then
            begin
              FBallSpeedY:=FBallSpeedY*-1;
            end;
            FBallSpeedX:=FBallSpeedX*-1;
            FPlatforms[i,j]:=False;
            Result:=True;
          end;
        end;
      end;
    end;
  end;
end;
procedure TMyArcanoid.SetPlatformsColor(Value: TColor);//��������� ����� ������
begin
  if (Value<>FPlatformsColor) then
  begin
    FPlatformsColor:=Value;
    Refresh;
  end;
end;
////////////////////////////////////////////////////
////////////////////////����////////////////////////
procedure TMyArcanoid.StartPositionPlayer;//����������� ������� ��������� � ��������� ���������
var
  i,j:integer;
begin
    FPlayerX:=Width div 2 - 30;
    FPlayerY:=Height-50;
    FBallX:=Width/2;
    FBallY:=Height-60;
    FBallSpeedX:=0;
    for i:=0 to M-1 do
    begin
      for j:=0 to N-1 do
      begin
        FPlatforms[i,j]:=True;
      end;
    end;
end;
function TMyArcanoid.CountFalsePlatforms:Integer;//������� ������ ������
var
  i,j,count:integer;
begin
  count:=0;
  for i:=0 to M-1 do
  begin
    for j:=0 to N-1 do
    begin
      if (FPlatforms[i,j]=False) then
      begin
        count:=count+1;
      end;
    end;
  end;
  Result:=count;
end;
////////////////////////////////////////////////////
//////////////////////������////////////////////////
destructor TMyArcanoid.Destroy;//���������� �������
begin
   FTimer.Free;
   inherited;
end;
procedure TMyArcanoid.StartArcanoid;//������ ����
begin
  FTimer.Enabled:=True;
  DoScore;
end;
procedure TMyArcanoid.DoTimer(Sender: TObject);//������
begin
  BallMove;//����������� ����
  //////////////�������� ������������///////////////
  if (BallAndPlatformsConflict=True) then
  begin
    CountFalsePlatforms;
    DoScore;
  end;
  //////////////////////////////////////////////////
  ////////////////�������� ���������////////////////
  if (FBallY+FBallRadius>=Height) then
  begin
    StartPositionPlayer;
    FTimer.Enabled:=False;
  end;
  //////////////////////////////////////////////////
  ////////////////�������� ��������////////////////
  if (CountFalsePlatforms=25) then
  begin
    StartPositionPlayer;
    FTimer.Enabled:=False;
  end;
  //////////////////////////////////////////////////
end;
////////////////////////////////////////////////////
/////////////////////�������////////////////////////
procedure TMyArcanoid.DoScore;
begin
  if Assigned(FScore) then
  begin
    FScore(Self);
  end;
end;
////////////////////////////////////////////////////
////////////////////���������///////////////////////
procedure TMyArcanoid.Paint;
var
  Image: TBitmap;
  i,j:Integer;
begin
   Image:= TBitmap.Create;
    try
      Image.Width:=Width;
      Image.Height:=Height;
      with Image.Canvas do
      begin
        Brush.Color:=Color;
        FillRect(ClientRect);
        Brush.Color:=FPlayerColor;
        Rectangle(FPlayerX,FPlayerY,FPlayerX+FPlayerWidth,FPlayerY+FPlayerHeight);
        Brush.Color:=FBallColor;
        Ellipse(Round(FBallX-FBallRadius),FBallY-FBallRadius,Round(FBallX+FBallRadius),FBallY+FBallRadius);
        Brush.Color:=FPlatformsColor;
        for i:=0 to M-1 do
        begin
          for j:=0 to N-1 do
          begin
            if (FPlatforms[i,j]=true) then
            begin
              Rectangle(FPlatformX[j],FPlatformY[i],FPlatformX[j]+FPlayerWidth,FPlatformY[i]+FPlayerHeight);
            end;
          end;
        end;
      end;
      Canvas.CopyRect(ClientRect, Image.Canvas, ClientRect);
    finally
      Image.Free;
    end;
end;
///////////////////////////////////////////
procedure Register;
begin
   RegisterComponents('Test', [TMyArcanoid]);
end;
end.
