(*****************************************************************************************
 *   LomCN Mir3 file manager core File 2012                                              *
 *                                                                                       *
 *   Web       : http://www.lomcn.org                                                    *
 *   Version   : 0.0.0.6                                                                 *
 *                                                                                       *
 *   - File Info -                                                                       *
 *                                                                                       *
 *   This file holds all Texture loading things and ..                                   *
 *                                                                                       *
 *                                                                                       *
 *                                                                                       *
 *****************************************************************************************
 * Change History                                                                        *
 *                                                                                       *
 *  - 0.0.0.1 [2012-09-11] Coly : fist init                                              *
 *  - 0.0.0.2 [2012-10-10] Coly : cleanup code                                           *
 *  - 0.0.0.3 [2013-03-27] Coly : change img reading and cliping                         *
 *  - 0.0.0.4 [2013-03-27] Coly : add more WTL and LMT code                              *
 *  - 0.0.0.5 [2013-05-08] Coly : Change Draw function and add more                      *
 *  - 0.0.0.6 [2013-05-17] Coly : remap texture file for more texture suport             *  
 *                                                                                       *
 *                                                                                       *
 *                                                                                       *
 *                                                                                       *
 *****************************************************************************************
 *  - TODO List for this *.pas file -                                                    *
 *---------------------------------------------------------------------------------------*                     
 *  if a todo finished, then delete it here...                                           *
 *  if you find a global TODO thats need to do, then add it here..                       *
 *---------------------------------------------------------------------------------------*                      
 *                                                                                       *
 *  - TODO : -all -fill *.pas header information                                         *
 *                 (how to need this file etc.)                                          *
 *                                                                                       *
 *                                                                                       *
 *****************************************************************************************)
 unit mir3_game_file_manager;

interface

{$I DevelopmentDefinition.inc}

uses 
{Delphi }  Windows, SysUtils, Math, Graphics, Classes, ActiveX, 
{DirectX}  D3DX9, Direct3D9, DirectShow9, 
{Game   }  mir3_game_file_manager_const, mir3_global_config, mir3_misc_utils, 
{Game   }  mir3_game_engine_def, mir3_game_engine;     
     
type
  { Forweard declaration }
  TMir3_Texture         = class;
  TMir3_FileMapping     = class;
  TMir3_TextureLibrary  = class;
  TMir3_FileCashManager = class;


  {$REGION ' - Wemade Orginal Header (For Import WIL/WIX)   '}
     (*****************************************************************************
      * TWIL_Header WIL (Wemade Orginal) File Header
      *
      ****************************************************************************)
      PWIL_Header =^TWIL_Header;
      TWIL_Header = packed record
        whValid            : Byte;                          // 1
        whLib_Info         : array [0..20] of AnsiChar;     // ILIB v1.0-WEMADE
        whLib_Type         : Word;                          // 5000=Type2 | 17=Type1
        whTotal_Index      : Word;                          // Total Image in this File
      end;
    
     (*****************************************************************************
      * PWIX_Header WIX (Wemade Orginal) File Index Header
      *
      ****************************************************************************)
      PWIX_Header = ^TWIX_Header;
      TWIX_Header = packed record
        whLib_Info         : array [0..19] of AnsiChar;
        whTotal_Index      : Word;
      end;
    
     (*****************************************************************************
      * TWIL_Img_Header WIL_IMG (Wemade Orginal) Image Header
      *
      ****************************************************************************)
      PWIL_Img_Header = ^TWIL_Img_Header;         // WIL-File Image Offset Header
      TWIL_Img_Header = packed record
        imgWidth           : Word;                          // Image Width
        imgHeight          : Word;                          // Image Height
        imgOffset_X        : Smallint;                      // Image Offset X
        imgOffset_Y        : Smallint;                      // Image Offset Y
        imgShadow_type     : Byte;                          // Image Shadow Type
        imgShadow_Offset_X : Smallint;                      // Image Shadow Offset X
        imgShadow_Offset_Y : Smallint;                      // Image Shadow Offset Y
        imgFileSize        : Cardinal;                      // FileSize Only in Type2   or ByteSwap TEST IT // Packed and Crypted File Size (must by * 2 + Position + 21)
      end;
  {$ENDREGION}

  {$REGION ' - LomCN Texture Format Header (For Import LMT) '}
     (*****************************************************************************
      * TLMT_Header LMT (LomCN Texture) File Header
      *
      ****************************************************************************)
      PLMT_Header =^TLMT_Header;
      TLMT_Header = packed record  (*29*)
        lhValid            : Byte;                          // 1
        lhLib_Info         : array [0..20] of AnsiChar;     // LMT v1.0-LomCN HEADER_INFORMATION
        lhLib_Type         : Word;                          // 9000=Type4
        lhTotal_Index      : Word;                          // Total Indexes in this File
        lhTotal_Image      : Word;                          // Total Image in this File
        lhSecuredImage     : Byte;                          // 0: No  |  1:Yes (Type 1 Crypt) |  2:Yes (Type 2 Crypt) ...
      end;
      {$EXTERNALSYM TLMT_Header}

     (*****************************************************************************
      * TLMT_Img_Header LMT_IMG (LomCN Texture) Image Header
      *
      ****************************************************************************)
      PLMT_Img_Header = ^TLMT_Img_Header;         // LMT-File Image Offset Header
      TLMT_Img_Header = packed record
        imgWidth           : Word;                          // Image Width
        imgHeight          : Word;                          // Image Height
        imgOffset_X        : Smallint;                      // Image Offset X
        imgOffset_Y        : Smallint;                      // Image Offset Y
        imgShadow_type     : Byte;                          // Image Shadow Type
        imgShadow_Offset_X : Smallint;                      // Image Shadow Offset X
        imgShadow_Offset_Y : Smallint;                      // Image Shadow Offset Y
        imgFileSize        : Cardinal;                      // FileSize 
      end;
  {$ENDREGION}   
  
  {$REGION ' - Records  '}
    { Records }

    PImageHeaderD3D = ^TImageHeaderD3D;
    TImageHeaderD3D = record
      ihORG_Width      : Word;                  // Breite des Images Blit Gr??e
      ihORG_Height     : Word;                  // H?he des Images Blit Gr??e
      ihPO2_Width      : Word;                  // Breite des Images Power of 2 Gr??e
      ihPO2_Height     : Word;                  // Breite des Images Power of 2 Blit Gr??e
      ihOffset_X       : Smallint;
      ihOffset_Y       : Smallint;
      ihOffsetShadow_X : Smallint;
      ihOffsetShadow_Y : Smallint;
      ihTypeShadow     : Byte;
      ihUseTime        : LongWord;
      ihFileSize       : Integer;
      ihD3DTexture     : TMir3_Texture;
    end;

    PFileInformation =^ TFileInformation;
    TFileInformation = record
      fiFileID           : Integer;
      fiImageOpenCount   : DWord;
      fiImageMemoryUsag  : Extended;
      fiLastUseTick      : DWord;
      fiFirstUseTick     : DWord;
      fiUnloadFile       : Boolean;   // Zur Steuerung ob File aus dem Speicher geschmissen wird (Nein bei GUI Interface Image File)
      fiImageLib         : TMir3_TextureLibrary;
      fiImageList        : array of PImageHeaderD3D;
    end;
  {$ENDREGION}

  {$REGION ' - Classes  '}

  { TMir3_Texture }
  TMir3_Texture = class
  strict private
    FStaticImage    : ITexture;
    FGrayScaleImage : ITexture;
    FColorImage     : ITexture;
    FLastR          : Byte;
    FLastG          : Byte;
    FLastB          : Byte;
  public
    FQuad       : THGEQuad;
    FWidth      : Integer;
    FHeight     : Integer;
    FTexWidth   : Integer;
    FTexHeight  : Integer;
    FClientRect : TRect;
  public
    constructor Create;
    destructor Destroy(); override;
  public
    function GetPixels(AX, AY: integer): LongWord;
    procedure ColorToGray;
    procedure FlipQuadTexture(const ATextureID: Integer);
    procedure ChangeColor(const R, G, B: Byte);
    procedure LoadFromITexture(const AImages: ITexture; AWidth, AHeight: Integer);
  end;

  { TMir3_TextureLibrary } // WIL         WIL         WTL         LMT
  TFileLibType         = (LIB_TYPE_1, LIB_TYPE_2, LIB_TYPE_3, LIB_TYPE_4);
  TMir3_TextureLibrary = class
  strict private
    FFileName      : string;
    FUsingLibType  : TFileLibType;
    FImageIndex    : Integer;
    FTotalImage    : Integer;
    FTotalIndex    : Integer;
    FBeginImage    : Integer;
    (* Wil / Wix System *)
    FHeaderWILInfo    : TWIL_Header;
    FHeaderWIXInfo    : TWIX_Header;
    FHeaderWILImage   : TWIL_Img_Header;
    FDumpWILImageInfo : TWIL_Img_Header;
    FWIL              : PByte;
    FWIX              : PByte;
    (* LMT System *)
    FHeaderLMTInfo    : TLMT_Header;
    FHeaderLMTImage   : TLMT_Img_Header;
    FDumpLMTImageInfo : TLMT_Img_Header;
    FLMT              : PByte;
  private
    procedure CreateFilesMMF(FFileName: String);
    function GetLibTypeOffset(LibType: Integer): Integer;
    function GetLibTypeWixOffset(LibType: Integer): Integer;
    function GetLibType(LibType: Integer): String;
    function GetImageInformationWIL(AFrame: Integer): PWIL_Img_Header;
    function GetImageInformationLMT(AFrame: Integer): PLMT_Img_Header;
  public
    constructor Create(const AUsingLibType: TFileLibType = LIB_TYPE_2);
    destructor Destroy; override;
    procedure FlushMMF;
    function Open(FileName: string): Boolean;
    procedure Close;
    // Get Functions
    function GetTotalIndex: Integer;
    function GetVersionType: String;
    function GetOverallImage: Integer;
    function GetLastImageInt: Integer;
    function GetLastImageStr: String;
    function GetIndexInformation(AFrame: Integer): Integer;
    // Decode Functions
    function DecodeFrame32ToMir3_D3D(const AFrame: Integer; var APImageRecord: PImageHeaderD3D): Boolean;

    function DecodeFrame32ToMir3D3DX(AFrame: Integer; var APImageRecord: PImageHeaderD3D): Boolean; overload;
    function DecodeFrame32ToMir3D3DX(AFrame: Integer; var APImageRecord: PImageHeaderD3D; AColor: Word): Boolean; overload;
    property ImageInfoWIL[Index: Integer]: PWIL_Img_Header read GetImageInformationWIL;
    property ImageInfoLMT[Index: Integer]: PLMT_Img_Header read GetImageInformationLMT;
  end;

  { TMir3_FileMapping }
  TMir3_FileMapping = class
  strict private
    FStaticFileIndex : array of Pointer;
  public
    constructor Create;
    destructor  Destroy; override;
  public
    function GetStaticFile(AIndex: Integer): Pointer;
    procedure SetStaticFile(AIndex: Integer; AFilePointer: Pointer);
    procedure CleanUpStaticFileMapping(AIndex: Integer);
  end;

  { TMir3_FileManager }
  TMir3_FileManager = class
  strict private
    FThreadsRunning : Integer;
    FManager        : TMir3_FileCashManager;
    FTextureManager : TMir3_FileMapping;
    FUsingLibType   : TFileLibType;
    FEventCode      : Integer;
    FMediaEvent     : IMediaEvent;
    FGraphBuilder   : IGraphBuilder;
    FMediaControl   : IMediaControl;
    FMediaSeeking   : IMediaSeeking;
    FVideoWindow    : IVideoWindow;
    FBasicAudio     : IBasicAudio;
  strict private
    function TestIfInList(AType: Byte; AFileID: Integer; AUsingLibType: TFileLibType = LIB_TYPE_2) : PFileInformation;
    function GetFileNameByID(AIndexID: Integer; AUsingLibType: TFileLibType = LIB_TYPE_2): String;
  public
    constructor Create(const AUsingLibType: TFileLibType = LIB_TYPE_2);
    destructor  Destroy; override;
  public //Video
    procedure RenderVideo(AType: Byte);
  public
    function GetImageD3DDirect(const AImageID, AFileID: Integer): PImageHeaderD3D;
    function GetFileMapping : TMir3_FileMapping;

    procedure DrawColor(AImage: TMir3_Texture; AX, AY: Integer; AColor: Cardinal);
    //V2.0
    procedure DrawTexture(const ATextureID, AFileID: Integer; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTexture(const ATexture: TMir3_Texture; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureStretch(const ATextureID, AFileID: Integer; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureStretch(const ATexture: TMir3_Texture; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;    
    procedure DrawTextureClipRect(const ATextureID, AFileID: Integer; AX, AY: Integer; ARect: TRect; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureClipRect(const ATexture: TMir3_Texture; AX, AY: Integer; ARect: TRect; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureClipRectStretch(const ATextureID, AFileID: Integer; AX, AY: Integer; ARect: TRect; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureClipRectStretch(const ATexture: TMir3_Texture; AX, AY: Integer; ARect: TRect; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureGrayScale(const ATextureID, AFileID: Integer; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureGrayScale(const ATexture: TMir3_Texture; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureGrayScaleStretch(const ATextureID, AFileID: Integer; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
    procedure DrawTextureGrayScaleStretch(const ATexture: TMir3_Texture; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255); overload;
  end;

  TMir3_FileCashManager = class(TThread)
  strict private
    FSpawnObject : TObject;
  protected
    procedure WatchCachLogic;
    procedure Execute; override;
  public
    constructor Create(const ASpawnObject: TObject); overload;
    destructor Destroy; override;
  end;
{$ENDREGION}
  

implementation

uses mir3_game_backend;

var
  GStopThreads  : Boolean;

  {$REGION ' - TMir3_TextureLibrary Constructor / Destructor / Open / Close '}
    constructor TMir3_TextureLibrary.Create(const AUsingLibType: TFileLibType = LIB_TYPE_2);
    begin
      inherited Create;
      // Set Lib Type
      FUsingLibType :=AUsingLibType;
    end;
    
    destructor TMir3_TextureLibrary.Destroy;
    begin
      try
        Close;
      except
      end;
      inherited;
    end;

    procedure TMir3_TextureLibrary.FlushMMF;
    begin
      CloseMMF(Pointer(FWIL));
      CloseMMF(Pointer(FWIX));
      Sleep(20);
      CreateFilesMMF(FFileName);
    end;

    function TMir3_TextureLibrary.Open(FileName: string): Boolean;
    begin
      Close;
      Result    := False;
      try
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin //Wil / Wix
            CreateFilesMMF(FileName);
            // Read Wil and Wix File Header
            CopyMemory(@FHeaderWilInfo, FWIL  , sizeof(TWIL_Header));
            CopyMemory(@FHeaderWixInfo, FWIX  , sizeof(TWIX_Header));
            FTotalImage := FHeaderWILInfo.whTotal_Index;
            FTotalIndex := FHeaderWILInfo.whTotal_Index;
            FFileName   := FileName;
          end;
          LIB_TYPE_4 : begin //LMT
            CreateFilesMMF(FileName);
            // Read LMT File Header
            CopyMemory(@FHeaderLMTInfo, FLMT  , sizeof(TLMT_Header));
            FBeginImage := 28 + (FHeaderLMTInfo.lhTotal_Index * SizeOf(Cardinal));
            FTotalImage := FHeaderLMTInfo.lhTotal_Image;
            FTotalIndex := FHeaderLMTInfo.lhTotal_Index;
          end;          
        end;
        Result      := True;
      finally
        if not Result then Close;
      end;
    end;

    procedure TMir3_TextureLibrary.Close;
    begin
      case FUsingLibType of
        LIB_TYPE_1 ,
        LIB_TYPE_2 : begin
          CloseMMF(Pointer(FWIL));
          CloseMMF(Pointer(FWIX));
          FillChar(FHeaderWILInfo , SizeOf(TWIL_Header)    , 0);
          FillChar(FHeaderWIXInfo , SizeOf(TWIX_Header)    , 0);
          FillChar(FHeaderWILImage, SizeOf(TWIL_Img_Header), 0);
        end;
        LIB_TYPE_4 : begin
          CloseMMF(Pointer(FLMT));
          FillChar(FHeaderLMTInfo, SizeOf(TLMT_Header)     , 0);
          FillChar(FHeaderLMTImage, SizeOf(TWIL_Img_Header), 0);
        end;
      end;  
      FImageIndex := -1;
      FTotalImage := -1;
      FTotalIndex := -1;
      FFileName   := '';
    end;
  {$ENDREGION}

  {$REGION ' - TMir3_TextureLibrary Functions     '}
    procedure TMir3_TextureLibrary.CreateFilesMMF(FFileName: String);
    var
      Size     : Cardinal;
      Error    : Integer;
      FFileWix : String;
      FFileWil : String;
    begin
      if (UpperCase(ExtractFileExt(FFileName)) = '.WIL') or
         (UpperCase(ExtractFileExt(FFileName)) = '.WIX') then
      begin
        FUsingLibType := LIB_TYPE_2;
        if UpperCase(ExtractFileExt(FFileName)) = '.WIL'  then
        begin
          FFileWil :=  FFileName;
          FFileWix :=  Copy(FFileName, 0, Length(FFileName)-4) + '.wix';
        end else begin
          FFileWix :=  FFileName;
          FFileWil :=  Copy(FFileName, 0, Length(FFileName)-4) + '.wil';
        end;

        if (FileExists(FFileWil)) and (FileExists(FFileWix)) then
        begin
          FWIL := CreateMMF(FFileWil, True, Size, Error);
          if Error <> 0 then Exit;
          FWIX := CreateMMF(FFileWix, True, Size, Error);
          if Error <> 0 then Exit;
        end else begin
                    FWIL := nil;
                    FWIX := nil;
                  end;
      end else if (UpperCase(ExtractFileExt(FFileName)) = '.LMT') then
               begin
                 FUsingLibType := LIB_TYPE_4;
                 if (FileExists(FFileName)) then
                 begin
                   FLMT := CreateMMF(FFileName, True, Size, Error);
                 end else FLMT := nil;
               end;
    end;

    function TMir3_TextureLibrary.GetLibTypeOffset(LibType: Integer): Integer;
    begin
      Result := 0;
      case LibType of
        17   : Result := 17;
        5000 : Result := 21;
        6000 : Result := 17;
        9000 : Result := 17; //(LMT System - LomCn Mir3 Texture)
      end;
    end;

    function TMir3_TextureLibrary.GetLibTypeWixOffset(LibType: Integer): Integer;
    begin
      Result := 0;
      case LibType of
        17   : Result := 24;
        5000 : Result := 28;
        6000 : Result := 32;
        9000 : Result := SizeOf(TLMT_Header); //(LMT System - LomCn Mir3 Texture)
      end;
    end;

    function TMir3_TextureLibrary.GetLibType(LibType: Integer): String;
    begin
      case LibType of
        17   : Result := 'Type 1';
        5000 : Result := 'Type 2';
        6000 : Result := 'Type 3';
        9000 : Result := 'Type 4'; //(LMT System - LomCn Mir3 Texture)
      end;
    end;
  {$ENDREGION}

  {$REGION ' - TMir3_TextureLibrary Get Functions '}
      function TMir3_TextureLibrary.GetTotalIndex: Integer;
      begin
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin
            if FWIL <> nil then
            begin
              Result := FHeaderWilInfo.whTotal_Index;
            end else Result := 0;
          end;
          LIB_TYPE_4 : begin
            if FLMT <> nil then
            begin
              Result := FHeaderLMTInfo.lhTotal_Index;
            end else Result := 0;
          end;
        end;
      end;
    
      function TMir3_TextureLibrary.GetVersionType: String;
      begin
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin
            if FWIL <> nil then
            begin
              Result := GetLibType(FHeaderWilInfo.whLib_Type);
            end else Result := 'Unknow';
          end;
          LIB_TYPE_4 : begin
            if FLMT <> nil then
            begin
              Result := GetLibType(FHeaderLMTInfo.lhLib_Type);
            end else Result := 'Unknow';
          end;
        end;
      end;

      function TMir3_TextureLibrary.GetOverallImage: Integer;
      var
        FPosition, I : Integer;
      begin
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin
            if FWIX <> nil then
            begin
              Result := 0;
              for I := 0 to GetTotalIndex do
              begin
                CopyMemory(@FPosition, PInteger(Integer(FWIX) + ((I * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), sizeof(FPosition));
                if FPosition <> 0 then
                  Inc(Result);
              end;
            end else Result := 0;
          end;
          LIB_TYPE_4 : begin
            if FLMT <> nil then
            begin
              Result := 0;
              for I := 0 to GetTotalIndex do
              begin
                CopyMemory(@FPosition, PInteger(Integer(FLMT) + ((I * 4) + GetLibTypeWixOffset(FHeaderLMTInfo.lhLib_Type))), sizeof(FPosition));
                if FPosition <> 0 then
                  Inc(Result);
              end;
            end else Result := 0;
          end;
        end;
      end;

      function TMir3_TextureLibrary.GetLastImageInt: Integer;
      var
        FPosition, I : Integer;
      begin
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin
            if FWIX <> nil then
            begin
              Result := 0;
              for I := GetTotalIndex downto 0 do
              begin
                CopyMemory(@FPosition, PInteger(Integer(FWIX) + ((I * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), sizeof(FPosition));
                if FPosition <> 0 then
                begin
                  Result := I;
                  Break;
                end;
              end;
            end else Result := 0;
          end;
          LIB_TYPE_4 : begin
            if FLMT <> nil then
            begin
              Result := 0;
              for I := GetTotalIndex downto 0 do
              begin
                CopyMemory(@FPosition, PInteger(Integer(FLMT) + ((I * 4) + GetLibTypeWixOffset(FHeaderLMTInfo.lhLib_Type))), sizeof(FPosition));
                if FPosition <> 0 then
                begin
                  Result := I;
                  Break;
                end;
              end;
            end else Result := 0;
          end;
        end;
      end;

      function TMir3_TextureLibrary.GetLastImageStr: String;
      var
        FPosition, I : Integer;
      begin
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin
            if FWIX <> nil then
            begin
              Result := '0';
              for I := GetTotalIndex downto 0 do
              begin
                CopyMemory(@FPosition, PInteger(Integer(FWIX) + ((I * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), sizeof(FPosition));
                if FPosition <> 0 then
                begin
                  Result := IntToStr(I);
                  Break;
                end;
              end;
            end else Result := '0';
          end;
          LIB_TYPE_4 : begin
            if FLMT <> nil then
            begin
              Result := '0';
              for I := GetTotalIndex downto 0 do
              begin
                CopyMemory(@FPosition, PInteger(Integer(FLMT) + ((I * 4) + GetLibTypeWixOffset(FHeaderLMTInfo.lhLib_Type))), sizeof(FPosition));
                if FPosition <> 0 then
                begin
                  Result := IntToStr(I);
                  Break;
                end;
              end;
            end else Result := '0';
          end;
        end;
      end;

      function TMir3_TextureLibrary.GetIndexInformation(AFrame: Integer): Integer;
      var
        FPosition : Integer;
      begin
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin
            if FWIX <> nil then
            begin
              CopyMemory(@FPosition, PInteger(Integer(FWIX) + ((AFrame * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), sizeof(FPosition));
              Result := FPosition;
            end else Result := 0;
          end;
          LIB_TYPE_4 : begin
            if FLMT <> nil then
            begin
              CopyMemory(@FPosition, PInteger(Integer(FLMT) + ((AFrame * 4) + GetLibTypeWixOffset(FHeaderLMTInfo.lhLib_Type))), sizeof(FPosition));
              Result := FPosition;
            end else Result := 0;
          end;
        end;
      end;
    
      function TMir3_TextureLibrary.GetImageInformationWIL(AFrame: Integer): PWIL_Img_Header;
      var
        FPosition : Integer;
      begin
        if (FWIX <> nil ) and (FWIL <> nil) then
        begin
          CopyMemory(@FPosition         , PInteger(Integer(FWIX) + ((AFrame * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), sizeof(FPosition));
          CopyMemory(@FDumpWILImageInfo , PInteger(Integer(FWIL) + FPosition)          , sizeof(TWIL_Img_Header));
          Result := @FDumpWILImageInfo;
        end else Result := nil;
      end;

      function TMir3_TextureLibrary.GetImageInformationLMT(AFrame: Integer): PLMT_Img_Header;
      var
        FPosition : Integer;
      begin
        if (FLMT <> nil ) then
        begin
          CopyMemory(@FPosition         , PInteger(Integer(FLMT) + ((AFrame * 4) + GetLibTypeWixOffset(FHeaderLMTInfo.lhLib_Type))), sizeof(FPosition));
          CopyMemory(@FDumpLMTImageInfo , PInteger(Integer(FLMT) + FPosition)          , sizeof(TLMT_Img_Header));
          Result := @FDumpLMTImageInfo;
        end else Result := nil;
      end;

  {$ENDREGION}

  {$REGION ' - TMir3_TextureLibrary Decode Functions '}
      function TMir3_TextureLibrary.DecodeFrame32ToMir3_D3D(const AFrame: Integer; var APImageRecord: PImageHeaderD3D): Boolean;
      var                           
        X, Y, H, W   : Integer;
        FPosition    : Integer;
        FCount       : Integer;
        FHelp        : Integer;
        FIncX        : Integer;
        FBGR         : Integer;
        PBGR         : PInteger;
        FEncodeRGBA  : Integer;
        PEncodeRGBA  : PInteger;
        FColorCount  : Integer;
        FTexture     : ITexture;
        FD3DLockRect : TD3DLocked_Rect;
        FFilePointer : PByte;
      begin
        {$IFDEF DEVELOP_PERFORMANCE_COUNTER}
          // Using to get the Performance of this Decoder
          GPerformanceCounter(False).StartPerformanceMeasure;
        {$ENDIF}
        Result := False;
        case FUsingLibType of
          LIB_TYPE_1 ,
          LIB_TYPE_2 : begin //WIL-WIX
            {$REGION ' - Get DX Image from WIL / WIX '}
            if (FWIX = nil) or (FWIL = nil) then Exit;
            PEncodeRGBA  := @FEncodeRGBA;
            PBGR         := @FBGR;
            // Copy Image Position from Wix file (use Type check)
            CopyMemory(@FPosition, PInteger(Integer(FWIX) + ((AFrame * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), SizeOf(FPosition));
            if FPosition = 0 then
            begin
              Result := False;
              Exit;
            end;
            FFilePointer := PByte(Integer(FWIL) + FPosition);
            // Copy Image Information from Wil file and set size to Power of 2
            CopyMemory(@FHeaderWILImage, FFilePointer, sizeof(TWIL_Img_Header));
            FPosition := GetLibTypeOffset(FHeaderWilInfo.whLib_Type);
            Inc(FFilePointer, FPosition);
            MakePowerOfTwoHW(H, W, FHeaderWILImage.imgHeight, FHeaderWILImage.imgWidth);
            // Get 2 ms more power and save some memory
            if FHeaderWILImage.imgHeight = 768 then H:=768;

            // Check and Setup Image Record
            if not Assigned(APImageRecord) then
              new(APImageRecord)
            else if APImageRecord^.ihD3DTexture <> nil then
                   APImageRecord^.ihD3DTexture := nil;

            // Create Texture with POW2 Size and Lock the Texture
            FTexture     := GRenderEngine.Texture_Create(W, H);
            FD3DLockRect := FTexture.LockExt(False);
            try
              {$REGION ' - Decoder '}
              for Y:=0 to FHeaderWILImage.imgHeight-1 do
              begin
                FIncX := 0;  X := 0; FCount := 0;
                CopyMemory(@FCount, FFilePointer, sizeOf(Word));
                Inc(FFilePointer, 2);
                while X < FCount do
                begin
                  Inc(X);
                  case FFilePointer^ of
                    192: begin
                           Inc(X);
                           Inc(FFilePointer, 2);
                           Inc(FIncX, PWord(Integer(FFilePointer))^);
                           Inc(FFilePointer, 2);
                         end;//case in
                    193: begin
                           Inc(FFilePointer, 2); Inc(X); FHelp := 0; FColorCount :=0;
                           CopyMemory(@FColorCount, FFilePointer, 2);
                           Inc(FFilePointer, 2);
                           while FHelp < FColorCount do
                           begin
                             PEncodeRGBA^ := 0;
                             CopyMemory(PEncodeRGBA, FFilePointer, 2);
                             PBGR^ := ($FF00 or ((((PEncodeRGBA^ and 63488) shr 11) * 8))) shl 8;
                             PBGR^ := (PBGR^ or ((((PEncodeRGBA^ and  2016) shr  5) * 4))) shl 8;
                             PBGR^ := (PBGR^ or ((((PEncodeRGBA^ and    31) shr  0) * 8)));
                             PInteger(Integer(FD3DLockRect.pBits) + Y * FD3DLockRect.Pitch + FIncX * 4 )^ := PBGR^;
                             Inc(X); Inc(FFilePointer, 2); Inc(FHelp); Inc(FIncX);
                           end;//while
                         end;//case in
                    194: begin
                           Inc(FFilePointer, 2); Inc(X); FHelp := 0; FColorCount :=0;
                           CopyMemory(@FColorCount, FFilePointer, 2);
                           Inc(FFilePointer, 2);
                           while FHelp < FColorCount do
                           begin
                             PEncodeRGBA^ := 0;
                             CopyMemory(PEncodeRGBA, FFilePointer, 2);
                             PBGR^ := ($7F00 or ((((PEncodeRGBA^ and 63488) shr 11) * 8))) shl 8;
                             PBGR^ := (PBGR^ or ((((PEncodeRGBA^ and  2016) shr  5) * 4))) shl 8;
                             PBGR^ := (PBGR^ or ((((PEncodeRGBA^ and    31) shr  0) * 8)));
                             PInteger(Integer(FD3DLockRect.pBits) + Y * FD3DLockRect.Pitch + FIncX * 4 )^ := PBGR^;
                             Inc(X); Inc(FFilePointer, 2); Inc(FHelp); Inc(FIncX);
                           end;//while
                         end;//case in
                    else X := FCount;
                  end;//case
                end;//while
              end;//for
              {$ENDREGION}

              FTexture.Unlock;
              APImageRecord.ihD3DTexture      := TMir3_Texture.Create;
              APImageRecord.ihOffset_X        := FHeaderWILImage.imgOffset_X;
              APImageRecord.ihOffset_Y        := FHeaderWILImage.imgOffset_Y;
              APImageRecord.ihOffsetShadow_X  := FHeaderWILImage.imgShadow_Offset_X;
              APImageRecord.ihOffsetShadow_Y  := FHeaderWILImage.imgShadow_Offset_Y;
              APImageRecord.ihTypeShadow      := FHeaderWILImage.imgShadow_type;
              APImageRecord.ihORG_Width       := FHeaderWILImage.imgWidth;
              APImageRecord.ihORG_Height      := FHeaderWILImage.imgHeight;
              APImageRecord.ihPO2_Width       := W;
              APImageRecord.ihPO2_Height      := H;
              APImageRecord.ihD3DTexture.LoadFromITexture(FTexture, FHeaderWILImage.imgWidth, FHeaderWILImage.imgHeight);
            except
              FTexture.Unlock;
            end;
            {$IFDEF DEVELOP_PERFORMANCE_COUNTER}
              GRenderEngine.System_Log('DEBUG Decode Time (WIL) : ' + GPerformanceCounter.StopAndGetMircoTime +
              ' - Real Texture Size : ' + IntToStr(FHeaderWILImage.imgWidth) + 'x' + IntToStr(FHeaderWILImage.imgHeight)+
              ' - Pow2 Texture Size : ' + IntToStr(W) + 'x' + IntToStr(H) );
            {$ENDIF}
            {$ENDREGION}
          end;
          LIB_TYPE_4 : begin //LMT
            {$REGION ' - Get DX Image from LMT       '}
            if (FLMT = nil) then Exit;
            // Copy Image Position from LMT file (use Type check)
            CopyMemory(@FPosition, PInteger(Integer(FLMT) + (((AFrame)* 4) + GetLibTypeWixOffset(FHeaderLMTInfo.lhLib_Type))), SizeOf(FPosition));
            if FPosition = 0 then
            begin
              Result := False;
              Exit;
            end;
            
            Inc(FPosition, FBeginImage);
            CopyMemory(@FHeaderLMTImage, PInteger(Integer(FLMT) + FPosition), sizeof(TLMT_Img_Header));
            Inc(FPosition, 17);
            MakePowerOfTwoHW(H, W, FHeaderLMTImage.imgHeight, FHeaderLMTImage.imgWidth);
            // Get 2 ms more power and save some memory
            if FHeaderLMTImage.imgHeight = 768 then H:=768;
            
            // Check and Setup Image Record
            if not Assigned(APImageRecord) then
              new(APImageRecord)
            else if APImageRecord^.ihD3DTexture <> nil then
                   APImageRecord^.ihD3DTexture := nil;

            // Create Texture and load image from file
            FTexture := GRenderEngine.Texture_LoadMemory(PInteger(Integer(FLMT)+FPosition), FHeaderLMTImage.imgFileSize, D3DFMT_A8R8G8B8);
            APImageRecord.ihD3DTexture      := TMir3_Texture.Create;
            APImageRecord.ihOffset_X        := FHeaderLMTImage.imgOffset_X;
            APImageRecord.ihOffset_Y        := FHeaderLMTImage.imgOffset_Y;
            APImageRecord.ihOffsetShadow_X  := FHeaderLMTImage.imgShadow_Offset_X;
            APImageRecord.ihOffsetShadow_Y  := FHeaderLMTImage.imgShadow_Offset_Y;
            APImageRecord.ihTypeShadow      := FHeaderLMTImage.imgShadow_type;
            APImageRecord.ihORG_Width       := FHeaderLMTImage.imgWidth;
            APImageRecord.ihORG_Height      := FHeaderLMTImage.imgHeight;
            APImageRecord.ihPO2_Width       := W;
            APImageRecord.ihPO2_Height      := H;
            APImageRecord.ihD3DTexture.LoadFromITexture(FTexture, FHeaderLMTImage.imgWidth, FHeaderLMTImage.imgHeight);
            {$IFDEF DEVELOP_PERFORMANCE_COUNTER}
              GRenderEngine.System_Log('DEBUG Decode Time (LMT) : ' + GPerformanceCounter.StopAndGetMircoTime +
              ' - Real Texture Size : ' + IntToStr(FHeaderLMTImage.imgWidth) + 'x' + IntToStr(FHeaderLMTImage.imgHeight)+
              ' - Pow2 Texture Size : ' + IntToStr(W) + 'x' + IntToStr(H) );
            {$ENDIF}
            {$ENDREGION}
          end;
        end;
      end;

      function TMir3_TextureLibrary.DecodeFrame32ToMir3D3DX(AFrame: Integer; var APImageRecord: PImageHeaderD3D): Boolean;
      var
        FPosition    : Integer;
        X, Y, H, W   : Integer;
        FHelp        : Integer;
        FEncodeRGBA  : Integer; PEncodeRGBA  : PInteger;
        FColorCount  : Integer; PColorCount  : PInteger;
        FCount       : Integer; PCount       : PInteger;
        FIncX        : Integer; PIncX        : PInteger;
        FBGR         : Integer; PBGR         : PInteger;
        PosCount     : LongInt;
        FTexture     : ITexture;
        d3dlr        : TD3DLocked_Rect;
      begin
        {$IFDEF DEVELOP_PERFORMANCE_COUNTER}
          // Using to get the Performance of this Decoder
          GPerformanceCounter(False).StartPerformanceMeasure;
        {$ENDIF}

        Result := False;
        if (FWIX = nil) or (FWIL = nil) then Exit;

        PEncodeRGBA       := @FEncodeRGBA;
        PColorCount       := @FColorCount;
        PCount            := @FCount;
        PIncX             := @FIncX;
        PBGR              := @FBGR;

        CopyMemory(@FPosition   , PInteger(Integer(FWIX) + ((AFrame * 4) + GetLibTypeWixOffset(FHeaderWilInfo.whLib_Type))), sizeof(FPosition));
        if FPosition = 0 then
        begin
          Result := False;
          Exit;
        end;
        CopyMemory(@FHeaderWILImage, PInteger(Integer(FWIL) + FPosition)         , sizeof(TWIL_Img_Header));
        PosCount := FPosition + GetLibTypeOffset(FHeaderWilInfo.whLib_Type);
        MakePowerOfTwoHW(H, W, FHeaderWILImage.imgHeight, FHeaderWILImage.imgWidth);

        if not Assigned(APImageRecord) then
          new(APImageRecord)
        else if APImageRecord^.ihD3DTexture <> nil then
               APImageRecord^.ihD3DTexture := nil;

        FTexture := GRenderEngine.Texture_Create(W, H);
        d3dlr    := FTexture.LockExt(False);
        try
          {$REGION ' - Decoder '}
          for Y:=0 to FHeaderWILImage.imgHeight-1 do
          begin
            PIncX^ := 0;  X := 0; PCount^ := 0;
            CopyMemory(PCount, PInteger(Integer(FWIL)+ PosCount), sizeOf(Word));
            Inc(PosCount, 2);
            while X < PCount^ do
            begin
              Inc(X);
              case PByte(Integer(FWIL)+ PosCount)^ of
                192: begin
                       Inc(x);
                       Inc(PosCount, 2);
                       Inc(PIncX^, PWord(Integer(FWIL)+ PosCount)^);
                       Inc(PosCount, 2);
                     end;//case in
                193: begin
                       Inc(PosCount, 2); Inc(X); FHelp := 0; PColorCount^ := 0;
                       CopyMemory(PColorCount, PInteger(Integer(FWIL)+ PosCount), 2);
                       Inc(PosCount, 2);
                       while FHelp < PColorCount^ do
                       begin
                         PEncodeRGBA^ := 0;
                         CopyMemory(PEncodeRGBA, PInteger(Integer(FWIL)+ PosCount), 2);
                         PBGR^ := ($FF00 or (Trunc((((PEncodeRGBA^ and 63488) shr 11) * 8.225806) + 0.5))) shl 8;
                         PBGR^ := (PBGR^ or (Trunc((((PEncodeRGBA^ and  2016) shr  5) * 4.047619) + 0.5))) shl 8;
                         PBGR^ := (PBGR^ or (Trunc((((PEncodeRGBA^ and    31) shr  0) * 8.225806) + 0.5)));
                         PInteger(Integer(d3dlr.pBits) + Y * d3dlr.Pitch + PIncX^ * 4 )^ := PBGR^;
                         Inc(x); Inc(PosCount, 2); Inc(FHelp); Inc(PIncX^);
                       end;//while
                     end;//case in
                194: begin
                       Inc(PosCount, 2); Inc(X); FHelp := 0; PColorCount^ := 0;
                       CopyMemory(PColorCount, PInteger(Integer(FWIL)+ PosCount), 2);
                       Inc(PosCount, 2);
                       while FHelp < PColorCount^ do
                       begin
                         PEncodeRGBA^ := 0;
                         CopyMemory(PEncodeRGBA, PInteger(Integer(FWIL)+ PosCount), 2);
                         PBGR^ := ($7F00 or (Trunc((((PEncodeRGBA^ and 63488) shr 11) * 8.225806) + 0.5))) shl 8;
                         PBGR^ := (PBGR^ or (Trunc((((PEncodeRGBA^ and  2016) shr  5) * 4.047619) + 0.5))) shl 8;
                         PBGR^ := (PBGR^ or (Trunc((((PEncodeRGBA^ and    31) shr  0) * 8.225806) + 0.5)));
                         PInteger(Integer(d3dlr.pBits) + Y * d3dlr.Pitch + PIncX^ * 4 )^ := PBGR^;
                         Inc(X); Inc(PosCount, 2); Inc(FHelp); Inc(PIncX^);
                       end;//while
                     end;//case in
                else X := PCount^;
              end;//case
            end;//while
          end;//for
          {$ENDREGION}
          FTexture.Unlock;
          APImageRecord.ihD3DTexture      := TMir3_Texture.Create;
          APImageRecord.ihOffset_X        := FHeaderWILImage.imgOffset_X;
          APImageRecord.ihOffset_Y        := FHeaderWILImage.imgOffset_Y;
          APImageRecord.ihOffsetShadow_X  := FHeaderWILImage.imgShadow_Offset_X;
          APImageRecord.ihOffsetShadow_Y  := FHeaderWILImage.imgShadow_Offset_Y;
          APImageRecord.ihTypeShadow      := FHeaderWILImage.imgShadow_type;
          APImageRecord.ihORG_Width       := FHeaderWILImage.imgWidth;
          APImageRecord.ihORG_Height      := FHeaderWILImage.imgHeight;
          APImageRecord.ihPO2_Width       := W;
          APImageRecord.ihPO2_Height      := H;
          APImageRecord.ihD3DTexture.LoadFromITexture(FTexture, FHeaderWILImage.imgWidth, FHeaderWILImage.imgHeight);
        except
          FTexture.Unlock;
        end;
        {$IFDEF DEVELOP_PERFORMANCE_COUNTER}
          GRenderEngine.System_Log('DEBUG Decode Time : ' + GPerformanceCounter.StopAndGetMircoTime +
          ' - Real Texture Size : ' + IntToStr(FHeaderWILImage.imgWidth) + 'x' + IntToStr(FHeaderWILImage.imgHeight)+
          ' - Pow2 Texture Size : ' + IntToStr(W) + 'x' + IntToStr(H) );
        {$ENDIF}
      end;

      function TMir3_TextureLibrary.DecodeFrame32ToMir3D3DX(AFrame: Integer; var APImageRecord: PImageHeaderD3D;  AColor: Word): Boolean;
      begin

      end;
  {$ENDREGION}

  {$REGION ' - TMir3_FileMapping '}
    constructor TMir3_FileMapping.Create;
    begin
      inherited Create;
      FStaticFileIndex := nil;
      SetLength(FStaticFileIndex, MAX_FILE_MAPPING);
    end;
    
    destructor TMir3_FileMapping.Destroy;
    var
      I : Integer;
    begin
      if Assigned(FStaticFileIndex) then
      begin
        for I := Low(FStaticFileIndex) to High(FStaticFileIndex) do
        begin
          if Assigned(FStaticFileIndex[I]) then
          begin
            Dispose(FStaticFileIndex[I]);
            FStaticFileIndex[I] := nil;
          end;
        end;
      end;
      FStaticFileIndex := nil;
      inherited;
    end;
    
    function TMir3_FileMapping.GetStaticFile(AIndex: Integer): Pointer;
    begin
      Result := nil;
      if Assigned(FStaticFileIndex) then
      begin
        Result := FStaticFileIndex[AIndex];
      end;
    end;
    
    procedure TMir3_FileMapping.SetStaticFile(AIndex: Integer; AFilePointer: Pointer);
    begin
      FStaticFileIndex[AIndex] := AFilePointer;
    end;
    
    procedure TMir3_FileMapping.CleanUpStaticFileMapping(AIndex: Integer);
    begin
      FStaticFileIndex[AIndex] := nil;
    end;
  {$ENDREGION}

  {$REGION ' - TMir3_ImageManager '}
    constructor TMir3_Texture.Create();
    begin
      Inherited;
      FLastR          := 0;
      FLastG          := 0;
      FLastB          := 0;      
      FQuad.Tex       := nil;
      FStaticImage    := nil;
      FGrayScaleImage := nil;
      FColorImage     := nil;      
    end;
    
    destructor TMir3_Texture.Destroy();
    begin      
      FQuad.Tex.Handle := nil;
      FQuad.Tex        := nil;
     
     if Assigned(FColorImage) then
        FStaticImage.Handle := nil;
      FStaticImage        := nil;

      if Assigned(FGrayScaleImage) then
        FGrayScaleImage.Handle := nil;
      FGrayScaleImage        := nil;      
      
      if Assigned(FColorImage) then
        FColorImage.Handle := nil;
      FColorImage        := nil;  
      
      Inherited;
    end;

    function TMir3_Texture.GetPixels(AX, AY: Integer): LongWord;
    var
      OldColP : PLongWord;
    begin
      if Assigned(FStaticImage) then
      begin
        if ((AX > FWidth) or (AX < 0)) or ((AY > FHeight) or (AY < 0)) then
        begin
          Result := 0;
          exit;
        end;
    
        OldColP := FStaticImage.Lock(True);
        Inc(OldColp, AY * FTexWidth + AX);
        Result := OldColp^;
        FStaticImage.Unlock;
      end else Result := 0;
    end;
    
    procedure TMir3_Texture.ColorToGray; 
    var
      FOldColor : PLongWord;
      FTmpColor : PLongWord;
      I, J      : Integer;
      FGray     : byte;
    begin
      if Assigned(FStaticImage) then
      begin
        // If no Gray Image set in FGrayScaleImage then create new one
        // If FGrayScaleImage set, then do nothing and go out here
        If not Assigned(FGrayScaleImage) then
        begin
          FGrayScaleImage := GRenderEngine.Texture_Create(Self.FTexWidth, Self.FTexHeight);
          FOldColor := FStaticImage.Lock(False);
          FTmpColor := FGrayScaleImage.Lock(True);
          for I := 0 to FHeight - 1 do
          begin
            for J := 0 to FWidth - 1 do
            begin
              if FOldColor^ = 0 then
              begin
                Inc(FOldColor);
                Inc(FTmpColor);
                Continue;
              end else begin
                FGray      := GetG(FOldColor^);
                FTmpColor^ := ARGB(255, FGray, FGray, FGray);
              end;
              Inc(FOldColor);
              inc(FTmpColor);
            end;
            Inc(FOldColor, FTexWidth - FWidth);
            Inc(FTmpColor, FTexWidth - FWidth);
          end;
          FStaticImage.Unlock;
          FGrayScaleImage.Unlock;
        end;  
      end;
    end;
    
    
    procedure TMir3_Texture.FlipQuadTexture(const ATextureID: Integer);
    begin
      case ATextureID of
        0 : begin
          FQuad.Tex := FStaticImage;
        end;
        1 : begin
          FQuad.Tex := FGrayScaleImage;
        end;
        2 : begin
          FQuad.Tex := FColorImage;
        end;          
      end;
    end;    
    
    procedure TMir3_Texture.ChangeColor(const R, G, B: Byte);
    var
      OldColP           : PLongWord;
      TmpColP           : PLongWord;
      I, J              : Integer;
      R1, G1, B1, A1    : byte;
    begin
      if Assigned(FStaticImage) then
      begin
        // Test has color change or not (get more speed up)
        if (FLastR <> R) or (FLastG <> G) or (FLastB <> B) then
        begin
          // if the color changed then cleanup here
          if Assigned(FColorImage) then
            FColorImage.Handle := nil;
          FColorImage := nil;  
        end;
        // If no Image set with color in FColorImage then create new one
        // If FColorImage set, then do nothing and go out here
        if not Assigned(FColorImage) then
        begin      
          FLastR := R; FLastG := G; FLastB := B;
          FColorImage := GRenderEngine.Texture_Create(self.FTexWidth, Self.FTexHeight);
          OldColP     := FStaticImage.Lock(False);
          TmpColP     := FColorImage.Lock(True);
          for I := 0 to FHeight - 1 do
          begin
            for J := 0 to FWidth - 1 do
            begin
              if OldColP^ = 0 then
              begin
                Inc(OldColP);
                Inc(tmpColP);
                Continue;
              end;
              R1 := GetR(OldColP^);
              G1 := GetG(OldColP^);
              B1 := GetB(OldColP^);
              if (R1 < 128) Or (G1 < 128) Or (B1 < 128) then
              begin
                TmpColp^ := OldColP^;
                Inc(OldColP);
                Inc(tmpColP);
                Continue;
              end;
              A1 := GetA(OldColP^);
              if (ABS(R1 - G1) In [0..15]) And (ABS(G1 - B1) In [0..15]) then
              begin
                TmpColp^ := ARGB(A1, R, G, B);
                Inc(OldColP);
                Inc(tmpColP);
              end else begin
                TmpColp^ := OldColP^;
                Inc(OldColP);
                Inc(tmpColP);
              end;
            end;
            Inc(OldColP, FTexWidth - FWidth);
            Inc(TmpColP, FTexWidth - FWidth);
          end;
          FStaticImage.Unlock;
          FColorImage.Unlock;
        end;
      end;  
    end;
    
    procedure TMir3_Texture.LoadFromITexture(const AImages: ITexture; AWidth, AHeight: Integer);
    begin
      FStaticImage       := AImages;
      FTexWidth          := FStaticImage.GetWidth();
      FTexHeight         := FStaticImage.GetHeight();
      FWidth             := AWidth;
      FHeight            := AHeight;
      FQuad.Tex          := FStaticImage;

      FQuad.V[0].TX      := 0;                     //left
      FQuad.V[0].TY      := 0;
      FQuad.V[1].TX      := FWidth  / FTexWidth;
      FQuad.V[1].TY      := 0;                     //right
      FQuad.V[2].TX      := FWidth  / FTexWidth;
      FQuad.V[2].TY      := FHeight / FTexHeight;  //rightbottom
      FQuad.V[3].TX      := 0;
      FQuad.V[3].TY      := FHeight / FTexHeight;  //leftbottom

      FQuad.Blend        := BLEND_DEFAULT;
      FQuad.V[0].Col     := $FFFFFFFF;
      FQuad.V[1].Col     := $FFFFFFFF;
      FQuad.V[2].Col     := $FFFFFFFF;
      FQuad.V[3].Col     := $FFFFFFFF;
      FClientRect.Left   := 0;
      FClientRect.Top    := 0;
      FClientRect.Right  := FWidth;
      FClientRect.Bottom := FHeight;
    end;
    
  {$ENDREGION}


constructor TMir3_FileManager.Create(const AUsingLibType: TFileLibType = LIB_TYPE_2);
begin
  Inherited Create;
  FUsingLibType   := AUsingLibType;
  FTextureManager := TMir3_FileMapping.Create;
  GStopThreads    := False;
  FThreadsRunning := 1;
  FManager        := TMir3_FileCashManager.Create(Self);
  FManager.Resume;
end;

destructor TMir3_FileManager.Destroy();
var
  I, I2 : Integer;
  FF: PFileInformation;
begin
  FManager.Terminate;
  FManager.WaitFor;

  for I := 0 to MAX_FILE_MAPPING do
  begin
    FF := FTextureManager.GetStaticFile(I);
    if Assigned(FF) then
    begin
      if Assigned(FF.fiImageList) then
      begin
        for I2 := Low(FF.fiImageList) to High(FF.fiImageList) do
        begin
          if Assigned(FF.fiImageList[I2]) then
          begin
            FreeAndNil(FF.fiImageList[I2].ihD3DTexture);
            Dispose(FF.fiImageList[I2]);
          end;
        end;
        SetLength(FF.fiImageList, 0);
      end;
      if Assigned(FF.fiImageLib) then
        FreeAndNil(FF.fiImageLib);
    end;
  end;

  if Assigned(FTextureManager) then
    FreeAndNil(FTextureManager);

  if Assigned(FManager) then
    FreeAndNil(FManager);
  Inherited;
end;

function TMir3_FileManager.TestIfInList(AType: Byte; AFileID: Integer; AUsingLibType: TFileLibType = LIB_TYPE_2) : PFileInformation;
var
  FFileInfo : PFileInformation;
  
  function GetUnloadInfo: Boolean;
  begin
    Result := True;
    case AFileID of
      0..79 :;
      // Hold in Memory
      GAME_TEXTURE_GAMEINTER_INT  ,  
      GAME_TEXTURE_GAMEINTER1_INT , 
      GAME_TEXTURE_GAMEINTER2_INT : Result := False;       
    end;
  end;
  
begin
  new(FFileInfo);
  FFileInfo.fiFileID          := AFileID;
  FFileInfo.fiImageOpenCount  := 0;
  FFileInfo.fiImageMemoryUsag := 0;
  FFileInfo.fiUnloadFile      := GetUnloadInfo;
  FFileInfo.fiImageLib        := TMir3_TextureLibrary.Create(AUsingLibType);
  FFileInfo.fiImageLib.Open(GetFileNameByID(AFileID, AUsingLibType));
  FFileInfo.fiLastUseTick     := GetTickCount;
  FFileInfo.fiFirstUseTick    := GetTickCount;
  FTextureManager.SetStaticFile(AFileID, FFileInfo);
  Result := FFileInfo;
end;

function TMir3_FileManager.GetFileNameByID(AIndexID: Integer; AUsingLibType: TFileLibType = LIB_TYPE_2): String;
begin
  Result := '';
  case AIndexID of
    {$REGION ' - Map Texture Data            '}
     0: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_TILESC;
     1: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_TILES30C;
     2: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_TILES5C;
     3: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_SMTILESC;
     4: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_HOUSESC;
     5: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_CLIFFSC;
     6: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_DUNGEONSC;
     7: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_INNERSC;
     8: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_FUNITURESC;
     9: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_WALLSC;
    10: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_SMOBJECTSC;
    11: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_ANIMATIONSC;
    12: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_OBJECT1C;
    13: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_OBJECT2C;
    14: Result := MAP_TEXTURE_PHAT_DATA + MAP_TEXTURE_FREEUSER;
    {$ENDREGION}
    {$REGION ' - Map Texture Wood            '}
    15: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_TILESC;
    16: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_TILES30C;
    17: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_TILES5C;
    18: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_SMTILESC;
    19: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_HOUSESC;
    20: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_CLIFFSC;
    21: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_DUNGEONSC;
    22: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_INNERSC;
    23: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_FUNITURESC;
    24: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_WALLSC;
    25: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_SMOBJECTSC;
    26: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_ANIMATIONSC;
    27: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_OBJECT1C;
    28: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_OBJECT2C;
    29: Result := MAP_TEXTURE_PHAT_WOOD + MAP_TEXTURE_FREEUSER;
    {$ENDREGION}
    {$REGION ' - Map Texture Sand            '}
    30: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_TILESC;
    31: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_TILES30C;
    32: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_TILES5C;
    33: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_SMTILESC;
    34: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_HOUSESC;
    35: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_CLIFFSC;
    36: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_DUNGEONSC;
    37: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_INNERSC;
    38: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_FUNITURESC;
    39: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_WALLSC;
    40: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_SMOBJECTSC;
    41: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_ANIMATIONSC;
    42: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_OBJECT1C;
    43: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_OBJECT2C;
    44: Result := MAP_TEXTURE_PHAT_SAND + MAP_TEXTURE_FREEUSER;
    {$ENDREGION}
    {$REGION ' - Map Texture Snow            '}
    45: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_TILESC;
    46: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_TILES30C;
    47: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_TILES5C;
    48: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_SMTILESC;
    49: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_HOUSESC;
    50: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_CLIFFSC;
    51: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_DUNGEONSC;
    52: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_INNERSC;
    53: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_FUNITURESC;
    54: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_WALLSC;
    55: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_SMOBJECTSC;
    56: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_ANIMATIONSC;
    57: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_OBJECT1C;
    58: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_OBJECT2C;
    59: Result := MAP_TEXTURE_PHAT_SNOW + MAP_TEXTURE_FREEUSER;
    {$ENDREGION}
    {$REGION ' - Map Texture Forest          '}
    60: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_TILESC;
    61: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_TILES30C;
    62: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_TILES5C;
    63: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_SMTILESC;
    64: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_HOUSESC;
    65: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_CLIFFSC;
    66: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_DUNGEONSC;
    67: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_INNERSC;
    68: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_FUNITURESC;
    69: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_WALLSC;
    70: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_SMOBJECTSC;
    71: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_ANIMATIONSC;
    72: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_OBJECT1C;
    73: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_OBJECT2C;
    74: Result := MAP_TEXTURE_PHAT_FOREST + MAP_TEXTURE_FREEUSER;
    {$ENDREGION}
    {$REGION ' - Game Texture (start pos 80) '}
    80: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_INTERFACE1C;
    81: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_PROGUSE;
    82: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_GAMEINTER;
    83: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_GAMEINTER1;
    84: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_GAMEINTER2;
    85: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_NPC;
    86: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_NPCFACE;
    87: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_MICON;
    88: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_CBICONS;
    89: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_MAPICON;
    90: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_MMAP;
    91: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_FMMAP;
    92: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_INVENTORY;
    93: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_STOREITEM;
    94: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_SALEITEM;
    95: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_EQUIP; 
    96: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_EQUIP_EFFECT_FULL;    
    97: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_EQUIP_EFFECT_FULL_EX1;
    98: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_EQUIP_EFFECT_PART;
    99: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_EQUIP_EFFECT_UI;     
   100: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_GROUND;
   101: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_PEQUIPH1;
   102: Result := MAP_TEXTURE_PHAT_DATA + GAME_TEXTURE_PEQUIPB1;
    {$ENDREGION}
    {$REGION ' - Human Texture               '}
   150: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HUM_1;
   151: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HUM_1;
   152: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HUM_2;
   153: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HUM_2;
   154: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HUM_3;
   155: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HUM_3;
   156: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HUM_4;
   157: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HUM_4;
   158: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HUM_5;
   159: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HUM_5;
   160: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HUM_6;
   161: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HUM_6;
  { Human Wings }
   180: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_SHUM_1;
   181: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_SHUM_1;
   182: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_SHUM_2;
   183: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_SHUM_2;
  { Human Hair }
   190: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HAIR_1;
   191: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HAIR_1;
   192: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HAIR_2;
   193: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HAIR_2;
   194: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HAIR_3;
   195: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HAIR_3;
   196: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HAIR_4;
   197: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HAIR_4;
  { Human Helmet }
   200: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HELMET_1;
   201: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HELMET_1;
   202: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HELMET_2;
   203: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HELMET_2;
   204: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HELMET_3;
   205: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HELMET_3;
   206: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HELMET_4;
   207: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HELMET_4;
   208: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HELMET_5;
   209: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HELMET_5;
   210: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_HELMET_6;
   211: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_HELMET_6;
  { Human Weapon }
   220: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_1;
   221: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_1;
   222: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_2;
   223: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_2;
   224: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_3;
   225: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_3;
   226: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_4;
   227: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_4;
   228: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_5;
   229: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_5;
   230: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_6;
   231: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_6;
   232: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_7;
   233: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_7;
   234: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_8;
   235: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_8;
   236: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_9;
   237: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_9;
   238: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_10;
   239: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_10;
   240: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_11;
   241: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_11;
   242: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_12;
   243: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_12;
  { Human Weapon Assassin }
   250: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_A1;
   251: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_A1;
   252: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_A2;
   253: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_A2;
   254: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_ADL1;
   255: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_ADL1;
   256: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_ADL2;
   257: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_ADL2;
   258: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_ADR1;
   259: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_ADR1;
   260: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_ADR2;
   261: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_ADR2;
   262: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_AOH1;
   263: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_AOH1;
   264: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_AOH2;
   265: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_AOH2;
   266: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_M_WEAPON_AOH3;
   267: Result := MAP_TEXTURE_PHAT_DATA + HUMAN_TEXTURE_WM_WEAPON_AOH3;
    {$ENDREGION}
    {$REGION ' - Human Monster Horse         '}
   281: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_SHADOW;
   282: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_DARK_EFFECT;
   283: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_1;
   284: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_2;
   285: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_3;
   286: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_4;
   287: Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_HORSE_5;
    {$ENDREGION}
    {$REGION ' - Human Magic                 '}
   290: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_TEXTURE_1;
   291: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_TEXTURE_2;
   292: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_TEXTURE_3;
   293: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_TEXTURE_4;
   294: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_TEXTURE_5;
   295: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_TEXTURE_6;
    {$ENDREGION}
    {$REGION ' - Human Monster Magic         '}
   300: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_1;
   301: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_2;
   302: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_3;
   303: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_4;
   304: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_5;
   305: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_6;
   306: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_7;
   307: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_8;
   308: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_9;
   309: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_10;
   310: Result := MAP_TEXTURE_PHAT_DATA + MAGIC_MONSTER_TEXTURE_11;
    {$ENDREGION}
   330..429 : Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_NORMAL;
   430..529 : Result := MAP_TEXTURE_PHAT_DATA + MONSTER_TEXTURE_SHADOW;
  end;
  case AUsingLibType of
    LIB_TYPE_1,
    LIB_TYPE_2: Result := Result + '.wil';
    LIB_TYPE_3: Result := Result + '.wtl';
    LIB_TYPE_4: Result := Result + '.lmt';
  end;
end;

function TMir3_FileManager.GetFileMapping : TMir3_FileMapping;
begin
  Result := FTextureManager;
end;

function TMir3_FileManager.GetImageD3DDirect(const AImageID, AFileID: Integer): PImageHeaderD3D;
var
  FFileInfo : PFileInformation;
  FImageID  : Integer;

  //This little hack is need for the gui system
  function GetImageOffset(AValue: Integer): Integer;
  begin
    case AFileID of
      0..75 : Result :=  AValue;
      else    Result := (AValue-1);
    end;
  end;

begin
  try
    FImageID  := GetImageOffset(AImageID);
    FFileInfo := FTextureManager.GetStaticFile(AFileID);
    if not Assigned(FFileInfo) then
    begin
      FFileInfo := TestIfInList(1,AFileID, FUsingLibType);
    end;
    if High(FFileInfo.fiImageList)+1 <= FImageID then
    begin
      SetLength(FFileInfo.fiImageList, FFileInfo.fiImageLib.GetLastImageInt+1);
    end;
    if Assigned(FFileInfo.fiImageList[FImageID]) and Assigned(FFileInfo.fiImageList[FImageID].ihD3DTexture) then
    begin
      Result                                       := FFileInfo.fiImageList[FImageID];
      FFileInfo.fiImageList[FImageID].ihUseTime    := GetTickCount;
      FFileInfo.fiLastUseTick                      := GetTickCount;
    end else begin
      FFileInfo.fiImageLib.DecodeFrame32ToMir3_D3D(FImageID, FFileInfo.fiImageList[FImageID]);
      if Assigned(FFileInfo.fiImageList[FImageID]) and Assigned(FFileInfo.fiImageList[FImageID].ihD3DTexture) then
      begin
        FFileInfo.fiImageList[FImageID].ihUseTime := GetTickCount;
        FFileInfo.fiLastUseTick                   := GetTickCount;
        Inc(FFileInfo.fiImageOpenCount);
        //IncExtended(FFileInfo.fiImageMemoryUsag, ((FFileInfo.fiImageList[FImageID].ihPO2_Width * FFileInfo.fiImageList[FImageID].ihPO2_Height) * 4));
      end;
      Result := FFileInfo.fiImageList[FImageID];
    end;
  except
    Result := nil;
    GRenderEngine.System_Log('ERROR:DRAW::DIRECT::IMAGEID('+IntToStr(AImageID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;
end;

procedure TMir3_FileManager.DrawColor(AImage: TMir3_Texture; AX, AY: Integer; AColor: Cardinal);
Var
  FColor            : Cardinal;
Begin
  FColor := AImage.FQuad.V[0].Col;
  AImage.FQuad.V[0].X := AX;
  AImage.FQuad.V[0].Y := AY;
  AImage.FQuad.V[1].X := AX + AImage.FWidth;
  AImage.FQuad.V[1].Y := AY;
  AImage.FQuad.V[2].X := AX + AImage.FWidth;
  AImage.FQuad.V[2].Y := AY + AImage.FHeight;
  AImage.FQuad.V[3].X := AX;
  AImage.FQuad.V[3].Y := AY + AImage.FHeight;
  AImage.FQuad.Blend  := BLEND_DEFAULT;//Blend_Add;
  AImage.FQuad.V[0].Col := AColor;
  AImage.FQuad.V[1].Col := AColor;
  AImage.FQuad.V[2].Col := AColor;
  AImage.FQuad.V[3].Col := AColor;
  GRenderEngine.Gfx_RenderQuad(AImage.FQuad);

  AImage.FQuad.V[0].Col := FColor;
  AImage.FQuad.V[1].Col := FColor;
  AImage.FQuad.V[2].Col := FColor;
  AImage.FQuad.V[3].Col := FColor;
End;

procedure TMir3_FileManager.RenderVideo(AType: Byte);
var
  FLength : Int64;
begin
  CoInitialize(nil);
  CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC, IID_IGraphBuilder, FGraphBuilder);
  FGraphBuilder.QueryInterface(IVideoWindow     , FVideoWindow);
  FGraphBuilder.QueryInterface(IID_IMediaControl, FMediaControl);
  FGraphBuilder.QueryInterface(IID_IMediaEvent  , FMediaEvent);
  FGraphBuilder.QueryInterface(IID_IMediaSeeking, FMediaSeeking);
  FGraphBuilder.QueryInterface(IID_IBasicAudio  , FBasicAudio);
  case AType of
    0: begin
      if FAILED(FGraphBuilder.RenderFile(MAP_TEXTURE_PHAT_DATA + VIDEO_GAME_START, nil)) then
      begin
        GRenderEngine.System_Log(' - Intel Indeo 5 Codec not found...');
      end;
      FLength := INFINITE;
    end;
    1: begin
      if FAILED(FGraphBuilder.RenderFile(MAP_TEXTURE_PHAT_DATA + VIDEO_GAME_CREATE_CHAR, nil)) then
      begin
        GRenderEngine.System_Log(' - Intel Indeo 5 Codec not found...');
      end;
      FGraphBuilder.RenderFile(SOUND_PHAT + VIDEO_SOUND_CREATE_CHAR, nil);
      FLength := 1324; // Video Special Cut, don't change it!!
    end;
    2: begin
      if FAILED(FGraphBuilder.RenderFile(MAP_TEXTURE_PHAT_DATA + VIDEO_GAME_START_GAME, nil)) then
      begin
        GRenderEngine.System_Log(' - Intel Indeo 5 Codec not found...');
      end;
      FGraphBuilder.RenderFile(SOUND_PHAT + VIDEO_SOUND_START_GAME, nil);
      FLength := 1424; // Video Special Cut, don't change it!!
    end;
  end;
  FBasicAudio.put_volume(FGameEngine.GameLauncherSetting.FVideoVolume);
  FBasicAudio := nil;
  FVideoWindow.put_owner(GRenderEngine.GetGameHWND);
  FVideoWindow.SetWindowPosition(0,0,FScreen_Width, FScreen_Height);
  FVideoWindow.put_MessageDrain(GRenderEngine.GetGameHWND);
  FVideoWindow.put_WindowStyle(WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN);
  FMediaControl.Run();
  FMediaEvent.WaitForCompletion(FLength, FEventCode);
  CoUninitialize();
end;


///////////// V2.0 ///////////////////////////////////
 
procedure TMir3_FileManager.DrawTexture(const ATextureID, AFileID: Integer; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
  FImage   : TMir3_Texture;
begin
  try
    FImage := GetImageD3DDirect(ATextureID, AFileID).ihD3DTexture;
    if Assigned(FImage) then
    begin
      FOldQuad := FImage.FQuad;
      FImage.FQuad.V[0].X   := AX;
      FImage.FQuad.V[0].Y   := AY;
      FImage.FQuad.V[1].X   := AX + FImage.FWidth;
      FImage.FQuad.V[1].Y   := AY;
      FImage.FQuad.V[2].X   := AX + FImage.FWidth;
      FImage.FQuad.V[2].Y   := AY + FImage.FHeight;
      FImage.FQuad.V[3].X   := AX;
      FImage.FQuad.V[3].Y   := AY + FImage.FHeight;
      FImage.FQuad.V[0].Col := SetA(FImage.FQuad.V[0].Col, AAlpha);
      FImage.FQuad.V[1].Col := SetA(FImage.FQuad.V[1].Col, AAlpha);
      FImage.FQuad.V[2].Col := SetA(FImage.FQuad.V[2].Col, AAlpha);
      FImage.FQuad.V[3].Col := SetA(FImage.FQuad.V[3].Col, AAlpha);
      FImage.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(FImage.FQuad);
      FImage.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::1::TEXTUREID('+IntToStr(ATextureID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;
end;

procedure TMir3_FileManager.DrawTexture(const ATexture: TMir3_Texture; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
begin
  try
    if Assigned(ATexture) then
    begin
      FOldQuad := ATexture.FQuad;
      ATexture.FQuad.V[0].X   := AX;
      ATexture.FQuad.V[0].Y   := AY;
      ATexture.FQuad.V[1].X   := AX + ATexture.FWidth;
      ATexture.FQuad.V[1].Y   := AY;
      ATexture.FQuad.V[2].X   := AX + ATexture.FWidth;
      ATexture.FQuad.V[2].Y   := AY + ATexture.FHeight;
      ATexture.FQuad.V[3].X   := AX;
      ATexture.FQuad.V[3].Y   := AY + ATexture.FHeight;
      ATexture.FQuad.V[0].Col := SetA(ATexture.FQuad.V[0].Col, AAlpha);
      ATexture.FQuad.V[1].Col := SetA(ATexture.FQuad.V[1].Col, AAlpha);
      ATexture.FQuad.V[2].Col := SetA(ATexture.FQuad.V[2].Col, AAlpha);
      ATexture.FQuad.V[3].Col := SetA(ATexture.FQuad.V[3].Col, AAlpha);
      ATexture.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(ATexture.FQuad);
      ATexture.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::2');
  end;
end;

procedure TMir3_FileManager.DrawTextureStretch(const ATextureID, AFileID: Integer; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
  FImage   : TMir3_Texture;
begin
  try
    FImage := GetImageD3DDirect(ATextureID, AFileID).ihD3DTexture;
    if Assigned(FImage) then
    begin
      FOldQuad := FImage.FQuad;
      FImage.FQuad.V[0].X   := AX;
      FImage.FQuad.V[0].Y   := AY;
      FImage.FQuad.V[1].X   := AX + FImage.FWidth  * ARateX;
      FImage.FQuad.V[1].Y   := AY;
      FImage.FQuad.V[2].X   := AX + FImage.FWidth  * ARateX;
      FImage.FQuad.V[2].Y   := AY + FImage.FHeight * ARateY;
      FImage.FQuad.V[3].X   := AX;
      FImage.FQuad.V[3].Y   := AY + FImage.FHeight * ARateY;
      FImage.FQuad.V[0].Col := SetA(FImage.FQuad.V[0].Col, AAlpha);
      FImage.FQuad.V[1].Col := SetA(FImage.FQuad.V[1].Col, AAlpha);
      FImage.FQuad.V[2].Col := SetA(FImage.FQuad.V[2].Col, AAlpha);
      FImage.FQuad.V[3].Col := SetA(FImage.FQuad.V[3].Col, AAlpha);
      FImage.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(FImage.FQuad);
      FImage.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::STRETCH::1::TEXTUREID('+IntToStr(ATextureID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;  
end;

procedure TMir3_FileManager.DrawTextureStretch(const ATexture: TMir3_Texture; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
begin
  try
    if Assigned(ATexture) then
    begin
      FOldQuad := ATexture.FQuad;
      ATexture.FQuad.V[0].X   := AX;
      ATexture.FQuad.V[0].Y   := AY;
      ATexture.FQuad.V[1].X   := AX + ATexture.FWidth  * ARateX;
      ATexture.FQuad.V[1].Y   := AY;
      ATexture.FQuad.V[2].X   := AX + ATexture.FWidth  * ARateX;
      ATexture.FQuad.V[2].Y   := AY + ATexture.FHeight * ARateY;
      ATexture.FQuad.V[3].X   := AX;
      ATexture.FQuad.V[3].Y   := AY + ATexture.FHeight * ARateY;
      ATexture.FQuad.V[0].Col := SetA(ATexture.FQuad.V[0].Col, AAlpha);
      ATexture.FQuad.V[1].Col := SetA(ATexture.FQuad.V[1].Col, AAlpha);
      ATexture.FQuad.V[2].Col := SetA(ATexture.FQuad.V[2].Col, AAlpha);
      ATexture.FQuad.V[3].Col := SetA(ATexture.FQuad.V[3].Col, AAlpha);
      ATexture.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(ATexture.FQuad);
      ATexture.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::STRETCH::2');
  end;  
end;

procedure TMir3_FileManager.DrawTextureClipRect(const ATextureID, AFileID: Integer; AX, AY: Integer; ARect: TRect; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad    : THGEQuad;
  FImage      : TMir3_Texture;
  FTX1, FTY1  : Single;
  FTX2, FTY2  : Single;
  FTempWidth  : Single;  
  FTempHeight : Single;
begin
  try
    FImage := GetImageD3DDirect(ATextureID, AFileID).ihD3DTexture;
    if Assigned(FImage) then
    begin
      FOldQuad := FImage.FQuad;
   
      if ARect.Left   > FImage.FWidth  then ARect.Left   := FImage.FWidth;
      if ARect.Top    > FImage.FHeight then ARect.Top    := FImage.FHeight;
      if ARect.Right  > FImage.FWidth  then ARect.Right  := FImage.FWidth;
      if ARect.Bottom > FImage.FHeight then ARect.Bottom := FImage.FHeight;
   
      FTempHeight := ARect.bottom - ARect.top;
      FTempWidth  := ARect.Right  - ARect.Left;
   
      FTX1 := ARect.Left / FImage.FTexWidth;
      FTY1 := ARect.Top  / FImage.FTexHeight;
      FTX2 := FTX1 + (ARect.Right  - ARect.left) / FImage.FTexWidth;
      FTY2 := FTY1 + (ARect.Bottom - ARect.top ) / FImage.FTexHeight;
   
      FImage.FQuad.V[0].TX := FTX1; FImage.FQuad.V[0].TY := FTY1;
      FImage.FQuad.V[1].TX := FTX2; FImage.FQuad.V[1].TY := FTY1;
      FImage.FQuad.V[2].TX := FTX2; FImage.FQuad.V[2].TY := FTY2;
      FImage.FQuad.V[3].TX := FTX1; FImage.FQuad.V[3].TY := FTY2;
   
      FImage.FQuad.V[0].X  := AX;              FImage.FQuad.V[0].Y := AY;
      FImage.FQuad.V[1].X  := AX + FTempWidth; FImage.FQuad.V[1].Y := AY;
      FImage.FQuad.V[2].X  := AX + FTempWidth; FImage.FQuad.V[2].Y := AY + FTempHeight;
      FImage.FQuad.V[3].X  := AX;              FImage.FQuad.V[3].Y := AY + FTempHeight;
   
      FImage.FQuad.V[0].Col := SetA(FImage.FQuad.V[0].Col, AAlpha);
      FImage.FQuad.V[1].Col := SetA(FImage.FQuad.V[1].Col, AAlpha);
      FImage.FQuad.V[2].Col := SetA(FImage.FQuad.V[2].Col, AAlpha);
      FImage.FQuad.V[3].Col := SetA(FImage.FQuad.V[3].Col, AAlpha);
      FImage.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(FImage.FQuad);
      FImage.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::CLIPRECT::1::TEXTUREID('+IntToStr(ATextureID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;  
end;

procedure TMir3_FileManager.DrawTextureClipRect(const ATexture: TMir3_Texture; AX, AY: Integer; ARect: TRect; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad    : THGEQuad;
  FTX1, FTY1  : Single;
  FTX2, FTY2  : Single;
  FTempWidth  : Single;  
  FTempHeight : Single;
begin
  try
    if Assigned(ATexture) then
    begin
      FOldQuad := ATexture.FQuad;
    
      if ARect.Left   > ATexture.FWidth  then ARect.Left   := ATexture.FWidth;
      if ARect.Top    > ATexture.FHeight then ARect.Top    := ATexture.FHeight;
      if ARect.Right  > ATexture.FWidth  then ARect.Right  := ATexture.FWidth;
      if ARect.Bottom > ATexture.FHeight then ARect.Bottom := ATexture.FHeight;
    
      FTempHeight := ARect.bottom - ARect.top;
      FTempWidth  := ARect.Right  - ARect.Left;
    
      FTX1 := ARect.Left / ATexture.FTexWidth;
      FTY1 := ARect.Top  / ATexture.FTexHeight;
      FTX2 := FTX1 + (ARect.Right  - ARect.left) / ATexture.FTexWidth;
      FTY2 := FTY1 + (ARect.Bottom - ARect.top ) / ATexture.FTexHeight;
    
      ATexture.FQuad.V[0].TX := FTX1; ATexture.FQuad.V[0].TY := FTY1;
      ATexture.FQuad.V[1].TX := FTX2; ATexture.FQuad.V[1].TY := FTY1;
      ATexture.FQuad.V[2].TX := FTX2; ATexture.FQuad.V[2].TY := FTY2;
      ATexture.FQuad.V[3].TX := FTX1; ATexture.FQuad.V[3].TY := FTY2;
    
      ATexture.FQuad.V[0].X  := AX;              ATexture.FQuad.V[0].Y := AY;
      ATexture.FQuad.V[1].X  := AX + FTempWidth; ATexture.FQuad.V[1].Y := AY;
      ATexture.FQuad.V[2].X  := AX + FTempWidth; ATexture.FQuad.V[2].Y := AY + FTempHeight;
      ATexture.FQuad.V[3].X  := AX;              ATexture.FQuad.V[3].Y := AY + FTempHeight;
    
      ATexture.FQuad.V[0].Col := SetA(ATexture.FQuad.V[0].Col, AAlpha);
      ATexture.FQuad.V[1].Col := SetA(ATexture.FQuad.V[1].Col, AAlpha);
      ATexture.FQuad.V[2].Col := SetA(ATexture.FQuad.V[2].Col, AAlpha);
      ATexture.FQuad.V[3].Col := SetA(ATexture.FQuad.V[3].Col, AAlpha);
      ATexture.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(ATexture.FQuad);
      ATexture.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::CLIPRECT::2');
  end;  
end;

procedure TMir3_FileManager.DrawTextureClipRectStretch(const ATextureID, AFileID: Integer; AX, AY: Integer; ARect: TRect; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad    : THGEQuad;
  FImage      : TMir3_Texture;
  FTX1, FTY1  : Single;
  FTX2, FTY2  : Single;
  FTempWidth  : Single;  
  FTempHeight : Single;
begin
  try
    FImage := GetImageD3DDirect(ATextureID, AFileID).ihD3DTexture;
    if Assigned(FImage) then
    begin
      FOldQuad := FImage.FQuad;
   
      if ARect.Left   > FImage.FWidth  then ARect.Left   := FImage.FWidth;
      if ARect.Top    > FImage.FHeight then ARect.Top    := FImage.FHeight;
      if ARect.Right  > FImage.FWidth  then ARect.Right  := FImage.FWidth;
      if ARect.Bottom > FImage.FHeight then ARect.Bottom := FImage.FHeight;
   
      FTempHeight := ARect.bottom - ARect.top;
      FTempWidth  := ARect.Right  - ARect.Left;
   
      FTX1 := ARect.Left / FImage.FTexWidth;
      FTY1 := ARect.Top  / FImage.FTexHeight;
      FTX2 := FTX1 + (ARect.Right  - ARect.left) / FImage.FTexWidth;
      FTY2 := FTY1 + (ARect.Bottom - ARect.top ) / FImage.FTexHeight;
   
      FImage.FQuad.V[0].TX := FTX1; FImage.FQuad.V[0].TY := FTY1;
      FImage.FQuad.V[1].TX := FTX2; FImage.FQuad.V[1].TY := FTY1;
      FImage.FQuad.V[2].TX := FTX2; FImage.FQuad.V[2].TY := FTY2;
      FImage.FQuad.V[3].TX := FTX1; FImage.FQuad.V[3].TY := FTY2;

      FImage.FQuad.V[0].X  := AX;                       FImage.FQuad.V[0].Y := AY;
      FImage.FQuad.V[1].X  := AX + FTempWidth * ARateX; FImage.FQuad.V[1].Y := AY;
      FImage.FQuad.V[2].X  := AX + FTempWidth * ARateX; FImage.FQuad.V[2].Y := AY + FTempHeight * ARateY;
      FImage.FQuad.V[3].X  := AX;                       FImage.FQuad.V[3].Y := AY + FTempHeight * ARateY;
   
      FImage.FQuad.V[0].Col := SetA(FImage.FQuad.V[0].Col, AAlpha);
      FImage.FQuad.V[1].Col := SetA(FImage.FQuad.V[1].Col, AAlpha);
      FImage.FQuad.V[2].Col := SetA(FImage.FQuad.V[2].Col, AAlpha);
      FImage.FQuad.V[3].Col := SetA(FImage.FQuad.V[3].Col, AAlpha);
      FImage.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(FImage.FQuad);
      FImage.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::CLIPRECT::STRETCH::1::TEXTUREID('+IntToStr(ATextureID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;  
end;

procedure TMir3_FileManager.DrawTextureClipRectStretch(const ATexture: TMir3_Texture; AX, AY: Integer; ARect: TRect; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad    : THGEQuad;
  FTX1, FTY1  : Single;
  FTX2, FTY2  : Single;
  FTempWidth  : Single;  
  FTempHeight : Single;
begin
  try
    if Assigned(ATexture) then
    begin
      FOldQuad := ATexture.FQuad;
    
      if ARect.Left   > ATexture.FWidth  then ARect.Left   := ATexture.FWidth;
      if ARect.Top    > ATexture.FHeight then ARect.Top    := ATexture.FHeight;
      if ARect.Right  > ATexture.FWidth  then ARect.Right  := ATexture.FWidth;
      if ARect.Bottom > ATexture.FHeight then ARect.Bottom := ATexture.FHeight;
    
      FTempHeight := ARect.bottom - ARect.top;
      FTempWidth  := ARect.Right  - ARect.Left;
    
      FTX1 := ARect.Left / ATexture.FTexWidth;
      FTY1 := ARect.Top  / ATexture.FTexHeight;
      FTX2 := FTX1 + (ARect.Right  - ARect.left) / ATexture.FTexWidth;
      FTY2 := FTY1 + (ARect.Bottom - ARect.top ) / ATexture.FTexHeight;
    
      ATexture.FQuad.V[0].TX := FTX1; ATexture.FQuad.V[0].TY := FTY1;
      ATexture.FQuad.V[1].TX := FTX2; ATexture.FQuad.V[1].TY := FTY1;
      ATexture.FQuad.V[2].TX := FTX2; ATexture.FQuad.V[2].TY := FTY2;
      ATexture.FQuad.V[3].TX := FTX1; ATexture.FQuad.V[3].TY := FTY2;
    
      ATexture.FQuad.V[0].X  := AX;                       ATexture.FQuad.V[0].Y := AY;
      ATexture.FQuad.V[1].X  := AX + FTempWidth * ARateX; ATexture.FQuad.V[1].Y := AY;
      ATexture.FQuad.V[2].X  := AX + FTempWidth * ARateX; ATexture.FQuad.V[2].Y := AY + FTempHeight * ARateY;
      ATexture.FQuad.V[3].X  := AX;                       ATexture.FQuad.V[3].Y := AY + FTempHeight * ARateY;
    
      ATexture.FQuad.V[0].Col := SetA(ATexture.FQuad.V[0].Col, AAlpha);
      ATexture.FQuad.V[1].Col := SetA(ATexture.FQuad.V[1].Col, AAlpha);
      ATexture.FQuad.V[2].Col := SetA(ATexture.FQuad.V[2].Col, AAlpha);
      ATexture.FQuad.V[3].Col := SetA(ATexture.FQuad.V[3].Col, AAlpha);
      ATexture.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(ATexture.FQuad);
      ATexture.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::CLIPRECT::STRETCH::2');
  end;
end;

procedure TMir3_FileManager.DrawTextureGrayScale(const ATextureID, AFileID: Integer; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
  FImage   : TMir3_Texture;
begin
  try
    FImage := GetImageD3DDirect(ATextureID, AFileID).ihD3DTexture;
    if Assigned(FImage) then
    begin
      FImage.ColorToGray; 
      FOldQuad := FImage.FQuad;
      FImage.FlipQuadTexture(FLIP_TO_GRAY_SCALE);
      FImage.FQuad.V[0].X   := AX;
      FImage.FQuad.V[0].Y   := AY;
      FImage.FQuad.V[1].X   := AX + FImage.FWidth;
      FImage.FQuad.V[1].Y   := AY;
      FImage.FQuad.V[2].X   := AX + FImage.FWidth;
      FImage.FQuad.V[2].Y   := AY + FImage.FHeight;
      FImage.FQuad.V[3].X   := AX;
      FImage.FQuad.V[3].Y   := AY + FImage.FHeight;
      FImage.FQuad.V[0].Col := SetA(FImage.FQuad.V[0].Col, AAlpha);
      FImage.FQuad.V[1].Col := SetA(FImage.FQuad.V[1].Col, AAlpha);
      FImage.FQuad.V[2].Col := SetA(FImage.FQuad.V[2].Col, AAlpha);
      FImage.FQuad.V[3].Col := SetA(FImage.FQuad.V[3].Col, AAlpha);
      FImage.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(FImage.FQuad);
      FImage.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::GRAYSCALE::1::TEXTUREID('+IntToStr(ATextureID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;
end;

procedure TMir3_FileManager.DrawTextureGrayScale(const ATexture: TMir3_Texture; AX, AY: Integer; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
begin
  try
    if Assigned(ATexture) then
    begin
      ATexture.ColorToGray; 
      FOldQuad := ATexture.FQuad;
      ATexture.FlipQuadTexture(FLIP_TO_GRAY_SCALE);
      ATexture.FQuad.V[0].X   := AX;
      ATexture.FQuad.V[0].Y   := AY;
      ATexture.FQuad.V[1].X   := AX + ATexture.FWidth;
      ATexture.FQuad.V[1].Y   := AY;
      ATexture.FQuad.V[2].X   := AX + ATexture.FWidth;
      ATexture.FQuad.V[2].Y   := AY + ATexture.FHeight;
      ATexture.FQuad.V[3].X   := AX;
      ATexture.FQuad.V[3].Y   := AY + ATexture.FHeight;
      ATexture.FQuad.V[0].Col := SetA(ATexture.FQuad.V[0].Col, AAlpha);
      ATexture.FQuad.V[1].Col := SetA(ATexture.FQuad.V[1].Col, AAlpha);
      ATexture.FQuad.V[2].Col := SetA(ATexture.FQuad.V[2].Col, AAlpha);
      ATexture.FQuad.V[3].Col := SetA(ATexture.FQuad.V[3].Col, AAlpha);
      ATexture.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(ATexture.FQuad);
      ATexture.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::GRAYSCALE::2');
  end;
end;

procedure TMir3_FileManager.DrawTextureGrayScaleStretch(const ATextureID, AFileID: Integer; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);
var
  FOldQuad : THGEQuad;
  FImage   : TMir3_Texture;
begin
  try
    FImage := GetImageD3DDirect(ATextureID, AFileID).ihD3DTexture;
    if Assigned(FImage) then
    begin
      FImage.ColorToGray; 
      FOldQuad := FImage.FQuad;
      FImage.FlipQuadTexture(FLIP_TO_GRAY_SCALE);
      FImage.FQuad.V[0].X   := AX;
      FImage.FQuad.V[0].Y   := AY;
      FImage.FQuad.V[1].X   := AX + FImage.FWidth  * ARateX;
      FImage.FQuad.V[1].Y   := AY;
      FImage.FQuad.V[2].X   := AX + FImage.FWidth  * ARateX;
      FImage.FQuad.V[2].Y   := AY + FImage.FHeight * ARateY;
      FImage.FQuad.V[3].X   := AX;
      FImage.FQuad.V[3].Y   := AY + FImage.FHeight * ARateY;
      FImage.FQuad.V[0].Col := SetA(FImage.FQuad.V[0].Col, AAlpha);
      FImage.FQuad.V[1].Col := SetA(FImage.FQuad.V[1].Col, AAlpha);
      FImage.FQuad.V[2].Col := SetA(FImage.FQuad.V[2].Col, AAlpha);
      FImage.FQuad.V[3].Col := SetA(FImage.FQuad.V[3].Col, AAlpha);
      FImage.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(FImage.FQuad);
      FImage.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::STRETCH::1::TEXTUREID('+IntToStr(ATextureID)+')-FILEID('+ IntToStr(AFileID) +')');
  end;  
end;

procedure TMir3_FileManager.DrawTextureGrayScaleStretch(const ATexture: TMir3_Texture; AX, AY: Integer; ARateX, ARateY: Single; ABlendMode: Word = BLEND_DEFAULT; AAlpha: Byte = 255);  
var
  FOldQuad : THGEQuad;
begin
  try
    if Assigned(ATexture) then
    begin
      ATexture.ColorToGray; 
      FOldQuad := ATexture.FQuad;
      ATexture.FlipQuadTexture(FLIP_TO_GRAY_SCALE);
      ATexture.FQuad.V[0].X   := AX;
      ATexture.FQuad.V[0].Y   := AY;
      ATexture.FQuad.V[1].X   := AX + ATexture.FWidth  * ARateX;
      ATexture.FQuad.V[1].Y   := AY;
      ATexture.FQuad.V[2].X   := AX + ATexture.FWidth  * ARateX;
      ATexture.FQuad.V[2].Y   := AY + ATexture.FHeight * ARateY;
      ATexture.FQuad.V[3].X   := AX;
      ATexture.FQuad.V[3].Y   := AY + ATexture.FHeight * ARateY;
      ATexture.FQuad.V[0].Col := SetA(ATexture.FQuad.V[0].Col, AAlpha);
      ATexture.FQuad.V[1].Col := SetA(ATexture.FQuad.V[1].Col, AAlpha);
      ATexture.FQuad.V[2].Col := SetA(ATexture.FQuad.V[2].Col, AAlpha);
      ATexture.FQuad.V[3].Col := SetA(ATexture.FQuad.V[3].Col, AAlpha);
      ATexture.FQuad.Blend    := ABlendMode;
      GRenderEngine.Gfx_RenderQuad(ATexture.FQuad);
      ATexture.FQuad := FOldQuad;
    end;
  except
    GRenderEngine.System_Log('ERROR::DRAW::TEXTURE::GREYSCALE::STRETCH::2');
  end;  
end;






 { TMir3_FileCashManager }

constructor TMir3_FileCashManager.Create(const ASpawnObject: TObject);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FSpawnObject    := ASpawnObject;
end;

destructor TMir3_FileCashManager.Destroy;
begin

  inherited;
end;

procedure TMir3_FileCashManager.Execute;
begin
  while not Terminated do
  begin
    WatchCachLogic;
    Sleep(450);
  end;
end;

procedure TMir3_FileCashManager.WatchCachLogic;
var
  FF: PFileInformation;
  I, I2, I3 : Integer;
begin
  for I := MAX_FILE_MAPPING downto 0 do
  begin
    FF := TMir3_FileManager(FSpawnObject).GetFileMapping.GetStaticFile(I);

    if not Assigned(FF) or (FF.fiUnloadFile = False) then Continue;

    if (GetTickCount - FF.fiLastUseTick) > 120000 then
    begin
      if Assigned(FF.fiImageList) then
      begin
        for I2 := Low(FF.fiImageList) to High(FF.fiImageList) do
        begin
          if Assigned(FF.fiImageList[I2]) then
          begin
            FreeAndNil(FF.fiImageList[I2].ihD3DTexture);
            Dispose(FF.fiImageList[I2]);
          end;
        end;
        SetLength(FF.fiImageList, 0);
        FF.fiImageList := nil;
      end;

      if Assigned(FF.fiImageLib) then
        FreeAndNil(FF.fiImageLib);
      TMir3_FileManager(FSpawnObject).GetFileMapping.CleanUpStaticFileMapping(FF.fiFileID);
    end else if (GetTickCount - FF.fiFirstUseTick) > 60000 then
             begin
               for I3 := Low(FF.fiImageList) to High(FF.fiImageList) do
               begin
                 if Assigned(FF.fiImageList[I3]) then
                   if (GetTickCount - FF.fiImageList[I3].ihUseTime) > 30000 then
                     if Assigned(FF.fiImageList[I3].ihD3DTexture) then
                     begin
                       //CS
                       //DecExtended(FF.fiImageMemoryUsag, ((FF.fiImageList[I3].ihPO2_Width * FF.fiImageList[I3].ihPO2_Height) * 4));
                       FreeAndNil(FF.fiImageList[I3].ihD3DTexture);
                       FF.fiImageList[I3].ihUseTime    := 0;
                       Dec(FF.fiImageOpenCount);
                       //CS
                     end;
               end;
             end;
    if (Terminated) then Exit;
  end;
end;


end.
