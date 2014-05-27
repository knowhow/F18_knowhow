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


#include "ld.ch"


FUNCTION ld_obracun()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. unos                              " )
   AAdd( _opcexe, {|| ld_unos_obracuna() } )
   AAdd( _opc, "2. administracija obracuna           " )
   AAdd( _opcexe, {|| ld_obracun_mnu_admin() } )

   f18_menu( "obr", .F., _izbor, _opc, _opcexe )

   RETURN


FUNCTION ld_obracun_mnu_admin()

   LOCAL _radni_sati := fetch_metric( "ld_radni_sati", NIL, "N" )
   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. otvori / zakljuci obracun                     " )

   IF gZastitaObracuna == "D"
      AAdd( _opcexe, {|| DlgZakljucenje() } )
   ELSE
      AAdd( _opcexe, {|| MsgBeep( "Opcija nije dostupna !" ) } )
   ENDIF

   AAdd( _opc, "2. radnici obradjeni vise puta za isti mjesec" )
   AAdd( _opcexe, {|| ld_obracun_napravljen_vise_puta() } )

   AAdd( _opc, "3. promjeni varijantu obracuna za obracun" )
   AAdd( _opcexe, {|| ld_promjeni_varijantu_obracuna() } )

   IF gVarObracun == "2"
      AAdd( _opc, "I. unos datuma isplate placa" )
      AAdd( _opcexe, {|| unos_datuma_isplate_place() } )
   ENDIF

   IF gSihtGroup == "D"
      AAdd( _opc, "S. obrada sihtarica" )
      AAdd( _opcexe, {|| siht_obr() } )
   ENDIF

   IF _radni_sati == "D"
      AAdd( _opc, "R. pregled/ispravka radnih sati radnika" )
      AAdd( _opcexe, {|| edRadniSati() } )
   ENDIF

   f18_menu( "ao", .F., _izbor, _opc, _opcexe )

   RETURN

FUNCTION siht_obr()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. unos/ispravka                " )
   AAdd( _opcexe, {|| def_siht() } )
   AAdd( _opc, "2. pregled unesenih sihtarica" )
   AAdd( _opcexe, {|| get_siht() } )
   AAdd( _opc, "3. pregled ukupnih sati po siht." )
   AAdd( _opcexe, {|| get_siht2() } )
   AAdd( _opc, "4. brisanje sihtarice " )
   AAdd( _opcexe, {|| del_siht() } )

   f18_menu( "sobr", .F., _izbor, _opc, _opcexe )

   RETURN
