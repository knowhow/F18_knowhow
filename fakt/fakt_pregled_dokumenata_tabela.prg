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

MEMVAR ImeKol
FIELD idfirma, idtipdok, brdok, rezerv, idvrstep, datdok, partner, iznos, rabat

STATIC s_lBrowseInitialized  := .F.

FUNCTION fakt_lista_dokumenata_tabelarni_pregled( lVrsteP, lOpcine, cFilter )

   LOCAL i
   LOCAL nWidthMeni := 30
   LOCAL nX, nY
   LOCAL hFaktParams := fakt_params()
   LOCAL cFiskalniUredjajModel := fiskalni_uredjaj_model()

   ImeKol := {}
   //AAdd( ImeKol, { " ",            {|| select_fakt_doks(), get_fiscal_info( cFiskalniUredjajModel ) } } )
   AAdd( ImeKol, { "RJ",           {|| fakt_doks->idfirma }  } )
   AAdd( ImeKol, { "VD",           {|| fakt_doks->idtipdok } } )
   AAdd( ImeKol, { "Brdok",        {|| fakt_doks->brdok + fakt_doks->rezerv } } )
   AAdd( ImeKol, { "VP",           {|| fakt_doks->idvrstep } } )
   AAdd( ImeKol, { "Datum",        {|| fakt_doks->Datdok } } )
   AAdd( ImeKol, { "Partner",      {|| PadR( fakt_doks->partner, 45 ) } } )
   AAdd( ImeKol, { "Ukupno",       {|| fakt_doks->iznos + fakt_doks->rabat } } )
   AAdd( ImeKol, { "Rabat",        {|| fakt_doks->rabat } } )
   AAdd( ImeKol, { "Ukupno-Rab ",  {|| fakt_doks->iznos } } )

   IF lVrsteP
      AAdd( ImeKol, { _u( "Način placanja" ), {|| fakt_doks->idvrstep } } )
   ENDIF

   // datum otpremnice datum valute
   AAdd( ImeKol, { _u( "Datum plaćanja" ), {|| fakt_doks->datpl } } )
   AAdd( ImeKol, { "Dat.otpr",       {|| fakt_doks->dat_otpr } } )
   AAdd( ImeKol, { "Dat.val.",       {|| fakt_doks->dat_val } } )

   //AAdd( ImeKol, { "Fisk.rn",        {|| PadR( prikazi_brojeve_fiskalnog_racuna( fisc_rn, fisc_st ), 20 ) } } )
   AAdd( ImeKol, { "Fisk.vr",        {|| PadR( DToC( fisc_date ) + " " + AllTrim( fisc_time ), 20 ) } } )

   // prikaz operatera
   AAdd( ImeKol, { "Operater",       {|| GetUserName( field->oper_id ) } } )

   // veza sa dokumentima
   IF hFaktParams[ "fakt_dok_veze" ]
      AAdd( ImeKol, { "Vezni dokumenti", {|| PadR( get_fakt_vezni_dokumenti( idfirma, idtipdok, brdok ), 50 ) } } )
   ENDIF

   Kol := {}
   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   nX := f18_max_rows() - 4
   nY := f18_max_cols() - 3

   Box( , nX, nY )

   @ get_x_koord() + nX - 4, get_y_koord() + 2 SAY8 _upadr( " <ENTER> Štampa TXT", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < P > Povrat dokumenta", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < I > Informacije", nWidthMeni )
   @ get_x_koord() + nX - 3, get_y_koord() + 2 SAY8 _upadr( " <a+P> ili <L> Štampa ODT", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < S > Storno dokument", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < c+V > Postavi vezu fisk.", nWidthMeni )
   @ get_x_koord() + nX - 2, get_y_koord() + 2 SAY8 _upadr( " < R > Štampa fisk.računa", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < F > ponuda->račun", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < F5 > osvježi ", nWidthMeni )
   @ get_x_koord() + nX - 1, get_y_koord() + 2 SAY8 _upadr( " < W > Dupliciraj", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < K > Ispravka podataka", nWidthMeni ) + ;
      BROWSE_COL_SEP + _upadr( " < T > Duplikat fiskalnog rn.", nWidthMeni )


   fUPripremu := .F.

   adImeKol := {}

   PRIVATE  bGoreRed := NIL
   PRIVATE  bDoleRed := NIL
   PRIVATE  bDodajRed := NIL
   PRIVATE  TBInitialized := .F.
   PRIVATE  fTBNoviRed := .F. // trenutno smo u novom redu ?
   PRIVATE  TBCanClose := .T. // da li se moze zavrsiti unos podataka ?
   PRIVATE  bZaglavlje := NIL
   // zaglavlje se edituje kada je kursor u prvoj koloni
   // prvog reda
   // PRIVATE  TBSkipBlock := {| nSkip | SkipDB( nSkip, @nTBLine ) }

   PRIVATE  nTBLine := 1      // tekuca linija-kod viselinijskog browsa
   PRIVATE  nTBLastLine := 1  // broj linija kod viselinijskog browsa
   PRIVATE  TBPomjerise := "" // ako je ">2" pomjeri se lijevo dva
   // ovo se mo§e setovati u when/valid fjama

   PRIVATE  TBScatter := "N"  // uzmi samo tekuce polje

   FOR i := 1 TO Len( ImeKol )
      AAdd( adImeKol, ImeKol[ i ] )
   NEXT

   ASize( adImeKol, Len( adImeKol ) + 1 )
   AIns( adImeKol, 6 )
   adImeKol[ 6 ] := { "ID PARTNER", {|| idpartner }, "idpartner", {|| .T. }, {|| p_partner( @widpartner ) }, "V" }

   adKol := {}
   FOR i := 1 TO Len( adImeKol )
      AAdd( adKol, i )
   NEXT


   my_db_edit_sql( "", nX - 3, nY, {| nCh | fakt_pregled_dokumenata_browse_key_handler( nCh, lOpcine, cFiskalniUredjajModel ) }, "", "", .F., ;
      NIL, NIL, NIL, 2,  NIL, NIL, {| nSkip | fakt_pregled_dokumenata_skip_block( nSkip ) } ) // aOpcije, nFreeze, bPodvuci, nPrazno, nGPrazno, aPoredak, bSkipBlock


   BoxC()

   IF fUpripremu
      my_close_all_dbf()
      fakt_unos_dokumenta()
   ENDIF

   my_close_all_dbf()

   RETURN .T.



FUNCTION fakt_pregled_dokumenata_browse_key_handler( nCh, lOpcine, cFiskalniUredjajModel )

   LOCAL nRet := DE_CONT
   LOCAL hRec
   LOCAL cFilter
   LOCAL _dev_id, hFiskalniParams
   LOCAL lRefresh
   LOCAL nFaktDokTekuciZapis := RecNo()

   // LOCAL nDbfArea := Select()
   LOCAL hFiskRacunParams
   LOCAL nFiscal
   LOCAL nRekl
   LOCAL dFiscal_date
   LOCAL cFiscal_time
   LOCAL lReload
   LOCAL nPovrat
   LOCAL GetList := {}

   s_lBrowseInitialized := .T.

   cFilter := fakt_doks->( dbFilter() )

   // prikazi_broj_fiskalnog_racuna( cFiskalniUredjajModel )

   lRefresh := .F.
   lReload := .F.

   DO CASE

   CASE nCh == K_ENTER

      // nRet := print_porezna_faktura( lOpcine )
      SELECT F_FAKT_DOKS
      IF !Used()
         MsgBeep( "ERROR FAKT_DOKS nije otvoren ?!" )
      ELSE
         fakt_stamp_txt_dokumenta( fakt_doks->IdFirma, fakt_doks->IdTipdok, fakt_doks->Brdok )
      ENDIF
      lRefresh := .T.
      lReload := .T.

   CASE nCh == K_ALT_P .OR. Upper( Chr( nCh ) ) == "L"

      nRet := fakt_print_odt( lOpcine )
      lRefresh := .T.
      lReload := .T.

   CASE nCh == K_F5

      SELECT fakt_doks
      USE
      o_fakt_doks()

      nRet := DE_REFRESH
      lRefresh := .T.
      lReload := .T.


   CASE nCh == K_CTRL_V

      SELECT fakt_doks

      IF postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, cFiskalniUredjajModel )

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
      @ get_x_koord() + 1, get_y_koord() + 2 SAY8 "   fiskalni račun:" GET nFiscal PICT "9999999999"
      @ get_x_koord() + 2, get_y_koord() + 2 SAY8 "reklamirani račun:" GET nRekl PICT "9999999999"
      @ get_x_koord() + 3, get_y_koord() + 2 SAY8 "            datum:" GET dFiscal_date
      @ get_x_koord() + 4, get_y_koord() + 2 SAY8 "          vrijeme:" GET cFiscal_time PICT "@S10"
      READ
      BoxC()

      IF nFiscal <> field->fisc_rn .OR. nRekl <> field->fisc_st

         hRec := dbf_get_rec()
         hRec[ "fisc_rn" ] := nFiscal
         hRec[ "fisc_st" ] := nRekl
         hRec[ "fisc_time" ] := cFiscal_time
         hRec[ "fisc_date" ] := dFiscal_date

         update_rec_server_and_dbf( "fakt_doks", hRec, 1, "FULL" )

         nRet := DE_REFRESH
         lRefresh := .T.
         lReload := .F.
      ENDIF

   CASE Upper( Chr( nCh ) ) $ "K"

      IF fakt_ispravka_podataka_azuriranog_dokumenta( field->idfirma, field->idtipdok, field->brdok )
         nRet := DE_REFRESH
         lRefresh := .T.
         lReload := .T.
      ENDIF

   CASE Upper( Chr( nCh ) ) == "T"

      IF !( field->idtipdok $ "10#11" )
         MsgBeep( "Opcija moguća samo za račune !" )
         RETURN DE_CONT
      ENDIF

      IF !fiscal_opt_active()
         RETURN DE_CONT
      ENDIF

      _dev_id := odaberi_fiskalni_uredjaj( field->idtipdok, .F., .F. )

      IF _dev_id > 0
         hFiskalniParams := get_fiscal_device_params( _dev_id, my_user() )
         IF hFiskalniParams == NIL
            RETURN DE_CONT
         ENDIF
      ELSE

         RETURN DE_CONT
      ENDIF

      IF hFiskalniParams[ "drv" ] <> "FPRINT"
         MsgBeep( "Opcija moguća samo za FPRINT/DATECS uređaje !" )
         RETURN DE_CONT
      ENDIF

      hFiskRacunParams := hb_Hash()

      IF field->fisc_st <> 0
         hFiskRacunParams[ "storno" ] := .T.
      ELSE
         hFiskRacunParams[ "storno" ] := .F.
      ENDIF

      hFiskRacunParams[ "datum" ] := field->fisc_date
      hFiskRacunParams[ "vrijeme" ] := field->fisc_time

      fprint_dupliciraj_racun( hFiskalniParams, hFiskRacunParams )

      MsgBeep( "Duplikat računa za datum: " + DToC( field->fisc_date ) + ", vrijeme: " + AllTrim( field->fisc_time ) )
      lRefresh := .T.
      lReload := .T.


   CASE Upper( Chr( nCh ) ) == "R"

      IF !fiscal_opt_active()
         RETURN DE_CONT
      ENDIF

      IF field->idtipdok $ "10#11"

         IF postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, cFiskalniUredjajModel )
            MsgBeep( "Fiskalni račun već štampan za ovaj dokument !#Ako je potrebna ponovna štampa resetujte broj veze." )
            RETURN DE_CONT
         ENDIF

         IF Pitanje( "ST FISK RN5", "Štampati fiskalni račun za dokument " + ;
               AllTrim( field->idfirma ) + "-" + ;
               AllTrim( field->idtipdok ) + "-" + ;
               AllTrim( field->brdok ) + " (D/N) ?", "D" ) == "D"

            _dev_id := odaberi_fiskalni_uredjaj( field->idtipdok, .F., .F. )

            IF _dev_id > 0
               hFiskalniParams := get_fiscal_device_params( _dev_id, my_user() )
               IF hFiskalniParams == NIL
                  RETURN DE_CONT
               ENDIF
            ELSE
               RETURN DE_CONT
            ENDIF
            IF hFiskalniParams[ "print_fiscal" ] == "N"
               MsgBeep( "Nije Vam dozvoljena opcija za štampu fiskalnih računa !" )
               RETURN DE_CONT
            ENDIF

            fakt_fiskalni_racun( field->idfirma, field->idtipdok, field->brdok, .F., hFiskalniParams )

            // SELECT ( nDbfArea )
            // nRet := DE_REFRESH
            lRefresh := .T.
            lReload := .T.

         ENDIF

      ENDIF

   CASE Upper( Chr( nCh ) ) == "W"

      fakt_napravi_duplikat( field->idfirma, field->idtipdok, field->brdok )
      SELECT fakt_doks

   CASE Upper( Chr( nCh ) ) == "S"

      fakt_generisi_storno_dokument( field->idfirma, field->idtipdok, field->brDok )

      IF Pitanje(, "Preći u tabelu pripreme ?", "D" ) == "D"
         fUPripremu := .T.
         nRet := DE_ABORT
         lRefresh := .F.
      ELSE
         nRet := DE_REFRESH
         lRefresh := .T.
         lReload := .T.
      ENDIF

   CASE Upper( Chr( nCh ) ) == "N"

      SELECT fakt_doks
      fakt_print_narudzbenica( field->idFirma, field->IdTipDok, field->BrDok )
      nRet := DE_CONT
      lRefresh := .T.

   CASE Upper( Chr( nCh ) ) == "F"

      IF idtipdok $ "20"
         nRet := generisi_fakturu( lOpcine )
         lRefresh := .T.
         lReload := .T.
      ENDIF

   CASE Upper( Chr( nCh ) ) = "P"

      nPovrat := povrat_fakt_dokumenta( .F., field->idfirma, field->idtipdok, field->brdok )

      o_fakt_doks()
      IF nPovrat <> 0 .AND. Pitanje(, "Preći u tabelu pripreme ?", "D" ) == "D"
         fUPripremu := .T.
         lRefresh := .F.
         lReload := .F.
         nRet := DE_ABORT
      ELSE
         nRet := DE_REFRESH
         lRefresh := .T.
         lReload := .T.
      ENDIF

   ENDCASE

   IF lRefresh

      // SELECT ( nDbfArea )
      // SET ORDER TO TAG "1"
      IF lReload
         fakt_pregled_reload_tables( cFilter )
      ENDIF
      SELECT FAKT_DOKS
      GO ( nFaktDokTekuciZapis )
      nRet := DE_REFRESH

   ENDIF

   RETURN nRet


STATIC FUNCTION fakt_pregled_dokumenata_skip_block( nRecs, cFiskalniUredjajModel )

   LOCAL nSkipped := 0

   IF LastRec() != 0
      DO CASE
      CASE nRecs == 0
         IF Eof()
            dbSkip( - 1 )
            nSkipped := -1
         ELSE
            dbSkip( 0 )
         ENDIF
      CASE nRecs > 0 .AND. RecNo() != LastRec() + 1
         DO WHILE nSkipped < nRecs
            dbSkip()
            IF Eof()
               dbSkip( - 1 )
               EXIT
            ENDIF
            nSkipped++
         ENDDO
      CASE nRecs < 0
         DO WHILE nSkipped > nRecs
            dbSkip( - 1 )
            IF Bof()
               EXIT
            ENDIF
            nSkipped--
         ENDDO
      ENDCASE
   ENDIF

   IF TBInitialized .AND. nSkipped != 0  // TBInitialized se postavlja unutar my_db_edit_sql, znaci da je zavrseno inicijalno renderisanje browse objekta
      prikazi_broj_fiskalnog_racuna( cFiskalniUredjajModel )
   ENDIF

   RETURN nSkipped



STATIC FUNCTION prikazi_broj_fiskalnog_racuna( cFiskalniUredjajModel )

   LOCAL cFiskalniRacun
   LOCAL cReklamiraniRacun
   LOCAL _total
   LOCAL _txt := ""

   IF fakt_doks->idtipdok $ "10#11"
      IF !postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, cFiskalniUredjajModel )
         _txt := "nema fiskalnog računa !"
         @ get_x_koord() + 1, get_y_koord() + 2 SAY8 PadR( _txt, 60 ) COLOR "W/R+"
      ELSE
         cFiskalniRacun := AllTrim( Str( fakt_doks->fisc_rn ) )
         cReklamiraniRacun := AllTrim( Str( fakt_doks->fisc_st ) )
         _txt := ""
         IF cReklamiraniRacun <> "0"
            _txt += "reklamirani račun: " + cReklamiraniRacun + ", "
         ENDIF
         _txt += "fiskalni račun: " + cFiskalniRacun
         @ get_x_koord() + 1, get_y_koord() + 2 SAY8 PadR( _txt, 60 ) COLOR "GR+/B"
      ENDIF
   ELSE
      @ get_x_koord() + 1, get_y_koord() + 2 SAY PadR( "", 60 )
   ENDIF

   RETURN .T.


/*
STATIC FUNCTION get_fiscal_info( cFiskalniUredjajModel )

   LOCAL cInfo := " "

   IF !postoji_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, cFiskalniUredjajModel )
      cInfo := " "
   ELSE
      cInfo := "F"
   ENDIF

   prikazi_broj_fiskalnog_racuna( cFiskalniUredjajModel )

   RETURN cInfo
*/


STATIC FUNCTION prikazi_brojeve_fiskalnog_racuna( _f_rn, _s_rn )

   LOCAL _txt := ""

   _txt += AllTrim( Str( _f_rn ) )

   IF _s_rn > 0
      _txt += " / "
      _txt += AllTrim( Str( _s_rn ) )
   ENDIF

   RETURN _txt



FUNCTION fakt_pregled_reload_tables( cFilter )

   LOCAL nRec

   IF Select( "FAKT_DOKS" ) > 0
      SELECT FAKT_DOKS
      nRec := RecNo()
   ENDIF

   my_close_all_dbf()

   // o_vrstep()
   // o_ops()

   // o_valute()
   // o_rj()
   select_o_fakt_objekti()

   o_fakt()
   // o_partner()
   o_fakt_doks2()
   o_fakt_doks()

   SELECT fakt_doks
   SET ORDER TO TAG "1"
   GO TOP

   ?E time(), "fakt_pregled_reload_tables"
   SET FILTER TO &( cFilter )
   GO TOP
   IF nRec != NIL
      GO nRec
   ENDIF

   RETURN .T.
