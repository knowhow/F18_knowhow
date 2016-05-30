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



FUNCTION find_kalk_doks_za_tip( cIdFirma, cIdvd )

   RETURN find_kalk_doks_by_broj_dokumenta( cIdFirma, cIdvd, NIL )


FUNCTION find_kalk_doks_by_broj_dokumenta( cIdFirma, cIdvd, cBrDok )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVd <> NIL
      hParams[ "idvd" ] := cIdVd
   ENDIF

   IF cBrDok <> NIL
      hParams[ "brdok" ] := cBrDok
   ENDIF

   hParams[ "indeks" ] := .T.

   use_sql_kalk_doks( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_kalk_doks2_by_broj_dokumenta( cIdFirma, cIdvd, cBrDok )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVd <> NIL
      hParams[ "idvd" ] := cIdVd
   ENDIF

   IF cBrDok <> NIL
      hParams[ "brdok" ] := cBrDok
   ENDIF

   hParams[ "indeks" ] := .T.

   use_sql_kalk_doks2( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_kalk_doks_by_broj_fakture( cBrojFakture )

   LOCAL hParams := hb_Hash()

   hParams[ "broj_fakture" ] := cBrojFakture
   hParams[ "indeks" ] := .T.

   use_sql_kalk_doks( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_kalk_by_mkonto_idroba( cIdFirma, cIdKonto, cIdRoba )

   LOCAL hParams := hb_Hash()

   hParams[ "idfirma" ] := cIdFirma
   hParams[ "mkonto" ] := cIdKonto
   hParams[ "idroba" ] := cIdRoba
   hParams[ "order_by" ] := "idfirma, mkonto, idroba, datdok, podbr, mu_i, idvd"

   use_sql_kalk( hParams )
   GO TOP

   RETURN !Eof()


FUNCTION find_kalk_by_pkonto_idroba( cIdFirma, cIdKonto, cIdRoba )

   LOCAL hParams := hb_Hash()

   hParams[ "idfirma" ] := cIdFirma
   hParams[ "pkonto" ] := cIdKonto
   hParams[ "idroba" ] := cIdRoba
   hParams[ "order_by" ] := "idfirma, pkonto, idroba, datdok, podbr, mu_i, idvd"

   use_sql_kalk( hParams )
   GO TOP

   RETURN !Eof()

FUNCTION find_kalk_kalk_by_broj_dokumenta( cIdFirma, cIdvd, cBrDok )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVd <> NIL
      hParams[ "idvd" ] := cIdVd
   ENDIF

   IF cBrDok <> NIL
      hParams[ "brdok" ] := cBrDok
   ENDIF

   hParams[ "indeks" ] := .T.

   use_sql_kalk_kalk( hParams )
   GO TOP

   RETURN ! Eof()



FUNCTION use_kalk( hParams )
   RETURN use_sql_kalk( hParams )

FUNCTION use_kalk_doks( hParams )
   RETURN use_sql_kalk_doks( hParams )

FUNCTION use_kalk_doks2( hParams )
   RETURN use_sql_kalk_doks2( hParams )


FUNCTION use_kalk_kalk( hParams )
   RETURN use_sql_kalk_kalk( hParams )

FUNCTION use_kalk_kalk_atributi( hParams )
   RETURN use_sql_kalk_kalk_atributi( hParams )


FUNCTION kalk_otvori_kumulativ_kao_pripremu( cIdFirma, cIdVd, cBrDok )

   LOCAL hParams

   hParams := hb_Hash()
   hParams[ "alias" ] := "kalk_pripr"
   hParams[ "indeks" ] := .T.

   IF cIdFirma != NIL .AND. cIdVd != NIL .AND. cBrDok != NIL
      hParams[ "idfirma" ] := cIdFirma
      hParams[ "idvd" ] := cIdVd
      hParams[ "brdok" ] := cBrDok
   ENDIF

   RETURN use_sql_kalk( hParams )



FUNCTION use_sql_kalk( hParams )

   LOCAL cTable := "KALK"
   LOCAL cWhere, cOrder
   LOCAL cSql
   LOCAL lReportMagacin := .F.
   LOCAL lReportProdavnica := .F.

   default_if_nil( @hParams, hb_Hash() )

   IF hb_HHasKey( hParams, "polja" ) .AND. hParams[ "polja" ] == "rpt_magacin"
      lReportMagacin := .T.
   ENDIF

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idroba", 10 )
   cSql += coalesce_char_zarez( "idvd", 2 )
   cSql += coalesce_char_zarez( "brdok", 8 )
   cSql += coalesce_char_zarez( "rbr", 3 )
   cSql += "datdok, datfaktp, "
   cSql += coalesce_char_zarez( "brfaktp", 10 )
   cSql += coalesce_char_zarez( "idpartner", 6 )
   cSql += coalesce_char_zarez( "idtarifa", 6 )
   cSql += coalesce_char_zarez( "mkonto", 7 )
   cSql += coalesce_char_zarez( "pkonto", 7 )
   cSql += coalesce_char_zarez( "idkonto", 7 )
   cSql += coalesce_char_zarez( "idkonto2", 7 )

   IF !( lReportMagacin  .OR. lReportProdavnica )
      cSql += coalesce_char_zarez( "idzaduz", 6 )
      cSql += coalesce_char_zarez( "idzaduz2", 6 )
      cSql += coalesce_char_zarez( "trabat", 1 )
      cSql += coalesce_char_zarez( "tprevoz", 1 )
      cSql += coalesce_char_zarez( "tprevoz2", 1 )
      cSql += coalesce_char_zarez( "tbanktr", 1 )
      cSql += coalesce_char_zarez( "tspedtr", 1 )
      cSql += coalesce_char_zarez( "tcardaz", 1 )
      cSql += coalesce_char_zarez( "tzavtr", 1 )
      cSql += coalesce_char_zarez( "tmarza", 1 )
      cSql += coalesce_char_zarez( "tmarza2", 1 )
      cSql += coalesce_num_num_zarez( "rabat", 18, 8 )
      cSql += coalesce_num_num_zarez( "marza2", 18, 8 )
      cSql += coalesce_num_num_zarez( "fcj2", 18, 8 )
      cSql += coalesce_num_num_zarez( "fcj3", 18, 8 )
      cSql += coalesce_num_num_zarez( "prevoz", 18, 8 )
      cSql += coalesce_num_num_zarez( "banktr", 18, 8 )
      cSql += coalesce_num_num_zarez( "cardaz", 18, 8 )
      cSql += coalesce_num_num_zarez( "spedtr", 18, 8 )
      cSql += coalesce_num_num_zarez( "zavtr", 18, 8 )
   ENDIF

   cSql += coalesce_num_num_zarez( "kolicina", 12, 3 )
   cSql += coalesce_num_num_zarez( "gkolicina", 12, 3  )
   cSql += coalesce_num_num_zarez( "gkolicin2", 12, 3  )

   cSql += coalesce_num_num_zarez( "fcj", 18, 8 )
   cSql += coalesce_num_num_zarez( "nc", 18, 8 )
   cSql += coalesce_num_num_zarez( "marza", 18, 8 )
   cSql += coalesce_num_num_zarez( "vpc", 18, 8 )

   IF !lReportProdavnica
      cSql += coalesce_num_num_zarez( "rabatv", 18, 8 )
      cSql += coalesce_num_num_zarez( "vpcsap", 18, 8 )
   ENDIF

   IF !lReportMagacin
      cSql += coalesce_num_num_zarez( "mpc", 18, 8 )
      cSql += coalesce_num_num_zarez( "mpcsapp", 18, 8 )
   ENDIF

   cSql += coalesce_char_zarez( "mu_i", 1 )
   cSql += coalesce_char_zarez( "pu_i", 1 )
   cSql += coalesce_char_zarez( "error", 1 )
   cSql += coalesce_char( "podbr", 2 )

   cSql += " FROM fmk.kalk_kalk"

   cWhere := use_sql_kalk_where( hParams )
   cOrder := use_sql_kalk_order( hParams )

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1000"
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_KALK )

   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON ( field->idfirma + field->idvd + field->brdok ) TAG "1" TO cTable
      INDEX ON ( field->idfirma + field->mkonto + field->idzaduz2 + field->idvd + field->brdok ) TAG "2" TO cTable
      INDEX ON ( field->idfirma + DToS( field->datdok ) + field->podbr + field->idvd + field->brdok ) TAG "3" TO cTable
      INDEX ON ( field->datdok ) TAG "DAT" TO cTable
      INDEX ON ( field->brfaktp + field->idvd ) TAG "V_BRF" TO cTable

      INDEX ON idFirma+IdVD+BrDok+RBr  TAG "1" TO cTable
      INDEX ON idFirma+idvd+brdok+IDTarifa TAG "2" TO cTable
      INDEX ON idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD TAG "3" TO cTable
      INDEX ON idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD TAG "4" TO cTable
      INDEX ON idFirma+dtos(datdok)+podbr+idvd+brdok TAG "5" TO cTable
      INDEX ON idFirma+IdTarifa+idroba TAG "6" TO cTable
      INDEX ON idroba+idvd TAG "7" TO cTable
      INDEX ON mkonto TAG "8" TO cTable
      INDEX ON pkonto TAG "9" TO cTable
      INDEX ON datdok TAG "DAT" TO cTable
      INDEX ON mu_i+mkonto+idfirma+idvd+brdok  TAG "MU_I" TO cTable
      INDEX ON mu_i+idfirma+idvd+brdok  TAG "MU_I2" TO cTable
      INDEX ON pu_i+pkonto+idfirma+idvd+brdok   TAG "PU_I" TO cTable
      INDEX ON pu_i+idfirma+idvd+brdok   TAG "PU_I2" TO cTable
      INDEX ON idfirma+mkonto+idpartner+idvd+dtos(datdok)   TAG "PMAG" TO cTable

      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.



STATIC FUNCTION use_sql_kalk_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + order_by( hParams[ "order_by" ] )
   ELSE
      cOrder += " ORDER BY " + order_by( "brdok" )
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_kalk_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere += parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvd" )
      cWhere += " AND " + parsiraj_sql( "idvd", hParams[ "idvd" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      cWhere += " AND " + parsiraj_sql( "brdok", hParams[ "brdok" ] )
   ENDIF

   IF hb_HHasKey( hParams, "mkonto" )
      cWhere += " AND " + parsiraj_sql( "mkonto", hParams[ "mkonto" ] )
   ENDIF

   IF hb_HHasKey( hParams, "pkonto" )
      cWhere += " AND " + parsiraj_sql( "pkonto", hParams[ "pkonto" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idroba" )
      cWhere += "AND " + parsiraj_sql( "idroba", hParams[ "idroba" ] )
   ENDIF

   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += " AND " + parsiraj_sql_date_interval( "datdok", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   RETURN cWhere


STATIC FUNCTION order_by(  cSort )

   LOCAL cRet := "idfirma"

   SWITCH cSort
   CASE "brdok"
      cRet += ",idvd, brdok"
      EXIT
   CASE "pkonto"
      cRet += ",pkonto, idroba"
      EXIT
   CASE "mkonto"
      cRet += ",mkonto, idroba"
      EXIT
   CASE "tarifa"
      cRet += ",idtarifa, idroba"
      EXIT
   ENDSWITCH

   cRet += ",datdok"

   RETURN cRet



FUNCTION kalk_mkonto( cIdFirma, cIdKonto, cIdRoba, cX )
   RETURN kalk_mkonto_pkonto( "M", cIdFirma, cIdKonto, cIdRoba, cX )


FUNCTION kalk_pkonto( cIdFirma, cIdKonto, cIdRoba, cX )
   RETURN kalk_mkonto_pkonto( "P", cIdFirma, cIdKonto, cIdRoba, cX )

FUNCTION kalk_mkonto_pkonto( cTip, cIdFirma, cIdKonto, cIdRoba, cX )

   LOCAL lKraj
   LOCAL hParams := hb_Hash()

   IF cX == NIL
      lKraj := .F.
      cX := ""
   ELSE
      // cX := "X"
      lKraj := .T.
   ENDIF

   hParams[ 'idfirma' ]  := cIdFirma + ";"
   hParams[ iif( cTip == "M", 'mkonto', 'pkonto' ) ]  := cIdKonto + ";"
   IF cIdRoba != NIL
      hParams[ 'idroba'  ]  := cIdRoba  + ";"
   ENDIF
   hParams[ 'order_by' ] := iif( cTip == "M", "mkonto", "pkonto" )

   use_sql_kalk( hParams )

   IF lKraj
      GO BOTTOM
   ENDIF

   RETURN Eof()


FUNCTION use_sql_kalk_doks( hParams )

   LOCAL cSql, cWhere, cOrder
   LOCAL cTable := "KALK_DOKS"

   default_if_nil( @hParams, hb_Hash() )

   cWhere := sql_kalk_doks_where( hParams )
   cOrder := sql_kalk_doks_order( hParams )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvd", 2 )
   cSql += coalesce_char_zarez( "brdok", 8 )
   cSql += " datdok, "
   cSql += coalesce_char_zarez( "brfaktp", 10 )
   cSql += coalesce_char_zarez( "idpartner", 6 )
   cSql += coalesce_char_zarez( "idzaduz", 6 )
   cSql += coalesce_char_zarez( "idzaduz2", 6 )
   cSql += coalesce_char_zarez( "pkonto", 7 )
   cSql += coalesce_char_zarez( "mkonto", 7 )
   cSql += coalesce_num_num_zarez( "nv", 12, 2 )
   cSql += coalesce_num_num_zarez( "vpv", 12, 2 )
   cSql += coalesce_num_num_zarez( "rabat", 12, 2 )
   cSql += coalesce_num_num_zarez( "mpv", 12, 2 )
   cSql += coalesce_char_zarez( "podbr", 2 )
   cSql += coalesce_char( "sifra", 6 )
   cSql += " FROM fmk.kalk_doks "

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1 "
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_KALK_DOKS )
   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON ( field->idfirma + field->idvd + field->brdok ) TAG "1" TO cTable
      INDEX ON ( field->idfirma + field->mkonto + field->idzaduz2 + field->idvd + field->brdok ) TAG "2" TO cTable
      INDEX ON ( field->idfirma + DToS( field->datdok ) + field->podbr + field->idvd + field->brdok ) TAG "3" TO cTable
      INDEX ON ( field->datdok ) TAG "DAT" TO cTable
      INDEX ON ( field->brfaktp + field->idvd ) TAG "V_BRF" TO cTable
      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.



STATIC FUNCTION sql_kalk_doks_where( hParams )

   LOCAL cWhere := ""

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere += "idfirma = " + sql_quote( hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvd" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "idvd = " + sql_quote( hParams[ "idvd" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "brdok = " + sql_quote( hParams[ "brdok" ] )
   ENDIF

   IF hb_HHasKey( hParams, "broj_fakture" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "brfaktp = " + sql_quote( hParams[ "broj_fakture" ] )
   ENDIF

   RETURN cWhere



STATIC FUNCTION sql_kalk_doks_order( hParams )

   LOCAL cOrder

   IF hb_HHasKey( hParams, "order_by" )
      cOrder := " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder := " ORDER BY idfirma, idvd, brdok "
   ENDIF

   RETURN cOrder




FUNCTION use_sql_kalk_doks2( hParams )

   LOCAL cSql, cWhere, cOrder
   LOCAL cTable := "KALK_DOKS2"

   default_if_nil( @hParams, hb_Hash() )

   cWhere := sql_kalk_doks2_where( hParams )
   cOrder := sql_kalk_doks2_order( hParams )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvd", 2 )
   cSql += coalesce_char_zarez( "brdok", 8 )
   cSql += "datval, "
   cSql += coalesce_char_zarez( "opis", 20 )
   cSql += coalesce_char_zarez( "k1", 1 )
   cSql += coalesce_char_zarez( "k2", 2 )
   cSql += coalesce_char( "k3", 3 )
   cSql += " FROM fmk.kalk_doks2 "

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1 "
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_KALK_DOKS2 )
   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON ( field->idfirma + field->idvd + field->brdok ) TAG "1" TO cTable
      INDEX ON ( field->idfirma + DToS( field->datval ) + field->idvd + field->brdok ) TAG "2" TO cTable
      INDEX ON ( field->datval ) TAG "DAT" TO cTable
      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.



STATIC FUNCTION sql_kalk_doks2_where( hParams )

   LOCAL cWhere := ""

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere += "idfirma = " + sql_quote( hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvd" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "idvd = " + sql_quote( hParams[ "idvd" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "brdok = " + sql_quote( hParams[ "brdok" ] )
   ENDIF

   RETURN cWhere



STATIC FUNCTION sql_kalk_doks2_order( hParams )

   LOCAL cOrder

   IF hb_HHasKey( hParams, "order_by" )
      cOrder := " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder := " ORDER BY idfirma, idvd, brdok "
   ENDIF

   RETURN cOrder




FUNCTION use_sql_kalk_kalk( hParams )

   LOCAL cSql, cWhere, cOrder
   LOCAL cTable := "KALK_KALK"

   default_if_nil( @hParams, hb_Hash() )

   cWhere := sql_kalk_kalk_where( hParams )
   cOrder := sql_kalk_kalk_order( hParams )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idroba", 10 )
   cSql += coalesce_char_zarez( "idkonto", 7 )
   cSql += coalesce_char_zarez( "idkonto2", 7 )
   cSql += coalesce_char_zarez( "idzaduz", 6 )
   cSql += coalesce_char_zarez( "idzaduz2", 7 )
   cSql += coalesce_char_zarez( "idvd", 2 )
   cSql += coalesce_char_zarez( "brdok", 8 )
   cSql += " datdok, "
   cSql += " datfaktp, "
   cSql += " datkurs, "
   cSql += coalesce_char_zarez( "brfaktp", 10 )
   cSql += coalesce_char_zarez( "idpartner", 6 )
   cSql += coalesce_char_zarez( "rbr", 3 )
   cSql += coalesce_num_num_zarez( "kolicina", 12, 3 )
   cSql += coalesce_num_num_zarez( "gkolicina", 12, 3 )
   cSql += coalesce_num_num_zarez( "gkolicin2", 12, 3 )
   cSql += coalesce_num_num_zarez( "fcj", 18, 8 )
   cSql += coalesce_num_num_zarez( "fcj2", 18, 8 )
   cSql += coalesce_num_num_zarez( "fcj3", 18, 8 )
   cSql += coalesce_char_zarez( "trabat", 1 )
   cSql += coalesce_num_num_zarez( "rabat", 18, 8 )
   cSql += coalesce_char_zarez( "tprevoz", 1 )
   cSql += coalesce_num_num_zarez( "prevoz", 18, 8 )
   cSql += coalesce_char_zarez( "tprevoz2", 1 )
   cSql += coalesce_num_num_zarez( "prevoz2", 18, 8 )
   cSql += coalesce_char_zarez( "tbanktr", 1 )
   cSql += coalesce_num_num_zarez( "bnktr", 18, 8 )
   cSql += coalesce_char_zarez( "tspedtr", 1 )
   cSql += coalesce_num_num_zarez( "spedtr", 18, 8 )
   cSql += coalesce_char_zarez( "tcardaz", 1 )
   cSql += coalesce_num_num_zarez( "cardaz", 18, 8 )
   cSql += coalesce_char_zarez( "tzavtr", 1 )
   cSql += coalesce_num_num_zarez( "zavtr", 18, 8 )
   cSql += coalesce_num_num_zarez( "nc", 18, 8 )
   cSql += coalesce_char_zarez( "tmarza", 1 )
   cSql += coalesce_num_num_zarez( "mrza", 18, 8 )
   cSql += coalesce_char_zarez( "tmarza2", 1 )
   cSql += coalesce_num_num_zarez( "mrza2", 18, 8 )
   cSql += coalesce_num_num_zarez( "vpc", 18, 8 )
   cSql += coalesce_num_num_zarez( "rabatv", 18, 8 )
   cSql += coalesce_num_num_zarez( "vpcsap", 18, 8 )
   cSql += coalesce_num_num_zarez( "mpc", 18, 8 )
   cSql += coalesce_char_zarez( "idtarifa", 6 )
   cSql += coalesce_num_num_zarez( "mpcsapp", 18, 8 )
   cSql += coalesce_char_zarez( "mkonto", 7 )
   cSql += coalesce_char_zarez( "pkonto", 7 )
   cSql += " roktr, "
   cSql += coalesce_char_zarez( "m_ui", 1 )
   cSql += coalesce_char_zarez( "p_ui", 1 )
   cSql += coalesce_char_zarez( "error", 1 )
   cSql += coalesce_char( "podbr", 2 )
   cSql += " FROM fmk.kalk_kalk "

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1 "
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_KALK_KALK )
   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON ( field->idfirma + field->idvd + field->brdok + field->rbr  ) TAG "1" TO cTable
      INDEX ON ( field->idfirma + field->mkonto + field->idzaduz2 + field->idvd + field->brdok ) TAG "2" TO cTable
      INDEX ON ( field->idfirma + DToS( field->datdok ) + field->idvd + field->brdok ) TAG "3" TO cTable
      INDEX ON ( field->datdok ) TAG "DAT" TO cTable
      INDEX ON ( field->brfaktp + field->idvd ) TAG "V_BRF" TO cTable
      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.



STATIC FUNCTION sql_kalk_kalk_where( hParams )

   LOCAL cWhere := ""

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere += "idfirma = " + sql_quote( hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvd" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "idvd = " + sql_quote( hParams[ "idvd" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "brdok = " + sql_quote( hParams[ "brdok" ] )
   ENDIF

   IF hb_HHasKey( hParams, "broj_fakture" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "brfaktp = " + sql_quote( hParams[ "broj_fakture" ] )
   ENDIF

   RETURN cWhere



STATIC FUNCTION sql_kalk_kalk_order( hParams )

   LOCAL cOrder

   IF hb_HHasKey( hParams, "order_by" )
      cOrder := " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder := " ORDER BY idfirma, idvd, brdok "
   ENDIF

   RETURN cOrder



FUNCTION use_sql_kalk_kalk_atributi( hParams )

   LOCAL cSql, cWhere, cOrder
   LOCAL cTable := "KALK_KALK_ATRIBUTI"

   default_if_nil( @hParams, hb_Hash() )

   cWhere := sql_kalk_kalk_atributi_where( hParams )
   cOrder := sql_kalk_kalk_atributi_order( hParams )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idtipdok", 2 )
   cSql += coalesce_char_zarez( "brdok", 8 )
   cSql += coalesce_char_zarez( "rbr", 3 )
   cSql += coalesce_char( "atribut", 50 )
   cSql += " FROM fmk.kalk_kalk_atributi "

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1 "
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_KALK_ATRIBUTI )
   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON ( field->idfirma + field->idtipdok + field->brdok ) TAG "1" TO cTable
      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.


STATIC FUNCTION sql_kalk_kalk_atributi_where( hParams )

   LOCAL cWhere := ""

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere += "idfirma = " + sql_quote( hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idtipdok" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "idtipdok = " + sql_quote( hParams[ "idtipdok" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      IF !Empty( cWhere )
         cWhere += " AND "
      ENDIF
      cWhere += "brdok = " + sql_quote( hParams[ "brdok" ] )
   ENDIF

   RETURN cWhere



STATIC FUNCTION sql_kalk_kalk_atributi_order( hParams )

   LOCAL cOrder

   IF hb_HHasKey( hParams, "order_by" )
      cOrder := " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder := " ORDER BY idfirma, idtipdok, brdok "
   ENDIF

   RETURN cOrder
