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



FUNCTION kadev_izvjestaj_staz()

   LOCAL _params

   __template := "kadev_staz.odt"
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
   LOCAL _datum_od := fetch_metric( "kadev_rpt_staz_datum_od", my_user(), CToD( "" ) )
   LOCAL _datum_do := fetch_metric( "kadev_rpt_staz_datum_do", my_user(), Date() )
   LOCAL _rj := PadR( fetch_metric( "kadev_rpt_staz_rj", my_user(), "" ), 100 )
   LOCAL _rmj := PadR( fetch_metric( "kadev_rpt_staz_rmj", my_user(), "" ), 100 )
   LOCAL _strspr := PadR( fetch_metric( "kadev_rpt_staz_strspr", my_user(), "" ), 100 )
   LOCAL _spol := " "

   SET CENTURY ON

   Box(, 8, 65 )

   @ m_x + 1, m_y + 2 SAY "Za datum od:" GET _datum_od
   @ m_x + 1, Col() + 1 SAY "do:" GET _datum_do

   @ m_x + 3, m_y + 2 SAY "Radne jedinice (prazno-sve):" GET _rj PICT "@S30"
   @ m_x + 4, m_y + 2 SAY "  Radna mjesta (prazno-sve):" GET _rmj PICT "@S30"
   @ m_x + 5, m_y + 2 SAY "Strucne spreme (prazno-sve):" GET _strspr PICT "@S30"

   @ m_x + 7, m_y + 2 SAY "Spol ( /M/Z):" GET _spol VALID _spol $ " MZ" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   set_metric( "kadev_rpt_staz_datum_od", my_user(), _datum_od )
   set_metric( "kadev_rpt_staz_datum_do", my_user(), _datum_do )
   set_metric( "kadev_rpt_staz_rj", my_user(), AllTrim( _rj ) )
   set_metric( "kadev_rpt_staz_rmj", my_user(), AllTrim( _rmj ) )
   set_metric( "kadev_rpt_staz_strspr", my_user(), AllTrim( _strspr ) )

   params := hb_Hash()
   params[ "datum_od" ] := _datum_od
   params[ "datum_do" ] := _datum_do
   params[ "rj" ] := _rj
   params[ "rmj" ] := _rmj
   params[ "strspr" ] := _strspr
   params[ "spol" ] := _spol

   _ok := .T.

   RETURN _ok


// -----------------------------------------------------
// -----------------------------------------------------
STATIC FUNCTION _get_data( param )

   LOCAL _data, _qry, oRow, oDATA
   LOCAL _where := ""
   LOCAL _a_data := {}
   LOCAL _params

   IF !Empty( PARAM[ "datum_od" ] ) .OR. !Empty( PARAM[ "datum_do" ] )
      _where += _sql_date_parse( "pr.datumod", PARAM[ "datum_od" ], PARAM[ "datum_do" ] )
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
      _where += " AND main.pol = " + _sql_quote( PARAM[ "spol" ] )
   ENDIF

   // sredi WHERE upit na kraju...
   IF !Empty( _where )
      _where := "WHERE " + _where
   ENDIF

   _qry := "SELECT "
   _qry += "  pr.id AS jmbg, "
   _qry += "  main.ime || ' (' || main.imerod || ') ' || main.prezime AS radnik, "
   _qry += "  main.idrj AS rj, "
   _qry += "  rj.naz AS rj_naz, "
   _qry += "  main.idrmj AS rmj, "
   _qry += "  rmj.naz AS rmj_naz, "
   _qry += "  main.idstrspr AS strspr, "
   _qry += "  ss.naz2 AS strspr_naz "
   _qry += "FROM fmk.kadev_1 pr "
   _qry += "LEFT JOIN fmk.kadev_0 main ON pr.id = main.id "
   _qry += "LEFT JOIN fmk.kadev_rj rj ON main.idrj = rj.id "
   _qry += "LEFT JOIN fmk.kadev_rmj rmj ON main.idrmj = rmj.id "
   _qry += "LEFT JOIN fmk.strspr ss ON main.idstrspr = ss.id "
   _qry += " " + _where + " "
   _qry += "GROUP BY pr.id, main.ime, main.prezime, "
   _qry += "  main.imerod, rj.naz, main.idrmj, rmj.naz, main.idrj, rj.naz, main.idstrspr, ss.naz2 "
   _qry += "ORDER BY pr.id "

   MsgO( "Formiram podatke izvjestaja ..." )
   _data := _sql_query( my_server(), _qry )
   MsgC()

   IF ValType( _data ) == "L"
      RETURN NIL
   ENDIF

   _data:GoTo( 1 )

   MsgO( "Kalkulisem staz po zadatim parametrima ..." )

   DO WHILE !_data:Eof()

      oRow := _data:GetRow()

      _params := hb_Hash()
      _params[ "jmbg" ] := oRow:FieldGet( oRow:FieldPos( "jmbg" ) )
      _params[ "datum_od" ] := PARAM[ "datum_od" ]
      _params[ "datum_do" ] := PARAM[ "datum_do" ]

      oDATA := KADEV_DATA_CALC():new()
      oDATA:params := _params
      oDATA:data_selection()
      oDATA:get_radni_staz()

      _rst_ef := oDATA:radni_staz[ "rst_ef_info" ]
      _rst_ben := oDATA:radni_staz[ "rst_ben_info" ]
      _rst_uk := oDATA:radni_staz[ "rst_uk_info" ]

      AAdd( _a_data, { oRow:FieldGet( oRow:FieldPos( "jmbg" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "radnik" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "rj_naz" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "rmj_naz" ) ), ;
         oRow:FieldGet( oRow:FieldPos( "strspr_naz" ) ), ;
         _rst_ef, ;
         _rst_ben, ;
         _rst_uk } )

      _data:SKIP()

   ENDDO

   MsgC()

   RETURN _a_data



// -----------------------------------------------------
// -----------------------------------------------------
STATIC FUNCTION _cre_xml( params )

   LOCAL _a_data, oRow
   LOCAL _ok := .F.
   LOCAL _count := 0
   LOCAL _tmp, _jmbg, _i

   // uzmi podatke za izvjestaj....
   _a_data := _get_data( params )

   IF _a_data == NIL
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
   xml_node( "strspr", to_xml_encoding( params[ "strspr" ] ) )

   FOR _i := 1 TO Len( _a_data )

      _jmbg := _a_data[ _i, 1 ]

      xml_subnode( "item", .F. )

      xml_node( "no", AllTrim( Str( ++_count ) ) )
      xml_node( "jmbg", to_xml_encoding( _jmbg ) )
      xml_node( "radn", to_xml_encoding( hb_UTF8ToStr( _a_data[ _i, 2 ] ) ) )

      xml_node( "rj", to_xml_encoding( hb_UTF8ToStr( _a_data[ _i, 3 ] ) ) )
      xml_node( "rmj", to_xml_encoding( hb_UTF8ToStr( _a_data[ _i, 4 ] ) ) )
      xml_node( "strspr", to_xml_encoding( hb_UTF8ToStr( _a_data[ _i, 5 ] ) ) )

      xml_node( "ef", to_xml_encoding( _a_data[ _i, 6 ] ) )
      xml_node( "ben", to_xml_encoding( _a_data[ _i, 7 ] ) )
      xml_node( "uk", to_xml_encoding( _a_data[ _i, 8 ] ) )

      xml_subnode( "item", .T. )

      _ok := .T.

   NEXT

   xml_subnode( "rpt", .T. )

   close_xml()

   RETURN _ok
