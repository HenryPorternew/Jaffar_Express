unit UHandle;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DateUtils,
  blcksock, synsock,
  UConfig, UCrypts;

type

  { THandle }

  THandle = class(TThread)
  private
    FConfig: TConfig;
    FLifeTime: TDateTime;
    FNewSocket: TSocket;
    FCrypts: TCrypts;
    FSourceSocket: TBlockSocket;
    FTargetSocket: TBlockSocket;
  protected
    procedure Execute; override;
  public
    constructor Create(NewSocket: TSocket; Config: TConfig);
    destructor Destroy; override;
  end;

implementation

{ THandle }

procedure THandle.Execute;
var
  SourceAvailable: boolean;
  TargetAvailable: boolean;
  Buffer: ansistring;
begin
  case FConfig.Protocol of
    TCP: begin
      FSourceSocket.Socket := FNewSocket;
    end;
    UDP: begin
      FSourceSocket.Bind(FConfig.Source.Address, FConfig.Source.Port);
    end;
  end;
  if FSourceSocket.LastError <> 0 then Exit;

  FTargetSocket.Connect(FConfig.Target.Address, FConfig.Target.Port);
  if FTargetSocket.LastError <> 0 then Exit;

  while True do
  begin
    SourceAvailable := False;
    TargetAvailable := False;

    if FSourceSocket.WaitingData > 0 then
    begin
      Buffer := FSourceSocket.RecvPacket(FConfig.ReciveTimeout);
      if (FSourceSocket.LastError = 0) and (Length(Buffer) > 0) then
      begin
        SourceAvailable := True;
        Buffer := FCrypts.CryptBuffer(Buffer, SourceToTarget);
        FTargetSocket.SendString(Buffer);
      end;
    end;

    if FTargetSocket.WaitingData > 0 then
    begin
      Buffer := FTargetSocket.RecvPacket(FConfig.ReciveTimeout);
      if (FTargetSocket.LastError = 0) and (Length(Buffer) > 0) then
      begin
        TargetAvailable := True;
        Buffer := FCrypts.CryptBuffer(Buffer, TargetToSource);
        FSourceSocket.SendString(Buffer);
      end;
    end;

    if (SourceAvailable = False) and (TargetAvailable = False) then
    begin
      if MilliSecondsBetween(Now, FLifeTime) > FConfig.HandleTimeout then Break;
      Sleep(1);
    end
    else if (SourceAvailable = True) or (TargetAvailable = True) then
    begin
      FLifeTime := Now;
    end;
  end;
end;

constructor THandle.Create(NewSocket: TSocket; Config: TConfig);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FConfig := Config;
  FLifeTime := Now;
  FNewSocket := NewSocket;
  FCrypts := TCrypts.Create(Config);

  case Config.Protocol of
    TCP: begin
      FSourceSocket := TTCPBlockSocket.Create;
      FTargetSocket := TTCPBlockSocket.Create;
    end;
    UDP: begin
      FSourceSocket := TUDPBlockSocket.Create;
      FTargetSocket := TUDPBlockSocket.Create;
    end;
  end;
end;

destructor THandle.Destroy;
begin
  FTargetSocket.Free;
  FSourceSocket.Free;
  FCrypts.Free;
  inherited Destroy;
end;

end.
