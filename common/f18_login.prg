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
   METHOD connect( nConnType )
   METHOD disconnect( nConn )
   METHOD set_hDbPostgresConnectionParams( hSqlParams )
   METHOD set_hDbDataConnectionParams( hSqpParams )
   METHOD included_databases_for_user()
   METHOD write_to_ini_server_params()


   DATA lPostgresDbSpojena
   DATA oMainDbServer
   DATA lOrganizacijaSpojena

   DATA _company_db_curr_choice
   DATA _company_db_curr_session
   DATA hDbPostgresConnectionParams
   DATA hDbDataConnectionParams
   DATA _include_db_filter

ENDCLASS


/* my_login obezbjedjuje da je login objekat singleton */

FUNCTION my_login()


   IF s_oLogin == NIL
      s_oLogin := F18Login():New()
   ENDIF

   RETURN s_oLogin



METHOD F18Login:New()

   LOCAL _key, _ini_params

   ::hDbPostgresConnectionParams := hb_Hash()
   ::hDbDataConnectionParams := hb_Hash()
   ::_company_db_curr_choice := ""
   ::_company_db_curr_session := ""
   ::_include_db_filter := ""
   ::lOrganizacijaSpojena := .F.
   ::lPostgresDbSpojena := .F.
   s_cTekucaSezona := AllTrim( Str( Year( Date() ) ) )
   s_cPredhodnaSezona := AllTrim( Str( Year( Date() ) -1 ) )
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

   ::set_hDbDataConnectionParams( _ini_params )

   _ini_params[ "database" ] := "postgres"
   ::set_hDbPostgresConnectionParams( _ini_params )

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


METHOD F18Login:connect( nConnType, silent )

   LOCAL lConnected, hSqlParams

   IF silent == NIL
      silent := .F.
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





METHOD F18Login:set_hDbPostgresConnectionParams( hSqlParams )

   ::hDbPostgresConnectionParams := hb_Hash()
   ::hDbPostgresConnectionParams[ "user" ] := hSqlParams[ "user" ]
   ::hDbPostgresConnectionParams[ "password" ] := hSqlParams[ "password" ]
   ::hDbPostgresConnectionParams[ "host" ] := hSqlParams[ "host" ]
   ::hDbPostgresConnectionParams[ "port" ] := hSqlParams[ "port" ]
   ::hDbPostgresConnectionParams[ "database" ] := hSqlParams[ "database" ]
   ::hDbPostgresConnectionParams[ "schema" ] := hSqlParams[ "schema" ]
   ::hDbPostgresConnectionParams[ "session" ] := hSqlParams[ "session" ]

   RETURN .T.


METHOD F18Login:set_hDbDataConnectionParams( hSqlParams )

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

   IF ::connect( 0 )
      ::lPostgresDbSpojena := .T.
      RETURN .T.
   ENDIF

   RETURN .T.




METHOD F18Login:login_odabir_organizacije()

   LOCAL nI
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
   cSaveDatabase := ::hDbDataConnectionParams[ "database" ]
   ::hDbDataConnectionParams[ "database" ] := StrTran( cTrenutnaDatabase, "_" + cTrenutnaSezona, "_" + cNovaSezona )
   ::hDbDataConnectionParams[ "session" ] := cNovaSezona

   IF ::connect( 1 )
      _ok := .T.
   ELSE
      MsgBeep( "Traženo sezonsko područje " + cNovaSezona + " ne postoji !" )
      ::hDbDataConnectionParams[ "database" ] := cSaveDatabase // vrati posljednju ispravnu bazu
      ::hDbDataConnectionParams[ "session" ] := cTrenutnaSezona
      IF !::connect( 1 )
         MsgBeep( "Ne mogu se spojiti na " +  cSaveDatabase + "?!" )
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
   hParams[ "posljednja_org" ] := StrTran( ::hDbDataConnectionParams[ "database" ], "_" + cNovaSezona, "" )

   f18_ini_config_write( "sezona", @hParams, .T. )

   RETURN _ok




METHOD F18Login:server_login_form()

   LOCAL cUser, cPassword, _port, _host, _schema
   LOCAL _x := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL _session
   LOCAL _key, _ini_params := hb_Hash()

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

   ++_x
   @ _x, _left SAY PadC( "**** Unesite podatke za pristup *****", 60 )

   _x += 2
   @ _x, _left SAY PadL( "Konfigurisati server ?:", 21 ) GET _srv_config ;
      VALID _srv_config $ "DN" PICT "@!"
   ++_x

   READ

   IF _srv_config == "D"
      ++_x
      @ _x, _left SAY PadL( "Server:", 8 ) GET _host PICT "@S20"
      @ _x, 37 SAY "Port:" GET _port PICT "9999"
   ELSE
      ++_x
   ENDIF

   _x += 2
   @ _x, _left SAY PadL( "KORISNIK:", 15 ) GET cUser PICT "@S30"

   _x += 2
   @ _x, _left SAY PadL( "LOZINKA:", 15 ) GET cPassword PICT "@S30" COLOR F18_COLOR_PASSWORD

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

   LOCAL _session
   LOCAL _x := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL _arr, _tmp
   LOCAL hParams := hb_Hash()
   LOCAL hIniParams := hb_Hash(), cKey
   LOCAL nOrganizacija

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

   ::hDbDataConnectionParams[ "database" ] := AllTrim( ::_company_db_curr_choice ) + ;
      iif( !Empty( _session ), "_" + AllTrim( _session ), "" )
   ::hDbDataConnectionParams[ "session" ] := AllTrim( _session )

   hParams[ "posljednji_put" ] := ::hDbDataConnectionParams[ "session" ]
   hParams[ "posljednja_org" ] := StrTran( ::hDbDataConnectionParams[ "database" ], "_" + ::hDbDataConnectionParams[ "session" ], "" )
   f18_ini_config_write( "sezona", @hParams, .T. ) // nakon odabira organizacije upisi izbor

   RETURN .T.




METHOD F18Login:get_database_sessions( database )

   LOCAL _session := ""
   LOCAL oDataSet, oRow, _db, cQuery
   LOCAL _arr := {}

   IF Empty( database )
      RETURN NIL
   ENDIF

   cQuery := "SELECT DISTINCT substring( datname, '" + AllTrim( database ) +  "_([0-9]+)') AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   oDataSet := postgres_sql_query( cQuery )
   IF sql_error_in_query( oDataSet, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oDataSet:GoTo( 1 )

   DO WHILE !oDataSet:Eof()

      oRow := oDataSet:GetRow()
      _session := oRow:FieldGet( oRow:FieldPos( "godina" ) )

      IF !Empty( _session )
         AAdd( _arr, { _session } )
      ENDIF

      oDataSet:skip()

   ENDDO

   RETURN _arr




METHOD F18Login:get_database_top_session( database )

   LOCAL _session := ""
   LOCAL oDataSet, oRow, _db, cQuery

   cQuery := "SELECT MAX( DISTINCT substring( datname, '" + AllTrim( database ) +  "_([0-9]+)') ) AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   oDataSet := postgres_sql_query( cQuery )
   IF sql_error_in_query( oDataSet, "SELECT", sql_postgres_conn() )
      RETURN NIL
   ENDIF

   oRow := oDataSet:GetRow()
   _session := oRow:FieldGet( oRow:FieldPos( "godina" ) )

   RETURN _session



METHOD F18Login:get_database_description( database, cSezona )

   LOCAL _descr := ""
   LOCAL oDataSet, oRow, cQuery
   LOCAL _database_name := ""

   IF Empty( database )
      RETURN _descr
   ENDIF

   _database_name := database + IF( !Empty( cSezona ), "_" + cSezona, "" )

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




METHOD F18Login:get_database_browse_array( arr )

   LOCAL _arr := {}
   LOCAL _count, _n, _x
   LOCAL _len := 20

   _count := 0
   FOR _n := 1 TO 30

      AAdd( _arr, { "", "", "", "" } )

      FOR _x := 1 TO 4
         ++_count
         _arr[ _n, _x ] := IF( _count > Len( arr ), PadR( "", _len ), PadR( arr[ _count, 1 ], _len ) )
      NEXT

   NEXT

   RETURN _arr



METHOD F18Login:database_array()

   LOCAL oDataSet, oRow, _db, cQuery
   LOCAL _tmp := {}
   LOCAL _filter_db := "empty#empty_sezona"
   LOCAL _where := ""

   _where := " WHERE has_database_privilege( CURRENT_USER, datname, 'connect' ) "

   IF !Empty( ::_include_db_filter )
      _where += " AND " + _sql_cond_parse( "datname", ::_include_db_filter + " " )
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
      IF !Empty( _db ) .AND. ! ( AllTrim( _db ) $ _filter_db )
         AAdd( _tmp, { _db } )
      ENDIF

      oDataSet:Skip()

   ENDDO

   RETURN _tmp




METHOD F18Login:administrative_options( x_pos, y_pos )

   LOCAL _x, _y
   LOCAL aMeniOpcije, _menuexec, _mnu_choice

   _x := x_pos
   _y := ( MAXCOLS() / 2 ) -5


   aMeniOpcije := {} // resetuj
   _menuexec := {}

   _set_menu_choices( @aMeniOpcije, @_menuexec )

   DO WHILE .T.

      _mnu_choice := meni_0_inkey( _x, _y + 1, _x + 5, _y + 40, aMeniOpcije, 1 )

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
   AAdd( menuexec, {|| F18Admin():New():update_app(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "3. update baze" ) )
   AAdd( menuexec, {|| F18Admin():New():update_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "4. nova baza" ) )
   AAdd( menuexec, {|| F18Admin():New():create_new_pg_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "5. brisanje baze" ) )
   AAdd( menuexec, {|| F18Admin():New():drop_pg_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "6. otvaranje nove godine" ) )
   AAdd( menuexec, {|| F18Admin():New():razdvajanje_sezona(), .T. } )

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

   ++_x
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

   LOCAL nI, _l
   LOCAL _key
   LOCAL _br
   LOCAL _opt := 0
   LOCAL _pos_left := 3
   LOCAL _pos_top := 5
   LOCAL _pos_bottom := _pos_top + 12
   LOCAL _pos_right := MAXCOLS() -12
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
   @ _pos_bottom + 3, 2, _pos_bottom + 10, ( _pos_right / 2 ) -3 BOX B_DOUBLE_SINGLE
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
   LOCAL _max_len := MAXCOLS() -2
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
   ++_x
   @ _x, _y SAY "F18 version: " + f18_ver() + " lib: " + f18_lib_ver()

   RETURN .T.



STATIC FUNCTION _get_company_count( arr )

   LOCAL _count := 0, nI, _n

   FOR nI := 1 TO Len( arr )
      FOR _n := 1 TO 4
         IF !Empty( arr[ nI, _n ] )
            ++_count
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
