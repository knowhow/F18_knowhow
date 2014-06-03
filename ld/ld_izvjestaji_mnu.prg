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


#include "ld.ch"



FUNCTION ld_izvjestaji()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. kartica                                           " )
   AAdd( _opcexe, {|| ld_kartica_plate() } )
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

   RETURN




STATIC FUNCTION izvjestaji_obrasci()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _Izbor := 1

   AAdd( _opc, "1. mjesečni obrazac MIP-1023                  " )
   AAdd( _opcexe, {|| r_mip_obr() } )
   AAdd( _opc, "2. obračunski listovi (obrasci OLP i GIP)" )
   AAdd( _opcexe, {|| r_obr_list() } )
   AAdd( _opc, "3. akontacije poreza (obrasci ASD i AUG)" )
   AAdd( _opcexe, {|| r_ak_list() } )
   AAdd( _opc, "4. prijave doprinosa (JS-3400)" )
   AAdd( _opcexe, {|| r_js3400_obrazac() } )
 
   f18_menu( "obr", .F., _izbor, _opc, _opcexe )

   RETURN



STATIC FUNCTION izvjestaji_specifikacije()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. specifikacija uz isplatu plata                 " )
   AAdd( _opcexe, {|| ld_specifikacija_plate() } )
   AAdd( _opc, "2. specifikacija za samostalne poduzetnike     " )
   AAdd( _opcexe, {|| SpecPlS() } )
   AAdd( _opc, "3. specifikacija ostale samostalne djelatnosti" )
   AAdd( _opcexe, {|| SpecPlU() } )
   AAdd( _opc, "-----------------------------------------" )
   AAdd( _opcexe, {|| nil } )
   AAdd( _opc, "5. specifikacija po opštinama i RJ" )
   AAdd( _opcexe, {|| Specif2() } )
   AAdd( _opc, "6. specifikacija po rasponima primanja" )
   AAdd( _opcexe, {|| SpecifRasp() } )
   AAdd( _opc, "7. specifikacija primanja po mjesecima" )
   AAdd( _opcexe, {|| SpecifPoMjes() } )
   AAdd( _opc, "8. specif.novčanica potrebnih za isplatu plata" )
   AAdd( _opcexe, {|| SpecNovcanica() } )
   AAdd( _opc, "9. specif.prosječnog neta po stručnoj spremi" )
   AAdd( _opcexe, {|| Specif3() } )
   AAdd( _opc, "10. specifikacija primanja po RJ" )
   AAdd( _opcexe, {|| SpecPrimRj() } )

   f18_menu( "spec", .F., _izbor, _opc, _opcexe )

   RETURN




STATIC FUNCTION izvjestaji_pregledi()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. pregled plata                                  " )
   AAdd( _opcexe, {|| PregPl() } )
   AAdd( _opc, "2. pregled plata za više mjeseci  " )
   AAdd( _opcexe, {|| ppl_vise() } )
   AAdd( _opc, "3. pregled određenog primanja" )
   AAdd( _opcexe, {|| PregPrim() } )
   AAdd( _opc, "4. platni spisak" )
   AAdd( _opcexe, {|| PlatSp() } )
   AAdd( _opc, "5. platni spisak tekući račun" )
   AAdd( _opcexe, {|| PlatSpTR( "1" ) } )
   AAdd( _opc, "6. platni spisak štedna knjižica  " )
   AAdd( _opcexe, {|| PlatSpTR( "2" ) } )
   AAdd( _opc, "7. pregled primanja za period" )
   AAdd( _opcexe, {|| PregPrimPer() } )
   AAdd( _opc, "8. isplata jednog tipa primanja na tekući račun" )
   AAdd( _opcexe, {|| IsplataTR( "1" ) } )


   f18_menu( "preg", .F., _izbor, _opc, _opcexe )

   RETURN



STATIC FUNCTION izvjestaji_ostali()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. lista radnika sa netom po općini stanovanja  " )
   AAdd( _opcexe, {|| SpRadOpSt() } )
   AAdd( _opc, "2. pregled utroška po šihtaricama" )
   AAdd( _opcexe, {|| r_sh_print() } )
   AAdd( _opc, "3. lista radnika za isplatu toplog obroka" )
   AAdd( _opcexe, {|| to_list() } )

   f18_menu( "ost", .F., _izbor, _opc, _opcexe )

   RETURN


STATIC FUNCTION izvjestaji_rekapitulacije()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. rekapitulacija                         " )
   AAdd( _opcexe, {|| Rekap2( .F. ) } )
   AAdd( _opc, "2. rekapitulacija za sve radne jedinice" )
   AAdd( _opcexe, {|| Rekap2( .T. ) } )
   AAdd( _opc, "3. rekapitulacija po koeficijentima" )
   AAdd( _opcexe, {|| RekapBod() } )
   AAdd( _opc, "4. rekapitulacija neto primanja" )
   AAdd( _opcexe, {|| RekNeto() } )
   AAdd( _opc, "5. rekapitulacija tekućih računa" )
   AAdd( _opcexe, {|| RekTekRac() } )

   f18_menu( "rekap", .F., _izbor, _opc, _opcexe )

   RETURN


