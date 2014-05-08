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
   LOCAL _Izbor := 1

   AAdd( _opc, "1. kartice                                           " )
   AAdd( _opcexe, {|| MnuIzvK() } )
   AAdd( _opc, "2. rekapitulacije" )
   AAdd( _opcexe, {|| MnuIzvR() } )
   AAdd( _opc, "3. pregledi" )
   AAdd( _opcexe, {|| MnuIzvP() } )
   AAdd( _opc, "4. specifikacije" )
   AAdd( _opcexe, {|| MnuIzvS() } )

   IF gVarObracun == "2"
      AAdd( _opc, "5. specifikacije specijalni tipovi rada" )
      AAdd( _opcexe, {|| m_spec_o() } )
   ENDIF

   AAdd( _opc, "6. ostali izvjestaji" )
   AAdd( _opcexe, {|| MnuIzvO() } )

   IF gVarObracun == "2"

      AAdd( _opc, "-----------------------------------------" )
      AAdd( _opcexe, {|| nil } )
      AAdd( _opc, "J. prijave doprinosa (JS-3400)" )
      AAdd( _opcexe, {|| r_js3400_obrazac() } )
      AAdd( _opc, "O. obracunski listovi (obrasci OLP i GIP)" )
      AAdd( _opcexe, {|| r_obr_list() } )
      AAdd( _opc, "P. akontacije poreza (obrasci ASD i AUG)" )
      AAdd( _opcexe, {|| r_ak_list() } )
      AAdd( _opc, "M. mjesecni obrazac MIP-1023" )
      AAdd( _opcexe, {|| r_mip_obr() } )
      AAdd( _opc, "E. poreska kartica : export" )
      AAdd( _opcexe, {|| pk_export() } )

   ENDIF

   f18_menu( "izvj", .F., _izbor, _opc, _opcexe )

   RETURN




STATIC FUNCTION MnuIzvK()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _Izbor := 1

   AAdd( _opc, "1. kartice plate                      " )
   AAdd( _opcexe, {|| KartPl() } )
   AAdd( _opc, "2. kartica plate za period (za m4)" )
   AAdd( _opcexe, {|| UKartPl() } )

   f18_menu( "kart", .F., _izbor, _opc, _opcexe )

   RETURN



STATIC FUNCTION m_spec_o()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _Izbor := 1

   AAdd( _opc, "1. specifikacija za samostalne poduzetnike     " )
   AAdd( _opcexe, {|| SpecPlS() } )
   AAdd( _opc, "2. specifikacija ostale samostalne djelatnosti" )
   AAdd( _opcexe, {|| SpecPlU() } )

   f18_menu( "spec2", .F., _izbor, _opc, _opcexe )

   RETURN


STATIC FUNCTION MnuIzvS()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. specifikacija uz isplatu plata                 " )
   IF gVarObracun == "2"
      AAdd( opcexe, {|| SpecPl2() } )
   ELSE
      AAdd( opcexe, {|| Specif() } )
   ENDIF

   AAdd( opc, "2. specifikacija po opštinama i RJ" )
   AAdd( opcexe, {|| Specif2() } )
   AAdd( opc, "3. specifikacija po rasponima primanja" )
   AAdd( opcexe, {|| SpecifRasp() } )
   AAdd( opc, "4. specifikacija primanja po mjesecima" )
   AAdd( opcexe, {|| SpecifPoMjes() } )
   AAdd( opc, "5. specif.novcanica potrebnih za isplatu plata" )
   AAdd( opcexe, {|| SpecNovcanica() } )
   AAdd( opc, "6. spec. prosječnog neta po stručnoj spremi" )
   AAdd( opcexe, {|| Specif3() } )
   AAdd( opc, "7. specifikacija primanja po RJ" )
   AAdd( opcexe, {|| SpecPrimRj() } )

   Menu_SC( "spec" )

   RETURN




STATIC FUNCTION MnuIzvP()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. pregled plata                                  " )
   AAdd( opcexe, {|| PregPl() } )
   AAdd( opc, "1a. pregled plata za vise mjeseci  " )
   AAdd( opcexe, {|| ppl_vise() } )
   AAdd( opc, "2. pregled odredjenog primanja" )
   AAdd( opcexe, {|| PregPrim() } )
   AAdd( opc, "3. platni spisak" )
   AAdd( opcexe, {|| PlatSp() } )
   AAdd( opc, "4. platni spisak tekuci racun" )
   AAdd( opcexe, {|| PlatSpTR( "1" ) } )
   AAdd( opc, "5. platni spisak stedna knj  " )
   AAdd( opcexe, {|| PlatSpTR( "2" ) } )
   AAdd( opc, "6. pregled primanja za period" )
   AAdd( opcexe, {|| PregPrimPer() } )
   AAdd( opc, "7. pregled obracunatih doprinosa" )
   AAdd( opcexe, {|| ld_pregled_obr_doprinosa() } )
   AAdd( opc, "8. isplata jednog tipa primanja na tekuci racun" )
   AAdd( opcexe, {|| IsplataTR( "1" ) } )


   Menu_SC( "preg" )

   RETURN


STATIC FUNCTION MnuIzvO()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. lista radnika sa netom po opst.stanovanja  " )
   AAdd( opcexe, {|| SpRadOpSt() } )

   IF ( IsRamaGlas() )
      AAdd( opc, "2. pregled plata po radnim nalozima    " )
      AAdd( opcexe, {|| PlatePoRNalozima() } )
   ENDIF

   AAdd( opc, "S. pregled utroska po sihtaricama" )
   AAdd( opcexe, {|| r_sh_print() } )

   AAdd( opc, "T. lista radnika za isplatu toplog obroka" )
   AAdd( opcexe, {|| to_list() } )


   Menu_SC( "ost" )

   RETURN


STATIC FUNCTION MnuIzvR()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. rekapitulacija                         " )
   IF gVarObracun == "2"
      AAdd( opcexe, {|| Rekap2( .F. ) } )
   ELSE
      AAdd( opcexe, {|| Rekap( .F. ) } )
   ENDIF
   AAdd( opc, "2. rekapitulacija za sve rj" )
   IF gVarObracun == "2"
      AAdd( opcexe, {|| Rekap2( .T. ) } )
   ELSE
      AAdd( opcexe, {|| Rekap( .T. ) } )
   ENDIF
   AAdd( opc, "3. rekapitulacija po koeficijentima" )
   AAdd( opcexe, {|| RekapBod() } )
   AAdd( opc, "4. rekapitulacija neto primanja" )
   AAdd( opcexe, {|| RekNeto() } )
   AAdd( opc, "5. rekapitulacija tekucih racuna" )
   AAdd( opcexe, {|| RekTekRac() } )

   Menu_SC( "rekap" )

   RETURN
