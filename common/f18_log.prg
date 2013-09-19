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


// -----------------------------------------------------------
// pregled log-a
// -----------------------------------------------------------
function f18_view_log()
local _params
local _data

// uslovi pregleda...
if !_vars( @_params )
    return
endif

// sql upit...
_data := _log_get_data( _params )

// printanje sadrzaja
_print_log_data( _data, _params )

return




// -----------------------------------------------------------
// uslovi pregleda ...
// -----------------------------------------------------------
static function _vars( params )
local _ok := .f.
local _limit := 0
local _datum_od := DATE()
local _datum_do := DATE()
local _user := PADR( f18_user(), 200 )
local _x := 1
local _conds_true := SPACE(600)
local _conds_false := SPACE(600)
local _f18_doc_oper := "N"

Box(, 12, 70 )

    @ m_x + _x, m_y + 2 SAY "Uslovi za pregled log-a..."

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Datum od" GET _datum_od
    @ m_x + _x, col() + 1 SAY "do" GET _datum_do

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Korisnik (prazno svi):" GET _user PICT "@S40"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "LIKE uslovi:" 

    ++ _x

    @ m_x + _x, m_y + 2 SAY "  sadrzi:" GET _conds_true PICT "@S40"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "nesadrzi:" GET _conds_false PICT "@S40"

    ++ _x
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Pregledaj samo operacije nad dokumentima (D/N)?" GET _f18_doc_oper VALID _f18_doc_oper $ "DN" PICT "@!"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Limit na broj zapisa (0-bez limita)" GET _limit PICT "999999"
    
    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

_ok := .t.

if !EMPTY( _conds_true )
    _conds_true := ALLTRIM( _conds_true ) + SPACE(1)
else
    _conds_true := ""
endif

if !EMPTY( _conds_false )
    _conds_false := ALLTRIM( _conds_false ) + SPACE(1)
else
    _conds_false := ""
endif

// snimi parametre...
params := hb_hash()
params["date_from"] := _datum_od
params["date_to"] := _datum_do
params["user"] := ALLTRIM( _user )
params["limit"] := _limit
params["conds_true"] := _conds_true
params["conds_false"] := _conds_false
params["doc_oper"] := _f18_doc_oper

return _ok





// -----------------------------------------------------------
// vraca podatke prema zadanom sql upitu
// -----------------------------------------------------------
static function _log_get_data( params )
local _user := params["user"]
local _dat_from := params["date_from"]
local _dat_to := params["date_to"]
local _limit := params["limit"]
local _conds_true := params["conds_true"]
local _conds_false := params["conds_false"]
local _is_doc_oper := params["doc_oper"] == "D"
local _qry, _where
local _server := pg_server()
local _data

// WHERE uslov
// ==========================

// datumski uslov
_where := _sql_date_parse( "l_time", _dat_from, _dat_to )

// user
if !EMPTY( _user )
    _where += " AND " + _sql_cond_parse( "user_code", _user )
endif

// dodatni uslovi, sadrzi
if !EMPTY( _conds_true )
    _where += " AND (" + _sql_cond_parse( "msg", _conds_true ) + ")"
endif

// dodatni uslovi, ne-sadrzi
if !EMPTY( _conds_false )
    _where += " AND (" + _sql_cond_parse( "msg", _conds_false, .t. ) + ")"
endif

// samo pregledaj dokument operacije F18
if _is_doc_oper
    _where += " AND ( msg LIKE '%F18_DOK_OPER%' ) " 
endif


// GLAVNI UPIT
// ==========================
// glavni dio upita...
_qry := "SELECT id, user_code, l_time, msg "
_qry += "FROM fmk.log "

// dodaj WHERE
_qry += "WHERE " + _where 

// postavi ORDER
_qry += " ORDER BY id, l_time"

// doaj limit ako treba...
if _limit > 0
    _qry += " LIMIT " + ALLTRIM(STR( _limit )) 
endif

// izvrsi upit
MsgO( "Vrsim upit prema serveru..." )

_data := _sql_query( _server, _qry )

if VALTYPE( _data ) == "L"
    MsgC()
    return NIL
endif

_data:Refresh()

MsgC()

return _data


// -----------------------------------------------------------
// printanje sadrzaja log-a
// -----------------------------------------------------------
static function _print_log_data( data, params )
local _row
local _user, _txt, _date, _id
local _a_txt, _tmp, _i, _pos_y
local _txt_len := 100

// nema zapisa
if data == NIL .or. data:LastRec() == 0
    MsgBeep( "Za zadati uslov ne postoje podaci u log-u !!!" )
    return
endif

START PRINT CRET

?

P_COND

? "PREGLED LOG-a"
? REPLICATE( "-", 130 )
? PADR("log id", 10 ), PADR( "user", 10 ), PADR( "datum", 10 ), "opis..." 
? REPLICATE( "-", 130 )

do while !data:EOF()

    _row := data:GetRow()

    _id := data:FieldGet( data:FieldPos( "id" ) )
    _date := data:FieldGet( data:FieldPos( "l_time" ) )
    _user := hb_utf8tostr( data:FieldGet( data:FieldPos( "user_code" ) ) )
    _txt := hb_utf8tostr( data:FieldGet( data:FieldPos( "msg" ) ) )

    ? PADR( ALLTRIM( STR( _id ) ), 10 )
    @ prow(), pcol() + 1 SAY PADR( _user, 10 )
    @ prow(), _pos_y := pcol() + 1 SAY PADR( _date, 10 )

    // razbij poruku u niz
    _a_txt := SjeciStr( _txt, _txt_len )

    for _i := 1 to LEN( _a_txt )
        if _i > 1
            ?
            @ prow(), _pos_y SAY PAD( _a_txt[ _i ], _txt_len )
        else
            @ prow(), _pos_y := pcol() + 1 SAY PADR( _a_txt[ _i ], _txt_len )
        endif
    next

    data:Skip()

enddo

FF
END PRINT

return



// ------------------------------------------------------------
// brisanje log-a
// ------------------------------------------------------------
function f18_log_delete()
local _params := hb_hash()
local _curr_log_date := DATE()
local _last_log_date := fetch_metric( "log_last_delete_date", NIL, CTOD( "" ) )
local _delete_log_level := fetch_metric( "log_delete_level", NIL, 30 )

if _delete_log_level == 0
    // ne radi nista
    return
endif

// DATE() - 30 > zadnji put brisano !
if ( _curr_log_date - _delete_log_level ) > _last_log_date   

    // brisi sve starije od n dana
    _params["delete_level"] := _delete_log_level
    _params["current_date"] := _curr_log_date

    // brisi log
    if _sql_log_delete( _params )
        // zabiljezi operaciju
        set_metric( "log_last_delete_date", NIL,  _curr_log_date )
    endif

endif

return


// -------------------------------------------------------------
// brisanje log-a za odredjeni datumski period
// -------------------------------------------------------------
static function _sql_log_delete( params )
local _ok := .t.
local _qry, _where
local _server := pg_server()
local _result
local _delete_level := params["delete_level"]
local _curr_date := params["current_date"]
local _delete_date := ( _curr_date - _delete_level )

// WHERE uslov
// ==========================

// datumski uslov
_where := "l_time::char(8) <= " + _sql_quote( _delete_date )
_where += " AND msg NOT LIKE " + _sql_quote( "%F18_DOK_OPER%" )

// GLAVNI UPIT
// ==========================
// glavni dio upita...
_qry := "DELETE FROM fmk.log "
// dodaj WHERE
_qry += "WHERE " + _where 

MsgO( "Brisanje log-a u toku... sacekajte trenutak !" )

_result := _sql_query( _server, _qry )

MsgC()

if VALTYPE( _result ) == "L"
    _ok := .f.
endif

return _ok




