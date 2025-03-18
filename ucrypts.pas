unit UCrypts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, base64,
  UConfig;

type
  TDirection = (SourceToTarget, TargetToSource);

  { TCrypts }

  TCrypts = class
  private
    FConfig: TConfig;
    procedure XORLv0AnCrypt(var Buffer: ansistring; out Data: ansistring);
    procedure XORLv1AnCrypt(var Buffer: ansistring; out Data: ansistring);
    procedure HexEnCrypt(var Buffer: ansistring; out Data: ansistring);
    procedure HexDeCrypt(var Buffer: ansistring; out Data: ansistring);
  public
    constructor Create(Config: TConfig);
    function CryptBuffer(var Buffer: ansistring; Direction: TDirection): ansistring;
  end;

implementation

procedure TCrypts.XORLv0AnCrypt(var Buffer: ansistring; out Data: ansistring);
var
  Index: integer;
  BufferLength: integer;
begin
  BufferLength := Length(Buffer);
  SetLength(Data, BufferLength);

  for Index := 1 to BufferLength do Data[Index] := char((Ord(Buffer[Index]) xor FConfig.XORLv0Data));
end;

procedure TCrypts.XORLv1AnCrypt(var Buffer: ansistring; out Data: ansistring);
var
  Index: integer;
  KeyLength: integer;
  BufferLength: integer;
begin
  BufferLength := Length(Buffer);
  KeyLength := Length(FConfig.XORLv1Data);
  SetLength(Data, BufferLength);

  for Index := 1 to BufferLength do
    Data[Index] := char(Ord(Buffer[Index]) xor Ord(FConfig.XORLv1Data[(((Index - 1) mod KeyLength) + 1)]));
end;

procedure TCrypts.HexEnCrypt(var Buffer: ansistring; out Data: ansistring);
var
  Index: integer;
  BufferLength: integer;
begin
  Data := '';
  BufferLength := Length(Buffer);

  for Index := 1 to BufferLength do Data += IntToHex(Ord(Buffer[Index]), 2);
end;

procedure TCrypts.HexDeCrypt(var Buffer: ansistring; out Data: ansistring);
var
  Index: integer;
  BufferLength: integer;
  HexCode: string;
begin
  Data := '';
  Index := 1;
  BufferLength := Length(Buffer);

  while Index < BufferLength do
  begin
    HexCode := Copy(Buffer, Index, 2);
    Data += Chr(StrToInt('$' + HexCode));
    Inc(Index, 2);
  end;
end;

constructor TCrypts.Create(Config: TConfig);
begin
  FConfig := Config;
end;

function TCrypts.CryptBuffer(var Buffer: ansistring; Direction: TDirection): ansistring;
begin
  case Direction of
    SourceToTarget: begin
      case FConfig.Mode of
        Server: begin
          case FConfig.Method of
            MDirect: Result := Buffer;
            MXOR1: XORLv0AnCrypt(Buffer, Result);
            MXOR2: XORLv1AnCrypt(Buffer, Result);
            MBase64: Result := DecodeStringBase64(Buffer);
            MHex: HexDeCrypt(Buffer, Result);
            MReverse: Result := AnsiReverseString(Buffer);
          end;
        end;
        Client: begin
          case FConfig.Method of
            MDirect: Result := Buffer;
            MXOR1: XORLv0AnCrypt(Buffer, Result);
            MXOR2: XORLv1AnCrypt(Buffer, Result);
            MBase64: Result := EncodeStringBase64(Buffer);
            MHex: HexEnCrypt(Buffer, Result);
            MReverse: Result := AnsiReverseString(Buffer);
          end;
        end;
      end;
    end;
    TargetToSource: begin
      case FConfig.Mode of
        Server: begin
          case FConfig.Method of
            MDirect: Result := Buffer;
            MXOR1: XORLv0AnCrypt(Buffer, Result);
            MXOR2: XORLv1AnCrypt(Buffer, Result);
            MBase64: Result := EncodeStringBase64(Buffer);
            MHex: HexEnCrypt(Buffer, Result);
            MReverse: Result := AnsiReverseString(Buffer);
          end;
        end;
        Client: begin
          case FConfig.Method of
            MDirect: Result := Buffer;
            MXOR1: XORLv0AnCrypt(Buffer, Result);
            MXOR2: XORLv1AnCrypt(Buffer, Result);
            MBase64: Result := DecodeStringBase64(Buffer);
            MHex: HexDeCrypt(Buffer, Result);
            MReverse: Result := AnsiReverseString(Buffer);
          end;
        end;
      end;
    end;
  end;
end;

end.
