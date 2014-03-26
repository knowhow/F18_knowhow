/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"

#define D_STAROST_DANA   25

PROCEDURE OutMsg( hFile, cMsg )
   IF hFile == 1
      OutStd( cMsg )
   ELSEIF hFile == 2
      OutErr( cMsg )
   ELSE
      FWrite( hFile, cMsg )
   ENDIF
RETURN



// ------------------------------------
// vraca putanju exe fajlova
// ------------------------------------
function GetExePath( cPath )
local cRet := ""
local i
local n := 0
local cTmp

for i:=1 to LEN(cPath)

	cTmp := SUBSTR( cPath, i, 1 )
	
	if cTmp == "\"
		n += 1
	endif

	cRet += cTmp

	if n = 2
		exit
	endif

next

return cRet


/*! \fn FilePath(cFile)
 *  \brief  Extract the full path name from a filename
 *  \return cFilePath
 */
 
function My_FilePath( cFile )
LOCAL nPos, cFilePath

nPos := RAT(SLASH, cFile)
if (nPos != 0)
	cFilePath := SUBSTR(cFile, 1, nPos)
else
	cFilePath := ""
endif
return cFilePath

function ExFileName( cFile )
LOCAL nPos, cFileName
IF (nPos := RAT(SLASH, cFile)) != 0
   cFileName:= SUBSTR(cFile, nPos + 1 )
ELSE
   cFileName := cFile 
ENDIF
return cFileName

function AddBS(cPath)
if right(cPath,1)<>SLASH     
     cPath:=cPath + SLASH
endif


function DiskPrazan(cDisk)

 if diskspace(asc(cDisk)-64)<15000
   Beep(4)
   Msg("Nema dovoljno prostora na ovom disku, stavite drugu disketu",6)
   return .f.
 endif
return .t.


*string FmkIni_ExePath_POS_PitanjeUgasiti;

/*! \ingroup ini
 *  \var *string FmkIni_ExePath_POS_PitanjeUgasiti
 *  \param "0" - ne pitaj (dobro za racunar koji se ne koristi SAMO kao PC Kasa
 *  \param "-" - pitaj 
 */

function UgasitiR()

local cPitanje

if (gSQL=="D")
	cPitanje:=IzFmkIni("POS","PitanjeUgasiti","-")
	if cPitanje=="-"
		cPitanje:=" "
	endif

	if (cPitanje=="0")
		goModul:quit()
	elseif Pitanje(,"Želite li ugasiti racunar D/N ?", cPitanje)=="D"
		if Gw("OMSG SHUTDOWN")=="OK"
			goModul:quit()
		endif
	endif
endif

if gModul<>"TOPS"
	goModul:quit()
endif

return



/*! \file ChangeEXT(cImeF,cExt, cExtNew, fBezAdd)
 * \brief Promjeni ekstenziju
 *
 * \params cImeF   ime fajla
 * \params cExt    polazna extenzija (obavezno 3 slova) 
 * \params cExtNew nova extenzija
 * \params fBezAdd ako je .t. onda ce fajlu koji nema cExt dodati cExtNew
 * 
 * \code
 *
 * ChangeEXT("SUBAN", "DBF", "CDX", .t.)
 * suban     -> suban.CDX
 * 
 * ChangeEXT("SUBAN", "DBF", "CDX", .f.)
 * SUBAN     -> SUBAN
 * 
 *
 * ChangeEXT("SUBAN.DBF", "DBF", "CDX", .t.)
 * SUBAN.DBF  -> SUBAN.CDX
 *
 * \endcode 
 *
 */

function ChangeEXT(cImeF, cExt, cExtNew, fBezAdd)

local cTacka

if fBezAdd==NIL
  fBezAdd:=.t.
endif  
  
if EMPTY(cExtNew)
  cTacka:=""
else
  cTacka:="."
endif
cImeF:=ToUnix(cImeF)

cImeF:=trim(STRTRAN(cImeF,"."+cEXT,cTacka+cExtNew))
if !EMPTY(cTacka) .and.  RIGHT(cImeF,4)<>cTacka+cExtNew
  cImeF:=cImeF+cTacka+cExtNew
endif
return  cImeF


// ------------------------------------------
// ------------------------------------------
function IsDirectory(cDir1)

local cDirTek
local lExists

cDir1 := ToUnix(cDir1)

cDirTek:=DirName()

if DirChange(cDir1) <> 0
 lExists:=.f.
else
 lExists:=.t.
endif

DirChange(cDirTek)

return lExists


/*! \fn BrisiSFajlove(cDir)
  * \brief Brisi fajlove starije od 45 dana
  *
  * \code
  *
  * npr:  cDir ->  c:\tops\prenos\ 
  *
  * brisi sve fajlove u direktoriju
  * starije od 45 dana
  *
  * \endcode
  */

function BrisiSFajlove(cDir, nDana)

local cFile

if nDana == nil
	nDana := D_STAROST_DANA
endif

cDir:=ToUnix(trim(cdir))
cFile:=fileseek(trim(cDir)+"*.*")
do while !empty(cFile)
    if date() - filedate() > nDana  
       filedelete(cdir+cfile)
    endif
    cfile:=fileseek()
enddo
return NIL



// ----------------------------------------------
// ----------------------------------------------
function ToUnix(cFileName)
return cFileName


#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapifs.h"

HB_FUNC( FILEBASE )
{
   const char * szPath = hb_parc( 1 );
   if( szPath )
   {
      PHB_FNAME pFileName = hb_fsFNameSplit( szPath );
      hb_retc( pFileName->szName );
      hb_xfree( pFileName );
   }
   else
      hb_retc_null();
}

/* FileExt( <cFile> ) --> cFileExt
*/
HB_FUNC( FILEEXT )
{
   const char * szPath = hb_parc( 1 );
   if( szPath )
   {
      PHB_FNAME pFileName = hb_fsFNameSplit( szPath );
      if( pFileName->szExtension != NULL )
         hb_retc( pFileName->szExtension + 1 ); /* Skip the dot */
      else
         hb_retc_null();
      hb_xfree( pFileName );
   }
   else
      hb_retc_null();
}

#pragma ENDDUMP


#pragma BEGINDUMP

#include "hbapi.h"
#include "hbapierr.h"
#include "hbapigt.h"
#include "hbapiitm.h"
#include "hbapifs.h"

/* TOFIX: The screen buffer handling is not right for all platforms (Windows)
          The output of the launched (MS-DOS?) app is not visible. */

HB_FUNC( __RUN_SYSTEM )
{
   const char * pszCommand = hb_parc( 1 );
   int iResult;

   if( pszCommand && hb_gtSuspend() == HB_SUCCESS )
   {
      char * pszFree = NULL;

      iResult = system( hb_osEncodeCP( pszCommand, &pszFree, NULL ) );

      hb_retni(iResult);

      if( pszFree )
         hb_xfree( pszFree );

      if( hb_gtResume() != HB_SUCCESS )
      {
         /* an error should be generated here !! Something like */
         /* hb_errRT_BASE_Ext1( EG_GTRESUME, 6002, NULL, HB_ERR_FUNCNAME, 0, EF_CANDEFAULT ); */
      }


   }
}

#pragma ENDDUMP



function f18_run(cmd, output, always_ok, async)
local _ret, _stdout, _stderr, _prefix
local _msg

if always_ok == NIL
  always_ok := .f.
endif

if async == NIL
  // najcesce mi zelimo da okinemo exkternu komandu i nastavimo rad
  async := .f.
endif


#ifdef __PLATFORM__LINUX
   _ret := __run_system(cmd + IIF(async, "&", ""))
#else
   _ret := hb_ProcessRun(cmd, NIL, NIL, NIL, async)
#endif

if _ret <> 0

#ifdef __PLATFORM__WINDOWS
   //_prefix := "start "
   _prefix := "c:\knowhowERP\util\start.exe /m "

#else
   #ifdef __PLATFORM__DARWIN
      _prefix := "open "
   #else
      _prefix := "xdg-open "
   #endif
#endif

#ifdef __PLATFORM__LINUX
   if async
       _ret := __run_system(_prefix + cmd + "&")
   else
       _ret := hb_processRun(_prefix + cmd, NIL, NIL, NIL, async) 
   endif 
#else
   _ret := hb_processRun(_prefix + cmd, NIL, NIL, NIL, async) 
#endif


#ifdef __PLATFORM__WINDOWS
   // copy komanda trazi system run a ne hbprocess run 
   if _ret <> 0
       _ret := __run_system(cmd)
   endif
#endif
   if _ret <> 0 .and. !always_ok 
        _msg := "ERR run cmd:"  + cmd
        log_write(_msg, 2)
        MsgBeep(_msg)
   endif
   
endif

if VALTYPE(output) == "H"
    // hash matrica
    output["stdout"] := _stdout
    output["stderr"] := _stderr
endif

return _ret

// -------------------------------------------
// -------------------------------------------
function f18_open_document(document)
local _ret, _prefix
local _msg


#ifdef __PLATFORM__WINDOWS
   //_prefix := "start "
   _prefix := "c:\knowhowERP\util\start.exe "

#else
   #ifdef __PLATFORM__DARWIN
      _prefix := "open "
   #else
      _prefix := "xdg-open "
   #endif
#endif

#ifdef __PLATFORM__LINUX
   _ret := __run_system(_prefix + document + "&")
#else
   _ret := hb_processRun(_prefix + document, NIL, NIL, NIL, .t.) 
#endif

return _ret


// ----------------------------
// ----------------------------
function open_folder(folder)
local _cmd
#ifdef __PLATFORM__WINDOWS
   folder := _path_quote(folder)   
#endif

return f18_open_document(folder)
