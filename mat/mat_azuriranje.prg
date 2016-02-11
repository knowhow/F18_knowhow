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



// ----------------------------------------------------
// otvori tabele prije azuriranja
// ----------------------------------------------------
static function _o_tbls()
O_PARTN
O_MAT_PRIPR
O_MAT_SUBAN
O_MAT_PSUBAN
O_MAT_ANAL
O_MAT_PANAL
O_MAT_SINT
O_MAT_PSINT
O_MAT_NALOG
O_MAT_PNALOG
O_ROBA
return



// -------------------------------------------------------------
// razno-razne provjere dokumenta prije samog azuriranja
// -------------------------------------------------------------
static function _provjera_dokumenta()
local _valid := .t.

if !_stampan_nalog()
    _valid := .f.
    return _valid
endif

if !_ispravne_sifre()
    _valid := .f.
    return _valid
endif

return _valid


// ---------------------------------------------------
// provjera sifara koristenih u dokumentu 
// ---------------------------------------------------
static function _ispravne_sifre()
local _valid := .t.

// kontrola ispravnosti sifara artikala
select mat_psuban
go top

do while !EOF()

    // provjeri prvo robu   
    select roba
    hseek mat_psuban->idroba
    
    if !found()
        Beep(1)
        Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra artikla!")
        _valid := .f.
        exit
    endif
  
    // provjeri partnere
    select partn
    hseek mat_psuban->idpartner
    
    if !found() .and. !EMPTY(mat_psuban->idpartner)
        Beep(1)
        Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra partnera!")
        _valid := .f.
        exit
    endif
    
    select mat_psuban
    skip 1

enddo

// pobrisi tabele ako postoji problem
if !_valid

    select mat_psuban
    my_dbf_zap()
    select mat_panal
    my_dbf_zap()
    select mat_psint
    my_dbf_zap()
    
endif

return _valid


// -----------------------------------------------------
// da li je nalog stampan prije azuriranja
// -----------------------------------------------------
static function _stampan_nalog()
local _valid := .t.

select mat_psuban
if reccount2() == 0
    _valid := .f.
endif

select mat_panal
if reccount2() == 0
    _valid := .f.
endif

select mat_psint
if reccount2() == 0
    _valid := .f. 
endif

if !_valid
    Beep(3)
    Msg( "Niste izvrsili stampanje naloga ...", 10 )
endif

return _valid



// ----------------------------------------------------
// centralna funkcija za azuriranje mat naloga
// ----------------------------------------------------
function azur_mat()

if Pitanje(,"Sigurno želite izvršiti ažuriranje (D/N)?","N")=="N"
    return
endif

// otvori potrebne tabele
_o_tbls()

// napravi bazne provjere dokumenta prije azuriranja
if !_provjera_dokumenta()
    my_close_all_dbf()
    return
endif

// azuriraj u sql
if _mat_azur_sql()
    // azuriraj u dbf
    if !_mat_azur_dbf()
        MsgBeep( "Problem sa azuriranjem mat/dbf !" )
    endif
else
    MsgBeep( "Problem sa azuriranjem mat/sql !" )
endif

my_close_all_dbf()

return


// --------------------------------------------------
// azuriranje mat naloga u sql bazu
// --------------------------------------------------
static function _mat_azur_sql()
local _ok := .t.
local _ids := {}
local _record
local _tmp_id, _log_info
local _tbl_suban
local _tbl_anal
local _tbl_sint
local _tbl_nalog
local _i
local _ids_suban := {}
local _ids_sint := {}
local _ids_anal := {}
local _ids_nalog := {}

_tbl_suban := "mat_suban"
_tbl_anal  := "mat_anal"
_tbl_nalog := "mat_nalog"
_tbl_sint  := "mat_sint"

if !f18_lock_tables({ _tbl_suban, _tbl_anal, _tbl_sint, _tbl_nalog})
    MsgBeep("ERROR lock tabele")
    return .f.
endif

MsgO("sql mat_suban")
  
  _record := hb_hash()

  select mat_psuban
  go top

  sql_table_update(nil, "BEGIN")
 
  _record := dbf_get_rec()
  _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
  _log_info := _record["idfirma"] + "-" + _record["idvn"] + "-" + _record["brnal"]
  AADD( _ids_suban, "#2" + _tmp_id )

  @ m_x+1, m_y+2 SAY "mat_suban -> server: " + _tmp_id 
  do while !eof()

     _record := dbf_get_rec()
     if !sql_table_update("mat_suban", "ins", _record )
       _Ok := .f.
       exit
     endif

     SKIP
  enddo


MsgC()


// idi dalje, na anal ... ako je ok
if _ok == .t.
  

  select mat_panal
  go top
 
  MsgO("sql mat_anal")
  _record := dbf_get_rec()
  _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
  AADD( _ids_anal, "#2" + _tmp_id )

  do while !eof()
   _record := dbf_get_rec()
   if !sql_table_update("mat_anal", "ins", _record )
       lOk := .f.
       exit
    endif
   SKIP
  enddo
  
  MsgC()

endif


// idi dalje, na sint ... ako je ok
if _ok == .t.
  
  MsgO("sql mat_sint")

  select mat_psint
  go top
 
  _record := dbf_get_rec()
  _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
  AADD( _ids_sint, "#2" + _tmp_id )

  do while !eof()
 
   _record := dbf_get_rec()
   if !sql_table_update("mat_sint", "ins", _record )
       lOk := .f.
       exit
    endif
   SKIP
  enddo

  MsgC()

endif


// idi dalje, na nalog ... ako je ok
if _ok == .t.
  
  MsgO("sql mat_nalog")

  _record := hb_hash()

  select mat_pnalog


  GO TOP
 
  _record := dbf_get_rec()
  _tmp_id := _record["idfirma"] + _record["idvn"] + _record["brnal"]
  AADD( _ids_nalog, _tmp_id )

  do while !eof()
 
   _record := dbf_get_rec()
   if !sql_table_update("mat_nalog", "ins", _record )
       lOk := .f.
       exit
    endif
   SKIP
  enddo


endif

if ! _ok
    // vrati sve promjene...    
    sql_table_update(nil, "ROLLBACK" )
else
    // dodaj ids
    AADD(_ids, _tmp_id) 
    
    push_ids_to_semaphore( _tbl_suban, _ids_suban )
    push_ids_to_semaphore( _tbl_anal,  _ids_anal  )
    push_ids_to_semaphore( _tbl_sint,  _ids_sint  )
    push_ids_to_semaphore( _tbl_nalog, _ids_nalog )

    sql_table_update(nil, "END")

    log_write( "F18_DOK_OPER: mat, azuriranje dokumenta: " + _log_info, 2 )

endif

f18_free_tables({_tbl_suban, _tbl_anal, _tbl_sint, _tbl_nalog})

return _ok




// --------------------------------------------------
// azuriranje mat naloga u dbf
// --------------------------------------------------
static function _mat_azur_dbf()
local _ret := .t.
local _vars

Box(,7,30,.f.)
    
    @ m_x + 1, m_y + 2 SAY "ANALITIKA"
    select mat_panal
    go top

    do while !EOF()
        
        _vars := dbf_get_rec() 
        select mat_anal
        append blank
        
        dbf_update_rec( _vars )
        
        select mat_panal
        skip
    
    enddo

    select mat_panal
    my_dbf_zap()

    @ m_x + 3, m_y + 2 SAY "SINTETIKA"
    select mat_psint
    go top

    do while !EOF()
        
        _vars := dbf_get_rec() 
        
        select mat_sint
        append blank
        
        dbf_update_rec( _vars )
        
        select mat_psint
        skip
    
    enddo

    select mat_psint
    my_dbf_zap()

    @ m_x + 5, m_y + 2 SAY "NALOZI"
    select mat_pnalog
    go top

    do while !EOF()
        
        _vars := dbf_get_rec() 
        
        select mat_nalog
        append blank
        
        dbf_update_rec( _vars )
        
        select mat_pnalog
        skip
    
    enddo

    select mat_pnalog
    my_dbf_zap()

    @ m_x + 7, m_y + 2 SAY "SUBANALITIKA"
    select mat_psuban
    go top

    do while !EOF()
        
        _vars := dbf_get_rec() 
        
        select mat_suban
        append blank
        
        dbf_update_rec( _vars )
        
        select mat_psuban
        skip
    
    enddo

    select mat_psuban
    my_dbf_zap()

    select mat_pripr
    my_dbf_zap()

    Inkey(2)

BoxC()

return _ret




