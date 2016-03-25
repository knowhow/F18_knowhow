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


FUNCTION ld_kred_specifikacija()

   LOCAL _params := hb_Hash()
   LOCAL _data

   IF !_get_vars( @_params )
      RETURN
   ENDIF

   _data := _get_data( _params )

   IF _data:LastRec() == 0
      RETURN
   ENDIF

   _print_data( _data, _params )

   RETURN



STATIC FUNCTION _get_data( params )

   LOCAL _data := {}
   LOCAL _qry
   LOCAL _where
   LOCAL _order
   LOCAL _server := my_server()

   _where := " lk.godina = " + AllTrim( Str( params[ "godina" ] ) )
   _where += " AND lk.mjesec = " + AllTrim( Str( params[ "mjesec" ] ) )

   IF !Empty( params[ "kreditor" ] )
      _where += " AND lk.idkred = " + sql_quote( params[ "kreditor" ] )
   ENDIF

   IF !Empty( params[ "radnik" ] )
      _where += " AND lk.idradn = " + sql_quote( params[ "radnik" ] )
   ENDIF

   IF !Empty( params[ "osnova" ] )
      _where += " AND " + _sql_cond_parse( "lk.naosnovu", params[ "osnova" ] )
   ENDIF

   IF !Empty( params[ "rj" ] )
      _where += " AND " + _sql_cond_parse( "ld.idrj", params[ "rj" ] )
   ENDIF

   _order := " lk.idkred, lk.idradn, lk.naosnovu "

   _qry := "SELECT " + ;
      " lk.idradn, " + ;
      " rd.naz AS radn_prezime, " + ;
      " rd.ime AS radn_ime, " + ;
      " rd.imerod AS radn_imerod, " + ;
      " lk.idkred, " + ;
      " kr.naz AS kred_naz, " + ;
      " lk.naosnovu, " + ;
      " lk.placeno AS iznos_rate, " + ;
      " ld.idrj AS rj, " + ;
      " ( SELECT COUNT(iznos) FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu) AS kredit_rate_ukupno, " + ;
      " ( SELECT COUNT(placeno) FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu AND placeno <> 0 ) AS kredit_rate_uplaceno, " + ;
      " ( SELECT SUM(iznos) FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu) AS kredit_ukupno, " + ;
      " ( SELECT SUM(iznos) FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr WHERE idradn = lk.idradn AND idkred = lk.idkred AND naosnovu = lk.naosnovu AND placeno <> 0) AS kredit_uplaceno " + ;
      " FROM " + F18_PSQL_SCHEMA_DOT + "ld_radkr lk " + ;
      " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " ld_ld ld ON lk.idradn = ld.idradn AND ld.mjesec = " + AllTrim( Str( params[ "mjesec" ] ) ) + " AND ld.godina = " + AllTrim( Str( params[ "godina" ] ) ) + ;
      " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " ld_radn rd ON lk.idradn = rd.id " + ;
      " LEFT JOIN " + F18_PSQL_SCHEMA_DOT + " kred kr ON lk.idkred = kr.id " + ;
      " WHERE " + _where + ;
      " ORDER BY " + _order

   MsgO( "formiranje sql upita u toku ..." )
   _data := _sql_query( _server, _qry )
   MsgC()

   IF _data == NIL
      RETURN NIL
   ENDIF

   _data:GoTo( 1 )

   RETURN _data


STATIC FUNCTION _get_vars( params )

   LOCAL _ok := .F.
   LOCAL _x := 1
   LOCAL _godina, _mjesec
   LOCAL _id_radn, _id_kred, _sort, _rj
   LOCAL _osnova := Space( 200 )

   _godina := fetch_metric( "ld_kred_spec_godina", my_user(), 2013 )
   _mjesec := fetch_metric( "ld_kred_spec_mjesec", my_user(), 1 )
   _id_radn := fetch_metric( "ld_kred_spec_radnik", my_user(), Space( 6 ) )
   _id_kred := fetch_metric( "ld_kred_spec_kreditor", my_user(), Space( 6 ) )
   _sort := fetch_metric( "ld_kred_spec_sort", my_user(), 2 )
   _rj := fetch_metric( "ld_kred_spec_rj", my_user(), Space( 200 ) )

   Box(, 15, 60 )

   @ m_x + _x, m_y + 2 SAY "Godina" GET _godina PICT "9999"
   @ m_x + _x, Col() + 1 SAY "mjesec" GET _mjesec PICT "99"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Radnik (prazno-svi):" GET _id_radn VALID Empty( _id_radn ) .OR. P_Radn( @_id_radn )

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Kreditor (prazno-svi):" GET _id_kred VALID Empty( _id_kred ) .OR. P_Kred( @_id_kred )

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "   Filter po osnovi kredita:" GET _osnova PICT "@S30"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Filter po radnim jedinicama:" GET _rj PICT "@S30"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   set_metric( "ld_kred_spec_godina", my_user(), _godina )
   set_metric( "ld_kred_spec_mjesec", my_user(), _mjesec )
   set_metric( "ld_kred_spec_radnik", my_user(), _id_radn )
   set_metric( "ld_kred_spec_kreditor", my_user(), _id_kred )
   set_metric( "ld_kred_spec_sort", my_user(), _sort )
   set_metric( "ld_kred_spec_rj", my_user(), _rj )

   IF !Empty( _osnova )
      _osnova := AllTrim( _osnova ) + " "
   ENDIF

   IF !Empty( _rj )
      _rj := AllTrim( _rj ) + " "
   ENDIF

   params[ "godina" ] := _godina
   params[ "mjesec" ] := _mjesec
   params[ "kreditor" ] := _id_kred
   params[ "radnik" ] := _id_radn
   params[ "tip_sorta" ] := _sort
   params[ "osnova" ] := _osnova
   params[ "rj" ] := _rj

   _ok := .T.

   RETURN _ok


STATIC FUNCTION _print_data( data, params )

   LOCAL _template := "kred_spec.odt"

   _cre_xml( data, params )

   IF generisi_odt_iz_xml( _template )
      prikazi_odt()
   ENDIF

   RETURN

STATIC FUNCTION _cre_xml( data, params )

   LOCAL oRow
   LOCAL _xml_file := my_home() + "data.xml"
   LOCAL _id_kred
   LOCAL _sort := params[ "tip_sorta" ]
   LOCAL _t_rata_iznos := 0
   LOCAL _t_rata_ukupno := 0
   LOCAL _t_rata_uplaceno := 0
   LOCAL _t_kred_ukupno := 0
   LOCAL _t_kred_uplaceno := 0
   LOCAL _t_ostatak := 0

   open_xml( _xml_file )
   xml_head()

   xml_subnode( "spec", .F. )

   xml_node( "firma", to_xml_encoding( gNFirma ) )
   xml_node( "godina", Str( params[ "godina" ] ) )
   xml_node( "mjesec", Str( params[ "mjesec" ] ) )
   xml_node( "kreditor", to_xml_encoding( params[ "kreditor" ] ) )
   xml_node( "radnik", to_xml_encoding( params[ "radnik" ] ) )

   data:GoTo( 1 )

   DO WHILE !data:Eof()

      oRow := data:GetRow()

      _id_kred := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idkred" ) ) )
      _id_radn := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "idradn" ) ) )

      xml_subnode( "kred", .F. )

      xml_node( "k_naz", to_xml_encoding( hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "kred_naz" ) ) ) ) )
      xml_node( "k_id", to_xml_encoding( _id_kred ) )

      _t_rata_iznos := 0
      _t_rata_ukupno := 0
      _t_rata_uplaceno := 0
      _t_kred_ukupno := 0
      _t_kred_uplaceno := 0
      _t_ostatak := 0

      DO WHILE !data:Eof() .AND. _id_kred == hb_UTF8ToStr( data:FieldGet( data:FieldPos( "idkred" ) ) )

         oRow2 := data:GetRow()

         xml_subnode( "data", .F. )

         xml_node( "r_id", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "idradn" ) ) ) ) )
         xml_node( "r_prez", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "radn_prezime" ) ) ) ) )
         xml_node( "r_ime", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "radn_ime" ) ) ) ) )
         xml_node( "r_imerod", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "radn_imerod" ) ) ) ) )
         xml_node( "k_id", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "idkred" ) ) ) ) )
         xml_node( "k_naz", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "kred_naz" ) ) ) ) )
         xml_node( "osn", to_xml_encoding( hb_UTF8ToStr( oRow2:FieldGet( oRow2:FieldPos( "naosnovu" ) ) ) ) )
         xml_node( "rata_i", AllTrim( Str( oRow2:FieldGet( oRow2:FieldPos( "iznos_rate" ) ), 12, 2 ) ) )
         xml_node( "rata_uk", AllTrim( Str( oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_ukupno" ) ), 12, 0 ) ) )
         xml_node( "rata_up", AllTrim( Str( oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_uplaceno" ) ), 12, 0 ) ) )
         xml_node( "kred_uk", AllTrim( Str( oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) ), 12, 2 ) ) )
         xml_node( "kred_up", AllTrim( Str( oRow2:FieldGet( oRow2:FieldPos( "kredit_uplaceno" ) ), 12, 2 ) ) )
         xml_node( "ostatak", AllTrim( Str( oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) ) - ;
            oRow2:FieldGet( oRow:FieldPos( "kredit_uplaceno" ) ), 12, 2 ) ) )

         _t_rata_iznos += oRow2:FieldGet( oRow2:FieldPos( "iznos_rate" ) )
         _t_rata_ukupno += oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_ukupno" ) )
         _t_rata_uplaceno += oRow2:FieldGet( oRow2:FieldPos( "kredit_rate_uplaceno" ) )
         _t_kred_ukupno += oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) )
         _t_kred_uplaceno += oRow2:FieldGet( oRow2:FieldPos( "kredit_uplaceno" ) )
         _t_ostatak += oRow2:FieldGet( oRow2:FieldPos( "kredit_ukupno" ) ) - ;
            oRow2:FieldGet( oRow2:FieldPos( "kredit_uplaceno" ) )

         xml_subnode( "data", .T. )

         data:Skip()

      ENDDO

      xml_node( "rata_i", AllTrim( Str( _t_rata_iznos, 12, 2 ) ) )
      xml_node( "rata_uk", AllTrim( Str( _t_rata_ukupno, 12, 2 ) ) )
      xml_node( "rata_up", AllTrim( Str( _t_rata_uplaceno, 12, 2 ) ) )
      xml_node( "kred_uk", AllTrim( Str( _t_kred_ukupno, 12, 2 ) ) )
      xml_node( "kred_up", AllTrim( Str( _t_kred_uplaceno, 12, 2 ) ) )
      xml_node( "ostatak", AllTrim( Str( _t_ostatak, 12, 2 ) ) )

      xml_subnode( "kred", .T. )

   ENDDO

   xml_subnode( "spec", .T. )

   close_xml()

   RETURN
