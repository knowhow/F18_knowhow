
#include "f18.ch"

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

   LOCAL cSql
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
