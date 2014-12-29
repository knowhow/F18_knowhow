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

#include "fmk.ch"


// ---------------------------------------------------------
// napuni tablu sa servera
// step_size - broj zapisa koji se citaju u jednom query-u
// ---------------------------------------------------------
function full_synchro(dbf_table, step_size)
local _seconds
local _count
local _offset
local _qry
local _sql_table, _sql_fields
local _a_dbf_rec
local _sql_order
local _opened
local _sql_fetch_time, _dbf_write_time

// hernad: izbacen full sync u 1.4
RETURN .T.

if f18_session()['id'] > 1
    log_write("full_synchro u child thread se ne radi, preskocena tabela: "  + dbf_table, 3 )
    return .f.
endif

if step_size == NIL
    step_size := 20000
endif

nuliraj_ids_and_update_my_semaphore_ver(dbf_table)

// transakcija mi treba da bih sakrio promjene koje prave druge
// ako nemam transakcije onda se moze desiti ovo:
// 1) odabarem 100 000 zapisa i pocnem ih uzimati po redu (po dokumentima)
// 2) drugi korisnik izmijeni neki stari dokument u sredini prenosa i u njega doda 500 stavki
// 4) ja cu pokupiti 100 000 stavki a necu posljednjih 500
// 3) ako nema transakcije ja cu pokupiti tu promjenu, sa transakcijom ja tu promjenu neću vidjeti


_sql_table  := "fmk." + dbf_table
_a_dbf_rec  := get_a_dbf_rec(dbf_table)
_sql_fields := sql_fields(_a_dbf_rec["dbf_fields"])
_sql_order  := _a_dbf_rec["sql_order"]


// .t. - brisi indeksni fajl tako da se full sinchro obavlja bez azuriranja indeksa
// .f. - otvori indeks
reopen_exclusive_and_zap(_a_dbf_rec["table"], .t., .f.)

Box(, 6, 70)

    @ m_x + 1, m_y + 2 SAY "full synchro: " + _sql_table + " => " + dbf_table

    run_sql_query("BEGIN; SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
    _count := table_count( _sql_table, "true" )

    log_write( "START full_synchro table: " + dbf_table + "/ sql count: " + ALLTRIM(STR(_count)), 3)

    _seconds := SECONDS()

    if _sql_fields == NIL
        _msg := "sql_fields za " + _sql_table + " nije setovan ... sinhro nije moguć"
        log_write( "full_synchro: " + _msg, 2 )
        msgbeep( _msg )
        QUIT_1
    endif

    @ m_x + 3, m_y + 2 SAY _count

    for _offset := 0 to _count STEP step_size

        _qry :=  "SELECT " + _sql_fields + " FROM " +	_sql_table
        _qry += " ORDER BY " + _sql_order
        _qry += " LIMIT " + STR(step_size) + " OFFSET " + STR(_offset)

        log_write( "GET FROM SQL full_synchro tabela: " + dbf_table + " " + ALLTRIM(STR(_offset)) + " / qry: " + _qry, 7 )

        @ m_x + 5, m_y + 2 SAY "dbf <- qry "
        fill_dbf_from_server(dbf_table, _qry, @_sql_fetch_time, @_dbf_write_time)
        @ m_x + 5, m_y + 15 SAY "sql fetch time: " + ALLTRIM(STR(_sql_fetch_time)) + " dbf write time: " + ALLTRIM(STR(_dbf_write_time))

        @ m_x + 6, m_y + 2 SAY _offset + step_size
        @ row(), col() + 2 SAY "/"
        @ row(), col() + 2 SAY _count
        log_write( "STEP full_synchro tabela: " + dbf_table + " " + ALLTRIM(STR(_offset + step_size)) + " / " + ALLTRIM(STR(_count)), 7 )
    next

    if log_level() > 6
      _count := table_count( _sql_table, "true" )
       log_write( "full_synchro sql (END transaction): " + dbf_table + "/ sql count: " + ALLTRIM(STR(_count)), 7)
    endif

    run_sql_query("COMMIT")

    if log_level() > 6
       _count := table_count( _sql_table, "true" )
       log_write( "sql count nakon END transaction): " + dbf_table + "/ sql count: " + ALLTRIM(STR(_count)), 7)
    endif

BoxC()

MsgO("Reindex nakon full sync: " + dbf_table)
   log_write("reopen sa indexom, START reindex " + dbf_table, 3)
   reopen_exclusive(_a_dbf_rec["table"], .t.)
   REINDEX
MsgC()

USE

log_write( "END full_synchro tabela: " + dbf_table +  " cnt: " + ALLTRIM(STR(_count)), 3 )


return .t.
