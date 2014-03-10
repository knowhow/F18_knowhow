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

static __connected := .f.

//ANNOUNCE RDDSYS

// -----------------------------------------
// -----------------------------------------
function use_sql( table, l_make_index )

if l_make_index == NIL
   l_make_index = .f.
endif

//AEval( rddList(), {| x | QOut( x ) } )
//inkey(0)

rddSetDefault( "SQLMIX" )

if !__connected 
IF rddInfo( RDDI_CONNECT, { "POSTGRESQL", "localhost", "test1", "test1" , "f18_2014" } ) == 0
      ? "Unable connect to the server"
      RETURN
ENDIF
__connected := .t.
endif


dbUseArea( .f., "SQLMIX", "SELECT * FROM fmk." + table,  table )

if l_make_index
  INDEX ON ID TAG ID TO (table)
  INDEX ON NAZ TAG NAZ TO (table)
endif

rddSetDefault( "DBFCDX" )

return .f.
