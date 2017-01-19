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


FUNCTION o_radn()

   SELECT ( F_RADN )

   IF !use_sql_sif ( "radn" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "1"

   RETURN .T.


FUNCTION select_o_radn()

   SELECT ( F_RADN )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_kred()


FUNCTION o_kred()

   SELECT ( F_KRED )

   IF !use_sql_sif ( "kred" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.

FUNCTION select_o_kred()

   SELECT ( F_KRED )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_kred()


FUNCTION o_ld_rj()

   SELECT ( F_LD_RJ )

   IF !use_sql_sif ( "ld_rj" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION select_open_ld_rj()

   SELECT ( F_LD_RJ )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_ld_rj()



FUNCTION o_por()

   SELECT ( F_POR )

   IF !use_sql_sif ( "por" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_dopr()

   SELECT ( F_DOPR )

   IF !use_sql_sif ( "dopr" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.




FUNCTION open_rekld()

   RETURN o_dbf_table( F_REKLD, "rekld", "1" )


FUNCTION select_o_rekld()

   RETURN select_o_dbf( "REKLD", F_REKLD, "rekld", "1" )






/*
 strucne spreme
*/

FUNCTION o_str_spr()

   RETURN o_dbf_table( F_STRSPR, "strspr", "ID" )


FUNCTION select_o_str_spr()

   RETURN select_o_dbf( "STRSPR", F_STRSPR, "strspr", "ID" )
