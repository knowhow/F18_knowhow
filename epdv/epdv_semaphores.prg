/* 
 * This file is part of the bring.out ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "epdv.ch"
#include "common.ch"


// -----------------------------------------
// -----------------------------------------
function epdv_sg_kuf_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "epdv_sg_kuf"


_result := sifrarnik_from_sql_server(_tbl, algoritam, F_SG_KUF, {"id", "naz", "src", "s_path", "s_path_s", "form_b_pdv", "form_pdv", ;
                "id_tar", "id_kto", "razb_tar", "razb_kto", "razb_dan", "kat_part", "td_src", "kat_p", "kat_p_2", "s_id_tar", ;
                "zaok", "zaok2", "s_id_part", "aktivan", "id_kto_naz", "s_br_dok" })

return _result


// -----------------------------------------
// -----------------------------------------
function epdv_sg_kif_from_sql_server(algoritam)
local _result := .f.
local _i
local _tbl := "epdv_sg_kif"

_result := sifrarnik_from_sql_server(_tbl, algoritam, F_SG_KIF, {"id", "naz", "src", "s_path", "s_path_s", "form_b_pdv", "form_pdv", ;
                "id_tar", "id_kto", "razb_tar", "razb_kto", "razb_dan", "kat_part", "td_src", "kat_p", "kat_p_2", "s_id_tar", ;
                "zaok", "zaok2", "s_id_part", "aktivan", "id_kto_naz", "s_br_dok" })

return _result




// ------------------------------
// sinhronizacija sa sql serverom
// ------------------------------
function epdv_pdv_from_sql_server(algoritam)
return



// ------------------------------
// sinhronizacija sa sql serverom
// ------------------------------
function epdv_kuf_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "br_dok, datum"
local _key_block

_tbl := "fmk.epdv_kuf"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update epdv_kuf: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_KUF
my_usex ("kuf", "epdv_kuf", .f., "SEMAPHORE")


for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + ;
        "datum, datum_2, src, td_src, src_2, id_tar, id_part, part_idbr, part_kat, src_td, src_br,  " + ;
        "src_veza_b, src_br_2, r_br, br_dok, g_r_br, lock, kat, kat_2, opis, i_b_pdv, i_pdv, i_v_b_pdv,  " + ;
        "i_v_pdv, status, kat_p, kat_p_2 " + ;
        "FROM " +   _tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("epdv_kuf")
    _qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datum }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("epdv_kuf")
        _qry += " WHERE "
        if LEN(_ids) < 1
            // nema id-ova
            _qry += "false"
        else
            _sql_ids := "("
            for _i := 1 to LEN(_ids)
                _sql_ids += _sql_quote(_ids[_i])
                if _i < LEN(_ids)
                    _sql_ids += ","
                endif
            next
            _sql_ids += ")"
            _qry += " ( br_dok::char(6) ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->br_dok, 6, 0 ) } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 

  DO CASE

    CASE algoritam == "FULL" .and. _offset==0
        // "full" algoritam
        log_write("datdok = nil full algoritam") 
        ZAP

    CASE algoritam == "DATE"

        log_write("datdok <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "8"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. eval(_key_block)  >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        SET ORDER TO TAG "BR_DOK2"

        // CREATE_INDEX("BR_DOK2", "STR(br_dok) + DTOS(datum)", "KUF")
        // pobrisimo sve id-ove koji su drugi izmijenili
        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                
                HSEEK _tmp_id
                
                do while !EOF() .and. EVAL(_key_block) == _tmp_id
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

  ENDCASE
  // sada je sve izbrisano

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

  _counter := 1

  DO WHILE !_qry_obj:Eof()
    append blank
    
    /*
        "datum, datum_2, src, td_src, src_2, id_tar, id_part, part_idbr, part_kat, src_td, src_br,  " + ;
        "src_veza_b, src_br_2, r_br, br_dok, g_r_br, lock, kat, kat_2, opis, i_b_pdv, i_pdv, i_v_b_pdv,  " + ;
        "i_v_pdv, status, kat_p, kat_p_2 " + ;
    */

    replace datum with _qry_obj:FieldGet(1), ;
            datum_2 with _qry_obj:FieldGet(2), ;
            src with _qry_obj:FieldGet(3), ;
            td_src with _qry_obj:FieldGet(4), ;
            src_2 with _qry_obj:FieldGet(5), ;
            id_tar with _qry_obj:FieldGet(6), ;
            id_part with _qry_obj:FieldGet(7), ;
            part_idbr with _qry_obj:FieldGet(8), ;
            part_kat with _qry_obj:FieldGet(9), ;
            src_td with _qry_obj:FieldGet(10), ;
            src_br with _qry_obj:FieldGet(11), ;
            src_veza_b with _qry_obj:FieldGet(12), ;
            src_br_2 with _qry_obj:FieldGet(13), ;
            r_br with _qry_obj:FieldGet(14), ;
            br_dok with _qry_obj:FieldGet(15), ;
            g_r_br with _qry_obj:FieldGet(16), ;
            lock with _qry_obj:FieldGet(17), ;
            kat with _qry_obj:FieldGet(18), ;
            kat_2 with _qry_obj:FieldGet(19), ;
            opis with _qry_obj:FieldGet(20), ;
            i_b_pdv with _qry_obj:FieldGet(21), ;
            i_pdv with _qry_obj:FieldGet(22), ;
            i_v_b_pdv with _qry_obj:FieldGet(23), ;
            i_v_pdv with _qry_obj:FieldGet(24), ;
            status with _qry_obj:FieldGet(25), ;
            kat_p with _qry_obj:FieldGet(26), ;
            kat_p_2 with _qry_obj:FieldGet(27)
      
    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO


next

USE

if (gDebug > 5)
    log_write("epdv_kuf synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_epdv_kuf_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.epdv_kuf"

if record <> nil
    _where := "br_dok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
               "( datum, datum_2, src, td_src, src_2, id_tar, id_part, part_idbr, part_kat, src_td, src_br,  " + ;
               "src_veza_b, src_br_2, r_br, br_dok, g_r_br, lock, kat, kat_2, opis, i_b_pdv, i_pdv, i_v_b_pdv,  " + ;
               "i_v_pdv, status, kat_p, kat_p_2 ) " + ;
               "VALUES(" + _sql_quote( record["datum"] )  + "," +;
                            + _sql_quote( record["datum_2"] ) + "," +; 
                            + _sql_quote( record["src"] ) + "," +; 
                            + _sql_quote( record["td_src"] ) + "," +; 
                            + _sql_quote( record["src_2"] ) + "," +;
                            + _sql_quote( record["id_tar"] ) + "," +;
                            + _sql_quote( record["id_part"] ) + "," +;
                            + _sql_quote( record["part_idbr"] ) + "," +;
                            + _sql_quote( record["part_kat"] ) + "," +;
                            + _sql_quote( record["src_td"] ) + "," +;
                            + _sql_quote( record["src_br"] ) + "," +;
                            + _sql_quote( record["src_veza_b"] ) + "," +;
                            + _sql_quote( record["src_br_2"] ) + "," +;
                            + STR( record["r_br"], 6, 0 ) + "," +;
                            + STR( record["br_dok"], 6, 0 ) + "," +;
                            + STR( record["g_r_br"], 8, 0 ) + "," +;
                            + _sql_quote( record["lock"] ) + "," +;
                            + _sql_quote( record["kat"] ) + "," +;
                            + _sql_quote( record["kat_2"] ) + "," +;
                            + _sql_quote( record["opis"] ) + "," +;
                            + STR( record["i_b_pdv"], 16, 2 ) + "," +;
                            + STR( record["i_pdv"], 16, 2 ) + "," +;
                            + STR( record["i_v_b_pdv"], 16, 2 ) + "," +;
                            + STR( record["i_v_pdv"], 16, 2 ) + "," +;
                            + _sql_quote( record["status"] ) + "," +;
                            + _sql_quote( record["kat_p"] ) + "," +;
                            + _sql_quote( record["kat_p_2"] ) + " )"
                         
 
ENDCASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 
return



// ------------------------------
// sinhronizacija sa sql serverom
// ------------------------------
function epdv_kif_from_sql_server(algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _dat, _ids
local _fnd, _tmp_id
local _count
local _tbl
local _offset
local _step := 15000
local _retry := 3
local _order := "br_dok, datum"
local _key_block

_tbl := "fmk.epdv_kif"

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
    algoritam := "FULL"
endif

@ _x + 1, _y + 2 SAY "update epdv_kif: " + algoritam

_seconds := SECONDS()

_count := table_count( _tbl, "true" ) 

SELECT F_KIF
my_usex ("kif", "epdv_kif", .f., "SEMAPHORE")

for _offset := 0 to _count STEP _step 

  _qry :=  "SELECT " + ;
        "datum, datum_2, src, td_src, src_2, id_tar, id_part, part_idbr, part_kat, src_td, src_br,  " + ;
        "src_veza_b, src_br_2, r_br, br_dok, g_r_br, lock, kat, kat_2, opis, i_b_pdv, i_pdv, i_v_b_pdv,  " + ;
        "i_v_pdv, status, kat_p, kat_p_2, src_pm " + ;
        "FROM " +   _tbl 
  
  if algoritam == "DATE"
    _dat := get_dat_from_semaphore("epdv_kif")
    _qry += " WHERE datdok >= " + _sql_quote(_dat)
    _key_block := {|| field->datum }
  endif

  if algoritam == "IDS"
        _ids := get_ids_from_semaphore("epdv_kif")
        _qry += " WHERE "
        if LEN(_ids) < 1
            // nema id-ova
            _qry += "false"
        else
            _sql_ids := "("
            for _i := 1 to LEN(_ids)
                _sql_ids += _sql_quote(_ids[_i])
                if _i < LEN(_ids)
                    _sql_ids += ","
                endif
            next
            _sql_ids += ")"
            _qry += " ( br_dok::char(6) ) IN " + _sql_ids
        endif

        _key_block := {|| STR( field->br_dok, 6, 0 )  } 
  endif

  _qry += " ORDER BY " + _order
  _qry += " LIMIT " + STR(_step) + " OFFSET " + STR(_offset) 


  DO CASE

    CASE algoritam == "FULL" .and. _offset==0
        // "full" algoritam
        log_write("datdok = nil full algoritam") 
        ZAP

    CASE algoritam == "DATE"

        log_write("datdok <> nil date algoritam") 
        // "date" algoritam  - brisi sve vece od zadanog datuma
        SET ORDER TO TAG "8"
        // tag je "DatDok" nije DTOS(DatDok)
        seek _dat
        do while !eof() .and. eval(_key_block)  >= _dat 
            // otidji korak naprijed
            SKIP
            _rec := RECNO()
            SKIP -1
            DELETE
            GO _rec  
        enddo

    CASE algoritam == "IDS"
        
        SET ORDER TO TAG "BR_DOK2"

        // CREATE_INDEX("BR_DOK2", "STR(br_dok) + DTOS(datum)", "KUF")
        // pobrisimo sve id-ove koji su drugi izmijenili
        do while .t.
            _fnd := .f.
            for each _tmp_id in _ids
                
                HSEEK _tmp_id
                
                do while !EOF() .and. EVAL(_key_block) == _tmp_id
                    skip
                    _rec := RECNO()
                    skip -1 
                    DELETE
                    go _rec 
                    _fnd := .t.
                enddo
            next
            if ! _fnd 
                exit
            endif
        enddo

  ENDCASE
  // sada je sve izbrisano

  _qry_obj := run_sql_query( _qry, _retry )

  @ _x + 4, _y + 2 SAY SECONDS() - _seconds 

  _counter := 1

  DO WHILE !_qry_obj:Eof()
    append blank
    
    /*
        "datum, datum_2, src, td_src, src_2, id_tar, id_part, part_idbr, part_kat, src_td, src_br,  " + ;
        "src_veza_b, src_br_2, r_br, br_dok, g_r_br, lock, kat, kat_2, opis, i_b_pdv, i_pdv, i_v_b_pdv,  " + ;
        "i_v_pdv, status, kat_p, kat_p_2, src_pm " + ;
    */

    replace datum with _qry_obj:FieldGet(1), ;
            datum_2 with _qry_obj:FieldGet(2), ;
            src with _qry_obj:FieldGet(3), ;
            td_src with _qry_obj:FieldGet(4), ;
            src_2 with _qry_obj:FieldGet(5), ;
            id_tar with _qry_obj:FieldGet(6), ;
            id_part with _qry_obj:FieldGet(7), ;
            part_idbr with _qry_obj:FieldGet(8), ;
            part_kat with _qry_obj:FieldGet(9), ;
            src_td with _qry_obj:FieldGet(10), ;
            src_br with _qry_obj:FieldGet(11), ;
            src_veza_b with _qry_obj:FieldGet(12), ;
            src_br_2 with _qry_obj:FieldGet(13), ;
            r_br with _qry_obj:FieldGet(14), ;
            br_dok with _qry_obj:FieldGet(15), ;
            g_r_br with _qry_obj:FieldGet(16), ;
            lock with _qry_obj:FieldGet(17), ;
            kat with _qry_obj:FieldGet(18), ;
            kat_2 with _qry_obj:FieldGet(19), ;
            opis with _qry_obj:FieldGet(20), ;
            i_b_pdv with _qry_obj:FieldGet(21), ;
            i_pdv with _qry_obj:FieldGet(22), ;
            i_v_b_pdv with _qry_obj:FieldGet(23), ;
            i_v_pdv with _qry_obj:FieldGet(24), ;
            status with _qry_obj:FieldGet(25), ;
            kat_p with _qry_obj:FieldGet(26), ;
            kat_p_2 with _qry_obj:FieldGet(27), ;
            src_pm with _qry_obj:FieldGet(28)
      
    _qry_obj:Skip()

    _counter++

    if _counter % 5000 == 0
        @ _x + 4, _y + 2 SAY SECONDS() - _seconds
    endif 
  ENDDO


next

USE

if (gDebug > 5)
    log_write("epdv_kif synchro cache:" + STR(SECONDS() - _seconds))
endif

return .t. 


// ----------------------------------------------
// ----------------------------------------------
function sql_epdv_kif_update( op, record )
LOCAL _ret
LOCAL _result
LOCAL _qry
LOCAL _tbl
LOCAL _where := ""
LOCAL _server := pg_server()

_tbl := "fmk.epdv_kif"

if record <> nil
    _where := "br_dok=" + _sql_quote(record["br_dok"]) 
endif

DO CASE
 CASE op == "BEGIN"
    _qry := "BEGIN;"
 CASE op == "END"
    _qry := "COMMIT;"
 CASE op == "ROLLBACK"
    _qry := "ROLLBACK;"
 CASE op == "del"
    _qry := "DELETE FROM " + _tbl + ;
             " WHERE " + _where
 CASE op == "ins"
    _qry := "INSERT INTO " + _tbl + ;
               "( datum, datum_2, src, td_src, src_2, id_tar, id_part, part_idbr, part_kat, src_td, src_br,  " + ;
               "src_pm, src_veza_b, src_br_2, r_br, br_dok, g_r_br, lock, kat, kat_2, opis, i_b_pdv, i_pdv, i_v_b_pdv,  " + ;
               "i_v_pdv, status, kat_p, kat_p_2 ) " + ;
               "VALUES(" + _sql_quote( record["datum"] )  + "," +;
                            + _sql_quote( record["datum_2"] ) + "," +; 
                            + _sql_quote( record["src"] ) + "," +; 
                            + _sql_quote( record["td_src"] ) + "," +; 
                            + _sql_quote( record["src_2"] ) + "," +;
                            + _sql_quote( record["id_tar"] ) + "," +;
                            + _sql_quote( record["id_part"] ) + "," +;
                            + _sql_quote( record["part_idbr"] ) + "," +;
                            + _sql_quote( record["part_kat"] ) + "," +;
                            + _sql_quote( record["src_td"] ) + "," +;
                            + _sql_quote( record["src_br"] ) + "," +;
                            + _sql_quote( record["src_pm"] ) + "," +;
                            + _sql_quote( record["src_veza_b"] ) + "," +;
                            + _sql_quote( record["src_br_2"] ) + "," +;
                            + STR( record["r_br"], 6, 0 ) + "," +;
                            + STR( record["br_dok"], 6, 0 ) + "," +;
                            + STR( record["g_r_br"], 8, 0 ) + "," +;
                            + _sql_quote( record["lock"] ) + "," +;
                            + _sql_quote( record["kat"] ) + "," +;
                            + _sql_quote( record["kat_2"] ) + "," +;
                            + _sql_quote( record["opis"] ) + "," +;
                            + STR( record["i_b_pdv"], 16, 2 ) + "," +;
                            + STR( record["i_pdv"], 16, 2 ) + "," +;
                            + STR( record["i_v_b_pdv"], 16, 2 ) + "," +;
                            + STR( record["i_v_pdv"], 16, 2 ) + "," +;
                            + _sql_quote( record["status"] ) + "," +;
                            + _sql_quote( record["kat_p"] ) + "," +;
                            + _sql_quote( record["kat_p_2"] ) + " )"
                          
ENDCASE
   
_ret := _sql_query( _server, _qry)

if (gDebug > 5)
   log_write(_qry)
   log_write("_sql_query VALTYPE(_ret) = " + VALTYPE(_ret))
endif

if VALTYPE(_ret) == "L"
   // u slucaju ERROR-a _sql_query vraca  .f.
   return _ret
else
   return .t.
endif
 
return




