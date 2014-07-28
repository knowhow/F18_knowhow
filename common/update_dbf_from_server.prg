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
// get data from sql server, push to dbf
// --------------------------------------------------------
FUNCTION update_dbf_from_server( table, algoritam )

   LOCAL _qry
   LOCAL _counter
   LOCAL _rec
   LOCAL _qry_obj
   LOCAL _server := pg_server()
   LOCAL _seconds
   LOCAL _x, _y
   LOCAL _ids
   LOCAL _fnd, _tmp_id
   LOCAL _count
   LOCAL _sql_tbl, _dbf_tbl
   LOCAL _offset
   LOCAL _step := 50000
   LOCAL _retry := 3
   LOCAL _key_blocks := {}
   LOCAL _key_block
   LOCAL _i, _fld, _dbf_fields, _sql_fields, _sql_order
   LOCAL _sql_in := {}
   LOCAL _queries
   LOCAL _dbf_index_tags := {}
   LOCAL _dbf_wa, _dbf_alias
   LOCAL _ids_queries
   LOCAL _table
   LOCAL _a_dbf_rec

   _a_dbf_rec  := get_a_dbf_rec( table )
   _dbf_fields := _a_dbf_rec[ "dbf_fields" ]
   _sql_fields := sql_fields( _dbf_fields )
   _sql_order  := _a_dbf_rec[ "sql_order" ]
   _dbf_wa     := _a_dbf_rec[ "wa" ]
   _dbf_alias  := _a_dbf_rec[ "alias" ]
   _sql_tbl    := "fmk." + table

   _x := maxrows() - 15
   _y := maxcols() - 20

   IF algoritam == NIL
      algoritam := "FULL"
   ENDIF

   _seconds := Seconds()

   log_write( "START update_dbf_from_server", 9 )

   IF algoritam == "FULL"

      log_write( "update_dbf_from_server(), iniciraj full synchro", 8 )

      // full synchro ne treba otvorenu tabelu, on je ionako zapuje
      full_synchro ( table, _step )

   ELSE
      log_write( "update_dbf_from_server(), iniciraj ids synchro", 8 )

      // samo otvori tabelu da je ids_synchro moze napuniti
      SELECT ( _dbf_wa )
      my_use ( _dbf_alias, table, .F., "SEMAPHORE" )

      ids_synchro  ( table )
   ENDIF

   USE

   log_write( "update_dbf_from_server table: " + table + " synchro cache: " + Str( Seconds() - _seconds ), 5 )

   log_write( "END update_dbf_from_server", 9 )

   RETURN .T.
