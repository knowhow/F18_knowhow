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

MEMVAR GetList

STATIC s_cTekucaSezona
STATIC s_cPredhodnaSezona
STATIC s_lPrvoPokretanje // prvo pokretanje aplikacije

CLASS F18Login

   METHOD New()
   METHOD postgres_db_login( lForceConnect )
   METHOD login_odabir_organizacije()
   METHOD promjena_sezone( cDatabase, cSezona )
   METHOD promjena_sezone_box()
   METHOD browse_odabir_organizacije()
   METHOD manual_enter_company_data()
   METHOD administrative_options()
   METHOD database_array()
   METHOD get_database_browse_array()
   METHOD get_database_top_session()
   METHOD get_database_sessions()
   METHOD get_database_description()
   METHOD show_info_bar()
   METHOD server_login_form()
   METHOD odabir_organizacije()
   METHOD connect()
   METHOD disconnect( nConn )
   METHOD set_postgres_db_params( hSqlParams )
   METHOD set_data_db_params( hSqpParams )
   METHOD included_databases_for_user()

   DATA lPostgresDbSpojena
   DATA oMainDbServer
   DATA lOrganizacijaSpojena

   DATA _company_db_curr_choice
   DATA _company_db_curr_session
   DATA postgres_db_params
   DATA data_db_params
   DATA _include_db_filter

ENDCLASS


// main db connect
// =======================================
// oLogin = F18Login():New()
// oLogin:MainDbLoginForm()
// if !oLogin:lPostgresDbSpojena
// ....
// endif


METHOD F18Login:New()

   LOCAL _key, _ini_params

   ::postgres_db_params := hb_Hash()
   ::data_db_params := hb_Hash()
   ::_company_db_curr_choice := ""
   ::_company_db_curr_session := ""
   ::_include_db_filter := ""
   ::lOrganizacijaSpojena := .F.
   ::lPostgresDbSpojena := .F.
   s_cTekucaSezona := AllTrim( Str( Year( Date() ) ) )
   s_cPredhodnaSezona := AllTrim( Str( Year( Date() ) - 1 ) )
   s_lPrvoPokretanje := .T.


   _ini_params := hb_Hash()
   _ini_params[ "host" ] := nil
   _ini_params[ "database" ] := nil
   _ini_params[ "user" ] := nil
   _ini_params[ "schema" ] := nil
   _ini_params[ "port" ] := nil
   _ini_params[ "session" ] := nil

   IF !f18_ini_config_read( F18_SERVER_INI_SECTION + iif( test_mode(), "_test", "" ), @_ini_params, .T. )
      error_bar( "ini", "problem f18 ini read" )
   ENDIF

   IF ValType( _ini_params[ "port" ] ) == "C" // port je numeric
      _ini_params[ "port" ] := Val( _ini_params[ "port" ] )
   ENDIF
   _ini_params[ "password" ] := _ini_params[ "user" ]

   my_server_params( _ini_params )

   ::set_data_db_params( _ini_params )

   _ini_params[ "database" ] := "postgres"
   ::set_postgres_db_params( _ini_params )


   RETURN SELF



METHOD F18Login:included_databases_for_user()

   LOCAL _ini_sect := "login_options"
   LOCAL _ini_var := "database_filter"
   LOCAL _ini_params := hb_Hash()
   LOCAL _inc_filter := ""

   _ini_params[ _ini_var ] := NIL

   f18_ini_config_read( _ini_sect, @_ini_params, .T. )

   IF _ini_params[ _ini_var ] == NIL
      ::_include_db_filter := ""
   ELSE
      ::_include_db_filter := _ini_params[ _ini_var ]
   ENDIF

   RETURN .T.


METHOD F18Login:connect( conn_type, silent )

   LOCAL lConnected, hSqlParams

   IF silent == NIL
      silent := .F.
   ENDIF

   IF conn_type == 0
      server_postgres_db_close()
      hSqlParams := ::postgres_db_params
      lConnected := my_server_login( ::postgres_db_params, 0 )
   ENDIF

   IF conn_type == 1
      my_server_close( 1 )
      hSqlParams := ::data_db_params
      lConnected := my_server_login( ::data_db_params, 1 )
      my_server_params( ::data_db_params )
   ENDIF


   IF lConnected
      IF conn_type == 0
         ::lPostgresDbSpojena := .T.
      ELSE
         ::lOrganizacijaSpojena := .T.
         IF post_login()
            post_login_cleanup()
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





METHOD F18Login:set_postgres_db_params( hSqlParams )

   ::postgres_db_params := hb_Hash()
   ::postgres_db_params[ "user" ] := hSqlParams[ "user" ]
   ::postgres_db_params[ "password" ] := hSqlParams[ "password" ]
   ::postgres_db_params[ "host" ] := hSqlParams[ "host" ]
   ::postgres_db_params[ "port" ] := hSqlParams[ "port" ]
   ::postgres_db_params[ "database" ] := hSqlParams[ "database" ]
   ::postgres_db_params[ "schema" ] := hSqlParams[ "schema" ]
   ::postgres_db_params[ "session" ] := hSqlParams[ "session" ]

   RETURN .T.


METHOD F18Login:set_data_db_params( hSqlParams )

   ::data_db_params[ "database" ] := hSqlParams[ "database" ]
   ::data_db_params[ "session" ] := hSqlParams[ "session" ]
   ::data_db_params[ "user" ] := hSqlParams[ "user" ]
   ::data_db_params[ "password" ] := hSqlParams[ "password" ]
   ::data_db_params[ "host" ] := hSqlParams[ "host" ]
   ::data_db_params[ "port" ] := hSqlParams[ "port" ]
   ::data_db_params[ "schema" ] := hSqlParams[ "schema" ]

   RETURN .T.


METHOD F18Login:postgres_db_login( lForceConnect )

   IF lForceConnect == NIL
      lForceConnect := .T.
   ENDIF

   IF lForceConnect .AND. ::postgres_db_params[ "user" ] <> NIL .AND.  ::connect( 0 ) // try to connect, if not, open login form
      ::lPostgresDbSpojena := .T.
      RETURN .T.
   ENDIF

   IF ! ::server_login_form()
      ::lPostgresDbSpojena := .F.
      RETURN .F.
   ENDIF

   IF ::connect( 0 )
      ::lPostgresDbSpojena := .T.
      RETURN .T.
   ENDIF

   RETURN .T.




METHOD F18Login:login_odabir_organizacije()

   LOCAL _i
   LOCAL _ret_comp


   IF ! ::odabir_organizacije()
      RETURN .F.
   ENDIF

   IF !::connect( 1 )
      RETURN .F.
   ENDIF

   ::lOrganizacijaSpojena := .T.

   RETURN .T.


METHOD F18Login:promjena_sezone_box( cSession )

   LOCAL lRet := .T.

   Box(, 1, 50 )
   @ m_x + 1, m_y + 2 SAY "Pristup podacima sezone:" GET cSession VALID !Empty( cSession )
   READ
   BoxC()

   IF LastKey() == K_ESC
      lRet := .F.
      RETURN lRet
   ENDIF

   RETURN lRet


METHOD F18Login:promjena_sezone( cDatabase, cSezona )

   LOCAL _ok := .F.
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
      cTrenutnaDatabase := ::data_db_params[ "database" ]
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

   IF ! ( "_" $ cTrenutnaDatabase )
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
   cSaveDatabase := ::data_db_params[ "database" ]
   ::data_db_params[ "database" ] := StrTran( cTrenutnaDatabase, "_" + cTrenutnaSezona, "_" + cNovaSezona )
   ::data_db_params[ "session" ] := cNovaSezona

   IF ::connect( 1 )
      _ok := .T.
   ELSE
      MsgBeep( "Traženo sezonsko područje " + cNovaSezona + " ne postoji !" )
      ::data_db_params[ "database" ] := cSaveDatabase // vrati posljednju ispravnu bazu
      ::data_db_params[ "session" ] := cTrenutnaSezona
      IF !::connect( 1 )
         MsgBeep( "Ne mogu se spojiti na " +  cSaveDatabase + "?!")
         QUIT_1
      ENDIF
   ENDIF


   IF _ok .AND. _show_box

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
   hParams[ "posljednja_org" ] := StrTran( ::data_db_params[ "database" ], "_" + cNovaSezona, "" )

   f18_ini_config_write( "sezona", @hParams, .T. )

   RETURN _ok




METHOD F18Login:server_login_form()

   LOCAL _user, _pwd, _port, _host, _schema
   LOCAL _server
   LOCAL _x := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL _session

   _user := ::postgres_db_params[ "user" ]
   _pwd := ""
   _host := ::postgres_db_params[ "host" ]
   _port := ::postgres_db_params[ "port" ]
   _schema := ::postgres_db_params[ "schema" ]
   _session := ::postgres_db_params[ "session" ]

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

   IF _user == NIL
      _user := "test1"
   ENDIF

   IF _session == NIL
      _session := AllTrim( Str( Year( Date() ) ) )
   ENDIF

   _host := PadR( _host, 100 )
   _user := PadR( _user, 100 )
   _pwd := PadR( _pwd, 100 )

   CLEAR SCREEN

   @ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

   ++ _x
   @ _x, _left SAY PadC( "*1*** Unesite podatke za pristup *****", 60 )

   _x += 2
   @ _x, _left SAY PadL( "Konfigurisati server ?:", 21 ) GET _srv_config ;
      VALID _srv_config $ "DN" PICT "@!"
   ++ _x

   READ

   IF _srv_config == "D"
      ++ _x
      @ _x, _left SAY PadL( "Server:", 8 ) GET _host PICT "@S20"
      @ _x, 37 SAY "Port:" GET _port PICT "9999"
   ELSE
      ++ _x
   ENDIF

   _x += 2
   @ _x, _left SAY PadL( "KORISNIK:", 15 ) GET _user PICT "@S30"

   _x += 2
   @ _x, _left SAY PadL( "LOZINKA:", 15 ) GET _pwd PICT "@S30" COLOR F18_COLOR_PASSWORD

   READ

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   ::postgres_db_params[ "user" ] := AllTrim( _user )
   ::postgres_db_params[ "host" ] := AllTrim( _host )
   ::postgres_db_params[ "port" ] := _port
   ::postgres_db_params[ "schema" ] := _schema
   ::postgres_db_params[ "session" ] := ""
   ::postgres_db_params[ "database" ] := "postgres"


   IF Empty( _pwd ) // korisnici user=password se jednostavno logiraju
      ::postgres_db_params[ "password" ] := ::postgres_db_params[ "user" ]
   ELSE
      ::postgres_db_params[ "password" ] := AllTrim( _pwd )
   ENDIF

   RETURN .T.



METHOD F18Login:odabir_organizacije()

   LOCAL _session
   LOCAL _x := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL _arr, _tmp
   LOCAL hParams := hb_Hash()
   LOCAL nOrganizacija

   ::included_databases_for_user()  // filter baza dostupnih useru, ako postoji !

   hParams[ "posljednji_put" ] := "0000"
   hParams[ "posljednja_org" ] := "x"
   f18_ini_config_read( "sezona", @hParams, .T. ) // read from global ~/.f18_config.ini

   IF s_lPrvoPokretanje .AND. hParams[ "posljednja_org" ] != "x" // odmah se prebaciti  posljednju organizaciju/sezonu
      ::data_db_params[ "database" ] :=  hParams[ "posljednja_org" ] + "_" + hParams[ "posljednji_put" ]
      ::data_db_params[ "session" ] := hParams[ "posljednji_put" ]
      s_lPrvoPokretanje := .F.
      RETURN .T.
   ENDIF

   _tmp := ::database_array()

   IF HB_ISNIL( _tmp ) .OR. Len( _tmp ) == 0
      MsgBeep( "Na serveru ne postoji definisana nijedna baza !" )
      RETURN .F.
   ENDIF

   _arr := ::get_database_browse_array( _tmp ) // odaberi organizaciju
   nOrganizacija := ::browse_odabir_organizacije( _arr ) // browsaj listu organizacija

   IF nOrganizacija < 1
      RETURN .F.
   ENDIF

   IF ::_company_db_curr_session == NIL
      _session := ::get_database_top_session( ::_company_db_curr_choice ) // ako nije zadata sezona odaberi top sezonu, NIL je ako nije zadata
   ELSE
      _session := AllTrim( ::_company_db_curr_session ) // ako je zadata uzmi nju
   ENDIF

   ::data_db_params[ "database" ] := AllTrim( ::_company_db_curr_choice ) + ;
      iif( !Empty( _session ), "_" + AllTrim( _session ), "" )
   ::data_db_params[ "session" ] := AllTrim( _session )


   hParams[ "posljednji_put" ] := ::data_db_params[ "session" ]
   hParams[ "posljednja_org" ] := StrTran( ::data_db_params[ "database" ], "_" + ::data_db_params[ "session" ], "" )
   f18_ini_config_write( "sezona", @hParams, .T. ) // nakon odabira organizacije upisi izbor

   RETURN .T.




METHOD F18Login:get_database_sessions( database )

   LOCAL _session := ""
   LOCAL _table, oRow, _db, _qry
   LOCAL _arr := {}

   IF Empty( database )
      RETURN NIL
   ENDIF

   _qry := "SELECT DISTINCT substring( datname, '" + AllTrim( database ) +  "_([0-9]+)') AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   _table := postgres_sql_query( _qry )
   IF sql_error_in_query( _table, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   _table:GoTo( 1 )

   DO WHILE !_table:Eof()

      oRow := _table:GetRow()
      _session := oRow:FieldGet( oRow:FieldPos( "godina" ) )

      IF !Empty( _session )
         AAdd( _arr, { _session } )
      ENDIF

      _table:skip()

   ENDDO

   RETURN _arr




METHOD F18Login:get_database_top_session( database )

   LOCAL _session := ""
   LOCAL _table, oRow, _db, _qry

   _qry := "SELECT MAX( DISTINCT substring( datname, '" + AllTrim( database ) +  "_([0-9]+)') ) AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   _table := postgres_sql_query( _qry )
   IF sql_error_in_query( _table, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oRow := _table:GetRow()
   _session := oRow:FieldGet( oRow:FieldPos( "godina" ) )

   RETURN _session



METHOD F18Login:get_database_description( database, cSezona )

   LOCAL _descr := ""
   LOCAL _table, oRow, _qry
   LOCAL _database_name := ""

   IF Empty( database )
      RETURN _descr
   ENDIF

   _database_name := database + IF( !Empty( cSezona ), "_" + cSezona, "" )

   _qry := "SELECT description AS opis " + ;
      "FROM pg_shdescription " + ;
      "JOIN pg_database on objoid = pg_database.oid " + ;
      "WHERE datname = " + sql_quote( _database_name )

   _table := postgres_sql_query( _qry )
   IF sql_error_in_query( _table, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oRow := _table:GetRow()

   IF oRow <> NIL
      _descr := hb_UTF8ToStr( oRow:FieldGet( oRow:FieldPos( "opis" ) ) )
   ELSE
      _descr := "< naziv nije setovan >"
   ENDIF

   RETURN _descr




METHOD F18Login:get_database_browse_array( arr )

   LOCAL _arr := {}
   LOCAL _count, _n, _x
   LOCAL _len := 20

   _count := 0
   FOR _n := 1 TO 30

      AAdd( _arr, { "", "", "", "" } )

      FOR _x := 1 TO 4
         ++ _count
         _arr[ _n, _x ] := IF( _count > Len( arr ), PadR( "", _len ), PadR( arr[ _count, 1 ], _len ) )
      NEXT

   NEXT

   RETURN _arr



METHOD F18Login:database_array()

   LOCAL _table, oRow, _db, _qry
   LOCAL _tmp := {}
   LOCAL _filter_db := "empty#empty_sezona"
   LOCAL _where := ""

   _where := " WHERE has_database_privilege( CURRENT_USER, datname, 'connect' ) "

   IF !Empty( ::_include_db_filter )
      _where += " AND " + _sql_cond_parse( "datname", ::_include_db_filter + " " )
   ENDIF

   _qry := "SELECT DISTINCT substring( datname, '(.*)_[0-9]+') AS datab " + ;
      " FROM pg_database " + ;
      _where + ;
      " ORDER BY datab "

   _table := postgres_sql_query( _qry )
   IF sql_error_in_query( _table, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   _table:GoTo( 1 )

   DO WHILE !_table:Eof()

      oRow := _table:GetRow()
      _db := oRow:FieldGet( oRow:FieldPos( "datab" ) )

      // filter za tabele
      IF !Empty( _db ) .AND. ! ( AllTrim( _db ) $ _filter_db )
         AAdd( _tmp, { _db } )
      ENDIF

      _table:Skip()

   ENDDO

   RETURN _tmp




METHOD F18Login:administrative_options( x_pos, y_pos )

   LOCAL _x, _y
   LOCAL _menuop, _menuexec, _mnu_choice

   _x := x_pos
   _y := ( MAXCOLS() / 2 ) - 5

   // resetuj...
   _menuop := {}
   _menuexec := {}

   _set_menu_choices( @_menuop, @_menuexec )

   DO WHILE .T.

      _mnu_choice := Achoice2( _x, _y + 1, _x + 5, _y + 40, _menuop, .T., "MenuFunc", 1 )

      DO CASE
      CASE _mnu_choice == 0
         EXIT
      CASE _mnu_choice > 0
         Eval( _menuexec[ _mnu_choice ] )
      ENDCASE

      LOOP

   ENDDO

   RETURN .T.



STATIC FUNCTION _set_menu_choices( menuop, menuexec )

   // print_sql_connections()

   AAdd( menuop, hb_UTF8ToStr( "1. rekonfiguracija servera        " ) )
   AAdd( menuexec, {|| f18_login_loop( .F. ), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "2. update F18" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():update_app(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "3. update baze" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():update_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "4. nova baza" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():create_new_pg_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "5. brisanje baze" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():drop_pg_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "6. otvaranje nove godine" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():razdvajanje_sezona(), .T. } )

   RETURN .T.





METHOD F18Login:manual_enter_company_data( x_pos, y_pos )

   LOCAL _x
   LOCAL _y := 3
   LOCAL _db := Space( 20 )
   LOCAL _session := AllTrim( Str( Year( Date() ) ) )

   _x := x_pos

   @ _x, _y + 1 SAY hb_UTF8ToStr( "Pristupiti sljedećoj bazi:" )

   _x += 2
   @ _x, _y + 3 SAY Space( 30 )
   @ _x, _y + 3 SAY "  Baza:" GET _db VALID !Empty( _db )

   ++ _x
   @ _x, _y  + 3 SAY "Sezona:" GET _session

   READ

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   IF LastKey() == K_ENTER
      ::_company_db_curr_choice := AllTrim( _db )
      ::_company_db_curr_session := AllTrim( _session )
   ENDIF

   RETURN .T.



// -------------------------------------------------------
// vraca 0 - ESC
// -1 - loop
// 1 - ENTER
// -------------------------------------------------------

METHOD F18Login:browse_odabir_organizacije( arr, table_type )

   LOCAL _i, _l
   LOCAL _key
   LOCAL _br
   LOCAL _opt := 0
   LOCAL _pos_left := 3
   LOCAL _pos_top := 5
   LOCAL _pos_bottom := _pos_top + 12
   LOCAL _pos_right := MAXCOLS() - 12
   LOCAL _company_count

   IF table_type == NIL
      table_type := 0
   ENDIF

   // SetColor( F18_COLOR_ORGANIZACIJA )

   PRIVATE _row := 1

   IF arr == NIL
      MsgBeep( "Nema podataka za prikaz..." )
      RETURN NIL
   ENDIF

   // stvarni broj aktuelenih firmi
   _company_count := _get_company_count( arr )

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

   _br := TBrowseNew( _pos_top, _pos_left, _pos_bottom, _pos_right )

   IF table_type == 0
      _br:HeadSep := ""
      _br:FootSep := ""
      _br:ColSep := " "
   ELSEIF table_type == 1
      _br:headSep := "-"
      _br:footSep := "-"
      _br:colSep := "|"
   ELSEIF table_type == 2
      _br:HeadSep := hb_UTF8ToStr( "╤═" )
      _br:FootSep := hb_UTF8ToStr( "╧═" )
      _br:ColSep := hb_UTF8ToStr( "│" )
   ENDIF

   _br:skipBlock := {| _skip | _skip := _skip_it( arr, _row, _skip ), _row += _skip, _skip }
   _br:goTopBlock := {|| _row := 1 }
   _br:goBottomBlock := {|| _row := Len( arr ) }

   FOR _l := 1 TO Len( arr[ 1 ] )
      _br:addColumn( TBColumnNew( "", _browse_block( arr, _l ) ) )
   NEXT



   DO WHILE ( _key <> K_ESC ) .AND. ( _key <> K_RETURN ) // main key handler loop


      _br:forcestable() // stabilize the browse and wait for a keystroke
      ::show_info_bar( AllTrim( Eval( _br:GetColumn( _br:colpos ):block ) ), _pos_bottom + 4 )
      _key := Inkey( 0 )

      IF _br:stable

         DO CASE

         CASE ( _key == K_DOWN )
            _br:down()
         CASE ( _key == K_UP )
            _br:up()
         CASE ( _key == K_RIGHT )
            _br:Right()
         CASE ( _key == K_LEFT )
            _br:Left()
         CASE ( _key == K_F10 )
            ::administrative_options( _pos_bottom + 4, _pos_left )
            RETURN -1
         CASE ( _key == K_TAB )
            if ::manual_enter_company_data( _pos_bottom + 4, _pos_left )
               RETURN 1
            ELSE
               RETURN -1
            ENDIF
         CASE ( _key == K_ENTER )

            ::_company_db_curr_choice := AllTrim( Eval( _br:GetColumn( _br:colpos ):block ) ) // ovo je firma koju smo odabrali...
            ::_company_db_curr_session := NIL // sezona treba da bude uzeta kao TOP sezona
            RETURN 1
         ENDCASE

      ENDIF

   ENDDO

   RETURN 0



METHOD F18Login:show_info_bar( database, x_pos )

   LOCAL _x := x_pos + 7
   LOCAL _y := 3
   LOCAL _info := ""
   LOCAL _arr := ::get_database_sessions( database )
   LOCAL _max_len := MAXCOLS() - 2
   LOCAL _descr := ""

   IF !_arr == NIL .AND. Len( _arr ) > 0

      _descr := ::get_database_description( database, _arr[ Len( _arr ), 1 ] )

      _info += AllTrim( _descr )

      IF Len( _arr ) > 1
         _info += ", dostupne sezone: " + _arr[ 1, 1 ] + " ... " + _arr[ Len( _arr ), 1 ]
      ELSE
         _info += ", sezona: " + _arr[ 1, 1 ]
      ENDIF

   ENDIF

   @ _x, _y SAY PadR( "Info: " + _info, _max_len )
   ++ _x
   @ _x, _y SAY PadR( "F18 version: " + F18_VER, _max_len )

   RETURN .T.



STATIC FUNCTION _get_company_count( arr )

   LOCAL _count := 0, _i, _n

   FOR _i := 1 TO Len( arr )
      FOR _n := 1 TO 4
         IF !Empty( arr[ _i, _n ] )
            ++ _count
         ENDIF
      NEXT
   NEXT

   RETURN _count




STATIC FUNCTION _browse_block( arr, x )
   RETURN ( {| p| iif( PCount() == 0, arr[ _row, x ], arr[ _row, x ] := p ) } )



STATIC FUNCTION _skip_it( arr, curr, skiped )

   IF ( curr + skiped < 1 )
      // Would skip past the top...
      RETURN( -curr + 1 )
   ELSEIF ( curr + skiped > Len( arr ) )
      // Would skip past the bottom...
      RETURN ( Len( arr ) - curr )
   ENDIF

   RETURN( skiped )
