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

#include "fmk.ch"


// -----------------------------------------------------
// podesenje korisnickih podataka
// -----------------------------------------------------
function f18_set_user_preferences( params )
local _user_id := 0
local _x := 1
local _proper_name
local _user_name
local _active := "D"
local _email
local _qry, _table
local _server := pg_server()
local _show_box := .f.

if params == NIL
    _proper_name := SPACE(50)
    _email := SPACE(50)
    _user_name := ""
    _show_box := .t.
else
    _proper_name := params["proper_name"]
    _email := params["email"]
    _user_name := params["user_name"]
endif

if !EMPTY( _user_name )
    _user_id := GetUserID( _user_name )
endif

if _show_box

    Box(, 6, 65 )

        @ m_x + _x, m_y + 2 SAY "Korisnik (0 - odaberi iz liste):" GET _user_id ;
                VALID { || IIF( _user_id == 0, choose_f18_user_from_list( @_user_id ), .t. ), ;
                    show_it( GetFullUserName( _user_id ), 30 ), .t.  }

        read

        // uzmi ime usera iz liste
        _user_name := GetUserName( _user_id )

        ++ _x
        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Puno ime i prezime:", 20 ) GET _proper_name PICT "@S50"
    
        ++ _x

        @ m_x + _x, m_y + 2 SAY PADL( "Email:", 20 ) GET _email PICT "@S50"
    
        read

    BoxC()

    if LastKey() == K_ESC
        return
    endif

endif


// setuj parametre na sql serveru....
_qry := "SELECT setUserPreference(" + _sql_quote( _user_name ) + ;
          "," + _sql_quote("propername") + "," + _sql_quote( _proper_name ) + ");"

_qry += "SELECT setUserPreference(" + _sql_quote( _user_name ) + ;
          "," + _sql_quote("email") + "," + _sql_quote( _email ) + ");"

_qry += "SELECT setUserPreference(" + _sql_quote( _user_name ) + ;
          "," + _sql_quote("active") + "," + _sql_quote( "t" ) + ");"

_table := _sql_query( _server, _qry )

return




