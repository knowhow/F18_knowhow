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

// ---------------------------------
// ---------------------------------
FUNCTION fakt_pregled_dokumenata()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. štampa azuriranog dokumenta                               " )
   AAdd( _opcexe, {|| fakt_stampa_azuriranog() } )
   AAdd( _opc, "2. pregled liste dokumenata" )
   AAdd( _opcexe, {|| fakt_pregled_liste_dokumenata() } )
   AAdd( _opc, "3. štampa/export odt dokumenata po zadanom uslovu" )
   AAdd( _opcexe, {|| stdokodt_grupno() } )

   f18_menu( "stfak", .F., _izbor, _opc, _opcexe )

   my_close_all_dbf()

   RETURN .F.


FUNCTION fakt_ostale_operacije_doks()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. povrat dokumenta u pripremu       " )
   AAdd( _opcexe, {|| Povrat_fakt_dokumenta() } )

   AAdd( _opc, "2. povrat dokumenata prema kriteriju " )
   AAdd( _opcexe, {|| if( SigmaSif(), Povrat_fakt_po_kriteriju(), nil ) } )

   AAdd( _opc, "3. prekid rezervacije" )
   AAdd( _opcexe, {|| Povrat_fakt_dokumenta( .T. ) } )

   AAdd( _opc, "A. administrativne opcije " )
   AAdd( _opcexe, {|| fakt_admin_menu() } )

   AAdd( _opc, "B. podesenje brojaca dokumenta" )
   AAdd( _opcexe, {|| fakt_set_param_broj_dokumenta() } )

   f18_menu( "ostop", .F., _izbor, _opc, _opcexe )

   RETURN .F.
