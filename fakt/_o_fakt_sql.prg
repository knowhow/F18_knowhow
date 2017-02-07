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



FUNCTION o_sastavnica()

   SELECT ( F_SAST )
   my_use  ( "sast" )
   SET ORDER TO TAG "ID"

   RETURN .T.

FUNCTION select_o_sastavnica()
   RETURN select_o_dbf( "SAST", F_SAST, "sast", "ID" )


FUNCTION o_sast( cId )
   RETURN o_sastavnica( cId )

FUNCTION select_o_sast( cId )
   RETURN select_o_sastavnica( cId )



FUNCTION select_O_FAKT_TXT()
   RETURN .T.

   /*
      ftxt uzorci teksta fakture

   FUNCTION o_fakt_txt()

      RETURN o_dbf_table( F_FTXT, "ftxt", "ID" )
*/


FUNCTION SEEK_FAKT_3()
   RETURN .T.

FUNCTION SEEK_FAKT_6()
   RETURN .T.

FUNCTION SEEK_FAKT_DOKS_IDPARTNER()
   RETURN .T.


FUNCTION   SEEK_FAKT_FAKT_3()
   RETURN .T.

FUNCTION SEEK_FAKT_IDROBA()
   RETURN .T.

FUNCTION SEEK_FAKT_IDROBA_SINTETIKA()
   RETURN .T.



FUNCTION SEEK_FAKT_UPL()
   RETURN .T.

FUNCTION SEEK_FAKT_UPLATE()
   RETURN seek_fakt_upl()

FUNCTION SEEK_GEN_UG_DAT_OBR()
   RETURN .T.

FUNCTION SEEK_ROBA_PARTIAL()
   RETURN .T.

FUNCTION SEEK_RUGOV()
   RETURN .T.

FUNCTION SEEK_UGOV()
   RETURN .T.

FUNCTION SELECT_FAKT_DOKS()
   RETURN .T.

FUNCTION SELECT_O_BANKA()
   RETURN .T.

FUNCTION SELECT_O_FAKT_OBJEKTI()
   RETURN .T.

FUNCTION SELECT_O_FTXT()
   RETURN .T.


FUNCTION SELECT_O_RJ()
   RETURN .T.




FUNCTION seek_fakt( cIdFirma, cIdTipDok, cBrDok, cIdRoba, cTag )

   LOCAL cSql
   LOCAL cTable := "fakt_fakt", cAlias := "FAKT"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable


   IF cIdFirma != NIL .AND. !Empty( cIdFirma )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idfirma=" + sql_quote( cIdFirma )
   ENDIF

   IF cIdTipDok != NIL .AND. !Empty( cIdTipDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idtipdok=" + sql_quote( cIdTipDok )
   ENDIF


   IF cBrDok != NIL .AND. !Empty( cBrDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "brdok=" + sql_quote( cBrDok )
   ENDIF


   IF cIdRoba != NIL .AND. !Empty( cIdRoba )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "idroba=" + sql_quote( cIdRoba )
   ENDIF

   SELECT F_FAKT
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_fakt_fakt_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT
   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN .T.


FUNCTION find_fakt_dokument( cIdFirma, cIdTipDok, cBrDok )

   LOCAL lRet

   seek_fakt_doks( cIdFirma, cIdTipDok, cBrDok, "1" )

   lRet := cIdFirma == fakt_doks->idfirma .AND. cIdTipDok == fakt_doks->idtipdok .AND. cBrDok == fakt_doks->brdok

   RETURN lRet


FUNCTION seek_fakt_doks( cIdFirma, cIdTipDok, cBrDok, cTag )

   LOCAL cSql
   LOCAL cTable := "fakt_doks", cAlias := "FAKT_DOKS"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable


   IF cIdFirma != NIL .AND. !Empty( cIdFirma )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idfirma=" + sql_quote( cIdFirma )
   ENDIF

   IF cIdTipDok != NIL .AND. !Empty( cIdTipDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idtipdok=" + sql_quote( cIdTipDok )
   ENDIF


   IF cBrDok != NIL .AND. !Empty( cBrDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "brdok=" + sql_quote( cBrDok )
   ENDIF



   SELECT F_FAKT_DOKS
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_fakt_doks_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT
   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN .T.





FUNCTION seek_fakt_doks2( cIdFirma, cIdTipDok, cBrDok, cTag )

   LOCAL cSql
   LOCAL cTable := "fakt_doks2", cAlias := "FAKT_DOSK2"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable


   IF cIdFirma != NIL .AND. !Empty( cIdFirma )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idfirma=" + sql_quote( cIdFirma )
   ENDIF

   IF cIdTipDok != NIL .AND. !Empty( cIdTipDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idtipdok=" + sql_quote( cIdTipDok )
   ENDIF


   IF cBrDok != NIL .AND. !Empty( cBrDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "brdok=" + sql_quote( cBrDok )
   ENDIF



   SELECT F_FAKT_DOKS2
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_fakt_doks2_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT
   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN .T.
