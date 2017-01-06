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

MEMVAR cSection, cHistory, aHistory, izbor, opc, opcexe, gAImpPrint
MEMVAR GetList, m_x, m_y
MEMVAR cExpPath, cImpFile

STATIC s_cKalkAutoImportPodatakaKonto := nil
STATIC __stampaj // stampanje dokumenata .t. or .f.
// STATIC s_lAutom := .T. // Automatski asistent i ažuriranje naloga (D/N)

FUNCTION meni_import_vindija()

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}

   __stampaj := .F.

   IF gAImpPrint == "D"
      __stampaj := .T.
   ENDIF

   AAdd( opc, "1. import vindija računi                 " )
   AAdd( opcexe, {|| kalk_auto_import_racuni() } )
   AAdd( opc, "2. import vindija partner" )
   AAdd( opcexe, {|| kalk_import_txt_partner() } )
   AAdd( opc, "3. import vindija roba" )
   AAdd( opcexe, {|| kalk_import_txt_roba() } )
   // AAdd( opc, "4. popuna polja šifra dobavljača " )
   // AAdd( opcexe, {|| FillDobSifra() } )
   AAdd( opc, "5. nastavak obrade dokumenata " )
   AAdd( opcexe, {|| kalk_imp_continue_from_check_point() } )
   AAdd( opc, "6. podešenja importa " )
   AAdd( opcexe, {|| kalk_auto_import_setup() } )
   AAdd( opc, "7. kreiraj pomoćnu tabelu stanja" )
   AAdd( opcexe, {|| gen_cache() } )
   AAdd( opc, "8. pregled pomoćne tabele stanja" )
   AAdd( opcexe, {|| brow_cache() } )
   AAdd( opc, "9. parametri cache" )
   AAdd( opcexe, {|| brow_cache() } )
   AAdd( opc, "P. parametri kontiranja poslovnica" )
   AAdd( opcexe, {|| set_kalk_imp_parametri_za_poslovnica() } )
   AAdd( opc, "R. parametri kontiranja prodavnica" )
   AAdd( opcexe, {|| kalk_imp_set_konto_zaduz_prodavnica_za_prod_mjesto() } )


   f18_menu_sa_priv_vars_opc_opcexe_izbor( "itx" )

   RETURN .T.



FUNCTION kalk_auto_import_racuni()

   // LOCAL cCtrl_art := "N"
   PRIVATE cExpPath
   PRIVATE cImpFile

   cre_kalk_priprt()

   cExpPath := get_liste_za_import_path()

   cFFilt := kalk_get_vp_ili_mp() // filter za import MP ili VP

   // IF prag_odstupanja_nc_sumnjiv() > 0 .AND. Pitanje(, "Ispusti artikle sa sumnjivom NC (D/N)",  "N" ) == "D"
   // cCtrl_art := "D"
   // ENDIF


   IF get_file_list( cFFilt, cExpPath, @cImpFile ) == 0 // daj pregled fajlova za import, te setuj varijablu cImpFile
      RETURN .F.
   ENDIF


   IF fajl_get_broj_linija( cImpFile ) == 0
      MsgBeep( "Odabrani fajl je prazan!#Prekidam operaciju !" )
      RETURN .F.
   ENDIF

   PRIVATE aDbf := {}
   PRIVATE aRules := {}
   PRIVATE aFaktEx
   PRIVATE lFtSkip := .F.
   PRIVATE lNegative := .F.


   kalk_imp_txt_set_a_dbf_temp( @aDbf ) // setuj polja temp tabele u matricu aDbf
   kalk_imp_set_rule_dok( @aRules ) // setuj pravila upisa podataka u temp tabelu
   kalk_imp_txt_to_temp( aDbf, aRules, cImpFile ) // prebaci iz txt => temp tbl


   IF !kalk_imp_check_partn_roba_exist()
      MsgBeep( "Prekidamo operaciju !#Nepostojeće šifre!" )
      RETURN .F.
   ENDIF

   IF kalk_imp_check_broj_fakture_exist( @aFaktEx )
      IF Pitanje(, "Preskočiti ove dokumente prilikom importa (D/N)?", "D" ) == "D"
         lFtSkip := .T.
      ENDIF
   ENDIF

   lNegative := .F.

   IF Pitanje(, "Prebaciti prvo negativne dokumente (povrate) ?", "D" ) == "D"
      lNegative := .T.
   ENDIF


   IF kalk_imp_from_temp_to_pript( aFaktEx, lFtSkip, lNegative ) == 0  // , cCtrl_art ) == 0
      MsgBeep( "Operacija prekinuta!" )
      RETURN .F.
   ENDIF

   IF Pitanje(, "Obraditi dokumente iz kalk pript (D/N)?", "D" ) == "D"
      IF kalk_imp_obradi_sve_dokumente_iz_pript( nil, __stampaj )
         kalk_imp_brisi_txt( cImpFile )
      ENDIF
   ELSE
      MsgBeep( "Dokumenti nisu obrađeni!#Obrada se moze uraditi i naknadno!" )
      my_close_all_dbf()
   ENDIF

   RETURN .T.


/*
 *     Vraca filter za naziv dokumenta u zavisnosti sta je odabrano VP ili MP
 */

STATIC FUNCTION kalk_get_vp_ili_mp()

   LOCAL cVPMP := "V", cRet

   // pozovi box za izbor
   Box(, 5, 60 )
   @ 1 + m_x, 2 + m_y SAY "Importovati:"
   @ 2 + m_x, 2 + m_y SAY "----------------------------------"
   @ 3 + m_x, 2 + m_y SAY "Veleprodaja (V)"
   @ 4 + m_x, 2 + m_y SAY "Maloprodaja (M)"
   @ 5 + m_x, 17 + m_y SAY "izbor =>" GET cVPMP VALID cVPMP $ "MV" .AND. !Empty( cVPMP ) PICT "@!"
   READ
   BoxC()


   cRet := "R*.R??" // filter za veleprodaju

   DO CASE
   CASE cVPMP == "M" // maloprodaja
      cRet := "M*.M??"
   CASE cVPMP == "V"
      cRet := "R*.R??"
   ENDCASE

   RETURN cRet



/*
 *     Kreiranje temp tabele, te prenos zapisa iz text fajla "cTextFile" u tabelu putem aRules pravila
 *   param: aDbf - struktura tabele
 *   param: aRules - pravila upisivanja jednog zapisa u tabelu, princip uzimanja zapisa iz linije text fajla
 *   param: cTxtFile - txt fajl za import
 */

FUNCTION kalk_imp_txt_to_temp( aDbf, aRules, cTxtFile )

   LOCAL oFile, nCnt

   my_close_all_dbf()

   cre_kalk_imp_temp( aDbf )
   o_kalk_imp_temp()

   IF !File( f18_ime_dbf( "kalk_imp_temp" ) )
      MsgBeep( "Ne mogu kreirati fajl kalk_imp_temp.dbf !" )
      RETURN .F.
   ENDIF


   cTxtFile := AllTrim( cTxtFile ) // zatim iscitaj fajl i ubaci podatke u tabelu

   oFile := TFileRead():New( cTxtFile )
   oFile:Open()

   IF oFile:Error()
      MsgBeep( oFile:ErrorMsg( "Problem sa otvaranjem fajla: " ) )
   ENDIF


   DO WHILE oFile:MoreToRead() // prodji kroz svaku liniju i insertuj zapise u temp.dbf


      cVar := hb_StrToUTF8( oFile:ReadLine() ) // uzmi u cText liniju fajla


      SELECT kalk_imp_temp
      APPEND BLANK

      FOR nCt := 1 TO Len( aRules )
         fname := FIELD( nCt )
         xVal := aRules[ nCt, 1 ]
         RREPLACE &fname with &xVal
      NEXT

   ENDDO

   oFile:Close()

   SELECT kalk_imp_temp

   // proci kroz temp i napuni da li je dtype pozitivno ili negativno
   // ali samo ako je u pitanju racun tabela... !
   IF kalk_imp_temp->( FieldPos( "idtipdok" ) ) <> 0
      GO TOP
      my_flock()
      DO WHILE !Eof()
         IF field->idtipdok == "10" .AND. field->kolicina < 0
            RREPLACE field->dtype WITH "0"
         ELSE
            RREPLACE field->dtype WITH "1"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
   ENDIF

   MsgBeep( "Import txt => temp - OK" )

   RETURN .T.



/*
*  kopira podatke iz pomocne tabele u tabelu KALK->PRIPT
*  - aFExist matrica sa postojecim fakturama
*  - lFSkip preskaci postojece fakture
*  - lNegative - prvo prebaci negativne fakture
* - cCtrl_art - preskoci sporne artikle NC u hendeku ! na osnovu CACHE tabele
*/

STATIC FUNCTION kalk_imp_from_temp_to_pript( aFExist, lFSkip, lNegative )// , cCtrl_art )

   LOCAL cBrojKalk
   LOCAL cTipDok
   LOCAL cIdKonto
   LOCAL cIdKonto2
   LOCAL cIdPJ
   LOCAL aArr_ctrl := {}
   LOCAL cIdKontoZaduzuje, cIdKontoRazduzuje
   LOCAL nRbr, nUvecaj, nCnt, cPredhodniFaktDokument, cPredhodniTipDokumenta, cPredhodnoProdMjesto, aPom
   LOCAL cFakt, cTDok, cIdProdajnoMjesto
   LOCAL nFExist, nT_scan, cTmpArt
   LOCAL cIdKontoTmp, cSifraDobavljaca, cIdRobaTmp

   o_kalk_pripr()
   o_koncij()


   O_ROBA
   o_kalk_pript()

   SELECT kalk_imp_temp

   IF lNegative == nil
      lNegative := .F.
   ENDIF

   IF lNegative == .T.
      SET ORDER TO TAG "2"
   ELSE
      SET ORDER TO TAG "1"
   ENDIF

   GO TOP

   nRbr := 0
   nUvecaj := 0
   nCnt := 0

   cPredhodniFaktDokument := "XXXXXX"
   cPredhodniTipDokumenta := "XX"
   cPredhodnoProdMjesto := "XXX"
   aPom := {}

   MsgO( "tmp -> pript ..." )
   DO WHILE !Eof()

      cFakt := AllTrim( kalk_imp_temp->brdok )
      cTDok := get_kalk_tip_by_vind_fakt_tip( AllTrim( kalk_imp_temp->idtipdok ), kalk_imp_temp->idpm )
      cIdProdajnoMjesto := kalk_imp_temp->idpm
      cIdPJ := kalk_imp_temp->idpj

   /*
         IF cCtrl_art == "D"   // pregledaj CACHE, da li treba preskociti ovaj artikal

            nT_scan := 0

            cIdKontoTmp := kalk_imp_get_konto_by_tip_pm_poslovnica( cTDok, kalk_imp_temp->idpm, "R", cIdPJ )

            SELECT roba
            SET ORDER TO TAG "ID_VSD"
            cSifraDobavljaca := PadL( AllTrim( kalk_imp_temp->idroba ), 5, "0" )

            SEEK cSifraDobavljaca // aha trazi se po sifri dobavljaca 52 => 00052
            cIdRobaTmp := field->id

            O_CACHE
            SELECT cache
            SET ORDER TO TAG "1"
            GO TOP
            SEEK PadR( cIdKontoTmp, 7 ) + PadR( cIdRobaTmp, 10 )


            IF Found() .AND. prag_odstupanja_nc_sumnjiv() > 0 .AND. ( field->odst > prag_odstupanja_nc_sumnjiv() ) // dodaj sporne u kontrolnu matricu

               nT_scan := AScan( aArr_ctrl, ;
                  {| xVal| xVal[ 1 ] + PadR( xVal[ 2 ], 10 ) == cTDok + PadR( AllTrim( cFakt ), 10 ) } )

               IF nT_scan = 0
                  AAdd( aArr_ctrl, { cTDok, PadR( AllTrim( cFakt ), 10 ) } )
               ENDIF

            ENDIF

            SELECT kalk_imp_temp
         ENDIF
   */

      IF lFSkip // ako je ukljucena opcija preskakanja postojecih faktura
         IF Len( aFExist ) > 0
            nFExist := AScan( aFExist, {| aVal| AllTrim( aVal[ 1 ] ) == cFakt } )
            IF nFExist > 0
               SELECT kalk_imp_temp  // prekoci onda ovaj zapis i idi dalje
               SKIP
               LOOP
            ENDIF
         ENDIF
      ENDIF


      // IF cTDok <> cPredhodniTipDokumenta // promjena tipa dokumenta
      // nUvecaj := 0
      // ENDIF

      IF ( cFakt <> cPredhodniFaktDokument ) // .OR. (cTDok == "11" .AND. (cIdProdajnoMjesto <> cPredhodnoProdMjesto) )
         ++nUvecaj
         cBrojKalk := kalk_imp_get_next_temp_broj( nUvecaj )
         nRbr := 0
         AAdd( aPom, { cTDok, cBrojKalk, cFakt } )
      ENDIF


      SELECT roba   // pronadji robu
      SET ORDER TO TAG "ID_VSD"
      cTmpArt := PadL( AllTrim( kalk_imp_temp->idroba ), 5, "0" )
      GO TOP
      SEEK cTmpArt

      cIdKontoZaduzuje := kalk_imp_get_konto_by_tip_pm_poslovnica( cTDok, kalk_imp_temp->idpm, "Z", cIdPJ )
      cIdKontoRazduzuje := kalk_imp_get_konto_by_tip_pm_poslovnica( cTDok, kalk_imp_temp->idpm, "R", cIdPJ )

      SELECT koncij // pozicionirati se na konto zaduzuje
      SET ORDER TO TAG "ID"
      GO TOP
      SEEK cIdKontoZaduzuje


      select_o_kalk_pript()

      APPEND BLANK // pript
      REPLACE idfirma WITH self_organizacija_id(), ;
         rBr WITH Str( ++nRbr, 3 ), ;
         idvd WITH cTDok, ;
         brdok WITH cBrojKalk, ;
         datdok WITH kalk_imp_temp->datdok, ;
         idpartner WITH kalk_imp_temp->idpartner, ;
         idtarifa WITH ROBA->idtarifa, ;
         brfaktp WITH cFakt, ;
         datfaktp WITH kalk_imp_temp->datdok, ;
         datval WITH kalk_imp_temp->datval


      REPLACE idkonto WITH cIdKontoZaduzuje // konto zaduzuje
      REPLACE idkonto2 WITH cIdKontoRazduzuje // konto razduzuje
      REPLACE idzaduz2 WITH ""


      IF cTDok $ "11#41" // spec.za tip dok 11

         REPLACE tmarza2 WITH "A"
         REPLACE tprevoz WITH "A"

         IF cTDok == "11"
            REPLACE pkonto WITH cIdKontoZaduzuje, ;
               mkonto WITH cIdKontoRazduzuje, ;
               mpcsapp WITH kalk_get_mpc_by_koncij_pravilo( cIdKontoZaduzuje )
         ELSE
            REPLACE mpcsapp WITH kalk_imp_temp->cijena
         ENDIF

      ENDIF

      REPLACE kolicina WITH kalk_imp_temp->kolicina
      REPLACE idroba WITH roba->id
      REPLACE nc WITH ROBA->nc

      REPLACE vpc WITH kalk_imp_temp->cijena
      REPLACE rabatv WITH kalk_imp_temp->rabatp

      REPLACE mpc WITH kalk_imp_temp->porez

      cPredhodniFaktDokument := cFakt
      cPredhodniTipDokumenta := cTDok
      cPredhodnoProdMjesto := cIdProdajnoMjesto

      ++nCnt
      SELECT kalk_imp_temp
      SKIP

   ENDDO
   MsgC()

   IF nCnt > 0 // izvjestaj o prebacenim dokumentima

      ASort( aPom,,, {| x, y| x[ 1 ] + "-" + x[ 2 ] < y[ 1 ] + "-" + y[ 2 ] } )

      START PRINT EDITOR
      ? "========================================"
      ? "Generisani sljedeci dokumenti:          "
      ? "========================================"
      ? "Dokument     * Sporna NC"
      ? "----------------------------------------"

      FOR i := 1 TO Len( aPom )

         cT_tipdok := aPom[ i, 1 ]
         cT_brdok := aPom[ i, 2 ]
         cT_brfakt := aPom[ i, 3 ]
         cT_ctrl := ""

   /*
            IF cCtrl_art == "D" .AND. Len( aArr_ctrl ) > 0
               nT_scan := AScan( aArr_ctrl, {| xVal| xVal[ 1 ] + PadR( xVal[ 2 ], 10 ) == cT_tipdok + PadR( cT_brfakt, 10 ) } )

               IF nT_scan <> 0
                  cT_ctrl := " !!! ERROR !!!"
               ENDIF
            ENDIF
   */
         ? cT_tipdok + " - " + cT_brdok, cT_ctrl

      NEXT

      ?
      FF
      ENDPRINT

   ENDIF

   /*
      IF cCtrl_art == "D" .AND. Len( aArr_ctrl ) > 0

         START PRINT EDITOR

         ?
         ? "Ispusteni dokumenti:"
         ? "------------------------------------"

         FOR xy := 1 TO Len( aArr_ctrl )
            ? aArr_ctrl[ xy, 1 ] + "-" + aArr_ctrl[ xy, 2 ]
         NEXT

         FF
         ENDPRINT

      ENDIF
   */

   /*
      IF cCtrl_art == "D" .AND. Len( aArr_ctrl ) > 0 // pobrisi ispustene dokumente

         nT_scan := 0

         SELECT pript
         SET ORDER TO TAG "0"
         GO TOP

         DO WHILE !Eof()

            nT_scan := AScan( aArr_ctrl, {| xval| xval[ 1 ] + PadR( xval[ 2 ], 10 ) == field->idvd + PadR( field->brfaktp, 10 ) } )

            IF nT_scan <> 0
               DELETE
            ENDIF

            SKIP
         ENDDO

      ENDIF
   */

   RETURN 1



/*
 *     Obrada importovanih dokumenata pript -> pripr
 *     ( funkcija se koristi i za prenos kalk -> kalk)
 *     lOstaviBrdok - kalk_imprort sa udaljene lokacije koristi brojeve
 */

FUNCTION kalk_imp_obradi_sve_dokumente_iz_pript( nPocniOd, lStampaj, lOstaviBrdok )

   LOCAL dDatVal
   LOCAL cNoviKalkBrDok := ""
   LOCAL nUvecaj := 0
   LOCAL cMKonto, cPKonto
   LOCAL nTekucaWA, nStCnt, cBBTipDok
   LOCAL nPTRec, nPCRec, cBRdok, cFirma, cIdVd
   LOCAL hRec

   o_kalk_pripr()
   o_kalk_pript()

   automatska_obrada_error( .F. )

   IF lStampaj == nil
      lStampaj := .T.
   ENDIF

   IF nPocniOd == nil
      nPocniOd := 0
   ENDIF

   hb_default( @lOstaviBrdok, .F. ) // ostavi broj dokumenta koji se nalazi u pript

   // IF Pitanje(, "Automatski asistent i ažuriranje naloga (D/N)?", "D" ) == "D"
   // s_lAutom := .T.
   // ENDIF


   SELECT pript // iz kalk_pript prebaci u kalk_pripr jednu po jednu kalkulaciju
   SET ORDER TO TAG "1"

   IF nPocniOd == 0
      GO TOP
   ELSE
      GO nPocniOd
   ENDIF


   cBBTipDok := Space( 30 ) // uzmi parametre koje ces dokumente prenositi
   Box(, 3, 70 )
   @ 1 + m_x, 2 + m_y SAY "Prenos sljedecih tipova dokumenata ( kalk pript -> pripr) :"
   @ 3 + m_x, 2 + m_y SAY "Tip dokumenta (prazno-svi):" GET cBBTipDok PICT "@S25"
   READ
   BoxC()

   IF !Empty( cBBTipDok )
      cBBTipDok := AllTrim( cBBTipDok )
   ENDIF

   // SetKey(K_F3,{|| kalk_imp_set_check_point(nPTRec)})

   Box(, 10, 79 )
   @ 1 + m_x, 2 + m_y SAY8 "Obrada dokumenata iz pomoćne tabele:" COLOR f18_color_i()
   @ 2 + m_x, 2 + m_y SAY8 "======================================="

   DO WHILE !Eof()

      nPTRec := RecNo()
      nPCRec := nPTRec
      cBrDok := field->brdok
      cFirma := field->idfirma
      cIdVd  := field->idvd
      cPKonto := field->pkonto
      cMKonto := field->mkonto

      IF !Empty( cBBTipDok ) .AND. !( cIdVd $ cBBTipDok )
         SKIP
         LOOP
      ENDIF

      nTekucaWA := Select()

      IF lOstaviBrdok
         cNoviKalkBrDok := cBrDok
         IF !kalk_broj_ima_sufiks( cBrDok )
            MsgBeep( "kalk_import - pript, brojevi dokumenata moraju imati sufiks !## STOP!" )
            RETURN .F.
         ENDIF
      ELSE
         cNoviKalkBrDok := kalk_get_next_broj_v5( cFirma, cIdVd, kalk_konto_za_brojac( cIdVd, cMKonto, cPKonto ) )  // daj konacni novi broj dokumenta kalk
      ENDIF

      SELECT ( nTekucaWA )

      @ 3 + m_x, 2 + m_y SAY "KALK IMP Prebacujem: " + cFirma + "-" + cIdVd + "-" + cBrDok + " /"  + cNoviKalkBrDok

      nStCnt := 0
      DO WHILE !Eof() .AND. field->brdok == cBrDok .AND. field->idfirma == cFirma .AND. field->idvd == cIdVd


         SELECT kalk_pripr // jedan po jedan row azuriraj u kalk_pripr
         APPEND BLANK
         // Scatter()


         SELECT pript
         dDatVal := pript->datval
         // Scatter()
         hRec := dbf_get_rec()

         SELECT kalk_pripr
         hRec[ "brdok" ] := cNoviKalkBrDok
         dbf_update_rec( hRec )

         IF hRec[ "idvd" ] == "14"
            update_kalk_14_datval( cNoviKalkBrDok, dDatVal )
         ENDIF

         SELECT pript
         SKIP
         ++nStCnt

         nPTRec := RecNo()

         @ 5 + m_x, 13 + m_y SAY Space( 5 )
         @ 5 + m_x, 2 + m_y SAY "Broj stavki:" + AllTrim( Str( nStCnt ) )
      ENDDO


      // IF s_lAutom // nakon sto smo prebacili dokument u kalk_pripremu oznaciti dokle smo stigli

      IF automatska_obrada_error()
         MsgBeep( "prekid operacije importa - greške u automatskoj obradi!" )
         BoxC()
         RETURN .F.
      ENDIF

      kalk_imp_set_check_point( nPCRec ) // snimi zapis u params da znas dokle si dosao
      IF kalk_imp_obradi_dokument_u_pripremi( cIdVd, lStampaj )
         kalk_imp_set_check_point( nPTRec )
      ELSE
         MsgBeep( "prekid operacije importa !" )
         BoxC()
         RETURN .F.
      ENDIF
      o_kalk_pript()
      // ENDIF

      SELECT pript
      GO nPTRec

   ENDDO

   BoxC()

   IF automatska_obrada_error()
      RETURN .F.
   ENDIF

   RETURN .T.



   /*
    *  Obrada jednog dokumenta
    *  param cIdVd - id vrsta dokumenta
    */

STATIC FUNCTION kalk_imp_obradi_dokument_u_pripremi( cIdVd, lStampaj )

   LOCAL nRslt, lPrvi := .T.

   IF lStampaj == nil
      lStampaj := .T.
   ENDIF


   // kalk_pripr_obrada_stavki_sa_asistentom()

   // IF lStampaj == .T.
   // kalk_stampa_dokumenta( nil, nil, .T. ) // odstampaj kalk
   // ENDIF
   // kalk_azuriranje_dokumenta( .T. ) // azuriraj kalk
   // o_kalk_edit()

   kalk_asistent_pause( .F. )


   DO WHILE (  ( nRslt := provjeri_stanje_kalk_pripreme( cIdVd ) ) <> 0 )


      IF lPrvi .OR. ( nRslt == 1 ) // vezni dokument u kalk_pripremi je ok

         IF !kalk_pripr_auto_obrada_i_azuriranje( lStampaj )
            RETURN .F.
         ENDIF

      ENDIF

      IF lPrvi
         lPrvi := .F.
         LOOP
      ENDIF

      IF  nRslt >= 2 // vezni dokument u pripremi ne pripada azuriranom dokumentu, sta sa njim

         error_bar( "kalk_auto_imp", "postoji dokument u pripremi koji je sumnjiv" )

         MsgBeep( "Postoji dokument u kalk_pripremi koji je sumljiv!#Radi se o veznom dokumentu ili nekoj drugoj gresci...#Obradite ovaj dokument i autoimport ce nastaviti dalje sa radom !" )
         IF LastKey() == K_ESC
            IF Pitanje(, "Prekid operacije?", "N" ) == "D"
               RETURN .F.
            ENDIF
         ENDIF
         kalk_pripr_obrada()
         o_kalk_edit()

      ENDIF


   ENDDO

   RETURN .T.



FUNCTION kalk_pripr_auto_obrada_i_azuriranje( lStampaj )

   hb_default( @lStampaj, .F. )

   kalk_pripr_obrada_stavki_sa_asistentom()
   IF automatska_obrada_error() .AND. Pitanje( , "Automatska obrada greške, prekid obrade ?", "D" ) == "D"
      RETURN .F.
   ELSE
      automatska_obrada_error( .F. ) // ako se trazi nastavak, onda stavi prekid
   ENDIF

   IF kalk_asistent_pause() .AND. Pitanje( , "Asistent pauza, Prekid obrade ?", "N" ) == "D"
      RETURN .F.
   ENDIF

   IF lStampaj == .T.
      kalk_stampa_dokumenta( nil, nil, .T. )
   ENDIF
   kalk_azuriranje_dokumenta( .T., lStampaj )
   o_kalk_edit()

   RETURN .T.



// == SEKCIJA ====================== provjere - validacije =========================================


/*
 *     Provjeri da li postoji broj fakture u azuriranim dokumentima
 */

STATIC FUNCTION kalk_imp_check_broj_fakture_exist( aFakt )

   LOCAL i

   MsgO( "provjera da li u kalk dokumentima vec postoje brfaktp ..." )
   // aPomFakt := kalk_postoji_faktura_a( gAImpRight )
   aFakt := kalk_postoji_faktura_a()
   MsgC()

   IF Len( aFakt ) > 0

      start_print_editor()
      ?
      ? "Kontrolom azuriranih KALK dokumenata, uoceno da se vec pojavljuju"
      ? "navedeni brojevi faktura iz fajla za import:"
      ?
      ?
      ? "Kontrola azuriranih dokumenata:"
      ? "-------------------------------"
      ? "Broj fakture => kalkulacija"
      ? "-------------------------------"
      ?

      FOR i := 1 TO Len( aFakt )
         ? aFakt[ i, 1 ] + " => " + aFakt[ i, 2 ]
      NEXT


      end_print_editor()

      RETURN .T.

   ENDIF

   RETURN .F. // ne postoje azurirane fakture



/*
 *     Provjera da li postoje sve sifre u sifarnicima za dokumente
 */

STATIC FUNCTION kalk_imp_check_partn_roba_exist()

   LOCAL lSifDob := .T.

   aPomPart := kalk_imp_partn_exist()
   aPomRoba  := kalk_imp_roba_exist_sifradob( lSifDob )

   IF ( Len( aPomPart ) > 0 .OR. Len( aPomRoba ) > 0 )


      start_print_editor()

      IF ( Len( aPomPart ) > 0 )
         ? "Lista nepostojecih partnera:"
         ? "----------------------------"
         ?
         FOR i := 1 TO Len( aPomPart )
            ? aPomPart[ i, 1 ]
         NEXT
         ?
      ENDIF

      IF ( Len( aPomRoba ) > 0 )
         ? "Lista nepostojecih artikala:"
         ? "----------------------------"
         ?
         FOR ii := 1 TO Len( aPomRoba )
            ? aPomRoba[ ii, 1 ]
         NEXT
         ?
      ENDIF

      end_print_editor()

      RETURN .F.
   ENDIF

   RETURN .T.



FUNCTION kalk_imp_partn_exist( lPartNaz )

   LOCAL aRet

   O_PARTN
   SELECT kalk_imp_temp
   GO TOP

   IF lPartNaz == NIL
      lPartNaz := .F.
   ENDIF

   aRet := {}

   IF kalk_imp_temp->idtipdok == "96" // partner prazan
      RETURN aRet
   ENDIF

   DO WHILE !Eof()
      SELECT partn
      GO TOP
      SEEK kalk_imp_temp->idpartner
      IF !Found()
         IF lPartNaz
            AAdd( aRet, { kalk_imp_temp->idpartner, kalk_imp_temp->naz } )
         ELSE
            AAdd( aRet, { kalk_imp_temp->idpartner } )
         ENDIF
      ENDIF
      SELECT kalk_imp_temp
      SKIP
   ENDDO

   RETURN aRet


/*
 Provjera da li postoje sifre artikla u sifraniku
 lSifraDob - pretraga po sifri dobavljaca
*/

FUNCTION kalk_imp_roba_exist_sifradob()

   LOCAL aRet, cTmpRoba, nRes, cNazRoba

   O_ROBA
   SELECT kalk_imp_temp
   GO TOP

   aRet := {}

   DO WHILE !Eof()

      // IF lSifraDob == .T.
      cTmpRoba := PadL( AllTrim( kalk_imp_temp->idroba ), 5, "0" )
      // ELSE
      // cTmpRoba := AllTrim( kalk_imp_temp->idroba )
      // ENDIF

      cNazRoba := ""

      // ako u temp postoji "NAZROBA"
      IF kalk_imp_temp->( FieldPos( "nazroba" ) ) <> 0
         cNazRoba := AllTrim( kalk_imp_temp->nazroba )
      ENDIF

      SELECT roba

      // IF lSifraDob == .T.
      SET ORDER TO TAG "ID_VSD"
      // ENDIF

      GO TOP
      SEEK cTmpRoba

      IF !Found() // ako nisi nasao dodaj robu u matricu
         nRes := AScan( aRet, {| aVal| aVal[ 1 ] == cTmpRoba } )
         IF nRes == 0
            AAdd( aRet, { cTmpRoba, cNazRoba } )
         ENDIF
      ENDIF

      SELECT kalk_imp_temp
      SKIP
   ENDDO

   RETURN aRet


/*
 *   vraca matricu sa parovima faktura -> pojavljuje se u azur.kalk
 */
STATIC FUNCTION kalk_postoji_faktura_a()

   LOCAL cBrFakt
   LOCAL cTDok
   LOCAL aRet, cDok, cBrOriginal

   // IF nRight == nil
   // nRight := 0
   // ENDIF

   // o_kalk_doks()

   SELECT kalk_imp_temp
   GO TOP

   aRet := {}
   cDok := "XXXXXX"

   DO WHILE !Eof()

      cBrFakt := AllTrim( kalk_imp_temp->brdok )
      cBrOriginal := cBrFakt

      // IF nRight > 0
      // cBrFakt := PadR( cBrFakt, Len( cBrFakt ) - nRight )
      // ENDIF

      cTDok := get_kalk_tip_by_vind_fakt_tip( AllTrim( kalk_imp_temp->idtipdok ), kalk_imp_temp->idpm )

      IF cBrFakt == cDok
         SKIP
         LOOP
      ENDIF

/*
      SELECT kalk_doks

      IF nRight > 0
         SET ORDER TO TAG "V_BRF2"
      ELSE
         SET ORDER TO TAG "V_BRF"
      ENDIF

      GO TOP

      IF nRight > 0
         SEEK cTDok + cBrFakt
      ELSE
         SEEK PadR( cBrFakt, 10 ) + cTDok
      ENDIF
*/

      // IF Found()
      IF find_kalk_doks_by_broj_fakture( cTDok,  PadR( cBrFakt, 10 ) )
         AAdd( aRet, { cBrOriginal, kalk_doks->idfirma + "-" + kalk_doks->idvd + "-" + AllTrim( kalk_doks->brdok ) } )
      ENDIF

      SELECT kalk_imp_temp
      SKIP

      cDok := cBrFakt

   ENDDO

   RETURN aRet







FUNCTION kalk_imp_get_next_temp_broj( nUvecaj )

   LOCAL nX := 1, cResult := "00001   "

   FOR nX := 1 TO nUvecaj
      cResult := PadR( novasifra( AllTrim( cResult ) ), 5 ) + Right( cResult, 3 )
   NEXT

   RETURN cResult



// =================== veze =====================================================


/*
 *   Vraca kalk tip dokumenta na osnovu fakt tip dokumenta
 *   param: cFaktTD - fakt tip dokumenta
 */

STATIC FUNCTION get_kalk_tip_by_vind_fakt_tip( cFaktTD, cIdProdajnoMjesto )

   LOCAL cRet := ""

   IF ( cFaktTD == "" .OR. cFaktTD == nil )
      RETURN "XX"
   ENDIF

   DO CASE

   CASE cFaktTD == "10" // racuni VP FAKT 10 -> KALK 14
      cRet := "14"


   CASE ( cFaktTD == "11" .AND. cIdProdajnoMjesto < "200" ) // zaduzenje prodavnica KALK 11
      cRet := "11"

   CASE ( cFaktTD == "11" .AND. cIdProdajnoMjesto >= "200" ) // diskont vindija FAKT 11 -> KALK 41
      cRet := "41"


   CASE cFaktTD $ "90#91#92" // kalo, rastur - otpis radio se u kalku
      cRet := "95"


   CASE cFaktTD $ "96"  // otprema - medjuskladisnica
      cRet := "96"

   CASE cFaktTD == "70" // Knjizna obavjest 70 -> KALK KO
      cRet := "KO"

   ENDCASE

   RETURN cRet



// ---------------------------------------------------------------
// Vrati konto za prodajno mjesto Vindijine prodavnice
// cProd - prodajno mjesto C(3), npr "200"
// cPoslovnica - poslovnica sarajevo ili tuzla ili ....
// cita iz fmk.ini/kumpath
// [Vindija]
// VPR200_050=13200
// VPR201_050=13201
// ---------------------------------------------------------------

STATIC FUNCTION kalk_imp_get_konto_zaduz_prodavnica_za_prod_mjesto( cPoslovnica, cProd )

   LOCAL cRet

   IF cProd == "XXX"
      RETURN "XXXXX"
   ENDIF

   IF cProd == "" .OR. cProd == nil
      RETURN "XXXXX"
   ENDIF

   IF cPoslovnica == "" .OR. cPoslovnica == nil
      RETURN "XXXXX"
   ENDIF


   cRet := fetch_metric(  "kalk_imp_prod_zad_" + cPoslovnica + "_" + cProd, NIL,  Space( 7 ) )

   IF Empty( cRet )
      kalk_imp_set_konto_zaduz_prodavnica_za_prod_mjesto( cPoslovnica, cProd )
      cRet := kalk_imp_get_konto_zaduz_prodavnica_za_prod_mjesto( cPoslovnica, cProd )
   ENDIF

   IF cRet == "" .OR. cRet == nil
      cRet := "XXXXX"
   ENDIF

   RETURN cRet


/*

   040 poslovnica, prodajno mjesto 0001, konto 13300

*/
STATIC FUNCTION  kalk_imp_set_konto_zaduz_prodavnica_za_prod_mjesto( cPoslovnica, cIdProdajnoMjesto )

   LOCAL hKonta := hb_Hash(), cKonto

   Box(, 10, 75 )
   IF cPoslovnica == NIL
      cPoslovnica := Space( 3 )
      cIdProdajnoMjesto := Space( 3 )
      @ m_x + 1, m_y + 2 SAY "Poslovnica:" GET cPoslovnica
      @ m_x + 2, m_y + 2 SAY "Prodajno mjesto:" GET cIdProdajnoMjesto
      READ
      IF LastKey() == K_ESC
         BoxC()
         RETURN .F.
      ENDIF
   ELSE
      @ m_x + 1, m_y + 2 SAY "Poslovnica: " + cPoslovnica
      @ m_x + 2, m_y + 2 SAY "Prodajno mjesto: " + cIdProdajnoMjesto
   ENDIF


   cKonto := PadR( fetch_metric(  "kalk_imp_prod_zad_" + cPoslovnica + "_" + cIdProdajnoMjesto, NIL,  Space( 7 ) ), 7 )

   @ m_x + 3, m_y + 2 SAY8 "KALK 11 prod konto zaduzuje: " GET cKonto

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   set_metric( "kalk_imp_prod_zad_" + cPoslovnica + "_" + cIdProdajnoMjesto, NIL, cKonto )

   RETURN .T.


/* -----------------------------------------------------------

Vraca konto za odredjeni tipdokumenta
cTipDok - tip dokumenta
 cTip - "Z" zaduzuje, "R" - razduzuje
 cPoslovnica -poslovnica vindije sarajevo, tuzla ili ...


 primjer:
 TD14Z050=1310 // posl.sarajevo
 TD14R050=1200
 TD14R042=1201 // posl.tuzla


 Poslovnica sarajevo 050
 ==================================
 kalk_imp_050_14_Z = 1310   // kalk 14 kto zaduzuje
 kalk_imp_050_14_R = 1200   // kalk 14 kto razduzuje

*/

STATIC FUNCTION kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cZadRazd, cPoslovnica )

   LOCAL cRet := fetch_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  "XXXX" )

   IF cRet == "XXXX"
      set_kalk_imp_parametri_za_poslovnica( cPoslovnica )
      kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cZadRazd, cPoslovnica )
   ENDIF

   RETURN cRet


STATIC FUNCTION set_kalk_imp_parametri_za_poslovnica( cPoslovnica )

   LOCAL hKonta := hb_Hash(), cTipDok, cZadRazd

   Box(, 11, 75 )
   IF cPoslovnica == NIL
      cPoslovnica := Space( 3 )
      @ m_x + 1, m_y + 2 SAY "Poslovnica:" GET cPoslovnica
      READ
      IF LastKey() == K_ESC
         BoxC()
         RETURN .F.
      ENDIF
   ELSE
      @ m_x + 1, m_y + 2 SAY "Poslovnica: " + cPoslovnica
   ENDIF


   cTipDok := "14"
   cZadRazd := "Z"
   hKonta[ "14Z" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )
   cZadRazd := "R"
   hKonta[ "14R" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )

   cTipDok := "11"
   cZadRazd := "Z"
   hKonta[ "11Z" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )
   cZadRazd := "R"
   hKonta[ "11R" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )

   cTipDok := "41"
   cZadRazd := "Z"
   hKonta[ "41Z" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )
   cZadRazd := "R"
   hKonta[ "41R" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )

   cTipDok := "95"
   cZadRazd := "Z"
   hKonta[ "95Z" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )
   cZadRazd := "R"
   hKonta[ "95R" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )

   cTipDok := "96"
   cZadRazd := "Z"
   hKonta[ "96Z" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )
   cZadRazd := "R"
   hKonta[ "96R" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )

   cTipDok := "KO"
   cZadRazd := "Z"
   hKonta[ "KOZ" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )
   cZadRazd := "R"
   hKonta[ "KOR" ] := fetch_metric(  "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL,  Space( 7 ) )


   @ m_x + 3, m_y + 2 SAY "KALK 14 KTO ZAD: " GET hKonta[ "14Z" ]
   @ m_x + 3, Col() + 2 SAY "KALK 14 KTO RAZD: " GET hKonta[ "14R" ]

   @ m_x + 4, m_y + 2 SAY "KALK 11 KTO ZAD: " GET hKonta[ "11Z" ]
   @ m_x + 4, Col() + 2 SAY "KALK 11 KTO RAZD: " GET hKonta[ "11R" ]

   @ m_x + 5, m_y + 2 SAY "KALK 41 KTO ZAD: " GET hKonta[ "41Z" ]
   @ m_x + 5, Col() + 2 SAY "KALK 41 KTO RAZD: " GET hKonta[ "41R" ]

   @ m_x + 6, m_y + 2 SAY "KALK 95 KTO ZAD: " GET hKonta[ "95Z" ]
   @ m_x + 6, Col() + 2 SAY "KALK 95 KTO RAZD: " GET hKonta[ "95R" ]

   @ m_x + 7, m_y + 2 SAY "KALK 96 KTO ZAD: " GET hKonta[ "96Z" ]
   @ m_x + 7, Col() + 2 SAY "KALK 96 KTO RAZD: " GET hKonta[ "96R" ]

   @ m_x + 8, m_y + 2 SAY "KALK KO KTO ZAD: " GET hKonta[ "KOZ" ]
   @ m_x + 8, Col() + 2 SAY "KALK KO KTO RAZD: " GET hKonta[ "KOR" ]

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   cTipDok := "14"
   cZadRazd := "Z"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )
   cZadRazd := "R"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )

   cTipDok := "11"
   cZadRazd := "Z"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )
   cZadRazd := "R"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )

   cTipDok := "41"
   cZadRazd := "Z"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )
   cZadRazd := "R"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )

   cTipDok := "95"
   cZadRazd := "Z"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )
   cZadRazd := "R"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )

   cTipDok := "96"
   cZadRazd := "Z"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )
   cZadRazd := "R"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )

   cTipDok := "KO"
   cZadRazd := "Z"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )
   cZadRazd := "R"
   set_metric( "kalk_imp_" + cPoslovnica + "_" + cTipDok + "_" + cZadRazd, NIL, hKonta[ cTipDok + cZadRazd ] )

   RETURN .T.


/*
 *   Vraca konto za trazeni tip dokumenta i prodajno mjesto
 *   param: cTipDok - tip dokumenta
 *   param: cIdProdajnoMjesto - prodajno mjesto
 *   param: cTip - tip "Z" zad. i "R" razd.
 *   param: cPoslovnica - poslovnica tuzla ili sarajevo
 */

STATIC FUNCTION kalk_imp_get_konto_by_tip_pm_poslovnica( cTipDok, cIdProdajnoMjesto, cTip, cPoslovnica )

   LOCAL cRet

   DO CASE

   CASE cTipDok == "14"
      cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cPoslovnica )

   CASE cTipDok == "11"
      IF cTip == "R"
         cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cPoslovnica ) // razduzuje magacin
      ELSE // zaduzuje prodavnica
         cRet := kalk_imp_get_konto_zaduz_prodavnica_za_prod_mjesto( cPoslovnica, cIdProdajnoMjesto ) // zaduzuje prodavnica
      ENDIF

   CASE cTipDok == "41"
      cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cPoslovnica )

   CASE cTipDok == "95"
      cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cPoslovnica )

   CASE cTipDok $ "96"
      IF cTip == "R"
         cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cPoslovnica )
      ELSE
         cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cIdProdajnoMjesto )
      ENDIF

   CASE cTipDok == "KO"
      cRet := kalk_imp_get_konto_za_tip_dokumenta_poslovnica( cTipDok, cTip, cPoslovnica )

   ENDCASE

   RETURN cRet



FUNCTION update_kalk_14_datval( cBrojKalk, dDatVal )

   LOCAL hRec

   PushWa()
   IF !find_kalk_doks2_by_broj_dokumenta( self_organizacija_id(), "14", cBrojKalk )
      APPEND BLANK
   ENDIF

   hRec := dbf_get_rec()
   hRec[ "idvd" ] := "14"
   hRec[ "brdok" ] := cBrojKalk
   hRec[ "idfirma" ] := self_organizacija_id()
   hRec[ "datval" ] := dDatVal

   update_rec_server_and_dbf( "kalk_doks2", hRec, 1, "FULL" )
   PopWa()

   RETURN .T.


FUNCTION get_kalk_14_datval( cBrojKalk )

   LOCAL dRet

   PushWa()
   IF !find_kalk_doks2_by_broj_dokumenta( self_organizacija_id(), "14", cBrojKalk )
      dRet := CToD( "" )
   ELSE
      dRet := kalk_doks2->datval
   ENDIF
   PopWa()

   RETURN dRet



// ================== parametri - Rpar, WPara checkpoint ==================



FUNCTION kalk_imp_txt_param_auto_import_podataka_konto( cSet )

   IF s_cKalkAutoImportPodatakaKonto == nil
      s_cKalkAutoImportPodatakaKonto := fetch_metric( "kalk_auto_import_podataka_konto", f18_user(), PadR( "1370", 7 ) )
   ENDIF

   IF cSet != NIL
      s_cKalkAutoImportPodatakaKonto := cSet
      set_metric( "kalk_auto_import_podataka_konto", f18_user(), cSet )
   ENDIF

   RETURN s_cKalkAutoImportPodatakaKonto


/*  kalk_imp_set_check_point
 *  Snima momenat do kojeg je dosao pri obradi dokumenata
 */
STATIC FUNCTION kalk_imp_set_check_point( nPRec )

   LOCAL nArr

   nArr := Select()

   O_PARAMS
   SELECT params

   PRIVATE cSection := "K"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   Wpar( "is", nPRec )

   SELECT ( nArr )

   RETURN .T.



STATIC FUNCTION kalk_auto_import_setup()

   LOCAL nX
   LOCAL GetList := {}
   LOCAL cAImpRKonto

   cAImpRKonto := PadR( kalk_imp_txt_param_auto_import_podataka_konto(), 7 )

   nX := 1
   Box(, 10, 70 )

   @ m_x + nX, m_y + 2 SAY8 "Podešenja importa ********"

   nX += 2
   @ m_x + nX, m_y + 2 SAY8 "Štampati dokumente pri auto obradi (D/N)" GET gAImpPrint VALID gAImpPrint $ "DN" PICT "@!"
   nX += 1
   @ m_x + nX, m_y + 2 SAY8 "Automatska ravnoteža naloga na konto: " GET cAImpRKonto

   // nX += 1
   // @ m_x + nX, m_y + 2 SAY "Provjera broj naloga (minus karaktera):" GET gAImpRight PICT "9"


   READ
   BoxC()

   IF LastKey() <> K_ESC

      kalk_imp_txt_param_auto_import_podataka_konto( cAImpRKonto )

      O_PARAMS

      PRIVATE cSection := "7"
      PRIVATE cHistory := " "
      PRIVATE aHistory := {}

      WPar( "ap", gAImpPrint )
      // WPar( "ar", gAImpRight )

      SELECT params
      USE

   ENDIF

   RETURN .T.


/*
 *  Pokrece ponovo obradu od momenta do kojeg je stao
 */
STATIC FUNCTION kalk_imp_continue_from_check_point()

   O_PARAMS
   SELECT params
   PRIVATE cSection := "K"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}
   PRIVATE nDosaoDo
   Rpar( "is", @nDosaoDo )

   IF nDosaoDo == nil
      MsgBeep( "Nema nista zapisano u parametrima!#Prekidam operaciju!" )
      RETURN .F.
   ENDIF

   IF nDosaoDo == 0
      MsgBeep( "Nema zapisa o prekinutoj obradi!" )
      RETURN .F.
   ENDIF

   o_kalk_pript()
   SELECT pript
   SET ORDER TO TAG "1"
   GO nDosaoDo

   IF !Eof()
      MsgBeep( "Nastavljam od dokumenta#" + field->idfirma + "-" + field->idvd + "-" + field->brdok )
   ELSE
      MsgBeep( "Kraj tabele, nema nista za obradu!" )
      RETURN .T.
   ENDIF

   IF Pitanje(, "Nastaviti sa obradom dokumenata", "D" ) == "N"
      MsgBeep( "Operacija prekinuta!" )
      RETURN .F.
   ENDIF

   IF kalk_imp_obradi_sve_dokumente_iz_pript( nDosaoDo, __stampaj )

      kalk_imp_set_check_point( 0 ) // oznaci da je obrada zavrsena
      MsgBeep( "Dokumenti obradjeni!" )
      kalk_imp_brisi_txt( cImpFile )
   ENDIF

   RETURN .T.



/*
 *   Provjeri da li je kalk_priprema prazna
 *   param: cIdVd - id vrsta dokumenta
 */

STATIC FUNCTION provjeri_stanje_kalk_pripreme( cIdVd )

   LOCAL nNrRec, nTmp, nPrviDok, cPrviDok, nUzorak

   SELECT kalk_pripr


   IF RecCount2() == 0
      RETURN 0 // provjeri da li je kalk_priprema prazna, ako je prazna vrati 0
   ENDIF

   GO TOP


   nNrRec := RecCount2()
   nTmp := 0
   cPrviDok := field->idvd
   nPrviDok := Val( cPrviDok )

   DO WHILE !Eof()
      nTmp += Val( field->idvd )
      SKIP
   ENDDO

   nUzorak := nPrviDok * nNrRec

   IF nUzorak <> nNrRec * nTmp
      RETURN 3 // ako u kalk_pripremi ima vise vrsta dokumenata vrati 3
   ENDIF

   DO CASE
   CASE cIdVd $ "14#KO"
      RETURN provjeri_vezne_dokumente_za_14( cPrviDok )


   CASE cIdVd == "41"
      RETURN provjeri_vezne_dokumente_za_41( cPrviDok )


   CASE cIdVd == "11"
      RETURN provjeri_vezne_dokumente_za_11( cPrviDok )


   CASE cIdVD == "95"
      RETURN provjeri_vezne_dokumente_za_95( cPrviDok )

   CASE cIdVD == "96"
      RETURN provjeri_vezne_dokumente_za_96( cPrviDok )
   ENDCASE

   RETURN 0



/*
 *     Provjeri vezne dokumente za tip dokumenta 14
 *   param: cVezniDok - dokument iz kalk_pripreme
 *  result vraca 1 ako je sve ok, ili 2 ako vezni dokument ne odgovara
 */
STATIC FUNCTION provjeri_vezne_dokumente_za_14( cVezniDok )

   // iza 14 ne moze biti veznih dokumenata

   RETURN 2


/*
 *     Provjeri vezne dokumente za tip dokumenta 41
 */
STATIC FUNCTION provjeri_vezne_dokumente_za_41( cVezniDok )

   IF cVezniDok $ "19"
      RETURN 1
   ENDIF

   RETURN 2


/*
 *     Provjeri vezne dokumente za tip dokumenta 11
 */
STATIC FUNCTION provjeri_vezne_dokumente_za_11( cVezniDok )

   IF cVezniDok $ "19"
      RETURN 1
   ENDIF

   RETURN 2


/*
 *     Provjeri vezne dokumente za tip dokumenta 95
 */
STATIC FUNCTION provjeri_vezne_dokumente_za_95( cVezniDok )

   IF cVezniDok $ "16"
      RETURN 1
   ENDIF

   RETURN 2


/*
 *     Provjeri vezne dokumente za tip dokumenta 96
 */

STATIC FUNCTION provjeri_vezne_dokumente_za_96( cVezniDok )

   IF cVezniDok $ "16"
      RETURN 1
   ENDIF

   RETURN 2

/*
 *     Popunjavanje polja sifradob prema kljucu


STATIC FUNCTION FillDobSifra()

   LOCAL i

   IF !spec_funkcije_sifra( "FILLDOB" )
      MsgBeep( "Nemate ovlastenja za ovu opciju!!!" )
      RETURN .F.
   ENDIF

   O_ROBA

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   cSifra := ""
   nCnt := 0
   aRpt := {}
   aSDob := {}

   Box(, 5, 60 )
   @ 1 + m_x, 2 + m_y SAY "Vrsim upis sifre dobavaljaca robe:"
   @ 2 + m_x, 2 + m_y SAY "==================================="

   DO WHILE !Eof()
      // ako je prazan zapis preskoci
      IF Empty( field->id )
         SKIP
         LOOP
      ENDIF

      cSStr := SubStr( field->id, 1, 1 )

      // provjeri karakteristicnost robe
      IF cSStr == "K" .OR. cSStr == "P"
         // roba KOKA LEN 5 sifradob
         cSifra := SubStr( RTrim( field->id ), -5 )
      ELSEIF cSStr == "V"
         // ostala roba
         cSifra := SubStr( RTrim( field->id ), -4 )
      ELSE
         SKIP
         LOOP
      ENDIF

      // upisi zapis
      Scatter()
      _sifradob := cSifra
      my_rlock()
      Gather()
      my_unlock()

      // potrazi sifru u matrici
      nRes := AScan( aSDob, {| aVal| aVal[ 1 ] == cSifra } )
      IF nRes == 0
         AAdd( aSDob, { cSifra, field->id } )
      ELSE
         AAdd( aRpt, { cSifra, aSDob[ nRes, 2 ] } )
         AAdd( aRpt, { cSifra, field->id } )
      ENDIF

      ++ nCnt

      @ 3 + m_x, 2 + m_y SAY "FMK sifra " + AllTrim( field->id ) + " => sifra dob. " + cSifra
      @ 5 + m_x, 2 + m_y SAY " => ukupno " + AllTrim( Str( nCnt ) )

      SKIP

   ENDDO

   BoxC()

   // ako je report matrica > 0 dakle postoje dupli zapisi
   IF Len( aRpt ) > 0

      START PRINT EDITOR
      ? "KONTROLA DULIH SIFARA VINDIJA_FAKT:"
      ? "==================================="
      ? "Sifra Vindija_FAKT -> Sifra FMK  "
      ?

      FOR i := 1 TO Len( aRpt )
         ? aRpt[ i, 1 ] + " -> " + aRpt[ i, 2 ]
      NEXT

      ?
      ? "Provjerite navedene sifre..."
      ?

      FF
      ENDPRINT
   ENDIF

   RETURN .T.

*/


/*
 *   Brisanje fajla cTxtFile
 *   param: cTxtFile - fajl za brisanje
 */

FUNCTION kalk_imp_brisi_txt( cTxtFile )

   CLEAR TYPEAHEAD
   // postavi pitanje za brisanje fajla
   IF Pitanje(, "Pobrisati txt fajl " + cTxtFile + " (D/N)?", "D" ) == "N"
      RETURN .F.
   ENDIF

   IF FErase( cTxtFile ) == -1
      MsgBeep( "Ne mogu izbrisati " + cTxtFile )
   ENDIF

   RETURN .T.



   /*
    *   Setovanje pravila upisa zapisa u temp tabelu
    *   param: aRule - matrica pravila
    */

STATIC FUNCTION kalk_imp_set_rule_dok( aRule )

   // 1- idfirma
   AAdd( aRule, { "SUBSTR(cVar, 1, 2)" } )
   // 2-idtipdok
   AAdd( aRule, { "SUBSTR(cVar, 4, 2)" } )
   // 3-brdok
   AAdd( aRule, { "SUBSTR(cVar, 7, 8)" } )
   // 4-datdok
   AAdd( aRule, { "CTOD(SUBSTR(cVar, 16, 10))" } )
   // 5-idpartner
   AAdd( aRule, { "SUBSTR(cVar, 27, 6)" } )
   // 6-id pm
   AAdd( aRule, { "SUBSTR(cVar, 34, 3)" } )
   // 7-dindem
   AAdd( aRule, { "SUBSTR(cVar, 38, 3)" } )
   // 8-zaokr
   AAdd( aRule, { "VAL(SUBSTR(cVar, 42, 1))" } )
   // 9-rbr
   AAdd( aRule, { "STR(VAL(SUBSTR(cVar, 44, 3)),3)" } )
   // 10-idroba
   AAdd( aRule, { "ALLTRIM(SUBSTR(cVar, 48, 5))" } )
   // 11-kolicina
   AAdd( aRule, { "VAL(SUBSTR(cVar, 54, 16))" } )
   // 12-cijena
   AAdd( aRule, { "VAL(SUBSTR(cVar, 71, 16))" } )
   // 13-rabat
   AAdd( aRule, { "VAL(SUBSTR(cVar, 88, 14))" } )
   // 14-porez
   AAdd( aRule, { "VAL(SUBSTR(cVar, 103, 14))" } )
   // 15-procenat rabata
   AAdd( aRule, { "VAL(SUBSTR(cVar, 118, 14))" } )
   // 16-datum valute
   AAdd( aRule, { "CTOD(SUBSTR(cVar, 133, 10))" } )
   // 17-obracunska kolicina
   AAdd( aRule, { "VAL(SUBSTR(cVar, 144, 16))" } )
   // 18-poslovna jedinica "kod"
   AAdd( aRule, { "SUBSTR(cVar, 161, 3)" } )

   RETURN .T.



/*
 *   Setuj matricu sa poljima tabele dokumenata RACUN
 *   param: aDbf - matrica
*/

STATIC FUNCTION kalk_imp_txt_set_a_dbf_temp( aDbf )

   AAdd( aDbf, { "idfirma", "C", 2, 0 } )
   AAdd( aDbf, { "idtipdok", "C", 2, 0 } )
   AAdd( aDbf, { "brdok", "C", 8, 0 } )
   AAdd( aDbf, { "datdok", "D", 8, 0 } )
   AAdd( aDbf, { "idpartner", "C", 6, 0 } )
   AAdd( aDbf, { "idpm", "C", 3, 0 } )
   AAdd( aDbf, { "dindem", "C", 3, 0 } )
   AAdd( aDbf, { "zaokr", "N", 1, 0 } )
   AAdd( aDbf, { "rbr", "C", 3, 0 } )
   AAdd( aDbf, { "idroba", "C", 10, 0 } )
   AAdd( aDbf, { "kolicina", "N", 14, 5 } )
   AAdd( aDbf, { "cijena", "N", 14, 5 } )
   AAdd( aDbf, { "rabat", "N", 14, 5 } )
   AAdd( aDbf, { "porez", "N", 14, 5 } )
   AAdd( aDbf, { "rabatp", "N", 14, 5 } )
   AAdd( aDbf, { "datval", "D", 8, 0 } )
   AAdd( aDbf, { "obrkol", "N", 14, 5 } )
   AAdd( aDbf, { "idpj", "C", 3, 0 } )
   AAdd( aDbf, { "dtype", "C", 3, 0 } )

   RETURN .T.


STATIC FUNCTION cre_kalk_imp_temp( aDbf )

   LOCAL cTmpTbl := "kalk_imp_temp"

   IF File( f18_ime_dbf( cTmpTbl ) ) .AND. FErase( f18_ime_dbf( cTmpTbl ) ) == -1
      MsgBeep( "Ne mogu izbrisati kalk_imp_temp.dbf !" )

   ENDIF

   DbCreate2( cTmpTbl, aDbf )

   IF aDbf[ 1, 1 ] == "idpartner" // provjeri jesu li partneri ili dokumenti ili je roba

      create_index( "1", "idpartner", cTmpTbl ) // partner

   ELSEIF aDbf[ 1, 1 ] == "idpm"

      create_index( "1", "sifradob", cTmpTbl ) // roba
   ELSE

      create_index( "1", "idfirma+idtipdok+brdok+rbr", cTmpTbl ) // dokumenti
      create_index( "2", "dtype+idfirma+idtipdok+brdok+rbr", cTmpTbl )
   ENDIF

   RETURN .T.



FUNCTION cre_kalk_priprt()

   // LOCAL cKalkPript := "kalk_pript"

   my_close_all_dbf()

   /*
      FErase( my_home() + cKalkPript + ".dbf" )
      FErase( my_home() + cKalkPript + ".cdx" )

      o_kalk_pripr()

      // napravi pript sa strukturom tabele kalk_pripr
      COPY STRUCTURE EXTENDED to ( my_home() + "struct" )
      CREATE ( my_home() + cKalkPript ) from ( my_home() + "struct" )

      USE

      SELECT ( F_PRIPT )
      my_use_temp( "PRIPT", my_home() + cKalkPript, .F., .T. )

      INDEX on ( idfirma + idvd + brdok ) TAG "1"
      INDEX on ( idfirma + idvd + brdok + idroba ) TAG "2"

      USE
   */
   o_kalk_pript()
   my_dbf_zap()

   RETURN .T.
