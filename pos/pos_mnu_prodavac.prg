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


FUNCTION pos_main_menu_prodavac()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. priprema racuna                        " )
   AAdd( _opcexe, {|| _pos_prodavac_racun() } )
	
   IF gStolovi == "D"
      AAdd( _opc, "2. zakljucenje - placanje stola " )
      AAdd( _opcexe, {|| g_zak_sto() } )
   ENDIF

   AAdd( _opc, "2. pregled azuriranih racuna  " )
   AAdd( _opcexe, {|| pos_pregled_racuna( .F. ) } )

   AAdd( _opc, "-------------------------------------------" )
   AAdd( _opcexe, {|| nil } )

   AAdd( _opc, "5. trenutna realizacija radnika" )
   AAdd( _opcexe, {|| realizacija_radnik( .T., "P", .F. ) } )

   AAdd( _opc, "6. trenutna realizacija po artiklima" )
   AAdd( _opcexe, {|| realizacija_radnik( .T., "R", .F. ) } )

   // AADD(opc,"7. porezna faktura za posljednji racun")
   // AADD(opcexe, {|| f7_pf_traka()})

   AAdd( _opc, "-------------------------------------------" )
   AAdd( _opcexe, {|| nil } )


   IF fiscal_opt_active()

      AAdd( _opc, "F. fiskalne funkcije - prodavac" )
      AAdd( _opcexe, {|| fiskalni_izvjestaji_komande( .T., .T. ) } )

   endif

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

   RETURN
