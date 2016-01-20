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


#include "f18.ch"
#include "f18_ver.ch"

// --------------------------------------------
// postavi globalne varijable
// --------------------------------------------
FUNCTION set_global_vars_0()

   PUBLIC ZGwPoruka := ""
   PUBLIC GW_STATUS := "-"
   PUBLIC GW_HANDLE := 0
   PUBLIC gModul := ""
   PUBLIC gVerzija := ""
   PUBLIC gAppSrv := .F.
   PUBLIC gSQL := "N"
   PUBLIC gSQLLogBase := ""
   PUBLIC ZGwPoruka := ""
   PUBLIC GW_STATUS := "-"
   PUBLIC GW_HANDLE := 0
   PUBLIC gReadOnly := .F.
   PUBLIC gProcPrenos := "N"
   PUBLIC gInstall := .F.
   PUBLIC gfKolor := "D"
   PUBLIC gPrinter := "R"
   PUBLIC gPtxtSw := nil
   PUBLIC gPDFSw := nil
   PUBLIC gMeniSif := .F.
   PUBLIC gValIz := "280 "
   PUBLIC gValU := "000 "
   PUBLIC gKurs := "1"
   PUBLIC gPTKONV := "0 "
   PUBLIC gPicSif := "V"
   PUBLIC gcDirekt := "V"
   PUBLIC gSKSif := "D"
   PUBLIC gSezona := "    "
   PUBLIC gShemaVF := "B5"

   // counter - za testiranje
   PUBLIC gCnt1 := 0
   PUBLIC m_x
   PUBLIC m_y
   PUBLIC h[ 20 ]
   PUBLIC lInstal := .F.
   // .t. - korisnik je SYSTEM
   PUBLIC System
   PUBLIC aRel := {}
   PUBLIC cDirRad
   PUBLIC cDirSif
   PUBLIC cDirPriv
   PUBLIC gNaslov
   PUBLIC gSezonDir := ""
   PUBLIC gRadnoPodr := "RADP"
   PUBLIC ImeKorisn := ""
   PUBLIC SifraKorisn := ""
   PUBLIC KLevel := "9"
   PUBLIC gArhDir := ""
   PUBLIC gPFont := "Arial"
   PUBLIC gKodnaS := "8"
   PUBLIC gWord97 := "N"
   PUBLIC g50f := " "
   PUBLIC StaraBoja := SetColor()
   PUBLIC System := .F.
   PUBLIC gGlBaza := ""
   PUBLIC gSQL
   PUBLIC gSqlLogBase
   PUBLIC Invert := "N/W,R/N+,,,R/B+"
   PUBLIC Normal := "GR+/N,R/N+,,,N/W"
   PUBLIC Blink := "R****/W,W/B,,,W/RB"
   PUBLIC Nevid := "W/W,N/N"
   PUBLIC gVeryBusyInterval
   PUBLIC gKonvertPath := "N"
   PUBLIC gHostOS

#ifdef __WINDOWS
   gHostOS := "Linux"
#else
   gHostOS := "WindowsXP"
#endif

   PUBLIC cBteksta
   PUBLIC cBokvira
   PUBLIC cBnaslova
   PUBLIC cBshema := "B1"
   PUBLIC gCekaScreenSaver := 5
   // ne koristi lokale
   PUBLIC gLokal := "0"
   // pdf stampa
   PUBLIC gPDFPrint := "N"
   PUBLIC gPDFPAuto := "D"
   PUBLIC gPDFViewer := Space( 150 )
   PUBLIC gDefPrinter := Space( 150 )

   PUBLIC gPicDEM := "9999999.99"
   PUBLIC gPicBHD := "999999999999.99"

   PUBLIC gRavnot := "D"
   PUBLIC gDatNal := "N"
   PUBLIC gSAKrIz := "N"
   PUBLIC gBezVracanja := "N"
   PUBLIC gBuIz := "N"
   PUBLIC gVar1 := "1"
   PUBLIC gRj := "N"
   PUBLIC gTroskovi := "N"
   PUBLIC gnRazRed := 3
   PUBLIC gVSubOp := "N"
   PUBLIC gnLMONI := 120
   PUBLIC gKtoLimit := "N"
   PUBLIC gnKtoLimit := 3
   PUBLIC gDUFRJ := "N"
   PUBLIC gBrojac := "1"
   PUBLIC gDatVal := "D"
   PUBLIC gnLOSt := 0
   PUBLIC gPotpis := "N"
   PUBLIC gnKZBDana := 0
   PUBLIC gOAsDuPartn := "N"
   PUBLIC gAzurTimeOut := 120
   PUBLIC g_knjiz_help := "N"
   PUBLIC gMjRj := "N"

   // setuje globalne varijable printera
   init_print_variables()

   RETURN



FUNCTION set_global_vars_0_prije_prijave( fSve )

   LOCAL cImeDbf

   IF fsve == nil
      fSve := .T.
   ENDIF

   IF fSve
      PUBLIC gSezonDir := ""
      PUBLIC gRadnoPodr := "RADP"
      PUBLIC ImeKorisn := ""
      PUBLIC SifraKorisn := ""
      PUBLIC KLevel := "9"
      PUBLIC gPTKONV := "0 "
      PUBLIC gPicSif := "V", gcDirekt := "V", gShemaVF := "B5", gSKSif := "D"

      // public gPFont:="Arial"

      PUBLIC gKodnaS := "8"
      PUBLIC gWord97 := "N"
      PUBLIC g50f := " "

   ENDIF

   PUBLIC gFKolor := "D"

   O_GPARAMS
   PRIVATE cSection := "1", cHistory := " "; aHistory := {}

   IF fsve
      Rpar( "pt", @gPTKonv )
      Rpar( "pS", @gPicSif )
      Rpar( "SK", @gSKSif )
      Rpar( "DO", @gcDirekt )
      Rpar( "SB", @gShemaVF )
      Rpar( "Ad", @gArhDir )
      Rpar( "FO", @gPFont )
      Rpar( "KS", @gKodnaS )
      Rpar( "W7", @gWord97 )
      Rpar( "5f", @g50f )
      Rpar( "L8", @gLokal )
      Rpar( "pR", @gPDFPrint )
      Rpar( "pV", @gPDFViewer )
      Rpar( "pA", @gPDFPAuto )
      Rpar( "dP", @gDefPrinter )
   ENDIF

   Rpar( "FK", @gFKolor )

   SELECT ( F_GPARAMS )
   USE

   RETURN NIL



FUNCTION set_global_vars_0_nakon_prijave()

   gSql := "N"
   gSqlLogBase := ""

   RETURN



/*! \fn IniGParam2(lSamoKesiraj)
 *  \brief Ucitava globalne parametre gPTKonv
 *  Prvo ucitava "p?" koji je D ako zelimo ucitavati globalne parametre iz PRIVDIR
 *  \todo Ocigledno da je ovo funkcija za eliminaciju ...
 */

FUNCTION IniGParam2()

   LOCAL cPosebno := "N"

   O_PARAMS
   PUBLIC gMeniSif := .F.
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   RPar( "p?", @cPosebno )

   SELECT params
   USE

   IF ( cPosebno == "D" )

      bErr := ErrorBlock( {| o| MyErrH( o ) } )
      O_GPARAMSP
      SEEK "1"

      bErr := ErrorBlock( bErr )

      Rpar( "pt", @gPTKonv )
      Rpar( "pS", @gPicSif )
      Rpar( "SK", @gSKSif )
      Rpar( "DO", @gcDirekt )
      Rpar( "FK", @gFKolor )
      Rpar( "S9", @gSQL )
      gSQL := IzFmkIni( "Svi", "SQLLog", "N", KUMPATH )
      Rpar( "SB", @gShemaVF )
      Rpar( "Ad", @gArhDir )
      Rpar( "FO", @gPFont )
      Rpar( "KS", @gKodnaS )
      Rpar( "W7", @gWord97 )
      Rpar( "5f", @g50f )
      Rpar( "L8", @gLokal )
      Rpar( "pR", @gPDFPrint )
      Rpar( "pV", @gPDFViewer )
      Rpar( "pA", @gPDFPAuto )
      Rpar( "dP", @gDefPrinter )
      Rpar( "oP", @gOOPath )
      Rpar( "oW", @gOOWriter )
      Rpar( "oS", @gOOSpread )
      Rpar( "oJ", @gJavaPath )
      Rpar( "jS", @gJavaStart )
      Rpar( "jR", @gJODRep )
      SELECT ( F_GPARAMSP )
      USE
   ENDIF

   RETURN


// ------------------------------------
// ------------------------------------
FUNCTION IniPrinter()

   // procitaj gPrinter, gpini, itd..
   // postavi shift F2 kao hotkey

   IF gModul $ "EPDV"
      gPrinter := "R"
   ENDIF

   IF gPrinter == "E"
      set_epson_print_codes()
   ELSE
      PtxtSekvence()
   ENDIF

   IF gPicSif == "8"
      SetKey( K_CTRL_F2, {|| PPrint() } )
   ELSE
      SetKey( K_SH_F2, {|| PPrint() } )
   ENDIF

   RETURN


// ---------------------------------
// FMK_LIB_VER - defined in fmk.ch
// ---------------------------------
FUNCTION fmklibver()
   RETURN FMK_LIB_VER
