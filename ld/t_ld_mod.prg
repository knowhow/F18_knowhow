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


CLASS TLdMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD mMenu
   METHOD programski_modul_osnovni_meni

ENDCLASS

METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )
   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )
   RETURN self



METHOD mMenu()

   PRIVATE Izbor

   Izbor := 1

   my_close_all_dbf()

   ld_postavi_parametre_obracuna()

   ::programski_modul_osnovni_meni()

   RETURN NIL


METHOD programski_modul_osnovni_meni

   PRIVATE Izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   AAdd( opc, "1. obračun (unos, ispravka, brisanje...)         " )
   AAdd( opcexe, {|| ld_obracun() } )
   AAdd( opc, "2. izvještaji" )
   AAdd( opcexe, {|| ld_izvjestaji() } )
   AAdd( opc, "3. krediti" )
   AAdd( opcexe, {|| ld_krediti_menu() } )
   AAdd( opc, "4. export podataka za banke " )
   AAdd( opcexe, {|| ld_export_banke() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc, "S. šifarnici plate" )
   AAdd( opcexe, {|| ld_sifarnici() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc, "A. rekapitulacija" )
   AAdd( opcexe, {|| ld_rekapitulacija(.T.) } )
   AAdd( opc, "B. kartica plate" )
   AAdd( opcexe, {|| ld_kartica_plate() } )
   AAdd( opc, "V. generisanje virmana " )
   AAdd( opcexe, {|| ld_gen_virm() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc, "X. parametri plate " )
   AAdd( opcexe, {|| ld_parametri() } )

   f18_menu_sa_priv_vars_opc_opcexe_izbor( "gld", .T. )

   RETURN .T.



METHOD set_module_gvars()

   PUBLIC cFormula := ""
   PUBLIC gRJ := "01"
   PUBLIC gnHelpObr := 0
   PUBLIC gMjesec := 1
   PUBLIC gObracun := "1"
   // varijanta obracuna u skladu sa zak.promjenama
   PUBLIC gVarObracun := "2"
   PUBLIC gOsnLOdb := 300
   PUBLIC gRadnFilter := "D"
   PUBLIC gUgTrosk := 20
   PUBLIC gAhTrosk := 30
   PUBLIC gIzdanje := Space( 10 )
   PUBLIC gGodina := Year( Date() )
   PUBLIC gZaok := 2
   PUBLIC gZaok2 := 2
   PUBLIC gValuta := "KM "
   PUBLIC gPicI := "99999999.99"
   PUBLIC gPicS := "99999999"
   PUBLIC gTipObr := "1"
   PUBLIC gVarSpec := "1"
   PUBLIC cVarPorOl := "1"
   PUBLIC gSihtarica := "N"
   PUBLIC gSihtGroup := "N"
   PUBLIC gFUPrim := PadR( "UNETO+I24+I25", 50 )
   PUBLIC gBFForm := PadR( "", 100 )
   PUBLIC gBenefSati := 1
   PUBLIC gFURaz := PadR( "", 60 )
   PUBLIC gFUSati := PadR( "USATI", 50 )
   PUBLIC gFURSati := PadR( "", 50 )
   PUBLIC gFUGod := PadR( "I06", 40 )
   PUBLIC gUNMjesec := "N"
   PUBLIC gMRM := 0.6
   PUBLIC gMRZ := 0.6
   PUBLIC gPDLimit := 0
   PUBLIC gSetForm := "1"
   PUBLIC gPrBruto := "D"
   PUBLIC gMinR := "%"
   PUBLIC gPotp := "D"
   PUBLIC gBodK := "1"
   PUBLIC gDaPorol := "N" // pri obracunu uzeti u obzir poreske olaksice
   PUBLIC gFSpec := PadR( "SPEC.TXT", 12 )
   PUBLIC gReKrOs := "X"
   PUBLIC gReKrKP := "2"
   PUBLIC gVarPP := "1"
   PUBLIC gKarSDop := "N"
   PUBLIC gPotpRpt := "N"
   PUBLIC gPotp1 := PadR( "PADL('Potpis:',70)", 150 )
   PUBLIC gPotp2 := PadR( "PADL('_________________',70)", 150 )
   PUBLIC _LK_ := 6
   PUBLIC lViseObr := .T.
   PUBLIC lVOBrisiCDX := .F.
   PUBLIC cLdPolja := 40

   ld_get_params()

   LDPoljaINI()


   RETURN .T.
