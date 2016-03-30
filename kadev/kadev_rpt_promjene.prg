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



FUNCTION kadev_izvjestaj_promjene()

   LOCAL _params

   __template := "kadev_promjene.odt"
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
   LOCAL _datum_od := fetch_metric( "kadev_rpt_prom_datum_od", my_user(), CToD( "" ) )
   LOCAL _datum_do := fetch_metric( "kadev_rpt_prom_datum_do", my_user(), Date() )
   LOCAL _promjene := PadR( fetch_metric( "kadev_rpt_prom_promjene", my_user(), "P1;P2;" ), 200 )
   LOCAL _rj := PadR( fetch_metric( "kadev_rpt_prom_rj", my_user(), "" ), 100 )
   LOCAL _rmj := PadR( fetch_metric( "kadev_rpt_prom_rmj", my_user(), "" ), 100 )
   LOCAL _strspr := PadR( fetch_metric( "kadev_rpt_prom_strspr", my_user(), "" ), 100 )
   LOCAL _spol := " "

   SET CENTURY ON

   Box(, 10, 65 )

   @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _datum_od
   @ m_x + 1, Col() + 1 SAY "do:" GET _datum_do

   @ m_x + 3, m_y + 2 SAY "PROMJENE:" GET _promjene VALID !Empty( _promjene ) PICT "@S40"

   @ m_x + 5, m_y + 2 SAY "Radne jedinice (prazno-sve):" GET _rj PICT "@S30"
   @ m_x + 6, m_y + 2 SAY "  Radna mjesta (prazno-sve):" GET _rmj PICT "@S30"
   @ m_x + 7, m_y + 2 SAY "Strucne spreme (prazno-sve):" GET _strspr PICT "@S30"

   @ m_x + 9, m_y + 2 SAY "Spol ( /M/Z):" GET _spol VALID _spol $ " MZ" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   set_metric( "kadev_rpt_prom_datum_od", my_user(), _datum_od )
   set_metric( "kadev_rpt_prom_datum_do", my_user(), _datum_do )
   set_metric( "kadev_rpt_prom_promjene", my_user(), AllTrim( _promjene ) )
   set_metric( "kadev_rpt_prom_rj", my_user(), AllTrim( _rj ) )
   set_metric( "kadev_rpt_prom_rmj", my_user(), AllTrim( _rmj ) )
   set_metric( "kadev_rpt_prom_strspr", my_user(), AllTrim( _strspr ) )

   params := hb_Hash()
   params[ "datum_od" ] := _datum_od
   params[ "datum_do" ] := _datum_do
   params[ "promjene" ] := _promjene
   params[ "rj" ] := _rj
   params[ "rmj" ] := _rmj
   params[ "strspr" ] := _strspr
   params[ "spol" ] := _spol

   _ok := .T.

   RETURN _ok


// -----------------------------------------------------
// -----------------------------------------------------
STATIC FUNCTION _get_data( param )

   LOCAL _data, _qry
   LOCAL _where := ""

   IF !Empty( PARAM[ "datum_od" ] ) .OR. !Empty( PARAM[ "datum_do" ] )
      _where += _sql_date_parse( "pr.datumod", PARAM[ "datum_od" ], PARAM[ "datum_do" ] )
   ENDIF

   IF !Empty( PARAM[ "promjene" ] )
      _where += " AND ( " + _sql_cond_parse( "pr.idpromj", PARAM[ "promjene" ] ) + " ) "
   ENDIF

   IF !Empty( PARAM[ "strspr" ] )
      _where += " AND ( "  + _sql_cond_parse( "main.idstrspr", PARAM[ "strspr" ] ) + " ) "
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

   _qry := "SELECT "
   _qry += "  pr.id AS jmbg, "
   _qry += "  main.ime || ' (' || main.imerod || ') ' || main.prezime AS radnik, "
   _qry += "  pr.idpromj AS idpromj , "
   _qry += "  pr.datumod AS datum, "
   _qry += "  main.idrj AS rj, "
   _qry += "  rj.naz AS rj_naz, "
   _qry += "  main.idrmj AS rmj, "
   _qry += "  rmj.naz AS rmj_naz, "
   _qry += "  main.idstrspr AS strspr, "
   _qry += "  ben.naz AS kben_naz, "
   _qry += "  ben.iznos AS kben_iznos, "
   _qry += "  ss.naz2 AS strspr_naz "
   _qry += "FROM " + F18_PSQL_SCHEMA_DOT + "kadev_1 pr "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_0 main ON pr.id = main.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_promj prom ON pr.idpromj = prom.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_rj rj ON main.idrj = rj.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_rmj rmj ON main.idrmj = rmj.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + "kadev_rjrmj rjrmj ON main.idrmj = rjrmj.idrmj AND main.idrj = rjrmj.idrj "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " kbenef ben ON rjrmj.sbenefrst = ben.id "
   _qry += "LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " strspr ss ON main.idstrspr = ss.id "
   _qry += " " + _where + " "
   _qry += "ORDER BY pr.id, pr.datumod"

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
   xml_node( "promjene", to_xml_encoding( params[ "promjene" ] ) )
   xml_node( "strspr", to_xml_encoding( params[ "strspr" ] ) )

   _tmp := "XXX"

   DO WHILE !_data:Eof()

      oRow := _data:GetRow()

      _jmbg := oRow:FieldGet( oRow:FieldPos( "jmbg" ) )

      xml_subnode( "item", .F. )

      IF _jmbg <> _tmp
         xml_node( "no", AllTrim( Str( ++_count ) ) )
         xml_node( "jmbg", to_xml_encoding( _jmbg ) )
         xml_node( "radn", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "radnik" ) ) ) ) )
      ELSE
         xml_node( "no", "" )
         xml_node( "jmbg", "" )
         xml_node( "radn", "" )
      ENDIF

      xml_node( "rj", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "rj_naz" ) ) ) ) )
      xml_node( "strspr", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "strspr_naz" ) ) ) ) )
      xml_node( "datum", DToC( oRow:FieldGet( oRow:FieldPos( "datum" ) ) ) )
      xml_node( "rmj", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "rmj_naz" ) ) ) ) )
      xml_node( "b_st", Str( oRow:FieldGet( oRow:FieldPos( "kben_iznos" ) ) ) )
      xml_node( "b_naz", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "kben_naz" ) ) ) ) )

      xml_subnode( "item", .T. )

      _tmp := _jmbg

      _ok := .T.
      _data:SKIP()

   ENDDO

   xml_subnode( "rpt", .T. )

   close_xml()

   RETURN _ok
