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

FUNCTION find_roba_by_sifradob( cIdSifraDob, cOrderBy, cWhere )

   LOCAL hParams := hb_Hash()

   hb_default( @cOrderBy, "id,naz" )

   IF cIdSifraDob <> NIL
      hParams[ "sifradob" ] := cIdSifraDob
   ENDIF
   hParams[ "order_by" ] := cOrderBy

   hParams[ "indeks" ] := .F.

   IF cWhere != NIL
      hParams[ "where" ] := cWhere
   ENDIF
   IF !use_sql_roba( hParams )
      RETURN .F.
   ENDIF
   GO TOP

   RETURN ! Eof()


FUNCTION find_roba_by_id( cId, lCheckOnly, cWhere )

   LOCAL hParams := hb_Hash()

   hb_default( @lCheckOnly, .F. )

   IF lCheckOnly
      hParams[ "check_only" ] := .T.
   ENDIF

   IF cId <> NIL
      hParams[ "id" ] := cId
   ENDIF

   // hParams[ "order_by" ] := cOrderBy


   hParams[ "indeks" ] := .F.

   IF cWhere != NIL
      hParams[ "where" ] := cWhere
   ENDIF

   IF !use_sql_roba( hParams )
      RETURN .F.
   ENDIF

   GO TOP

   RETURN ! Eof()



FUNCTION find_roba_by_id_sintetika( cId, lCheckOnly, cWhere )

   LOCAL hParams := hb_Hash()

   hb_default( @lCheckOnly, .F. )

   IF lCheckOnly
      hParams[ "check_only" ] := .T.
   ENDIF

   IF cId <> NIL
      hParams[ "id" ] := cId
   ENDIF

   hParams[ "sintetika" ] := .T.  // pretraga sa LIKE  idç%
   hParams[ "indeks" ] := .F.

   IF cWhere != NIL
      hParams[ "where" ] := cWhere
   ENDIF

   IF !use_sql_roba( hParams )
      RETURN .F.
   ENDIF

   GO TOP

   RETURN ! Eof()


/*


CREATE TABLE fmk.roba
(
  id character(10) NOT NULL,
  match_code character(10),
  sifradob character(20),
  naz character varying(250),
  jmj character(3),
  idtarifa character(6),
  nc numeric(18,8),
  vpc numeric(18,8),
  mpc numeric(18,8),
  tip character(1),
  carina numeric(5,2),
  opis text,
  vpc2 numeric(18,8),
  mpc2 numeric(18,8),
  mpc3 numeric(18,8),
  k1 character(4),
  k2 character(4),
  n1 numeric(12,2),
  n2 numeric(12,2),
  plc numeric(18,8),
  mink numeric(12,2),
  _m1_ character(1),
  barkod character(13),
  zanivel numeric(18,8),
  zaniv2 numeric(18,8),
  trosk1 numeric(15,5),
  trosk2 numeric(15,5),
  trosk3 numeric(15,5),
  trosk4 numeric(15,5),
  trosk5 numeric(15,5),
  fisc_plu numeric(10,0),
  k7 character(4),
  k8 character(4),
  k9 character(4),
  strings numeric(10,0),
  idkonto character(7),
  mpc4 numeric(18,8),
  mpc5 numeric(18,8),
  mpc6 numeric(18,8),
  mpc7 numeric(18,8),
  mpc8 numeric(18,8),
  mpc9 numeric(18,8)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.roba
  OWNER TO admin;
GRANT ALL ON TABLE fmk.roba TO admin;
GRANT ALL ON TABLE fmk.roba TO xtrole;

*/
FUNCTION use_sql_roba( hParams )

   LOCAL cTable := "ROBA"
   LOCAL cWhere, cOrder
   LOCAL cSql, lCheckOnly := .F.

   default_if_nil( @hParams, hb_Hash() )

   IF hb_HHasKey( hParams, "check_only" ) .AND. hParams[ "check_only" ] == .T.
      lCheckOnly := .T.
   ENDIF

   cSql := "SELECT "

   IF lCheckOnly
      cSql += coalesce_char( "id", 10 )
   ELSE
      cSql += coalesce_char_zarez( "id", 10 )
      cSql += coalesce_char_zarez( "sifradob", 20 )
      cSql += coalesce_char_zarez( "naz", 250 )
      cSql += coalesce_char_zarez( "jmj", 3 )
      cSql += coalesce_char_zarez( "idtarifa", 6 )
      cSql += coalesce_char_zarez( "tip", 1 )
      cSql += coalesce_char_zarez( "opis", 200 )
      cSql += coalesce_char_zarez( "k1", 4 )
      cSql += coalesce_char_zarez( "k2", 4 )
      cSql += coalesce_char_zarez( "barkod", 13 )

      cSql += coalesce_num_num_zarez( "n1", 12, 2 )
      cSql += coalesce_num_num_zarez( "n2", 12, 2 )
      cSql += coalesce_num_num_zarez( "carina", 5, 2 )
      cSql += coalesce_num_num_zarez( "nc", 18, 8 )
      cSql += coalesce_num_num_zarez( "vpc", 18, 8 )
      cSql += coalesce_num_num_zarez( "vpc2", 18, 8 )
      cSql += coalesce_num_num_zarez( "mpc", 18, 8 )
      cSql += coalesce_num_num_zarez( "mpc2", 18, 8 )
      cSql += coalesce_num_num_zarez( "mpc3", 18, 8 )
      cSql += coalesce_num_num_zarez( "mpc4", 18, 8 )
      cSql += coalesce_num_num( "mpc5", 18, 8 )
   ENDIF

   cSql += " FROM fmk.roba"


   cWhere := use_sql_roba_where( hParams )
   cOrder := use_sql_roba_order( hParams )

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
   IF !use_sql( cTable, cSql )
      RETURN .F.
   ENDIF

   IF is_sql_rdd_treba_indeks( hParams )
      INDEX ON id  TAG "ID" TO cTable
      INDEX ON naz  TAG "NAZ" TO cTable

      SET ORDER TO TAG "ID"
   ENDIF

   GO TOP

   RETURN .T.


STATIC FUNCTION use_sql_roba_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY id,naz"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_roba_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "id" )
      IF hb_HHasKey( hParams, "sintetika" ) .AND. hParams[ "sintetika" ]  //   npr: id like '100%'
         cWhere := "id LIKE " + sql_quote( Trim( hParams[ "id" ] ) + "%" )
      ELSE
         cWhere := parsiraj_sql( "id", hParams[ "id" ] )
      ENDIF
   ENDIF

   IF hb_HHasKey( hParams, "sifradob" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "trim(sifradob)", hParams[ "sifradob" ] )
   ENDIF

   IF hb_HHasKey( hParams, "where" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) +  hParams[ "where" ]
   ENDIF

   RETURN cWhere
