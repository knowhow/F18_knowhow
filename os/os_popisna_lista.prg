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

#include "f18.ch"


function os_popisna_lista()
local _pars 

_o_tables()

if !_get_vars( @_pars )
    return
endif

if !_gen_xml( _pars )
    return 
endif

if generisi_odt_iz_xml( "mat_invent.odt", my_home() + "data.xml" )
    prikazi_odt()
endif

return


static function _o_tables()
O_RJ
o_os_sii()
return


// uslovi izvjestaja
static function _get_vars( params )
local _ok := .f.
local _idrj := PADR( fetch_metric( "os_popis_idrj", my_user(), "" ), LEN( field->idrj ) )
local _on := "N"
local _filt_k1 := SPACE(100)
local _filt_dob := SPACE(100)
local _filt_jmj := PADR( fetch_metric( "os_popis_jmj", my_user(), "" ), 100 )
local _cijena := "N"

Box(, 10, 77 )

    @ m_x + 1, m_y + 2 SAY "Radna jedinica:" GET _idrj ;
            VALID {|| P_RJ( @_idrj ), IF( !EMPTY( _idrj ), _idrj := PADR( _idrj, 4), .t. ), .t. }

    @ m_x + 2, m_y + 2 SAY "Prikaz svih neotpisanih (N) / otpisanih(O) /"
    @ m_x + 3, m_y + 2 SAY "samo novonabavljenih (B)    / iz proteklih godina (G)" GET _on PICT "@!" ;
            VALID _on $ "ONBG"
    
    @ m_x + 5, m_y + 2 SAY "Filter po grupaciji K1:" GET _filt_k1 PICT "@!S20"
    @ m_x + 6, m_y + 2 SAY "Filter po dobavljacima:" GET _filt_dob PICT "@!S20"
    @ m_x + 7, m_y + 2 SAY "Filter po jedin. mjere:" GET _filt_jmj PICT "@!S20"

    @ m_x + 9, m_y + 2 SAY "Prikaz nab.cijene (D/N) ?" GET _cijena PICT "@!" VALID _cijena $ "DN"
    
    READ

BoxC()

if LastKey() == K_ESC
    return _ok
endif

_ok := .t.

set_metric( "os_popis_idrj", my_user(), ALLTRIM( _idrj ) )
set_metric( "os_popis_jmj", my_user(), ALLTRIM( _filt_jmj ) )

params := hb_hash()
params["idrj"] := _idrj
params["prikaz"] := _on
params["filter_k1"] := _filt_k1
params["filter_dob"] := _filt_dob
params["filter_jmj"] := _filt_jmj
params["cijena"] := ( _cijena == "D" )

return _ok


// generisanje podataka...
static function _gen_xml( params )
local _idrj := PADR( params["idrj"], 4 )
local _prikaz := params["prikaz"]
local _filt_jmj := params["filter_jmj"]
local _filt_k1 := params["filter_k1"]
local _filt_dob := params["filter_dob"]
local _filter := ""
local _rbr := 0
local _ok := .f.

select_os_sii()
set order to tag "2" 

if !EMPTY( _idrj )
    _filter += "idrj=" + _filter_quote( _idrj )
endif

if !EMPTY( _filt_jmj )
    if !EMPTY( _filter )
        _filter += " .AND. "
    endif
    _filter += Parsiraj( UPPER( _filt_jmj ) , "UPPER(jmj)" )
endif

if !EMPTY( _filt_k1 )
    if !EMPTY( _filter )
        _filter += " .AND. "
    endif
    _filter += Parsiraj( _filt_k1, "k1" )
endif

if !EMPTY( _filt_dob )
    if !EMPTY( _filter )
        _filter += " .AND. "
    endif
    _filter += Parsiraj( _filt_dob, "idpartner" )
endif

if !EMPTY( _filter )
    set filter to &_filter
endif

go top

open_xml( my_home() + "data.xml" )
xml_head()

xml_subnode( "inv", .f. )

//header
xml_node( "fid", to_xml_encoding( gFirma ) )
xml_node( "fnaz", to_xml_encoding( gNFirma ) )
xml_node( "datum", DTOC( gDatObr ) )
xml_node( "kid", to_xml_encoding( _idrj ) )
xml_node( "knaz", "" )
xml_node( "pid", "" )
xml_node( "pnaz", "" )
xml_node( "modul", "OS" )

do while !EOF()

    if ( _prikaz == "B" .and. YEAR( gDatobr ) <> YEAR( field->datum ) )  
        skip 
        loop                                  
    endif

    if ( _prikaz == "G" .and. YEAR( gdatobr ) = YEAR( field->datum ) )  
        skip
        loop                                   
    endif

    if ( !EMPTY( datotp ) .and. year( datotp ) <= year( gdatobr ) ) .and. _prikaz $ "NB"
        skip 
        loop
    endif
    
    if ( empty( datotp ) .and. year( datotp ) < year( gdatobr ) ) .and. _prikaz == "O"
        skip 
        loop
    endif

    xml_subnode( "items", .f. )

    xml_node( "rbr", ALLTRIM( STR( ++ _rbr ) ) )
    xml_node( "rid", to_xml_encoding( field->id ) )
    xml_node( "naz", to_xml_encoding( field->naz ) )
    xml_node( "jmj", to_xml_encoding( field->jmj ) )
    xml_node( "stanje", STR( field->kolicina, 12, 2 ) )
    
    if params["cijena"]
        xml_node( "cijena", STR( field->nabvr, 12, 2 ) )
    else
        xml_node( "cijena", "" )
    endif

    xml_subnode( "items", .t. )
    
    skip

enddo

xml_subnode( "inv", .t. )

close_xml()

my_close_all_dbf()

if _rbr > 0
    _ok := .t.
endif

return _ok


