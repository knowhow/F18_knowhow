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




FUNCTION pos_vrati_broj_racuna_iz_fiskalnog( fisc_rn, broj_racuna, datum_racuna )

   LOCAL _qry, _qry_ret, _table
   LOCAL _server := my_server()
   LOCAL _i, oRow
   LOCAL _id_pos := gIdPos
   LOCAL _rn_broj := ""
   LOCAL _ok := .F.

   _qry := " SELECT pd.datum, pd.brdok, pd.fisc_rn, " + ;
      " SUM( pp.kolicina * pp.cijena ) as iznos, " + ;
      " SUM( pp.kolicina * pp.ncijena ) as popust " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "pos_pos pp " + ;
      " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " pos_doks pd " + ;
      " ON pd.idpos = pp.idpos AND pd.idvd = pp.idvd AND pd.brdok = pp.brdok AND pd.datum = pp.datum " + ;
      " WHERE pd.idpos = " + sql_quote( _id_pos ) + ;
      " AND pd.idvd = '42' AND pd.fisc_rn = " + AllTrim( Str( fisc_rn ) ) + ;
      " GROUP BY pd.datum, pd.brdok, pd.fisc_rn " + ;
      " ORDER BY pd.datum, pd.brdok, pd.fisc_rn "

   _table := _sql_query( _server, _qry )
   _table:GoTo( 1 )

   IF _table:LastRec() > 1

      _arr := {}

      DO WHILE !_table:Eof()
         oRow := _table:GetRow()
         AAdd( _arr, { oRow:FieldGet( 1 ), oRow:FieldGet( 2 ), oRow:FieldGet( 3 ), oRow:FieldGet( 4 ), oRow:FieldGet( 5 ) } )
         _table:Skip()
      ENDDO

      izaberi_racun_iz_liste( _arr, @broj_racuna, @datum_racuna )

      _ok := .T.

   ELSE

      IF _table:LastRec() == 0
         RETURN _ok
      ENDIF

      _ok := .T.
      oRow := _table:GetRow()
      broj_racuna := oRow:FieldGet( oRow:FieldPos( "brdok" ) )
      datum_racuna := oRow:FieldGet( oRow:FieldPos( "datum" ) )

   ENDIF

   RETURN _ok




STATIC FUNCTION izaberi_racun_iz_liste( arr, broj_racuna, datum_racuna )

   LOCAL _ret := 0
   LOCAL _i, _n
   LOCAL _tmp
   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _m_x := m_x
   LOCAL _m_y := m_y

   FOR _i := 1 TO Len( arr )

      _tmp := ""
      _tmp += DToC( arr[ _i, 1 ] )
      _tmp += " racun: "
      _tmp += PadR( PadL( AllTrim( gIdPos ), 2 ) + "-" + AllTrim( arr[ _i, 2 ]  ), 10 )
      _tmp += PadL( AllTrim( Str( arr[ _i, 4 ] - arr[ _i, 5 ], 12, 2 ) ), 10 )

      AAdd( _opc, _tmp )
      AAdd( _opcexe, {|| "" } )

   NEXT

   DO WHILE .T. .AND. LastKey() != K_ESC
      _izbor := Menu( "choice", _opc, _izbor, .F. )
      IF _izbor == 0
         EXIT
      ELSE
         broj_racuna := arr[ _izbor, 2 ]
         datum_racuna := arr[ _izbor, 1 ]
         _izbor := 0
      ENDIF
   ENDDO

   m_x := _m_x
   m_y := _m_y

   RETURN _ret



// ---------------------------------------------------------------
// koriguje broj racuna
// ---------------------------------------------------------------
STATIC FUNCTION _fix_rn_no( racun )

   LOCAL _a_rn := {}

   IF !Empty( racun ) .AND. ( "-" $ racun )

      _a_rn := TokToNiz( racun, "-" )

      IF !Empty( _a_rn[ 2 ] )
         racun := PadR( AllTrim( _a_rn[ 2 ] ), 6 )
      ENDIF

   ENDIF

   RETURN .T.



// ---------------------------------------------------------------
// storniranje racuna po fiskalnom isjecku
// ---------------------------------------------------------------
FUNCTION pos_storno_fisc_no()

   LOCAL nTArea := Select()
   LOCAL _rec
   LOCAL _datum, _broj_rn
   LOCAL _fisc_broj := 0
   PRIVATE GetList := {}
   PRIVATE aVezani := {}

   Box(, 1, 55 )
   @ m_x + 1, m_y + 2 SAY8 "broj fiskalnog isječka:" GET _fisc_broj ;
      VALID pos_vrati_broj_racuna_iz_fiskalnog( _fisc_broj, @_broj_rn, @_datum ) ;
      PICT "9999999999"
   READ
   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      RETURN
   ENDIF

   napravi_u_pripremi_storno_dokument( _datum, _broj_rn, Str( _fisc_broj, 10 ) )

   SELECT ( nTArea )

   oBrowse:goBottom()
   oBrowse:refreshAll()
   oBrowse:dehilite()

   DO WHILE !oBrowse:Stabilize() .AND. ( ( Ch := Inkey() ) == 0 )
   ENDDO

   RETURN


FUNCTION pos_storno_rn( lSilent, cSt_rn, dSt_date, cSt_fisc )

   LOCAL nTArea := Select()
   LOCAL _rec
   LOCAL _datum := gDatum
   LOCAL _danasnji := "D"
   PRIVATE GetList := {}
   PRIVATE aVezani := {}

   IF lSilent == nil
      lSilent := .F.
   ENDIF

   IF cSt_rn == nil
      cSt_rn := Space( 6 )
   ENDIF

   IF dSt_date == nil
      dSt_date := Date()
   ENDIF

   IF cSt_fisc == nil
      cSt_fisc := Space( 10 )
   ENDIF

   SELECT ( F_POS )
   IF !Used()
      O_POS
   ENDIF

   SELECT ( F_POS_DOKS )
   IF !Used()
      O_POS_DOKS
   ENDIF

   Box(, 4, 55 )

   @ m_x + 1, m_y + 2 SAY8 "Račun je današnji (D/N) ?" GET _danasnji VALID _danasnji $ "DN" PICT "@!"

   READ

   IF _danasnji == "N"
      _datum := NIL
   ENDIF

   @ m_x + 2, m_y + 2 SAY8 "stornirati pos račun broj:" GET cSt_rn VALID {|| pos_lista_racuna( @_datum, @cSt_rn, .T. ), _fix_rn_no( @cSt_rn ), dSt_date := _datum,  .T. }
   @ m_x + 3, m_y + 2 SAY "od datuma:" GET dSt_date

   READ

   cSt_rn := PadL( AllTrim( cSt_rn ), 6 )

   IF Empty( cSt_fisc )
      SELECT pos_doks
      SEEK gIdPos + "42" + DToS( dSt_date ) + cSt_rn
      cSt_fisc := PadR( AllTrim( Str( pos_doks->fisc_rn ) ), 10 )
   ENDIF

   @ m_x + 4, m_y + 2 SAY8 "broj fiskalnog isječka:" GET cSt_fisc

   READ

   BoxC()

   IF LastKey() == K_ESC
      SELECT ( nTArea )
      RETURN
   ENDIF

   IF Empty( cSt_rn )
      SELECT ( nTArea )
      RETURN
   ENDIF

   SELECT ( nTArea )

   napravi_u_pripremi_storno_dokument( dSt_date, cSt_rn, cSt_fisc )

   SELECT ( F_POS )
   USE
   SELECT ( F_POS_DOKS )
   USE

   SELECT ( nTArea )

   IF lSilent == .F.

      oBrowse:goBottom()
      oBrowse:refreshAll()
      oBrowse:dehilite()

      DO WHILE !oBrowse:Stabilize() .AND. ( ( Ch := Inkey() ) == 0 )
      ENDDO

   ENDIF

   RETURN


STATIC FUNCTION napravi_u_pripremi_storno_dokument( rn_datum, storno_rn, broj_fiscal )

   LOCAL _t_area := Select()
   LOCAL _t_roba, _rec

   SELECT ( F_POS )
   IF !Used()
      O_POS
   ENDIF
   SELECT pos
   SEEK gIdPos + "42" + DToS( rn_datum ) + storno_rn

   DO WHILE !Eof() .AND. field->idpos == gIdPos ;
         .AND. field->brdok == storno_rn ;
         .AND. field->idvd == "42"

      _t_roba := field->idroba

      SELECT roba
      SEEK _t_roba

      SELECT pos

      _rec := dbf_get_rec()
      hb_HDel( _rec, "rbr" )

      SELECT _pos_pripr
      APPEND BLANK

      _rec[ "brdok" ] :=  "PRIPRE"
      _rec[ "kolicina" ] := ( _rec[ "kolicina" ] * -1 )
      _rec[ "robanaz" ] := roba->naz
      _rec[ "datum" ] := gDatum
      _rec[ "idvrstep" ] := "01"

      IF Empty( broj_fiscal )
         _rec[ "c_1" ] := AllTrim( storno_rn )
      ELSE
         _rec[ "c_1" ] := AllTrim( broj_fiscal )
      ENDIF

      dbf_update_rec( _rec )

      SELECT pos
      SKIP

   ENDDO

   SELECT pos
   USE

   SELECT ( _t_area )

   RETURN



