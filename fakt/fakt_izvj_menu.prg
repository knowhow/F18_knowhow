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

FUNCTION fakt_izvjestaji()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. stanje robe                                          " )
   AAdd( _opcexe, {|| fakt_stanje_robe() } )
   AAdd( _opc, "2. lager lista - specifikacija   " )
   AAdd( _opcexe, {|| fakt_lager_lista() } )
   AAdd( _opc, "3. kartica" )
   AAdd( _opcexe, {|| fakt_kartica() } )
   AAdd( _opc, "5. usporedna lager lista fakt <-> kalk" )
   AAdd( _opcexe, {|| usporedna_lista_fakt_kalk( .F. ) } )
   AAdd( _opc, "6. realizacija kumulativno po partnerima" )
   AAdd( _opcexe, {|| fakt_real_partnera() } )

   AAdd( _opc, "7. specifikacija prodaje - realizacija po kolicinama" )
   AAdd( _opcexe, {|| fakt_specif_prodaje_real_kolicina() } )

   AAdd( _opc, "8. kolicinski pregled isporuke robe po partnerima " )
   AAdd( _opcexe, {|| spec_kol_partn() } )
   AAdd( _opc, "9. realizacija maloprodaje " )
   AAdd( _opcexe, {|| fakt_real_maloprodaje() } )

   IF fiscal_opt_active()
      AAdd( _opc, "F. fiskalni izvještaji i komande " )
      AAdd( _opcexe, {|| fiskalni_izvjestaji_komande() } )
   ENDIF

   PRIVATE fID_J := .F.

   f18_menu( "izvj", .F., _izbor, _opc, _opcexe )

   RETURN .T.
