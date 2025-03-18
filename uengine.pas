unit UEngine;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  blcksock, synsock,
  UConfig, UServer;

procedure EngineStart();

implementation

procedure EngineStart();
var
  Configs: TConfigArray;
  Index: integer;
begin
  Configs := ConfigLoad(ParamStr(1));

  for Index := Low(Configs) to High(Configs) do
  begin
    TServer.Create(Configs[Index]);
  end;

  while True do
  begin
    Sleep(1000);
  end;
end;

end.
