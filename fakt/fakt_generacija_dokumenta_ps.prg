/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fakt.ch"



// -------------------------------------------------------------
// fakt generacija dokumenta menu
// -------------------------------------------------------------
function fakt_mnu_generacija_dokumenta()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc,"1. pocetno stanje                    ")
AADD( _opcexe, {|| fakt_pocetno_stanje() })
AADD( _opc,"2. dokument inventure     ")
AADD( _opcexe, {|| FaUnosInv()})

f18_menu( "mgdok", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()
return



// -----------------------------------------------------
// fakt generisanje dokumenta pocetnog stanja...
// -----------------------------------------------------
function fakt_pocetno_stanje()
local _param := hb_hash()
local _data := NIL
local _ps := .t.
local _n_br_dok 
local _count := 0
local _ulaz, _izlaz, _stanje
local _txt := ""
local _partn_id := PADR( "10", 6 )

// daj mi parametre prije prenosa...
if fakt_lager_lista_vars( @_param, _ps ) == 0
    return
endif

MsgO( "Formiranje lager liste sql query u toku..." )

// napuni mi podatke...
_data := fakt_lager_lista_sql( _param, _ps )

MsgC()

// dobio sam data... sada mogu provrtiti u tekucoj bazi i azurirati tekuci dokument
O_ROBA
O_PARTN
O_SIFK
O_SIFV
O_FAKT_PRIPR

_n_br_dok := PADR( "00000", 8 )

MsgO( "Formiranje dokumenta pocetnog stanja u toku... " )

do while !_data:EOF()

    _row := _data:GetRow()

    _id_roba := hb_utf8tostr( _row:FieldGet( _row:FieldPos("idroba") ) )
    _ulaz := _row:FieldGet( _row:FieldPos("ulaz") ) 
    _izlaz := _row:FieldGet( _row:FieldPos("izlaz") )
    _stanje := ( _ulaz - _izlaz ) 

    select roba
    hseek _id_roba

    if roba->tip == "U" .or. ROUND( _stanje, 2 ) == 0
        _data:Skip()
        loop
    endif

    select partn
    hseek _partn_id

    // formiraj stavku u pripremi
    select fakt_pripr
    append blank

    _rec := dbf_get_rec()

    _memo := ParsMemo( _rec["txt"] )

    _rec["idfirma"] := _param["id_firma"]
    _rec["idtipdok"] := "00"
    _rec["brdok"] := _n_br_dok
    _rec["rbr"] := RedniBroj( ++ _count )
    _rec["datdok"] := _param["datum_ps"]
    _rec["dindem"] := "KM "
    _rec["idpartner"] := _partn_id

    _memo[2] := ALLTRIM( partn->naz ) + ", " + ALLTRIM( partn->mjesto )
    _memo[3] := "Pocetno stanje"

    _rec["txt"] := fakt_memo_field_to_txt( _memo )

    _rec["idroba"] := _id_roba 
    _rec["kolicina"] := _stanje

    // ovo je interesatno, koju cijenu uzeti ????
    // tamo gdje se koristi samo maloprodaja 
    _rec["cijena"] := roba->vpc

    dbf_update_rec( _rec )

    _data:Skip()

enddo

MsgC()

if _count > 0
    MsgBeep( "Formiran dokument pocetnog stanja i nalazi se u pripremi !!!" )
endif

return



