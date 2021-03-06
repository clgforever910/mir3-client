(******************************************************************           *
 *   LomCN Mir3 Spanish Launcher Language LGU File 2013                       *
 *                                                                            *
 *   Web       : http://www.lomcn.co.uk                                       *
 *   Version   : 0.0.0.3                                                      *
 *                                                                            *
 *   - File Info -                                                            *
 *                                                                            *
 *   It holds the mir3 Spanish language strings.                              *
 *                                                                            *
 ******************************************************************************
 * Change History                                                             *
 *                                                                            *
 *  - 0.0.0.1 [2013-02-11] Elamo : first init                                 *
 *  - 0.0.0.2 [2013-04-13] Coly : add utf8 code support                       *
 *  - 0.0.0.3 [2013-05-02] 1PKRyan : code clean-up                            *
 *                                                                            *
 ******************************************************************************
 * :Info:                                                                     *
 * The Maximum of String Literale is 255 so you need to add ' + '             *
 * at the end of 255 Char...                                                  *
 * The String it self can have a length of 1024                               *
 *                                                                            *
 * !! Don't localize or delete things with "¦" !!                             *
 * !! it is part of the Script Engine Commands !!                             *
 *                                                                            *
 * !!! Attention, only the Spanish language files are                         * 
 * !!! matched by the development team, not other languages??.                *
 *                                                                            * 
 ******************************************************************************)

unit mir3_language_launcher;

interface

uses
  { Delphi }
  Windows,
  SysUtils,
  Classes;

function GetLauncherLine(): Integer; stdcall;
function GetLauncherString(ID: Integer; Buffer: PWideChar): Integer; stdcall;

implementation

function GetLauncherLine(): Integer; stdcall;
begin
  Result := 1;
end;

function GetLauncherString(ID: Integer; Buffer: PWideChar): Integer; stdcall;
var
  Value : WideString;
begin
  case ID of
    (*******************************************************************
    *                  Server Informations strings                     *
    *******************************************************************)
    1: Value :='';

    (*******************************************************************
    *                         Option strings                           *
    *******************************************************************)

    (*******************************************************************
    *                     Account Manager strings                      *
    *******************************************************************)

    (*******************************************************************
    *                       Update Game strings                        *
    *******************************************************************)

    else Value := 'No soportado';
  end;

  ////////////////////////////////////////////////////////////////////////////
  ///

  if Assigned(Buffer) then
    lstrcpynW(Buffer, PWideChar(Value), lstrlenW(PWideChar(Value)) + 1);

  Result := lstrlenW(PWideChar(Value)) + 1;
end;

end.
