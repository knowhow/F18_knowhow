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

#require "rddsql"
#require "sddpg"

#include "dbinfo.ch"
#include "error.ch"


REQUEST SDDPG, SQLMIX

// -----------------------------------------
// -----------------------------------------
function use_sql_sif( table, l_make_index )
LOCAL oConn


if USED()
   return .f.
endif

if l_make_index == NIL
   l_make_index = .f.
endif

//AEval( rddList(), {| x | QOut( x ) } )
//inkey(0)

oConn := my_server():pDB 
//? PQHOST(oConn)

rddSetDefault( "SQLMIX" )

IF rddInfo( RDDI_CONNECT, { "POSTGRESQL", oConn } ) == 0
      ? "Unable connect to the server"
      RETURN
ENDIF

dbUseArea( .f., "SQLMIX", "SELECT * FROM fmk." + table + " ORDER BY ID",  table )

if l_make_index
     INDEX ON ID TAG ID TO (table)
     INDEX ON NAZ TAG NAZ TO (table)
endif


rddSetDefault( "DBFCDX" )

return .f.
