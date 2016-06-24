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


FUNCTION o_sql_suban_kto_partner( cIdFirma )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   hParams[ "order_by" ] := "IdFirma,IdKonto,IdPartner,DatDok,BrNal,RBr"
   hParams[ "indeks" ] := .F. // ne trositi vrijeme na kreiranje indeksa

   use_sql_suban( hParams )
   GO TOP

   RETURN ! Eof()

FUNCTION find_suban_za_period( cIdFirma, dDatOd, dDatDo, cOrderBy )

   LOCAL hParams := hb_Hash()

   hb_default( @cOrderBy, "idFirma,IdVN,BrNal,Rbr" )

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF dDatOd != NIL
      hParams[ "dat_od" ] := dDatOd
   ENDIF

   IF dDatDo != NIL
      hParams[ "dat_do" ] := dDatDo
   ENDIF

   hParams[ "order_by" ] := cOrderBy

   hParams[ "indeks" ] := .F.
   use_sql_suban( hParams )
   GO TOP

   RETURN ! Eof()



FUNCTION find_sint_by_konto( cIdFirma, cIdKonto )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdKonto <> NIL
      hParams[ "idkonto" ] := cIdKonto
   ENDIF

   hParams[ "order_by" ] := "datnal" // ako ima vise brojeva dokumenata sortiraj po njima

   hParams[ "indeks" ] := .T. // ne trositi vrijeme na kreiranje indeksa

   use_sql_sint( hParams )
   GO TOP

   RETURN ! Eof()



FUNCTION find_anal_by_konto( cIdFirma, cIdKonto )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdKonto <> NIL
      hParams[ "idkonto" ] := cIdKonto
   ENDIF

   hParams[ "order_by" ] := "datnal" // ako ima vise brojeva dokumenata sortiraj po njima

   hParams[ "indeks" ] := .T. // ne trositi vrijeme na kreiranje indeksa

   use_sql_anal( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_suban_by_konto_partner( cIdFirma, cIdKonto, cIdPartner )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdKonto <> NIL
      hParams[ "idkonto" ] := cIdKonto
   ENDIF

   IF cIdPartner <> NIL
      hParams[ "idpartner" ] := cIdPartner
   ELSE
      hParams[ "order_by" ] := "datdok" // ako ima vise brojeva dokumenata sortiraj po njima
   ENDIF

   hParams[ "indeks" ] := .T. // ne trositi vrijeme na kreiranje indeksa

   use_sql_suban( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_nalog_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal, cOrderBy )

   LOCAL hParams := hb_Hash()

   hb_default( @cOrderBy, "idfirma,idvn,brnal" )

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVN <> NIL
      hParams[ "idvn" ] := cIdvn
   ENDIF

   IF cBrNal <> NIL
      hParams[ "brnal" ] := cBrNal
   ENDIF

   hParams[ "order_by" ] :=  cOrderBy // ako ima vise brojeva dokumenata sortiraj po njima

   hParams[ "indeks" ] := .F. // ne trositi vrijeme na kreiranje indeksa

   use_sql_nalog( hParams )
   GO TOP

   RETURN ! Eof()

FUNCTION find_sint_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVN <> NIL
      hParams[ "idvn" ] := cIdvn
   ENDIF

   IF cBrNal <> NIL
      hParams[ "brnal" ] := cBrNal
   ENDIF

   hParams[ "order_by" ] := "idfirma,idvn,brnal,rbr" // ako ima vise brojeva dokumenata sortiraj po njima

   hParams[ "indeks" ] := .F. // ne trositi vrijeme na kreiranje indeksa

   use_sql_sint( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_anal_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVN <> NIL
      hParams[ "idvn" ] := cIdvn
   ENDIF

   IF cBrNal <> NIL
      hParams[ "brnal" ] := cBrNal
   ENDIF

   hParams[ "order_by" ] := "idfirma,idvn,brnal,rbr" // ako ima vise brojeva dokumenata sortiraj po njima

   hParams[ "indeks" ] := .F. // ne trositi vrijeme na kreiranje indeksa

   use_sql_anal( hParams )
   GO TOP

   RETURN ! Eof()


FUNCTION find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal, lIndex )

   LOCAL hParams := hb_Hash()

   hb_default( @lIndex, .F. )

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVN <> NIL
      hParams[ "idvn" ] := cIdvn
   ENDIF

   IF cBrNal <> NIL
      hParams[ "brnal" ] := cBrNal
   ENDIF

   hParams[ "order_by" ] := "idfirma,idvn,brnal,rbr" // ako ima vise brojeva dokumenata sortiraj po njima

   hParams[ "indeks" ] := lIndex  // ne trositi vrijeme na kreiranje indeksa, osim ako se ne naglasi

   use_sql_suban( hParams )
   GO TOP

   RETURN ! Eof()



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


/* --- nalog -- */


FUNCTION use_sql_nalog( hParams )

   LOCAL cTable := "NALOG"
   LOCAL cWhere, cOrder
   LOCAL cSql


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
  sifra character(6)
)
*/


   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvn", 2 )
   cSql += coalesce_char_zarez( "brnal", 8 )
   cSql += coalesce_char_zarez( "sifra", 8 )
   cSql += "datnal, "
   cSql += coalesce_num_num_zarez( "dugbhd", 17, 2 )
   cSql += coalesce_num_num_zarez( "potbhd", 17, 2 )
   cSql += coalesce_num_num_zarez( "dugdem", 15, 2  )
   cSql += coalesce_num_num( "potdem", 15, 2  )

   cSql += " FROM fmk.fin_nalog"


   cWhere := use_sql_nalog_where( hParams )
   cOrder := use_sql_nalog_order( hParams )

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1"
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_NALOG )

   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )

      INDEX ON idFirma + IdVN + BrNal  TAG "1" TO cTable
      INDEX ON IdFirma + Str( Val( BrNal ), 8 ) + idvn  TAG "2" TO cTable
      INDEX ON DToS( datnal ) + IdFirma + idvn + brnal  TAG "3" TO cTable
      INDEX ON datnal  TAG "4" TO cTable

      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.


STATIC FUNCTION use_sql_nalog_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY idfirma,idvn,brnal"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_nalog_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere := parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvn" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idvn", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brnal" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "brnal", hParams[ "brnal" ] )
   ENDIF


   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql_date_interval( "datnal", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   RETURN cWhere


/* --- sint -- */

FUNCTION use_sql_sint( hParams )

   LOCAL cTable := "SINT"
   LOCAL cWhere, cOrder
   LOCAL cSql


/*
CREATE TABLE fmk.fin_sint
(
  idfirma character(2) NOT NULL,
  idkonto character(3),
  idvn character(2) NOT NULL,
  brnal character(8) NOT NULL,
  rbr character varying(4) NOT NULL,
  datnal date,
  dugbhd numeric(17,2),
  potbhd numeric(17,2),
  dugdem numeric(15,2),
  potdem numeric(15,2)
)

*/

   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvn", 2 )
   cSql += coalesce_char_zarez( "brnal", 8 )
   cSql += coalesce_char_zarez( "idkonto", 3 )
   cSql += coalesce_char_zarez( "rbr", 4 )
   cSql += "datnal, "
   cSql += coalesce_num_num_zarez( "dugbhd", 17, 2 )
   cSql += coalesce_num_num_zarez( "potbhd", 17, 2 )
   cSql += coalesce_num_num_zarez( "dugdem", 15, 2  )
   cSql += coalesce_num_num( "potdem", 15, 2  )

   cSql += " FROM fmk.fin_sint"


   cWhere := use_sql_sint_where( hParams )
   cOrder := use_sql_sint_order( hParams )

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1"
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_SINT )

   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON  IdFirma + IdKonto + DToS( DatNal )  TAG "1" TO cTable
      INDEX ON idFirma + IdVN + BrNal + Rbr  TAG "2" TO cTable
      INDEX ON idFirma + DToS( DatNal )  TAG "3" TO cTable
      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.


STATIC FUNCTION use_sql_sint_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY idfirma,idvn,brnal"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_sint_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere := parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvn" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idvn", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brnal" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "brnal", hParams[ "brnal" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idkonto" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idkonto", hParams[ "idkonto" ] )
   ENDIF


   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql_date_interval( "datnal", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   RETURN cWhere


/* --- anal -- */

FUNCTION use_sql_anal( hParams )

   LOCAL cTable := "ANAL"
   LOCAL cWhere, cOrder
   LOCAL cSql


/*
CREATE TABLE fmk.fin_anal
(
  idfirma character(2) NOT NULL,
  idkonto character(7),
  idvn character(2) NOT NULL,
  brnal character(8) NOT NULL,
  rbr character varying(4) NOT NULL,
  datnal date,
  dugbhd numeric(17,2),
  potbhd numeric(17,2),
  dugdem numeric(15,2),
  potdem numeric(15,2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.fin_anal
  OWNER TO admin;
GRANT ALL ON TABLE fmk.fin_anal TO admin;
GRANT ALL ON TABLE fmk.fin_anal TO xtrole;

*/

   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvn", 2 )
   cSql += coalesce_char_zarez( "brnal", 8 )
   cSql += coalesce_char_zarez( "idkonto", 7 )
   cSql += coalesce_char_zarez( "rbr", 4 )
   cSql += "datnal, "
   cSql += coalesce_num_num_zarez( "dugbhd", 17, 2 )
   cSql += coalesce_num_num_zarez( "potbhd", 17, 2 )
   cSql += coalesce_num_num_zarez( "dugdem", 15, 2  )
   cSql += coalesce_num_num( "potdem", 15, 2  )

   cSql += " FROM fmk.fin_anal"


   cWhere := use_sql_anal_where( hParams )
   cOrder := use_sql_anal_order( hParams )

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1"
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_ANAL )

   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON  IdFirma + IdKonto + DToS( DatNal )  TAG "1" TO cTable
      INDEX ON idFirma + IdVN + BrNal + Rbr  TAG "2" TO cTable
      INDEX ON idFirma + DToS( DatNal )  TAG "3" TO cTable
      INDEX ON  Idkonto  TAG "4" TO cTable
      INDEX ON  DatNal  TAG "5" TO cTable

      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.


STATIC FUNCTION use_sql_anal_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY idfirma,idvn,brnal"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_anal_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere := parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvn" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idvn", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brnal" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "brnal", hParams[ "brnal" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idkonto" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idkonto", hParams[ "idkonto" ] )
   ENDIF


   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql_date_interval( "datnal", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   RETURN cWhere


FUNCTION use_sql_suban( hParams )

   LOCAL cTable := "SUBAN"
   LOCAL cWhere, cOrder
   LOCAL cSql

   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvn", 2 )
   cSql += coalesce_char_zarez( "brnal", 8 )
   cSql += coalesce_char_zarez( "idkonto", 7 )
   cSql += coalesce_char_zarez( "idpartner", 6 )
   cSql += coalesce_int_zarez( "rbr" )
   cSql += coalesce_char_zarez( "idtipdok", 2 )
   cSql += coalesce_char_zarez( "brdok", 20 )
   cSql += "coalesce(datdok, TO_DATE('','yyyymmdd')) as datdok, coalesce( datval, TO_DATE('','yyyymmdd')) as datval,"
   cSql += coalesce_char_zarez( "otvst", 1 )
   cSql += coalesce_char_zarez( "d_p", 1 )

   cSql += coalesce_char_zarez( "opis", 500 )
   cSql += coalesce_char_zarez( "k1", 1 )
   cSql += coalesce_char_zarez( "k2", 1 )
   cSql += coalesce_char_zarez( "k3", 2 )
   cSql += coalesce_char_zarez( "k4", 2 )
   cSql += coalesce_char_zarez( "m1", 1 )
   cSql += coalesce_char_zarez( "m2", 2 )
   cSql += coalesce_char_zarez( "idrj", 6 )
   cSql += coalesce_char_zarez( "funk", 5 )
   cSql += coalesce_char_zarez( "fond", 4 )

   cSql += coalesce_num_num_zarez( "iznosbhd", 17, 2 )
   cSql += coalesce_num_num( "iznosdem", 15, 2  )

   cSql += " FROM fmk.fin_suban"


   cWhere := use_sql_suban_where( hParams )
   cOrder := use_sql_suban_order( hParams )

   IF !Empty( cWhere )
      cSql += " WHERE " + cWhere
      IF !Empty( cOrder )
         cSql += cOrder
      ENDIF
   ELSE
      cSql += " OFFSET 0 LIMIT 1"
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_SUBAN )

   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON IdFirma + IdKonto + IdPartner + DToS( DatDok ) + BrNal + Str( RBr, 5 )  TAG "1" TO cTable
      INDEX ON IdFirma + IdPartner + IdKonto  TAG "2" TO cTable
      INDEX ON IdFirma + IdKonto + IdPartner + BrDok + DToS( DatDok )  TAG "3" TO cTable
      INDEX ON idFirma + IdVN + BrNal + Str( Rbr, 5 )  TAG "4" TO cTable
      INDEX ON idFirma + IdKonto + DToS( DatDok ) + idpartner  TAG "5" TO cTable
      INDEX ON IdKonto  TAG "6" TO cTable
      INDEX ON Idpartner  TAG "7" TO cTable
      INDEX ON Datdok  TAG "8" TO cTable
      INDEX ON idfirma + idkonto + idrj + idpartner + DToS( datdok ) + brnal + Str( rbr, 5 )  TAG "9" TO cTable
      INDEX ON idFirma + IdVN + BrNal + idkonto + DToS( datdok )  TAG "10" TO cTable

      SET ORDER TO TAG "1"
      GO TOP
   ENDIF

   RETURN .T.


STATIC FUNCTION use_sql_suban_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY idvn,brnal"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_suban_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere := parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idvn" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idvn", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brnal" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "brnal", hParams[ "brnal" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idkonto" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idkonto", hParams[ "idkonto" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idpartner" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idpartner", hParams[ "idpartner" ] )
   ENDIF


   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql_date_interval( "datdok", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   RETURN cWhere
