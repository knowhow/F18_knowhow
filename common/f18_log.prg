/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION f18_view_log( _params )

   LOCAL _data
   LOCAL _print_to_file := .F.
   LOCAL cLogFile

   IF PCount() > 0
      _print_to_file := .T.
   ENDIF

   IF _params == NIL .AND. !uslovi_pregleda_loga( @_params )
      RETURN .F.
   ENDIF

   _data := query_log_data( _params )
   cLogFile := print_log_data( _data, _params, _print_to_file )

   RETURN cLogFile




STATIC FUNCTION uslovi_pregleda_loga( params )

   LOCAL _ok := .F.
   LOCAL _limit := 0
   LOCAL _datum_od := Date()
   LOCAL _datum_do := Date()
   LOCAL _user := PadR( f18_user(), 200 )
   LOCAL _x := 1
   LOCAL _conds_true := Space( 600 )
   LOCAL _conds_false := Space( 600 )
   LOCAL _f18_doc_oper := "N"

   Box(, 12, 70 )

   @ m_x + _x, m_y + 2 SAY "Uslovi za pregled log-a..."

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Datum od" GET _datum_od
   @ m_x + _x, Col() + 1 SAY "do" GET _datum_do

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Korisnik (prazno svi):" GET _user PICT "@S40"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "LIKE uslovi:"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "  sadrži:" GET _conds_true PICT "@S40"

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "nesadrži:" GET _conds_false PICT "@S40"

   ++ _x
   ++ _x
   @ m_x + _x, m_y + 2 SAY "Pregledaj samo operacije nad dokumentima (D/N)?" GET _f18_doc_oper VALID _f18_doc_oper $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Limit na broj zapisa (0-bez limita)" GET _limit PICT "999999"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   _ok := .T.

   IF !Empty( _conds_true )
      _conds_true := AllTrim( _conds_true ) + Space( 1 )
   ELSE
      _conds_true := ""
   ENDIF

   IF !Empty( _conds_false )
      _conds_false := AllTrim( _conds_false ) + Space( 1 )
   ELSE
      _conds_false := ""
   ENDIF

   params := hb_Hash()
   params[ "date_from" ] := _datum_od
   params[ "date_to" ] := _datum_do
   params[ "user" ] := AllTrim( _user )
   params[ "limit" ] := _limit
   params[ "conds_true" ] := _conds_true
   params[ "conds_false" ] := _conds_false
   params[ "doc_oper" ] := _f18_doc_oper

   RETURN _ok


STATIC FUNCTION query_log_data( params )

   LOCAL _user := ""
   LOCAL _dat_from := params[ "date_from" ]
   LOCAL _dat_to := params[ "date_to" ]
   LOCAL _limit := params[ "limit" ]
   LOCAL _conds_true := params[ "conds_true" ]
   LOCAL _conds_false := params[ "conds_false" ]
   LOCAL _is_doc_oper := params[ "doc_oper" ] == "D"
   LOCAL _qry, _where
   LOCAL _server := pg_server()
   LOCAL _data

   IF hb_HHasKey( params, "user" )
      _user := params[ "user" ]
   ENDIF

   _where := _sql_date_parse( "l_time", _dat_from, _dat_to )

   IF !Empty( _user )
      _where += " AND " + _sql_cond_parse( "user_code", _user )
   ENDIF

   IF !Empty( _conds_true )
      _where += " AND (" + _sql_cond_parse( "msg", _conds_true ) + ")"
   ENDIF

   IF !Empty( _conds_false )
      _where += " AND (" + _sql_cond_parse( "msg", _conds_false, .T. ) + ")"
   ENDIF

   IF _is_doc_oper
      _where += " AND ( msg LIKE '%F18_DOK_OPER%' ) "
   ENDIF

   _qry := "SELECT id, user_code, l_time, msg "
   _qry += "FROM fmk.log "
   _qry += "WHERE " + _where
   _qry += " ORDER BY l_time DESC "
   IF _limit > 0
      _qry += " LIMIT " + AllTrim( Str( _limit ) )
   ENDIF

   info_bar( "log_get_data", "qry:" + _qry )
   _data := _sql_query( _server, _qry )

   IF !is_var_objekat_tpquery( _data )
      RETURN NIL
   ENDIF

   RETURN _data


STATIC FUNCTION print_log_data( data, params, print_to_file )

   LOCAL _row
   LOCAL _user, _txt, _date
   LOCAL _a_txt, _tmp, _i, _pos_y
   LOCAL _txt_len := 100
   LOCAL _log_file := DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + "_log.txt"
   LOCAL _log_path := my_home_root()

   IF data == NIL .OR. data:LastRec() == 0
      IF !print_to_file
         MsgBeep( "Za zadati uslov ne postoje podaci u log-u !" )
      ENDIF
      RETURN .F.
   ENDIF

   IF !is_in_main_thread() .OR. print_to_file
      f18_start_print( _log_path + _log_file, "D" )
   ELSE
      START PRINT CRET
   ENDIF

   ?
   P_COND

   ? "PREGLED LOG-a"
   ? Replicate( "-", 130 )
   ? PadR( "Datum / vrijeme", 19 ), PadR( "Korisnik", 10 ), "operacija"
   ? Replicate( "-", 130 )

   DO WHILE !data:Eof()

      _row := data:GetRow()

      _date := data:FieldGet( data:FieldPos( "l_time" ) )
      _user := hb_UTF8ToStr( data:FieldGet( data:FieldPos( "user_code" ) ) )
      _txt := hb_UTF8ToStr( data:FieldGet( data:FieldPos( "msg" ) ) )

      ?
      @ PRow(), PCol() + 1 SAY PadR( _date, 19 )
      @ PRow(), _pos_y := PCol() + 1 SAY PadR( _user, 10 )

      _a_txt := SjeciStr( _txt, _txt_len )

      FOR _i := 1 TO Len( _a_txt )
         IF _i > 1
            ?
            @ PRow(), _pos_y SAY Pad( _a_txt[ _i ], _txt_len )
         ELSE
            @ PRow(), _pos_y := PCol() + 1 SAY PadR( _a_txt[ _i ], _txt_len )
         ENDIF
      NEXT

      data:Skip()

   ENDDO

   IF !is_in_main_thread() .OR. print_to_file
      f18_end_print( _log_path + _log_file, "D" )
   ELSE
      FF
      ENDPRINT
   ENDIF

   RETURN _log_file


FUNCTION f18_log_delete()

   LOCAL _params := hb_Hash()
   LOCAL _curr_log_date := Date()
   LOCAL _last_log_date := fetch_metric( "log_last_delete_date", NIL, CToD( "" ) )
   LOCAL _delete_log_level := fetch_metric( "log_delete_level", NIL, 30 )

   info_bar( "init", "f18_log_delete - start" )

   IF _delete_log_level == 0
      RETURN .F.
   ENDIF

   IF ( _curr_log_date - _delete_log_level ) > _last_log_date

      _params[ "delete_level" ] := _delete_log_level
      _params[ "current_date" ] := _curr_log_date

      IF sql_log_delete( _params )
         set_metric( "log_last_delete_date", NIL,  _curr_log_date )
      ENDIF

   ENDIF
   info_bar( "init", "f18_log_delete - stop" )

   RETURN .T.


STATIC FUNCTION sql_log_delete( params )

   LOCAL _ok := .T.
   LOCAL _qry, _where
   LOCAL _server := pg_server()
   LOCAL _result
   LOCAL _dok_oper := "%F18_DOK_OPER%"
   LOCAL _delete_level := params[ "delete_level" ]
   LOCAL _curr_date := params[ "current_date" ]
   LOCAL _delete_date := ( _curr_date - _delete_level )

   _where := "( l_time::char(8) <= " + sql_quote( _delete_date )
   _where += " AND msg NOT LIKE " + sql_quote( _dok_oper ) + " ) "
   _where += " OR "
   _where += "( EXTRACT( YEAR FROM l_time ) < EXTRACT( YEAR FROM CURRENT_DATE ) "
   _where += " AND "
   _where += " msg LIKE " + sql_quote( _dok_oper ) + " ) "

   _qry := "DELETE FROM fmk.log "
   _qry += "WHERE " + _where

   _result := _sql_query( _server, _qry )

   IF ValType( _result ) == "L"
      _ok := .F.
   ENDIF

   RETURN _ok
