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

FIELD idfirma, idvn, brnal, datnal
/*

CREATE TABLE fmk.fin_nalog
(
  idfirma character(2) NOT NULL,
  idvn character(2) NOT NULL,
  brnal character(8) NOT NULL,
  datnal date,
  dugbhd numeric(17,2),
  potbhd numeric(17,2),
  dugdem numeric(15,2),
  potdem numeric(15,2),
  sifra character(6),
  CONSTRAINT fin_nalog_pkey PRIMARY KEY (idfirma, idvn, brnal)
)

*/
FUNCTION use_sql_fin_nalog( cIdVN, lMakeIndex )

   LOCAL cSql
   LOCAL cTable := "fin_nalog"
   LOCAL cAlias := "NALOG"

   IF lMakeIndex == NIL
      lMakeIndex := .T.
   ENDIF

   cSql := "SELECT "
   cSql += "  idfirma, idvn, brnal, sifra, "
   cSql += "  COALESCE(datnal,('1900-01-01'::date)) AS datnal, "
   cSql += "  COALESCE(dugbhd,0)::numeric(17,2) AS dugbhd, "
   cSql += "  COALESCE(potbhd,0)::numeric(17,2) AS potbhd, "
   cSql += "  COALESCE(dugdem,0)::numeric(15,2) AS dugdem, "
   cSql += "  COALESCE(potdem,0)::numeric(15,2) AS potdem "
   cSql += "FROM " + F18_PSQL_SCHEMA_DOT + cTable
   IF cIdVN != NIL .AND. !Empty( cIdVN )
      cSql += " WHERE IdVN=" + sql_quote( cIdVN )
   ENDIF
   cSQL += " ORDER BY idfirma, idvn, brnal"

   SELECT F_NALOG
   IF !use_sql( cTable, cSql, cAlias )
      RETURN .F.
   ENDIF

   IF lMakeIndex
      INDEX ON IdFirma + IdVn + BrNal TAG 1 TO ( cAlias )
      INDEX ON IdFirma + Str( Val( BrNal ), 8 ) + idvn TAG 2 TO ( cAlias )
      INDEX ON DToS( datnal ) + IdFirma + idvn + brnal TAG 3 TO ( cAlias )
      INDEX ON datnal TAG 4 TO ( cAlias )
      SET ORDER TO TAG 1
      GO TOP
   ENDIF

   RETURN .T.
