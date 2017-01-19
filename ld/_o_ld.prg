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


FUNCTION o_banke()

   SELECT ( F_BANKE )
   use_sql_sif  ( "banke" )
   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION o_ld_radn()

   SELECT ( F_RADN )

   IF !use_sql_sif ( "ld_radn", .T., "RADN" )
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



FUNCTION o_tprsiht()

   SELECT ( F_TPRSIHT )

   IF !use_sql_sif( "ld_tprsiht", .T., "TPRSIHT" )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION o_norsiht()

   SELECT ( F_NORSIHT )

   IF !use_sql_sif( "ld_norsiht", .T., "NORSIHT" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.



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




FUNCTION o_str_spr()

   SELECT ( F_STRSPR )

   IF !use_sql_sif ( "strspr" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION select_o_str_spr()

   SELECT ( F_STRSPR )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_str_spr()



FUNCTION o_ld_vrste_posla()

   SELECT ( F_VPOSLA )
   IF !use_sql_sif ( "vposla" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_koef_beneficiranog_radnog_staza()

   SELECT ( F_KBENEF )

   IF !use_sql_sif ( "kbenef" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_ld_parametri_obracuna()

   SELECT ( F_PAROBR )

   IF !use_sql_sif ( "ld_parobr", .T., "PAROBR" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.





FUNCTION o_tippr()

   SELECT ( F_TIPPR )

   IF !use_sql_sif ( "tippr" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION o_tippr2()

   SELECT ( F_TIPPR2 )

   IF !use_sql_sif ( "tippr2" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_tippr_ili_tippr2( cObracun )

   SELECT ( F_TIPPR )
   IF Used()
      USE
   ENDIF

   SELECT ( F_TIPPR2 )
   IF Used()
      USE
   ENDIF

   IF cObracun <> "1" .AND. !Empty( cObracun )
      SELECT ( F_TIPPR2 )
      IF !use_sql_sif ( "tippr", .T., "TIPPR2" )
         RETURN .F.
      ENDIF
   ELSE
      SELECT ( F_TIPPR )
      IF !use_sql_sif ( "tippr" )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT TIPPR
   SET ORDER TO TAG "ID"

   RETURN .T.
