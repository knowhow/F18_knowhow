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
   PRIVATE cImekup, cIdFirma, qqTipDok, cBrFakDok, qqPartn
   PRIVATE cFilter := ".t."

   O_VRSTEP
   O_OPS
   O_VALUTE
   O_RJ
   O_FAKT_OBJEKTI
   O_FAKT
   O_PARTN
   O_FAKT_DOKS

   qqVrsteP := Space( 20 )
   dDatVal0 := dDatVal1 := CToD( "" )

   cIdfirma := gFirma
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

      IF gNW $ "DR"
         cIdFirma := PadR( cIdfirma, 2 )
         @ m_x + 1, m_y + 2 SAY "RJ prazno svi" GET cIdFirma valid {|| Empty( cidfirma ) .OR. cidfirma == gfirma .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
         READ
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      ENDIF

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

      READ

      ESC_BCR

      aUslBFD := Parsiraj( cBrFakDok, "BRDOK", "C" )
      aUslovSifraKupca := Parsiraj( qqPartn, "IDPARTNER", "C" )
      aUslVrsteP := Parsiraj( qqVrsteP, "IDVRSTEP", "C" )
      aUslOpc := Parsiraj( cOpcina, "flt_fakt_part_opc()", "C" )

      IF ( !lOpcine .OR. aUslOpc <> NIL ) .AND. aUslBFD <> NIL .AND. aUslovSifraKupca <> NIL .AND. ( !_vrste_pl .OR. aUslVrsteP <> NIL )
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

   SELECT partn
   // radi filtera aUslOpc partneri trebaju biti na ID-u indeksirani
   SET ORDER TO TAG "ID"

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
      cFilter += ".and. " + aUslOpc
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

   IF cFilter == ".t. .and."
      cFilter := SubStr( cFilter, 9 )
   ENDIF

   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF

   @ MaxRow() - 4, MaxCol() - 3 SAY Str( rloptlevel(), 2 )

   qqTipDok := Trim( qqTipDok )

   SEEK cIdFirma + qqTipDok

   EOF CRET

   IF cTabela == "D"
      fakt_lista_dokumenata_tabelarni_pregled( _vrste_pl, lOpcine, cFilter )
   ELSE
      gaZagFix := { 3, 3 }
      stampa_liste_dokumenata( dDatOd, dDatDo, qqTipDok, cIdFirma, _objekat_id, cImeKup, lOpcine, aUslOpc, valute )
   ENDIF

   my_close_all_dbf()

   RETURN


FUNCTION print_porezna_faktura( lOpcine )

   LOCAL nTrec

   SELECT fakt_doks
   nTrec := RecNo()

   _cIdFirma := idfirma
   _cIdTipDok := idtipdok
   _cBrDok := brdok

   close_open_fakt_tabele()

   fakt_stamp_txt_dokumenta( _cidfirma, _cIdTipdok, _cbrdok )

   SELECT ( F_FAKT_DOKS )
   USE

   O_FAKT_DOKS
   O_PARTN
   SELECT fakt_doks
   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF
   GO nTrec

   RETURN DE_CONT


FUNCTION fakt_print_odt( lOpcine )

   SELECT fakt_doks

   nTrec := RecNo()
   _cIdFirma := idfirma
   _cIdTipDok := idtipdok
   _cBrDok := brdok
   my_close_all_dbf()

   fakt_stampa_dok_odt( _cidfirma, _cIdTipdok, _cbrdok )


   close_open_fakt_tabele()
   SELECT ( F_FAKT_DOKS )
   USE
   O_FAKT_DOKS
   O_PARTN
   SELECT fakt_doks
   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF
   GO nTrec

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
   LOCAL _t_area := Select()

   IF Pitanje(, "Generisati fakturu na osnovu ponude ?", "D" ) == "N"
      RETURN DE_CONT
   ENDIF

   O_FAKT_PRIPR
   O_FAKT

   IF fakt_pripr->( RecCount() ) <> 0
      MsgBeep( "Priprema mora biti prazna !!!" )
      SELECT ( _t_area )
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

      ++ nCnt

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

   O_PARTN
   SELECT fakt_doks

   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF

   GO nTrec

   RETURN DE_REFRESH



STATIC FUNCTION prikazi_broj_fiskalnog_racuna( model )

   LOCAL _fisc_rn
   LOCAL _rekl_rn
   LOCAL _total
   LOCAL _txt := ""

   IF fakt_doks->idtipdok $ "10#11"
      IF !postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, model )
         _txt := "nema fiskalnog računa !"
         @ m_x + 1, m_y + 2 SAY8 PadR( _txt, 60 ) COLOR "W/R+"
      ELSE
         _fisc_rn := AllTrim( Str( fakt_doks->fisc_rn ) )
         _rekl_rn := AllTrim( Str( fakt_doks->fisc_st ) )
         _txt := ""
         IF _rekl_rn <> "0"
            _txt += "reklamirani račun: " + _rekl_rn + ", "
         ENDIF
         _txt += "fiskalni račun: " + _fisc_rn
         @ m_x + 1, m_y + 2 SAY8 PadR( _txt, 60 ) COLOR "GR+/B"
      ENDIF
   ELSE
      @ m_x + 1, m_y + 2 SAY PadR( "", 60 )
   ENDIF

   RETURN .T.



FUNCTION fakt_tabela_komande( lOpcine, fakt_doks_filt, model )

   LOCAL nRet := DE_CONT
   LOCAL _rec
   LOCAL _filter
   LOCAL _dev_id, _dev_params
   LOCAL _refresh
   LOCAL _t_rec := RecNo()
   LOCAL _t_area := Select()

   _filter := dbFilter()

   prikazi_broj_fiskalnog_racuna( model )

   _refresh := .F.

   DO CASE

   CASE Ch == K_ENTER

      nRet := print_porezna_faktura( lOpcine )
      _refresh := .T.

   CASE Ch == K_ALT_P

      nRet := fakt_print_odt( lOpcine )
      _refresh := .T.

   CASE Ch == K_F5

      SELECT fakt_doks
      USE
      O_FAKT_DOKS

      nRet := DE_REFRESH
      _refresh := .T.


   CASE CH == K_CTRL_V

      SELECT fakt_doks

      IF postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, model )

         MsgBeep( "veza: fiskalni račun već setovana !" )

         IF Pitanje( "FAKT_PROM_VEZU", "Promjeniti postojeću vezu (D/N)?", "N" ) == "N"
            RETURN DE_CONT
         ENDIF

      ENDIF

      IF Pitanje( "FISC_NVEZA_SET", "Setovati novu vezu sa fiskalnim računom (D/N)?", "D" ) == "N"
         RETURN DE_CONT
      ENDIF

      nFiscal := field->fisc_rn
      nRekl := field->fisc_st
      dFiscal_date := field->fisc_date
      cFiscal_time := PadR( field->fisc_time, 10 )

      Box(, 4, 40 )
      @ m_x + 1, m_y + 2 SAY "fiskalni racun:" GET nFiscal PICT "9999999999"
      @ m_x + 2, m_y + 2 SAY "reklamni racun:" GET nRekl PICT "9999999999"
      @ m_x + 3, m_y + 2 SAY "         datum:" GET dFiscal_date
      @ m_x + 4, m_y + 2 SAY "       vrijeme:" GET cFiscal_time PICT "@S10"
      READ
      BoxC()

      IF nFiscal <> field->fisc_rn .OR. nRekl <> field->fisc_st

         _rec := dbf_get_rec()
         _rec[ "fisc_rn" ] := nFiscal
         _rec[ "fisc_st" ] := nRekl
         _rec[ "fisc_time" ] := cFiscal_time
         _rec[ "fisc_date" ] := dFiscal_date

         update_rec_server_and_dbf( "fakt_doks", _rec, 1, "FULL" )

         nRet := DE_REFRESH
         _refresh := .T.

      ENDIF

   CASE Chr( Ch ) $ "kK"

      IF fakt_ispravka_podataka_azuriranog_dokumenta( field->idfirma, field->idtipdok, field->brdok )
         nRet := DE_REFRESH
         _refresh := .T.
      ENDIF

   CASE Upper( Chr( Ch ) ) == "T"

      IF ! ( field->idtipdok $ "10#11" )
         MsgBeep( "Opcija moguća samo za račune !" )
         RETURN DE_CONT
      ENDIF

      IF !fiscal_opt_active()
         RETURN DE_CONT
      ENDIF

      _dev_id := odaberi_fiskalni_uredjaj( field->idtipdok, .F., .F. )

      IF _dev_id > 0
         _dev_params := get_fiscal_device_params( _dev_id, my_user() )
         IF _dev_params == NIL
            RETURN DE_CONT
         ENDIF
      ELSE

         RETURN DE_CONT
      ENDIF

      IF _dev_params[ "drv" ] <> "FPRINT"
         MsgBeep( "Opcija moguća samo za FPRINT/DATECS uređaje !" )
         RETURN DE_CONT
      ENDIF

      _rn_params := hb_Hash()

      IF field->fisc_st <> 0
         _rn_params[ "storno" ] := .T.
      ELSE
         _rn_params[ "storno" ] := .F.
      ENDIF

      _rn_params[ "datum" ] := field->fisc_date
      _rn_params[ "vrijeme" ] := field->fisc_time

      fprint_dupliciraj_racun( _dev_params, _rn_params )

      MsgBeep( "Duplikat računa za datum: " + DToC( field->fisc_date ) + ", vrijeme: " + AllTrim( field->fisc_time ) )


   CASE Upper( Chr( Ch ) ) == "R"

      IF !fiscal_opt_active()
         RETURN DE_CONT
      ENDIF

      IF field->idtipdok $ "10#11"

         IF postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, model )
            MsgBeep( "Fiskalni račun već štampan za ovaj dokument !#Ako je potrebna ponovna štampa resetujte broj veze." )
            RETURN DE_CONT
         ENDIF

         IF Pitanje( "ST FISK RN5", "Štampati fiskalni račun za dokument " + ;
               AllTrim( field->idfirma ) + "-" + ;
               AllTrim( field->idtipdok ) + "-" + ;
               AllTrim( field->brdok ) + " (D/N) ?", "D" ) == "D"

            _dev_id := odaberi_fiskalni_uredjaj( field->idtipdok, .F., .F. )

            IF _dev_id > 0
               _dev_params := get_fiscal_device_params( _dev_id, my_user() )

               IF _dev_params == NIL
                  RETURN DE_CONT
               ENDIF
            ELSE
               RETURN DE_CONT
            ENDIF

            IF _dev_params[ "print_fiscal" ] == "N"
               MsgBeep( "Nije Vam dozvoljena opcija za štampu fiskalnih računa !" )
               RETURN DE_CONT
            ENDIF

            fakt_fiskalni_racun( field->idfirma, field->idtipdok, field->brdok, .F., _dev_params )

            SELECT ( _t_area )

            nRet := DE_REFRESH
            _refresh := .T.

         ENDIF

      ENDIF

   CASE Chr( ch ) $ "wW"

      fakt_napravi_duplikat( field->idfirma, field->idtipdok, field->brdok )
      SELECT fakt_doks

   CASE Chr( Ch ) $ "sS"

      fakt_generisi_storno_dokument( field->idfirma, field->idtipdok, field->brDok )

      IF Pitanje(, "Preći u tabelu pripreme ?", "D" ) == "D"
         fUPripremu := .T.
         nRet := DE_ABORT
      ELSE
         nRet := DE_REFRESH
         _refresh := .T.
      ENDIF

   CASE Chr( Ch ) $ "nN"

      SELECT fakt_doks
      fakt_print_narudzbenica( field->idFirma, field->IdTipDok, field->BrDok )
      nRet := DE_CONT
      _refresh := .T.

   CASE Chr( Ch ) $ "fF"

      IF idtipdok $ "20"
         nRet := generisi_fakturu( lOpcine )
         _refresh := .T.
      ENDIF

   CASE Chr( Ch ) $ "pP"

      _tmp := povrat_fakt_dokumenta( .F., field->idfirma, field->idtipdok, field->brdok )

      O_FAKT_DOKS

      IF _tmp <> 0 .AND. Pitanje(, "Preći u tabelu pripreme ?", "D" ) == "D"
         fUPripremu := .T.
         _refresh := .F.
         nRet := DE_ABORT
      ELSE
         nRet := DE_REFRESH
         _refresh := .T.
      ENDIF

   ENDCASE

   IF _refresh

      SELECT ( _t_area )
      SET ORDER TO TAG "1"

      refresh_fakt_tbl_dbfs( _filter )

      GO ( _t_rec )

   ENDIF

   RETURN nRet




FUNCTION refresh_fakt_tbl_dbfs( tbl_filter )

   my_close_all_dbf()

   O_VRSTEP
   O_OPS
   O_FAKT_DOKS2
   O_VALUTE
   O_RJ
   O_FAKT_OBJEKTI
   O_FAKT
   O_PARTN
   O_FAKT_DOKS

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP

   SET FILTER TO &( tbl_filter )

   RETURN .T.




FUNCTION fakt_real_partnera()

   O_FAKT_DOKS
   O_PARTN
   O_VALUTE
   O_RJ

   cIdfirma := gFirma
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
      @ m_x + 1, m_y + 2 SAY "RJ            " GET cIdFirma valid {|| Empty( cidfirma ) .OR. cidfirma == gfirma .OR. P_RJ( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
      @ m_x + 2, m_y + 2 SAY "Tip dokumenta " GET qqTipDok PICT "@!S20"
      @ m_x + 3, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 3, Col() + 1 SAY "do"  GET dDatDo
      @ m_x + 6, m_y + 2 SAY "Uslov po nazivu kupca (prazno svi)"  GET qqPartn PICT "@!"
      @ m_x + 7, m_y + 2 SAY "Broj dokumenta (prazno svi)"  GET cBrFakDok PICT "@!"
      @ m_x + 9, m_y + 2 SAY "Opcina (prazno sve)" GET qqOpc PICT "@!"
      READ
      ESC_BCR
      aUslBFD := Parsiraj( cBrFakDok, "BRDOK", "C" )
      aUslovSifraKupca:=Parsiraj( qqPartn,"IDPARTNER")
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

   if !empty(qqPartn)
    cFilter+=".and."+aUslovSifraKupca
   endif

   IF !Empty( qqTipDok )
      cFilter += ".and." + aUslTD
   ENDIF

   IF cFilter = ".t..and."
      cFilter := SubStr( cFilter, 9 )
   ENDIF

   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
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
      SELECT partn
      HSEEK cIdPartner
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

   RETURN


/*
   Filter fakt_doks->idpartner->idops

   pretpostavlja:
   1) da je glavna tabela FAKT_DOKS
   2) da je tabela PARTN na ID indeksu
*/
FUNCTION flt_fakt_part_opc()

   LOCAL cRet

   SELECT partn
   SEEK fakt_doks->idpartner
   cRet := partn->idops
   SELECT fakt_doks

   RETURN cRet
