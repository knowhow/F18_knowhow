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
    METHOD database_array()
    METHOD get_database_top_session()

    DATA _company_db_connected
    DATA _company_db_curr_choice 
    DATA _main_db_connected
    DATA main_db_params
    DATA company_db_params
    DATA _login_count

    METHOD main_db_login_form()
    METHOD company_db_login_form()
    METHOD connect()
    METHOD disconnect()
        
    METHOD _read_params()
    METHOD _write_params()

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
::_login_count := 0
return SELF





METHOD F18Login:connect( params, conn_type, silent )
local _connected

if silent == NIL
    silent := .f.
endif
 
_connected := my_server_login( params, conn_type )

if !silent .and. !_connected
    MsgBeep( hb_utf8tostr( "Neuspješna prijava na server !" ) )
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

// procitaj mi parametre za preduzece
::_read_params( @server_param )

if !_logged_in
    // imamo pravo na 4 pokusaja !
    for _i := 1 to _max_login
        
        // login forma...
        if ! ::company_db_login_form()
            // ovdje naprosto izlazimo, vjerovatno je ESC u pitanju
            return _logged_in
        endif
 
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

endif

return _ok






METHOD F18Login:main_db_login_form()
local _ok := .f.
local _user, _pwd, _port, _host
local _server
local _x := 5
local _left := 7
local _srv_config := "N"

_user := ::main_db_params["username"]
_pwd := ::main_db_params["username"]
_host := ::main_db_params["host"]
_port := ::main_db_params["port"]
_db := ::main_db_params["postgres"]
_schema := ::main_db_params["schema"]

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

@ _x, _left SAY PADL( "LOZINKA:", 15 ) GET _pwd PICT "@S30" COLOR "BG/BG"

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
local _ok := .f.
local _db, _session
local _x := 5
local _left := 7
local _srv_config := "N"
local _arr

_db := ::main_db_params["database"]
_session := ALLTRIM( STR( YEAR( DATE() ) ) )

_db := PADR( _db, 30 )
_session := PADR( _session, 4 )

// daj matricu sa firmama dostupnim...
_arr := ::database_array()

// treba napraviti da ako je jedna baza samo da odmah udje

CLEAR SCREEN

@ 1, 2 SAY "*** ODABIR BAZE " COLOR "I"
@ 2, 2 SAY hb_utf8tostr( " - Strelicama gore/dole/lijevo/desno odaberite željenu bazu " )
@ 3, 2 SAY hb_utf8tostr( " - TAB - ostale opcije / ručno zadavanje konekcije" )

// browsaj listu firmi
_ok := ::browse_database_array( _arr )

if _ok
    
    _session := ::get_database_top_session( ::_company_db_curr_choice )
    
    ::main_db_params["database"] := ALLTRIM( ::_company_db_curr_choice ) + ;
            if( !EMPTY( _session ), "_" + ALLTRIM( _session ), "" )
    ::main_db_params["session"] := ALLTRIM( _session )

endif

return _ok




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




METHOD F18Login:database_array()
local _arr := {}
local _server := pg_server()
local _table, oRow, _db, _qry
local _tmp := {}
local _len := 15
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

_count := 0
// punimo sada matricu _arr
for _n := 1 to 30

    AADD( _arr, { "", "", "", "" } )

    for _x := 1 to 4
        ++ _count
        _arr[ _n, _x ] := IF( _count > LEN( _tmp ), PADR( "", _len ), PADR( _tmp[ _count, 1 ], _len ) )
    next

next

return _arr



METHOD F18Login:manual_enter_company_data( x_pos )
local _x := 21
local _y := 3
local _db := SPACE(20)
local _session := ALLTRIM( STR( YEAR(DATE()) ) )
local _ok := .f.
local _reconf := "N"

_x := x_pos

@ _x, _y SAY "**** Opcije:"
++ _x
@ _x, _y SAY hb_utf8tostr( "Rekonfiguriši server (D/N)?" ) GET _reconf VALID _reconf $ "DN" PICT "@!"

read

if LastKey() == K_ESC
    return _ok    
endif

if _reconf == "D"
    f18_init_app_login( .f. )
    return _ok
endif

++ _x
++ _x

@ _x, _y SAY hb_utf8tostr( "**** Ručni unos podataka za pristup:" )

++ _x

@ _x, _y SAY "  Baza:" GET _db VALID !EMPTY( _db )

++ _x

@ _x, _y SAY "Sezona:" GET _session VALID !EMPTY( _session )

read

if LastKey() == K_ESC
    return _ok    
endif

_ok := .t.

::_company_db_curr_choice := ALLTRIM( _db )

return _ok





METHOD F18Login:browse_database_array( arr, table_type ) 
local _i
local _key
local _br
local _opt := 0
local _pos_left := 3
local _pos_top := 5
local _pos_bottom := _pos_top + 10
local _pos_right := MAXCOLS() - 22
local _company_count 

if table_type == NIL
    table_type := 0
endif

_row := 1

if arr == NIL
    MsgBeep( "Nema podataka za prikaz..." )
    return NIL
endif

// ispitivanje matrice... 
// radi smanjenja forme za odabir firme
_company_count := _get_company_count( arr )
if _company_count <= 4
    _pos_bottom := _pos_top + 1
elseif _company_count <= 20 
    _pos_bottom := _pos_top + 4
elseif _company_count <= 40
    _pos_bottom := _pos_top + 10
endif
// itd... ovo treba vidjeti kako dalje...

@ 0,0 SAY ""
@ 4, 2, _pos_bottom + 1, _pos_right + 2 BOX B_DOUBLE_SINGLE

// TBrowse object for values
// top, left,  bottom, right
_br := TBrowseNew( _pos_top, _pos_left, _pos_bottom, _pos_right )

if table_type == 0
    _br:HeadSep := ""
    _br:FootSep := ""
    _br:ColSep := "   "
elseif table_type == 1
    _br:headSep := "-"
    _br:footSep := "-"
    _br:colSep := " | "
elseif table_type == 2
    _br:HeadSep := hb_UTF8ToStr( "╤═" )
    _br:FootSep := hb_UTF8ToStr( "╧═" )
    _br:ColSep := hb_UTF8ToStr( " │ " )
endif

_br:skipBlock := { | _skip | _skip := _skip_it( arr, _row, _skip ), _row += _skip, _skip }
_br:goTopBlock := { || _row := 1 }
_br:goBottomBlock := { || _row := LEN( arr ) }

for _l := 1 TO LEN( arr[1] )
    _br:addColumn( TBColumnNew( "", _browse_block( arr, _l )) )
next

// vrijednost uzimamo kao:
// EVAL( _br:GetColumn( _br:colpos ):block ) => "cago      "

// main key handler loop
do while ( _key <> K_ESC ) .and. ( _key <> K_RETURN )

    // stabilize the browse and wait for a keystroke
    _br:forcestable()
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
            case ( _key == K_TAB )
                ::manual_enter_company_data( _pos_bottom + 2 )
                return .t.
            case ( _key == K_ENTER )
                ::_company_db_curr_choice := ALLTRIM( EVAL( _br:GetColumn( _br:colpos ):block ) )
                return .t.
        endcase
    endif
enddo

return .f.




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



