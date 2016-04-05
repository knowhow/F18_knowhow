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



FUNCTION pos_parametri()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. podaci kase                    " )
   AAdd( _opcexe, {|| pos_param_podaci_kase() } )
   AAdd( _opc, "2. principi rada" )
   AAdd( _opcexe, {|| parprbase() } )
   AAdd( _opc, "3. izgled racuna" )
   AAdd( _opcexe, {|| pos_param_izgled_racuna() } )
   AAdd( _opc, "4. cijene" )
   AAdd( _opcexe, {|| pos_param_cijene() } )
   AAdd( _opc, "5. podaci firme" )
   AAdd( _opcexe, {|| pos_param_firma() } )
   AAdd( _opc, "6. fiskalni parametri" )
   AAdd( _opcexe, {|| fiskalni_parametri_za_korisnika() } )
   AAdd( _opc, "7. podešenja organizacije" )
   AAdd( _opcexe, {|| parametri_organizacije() } )
   AAdd( _opc, "8. podešenja barkod-a" )
   AAdd( _opcexe, {|| label_params() } )

   f18_menu( "par", .F., _izbor, _opc, _opcexe )

   RETURN .F.



FUNCTION pos_param_podaci_kase()

   LOCAL aNiz := {}
   LOCAL cPom := ""
   LOCAL _user := my_user()
   PRIVATE cIdPosOld := gIdPos
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE cSection := "1"

   gKalkDest := PadR( gKalkDest, 500 )

   SET CURSOR ON

   AAdd( aNiz, { "Oznaka/ID prodajnog mjesta", "gIdPos",, "@!", } )
   AAdd( aNiz, { "Destinacija datoteke TOPSKA", "gKALKDEST", , "@S40", } )
   AAdd( aNiz, { "Razmjena podataka, vise prodajnih jedinica (D/N)", "gMultiPM", "gMultiPM $ 'DN'", "@!", } )
   AAdd( aNiz, { "Razmjena podataka, koristiti 'chk' direktorij D/N", "gUseChkDir", "gUseChkDir$'DN'", "@!", } )
   AAdd( aNiz, { "Lokalni port za stampu racuna", "gLocPort", , , } )
   AAdd( aNiz, { "Oznaka/ID gotovinskog placanja", "gGotPlac",, "@!", } )
   AAdd( aNiz, { "Oznaka/ID placanja duga       ", "gDugPlac",, "@!", } )
   AAdd( aNiz, { "Oznaka strane valute", "gStrValuta",, "@!", } )
   AAdd( aNiz, { "Duzina sifre artikla u unosu", "gDuzSifre",, "99", } )

   VarEdit( aNiz, 2, 2, 24, 78, "PARAMETRI RADA PROGRAMA - PODACI KASE", "B1" )

   // Upisujem nove parametre
   IF LastKey() <> K_ESC

      set_metric( "IDPos", _user, gIdPos )
      set_metric( "KalkDestinacija", _user, gKalkDest )
      set_metric( "kalk_tops_prenos_vise_prodajnih_mjesta", _user, gMultiPM )
      set_metric( "KoristitiDirektorijProvjere", _user, gUseChkDir )
      set_metric( "OznakaLokalnogPorta", _user, gLocPort )
      set_metric( "OznakaGotovinskogPlacanja", nil, gGotPlac )
      set_metric( "OznakaDugPlacanja", nil, gDugPlac )
      set_metric( "StranaValuta", nil, gStrValuta )
      set_metric( "DuzinaSifre", _user, gDuzSifre )

   ENDIF

   RETURN



FUNCTION pos_param_firma()

   LOCAL aNiz := {}
   LOCAL cPom := ""

   gFirIdBroj := PadR( gFirIdBroj, 13 )

   SET CURSOR ON

   AAdd( aNiz, { "Puni naziv firme", "gFirNaziv", , , } )
   AAdd( aNiz, { "Adresa firme", "gFirAdres", , , } )
   AAdd( aNiz, { "Telefoni", "gFirTel", , , } )
   AAdd( aNiz, { "ID broj", "gFirIdBroj", , , } )
   AAdd( aNiz, { "Prodajno mjesto", "gFirPM", , , } )
   AAdd( aNiz, { "Mjesto nastanka racuna", "gRnMjesto", , , } )
   AAdd( aNiz, { "Pomocni tekst racuna - linija 1:", "gRnPTxt1", , , } )
   AAdd( aNiz, { "Pomocni tekst racuna - linija 2:", "gRnPTxt2", , , } )
   AAdd( aNiz, { "Pomocni tekst racuna - linija 3:", "gRnPTxt3", , , } )

   VarEdit( aNiz, 7, 2, 24, 78, "PODACI FIRME I RACUNA", "B1" )

   // Upisujem nove parametre
   IF LastKey() <> K_ESC

      set_metric( "pos_header_org_naziv", nil, gFirNaziv )
      set_metric( "pos_header_org_adresa", nil, gFirAdres )
      set_metric( "pos_header_org_id_broj", nil, gFirIdBroj )
      set_metric( "pos_header_pm", nil, gFirPM )
      set_metric( "pos_header_mjesto", nil, gRnMjesto )
      set_metric( "pos_header_telefon", nil, gFirTel )
      set_metric( "pos_header_txt_1", nil, gRnPTxt1 )
      set_metric( "pos_header_txt_2", nil, gRnPTxt2 )
      set_metric( "pos_header_txt_3", nil, gRnPTxt3 )

   ENDIF

   RETURN



// -------------------------------------------------------------
// principi rada kase
// -------------------------------------------------------------
FUNCTION pos_param_principi_rada()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. osnovna podešenja              " )
   AAdd( opcexe, {|| ParPrBase() } )


   Menu_SC( "prr" )

   RETURN .F.



// -------------------------------------------------------------
// -------------------------------------------------------------
FUNCTION ParPrUgost()

   LOCAL aNiz := {}
   LOCAL cPrevPSS
   LOCAL cPom := ""
   PRIVATE cIdPosOld := gIdPos

   cPrevPSS := gPocStaSmjene

   SET CURSOR ON

   aNiz := { { "Da li se vode trebovanja (D/N)", "gVodiTreb", "gVodiTreb$'DN'", "@!", } }
   AAdd ( aNiz, { "Da li se koriste radni racuni(D/N)", "gRadniRac", "gRadniRac$'DN'", "@!", } )
   AAdd ( aNiz, { "Ako se ne koriste, da li se racun zakljucuje direktno (D/N)", "gDirZaklj", "gDirZaklj$'DN'", "@!", } )
   AAdd ( aNiz, { "Da li je broj stola obavezan (D/N/0)", "gBrojSto", "gBrojSto$'DN0'", "@!", } )
   AAdd ( aNiz, { "Dijeljenje racuna, spec.opcije nad racunom (D/N)", "gRnSpecOpc", "gRnSpecOpc$'DN'", "@!", } )
   AAdd ( aNiz, { "Da li se po zakljucenju smjene stampa stanje puktova (D/N)", "gStamStaPun", "gStamStaPun$'DN'", "@!", } )

   VarEdit( aNiz, 2, 2, 24, 79, "PARAMETRI RADA PROGRAMA - UGOSTITELJSTVO", "B1" )

   IF LastKey() <> K_ESC
      MsgO( "Azuriram parametre" )
      set_metric( "VodiTrebovanja", nil, gVodiTreb )
      set_metric( "DirektnoZakljucivanjeRacuna", nil, gDirZaklj )
      set_metric( "RacunSpecifOpcije", nil, gRnSpecOpc )
      set_metric( "RadniRacuni", nil, gRadniRac )
      set_metric( "BrojStolova", nil, gBrojSto )
      set_metric( "StampanjePunktova", nil, gStamStaPun )
      MsgC()
   ENDIF

   RETURN



// --------------------------------------------
// osnovni prinicipi rada kase
// --------------------------------------------
FUNCTION ParPrBase()

   LOCAL aNiz := {}
   LOCAL cPrevPSS
   LOCAL cPom := ""

   PRIVATE _konstantni_unos := fetch_metric( "pos_konstantni_unos_racuna", my_user(), "N" )
   PRIVATE _kalk_konto := fetch_metric( "pos_stanje_sa_kalk_konta", NIL, Space( 7 ) )
   PRIVATE _max_qtty := fetch_metric( "pos_maksimalna_kolicina_na_unosu", NIL, 0 )
   PRIVATE cIdPosOld := gIdPos

   cPrevPSS := gPocStaSmjene

   SET CURSOR ON

   aNiz := {}

   AAdd ( aNiz, { "Racun se zakljucuje dikretno bez upita (D/N)", "gDirZaklj", "gDirZaklj$'DN'", "@!", } )
   AAdd ( aNiz, { "Dopustiti dupli unos artikala na racunu (D/N)", "gDupliArt", "gDupliArt$'DN'", "@!", } )
   AAdd ( aNiz, { "Ako se dopusta dupli unos, da li se radnik upozorava(D/N)", "gDupliUpoz", "gDupliUpoz$'DN'", "@!", } )
   AAdd ( aNiz, { "Da li se prati stanje artikla na unosu (D/N/!)", "gPratiStanje", "gPratiStanje$'DN!'", "@!", } )

   IF pos_admin()
      AAdd ( aNiz, { "Upravnik moze ispravljati cijene", "gSifUpravn", "gSifUpravn$'DN'", "@!", } )
   ENDIF

   AAdd ( aNiz, { "Ako je Bar Cod generisi <ENTER> ", "gEntBarCod", "gEntBarCod$'DN'", "@!", } )
   AAdd ( aNiz, { "Pri unosu zaduzenja azurirati i cijene (D/N)? ", "gZadCij", "gZadCij$'DN'", "@!", } )
   AAdd ( aNiz, { "Pri azuriranju pitati za nacin placanja (D/N)? ", "gUpitNP", "gUpitNP$'DN'", "@!", } )
   AAdd ( aNiz, { "Voditi po stolovima (D/N)? ", "gStolovi", "gStolovi$'DN'", "@!", } )
   AAdd ( aNiz, { "Kod unosa racuna uvijek pretraga art.po nazivu (D/N)? ", "gSifUvPoNaz", "gSifUvPoNaz$'DN'", "@!", } )
   AAdd ( aNiz, { "Maksimalna kolicina pri unosu racuna (0 - bez provjere) ", "_max_qtty", "_max_qtty >= 0", "999999", } )
   AAdd ( aNiz, { "Unos racuna bez izlaska iz pripreme (D/N) ", "_konstantni_unos", "_konstantni_unos$'DN'", "@!", } )
   AAdd ( aNiz, { "Za stanje artikla gledaj KALK konto", "_kalk_konto",, "@S7", } )

   VarEdit( aNiz, 2, 2, MAXROWS() - 10, MAXCOLS() - 5, "PARAMETRI RADA PROGRAMA - PRINCIPI RADA", "B1" )

   IF LastKey() <> K_ESC

      MsgO( "Azuriram parametre" )

      set_metric( "VodiTrebovanja", nil, gVodiTreb )
      set_metric( "AzuriranjeCijena", nil, gZadCij )
      set_metric( "VodiOdjeljenja", nil, gVodiOdj )
      set_metric( "Stolovi", nil, gStolovi )
      set_metric( "DirektnoZakljucivanjeRacuna", nil, gDirZaklj )
      set_metric( "RacunSpecifOpcije", nil, gRnSpecOpc )
      set_metric( "RadniRacuni", nil, gRadniRac )
      set_metric( "BrojStolova", nil, gBrojSto )
      set_metric( "DupliArtikli", nil, gDupliArt )
      set_metric( "DupliUnosUpozorenje", nil, gDupliUpoz )
      set_metric( "PratiStanjeRobe", nil, gPratiStanje )
      set_metric( "PratiPocetnoStanjeSmjene", nil, gPocStaSmjene )
      set_metric( "StampanjePazara", nil, gStamPazSmj )
      set_metric( "StampanjePunktova", nil, gStamStaPun )
      set_metric( "VoditiPoSmjenama", nil, gVsmjene )
      set_metric( "UpravnikIspravljaCijene", nil, gSifUpravn )
      set_metric( "BarkodEnter", my_user(), gEntBarCod )
      set_metric( "UpitZaNacinPlacanja", nil, gUpitNP )
      set_metric( "EvidentiranjeVrstaPlacanja", nil, gEvidPl )
      set_metric( "PretragaArtiklaPoNazivu", nil, gSifUvPoNaz )

      set_metric( "pos_stanje_sa_kalk_konta", my_user(), _kalk_konto )
      kalk_konto_za_stanje_pos( .T. )

      set_metric( "pos_maksimalna_kolicina_na_unosu", my_user(), _max_qtty )
      max_kolicina_kod_unosa( .T. )

      set_metric( "pos_konstantni_unos_racuna", my_user(), _konstantni_unos )

      MsgC()

   ENDIF

   RETURN




FUNCTION pos_param_izgled_racuna()

   LOCAL aNiz := {}
   LOCAL cPom := ""

   PRIVATE cIdPosOld := gIdPos

   gSjecistr := PadR( GETPStr( gSjeciStr ), 20 )
   gOtvorstr := PadR( GETPStr( gOtvorStr ), 20 )

   SET CURSOR ON

   gSjeciStr := PadR( gSjeciStr, 30 )
   gOtvorStr := PadR( gOtvorStr, 30 )
   gZagIz := PadR( gZagIz, 20 )

   AAdd( aNiz, { "Stampa poreza pojedinacno (D-pojedinacno,N-zbirno)", "gPoreziRaster", "gPoreziRaster$'DN'", "@!", } )
   AAdd( aNiz, { "Broj redova potrebnih da se racun otcijepi", "nFeedLines", "nFeedLines>=0", "99", } )
   AAdd( aNiz, { "Sekvenca za cijepanje trake", "gSjeciStr", , "@S20", } )
   AAdd( aNiz, { "Sekvenca za otvaranje kase ", "gOtvorStr", , "@S20", } )
   AAdd( aNiz, { "Racun, prikaz cijene bez PDV (1) ili sa PDV (2) ?", "grbCjen", , "9", } )
   AAdd( aNiz, { "Racun, prikaz id artikla na racunu (D/N)", "grbStId", "grbStId$'DN'", "@!", } )
   AAdd( aNiz, { "Redukcija potrosnje trake kod stampe racuna i izvjestaja (0/1/2)", "grbReduk", "grbReduk>=0 .and. grbReduk<=2", "9", } )

   VarEdit( aNiz, 9, 1, 19, 78, "PARAMETRI RADA PROGRAMA - IZGLED RACUNA", "B1" )

   IF LastKey() <> K_ESC
      MsgO( "Azuriram parametre" )
      set_metric( "PorezniRaster", nil, gPoreziRaster )
      set_metric( "BrojLinijaZaKrajRacuna", nil, nFeedLines )
      set_metric( "SekvencaSjeciTraku", nil, gSjeciStr )
      set_metric( "SekvencaOtvoriLadicu", nil, gOtvorStr )
      set_metric( "RacunCijenaSaPDV", nil, grbCjen )
      set_metric( "RacunStampaIDArtikla", nil, grbStId )
      set_metric( "RacunRedukcijaTrake", nil, grbReduk )
      set_metric( "RacunHeader", nil, gRnHeder )
      set_metric( "IzgledZaglavlja", nil, gZagIz )
      set_metric( "RacunFooter", nil, gRnFuter )
      MsgC()
   ENDIF

   gSjeciStr := Odsj( gSjeciStr )
   gOtvorStr := Odsj( gOtvorStr )
   gZagIz := Trim( gZagIz )

   RETURN


FUNCTION pos_param_cijene()

   LOCAL aNiz := {}
   PRIVATE cIdPosOld := gIdPos

   SET CURSOR ON

   AAdd ( aNiz, { "Generalni popust % (99-gledaj sifranik)", "gPopust", , "99", } )
   AAdd ( aNiz, { "Zakruziti cijenu na (broj decimala)    ", "gPopDec", ,  "9", } )
   AAdd ( aNiz, { "Varijanta Planika/Apoteka decimala)    ", "gPopVar", "gPopVar$' PA'", , } )
   AAdd ( aNiz, { "Popust zadavanjem nove cijene          ", "gPopZCj", "gPopZCj$'DN'", , } )
   AAdd ( aNiz, { "Popust zadavanjem procenta             ", "gPopProc", "gPopProc$'DN'", , } )
   AAdd ( aNiz, { "Popust preko odredjenog iznosa (iznos):", "gPopIzn",, "999999.99", } )
   AAdd ( aNiz, { "                  procenat popusta (%):", "gPopIznP",, "999.99", } )
   AAdd ( aNiz, { "Koristiti set cijena                  :", "gSetMPCijena",, "9", } )
   VarEdit( aNiz, 9, 2, 20, 78, "PARAMETRI RADA PROGRAMA - CIJENE", "B1" )

   O_PARAMS

   IF LastKey() <> K_ESC
      set_metric( "Popust", nil, gPopust )
      set_metric( "PopustZadavanjemCijene", nil, gPopZCj )
      set_metric( "PopustDecimale", nil, gPopDec )
      set_metric( "PopustVarijanta", nil, gPopVar )
      set_metric( "PopustProcenat", nil, gPopProc )
      set_metric( "PopustIznos", nil, gPopIzn )
      set_metric( "PopustVrijednostProcenta", nil, gPopIznP )
      set_metric( "pos_set_cijena", nil, gSetMPCijena )
   ENDIF

   RETURN
