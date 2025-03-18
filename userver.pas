unit UServer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  blcksock, synsock,
  UConfig, UHandle;

type

  { TServer }

  TServer = class(TThread)
  private
    FConfig: TConfig;
  protected
    procedure Execute; override;
  public
    constructor Create(Config: TConfig);
    destructor Destroy; override;
  end;

implementation

{ TServer }

procedure TServer.Execute;
var
  ServerSocket: TBlockSocket;
  NewSocket: TSocket;
  ServHandle: THandle;
begin
  case FConfig.Protocol of
    TCP: begin
      ServerSocket := TTCPBlockSocket.Create;
      try
        ServerSocket.Bind(FConfig.Source.Address, FConfig.Source.Port);
        if ServerSocket.LastError <> 0 then Exit;

        ServerSocket.Listen;
        if ServerSocket.LastError <> 0 then Exit;

        while True do
        begin
          NewSocket := ServerSocket.Accept;
          if ServerSocket.LastError <> 0 then Continue;
          if NewSocket = INVALID_SOCKET then Continue;
          ServHandle := THandle.Create(NewSocket, FConfig);
        end;
      finally
        ServerSocket.Free;
      end;
    end;
    UDP: begin
      while True do
      begin
        ServHandle := THandle.Create(0, FConfig);
        ServHandle.WaitFor;
      end;
    end;
  end;
end;

constructor TServer.Create(Config: TConfig);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FConfig := Config;
end;

destructor TServer.Destroy;
begin
  inherited Destroy;
end;


end.
