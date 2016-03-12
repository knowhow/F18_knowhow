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

#include "f18.ch"


PROCEDURE set_global_vars_0()

#ifdef F18_DEBUG
   ?E "set_global_vars_0"
#endif
   PUBLIC ZGwPoruka := ""
   PUBLIC GW_STATUS := "-"
   PUBLIC GW_HANDLE := 0
   PUBLIC gModul := ""
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
   PUBLIC gSifreSamoVelikaSlova := "V"
   PUBLIC gcDirekt := "V"
   PUBLIC gSKSif := "D"
   PUBLIC gSezona := "    "
   PUBLIC gShemaVF := "B5"

   PUBLIC m_x
   PUBLIC m_y
   PUBLIC h[ 20 ]
   PUBLIC lInstal := .F.
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
   PUBLIC g50f := " "
   PUBLIC System := .F.
   PUBLIC gGlBaza := ""
   PUBLIC gSqlLogBase


   PUBLIC cBteksta
   PUBLIC cBokvira
   PUBLIC cBnaslova
   PUBLIC cBshema := "B1"

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

   PUBLIC gRj         := "N"
   PUBLIC gReadOnly   := .F.
   PUBLIC gOModul     := NIL
   PUBLIC cDirPriv    := ""
   PUBLIC cDirRad     := ""
   PUBLIC cDirSif     := ""
   PUBLIC glBrojacPoKontima := .T.

   init_print_variables() // setuje globalne varijable printera
   set_ptxt_sekvence()
   set_global_vars_roba()

   ?E "set_global_vars_0 end"

   RETURN


FUNCTION set_ptxt_sekvence()

   gpIni :=  "#%INI__#"
   gpCOND := "#%KON17#"
   gpCOND2 := "#%KON20#"
   gp10CPI := "#%10CPI#"
   gP12CPI := "#%12CPI#"
   gPB_ON := "#%BON__#"
   gPB_OFF := "#%BOFF_#"
   gPU_ON := "#%UON__#"
   gPU_OFF := "#%UOFF_#"
   gPI_ON := "#%ION__#"
   gPI_OFF := "#%IOFF_#"
   gPFF   := "#%NSTR_#"
   gPO_Port := "#%PORTR#"
   gPO_Land := "#%LANDS#"
   gPPort := "1"
   gRPL_Normal := ""
   gRPL_Gusto := ""
   gPPTK := " "

   RETURN .T.


FUNCTION set_global_vars_1( fSve )

   LOCAL cImeDbf

   info_bar( "vars", "set_global_vars_1" )
   IF fsve == nil
      fSve := .T.
   ENDIF

   create_gparams()
   IF fSve
      PUBLIC gSezonDir := ""
      PUBLIC gRadnoPodr := "RADP"
      PUBLIC ImeKorisn := ""
      PUBLIC SifraKorisn := ""
      PUBLIC KLevel := "9"
      PUBLIC gPTKONV := "0 "
      PUBLIC gSifreSamoVelikaSlova := "V", gcDirekt := "V", gShemaVF := "B5", gSKSif := "D"
      PUBLIC gKodnaS := "8"
      PUBLIC g50f := " "

   ENDIF

   PUBLIC gFKolor := "D"

   O_GPARAMS
   PRIVATE cSection := "1", cHistory := " "; aHistory := {}

   IF fsve
      Rpar( "pt", @gPTKonv )
      Rpar( "pS", @gSifreSamoVelikaSlova )
      Rpar( "SK", @gSKSif )
      Rpar( "DO", @gcDirekt )
      Rpar( "SB", @gShemaVF )
      Rpar( "Ad", @gArhDir )
      Rpar( "FO", @gPFont )
      Rpar( "KS", @gKodnaS )
      Rpar( "5f", @g50f )
      Rpar( "pR", @gPDFPrint )
      Rpar( "pV", @gPDFViewer )
      Rpar( "pA", @gPDFPAuto )
      Rpar( "dP", @gDefPrinter )
   ENDIF

   Rpar( "FK", @gFKolor )

   SELECT ( F_GPARAMS )
   USE

   RETURN NIL



FUNCTION set_global_vars_2()

   info_bar( "init", "set global_vars_2 - start" )

   init_printer()

   PUBLIC gOznVal := "KM"
   PUBLIC gFirma := "10"
   PUBLIC gNFirma := PadR( "", 50 )
   PUBLIC gTS := PadR( "Preduzece", 20 )
   PUBLIC gBaznaV := "D"
   PUBLIC gZaokr := 2
   PUBLIC gTabela := 0
   PUBLIC gPDV := "D"
   PUBLIC gMjStr := PadR( "Sarajevo", 30 )
   PUBLIC gModemVeza := "N"
   PUBLIC gNW := "D"


   PUBLIC gPartnBlock
   gPartnBlock := nil

   PUBLIC gSecurity := "D"
   PUBLIC gnDebug := 0
   PUBLIC gOpSist := "-"


   gSql := "N"
   gSqlLogBase := ""
   gReadOnly := .F.


   info_bar( "init", "set global_vars_2 - end" )

   RETURN .T.



FUNCTION set_global_vars_roba()

   PUBLIC gUVarPP
   PUBLIC gRobaBlock
   PUBLIC gPicCDem
   PUBLIC PicDem
   PUBLIC gPicProc
   PUBLIC gPicDEM
   PUBLIC gPickol
   PUBLIC gFPicCDem
   PUBLIC gFPicDem
   PUBLIC gFPicKol

   PUBLIC gDuzSifIni

   PUBLIC glPoreziLegacy
   PUBLIC glUgost
   PUBLIC gUgostVarijanta

   // R - Obracun porez na RUC
   // D - starija varijanta ???
   // N - obicno robno knjigovodstvo

   glPoreziLegacy := .T.
   glUgost := .F.

   // RMarza_DLimit - osnovica realizovana marza ili donji limit
   // MpcSaPor - Maloprodajna cijena sa porezom
   gUgostVarijanta := "Rmarza_DLimit"
   gUVarPP := "N"
   gRobaBlock := NIL
   gPicCDEM := "999999.999"
   gPicProc := "999999.99%"
   gPicDEM := "9999999.99"
   gPickol := "999999.999"
   gFPicCDem := "0"
   gFPicDem := "0"
   gFPicKol := "0"
   gDuzSifINI := "10"

   RETURN .T.




FUNCTION init_printer() // procitaj gPrinter, gpini,  postavi shift F2 kao hotkey

   info_bar( "init", "init printer seqs start" )

   IF gModul $ "EPDV"
      gPrinter := "R"
   ENDIF

   IF gPrinter == "E"
      set_epson_print_codes()
   ELSE
      set_ptxt_sekvence()
   ENDIF

   IF gSifreSamoVelikaSlova == "8"
      SetKey( K_CTRL_F2, {|| PPrint() } )
   ELSE
      SetKey( K_SH_F2, {|| PPrint() } )
   ENDIF

   info_bar( "init", "init printer seqs end" )

   RETURN .T.



// ---------------------------------
// F18_LIB_VER - defined in fmk.ch
// ---------------------------------
FUNCTION f18_lib_ver()
   RETURN F18_LIB_VER
