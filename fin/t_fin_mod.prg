/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

#include "hbclass.ch"

CLASS TFinMod FROM TAppMod

   METHOD NEW
   METHOD dummy
   METHOD setGVars
   METHOD mMenu
   METHOD mMenuStandard
   METHOD initdb

END CLASS


// ----------------------------------------------------
// ----------------------------------------------------
METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self


// ----------------------------------------
// ----------------------------------------
METHOD initdb()

   ::oDatabase := TDbFin():new()

   RETURN NIL


// ----------------------------------------
// ----------------------------------------
METHOD dummy()
   RETURN


// ----------------------------------------
// ----------------------------------------
METHOD mMenu()

   set_hot_keys()

   auto_kzb()

   CLOSE ALL

   @ 1, 2 SAY PadC( gTS + ": " + gNFirma, 50, "*" )
   @ 4, 5 SAY ""

   ::mMenuStandard()

   RETURN NIL


METHOD mMenuStandard()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL oDb_lock := F18_DB_LOCK():New()
   LOCAL _locked := oDb_lock:is_locked()

   AAdd( _opc, "1. unos/ispravka dokumenta                   " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "DOK", "KNJIZNALOGA" ) ) .AND. !_locked
      AAdd( _opcexe, {|| fin_unos_naloga() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF

   AAdd( _opc, "2. izvjestaji" )
   AAdd( _opcexe, {|| Izvjestaji() } )

   AAdd( _opc, "3. pregled dokumenata" )
   AAdd( _opcexe, {|| MnuPregledDokumenata() } )

   AAdd( _opc, "4. generacija dokumenata" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "DOK", "GENDOK" ) ) .AND. !_locked
      AAdd( _opcexe, {|| MnuGenDok() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF

   AAdd( _opc, "5. moduli - razmjena podataka" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "RAZDB", "MODULIRAZMJENA" ) ) .AND. !_locked
      AAdd( _opcexe, {|| MnuRazmjenaPodataka() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF

   AAdd( _opc, "6. ostale operacije nad dokumentima" )
   AAdd( _opcexe, {|| MnuOstOperacije() } )

   AAdd( _opc, "7. udaljene lokacije - razmjena podataka " )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "RAZDB", "UDLOKRAZMJENA" ) ) .AND. !_locked
      AAdd( _opcexe, {|| fin_udaljena_razmjena_podataka() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF

   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )

   AAdd( _opc, "8. sifrarnici" )
   AAdd( _opcexe, {|| MnuSifrarnik() } )

   AAdd( _opc, "9. administracija baze podataka" )

   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "MAIN", "DBADMIN" ) ) .AND. !_locked
      AAdd( _opcexe, {|| MnuAdminDB() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF

   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )

   AAdd( _opc, "K. kontrola zbira datoteka" )
   AAdd( _opcexe, {|| KontrZb() } )

   AAdd( _opc, "P. povrat dokumenta u pripremu" )
   IF ( ImaPravoPristupa( goModul:oDatabase:cName, "UT", "POVRATNALOGA" ) ) .AND. !_locked
      AAdd( _opcexe, {|| povrat_fin_naloga() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF

   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )

   AAdd( _opc, "X. parametri" )
   IF ( ImaPravoPristupa( goModul:oDataBase:cName, "PARAM", "PARAMETRI" ) )
      AAdd( _opcexe, {|| mnu_fin_params() } )
   ELSE
      AAdd( _opcexe, {|| oDb_lock:warrning() } )
   ENDIF


   f18_menu( "gfin", .T., _izbor, _opc, _opcexe )

   RETURN



METHOD setGVars()

   set_global_vars()
   set_roba_global_vars()

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   PUBLIC gRavnot := "D"
   PUBLIC gDatNal := "N"
   PUBLIC gSAKrIz := "N"
   PUBLIC gBezVracanja := "N"
   PUBLIC gBuIz := "N"
   PUBLIC gPicDEM := "9999999.99"
   PUBLIC gPicBHD := "999999999999.99"
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
   PUBLIC aRuleCols := g_rule_cols_fin()
   PUBLIC bRuleBlock := g_rule_block_fin()

   ::super:setTGVars()

   // procitaj parametre fin modula
   fin_read_params()

   PUBLIC gModul
   PUBLIC gTema
   PUBLIC gGlBaza

   gModul := "FIN"
   gTema := "OSN_MENI"
   gGlBaza := "SUBAN.DBF"

   PUBLIC cZabrana := "Opcija nedostupna za ovaj nivo !!!"

   fin_params( .T. )

   RETURN
