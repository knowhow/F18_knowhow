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

select ( F__DOC_OPS )
if !USED()
    O__DOC_OPS
endif

select _doc_ops
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
    
    select _doc_ops
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

select ( F__DOC_OPS )
if !USED()
    O__DOC_OPS
endif

select _doc_ops

ObjDbedit( "nalst", _box_x, _box_y, {|| key_handler() }, _header, _footer, , , , , 5 )

BoxC()

close all

return _ok



// --------------------------------------------------------
// obrada tipki
// --------------------------------------------------------
static function key_handler()
return DE_CONT



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
	{|| PADR( aop_value, 10 ) }, ;
	"aop_value", ;
	{|| .t.}, ;
	{|| .t.} })

AADD( a_ime_kol, { "Napomene" , ;
	{|| PADR( aop_value, 20 ) }, ;
	"aop_value", ;
	{|| .t.}, ;
	{|| .t.} })


for _i := 1 to LEN( a_ime_kol )
	AADD( a_kol, _i )
next

return



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

