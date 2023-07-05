{

Fonte original disponível em https://pastebin.com/uhn24hbm

05.07.2023 - João B. S. Junior
             Whatsapp (69) 9 9250-3445

05.07.2023 - Adicionado propriedade de mudança de cor da borda ao dar foco em qualquer controle filho do panel

05.07.2023 - Doações PIX Chave Email jr.playsoft@gmail.com
}

unit UPanelBorderColor;

interface

uses

  Windows,
  Messages,
  SysUtils,
  Classes,
  VCL.Graphics,
  VCL.ExtCtrls,
  VCL.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Direct2D,
  D2D1;

type

  TDestAlign = (alNone, alTop, alBottom, alLeft, alRight, alLeftRight, alTopBottom);

  TPanelBorderColor = class(VCL.ExtCtrls.TPanel)
    private
      FD2DCanvas: TDirect2DCanvas;
      FRadiusX : Integer;
      FRadiusY : Integer;
      FColor : TColor;
      xFBorderColor    : TColor;
      FBorderColorFoco : TColor;
      FBorderFocoActive: Boolean;
      FBorderColor     : TColor;
      FBorderVisible   : Boolean;
      FColorBackGround : TColor;
      FDestWidth : Integer;
      FDestVisible : Boolean;
      FPenWidth : Integer;
      FExStyle : DWORD;
      FDestAlign : TDestAlign;

      procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
      procedure CMExit(var Message: TCMExit); message CM_EXIT;

      procedure PaintBorder;
      procedure SetBorderColor(const Value: TColor);
      procedure SetBorderColorFoco(const Value: TColor);
      procedure SetPenWidth(const Value: Integer);
      procedure SetRadiusX(const Value: Integer);
      procedure SetRadiusY(const Value: Integer);
      procedure SetColorBackGround(const Value: TColor);
      procedure SetColor(const Value: TColor);
      procedure SetDestWidth(const Value: Integer);
      procedure SetDestVisible(const Value: Boolean);
      procedure SetBorderVisible(const Value: Boolean);
      procedure SetDestAlign(const Value: TDestAlign);
      function ContainsFocus(Control: TWinControl): Boolean;
      procedure SetBorderFocoActive(const Value: Boolean);



    protected
      procedure CreateParams(var Params : TCreateParams); override;
      procedure CreateWnd; override;
      procedure WMSize(var Message: TWMSize); message WM_SIZE;
      procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
      procedure CMMouseEnter(var Msg: TMessage); message CM_MouseEnter;
      procedure CMMouseLeave(var Msg: TMessage); message CM_MouseLeave;
      procedure WM_NCPaint(var Message : TWMNCPaint); message WM_NCPaint;
      procedure Paint; override;
      procedure UpdatePanelColor;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
    published
      property BorderRadiusX : Integer read FRadiusX write SetRadiusX;
      property BorderRadiusY : Integer read FRadiusY write SetRadiusY;
      property BorderColor : TColor read FBorderColor write SetBorderColor;
      property BorderColorFoco : TColor read FBorderColorFoco write SetBorderColorFoco;
      property BorderVisible : Boolean read FBorderVisible write SetBorderVisible;
      property BorderFocoActive : Boolean read FBorderFocoActive write SetBorderFocoActive;

      property Color : TColor read FColor write SetColor;
      property ColorBackGround : TColor read FColorBackGround write SetColorBackGround;
      property BorderPenWidth : Integer read FPenWidth write SetPenWidth;
      property DestWidth : Integer read FDestWidth write SetDestWidth;
      property DestVisible : Boolean read FDestVisible write SetDestVisible;
      property DestAlign : TDestAlign read FDestAlign write SetDestAlign;
  end;

procedure Register;

implementation

{ TPanelBorderColor }


procedure TPanelBorderColor.CMEnter(var Message: TCMEnter);
begin
 inherited;
  UpdatePanelColor;
end;

procedure TPanelBorderColor.CMExit(var Message: TCMExit);
begin
 inherited;
  UpdatePanelColor;
end;


procedure TPanelBorderColor.CMMouseEnter(var Msg: TMessage);
begin
//  PaintStruct;
end;

procedure TPanelBorderColor.CMMouseLeave(var Msg: TMessage);
begin
// PaintStruct;
end;
procedure TPanelBorderColor.UpdatePanelColor;
var
  HasFocus: Boolean;
begin
  if FBorderFocoActive then
  begin
      HasFocus := ContainsFocus(Self);

      if HasFocus then
      begin
        xFBorderColor := FBorderColorFoco;
        Caption := '.';
      end
      else
      begin
        xFBorderColor := FBorderColor;
        Caption := '..';
      end;
  end
  else
  begin
       xFBorderColor := FBorderColor;
  end;
end;
           
function TPanelBorderColor.ContainsFocus(Control: TWinControl): Boolean;
var
  I: Integer;
  ChildControl: TControl;
begin
  Result := False;

  for I := 0 to Control.ControlCount - 1 do
  begin
    ChildControl := Control.Controls[I];
    if ChildControl is TWinControl then
    begin
      if TWinControl(ChildControl).HandleAllocated and TWinControl(ChildControl).Focused then
        Exit(True)
      else if ContainsFocus(TWinControl(ChildControl)) then
        Exit(True);
    end;
  end;
end;

constructor TPanelBorderColor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  UpdatePanelColor;
  Width := 200;
  Height := 50;
  BevelOuter:=bvNone;
  BorderStyle := bsNone;
  Caption:='';

  FBorderColorFoco :=clRed;
  FBorderFocoActive:=false;

  FColor := clbtnFace;

  FColorBackGround := clSilver;
  FBorderColor     := clGray;

  FRadiusX       := 5;
  FRadiusY       := 5;
  FPenWidth      := 2;
  FDestWidth     :=30;
  FBorderVisible := True;
  FDestVisible   :=False;
  FDestAlign     :=alTop;

  DoubleBuffered      :=False;
  ParentDoubleBuffered:=False;
  FullRepaint         :=False;

  ControlStyle := ControlStyle - [csOpaque, csSetCaption] + [csAcceptsControls, csPannable];
end;

procedure TPanelBorderColor.CreateParams(var Params: TCreateParams);
begin

  inherited CreateParams(Params);

  with Params do
  begin
    FExStyle := ExStyle or WS_EX_TRANSPARENT;
    ExStyle := FExStyle;
  end;

end;

procedure TPanelBorderColor.CreateWnd;
begin
  inherited;
end;

destructor TPanelBorderColor.Destroy;
begin
  if Assigned(FD2DCanvas) then
    FreeAndNil(FD2DCanvas);
  inherited;
end;


procedure TPanelBorderColor.Paint;
begin
  inherited;
  PaintBorder;
end;

procedure TPanelBorderColor.PaintBorder;
var
  RRect, RRect2: TD2D1RoundedRect;
  Rect : D2D1_Rect_F;
begin

    UpdatePanelColor;

  FD2DCanvas := TDirect2DCanvas.Create(Canvas, ClientRect);
try

  D2D1RenderTargetProperties(D2D1_RENDER_TARGET_TYPE_DEFAULT);
  FD2DCanvas.RenderTarget.SetAntialiasMode(D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);
  FD2DCanvas.RenderTarget.SetTransform(TD2DMatrix3x2F.Identity);
  FD2DCanvas.RenderTarget.BeginDraw;

  FD2DCanvas.Brush.Style:=bsSolid;
  FD2DCanvas.Brush.Color:=FColorBackGround;

  RRect.Rect.Left:=ClientRect.Left+2;
  RRect.Rect.Top:=ClientRect.Top+2;
  RRect.Rect.Right:=ClientRect.Right-2;
  RRect.Rect.Bottom:=ClientRect.Bottom-2;
  RRect.RadiusX:=FRadiusX;
  RRect.RadiusY:=FRadiusY;

  FD2DCanvas.FillRoundedRectangle(RRect);

  if (FDestVisible=True) then
  begin

    if FDestAlign=alRight then
    begin

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=xFBorderColor;

      RRect2.Rect.Left:=ClientRect.Right-FDestWidth;
      RRect2.Rect.Top:=ClientRect.Top+2;
      RRect2.Rect.Right:=ClientRect.Right-2;
      RRect2.Rect.Bottom:=ClientRect.Bottom-2;
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=(ClientRect.Right-(FDestWidth+2));
      Rect.Top:=ClientRect.Top+2;
      Rect.Right:=ClientRect.Right-(FDestWidth-8);
      Rect.Bottom:=ClientRect.Bottom-2;

      FD2DCanvas.FillRectangle(Rect);
    end;


    if FDestAlign=alLeft then
    begin
      FD2DCanvas.Brush.Style:=bsSolid;
//      FD2DCanvas.Brush.Color:=xFBorderColor;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Left;
      RRect2.Rect.Top:=ClientRect.Top+2;
      RRect2.Rect.Right:=ClientRect.Left+(FDestWidth+2);
      RRect2.Rect.Bottom:=ClientRect.Bottom-2;
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=(ClientRect.Left+(FDestWidth+2));
      Rect.Top:=ClientRect.Top+2;
      Rect.Right:=ClientRect.Left+(FDestWidth-8);
      Rect.Bottom:=ClientRect.Bottom-2;

      FD2DCanvas.FillRectangle(Rect);
    end;


    if FDestAlign=alLeftRight then
    begin
      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Right-FDestWidth;
      RRect2.Rect.Top:=ClientRect.Top+2;
      RRect2.Rect.Right:=ClientRect.Right-2;
      RRect2.Rect.Bottom:=ClientRect.Bottom-2;
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=(ClientRect.Right-(FDestWidth+2));
      Rect.Top:=ClientRect.Top+2;
      Rect.Right:=ClientRect.Right-(FDestWidth-8);
      Rect.Bottom:=ClientRect.Bottom-2;

      FD2DCanvas.FillRectangle(Rect);

      //
      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Left;
      RRect2.Rect.Top:=ClientRect.Top+2;
      RRect2.Rect.Right:=ClientRect.Left+(FDestWidth+2);
      RRect2.Rect.Bottom:=ClientRect.Bottom-2;
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=(ClientRect.Left+(FDestWidth+2));
      Rect.Top:=ClientRect.Top+2;
      Rect.Right:=ClientRect.Left+(FDestWidth-8);
      Rect.Bottom:=ClientRect.Bottom-2;

      FD2DCanvas.FillRectangle(Rect);


    end;


    if FDestAlign=alTop then
    begin
      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Left+2;
      RRect2.Rect.Top:=ClientRect.Top+2;
      RRect2.Rect.Right:=ClientRect.Right-2;
      RRect2.Rect.Bottom:=ClientRect.Top+2+(FDestWidth+2);
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=ClientRect.Left+2;
      Rect.Top:=ClientRect.Top+(FDestWidth-2);
      Rect.Right:=ClientRect.Right-2;
      Rect.Bottom:=ClientRect.Top+(FDestWidth+8);

      FD2DCanvas.FillRectangle(Rect);
    end;


    if FDestAlign=alBottom then
    begin
      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Left+2;
      RRect2.Rect.Top:=ClientRect.Bottom-2;
      RRect2.Rect.Right:=ClientRect.Right-2;
      RRect2.Rect.Bottom:=ClientRect.Bottom-2-(FDestWidth+2);
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=ClientRect.Left+2;
      Rect.Top:=ClientRect.Bottom-(FDestWidth-2);
      Rect.Right:=ClientRect.Right-2;
      Rect.Bottom:=ClientRect.Bottom-(FDestWidth+8);

      FD2DCanvas.FillRectangle(Rect);
    end;

    if FDestAlign=alTopBottom then
    begin
      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Left+2;
      RRect2.Rect.Top:=ClientRect.Top+2;
      RRect2.Rect.Right:=ClientRect.Right-2;
      RRect2.Rect.Bottom:=ClientRect.Top+2+(FDestWidth+2);
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=ClientRect.Left+2;
      Rect.Top:=ClientRect.Top+(FDestWidth-2);
      Rect.Right:=ClientRect.Right-2;
      Rect.Bottom:=ClientRect.Top+(FDestWidth+8);

      FD2DCanvas.FillRectangle(Rect);
      //
      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=Color;

      RRect2.Rect.Left:=ClientRect.Left+2;
      RRect2.Rect.Top:=ClientRect.Bottom-2;
      RRect2.Rect.Right:=ClientRect.Right-2;
      RRect2.Rect.Bottom:=ClientRect.Bottom-2-(FDestWidth+2);
      RRect2.RadiusX:=FRadiusX;
      RRect2.RadiusY:=FRadiusY;

      FD2DCanvas.FillRoundedRectangle(RRect2);

      FD2DCanvas.Brush.Style:=bsSolid;
      FD2DCanvas.Brush.Color:=FColorBackGround;

      Rect.Left:=ClientRect.Left+2;
      Rect.Top:=ClientRect.Bottom-(FDestWidth-2);
      Rect.Right:=ClientRect.Right-2;
      Rect.Bottom:=ClientRect.Bottom-(FDestWidth+8);

      FD2DCanvas.FillRectangle(Rect);
    end;

  end;


  if (FBorderVisible=True) then
  begin

    FD2DCanvas.Brush.Style:=bsSolid;
    FD2DCanvas.Pen.Width:=FPenWidth;
    FD2DCanvas.Pen.Color:= xFBorderColor;

    RRect.Rect.Left:=ClientRect.Left+2;
    RRect.Rect.Top:=ClientRect.Top+2;
    RRect.Rect.Right:=ClientRect.Right-2;
    RRect.Rect.Bottom:=ClientRect.Bottom-2;
    RRect.RadiusX:=FRadiusX;
    RRect.RadiusY:=FRadiusY;

    FD2DCanvas.DrawRoundedRectangle(RRect);

  end;



finally
  FD2DCanvas.RenderTarget.EndDraw;
  FreeAndNil(FD2DCanvas);
end;

end;

procedure TPanelBorderColor.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetBorderColorFoco(const Value: TColor);
begin
  FBorderColorFoco := Value;
  PaintBorder;
end;


procedure TPanelBorderColor.SetBorderVisible(const Value: Boolean);
begin
  FBorderVisible := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetBorderFocoActive(const Value: Boolean);
begin
  FBorderFocoActive := Value;
  PaintBorder;
end;



procedure TPanelBorderColor.SetColor(const Value: TColor);
begin
  FColor := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetColorBackGround(const Value: TColor);
begin
  FColorBackGround := Value;
  PaintBorder;
End;

procedure TPanelBorderColor.SetDestAlign(const Value: TDestAlign);
begin
  FDestAlign := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetDestVisible(const Value: Boolean);
begin
  FDestVisible := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetDestWidth(const Value: Integer);
begin
  FDestWidth := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetPenWidth(const Value: Integer);
begin
  FPenWidth := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.SetRadiusX(const Value: Integer);
begin
  FRadiusX := Value;
  PaintBorder;
end;


procedure TPanelBorderColor.SetRadiusY(const Value: Integer);
begin
  FRadiusY := Value;
  PaintBorder;
end;

procedure TPanelBorderColor.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
End;

procedure TPanelBorderColor.WMSize(var Message: TWMSize);
var
  S: TD2DSizeU;
begin
  if Assigned(FD2DCanvas) then
  begin
    S := D2D1SizeU(ClientWidth, ClientHeight);
    ID2D1HwndRenderTarget(FD2DCanvas.RenderTarget).Resize(S);
  end;
  Realign;
  PaintBorder;
  Invalidate;
end;

procedure TPanelBorderColor.WM_NCPaint(var Message: TWMNCPaint);
begin
 PaintBorder;
 Invalidate;
end;

procedure Register;
begin
  RegisterComponents('Standard', [TPanelBorderColor]);
end;

initialization
  RegisterClass(TPanelBorderColor);

end.
