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


FUNCTION pos_lista_azuriranih_dokumenata()

   LOCAL aOpc
   LOCAL _prikaz_partnera := .F.
   PRIVATE cFilter := ".t."
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   cVrste := "  "
   dDatOd := Date() - 1
   dDatDo := Date()

   Box(, 3, 60 )
   @ m_x + 1, m_y + 2 SAY "Datumski period:" GET dDatOd
   @ m_x + 1, Col() + 2 SAY "-" GET dDatDo
   @ m_x + 3, m_y + 2 SAY "Vrste (prazno-svi)" GET cVrste PICT "@!"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   _o_pos_prepis_tbl()

   AAdd( ImeKol, { "Vrsta", {|| IdVd } } )
   AAdd( ImeKol, { "Broj ", {|| PadR( IF( !Empty( IdPos ), Trim( IdPos ) + "-", "" ) + AllTrim( BrDok ), 9 ) } } )
   AAdd( ImeKol, { "Fisk.rn", {|| fisc_rn } } )

   IF _prikaz_partnera
      SELECT pos_doks
      SET RELATION TO idgost INTO partn
      AAdd( ImeKol, { PadR( "Partner", 25 ), {|| PadR( Trim( idgost ) + "-" + Trim( partn->naz ), 25 ) } } )
   ENDIF

   AAdd( ImeKol, { "VP", {|| IdVrsteP } } )
   AAdd( ImeKol, { "Datum", {|| datum } } )


   AAdd( ImeKol, { "Smj", {|| smjena } } )


   AAdd( ImeKol, { PadC( "Iznos", 10 ), {|| pos_iznos_dokumenta( NIL ) } } )
   AAdd( ImeKol, { "Radnik", {|| IdRadnik } } )


   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   SELECT pos_doks
   SET CURSOR ON

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilter += ".and. Datum>=" + dbf_quote( dDatOD ) + ".and. Datum<=" + dbf_quote( dDatDo )
   ENDIF
   IF !Empty( cVrste )
      cFilter += ".and. IdVd=" + dbf_quote( cVrste )
   ENDIF
   IF !( cFilter == ".t." )
      SET FILTER TO &cFilter
   ENDIF

   GO TOP

   aOpc := { "<ENTER> Odabir", "<E> eksport" }

   IF pos_upravnik() .OR. pos_admin()
      AAdd( aOpc, "<F2> - promjena vrste placanja" )
   ENDIF


   my_db_edit_sql( "pos_doks", f18_max_rows() - 10, f18_max_cols() - 15, ;  // params cImeBoxa, xw, yw
      {|| pos_stampa_dokumenta_key_handler( dDatOd, dDatDo ) }, _u( "  ŠTAMPA AŽURIRANOG DOKUMENTA  " ), "POS", ; // bUserF, cMessTop, cMessBot
      .F., aOpc ) // lInvert, aMessage

   CLOSE ALL

   RETURN .T.



FUNCTION pos_stampa_dokumenta_key_handler( dDat0, dDat1 )

   LOCAL cLevel
   LOCAL cOdg
   LOCAL nRecNo
   LOCAL ctIdPos
   LOCAL dtDatum
   LOCAL hRec, _id_pos, _id_vd, _dat_dok, _br_dok
   LOCAL nDbfArea := Select()
   LOCAL _tbl_filter := dbFilter()
   LOCAL _rec_no, _ok
   LOCAL _tbl_pos := "pos_pos"
   LOCAL _tbl_doks := "pos_doks"
   STATIC cIdPos
   STATIC cIdVd
   STATIC cBrDok
   STATIC dDatum
   STATIC cIdRadnik

   IF M->Ch == 0
      RETURN ( DE_CONT )
   ENDIF

   IF LastKey() == K_ESC
      RETURN ( DE_ABORT )
   ENDIF

   _rec_no := RecNo()

   DO CASE

   CASE Ch == K_F2 .AND. ( pos_admin() .OR. pos_upravnik() )

      IF Pitanje(, "Želite li promijeniti vrstu plaćanja (D/N) ?", "N" ) == "D"

         cVrPl := field->idvrstep

         IF !VarEdit( { { "Nova vrsta placanja", "cVrPl", "Empty (cVrPl).or.P_VrsteP(@cVrPl)", "@!", } }, 10, 5, 14, 74, 'PROMJENA VRSTE PLACANJA, DOKUMENT:' + idvd + "/" + idpos + "-" + brdok + " OD " + DToC( datum ), "B1" )
            RETURN DE_CONT
         ENDIF

         hRec := dbf_get_rec()
         hRec[ "idvrstep" ] := cVrPl

         update_rec_server_and_dbf( "pos_doks", hRec, 1, "FULL" )

         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE Ch == k_ctrl_f9()

      _id_pos := field->idpos
      _id_vd := field->idvd
      _br_dok := field->brdok
      _dat_dok := field->datum

      _rec_no := RecNo()

      IF Pitanje(, "Želite li zaista izbrisati dokument (D/N) ?", "N" ) == "D"

         pos_brisi_dokument( _id_pos, _id_vd, _dat_dok, _br_dok )

         _o_pos_prepis_tbl()

         SELECT ( nDbfArea )
         SET FILTER TO &_tbl_filter
         GO ( _rec_no )

         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE Ch == K_ENTER

      DO CASE

      CASE pos_doks->IdVd == VD_RN

         cOdg := "D"

         IF glRetroakt
            cOdg := Pitanje(, "Štampati tekući račun? (D-da,N-ne,S-sve račune u izabranom periodu)", "D", "DNS" )
         ENDIF

         IF cOdg == "S"

            ctIdPos := gIdPos
            SEEK ctIdPos + VD_RN

            START PRINT CRET

            DO WHILE !Eof() .AND. IdPos + IdVd == ctIdPos + VD_RN
               IF ( datum <= dDat1 )
                  aVezani := { { IdPos, BrDok, IdVd, datum } }
                  StampaPrep( IdPos, DToS( datum ) + BrDok, aVezani, .F., glRetroakt )
               ENDIF
               SELECT pos_doks
               SKIP 1
            ENDDO

            ENDPRINT

         ELSEIF cOdg == "D"

            aVezani := { { IdPos, BrDok, IdVd, datum } }
            StampaPrep( IdPos, DToS( datum ) + BrDok, aVezani, .T. )

         ENDIF

      CASE pos_doks->IdVd == "16"
         PrepisZad( "ZADUZENJE " )
      CASE pos_doks->IdVd == VD_OTP
         PrepisZad( "OTPIS " )
      CASE pos_doks->IdVd == VD_REK
         PrepisZad( "REKLAMACIJA" )
         // CASE pos_doks->IdVd == VD_RZS
         // PrepisRazd()

      CASE pos_doks->IdVd == "IN"
         PrepisInvNiv( .T. )
      CASE pos_doks->IdVd == VD_NIV
         PrepisInvNiv( .F. )
         RETURN ( DE_REFRESH )
      CASE pos_doks->IdVd == VD_PRR
         PrepisKumPr()
      CASE pos_doks->IdVd == VD_PCS
         PrepisPCS()
      ENDCASE

   CASE Ch == Asc( "F" ) .OR. Ch == Asc( "f" )

      aVezani := { { IdPos, BrDok, IdVd, datum } }
      StampaPrep( IdPos, DToS( datum ) + BrDok, aVezani, .T., NIL, .T. )

      SELECT pos_doks

      f7_pf_traka( .T. )

      SELECT pos_doks

      RETURN ( DE_REFRESH )



   CASE Ch == K_CTRL_P

      pos_stampa_dokumenta()

   CASE Ch == Asc( "E" ) .OR. Ch == Asc( "e" )

      IF field->idvd == "IN"
         IF Pitanje(, "Eksportovati dokument (D/N) ?", "N" ) == "D"
            pos_prenos_inv_2_kalk( field->idpos, field->idvd, field->datum, field->brdok )
         ENDIF
      ELSE
         MsgBeep( "Ne postoji metoda eksporta za ovu vrstu dokumenta !" )
      ENDIF

      RETURN ( DE_CONT )

   CASE Ch == Asc( "P" ) .OR. Ch == Asc( "p" )

      _id_pos := field->idpos
      _id_vd := field->idvd
      _br_dok := field->brdok
      _dat_dok := field->datum

      IF field->idvd <> VD_INV
         MsgBeep( "Ne postoji metoda povrata za ovu vrstu dokumenta !" )
         RETURN ( DE_CONT )
      ENDIF

      IF Pitanje(, "Dokument " + _id_pos + "-" + _id_vd + "-" + _br_dok + " povući u pripremu (D/N) ?", "N" ) == "N"
         RETURN ( DE_CONT )
      ENDIF

      IF field->idvd == VD_INV

         pos_povrat_dokumenta_u_pripremu()
         pos_brisi_dokument( _id_pos, _id_vd, _dat_dok, _br_dok )

         _o_pos_prepis_tbl()
         SELECT pos_doks
         SET FILTER TO &_tbl_filter
         GO TOP

         MsgBeep( "Dokument je vraćen u pripremu inventure ..." )

         RETURN ( DE_REFRESH )

      ENDIF

      RETURN ( DE_CONT )


   ENDCASE

   _o_pos_prepis_tbl()
   SELECT pos_doks
   SET FILTER TO &( _tbl_filter )
   GO ( _rec_no )

   RETURN ( DE_CONT )




FUNCTION pos_pregled_stavki_racuna()

   LOCAL oBrowse
   LOCAL cPrevCol
   LOCAL hRec
   LOCAL nMaxRow := f18_max_rows() - 15
   LOCAL nMaxCol := f18_max_cols() - 35


   PRIVATE ImeKol
   PRIVATE Kol

   cPrevCol := SetColor( f18_color_invert()  )

   SELECT F__PRIPR

   IF !Used()
      O__POS_PRIPR
   ENDIF

   SELECT _pos_pripr

   my_dbf_zap()

   Scatter()

   SELECT POS
   SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

   DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

      hRec := dbf_get_rec()

      select_o_roba( hRec[ "idroba" ] )

      hRec[ "robanaz" ] := roba->naz
      hRec[ "jmj" ] := roba->jmj

      hb_HDel( hRec, "rbr" )

      SELECT _pos_pripr
      APPEND BLANK

      dbf_update_rec( hRec )
      SELECT POS
      SKIP

   ENDDO

   SELECT _pos_pripr
   GO TOP

   browse_kolone( @ImeKol, @Kol )

   Box(, nMaxRow, nMaxCol )

   @ m_x + 1, m_y + 19 SAY8 PadC ( "Pregled računa " + Trim( pos_doks->IdPos ) + "-" + LTrim ( pos_doks->BrDok ), 30 ) COLOR f18_color_invert()

   oBrowse := pos_form_browse( m_x + 2, m_y + 1, m_x + nMaxRow, m_y + nMaxCol, ImeKol, Kol, ;
      { hb_UTF8ToStrBox( BROWSE_PODVUCI_2 ), ;
      hb_UTF8ToStrBox( BROWSE_PODVUCI ), ;
      hb_UTF8ToStrBox( BROWSE_COL_SEP ) }, 0 )
   ShowBrowse( oBrowse, {}, {} )
   SELECT _pos_pripr
   my_dbf_zap()

   BoxC()

   SetColor ( cPrevCol )

   SELECT pos_doks

   RETURN .T.



STATIC FUNCTION browse_kolone( aImeKol, aKol )

   LOCAL i

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { _u( "Šifra" ), {|| idroba } } )
   AAdd( aImeKol, { "Naziv", {|| Left( robanaz, 30 ) } } )
   AAdd( aImeKol, { _u( "Količina" ), {|| Str( kolicina, 7, 3 ) } } )
   AAdd( aImeKol, { "Cijena", {|| Str( cijena, 7, 2 ) } } )
   AAdd( aImeKol, { "Ukupno", {|| Str( kolicina * cijena, 11, 2 ) } } )
   AAdd( aImeKol, { "Tarifa", {|| idtarifa } } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN .T.



STATIC FUNCTION _o_pos_prepis_tbl()

// SELECT ( F_PARTN )
// IF !Used()
// o_partner()
// ENDIF

   SELECT ( F_VRSTEP )
   IF !Used()
      o_vrstep()
   ENDIF


   SELECT ( F_ODJ )
   IF !Used()
      o_pos_odj()
   ENDIF

   SELECT ( F_KASE )
   IF !Used()
      o_pos_kase()
   ENDIF

   SELECT ( F_OSOB )
   IF !Used()
      o_pos_osob()
      SET ORDER TO TAG "NAZ"
   ENDIF

// SELECT ( F_TARIFA )
// IF !Used()
// o_tarifa()
// ENDIF

   SELECT ( F_VALUTE )
   IF !Used()
      o_valute()
   ENDIF

// SELECT ( F_SIFK )
   // IF !Used()
// o_sifk()
// ENDIF

// SELECT ( F_SIFV )
// IF !Used()
// o_sifv()
// ENDIF

// SELECT ( F_ROBA )
   // IF !Used()
   // o_roba()
// ENDIF

   SELECT ( F_POS_DOKS )
   IF !Used()
      o_pos_doks()
   ENDIF

   SELECT ( F_POS )
   IF !Used()
      o_pos_pos()
   ENDIF

   RETURN .T.
