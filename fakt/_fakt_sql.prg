#include "f18.ch"


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
