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


FUNCTION ld_izvjestaji()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. kartice                                           " )
   AAdd( _opcexe, {|| izvjestaji_kartice() } )
   AAdd( _opc, "2. rekapitulacije" )
   AAdd( _opcexe, {|| izvjestaji_rekapitulacije() } )
   AAdd( _opc, "3. pregledi" )
   AAdd( _opcexe, {|| izvjestaji_pregledi() } )
   AAdd( _opc, "4. specifikacije" )
   AAdd( _opcexe, {|| izvjestaji_specifikacije() } )
   AAdd( _opc, "5. ostali izvještaji" )
   AAdd( _opcexe, {|| izvjestaji_ostali() } )
   AAdd( _opc, "6. obrasci (MIP/GIP/OLP)" )
   AAdd( _opcexe, {|| izvjestaji_obrasci() } )

   f18_menu( "izvj", .F., _izbor, _opc, _opcexe )

   RETURN .T.


STATIC FUNCTION izvjestaji_kartice()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _Izbor := 1

   AAdd( _opc, "1. kartica plate                  " )
   AAdd( _opcexe, {|| ld_kartica_plate() } )
   AAdd( _opc, "2. kartica plate za više mjeseci" )
   AAdd( _opcexe, {|| ld_kartica_plate_za_vise_mjeseci() } )

   f18_menu( "krt", .F., _izbor, _opc, _opcexe )

   RETURN .T.



STATIC FUNCTION izvjestaji_obrasci()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _Izbor := 1

   AAdd( _opc, "1. mjesečni obrazac MIP-1023                  " )
   AAdd( _opcexe, {|| ld_mip_obrazac() } )
   AAdd( _opc, "2. obračunski listovi (obrasci OLP i GIP)" )
   AAdd( _opcexe, {|| ld_olp_gip_obrazac() } )
   AAdd( _opc, "3. akontacije poreza (obrasci ASD i AUG)" )
   AAdd( _opcexe, {|| ld_asd_aug_obrazac() } )
   AAdd( _opc, "4. prijave doprinosa (JS-3400)" )
   AAdd( _opcexe, {|| ld_js3400_obrazac() } )

   f18_menu( "obr", .F., _izbor, _opc, _opcexe )

   RETURN .T.



STATIC FUNCTION izvjestaji_specifikacije()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. specifikacija uz isplatu plata                              " )
   AAdd( _opcexe, {|| ld_specifikacija_plate() } )
   AAdd( _opc, "2. specifikacija za samostalne poduzetnike     " )
   AAdd( _opcexe, {|| ld_specifikacija_plate_samostalni() } )
   AAdd( _opc, "3. specifikacija ostale samostalne djelatnosti" )
   AAdd( _opcexe, {|| ld_specifikacija_plate_ostali() } )
   AAdd( _opc, "4. specifikacija primanja po mjesecima" )
   AAdd( _opcexe, {|| ld_specifikacija_po_mjesecima() } )
   AAdd( _opc, "5. specifikacija primanja po RJ" )
   AAdd( _opcexe, {|| ld_specifikacija_po_rj() } )
   AAdd( _opc, "6. specifikacija po rasponima primanja" )
   AAdd( _opcexe, {|| ld_specifikacija_po_rasponima_primanja() } )
   AAdd( _opc, "7. specifikacija neto primanja radnika po općinama stanovanja " )
   AAdd( _opcexe, {|| ld_specifikacija_neto_primanja_po_opcinama() } )


   f18_menu( "spec", .F., _izbor, _opc, _opcexe )

   RETURN .T.



STATIC FUNCTION izvjestaji_pregledi()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. pregled plata                                  " )
   AAdd( _opcexe, {|| pregled_plata() } )
   AAdd( _opc, "2. pregled plata za više mjeseci  " )
   AAdd( _opcexe, {|| ld_pregled_plata_za_period() } )
   AAdd( _opc, "3. pregled određenog primanja" )
   AAdd( _opcexe, {|| ld_pregled_primanja() } )
   AAdd( _opc, "4. pregled primanja za period" )
   AAdd( _opcexe, {|| ld_pregled_primanja_za_period() } )
   AAdd( _opc, "5. platni spisak" )
   AAdd( _opcexe, {|| ld_platni_spisak() } )
   AAdd( _opc, "6. platni spisak tekući račun" )
   AAdd( _opcexe, {|| ld_platni_spisak_tekuci_racun( "1" ) } )
   AAdd( _opc, "8. isplata jednog tipa primanja na tekući račun" )
   AAdd( _opcexe, {|| ld_pregled_isplate_za_tekuci_racun( "1" ) } )

   f18_menu( "preg", .F., _izbor, _opc, _opcexe )

   RETURN



STATIC FUNCTION izvjestaji_ostali()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. pregled utroška po šihtaricama                        " )
   AAdd( _opcexe, {|| ld_utrosak_po_sihtaricama() } )
   AAdd( _opc, "2. lista radnika za isplatu toplog obroka" )
   AAdd( _opcexe, {|| ld_lista_isplate_toplog_obroka() } )

   f18_menu( "ost", .F., _izbor, _opc, _opcexe )

   RETURN .T.


STATIC FUNCTION izvjestaji_rekapitulacije()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. rekapitulacija plate za radnu jedinicu   " )
   AAdd( _opcexe, {|| ld_rekapitulacija( .F. ) } )
   AAdd( _opc, "2. rekapitulacija za sve radne jedinice" )
   AAdd( _opcexe, {|| ld_rekapitulacija( .T. ) } )

   f18_menu( "rekap", .F., _izbor, _opc, _opcexe )

   RETURN .T.
