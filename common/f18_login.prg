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
#include "f18_color.ch"

MEMVAR GetList

STATIC s_oLogin
STATIC s_cTekucaSezona
STATIC s_cPredhodnaSezona
STATIC s_lPrvoPokretanje // prvo pokretanje aplikacije

CLASS F18Login

   METHOD New()
   METHOD postgres_db_login( lForceConnect )

   METHOD promjena_sezone( cDatabase, cSezona )
   METHOD promjena_sezone_box()
   METHOD browse_odabir_organizacije()
   METHOD manual_enter_company_data()
   METHOD administratorske_opcije()
   METHOD database_array()
   METHOD get_database_browse_array()
   METHOD get_database_top_session()
   METHOD get_database_sessions()
   METHOD get_database_description()
   METHOD show_info_bar()
   METHOD server_login_form()
   METHOD odabir_organizacije()

   METHOD connect( nConnType )
   METHOD connect_postgresql()
   METHOD connect_user_database()

   METHOD disconnect( nConn )
   METHOD disconnect_postgresql()
   METHOD disconnect_user_database()

   METHOD set_postgresql_connection_params( hSqlParams )
   METHOD set_data_connection_params( hSqpParams )
   METHOD included_databases_for_user()
   METHOD write_to_ini_server_params()


   DATA lPostgresDbSpojena
   DATA oMainDbServer
   DATA lOrganizacijaSpojena

   DATA cOrganizacijaOdabranaUBrowse
   DATA cTekucaSezona
   DATA hDbPostgresConnectionParams
   DATA hDbDataConnectionParams
   DATA cIncludeDbFilter

ENDCLASS


/* my_login obezbjedjuje da je login objekat singleton */

FUNCTION my_login()

   IF s_oLogin == NIL
      s_oLogin := F18Login():New()
   ENDIF

   RETURN s_oLogin



METHOD F18Login:New()

   LOCAL _key, hDbParamsIni

   ::hDbPostgresConnectionParams := hb_Hash()
   ::hDbDataConnectionParams := hb_Hash()
   ::cOrganizacijaOdabranaUBrowse := ""
   ::cTekucaSezona := ""
   ::cIncludeDbFilter := ""
   ::lOrganizacijaSpojena := .F.
   ::lPostgresDbSpojena := .F.
   s_cTekucaSezona := AllTrim( Str( Year( Date() ) ) )
   s_cPredhodnaSezona := AllTrim( Str( Year( Date() ) - 1 ) )
   s_lPrvoPokretanje := .T.


   hDbParamsIni := hb_Hash()
   hDbParamsIni[ "host" ] := nil
   hDbParamsIni[ "database" ] := nil
   hDbParamsIni[ "user" ] := nil
   hDbParamsIni[ "schema" ] := nil
   hDbParamsIni[ "port" ] := nil
   hDbParamsIni[ "session" ] := nil

   IF !f18_ini_config_read( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), @hDbParamsIni, .T. )
      error_bar( "ini", "problem f18 ini read" )
   ENDIF

   IF ValType( hDbParamsIni[ "port" ] ) == "C" // port je numeric
      hDbParamsIni[ "port" ] := Val( hDbParamsIni[ "port" ] )
   ENDIF
   hDbParamsIni[ "password" ] := hDbParamsIni[ "user" ]

   my_server_params( hDbParamsIni )

   ::set_data_connection_params( hDbParamsIni )

   hDbParamsIni[ "database" ] := "postgres"
   ::set_postgresql_connection_params( hDbParamsIni )

   RETURN SELF



METHOD F18Login:included_databases_for_user()

   LOCAL cIniSection := "login_options"
   LOCAL cFilterKey := "database_filter"
   LOCAL hDbParamsIni := hb_Hash()
   LOCAL _inc_filter := ""

   hDbParamsIni[ cFilterKey ] := NIL

   f18_ini_config_read( cIniSection, @hDbParamsIni, .T. )

   IF hDbParamsIni[ cFilterKey ] == NIL
      ::cIncludeDbFilter := ""
   ELSE
      ::cIncludeDbFilter := hDbParamsIni[ cFilterKey ]
   ENDIF

   RETURN .T.


METHOD F18Login:connect( nConnType, lSilent )

   LOCAL lConnected, hSqlParams

   IF lSilent == NIL
      lSilent := .F.
   ENDIF

   IF nConnType == 0
      server_postgres_db_close()
      hSqlParams := ::hDbPostgresConnectionParams
      lConnected := my_server_login( ::hDbPostgresConnectionParams, 0 )
   ENDIF

   IF nConnType == 1
      my_server_close( 1 )
      hSqlParams := ::hDbDataConnectionParams
      lConnected := my_server_login( ::hDbDataConnectionParams, 1 )
      my_server_params( ::hDbDataConnectionParams )
   ENDIF


   IF lConnected
      IF nConnType == 0
         ::lPostgresDbSpojena := .T.
      ELSE
         ::lOrganizacijaSpojena := .T.
         IF post_login()
            IF is_in_main_thread()
               post_login_cleanup()
               ::write_to_ini_server_params()
            ENDIF
         ELSE
            my_server_close( 1 )
            my_server_close( 0 )
            RETURN .F.
         ENDIF
      ENDIF
   ELSE
      ?E "connection error:", hSqlParams[ "host" ], hSqlParams[ "port" ], hSqlParams[ "database" ], hSqlParams[ "user" ]
   ENDIF

   RETURN lConnected



METHOD F18Login:connect_postgresql()

   RETURN ::connect( 0 )


METHOD F18Login:connect_user_database()

   RETURN ::connect( 1 )


METHOD F18Login:write_to_ini_server_params()

   LOCAL cKey, hIniParams := hb_Hash()

   FOR EACH cKey in { "host", "user", "schema", "port", "database", "session" }
      hIniParams[ cKey ] := ::hDbDataConnectionParams[ cKey ]
   NEXT

   IF !f18_ini_config_write( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), hIniParams, .T. )
      MsgBeep( "problem ini write server params" )
      RETURN .F.
   ENDIF

   RETURN .T.


METHOD F18Login:disconnect( nConn )

   LOCAL lDisconnected

   IF nConn == NIL
      nConn := 1
   ENDIF

   IF nConn == 0
      lDisconnected := server_postgres_db_close()
   ELSE
      lDisconnected := my_server_close()
   ENDIF

   RETURN lDisconnected


METHOD F18Login:disconnect_postgresql()

   RETURN  server_postgres_db_close()


METHOD F18Login:disconnect_user_database()

   RETURN  my_server_close()


METHOD F18Login:set_postgresql_connection_params( hSqlParams )

   ::hDbPostgresConnectionParams := hb_Hash()
   ::hDbPostgresConnectionParams[ "user" ] := hSqlParams[ "user" ]
   ::hDbPostgresConnectionParams[ "password" ] := hSqlParams[ "password" ]
   ::hDbPostgresConnectionParams[ "host" ] := hSqlParams[ "host" ]
   ::hDbPostgresConnectionParams[ "port" ] := hSqlParams[ "port" ]
   ::hDbPostgresConnectionParams[ "database" ] := hSqlParams[ "database" ]
   ::hDbPostgresConnectionParams[ "schema" ] := hSqlParams[ "schema" ]
   ::hDbPostgresConnectionParams[ "session" ] := hSqlParams[ "session" ]

   RETURN .T.


METHOD F18Login:set_data_connection_params( hSqlParams )

   ::hDbDataConnectionParams[ "database" ] := hSqlParams[ "database" ]
   ::hDbDataConnectionParams[ "session" ] := hSqlParams[ "session" ]
   ::hDbDataConnectionParams[ "user" ] := hSqlParams[ "user" ]
   ::hDbDataConnectionParams[ "password" ] := hSqlParams[ "password" ]
   ::hDbDataConnectionParams[ "host" ] := hSqlParams[ "host" ]
   ::hDbDataConnectionParams[ "port" ] := hSqlParams[ "port" ]
   ::hDbDataConnectionParams[ "schema" ] := hSqlParams[ "schema" ]

   RETURN .T.


METHOD F18Login:postgres_db_login( lForceConnect )

   IF lForceConnect == NIL
      lForceConnect := .T.
   ENDIF

   IF lForceConnect .AND. ::hDbPostgresConnectionParams[ "user" ] <> NIL .AND.  ::connect( 0 ) // try to connect, if not, open login form
      ::lPostgresDbSpojena := .T.
      RETURN .T.
   ENDIF

   IF ! ::server_login_form()
      ::lPostgresDbSpojena := .F.
      RETURN .F.
   ENDIF

   IF ::connect_postgresql()
      ::lPostgresDbSpojena := .T.
      RETURN .T.
   ENDIF

   RETURN .T.






METHOD F18Login:promjena_sezone_box( cSession )

   LOCAL lRet := .T.

   Box(, 1, 50 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Pristup podacima sezone:" GET cSession VALID !Empty( cSession )
   READ
   BoxC()

   IF LastKey() == K_ESC
      lRet := .F.
      RETURN lRet
   ENDIF

   RETURN lRet


METHOD F18Login:promjena_sezone( cDatabase, cSezona )

   LOCAL lOk := .F.
   LOCAL cTrenutnaDatabase
   LOCAL cTrenutnaSezona
   LOCAL _show_box := .T.
   LOCAL _modul_name
   LOCAL hParams
   LOCAL cTekucaSezona
   LOCAL cNovaSezona
   LOCAL cSaveDatabase

   hParams := hb_Hash()
   hParams[ "posljednji_put" ] := s_cPredhodnaSezona // posljednji put se radilo u ovoj sezoni
   hParams[ "posljednja_org" ] := "x"
   f18_ini_config_read( "sezona", @hParams, .T. ) // promjena, sezone, read global from ~/.f18_config.ini

   IF goModul != NIL
      _modul_name := Lower( goModul:cName )
   ENDIF


   IF cDatabase == NIL
      cTrenutnaDatabase := ::hDbDataConnectionParams[ "database" ]
   ELSE
      cTrenutnaDatabase := cDatabase
      _show_box := .F.
   ENDIF

   IF cSezona <> NIL
      cNovaSezona := cSezona
      _show_box := .F.
   ELSE
      cNovaSezona := hParams[ "posljednji_put" ]
   ENDIF

   IF !( "_" $ cTrenutnaDatabase )
      RETURN .F.
   ENDIF

   IF _show_box
      IF !::promjena_sezone_box( @cNovaSezona )
         RETURN .F.
      ENDIF
   ENDIF

   IF cTrenutnaSezona == cNovaSezona
      MsgBeep( "Već se nalazimo u sezoni " + cTrenutnaSezona  )
      RETURN .F.
   ENDIF

   cTrenutnaSezona := Right( cTrenutnaDatabase, 4 ) // bringout_2016 => bringout_2015
   cSaveDatabase := ::hDbDataConnectionParams[ "database" ]
   ::hDbDataConnectionParams[ "database" ] := StrTran( cTrenutnaDatabase, "_" + cTrenutnaSezona, "_" + cNovaSezona )
   ::hDbDataConnectionParams[ "session" ] := cNovaSezona

   IF ::connect_user_database()
      lOk := .T.
   ELSE
      MsgBeep( "Traženo sezonsko područje " + cNovaSezona + " ne postoji !" )
      ::hDbDataConnectionParams[ "database" ] := cSaveDatabase // vrati posljednju ispravnu bazu
      ::hDbDataConnectionParams[ "session" ] := cTrenutnaSezona
      IF !::connect_user_database()
         MsgBeep( "Ne mogu se spojiti na " +  cSaveDatabase + "?!" )
         QUIT_1
      ENDIF
   ENDIF


   IF lOk .AND. _show_box

      IF _modul_name != NIL .AND. !f18_use_module( _modul_name )
         MsgBeep( "U " + AllTrim( s_cPredhodnaSezona ) + " programski modul " + Upper( _modul_name ) + " vam nije aktiviran !" )
         IF Pitanje(, "Želite li korisiti programski modul " + Upper( _modul_name ) + " u sezoni " + s_cPredhodnaSezona + " (D/N) ?", "N" ) == "D"
            f18_set_use_module( _modul_name, .T. )
         ELSE
            MsgBeep( "Vraćamo se u sezonu " + cTrenutnaSezona )
            ::promjena_sezone( cTrenutnaDatabase, cTrenutnaSezona )
         ENDIF
      ENDIF
      CLOSE ALL


   ENDIF

   hParams[ "posljednji_put" ] := cNovaSezona
   // ako je baza bringout_2014, hparams[ posljednja_org ] ce biti bringout
   hParams[ "posljednja_org" ] := StrTran( ::hDbDataConnectionParams[ "database" ], "_" + cNovaSezona, "" )

   f18_ini_config_write( "sezona", @hParams, .T. )

   RETURN lOk




METHOD F18Login:server_login_form()

   LOCAL cUser, cPassword, _port, _host, _schema
   LOCAL nX := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL cSezona
   LOCAL _key, hDbParamsIni := hb_Hash()

   cUser := ::hDbPostgresConnectionParams[ "user" ]
   cPassword := ""
   _host := ::hDbPostgresConnectionParams[ "host" ]
   _port := ::hDbPostgresConnectionParams[ "port" ]
   _schema := ::hDbPostgresConnectionParams[ "schema" ]


   IF ( _host == NIL ) .OR. ( _port == NIL )
      _srv_config := "D"
   ENDIF

   IF _host == NIL
      _host := "localhost"
   ENDIF

   IF _port == NIL
      _port := 5432
   ENDIF

   IF _schema == NIL
      _schema := F18_PSQL_SCHEMA
   ENDIF

   IF cUser == NIL
      cUser := "test1"
   ENDIF

   _host := PadR( _host, 100 )
   cUser := PadR( cUser, 100 )
   cPassword := PadR( cPassword, 100 )

   CLEAR SCREEN

   @ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

   ++nX
   @ nX, _left SAY PadC( "**** Unesite podatke za pristup *****", 60 )

   nX += 2
   @ nX, _left SAY PadL( "Konfigurisati server ?:", 21 ) GET _srv_config ;
      VALID _srv_config $ "DN" PICT "@!"
   ++nX

   READ

   IF _srv_config == "D"
      ++nX
      @ nX, _left SAY PadL( "Server:", 8 ) GET _host PICT "@S20"
      @ nX, 37 SAY "Port:" GET _port PICT "99999"
   ELSE
      ++nX
   ENDIF

   nX += 2
   @ nX, _left SAY PadL( "KORISNIK:", 15 ) GET cUser PICT "@S30"

   nX += 2
   @ nX, _left SAY PadL( "LOZINKA:", 15 ) GET cPassword PICT "@S30" COLOR F18_COLOR_PASSWORD

   READ

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   ::hDbPostgresConnectionParams[ "user" ] := AllTrim( cUser )
   ::hDbPostgresConnectionParams[ "host" ] := AllTrim( _host )
   ::hDbPostgresConnectionParams[ "port" ] := _port
   ::hDbPostgresConnectionParams[ "schema" ] := _schema
   ::hDbPostgresConnectionParams[ "database" ] := "postgres"

   IF Empty( cPassword ) // korisnici user=password se jednostavno logiraju
      ::hDbPostgresConnectionParams[ "password" ] := ::hDbPostgresConnectionParams[ "user" ]
   ELSE
      ::hDbPostgresConnectionParams[ "password" ] := AllTrim( cPassword )
   ENDIF

   ::hDbDataConnectionParams := hb_HClone( ::hDbPostgresConnectionParams )
   ::hDbDataConnectionParams[ "database" ] := "test_2016"

   RETURN .T.



METHOD F18Login:odabir_organizacije()

   LOCAL cSezona
   LOCAL nX := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL aOrganizacijeZaBrowse, aOrganizacije
   LOCAL hParams := hb_Hash()
   LOCAL hIniParams := hb_Hash(), cKey
   LOCAL nOrgBrowseReturn

   ::included_databases_for_user()  // filter baza dostupnih useru, ako postoji !

   hParams[ "posljednji_put" ] := "0000"
   hParams[ "posljednja_org" ] := "x"
   f18_ini_config_read( "sezona", @hParams, .T. ) // read from global ~/.f18_config.ini

   IF s_lPrvoPokretanje .AND. hParams[ "posljednja_org" ] != "x" // odmah se prebaciti  posljednju organizaciju/sezonu
      ::hDbDataConnectionParams[ "database" ] :=  hParams[ "posljednja_org" ] + "_" + hParams[ "posljednji_put" ]
      ::hDbDataConnectionParams[ "session" ] := hParams[ "posljednji_put" ]
      s_lPrvoPokretanje := .F.
      RETURN .T.
   ENDIF

   aOrganizacije := ::database_array()

   IF HB_ISNIL( aOrganizacije ) .OR. Len( aOrganizacije ) == 0
      MsgBeep( "Na serveru ne postoji definisana nijedna baza !" )
      RETURN .F.
   ENDIF


   aOrganizacijeZaBrowse := ::get_database_browse_array( aOrganizacije ) // odaberi organizaciju
   nOrgBrowseReturn := ::browse_odabir_organizacije( aOrganizacijeZaBrowse ) // browsaj listu organizacija

   IF nOrgBrowseReturn < 1
      // vraca 0 - ESC, -1 - loop,  1 - ENTER
      RETURN .F.
   ENDIF

   IF ::cTekucaSezona == NIL
      cSezona := ::get_database_top_session( ::cOrganizacijaOdabranaUBrowse ) // ako nije zadata sezona odaberi top sezonu, NIL je ako nije zadata
   ELSE
      cSezona := AllTrim( ::cTekucaSezona ) // ako je zadata uzmi nju
   ENDIF

   ::hDbDataConnectionParams[ "database" ] := AllTrim( ::cOrganizacijaOdabranaUBrowse ) + iif( !Empty( cSezona ), "_" + AllTrim( cSezona ), "" )
   ::hDbDataConnectionParams[ "session" ] := AllTrim( cSezona )

   hParams[ "posljednji_put" ] := ::hDbDataConnectionParams[ "session" ]
   hParams[ "posljednja_org" ] := StrTran( ::hDbDataConnectionParams[ "database" ], "_" + ::hDbDataConnectionParams[ "session" ], "" )
   f18_ini_config_write( "sezona", @hParams, .T. ) // nakon odabira organizacije upisi izbor


   ::lOrganizacijaSpojena := .T.

   RETURN .T.




METHOD F18Login:get_database_sessions( DATABASE )

   LOCAL cSezona := ""
   LOCAL oDataSet, oRow, _db, cQuery
   LOCAL aOrganizacijeZaBrowse := {}

   IF Empty( DATABASE )
      RETURN NIL
   ENDIF

   cQuery := "SELECT DISTINCT substring( datname, '" + AllTrim( DATABASE ) +  "_([0-9]+)') AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   oDataSet := postgres_sql_query( cQuery )
   IF sql_error_in_query( oDataSet, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oDataSet:GoTo( 1 )

   DO WHILE !oDataSet:Eof()

      oRow := oDataSet:GetRow()
      cSezona := oRow:FieldGet( oRow:FieldPos( "godina" ) )

      IF !Empty( cSezona )
         AAdd( aOrganizacijeZaBrowse, { cSezona } )
      ENDIF

      oDataSet:skip()

   ENDDO

   RETURN aOrganizacijeZaBrowse




METHOD F18Login:get_database_top_session( DATABASE )

   LOCAL cSezona := ""
   LOCAL oDataSet, oRow, _db, cQuery

   cQuery := "SELECT MAX( DISTINCT substring( datname, '" + AllTrim( DATABASE ) +  "_([0-9]+)') ) AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   oDataSet := postgres_sql_query( cQuery )
   IF sql_error_in_query( oDataSet, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oRow := oDataSet:GetRow()
   cSezona := oRow:FieldGet( oRow:FieldPos( "godina" ) )

   RETURN cSezona



METHOD F18Login:get_database_description( database, cSezona )

   LOCAL _descr := ""
   LOCAL oDataSet, oRow, cQuery
   LOCAL _database_name := ""

   IF Empty( DATABASE )
      RETURN _descr
   ENDIF

   _database_name := DATABASE + iif( !Empty( cSezona ), "_" + cSezona, "" )

   cQuery := "SELECT description AS opis " + ;
      "FROM pg_shdescription " + ;
      "JOIN pg_database on objoid = pg_database.oid " + ;
      "WHERE datname = " + sql_quote( _database_name )

   oDataSet := postgres_sql_query( cQuery )
   IF sql_error_in_query( oDataSet, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oRow := oDataSet:GetRow()

   IF oRow <> NIL
      _descr := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "opis" ) ) )
   ELSE
      _descr := "< naziv nije setovan >"
   ENDIF

   RETURN _descr




METHOD F18Login:get_database_browse_array( aArray )

   LOCAL aOrganizacijeZaBrowse := {}
   LOCAL _count, _n, nX
   LOCAL _len := 20

   _count := 0
   FOR _n := 1 TO 30

      AAdd( aOrganizacijeZaBrowse, { "", "", "", "" } )

      FOR nX := 1 TO 4
         ++_count
         aOrganizacijeZaBrowse[ _n, nX ] := IF( _count > Len( aArray ), PadR( "", _len ), PadR( aArray[ _count, 1 ], _len ) )
      NEXT

   NEXT

   RETURN aOrganizacijeZaBrowse



METHOD F18Login:database_array()

   LOCAL oDataSet, oRow, _db, cQuery
   LOCAL aOrganizacije := {}
   LOCAL _filter_db := "empty#empty_sezona"
   LOCAL _where := ""

   _where := " WHERE has_database_privilege( CURRENT_USER, datname, 'connect' ) "

   IF !Empty( ::cIncludeDbFilter )
      _where += " AND " + _sql_cond_parse( "datname", ::cIncludeDbFilter + " " )
   ENDIF

   cQuery := "SELECT DISTINCT substring( datname, '(.*)_[0-9]+') AS datab " + ;
      " FROM pg_database " + ;
      _where + ;
      " ORDER BY datab "

   oDataSet := postgres_sql_query( cQuery )
   IF sql_error_in_query( oDataSet, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oDataSet:GoTo( 1 )

   DO WHILE !oDataSet:Eof()

      oRow := oDataSet:GetRow()
      _db := oRow:FieldGet( oRow:FieldPos( "datab" ) )

      // filter za tabele
      IF !Empty( _db ) .AND. !( AllTrim( _db ) $ _filter_db )
         AAdd( aOrganizacije, { _db } )
      ENDIF

      oDataSet:Skip()

   ENDDO

   RETURN aOrganizacije




METHOD F18Login:administratorske_opcije( x_pos, y_pos )

   LOCAL nX, _y
   LOCAL aMeni := {}, aMeniExec := {}, nIzbor

   nX := x_pos
   _y := ( f18_max_cols() / 2 ) - 5


   // print_sql_connections()

   AAdd( aMeni, hb_UTF8ToStr( "1. rekonfiguracija servera        " ) )
   AAdd( aMeniExec, {|| f18_login_loop( .F. ), .T. } )

   AAdd( aMeni, hb_UTF8ToStr( "2. update F18" ) )
   AAdd( aMeniExec, {|| F18Admin():update_app(), .T. } )

   // AAdd( aMeni, hb_UTF8ToStr( "3. update baze" ) )
   // AAdd( aMeniExec, {|| F18Admin():New():update_db(), .T. } )

   AAdd( aMeni, hb_UTF8ToStr( "3. nova baza" ) )
   AAdd( aMeniExec, {|| F18Admin():New():create_new_pg_db(), .T. } )

   AAdd( aMeni, hb_UTF8ToStr( "5. brisanje baze" ) )
   AAdd( aMeniExec, {|| F18Admin():New():drop_pg_db(), .T. } )

   AAdd( aMeni, hb_UTF8ToStr( "6. otvaranje nove godine" ) )
   AAdd( aMeniExec, {|| F18Admin():New():razdvajanje_sezona(), .T. } )

   AAdd( aMeni, hb_UTF8ToStr( "7. sql_cleanup_all" ) )
   AAdd( aMeniExec, {|| F18Admin():sql_cleanup_all(), .T. } )


   DO WHILE .T.

      nIzbor := meni_0_inkey( nX, _y + 1, nX + 5, _y + 40, aMeni, 1 )

      DO CASE
      CASE nIzbor == 0
         EXIT
      CASE nIzbor > 0
         Eval( aMeniExec[ nIzbor ] )
      ENDCASE

      LOOP

   ENDDO

   RETURN .T.






METHOD F18Login:manual_enter_company_data( x_pos, y_pos )

   LOCAL nX
   LOCAL _y := 3
   LOCAL _db := Space( 20 )
   LOCAL cSezona := AllTrim( Str( Year( Date() ) ) )

   nX := x_pos

   @ nX, _y + 1 SAY hb_UTF8ToStr( "Pristupiti sljedećoj bazi:" )

   nX += 2
   @ nX, _y + 3 SAY Space( 30 )
   @ nX, _y + 3 SAY "  Baza:" GET _db VALID !Empty( _db )

   ++nX
   @ nX, _y  + 3 SAY "Sezona:" GET cSezona

   READ

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   IF LastKey() == K_ENTER
      ::cOrganizacijaOdabranaUBrowse := AllTrim( _db )
      ::cTekucaSezona := AllTrim( cSezona )
   ENDIF

   RETURN .T.




METHOD F18Login:browse_odabir_organizacije( aArray, table_type )

   LOCAL nI, _l
   LOCAL _key
   LOCAL oTBrowse
   LOCAL _opt := 0
   LOCAL _pos_left := 3
   LOCAL _pos_top := 5
   LOCAL _pos_bottom := _pos_top + 12
   LOCAL _pos_right := f18_max_cols() - 12
   LOCAL _company_count

   IF table_type == NIL
      table_type := 0
   ENDIF

   // SetColor( F18_COLOR_ORGANIZACIJA )

   PRIVATE _row := 1

   IF aArray == NIL
      MsgBeep( "Nema podataka za prikaz..." )
      RETURN NIL
   ENDIF


   _company_count := _get_company_count( aArray )    // stvarni broj aktuelenih firmi

   CLEAR SCREEN

   @ 0, 0 SAY ""

   // opcija 1
   // =========================
   @ 1, 3 SAY _u( "[1] Odabir baze" )
   @ 2, 2 SAY _u( " - Strelicama odaberite željenu bazu " )
   @ 3, 2 SAY _u( " - <TAB> ručno zadavanje konekcije  <F10> admin. opcije  <ESC> izlaz" )


   // box za selekciju firme....
   @ 4, 2, _pos_bottom + 1, _pos_right + 2 BOX B_DOUBLE_SINGLE

   // opcija 2
   // =========================
   // ispis opisa
   @ _pos_bottom + 2, 3 SAY hb_UTF8ToStr( "[2] Ručna konekcija na bazu" )

   // box za rucni odabir firme
   @ _pos_bottom + 3, 2, _pos_bottom + 10, ( _pos_right / 2 ) - 3 BOX B_DOUBLE_SINGLE
   @ _pos_bottom + 6, 11 SAY hb_UTF8ToStr( "<<< pritisni TAB >>>" )

   // opcija 3
   @ _pos_bottom + 2, ( _pos_right / 2 ) + 1 SAY hb_UTF8ToStr( "[3] Administrativne opcije" )

   // box za administrativne opcije
   @ _pos_bottom + 3,  ( _pos_right / 2 ), _pos_bottom + 10, _pos_right + 2 BOX B_DOUBLE_SINGLE
   @ _pos_bottom + 6, ( _pos_right / 2 ) + 12 SAY hb_UTF8ToStr( "<<< pritisni F10 >>>" )

   oTBrowse := TBrowseNew( _pos_top, _pos_left, _pos_bottom, _pos_right )

   IF table_type == 0
      oTBrowse:HeadSep := ""
      oTBrowse:FootSep := ""
      oTBrowse:ColSep := " "
   ELSEIF table_type == 1
      oTBrowse:headSep := "-"
      oTBrowse:footSep := "-"
      oTBrowse:colSep := "|"
   ELSEIF table_type == 2
      oTBrowse:HeadSep := hb_UTF8ToStrBox( BROWSE_HEAD_SEP )
      oTBrowse:FootSep := hb_UTF8ToStrBox( BROWSE_FOOT_SEP )
      oTBrowse:ColSep := hb_UTF8ToStrBox( BROWSE_COL_SEP )
   ENDIF

   oTBrowse:skipBlock := {| _skip | _skip := _skip_it( aArray, _row, _skip ), _row += _skip, _skip }
   oTBrowse:goTopBlock := {|| _row := 1 }
   oTBrowse:goBottomBlock := {|| _row := Len( aArray ) }

   FOR _l := 1 TO Len( aArray[ 1 ] )
      oTBrowse:addColumn( TBColumnNew( "", _browse_block( aArray, _l ) ) )
   NEXT


   DO WHILE ( _key <> K_ESC ) .AND. ( _key <> K_RETURN ) // main key handler loop

      oTBrowse:forcestable() // stabilize the browse and wait for a keystroke
      ::show_info_bar( AllTrim( Eval( oTBrowse:GetColumn( oTBrowse:colpos ):block ) ), _pos_bottom + 4 )
      _key := Inkey( 0 )

      IF oTBrowse:stable

         DO CASE

         CASE ( _key == K_DOWN )
            oTBrowse:down()
         CASE ( _key == K_UP )
            oTBrowse:up()
         CASE ( _key == K_RIGHT )
            oTBrowse:Right()
         CASE ( _key == K_LEFT )
            oTBrowse:Left()
         CASE ( _key == K_F10 )
            ::administratorske_opcije( _pos_bottom + 4, _pos_left )
            RETURN -1
         CASE ( _key == K_TAB )
            IF ::manual_enter_company_data( _pos_bottom + 4, _pos_left )
               RETURN 1
            ELSE
               RETURN -1
            ENDIF
         CASE ( _key == K_ENTER )

            ::cOrganizacijaOdabranaUBrowse := AllTrim( Eval( oTBrowse:GetColumn( oTBrowse:colpos ):block ) ) // ovo je firma koju smo odabrali
            ::cTekucaSezona := NIL // sezona treba da bude uzeta kao TOP sezona
            RETURN 1
         ENDCASE

      ENDIF

   ENDDO

   RETURN 0



METHOD F18Login:show_info_bar( database, x_pos )

   LOCAL nX := x_pos + 7
   LOCAL _y := 3
   LOCAL _info := ""
   LOCAL aOrganizacijeZaBrowse := ::get_database_sessions( DATABASE )
   LOCAL _max_len := f18_max_cols() - 2
   LOCAL _descr := ""

   IF !aOrganizacijeZaBrowse == NIL .AND. Len( aOrganizacijeZaBrowse ) > 0

      _descr := ::get_database_description( database, aOrganizacijeZaBrowse[ Len( aOrganizacijeZaBrowse ), 1 ] )

      _info += AllTrim( _descr )

      IF Len( aOrganizacijeZaBrowse ) > 1
         _info += ", dostupne sezone: " + aOrganizacijeZaBrowse[ 1, 1 ] + " ... " + aOrganizacijeZaBrowse[ Len( aOrganizacijeZaBrowse ), 1 ]
      ELSE
         _info += ", sezona: " + aOrganizacijeZaBrowse[ 1, 1 ]
      ENDIF

   ENDIF

   @ nX, _y SAY PadR( "Info: " + _info, _max_len )
   ++nX
   @ nX, _y SAY "F18 version: " + f18_ver() + " lib: " + f18_lib_ver()

   RETURN .T.



STATIC FUNCTION _get_company_count( aArray )

   LOCAL _count := 0, nI, _n

   FOR nI := 1 TO Len( aArray )
      FOR _n := 1 TO 4
         IF !Empty( aArray[ nI, _n ] )
            ++_count
         ENDIF
      NEXT
   NEXT

   RETURN _count




STATIC FUNCTION _browse_block( aArray, nX )
   RETURN ( {| p | iif( PCount() == 0, aArray[ _row, nX ], aArray[ _row, nX ] := p ) } )



STATIC FUNCTION _skip_it( aArray, curr, skiped )

   IF ( curr + skiped < 1 )
      // Would skip past the top...
      RETURN( - curr + 1 )
   ELSEIF ( curr + skiped > Len( aArray ) )
      // Would skip past the bottom...
      RETURN ( Len( aArray ) - curr )
   ENDIF

   RETURN( skiped )
