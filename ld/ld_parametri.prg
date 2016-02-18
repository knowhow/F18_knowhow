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



FUNCTION ld_parametri()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   O_LD_RJ
   O_PARAMS

   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   AAdd( _opc, "1. osnovni podaci organizacione jedinice                        " )
   AAdd( _opcexe, {|| parametri_organizacije() } )
   AAdd( _opc, "2. RJ, mjesec, godina...         " )
   AAdd( _opcexe, {|| ld_set_firma() } )
   AAdd( _opc, "3. postavka zaokruzenja, valute, formata prikaza iznosa...  " )
   AAdd( _opcexe, {|| ld_set_forma() } )
   AAdd( _opc, "4. postavka nacina obracuna " )
   AAdd( _opcexe, {|| ld_set_obracun() } )
   AAdd( _opc, "5. postavka formula (uk.prim.,uk.sati,godisnji) i koeficijenata " )
   AAdd( _opcexe, {|| ld_set_formule() } )
   AAdd( _opc, "6. postavka parametara izgleda dokumenata " )
   AAdd( _opcexe, {|| ld_set_prikaz() } )
   AAdd( _opc, "7. poseban odbitak za elementarne nepogode" )
   AAdd( _opcexe, {|| ld_elementarne_nepogode_parametri() } )

   f18_menu( "par", .F., _izbor, _opc, _opcexe )

   RETURN



FUNCTION ld_get_params()

   // ---------
   gGodina := fetch_metric( "ld_godina", my_user(), gGodina )
   gRj := fetch_metric( "ld_rj", my_user(), gRj )
   gMjesec := fetch_metric( "ld_mjesec", my_user(), gMjesec )
   lViseObr := fetch_metric( "ld_vise_obracuna", NIL, lViseObr )
   gObracun := fetch_metric( "ld_obracun", my_user(), gObracun )

   // ---------
   gPicI := fetch_metric( "ld_pic_iznos", NIL, AllTrim( gPicI ) )
   gPicS := fetch_metric( "ld_pic_sati", NIL, AllTrim( gPicS ) )
   gValuta := fetch_metric( "ld_valuta", NIL, gValuta )
   gZaok2 := fetch_metric( "ld_zaok_por_dopr", NIL, gZaok2 )
   gZaok := fetch_metric( "ld_zaok_prim", NIL, gZaok )

   // ---------
   gFUPrim := fetch_metric( "ld_formula_ukupna_primanja", NIL, gFUPrim )
   gFUSati := fetch_metric( "ld_formula_ukupni_sati", NIL, gFUSati )
   gFUGod := fetch_metric( "ld_formula_godisnji", NIL, gFUGod )
   gFURaz := fetch_metric( "ld_formula_ukupna_primanja_razno", NIL, gFURaz )
   gFURSati := fetch_metric( "ld_formula_ukupni_sati_razno", NIL, gFURSati )
   gMRZ := fetch_metric( "ld_minuli_rad_koef_zene", NIL, gMRZ )
   gMRM := fetch_metric( "ld_minuli_rad_koef_muskarci", NIL, gMRM )
   gPDLimit := fetch_metric( "ld_donji_limit_poreza_doprinosa", NIL, gPDLimit )
   gBFForm := fetch_metric( "ld_formula_beneficirani_staz", NIL, gBFForm )
   gBenefSati := fetch_metric( "ld_sati_beneficirani_staz_tip", NIL, gBenefSati )
   gOsnLOdb := fetch_metric( "ld_osnovni_licni_odbitak_iznos", NIL, gOsnLOdb )
   gUgTrosk := fetch_metric( "ld_trosak_ugovori", NIL, gUgTrosk )
   gAhTrosk := fetch_metric( "ld_trosak_honorari", NIL, gAhTrosk )

   // ---------
   gVarObracun := fetch_metric( "ld_varijanta_obracuna", NIL, gVarObracun )
   gSihtarica := fetch_metric( "ld_obrada_sihtarica", NIL, gSihtarica )
   gSihtGroup := fetch_metric( "ld_obrada_sihtarica_po_grupama", NIL, gSihtGroup )


   // ----------
   gSetForm := fetch_metric( "ld_set_formula", NIL, gSetForm )
   gMinR := fetch_metric( "ld_minuli_rad", NIL, gMinR )
   gDaPorOl := fetch_metric( "ld_poreske_olaksice", NIL, gDaPorOl )
   gTipObr := fetch_metric( "ld_tip_obracuna_legacy", NIL, gTipObr )
   gUnMjesec := fetch_metric( "ld_unos_mjeseca_kod_obracuna", NIL, gUnMjesec )
   gVarSpec := fetch_metric( "ld_grupe_poslova_specifikacija", NIL, gVarSpec )
   gRadnFilter := fetch_metric( "ld_filter_radnici", NIL, gRadnFilter )

   // ----------
   gBodK := fetch_metric( "ld_opis_osnovnih_podataka", NIL, gBodK )
   gReKrKP := fetch_metric( "ld_varijanta_kartice_krediti", NIL, gReKrKP )
   gVarPP := fetch_metric( "ld_pregled_plata_varijanta", NIL, gVarPP )
   gPrBruto := fetch_metric( "ld_prikaz_bruto_iznosa_varijanta", NIL, gPrBruto )
   gPotp := fetch_metric( "ld_potpis_na_kartici_radnika", NIL, gPotp )
   gReKrOs := fetch_metric( "ld_krediti_osnova_varijanta", NIL, gReKrOs )
   gPotpRpt := fetch_metric( "ld_potpis_na_izvjestajima", NIL, gPotpRpt )
   gPotp1 := fetch_metric( "ld_potpis_red_1", NIL, gPotp1 )
   gPotp2 := fetch_metric( "ld_potpis_red_2", NIL, gPotp2 )
   gKarSDop := fetch_metric( "ld_kartica_svi_doprinosi", NIL, gKarSDop )

   RETURN




FUNCTION ld_set_firma()

   LOCAL _godina := fetch_metric( "ld_godina", my_user(), gGodina )
   LOCAL _rj := fetch_metric( "ld_rj", my_user(), gRj )
   LOCAL _mjesec := fetch_metric( "ld_mjesec", my_user(), gMjesec )
   LOCAL _v_obr := fetch_metric( "ld_vise_obracuna", NIL, lViseObr )
   LOCAL _obracun := fetch_metric( "ld_obracun", my_user(), gObracun )

   PRIVATE GetList := {}

   Box(, 4, 60 )

   @ m_x + 1, m_y + 2 SAY "Radna jedinica :" GET _rj VALID P_LD_Rj( @_rj ) PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Mjesec         :" GET _mjesec PICT "99"
   @ m_x + 3, m_y + 2 SAY "Godina         :" GET _godina PICT "9999"
   @ m_x + 4, m_y + 2 SAY "Obracun        :" GET _obracun WHEN HelpObr( .F., _obracun ) VALID ValObr( .F., _obracun )

   READ

   ClvBox()

   BoxC()

   IF ( LastKey() <> K_ESC )

      set_metric( "ld_godina", my_user(), _godina )
      gGodina := _godina

      set_metric( "ld_mjesec", my_user(), _mjesec )
      gMjesec := _mjesec

      set_metric( "ld_rj", my_user(), _rj )
      gRJ := _rj

      set_metric( "ld_obracun", my_user(), _obracun )
      gObracun := _obracun

   ENDIF

   RETURN



FUNCTION ld_set_forma()

   PRIVATE GetList := {}

   gPicI := PadR( gPicI, 15 )
   gPicS := PadR( gPicS, 15 )

   Box(, 5, 60 )
   @ m_x + 1, m_y + 2 SAY "Zaokruzenje primanja          :" GET gZaok PICT "99"
   @ m_x + 2, m_y + 2 SAY "Zaokruzenje poreza i doprinosa:" GET gZaok2 PICT "99"
   @ m_x + 3, m_y + 2 SAY "Valuta                        :" GET gValuta PICT "XXX"
   @ m_x + 4, m_y + 2 SAY "Prikaz iznosa                 :" GET gPicI
   @ m_x + 5, m_y + 2 SAY "Prikaz sati                   :" GET gPicS
   READ
   BoxC()

   IF ( LastKey() <> K_ESC )
      set_metric( "ld_pic_iznos", NIL, AllTrim( gPicI ) )
      set_metric( "ld_pic_sati", NIL, AllTrim( gPicS ) )
      set_metric( "ld_valuta", NIL, gValuta )
      set_metric( "ld_zaok_por_dopr", NIL, gZaok2 )
      set_metric( "ld_zaok_prim", NIL, gZaok )
   ENDIF

   RETURN



FUNCTION ld_set_formule()

   PRIVATE GetList := {}

   Box(, 19, 77 )

   gFURaz := PadR( gFURaz, 100 )
   gFUPrim := PadR( gFUPrim, 100 )
   gFUSati := PadR( gFUSati, 100 )
   gFURSati := PadR( gFURSati, 100 )
   gBFForm := PadR( gBFForm, 100 )

   @ m_x + 1, m_y + 2 SAY "Formula za ukupna primanja:" GET gFUPrim  PICT "@!S30"
   @ m_x + 2, m_y + 2 SAY "Formula za ukupno sati    :" GET gFUSati  PICT "@!S30"
   @ m_x + 3, m_y + 2 SAY "Formula za godisnji       :" GET gFUGod PICT "@!S30"
   @ m_x + 5, m_y + 2 SAY "Formula za uk.prim.-razno :" GET gFURaz PICT "@!S30"
   @ m_x + 6, m_y + 2 SAY "Formula za uk.sati -razno :" GET gFURSati PICT "@!S30"
   @ m_x + 8, m_y + 2 SAY "God. promjena koef.min.rada - ZENE:" GET gMRZ   PICT "9999.99"
   @ m_x + 9, m_y + 2 SAY "God. promjena koef.min.rada - MUSK:" GET gMRM   PICT "9999.99"
   @ m_x + 11, m_y + 2 SAY "% prosjecne plate kao donji limit neta za obracun poreza i doprinosa" GET gPDLimit PICT "999.99"

   @ m_x + 13, m_y + 2 SAY "Osnovni licni odbitak" GET gOsnLOdb VALID gOsnLOdb > 0 PICT "9999.99"

   @ m_x + 15, m_y + 2 SAY "  Trosak - ugovor o djelu (%):" GET gUgTrosk PICT "999.99"

   @ m_x + 16, m_y + 2 SAY "Trosak - autorski honorar (%):" GET gAhTrosk PICT "999.99"

   @ m_x + 18, m_y + 2 SAY "Kod benef.gledaj formulu:" GET gBFForm PICT "@!S30"
   @ m_x + 19, m_y + 2 SAY "Sati benef. (1 - ukupni, 2 - po obracunu):" GET gBenefSati PICT "9"

   READ

   BoxC()

   IF ( LastKey() <> K_ESC )

      set_metric( "ld_formula_ukupna_primanja", NIL, gFUPrim )
      set_metric( "ld_formula_ukupni_sati", NIL, gFUSati )
      set_metric( "ld_formula_godisnji", NIL, gFUGod )
      set_metric( "ld_formula_ukupna_primanja_razno", NIL, gFURaz )
      set_metric( "ld_formula_ukupni_sati_razno", NIL, gFURSati )
      set_metric( "ld_minuli_rad_koef_zene", NIL, gMRZ )
      set_metric( "ld_minuli_rad_koef_muskarci", NIL, gMRM )
      set_metric( "ld_donji_limit_poreza_doprinosa", NIL, gPDLimit )
      set_metric( "ld_formula_beneficirani_staz", NIL, gBFForm )
      set_metric( "ld_sati_beneficirani_staz_tip", NIL, gBenefSati )
      set_metric( "ld_osnovni_licni_odbitak_iznos", NIL, gOsnLOdb )
      set_metric( "ld_trosak_ugovori", NIL, gUgTrosk )
      set_metric( "ld_trosak_honorari", NIL, gAhTrosk )

   ENDIF

   RETURN


FUNCTION ld_set_obracun()

   LOCAL nX := 1
   LOCAL _radni_sati := fetch_metric( "ld_radni_sati", NIL, "N" )
   LOCAL _st_stopa := fetch_metric( "ld_porezi_stepenasta_stopa", NIL, "N" )
   LOCAL _v_obr_unos := fetch_metric( "ld_vise_obracuna_na_unosu", my_user(), "N" )
   PRIVATE GetList := {}

   cVarPorol := PadR( cVarPorol, 2 )

   Box(, 20, 77 )

   @ m_x + nX, m_y + 2 SAY "  ' ' - (prazno) stara varijanta obracuna"

   ++nX

   @ m_x + nX, m_y + 2 SAY "  '2' - nova varijanta obracuna, zak.pr.2009"

   ++ nX

   @ m_x + nX, m_y + 2 SAY "Odabir broja obracuna na unosu (D/N) ?" GET _v_obr_unos VALID _v_obr_unos $ "DN" PICT "@!"

   ++ nX

   @ m_x + nX, m_y + 2 SAY "Tip obracuna (legacy)" GET gTipObr
   @ m_x + nX, Col() + 1 SAY "Mogucnost unosa mjeseca pri obradi D/N:" GET gUnMjesec  PICT "@!" VALID gUnMjesec $ "DN"
   ++nX

   @ m_x + nX, m_y + 2 SAY "Koristiti set formula (sifrarnik Tipovi primanja):" GET gSetForm PICT "9"
   ++nX

   @ m_x + nX, m_y + 2 SAY "Minuli rad  %/B:" GET gMinR  VALID gMinR $ "%B"   PICT "@!"
   ++nX

   @ m_x + nX, m_y + 2 SAY "Pri obracunu napraviti poreske olaksice D/N:" GET gDaPorOl  VALID gDaPorOl $ "DN"   PICT "@!"
   ++nX

   @ m_x + nX, m_y + 2 SAY "Ako se prave por.ol.pri obracunu, koja varijanta se koristi:"
   ++nX

   @ m_x + nX, m_y + 2 SAY " '1' - POROL = RADN->porol*PAROBR->prosld/100 �Ŀ  "
   ++nX

   @ m_x + nX, m_y + 2 SAY " '2' - POROL = RADN->porol, '29' - LD->I29    ����>" GET cVarPorOl WHEN gDaPorOl == "D"   PICT "99"
   ++nX

   @ m_x + nX, m_y + 2 SAY "Grupe poslova u specif.uz platu (1-automatski/2-korisnik definise):" GET gVarSpec  VALID gVarSpec $ "12" PICT "9"
   ++nX

   @ m_x + nX, m_y + 2 SAY "Obrada sihtarice ?" GET gSihtarica VALID gSihtarica $ "DN" PICT "@!"
   @ m_x + nX, Col() + 1 SAY "Sihtarice po grupama ?" GET gSihtGroup VALID gSihtGroup $ "DN" PICT "@!"
   ++ nX

   @ m_x + nX, m_y + 2 SAY "Filter 'aktivan' u sifraniku radnika ?" GET gRadnFilter VALID gRadnFilter $ "DN" PICT "@!"
   ++ nX

   @ m_x + nX, m_y + 2 SAY "Unos i obrada radnih sati (D/N)" GET _radni_sati VALID _radni_sati $ "DN" PICT "@!"

   @ m_x + nX, m_y + 2 SAY "Porezi - stepenaste stope ? (D/N)" GET _st_stopa VALID _st_stopa $ "DN" PICT "@!"

   READ

   BoxC()

   IF ( LastKey() <> K_ESC )

      IF gSihtGroup == "D"
         gSihtarica := "N"
      ENDIF

      set_metric( "ld_set_formula", NIL, gSetForm )
      set_metric( "ld_minuli_rad", NIL, gMinR )
      set_metric( "ld_poreske_olaksice", NIL, gDaPorOl )
      set_metric( "ld_tip_obracuna_legacy", NIL, gTipObr )
      set_metric( "ld_unos_mjeseca_kod_obracuna", NIL, gUnMjesec )
      set_metric( "ld_varijanta_porezne_olaksice", NIL, cVarPorOl )
      set_metric( "ld_grupe_poslova_specifikacija", NIL, gVarSpec )
      set_metric( "ld_filter_radnici", NIL, gRadnFilter )
      set_metric( "ld_varijanta_obracuna", NIL, gVarObracun )
      set_metric( "ld_obrada_sihtarica", NIL, gSihtarica )
      set_metric( "ld_obrada_sihtarica_po_grupama", NIL, gSihtGroup )
      set_metric( "ld_radni_sati", NIL, _radni_sati )
      set_metric( "ld_porezi_stepenasta_stopa", NIL, _st_stopa )
      set_metric( "ld_vise_obracuna_na_unosu", my_user(), _v_obr_unos )

   ENDIF

   RETURN

FUNCTION ld_set_prikaz()

   LOCAL _pr_kart_pl := fetch_metric( "ld_obracun_prikaz_kartice_na_unosu", nil, "N" )
   PRIVATE GetList := {}

   gPotp1 := PadR( gPotp1, 150 )
   gPotp2 := PadR( gPotp2, 150 )

   Box(, 15, 77 )
   @ m_x + 1, m_y + 2 SAY "Krediti-rekap.po 'na osnovu' (D/N/X)?" GET gReKrOs VALID gReKrOs $ "DNX" PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Na kraju obrade odstampati listic D/N:" GET _pr_kart_pl  PICT "@!" VALID _pr_kart_pl $ "DN"
   @ m_x + 3, m_y + 2 SAY "Prikaz bruto iznosa na kartici radnika (D/N/X) " GET gPrBruto PICT "@!" VALID gPrBruto $ "DNX"
   @ m_x + 4, m_y + 2 SAY "Potpis na kartici radnika D/N:" GET gPotp  VALID gPotp $ "DN"   PICT "@!"
   @ m_x + 5, m_y + 2 SAY "Varijanta kartice plate za kredite (1/2) ?" GET gReKrKP VALID gReKrKP $ "12"
   @ m_x + 6, m_y + 2 SAY "Opis osnovnih podataka za obracun (1-bodovi/2-koeficijenti) ?" GET gBodK VALID gBodK $ "12"
   @ m_x + 7, m_y + 2 SAY "Pregled plata: varijanta izvjestaja (1/2)" GET gVarPP VALID gVarPP $ "12"
   @ m_x + 8, m_y + 2 SAY "Potpisi na svim izvjestajima (D/N)" GET gPotpRpt VALID gPotpRpt $ "DN" PICT "@!"
   READ

   IF gPotpRpt == "D"
      @ m_x + 10, m_y + 2 SAY "red 1:" GET gPotp1 PICT "@S25"
      @ m_x + 10, Col() + 1 SAY "red 2:" GET gPotp2 PICT "@S25"
      READ
   ENDIF

   @ m_x + 11, m_y + 2 SAY "Kartica plate - svi doprinosi (D/N)" GET gKarSDop VALID gKarSDop $ "DN" PICT "@!"

   READ

   BoxC()

   IF ( LastKey() <> K_ESC )

      // parametri sql/db
      set_metric( "ld_obracun_prikaz_kartice_na_unosu", NIL, _pr_kart_pl )
      set_metric( "ld_opis_osnovnih_podataka", NIL, gBodK )
      set_metric( "ld_varijanta_kartice_krediti", NIL, gReKrKP )
      set_metric( "ld_pregled_plata_varijanta", NIL, gVarPP )
      set_metric( "ld_prikaz_bruto_iznosa_varijanta", NIL, gPrBruto )
      set_metric( "ld_potpis_na_kartici_radnika", NIL, gPotp )
      set_metric( "ld_krediti_osnova_varijanta", NIL, gReKrOs )
      set_metric( "ld_potpis_na_izvjestajima", NIL, gPotpRpt )
      set_metric( "ld_potpis_red_1", NIL, gPotp1 )
      set_metric( "ld_potpis_red_2", NIL, gPotp2 )
      set_metric( "ld_kartica_svi_doprinosi", NIL, gKarSDop )

   ENDIF

   RETURN


FUNCTION LDPoljaINI()

   PUBLIC cLDPolja := 60

   RETURN



FUNCTION helpobr( lIzv, cObracun )

   IF lIzv == nil
      lIzv := .F.
   ENDIF

   IF gNHelpObr = 0
      Box(, 3 + IF( lIzv, 1, 0 ), 40 )
      @ m_x + 0, m_y + 2 SAY PadC( " POMOC: ", 36, "�" )
      IF lIzv
         @ m_x + 2, m_y + 2 SAY "Ukucajte broj obracuna (1/2/.../9)"
         @ m_x + 3, m_y + 2 SAY "ili prazno ako zelite sve obracune"
      ELSE
         @ m_x + 2, m_y + 2 SAY "Ukucajte broj obracuna (1/2/.../9)"
      ENDIF
      ++gnHelpObr
   ENDIF

   RETURN .T.




FUNCTION ValObr( lIzv, cObracun )

   LOCAL lVrati := .T.

   IF lIzv == nil
      lIzv := .F.
   ENDIF

   IF lIzv
      lVrati := ( cObracun $ " 123456789" )
   ELSE
      lVrati := ( cObracun $ "123456789" )
   ENDIF

   IF gnHelpObr > 0 .AND. lVrati
      BoxC()
      --gnHelpObr
   ENDIF

   RETURN lVrati


FUNCTION ClVBox()

   LOCAL i := 0

   FOR i := 1 TO gnHelpObr
      BoxC()
   NEXT
   gnHelpObr := 0

   RETURN
