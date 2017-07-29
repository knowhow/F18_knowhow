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

STATIC s_bFaktDoksPeriod

FUNCTION fakt_pregled_liste_dokumenata()

   LOCAL _curr_user := "<>"
   LOCAL nCol1 := 0
   LOCAL nUl, nIzl, nRbr
   LOCAL m
   LOCAL _objekat_id
   LOCAL dDatod, dDatdo
   LOCAL _params := fakt_params()
   LOCAL _vrste_pl := _params[ "fakt_vrste_placanja" ]
   LOCAL _objekti := _params[ "fakt_objekti" ]
   LOCAL _vezni_dokumenti := _params[ "fakt_dok_veze" ]
   LOCAL lOpcine := .T.
   LOCAL cValute := Space( 3 )
   LOCAL cFilter := ".t."
   LOCAL cFilterOpcina
   LOCAL cSamoRobaDN := "N"
   LOCAL bFilter

   PRIVATE cImekup, cIdFirma, cUslovTipDok, cBrFakDok, cUslovIdPartner

   // o_vrstep()
   // o_ops()
   // o_valute()
   // o_rj()
   // o_fakt_objekti()

   // o_fakt_dbf()
   // o_partner()
   // o_fakt_doks_dbf()

   qqVrsteP := Space( 20 )
   dDatVal0 := dDatVal1 := CToD( "" )

   cIdFirma := self_organizacija_id()
   dDatOd := CToD( "" )
   dDatDo := Date()
   cUslovTipDok := ""
   cUslovIdPartner := Space( 20 )
   cTabela := "N"
   cBrFakDok := Space( 40 )
   cImeKup := Space( 20 )
   cOpcina := Space( 30 )

   IF _objekti
      _objekat_id := Space( 10 )
   ENDIF

   Box( , 13 + iif( _vrste_pl .OR. lOpcine .OR. _objekti, 6, 0 ), 77 )

   cIdFirma := fetch_metric( "fakt_stampa_liste_id_firma", _curr_user, cIdFirma )
   cUslovTipDok := fetch_metric( "fakt_stampa_liste_dokumenti", _curr_user, cUslovTipDok )
   dDatOd := fetch_metric( "fakt_stampa_liste_datum_od", _curr_user, dDatOd )
   dDatDo := fetch_metric( "fakt_stampa_liste_datum_do", _curr_user, dDatDo )
   cTabela := fetch_metric( "fakt_stampa_liste_tabelarni_pregled", _curr_user, cTabela )
   cImeKup := fetch_metric( "fakt_stampa_liste_ime_kupca", _curr_user, cImeKup )
   cUslovIdPartner := fetch_metric( "fakt_stampa_liste_partner", _curr_user, cUslovIdPartner )
   cBrFakDok := fetch_metric( "fakt_stampa_liste_broj_dokumenta", _curr_user, cBrFakDok )

   cImeKup := PadR( cImeKup, 20 )
   cUslovIdPartner := PadR( cUslovIdPartner, 20 )
   cUslovTipDok := PadR( cUslovTipDok, 2 )

   DO WHILE .T.

      // IF gNW $ "DR"
      cIdFirma := PadR( cIdFirma, 2 )

      fakt_getlist_rj_read( get_x_koord() + 1, get_y_koord() + 2, @cIdFirma )

      READ
      // ELSE
      // @ get_x_koord() + 1, get_y_koord() + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      // ENDIF

      @ get_x_koord() + 2, get_y_koord() + 2 SAY "Tip dokumenta (prazno svi tipovi)" GET cUslovTipDok PICT "@!"
      @ get_x_koord() + 3, get_y_koord() + 2 SAY "Od datuma " GET dDatOd
      @ get_x_koord() + 3, Col() + 1 SAY "do" GET dDatDo
      @ get_x_koord() + 5, get_y_koord() + 2 SAY8 "Ime kupca počinje sa (prazno svi)" GET cImeKup PICT "@!"
      @ get_x_koord() + 6, get_y_koord() + 2 SAY8 "Uslov po šifri kupca (prazno svi)" GET cUslovIdPartner PICT "@!" ;
         VALID {|| cFilterSifraKupca := Parsiraj( cUslovIdPartner, "IDPARTNER", "C", NIL, F_PARTN ), .T. }
      @ get_x_koord() + 7, get_y_koord() + 2 SAY "Broj dokumenta (prazno svi)" GET cBrFakDok PICT "@!"

      @ get_x_koord() + 9, get_y_koord() + 2 SAY "Tabelarni pregled" GET cTabela VALID cTabela $ "DN" PICT "@!"

      cRTarifa := "N"

      @ get_x_koord() + 11, get_y_koord() + 2 SAY "Rekapitulacija po tarifama ?" GET cRTarifa VALID cRtarifa $ "DN" PICT "@!"

      IF _vrste_pl
         @ get_x_koord() + 12, get_y_koord() + 2 SAY "----------------------------------------"
         @ get_x_koord() + 13, get_y_koord() + 2 SAY "Za fakture (Tip dok.10):"
         @ get_x_koord() + 14, get_y_koord() + 2 SAY8 "Način placanja:" GET qqVrsteP
         @ get_x_koord() + 15, get_y_koord() + 2 SAY8 "Datum valutiranja od" GET dDatVal0
         @ get_x_koord() + 15, Col() + 2 SAY "do" GET dDatVal1
         @ get_x_koord() + 16, get_y_koord() + 2 SAY "----------------------------------------"
      ENDIF

      @ get_x_koord() + 17, get_y_koord() + 2 SAY8 "Općina (prazno-sve): "  GET cOpcina

      IF _objekti
         @ get_x_koord() + 18, get_y_koord() + 2 SAY "Objekat (prazno-svi): "  GET _objekat_id VALID Empty( _objekat_id ) .OR. P_fakt_objekti( @_objekat_id )
      ENDIF

      @ get_x_koord() + 19, get_y_koord() + 2 SAY "Valute ( /KM/EUR)"  GET cValute
      @ get_x_koord() + 19, Col() + 2 SAY8 " samo dokumenti koji sadrže robu D/N"  GET cSamoRobaDN PICT "@!" VALID cSamoRobaDN $ "DN"

      READ

      ESC_BCR

      cFilterBrFaktDok := Parsiraj( cBrFakDok, "BRDOK", "C" )
      cFilterSifraKupca := Parsiraj( cUslovIdPartner, "IDPARTNER", "C" )
      aUslVrsteP := Parsiraj( qqVrsteP, "IDVRSTEP", "C" )
      cFilterOpcina := Parsiraj( cOpcina, "flt_fakt_part_opc()", "C" )

      IF ( !lOpcine .OR. cFilterOpcina <> NIL ) .AND. cFilterBrFaktDok <> NIL .AND. cFilterSifraKupca <> NIL .AND. ( !_vrste_pl .OR. aUslVrsteP <> NIL )
         EXIT
      ENDIF

   ENDDO

   cUslovTipDok := Trim( cUslovTipDok )
   cUslovIdPartner := Trim( cUslovIdPartner )

   set_metric( "fakt_stampa_liste_id_firma", f18_user(), cIdFirma )
   set_metric( "fakt_stampa_liste_dokumenti", f18_user(), cUslovTipDok )
   set_metric( "fakt_stampa_liste_datum_od", f18_user(), dDatOd )
   set_metric( "fakt_stampa_liste_datum_do", f18_user(), dDatDo )
   set_metric( "fakt_stampa_liste_tabelarni_pregled", f18_user(), cTabela )
   set_metric( "fakt_stampa_liste_ime_kupca", f18_user(), cImeKup )
   set_metric( "fakt_stampa_liste_partner", f18_user(), cUslovIdPartner )
   set_metric( "fakt_stampa_liste_broj_dokumenta", f18_user(), cBrFakDok )

   BoxC()

   // SELECT partn
   // radi filtera cFilterOpcina partneri trebaju biti na ID-u indeksirani
   // SET ORDER TO TAG "ID"

   // SET ORDER TO TAG "1"
   // GO TOP

   IF !Empty( dDatVal0 ) .OR. !Empty( dDatVal1 )
      cFilter += ".and. ( !idtipdok='10' .or. datpl>=" + _filter_quote( dDatVal0 ) + ".and. datpl<=" + _filter_quote( dDatVal1 ) + ")"
   ENDIF

   IF !Empty( qqVrsteP )
      cFilter += ".and. (!idtipdok='10' .or. " + aUslVrsteP + ")"
   ENDIF

   IF !Empty( cUslovTipDok )
      cFilter += ".and. idtipdok==" + _filter_quote( cUslovTipDok )
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
      cFilter += ".and." + cFilterBrFaktDok
   ENDIF

   IF !Empty( cUslovIdPartner )
      cFilter += ".and." + cFilterSifraKupca
   ENDIF

   IF !Empty( cValute )
      cFilter += ".and. dindem = " + _filter_quote( cValute )
   ENDIF

   IF cSamoRobaDN == "D"
      cFilter += ".and. fakt_dokument_sadrzi_robu()"
   ENDIF

   IF cFilter == ".t. .and."
      cFilter := SubStr( cFilter, 9 )
   ENDIF

   // IF cFilter == ".t."
   // SET FILTER TO
   // ELSE
   // SET FILTER TO &cFilter
   // ENDIF
   bFilter := {|| &cFilter }

   s_bFaktDoksPeriod := {|| find_fakt_doks_za_period( cIdFirma, dDatOd, dDatDo, "FAKT_DOKS_PREGLED", "idfirma,datdok,idtipdok,brdok" ), ;
      dbSetFilter( bFilter, cFilter ), dbGoTop() }

   Eval( s_bFaktDoksPeriod )


   @ f18_max_rows() - 4, f18_max_cols() - 3 SAY Str( rloptlevel(), 2 )

   cUslovTipDok := Trim( cUslovTipDok )

   // SEEK cIdFirma + cUslovTipDok

   EOF CRET

   IF cTabela == "D"
      fakt_lista_dokumenata_tabelarni_pregled( _vrste_pl, lOpcine, cFilter )
   ELSE
      gaZagFix := { 3, 3 }
      stampa_liste_dokumenata( dDatOd, dDatDo, cUslovTipDok, cIdFirma, _objekat_id, cImeKup, lOpcine, cFilterOpcina, cValute )
   ENDIF

   my_close_all_dbf()

   RETURN .T.



/*
FUNCTION print_porezna_faktura( lOpcine )

   LOCAL cIdFirma, cIdTipDok, cBrDok

   SELECT fakt_doks
   //nTrec := RecNo()

   cIdFirma := idfirma
   cIdTipDok := idtipdok
   cBrDok := brdok

   close_open_fakt_tabele()

   fakt_stamp_txt_dokumenta( cIdFirma, cIdTipdok, cBrdok )

   SELECT ( F_FAKT_DOKS )
   USE

   o_fakt_doks_dbf()

   RETURN DE_CONT
*/

FUNCTION fakt_print_odt( lOpcine )

   LOCAL cIdFirma := fakt_doks_pregled->idfirma
   LOCAL cIdTipDok := fakt_doks_pregled->idtipdok
   LOCAL cBrDok := fakt_doks_pregled->brdok

   // LOCAL nTrec := RecNo()

   // my_close_all_dbf()

   fakt_stampa_dok_odt( cIdFirma, cIdTipDok, cBrDok )

/*
   close_open_fakt_tabele()
   SELECT ( F_FAKT_DOKS )
   USE
   o_fakt_doks_dbf()
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
   LOCAL hRec
   LOCAL nDbfArea := Select()

   IF Pitanje(, "Generisati fakturu na osnovu ponude ?", "D" ) == "N"
      RETURN DE_CONT
   ENDIF

   o_fakt_pripr()
   o_fakt_dbf()

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

   @ get_x_koord() + 1, get_y_koord() + 2 SAY "*** Parametri fakture "

   @ get_x_koord() + 3, get_y_koord() + 2 SAY "  Datum fakture: " GET dDatFakt VALID !Empty( dDatFakt )
   @ get_x_koord() + 4, get_y_koord() + 2 SAY "   Datum valute: " GET dDatVal VALID !Empty( dDatVal )
   @ get_x_koord() + 5, get_y_koord() + 2 SAY " Datum isporuke: " GET dDatIsp VALID !Empty( dDatIsp )

   READ

   BoxC()

   SELECT fakt
   SET ORDER TO TAG "1"
   GO TOP
   SEEK cFirma + cTipDok + cBrFakt

   DO WHILE !Eof() .AND. field->idfirma + field->idtipdok + field->brdok == cFirma + cTipDok + cBrFakt

      ++nCnt

      hRec := dbf_get_rec()
      aMemo := fakt_ftxt_decode( hRec[ "txt" ] )

      hRec[ "idtipdok" ] := "10"
      hRec[ "brdok" ] := cNBrFakt
      hRec[ "datdok" ] := dDatFakt

      IF nCnt = 1

         hRec[ "txt" ] := ""
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 1 ] + Chr( 17 )
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 2 ] + Chr( 17 )
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 3 ] + Chr( 17 )
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 4 ] + Chr( 17 )
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 5 ] + Chr( 17 )
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 6 ] + Chr( 17 )
         // datum otpremnice
         hRec[ "txt" ] += Chr( 16 ) + DToC( dDatIsp ) + Chr( 17 )
         hRec[ "txt" ] += Chr( 16 ) + aMemo[ 8 ] + Chr( 17 )
         // datum narudzbe / amemo[9]
         hRec[ "txt" ] += Chr( 16 ) + DToC( dDatVal ) + Chr( 17 )
         // datum valute / amemo[10]
         hRec[ "txt" ] += Chr( 16 ) + DToC( dDatVal ) + Chr( 17 )

         // dodaj i ostala polja

         IF Len( aMemo ) > 10
            FOR i := 11 TO Len( aMemo )
               hRec[ "txt" ] += Chr( 16 ) + aMemo[ i ] + Chr( 17 )
            NEXT
         ENDIF

      ENDIF

      SELECT fakt_pripr
      APPEND BLANK
      dbf_update_rec( hRec )

      SELECT fakt
      SKIP

   ENDDO

   IF nCnt > 0
      MsgBeep( "Dokument formiran i nalazi se u pripremi. Obradite ga !" )
   ENDIF

   IF isugovori()

      IF pitanje(, "Setovati datum uplate za partnera ?", "N" ) == "D"

         o_ugov()
         SELECT ugov
         SET ORDER TO TAG "PARTNER"
         GO TOP
         SEEK cPart

         IF Found() .AND. field->idpartner == cPart
            hRec := dbf_get_rec()
            hRec[ "dat_l_fakt" ] := Date()
            update_rec_server_and_dbf( "fakt_ugov", hRec, 1, "FULL" )
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






FUNCTION fakt_real_partnera()

   LOCAL cFilter
   LOCAL cFilterBrFaktDok, cFilterSifraKupca, cFilterTipDok
   LOCAL cUslovTipDok, cUslovIdPartner, cUslovOpcina

   o_fakt_doks_dbf()
   // o_partner()
   // o_valute()
   // o_rj()

   cIdFirma := self_organizacija_id()
   dDatOd := CToD( "" )
   dDatDo := Date()

   cUslovTipDok := "10;"

   Box(, 11, 77 )

   cTabela := "N"
   cBrFakDok := Space( 40 )
   cImeKup := Space( 20 )

   cUslovIdPartner := Space( 20 )
   cUslovOpcina := Space( 20 )

   cTabela := fetch_metric( "fakt_real_tabela", my_user(), cTabela )
   cImeKup := fetch_metric( "fakt_real_ime_kupca", my_user(), cImeKup )
   cUslovIdPartner := fetch_metric( "fakt_real_partner", my_user(), cUslovIdPartner )
   cBrFakDok := fetch_metric( "fakt_real_broj_dok", my_user(), cBrFakDok )
   cIdFirma := fetch_metric( "fakt_real_id_firma", my_user(), cIdFirma )
   dDatOd := fetch_metric( "fakt_real_datum_od", my_user(), dDatOd )
   dDatDo := fetch_metric( "fakt_real_datum_do", my_user(), dDatDo )

   cUslovIdPartner := PadR( cUslovIdPartner, 20 )
   cUslovTipDok := PadR( cUslovTipDok, 40 )
   cUslovOpcina := PadR( cUslovOpcina, 20 )

   DO WHILE .T.
      cIdFirma := PadR( cIdFirma, 2 )

      fakt_getlist_rj_read( get_x_koord() + 1, get_y_koord() + 2, @cIdFirma )

      @ get_x_koord() + 2, get_y_koord() + 2 SAY "Tip dokumenta " GET cUslovTipDok PICT "@!S20"
      @ get_x_koord() + 3, get_y_koord() + 2 SAY "Od datuma "  GET dDatOd
      @ get_x_koord() + 3, Col() + 1 SAY "do"  GET dDatDo
      @ get_x_koord() + 6, get_y_koord() + 2 SAY "Uslov po nazivu kupca (prazno svi)"  GET cUslovIdPartner PICT "@!"
      @ get_x_koord() + 7, get_y_koord() + 2 SAY "Broj dokumenta (prazno svi)"  GET cBrFakDok PICT "@!"
      @ get_x_koord() + 9, get_y_koord() + 2 SAY8 "Općina (prazno sve)" GET cUslovOpcina PICT "@!"
      READ
      ESC_BCR

      cFilterBrFaktDok := Parsiraj( cBrFakDok, "BRDOK", "C" )
      cFilterSifraKupca := Parsiraj( cUslovIdPartner, "IDPARTNER" )
      cFilterTipDok := Parsiraj( cUslovTipDok, "IdTipdok", "C" )
      IF cFilterBrFaktDok <> NIL .AND. cFilterTipDok <> NIL
         EXIT
      ENDIF
   ENDDO


   cUslovTipDok := Trim( cUslovTipDok )
   cUslovIdPartner := Trim( cUslovIdPartner )

   set_metric( "fakt_real_tabela", my_user(), cTabela )
   set_metric( "fakt_real_ime_kupca", my_user(), cImeKup )
   set_metric( "fakt_real_partner", my_user(), cUslovIdPartner )
   set_metric( "fakt_real_broj_dok", my_user(), cBrFakDok )
   set_metric( "fakt_real_id_firma", my_user(), cIdFirma )
   set_metric( "fakt_real_datum_od", my_user(), dDatOd )
   set_metric( "fakt_real_datum_do", my_user(), dDatDo )

   BoxC()

   SELECT fakt_doks

   cFilter := ".t."

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilter += ".and.  datdok>=" + dbf_quote( dDatOd ) + ".and. datdok<=" + dbf_quote( dDatDo )
   ENDIF

   IF cTabela == "D"  // prikazu unutar browse-a
      cFilter += ".and. IdFirma=" + dbf_quote( cIdFirma )
   ENDIF

   IF !Empty( cBrFakDok )
      cFilter += ".and." + cFilterBrFaktDok
   ENDIF

   IF !Empty( cUslovIdPartner )
      cFilter += ".and." + cFilterSifraKupca
   ENDIF

   IF !Empty( cUslovTipDok )
      cFilter += ".and." + cFilterTipDok
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
      IF !Empty( cUslovIdPartner )
         IF !( fakt_doks->partner = cUslovIdPartner )
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
      IF !Empty( cUslovOpcina )
         IF At( partn->idops, cUslovOpcina ) == 0
            SKIP
            LOOP
         ENDIF
      ENDIF

      DO WHILE !Eof() .AND. IdFirma = cIdFirma .AND. idpartner == cIdpartner
         IF DinDem == Left( ValBazna(), 3 )
            nIznos += Round( iznos, fakt_zaokruzenje() )
            nRabat += Round( Rabat, fakt_zaokruzenje() )
         ELSE
            nIznos += Round( iznos * UBaznuValutu( datdok ), fakt_zaokruzenje() )
            nRabat += Round( Rabat * UBaznuValutu( datdok ), fakt_zaokruzenje() )
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

   RETURN .T.


// --------------------------------------------------------
// fakt_zagl_real_partnera()
// Zaglavlje izvjestaja realizacije partnera
// --------------------------------------------------------
FUNCTION fakt_zagl_real_partnera()

   ?
   P_12CPI
   ?? Space( gnLMarg )
   IspisFirme( cIdFirma )
   ?
   SET CENTURY ON
   P_12CPI
   ?U Space( gnLMarg ); ?? "FAKT: Štampa prometa partnera na dan:", Date(), Space( 8 ), "Strana:", Str( ++nStrana, 3 )
   ?U Space( gnLMarg ); ?? "      period:", dDatOd, "-", dDatDo
   IF cUslovTipDok <> "10;"
      ? Space( gnLMarg ); ?? "-izvjestaj za tipove dokumenata :", Trim( cUslovTipDok )
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

   select_o_partner( fakt_doks_pregled->idpartner )
   cRet := partn->idops
   SELECT fakt_doks_pregled

   RETURN cRet


FUNCTION fakt_dokument_sadrzi_robu()

   LOCAL lRet := .F., cQuery

   cQuery := "SELECT count(fakt_fakt.idroba) AS CNT FROM fmk.fakt_fakt"
   cQuery += " LEFT JOIN fmk.roba ON fakt_fakt.idroba = roba.id"
   cQuery += " WHERE roba.tip <> 'U'"
   cQuery += " AND fmk.fakt_fakt.idfirma=" + sql_quote( fakt_doks_pregled->idfirma )
   cQuery += " AND fmk.fakt_fakt.idtipdok=" + sql_quote( fakt_doks_pregled->idtipdok )
   cQuery += " AND fmk.fakt_fakt.brdok=" + sql_quote( fakt_doks_pregled->brdok )

   SELECT F_FAKT
   use_sql( "fakt_cnt", cQuery )

   IF field->CNT > 0
      lRet := .T. // ima robe unutar fakture
   ENDIF
   USE
   SELECT fakt_doks_pregled

   RETURN lRet





FUNCTION fakt_pregled_reload_tables( cFilter )

   LOCAL nRec

   IF Select( "FAKT_DOKS_PREGLED" ) > 0
      SELECT FAKT_DOKS_PREGLED
      nRec := RecNo()
   ENDIF

   my_close_all_dbf()
   Eval( s_bFaktDoksPeriod )

   ?E Time(), "fakt_pregled_reload_tables"
   // SET FILTER TO &( cFilter )
   // GO TOP

   IF nRec != NIL
      GO nRec
   ENDIF

   RETURN .T.
