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
#include "hbclass.ch"
#include "common.ch"


CLASS RNALDamageDocument

    METHOD New()
    METHOD get_damage_data()
    METHOD get_damage_items()
    METHOD has_damage_data()
    METHOD has_multiglass()
    METHOD generate_rnal_document()
    METHOD multiglass_configurator()

    DATA damage_items
    DATA damage_data
    DATA doc_no

    PROTECTED:

        METHOD open_tables()
        METHOD get_damage_items_cond()
        METHOD get_damage_items_qtty()
        METHOD get_damage_article()
        METHOD get_rnal_header_data()
        METHOD get_rnal_items_data()
        METHOD get_rnal_opers_data()
        METHOD config_tbl_struct()
        METHOD configurator_box()
        METHOD configurator_box_key_handler()
        METHOD set_configurator_box_columns()
        METHOD fill_config_tbl()
        METHOD configurator_edit_data()
        METHOD fix_items()


ENDCLASS



// ---------------------------------------
METHOD RNALDamageDocument:New()
::damage_data := NIL
::damage_items := NIL
::doc_no := NIL
return SELF


// vraca podatke o ostecenju za nalog broj
METHOD RNALDamageDocument:get_damage_data()
local _ok := .f.
local _qry, _table
local _server := pg_server()
local _log_type := "21"

_qry := "SELECT " + ;
        "  lit.doc_no, " + ;
        "  lit.doc_log_no, " + ;
        "  lit.doc_lit_no, " + ;
        "  lit.doc_lit_ac, " + ;
        "  lit.art_id, " + ;
        "  lit.char_1, " + ;
        "  lit.num_1, " + ;
        "  lit.num_2, " + ;
        "  lit.int_1, " + ;
        "  lit.int_2, " + ;
        "  dlog.doc_log_da, " + ;
        "  dlog.doc_log_ti " + ;
        "FROM fmk.rnal_doc_lit lit " + ;
        "LEFT JOIN fmk.rnal_doc_log dlog ON lit.doc_no = dlog.doc_no " + ;
        "   AND dlog.doc_log_no = lit.doc_log_no " + ;
        "WHERE dlog.doc_log_ty = " + _sql_quote( _log_type ) + ;
        "   AND dlog.doc_no = " + ALLTRIM( STR( ::doc_no ) ) + " " + ;
        "ORDER BY lit.doc_no, lit.doc_log_no, lit.doc_lit_no"

MsgO( "formiranje sql upita u toku ..." )

_table := _sql_query( _server, _qry )

MsgC()

if _table == NIL
    return NIL
endif

_table:Refresh()

::damage_data := _table

return


// ------------------------------------------------------
// daj mi stavke koje su sporne sa naloga
// ------------------------------------------------------
METHOD RNALDamageDocument:get_damage_items()
local oRow
local _item, _scan

::damage_items := {}
::damage_data:GoTo(1)

do while !::damage_data:EOF() 

    oRow := ::damage_data:GetRow()

    _item := oRow:FieldGet( oRow:FieldPos( "int_1" ) )
    _scan := ASCAN( ::damage_items, { | var | var[1] == _item } )

    if _scan == 0
        AADD( ::damage_items, { _item } )
    endif

    ::damage_data:skip()

enddo

::damage_data:GoTo(1)

return 

// -------------------------------------------------------------
// vrati mi uslov za sql izraz na osnovu ovoga
// -------------------------------------------------------------
METHOD RNALDamageDocument:get_damage_items_cond( field_name )
local _cond := ""
local _i

if ::damage_items == NIL .or. LEN( ::damage_items ) == 0
    return _cond
endif

_cond := " AND " +  field_name + " IN ( "

for _i := 1 to LEN( ::damage_items )
    _cond += ALLTRIM( STR( ::damage_items[ _i, 1 ] ) )
    if _i < LEN( ::damage_items )
        _cond += ", "
    endif
next

_cond += " ) "

return _cond


// -------------------------------------------------------------
// vraca podatke o ostecenju za nalog broj
// -------------------------------------------------------------
METHOD RNALDamageDocument:has_damage_data()
local _res
local _where

_where := "WHERE doc_log_ty = " + _sql_quote( _log_type ) + ;
        "   AND doc_no = " + ALLTRIM( STR( ::doc_no ) );

_res := table_count( "fmk.rnal_doc_log", _where )

return _res


// -------------------------------------------------------
// provjerava da li postoje slozena stakla
// -------------------------------------------------------
METHOD RNALDamageDocument:has_multiglass()
local _ok := .f.
local oRow, _art_id, _a_art

::damage_data:GoTo(1)

do while !::damage_data:EOF()

    oRow := ::damage_data:GetRow()

    _art_id := oRow:FieldGet( oRow:FieldPos( "art_id" ) )
    _a_art := {}

    // napuni matricu...
    _art_set_descr( _art_id, nil, nil, @_a_art, .t. )

    if is_izo( _a_art ) .or. is_lami( _a_art ) .or. is_lamig( _a_art )
        _ok := .t.
        exit
    endif

    ::damage_data:Skip()

enddo

::damage_data:GoTo(1)

return _ok



// --------------------------------------------------------
// pokreni konfiguraciju, tj. odaberi zamjenska stakla
// --------------------------------------------------------
METHOD RNALDamageDocument:multiglass_configurator()
local _ok := .f.

// 1) napravi i napuni tabelu konfiguratora...
::fill_config_tbl()

// 2) otvori box konfiguratora
::configurator_box()

_ok := .t.

return _ok



METHOD RNALDamageDocument:configurator_box()
local _x_pos := MAXROWS() - 15
local _y_pos := MAXCOLS() - 10
local _opts := "<ENTER> definisi novi artikal  <ESC> izlaz/snimanje"
local _head, _foot
private Kol, ImeKol

_head := "Konfiguracija artikala za novi nalog..."
_foot := ""

Box(, _x_pos, _y_pos, .t. )

select _tmp1
go top

// setuj kolone konfiguratora
::set_configurator_box_columns( @ImeKol, @Kol )

@ m_x + ( _x_pos - 1 ), m_y + 1 SAY _opts

ObjDbedit( "_tmp1", _x_pos, _y_pos, {|| ::configurator_box_key_handler() }, _head, _foot,,,,, 2 )

BoxC()

select _tmp1
go top

return



// ----------------------------------------------------------------------
//
// ----------------------------------------------------------------------
METHOD RNALDamageDocument:configurator_box_key_handler()

do case
    case Ch == K_ENTER
        if ::configurator_edit_data()
            return DE_REFRESH
        endif

endcase

return DE_CONT




// ----------------------------------------------------------------------
//
// ----------------------------------------------------------------------
METHOD RNALDamageDocument:configurator_edit_data()
local _ok := .f.
local _art_id := 0

Box(, 3, 55 )

    @ m_x + 1, m_y + 2 SAY "Postavi novi artikal:" GET _art_id ;
                        VALID {|| s_articles( @_art_id, .f., .t.  ), ;
                            check_article_valid( _art_id ) } ;
                        PICT "9999999999"
    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

_rec := dbf_get_rec()

_rec["art_id_2"] := _art_id

dbf_update_rec( _rec )

_ok := .t.

return _ok




// ----------------------------------------------------------------------
// setovanje kolona konfiguratora
// ----------------------------------------------------------------------
METHOD RNALDamageDocument:set_configurator_box_columns( ime_kol, kol )
local _i

ime_kol := {}
kol := {}

// definisanje kolona
AADD( ime_kol, { "rbr" , {|| docit_str( doc_it_no ) }, ;
	"doc_it_no", {|| .t.}, {|| .t.} })

AADD( ime_kol, {"Artikal/Kol." , {|| sh_article( art_id, doc_it_qtt, 0, 0 ) }, ;
	"art_id", {|| .t.}, {|| .t.} })

AADD( ime_kol, {"Br.stakla" , {|| glass_no }, ;
	"glass_no", {|| .t.}, {|| .t.} })

AADD( ime_kol, {"Novi artikal" , {|| if( art_id_2 <> 0, sh_article( art_id_2, doc_it_qtt, 0, 0 ), "ostaje isti" ) }, ;
	"art_id_2", {|| .t.}, {|| .t.} })

for _i := 1 to LEN( ime_kol )
	AADD( kol, _i )
next

return 


// -----------------------------------------------------------------
// sredjuje redne brojeve u pripremi...
// -----------------------------------------------------------------
METHOD RNALDamageDocument:fix_items()
return


// ------------------------------------------------------------------
// vraca artikal za novi nalog, originalni ili iz konfiguratora
// ------------------------------------------------------------------
METHOD RNALDamageDocument:get_damage_article( doc_no, item_no, art_orig )
local _t_area := SELECT()
local _ret := art_orig

select _tmp1
set order to tag "1"
go top
seek docno_str( doc_no ) + docit_str( item_no ) + STR( art_orig, 10, 0 )

if !FOUND() 
    select ( _t_area )
    return _ret
endif

if field->art_id_2 <> 0
    _ret := field->art_id_2
endif

select ( _t_area )

return _ret




// ------------------------------------------------------------
// filuje tabelu konfiguratora sa podacima 
// ------------------------------------------------------------
METHOD RNALDamageDocument:fill_config_tbl()
local _db_struct := ::config_tbl_struct()
local oRow
local _count := 0

// 1) napravi pomocnu tabelu
cre_tmp1( _db_struct )
o_tmp1()
index on ( STR( doc_no, 10, 0 ) + STR( doc_it_no, 4, 0 ) + STR( art_id, 10, 0 ) ) TAG "1"
select _tmp1
my_dbf_zap()

// 2) napuni mi podatke iz tabele ostecenih stavki
::damage_data:GoTo(1)

// daj mi podatke stavki
//_items_tbl := ::get_rnal_items_data()
//_items_tbl:GoTo(1)

do while !::damage_data:EOF()

    oRow := ::damage_data:GetRow()

    select _tmp1
    append blank

    _rec := dbf_get_rec()

    _rec["doc_no"] := oRow:FieldGet( oRow:FieldPos( "doc_no") )
    _rec["doc_it_no"] := oRow:FieldGet( oRow:FieldPos( "int_1") )
    _rec["art_id"] := oRow:FieldGet( oRow:FieldPos( "art_id") )
    _rec["glass_no"] := oRow:FieldGet( oRow:FieldPos( "int_2") )
    _rec["doc_it_qtt"] := oRow:FieldGet( oRow:FieldPos( "num_2") )
    // ovo je zamjenski artikal
    _rec["art_id_2"] := 0

    dbf_update_rec( _rec )

    ++ _count 

    ::damage_data:Skip()
   
enddo

::damage_data:GoTo(1)

return _count




// --------------------------------------------------------
// vraca strukturu config tabele
// --------------------------------------------------------
METHOD RNALDamageDocument:config_tbl_struct()
local _dbf := {}

AADD( _dbf, { "doc_no", "N", 10, 0 })
AADD( _dbf, { "doc_it_no", "N", 4, 0 })
AADD( _dbf, { "art_id", "N", 10, 0 })
AADD( _dbf, { "glass_no", "N", 3, 0 })
AADD( _dbf, { "doc_it_qtt", "N", 12, 2 })
AADD( _dbf, { "art_id_2", "N", 10, 2 })

return _dbf



// ------------------------------------------------------
// vraca header podatke dokumenta
// ------------------------------------------------------
METHOD RNALDamageDocument:get_rnal_header_data()
local _qry, _table
local _server := pg_server()

_qry := "SELECT * FROM fmk.rnal_docs " + ;
        " WHERE doc_no = " + docno_str( ::doc_no ) + ;
        " ORDER BY doc_no"

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table


// ------------------------------------------------------
// vraca item podatke dokumenta
// ------------------------------------------------------
METHOD RNALDamageDocument:get_rnal_items_data()
local _qry, _table
local _server := pg_server()
local _items_cond := ::get_damage_items_cond( "doc_it_no" )
local _i

_qry := " SELECT * FROM fmk.rnal_doc_it " + ;
        " WHERE doc_no = " + ALLTRIM( STR( ::doc_no ) ) + _items_cond + ;
        " ORDER BY doc_no, doc_it_no "
        
_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table


// ------------------------------------------------------
// vraca oper podatke dokumenta
// ------------------------------------------------------
METHOD RNALDamageDocument:get_rnal_opers_data()
local _qry, _table
local _server := pg_server()
local _items_cond := ::get_damage_items_cond( "doc_it_no" )

_qry := " SELECT * FROM fmk.rnal_doc_ops " + ;
        " WHERE doc_no = " + ALLTRIM( STR( ::doc_no ) ) + _items_cond + ;
        " ORDER BY doc_no, doc_it_no, doc_op_no"

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table



// -----------------------------------------------------
// generisanje novog dokumenta...
// -----------------------------------------------------
METHOD RNALDamageDocument:generate_rnal_document()
local _ok := .f.
local _rec
local _header_tbl, _items_tbl, _opers_tbl
local _damage_doc_no := 0
local _fix_items := {}
local oRow, _scan
local _count := 0

// otvori mi sve tabele potrebne za rad !
::open_tables()

if _docs->( RECCOUNT() ) <> 0
    MsgBeep( "Priprema nije prazna !!!" )
    return _ok
endif 

// daj mi podatke header-a
_header_tbl := ::get_rnal_header_data()
_header_tbl:GoTo(1)

// daj mi podatke stavki
_items_tbl := ::get_rnal_items_data()
_items_tbl:GoTo(1)

// daj mi podatke operacija
_opers_tbl := ::get_rnal_opers_data()
_opers_tbl:GoTo(1)

// 1) ubaci podatke header-a

oRow := _header_tbl:GetRow()

select _docs
append blank

_rec := dbf_get_rec()

_rec["doc_no"] := _damage_doc_no
_rec["doc_date"] := DATE()
_rec["doc_dvr_da"] := DATE() + 2
_rec["doc_dvr_ti"] := PADR( PADR( TIME(), 5 ), 8 )
_rec["doc_ship_p"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_ship_p" ) ) )
_rec["doc_priori"] := oRow:FieldGet( oRow:FieldPos( "doc_priori" ) )
_rec["doc_pay_id"] := oRow:FieldGet( oRow:FieldPos( "doc_pay_id" ) )
_rec["doc_paid"] := oRow:FieldGet( oRow:FieldPos( "doc_paid" ) )
_rec["doc_pay_de"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_pay_de" ) ) )
_rec["doc_status"] := 10
_rec["doc_sh_des"] := "NP na osnovu: " + ALLTRIM( docno_str( oRow:FieldGet( oRow:FieldPos("doc_no") ) ) ) ;
                + ", " + hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_sh_des" ) ) )
_rec["doc_desc"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_desc" ) ) )
_rec["operater_i"] := GetUserID( f18_user() )
_rec["cust_id"] := oRow:FieldGet( oRow:FieldPos( "cust_id" ) )
_rec["cont_add_d"] := oRow:FieldGet( oRow:FieldPos( "cont_add_d" ) )
_rec["cont_id"] := oRow:FieldGet( oRow:FieldPos( "cont_id" ) )
_rec["obj_id"] := oRow:FieldGet( oRow:FieldPos( "obj_id" ) )
_rec["doc_type"] := "NP"

dbf_update_rec( _rec )

// 2) ubaci podatke u items...

do while !_items_tbl:EOF()
    
    oRow := _items_tbl:GetRow()

    _item := oRow:FieldGet( oRow:FieldPos( "doc_it_no" ) )

    select _doc_it
    append blank

    _rec := dbf_get_rec()

    _rec["doc_no"] := _damage_doc_no
    _rec["doc_it_no"] := inc_docit( _damage_doc_no )

    // dodaj u matricu fix_items, stari/novi redni broj
    AADD( _fix_items, { _item, _rec["doc_it_no"] } )

    _rec["doc_it_typ"] := oRow:FieldGet( oRow:FieldPos( "doc_it_typ" ) )
    _rec["it_lab_pos"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "it_lab_pos" ) ) )
    _rec["doc_it_alt"] := oRow:FieldGet( oRow:FieldPos( "doc_it_alt" ) )
    _rec["doc_it_des"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_it_des" ) ) )
    _rec["doc_acity"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_acity" ) ) )
    _rec["doc_it_sch"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_it_sch" ) ) )
    _rec["doc_it_wid"] := oRow:FieldGet( oRow:FieldPos( "doc_it_wid" ) )
    _rec["doc_it_w2"] := oRow:FieldGet( oRow:FieldPos( "doc_it_w2" ) )
    _rec["doc_it_hei"] := oRow:FieldGet( oRow:FieldPos( "doc_it_hei" ) )
    _rec["doc_it_h2"] := oRow:FieldGet( oRow:FieldPos( "doc_it_h2" ) )

    // artikal ces mozda uzeti i iz konfiguratora....
    _rec["art_id"] := ::get_damage_article( oRow:FieldGet( oRow:FieldPos( "doc_no" )), ; 
                oRow:FieldGet( oRow:FieldPos( "doc_it_no" ) ), ;
                oRow:FieldGet( oRow:FieldPos( "art_id" ) ) )

    // broj komada ostecenog stakla
    _rec["doc_it_qtt"] := ::get_damage_items_qtty( _item ) 

    dbf_update_rec( _rec )

    ++ _count

    _items_tbl:Skip()

enddo


// 3) ubaci podatke u operacije

do while !_opers_tbl:EOF()
    
    oRow := _opers_tbl:GetRow()

    _item := oRow:FieldGet( oRow:FieldPos( "doc_it_no" ) )

    select _doc_ops
    append blank

    _rec := dbf_get_rec()

    _rec["doc_no"] := _damage_doc_no
    
    // pronadji i redni broj na osnovu kontrolne matrice
    _scan := ASCAN( _fix_items, { |var| var[1] == _item } )
    _item_no := _fix_items[ _scan, 2 ]

    _rec["doc_it_no"] := _item_no
    _rec["doc_op_no"] := inc_docop( _damage_doc_no )
    _rec["doc_it_el_"] := oRow:FieldGet( oRow:FieldPos( "doc_it_el_" ) )
    _rec["aop_id"] := oRow:FieldGet( oRow:FieldPos( "aop_id" ) )
    _rec["aop_att_id"] := oRow:FieldGet( oRow:FieldPos( "aop_att_id" ) )
    _rec["doc_op_des"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "doc_op_des" ) ) )
    _rec["aop_value"] := hb_utf8tostr( oRow:FieldGet( oRow:FieldPos( "aop_value" ) ) )

    dbf_update_rec( _rec )

    _opers_tbl:Skip()

enddo


if _count > 0
    MsgBeep( "Kreiran nalog tip-a NEUSKLADJENI PROIZVOD#Nalazi se u pripremi!#PREGLEDATI GA PRIJE AZURIRANJA" )
endif

_ok := .t.

return _ok




// -----------------------------------------------------
// koliko je osteceno stakala za stavku
// -----------------------------------------------------
METHOD RNALDamageDocument:get_damage_items_qtty( item_no )
local _qtty := 0
local _item, oRow

::damage_data:GoTo(1)

do while !::damage_data:EOF()

    oRow := ::damage_data:GetRow()
    _item := oRow:FieldGet( oRow:FieldPos( "int_1" ) )

    if _item == item_no
        _qtty := oRow:FieldGet( oRow:FieldPos( "num_2" ) )
        exit
    endif

    ::damage_data:Skip()

enddo

::damage_data:GoTo(1)

return _qtty





// -----------------------------------------------------
// otvaranje potrebnih tabela
// -----------------------------------------------------
METHOD RNALDamageDocument:open_tables()
o_tables( .t. )
return



// ---------------------------------------------
// generisi neuskladjeni nalog
// ---------------------------------------------
function rnal_damage_doc_generate( doc_no )
local oDamage := RNALDamageDocument():New()

// setuj broj dokumenta za koji cemo ovo sve raditi
oDamage:doc_no := doc_no
// daj mi podatke loma za ovaj nalog
oDamage:get_damage_data()

// ima li podataka ?
if oDamage:damage_data == NIL
    MsgBeep( "Ovaj dokument nema evidencije loma !" )
    return
endif

// daj mi matricu stavki koje su sporne sa naloga
oDamage:get_damage_items()

// konfigurator ako su visestruka stakla
if oDamage:has_multiglass()
    MsgBeep( "Ovaj nalog sadrzi visestruka stakla !#Napravite odgovarajucu zamjenu u tabeli" )
    oDamage:multiglass_configurator()
endif

oDamage:generate_rnal_document()

return



