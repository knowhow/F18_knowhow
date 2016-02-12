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
#include "f18_separator.ch"



STATIC FUNCTION _o_pos_prepis_tbl()

   SELECT ( F_PARTN )
   IF !Used()
      O_PARTN
   ENDIF

   SELECT ( F_VRSTEP )
   IF !Used()
      O_VRSTEP
   ENDIF

   SELECT ( F_DIO )
   IF !Used()
      O_DIO
   ENDIF

   SELECT ( F_ODJ )
   IF !Used()
      O_ODJ
   ENDIF

   SELECT ( F_KASE )
   IF !Used()
      O_KASE
   ENDIF

   SELECT ( F_OSOB )
   IF !Used()
      O_OSOB
      SET ORDER TO TAG "NAZ"
   ENDIF

   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF

   SELECT ( F_VALUTE )
   IF !Used()
      O_VALUTE
   ENDIF

   SELECT ( F_SIFK )
   IF !Used()
      O_SIFK
   ENDIF

   SELECT ( F_SIFV )
   IF !Used()
      O_SIFV
   ENDIF

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF

   SELECT ( F_POS_DOKS )
   IF !Used()
      O_POS_DOKS
   ENDIF

   SELECT ( F_POS )
   IF !Used()
      O_POS
   ENDIF

   RETURN


FUNCTION pos_prepis_dokumenta()

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
      RETURN
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

   IF gStolovi == "D"
      AAdd( ImeKol, { "Sto", {|| sto_br } } )
   ELSE
      AAdd( ImeKol, { "Smj", {|| smjena } } )
   ENDIF

   AAdd( ImeKol, { PadC( "Iznos", 10 ), {|| pos_iznos_dokumenta( NIL ) } } )
   AAdd( ImeKol, { "Radnik", {|| IdRadnik } } )

   IF gStolovi == "D"
      AAdd( ImeKol, { "Zaklj", {|| zak_br } } )
   ENDIF

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
      SET FILTER to &cFilter
   ENDIF

   GO TOP

   aOpc := { "<ENTER> Odabir", "<E> eksport" }

   IF klevel <= "1"
      AAdd( aOpc, "<F2> - promjena vrste placanja" )
   ENDIF

   ObjDBedit( "pos_doks", MAXROWS() - 10, MAXCOLS() - 3, {|| pos_stampa_dokumenta_key_handler( dDatOd, dDatDo ) }, "  STAMPA AZURIRANOG DOKUMENTA  ", "", nil, aOpc )

   CLOSE ALL

   RETURN



FUNCTION pos_stampa_dokumenta_key_handler( dDat0, dDat1 )

   LOCAL cLevel
   LOCAL cOdg
   LOCAL nRecNo
   LOCAL ctIdPos
   LOCAL dtDatum
   LOCAL _rec, _id_pos, _id_vd, _dat_dok, _br_dok
   LOCAL _t_area := Select()
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

   CASE Ch == K_F2 .AND. kLevel <= "1"

      IF Pitanje(, "Želite li promijeniti vrstu plaćanja (D/N) ?", "N" ) == "D"

         cVrPl := field->idvrstep

         IF !VarEdit( { { "Nova vrsta placanja", "cVrPl", "Empty (cVrPl).or.P_VrsteP(@cVrPl)", "@!", } }, 10, 5, 14, 74, 'PROMJENA VRSTE PLACANJA, DOKUMENT:' + idvd + "/" + idpos + "-" + brdok + " OD " + DToC( datum ), "B1" )
            RETURN DE_CONT
         ENDIF

         _rec := dbf_get_rec()
         _rec[ "idvrstep" ] := cVrPl

         update_rec_server_and_dbf( "pos_doks", _rec, 1, "FULL" )

         RETURN DE_REFRESH

      ENDIF

      RETURN DE_CONT

   CASE Ch == K_CTRL_F9

      _id_pos := field->idpos
      _id_vd := field->idvd
      _br_dok := field->brdok
      _dat_dok := field->datum

      _rec_no := RecNo()

      IF Pitanje(, "Želite li zaista izbrisati dokument (D/N) ?", "N" ) == "D"

         pos_brisi_dokument( _id_pos, _id_vd, _dat_dok, _br_dok )

         _o_pos_prepis_tbl()

         SELECT ( _t_area )
         SET FILTER to &_tbl_filter
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
      CASE pos_doks->IdVd == VD_RZS
         PrepisRazd()
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
      StampaPrep( IdPos, DToS( datum ) + BrDok, aVezani, .T., nil, .T. )

      SELECT pos_doks

      f7_pf_traka( .T. )

      SELECT pos_doks

      RETURN ( DE_REFRESH )

   CASE gStolovi == "D" .AND. ( Ch == Asc( "Z" ) .OR. Ch == Asc( "z" ) )

      IF pos_doks->idvd == "42"

         PushWA()
         print_zak_br( pos_doks->zak_br )
         o_pos_tables()
         PopWa()
         SELECT pos_doks
         RETURN ( DE_REFRESH )

      ENDIF

      RETURN ( DE_CONT )


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
         SET FILTER to &_tbl_filter
         GO TOP

         MsgBeep( "Dokument je vraćen u pripremu inventure ..." )

         RETURN ( DE_REFRESH )

      ENDIF

      RETURN ( DE_CONT )


   ENDCASE

   _o_pos_prepis_tbl()
   SELECT pos_doks
   SET FILTER to &( _tbl_filter )
   GO ( _rec_no )

   RETURN ( DE_CONT )




FUNCTION pos_pregled_stavki_racuna()

   LOCAL oBrowse
   LOCAL cPrevCol
   LOCAL _rec
   LOCAL nMaxCol := MAXCOL() - 2

   PRIVATE ImeKol
   PRIVATE Kol

   cPrevCol := SetColor( INVERT )

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

      _rec := dbf_get_rec()

      SELECT roba
      HSEEK _rec[ "idroba" ]

      _rec[ "robanaz" ] := roba->naz
      _rec[ "jmj" ] := roba->jmj

      hb_HDel( _rec, "rbr" )

      SELECT _pos_pripr
      APPEND BLANK

      dbf_update_rec( _rec )

      SELECT POS
      SKIP

   ENDDO

   SELECT _pos_pripr
   GO TOP

   browse_kolone( @ImeKol, @Kol )

   Box(, 15, nMaxCol )

   @ m_x + 1, m_y + 19 SAY8 PadC ( "Pregled " + IIF( gRadniRac == "D", "stalnog ", "" ) + "računa " + Trim( pos_doks->IdPos ) + "-" + LTrim ( pos_doks->BrDok ), 30 ) COLOR INVERT

   oBrowse := FormBrowse( m_x + 2, m_y + 1, m_x + 15, m_y + nMaxCol, ImeKol, Kol, { BROWSE_PODVUCI_2, BROWSE_PODVUCI, BROWSE_COL_SEP }, 0 )
   ShowBrowse( oBrowse, {}, {} )

   SELECT _pos_pripr
   my_dbf_zap()
   BoxC()

   SetColor ( cPrevCol )

   SELECT pos_doks

   RETURN



STATIC FUNCTION browse_kolone( aImeKol, aKol )

   LOCAL i

   aImeKol := {}
   aKol := {}

   AADD( aImeKol, { "Sifra", {|| idroba } } )
   AADD( aImeKol, { "Naziv", {|| Left( robanaz, 30 ) } } )
   AADD( aImeKol, { "Kolicina", {|| Str( kolicina, 7, 3 ) } } )
   AADD( aImeKol, { "Cijena", {|| Str( cijena, 7, 2 ) } } )
   AADD( aImeKol, { "Ukupno", {|| Str( kolicina * cijena, 11, 2 ) } } )
   AADD( aImeKol, { "Tarifa", {|| idtarifa } } )

   FOR i := 1 TO Len( aImeKol )
      AAdd( aKol, i )
   NEXT

   RETURN


