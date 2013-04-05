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

#include "fmk.ch"
#include "hbclass.ch"
#include "common.ch"

CLASS F18Login

    METHOD New()
    METHOD main_db_login()
    METHOD company_db_login()
    METHOD company_db_relogin()
    METHOD browse_database_array()
    METHOD manual_enter_company_data()
    METHOD administrative_options()
    METHOD database_array()
    METHOD get_database_browse_array()
    METHOD get_database_top_session()
    METHOD get_database_sessions()
    METHOD get_database_description()
    METHOD show_info_bar()
    METHOD main_db_login_form()
    METHOD company_db_login_form()
    METHOD connect()
    METHOD disconnect()        
    METHOD _read_params()
    METHOD _write_params()

    DATA _company_db_connected
    DATA _company_db_curr_choice
    DATA _company_db_curr_session 
    DATA _main_db_connected
    DATA main_db_params
    DATA company_db_params
    DATA _login_count

ENDCLASS


// main db connect
// =======================================
// oLogin = F18Login():New()
// oLogin:MainDbLoginForm()
// if !oLogin:_main_db_connected
//   ....
// endif




METHOD F18Login:New()
::main_db_params := hb_hash()
::company_db_params := hb_hash()
::_company_db_curr_choice := ""
::_company_db_curr_session := ""
::_login_count := 0
return SELF





METHOD F18Login:connect( params, conn_type, silent )
local _connected

if silent == NIL
    silent := .f.
endif
 
_connected := my_server_login( params, conn_type )

if !silent .and. !_connected
    //MsgBeep( "Neuspjesna prijava na server !" )
else
    ++ ::_login_count 
endif

return _connected




METHOD F18Login:disconnect()
local _disconn 
_disconn := my_server_logout()
return _disconn





METHOD F18Login:_read_params( server_param )

::main_db_params := hb_hash()
::main_db_params["username"] := server_param["user"]
::main_db_params["password"] := server_param["password"]
::main_db_params["host"] := server_param["host"]
::main_db_params["port"] := server_param["port"]
::main_db_params["database"] := server_param["database"]
::main_db_params["schema"] := server_param["schema"]
::main_db_params["session"] := server_param["session"]
::main_db_params["postgres"] := server_param["postgres"]

return .t.





METHOD F18Login:_write_params( server_params )
server_params["database"] := ::main_db_params["database"]
server_params["session"] := ::main_db_params["session"]
server_params["user"] := ::main_db_params["username"]
server_params["password"] := ::main_db_params["password"]
server_params["host"] := ::main_db_params["host"]
server_params["port"] := ::main_db_params["port"]
server_params["schema"] := ::main_db_params["schema"]
return .t.





METHOD F18Login:main_db_login( server_param, force_connect )
local _max_login := 4
local _i
local _logged_in := .f.

if force_connect == NIL
    force_connect := .t.
endif

// ucitaj parametre iz ini fajla i setuj ::main_db_params
::_read_params( @server_param )

if force_connect .and. ::_main_db_params["username"] <> NIL
    // try to connect
    // if not, open login form
    if ::connect( server_param, 0 )
        _logged_in := .t.
    endif

endif

if !_logged_in
    
    // imamo pravo na 4 pokusaja !
    for _i := 1 to _max_login
       
        // login forma...
        if ! ::main_db_login_form()
            // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
            ::_main_db_connected := _logged_in
            return _logged_in
        endif
       
        ::_write_params( @server_param )

        // zakaci se !
        if ::connect( server_param, 0 )
            _logged_in := .t.
            exit
        endif

    next

endif

::_main_db_connected := _logged_in

return _logged_in





METHOD F18Login:company_db_login( server_param )
local _logged_in := .f.
local _i
local _max_login := 4
local _ret_comp

// procitaj mi parametre za preduzece
::_read_params( @server_param )

if !_logged_in

    // imamo pravo na 4 pokusaja !
    for _i := 1 to _max_login
        
        // login forma...
        _ret_comp := ::company_db_login_form()

        if _ret_comp == 0
            // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
            return _logged_in
        endif

        // neka opcija se koristi...
        if _ret_comp < 0
            loop
        endif
        
        // _rec_comp je > 1 
        ::_write_params( @server_param )
      
        // zakaci se !
        if ::connect( server_param, 1 )
            _logged_in := .t.
            exit
        endif

    next
endif

::_company_db_connected := _logged_in

return







// --------------------------------------------------------------------
// relogin metoda...
// --------------------------------------------------------------------
METHOD F18Login:company_db_relogin( server_param, database, session )
local _ok := .f.
local _new_session := ALLTRIM( STR( YEAR( DATE() ) - 1 ) )
local _curr_database := server_param["database"]
local _curr_session := RIGHT( _curr_database, 4 )
local _show_box := .t.

// uzmi iz proslijedjenih parametara
// ovo omogucava automatski switch na bazu...

if database <> NIL
    _curr_database := database    
    _show_box := .f.
endif

if session <> NIL
    _new_session := session
    _show_box := .f.
endif

// relogin radi samo kod baza "ime_godina"
if ! ( "_" $ _curr_database )
    return _ok
endif

// ovdje se sada moze ubaciti i parametar firme... tako da mozemo skociti i u drugu firmu...

if _show_box

    Box(, 1, 50 )
        @ m_x + 1, m_y + 2 SAY "Pristup podacima sezone:" GET _new_session VALID !EMPTY( _new_session )
        read
    BoxC()

    if LastKey() == K_ESC
        return _ok
    endif

endif

// ako sam u istoj sezoni
if _curr_session == _new_session
    MsgBeep( hb_utf8tostr( "Već se nalazimo u sezoni " ) + _curr_session  )
    return _ok
endif

// promjeni mi podatke... database - bringout_2013 > bringout_2012
server_param["database"] := STRTRAN( _curr_database, _curr_session, _new_session )

// imamo sezonu... sada samo da se prebacimo
if ::connect( server_param, 1 )
    _ok := .t.
endif

// samo ako su uslovi zadovoljeni i ako je prelazak u sezonu sa pitanjem
// ako se koristi direktni prelaz u sezonu onda mi ovo nista nije potrebno
// sve sto treba je konekcija na sql server !

if _ok .and. _show_box
   
    SetgaSDbfs()

    // zatvori mi sve baze aktuelne ako su otvorene
    close all

    set_global_vars_0()

    init_gui( .f. )

    set_global_vars()

    post_login( .f. )
    
    f18_app_parameters( .t. )

    set_hot_keys()

    // init parametara sezonskog podrucja...
    goModul:setGVars()

    // prikazi info baza/user na vrhu u skladu sa tekucom bazom
    say_database_info()

endif

return _ok






METHOD F18Login:main_db_login_form()
local _ok := .f.
local _user, _pwd, _port, _host
local _server
local _x := 5
local _left := 7
local _srv_config := "N"
local _session 

_user := ::main_db_params["username"]
_pwd := ""
//::main_db_params["username"]
_host := ::main_db_params["host"]
_port := ::main_db_params["port"]
_db := ::main_db_params["postgres"]
_schema := ::main_db_params["schema"]
_session := ::main_db_params["session"]

if ( _host == NIL ) .or. ( _port == NIL )
    _srv_config := "D"
endif 

if _host == NIL
    _host := "localhost"
endif

if _port == NIL
    _port := 5432
endif

// ovdje nije fmk
if _schema == NIL
    _schema := "fmk"
endif

if _user == NIL
    _user := "test1"
endif

if _session == NIL
    _session := ALLTRIM( STR( YEAR( DATE() ) ) ) 
endif

_host := PADR( _host, 100 )
_user := PADR( _user, 100 )
_pwd := PADR( _pwd, 100 )

CLEAR SCREEN

@ 5, 5, 18, 77 BOX B_DOUBLE_SINGLE

++ _x

@ _x, _left SAY PADC( "***** Unestite podatke za pristup *****", 60 )

++ _x
++ _x
@ _x, _left SAY PADL( "Konfigurisati server ?:", 21 ) GET _srv_config ;
                    VALID _srv_config $ "DN" PICT "@!"
++ _x

read

if _srv_config == "D"
    ++ _x
    @ _x, _left SAY PADL( "Server:", 8 ) GET _host PICT "@S20"
    @ _x, 37 SAY "Port:" GET _port PICT "9999"
else    
    ++ _x
endif

++ _x
++ _x

@ _x, _left SAY PADL( "KORISNIK:", 15 ) GET _user PICT "@S30"

++ _x
++ _x

@ _x, _left SAY PADL( "LOZINKA:", 15 ) GET _pwd PICT "@S30" //COLOR "BG/BG"

read

if Lastkey() == K_ESC
    return _ok
endif

::main_db_params["username"] := ALLTRIM( _user )
::main_db_params["host"] := ALLTRIM( _host )
::main_db_params["port"] := _port
::main_db_params["schema"] := _schema
::main_db_params["postgres"] := "postgres"
::main_db_params["session"] := ""
::main_db_params["database"] := "postgres"

// omogucice da se korisnici user=password jednostavno logiraju
if EMPTY( _pwd )
    ::main_db_params["password"] := ::main_db_params["username"]
else
    ::main_db_params["password"] := ALLTRIM( _pwd )
endif 

_ok := .t.

return _ok





METHOD F18Login:company_db_login_form()
local _db, _session
local _x := 5
local _left := 7
local _srv_config := "N"
local _arr, _tmp
local _ret := 0

_db := ::main_db_params["database"]
_session := ALLTRIM( STR( YEAR( DATE() ) ) )

_db := PADR( _db, 30 )
_session := PADR( _session, 4 )

// daj matricu sa firmama dostupnim...
_tmp := ::database_array()

// nema firmi ??!???
if LEN( _tmp ) == 0
    MsgBeep( "Na serveru ne postoji definisana niti jedna baza !" )
    // izlazimo
    return 0
endif

// broj firmi je veci od 1
//if LEN( _tmp ) > 1

    // daj mi formiranu matricu za prikaz
    _arr := ::get_database_browse_array( _tmp )

    // treba napraviti da ako je jedna baza samo da odmah udje

    // browsaj listu firmi
    _ret := ::browse_database_array( _arr )

//else
    
    // samo jednu firmu imamo u matrici, odmah se logiraj...

//    ::_company_db_curr_session := NIL
//    ::_company_db_curr_choice := ALLTRIM( _tmp[ 1, 1 ] )

//    _ret := 1

//endif

if _ret > 0
    
    _ok := .t.

    if ::_company_db_curr_session == NIL
        // ako nije zadata sezona... odaberi top sezonu
        // NIL je ako nije zadata...
        _session := ::get_database_top_session( ::_company_db_curr_choice )
    else    
        // ako je zadata... uzmi nju !
        _session := ALLTRIM( ::_company_db_curr_session )
    endif
    
    ::main_db_params["database"] := ALLTRIM( ::_company_db_curr_choice ) + ;
            IF( !EMPTY( _session ), "_" + ALLTRIM( _session ), "" )
    ::main_db_params["session"] := ALLTRIM( _session )

endif

return _ret




METHOD F18Login:get_database_sessions( database )
local _session := ""
local _server := pg_server()
local _table, oRow, _db, _qry
local _arr := {}

if EMPTY( database )
    return NIL
endif

_qry := "SELECT DISTINCT substring( datname, '" + ALLTRIM( database ) +  "_([0-9]+)') AS godina " + ;
        "FROM pg_database " + ;
        "ORDER BY godina"

_table := _sql_query( _server, _qry )
_table:Refresh()

if _table == NIL
    return NIL
endif

_table:GoTo(1)

do while !_table:EOF()

    oRow := _table:GetRow()
    _session := oRow:FieldGet( oRow:FieldPos( "godina" ) )

    if !EMPTY( _session )
        AADD( _arr, { _session } )
    endif

    _table:skip()

enddo

return _arr




METHOD F18Login:get_database_top_session( database )
local _session := ""
local _server := pg_server()
local _table, oRow, _db, _qry

_qry := "SELECT MAX( DISTINCT substring( datname, '" + ALLTRIM( database ) +  "_([0-9]+)') ) AS godina " + ;
        "FROM pg_database " + ;
        "ORDER BY godina"

_table := _sql_query( _server, _qry )
_table:Refresh()

if _table == NIL
    return NIL
endif

oRow := _table:GetRow()
_session := oRow:FieldGet( oRow:FieldPos( "godina") )

return _session



METHOD F18Login:get_database_description( database, session )
local _descr := ""
local _server := pg_server()
local _table, oRow, _qry
local _database_name := ""

if EMPTY( database )
    return _descr
endif

_database_name := database + IF( !EMPTY( session ), "_" + session, "" )

_qry := "SELECT description AS opis " + ;
        "FROM pg_shdescription " + ;
        "JOIN pg_database on objoid = pg_database.oid " + ;
        "WHERE datname = " + _sql_quote( _database_name )

_table := _sql_query( _server, _qry )
_table:Refresh()

if _table == NIL
    return NIL
endif

oRow := _table:GetRow()

if oRow <> NIL
    _descr := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "opis" ) ) )
else
    _descr := "< naziv nije setovan >"
endif

return _descr






METHOD F18Login:get_database_browse_array( arr )
local _arr := {}
local _count, _n, _x
local _len := 20

_count := 0
// punimo sada matricu _arr
for _n := 1 to 30

    AADD( _arr, { "", "", "", "" } )

    for _x := 1 to 4
        ++ _count
        _arr[ _n, _x ] := IF( _count > LEN( arr ), PADR( "", _len ), PADR( arr[ _count, 1 ], _len ) )
    next

next

return _arr




METHOD F18Login:database_array()
local _server := pg_server()
local _table, oRow, _db, _qry
local _tmp := {}
local _filter_db := "empty#empty_sezona"

_qry := "SELECT DISTINCT substring( datname, '(.*)_[0-9]+') AS datab " + ;
        " FROM pg_database " + ;
        " ORDER BY datab"

_table := _sql_query( _server, _qry )
_table:Refresh()

if _table == NIL
    return NIL
endif

_table:GoTo(1)

do while !_table:EOF()
    
    oRow := _table:GetRow()
    _db := oRow:FieldGet( oRow:FieldPos( "datab" ) )
    
    // filter za tabele
    if !EMPTY( _db ) .and. ! ( ALLTRIM( _db ) $ _filter_db )
        AADD( _tmp, { _db } )    
    endif

    _table:Skip()

enddo

return _tmp




METHOD F18Login:administrative_options( x_pos, y_pos )
local _ok := .f.
local _x, _y
local _menuop, _menuexec

_x := x_pos
_y := ( MAXCOLS() / 2 ) - 5

// resetuj...
_menuop := {}
_menuexec := {}

// setuj odabir
_set_menu_choices( @_menuop, @_menuexec )

do while .t.

    _mnu_choice := ACHOICE2( _x, _y + 1, _x + 5, _y + 40, _menuop, .t., "MenuFunc", 1 )

 	do case
	    case _mnu_choice == 0
            exit
		case _mnu_choice > 0 
			EVAL( _menuexec[ _mnu_choice ] )
	endcase

 	loop

enddo

return _ok




static function _set_menu_choices( menuop, menuexec )

AADD( menuop, hb_utf8tostr( "1. rekonfiguracija servera " ) )
AADD( menuexec, {|| f18_init_app_login( .f. ), .t. } )
AADD( menuop, hb_utf8tostr( "2. update db" ) )
AADD( menuexec, {|| F18AdminOpts():New():update_db(), .t. } )
AADD( menuop, hb_utf8tostr( "3. vpn podrska" ) )
AADD( menuexec, {|| vpn_support( .f. ), .t. } )


return





METHOD F18Login:manual_enter_company_data( x_pos, y_pos )
local _x
local _y := 3
local _db := SPACE(20)
local _session := ALLTRIM( STR( YEAR(DATE()) ) )
local _ok := .f.

_x := x_pos

@ _x, _y + 1 SAY hb_utf8tostr( "Pristupiti sljedećoj bazi:" )

++ _x
++ _x

@ _x, _y + 3 SAY SPACE( 30 )
@ _x, _y + 3 SAY "  Baza:" GET _db VALID !EMPTY( _db )

++ _x

@ _x, _y  + 3 SAY "Sezona:" GET _session 

read

if LastKey() == K_ESC
    return _ok    
endif

if LastKey() == K_ENTER
    _ok := .t.
    ::_company_db_curr_choice := ALLTRIM( _db )
    ::_company_db_curr_session := ALLTRIM( _session )
endif

return _ok



// -------------------------------------------------------
// vraca 0 - ESC
// -1 - loop
// 1 - ENTER
// -------------------------------------------------------

METHOD F18Login:browse_database_array( arr, table_type ) 
local _i
local _key
local _br
local _opt := 0
local _pos_left := 3
local _pos_top := 5
local _pos_bottom := _pos_top + 12
local _pos_right := MAXCOLS() - 12
local _company_count 

if table_type == NIL
    table_type := 0
endif

_row := 1

if arr == NIL
    MsgBeep( "Nema podataka za prikaz..." )
    return NIL
endif

// stvarni broj aktuelenih firmi 
_company_count := _get_company_count( arr )

CLEAR SCREEN

@ 0,0 SAY ""

// opcija 1
// =========================

@ 1, 3 SAY hb_utf8tostr( "[1] Odabir baze" ) COLOR "I"

@ 2, 2 SAY hb_utf8tostr( " - Strelicama odaberite željenu bazu " )

@ 3, 2 SAY hb_utf8tostr( " - <TAB> ručno zadavanje konekcije  <F10> admin. opcije  <ESC> izlaz" )

// top, left, bottom, right

// box za selekciju firme....
@ 4, 2, _pos_bottom + 1, _pos_right + 2 BOX B_DOUBLE_SINGLE

// opcija 2
// =========================
// ispis opisa
@ _pos_bottom + 2, 3 SAY hb_utf8tostr( "[2] Ručna konekcija na bazu" ) COLOR "I"

// box za rucni odabir firme
@ _pos_bottom + 3, 2, _pos_bottom + 10, ( _pos_right / 2 ) - 3 BOX B_DOUBLE_SINGLE
@ _pos_bottom + 6, 11 SAY hb_utf8tostr( "<<< pritisni TAB >>>" )

// opcija 3
// =========================
// ispis opisa
@ _pos_bottom + 2, ( _pos_right / 2 ) + 1 SAY hb_utf8tostr( "[3] Administrativne opcije" ) COLOR "I"

// box za administrativne opcije
@ _pos_bottom + 3,  ( _pos_right / 2 ) , _pos_bottom + 10, _pos_right + 2 BOX B_DOUBLE_SINGLE
@ _pos_bottom + 6, ( _pos_right / 2 ) + 12 SAY hb_utf8tostr( "<<< pritisni F10 >>>" )

_br := TBrowseNew( _pos_top, _pos_left, _pos_bottom, _pos_right )

if table_type == 0
    _br:HeadSep := ""
    _br:FootSep := ""
    _br:ColSep := " "
elseif table_type == 1
    _br:headSep := "-"
    _br:footSep := "-"
    _br:colSep := "|"
elseif table_type == 2
    _br:HeadSep := hb_UTF8ToStr( "╤═" )
    _br:FootSep := hb_UTF8ToStr( "╧═" )
    _br:ColSep := hb_UTF8ToStr( "│" )
endif

_br:skipBlock := { | _skip | _skip := _skip_it( arr, _row, _skip ), _row += _skip, _skip }
_br:goTopBlock := { || _row := 1 }
_br:goBottomBlock := { || _row := LEN( arr ) }

for _l := 1 TO LEN( arr[ 1 ] )
    _br:addColumn( TBColumnNew( "", _browse_block( arr, _l )) )
next

// vrijednost uzimamo kao:
// EVAL( _br:GetColumn( _br:colpos ):block ) => "cago      "

// main key handler loop
do while ( _key <> K_ESC ) .and. ( _key <> K_RETURN )

    // stabilize the browse and wait for a keystroke
    _br:forcestable()
    
    ::show_info_bar( ALLTRIM( EVAL( _br:GetColumn( _br:colpos ):block ) ), _pos_bottom + 4 )
    
    _key := inkey( 0 )

    // process the directional keys
    if _br:stable

        do case
                
            case ( _key == K_DOWN )
                _br:down()
            case ( _key == K_UP )
                _br:up()
            case ( _key == K_RIGHT )
                _br:right()
            case ( _key == K_LEFT )
                _br:left()
            case ( _key == K_F10 )
                ::administrative_options( _pos_bottom + 4, _pos_left )
                return -1
            case ( _key == K_TAB )
                if ::manual_enter_company_data( _pos_bottom + 4, _pos_left )
                    return 1
                else
                    return -1
                endif
            case ( _key == K_ENTER )
                // ovo je firma koju smo odabrali...
                ::_company_db_curr_choice := ALLTRIM( EVAL( _br:GetColumn( _br:colpos ):block ) )
                // sezona treba da bude uzeta kao TOP sezona
                ::_company_db_curr_session := NIL
                return 1
        endcase
    
    endif

enddo

return 0



METHOD F18Login:show_info_bar( database, x_pos )
local _x := x_pos + 7
local _y := 3
local _info := ""
local _arr := ::get_database_sessions( database )
local _max_len := MAXCOLS() - 2
local _descr := ""

if !_arr == NIL .and. LEN( _arr ) > 0

    _descr := ::get_database_description( database, _arr[ LEN( _arr ), 1 ] )

    _info += ALLTRIM( _descr )

    if LEN( _arr ) > 1
        _info += ", dostupne sezone: " + _arr[ 1, 1 ] + " ... " + _arr[ LEN( _arr ), 1 ]
    else
        _info += ", sezona: " + _arr[ 1, 1 ]
    endif

endif

@ _x, _y SAY PADR( "Info: " + _info, _max_len )

return .t.



static function _get_company_count( arr )
local _count := 0

for _i := 1 to LEN( arr )
    for _n := 1 to 4
        if !EMPTY( arr[ _i, _n ] )
            ++ _count
        endif
    next
next

return _count




static function _browse_block( arr, x )
return ( {|p| if( PCount() == 0, arr[ _row, x ], arr[ _row, x ] := p ) } )



static function _skip_it( arr, curr, skiped )

if ( curr + skiped < 1 )
    // Would skip past the top...
    return( -curr + 1 )
elseif ( curr + skiped > LEN( arr ) )
    // Would skip past the bottom...
    return ( LEN( arr ) - curr )
endif

return( skiped )



