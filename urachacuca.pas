unit URachaCuca;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TDirection = (dLeft, dRight, dUp, dDown);

  { TUniqueRandom }

  TUniqueRandom = class
    type
      PValue=^TValue;
      TValue = record
	      Value: Integer;
	    end;
  private
    FRandomLimit: Integer;
    FList: TList;
  public
    constructor Create(RandomLimit: Integer; CallRandomize: Boolean);
    destructor Destroy; override;
    function HasNext: Boolean;
    function Next: Integer;
    property RandomLimit: Integer read FRandomLimit;
  end;

  { TBlock }

  TBlock = class
  private
    FValue: Integer;
    procedure SetValue(AValue: Integer);
  public
    constructor Create(AValue: Integer);
    property Value: Integer read FValue write SetValue;
  end;

  TBlocks = array of array of TBlock;

  { TRachaCucaBoard }

  TRachaCucaBoard = class
  private
    FBlocks: TBlocks;
    FMovementCount: Integer;
    FSize: Integer;
    function CheckCompleted: Boolean;
  public
    constructor Create(Size: Integer=4);
    destructor Destroy; override;
    procedure GetBlockPositionByValue(var I: Integer; var J: Integer;
      AValue: Integer);
    procedure Restart;
    procedure Move(Direction: TDirection);
    property Blocks: TBlocks read FBlocks;
    property Size: Integer read FSize;
    property MovementCount: Integer read FMovementCount;
    property Completed: Boolean read CheckCompleted;
  end;

implementation

{ TUniqueRandom }

constructor TUniqueRandom.Create(RandomLimit: Integer; CallRandomize: Boolean);
var
  V: PValue;
  I: Integer;
begin
  if CallRandomize then
    Randomize;

  FRandomLimit := RandomLimit;
  FList := TList.Create;

  for I:=0 to FRandomLimit-1 do
  begin
    new(V);
    V^.Value := I;
    FList.Add(V);
  end;
end;

destructor TUniqueRandom.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TUniqueRandom.HasNext: Boolean;
begin
  Result := FList.Count > 0;
end;

function TUniqueRandom.Next: Integer;
var
  V: PValue;
  I: Integer;
begin
  Result := -1;
  if not Self.HasNext then
    Exit;

  I := Random(FList.Count);
  V := FList.Items[I];
  FList.Remove(V);

  Result := V^.Value;
end;

{ TBlock }

procedure TBlock.SetValue(AValue: Integer);
begin
  FValue := AValue;
end;

constructor TBlock.Create(AValue: Integer);
begin
  inherited Create;
  Self.FValue := AValue;
end;

{ TRachaCucaBoard }

function TRachaCucaBoard.CheckCompleted: Boolean;
var
  I, J: Integer;
begin
  Result := False;
  for I:=0 to FSize-1 do
    for J:=0 to FSize-1 do
      if
        (FBlocks[I][J].Value > 0)
        and
        (FBlocks[I][J].Value <> (I*FSize) + (J+1)) then
        Exit;
  Result := True;
end;

constructor TRachaCucaBoard.Create(Size: Integer);
begin
  inherited Create;

  if Size < 2 then
    Size := 2;
  FSize := Size;

  Self.Restart;
end;

destructor TRachaCucaBoard.Destroy;
var
  I, J: Integer;
begin
  for I:=0 to FSize-1 do
    for J:=0 to FSize-1 do
      FBlocks[I][J].Free;
  inherited Destroy;
end;

procedure TRachaCucaBoard.GetBlockPositionByValue(var I: Integer;
  var J: Integer; AValue: Integer);
var
  II, JJ: Integer;
begin
  I := -1;
  J := -1;
  for II:=0 to FSize-1 do
    for JJ:=0 to FSize-1 do
      if Blocks[II][JJ].Value = AValue then
      begin
        I := II;
        J := JJ;
        Exit;
      end;
end;

procedure TRachaCucaBoard.Restart;
var
  I, J: Integer;
  UniqueRandom: TUniqueRandom;
begin
  FMovementCount := 0;
  UniqueRandom := TUniqueRandom.Create(FSize * FSize, True);
  try
    SetLength(FBlocks, Size, Size);
    for I:=0 to FSize-1 do
      for J:=0 to FSize-1 do
        FBlocks[I][J] := TBlock.Create(UniqueRandom.Next);
  finally
    UniqueRandom.Free;
  end;
end;

procedure TRachaCucaBoard.Move(Direction: TDirection);
var
  I, J: Integer;

  function ValidMovement: Boolean;
  begin
    Result := not (
      (Direction = dLeft) and (J = Size-1) or
      (Direction = dRight) and (J = 0) or
      (Direction = dUp) and (I = Size-1) or
      (Direction = dDown) and (I = 0)
    );
  end;

  procedure MoveValue(AFrom, ATo: TBlock);
  begin
    ATo.Value := AFrom.Value;
    AFrom.Value := 0;
  end;

  function FromBlock: TBlock;
  begin
    case Direction of
      dLeft:  Result := FBlocks[I][J+1];
      dRight: Result := FBlocks[I][J-1];
      dUp:    Result := FBlocks[I+1][J];
      dDown:  Result := FBlocks[I-1][J];
    end;
  end;

begin
  for I:=0 to FSize-1 do
    for J:=0 to FSize-1 do
      if FBlocks[I][J].Value = 0 then
      begin
        if not ValidMovement then
          Exit;

        MoveValue(FromBlock, FBlocks[I][J]);
        Inc(FMovementCount);
        Exit;
      end;
end;

end.

