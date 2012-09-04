/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"
#include "f18_ver.ch"

// --------------------------------------------
// postavi globalne varijable
// --------------------------------------------
function set_global_vars_0()
public ZGwPoruka:=""
public GW_STATUS:="-"
public GW_HANDLE:=0
public gModul:=""
public gVerzija:=""
public gAppSrv:=.f.
public gSQL := "N"
public gSQLLogBase := ""
public ZGwPoruka:=""
public GW_STATUS:="-"
public GW_HANDLE:=0
public gReadOnly:=.f.
public gProcPrenos:="N"
public gInstall:=.f.
public gfKolor:="D"
public gPrinter := "R"
public gPtxtSw := nil
public gPDFSw := nil
public gMeniSif:=.f.
public gValIz:="280 "
public gValU:="000 "
public gKurs:="1"
public gPTKONV:="0 "
public gPicSif:="V"
public gcDirekt:="V"
public gSKSif:="D"
public gSezona:="    "
public gShemaVF:="B5"
//counter - za testiranje
public gCnt1:=0
PUBLIC m_x
PUBLIC m_y
PUBLIC h[20]
PUBLIC lInstal:=.f.
//  .t. - korisnik je SYSTEM
PUBLIC System   
PUBLIC aRel:={}
PUBLIC cDirRad
PUBLIC cDirSif
PUBLIC cDirPriv
PUBLIC gNaslov
public gSezonDir:=""
public gRadnoPodr:="RADP"
public ImeKorisn:="" 
public SifraKorisn:=""
public KLevel:="9"
public gArhDir := ""
public gPFont := "Arial"
public gKodnaS:="8"
public gWord97:="N"
public g50f:=" "
PUBLIC StaraBoja := SETCOLOR()
public System:=.f.
public gGlBaza:=""
public gSQL
public gSqlLogBase
PUBLIC Invert:="N/W,R/N+,,,R/B+"
PUBLIC Normal:="GR+/N,R/N+,,,N/W"
PUBLIC Blink:="R****/W,W/B,,,W/RB"
PUBLIC Nevid:="W/W,N/N"
PUBLIC gVeryBusyInterval
PUBLIC gKonvertPath := "N"
PUBLIC gSifk := .t.
PUBLIC gHostOS

#ifdef __WINDOWS
    gHostOS:="Linux"
#else
    gHostOS:="WindowsXP"
#endif

public cBteksta
public cBokvira
public cBnaslova
public cBshema:="B1"
public gCekaScreenSaver := 5
// ne koristi lokale
public gLokal:="0"
// pdf stampa
public gPDFPrint := "N"
public gPDFPAuto := "D"
public gPDFViewer := SPACE(150)
public gDefPrinter := SPACE(150)

// setuje globalne varijable printera
init_print_variables()

return



// -------------------------------------------------------------
// -------------------------------------------------------------
function set_global_vars_0_prije_prijave(fSve)

local cImeDbf

if fsve == nil
    fSve := .t.
endif

if fSve
    public gSezonDir:=""
    public gRadnoPodr:="RADP"
    public ImeKorisn:="" 
    public SifraKorisn:=""
    public KLevel:="9"
    public gPTKONV:="0 "
    public gPicSif:="V", gcDirekt:="V", gShemaVF:="B5", gSKSif:="D"

    //public gPFont:="Arial"

    public gKodnaS:="8"
    public gWord97:="N"
    public g50f:=" "

endif 

public gFKolor:="D"

O_GPARAMS
private cSection:="1",cHistory:=" "; aHistory:={}

if fsve
  Rpar("pt",@gPTKonv)
  Rpar("pS",@gPicSif)
  Rpar("SK",@gSKSif)
  Rpar("DO",@gcDirekt)
  Rpar("SB",@gShemaVF)
  Rpar("Ad",@gArhDir)
  Rpar("FO",@gPFont)
  Rpar("KS",@gKodnaS)
  Rpar("W7",@gWord97)
  Rpar("5f",@g50f)
  Rpar("L8",@gLokal)
  Rpar("pR",@gPDFPrint)
  Rpar("pV",@gPDFViewer)
  Rpar("pA",@gPDFPAuto)
  Rpar("dP",@gDefPrinter)
endif

Rpar("FK",@gFKolor)

select (F_GPARAMS)
use

return nil



function set_global_vars_0_nakon_prijave()
gSql := "N"
gSqlLogBase:=""
return



/*! \fn IniGParam2(lSamoKesiraj)
 *  \brief Ucitava globalne parametre gPTKonv
 *  Prvo ucitava "p?" koji je D ako zelimo ucitavati globalne parametre iz PRIVDIR
 *  \todo Ocigledno da je ovo funkcija za eliminaciju ...
 */
 
function IniGParam2()

local cPosebno:="N"

O_PARAMS
public gMeniSif:=.f.
private cSection:="1"
private cHistory:=" "
private aHistory:={}
RPar("p?", @cPosebno)

SELECT params
USE

if (cPosebno=="D")

  bErr := ERRORBLOCK({|o| MyErrH(o)})
  O_GPARAMSP
  SEEK "1"

  bErr := ERRORBLOCK(bErr)

    Rpar("pt",@gPTKonv)
    Rpar("pS",@gPicSif)
    Rpar("SK",@gSKSif)
    Rpar("DO",@gcDirekt)
    Rpar("FK",@gFKolor)
    Rpar("S9",@gSQL)
    gSQL:=IzFmkIni("Svi","SQLLog","N",KUMPATH)
    Rpar("SB",@gShemaVF)
    Rpar("Ad",@gArhDir)
    Rpar("FO",@gPFont)
    Rpar("KS",@gKodnaS)
    Rpar("W7",@gWord97)
    Rpar("5f",@g50f)
    Rpar("L8",@gLokal)
    Rpar("pR",@gPDFPrint)
    Rpar("pV",@gPDFViewer)
    Rpar("pA",@gPDFPAuto)
    Rpar("dP",@gDefPrinter)
	Rpar("oP",@gOOPath)
	Rpar("oW",@gOOWriter)
	Rpar("oS",@gOOSpread)
	Rpar("oJ",@gJavaPath)
	Rpar("jS",@gJavaStart)
	Rpar("jR",@gJODRep)
  SELECT (F_GPARAMSP)
  USE
endif

return


// ------------------------------------
// ------------------------------------
function IniPrinter()
// procitaj gPrinter, gpini, itd..
// postavi shift F2 kao hotkey

if gModul $ "EPDV"
	gPrinter := "R"
endif

if gPrinter == "E"
    set_epson_print_codes()
else
    PtxtSekvence()
endif

if gPicSif == "8"
    SETKEY( K_CTRL_F2, {|| PPrint()} )
else
    SETKEY( K_SH_F2, {|| PPrint()} )
endif

return


// ---------------------------------
// FMK_LIB_VER - defined in fmk.ch
// ---------------------------------
function fmklibver()
return FMK_LIB_VER


