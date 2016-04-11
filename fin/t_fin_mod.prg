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

#include "f18.ch"

CLASS TFinMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD mMenu
   METHOD programski_modul_osnovni_meni

ENDCLASS


METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self



METHOD mMenu()

   //auto_kzb()

   my_close_all_dbf()

   ::programski_modul_osnovni_meni()

   RETURN NIL


METHOD programski_modul_osnovni_meni()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}


   AAdd( _opc, "1. unos/ispravka dokumenta                   " )
   AAdd( _opcexe, {|| fin_unos_naloga() } )
   AAdd( _opc, "2. izvještaji" )
   AAdd( _opcexe, {|| fin_izvjestaji() } )
   AAdd( _opc, "3. pregled dokumenata" )
   AAdd( _opcexe, {|| MnuPregledDokumenata() } )
   AAdd( _opc, "4. generacija dokumenata" )
   AAdd( _opcexe, {|| MnuGenDok() } )
   AAdd( _opc, "5. moduli - razmjena podataka" )
   AAdd( _opcexe, {|| MnuRazmjenaPodataka() } )
   AAdd( _opc, "6. ostale operacije nad dokumentima" )
   AAdd( _opcexe, {|| MnuOstOperacije() } )
   AAdd( _opc, "7. udaljene lokacije - razmjena podataka " )
   AAdd( _opcexe, {|| fin_udaljena_razmjena_podataka() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "8. matični podaci - šifarnici" )
   AAdd( _opcexe, {|| MnuSifrarnik() } )
   AAdd( _opc, "9. administracija baze podataka" )
   AAdd( _opcexe, {|| fin_admin_opcije_menu() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "K. kontrola zbira datoteka" )
   AAdd( _opcexe, {|| fin_kontrola_zbira() } )
   AAdd( _opc, "P. povrat dokumenta u pripremu" )
   AAdd( _opcexe, {|| fin_povrat_naloga() } )
   AAdd( _opc, "------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "X. parametri" )
   AAdd( _opcexe, {|| mnu_fin_params() } )

   f18_menu( "gfin", .T., _izbor, _opc, _opcexe )

   RETURN .T.



METHOD set_module_gvars()


   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   PUBLIC aRuleCols := get_rule_field_cols_fin()
   PUBLIC bRuleBlock := get_rule_field_block_fin()

   ::super:setTGVars()

   fin_read_params()


   gModul := "FIN"

   fin_params( .T. )

   info_bar( "FIN", "params in cache: " + Alltrim( Str( params_in_cache() ) ) )
   RETURN .T.
