#include "f18.ch"


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
