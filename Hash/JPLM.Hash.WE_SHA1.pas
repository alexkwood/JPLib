unit JPLM.Hash.WE_SHA1;

interface

uses
  SysUtils,
  MFPC.Classes.Streams,
  JPL.Math, JPL.TimeLogger,
  JPLM.Hash.Common,

  //WE
  Hash, Mem_util, sha1
  ;

const
  HASH_BUFFER_SIZE_SHA1 = 1024*63; // 1024 * 100; // F000 = 61 440 bytes


function WeGetFileHash_Sha1(fName: string; var HashResult: THashResultRec; HashEnumProc: THashEnumProc = nil): Boolean;
function WeGetStreamHash_Sha1(AStream: TM_Stream; var HashResult: THashResultRec; StartPos: Int64 = 0; HashEnumProc: THashEnumProc = nil): Boolean;


implementation

function HexString(const x: array of byte): AnsiString; {-HEX string from memory}
begin
  Result := HexStr(@x, sizeof(x));
end;


function WeGetStreamHash_Sha1(AStream: TM_Stream; var HashResult: THashResultRec; StartPos: Int64 = 0; HashEnumProc: THashEnumProc = nil): Boolean;
var
  //Crc: integer;
  Context: THashContext;
  Digest: TSHA1Digest;
  xRead, xPercent: integer;
  xSize, xTotalRead: Int64;
  BufNo: integer;
  Buffer: array[0..HASH_BUFFER_SIZE_SHA1-1] of Byte;
  Logger: TClassTimeLogger;
begin
  Result := False;
  Logger := TClassTimeLogger.Create;
  try
    Logger.StartLog;
    ClearHashResultRec(HashResult);
    SHA1Init(Context);

    xTotalRead := StartPos;
    xSize := AStream.Size - StartPos;
    HashResult.StreamSize := xSize;
    BufNo := 0;

    AStream.Position := StartPos;

    while AStream.Position < AStream.Size do
    begin

      Inc(BufNo);

      xRead := AStream.Read(Buffer, SizeOf(Buffer));

      xTotalRead := xTotalRead + xRead;
      xPercent := Round(PercentValue(xTotalRead, xSize));

      if xRead > 0 then SHA1Update(Context, @Buffer, xRead);

      if Assigned(HashEnumProc) then if not HashEnumProc(xPercent, BufNo) then Exit;

    end; // while

    SHA1Final(Context, Digest);

    //HashResult.StrValueUpper := IntToHex(Crc, HASH_LEN_CRC24);
    HashResult.StrValueUpper := UpperCase(string(HexString(Digest)));
    HashResult.StrValueLower := LowerCase(HashResult.StrValueUpper);
//    HashResult.IntValue := Crc;
//    HashResult.Int64Value := Crc;
    Logger.EndLog;
    HashResult.ElapsedTimeMs := Logger.ElapsedTimeMs;
    HashResult.SpeedMBperSec := GetSpeedValue_MB_per_sec(HashResult.StreamSize, HashResult.ElapsedTimeMs);

    Result := True;
  finally
    Logger.Free;
  end;

end;

function WeGetFileHash_Sha1(fName: string; var HashResult: THashResultRec; HashEnumProc: THashEnumProc = nil): Boolean;
var
  fs: TM_FileStream;
begin
  fs := TM_FileStream.Create(fName, fmOpenRead or fmShareDenyNone);
  try
    Result := WeGetStreamHash_Sha1(fs, HashResult, 0, HashEnumProc);
  finally
    fs.Free;
  end;
end;

end.
