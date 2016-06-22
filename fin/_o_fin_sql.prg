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

FUNCTION find_suban_za_period( dDatOd, dDatDo )

   LOCAL hParams := hb_Hash()

   hParams[ "dat_od" ] := dDatOd
   hParams[ "dat_do" ] := dDatDo

   hParams[ "order_by" ] := "idFirma,IdVN,BrNal,Rbr"

   hParams[ "indeks" ] := .F.
   use_sql_suban( hParams )
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


FUNCTION find_suban_by_broj_dokumenta( cIdFirma, cIdVN, cBrNal )

   LOCAL hParams := hb_Hash()

   IF cIdFirma <> NIL
      hParams[ "idfirma" ] := cIdFirma
   ENDIF

   IF cIdVN <> NIL
      hParams[ "idvn" ] := cIdvn
   ENDIF

   IF cBrNal <> NIL
      hParams[ "brnal" ] := cBrNal
   ELSE
      hParams[ "order_by" ] := "brnal" // ako ima vise brojeva dokumenata sortiraj po njima
   ENDIF

   hParams[ "indeks" ] := .F. // ne trositi vrijeme na kreiranje indeksa

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





FUNCTION use_sql_suban( hParams )

   LOCAL cTable := "SUBAN"
   LOCAL cWhere, cOrder
   LOCAL cSql

   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT "
   cSql += coalesce_char_zarez( "idfirma", 2 )
   cSql += coalesce_char_zarez( "idvn", 2 )
   cSql += coalesce_char_zarez( "brnal", 10 )
   cSql += coalesce_char_zarez( "idkonto", 10 )
   cSql += coalesce_char_zarez( "idpartner", 6 )
   cSql += coalesce_int_zarez( "rbr" )
   cSql += coalesce_char_zarez( "idtipdok", 2 )
   cSql += coalesce_char_zarez( "brdok", 20 )
   cSql += "datdok, datval, "
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
      cSql += " OFFSET 0 LIMIT 1000"
   ENDIF

   IF hb_HHasKey( hParams, "alias" )
      cTable := hParams[ "alias" ]
   ENDIF

   SELECT ( F_SUBAN )

   use_sql( cTable, cSql )

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON IdFirma + IdKonto + IdPartner + DToS( DatDok ) + BrNal + RBr  TAG "1" TO cTable
      INDEX ON IdFirma + IdPartner + IdKonto  TAG "2" TO cTable
      INDEX ON IdFirma + IdKonto + IdPartner + BrDok + DToS( DatDok )  TAG "3" TO cTable
      INDEX ON idFirma + IdVN + BrNal + Rbr  TAG "4" TO cTable
      INDEX ON idFirma + IdKonto + DToS( DatDok ) + idpartner  TAG "5" TO cTable
      INDEX ON IdKonto  TAG "6" TO cTable
      INDEX ON Idpartner  TAG "7" TO cTable
      INDEX ON Datdok  TAG "8" TO cTable
      INDEX ON idfirma + idkonto + idrj + idpartner + DToS( datdok ) + brnal + rbr  TAG "9" TO cTable
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
      cWhere += IIF( Empty( cWhere), "", " AND ") + parsiraj_sql( "idvn", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brnal" )
      cWhere += IIF( Empty( cWhere), "", " AND ") + parsiraj_sql( "brnal", hParams[ "brnal" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idkonto" )
      cWhere += IIF( Empty( cWhere), "", " AND ") + parsiraj_sql( "idkonto", hParams[ "idkonto" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idpartner" )
      cWhere += IIF( Empty( cWhere), "", " AND ") + parsiraj_sql( "idpartner", hParams[ "idpartner" ] )
   ENDIF


   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += IIF( Empty( cWhere), "", " AND ") + parsiraj_sql_date_interval( "datdok", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   RETURN cWhere
