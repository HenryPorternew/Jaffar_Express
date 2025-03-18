program jaffarexpress;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SysUtils,
  UEngine;

begin
  try
    EngineStart();
  except
    on E: Exception do
    begin
      WriteLn(E.Message);
      ReadLn;
    end;
  end;
end.
