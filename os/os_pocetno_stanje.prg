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

#include "os.ch"

static __table_os
static __table_promj
static __table_os_alias
static __table_promj_alias



// -----------------------------------------------------
// generisanje pocetnog stanja
// -----------------------------------------------------
function os_generacija_pocetnog_stanja()
local _info := {} 
local _ok
local _pos_x, _pos_y
local _dat_ps := DATE()
local _db_params := my_server_params()
local _tek_database := my_server_params()["database"]
local _year_tek := YEAR( _dat_ps )
local _year_sez := _year_tek - 1

if ALLTRIM(STR( _year_sez )) $ _tek_database
    // ne moze se raditi razdvajanje u 2012
    MsgBeep( "Ne mogu vrsti prenos u sezonskim podacima..." )
    return _ok
endif

if Pitanje(, "Generisati pocetno stanje (D/N) ?", "N" ) == "N"
    return
endif

// sifra za koristenje...
if !SigmaSif("OSGEN")
    MsgBeep( "Opcija onemogucena !!!" )
    return
endif

// setuj staticke varijable na koje se tabele odnosi...
// nakon ovoga su nam dostupne 
// __table_os, __table_promj
_set_os_promj_tables()

Box(, 10, 60 )

    @ _pos_x := m_x + 1, _pos_y := m_y + 2 SAY "... prenos pocetnog stanja u toku" COLOR "I"

    // 1) pobrisati tekucu godinu
    _ok := _os_brisi_tekucu_godinu( @_info )

    // prebaciti iz prethodne godine tabele os/promj
    if _ok
        _ok := _os_prebaci_iz_prethodne( @_info )
    endif

    // napraviti generaciju podataka
    if _ok 
        _ok := _os_generacija_nakon_ps( @_info )
    endif

    // pakuj tabele...
    if _ok
        _pakuj_tabelu( __table_os_alias, __table_os )
        _pakuj_tabelu( __table_promj_alias, __table_promj )
    endif

    if _ok 
        @ _pos_x + 8, m_y + 2 SAY "... operacija uspjesna"
    else
        @ _pos_x + 8, m_y + 2 SAY "... operacija NEUSPJESNA !!!"
    endif

    @ _pos_x + 9, m_y + 2 SAY "Pritisnite <ESC> za izlazak i pregled rezulatata."
    
    // cekam ESC
    while Inkey(0.1) != K_ESC
    end

BoxC()

close all

if LEN( _info ) > 0
    _rpt_info( _info )
endif

return




// ---------------------------------------------------------------
// setuju se staticke varijable na koji modul se odnosi...
// ---------------------------------------------------------------
static function _set_os_promj_tables()

close all

o_os_sii()
o_os_sii_promj()

// tabela OS_OS/SII_SII
select_os_sii()
__table_os := get_os_table_name( ALIAS() )
__table_os_alias := ALIAS()

// tabela OS_PROMJ/SII_PROMJ
select_promj()
__table_promj := get_promj_table_name( ALIAS() )
__table_promj_alias := ALIAS()

close all

return


// ------------------------------------------------------
// pregled efekata prenosa pocetnog stanja
// ------------------------------------------------------
static function _rpt_info( info )
local _i

START PRINT CRET

?
? "Pregled efekata prenosa u novu godinu:"
? REPLICATE( "-", 70 )
? "Operacija                        Iznos       Ostalo"
? REPLICATE( "-", 70 )

for _i := 1 to LEN( info )
    ? PADR( info[ _i, 1 ], 50 ), info[ _i, 2 ], PADR( info[ _i, 3 ], 30 )
next

FF
END PRINT

return


// ---------------------------------------------------
// brisanje podataka tekuce godine 
// ---------------------------------------------------
static function _os_brisi_tekucu_godinu( info )
local _ok := .f.
local _table, _table_promj
local _count := 0
local _count_promj := 0
local _t_rec
local _pos_x, _pos_y

close all

o_os_sii()
o_os_sii_promj()

if !f18_lock_tables( { __table_os, __table_promj } )
    MsgBeep( "Problem sa lokovanjem tabela " + __table_os + ", " + __table_promj + " !!!#Prekidamo proceduru." )
    return _ok
endif

sql_table_update( nil, "BEGIN" )

select_os_sii()
set order to tag "1"
go top

@ _pos_x := m_x + 2, _pos_y := m_y + 2 SAY PADR( "1) Brisem podatke tekuce godine ", 40, "." )

do while !EOF()

    skip
    _t_rec := RECNO()
    skip -1

    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

    ++ _count

    go ( _t_rec )

enddo

select_promj()
set order to tag "1"
go top

do while !EOF()

    skip
    _t_rec := RECNO()
    skip -1

    _rec := dbf_get_rec()

    delete_rec_server_and_dbf( __table_promj, _rec, 1, "CONT" )

    ++ _count_promj

    go ( _t_rec )

enddo

f18_free_tables( { __table_os, __table_promj } )
sql_table_update( nil, "END" )

@ _pos_x, 55 SAY "OK"

AADD( info, { "1) izbrisano sredstava:", _count, ""  } )
AADD( info, { "2) izbrisano promjena:", _count_promj, ""  } )

_ok := .t.

close all

return _ok




// -------------------------------------------------------
// prebaci podatke iz prethodne sezone u tekucu
// -------------------------------------------------------
static function _os_prebaci_iz_prethodne( info )
local _ok := .f.
local _data_os, _data_promj, _server
local _qry_os, _qry_promj, _where
local _dat_ps := DATE()
local _db_params := my_server_params()
local _tek_database := my_server_params()["database"]
local _year_tek := YEAR( _dat_ps )
local _year_sez := _year_tek - 1
local _table, _table_promj
local _pos_x, _pos_y

// query za OS/PROMJ
_qry_os := " SELECT * FROM fmk." + __table_os
_qry_promj := " SELECT * FROM fmk." + __table_promj

// 1) predji u sezonsko podrucje
// ------------------------------------------------------------
// prebaci se u sezonu
switch_to_database( _db_params, _tek_database, _year_sez )
// setuj server
_server := pg_server()


@ _pos_x := m_x + 3, _pos_y := m_y + 2 SAY PADR( "2) vrsim sql upit ", 40, "." )

// podaci pocetnog stanja su ovdje....
_data_os := _sql_query( _server, _qry_os )
_data_promj := _sql_query( _server, _qry_promj )

@ _pos_x, 55 SAY "OK"

// 3) vrati se u tekucu bazu...
// ------------------------------------------------------------
switch_to_database( _db_params, _tek_database, _year_tek )
_server := pg_server()

if VALTYPE( _data_os ) == "L"
    MsgBeep( "Problem sa podacima..." )
    return _ok
endif
 
// ubaci sada podatke u OS/PROMJ
  
if !f18_lock_tables( { __table_os, __table_promj } )
    MsgBeep( "Problem sa lokovanjem tabela..." )
    return _ok
endif
 
sql_table_update( nil, "BEGIN" )

@ _pos_x := m_x + 4, _pos_y := m_y + 2 SAY PADR( "3) insert podataka u novoj sezoni ", 40, "." )

_insert_into_os( _data_os )
_insert_into_promj( _data_promj )

f18_free_tables( { __table_os, __table_promj } )
sql_table_update( nil, "END" )

@ _pos_x, 55 SAY "OK"

AADD( info, { "3) prebacio iz prethodne godine sredstva", _data_os:LastRec() , "" } )
AADD( info, { "4) prebacio iz prethodne godine promjene", _data_promj:LastRec(), "" } )

_ok := .t.

return _ok



// -----------------------------------------------------
// uzima row i vraca kao hb_hash
// -----------------------------------------------------
static function _row_to_rec( row )
local _rec := hb_hash()
local _field_name
local _field_val

for _i := 1 to row:FCOUNT()

    _field_name := row:FieldName( _i )
    _field_value := row:FieldGet( _i )

    if VALTYPE( _field_value ) == "C"
        _field_value := hb_utf8tostr( _field_value )
    endif
    
    _rec[ _field_name ] := _field_value

next

hb_hdel( _rec, "match_code" )

return _rec



// -----------------------------------------------------
// insert podataka u tabelu os
// -----------------------------------------------------
static function _insert_into_os( data )
local _i
local _table
local _row, _rec

close all
o_os_sii()

data:Refresh()

do while !data:EOF()

    _row := data:GetRow()    
    _rec := _row_to_rec( _row )

    // sredi neka polja...
    _rec["naz"] := PADR( _rec["naz"], 30 )

    select_os_sii()
    append blank

    update_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

    @ m_x + 5, m_y + 2 SAY "  " + __table_os + "/ sredstvo: " + _rec["id"]

    data:Skip()

enddo

close all

return


// -----------------------------------------------------
// insert podataka u tabelu os_promj
// -----------------------------------------------------
static function _insert_into_promj( data )
local _i
local _table
local _row, _rec

close all
o_os_sii_promj()

data:Refresh()

do while !data:EOF()

    _row := data:GetRow()    
    _rec := _row_to_rec( _row )

    select_promj()
    append blank

    update_rec_server_and_dbf( __table_promj, _rec, 1, "CONT" )

    @ m_x + 5, m_y + 2 SAY __table_promj + "/ promjena za sredstvo: " + _rec["id"]
    
    data:Skip()

enddo

close all

return




// ------------------------------------------------------
// regenerisanje podataka u novoj sezoni
// ------------------------------------------------------
static function _os_generacija_nakon_ps( info )
local _t_rec
local _rec, _r_br
local _sr_id 
local _table
local _ok := .f.
local _table_promj
local _data := {}
local _i, _count, _otpis_count
local _pos_x, _pos_y

// nalazim se u tekucoj godini, zelim "slijepiti" promjene i izbrisati
// otpisana sredstva u protekloj godini

close all
o_os_sii()
o_os_sii_promj()

select_os_sii()
go top

if !f18_lock_tables({ __table_os, __table_promj })
    MsgBeep( "Problem sa lokovanjem OS tabela !!!" )
    return _ok
endif

sql_table_update( nil, "BEGIN" )        

_otpis_count := 0

@ _pos_x := m_x + 6, _pos_y := m_y + 2 SAY PADR( "4) generacija podataka za novu sezonu ", 40, "." )

do while !eof()

    _sr_id := field->id
    _r_br := 0
    
    skip
    _t_rec := recno()
    skip -1

    // uzmi zapis...
    _rec := dbf_get_rec()    

    _rec["nabvr"] := _rec["nabvr"] + _rec["revd"]
    _rec["otpvr"] := _rec["otpvr"] + _rec["revp"] + _rec["amp"]
    
    // brisi sta je otpisano
    // ali samo osnovna sredstva, sitan inventar ostaje u bazi...
    if !EMPTY( _rec["datotp"] ) .and. gOsSii == "O"

        AADD( info, { "     sredstvo: " + _rec["id"] + "-" + PADR( _rec["naz"], 30 ), 0, "OTPIS" } )

        ++ _otpis_count

        delete_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

        go _t_rec
        loop

    endif

    select_promj()
    hseek _sr_id

    do while !EOF() .and. field->id == _sr_id
        _rec["nabvr"] += field->nabvr + field->revd
        _rec["otpvr"] += field->otpvr + field->revp + field->amp
        skip
    enddo

    select_os_sii()

    _rec["amp"] := 0
    _rec["amd"] := 0
    _rec["revd"] := 0
    _rec["revp"] := 0

    // update zapisa...
    update_rec_server_and_dbf( __table_os, _rec, 1, "CONT" )

    go _t_rec

enddo 

@ _pos_x, 55 SAY "OK"
 
AADD( info, { "5) broj otpisanih sredstava u novoj godini", _otpis_count, "" } )

// pobrisi sve promjene...
select_promj()
set order to tag "1"
go top

@ _pos_x := m_x + 7, _pos_y := m_y + 2 SAY PADR( "5) brisem promjene u novoj sezoni ", 40, "." )

do while !EOF()

    skip 1
    _t_rec := RECNO()
    skip -1

    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( __table_promj,  _rec, 1, "CONT" )

    go ( _t_rec )

enddo

@ _pos_x, 55 SAY "OK"

f18_free_tables( { __table_os, __table_promj } )
sql_table_update( nil, "END" )        

close all

_ok := .t.

return _ok


// -------------------------------------------------------------
// pakovanje tabele...
// -------------------------------------------------------------
static function _pakuj_tabelu( alias, table )

SELECT ( F_TMP_1 )
USE

my_use_temp( alias, my_home() + table + ".dbf", .f., .t. )

PACK
USE

return

