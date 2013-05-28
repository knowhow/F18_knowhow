/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "rnal.ch"



// --------------------------------------------------------
// prebaci sve iz doc_ops u _doc_ops
// --------------------------------------------------------
function rnal_doc_ops_to_tmp( r_doc_no )
local _count := 0, _rec 

select ( F_DOC_OPS )
if !USED()
    O_DOC_OPS
endif

select ( F__DOC_OPST )
if !USED()
    O__DOC_OPST
endif

select _doc_opst
if RECCOUNT() > 0
    zap
    __dbPack()
endif

select doc_ops
set order to tag "1"
go top

seek docno_str( r_doc_no )

if !FOUND()
    // nema naloga
    MsgBeep("Ovaj nalog ne postoji !!!")
    return _count
endif

MsgO( "Kopiram operacije naloga u pripremu ..." )

do while !EOF() .and. field->doc_no == r_doc_no
    
    ++ _count
    
    _rec := dbf_get_rec()
    
    select _doc_opst
    APPEND BLANK
    
    dbf_update_rec( _rec )

    select doc_ops    
    skip

enddo

MsgC()

return _count



// --------------------------------------------------------
// azuriranje statusa 
// --------------------------------------------------------
function rnal_azuriraj_statuse( doc_no )
local _ok := .f.
local _promjena := .f.
local _promj_count := 0

if !f18_lock_tables( { "rnal_doc_ops" } )
    MsgBeep( "Problem sa lock tabele doc_ops !!!" )
    return _ok
endif
sql_table_update( nil, "BEGIN" )

// sinhronizuj podatke na server
select _doc_opst
set order to tag "1"
go top

do while !EOF()

    _rec := dbf_get_rec()

    select doc_ops
    // "1", "STR(doc_no,10)+STR(doc_it_no,4)+STR(doc_op_no,4)"
    set order to tag "1"
    go top
    seek docno_str( _rec["doc_no" ] ) + docit_str( _rec["doc_it_no"] ) + STR( _rec["doc_op_no"], 4 )

    // nisam nasao !!!!
    if !FOUND()
        select _doc_opst
        skip
        loop
    endif

    _rec_ops := dbf_get_rec()
    _promjena := .f.

    if _rec_ops["op_status"] <> _rec["op_status"]
        _rec_ops["op_status"] := _rec["op_status"]
        _promjena := .t.
    endif

    if _rec_ops["op_notes"] <> _rec["op_notes"]
        _rec_ops["op_notes"] := _rec["op_notes"]
        _promjena := .t.
    endif

    // samo ako postoje promjene...
    if _promjena
        update_rec_server_and_dbf( "rnal_doc_ops", _rec, 1, "CONT" )
        ++ _promj_count 
    endif

    // idi na sljedeci zapis...
    select _doc_opst
    skip

enddo

f18_free_tables( { "rnal_doc_ops" } )
sql_table_update( nil, "END" )

// pobrisi pripremu...
select _doc_opst
zap
__dbPack()

return _ok




static function _nalog()
local _nalog := 0

Box(, 1, 60 )
    @ m_x + 1, m_y + 2 SAY "Pregledati za nalog:" GET _nalog PICT "9999999999" VALID _nalog > 0
    read
BoxC()

if LastKey() == K_ESC
    _nalog := NIL
endif

return _nalog


// --------------------------------------------------------
// tabela pregleda statusa operacija
// --------------------------------------------------------
function rnal_pregled_statusa_operacija( r_doc_no )
local _ok := .t.
local _footer
local _header
local _box_x := maxrows() - 10
local _box_y := maxcols() - 10

private imekol
private kol

if r_doc_no == NIL
    r_doc_no := _nalog()
    if r_doc_no == NIL
        return _ok
    endif
endif

o_tables( .t. )

// prebaci sve iz kum u pripr
if rnal_doc_ops_to_tmp( r_doc_no ) < 1
    MsgBeep( "Nalog ne sadrzi niti jednu operaciju !!!" )
    return _ok
endif

_footer := "Pregled statusa naloga " + ALLTRIM( STR( r_doc_no, 10, 0 ) )
_header := ""

Box(, _box_x, _box_y )

// setuj box opis...
_set_box( _box_x, _box_y )
_set_a_kol( @imekol, @kol )

select ( F__DOC_OPST )
if !USED()
    O__DOC_OPST
endif

select _doc_opst
go top

ObjDbedit( "nalst", _box_x, _box_y, {|| key_handler( r_doc_no ) }, _header, _footer, , , , , 5 )

BoxC()

if LastKey() == K_ESC

    if Pitanje(, "Azurirati promjene na server (D/N) ?", "D" ) == "D"
        // izlaz mi je bitan radi sinhronizacije ...
        rnal_azuriraj_statuse( r_doc_no )
    endif

endif

close all

return _ok



// --------------------------------------------------------
// obrada tipki
// --------------------------------------------------------
static function key_handler( doc )

do case

    case Ch == K_F2

        // setovanje statusa operacije
        _rec := dbf_get_rec()
        if _setuj_status( @_rec )
            dbf_update_rec( _rec )
            return DE_REFRESH
        endif
        
endcase

return DE_CONT



// ---------------------------------------------------
// setuj status ...
// ---------------------------------------------------
static function _setuj_status( rec )
local _ok := .f.
local _x := 1
local _op_status := _rec["op_status"]
local _op_notes := _rec["op_notes"]

Box(, 10, 70 )

    @ m_x + _x, m_y + 2 SAY "Postavi status tekuce stavke na "

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "  - '1' - zavrseno "

    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "  - prazno - u izradi"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "           -> odabrani status: " GET _op_status VALID _op_status $ " #1#2"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Napomena:" GET _op_notes PICT "@S50"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

_ok := .t.
_rec["op_notes"] := _op_notes
_rec["op_status"] := _op_status

return _ok



// ------------------------------------------
// setovanje boxa
// box_x - box x koord.
// box_y - box y koord.
// ------------------------------------------
static function _set_box( box_x, box_y )
local _line_1 := ""
local _line_2 := ""

_line_1 := "(F2) setuj status"
_line_2 := "-- "

@ m_x + ( box_x - 1 ), m_y + 2 SAY _line_1
@ m_x + box_x, m_y + 2 SAY _line_2

return



// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function _set_a_kol( a_ime_kol, a_kol )
local _i

a_ime_kol := {}
a_kol := {}

AADD( a_ime_kol, { "Artikal", ;
	{|| PADR( g_art_desc( _get_doc_article( doc_no, doc_it_no ), .t., .f. ), 20 ) }, ;
	"doc_no", ;
	{|| .t.}, ;
	{|| .t.} })


AADD( a_ime_kol, { "Element", ;
	{|| PADR( _get_doc_op_element( _get_doc_article( doc_no, doc_it_no ), doc_it_el_ ), 10 ) }, ;
	"doc_it_el_", ;
	{|| .t.}, ;
	{|| .t.} })

AADD( a_ime_kol, {"Operacija" , ;
	{|| PADR( ALLTRIM( g_aop_desc( aop_id ) ) + "/" + ALLTRIM( g_aop_att_desc( aop_att_id ) ), 30 )  }, ;
	"aop_id", ;
	{|| .t.}, ;
	{|| .t.} } )

AADD( a_ime_kol, { "Status" , ;
	{|| PADR( _get_status( op_status ), 10 ) }, ;
	"aop_value", ;
	{|| .t.}, ;
	{|| .t.} })

AADD( a_ime_kol, { "Napomene" , ;
	{|| PADR( op_notes, 50 ) }, ;
	"aop_value", ;
	{|| .t.}, ;
	{|| .t.} })


for _i := 1 to LEN( a_ime_kol )
	AADD( a_kol, _i )
next

return




static function _get_status( status )
local _ret := ""

do case
    case status == " "
        _ret := "u izradi"
    case status == "1"
        _ret := "zavrseno"
    case status == "2"
        _ret := "odbaceno"
endcase

return _ret




// ----------------------------------------------------------------
// vraca oznaku elementa 
static function _get_doc_op_element( art_id, el_no )
local _t_area := SELECT()
local _elem := {}
local _art := {}
local _art_id 
local _ret := ""
local _scan := 0
local _el_no 

// daj matricu kompletne strukture artikla 
_art_set_descr( art_id, .f., nil, @_art, .t. )

// daj elemente artikla 
_g_art_elements( @_elem, art_id )

// utvrdi koji mi element treba !
_scan := ASCAN( _elem, { |val| val[1] == el_no } )
_el_no := _elem[ _scan, 3 ]

// to je taj !
_ret := g_el_descr( _art, _el_no )
 
select ( _t_area )

return _ret



// -----------------------------------------------------------------
// vraca artikal dokumenta
// -----------------------------------------------------------------
static function _get_doc_article( r_doc_no, r_doc_it_no )
local _ret := 0
local _t_area := SELECT()

// artikal je ?
select doc_it
set order to tag "1"
go top
seek docno_str( r_doc_no )  + docit_str( r_doc_it_no )
    
_ret := field->art_id

select ( _t_area )
return _ret



