#include "f18.ch"


/*


-- Table: fmk.epdv_kuf

-- DROP TABLE fmk.epdv_kuf;

CREATE TABLE fmk.epdv_kuf
(
  datum date,
  datum_2 date,
  src character(1),
  td_src character(2),
  src_2 character(1),
  id_tar character(6),
  id_part character(6),
  part_idbr character(13),
  part_kat character(1),
  src_td character(12),
  src_br character(12),
  src_veza_b character(12),
  src_br_2 character(12),
  r_br numeric(6,0),
  br_dok numeric(6,0),
  g_r_br numeric(8,0),
  lock character(1),
  kat character(1),
  kat_2 character(1),
  opis character(160),
  i_b_pdv numeric(16,2),
  i_pdv numeric(16,2),
  i_v_b_pdv numeric(16,2),
  i_v_pdv numeric(16,2),
  status character(1),
  kat_p character(1),
  kat_p_2 character(1),
  p_kat character(1),
  p_kat_2 character(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.epdv_kuf
  OWNER TO hernad;

-- Index: fmk.epdv_kuf_id1

-- DROP INDEX fmk.epdv_kuf_id1;

CREATE INDEX epdv_kuf_id1
  ON fmk.epdv_kuf
  USING btree
  (datum, datum_2);


*/

/*

-- Table: fmk.epdv_kif

-- DROP TABLE fmk.epdv_kif;

CREATE TABLE fmk.epdv_kif
(
  datum date,
  datum_2 date,
  src character(1),
  td_src character(2),
  src_2 character(1),
  id_tar character(6),
  id_part character(6),
  part_idbr character(13),
  part_kat character(1),
  part_kat_2 character(13),
  src_pm character(6),
  src_td character(12),
  src_br character(12),
  src_veza_b character(12),
  src_br_2 character(12),
  r_br numeric(6,0),
  br_dok numeric(6,0),
  g_r_br numeric(8,0),
  lock character(1),
  kat character(1),
  kat_2 character(1),
  opis character(160),
  i_b_pdv numeric(16,2),
  i_pdv numeric(16,2),
  i_v_b_pdv numeric(16,2),
  i_v_pdv numeric(16,2),
  status character(1),
  kat_p character(1),
  kat_p_2 character(1),
  p_kat character(1),
  p_kat_2 character(1)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.epdv_kif
  OWNER TO hernad;

-- Index: fmk.epdv_kif_id1

-- DROP INDEX fmk.epdv_kif_id1;

CREATE INDEX epdv_kif_id1
  ON fmk.epdv_kif
  USING btree
  (datum, datum_2);


*/


/*

-- Table: fmk.epdv_pdv

-- DROP TABLE fmk.epdv_pdv;

CREATE TABLE fmk.epdv_pdv
(
  datum_1 date,
  datum_2 date,
  datum_3 date,
  id_br character(12),
  per_od date,
  per_do date,
  po_naziv character(60),
  po_adresa character(60),
  po_ptt character(10),
  po_mjesto character(40),
  isp_opor numeric(18,2),
  isp_izv numeric(18,2),
  isp_neopor numeric(18,2),
  isp_nep_sv numeric(18,2),
  nab_opor numeric(18,2),
  nab_uvoz numeric(18,2),
  nab_ne_opo numeric(18,2),
  nab_st_sr numeric(18,2),
  i_pdv_r numeric(18,2),
  i_pdv_nr1 numeric(18,2),
  i_pdv_nr2 numeric(18,2),
  i_pdv_nr3 numeric(18,2),
  i_pdv_nr4 numeric(18,2),
  u_pdv_r numeric(18,2),
  u_pdv_uv numeric(18,2),
  u_pdv_pp numeric(18,2),
  i_pdv_uk numeric(18,2),
  u_pdv_uk numeric(18,2),
  pdv_uplati numeric(18,2),
  pdv_prepla numeric(18,2),
  pdv_povrat character(1),
  pot_mjesto character(40),
  pot_datum date,
  pot_ob character(80),
  lock character(1),
  i_opor numeric(18,2),
  i_u_pdv_41 numeric(18,2),
  i_u_pdv_43 numeric(18,2),
  i_izvoz numeric(18,2),
  i_neop numeric(18,2),
  u_nab_21 numeric(18,2),
  u_nab_23 numeric(18,2),
  u_uvoz numeric(18,2),
  u_pdv_41 numeric(18,2),
  u_pdv_43 numeric(18,2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.epdv_pdv
  OWNER TO hernad;

-- Index: fmk.epdv_pdv_id1

-- DROP INDEX fmk.epdv_pdv_id1;

CREATE INDEX epdv_pdv_id1
  ON fmk.epdv_pdv
  USING btree
  (datum_1, datum_2);


*/

FUNCTION find_epdv_kuf_za_period( dDatOd, dDatDo, cIdTarifa, cIdPartner, cOrderBy, cWhere, cTag )
   RETURN find_epdv_kuf_kif_za_period( "kuf", dDatOd, dDatDo, cIdTarifa, cIdPartner, cOrderBy, cWhere, cTag )


/*
   find_epdv_kif_za_period( dDatOd, dDatDo )  // g_r_br
   find_epdv_kif_za_period( dDatOd, dDatDo, NIL, NIL, NIL, NIL, "datum" )
*/

FUNCTION find_epdv_kif_za_period( dDatOd, dDatDo, cIdTarifa, cIdPartner, cOrderBy, cWhere, cTag )
   RETURN find_epdv_kuf_kif_za_period( "kif", dDatOd, dDatDo, cIdTarifa, cIdPartner, cOrderBy, cWhere, cTag )



FUNCTION find_epdv_kuf_kif_za_period( cKufKif, dDatOd, dDatDo, cIdTarifa, cIdPartner, cOrderBy, cWhere, cTag )

   LOCAL hParams := hb_Hash()

   hb_default( @cOrderBy, "g_r_br,datum" )

   hParams[ "kuf_kif" ] := cKufKif

   IF cIdTarifa <> NIL
      IF !Empty( cIdTarifa )
         hParams[ "idtarifa" ] := cIdTarifa
      ENDIF
   ENDIF

   IF cIdPartner <> NIL
      IF !Empty( cIdPartner )
         hParams[ "idpartner" ] := cIdPartner
      ENDIF
   ENDIF

   IF dDatOd != NIL
      hParams[ "dat_od" ] := dDatOd
   ENDIF

   IF dDatDo != NIL
      hParams[ "dat_do" ] := dDatDo
   ENDIF

   hParams[ "order_by" ] := cOrderBy

   hParams[ "indeks" ] := .T.

   IF cTag == NIL
      cTag := "g_r_br"
   ENDIF
   hParams[ "tag" ] := cTag

   IF cWhere != NIL
      hParams[ "where" ] := cWhere
   ENDIF

   IF !use_sql_epdv_kuf_kif( hParams )
      RETURN .F.
   ENDIF

   GO TOP

   RETURN ! Eof()



FUNCTION use_sql_epdv_kuf_kif( hParams )

   LOCAL cTable := "epdv_kuf", cAlias := "KUF", nArea := F_KUF
   LOCAL cWhere, cOrder
   LOCAL cSql
   LOCAL hIndexes, cKey, cTag

   default_if_nil( @hParams, hb_Hash() )

   IF hParams[ "kuf_kif" ] == "kif"
      cTable := "epdv_kif"
      cAlias := "KIF"
      nArea := F_KIF
   ENDIF

   cSql := "SELECT * from fmk." + cTable

   cWhere := use_sql_epdv_kuf_kif_where( hParams )
   cOrder := use_sql_epdv_kuf_kif_order( hParams )

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

   IF hb_HHasKey( hParams, "tag" )
      cTag := hParams[ "tag" ]
   ENDIF

   SELECT ( nArea )
   IF !use_sql( cTable, cSql, cAlias )
      RETURN .F.
   ENDIF

   IF hParams[ "indeks" ]
      hIndexes := h_epdv_kuf_kif_indexes()

      FOR EACH cKey IN hIndexes:Keys
         INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
      NEXT
      SET ORDER TO TAG ( cTag )
   ENDIF
   GO TOP

   RETURN .T.


STATIC FUNCTION use_sql_epdv_kuf_kif_order( hParams )

   LOCAL cOrder := ""

      cOrder += " ORDER BY " + hParams[ "order_by" ]

   RETURN cOrder


STATIC FUNCTION use_sql_epdv_kuf_kif_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idtarifa" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "id_tar", hParams[ "idtarifa" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idpartner" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "id_part", hParams[ "idpartner" ] )
   ENDIF

   IF hb_HHasKey( hParams, "dat_do" )
      IF !hb_HHasKey( hParams, "dat_od" )
         dDatOd := CToD( "" )
      ELSE
         dDatOd := hParams[ "dat_od" ]
      ENDIF
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql_date_interval( "datum", dDatOd, hParams[ "dat_do" ] )
   ENDIF

   IF hb_HHasKey( hParams, "where" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) +  hParams[ "where" ]
   ENDIF

   RETURN cWhere


FUNCTION h_epdv_kuf_kif_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "datum" ] := "dtos(datum)+src_br_2"
   hIndexes[ "l_datum" ] := "lock+dtos(datum)+src_br_2"
   hIndexes[ "g_r_br" ] := "STR(g_r_br,6,0)+dtos(datum)"
   hIndexes[ "br_dok" ] := "STR(BR_DOK,6,0)+STR(r_br,6,0)"
   hIndexes[ "br_dok2" ] := "STR(BR_DOK,6,0)+dtos(datum)"

   RETURN hIndexes



// ------------------------------------------------------------------------------------

FUNCTION o_sg_kuf( cId )

   SELECT ( F_SG_KUF )
   use_sql_epdv_sg_kuf( cId )
   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_sg_kuf( cId )

   SELECT ( F_SG_KUF )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_sg_kuf( cId )



FUNCTION use_sql_epdv_sg_kuf( cId )

   LOCAL cSql
   LOCAL cTable := "epdv_sg_kuf"

   SELECT ( F_SG_KUF )
   IF !use_sql_sif( cTable, .T., "SG_KUF", cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()





FUNCTION o_sg_kif( cId )

   SELECT ( F_SG_KIF )
   use_sql_epdv_sg_kif( cId )
   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_sg_kif( cId )

   SELECT ( F_SG_KIF )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_sg_kif( cId )



FUNCTION use_sql_epdv_sg_kif( cId )

   LOCAL cSql
   LOCAL cTable := "epdv_sg_kif"

   SELECT ( F_SG_KIF )
   IF !use_sql_sif( cTable, .T., "SG_KIF", cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()
