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

FUNCTION fakt_pregled_liste_dokumenata()

   LOCAL _curr_user := "<>"
   LOCAL nCol1 := 0
   LOCAL nul, nizl, nRbr
   LOCAL m
   LOCAL _objekat_id
   LOCAL dDatod, dDatdo
   LOCAL _params := fakt_params()
   LOCAL _vrste_pl := _params[ "fakt_vrste_placanja" ]
   LOCAL _objekti := _params[ "fakt_objekti" ]
   LOCAL _vezni_dokumenti := _params[ "fakt_dok_veze" ]
   LOCAL lOpcine := .T.
   LOCAL valute := Space( 3 )
   LOCAL cFilter := ".t."
   LOCAL cFilterOpcina
   LOCAL cSamoRobaDN := "N"
   PRIVATE cImekup, cIdFirma, qqTipDok, cBrFakDok, qqPartn

   O_VRSTEP
   o_ops()
   o_valute()
   // o_rj()
   o_fakt_objekti()
   o_fakt()
   // o_partner()
   o_fakt_doks()

   qqVrsteP := Space( 20 )
   dDatVal0 := dDatVal1 := CToD( "" )

   cIdfirma := self_organizacija_id()
   dDatOd := CToD( "" )
   dDatDo := Date()
   qqTipDok := ""
   qqPartn := Space( 20 )
   cTabela := "N"
   cBrFakDok := Space( 40 )
   cImeKup := Space( 20 )
   cOpcina := Space( 30 )

   IF _objekti
      _objekat_id := Space( 10 )
   ENDIF

   Box( , 13 + iif( _vrste_pl .OR. lOpcine .OR. _objekti, 6, 0 ), 77 )

   cIdFirma := fetch_metric( "fakt_stampa_liste_id_firma", _curr_user, cIdFirma )
   qqTipDok := fetch_metric( "fakt_stampa_liste_dokumenti", _curr_user, qqTipDok )
   dDatOd := fetch_metric( "fakt_stampa_liste_datum_od", _curr_user, dDatOd )
   dDatDo := fetch_metric( "fakt_stampa_liste_datum_do", _curr_user, dDatDo )
   cTabela := fetch_metric( "fakt_stampa_liste_tabelarni_pregled", _curr_user, cTabela )
   cImeKup := fetch_metric( "fakt_stampa_liste_ime_kupca", _curr_user, cImeKup )
   qqPartn := fetch_metric( "fakt_stampa_liste_partner", _curr_user, qqPartn )
   cBrFakDok := fetch_metric( "fakt_stampa_liste_broj_dokumenta", _curr_user, cBrFakDok )

   cImeKup := PadR( cImeKup, 20 )
   qqPartn := PadR( qqPartn, 20 )
   qqTipDok := PadR( qqTipDok, 2 )

   DO WHILE .T.

      // IF gNW $ "DR"
      cIdFirma := PadR( cIdfirma, 2 )
      @ m_x + 1, m_y + 2 SAY "RJ prazno svi" GET cIdFirma VALID {|| Empty( cidfirma ) .OR. cidfirma == self_organizacija_id() .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      READ
      // ELSE
      // @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      // ENDIF

      @ m_x + 2, m_y + 2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqTipDok PICT "@!"
      @ m_x + 3, m_y + 2 SAY "Od datuma " GET dDatOd
      @ m_x + 3, Col() + 1 SAY "do" GET dDatDo
      @ m_x + 5, m_y + 2 SAY8 "Ime kupca počinje sa (prazno svi)" GET cImeKup PICT "@!"
      @ m_x + 6, m_y + 2 SAY8 "Uslov po šifri kupca (prazno svi)" GET qqPartn PICT "@!" ;
         VALID {|| aUslovSifraKupca := Parsiraj( qqPartn, "IDPARTNER", "C", NIL, F_PARTN ), .T. }
      @ m_x + 7, m_y + 2 SAY "Broj dokumenta (prazno svi)" GET cBrFakDok PICT "@!"

      @ m_x + 9, m_y + 2 SAY "Tabelarni pregled" GET cTabela VALID cTabela $ "DN" PICT "@!"

      cRTarifa := "N"

      @ m_x + 11, m_y + 2 SAY "Rekapitulacija po tarifama ?" GET cRTarifa VALID cRtarifa $ "DN" PICT "@!"

      IF _vrste_pl
         @ m_x + 12, m_y + 2 SAY "----------------------------------------"
         @ m_x + 13, m_y + 2 SAY "Za fakture (Tip dok.10):"
         @ m_x + 14, m_y + 2 SAY8 "Način placanja:" GET qqVrsteP
         @ m_x + 15, m_y + 2 SAY8 "Datum valutiranja od" GET dDatVal0
         @ m_x + 15, Col() + 2 SAY "do" GET dDatVal1
         @ m_x + 16, m_y + 2 SAY "----------------------------------------"
      ENDIF

      @ m_x + 17, m_y + 2 SAY8 "Općina (prazno-sve): "  GET cOpcina

      IF _objekti
         @ m_x + 18, m_y + 2 SAY "Objekat (prazno-svi): "  GET _objekat_id VALID Empty( _objekat_id ) .OR. P_fakt_objekti( @_objekat_id )
      ENDIF

      @ m_x + 19, m_y + 2 SAY "Valute ( /KM/EUR)"  GET valute
      @ m_x + 19, Col() + 2 SAY " samo dokumenti koji sadrže robu D/N"  GET cSamoRobaDN PICT "@!" VALID cSamoRobaDN $ "DN"

      READ

      ESC_BCR

      aUslBFD := Parsiraj( cBrFakDok, "BRDOK", "C" )
      aUslovSifraKupca := Parsiraj( qqPartn, "IDPARTNER", "C" )
      aUslVrsteP := Parsiraj( qqVrsteP, "IDVRSTEP", "C" )
      cFilterOpcina := Parsiraj( cOpcina, "flt_fakt_part_opc()", "C" )

      IF ( !lOpcine .OR. cFilterOpcina <> NIL ) .AND. aUslBFD <> NIL .AND. aUslovSifraKupca <> NIL .AND. ( !_vrste_pl .OR. aUslVrsteP <> NIL )
         EXIT
      ENDIF

   ENDDO

   qqTipDok := Trim( qqTipDok )
   qqPartn := Trim( qqPartn )

   set_metric( "fakt_stampa_liste_id_firma", f18_user(), cIdFirma )
   set_metric( "fakt_stampa_liste_dokumenti", f18_user(), qqTipDok )
   set_metric( "fakt_stampa_liste_datum_od", f18_user(), dDatOd )
   set_metric( "fakt_stampa_liste_datum_do", f18_user(), dDatDo )
   set_metric( "fakt_stampa_liste_tabelarni_pregled", f18_user(), cTabela )
   set_metric( "fakt_stampa_liste_ime_kupca", f18_user(), cImeKup )
   set_metric( "fakt_stampa_liste_partner", f18_user(), qqPartn )
   set_metric( "fakt_stampa_liste_broj_dokumenta", f18_user(), cBrFakDok )

   BoxC()

   // SELECT partn
   // radi filtera cFilterOpcina partneri trebaju biti na ID-u indeksirani
   // SET ORDER TO TAG "ID"

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP

   IF !Empty( dDatVal0 ) .OR. !Empty( dDatVal1 )
      cFilter += ".and. ( !idtipdok='10' .or. datpl>=" + _filter_quote( dDatVal0 ) + ".and. datpl<=" + _filter_quote( dDatVal1 ) + ")"
   ENDIF

   IF !Empty( qqVrsteP )
      cFilter += ".and. (!idtipdok='10' .or. " + aUslVrsteP + ")"
   ENDIF

   IF !Empty( qqTipDok )
      cFilter += ".and. idtipdok==" + _filter_quote( qqTipDok )
   ENDIF

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilter += ".and. datdok>=" + _filter_quote( dDatOd ) + ".and. datdok<=" + _filter_quote( dDatDo )
   ENDIF

   IF !Empty( cImekup )
      cFilter += ".and. partner=" + _filter_quote( Trim( cImeKup ) )
   ENDIF

   IF !Empty( cIdFirma )
      cFilter += ".and. IdFirma=" + _filter_quote( cIdFirma )
   ENDIF

   IF !Empty( cOpcina )
      cFilter += ".and. " + cFilterOpcina
   ENDIF

   IF _objekti .AND. !Empty( _objekat_id )
      cFilter += ".and. fakt_objekat_id() == " + _filter_quote( _objekat_id )
   ENDIF

   IF !Empty( cBrFakDok )
      cFilter += ".and." + aUslBFD
   ENDIF

   IF !Empty( qqPartn )
      cFilter += ".and." + aUslovSifraKupca
   ENDIF

   IF !Empty( valute )
      cFilter += ".and. dindem = " + _filter_quote( valute )
   ENDIF

   IF cSamoRobaDN == "D"
      cFilter += ".and. fakt_dokument_sadrzi_robu()"
   ENDIF
   
   IF cFilter == ".t. .and."
      cFilter := SubStr( cFilter, 9 )
   ENDIF

   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilter
   ENDIF

   @ MaxRow() - 4, MaxCol() - 3 SAY Str( rloptlevel(), 2 )

   qqTipDok := Trim( qqTipDok )

   SEEK cIdFirma + qqTipDok

   EOF CRET

   IF cTabela == "D"
      fakt_lista_dokumenata_tabelarni_pregled( _vrste_pl, lOpcine, cFilter )
   ELSE
      gaZagFix := { 3, 3 }
      stampa_liste_dokumenata( dDatOd, dDatDo, qqTipDok, cIdFirma, _objekat_id, cImeKup, lOpcine, cFilterOpcina, valute )
   ENDIF

   my_close_all_dbf()

   RETURN .T.




FUNCTION print_porezna_faktura( lOpcine )

   LOCAL nTrec

   SELECT fakt_doks
   nTrec := RecNo()

   _cIdFirma := idfirma
   _cIdTipDok := idtipdok
   _cBrDok := brdok

   close_open_fakt_tabele()

   fakt_stamp_txt_dokumenta( _cidfirma, _cIdTipdok, _cBrdok )

   SELECT ( F_FAKT_DOKS )
   USE

   o_fakt_doks()

   RETURN DE_CONT


FUNCTION fakt_print_odt( lOpcine )

   SELECT fakt_doks

   nTrec := RecNo()
   _cIdFirma := idfirma
   _cIdTipDok := idtipdok
   _cBrDok := brdok
   my_close_all_dbf()

   fakt_stampa_dok_odt( _cidfirma, _cIdTipdok, _cbrdok )

/*
   close_open_fakt_tabele()
   SELECT ( F_FAKT_DOKS )
   USE
   o_fakt_doks()
   //o_partner()
   SELECT fakt_doks
   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilter
   ENDIF
   GO nTrec
*/

   RETURN DE_CONT



FUNCTION generisi_fakturu( is_opcine )

   LOCAL cTipDok
   LOCAL cFirma
   LOCAL cBrFakt
   LOCAL nCnt := 0
   LOCAL dDatFakt
   LOCAL dDatVal
   LOCAL dDatIsp
   LOCAL i
   LOCAL cPart
   LOCAL aMemo := {}
   LOCAL _rec
   LOCAL nDbfArea := Select()

   IF Pitanje(, "Generisati fakturu na osnovu ponude ?", "D" ) == "N"
      RETURN DE_CONT
   ENDIF

   o_fakt_pripr()
   o_fakt()

   IF fakt_pripr->( RecCount() ) <> 0
      MsgBeep( "Priprema mora biti prazna !" )
      SELECT ( nDbfArea )
      RETURN DE_CONT
   ENDIF

   SELECT fakt_doks

   nTrec := RecNo()

   cTipDok := field->idtipdok
   cFirma := field->idfirma
   cBrFakt := field->brdok
   cPart := field->idpartner
   dDatFakt := Date()
   dDatVal := Date()
   dDatIsp := Date()
   cNBrFakt := PadR( "00000", 8 )

   Box(, 5, 55 )

   @ m_x + 1, m_y + 2 SAY "*** Parametri fakture "

   @ m_x + 3, m_y + 2 SAY "  Datum fakture: " GET dDatFakt VALID !Empty( dDatFakt )
   @ m_x + 4, m_y + 2 SAY "   Datum valute: " GET dDatVal VALID !Empty( dDatVal )
   @ m_x + 5, m_y + 2 SAY " Datum isporuke: " GET dDatIsp VALID !Empty( dDatIsp )

   READ

   BoxC()

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cFirma + cTipDok + cBrFakt

   DO WHILE !Eof() .AND. field->idfirma + field->idtipdok + field->brdok == cFirma + cTipDok + cBrFakt

      ++nCnt

      _rec := dbf_get_rec()
      aMemo := ParsMemo( _rec[ "txt" ] )

      _rec[ "idtipdok" ] := "10"
      _rec[ "brdok" ] := cNBrFakt
      _rec[ "datdok" ] := dDatFakt

      IF nCnt = 1

         _rec[ "txt" ] := ""
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 1 ] + Chr( 17 )
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 2 ] + Chr( 17 )
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 3 ] + Chr( 17 )
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 4 ] + Chr( 17 )
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 5 ] + Chr( 17 )
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 6 ] + Chr( 17 )
         // datum otpremnice
         _rec[ "txt" ] += Chr( 16 ) + DToC( dDatIsp ) + Chr( 17 )
         _rec[ "txt" ] += Chr( 16 ) + aMemo[ 8 ] + Chr( 17 )
         // datum narudzbe / amemo[9]
         _rec[ "txt" ] += Chr( 16 ) + DToC( dDatVal ) + Chr( 17 )
         // datum valute / amemo[10]
         _rec[ "txt" ] += Chr( 16 ) + DToC( dDatVal ) + Chr( 17 )

         // dodaj i ostala polja

         IF Len( aMemo ) > 10
            FOR i := 11 TO Len( aMemo )
               _rec[ "txt" ] += Chr( 16 ) + aMemo[ i ] + Chr( 17 )
            NEXT
         ENDIF

      ENDIF

      SELECT fakt_pripr
      APPEND BLANK
      dbf_update_rec( _rec )

      SELECT fakt
      SKIP

   ENDDO

   IF nCnt > 0
      MsgBeep( "Dokument formiran i nalazi se u pripremi. Obradite ga !" )
   ENDIF

   IF isugovori()

      IF pitanje(, "Setovati datum uplate za partnera ?", "N" ) == "D"

         O_UGOV
         SELECT ugov
         SET ORDER TO TAG "PARTNER"
         GO TOP
         SEEK cPart

         IF Found() .AND. field->idpartner == cPart
            _rec := dbf_get_rec()
            _rec[ "dat_l_fakt" ] := Date()
            update_rec_server_and_dbf( "fakt_ugov", _rec, 1, "FULL" )
         ENDIF

      ENDIF

   ENDIF

   SELECT fakt_doks

/*
   //o_partner()
   SELECT fakt_doks

   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilter
   ENDIF

   GO nTrec
*/

   RETURN DE_REFRESH



FUNCTION fakt_pregled_reopen_fakt_tabele( cFilter )

   my_close_all_dbf()

   O_VRSTEP
   o_ops()
   o_fakt_doks2()
   o_valute()
   // o_rj()
   o_fakt_objekti()
   o_fakt()
   // o_partner()
   o_fakt_doks()

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP

   SET FILTER TO &( cFilter )

   RETURN .T.




FUNCTION fakt_real_partnera()

   o_fakt_doks()
   // o_partner()
   o_valute()
   // o_rj()

   cIdfirma := self_organizacija_id()
   dDatOd := CToD( "" )
   dDatDo := Date()

   qqTipDok := "10;"

   Box(, 11, 77 )

   cTabela := "N"
   cBrFakDok := Space( 40 )
   cImeKup := Space( 20 )

   qqPartn := Space( 20 )
   qqOpc := Space( 20 )

   cTabela := fetch_metric( "fakt_real_tabela", my_user(), cTabela )
   cImeKup := fetch_metric( "fakt_real_ime_kupca", my_user(), cImeKup )
   qqPartn := fetch_metric( "fakt_real_partner", my_user(), qqPartn )
   cBrFakDok := fetch_metric( "fakt_real_broj_dok", my_user(), cBrFakDok )
   cIdFirma := fetch_metric( "fakt_real_id_firma", my_user(), cIdFirma )
   dDatOd := fetch_metric( "fakt_real_datum_od", my_user(), dDatOd )
   dDatDo := fetch_metric( "fakt_real_datum_do", my_user(), dDatDo )

   qqPartn := PadR( qqPartn, 20 )
   qqTipDok := PadR( qqTipDok, 40 )
   qqOpc := PadR( qqOpc, 20 )

   DO WHILE .T.
      cIdFirma := PadR( cidfirma, 2 )
      @ m_x + 1, m_y + 2 SAY "RJ            " GET cIdFirma VALID {|| Empty( cidfirma ) .OR. cidfirma == self_organizacija_id() .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      @ m_x + 2, m_y + 2 SAY "Tip dokumenta " GET qqTipDok PICT "@!S20"
      @ m_x + 3, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 3, Col() + 1 SAY "do"  GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Uslov po nazivu kupca (prazno svi)"  GET qqPartn PICT "@!"
      @ m_x + 7, m_y + 2 SAY "Broj dokumenta (prazno svi)"  GET cBrFakDok PICT "@!"
      @ m_x + 9, m_y + 2 SAY "Opcina (prazno sve)" GET qqOpc PICT "@!"
      READ
      ESC_BCR
      aUslBFD := Parsiraj( cBrFakDok, "BRDOK", "C" )
      aUslovSifraKupca := Parsiraj( qqPartn, "IDPARTNER" )
      aUslTD := Parsiraj( qqTipdok, "IdTipdok", "C" )
      IF aUslBFD <> NIL .AND. aUslTD <> NIL
         EXIT
      ENDIF
   ENDDO

   qqTipDok := Trim( qqTipDok )
   qqPartn := Trim( qqPartn )

   set_metric( "fakt_real_tabela", my_user(), cTabela )
   set_metric( "fakt_real_ime_kupca", my_user(), cImeKup )
   set_metric( "fakt_real_partner", my_user(), qqPartn )
   set_metric( "fakt_real_broj_dok", my_user(), cBrFakDok )
   set_metric( "fakt_real_id_firma", my_user(), cIdFirma )
   set_metric( "fakt_real_datum_od", my_user(), dDatOd )
   set_metric( "fakt_real_datum_do", my_user(), dDatDo )

   BoxC()

   SELECT fakt_doks

   PRIVATE cFilter := ".t."

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilter += ".and.  datdok>=" + dbf_quote( dDatOd ) + ".and. datdok<=" + dbf_quote( dDatDo )
   ENDIF

   IF cTabela == "D"  // tabel prikaz
      cFilter += ".and. IdFirma=" + dbf_quote( cIdFirma )
   ENDIF

   IF !Empty( cBrFakDok )
      cFilter += ".and." + aUslBFD
   ENDIF

   IF !Empty( qqPartn )
      cFilter += ".and." + aUslovSifraKupca
   ENDIF

   IF !Empty( qqTipDok )
      cFilter += ".and." + aUslTD
   ENDIF

   IF cFilter = ".t..and."
      cFilter := SubStr( cFilter, 9 )
   ENDIF

   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilter
   ENDIF

   EOF CRET

   // gaZagFix:={3,3}
   START PRINT CRET

   PRIVATE nStrana := 0
   PRIVATE m := "---- ------ -------------------------- ------------ ------------ ------------"

   fakt_zagl_real_partnera()

   SET ORDER TO TAG "6" // "6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS"
   SEEK cIdFirma

   nC := 0
   ncol1 := 10
   nTIznos := nTRabat := 0
   PRIVATE cRezerv := " "
   DO WHILE !Eof() .AND. IdFirma = cIdFirma
      // uslov po partneru
      IF !Empty( qqPartn )
         IF !( fakt_doks->partner = qqPartn )
            SKIP
            LOOP
         ENDIF
      ENDIF

      nIznos := 0
      nRabat := 0
      cIdPartner := idpartner
      select_o_partner( cIdPartner )
      SELECT fakt_doks


      // uslov po opcini
      IF !Empty( qqOpc )
         IF At( partn->idops, qqOpc ) == 0
            SKIP
            LOOP
         ENDIF
      ENDIF

      DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. idpartner == cIdpartner
         IF DinDem == Left( ValBazna(), 3 )
            nIznos += Round( iznos, ZAOKRUZENJE )
            nRabat += Round( Rabat, ZAOKRUZENJE )
         ELSE
            nIznos += Round( iznos * UBaznuValutu( datdok ), ZAOKRUZENJE )
            nRabat += Round( Rabat * UBaznuValutu( datdok ), ZAOKRUZENJE )
         ENDIF
         SKIP
      ENDDO
      IF PRow() > 61
         FF
         fakt_zagl_real_partnera()
      ENDIF

      ? Space( gnLMarg )
      ?? Str( ++nC, 4 ) + ".", cIdPartner, PadR( partn->naz, 25 )
      nCol1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY Str( nIznos + nRabat, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nRabat, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nIznos, 12, 2 )

      ntIznos += nIznos
      ntRabat += nRabat
   ENDDO

   IF PRow() > 59
      FF
      fakt_zagl_real_partnera()
   ENDIF

   ? Space( gnLMarg )
   ?? m
   ? Space( gnLMarg )
   ?? " Ukupno"
   @ PRow(), nCol1 SAY Str( ntIznos + ntRabat, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( ntRabat, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( ntIznos, 12, 2 )
   ? Space( gnLMarg )
   ?? m

   SET FILTER TO  // ukini filter

   FF
   ENDPRINT

   RETURN


// --------------------------------------------------------
// fakt_zagl_real_partnera()
// Zaglavlje izvjestaja realizacije partnera
// --------------------------------------------------------
FUNCTION fakt_zagl_real_partnera()

   ?
   P_12CPI
   ?? Space( gnLMarg )
   IspisFirme( cidfirma )
   ?
   SET CENTURY ON
   P_12CPI
   ? Space( gnLMarg ); ?? "FAKT: Stampa prometa partnera na dan:", Date(), Space( 8 ), "Strana:", Str( ++nStrana, 3 )
   ? Space( gnLMarg ); ?? "      period:", dDatOd, "-", dDatDo
   IF qqTipDok <> "10;"
      ? Space( gnLMarg ); ?? "-izvjestaj za tipove dokumenata :", Trim( qqTipDok )
   ENDIF

   SET CENTURY OFF
   P_12CPI
   ? Space( gnLMarg ); ?? m
   ? Space( gnLMarg ); ?? " Rbr  Sifra     Partner                  Ukupno        Rabat          UKUPNO"
   ? Space( gnLMarg ); ?? "                                           (1)          (2)            (1-2)"
   ? Space( gnLMarg ); ?? m

   RETURN .T.


/*
   Filter fakt_doks->idpartner->idops

   pretpostavlja:
   1) da je glavna tabela FAKT_DOKS
   2) da je tabela PARTN na ID indeksu
*/
FUNCTION flt_fakt_part_opc()

   LOCAL cRet

   select_o_partner( fakt_doks->idpartner )
   cRet := partn->idops
   SELECT fakt_doks

   RETURN cRet


FUNCTION fakt_dokument_sadrzi_robu()

   LOCAL lRet := .F., cQuery

   cQuery := "SELECT count(fakt_fakt.idroba) AS CNT FROM fmk.fakt_fakt"
   cQuery += " LEFT JOIN fmk.roba ON fakt_fakt.idroba = roba.id"
   cQuery += " WHERE roba.tip <> 'U'"
   cQuery += " AND fmk.fakt_fakt.idfirma=" + sql_quote( fakt_doks->idfirma )
   cQuery += " AND fmk.fakt_fakt.idtipdok=" + sql_quote( fakt_doks->idtipdok )
   cQuery += " AND fmk.fakt_fakt.brdok=" + sql_quote( fakt_doks->brdok )

   use_sql( "fakt_cnt", cQuery )

   IF field->CNT > 0
      lRet := .T. // ima robe unutar fakture
   ENDIF

   SELECT fakt_doks

   RETURN lRet
