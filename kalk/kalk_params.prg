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


STATIC s_cKalkFinIstiBroj := NIL
STATIC s_cKalkPreuzimanjeTroskovaIzSifRoba := NIL
STATIC s_cKalkMetodaNc := NIL


FUNCTION kalk_params()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   o_konto()

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




   AAdd( _opc, "B. parametri - razno" )
   AAdd( _opcexe, {|| kalk_par_razno( 'D' ) } )

   f18_menu( "pars", .F., _izbor, _opc, _opcexe )

   gNW := "X"

   my_close_all_dbf()

   RETURN .T.




FUNCTION kalk_preuzimanje_troskova_iz_sif_roba( cSet )

   IF s_cKalkPreuzimanjeTroskovaIzSifRoba == NIL
      s_cKalkPreuzimanjeTroskovaIzSifRoba := fetch_metric( "kalk_preuzimanje_troskova_iz_sif_roba", nil, "N" )
   ENDIF

   IF cSet != NIL
      set_metric( "kalk_preuzimanje_troskova_iz_sif_roba", nil, cSet )
      s_cKalkPreuzimanjeTroskovaIzSifRoba := cSet
   ENDIF

   RETURN s_cKalkPreuzimanjeTroskovaIzSifRoba



FUNCTION kalk_par_varijante_prikaza()

   LOCAL nX := 1
   LOCAL cRobaTrosk :=  kalk_preuzimanje_troskova_iz_sif_roba()
   PRIVATE  GetList := {}

   Box(, 23, 76, .F., "Varijante obrade i prikaza pojedinih dokumenata" )

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "14 -Varijanta poreza na RUC u VP 1/2 (1-naprijed,2-nazad)"  GET gVarVP  VALID gVarVP $ "12"

   nX += 1
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "14 - Nivelaciju izvrsiti na ukupno stanje/na prodanu kolicinu  1/2 ?" GET gNiv14  VALID gNiv14 $ "12"


   nX += 1
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "10 - prikaz ukalkulisanog poreza (D/N)" GET  g10Porez  PICT "@!" VALID g10Porez $ "DN"

   nX += 1
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "10 - ** kolicina = (1) kol-kalo ; (2) kol" GET gKalo VALID gKalo $ "12"

   nX += 1
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "10 - automatsko preuzimanje troskova iz sifrarnika robe ? (0/D/N)" GET cRobaTrosk VALID cRobaTrosk $ "0DN" PICT "@!"

   nX += 1

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "   default tip za pojedini trosak:"

   nX += 1

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "   " + c10T1 GET gRobaTr1Tip VALID gRobaTr1Tip $ " %URA" PICT "@!"

   @ form_x_koord() + nX, Col() + 1 SAY c10T2 GET gRobaTr2Tip VALID gRobaTr2Tip $ " %URA" PICT "@!"

   @ form_x_koord() + nX, Col() + 1 SAY c10T3 GET gRobaTr3Tip VALID gRobaTr3Tip $ " %URA" PICT "@!"

   @ form_x_koord() + nX, Col() + 1 SAY c10T4 GET gRobaTr4Tip VALID gRobaTr4Tip $ " %URA" PICT "@!"

   @ form_x_koord() + nX, Col() + 1 SAY c10T5 GET gRobaTr5Tip VALID gRobaTr5Tip $ " %URA" PICT "@!"

   //nX += 1
   //@ form_x_koord() + nX, form_y_koord() + 2 SAY "10 - pomoc sa koverzijom valute pri unosu dokumenta (D/N)" GET gDokKVal VALID gDokKVal $ "DN" PICT "@!"

   nX += 2

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Voditi kalo pri ulazu " GET gVodiKalo VALID gVodiKalo $ "DN" PICT "@!"

   nX += 1

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Program se koristi iskljucivo za vodjenje magacina po NC  Da-1 / Ne-2 " GET gMagacin VALID gMagacin $ "12"

   nX += 2

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Varijanta FAKT13->KALK11 ( 1-mpc iz sifrarnika, 2-mpc iz FAKT13)" GET  gVar13u11  PICT "@!" VALID gVar13u11 $ "12"

   nX += 2
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Varijanta KALK 11 bez prikaza NC i storna RUC-a (D/N)" GET  g11bezNC  PICT "@!" VALID g11bezNC $ "DN"

   nX += 1
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Pri ulaznoj kalkulaciji pomoc sa C.sa PDV (D/N)" GET  gMPCPomoc PICT "@!" VALID gMPCPomoc $ "DN"

   nX += 1

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Varijanta popusta na dokumentima, default P-%, C-cijena" GET gRCRP

   nX += 1

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "80 - var.rek.po tarifama ( 1 -samo ukupno / 2 -prod.1,prod.2,ukupno)" GET  g80VRT PICT "9" VALID g80VRT $ "12"

   nX += 2

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Kolicina za nivelaciju iz FAKT-a " GET  gKolicFakt VALID gKolicFakt $ "DN"  PICT "@!"

   @ form_x_koord() + nX, Col() + 1 SAY "Auto ravnoteza naloga (FIN):" GET gAutoRavn VALID gAutoRavn $ "DN" PICT "@!"

   nX += 1

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Automatsko azuriranje cijena u sifrarnik (D/N)" GET gAutoCjen VALID gAutoCjen $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      set_metric( "kalk_magacin_po_nc", nil, gMagacin )

      set_metric( "kalk_kolicina_kalo", nil, gKalo )
      set_metric( "kalk_voditi_kalo", nil, gVodiKalo )
      set_metric( "kalk_dokument_10_prikaz_ukalk_poreza", nil, g10Porez )
      set_metric( "kalk_dokument_14_varijanta_poreza", nil, gVarVP )
      set_metric( "kalk_dokument_11_bez_nc", nil, g11bezNC )
      set_metric( "kalk_dokument_80_rekap_po_tar", nil, g80VRT )
      set_metric( "kalk_tip_nivelacije_14", nil, gNiv14 )
      set_metric( "kalk_varijanta_fakt_13_kalk_11_cijena", nil, gVar13u11 )
      set_metric( "kalk_pomoc_sa_mpc", nil, gMPCPomoc )
      set_metric( "kalk_kolicina_kod_nivelacije_fakt", nil, gKolicFakt )

      kalk_preuzimanje_troskova_iz_sif_roba( cRobaTrosk )
      set_metric( "kalk_varijanta_popusta_na_dokumentima", nil, gRCRP )
      set_metric( "kalk_kontiranje_automatska_ravnoteza_naloga", nil, gAutoRavn )
      set_metric( "kalk_automatsko_azuriranje_cijena", nil, gAutoCjen )
      set_metric( "kalk_trosak_1_tip", nil, gRobaTr1Tip )
      set_metric( "kalk_trosak_2_tip", nil, gRobaTr2Tip )
      set_metric( "kalk_trosak_3_tip", nil, gRobaTr3Tip )
      set_metric( "kalk_trosak_4_tip", nil, gRobaTr4Tip )
      set_metric( "kalk_trosak_5_tip", nil, gRobaTr5Tip )
      //set_metric( "kalk_konverzija_valute_na_unosu", nil, gDokKVal )

   ENDIF

   RETURN NIL



FUNCTION kalk_par_razno()

   LOCAL _brojac := "N"
   LOCAL _unos_barkod := "N"
   LOCAL _x := 1
   LOCAL _reset_roba := fetch_metric( "kalk_reset_artikla_kod_unosa", my_user(), "N" )
   LOCAL _rabat := fetch_metric( "pregled_rabata_kod_ulaza", my_user(), "N" )
   LOCAL _vise_konta := fetch_metric( "kalk_dokument_vise_konta", NIL, "N" )
   LOCAL _rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" )
   LOCAL _opis := fetch_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, "N" )
   LOCAL nLenBrKalk :=  kalk_duzina_brojaca_dokumenta()
   LOCAL cRobaTrazi := PadR( roba_trazi_po_sifradob(), 20 )
   LOCAL nPragOdstupanjaNc := prag_odstupanja_nc_sumnjiv()
   LOCAL nStandardnaStopaMarza  := standardna_stopa_marze()

   PRIVATE  GetList := {}

   IF glBrojacPoKontima
      _brojac := "D"
   ENDIF

   IF roba_barkod_pri_unosu()
      _unos_barkod := "D"
   ENDIF

   Box(, 20, 75, .F., "RAZNO" )

   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Brojac kalkulacija D/N     " GET gBrojacKalkulacija PICT "@!" VALID gBrojacKalkulacija $ "DN"

   @ form_x_koord() + _x, Col() + 2 SAY8 "dužina brojača:" GET nLenBrKalk PICT "9" VALID ( nLenBrKalk > 0 .AND. nLenBrKalk < 10 )
   ++ _x

   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Brojac kalkulacija po kontima (D/N)" GET _brojac VALID _brojac $ "DN" PICT "@!"
   ++ _x

   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Koristiti BARCOD pri unosu kalkulacija (D/N)" GET _unos_barkod VALID _unos_barkod $ "DN" PICT "@!"
   ++ _x

   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Potpis na kraju naloga D/N     " GET gPotpis VALID gPotpis $ "DN"
   ++ _x

   @ form_x_koord() + _x, form_y_koord() + 2 SAY8 "Novi korisnički interfejs D/N/X" GET gNW VALID gNW $ "DNX" PICT "@!"

   _x += 2
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Tip tabele (0/1/2)             " GET gTabela VALID gTabela < 3 PICT "9"

   @ form_x_koord() + _x, Col() + 2 SAY "Vise konta na dokumentu (D/N) ?" GET _vise_konta VALID _vise_konta $ "DN" PICT "@!"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Zabraniti promjenu tarife u dokumentima? (D/N)" GET gPromTar VALID gPromTar $ "DN" PICT "@!"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "F-ja za odredjivanje dzokera F1 u kontiranju" GET gFunKon1 PICT "@S28"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "F-ja za odredjivanje dzokera F2 u kontiranju" GET gFunKon2 PICT "@S28"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Limit za otvorene stavke" GET gnLOst PICT "99999"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Timeout kod azuriranja dokumenta (sec.)" GET gAzurTimeout PICT "99999"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Timeout kod azuriranja fin.naloga (sec.)" GET gAzurFinTO PICT "99999"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Auto obrada dokumenata iz cache tabele (D/N)" GET gCache VALID gCache $ "DN" PICT "@!"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Prag odstupanja NC od posljednjeg ulaza sumnjiv :" GET nPragOdstupanjaNc PICT "999.99"
   @ form_x_koord() + _x, Col() SAY "%"
   ++ _x

   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Standardna stopa marze [NC x ( 1 + ST_STOPA ) = Roba.VPC] :" GET nStandardnaStopaMarza PICT "999.99"
   @ form_x_koord() + _x, Col() SAY "%"
   ++ _x

   @ form_x_koord() + _x, form_y_koord() + 2 SAY8 "Traži robu prema (prazno/SIFRADOB/)" GET cRobaTrazi PICT "@15"

   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Reset artikla prilikom unosa dokumenta (D/N)" GET _reset_roba PICT "@!" VALID _reset_roba $ "DN"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Pregled rabata za dobavljaca kod unosa ulaza (D/N)" GET _rabat PICT "@!" VALID _rabat $ "DN"
   ++ _x
   @ form_x_koord() + _x, form_y_koord() + 2 SAY "Def.opisa kod unosa (D/N)" GET _opis VALID _opis $ "DN" PICT "@!"
   @ form_x_koord() + _x, Col() + 1 SAY "Def.datuma isteka roka (D/N)" GET _rok VALID _rok $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      IF _brojac == "D"
         glBrojacPoKontima := .T.
      ELSE
         glBrojacPoKontima := .F.
      ENDIF


      roba_barkod_pri_unosu( _unos_barkod == "D" )
      set_metric( "kalk_brojac_kalkulacija", nil, gBrojacKalkulacija )
      set_metric( "kalk_brojac_dokumenta_po_kontima", nil, glBrojacPoKontima )
      set_metric( "kalk_potpis_na_kraju_naloga", nil, gPotpis )
      set_metric( "kalk_tip_tabele", nil, gTabela )
      set_metric( "kalk_novi_korisnicki_interfejs", nil, gNW )
      set_metric( "kalk_zabrana_promjene_tarifa", nil, gPromTar )
      set_metric( "kalk_djoker_f1_kod_kontiranja", nil, gFunKon1 )
      set_metric( "kalk_djoker_f2_kod_kontiranja", nil, gFunKon2 )
      set_metric( "kalk_timeout_kod_azuriranja", nil, gAzurTimeout )
      set_metric( "kalk_cache_tabela", f18_user(), gCache )
      prag_odstupanja_nc_sumnjiv( nPragOdstupanjaNc )
      set_metric( "kalk_limit_za_otvorene_stavke", f18_user(), gnLOst )
      kalk_duzina_brojaca_dokumenta( nLenBrKalk )
      roba_trazi_po_sifradob( cRobaTrazi )
      standardna_stopa_marze( nStandardnaStopaMarza )
      set_metric( "kalk_reset_artikla_kod_unosa", my_user(), _reset_roba )
      set_metric( "pregled_rabata_kod_ulaza", my_user(), _rabat )
      set_metric( "kalk_definisanje_roka_trajanja", NIL, _rok )
      set_metric( "kalk_dodatni_opis_kod_unosa_dokumenta", NIL, _opis )
      set_metric( "kalk_dokument_vise_konta", NIL, _vise_konta )

   ENDIF

   RETURN .T.






/*
 *     Ispravka parametara "METODA NC, ISPRAVKA DOKUMENATA"
 */

FUNCTION kalk_par_metoda_nc()

   LOCAL cMetodaNc := kalk_metoda_nc()

   PRIVATE  GetList := {}

   Box(, 4, 75, .F., "METODA NC, ISPRAVKA DOKUMENATA" )
   @ form_x_koord() + 1, form_y_koord() + 2 SAY "Metoda nabavne cijene: bez kalk./zadnja/prosjecna/prva ( /1/2/3)" GET cMetodaNc ;
      VALID cMetodaNC $ " 123" .AND. metodanc_info()
   @ form_x_koord() + 2, form_y_koord() + 2 SAY "Program omogucava /ne omogucava azuriranje sumnjivih dokumenata (1/2)" GET gCijene ;
      VALID  gCijene $ "12"
   @ form_x_koord() + 4, form_y_koord() + 2 SAY "Tekuci odgovor na pitanje o promjeni cijena ?" GET gDefNiv ;
      VALID  gDefNiv $ "DN" PICT "@!"
   READ
   BoxC()

   IF LastKey() <> K_ESC

      kalk_metoda_nc ( cMetodaNC )
      set_metric( "kalk_promjena_cijena_odgovor", nil, gDefNiv )
      set_metric( "kalk_azuriranje_sumnjivih_dokumenata", nil, gCijene )
      set_metric( "kalk_broj_decimala_za_kolicinu", nil, gDecKol )

   ENDIF

   RETURN .F.


FUNCTION nije_dozvoljeno_azuriranje_sumnjivih_stavki()

   RETURN ( gCijene == "2" )



FUNCTION dozvoljeno_azuriranje_sumnjivih_stavki()

   RETURN !( gCijene == "2" )


FUNCTION sumnjive_stavke_error( lForce )

   hb_default( @lForce, .F. )

   IF lForce .OR. nije_dozvoljeno_azuriranje_sumnjivih_stavki()
      Beep( 2 )
      error_bar( "kalk_asist", "sumnjive stavke error" )
      CLEAR TYPEAHEAD // zaustavi asistenta
      _ERROR := "1"
   ENDIF

   RETURN .T.


FUNCTION metodanc_info()

   IF kalk_metoda_nc() == " "
      Beep( 2 )
      Msg( "Ova metoda omogucava da izvrsite proizvoljne ispravke#" + ;
         "Program ce Vam omoguciti da ispravite bilo koji dokument#" + ;
         "bez bilo kakve analize. Zato nakon ispravki dobro provjerite#" + ;
         "odgovarajuce kartice.#" + ;
         "Ako ste neiskusan korisnik konsultujte uputstvo !", 0 )

   ELSEIF kalk_metoda_nc() $ "13"
      Beep( 2 )
      Msg( "Ovu metodu obracuna nabavne cijene ne preporucujemo !#" + ;
         "Molimo Vas da usvojite metodu  2 - srednja nabavna cijena !", 0 )
   ENDIF

   RETURN .T.



FUNCTION kalk_par_cijene()

   PRIVATE  GetList := {}

   Box(, 10, 60, .F., "PARAMETRI PRIKAZA - PICTURE KODOVI" )


   @ form_x_koord() + 1, form_y_koord() + 2 SAY "Prikaz Cijene  " GET gPicCDem
   @ form_x_koord() + 2, form_y_koord() + 2 SAY "Prikaz procenta" GET gPicProc
   @ form_x_koord() + 3, form_y_koord() + 2 SAY "Prikaz iznosa  " GET gPicDem
   @ form_x_koord() + 4, form_y_koord() + 2 SAY "Prikaz kolicine" GET gPicKol


   @ form_x_koord() + 5, form_y_koord() + 2 SAY "Ispravka NC    " GET gPicNC
   @ form_x_koord() + 6, form_y_koord() + 2 SAY "Decimale za kolicine" GET gDecKol PICT "9"
   @ form_x_koord() + 7, form_y_koord() + 2 SAY Replicate( "-", 30 )

   // @ form_x_koord() + 8, form_y_koord() + 2 SAY8 "Dodatno proširenje cijene" GET gFPicCDem
   // @ form_x_koord() + 9, form_y_koord() + 2 SAY8 "Dodatno proširenje iznosa" GET gFPicDem
   // @ form_x_koord() + 10, form_y_koord() + 2 SAY8 "Dodatno proširenje količine" GET gFPicKol
   READ
   BoxC()

   IF LastKey() <> K_ESC
      set_metric( "kalk_format_prikaza_cijene", nil, gPicCDEM )
      set_metric( "kalk_format_prikaza_procenta", nil, gPicProc )
      set_metric( "kalk_format_prikaza_iznosa", nil, gPicDEM )
      set_metric( "kalk_format_prikaza_kolicine", nil, gPicKol )
      set_metric( "kalk_format_prikaza_nabavne_cijene", nil, gPicNC )
      // set_metric( "kalk_format_prikaza_cijene_prosirenje", nil, gFPicCDem )
      // set_metric( "kalk_format_prikaza_iznosa_prosirenje", nil, gFPicDem )
      // set_metric( "kalk_format_prikaza_kolicine_prosirenje", nil, gFPicKol )
      set_metric( "kalk_broj_decimala_za_kolicinu", nil, gDecKol )
   ENDIF

   RETURN .T.



FUNCTION is_kalk_fin_isti_broj()

   RETURN kalk_fin_isti_broj() == "D"


FUNCTION kalk_fin_isti_broj( cSet )

   IF s_cKalkFinIstiBroj == NIL
      s_cKalkFinIstiBroj := fetch_metric( "kalk_fin_isti_broj", NIL, "D" )
   ENDIF

   IF cSet != NIL
      s_cKalkFinIstiBroj := cSet
      set_metric( "kalk_fin_isti_broj", NIL, cSet )
   ENDIF

   RETURN s_cKalkFinIstiBroj


FUNCTION kalk_par_zavisni_dokumenti()

   LOCAL cTopsDest := PadR( kalk_destinacija_topska(), 100 )
   LOCAL _auto_razduzenje := fetch_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), "N" )
   LOCAL cKalkFinIstiBroj := kalk_fin_isti_broj()

   PRIVATE  GetList := {}

   Box(, 12, 76, .F., "NACINI FORMIRANJA ZAVISNIH DOKUMENATA" )

   @ form_x_koord() + 1, form_y_koord() + 2 SAY "Automatika formiranja FIN naloga D/N/0" GET gAFin PICT "@!" VALID gAFin $ "DN0"
   @ form_x_koord() + 2, form_y_koord() + 2 SAY "Automatika formiranja MAT naloga D/N/0" GET gAMAT PICT "@!" VALID gAMat $ "DN0"
   @ form_x_koord() + 3, form_y_koord() + 2 SAY "Automatika formiranja FAKT dokum D/N" GET gAFakt PICT "@!" VALID gAFakt $ "DN"

   @ form_x_koord() + 4, form_y_koord() + 2 SAY "Generisati 16-ku nakon 96  D/N (1/2) ?" GET gGen16  VALID gGen16 $ "12"
   @ form_x_koord() + 5, form_y_koord() + 2 SAY "Nakon stampe zaduzenja prodavnice prenos u TOPS 0-ne/1 /2 " GET gTops  VALID gTops $ "0 /1 /2 /3 /99" PICT "@!"
   @ form_x_koord() + 6, form_y_koord() + 2 SAY "Nakon stampe zaduzenja prenos u FAKT 0-ne/1 /2 " GET gFakt  VALID gFakt $ "0 /1 /2 /3 /99" PICT "@!"

   @ form_x_koord() + 7, form_y_koord() + 2 SAY8 "KALK-FIN identičan broj (D/N): " GET cKalkFinIstiBroj VALID cKalkFinIstiBroj $ "DN" PICT "@!"

   // READ

   // IF gTops <> "0 " .OR. gFakt <> "0 "
   @ form_x_koord() + 8, form_y_koord() + 2 SAY "kalk->tops destinacija: " GET cTopsDest PICT "@S40"
   @ form_x_koord() + 10, form_y_koord() + 2 SAY "Auto.zaduzenje prod.konta (KALK 11) (D/N) ?" GET _auto_razduzenje PICT "@!" VALID _auto_razduzenje $ "DN"

   READ
   // ENDIF

   BoxC()

   IF LastKey() <> K_ESC

      set_metric( "kalk_kontiranje_fin", f18_user(), gAFin )
      set_metric( "kalk_kontiranje_mat", f18_user(), gAMat )
      set_metric( "kalk_kontiranje_fakt", f18_user(), gAFakt )
      set_metric( "kalk_generisi_16_nakon_96", f18_user(), gGen16 )
      set_metric( "kalk_prenos_pos", f18_user(), gTops )
      set_metric( "kalk_prenos_fakt", f18_user(), gFakt )
      kalk_destinacija_topska( cTopsDest )
      set_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), _auto_razduzenje )
      kalk_fin_isti_broj( cKalkFinIstiBroj )

   ENDIF

   RETURN NIL






FUNCTION kalk_troskovi_10ka()

   PRIVATE  GetList := {}

   Box(, 5, 76, .T., "Troskovi 10-ka" )
   @ form_x_koord() + 1, form_y_koord() + 2  SAY "T1:" GET c10T1
   @ form_x_koord() + 1, form_y_koord() + 40 SAY "T2:" GET c10T2
   @ form_x_koord() + 2, form_y_koord() + 2  SAY "T3:" GET c10T3
   @ form_x_koord() + 2, form_y_koord() + 40 SAY "T4:" GET c10T4
   @ form_x_koord() + 3, form_y_koord() + 2  SAY "T5:" GET c10T5
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
   @ form_x_koord() + 1, form_y_koord() + 2  SAY "T 1:" GET cRNT1
   @ form_x_koord() + 1, form_y_koord() + 40 SAY "T 2:" GET cRNT2
   @ form_x_koord() + 2, form_y_koord() + 2  SAY "T 3:" GET cRNT3
   @ form_x_koord() + 2, form_y_koord() + 40 SAY "T 4:" GET cRNT4
   @ form_x_koord() + 3, form_y_koord() + 2  SAY "T 5:" GET cRNT5
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
   @ form_x_koord() + 1, form_y_koord() + 2  SAY "T 1:" GET c24T1
   @ form_x_koord() + 1, form_y_koord() + 40 SAY "T 2:" GET c24T2
   @ form_x_koord() + 2, form_y_koord() + 2  SAY "T 3:" GET c24T3
   @ form_x_koord() + 2, form_y_koord() + 40 SAY "T 4:" GET c24T4
   @ form_x_koord() + 3, form_y_koord() + 2  SAY "T 5:" GET c24T5
   @ form_x_koord() + 3, form_y_koord() + 40 SAY "T 6:" GET c24T6
   @ form_x_koord() + 4, form_y_koord() + 2  SAY "T 7:" GET c24T7
   @ form_x_koord() + 4, form_y_koord() + 40 SAY "T 8:" GET c24T8
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


FUNCTION kalk_metoda_nc( cSet )

   IF s_cKalkMetodaNc == NIL
      s_cKalkMetodaNc := fetch_metric( "kalk_metoda_nc", nil, "2" )
   ENDIF
   IF cSet != NIL
      s_cKalkMetodaNc := cSet
      set_metric( "kalk_metod_nc", nil, cSet )
   ENDIF

   RETURN s_cKalkMetodaNc
