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


FUNCTION kalk_params()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   O_KONTO

   AAdd( _opc, "1. osnovni podaci o firmi                                 " )
   AAdd( _opcexe, {|| parametri_organizacije() } )

   AAdd( _opc, "2. metoda proracuna NC, mogucnosti ispravke dokumenata " )
   AAdd( _opcexe, {|| kalk_par_metoda_nc( 'D' ) } )

   AAdd( _opc, "3. varijante obrade i prikaza pojedinih dokumenata " )
   AAdd( _opcexe, {|| kalk_par_varijante_prikaza( 'D' ) } )

   AAdd( _opc, "4. nazivi troskova za 10-ku " )
   AAdd( _opcexe, {|| kalk_troskovi_10ka( 'D' ) } )

   AAdd( _opc, "5. nazivi troskova za 24-ku" )
   AAdd( _opcexe, {|| kalk_par_troskovi_24( 'D' ) } )

   AAdd( _opc, "6. nazivi troskova za RN" )
   AAdd( _opcexe, {|| kalk_par_troskovi_rn( 'D' ) } )

   AAdd( _opc, "7. prikaz cijene,%,iznosa" )
   AAdd( _opcexe, {|| kalk_par_cijene( 'D' ) } )

   AAdd( _opc, "8. nacin formiranja zavisnih dokumenata" )
   AAdd( _opcexe, {|| kalk_par_zavisni_dokumenti( 'D' ) } )

   AAdd( _opc, "9. lokacije FIN/MAT/FAKT .." )
   AAdd( _opcexe, {|| SetOdirs( 'D' ) } )

   AAdd( _opc, "A. parametri za komisionu prodaju" )
   AAdd( _opcexe, {|| SetKomis( 'D' ) } )

   AAdd( _opc, "B. parametri - razno" )
   AAdd( _opcexe, {|| kalk_par_razno( 'D' ) } )

   f18_menu( "pars", .F., _izbor, _opc, _opcexe )

   gNW := "X"

   my_close_all_dbf()

   RETURN




FUNCTION kalk_par_varijante_prikaza()

   LOCAL nX := 1
   PRIVATE  GetList := {}

   Box(, 23, 76, .F., "Varijante obrade i prikaza pojedinih dokumenata" )

   @ m_x + nX, m_y + 2 SAY "14 -Varijanta poreza na RUC u VP 1/2 (1-naprijed,2-nazad)"  GET gVarVP  VALID gVarVP $ "12"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "14 - Nivelaciju izvrsiti na ukupno stanje/na prodanu kolicinu  1/2 ?" GET gNiv14  VALID gNiv14 $ "12"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "10 - Varijanta izvjestaja (1/2/3)" GET c10Var  VALID c10Var $ "123"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "10 - prikaz ukalkulisanog poreza (D/N)" GET  g10Porez  PICT "@!" VALID g10Porez $ "DN"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "10 - ** kolicina = (1) kol-kalo ; (2) kol" GET gKalo VALID gKalo $ "12"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "10 - automatsko preuzimanje troskova iz sifrarnika robe ? (0/D/N)" GET gRobaTrosk VALID gRobaTrosk $ "0DN" PICT "@!"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "   default tip za pojedini trosak:"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "   " + c10T1 GET gRobaTr1Tip VALID gRobaTr1Tip $ " %URA" PICT "@!"

   @ m_x + nX, Col() + 1 SAY c10T2 GET gRobaTr2Tip VALID gRobaTr2Tip $ " %URA" PICT "@!"

   @ m_x + nX, Col() + 1 SAY c10T3 GET gRobaTr3Tip VALID gRobaTr3Tip $ " %URA" PICT "@!"

   @ m_x + nX, Col() + 1 SAY c10T4 GET gRobaTr4Tip VALID gRobaTr4Tip $ " %URA" PICT "@!"

   @ m_x + nX, Col() + 1 SAY c10T5 GET gRobaTr5Tip VALID gRobaTr5Tip $ " %URA" PICT "@!"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "10 - pomoc sa koverzijom valute pri unosu dokumenta (D/N)" GET gDokKVal VALID gDokKVal $ "DN" PICT "@!"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Voditi kalo pri ulazu " GET gVodiKalo VALID gVodiKalo $ "DN" PICT "@!"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Program se koristi iskljucivo za vodjenje magacina po NC  Da-1 / Ne-2 " GET gMagacin VALID gMagacin $ "12"

   IF IsPDV()

      nX += 1

   ENDIF

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Varijanta FAKT13->KALK11 ( 1-mpc iz sifrarnika, 2-mpc iz FAKT13)" GET  gVar13u11  PICT "@!" VALID gVar13u11 $ "12"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Varijanta KALK 11 bez prikaza NC i storna RUC-a (D/N)" GET  g11bezNC  PICT "@!" VALID g11bezNC $ "DN"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Pri ulaznoj kalkulaciji pomoc sa C.sa PDV (D/N)" GET  gMPCPomoc PICT "@!" VALID gMPCPomoc $ "DN"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Varijanta popusta na dokumentima, default P-%, C-cijena" GET gRCRP

   nX += 1

   @ m_x + nX, m_y + 2 SAY "80 - var.rek.po tarifama ( 1 -samo ukupno / 2 -prod.1,prod.2,ukupno)" GET  g80VRT PICT "9" VALID g80VRT $ "12"

   nX += 2

   @ m_x + nX, m_y + 2 SAY "Kolicina za nivelaciju iz FAKT-a " GET  gKolicFakt VALID gKolicFakt $ "DN"  PICT "@!"

   @ m_x + nX, Col() + 1 SAY "Auto ravnoteza naloga (FIN):" GET gAutoRavn VALID gAutoRavn $ "DN" PICT "@!"

   nX += 1

   @ m_x + nX, m_y + 2 SAY "Automatsko azuriranje cijena u sifrarnik (D/N)" GET gAutoCjen VALID gAutoCjen $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      set_metric( "kalk_magacin_po_nc", nil, gMagacin )


      set_metric( "kalk_kolicina_kalo", nil, gKalo )
      set_metric( "kalk_voditi_kalo", nil, gVodiKalo )
      set_metric( "kalk_dokument_10_prikaz_ukalk_poreza", nil, g10Porez )
      set_metric( "kalk_dokument_14_varijanta_poreza", nil, gVarVP )
      set_metric( "kalk_dokument_10_varijanta", nil, c10Var )
      set_metric( "kalk_dokument_11_bez_nc", nil, g11bezNC )
      set_metric( "kalk_dokument_80_rekap_po_tar", nil, g80VRT )
      set_metric( "kalk_tip_nivelacije_14", nil, gNiv14 )
      set_metric( "kalk_varijanta_fakt_13_kalk_11_cijena", nil, gVar13u11 )
      set_metric( "kalk_pomoc_sa_mpc", nil, gMPCPomoc )
      set_metric( "kalk_kolicina_kod_nivelacije_fakt", nil, gKolicFakt )
      set_metric( "kalk_preuzimanje_troskova_iz_sif_roba", nil, gRobaTrosk )
      set_metric( "kalk_varijanta_popusta_na_dokumentima", nil, gRCRP )
      set_metric( "kalk_kontiranje_automatska_ravnoteza_naloga", nil, gAutoRavn )
      set_metric( "kalk_automatsko_azuriranje_cijena", nil, gAutoCjen )
      set_metric( "kalk_trosak_1_tip", nil, gRobaTr1Tip )
      set_metric( "kalk_trosak_2_tip", nil, gRobaTr2Tip )
      set_metric( "kalk_trosak_3_tip", nil, gRobaTr3Tip )
      set_metric( "kalk_trosak_4_tip", nil, gRobaTr4Tip )
      set_metric( "kalk_trosak_5_tip", nil, gRobaTr5Tip )
      set_metric( "kalk_konverzija_valute_na_unosu", nil, gDokKVal )

   ENDIF

   RETURN NIL


// kalk :: parametri razno
FUNCTION kalk_par_razno()

   LOCAL _brojac := "N"
   LOCAL _unos_barkod := "N"
   LOCAL _x := 1
   LOCAL _reset_roba := fetch_metric( "kalk_reset_artikla_kod_unosa", my_user(), "N" )
   LOCAL _rabat := fetch_metric( "pregled_rabata_kod_ulaza", my_user(), "N" )
   LOCAL _vise_konta := fetch_metric( "kalk_dokument_vise_konta", NIL, "N" )
   LOCAL _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" )
   LOCAL _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" )
   PRIVATE  GetList := {}

   IF glBrojacPoKontima
      _brojac := "D"
   ENDIF

   IF lKoristitiBK
      _unos_barkod := "D"
   ENDIF

   Box(, 20, 75, .F., "RAZNO" )

   @ m_x + _x, m_y + 2 SAY "Brojac kalkulacija D/N         " GET gBrojac PICT "@!" VALID gbrojac $ "DN"
   @ m_x + _x, Col() + 2 SAY "duzina brojaca:" GET gLenBrKalk PICT "9" VALID gLenBrKalk > 0 .AND. gLenBrKalk < 10
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Brojac kalkulacija po kontima (D/N)" GET _brojac VALID _brojac $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Koristiti BARCOD pri unosu kalkulacija (D/N)" GET _unos_barkod VALID _unos_barkod $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Potpis na kraju naloga D/N     " GET gPotpis VALID gPotpis $ "DN"
   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Novi korisnički interfejs D/N/X" GET gNW VALID gNW $ "DNX" PICT "@!"
   ++ _x
 ++ _x
   @ m_x + _x, m_y + 2 SAY "Tip tabele (0/1/2)             " GET gTabela VALID gTabela < 3 PICT "9"
   @ m_x + _x, Col() + 2 SAY "Vise konta na dokumentu (D/N) ?" GET _vise_konta VALID _vise_konta $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Zabraniti promjenu tarife u dokumentima? (D/N)" GET gPromTar VALID gPromTar $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "F-ja za odredjivanje dzokera F1 u kontiranju" GET gFunKon1 PICT "@S28"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "F-ja za odredjivanje dzokera F2 u kontiranju" GET gFunKon2 PICT "@S28"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Limit za otvorene stavke" GET gnLOst PICT "99999"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Timeout kod azuriranja dokumenta (sec.)" GET gAzurTimeout PICT "99999"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Timeout kod azuriranja fin.naloga (sec.)" GET gAzurFinTO PICT "99999"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Auto obrada dokumenata iz cache tabele (D/N)" GET gCache VALID gCache $ "DN" PICT "@!"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Kontrola odstupanja NC:" GET gNC_ctrl PICT "999.99"
   @ m_x + _x, Col() SAY "%"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Indeks kod pretrage artikla:" GET gArtCDX PICT "@15"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Reset artikla prilikom unosa dokumenta (D/N)" GET _reset_roba PICT "@!" VALID _reset_roba $ "DN"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Pregled rabata za dobavljaca kod unosa ulaza (D/N)" GET _rabat PICT "@!" VALID _rabat $ "DN"
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Def.opisa kod unosa (D/N)" GET _opis VALID _opis $ "DN" PICT "@!"
   @ m_x + _x, Col() + 1 SAY "Def.datuma isteka roka (D/N)" GET _rok VALID _rok $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      IF _brojac == "D"
         glBrojacPoKontima := .T.
      ELSE
         glBrojacPoKontima := .F.
      ENDIF

      IF _unos_barkod == "D"
         lKoristitiBK := .T.
      ELSE
         lKoristitiBK := .F.
      ENDIF

      set_metric( "kalk_koristiti_barkod_pri_unosu", my_user(), lKoristitiBK )
      set_metric( "kalk_brojac_kalkulacija", nil, gBrojac )
      set_metric( "kalk_brojac_dokumenta_po_kontima", nil, glBrojacPoKontima )
      set_metric( "kalk_potpis_na_kraju_naloga", nil, gPotpis )
      set_metric( "kalk_tip_tabele", nil, gTabela )
      set_metric( "kalk_novi_korisnicki_interfejs", nil, gNW )
      set_metric( "kalk_zabrana_promjene_tarifa", nil, gPromTar )
      set_metric( "kalk_djoker_f1_kod_kontiranja", nil, gFunKon1 )
      set_metric( "kalk_djoker_f2_kod_kontiranja", nil, gFunKon2 )
      set_metric( "kalk_timeout_kod_azuriranja", nil, gAzurTimeout )
      set_metric( "kalk_cache_tabela", f18_user(), gCache )
      set_metric( "kalk_kontrola_odstupanja_nc", f18_user(), gNC_ctrl )
      set_metric( "kalk_limit_za_otvorene_stavke", f18_user(), gnLOst )
      set_metric( "kalk_duzina_brojaca_dokumenta", nil, gLenBrKalk )
      set_metric( "kalk_index_za_pretragu_artikala", f18_user(), gArtCDX )
      set_metric( "kalk_reset_artikla_kod_unosa", my_user(), _reset_roba )
      set_metric( "pregled_rabata_kod_ulaza", my_user(), _rabat )
      set_metric( "kalk_definisanje_roka_trajanja", NIL, _rok )
      set_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, _opis )
      set_metric( "kalk_dokument_vise_konta", NIL, _vise_konta )

   ENDIF

   RETURN .T.





/* kalk_par_metoda_nc()
 *     Ispravka parametara "METODA NC, ISPRAVKA DOKUMENATA"
 */

FUNCTION kalk_par_metoda_nc()

   PRIVATE  GetList := {}

   Box(, 4, 75, .F., "METODA NC, ISPRAVKA DOKUMENATA" )
   @ m_x + 1, m_y + 2 SAY "Metoda nabavne cijene: bez kalk./zadnja/prosjecna/prva ( /1/2/3)" GET gMetodaNC ;
      VALID gMetodaNC $ " 123" .AND. metodanc_info()
   @ m_x + 2, m_y + 2 SAY "Program omogucava /ne omogucava azuriranje sumnjivih dokumenata (1/2)" GET gCijene ;
      when {|| gCijene := iif( Empty( gmetodanc ), "1", "2" ), .T. } VALID  gCijene $ "12"
   @ m_x + 4, m_y + 2 SAY "Tekuci odgovor na pitanje o promjeni cijena ?" GET gDefNiv ;
      VALID  gDefNiv $ "DN" PICT "@!"
   READ
   BoxC()

   IF LastKey() <> K_ESC

      set_metric( "kalk_metoda_nc", nil, gMetodaNC )
      set_metric( "kalk_promjena_cijena_odgovor", nil, gDefNiv )
      set_metric( "kalk_azuriranje_sumnjivih_dokumenata", nil, gCijene )
      set_metric( "kalk_broj_decimala_za_kolicinu", nil, gDecKol )

   ENDIF

   RETURN .F.



FUNCTION metodanc_info()

   IF gMetodanc == " "
      Beep( 2 )
      Msg( "Ova metoda omogucava da izvrsite proizvoljne ispravke#" + ;
         "Program ce Vam omoguciti da ispravite bilo koji dokument#" + ;
         "bez bilo kakve analize. Zato nakon ispravki dobro provjerite#" + ;
         "odgovarajuce kartice.#" + ;
         "Ako ste neiskusan korisnik konsultujte uputstvo !", 0 )

   ELSEIF gMetodaNC $ "13"
      Beep( 2 )
      Msg( "Ovu metodu obracuna nabavne cijene ne preporucujemo !#" + ;
         "Molimo Vas da usvojite metodu  2 - srednja nabavna cijena !", 0 )
   ENDIF

   RETURN .T.



FUNCTION kalk_par_cijene()

   PRIVATE  GetList := {}

   Box(, 10, 60, .F., "PARAMETRI PRIKAZA - PICTURE KODOVI" )
   @ m_x + 1, m_y + 2 SAY "Prikaz Cijene  " GET gPicCDem
   @ m_x + 2, m_y + 2 SAY "Prikaz procenta" GET gPicProc
   @ m_x + 3, m_y + 2 SAY "Prikaz iznosa  " GET gPicDem
   @ m_x + 4, m_y + 2 SAY "Prikaz kolicine" GET gPicKol
   @ m_x + 5, m_y + 2 SAY "Ispravka NC    " GET gPicNC
   @ m_x + 6, m_y + 2 SAY "Decimale za kolicine" GET gDecKol PICT "9"
   @ m_x + 7, m_y + 2 SAY Replicate( "-", 30 )
   @ m_x + 8, m_y + 2 SAY "Dodatno prosirenje cijene" GET gFPicCDem
   @ m_x + 9, m_y + 2 SAY "Dodatno prosirenje iznosa" GET gFPicDem
   @ m_x + 10, m_y + 2 SAY "Dodatno prosirenje kolicine" GET gFPicKol
   READ
   BoxC()

   IF LastKey() <> K_ESC
      set_metric( "kalk_format_prikaza_cijene", nil, gPicCDEM )
      set_metric( "kalk_format_prikaza_procenta", nil, gPicProc )
      set_metric( "kalk_format_prikaza_iznosa", nil, gPicDEM )
      set_metric( "kalk_format_prikaza_kolicine", nil, gPicKol )
      set_metric( "kalk_format_prikaza_nabavne_cijene", nil, gPicNC )
      set_metric( "kalk_format_prikaza_cijene_prosirenje", nil, gFPicCDem )
      set_metric( "kalk_format_prikaza_iznosa_prosirenje", nil, gFPicDem )
      set_metric( "kalk_format_prikaza_kolicine_prosirenje", nil, gFPicKol )
      set_metric( "kalk_broj_decimala_za_kolicinu", nil, gDecKol )
   ENDIF

   RETURN .T.



FUNCTION SetKomis()

   PRIVATE  GetList := {}

   Box(, 6, 76, .F., "PARAMETRI KOMISIONE PRODAJE" )
   @ m_x + 1, m_y + 2 SAY "Komision: -konto" GET gKomKonto VALID P_Konto( @gKomKonto )
   @ m_x + 2, m_y + 2 SAY "Oznaka RJ u FAKT" GET gKomFakt
   READ
   BoxC()

   IF LastKey() <> K_ESC
      set_metric( "kalk_oznaka_rj_u_fakt", nil, gKomFakt )
      set_metric( "kalk_komision_konto", nil, gKomKonto )
   ENDIF

   RETURN NIL



FUNCTION kalk_par_zavisni_dokumenti()

   LOCAL _auto_razduzenje := fetch_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), "N" )
   PRIVATE  GetList := {}

   Box(, 12, 76, .F., "NACINI FORMIRANJA ZAVISNIH DOKUMENATA" )

   @ m_x + 1, m_y + 2 SAY "Automatika formiranja FIN naloga D/N/0" GET gAFin PICT "@!" VALID gAFin $ "DN0"
   @ m_x + 2, m_y + 2 SAY "Automatika formiranja MAT naloga D/N/0" GET gAMAT PICT "@!" VALID gAMat $ "DN0"
   @ m_x + 3, m_y + 2 SAY "Automatika formiranja FAKT dokum D/N" GET gAFakt PICT "@!" VALID gAFakt $ "DN"
   @ m_x + 4, m_y + 2 SAY "Generisati 16-ku nakon 96  D/N (1/2) ?" GET gGen16  VALID gGen16 $ "12"
   @ m_x + 5, m_y + 2 SAY "Nakon stampe zaduzenja prodavnice prenos u TOPS 0-ne/1 /2 " GET gTops  VALID gTops $ "0 /1 /2 /3 /99" PICT "@!"
   @ m_x + 6, m_y + 2 SAY "Nakon stampe zaduzenja prenos u FAKT 0-ne/1 /2 " GET gFakt  VALID gFakt $ "0 /1 /2 /3 /99" PICT "@!"

   READ

   IF gTops <> "0 " .OR. gFakt <> "0 "
      @ m_x + 8, m_y + 2 SAY "Destinacija fajla za razmjenu:" GET gTopsDest PICT "@S40"
      @ m_x + 9, m_y + 2 SAY "Koristi se vise prodajnih mjesta (D/N) ?" GET gMultiPM PICT "@!" VALID gMultiPM $ "DN"
      @ m_x + 10, m_y + 2 SAY "Auto.zaduzenje prod.konta (KALK 11) (D/N) ?" GET _auto_razduzenje ;
         PICT "@!" VALID _auto_razduzenje $ "DN"
      READ
   ENDIF

   BoxC()

   IF LastKey() <> K_ESC

      set_metric( "kalk_kontiranje_fin", f18_user(), gAFin )
      set_metric( "kalk_kontiranje_mat", f18_user(), gAMat )
      set_metric( "kalk_kontiranje_fakt", f18_user(), gAFakt )
      set_metric( "kalk_generisi_16_nakon_96", f18_user(), gGen16 )
      set_metric( "kalk_prenos_pos", f18_user(), gTops )
      set_metric( "kalk_prenos_fakt", f18_user(), gFakt )
      set_metric( "kalk_destinacija_topska", f18_user(), AllTrim( gTopsDest ) )
      set_metric( "kalk_tops_prenos_vise_prodajnih_mjesta", f18_user(), gMultiPM )
      set_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), _auto_razduzenje )

   ENDIF

   RETURN NIL




FUNCTION SetODirs()

   PRIVATE  GetList := {}

   gDirFin := PadR( gDirFin, 30 )
   gDirMat := PadR( gDirMat, 30 )
   gDirFiK := PadR( gDirFiK, 30 )
   gDirMaK := PadR( gDirMaK, 30 )
   gDirFakt := PadR( gDirFakt, 30 )
   gDirFakK := PadR( gDirFakK, 30 )

   Box(, 5, 76, .F., "DIREKTORIJI" )
   @ m_x + 1, m_y + 2 SAY "Priv.dir.FIN" GET gDirFin  PICT "@S25"
   @ m_x + 1, Col() + 1 SAY "Rad.dir.FIN" GET gDirFiK  PICT "@S25"
   @ m_x + 3, m_y + 2 SAY "Priv.dir.MAT" GET gDirMat   PICT "@S25"
   @ m_x + 3, Col() + 1 SAY "Rad.dir.MAT" GET gDirMaK  PICT "@S25"
   @ m_x + 5, m_y + 2 SAY "Pri.dir.FAKT" GET gDirFakt  PICT "@S25"
   @ m_x + 5, Col() + 1 SAY "Ra.dir.FAKT" GET gDirFakk  PICT "@S25"
   READ
   BoxC()

   gDirFin := Trim( gDirFin )
   gDirMat := Trim( gDirMat )
   gDirFiK := Trim( gDirFiK )
   gDirMaK := Trim( gDirMaK )
   gDirFakt := Trim( gDirFakt )
   gDirFakK := Trim( gDirFakK )

   IF LastKey() <> K_ESC
      // set_metric("df",gDirFIN)
      // set_metric("d3",gDirFIK)
      // set_metric("d4",gDirMaK)
      // set_metric("dm",gDirMat)

      // set_metric("dx",@gDirFakt)
      // set_metric("d5",@gDirFakK)
   ENDIF

   RETURN NIL



FUNCTION kalk_troskovi_10ka()

   PRIVATE  GetList := {}

   Box(, 5, 76, .T., "Troskovi 10-ka" )
   @ m_x + 1, m_y + 2  SAY "T1:" GET c10T1
   @ m_x + 1, m_y + 40 SAY "T2:" GET c10T2
   @ m_x + 2, m_y + 2  SAY "T3:" GET c10T3
   @ m_x + 2, m_y + 40 SAY "T4:" GET c10T4
   @ m_x + 3, m_y + 2  SAY "T5:" GET c10T5
   READ
   BoxC()

   IF LastKey() <> K_ESC

      set_metric( "kalk_dokument_10_trosak_1", nil, c10T1 )
      set_metric( "kalk_dokument_10_trosak_2", nil, c10T2 )
      set_metric( "kalk_dokument_10_trosak_3", nil, c10T3 )
      set_metric( "kalk_dokument_10_trosak_4", nil, c10T4 )
      set_metric( "kalk_dokument_10_trosak_5", nil, c10T5 )

   ENDIF

   RETURN NIL


FUNCTION kalk_par_troskovi_rn()

   PRIVATE  GetList := {}

   Box(, 5, 76, .T., "RADNI NALOG" )
   @ m_x + 1, m_y + 2  SAY "T 1:" GET cRNT1
   @ m_x + 1, m_y + 40 SAY "T 2:" GET cRNT2
   @ m_x + 2, m_y + 2  SAY "T 3:" GET cRNT3
   @ m_x + 2, m_y + 40 SAY "T 4:" GET cRNT4
   @ m_x + 3, m_y + 2  SAY "T 5:" GET cRNT5
   READ
   BoxC()

   IF LastKey() <> K_ESC
      set_metric( "kalk_dokument_rn_trosak_1", nil, cRNT1 )
      set_metric( "kalk_dokument_rn_trosak_2", nil, cRNT2 )
      set_metric( "kalk_dokument_rn_trosak_3", nil, cRNT3 )
      set_metric( "kalk_dokument_rn_trosak_4", nil, cRNT4 )
      set_metric( "kalk_dokument_rn_trosak_5", nil, cRNT5 )
   ENDIF

   cIspravka := "N"

   RETURN NIL



FUNCTION kalk_par_troskovi_24()

   PRIVATE  GetList := {}

   Box(, 5, 76, .T., "24 - USLUGE" )
   @ m_x + 1, m_y + 2  SAY "T 1:" GET c24T1
   @ m_x + 1, m_y + 40 SAY "T 2:" GET c24T2
   @ m_x + 2, m_y + 2  SAY "T 3:" GET c24T3
   @ m_x + 2, m_y + 40 SAY "T 4:" GET c24T4
   @ m_x + 3, m_y + 2  SAY "T 5:" GET c24T5
   @ m_x + 3, m_y + 40 SAY "T 6:" GET c24T6
   @ m_x + 4, m_y + 2  SAY "T 7:" GET c24T7
   @ m_x + 4, m_y + 40 SAY "T 8:" GET c24T8
   READ
   BoxC()

   IF LastKey() <> K_ESC
      set_metric( "kalk_dokument_24_trosak_1", nil, c24T1 )
      set_metric( "kalk_dokument_24_trosak_2", nil, c24T2 )
      set_metric( "kalk_dokument_24_trosak_3", nil, c24T3 )
      set_metric( "kalk_dokument_24_trosak_4", nil, c24T4 )
      set_metric( "kalk_dokument_24_trosak_5", nil, c24T5 )
      set_metric( "kalk_dokument_24_trosak_6", nil, c24T6 )
      set_metric( "kalk_dokument_24_trosak_7", nil, c24T7 )
      set_metric( "kalk_dokument_24_trosak_8", nil, c24T8 )
   ENDIF

   RETURN NIL
