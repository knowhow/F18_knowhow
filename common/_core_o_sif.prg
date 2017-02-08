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

#include "f18.ch"

FIELD id, naz


FUNCTION o_roba( cId )

   LOCAL cTabela := "roba"

   SELECT ( F_ROBA )
   IF !use_sql_sif  ( cTabela, .T., "ROBA", cId  )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION select_o_roba( cId )

   SELECT ( F_ROBA )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_roba( cId )



FUNCTION seek_roba_partial( cIdRobaDio )

   LOCAL cAlias := "ROBA"
   LOCAL cSqlQuery := "select * from fmk.roba"

   cSqlQuery += " WHERE id like" + cIdRobaDio + "%"

   IF !use_sql( "roba", cSqlQuery, cAlias )
      RETURN .F.
   ENDIF

   INDEX ON ID TAG ID TO ( cAlias )
   INDEX ON NAZ TAG NAZ TO ( cAlias )
   SET ORDER TO TAG "ID"

   SEEK cIdRobaDio
   IF !Found()
      GO TOP
   ENDIF

   RETURN .T.



FUNCTION find_roba_by_naz_or_id( cId )

   LOCAL cAlias := "ROBA"
   LOCAL cSqlQuery := "select * from fmk.roba"
   LOCAL cIdSql

   cIdSql := sql_quote( "%" + Upper( AllTrim( cId ) ) + "%" )
   cSqlQuery += " WHERE id ilike " + cIdSql
   cSqlQuery += " OR naz ilike " + cIdSql
   cSqlQuery += " OR sifradob ilike " + cIdSql
   cSqlQuery += " OR barkod ilike " + cIdSql

   IF !use_sql( "roba", cSqlQuery, cAlias )
      RETURN .F.
   ENDIF

   INDEX ON ID TAG ID TO ( cAlias )
   INDEX ON NAZ TAG NAZ TO ( cAlias )
   SET ORDER TO TAG "ID"

   SEEK cId
   IF !Found()
      GO TOP
   ENDIF

   RETURN .T.



FUNCTION o_sastavnica( cId )

   LOCAL cTabela := "sast"

   SELECT ( F_SAST )
   IF !use_sql_sif  ( cTabela, .T., "SAST", cId  )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION o_sast( cId )
   RETURN o_sastavnica( cId )


FUNCTION select_o_sastavnica( cId )

   SELECT ( F_SAST )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_sastavnica( cId )


FUNCTION select_o_sast( cId )
   RETURN select_o_sastavnica( cId )



FUNCTION o_banke( cId )

   SELECT ( F_BANKE )
   IF !use_sql_sif  ( "banke", .T., "BANKE", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_banke( cId )

   SELECT ( F_BANKE )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_banke( cId )


FUNCTION find_partner_by_naz_or_id( cId )

   LOCAL cAlias := "PARTN"
   LOCAL cSqlQuery := "select * from fmk.partn"
   LOCAL cIdSql

   cIdSql := sql_quote( "%" + Upper( AllTrim( cId ) ) + "%" )
   cSqlQuery += " WHERE id ilike " + cIdSql
   cSqlQuery += " OR naz ilike " + cIdSql
   cSqlQuery += " OR mjesto ilike " + cIdSql

   IF !use_sql( "partn", cSqlQuery, cAlias )
      RETURN .F.
   ENDIF
   INDEX ON ID TAG ID TO ( cAlias )
   INDEX ON NAZ TAG NAZ TO ( cAlias )
   SET ORDER TO TAG "ID"

   SEEK cId
   IF !Found()
      GO TOP
   ENDIF

   RETURN .T.


FUNCTION find_konto_by_naz_or_id( cId )

   LOCAL cAlias := "KONTO"
   LOCAL cSqlQuery := "select * from fmk.konto"
   LOCAL cIdSql

   cIdSql := sql_quote( "%" + Upper( AllTrim( cId ) ) + "%" )
   cSqlQuery += " WHERE id ilike " + cIdSql
   cSqlQuery += " OR naz ilike " + cIdSql

   IF !use_sql( "konto", cSqlQuery, cAlias )
      RETURN .F.
   ENDIF
   INDEX ON ID TAG ID TO ( cAlias )
   INDEX ON NAZ TAG NAZ TO ( cAlias )
   SET ORDER TO TAG "ID"

   SEEK cId
   IF !Found()
      GO TOP
   ENDIF

   RETURN .T.



FUNCTION o_partner( cId )

   LOCAL cTabela := "partn"

   SELECT ( F_PARTN )
   IF !use_sql_sif  ( cTabela, .T., "PARTN", cId  )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION select_o_partner( cId )

   SELECT ( F_PARTN )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_partner( cId )





FUNCTION o_konto( cId )

   LOCAL cTabela := "konto"

   SELECT ( F_KONTO )
   IF !use_sql_sif  ( cTabela, .T., "KONTO", cId  )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION select_o_konto( cId )

   SELECT ( F_KONTO )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_konto( cId )




FUNCTION o_vrste_placanja()

   LOCAL cTabela := "vrstep"

   SELECT ( F_VRSTEP )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


/*

FUNCTION o_vrnal()

--   LOCAL cTabela := "vrnal"

   SELECT ( F_VRNAL )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   RETURN .T.
  */

/*
--FUNCTION o_relac()

   LOCAL cTabela := "relac"

   SELECT ( F_RELAC )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   RETURN .T.
*/




FUNCTION o_rj( cId )

   SELECT ( F_RJ )
   IF !use_sql_sif  ( "rj", .T., "RJ", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_rj( cId )

   SELECT ( F_RJ )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_rj( cId )


FUNCTION o_valute()

   SELECT ( F_VALUTE )
   use_sql_valute()
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_refer()

   SELECT ( F_REFER )
   use_sql_sif  ( "refer" )
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_ops( cId )

   SELECT ( F_OPS )
   use_sql_opstine( cId )
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_ops( cId )

   SELECT ( F_OPS )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_ops( cId )


/*
      use_sql_opstine() => otvori šifarnik tarifa sa prilagođenim poljima
*/

FUNCTION use_sql_opstine( cId )

   LOCAL cTable := "ops"

   SELECT ( F_OPS )
   IF !use_sql_sif( cTable, .T., "OPS", cId )
      RETURN .F.
   ENDIF

   RETURN .T.





FUNCTION o_dest()

   LOCAL cTabela := "dest"

   SELECT ( F_DEST )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_trfp()

   SELECT ( F_TRFP )
   use_sql_trfp()
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_trfp2()

   SELECT ( F_TRFP2 )
   use_sql_trfp2()
   SET ORDER TO TAG "ID"

   RETURN .T.
