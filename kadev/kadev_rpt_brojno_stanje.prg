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

STATIC __template
STATIC __xml_file



FUNCTION kadev_izvjestaj_br_stanje()

   LOCAL _params

   __template := "kadev_br_stanje.odt"
   __xml_file := my_home() + "data.xml"

   IF !_get_vars( @_params )
      RETURN
   ENDIF

   IF _cre_xml( _params )
      IF generisi_odt_iz_xml( __template, __xml_file )
         prikazi_odt()
      ENDIF
   ENDIF

   RETURN



// -----------------------------------------------------
// -----------------------------------------------------
STATIC FUNCTION _get_vars( params )

   LOCAL _ok := .F.
   LOCAL _datum_od := CToD( "" )
   LOCAL _datum_do := Date()
   LOCAL _promjene := PadR( fetch_metric( "kadev_rpt_br_promjene", my_user(), "P1;P2;" ), 200 )
   LOCAL _rj := PadR( fetch_metric( "kadev_rpt_br_rj", my_user(), "" ), 100 )
   LOCAL _rmj := PadR( fetch_metric( "kadev_rpt_br_rmj", my_user(), "" ), 100 )
   LOCAL _spol := " "

   SET CENTURY ON

   Box(, 8, 65 )

   @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _datum_od
   @ m_x + 1, Col() + 1 SAY "do:" GET _datum_do

   @ m_x + 3, m_y + 2 SAY "Radne jedinice (prazno-sve):" GET _rj PICT "@S30"
   @ m_x + 4, m_y + 2 SAY "  Radna mjesta (prazno-sve):" GET _rmj PICT "@S30"

   @ m_x + 7, m_y + 2 SAY "Spol ( /M/Z):" GET _spol VALID _spol $ " MZ" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   set_metric( "kadev_rpt_br_rj", my_user(), AllTrim( _rj ) )
   set_metric( "kadev_rpt_br_rmj", my_user(), AllTrim( _rmj ) )

   params := hb_Hash()
   params[ "datum_od" ] := _datum_od
   params[ "datum_do" ] := _datum_do
   params[ "rj" ] := _rj
   params[ "rmj" ] := _rmj
   params[ "spol" ] := _spol

   _ok := .T.

   RETURN _ok


// -----------------------------------------------------
// -----------------------------------------------------
STATIC FUNCTION _get_data( param )

   LOCAL _data, _qry
   LOCAL _where := ""

   _where := " main.status = 'A' "

   IF !Empty( PARAM[ "datum_od" ] ) .OR. !Empty( PARAM[ "datum_do" ] )
      _where += " AND ( " + _sql_date_parse( "pr.datumod", PARAM[ "datum_od" ], PARAM[ "datum_do" ] ) + " ) "
   ENDIF


   IF !Empty( PARAM[ "rj" ] )
      _where += " AND ( "  + _sql_cond_parse( "main.idrj", PARAM[ "rj" ] ) + " ) "
   ENDIF

   IF !Empty( PARAM[ "rmj" ] )
      _where += " AND ( "  + _sql_cond_parse( "main.idrmj", PARAM[ "rmj" ] ) + " ) "
   ENDIF

   IF !Empty( PARAM[ "spol" ] )
      _where += " AND main.pol = " + sql_quote( PARAM[ "spol" ] )
   ENDIF

   // sredi WHERE upit na kraju...
   IF !Empty( _where )
      _where := "WHERE " + _where
   ENDIF

   _qry := "WITH tmp AS ( "
   _qry += " SELECT "
   _qry += "  main.id AS jmbg, "
   _qry += "  main.idrj AS idrj, "
   _qry += "  main.idstrspr AS idstrspr "
   _qry += "FROM " + F18_PSQL_SCHEMA_DOT + "kadev_1 pr "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_0 main ON pr.id = main.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_promj prom ON pr.idpromj = prom.id "
   _qry += " " + _where + " "
   _qry += "GROUP BY main.id, main.idrj, main.idstrspr "
   _qry += "ORDER BY main.id "
   _qry += " ) "
   _qry += " SELECT "
   _qry += "  idrj, "
   _qry += "  rj.naz, "
   _qry += "  SUM( CASE WHEN idstrspr = '1' THEN 1 END ) AS s_1, "
   _qry += "  SUM( CASE WHEN idstrspr = '2' THEN 1 END ) AS s_2, "
   _qry += "  SUM( CASE WHEN idstrspr = '3' THEN 1 END ) AS s_3, "
   _qry += "  SUM( CASE WHEN idstrspr = '4' THEN 1 END ) AS s_4, "
   _qry += "  SUM( CASE WHEN idstrspr = '5' THEN 1 END ) AS s_5, "
   _qry += "  SUM( CASE WHEN idstrspr = '6' THEN 1 END ) AS s_6, "
   _qry += "  SUM( CASE WHEN idstrspr = '7' THEN 1 END ) AS s_7, "
   _qry += "  SUM( CASE WHEN idstrspr = '8' THEN 1 END ) AS s_8, "
   _qry += "  SUM( CASE WHEN idstrspr = '9' THEN 1 END ) AS s_9, "
   _qry += "  SUM( CASE WHEN idstrspr = '000' THEN 1 END ) AS s_o "
   _qry += " FROM tmp "
   _qry += " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_rj rj ON tmp.idrj = rj.id "
   _qry += " GROUP BY idrj, rj.naz "
   _qry += " ORDER BY idrj "

   MsgO( "Formiram podatke izvjestaja ..." )
   _data := run_sql_query( _qry )
   MsgC()

   IF ValType( _data ) == "L"
      RETURN NIL
   ENDIF

   _data:GoTo( 1 )

   RETURN _data



// -----------------------------------------------------
// -----------------------------------------------------
STATIC FUNCTION _cre_xml( params )

   LOCAL _data, oRow
   LOCAL _ok := .F.
   LOCAL _count := 0
   LOCAL _tmp, _jmbg
   LOCAL _total := 0
   LOCAL _sprema := 0
   LOCAL _sp_1 := _sp_2 := _sp_3 := _sp_4 := _sp_5 := _sp_6 := _sp_7 := _sp_8 := _sp_9 := _sp_o := 0

   // uzmi podatke za izvjestaj....
   _data := _get_data( params )

   IF _data == NIL
      RETURN _ok
   ENDIF

   open_xml( __xml_file )
   xml_head()

   xml_subnode( "rpt", .F. )

   // header ...
   xml_node( "f_id", to_xml_encoding( gFirma ) )
   xml_node( "f_naz", to_xml_encoding( gNFirma ) )

   xml_node( "dat_od", DToC( params[ "datum_od" ] ) )
   xml_node( "dat_do", DToC( params[ "datum_do" ] ) )
   xml_node( "datum", DToC( Date() ) )

   DO WHILE !_data:Eof()

      _total := 0

      oRow := _data:GetRow()

      xml_subnode( "item", .F. )

      xml_node( "no", AllTrim( Str( ++_count ) ) )
      xml_node( "idrj", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idrj" ) ) ) ) )
      xml_node( "rj", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "naz" ) ) ) ) )

      // spreme
      _sprema := oRow:FieldGet( oRow:FieldPos( "s_1" ) )
      xml_node( "s_1", AllTrim( Str( _sprema ) ) )
      _sp_1 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_2" ) )
      xml_node( "s_2", AllTrim( Str( _sprema ) ) )
      _sp_2 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_3" ) )
      xml_node( "s_3", AllTrim( Str( _sprema ) ) )
      _sp_3 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_4" ) )
      xml_node( "s_4", AllTrim( Str( _sprema ) ) )
      _sp_4 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_5" ) )
      xml_node( "s_5", AllTrim( Str( _sprema ) ) )
      _sp_5 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_6" ) )
      xml_node( "s_6", AllTrim( Str( _sprema ) ) )
      _sp_6 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_7" ) )
      xml_node( "s_7", AllTrim( Str( _sprema ) ) )
      _sp_7 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_8" ) )
      xml_node( "s_8", AllTrim( Str( _sprema ) ) )
      _sp_8 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_9" ) )
      xml_node( "s_9", AllTrim( Str( _sprema ) ) )
      _sp_9 += _sprema
      _total += _sprema

      _sprema := oRow:FieldGet( oRow:FieldPos( "s_o" ) )
      xml_node( "s_o", AllTrim( Str( _sprema ) ) )
      _sp_o += _sprema
      _total += _sprema

      xml_node( "tot", AllTrim( Str( _total ) ) )

      xml_subnode( "item", .T. )

      _ok := .T.
      _data:SKIP()

   ENDDO

   xml_node( "s_1", AllTrim( Str( _sp_1 ) ) )
   xml_node( "s_2", AllTrim( Str( _sp_2 ) ) )
   xml_node( "s_3", AllTrim( Str( _sp_3 ) ) )
   xml_node( "s_4", AllTrim( Str( _sp_4 ) ) )
   xml_node( "s_5", AllTrim( Str( _sp_5 ) ) )
   xml_node( "s_6", AllTrim( Str( _sp_6 ) ) )
   xml_node( "s_7", AllTrim( Str( _sp_7 ) ) )
   xml_node( "s_8", AllTrim( Str( _sp_8 ) ) )
   xml_node( "s_9", AllTrim( Str( _sp_9 ) ) )
   xml_node( "s_o", AllTrim( Str( _sp_o ) ) )
   xml_node( "tot", AllTrim( Str( _sp_1 + _sp_2 + _sp_3 + _sp_4 + _sp_5 + _sp_6 + _sp_7 + _sp_8 + _sp_9 + _sp_o ) ) )

   xml_subnode( "rpt", .T. )

   close_xml()

   RETURN _ok
