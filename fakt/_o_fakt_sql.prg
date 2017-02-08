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




FUNCTION o_fakt_txt( cId )

   SELECT ( F_BANKE )
   IF !use_sql_sif  ( "fakt_ftxt", .T., "FTXT", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_fakt_txt( cId )

   SELECT ( F_FTXT )
   IF !use_sql_sif  ( "fakt_ftxt", .T., "FTXT", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN o_fakt_txt( cId )


FUNCTION o_fakt_objekti( cId )

   SELECT ( F_FAKT_OBJEKTI )
   IF !use_sql_sif  ( "fakt_objekti", .T., "FAKT_OBJEKTI", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_fakt_objekti( cId )

   SELECT ( F_FAKT_OBJEKTI )
   IF !use_sql_sif  ( "fakt_objekti", .T., "FAKT_OBJEKTI", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN o_fakt_objekti( cId )


FUNCTION select_o_ftxt( cId )
   RETURN select_o_fakt_txt( cId )




FUNCTION find_fakt_dokument( cIdFirma, cIdTipDok, cBrDok )

   LOCAL lRet

   seek_fakt_doks( cIdFirma, cIdTipDok, cBrDok, "1" )

   lRet := cIdFirma == fakt_doks->idfirma .AND. cIdTipDok == fakt_doks->idtipdok .AND. cBrDok == fakt_doks->brdok

   RETURN lRet

FUNCTION seek_fakt_doks( cIdFirma, cIdTipDok, cBrDok, cIdPartner, cTag, aWorkarea )

   LOCAL cSql
   LOCAL cTable := "fakt_doks"
   LOCAL hIndexes, cKey, lWhere := .F.
   LOCAL nWa := F_FAKT_DOKS, cAlias := "FAKT_DOKS"

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable


   IF aWorkarea != NIL
      nWa := aWorkarea[ 1 ]
      cAlias := aWorkarea[ 2 ]
   ENDIF



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

   IF cIdFirma != NIL .AND. !Empty( cBrDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "brdok=" + sql_quote( cBrDok )
   ENDIF

   IF cIdPartner != NIL .AND. !Empty( cIdPartner )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idpartner=" + sql_quote( cIdPartner )
   ENDIF

   SELECT ( nWa )
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



FUNCTION h_fakt_doks_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "IdFirma+idtipdok+brdok"
   hIndexes[ "2" ] := "IdFirma+idtipdok+partner"
   hIndexes[ "3" ] := "partner"
   hIndexes[ "4" ] := "idtipdok"
   hIndexes[ "5" ] := "datdok"
   hIndexes[ "6" ] := "IdFirma+idpartner+idtipdok"

   RETURN hIndexes


FUNCTION seek_fakt_doks_idpartner( cIdPartner )

   RETURN seek_fakt_doks( NIL, NIL, NIL, cIdPartner, "3" )




FUNCTION seek_fakt( cIdFirma, cIdTipDok, cBrDok, cIdPartner, cIdRoba, dDatDokOd, cTag )

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


   IF cIdPartner != NIL .AND. !Empty( cIdPartner )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "idroba=" + sql_quote( cIdParter )
   ENDIF


   IF cIdRoba != NIL .AND. !Empty( cIdRoba )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF

      IF Right( cIdRoba, 1 ) == "%"
         cSql += "idroba like" + sql_quote(  cIdRoba )
      ELSE
         cSql += "idroba=" + sql_quote( cIdRoba )
      ENDIF
   ENDIF

   IF dDatDokOd != NIL .AND. !Empty( dDatDokOd )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "datdok>=" + sql_quote( dDatDokOd )
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



FUNCTION h_fakt_fakt_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "IdFirma+idtipdok+brdok+rbr+podbr"
   hIndexes[ "2" ] := "IdFirma+dtos(datDok)+idtipdok+brdok+rbr"
   hIndexes[ "3" ] := "idroba+dtos(datDok)"
   hIndexes[ "6" ] := "idfirma+idpartner+idroba+idtipdok+dtos(datdok)"
   hIndexes[ "7" ] := "idfirma+idpartner+idroba+dtos(datdok)"
   hIndexes[ "8" ] := "datdok"

   RETURN hIndexes


FUNCTION  seek_fakt_3( cIdFirma, cIdRoba )
   RETURN seek_fakt( cIdFirma, NIL, NIL, NIL, cIdRoba, NIL, "3" )


FUNCTION seek_fakt_3_sintetika( cIdFirma, cIdRoba )
   RETURN seek_fakt( cIdFirma, NIL, NIL, NIL, Trim( cIdRoba ) + "%", NIL, "3" )

/*
      seek_fakt_6( _idfirma, _idpartne, _idroba, "10",  dNajstariji )
*/
FUNCTION seek_fakt_6( cIdFirma, cIdPartner, cIdRoba, cIdTipDok, dDatDokOd )
   RETURN seek_fakt( cIdFirma, cIdTipDok, NIL, cIdPartner, cIdRoba, dDatDokOd, "6" )








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










// -------------- fakt uplate

FUNCTION SEEK_FAKT_UPL()
   RETURN .T.

FUNCTION SEEK_FAKT_UPLATE()
   RETURN seek_fakt_upl()


// ------------ fakt ugovori
FUNCTION SEEK_RUGOV()
   RETURN .T.

FUNCTION SEEK_UGOV()
   RETURN .T.


FUNCTION SEEK_GEN_UG_DAT_OB()
   RETURN .T.

FUNCTION SEEK_GEN_UG_DAT_OBR()
   RETURN .T.

FUNCTION SELECT_O_RUGOV()
   RETURN .T.

FUNCTION SELECT_O_RUGOV_IDROBA()
   RETURN .T.

FUNCTION SELECT_O_UGOV()

   RETURN .T.


// --------------------
