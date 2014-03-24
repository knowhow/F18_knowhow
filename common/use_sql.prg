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

#include "fmk.ch"
#include "dbinfo.ch"
#include "error.ch"


REQUEST SDDPG, SQLMIX

// -----------------------------------------
// -----------------------------------------
function use_sql_sif( table, l_make_index )
LOCAL oConn


if USED()
   USE
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

return .T.


// -----------------------------------------
// -----------------------------------------
function use_sql( table, sql_query )
LOCAL oConn


if USED()
   USE
endif

oConn := my_server():pDB 
//? PQHOST(oConn)

rddSetDefault( "SQLMIX" )

IF rddInfo( RDDI_CONNECT, { "POSTGRESQL", oConn } ) == 0
      ? "Unable connect to the server"
      RETURN
ENDIF

dbUseArea( .f., "SQLMIX", sql_query,  table )

rddSetDefault( "DBFCDX" )

return .T.

/*
   use_sql_sifk() => otvori citavu tabelu
   use_sql_sifk( "ROBA", "GR1  " ) =>  filter na ROBA/GR1
*/
function use_sql_sifk( cDbf, cOznaka )

   LOCAL cSql
   LOCAL cTable := "sifk"

   cSql := "SELECT * from fmk.sifk"
   IF cDbf != NIL 
       cSql += " WHERE id=" + _sql_quote( cDbf ) 
   ENDIF
   IF cOznaka != NIL
       cSql += " AND oznaka=" + _sql_quote( cOznaka )
   ENDIF
    
   cSQL += " ORDER BY id,oznaka,sort" 
   SELECT F_SIFK
   use_sql( cTable, cSql )


   if cDbf == NIL .and. cOznaka == NIL 
      INDEX ON ID+SORT+NAZ TAG ID  TO ( cTable )
      INDEX ON NAZ            TAG NAZ TO ( cTable )
      SET ORDER TO TAG ID
   endif

   RETURN .T.


/*
   use_sql_sifv( "ROBA", "GR1", NIL, "G000000001" ) =>  filter na ROBA/GR1/grupa1=G0000000001
   use_sql_isfv( "ROBA", "GR1", "ROBA99", NIL )        =>  filter na ROBA/GR1/idroba=ROBA99
*/
function use_sql_sifv( cDbf, cOznaka, cIdSif, cVrijednost )

   LOCAL cSql

   IF cDbf == NIL
      SELECT F_SIFK
      IF !USED()
         Alert("USE_SQL Prije SIFV mora se otvoriti SIFK !")
         QUIT_1
      ENDIF
      cDbf := field->id
      cOznaka := field->oznaka
   ENDIF

   cSql := "SELECT * from fmk.sifv"
   cSql += " WHERE id=" + _sql_quote( cDbf ) + " AND oznaka=" + _sql_quote( cOznaka )
   
   IF cIdSif != NIL
      cSql += " AND idsif=" + _sql_quote( cIdSif )
   ENDIF

   IF cVrijednost != NIL
      cSql += " AND naz=" + _sql_quote( cVrijednost )
   ENDIF

   cSQL += " ORDER BY id,oznaka,idsif,naz" 
   SELECT F_SIFV
   use_sql( "sifv", cSql )

   RETURN .T.


