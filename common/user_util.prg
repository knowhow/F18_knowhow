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


FUNCTION f18_get_user_id()

   LOCAL cTmpQry
   LOCAL cTable := "public.usr" // view
   LOCAL oTable
   LOCAL nResult
   LOCAL cUser   := AllTrim( my_user() )

   cTmpQry := "SELECT usr_id FROM " + cTable + " WHERE usr_username = " + sql_quote( cUser )
   oTable := run_sql_query( cTmpQry )

   IF sql_error_in_query( oTable, "SELECT" )
      RETURN 0
   ENDIF

   RETURN oTable:FieldGet( 1 )




FUNCTION GetUserRoles( user_name )

   LOCAL _roles
   LOCAL cQuery

   IF user_name == NIL
      _user := "CURRENT_USER"
   ENDIF

   cQuery := "SELECT " + ;
      " rolname " + ;
      "FROM pg_user " + ;
      "JOIN pg_auth_members ON pg_user.usesysid = pg_auth_members.member " + ;
      "JOIN pg_roles ON pg_roles.oid = pg_auth_members.roleid " + ;
      "WHERE pg_user.usename = " + _user + " " + ;
      "ORDER BY rolname ;"

   _roles := run_sql_query( cQuery )

   IF sql_error_in_query( _roles, "SELECT" )
      RETURN NIL
   ENDIF

   RETURN _roles


FUNCTION f18_user_roles_info()

   LOCAL oRow
   LOCAL _info := ""
   LOCAL _roles := GetUserRoles()

   IF _roles == NIL
      RETURN _info
   ENDIF

   _roles:GoTo( 1 )

   DO WHILE !_roles:Eof()

      oRow := _roles:GetRow()
      _info += hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "rolname" ) ) ) + ", "

      _roles:Skip()

   ENDDO

   _info := PadR( _info, Len( _info ) - 2 )
   _info := "[" + _info + "]"

   RETURN _info



FUNCTION GetUserName( nUser_id )

   LOCAL cTmpQry
   LOCAL cTable := "public.usr"
   LOCAL oTable
   LOCAL cResult

   cTmpQry := "SELECT usr_username FROM " + cTable + " WHERE usr_id = " + AllTrim( Str( nUser_id ) )
   oTable := run_sql_query( cTmpQry )

   IF sql_error_in_query( oTable, "SELECT" )
      RETURN "?user?"
   ENDIF

   RETURN hb_UTF8ToStr( oTable:FieldGet( 1 ) )



FUNCTION GetFullUserName( nUser_id )

   LOCAL cTmpQry
   LOCAL cTable := "public.usr" // view
   LOCAL oTable

   cTmpQry := "SELECT usr_propername FROM " + cTable + " WHERE usr_id = " + AllTrim( Str( nUser_id ) )
   oTable := run_sql_query( cTmpQry )

   IF sql_error_in_query( oTable, "SELECT" )
      RETURN "?user?"
   ENDIF

   RETURN hb_UTF8ToStr( oTable:FieldGet( 1 ) )



FUNCTION choose_f18_user_from_list( nOperaterId )

   LOCAL _list

   nOperaterId := 0

   _list := get_list_f18_users()
   nOperaterId := izaberi_f18_korisnika( _list )

   RETURN .T.




STATIC FUNCTION izaberi_f18_korisnika( arr )

   LOCAL _ret := 0
   LOCAL nI, _n
   LOCAL _tmp
   LOCAL _choice := 0
   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _m_x := m_x
   LOCAL _m_y := m_y

   FOR nI := 1 TO Len( arr )

      _tmp := ""
      _tmp += PadL( AllTrim( Str( nI ) ) + ")", 3 )
      _tmp += " " + PadR( arr[ nI, 2 ], 30 )

      AAdd( _opc, _tmp )
      AAdd( _opcexe, {|| "" } )

   NEXT

   DO WHILE .T. .AND. LastKey() != K_ESC
      _izbor := meni_0( "choice", _opc, _izbor, .F. )
      IF _izbor == 0
         EXIT
      ELSE
         _ret := arr[ _izbor, 1 ]
         _izbor := 0
      ENDIF
   ENDDO

   m_x := _m_x
   m_y := _m_y

   RETURN _ret


FUNCTION get_list_f18_users()

   LOCAL cQuery, oTable
   LOCAL _list := {}
   LOCAL _row, nI

   cQuery := "SELECT usr_id AS id, usr_username AS name, usr_propername AS fullname, usr_email AS email " + ;
      "FROM public.usr " + ;
      "WHERE usr_username NOT IN ( 'postgres', 'admin' ) " + ;
      "ORDER BY usr_username;"

   oTable := run_sql_query( cQuery )
   IF sql_error_in_query( oTable, "SELECT" )
      RETURN NIL
   ENDIF

   oTable:GoTo( 1 )

   FOR nI := 1 TO oTable:LastRec()

      _row := oTable:GetRow( nI )

      AAdd( _list, { _row:FieldGet( _row:FieldPos( "id" ) ), ;
         _row:FieldGet( _row:FieldPos( "name" ) ), ;
         _row:FieldGet( _row:FieldPos( "fullname" ) ), ;
         _row:FieldGet( _row:FieldPos( "email" ) ) } )

   NEXT

   RETURN _list
