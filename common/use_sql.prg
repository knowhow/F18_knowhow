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
   l_make_index = .t.
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
     IF FIELDPOS( "NAZ" ) > 0
       INDEX ON NAZ TAG NAZ TO (table)
     ENDIF
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
   use_sql_tarifa() => otvori šifarnik tarifa sa prilagođenim poljima
*/
function use_sql_tarifa( l_make_index )

   LOCAL cSql
   LOCAL cTable := "tarifa"

   if l_make_index == NIL
         l_make_index := .t.
   endif

   cSql := "SELECT "
   cSql += "  id, "
   cSql += "  naz, "
   cSql += "  CAST( CASE WHEN opp IS NULL THEN 0.00 ELSE opp END AS float8 ) AS opp, "
   cSql += "  CAST( CASE WHEN ppp IS NULL THEN 0.00 ELSE ppp END AS float8 ) AS ppp, "
   cSql += "  CAST( CASE WHEN zpp IS NULL THEN 0.00 ELSE zpp END AS float8 ) AS zpp, "
   cSql += "  CAST( CASE WHEN vpp IS NULL THEN 0.00 ELSE vpp END AS float8 ) AS vpp, "
   cSql += "  CAST( CASE WHEN mpp IS NULL THEN 0.00 ELSE mpp END AS float8 ) AS mpp, "
   cSql += "  CAST( CASE WHEN dlruc IS NULL THEN 0.00 ELSE dlruc END AS float8 ) AS dlruc "
   cSql += "FROM fmk.tarifa "
   cSQL += "ORDER BY id" 

   SELECT F_TARIFA
   use_sql( cTable, cSql )

   if l_make_index
         INDEX ON ID TAG ID TO ( cTable )
         INDEX ON NAZ TAG NAZ TO ( cTable )
   endif

   SET ORDER TO TAG ID

   RETURN .T.



/*
   use_sql_trfp() => otvori šifarnik šema kontiranja sa uslovima
*/
function use_sql_trfp( shema, dok, l_make_index )

   LOCAL cSql
   LOCAL cTable := "trfp"
   LOCAL cWhere := ""

   if l_make_index == NIL
         l_make_index := .t.
   endif

   cSql := "SELECT * FROM " + cTable 

   if shema <> NIL .and. !EMPTY( shema )
         cWhere += " shema = " + _sql_quote( shema )
   endif

   if dok <> NIL .and. !EMPTY( dok )
         if !EMPTY( cWhere )
               cWhere += " AND "
         endif
         cWhere += " idvd = " + _sql_quote( dok )
   endif

   if !EMPTY( cWhere )
         cSql += " WHERE " + cWhere
   endif

   cSql += " ORDER BY idvd, shema, idkonto, id, idtarifa, idvn, naz"

   SELECT F_TRFP
   use_sql( cTable, cSql )

   if l_make_index
         INDEX ON IDVD + SHEMA + IDKONTO + ID + IDTARIFA + IDVN + NAZ TAG ID TO ( cTable )
   endif

   SET ORDER TO TAG ID

   RETURN .T.




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
      INDEX ON NAZ             TAG NAZ TO ( cTable )
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
   
   IF cIdSif == NIL
      IF EMPTY( cDbf )
        // nepostojeca sifra
        cIdSif := "MLFJUSX" + CHR(170)
      ELSE
        cIdSif := ( cDbf )->id
      ENDIF
   ENDIF
   cSql += " AND idsif=" + _sql_quote( cIdSif )

   IF cVrijednost != NIL
      cSql += " AND naz=" + _sql_quote( cVrijednost )
   ENDIF

   cSQL += " ORDER BY id,oznaka,idsif,naz" 
   SELECT F_SIFV
   use_sql( "sifv", cSql )

   RETURN .T.


// ----------------------------------
// kreiranje tabela "rules"
// ----------------------------------
function use_sql_rules()

   local _table_name, _alias
   LOCAL cSql 

   _alias := "FMKRULES"
   _table_name := "f18_rules"


   cSql := "SELECT * FROM fmk." + _table_name
   
   SELECT F_FMKRULES
   use_sql( _alias, cSql )

   INDEX ON STR(RULE_ID,10)                                       TAG 1 TO (_table_name)
   INDEX ON MODUL_NAME+RULE_OBJ+STR(RULE_NO,10)                   TAG 2 TO (_table_name)
   INDEX ON MODUL_NAME+RULE_OBJ+STR(RULE_LEVEL,2)+STR(RULE_NO,10) TAG 3 TO (_table_name)
   INDEX ON MODUL_NAME+RULE_OBJ+RULE_C1+RULE_C2                   TAG 4 TO (_table_name)
   // kreiranje rules index-a specificnih za rnal
   INDEX ON MODUL_NAME+RULE_OBJ+RULE_C3+RULE_C4                   TAG ELCODE TO (_table_name)
   INDEX ON MODUL_NAME+RULE_OBJ+RULE_C3+STR(RULE_NO,5)            TAG RNART1 TO (_table_name)
   INDEX ON MODUL_NAME+RULE_OBJ+RULE_C5+STR(RULE_NO,5)            TAG ITEM1  TO (_table_name)
   // kreiranje rules index-a specificnih za fin
   INDEX ON MODUL_NAME+RULE_OBJ+STR(RULE_NO,5)                    TAG FINKNJ1 TO (_table_name)
   INDEX ON MODUL_NAME+RULE_OBJ+RULE_C3                           TAG ELBA1 TO (_table_name)

   return .T.


