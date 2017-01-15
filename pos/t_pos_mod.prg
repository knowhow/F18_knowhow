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


CLASS TPosMod FROM TAppMod

   METHOD NEW
   METHOD set_module_gvars
   METHOD setScreen
   METHOD mMenu

ENDCLASS


METHOD New( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   ::super:new( p1, p2, p3, p4, p5, p6, p7, p8, p9 )

   RETURN self



METHOD mMenu()

   LOCAL Fx
   LOCAL Fy

   gPrevPos := gIdPos

   Fx := 4
   Fy := 8

/*
   IF gSamoProdaja == "N"
      --cre_doksrc()
   ENDIF
*/

   // predradnje
   pos_init_dbfs()

   CLOSE ALL


   DO WHILE ( .T. )

#ifdef F18_DEBUG
      ?E ">>>>>>>>>>>>>>>>>> pos_prijava while <<<<<<<<<<<<<<<<<<<<<"
#endif
      m_x := Fx
      m_y := Fy

      KLevel := pos_prijava( Fx, Fy )

      IF KLevel == "X"
         RETURN .F.
      ENDIF

      SetPos ( Fx, Fy )

      IF gVsmjene == "N"
         gSmjena := "1"
         OdrediSmjenu( .F. )
      ELSE
         OdrediSmjenu( .T. )
      ENDIF

      EXIT

   ENDDO

   pos_status_traka()

   SetPos( Fx, Fy )
   fPrviPut := .T.

   DO WHILE ( .T. )

      m_x := Fx
      m_y := Fy

      // unesi prijavu korisnika
      IF fPRviPut .AND. gVSmjene == "N" // ne vodi vise smjena
         fPrviPut := .F.
      ELSE
         KLevel := pos_prijava( Fx, Fy )
         pos_status_traka()
      ENDIF

      SetPos( Fx, Fy )

      pos_main_menu_level( Fx, Fy )

      IF self:lTerminate
         // zavrsi run!
         EXIT
      ENDIF

   ENDDO

   CLOSE ALL

   RETURN .T.


FUNCTION pos_main_menu_level( Fx, Fy )

   DO CASE

   CASE pos_admin()
      pos_main_menu_admin()
   CASE pos_upravnik()
      SetPos( Fx, Fy )
      pos_main_menu_upravnik()
   CASE pos_prodavac()
      SetPos( Fx, Fy )
      pos_main_menu_prodavac()

   ENDCASE

   RETURN .T.



METHOD setScreen()

   pripremi_naslovni_ekran( self )
   crtaj_naslovni_ekran()

   RETURN .T.



METHOD set_module_gvars()

   // gPrevIdPos - predhodna vrijednost gIdPos
   PUBLIC gPrevIdPos := "  "
   PUBLIC gOcitBarcod := .F.
   PUBLIC gSmijemRaditi := 'D'
   PUBLIC gSamoProdaja := 'N'
   PUBLIC gZauzetSam := 'N'
   // sifra radnika
   PUBLIC gIdRadnik
   // prezime i ime korisnika (iz OSOB)
   PUBLIC gKorIme

   // status radnika
   PUBLIC gSTRAD

   // identifikator seta cijena koji se
   PUBLIC gSetMPCijena := "1"
   PUBLIC gIdCijena := "1"
   PUBLIC gPopust := 0
   PUBLIC gPopDec := 2
   PUBLIC gPopZcj := "N"
   PUBLIC gPopVar := "P"
   PUBLIC gPopProc := "N"
   PUBLIC gPopIzn := 0
   PUBLIC gPopIznP := 0
   PUBLIC SC_Opisi[ 5 ]      // nazivi (opisi) setova cijena
   PUBLIC gSmjena := " "   // identifikator smjene
   PUBLIC gDatum           // datum

   PUBLIC gVodiOdj
   PUBLIC gRadniRac        // da li se koristi princip radnih racuna ili se
   // racuni furaju kao u trgovini
   PUBLIC gDupliArt        // da li dopusta unos duplih artikala na racunu
   PUBLIC gDupliUpoz       // ako se dopusta, da li se radnik upozorava na duple

   PUBLIC gDirZaklj        // ako se ne koristi princip radnih racuna, da li se
   // racuni zakljucuju odmah po unosu stavki
   PUBLIC gBrojSto         // da li je broj stola obavezan
   // D-da, N-ne, 0-uopce se ne vodi
   PUBLIC gPoreziRaster    // da li se porezi stampaju pojedinacno ili
   // zbirno
   PUBLIC gPocStaSmjene    // da li se uvodi pocetno stanje smjene
   // (da li se radnicima dodjeljuju pocetna sredstva)
   PUBLIC gIdPos           // id prodajnog mjesta

   PUBLIC gIdDio           // id dijela objekta u kome je kasa locirana
   // (ima smisla samo za HOPS)

   PUBLIC nFeedLines       // broj linija potrebnih da se racun otcijepi
   PUBLIC CRinitDone       // da li je uradjen init kase (na pocetku smjene)

   PUBLIC gDomValuta
   PUBLIC gGotPlac         // sifra za gotovinsko (default) placanje
   PUBLIC gDugPlac

   PUBLIC gVrstaRS         // vrsta radne stanice
   // ( K-kasa S-server A-samostalna kasa)
   PUBLIC gEvidPl          // evidentiranje podataka za vrste placanja CEK, SIND.KRED. i GARANTNO PISMO

   PUBLIC gDisplay  // koristiti ispis na COM DISPLAY

   PUBLIC gLocPort := "LPT1" // lokalni port za stampanje racuna

   PUBLIC gStamPazSmj      // da li se automatski stampa pazar smjene
   // na kasi
   PUBLIC gStamStaPun      // da li se automatski stampa stanje
   // nedijeljenih punktova koje kasa pokriva

   PUBLIC gRnSpecOpc  // HOPS - rn specificne opcije
   PUBLIC gSjeciStr := ""
   PUBLIC gOtvorStr := ""
   PUBLIC gVSmjene := "N"
   PUBLIC gSezonaTip := "M"
   PUBLIC gSifUpravn := "D"
   PUBLIC gEntBarCod := "D"
   PUBLIC gSifUvPoNaz := "N" // sifra uvijek po nazivu

   PUBLIC gPosNaz
   PUBLIC gDioNaz
   PUBLIC gRnHeder := "RacHeder.TXT"
   PUBLIC gRnFuter := "RacPodn.TXT "
   PUBLIC gZagIz := "1;2;"
   PUBLIC gColleg := "N"
   PUBLIC gDuplo := "N"
   PUBLIC gDuploKum := ""
   PUBLIC gDuploSif := ""
   PUBLIC gFmkSif := ""
   PUBLIC gRNALSif := ""
   PUBLIC gRNALKum := ""

   PUBLIC gDuzSifre := 13

   // postavljanje globalnih varijabli
   PUBLIC gLocPort := "LPT1"
   PUBLIC gIdCijena := "1"
   PUBLIC gDiskFree := "N"
   PUBLIC grbCjen := 2
   PUBLIC grbStId := "D"
   PUBLIC grbReduk := 0
   PUBLIC gRnInfo := "N"
   PUBLIC aRabat

   self:cName := "POS"
   gModul := self:cName

   gKorIme := ""
   gIdRadnik := ""
   gStRad := ""


   SC_Opisi[ 1 ] := "1"
   SC_Opisi[ 2 ] := "2"
   SC_Opisi[ 3 ] := "3"
   SC_Opisi[ 4 ] := "4"
   SC_Opisi[ 5 ] := "5"

   gDatum := Date()

   PUBLIC gPopVar := "P"
   PUBLIC gPopZcj := "N"
   PUBLIC gZadCij := "N"
   PUBLIC gPopProc := "N"
   PUBLIC gIsPopust := .F.
   PUBLIC gKolDec := 2
   PUBLIC gCijDec := 2
   PUBLIC gStariObrPor := .F.
   PUBLIC gPoreziRaster := "D"
   PUBLIC gPratiStanje := "N"
   PUBLIC gIdPos := "1 "
   PUBLIC gPostDO := "N"
   PUBLIC gIdDio := "  "
   PUBLIC nFeedLines := 6
   PUBLIC gPocStaSmjene := "N"
   PUBLIC gStamPazSmj := "D"
   PUBLIC gStamStaPun := "D"
   PUBLIC CRinitDone := .T.
   PUBLIC gVrstaRS := "A"
   PUBLIC gEvidPl := "N"
   PUBLIC gGotPlac := "01"
   PUBLIC gDugPlac := "DP"
   PUBLIC gSifPath := my_home()
   PUBLIC LocSIFPATH := my_home()
   PUBLIC gServerPath := PadR( "i:" + SLASH + "sigma", 40 )
   PUBLIC gKalkDEST := PadR( "a:" + SLASH, 300 )
   PUBLIC gUseChkDir := "N"
   PUBLIC gStrValuta := Space( 4 )
   // upit o nacinu placanja
   PUBLIC gUpitNp := "N"
   // podaci kase - zaglavlje
   PUBLIC gFirNaziv := Space( 35 )
   PUBLIC gFirAdres := Space( 35 )
   PUBLIC gFirIdBroj := Space( 13 )
   PUBLIC gFirPM := Space( 35 )
   PUBLIC gRnMjesto := Space( 20 )
   PUBLIC gPorFakt := "N"
   PUBLIC gRnPTxt1 := Space( 35 )
   PUBLIC gRnPTxt2 := Space( 35 )
   PUBLIC gRnPTxt3 := Space( 35 )
   PUBLIC gFirTel := Space( 20 )

   // fiskalni parametri
   gVodiOdj := "N"
   gBrojSto := "0"
   gRnSpecOpc := "N"
   gRadniRac := "N"
   gDirZaklj := "D"
   gDupliArt := "D"
   gDupliUpoz := "N"
   gDisplay := "N"

   // citaj parametre iz metric tabele
   gFirNaziv := fetch_metric( "pos_header_org_naziv", nil, gFirNaziv )
   gFirAdres := fetch_metric( "pos_header_org_adresa", nil, gFirAdres )
   gFirIdBroj := fetch_metric( "pos_header_org_id_broj", nil, gFirIdBroj )
   gFirPM := fetch_metric( "pos_header_pm", nil, gFirPM )
   gRnMjesto := fetch_metric( "pos_header_mjesto", nil, gRnMjesto )
   gFirTel := fetch_metric( "pos_header_telefon", nil, gFirTel )
   gRnPTxt1 := fetch_metric( "pos_header_txt_1", nil, gRnPTxt1 )
   gRnPTxt2 := fetch_metric( "pos_header_txt_2", nil, gRnPTxt2 )
   gRnPTxt3 := fetch_metric( "pos_header_txt_3", nil, gRnPTxt3 )
   gPorFakt := fetch_metric( "StampatiPoreskeFakture", nil, gPorFakt )
   gVrstaRS := fetch_metric( "VrstaRadneStanice", nil, gVrstaRS )
   gIdPos := fetch_metric( "IDPos", my_user(), gIdPos )
   gPostDO := fetch_metric( "ZasebneCjelineObjekta", nil, gPostDO )
   gIdDio := fetch_metric( "OznakaDijelaObjekta", nil, gIdDio )
   gServerPath := fetch_metric( "PutanjaServera", nil, gServerPath )
   gKalkDest := fetch_metric( "KalkDestinacija", my_user(), gKalkDest )
   gUseChkDir := fetch_metric( "KoristitiDirektorijProvjere", my_user(), gUseChkDir )
   gStrValuta := fetch_metric( "StranaValuta", nil, gStrValuta )
   gLocPort := fetch_metric( "OznakaLokalnogPorta", my_user(), gLocPort )
   gGotPlac := fetch_metric( "OznakaGotovinskogPlacanja", nil, gGotPlac )
   gDugPlac := fetch_metric( "OznakaDugPlacanja", nil, gDugPlac )
   gRnInfo := fetch_metric( "RacunInfo", nil, gRnInfo )

   gServerPath := AllTrim( gServerPath )
   IF ( Right( gServerPath, 1 ) <> SLASH )
      gServerPath += SLASH
   ENDIF

   // principi rada kase
   cPrevPSS := gPocStaSmjene

   gZadCij := fetch_metric( "AzuriranjeCijena", nil, gZadCij )
   gVodiOdj := fetch_metric( "VodiOdjeljenja", nil, gVodiOdj )
   gRadniRac := fetch_metric( "RadniRacuni", nil, gRadniRac )
   gDirZaklj := fetch_metric( "DirektnoZakljucivanjeRacuna", nil, gDirZaklj )
   gRnSpecOpc := fetch_metric( "RacunSpecifOpcije", nil, gRnSpecOpc )
   gBrojSto := fetch_metric( "BrojStolova", nil, gBrojSto )
   gDupliArt := fetch_metric( "DupliArtikli", nil, gDupliArt )
   gDupliUpoz := fetch_metric( "DupliUnosUpozorenje", nil, gDupliUpoz )
   gPratiStanje := fetch_metric( "PratiStanjeRobe", nil, gPratiStanje )
   gPocStaSmjene := fetch_metric( "PratiPocetnoStanjeSmjene", nil, gPocStaSmjene )
   gStamPazSmj := fetch_metric( "StampanjePazara", nil, gStamPazSmj )
   gStamStaPun := fetch_metric( "StampanjePunktova", nil, gStamStaPun )
   gVSmjene := fetch_metric( "VoditiPoSmjenama", nil, gVsmjene )
   gSezonaTip := fetch_metric( "TipSezone", nil, gSezonaTip )
   gSifUpravn := fetch_metric( "UpravnikIspravljaCijene", nil, gSifUpravn )
   gDisplay := fetch_metric( "DisplejOpcije", nil, gDisplay )
   gEntBarCod := fetch_metric( "BarkodEnter", my_user(), gEntBarCod )
   gEvidPl := fetch_metric( "EvidentiranjeVrstaPlacanja", nil, gEvidPl )
   gSifUvPoNaz := fetch_metric( "PretragaArtiklaPoNazivu", nil, gSifUvPoNaz )
   gDiskFree := fetch_metric( "SlobodniProstorDiska", nil, gDiskFree )

   // izgled racuna
   gSjecistr := PadR( GETPStr( gSjeciStr ), 20 )
   gOtvorstr := PadR( GETPStr( gOtvorStr ), 20 )

   gPoreziRaster := fetch_metric( "PorezniRaster", nil, gPoreziRaster )
   nFeedLines := fetch_metric( "BrojLinijaZaKrajRacuna", nil, nFeedLines )
   gSjeciStr := fetch_metric( "SekvencaSjeciTraku", nil, gSjeciStr )
   gOtvorStr := fetch_metric( "SekvencaOtvoriLadicu", nil, gOtvorStr )

   gSjeciStr := Odsj( @gSjeciStr )
   gOtvorStr := Odsj( @gOtvorStr )

   gZagIz := fetch_metric( "IzgledZaglavlja", nil, gZagIz )
   gRnHeader := fetch_metric( "RacunHeader", nil, gRnHeder )
   gRnFuter := fetch_metric( "RacunFooter", nil, gRnFuter )

   // izgled racuna
   grbCjen := fetch_metric( "RacunCijenaSaPDV", nil, grbCjen )
   grbStId := fetch_metric( "RacunStampaIDArtikla", nil, grbStId )
   grbReduk := fetch_metric( "RacunRedukcijaTrake", nil, grbReduk )

   // cijene
   gSetMPCijena := fetch_metric( "pos_set_cijena", nil, gSetMPCijena )
   gIdCijena := fetch_metric( "SetCijena", nil, gIdCijena )
   gPopust := fetch_metric( "Popust", nil, gPopust )
   gPopDec := fetch_metric( "PopustDecimale", nil, gPopDec )
   gPopVar := fetch_metric( "PopustVarijanta", nil, gPopVar )
   gPopZCj := fetch_metric( "PopustZadavanjemCijene", nil, gPopZCj )
   gPopProc := fetch_metric( "PopustProcenat", nil, gPopProc )
   gPopIzn := fetch_metric( "PopustIznos", nil, gPopIzn )
   gPopIznP := fetch_metric( "PopustVrijednostProcenta", nil, gPopIznP )

   gColleg := fetch_metric( "PodesenjeNonsense", nil, gColleg )
   gDuplo := fetch_metric( "AzurirajUPomocnuBazu", nil, gDuplo )
   gDuploKum := fetch_metric( "KumulativPomocneBaze", nil, gDuploKum )
   gDuploSif := fetch_metric( "SifrarnikPomocneBaze", nil, gDuploSif )
   gFMKSif := fetch_metric( "FMKSifrarnik", nil, gFmkSif )
   gRNALSif := fetch_metric( "RNALSifrarnik", nil, gRNALSif )
   gRNALKum := fetch_metric( "RNALKumulativ", nil, gRNALKum )

   gDuzSifre := fetch_metric( "DuzinaSifre", my_user(), gDuzSifre )

   gUpitNp := fetch_metric( "UpitZaNacinPlacanja", nil, gUpitNp )

   PUBLIC gStela := CryptSC( "STELA" )
   PUBLIC gPVrsteP := .F.
   gPVrsteP := fetch_metric( "AzuriranjePrometaPoVP", nil, gPVrsteP )

   IF ( gVrstaRS == "S" )
      gIdPos := Space( Len( gIdPos ) )
   ENDIF

   PUBLIC gSQLKom
   gSQLLogBase := my_get_from_ini( "SQL", "SQLLogBase", "c:" + SLASH + "sigma", EXEPATH )

   gSamoProdaja := fetch_metric( "SamoProdaja", nil, gSamoProdaja )

   PUBLIC gPosSirovine
   PUBLIC gPosKalk

   PUBLIC gSQLSynchro
   PUBLIC gPosModem

   PUBLIC glRetroakt := .F.

   gPosSirovine := "D"
   gPosKalk := "D"
   gSQLSynchro := "D"
   gPosModem := "D"

   PUBLIC glPorezNaSvakuStavku := .F.
   PUBLIC glPorNaSvStRKas := .F.

   IF ( gVrstaRS <> "S" )
      O_KASE
      SET ORDER TO TAG "ID"
      HSEEK gIdPos
      IF Found()
         gPosNaz := AllTrim( KASE->Naz )
      ELSE
         gPosNaz := "SERVER"
      ENDIF
      O_DIO
      SET ORDER TO TAG "ID"
      HSEEK gIdDio
      IF Found()
         gDioNaz := AllTrim ( DIO->Naz )
      ELSE
         gDioNaz := ""
      ENDIF
      CLOSE ALL
   ENDIF

   SetNazDVal() // set valuta
   param_tezinski_barkod( .T. ) // setuj parametar tezinski_barkod
   max_kolicina_kod_unosa( .T. ) // maksimalna kolicina kod unosa racuna
   kalk_konto_za_stanje_pos( .T. ) // kalk konto za stanje pos artikla
   fiscal_opt_active() // koristenje fiskalnih opcija

   gRobaBlock := {| Ch| pos_roba_block( Ch ) }

   RETURN .T.
