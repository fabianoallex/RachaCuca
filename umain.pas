unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  URachaCuca;

type
  { TBlockPanel }

  TBlockPanel = class(TPanel)
  private
    FCorrectValue: Integer;
    FValue: Integer;
    procedure SetValue(AValue: Integer);
  public
    constructor Create(TheOwner: TComponent); override; overload;
    constructor Create(TheOwner: TComponent; CorrectValue: Integer); overload;
    property Value: Integer read FValue write SetValue;
  end;

  TClickBlockPanelEvent = procedure(I, J: Integer) of Object;

  { TBoardPanel }

  TBoardPanel = class(TPanel)
  private
    FOnClickBlock: TClickBlockPanelEvent;
    FSize: Integer;
    FBlocks: array of array of TBlockPanel;
    procedure DrawBlocks;
    procedure ClickBlock(Sender: TObject);
    procedure GetBlockPosition(BlockPanel: TBlockPanel;
      var I: Integer; var J: Integer);
    procedure SetOnClickBlock(AValue: TClickBlockPanelEvent);
  public
    constructor Create(TheOwner: TComponent; Board: TRachaCucaBoard); overload;
    property OnClickBlock: TClickBlockPanelEvent read FOnClickBlock write SetOnClickBlock;
  end;

  { TFMain }

  TFMain = class(TForm)
    Button5: TButton;
    LMovementCount: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ClickBlock(I: Integer; J: Integer);
  private
    FBoard: TRachaCucaBoard;
    FBoardPanel: TBoardPanel;
    procedure SetBoard(AValue: TRachaCucaBoard);
  public
    procedure Render;
    property Board: TRachaCucaBoard read FBoard write SetBoard;
  end;

var
  FMain: TFMain;

implementation

{$R *.lfm}

{ TBlockPanel }

procedure TBlockPanel.SetValue(AValue: Integer);
begin
  FValue := AValue;

  if FCorrectValue = FValue then
    Color := clYellow
  else
    Color := clBtnFace;

  if AValue = 0 then
    Caption := ''
  else
    Caption := AValue.ToString;
end;

constructor TBlockPanel.Create(TheOwner: TComponent);
begin
  Create(TheOwner, 0);
end;

constructor TBlockPanel.Create(TheOwner: TComponent; CorrectValue: Integer);
begin
  inherited Create(TheOwner);
  FCorrectValue := CorrectValue;
  Self.Font.Style := [fsBold];
  Self.Font.Size := 16;
end;

{ TBoardPanel }

procedure TBoardPanel.DrawBlocks;
var
  I, J: Integer;
begin
  for I:=0 to FSize-1 do
    for J:=0 to FSize-1 do
    begin
      FBlocks[I][J].Top := I * (Self.Height div FSize);
      FBlocks[I][J].Left := J * (Self.Width div FSize);
      FBlocks[I][J].Height := Self.Height div FSize;
      FBlocks[I][J].Width := Self.Width div FSize;
    end;
end;

procedure TBoardPanel.ClickBlock(Sender: TObject);
var
  I, J: Integer;
begin
  if Assigned(FOnClickBlock) then
  begin
    I := -1;
    J := -1;
    GetBlockPosition(TBlockPanel(Sender), I, J);
    FOnClickBlock(I, J);
  end;
end;

procedure TBoardPanel.GetBlockPosition(BlockPanel: TBlockPanel;
  var I: Integer; var J: Integer);
var
  II, JJ: Integer;
begin
  I := -1;
  J := -1;
  for II:=0 to FSize-1 do
    for JJ:=0 to FSize-1 do
      if FBlocks[II][JJ] = BlockPanel then
      begin
        I := II;
        J := JJ;
        Exit;
      end;
end;

procedure TBoardPanel.SetOnClickBlock(AValue: TClickBlockPanelEvent);
begin
  FOnClickBlock:=AValue;
end;

constructor TBoardPanel.Create(TheOwner: TComponent; Board: TRachaCucaBoard);
var
  I, J: Integer;
begin
  inherited Create(TheOwner);
  FSize := Board.Size;
  SetLength(FBlocks, FSize, FSize);
  for I:=0 to FSize-1 do
    for J:=0 to FSize-1 do
    begin
      FBlocks[I][J] := TBlockPanel.Create(Self, (I*FSize) + (J+1));
      FBlocks[I][J].Parent := Self;
      FBlocks[I][J].OnClick := @ClickBlock;
    end;
end;

{ TFMain }

procedure TFMain.FormCreate(Sender: TObject);
begin
  FBoard := TRachaCucaBoard.Create(4);
  FBoardPanel := TBoardPanel.Create(Self, FBoard);
  FBoardPanel.Parent := Self;
  FBoardPanel.Top := 48;
  FBoardPanel.Left := 0;
  FBoardPanel.Width := 200;
  FBoardPanel.Height := 200;
  FBoardPanel.BorderStyle := bsSingle;
  FBoardPanel.DrawBlocks;
  FBoardPanel.OnClickBlock := @ClickBlock;
  Render;
end;

procedure TFMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case key of
    37 : FBoard.Move(dLeft);
    38 : FBoard.Move(dUp);
    39 : FBoard.Move(dRight);
    40 : FBoard.Move(dDown);
  end;
  Render;
end;

procedure TFMain.ClickBlock(I: Integer; J: Integer);
var
  IEmpty, JEmpty: Integer;
begin
  IEmpty := -1;
  JEmpty := -1;
  Board.GetBlockPositionByValue(IEmpty, JEmpty, 0);

  if (J = JEmpty) and (I = IEmpty-1) then Board.Move(dDown);
  if (J = JEmpty) and (I = IEmpty+1) then Board.Move(dUp);
  if (I = IEmpty) and (J = JEmpty-1) then Board.Move(dRight);
  if (I = IEmpty) and (J = JEmpty+1) then Board.Move(dLeft);

  Render;
end;

procedure TFMain.Button5Click(Sender: TObject);
begin
  Board.Restart;
  Render;
end;

procedure TFMain.SetBoard(AValue: TRachaCucaBoard);
begin
  FBoard := AValue;
end;

procedure TFMain.Render;
var
  I, J: Integer;
  Linha, Value: String;
begin
  LMovementCount.Caption := Format('Movimentos: %d', [Board.MovementCount]);

  for I:=0 to FBoard.Size-1 do
    for J:=0 to FBoard.Size-1 do
      FBoardPanel.FBlocks[I][J].Value := FBoard.Blocks[I][J].Value;

  Memo1.Lines.Clear;
  for I:=0 to FBoard.Size-1 do
  begin
    Linha := '';
    for J:=0 to FBoard.Size-1 do
    begin
      Value := IntToStr(FBoard.Blocks[I][J].Value);

      if FBoard.Blocks[I][J].Value < 10 then
        Value := ' ' + Value;

      if Value = ' 0' then
        Value := '  ';
      Linha := Linha + Value + '|';
    end;
    Memo1.Lines.Add(Linha);
  end;

  if Board.Completed then
    ShowMessage('Completou!');
end;

end.

