unit UConfig;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, base64;

type
  TMode = (Server, Client);
  TProtocol = (UDP, TCP);
  TMethod = (MDirect, MXOR1, MXOR2, MBase64, MHex, MReverse);

  TConfig = record
    ReciveTimeout: integer;
    HandleTimeout: integer;
    Mode: TMode;
    Protocol: TProtocol;
    Method: TMethod;
    Source: record
      Address: string;
      Port: string;
      end;
    Target: record
      Address: string;
      Port: string;
      end;
    XORLv0Data: byte;
    XORLv1Data: string;
  end;
  TConfigArray = array of TConfig;

function ConfigLoad(ConfigFile: string): TConfigArray;

implementation

const
  SectionDelimiter = '-';
  IPPortDelimiter = ':';

function DecodeToConfig(Data: string): TConfig;
var
  Sections: TStringArray;
  IPPort: TStringArray;
  MethodData: string;
begin
  Result := Default(TConfig);

  Result.ReciveTimeout := 1500;
  Result.HandleTimeout := 30000;

  Sections := SplitString(Data, SectionDelimiter);

  case LowerCase(Sections[0]) of
    'server': Result.Mode := Server;
    'client': Result.Mode := Client;
  end;

  case LowerCase(Sections[1]) of
    'udp': Result.Protocol := UDP;
    'tcp': Result.Protocol := TCP;
  end;

  IPPort := SplitString(Sections[2], IPPortDelimiter);
  Result.Source.Address := IPPort[0];
  Result.Source.Port := IPPort[1];

  IPPort := SplitString(Sections[3], IPPortDelimiter);
  Result.Target.Address := IPPort[0];
  Result.Target.Port := IPPort[1];

  case LowerCase(Sections[4]) of
    'direct': Result.Method := MDirect;
    'xor1': Result.Method := MXOR1;
    'xor2': Result.Method := MXOR2;
    'base64': Result.Method := MBase64;
    'hex': Result.Method := MHex;
    'reverse': Result.Method := MReverse;
  end;

  if Sections[5] <> '' then MethodData := DecodeStringBase64(Sections[5]);

  case Result.Method of
    MXOR1: Result.XORLv0Data := (StrToInt64(MethodData) mod 256);
    MXOR2: Result.XORLv1Data := MethodData;
  end;
end;

function ConfigLoad(ConfigFile: string): TConfigArray;
var
  FileData: TStringList;
  Index: integer;
begin
  Result := Default(TConfigArray);
  FileData := TStringList.Create;
  try
    FileData.LoadFromFile(ConfigFile);

    if FileData.Count > 0 then
    begin
      for Index := 0 to FileData.Count - 1 do
      begin
        if FileData[Index] <> '' then Insert(DecodeToConfig(FileData[Index]), Result, Length(Result));
      end;
    end;
  finally
    FileData.Free;
  end;
end;

end.
