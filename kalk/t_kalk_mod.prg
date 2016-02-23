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


CLASS TKalkMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD mMenu
   METHOD programski_modul_osnovni_meni

ENDCLASS


METHOD new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self



METHOD mMenu()

   PRIVATE Izbor

   Izbor := 1
   gDuzKonto := 7

   gRobaBlock := {| Ch| KalkRobaBlock( Ch ) }


   ::programski_modul_osnovni_meni()

   RETURN NIL



METHOD programski_modul_osnovni_meni

   LOCAL opc := {}
   LOCAL opcexe := {}
   LOCAL Izbor := 1

   AAdd( opc,   "1. unos/ispravka dokumenata                " )
   AAdd( opcexe, {|| kalk_unos_dokumenta() } )
   AAdd( opc,   "2. izvještaji" )
   AAdd( opcexe, {|| kalk_meni_mag_izvjestaji() } )
   AAdd( opc,   "3. pregled dokumenata" )
   AAdd( opcexe, {|| kalk_pregled_dokumenata() } )
   AAdd( opc,   "4. generacija dokumenata" )
   AAdd( opcexe, {|| kalk_mnu_generacija_dokumenta() } )
   AAdd( opc,   "5. moduli - razmjena podataka " )
   AAdd( opcexe, {|| kalk_razmjena_podataka() } )
   AAdd( opc,   "6. udaljene lokacije  - razmjena podataka" )
   AAdd( opcexe, {|| kalk_udaljena_razmjena_podataka() } )
   AAdd( opc,   "7. ostale operacije nad dokumentima" )
   AAdd( opcexe, {|| kalk_ostale_operacije_doks() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc,   "8. šifarnici" )
   AAdd( opcexe, {|| kalk_sifrarnik() } )
   AAdd( opc,   "9. administriranje baze podataka" )
   AAdd( opcexe, {|| MAdminKalk() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc,   "A. štampa ažuriranog dokumenta" )
   AAdd( opcexe, {|| kalk_stampa_dokumenta( .T. ) } )
   AAdd( opc,   "P. povrat dokumenta u pripremu" )
   AAdd( opcexe, {|| kalk_povrat_dokumenta() } )
   AAdd( opc, "------------------------------------" )
   AAdd( opcexe, nil )
   AAdd( opc,   "X. parametri" )
   AAdd( opcexe, {|| kalk_params() } )

   f18_menu( "gkas", .T.,  izbor, opc, opcexe )

   RETURN .T.



METHOD set_module_gvars()

   LOCAL cPPSaMr
   LOCAL cBazniDir
   LOCAL cMrRs
   LOCAL cOdradjeno
   LOCAL cSekcija
   LOCAL cVar, cVal
   LOCAL _tmp

   info_bar( ::cName, ::cName + " kalk set gvars start " )

   PUBLIC KursLis := "1"
   PUBLIC gMetodaNC := "2"
   PUBLIC gDefNiv := "D"
   PUBLIC gDecKol := 5
   PUBLIC gKalo := "2"
   PUBLIC gMagacin := "2"
   PUBLIC gPDVMagNab := "N"
   PUBLIC gPDVMagNab := "D"
   PUBLIC gMultiPM := "D"
   PUBLIC gRCRP := "C"
   PUBLIC gPotpis := "N"
   PUBLIC g10Porez := "N"
   PUBLIC gDirFin := ""
   PUBLIC gDirMat := ""
   PUBLIC gDirFiK := ""
   PUBLIC gDirMaK := ""
   PUBLIC gDirFakt := ""
   PUBLIC gDirFaKK := ""
   PUBLIC gBrojac := "D"
   PUBLIC gRokTr := "N"
   PUBLIC gVarVP := "1"
   PUBLIC gAFin := "D"
   PUBLIC gAMat := "0"
   PUBLIC gAFakt := "D"
   PUBLIC gVodiKalo := "N"
   PUBLIC gAutoRavn := "N"
   PUBLIC gAutoCjen := "D"
   PUBLIC gLenBrKalk := 5
   PUBLIC gArtCDX := Space( 20 )
   PUBLIC gVarEv := "1"  // 1-sa cijenama   2-bez cijena
   PUBLIC c24T1 := PadR( "Tr 1", 15 )
   PUBLIC c24T2 := PadR( "Tr 2", 15 )
   PUBLIC c24T3 := PadR( "Tr 3", 15 )
   PUBLIC c24T4 := PadR( "Tr 4", 15 )
   PUBLIC c24T5 := PadR( "Tr 5", 15 )
   PUBLIC c24T6 := PadR( "Tr 6", 15 )
   PUBLIC c24T7 := PadR( "Tr 7", 15 )
   PUBLIC c24T8 := PadR( "Tr 8", 15 )
   PUBLIC c10T1 := "PREVOZ.T"
   PUBLIC c10T2 := "AKCIZE  "
   PUBLIC c10T3 := "SPED.TR "
   PUBLIC c10T4 := "CARIN.TR"
   PUBLIC c10T5 := "ZAVIS.TR"
   PUBLIC cRNT1 := "        "
   PUBLIC cRNT2 := "R.SNAGA "
   PUBLIC cRNT3 := "TROSK 3 "
   PUBLIC cRNT4 := "TROSK 4 "
   PUBLIC cRNT5 := "TROSK 5 "

   PUBLIC gTops := "0 "
   // Koristim TOPS - 0 - ne prenosi se podaci,"1 " - prod mjes 1
   PUBLIC gFakt := "0 "
   // Koristim FAKT - 0 - ne prenosi se podaci,"1 " - prod mjes 1
   PUBLIC gTopsDEST := ""
   PUBLIC gSetForm := "1"

   PUBLIC c10Var := "2"  // 1-stara varijanta izvjestaja, nova varijanta izvj
   PUBLIC g80VRT := "1"
   PUBLIC gCijene := "2" // cijene iz sifrarnika, validnost
   PUBLIC gGen16 := "1"
   PUBLIC gNiv14 := "1"

   PUBLIC gTabela := 0
   PUBLIC gPicNC := "999999.99999999"
   PUBLIC gKomFakt := "20"
   PUBLIC gKomKonto := "5611   "     // zakomision definisemo
   // konto i posebnu sifru firme u FAKT-u
   PUBLIC gVar13u11 := "1"     // varijanta za otpremu u prodavnicu
   PUBLIC gPromTar := "N"
   PUBLIC gFunKon1 := PadR( "SUBSTR(FINMAT->IDKONTO,4,2)", 80 )
   PUBLIC gFunKon2 := PadR( "SUBSTR(FINMAT->IDKONTO2,4,2)", 80 )
   PUBLIC g11bezNC := "N"
   PUBLIC gMpcPomoc := "N"
   PUBLIC gKolicFakt := "N"
   PUBLIC gRobaTrosk := "N"
   PUBLIC gRobaTr1Tip := "%"
   PUBLIC gRobaTr2Tip := "%"
   PUBLIC gRobaTr3Tip := "%"
   PUBLIC gRobaTr4Tip := "%"
   PUBLIC gRobaTr5Tip := "%"

   // dokument. koverzija valute
   PUBLIC gDokKVal := "N"
   // time out kod azuriranja dokumenta
   PUBLIC gAzurTimeout := 150
   // time out kod azuriranja fin dokumenta
   PUBLIC gAzurFinTO := 150

   // auto obrada iz cache tabele
   PUBLIC gCache := "N"
   // kontrola odstupanja nab.cijene
   PUBLIC gNC_ctrl := 0
   // matrica koja sluzi u svrhu kontrole NC
   PUBLIC aNC_ctrl := {}
   // limit za otvorene stavke
   PUBLIC gnLOst := -99

   // KALK: auto import
   // print dokumenata pri auto importu
   PUBLIC gAImpPrint := "N"
   // ravnoteza def.konto
   PUBLIC gAImpRKonto := PadR( "1370", 7 )
   // kod provjere prebacenih dokumenata odrezi sa desne strane broj karaktera
   PUBLIC gAImpRight := 0
   PUBLIC gKalks := .F.
   PUBLIC lKoristitiBK := .F.
   PUBLIC lPrikPRUC := .F.
   PUBLIC gDuzKonto

   O_KALK_PRIPR
   gDuzKonto := Len( mkonto )


   PUBLIC glZabraniVisakIP
   PUBLIC glBrojacPoKontima := .F.
   PUBLIC glEvidOtpis
   PUBLIC gcSLObrazac
   PUBLIC ZAOKRUZENJE := 2

   // inicijalizujem ovu varijablu uvijek pri startu
   // ona sluzi za automatsku obradu kalkulacija
   // vindija - varazdin
   PUBLIC lAutoObr := .F.

   cOdradjeno := "D"

   gGlBaza := "KALK.DBF"

   c10T1 := fetch_metric( "kalk_dokument_10_trosak_1", nil, c10T1 )
   c10T2 := fetch_metric( "kalk_dokument_10_trosak_2", nil, c10T2 )
   c10T3 := fetch_metric( "kalk_dokument_10_trosak_3", nil, c10T3 )
   c10T4 := fetch_metric( "kalk_dokument_10_trosak_4", nil, c10T4 )
   c10T5 := fetch_metric( "kalk_dokument_10_trosak_5", nil, c10T5 )

   cRNT1 := fetch_metric( "kalk_dokument_rn_trosak_1", nil, cRNT1 )
   cRNT2 := fetch_metric( "kalk_dokument_rn_trosak_2", nil, cRNT2 )
   cRNT3 := fetch_metric( "kalk_dokument_rn_trosak_3", nil, cRNT3 )
   cRNT4 := fetch_metric( "kalk_dokument_rn_trosak_4", nil, cRNT4 )
   cRNT5 := fetch_metric( "kalk_dokument_rn_trosak_5", nil, cRNT5 )

   c24T1 := fetch_metric( "kalk_dokument_24_trosak_1", nil, c24T1 )
   c24T2 := fetch_metric( "kalk_dokument_24_trosak_2", nil, c24T2 )
   c24T3 := fetch_metric( "kalk_dokument_24_trosak_3", nil, c24T3 )
   c24T4 := fetch_metric( "kalk_dokument_24_trosak_4", nil, c24T4 )
   c24T5 := fetch_metric( "kalk_dokument_24_trosak_5", nil, c24T5 )
   c24T6 := fetch_metric( "kalk_dokument_24_trosak_6", nil, c24T6 )
   c24T7 := fetch_metric( "kalk_dokument_24_trosak_7", nil, c24T7 )
   c24T8 := fetch_metric( "kalk_dokument_24_trosak_8", nil, c24T8 )

   gAFin := fetch_metric( "kalk_kontiranje_fin", f18_user(), gAFin )
   gAMat := fetch_metric( "kalk_kontiranje_mat", f18_user(), gAMat )
   gAFakt := fetch_metric( "kalk_kontiranje_fakt", f18_user(), gAFakt )
   gBrojac := fetch_metric( "kalk_brojac_kalkulacija", nil, gBrojac )
   gMagacin := fetch_metric( "kalk_magacin_po_nc", nil, gMagacin )
   gPDVMagNab := fetch_metric( "kalk_magacin_po_nc_pdv", nil, gPDVMagNab )
   gCijene := fetch_metric( "kalk_azuriranje_sumnjivih_dokumenata", nil, gCijene )
   gTS := fetch_metric( "kalk_tip_subjekta", nil,  gTS)
   gTabela := fetch_metric( "kalk_tip_tabele", nil, gTabela )
   gSetForm := fetch_metric( "kalk_set_formula", nil, gSetForm )
   gGen16 := fetch_metric( "kalk_generisi_16_nakon_96", f18_user(), gGen16 )
   gKomFakt := fetch_metric( "kalk_oznaka_rj_u_fakt", nil, gKomFakt )
   gKomKonto := fetch_metric( "kalk_komision_konto", nil, gKomKonto )
   gKalo := fetch_metric( "kalk_kolicina_kalo", nil, gKalo )
   gVodiKalo := fetch_metric( "kalk_voditi_kalo", nil, gVodiKalo )
   gNiv14 := fetch_metric( "kalk_tip_nivelacije_14", nil, gNiv14 )
   gMetodaNC := fetch_metric( "kalk_metoda_nc", nil, gMetodaNC )
   gDecKol := fetch_metric( "kalk_broj_decimala_za_kolicinu", nil, gDeckol )
   gDefNiv := fetch_metric( "kalk_promjena_cijena_odgovor", nil, gDefNiv )
   gVarEv := fetch_metric( "kalk_varijanta_evidencije", nil, gVarEv )
   gPicCDem := fetch_metric( "kalk_format_prikaza_cijene", nil, gPicCDEM )
   gPicProc := fetch_metric( "kalk_format_prikaza_procenta", nil, gPicProc )
   gPicDem := fetch_metric( "kalk_format_prikaza_iznosa", nil, gPicDEM )
   gPicKol := fetch_metric( "kalk_format_prikaza_kolicine", nil, gPicKol )
   gPicNc := fetch_metric( "kalk_format_prikaza_nabavne_cijene", nil, gPicNC )
   gFPicCDem := fetch_metric( "kalk_format_prikaza_cijene_prosirenje", nil, gFPicCDem )
   gFPicDem := fetch_metric( "kalk_format_prikaza_iznosa_prosirenje", nil, gFPicDem )
   gFPicKol := fetch_metric( "kalk_format_prikaza_kolicine_prosirenje", nil, gFPicKol )
   gPotpis := fetch_metric( "kalk_potpis_na_kraju_naloga", nil, gPotpis )
   gRCRP := fetch_metric( "kalk_varijanta_popusta_na_dokumentima", nil, gRCRP )
   gAutoRavn := fetch_metric( "kalk_kontiranje_automatska_ravnoteza_naloga", nil, gAutoRavn )
   gAutoCjen := fetch_metric( "kalk_automatsko_azuriranje_cijena", nil, gAutoCjen )
   gRobaTrosk := fetch_metric( "PreuzimanjeTroskovaIzSifRoba", nil, gRobaTrosk )
   gRobaTr1Tip := fetch_metric( "kalk_trosak_1_tip", nil, gRobaTr1Tip )
   gRobaTr2Tip := fetch_metric( "kalk_trosak_2_tip", nil, gRobaTr2Tip )
   gRobaTr3Tip := fetch_metric( "kalk_trosak_3_tip", nil, gRobaTr3Tip )
   gRobaTr4Tip := fetch_metric( "kalk_trosak_4_tip", nil, gRobaTr4Tip )
   gRobaTr5Tip := fetch_metric( "kalk_trosak_5_tip", nil, gRobaTr5Tip )
   gDokKVal := fetch_metric( "kalk_konverzija_valute_na_unosu", nil, gDokKVal )

   g10Porez := fetch_metric( "kalk_dokument_10_prikaz_ukalk_poreza", nil, g10Porez )
   c10Var := fetch_metric( "kalk_dokument_10_varijanta", nil, c10Var )
   g11BezNC := fetch_metric( "kalk_dokument_11_bez_nc", nil, g11bezNC )
   g80VRT := fetch_metric( "kalk_dokument_80_rekap_po_tar", nil, g80VRT )
   gVarVP := fetch_metric( "kalk_dokument_14_varijanta_poreza", nil, gVarVP )
   gVar13u11 := fetch_metric( "kalk_varijanta_fakt_13_kalk_11_cijena", nil, gVar13u11 )

   gTops := fetch_metric( "kalk_prenos_pos", f18_user(), gTops )
   gFakt := fetch_metric( "kalk_prenos_fakt", f18_user(), gFakt )
   gTopsDest := PadR( fetch_metric( "kalk_destinacija_topska", f18_user(), gTopsDest ), 100 )
   gMultiPM := fetch_metric( "kalk_tops_prenos_vise_prodajnih_mjesta", f18_user(), gMultiPM )
   gMPCPomoc := fetch_metric( "kalk_pomoc_sa_mpc", nil, gMPCPomoc )
   gKolicFakt := fetch_metric( "kalk_kolicina_kod_nivelacije_fakt", nil, gKolicFakt )
   gPromTar := fetch_metric( "kalk_zabrana_promjene_tarifa", nil, gPromTar )
   gFunKon1 := fetch_metric( "kalk_djoker_f1_kod_kontiranja", nil, gFunKon1 )
   gFunKon2 := fetch_metric( "kalk_djoker_f2_kod_kontiranja", nil, gFunKon2 )

   gAzurTimeout := fetch_metric( "kalk_timeout_kod_azuriranja", nil, gAzurTimeout )
   gAzurFinTO := fetch_metric( "kalk_timeout_kod_azuriranja_fin_naloga", nil, gAzurFinTO )
   gCache := fetch_metric( "kalk_cache_tabela", f18_user(), gCache )
   gNC_ctrl := fetch_metric( "kalk_kontrola_odstupanja_nc", f18_user(), gNC_ctrl )
   gnLOst := fetch_metric( "kalk_limit_za_otvorene_stavke", f18_user(), gnLOst )
   gLenBrKalk := fetch_metric( "kalk_duzina_brojaca_dokumenta", nil, gLenBrKalk )
   gArtCDX := fetch_metric( "kalk_index_za_pretragu_artikla", f18_user(), gArtCDX )

   gAImpPrint := fetch_metric( "kalk_auto_import_podataka_printanje", f18_user(), gAImpPrint )
   gAImpRKonto := fetch_metric( "kalk_auto_import_podataka_konto", f18_user(), gAImpRKonto )
   gAImpRight := fetch_metric( "kalk_auto_import_podataka_karakteri", f18_user(), gAImpRight )

   // iz FMK inija...

   lKoristitiBK := fetch_metric( "kalk_koristiti_barkod_pri_unosu", my_user(), lKoristitiBK )

   IF lKoristitiBK
      // ako se koristi barkod onda je duzina robe 13
      gDuzSifIni := "13"
   ENDIF

   lPrikPRUC := fetch_metric( "kalk_prikazi_kolone_pruc", nil, lPrikPRUC )

   glZabraniVisakIP := fetch_metric( "kalk_zabrani_visak_kod_ip", nil, glZabraniVisakIP )
   glBrojacPoKontima := fetch_metric( "kalk_brojac_dokumenta_po_kontima", nil, glBrojacPoKontima )

   glEvidOtpis := fetch_metric( "kalk_evidentiraj_otpis", nil, glEvidOtpis )
   gcSlObracun := fetch_metric( "kalk_sl_obrazac", nil, gcSLObrazac )

   gRobaBlock := {| Ch| KalkRobaBlock( Ch ) }

   gNW := "X" // TODO: pogledati u svim drugim modulima je "D" ?!

   info_bar( ::cName, ::cName + " - kalk set gvars end" )
   info_bar( "KALK", "params in cache: " + Alltrim( Str( params_in_cache() ) ) )

   RETURN .T.
