#include "f18.ch"



/*

-- Table: fmk.fakt_fakt

-- DROP TABLE fmk.fakt_fakt;

CREATE TABLE fmk.fakt_fakt
(
  idfirma character(2) NOT NULL,
  idtipdok character(2) NOT NULL,
  brdok character(8) NOT NULL,
  datdok date,
  idpartner character(6),
  dindem character(3),
  zaokr numeric(1,0),
  rbr character(3) NOT NULL,
  podbr character(2),
  idroba character(10),
  serbr character(15),
  kolicina numeric(14,5),
  cijena numeric(14,5),
  rabat numeric(8,5),
  porez numeric(9,5),
  txt text,
  k1 character(4),
  k2 character(4),
  m1 character(1),
  brisano character(1),
  idroba_j character(10),
  idvrstep character(2),
  idpm character(15),
  c1 character(20),
  c2 character(20),
  c3 character(20),
  n1 numeric(10,3),
  n2 numeric(10,3),
  idrelac character(4),
  CONSTRAINT fakt_fakt_pkey PRIMARY KEY (idfirma, idtipdok, brdok, rbr)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.fakt_fakt
  OWNER TO admin;
GRANT ALL ON TABLE fmk.fakt_fakt TO admin;
GRANT ALL ON TABLE fmk.fakt_fakt TO xtrole;

-- Index: fmk.fakt_fakt_datdok

-- DROP INDEX fmk.fakt_fakt_datdok;

CREATE INDEX fakt_fakt_datdok
  ON fmk.fakt_fakt
  USING btree
  (datdok);

-- Index: fmk.fakt_fakt_id1

-- DROP INDEX fmk.fakt_fakt_id1;

CREATE INDEX fakt_fakt_id1
  ON fmk.fakt_fakt
  USING btree
  (idfirma COLLATE pg_catalog."default", idtipdok COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default", rbr COLLATE pg_catalog."default", idpartner COLLATE pg_catalog."default");

*/

/*

-- Table: fmk.fakt_doks

-- DROP TABLE fmk.fakt_doks;

CREATE TABLE fmk.fakt_doks
(
  idfirma character(2) NOT NULL,
  idtipdok character(2) NOT NULL,
  brdok character(8) NOT NULL,
  partner character varying(200),
  datdok date,
  dindem character(3),

  iznos numeric(12,3),
  rabat numeric(12,3),

  rezerv character(1),
  m1 character(1),
  idpartner character(6),
  sifra character(6),
  brisano character(1),
  idvrstep character(2),
  datpl date,
  idpm character(15),
  oper_id integer,
  fisc_rn numeric(10,0),
  dat_isp date,
  dat_otpr date,
  dat_val date,
  fisc_st numeric(10,0),
  fisc_time character(10),
  fisc_date date,
  obradjeno timestamp without time zone DEFAULT now(),
  korisnik text DEFAULT "current_user"(),
  CONSTRAINT fakt_doks_pkey PRIMARY KEY (idfirma, idtipdok, brdok)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.fakt_doks
  OWNER TO admin;
GRANT ALL ON TABLE fmk.fakt_doks TO admin;
GRANT ALL ON TABLE fmk.fakt_doks TO xtrole;

-- Index: fmk.fakt_doks_datdok

-- DROP INDEX fmk.fakt_doks_datdok;

CREATE INDEX fakt_doks_datdok
  ON fmk.fakt_doks
  USING btree
  (datdok);

-- Index: fmk.fakt_doks_id1

-- DROP INDEX fmk.fakt_doks_id1;

CREATE INDEX fakt_doks_id1
  ON fmk.fakt_doks
  USING btree
  (idfirma COLLATE pg_catalog."default", idtipdok COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default", datdok, idpartner COLLATE pg_catalog."default");


*/

/*

-- Table: fmk.fakt_doks2

-- DROP TABLE fmk.fakt_doks2;

CREATE TABLE fmk.fakt_doks2
(
  idfirma character(2),
  idtipdok character(2),
  brdok character(8),
  k1 character(15),
  k2 character(15),
  k3 character(15),
  k4 character(20),
  k5 character(20),
  n1 numeric(15,2),
  n2 numeric(15,2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fmk.fakt_doks2
  OWNER TO admin;
GRANT ALL ON TABLE fmk.fakt_doks2 TO admin;
GRANT ALL ON TABLE fmk.fakt_doks2 TO xtrole;

-- Index: fmk.fakt_doks2_id1

-- DROP INDEX fmk.fakt_doks2_id1;

CREATE INDEX fakt_doks2_id1
  ON fmk.fakt_doks2
  USING btree
  (idfirma COLLATE pg_catalog."default", idtipdok COLLATE pg_catalog."default", brdok COLLATE pg_catalog."default");


*/
FUNCTION find_fakt_dokument( cIdFirma, cIdTipDok, cBrDok )

   LOCAL lRet

   seek_fakt_doks( cIdFirma, cIdTipDok, cBrDok, NIL, "1" )

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
      cSql += "rpad(brdok," + ALLTRIM( Str( FIELD_LEN_FAKT_BRDOK ) ) + ")=" + sql_quote( cBrDok )
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

   RETURN !Eof()



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


/*
   seek_fakt_doks_6( self_organizacija_id(), cIdPartner )
*/

FUNCTION seek_fakt_doks_6( cIdFirma, cIdPartner, cIdTipDok )

   RETURN seek_fakt_doks( cIdFirma, cIdTipDok, NIL, cIdPartner, "6" )


// ---------------------------------------------------------------------------------------

FUNCTION seek_fakt( cIdFirma, cIdTipDok, cBrDok, cIdPartner, cIdRoba, dDatDokOd, cTag, cAlias )

   LOCAL cSql
   LOCAL cTable := "fakt_fakt"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   IF cAlias == NIL
      cAlias := "FAKT"
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


   IF cBrDok != NIL .AND. !Empty( cBrDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "rpad(brdok," + ALLTRIM( Str( FIELD_LEN_FAKT_BRDOK ) ) + ")=" + sql_quote( cBrDok )
   ENDIF


   IF cIdPartner != NIL .AND. !Empty( cIdPartner )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "idroba=" + sql_quote( cIdPartner )
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

   RETURN !Eof()


FUNCTION h_fakt_fakt_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "IdFirma+idtipdok+brdok+rbr+podbr"
   hIndexes[ "2" ] := "IdFirma+dtos(datDok)+idtipdok+brdok+rbr"
   hIndexes[ "3" ] := "idroba+dtos(datDok)"
   hIndexes[ "6" ] := "idfirma+idpartner+idroba+idtipdok+dtos(datdok)"
   hIndexes[ "7" ] := "idfirma+idpartner+idroba+dtos(datdok)"
   hIndexes[ "8" ] := "datdok"

   RETURN hIndexes


/*
   "idroba+dtos(datDok)"
  */
FUNCTION  seek_fakt_3( cIdFirma, cIdRoba )
   RETURN seek_fakt( cIdFirma, NIL, NIL, NIL, cIdRoba, NIL, "3" )


FUNCTION seek_fakt_3_sintetika( cIdFirma, cIdRoba )
   RETURN seek_fakt( cIdFirma, NIL, NIL, NIL, Trim( cIdRoba ) + "%", NIL, "3" )

/*
     "idfirma+idpartner+idroba+idtipdok+dtos(datdok)"
      seek_fakt_6( _idfirma, _idpartne, _idroba, "10",  dNajstariji )
*/
FUNCTION seek_fakt_6( cIdFirma, cIdPartner, cIdRoba, cIdTipDok, dDatDokOd )
   RETURN seek_fakt( cIdFirma, cIdTipDok, NIL, cIdPartner, cIdRoba, dDatDokOd, "6" )



FUNCTION seek_fakt_doks2( cIdFirma, cIdTipDok, cBrDok, cTag )

   LOCAL cSql
   LOCAL cTable := "fakt_doks2", cAlias := "FAKT_DOKS2"
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

   RETURN !Eof()



FUNCTION h_fakt_doks2_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "IdFirma+idtipdok+brdok"

   RETURN hIndexes



// ----------------------------- fakt_fakt ------------------------------------------


/*
   find_fakt_za_period( cIdFirma, dDatOd, dDatDo, NIL, NIL, "3" )
*/
FUNCTION find_fakt_za_period( cIdFirma, dDatOd, dDatDo, cOrderBy, cWhere, cTag )

   LOCAL hParams := hb_Hash()

   hb_default( @cOrderBy, "idFirma,idtipdok,brdok,rbr" )

   IF cIdFirma <> NIL
      IF !Empty( cIdFirma )
         hParams[ "idfirma" ] := cIdFirma
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
      cTag := "1"
   ENDIF
   hParams[ "tag" ] := cTag

   IF cWhere != NIL
      hParams[ "where" ] := cWhere
   ENDIF

   IF !use_sql_fakt( hParams )
      RETURN .F.
   ENDIF

   GO TOP

   RETURN ! Eof()


FUNCTION use_sql_fakt( hParams )

   LOCAL cTable := "fakt_fakt", cAlias := "FAKT"
   LOCAL cWhere, cOrder
   LOCAL cSql
   LOCAL hIndexes, cKey, cTag := "1"

   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT * from fmk." + cTable

   cWhere := use_sql_fakt_where( hParams )
   cOrder := use_sql_fakt_order( hParams )

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

   SELECT ( F_FAKT )
   IF !use_sql( cTable, cSql, cAlias )
      RETURN .F.
   ENDIF

   IF hParams[ "indeks" ]
      hIndexes := h_fakt_fakt_indexes()

      FOR EACH cKey IN hIndexes:Keys
         INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
      NEXT
      SET ORDER TO TAG ( cTag )
   ENDIF
   GO TOP

   RETURN .T.


STATIC FUNCTION use_sql_fakt_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY idfirma,idtipdok,brdok"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_fakt_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere := parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idtipdok" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idtipdok", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "brdok", hParams[ "brdok" ] )
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

   IF hb_HHasKey( hParams, "where" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) +  hParams[ "where" ]
   ENDIF

   RETURN cWhere




// --------------- fakt_doks ----------------------------------------------------------------------------------------------


FUNCTION fakt_doks_update_fisk_parametri_by_id( cIdFirma, cIdTipDok, cBrDok, hRec )

   LOCAL oQry, cSql := "update fmk.fakt_doks "

   cSql += "set fisc_rn=" + sql_quote( hRec[ "fisc_rn" ] )
   cSql += ",fisc_st=" + sql_quote( hRec[ "fisc_st" ] )
   cSql += ",fisc_time=" + sql_quote( hRec[ "fisc_time" ] )
   cSql += ",fisc_date=" + sql_quote( hRec[ "fisc_date" ] )

   cSql += " WHERE idfirma=" + sql_quote( cIdFirma )
   cSql += " AND idtipdok=" + sql_quote( cIdtipDok )
   cSql += " AND brdok=" + sql_quote( cBrDok )

   oQry := run_sql_query( cSql  )
   IF sql_error_in_query( oQry, "UPDATE" )
      RETURN .F.
   ENDIF

   RETURN .T.

/*
   find_fakt_doks_za_period( cIdFirma, dDatOd, dDatDo, "FAKT_DOKS_PREGLED", "idfirma,datdok,idtipdok,brdok" )
*/

FUNCTION find_fakt_doks_za_period( cIdFirma, dDatOd, dDatDo, cAlias, cOrderBy, cWhere )

   LOCAL hParams := hb_Hash()

   hb_default( @cOrderBy, "idFirma,idtipdok,brdok" )

   IF cIdFirma <> NIL
      IF !Empty( cIdFirma )
         hParams[ "idfirma" ] := cIdFirma
      ENDIF
   ENDIF

   IF dDatOd != NIL
      IF !Empty( dDatOd )
         hParams[ "dat_od" ] := dDatOd
      ENDIF
   ENDIF

   IF dDatDo != NIL
      hParams[ "dat_do" ] := dDatDo
   ENDIF

   hParams[ "order_by" ] := cOrderBy
   hParams[ "indeks" ] := .F.

   IF cAlias != NIL
      IF cAlias == "FAKT_DOKS_PREGLED"
         hParams[ "area" ] := F_FAKT_DOKS_PREGLED
      ELSE
         hParams[ "area" ] := F_FAKT_DOKS_X
      ENDIF
      hParams[ "alias" ] := cAlias
   ELSE
      hParams[ "area" ] := F_FAKT_DOKS
      hParams[ "alias" ] := "FAKT_DOKS"
   ENDIF

   IF cWhere != NIL
      hParams[ "where" ] := cWhere
   ENDIF

   IF !use_sql_fakt_doks( hParams )
      RETURN .F.
   ENDIF

   GO TOP

   RETURN ! Eof()


FUNCTION use_sql_fakt_doks( hParams )

   LOCAL cTable := "fakt_doks"
   LOCAL cWhere, cOrder
   LOCAL cSql
   LOCAL hIndexes, cKey, cTag := 1

   default_if_nil( @hParams, hb_Hash() )

   cSql := "SELECT * from fmk." + cTable

   cWhere := use_sql_fakt_doks_where( hParams )
   cOrder := use_sql_fakt_doks_order( hParams )

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

   SELECT ( hParams[ "area" ] )

   IF !use_sql( cTable, cSql, hParams[ "alias" ] )
      RETURN .F.
   ENDIF

   IF hParams[ "indeks" ]
      hIndexes := h_fakt_doks_indexes()

      FOR EACH cKey IN hIndexes:Keys
         INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
      NEXT
      IF cTag == NIL
         cTag := "1"
      ENDIF
      SET ORDER TO TAG ( cTag )
   ENDIF

   GO TOP

   RETURN .T.


STATIC FUNCTION use_sql_fakt_doks_order( hParams )

   LOCAL cOrder := ""

   IF hb_HHasKey( hParams, "order_by" )
      cOrder += " ORDER BY " + hParams[ "order_by" ]
   ELSE
      cOrder += " ORDER BY idfirma,idtipdok,brdok"
   ENDIF

   RETURN cOrder


STATIC FUNCTION use_sql_fakt_doks_where( hParams )

   LOCAL cWhere := ""
   LOCAL dDatOd

   IF hb_HHasKey( hParams, "idfirma" )
      cWhere := parsiraj_sql( "idfirma", hParams[ "idfirma" ] )
   ENDIF

   IF hb_HHasKey( hParams, "idtipdok" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "idtipdok", hParams[ "idvn" ] )
   ENDIF

   IF hb_HHasKey( hParams, "brdok" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) + parsiraj_sql( "brdok", hParams[ "brdok" ] )
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

   IF hb_HHasKey( hParams, "where" )
      cWhere += iif( Empty( cWhere ), "", " AND " ) +  hParams[ "where" ]
   ENDIF

   RETURN cWhere



// ------------------------------

FUNCTION o_fakt_txt( cId )

   SELECT ( F_FAKT_FTXT )
   IF !use_sql_sif( "fakt_ftxt", .T., "FAKT_FTXT", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   GO TOP
   IF cId != NIL
      SEEK cId
      IF !Found()
         GO TOP
      ENDIF
   ENDIF

   RETURN !Eof()

/*
    FAKT_FTXT, fakt_ftxt
*/

FUNCTION select_o_fakt_txt( cId )

   SELECT ( F_FAKT_FTXT )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_fakt_txt( cId )


FUNCTION find_fakt_ftxt_by_id( cId )

   LOCAL cAlias := "FAKT_FTXT"
   LOCAL cTable := "fakt_ftxt"
   LOCAL cSqlQuery := "select * from fmk." + cTable
   LOCAL cIdSql

   cIdSql := sql_quote( "%" + Upper( AllTrim( cId ) ) + "%" )
   cSqlQuery += " WHERE id ilike " + cIdSql

   IF !use_sql( cTable, cSqlQuery, cAlias )
      RETURN .F.
   ENDIF
   INDEX ON ID TAG ID TO ( cAlias )
   INDEX ON NAZ TAG NAZ TO ( cAlias )
   SET ORDER TO TAG "ID"

   SEEK cId
   IF !Found()
      GO TOP
   ENDIF

   RETURN !Eof()


FUNCTION find_fakt_txt_by_naz_or_id( cId )

   LOCAL cAlias := "FAKT_FTXT"
   LOCAL cSqlQuery := "select * from fmk.fakt_ftxt"
   LOCAL cIdSql

   cIdSql := sql_quote( "%" + Upper( AllTrim( cId ) ) + "%" )
   cSqlQuery += " WHERE id ilike " + cIdSql
   cSqlQuery += " OR naz ilike " + cIdSql

   IF !use_sql( "fakt_ftxt", cSqlQuery, cAlias )
      RETURN .F.
   ENDIF
   INDEX ON ID TAG ID TO ( cAlias )
   INDEX ON NAZ TAG NAZ TO ( cAlias )
   SET ORDER TO TAG "ID"

   SEEK cId
   IF !Found()
      GO TOP
   ENDIF

   RETURN !Eof()



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
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_fakt_objekti( cId )
