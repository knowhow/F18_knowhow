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

STATIC s_cTekucaSezona
STATIC s_cPredhodnaSezona
STATIC s_lPrvoPokretanje // prvo pokretanje aplikacije

CLASS F18Login

   METHOD New()
   METHOD main_db_login()
   METHOD login_odabir_organizacije()
   METHOD promjena_sezone()
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
   METHOD main_db_login_form()
   METHOD odabir_organizacije()
   METHOD connect()
   METHOD disconnect()
   METHOD set_main_db_params()
   METHOD set_server_params( server_params )
   METHOD included_databases_for_user()

   DATA _company_db_connected
   DATA _company_db_curr_choice
   DATA _company_db_curr_session
   DATA _main_db_connected
   DATA main_db_params
   DATA company_db_params
   DATA _login_count
   DATA _include_db_filter

ENDCLASS


// main db connect
// =======================================
// oLogin = F18Login():New()
// oLogin:MainDbLoginForm()
// if !oLogin:_main_db_connected
// ....
// endif


METHOD F18Login:New()

   ::main_db_params := hb_Hash()
   ::company_db_params := hb_Hash()
   ::_company_db_curr_choice := ""
   ::_company_db_curr_session := ""
   ::_login_count := 0
   ::_include_db_filter := ""
   s_cTekucaSezona := AllTrim( Str( Year( Date() ) ) )
   s_cPredhodnaSezona := AllTrim( Str( Year( Date() ) - 1 ) )
   s_lPrvoPokretanje := .T.

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


METHOD F18Login:connect( params, conn_type, silent )

   LOCAL _connected

   IF silent == NIL
      silent := .F.
   ENDIF

   _connected := my_server_login( params, conn_type )

   IF !silent .AND. !_connected
   ELSE
      ++ ::_login_count
   ENDIF

   RETURN _connected




METHOD F18Login:disconnect()

   LOCAL _disconn

   _disconn := my_server_logout()

   RETURN _disconn





METHOD F18Login:set_main_db_params( server_param )

   ::main_db_params := hb_Hash()
   ::main_db_params[ "username" ] := server_param[ "user" ]
   ::main_db_params[ "password" ] := server_param[ "password" ]
   ::main_db_params[ "host" ] := server_param[ "host" ]
   ::main_db_params[ "port" ] := server_param[ "port" ]
   ::main_db_params[ "database" ] := server_param[ "database" ]
   ::main_db_params[ "schema" ] := server_param[ "schema" ]
   ::main_db_params[ "session" ] := server_param[ "session" ]
   ::main_db_params[ "postgres" ] := server_param[ "postgres" ]

   RETURN .T.


METHOD F18Login:set_server_params( server_params )

   server_params[ "database" ] := ::main_db_params[ "database" ]
   server_params[ "session" ] := ::main_db_params[ "session" ]
   server_params[ "user" ] := ::main_db_params[ "username" ]
   server_params[ "password" ] := ::main_db_params[ "password" ]
   server_params[ "host" ] := ::main_db_params[ "host" ]
   server_params[ "port" ] := ::main_db_params[ "port" ]
   server_params[ "schema" ] := ::main_db_params[ "schema" ]

   RETURN .T.


METHOD F18Login:main_db_login( server_param, force_connect )

   LOCAL _max_login := 4
   LOCAL _i
   LOCAL _logged_in := .F.

   IF force_connect == NIL
      force_connect := .T.
   ENDIF

   ::set_main_db_params( @server_param ) // ucitaj parametre iz ini fajla i setuj ::main_db_params

   IF force_connect .AND. ::_main_db_params[ "username" ] <> NIL
      // try to connect
      // if not, open login form
      if ::connect( server_param, 0 )
         _logged_in := .T.
      ENDIF

   ENDIF

   IF !_logged_in

      // imamo pravo na 4 pokusaja !
      FOR _i := 1 TO _max_login

         // login forma...
         IF ! ::main_db_login_form()
            // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
            ::_main_db_connected := _logged_in
            RETURN _logged_in
         ENDIF

         ::set_server_params( @server_param )

         // zakaci se !
         if ::connect( server_param, 0 )
            _logged_in := .T.
            EXIT
         ENDIF

      NEXT

   ENDIF

   ::_main_db_connected := _logged_in

   RETURN _logged_in





METHOD F18Login:login_odabir_organizacije( server_param )

   LOCAL _logged_in := .F.
   LOCAL _i
   LOCAL _max_login := 4
   LOCAL _ret_comp


   ::set_main_db_params( @server_param ) // procitaj parametre za preduzece

   IF !_logged_in


      FOR _i := 1 TO _max_login // imamo pravo na 4 pokusaja !

         IF ! ::odabir_organizacije()
            RETURN _logged_in // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
         ENDIF

         ::set_server_params( @server_param ) // _rec_comp je > 1
         if ::connect( server_param, 1 )
            _logged_in := .T.
            EXIT
         ENDIF

      NEXT
   ENDIF

   ::_company_db_connected := _logged_in

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


METHOD F18Login:promjena_sezone( server_param, cDatabase, cSezona )

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
      cTrenutnaDatabase := server_param[ "database" ]
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

   // bringout_2016 => bringout_2015

   cTrenutnaSezona := Right( cTrenutnaDatabase, 4 )
   cSaveDatabase := server_param[ "database" ]
   server_param[ "database" ] := StrTran( cTrenutnaDatabase, "_" + cTrenutnaSezona, "_" + cNovaSezona )

   IF ::connect( server_param, 1 )
      _ok := .T.
   ELSE
      server_param[ "database" ] := cSaveDatabase // vrati posljednju ispravnu bazu
      MsgBeep( "Traženo sezonsko područje " + cNovaSezona + " ne postoji !" )
   ENDIF

   IF _ok .AND. _show_box

      IF _modul_name != NIL .AND. !f18_use_module( _modul_name )
         MsgBeep( "U " + AllTrim( s_cPredhodnaSezona ) + " programski modul " + Upper( _modul_name ) + " vam nije aktiviran !" )
         IF Pitanje(, "Želite li korisiti programski modul " + Upper( _modul_name ) + " u sezoni " + s_cPredhodnaSezona + " (D/N) ?", "N" ) == "D"
            f18_set_use_module( _modul_name, .T. )
         ELSE
            MsgBeep( "Vraćamo se u sezonu " + cTrenutnaSezona )
            ::promjena_sezone( server_param, cTrenutnaDatabase, cTrenutnaSezona )
         ENDIF
      ENDIF

      CLOSE ALL
      post_login( .F. )


   ENDIF

   hParams[ "posljednji_put" ] := cNovaSezona
   // ako je baza bringout_2014, hparams[ posljednja_org ] ce biti bringout
   hParams[ "posljednja_org" ] := StrTran( server_param[ "database" ], "_" + cNovaSezona, "" )

   f18_ini_config_write( "sezona", @hParams, .T. )

   RETURN _ok






METHOD F18Login:main_db_login_form()

   LOCAL _ok := .F.
   LOCAL _user, _pwd, _port, _host
   LOCAL _server
   LOCAL _x := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL _session

   _user := ::main_db_params[ "username" ]
   _pwd := ""
   // ::main_db_params["username"]
   _host := ::main_db_params[ "host" ]
   _port := ::main_db_params[ "port" ]
   _db := ::main_db_params[ "postgres" ]
   _schema := ::main_db_params[ "schema" ]
   _session := ::main_db_params[ "session" ]

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
   @ _x, _left SAY PadC( "***** Unestite podatke za pristup *****", 60 )

   ++ _x
   ++ _x
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

   ++ _x
   ++ _x
   @ _x, _left SAY PadL( "KORISNIK:", 15 ) GET _user PICT "@S30"

   ++ _x
   ++ _x
   @ _x, _left SAY PadL( "LOZINKA:", 15 ) GET _pwd PICT "@S30" COLOR F18_COLOR_PASSWORD

   READ

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   ::main_db_params[ "username" ] := AllTrim( _user )
   ::main_db_params[ "host" ] := AllTrim( _host )
   ::main_db_params[ "port" ] := _port
   ::main_db_params[ "schema" ] := _schema
   ::main_db_params[ "postgres" ] := "postgres"
   ::main_db_params[ "session" ] := ""
   ::main_db_params[ "database" ] := "postgres"


   IF Empty( _pwd ) // korisnici user=password se jednostavno logiraju
      ::main_db_params[ "password" ] := ::main_db_params[ "username" ]
   ELSE
      ::main_db_params[ "password" ] := AllTrim( _pwd )
   ENDIF

   _ok := .T.

   RETURN _ok



METHOD F18Login:odabir_organizacije()

   LOCAL _db, _session
   LOCAL _x := 5
   LOCAL _left := 7
   LOCAL _srv_config := "N"
   LOCAL _arr, _tmp
   LOCAL hParams := hb_Hash()
   LOCAL nOrganizacija

   _db := ::main_db_params[ "database" ]
   _session := AllTrim( Str( Year( Date() ) ) )

   _db := PadR( _db, 30 )
   _session := PadR( _session, 4 )

   ::included_databases_for_user()  // filter baza dostupnih useru, ako postoji !

   hParams[ "posljednji_put" ] := "0000"
   hParams[ "posljednja_org" ] := "x"
   f18_ini_config_read( "sezona", @hParams, .T. ) // read from global ~/.f18_config.ini

   IF s_lPrvoPokretanje .AND. hParams[ "posljednja_org" ] != "x" // odmah se prebaciti  posljednju organizaciju/sezonu
      ::main_db_params[ "database" ] :=  hParams[ "posljednja_org" ] + "_" + hParams[ "posljednji_put" ]
      ::main_db_params[ "session" ] := hParams[ "posljednji_put" ]
      s_lPrvoPokretanje := .F.
      RETURN .T.
   ENDIF

   _tmp := ::database_array()

   IF Len( _tmp ) == 0
      MsgBeep( "Na serveru ne postoji definisana niti jedna baza !" )
      RETURN .F.
   ENDIF

   _arr := ::get_database_browse_array( _tmp ) // odaberi organizaciju
   nOrganizacija := ::browse_odabir_organizacije( _arr ) // browsaj listu organizacija

   IF nOrganizacija < 1
      RETURN .F.
   ENDIF

   if ::_company_db_curr_session == NIL
      _session := ::get_database_top_session( ::_company_db_curr_choice ) // ako nije zadata sezona odaberi top sezonu, NIL je ako nije zadata
   ELSE
      _session := AllTrim( ::_company_db_curr_session ) // ako je zadata uzmi nju
   ENDIF

   ::main_db_params[ "database" ] := AllTrim( ::_company_db_curr_choice ) + ;
      IIF( !Empty( _session ), "_" + AllTrim( _session ), "" )
   ::main_db_params[ "session" ] := AllTrim( _session )


   hParams[ "posljednji_put" ] := ::main_db_params[ "session" ]
   hParams[ "posljednja_org" ] := StrTran( ::main_db_params[ "database" ], "_" + ::main_db_params[ "session" ], "" )
   f18_ini_config_write( "sezona", @hParams, .T. ) // nakon odabira organizacije upisi izbor

   RETURN .T.




METHOD F18Login:get_database_sessions( database )

   LOCAL _session := ""
   LOCAL _server := pg_server()
   LOCAL _table, oRow, _db, _qry
   LOCAL _arr := {}

   IF Empty( database )
      RETURN NIL
   ENDIF

   _qry := "SELECT DISTINCT substring( datname, '" + AllTrim( database ) +  "_([0-9]+)') AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   _table := _sql_query( _server, _qry )

   IF _table == NIL
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
   LOCAL _server := pg_server()
   LOCAL _table, oRow, _db, _qry

   _qry := "SELECT MAX( DISTINCT substring( datname, '" + AllTrim( database ) +  "_([0-9]+)') ) AS godina " + ;
      "FROM pg_database " + ;
      "ORDER BY godina"

   _table := _sql_query( _server, _qry )

   IF _table == NIL
      RETURN NIL
   ENDIF

   oRow := _table:GetRow()
   _session := oRow:FieldGet( oRow:FieldPos( "godina" ) )

   RETURN _session



METHOD F18Login:get_database_description( database, cSezona )

   LOCAL _descr := ""
   LOCAL _server := pg_server()
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

   _table := _sql_query( _server, _qry )

   IF _table == NIL
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
   // punimo sada matricu _arr
   FOR _n := 1 TO 30

      AAdd( _arr, { "", "", "", "" } )

      FOR _x := 1 TO 4
         ++ _count
         _arr[ _n, _x ] := IF( _count > Len( arr ), PadR( "", _len ), PadR( arr[ _count, 1 ], _len ) )
      NEXT

   NEXT

   RETURN _arr




METHOD F18Login:database_array()

   LOCAL _server := pg_server()
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

   _table := _sql_query( _server, _qry )

   IF _table == NIL
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

   LOCAL _ok := .F.
   LOCAL _x, _y
   LOCAL _menuop, _menuexec

   _x := x_pos
   _y := ( MAXCOLS() / 2 ) - 5

   // resetuj...
   _menuop := {}
   _menuexec := {}

   // setuj odabir
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

   RETURN _ok




STATIC FUNCTION _set_menu_choices( menuop, menuexec )

   AAdd( menuop, hb_UTF8ToStr( "1. rekonfiguracija servera        " ) )
   AAdd( menuexec, {|| f18_login( .F. ), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "2. update F18" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():update_app(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "3. update baze" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():update_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "4. nova baza" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():create_new_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "5. brisanje baze" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():drop_db(), .T. } )

   AAdd( menuop, hb_UTF8ToStr( "6. otvaranje nove godine" ) )
   AAdd( menuexec, {|| F18AdminOpts():New():new_session(), .T. } )

   RETURN .T.





METHOD F18Login:manual_enter_company_data( x_pos, y_pos )

   LOCAL _x
   LOCAL _y := 3
   LOCAL _db := Space( 20 )
   LOCAL _session := AllTrim( Str( Year( Date() ) ) )
   LOCAL _ok := .F.

   _x := x_pos

   @ _x, _y + 1 SAY hb_UTF8ToStr( "Pristupiti sljedećoj bazi:" )

   ++ _x
   ++ _x
   @ _x, _y + 3 SAY Space( 30 )
   @ _x, _y + 3 SAY "  Baza:" GET _db VALID !Empty( _db )

   ++ _x
   @ _x, _y  + 3 SAY "Sezona:" GET _session

   READ

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   IF LastKey() == K_ENTER
      _ok := .T.
      ::_company_db_curr_choice := AllTrim( _db )
      ::_company_db_curr_session := AllTrim( _session )
   ENDIF

   RETURN _ok



// -------------------------------------------------------
// vraca 0 - ESC
// -1 - loop
// 1 - ENTER
// -------------------------------------------------------

METHOD F18Login:browse_odabir_organizacije( arr, table_type )

   LOCAL _i
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

   //SetColor( F18_COLOR_ORGANIZACIJA )

   _row := 1

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

      // process the directional keys
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

   LOCAL _count := 0

   FOR _i := 1 TO Len( arr )
      FOR _n := 1 TO 4
         IF !Empty( arr[ _i, _n ] )
            ++ _count
         ENDIF
      NEXT
   NEXT

   RETURN _count




STATIC FUNCTION _browse_block( arr, x )
   RETURN ( {| p| if( PCount() == 0, arr[ _row, x ], arr[ _row, x ] := p ) } )



STATIC FUNCTION _skip_it( arr, curr, skiped )

   IF ( curr + skiped < 1 )
      // Would skip past the top...
      RETURN( -curr + 1 )
   ELSEIF ( curr + skiped > Len( arr ) )
      // Would skip past the bottom...
      RETURN ( Len( arr ) - curr )
   ENDIF

   RETURN( skiped )
