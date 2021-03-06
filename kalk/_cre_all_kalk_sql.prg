/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

/*
FUNCTION create_table_kalk_kalk()

   LOCAL cSql, oRet, cTableName := "kalk_kalk"

   cSql :=  "DROP TABLE IF EXISTS fmk." + cTableName
   oRet := run_sql_query( cSql, 1 )

   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := "CREATE TABLE fmk." + cTableName + " ("
   cSql += "idfirma character(2) NOT NULL,"
   cSql += "idroba character(10),"
   cSql += "idkonto character(7),"
   cSql += "idkonto2 character(7),"
   cSql += "idzaduz character(6),"
   cSql += "idzaduz2 character(6),"
   cSql += "idvd character(2) NOT NULL,"
   cSql += "brdok character(8) NOT NULL,"
   cSql += "datdok date,"
   cSql += "brfaktp character(10),"
   cSql += "datfaktp date,"
   cSql += "idpartner character(6),"
   cSql += "datkurs date,"
   cSql += "rbr character(3) NOT NULL,"
   cSql += "kolicina numeric(12,3),"
   cSql += "gkolicina numeric(12,3),"
   cSql += "gkolicin2 numeric(12,3),"
   cSql += "fcj numeric(18,8),"
   cSql += "fcj2 numeric(18,8),"
   cSql += "fcj3 numeric(18,8),"
   cSql += "trabat character(1),"
   cSql += "rabat numeric(18,8),"
   cSql += "tprevoz character(1),"
   cSql += "prevoz numeric(18,8),"
   cSql += "tprevoz2 character(1),"
   cSql += "prevoz2 numeric(18,8),"
   cSql += "tbanktr character(1),"
   cSql += "banktr numeric(18,8),"
   cSql += "tspedtr character(1),"
   cSql += "spedtr numeric(18,8),"
   cSql += "tcardaz character(1),"
   cSql += "cardaz numeric(18,8),"
   cSql += "tzavtr character(1),"
   cSql += "zavtr numeric(18,8),"
   cSql += "nc numeric(18,8),"
   cSql += "tmarza character(1),"
   cSql += "marza numeric(18,8),"
   cSql += "vpc numeric(18,8),"
   cSql += "rabatv numeric(18,8),"
   cSql += "vpcsap numeric(18,8),"
   cSql += "tmarza2 character(1),"
   cSql += "marza2 numeric(18,8),"
   cSql += "mpc numeric(18,8),"
   cSql += "idtarifa character(6),"
   cSql += "mpcsapp numeric(18,8),"
   cSql += "mkonto character(7),"
   cSql += "pkonto character(7),"
   cSql += "roktr date,"
   cSql += "mu_i character(1),"
   cSql += "pu_i character(1),"
   cSql += "error character(1),"
   cSql += "podbr character(2)"
   cSql += ")"

   oRet := run_sql_query( cSql )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql :=  "ALTER TABLE fmk." + cTableName + " OWNER TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO xtrole;"

   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := 'CREATE INDEX kalk_kalk_id ON fmk.kalk_kalk USING btree (idfirma COLLATE pg_catalog."default", idvd COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default", rbr COLLATE pg_catalog."default", mkonto COLLATE pg_catalog."default", pkonto COLLATE pg_catalog."default");'
   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   RETURN oRet



FUNCTION create_table_kalk_doks()

   LOCAL cSql, oRet, cTableName := "kalk_doks"

   cSql :=  "DROP TABLE IF EXISTS fmk." + cTableName
   oRet := run_sql_query( cSql, 1 )

   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := "CREATE TABLE fmk." + cTableName + " ("
   cSql += "idfirma character(2) NOT NULL,"
   cSql += "idvd character(2) NOT NULL,"
   cSql += "brdok character(8) NOT NULL,"
   cSql += "datdok date,"
   cSql += "brfaktp character(10),"
   cSql += "idpartner character(6),"
   cSql += "idzaduz character(6),"
   cSql += "idzaduz2 character(6),"
   cSql += "pkonto character(7),"
   cSql += "mkonto character(7),"
   cSql += "nv numeric(12,2),"
   cSql += "vpv numeric(12,2),"
   cSql += "rabat numeric(12,2),"
   cSql += "mpv numeric(12,2),"
   cSql += "podbr character(2),"
   cSql += "sifra character(6),"
   cSql += "CONSTRAINT kalk_doks_pkey PRIMARY KEY (idfirma, idvd, brdok)"
   cSql += ")"

   oRet := run_sql_query( cSql )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql :=  "ALTER TABLE fmk." + cTableName + " OWNER TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO xtrole;"

   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := 'CREATE INDEX kalk_doks_datdok ON fmk.kalk_doks USING btree (datdok)'
   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := 'CREATE INDEX kalk_doks_id1 ON fmk.kalk_doks USING btree (idfirma COLLATE pg_catalog."default", idvd COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default", mkonto COLLATE pg_catalog."default", pkonto COLLATE pg_catalog."default");'
   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   RETURN oRet



FUNCTION create_table_kalk_doks2()

   LOCAL cSql, oRet, cTableName := "kalk_doks2"

   cSql :=  "DROP TABLE IF EXISTS fmk." + cTableName
   oRet := run_sql_query( cSql, 1 )

   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := "CREATE TABLE fmk." + cTableName + " ("
   cSql += "idfirma character(2),"
   cSql += "idvd character(2),"
   cSql += "brdok character(8),"
   cSql += "datval date,"
   cSql += "opis character varying(20),"
   cSql += "k1 character(1),"
   cSql += "k2 character(2),"
   cSql += "k3 character(3)"
   cSql += ")"

   oRet := run_sql_query( cSql )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql :=  "ALTER TABLE fmk." + cTableName + " OWNER TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO xtrole;"

   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := 'CREATE INDEX kalk_doks2_id1 ON fmk.kalk_doks2 USING btree (idfirma COLLATE pg_catalog."default", idvd COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default");'
   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   RETURN oRet



FUNCTION create_table_kalk_kalk_atributi()

   LOCAL cSql, oRet, cTableName := "kalk_kalk_atributi"

   cSql :=  "DROP TABLE IF EXISTS fmk." + cTableName
   oRet := run_sql_query( cSql, 1 )

   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := "CREATE TABLE fmk." + cTableName + " ("
   cSql += "idfirma character(2) NOT NULL,"
   cSql += "idtipdok character(2)NOT NULL,"
   cSql += "brdok character(8) NOT NULL,"
   cSql += "rbr character(3) NOT NULL,"
   cSql += "atribut character(50) NOT NULL,"
   cSql += "value character varying,"
   cSql += "CONSTRAINT kalk_kalk_atributi_pkey PRIMARY KEY (idfirma, idtipdok, brdok, rbr, atribut)"
   cSql += ")"

   oRet := run_sql_query( cSql )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql :=  "ALTER TABLE fmk." + cTableName + " OWNER TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO admin;"
   cSql +=  "GRANT ALL ON TABLE fmk." + cTableName + " TO xtrole;"

   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   cSql := 'CREATE INDEX kalk_kalk_atributi_id1 ON fmk.kalk_kalk_atributi USING btree (idfirma COLLATE pg_catalog."default", idtipdok COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default", rbr COLLATE pg_catalog."default", atribut COLLATE pg_catalog."default");'
   oRet := run_sql_query( cSql, 1 )
   IF sql_error_alert( oRet )
      RETURN .F.
   ENDIF

   RETURN oRet
*/
