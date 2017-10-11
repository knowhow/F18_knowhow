
#include "f18.ch"

FUNCTION seek_pos_2( cIdOdj, cIdRoba, dDatum )

   LOCAL hParams := hb_Hash()

   hParams[ "idodj" ] := cIdOdj
   hParams[ "idroba" ] := cIdRoba
   hParams[ "datum" ] := dDatum
   hParams[ "tag" ] := "2"

   RETURN seek_pos_h( hParams )


FUNCTION seek_pos_pos( cIdPos, cIdVd, dDatum, cBrDok, cTag )

   LOCAL hParams := hb_Hash()

   hParams[ "idpos" ] := cIdPos
   hParams[ "idvd" ] := cIdVd
   hParams[ "datum" ] := dDatum
   hParams[ "brdok" ] := cBrDok
   hParams[  "tag" ] := cTag

   RETURN seek_pos_h( hParams )


FUNCTION seek_pos_h( hParams )

   LOCAL cIdPos, cIdVd, dDatum, cBrDok, cTag
   LOCAL cIdOdj, cIdRoba
   LOCAL cSql
   LOCAL cTable := "pos_pos", cAlias := "POS"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.

   IF hb_HHasKey( hParams, "idpos" )
      cIdPos := hParams[ "idpos" ]
   ENDIF
   IF hb_HHasKey( hParams, "idvd" )
      cIdVd := hParams[ "idvd" ]
   ENDIF
   IF hb_HHasKey( hParams, "datum" )
      dDatum := hParams[ "datum" ]
   ENDIF
   IF hb_HHasKey( hParams, "brdok" )
      cBrDok := hParams[ "brdok" ]
   ENDIF
   IF hb_HHasKey( hParams, "idodj" )
      cIdOdj := hParams[ "idodj" ]
   ENDIF
   IF hb_HHasKey( hParams, "idroba" )
      cIdRoba := hParams[ "idroba" ]
   ENDIF
   IF hb_HHasKey( hParams, "tag" )
      cTag := hParams[ "tag" ]
   ENDIF


   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   IF cIdPos != NIL .AND. !Empty( cIdPos )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idpos=" + sql_quote( cIdPos )
   ENDIF

   IF cIdVD != NIL .AND. !Empty( cIdVD )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idvd=" + sql_quote( cIdVd )
   ENDIF

   IF cIdOdj != NIL .AND. !Empty( cIdOdj )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idodj=" + sql_quote( cIdOdj )
   ENDIF

   IF cIdRoba != NIL .AND. !Empty( cIdRoba )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idroba=" + sql_quote( cIdRoba )
   ENDIF


   IF dDatum != NIL .AND. !Empty( dDatum )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "datum=" + sql_quote( dDatum )
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

   SELECT F_POS
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_pos_pos_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT

   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN !Eof()



FUNCTION h_pos_pos_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "IdPos+IdVd+dtos(datum)+BrDok+IdRoba+IdCijena+Rbr"
   hIndexes[ "2" ] := "IdOdj+idroba+DTOS(Datum)"
   hIndexes[ "3" ] := "Prebacen"
   hIndexes[ "4" ] := "dtos(datum)"
   hIndexes[ "5" ] := "IdPos+idroba+DTOS(Datum)"
   hIndexes[ "6" ] := "IdRoba"
   hIndexes[ "7" ] := "IdPos+IdVd+BrDok+DTOS(Datum)+IdDio+IdOdj"

   RETURN hIndexes


FUNCTION seek_pos_doks_2( cIdVd, dDatum )
   RETURN seek_pos_doks( NIL, cIdVd, dDatum, NIL, "2" )

FUNCTION seek_pos_doks( cIdPos, cIdVd, dDatum, cBrDok, cTag )

   LOCAL cSql
   LOCAL cTable := "pos_doks", cAlias := "POS_DOKS"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   IF cIdPos != NIL .AND. !Empty( cIdPos )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idpos=" + sql_quote( cIdPos )
   ENDIF

   IF cIdVD != NIL .AND. !Empty( cIdVD )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idvd=" + sql_quote( cIdVd )
   ENDIF

   IF dDatum != NIL .AND. !Empty( dDatum )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
      ENDIF
      cSql += "datum=" + sql_quote( dDatum )
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

   SELECT F_POS_DOKS
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_pos_doks_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT

   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN !Eof()



FUNCTION h_pos_doks_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "IdPos+IdVd+dtos(datum)+BrDok"
   hIndexes[ "2" ] := "IdVd+DTOS(Datum)+Smjena"
   hIndexes[ "3" ] := "IdGost+Placen+DTOS(Datum)"
   hIndexes[ "4" ] := "IdVd+M1"
   hIndexes[ "5" ] := "Prebacen"
   hIndexes[ "6" ] := "dtos(datum)"
   hIndexes[ "7" ] := "IdPos+IdVD+BrDok"
   hIndexes[ "TK" ] := "IdPos+DTOS(Datum)+IdVd"
   hIndexes[ "FISC" ] := "STR(fisc_rn,10)+idpos+idvd"

   RETURN hIndexes



FUNCTION pos_stanje_artikla( cIdPos, cIdRoba )

   LOCAL cQuery, _qry_ret, oTable
   LOCAL _data := {}
   LOCAL nI, oRow
   LOCAL nStanje := 0

   cQuery := "SELECT SUM( CASE WHEN idvd IN ('16') THEN kolicina WHEN idvd IN ('42') THEN -kolicina WHEN idvd IN ('IN') THEN -(kolicina - kol2) ELSE 0 END ) AS stanje FROM " + F18_PSQL_SCHEMA_DOT + "pos_pos " + ;
      " WHERE idpos = " + sql_quote( cIdPos ) + ;
      " AND idroba = " + sql_quote( cIdRoba )

   oTable := run_sql_query( cQuery )
   oRow := oTable:GetRow( 1 )
   nStanje := oRow:FieldGet( oRow:FieldPos( "stanje" ) )

   IF ValType( nStanje ) == "L"
      nStanje := 0
   ENDIF

   RETURN nStanje



FUNCTION pos_iznos_racuna( cIdPos, cIdVD, dDatum, cBrDok )

   LOCAL cSql, oData, oRow
   LOCAL nTotal := 0

   PushWA()

   IF PCount() == 0
      cIdPos := pos_doks->IdPos
      cIdVD := pos_doks->IdVD
      dDatum := pos_doks->Datum
      cBrDok := pos_doks->BrDok
   ENDIF

   cSql := "SELECT "
   cSql += " SUM( ( kolicina * cijena ) - ( kolicina * ncijena ) ) AS total "
   cSql += "FROM " + F18_PSQL_SCHEMA_DOT + "pos_pos "
   cSql += "WHERE "
   cSql += " idpos = " + sql_quote( cIdPos )
   cSql += " AND idvd = " + sql_quote( cIdVd )
   cSql += " AND brdok = " + sql_quote( cBrDok )
   cSql += " AND datum = " + sql_quote( dDatum )

   oData := run_sql_query( cSql )

   PopWa()

   IF !is_var_objekat_tpqquery( oData )
      RETURN nTotal
   ENDIF

   nTotal := oData:FieldGet( 1 )

   RETURN nTotal



FUNCTION pos_get_mpc()

   LOCAL nCijena := 0
   LOCAL cField
   LOCAL oData, cQry

   IF !pos_get_mpc_valid()
      MsgBeep( "Set cijena nije podesen ispravno !" )
      RETURN 0
   ENDIF

   cField := pos_get_mpc_field()

   cQry := "SELECT " + cField + " FROM " + F18_PSQL_SCHEMA_DOT + "roba "
   cQry += "WHERE id = " + sql_quote( roba->id )

   oData := run_sql_query( cQry )

   IF !is_var_objekat_tpqquery( oData )
      MsgBeep( "Problem sa SQL upitom !" )
   ELSE
      IF oData:LastRec() > 0 .AND. ValType( oData:FieldGet( 1 ) ) == "N"
         nCijena := oData:FieldGet( 1 )
      ENDIF
   ENDIF

   RETURN nCijena


STATIC FUNCTION pos_get_mpc_field()

   LOCAL cField := "mpc"
   LOCAL cSet := AllTrim( gSetMPCijena )

   IF cSet <> "1"
      cField := cField + cSet
   ENDIF

   RETURN cField



STATIC FUNCTION pos_get_mpc_valid()

   LOCAL lOk := .T.
   LOCAL cSet := AllTrim( gSetMPCijena )

   IF Empty( cSet ) .OR. cSet == "0"
      lOk := .F.
   ENDIF

   RETURN lOk


FUNCTION o_vrstep( cId )

   SELECT ( F_VRSTEP )
   use_sql_vrstep( cId )
   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_vrstep( cId )

   SELECT ( F_VRSTEP )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_vrstep( cId )


FUNCTION use_sql_vrstep( cId )

   LOCAL cSql
   LOCAL cTable := "vrstep"

   SELECT ( F_VRSTEP )
   IF !use_sql_sif( cTable, .T., "VRSTEP", cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()



// set_a_sql_sifarnik( "pos_strad", "STRAD", F_STRAD   )

FUNCTION o_pos_strad( cId )

   SELECT ( F_STRAD )
   use_sql_pos_strad( cId )
   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_pos_strad( cId )

   SELECT ( F_STRAD )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_pos_strad( cId )


FUNCTION use_sql_pos_strad( cId )

   LOCAL cTable := "pos_strad"
   LOCAL cAlias := "STRAD"

   SELECT ( F_STRAD )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()




FUNCTION find_pos_osob_by_naz( cNaz )

   LOCAL cTable := "pos_osob", cAlias := "OSOB"
   LOCAL cSqlQuery := "select * from fmk." + cTable

   cSqlQuery += " WHERE naz=" + sql_quote( cNaz )

   use_sql( cTable, cSqlQuery, cAlias )

   RETURN !Eof()


// set_a_sql_sifarnik( "pos_osob", "OSOB", F_OSOB   )

FUNCTION o_pos_osob( cId )

   SELECT ( F_OSOB )
   use_sql_pos_osob( cId )

   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_pos_osob( cId )

   SELECT ( F_OSOB )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_pos_osob( cId )


FUNCTION use_sql_pos_osob( cId )

   LOCAL cSql
   LOCAL cTable := "pos_osob"
   LOCAL cAlias := "OSOB"

   SELECT ( F_OSOB )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


// set_a_sql_sifarnik( "pos_kase", "KASE", F_KASE  )
/*
  pos_kase - KASE
*/

FUNCTION o_pos_kase( cId )

   SELECT ( F_KASE )
   use_sql_pos_kase( cId )
   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_pos_kase( cId )

   SELECT ( F_KASE )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_pos_kase( cId )


FUNCTION use_sql_pos_kase( cId )

   LOCAL cSql
   LOCAL cTable := "pos_kase"
   LOCAL cAlias := "KASE"

   SELECT ( F_KASE )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


// set_a_sql_sifarnik( "pos_odj", "ODJ", F_ODJ  )

/*
     pos_odj - ODJ
*/

// FUNCTION o_pos_odj()
// RETURN o_dbf_table( F_ODJ, "odj", "ID" )


FUNCTION o_pos_odj( cId )

   SELECT ( F_ODJ )
   use_sql_pos_odj( cId )
   SET ORDER TO TAG "ID"

   RETURN !Eof()


FUNCTION select_o_pos_odj( cId )

   SELECT ( F_ODJ )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_pos_odj( cId )


FUNCTION use_sql_pos_odj( cId )

   LOCAL cSql
   LOCAL cTable := "pos_odj"
   LOCAL cAlias := "ODJ"

   SELECT ( F_ODJ )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()

/*
       set_a_sql_sifarnik( "pos_odj", "ODJ", F_ODJ  )
*/
FUNCTION find_pos_odj_naziv( cIdOdj )

   LOCAL cRet, nSelect := Select()

   SELECT F_ODJ
   cRet := find_field_by_id( "pos_odj", cIdOdj, "naz" )
   SELECT ( nSelect )

   RETURN cRet





FUNCTION find_pos_osob_naziv( cId )

   LOCAL cRet, nSelect := Select()

   SELECT F_OSOB
   cRet := find_field_by_id( "pos_osob", cId, "naz" )
   SELECT ( nSelect )

   RETURN cRet



// set_a_dbf_sifarnik( "pos_kase", "KASE", F_KASE  )

FUNCTION find_pos_kasa_naz( cIdPos )

   LOCAL cRet, nSelect := Select()

   SELECT F_KASE
   cRet := find_field_by_id( "pos_kase", cIdPos, "naz" )
   SELECT ( nSelect )

   RETURN cRet


FUNCTION seek_pos_promvp( dDatDok )

   LOCAL cSql
   LOCAL cTable := "pos_promvp", cAlias := "PROMVP"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.
   LOCAL cTag := "1"

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   IF dDatDok != NIL .AND. !Empty( dDatDok )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "datum=" + sql_quote( dDatDok )
   ENDIF

   SELECT F_PROMVP
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_pos_promvp_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT

   IF cTag == NIL
      cTag := "1"
   ENDIF
   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN !Eof()


FUNCTION h_pos_promvp_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "DATUM"

   RETURN hIndexes

FUNCTION seek_pos_dokspf_by_naz( cKupac )

   // cFilter := Parsiraj( Lower( cKupac ), "lower(knaz)" )
   // SET FILTER TO &cFilter
   // SET ORDER TO TAG "2"
   // GO TOP
   RETURN seek_pos_dokspf( NIL, NIL, NIL, NIL, cKupac )


FUNCTION seek_pos_dokspf( cIdPos, cIdVd, cBrDok, dDatum, cKupac )

   LOCAL cSql
   LOCAL cTable := "pos_dokspf", cAlias := "DOKSPF"
   LOCAL hIndexes, cKey
   LOCAL lWhere := .F.
   LOCAL cTag := "1"

   cSql := "SELECT * from " + F18_PSQL_SCHEMA_DOT + cTable

   IF cKupac != NIL
      cTag := "2"
   ENDIF

   IF cIdPos != NIL .AND. !Empty( cIdPos )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idpos=" + sql_quote( cIdPos )
   ENDIF

   IF cIdVD != NIL .AND. !Empty( cIdVD )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "idvd=" + sql_quote( cIdVd )
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

   IF dDatum != NIL .AND. !Empty( dDatum )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "datum=" + sql_quote( dDatum )
   ENDIF

   IF cKupac != NIL .AND. !Empty( cKupac )
      IF lWhere
         cSql += " AND "
      ELSE
         cSql += " WHERE "
         lWhere := .T.
      ENDIF
      cSql += "knaz like " + sql_quote( Lower( Trim( cKupac ) ) + "%" )
   ENDIF

   SELECT F_DOKSPF
   use_sql( cTable, cSql, cAlias )

   hIndexes := h_pos_dokspf_indexes()

   FOR EACH cKey IN hIndexes:Keys
      INDEX ON  &( hIndexes[ cKey ] )  TAG ( cKey ) TO ( cAlias )
   NEXT


   SET ORDER TO TAG ( cTag )
   GO TOP

   RETURN !Eof()


FUNCTION h_pos_dokspf_indexes()

   LOCAL hIndexes := hb_Hash()

   hIndexes[ "1" ] := "idpos+idvd+DToS(datum)+brdok"
   hIndexes[ "2" ] := "knaz"

   RETURN hIndexes
