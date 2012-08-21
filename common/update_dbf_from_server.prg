/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"
#include "common.ch"

// --------------------------------------------------------
// sinhronizacija sa servera
// --------------------------------------------------------
function update_dbf_from_server(table, algoritam)
local _qry
local _counter
local _rec
local _qry_obj
local _server := pg_server()
local _seconds
local _x, _y
local _ids
local _fnd, _tmp_id
local _count
local _sql_tbl, _dbf_tbl
local _offset
local _step := 15000
local _retry := 3
local _key_blocks := {} 
local _key_block
local _i, _fld, _dbf_fields, _sql_fields, _sql_order
local _sql_in := {}
local _queries
local _dbf_index_tags := {}
local _dbf_wa, _dbf_alias
local _ids_queries
local _table
local _a_dbf_rec


_a_dbf_rec  := get_a_dbf_rec(table)

_dbf_fields := _a_dbf_rec["dbf_fields"]
_sql_fields := sql_fields( _dbf_fields )

_sql_order  := _a_dbf_rec["sql_order"]

_dbf_wa     := _a_dbf_rec["wa"]
_dbf_alias  := _a_dbf_rec["alias"]

_sql_tbl    := "fmk." + table

_x := maxrows() - 15
_y := maxcols() - 20

if algoritam == NIL
   algoritam := "FULL"
endif

_seconds := SECONDS()

if algoritam == "FULL"

    SELECT (_dbf_wa)
    my_usex (_dbf_alias, table, .f., "SEMAPHORE")
    nuliraj_ids(table )
    full_synchro (table, _step)
    update_semaphore_version( table, .f., .f. )

else

    if lock_semaphore(table, "lock")
 
        SELECT (_dbf_wa)
        my_usex (_dbf_alias, table, .f., "SEMAPHORE")

        //mi sa SQL transakcijom nista ne dobijamo
        // s obzirom da nasa aplikacija koristi nas lock-free mehanizam
        // cak sta vise transakcija nam smeta da ostali useri "vide" da smo 
        // zakljucali tabelu
        //sql_table_update(nil, "BEGIN")
        
        if "pos_pos" $ table .or. "fakt_fakt" $ table
            msgo("semaphore ids sleep")
            sleep(10)
            msgc()
        endif

        ids_synchro  (table)
        lock_semaphore(table, "free")
        update_semaphore_version(table, .f.)
        //sql_table_update(nil, "END")
    else
        //sql_table_update(nil, "ROLLBACK")
    endif

endif

USE

log_write( table + " synchro cache: " + STR(SECONDS() - _seconds), 3 )

return .t. 



