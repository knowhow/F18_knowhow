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


FUNCTION pos_main_menu_prodavac()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. priprema računa                        " )
   AAdd( _opcexe, {|| _pos_prodavac_racun() } )


   AAdd( _opc, "2. pregled ažuriranih racuna  " )
   AAdd( _opcexe, {|| pos_pregled_racuna( .F. ) } )


   AAdd( _opc, "R. trenutna realizacija radnika" )
   AAdd( _opcexe, {|| realizacija_radnik( .T., "P", .F. ) } )

   AAdd( _opc, "A. trenutna realizacija po artiklima" )
   AAdd( _opcexe, {|| realizacija_radnik( .T., "R", .F. ) } )


   IF fiscal_opt_active()

      AAdd( _opc, "F. fiskalne funkcije - prodavac" )
      AAdd( _opcexe, {|| fiskalni_izvjestaji_komande( .T., .T. ) } )

   ENDIF

   f18_menu( "prod", .F., _izbor, _opc, _opcexe )

   CLOSE ALL

   RETURN


STATIC FUNCTION _pos_prodavac_racun()

   pos_unos_ispravka_racuna()
   zakljuci_pos_racun()

   RETURN .T.



FUNCTION MnuZakljRacuna()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. napravi zbirni racun            " )
   AAdd( opcexe, {|| RekapViseRacuna() } )
   AAdd( opc, "2. pregled nezakljucenih racuna    " )
   AAdd( opcexe, {|| PreglNezakljRN() } )
   AAdd( opc, "3. setuj sve RN na zakljuceno      " )
   AAdd( opcexe, {|| SetujZakljuceno() } )

   Menu_SC( "zrn" )

   RETURN .T.
