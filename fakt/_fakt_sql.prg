#include "f18.ch"

FUNCTION o_fakt_txt( cId )

   SELECT ( F_BANKE )
   IF !use_sql_sif  ( "fakt_ftxt", .T., "FTXT", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_fakt_txt( cId )

   SELECT ( F_FTXT )
   IF !use_sql_sif  ( "fakt_ftxt", .T., "FTXT", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN o_fakt_txt( cId )



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
