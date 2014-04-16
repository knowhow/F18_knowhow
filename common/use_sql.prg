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
   use_sql_opstine() => otvori šifarnik tarifa sa prilagođenim poljima
*/
function use_sql_opstine()

   LOCAL cSql
   LOCAL cTable := "ops"

   SELECT ( F_OPS )
   use_sql_sif( cTable )

   INDEX ON IDJ TAG IDJ TO ( cTable )
   INDEX ON IDKAN TAG IDKAN TO ( cTable )
   INDEX ON IDN0 TAG IDN0 TO ( cTable )

   SET ORDER TO TAG ID

   RETURN .T.



/*
   use_sql_rj() => otvori šifarnik radnih jedinica sa prilagođenim poljima
*/
function use_sql_rj()

   LOCAL cSql
   LOCAL cTable := "rj"

   cSql := "SELECT "
   cSql += " id, "
   cSql += " ( CASE WHEN match_code IS NULL THEN rpad( '', 10 ) ELSE match_code END ) AS match_code, "
   cSql += " ( CASE WHEN naz IS NULL THEN rpad( '', 100 ) ELSE naz END ) AS naz, "
   cSql += " CAST( CASE WHEN tip IS NULL THEN rpad( '', 2 ) ELSE tip END AS character(2) ) AS tip, "
   cSql += " CAST( CASE WHEN konto IS NULL THEN rpad( '', 7 ) ELSE konto END AS character(7) ) AS konto "
   cSql += "FROM fmk.rj ORDER BY id"

   SELECT F_RJ
   use_sql( cTable, cSql )

   INDEX ON ID TAG ID TO ( cTable )
   INDEX ON NAZ TAG NAZ TO ( cTable )

   SET ORDER TO TAG ID

   RETURN .T.



/*
   use_sql_valute() => otvori šifarnik valuta sa prilagođenim poljima
*/
function use_sql_valute()

   LOCAL cSql
   LOCAL cTable := "valute"

   cSql := "SELECT "
   cSql += " id, "
   cSql += " ( CASE WHEN match_code IS NULL THEN rpad( '', 10 ) ELSE match_code END ) AS match_code, "
   cSql += " ( CASE WHEN naz IS NULL THEN rpad( '', 30 ) ELSE naz END ) AS naz, "
   cSql += " ( CASE WHEN naz2 IS NULL THEN rpad( '', 4 ) ELSE naz2 END ) AS naz2, "
   cSql += " ( CASE WHEN datum IS NULL THEN '1960-01-01'::date ELSE datum END ) AS datum, "
   cSql += " CAST( CASE WHEN kurs1 IS NULL THEN 0 ELSE kurs1 END AS numeric(18,8) ) AS kurs1, "
   cSql += " CAST( CASE WHEN kurs2 IS NULL THEN 0 ELSE kurs2 END AS numeric(18,8) ) AS kurs2, "
   cSql += " CAST( CASE WHEN kurs3 IS NULL THEN 0 ELSE kurs3 END AS numeric(18,8) ) AS kurs3, "
   cSql += " ( CASE WHEN tip IS NULL THEN ' ' ELSE tip END ) AS tip "
   cSql += "FROM fmk.valute ORDER BY id"

   SELECT F_VALUTE
   use_sql( cTable, cSql )

   INDEX ON ID TAG ID TO ( cTable )
   INDEX ON TIP+ID+DTOS(DATUM) TAG NAZ TO ( cTable )
   INDEX ON ID+DTOS(DATUM) TAG ID2 TO ( cTable )

   SET ORDER TO TAG ID

   RETURN .T.


/*
   use_sql_ks() => otvori šifarnik kamatnih stopa sa prilagođenim poljima
*/
function use_sql_ks()

   LOCAL cSql
   LOCAL cTable := "ks"

   cSql := "SELECT "
   cSql += "  id, "
   cSql += "  naz, "
   cSql += "  datod, "
   cSql += "  datdo, "
   cSql += "  CAST( CASE WHEN strev IS NULL THEN 0.0000 ELSE strev END AS float8 ) AS strev, "
   cSql += "  CAST( CASE WHEN stkam IS NULL THEN 0.0000 ELSE stkam END AS float8 ) AS stkam, "
   cSql += "  CAST( CASE WHEN den IS NULL THEN 0.000000 ELSE den END AS float8 ) AS den, "
   cSql += "  tip, "
   cSql += "  CAST( CASE WHEN duz IS NULL THEN 0 ELSE duz END AS float8 ) AS duz "
   cSql += "FROM fmk.ks "
   cSQL += "ORDER BY id" 


   SELECT ( F_KS )
   use_sql( cTable, cSql )

   INDEX ON ID TAG ID TO ( cTable )
   INDEX ON DTOS(DATOD) TAG "2" TO ( cTable )

   SET ORDER TO TAG ID

   RETURN .T.



/*
   use_sql_pkonto() => otvori šifarnik pkonto sa prilagođenim poljima
*/
function use_sql_pkonto()

   LOCAL cSql
   LOCAL cTable := "pkonto"

   cSql := "SELECT * FROM fmk.pkonto ORDER BY id"

   SELECT F_PKONTO
   use_sql( cTable, cSql )

   INDEX ON ID TAG ID TO ( cTable )
   INDEX ON TIP TAG NAZ TO ( cTable )

   SET ORDER TO TAG ID

   RETURN .T.


/*
   use_sql_lokal() => otvori šifarnik lokalizacije sa prilagođenim poljima
*/
function use_sql_lokalizacija()

   LOCAL cSql
   LOCAL cTable := "lokal"

   cSql := "SELECT * FROM fmk.lokal ORDER BY id"

   SELECT F_LOKAL
   use_sql( cTable, cSql )

   INDEX ON ID+STR(ID_STR,6)+NAZ TAG ID TO ( cTable )
   INDEX ON ID+NAZ TAG IDNAZ TO ( cTable )
   INDEX ON STR(ID_STR,6)+NAZ+ID TAG ID_STR TO ( cTable )
   INDEX ON NAZ+STR(ID_STR,6) TAG NAZ TO ( cTable )

   SET ORDER TO TAG ID

   RETURN .T.





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
   cSql += "  CAST( CASE WHEN dlruc IS NULL THEN 0.00 ELSE dlruc END AS float8 ) AS dlruc, "
   cSql += "  ( CASE WHEN match_code IS NULL THEN rpad('',10) ELSE match_code END ) AS match_code "
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
   use_sql_trfp() => otvori šifarnik šema kontiranja kalk->fin sa uslovima
*/
function use_sql_trfp( cShema, cDok )
return _use_sql_trfp( "trfp", F_TRFP, cShema, cDok )


/*
   use_sql_trfp2() => otvori šifarnik šema kontiranja fakt->fin sa uslovima
*/
function use_sql_trfp2( cShema, cDok )
return _use_sql_trfp( "trfp2", F_TRFP2, cShema, cDok )



/*
   use_sql_trfp() => otvori šifarnik šema kontiranja sa uslovima
*/
static function _use_sql_trfp( cTable, nWa, cShema, cDok )

   LOCAL cSql
   LOCAL cWhere := ""

   cSql := "SELECT * FROM fmk." + cTable 

   if cShema <> NIL
         cWhere += " shema = " + _sql_quote( cShema )
   endif

   if cDok <> NIL .and. !EMPTY( cDok )
         if !EMPTY( cWhere )
               cWhere += " AND "
         endif
         cWhere += " idvd = " + _sql_quote( cDok )
   endif

   if !EMPTY( cWhere )
         cSql += " WHERE " + cWhere
   endif

   cSql += " ORDER BY idvd, shema, idkonto, id, idtarifa, idvn, naz"

   SELECT ( nWa )
   use_sql( cTable, cSql )
   
   INDEX ON ( field->idvd + field->shema + field->idkonto + field->id + field->idtarifa + field->idvn + field->naz )  TAG ID TO ( cTable )

   SET ORDER TO TAG "ID"

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
      INDEX ON ID+OZNAKA TAG ID2  TO ( cTable )
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
   LOCAL cTable := "sifv"

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

   INDEX ON ID+OZNAKA+IDSIF+NAZ TAG ID  TO ( cTable )
   INDEX ON ID+IDSIF TAG IDIDSIF  TO ( cTable )
   GO TOP
   SET ORDER TO TAG "ID"

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


