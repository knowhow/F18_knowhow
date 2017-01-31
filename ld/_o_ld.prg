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

STATIC s_cObracun := " "  // obracun 1 ili 2, ili " "

FUNCTION o_ld()

   SELECT ( F_LD )
   my_use ( "ld" )
   SET ORDER TO TAG "1"

   RETURN .T.



FUNCTION select_o_ld()
   RETURN  select_o_dbf( "LD", F_LD, "ld_ld", "1" )



FUNCTION o_banke( cId )

   SELECT ( F_BANKE )
   use_sql_sif  ( "banke", .T., "BANKE", cId )
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION o_ld_radn( cId )

   SELECT ( F_RADN )

   IF !use_sql_sif ( "ld_radn", .T., "RADN", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "1"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.

FUNCTION o_radn( cId )
   RETURN o_ld_radn( cId )


FUNCTION select_o_ld_radn( cId )

   SELECT ( F_RADN )

   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   RETURN o_ld_radn( cId )


FUNCTION select_o_radn( cID )
   RETURN select_o_ld_radn( cId )




FUNCTION o_tprsiht( cId )

   SELECT ( F_TPRSIHT )

   IF !use_sql_sif( "ld_tprsiht", .T., "TPRSIHT", cId )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION o_norsiht( cId )

   SELECT ( F_NORSIHT )

   IF !use_sql_sif( "ld_norsiht", .T., "NORSIHT", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION o_kred( cId )

   SELECT ( F_KRED )

   IF !use_sql_sif ( "kred", .T., "KRED", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_kred( cId )

   SELECT ( F_KRED )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   RETURN o_kred( cId )



FUNCTION o_ld_rj( cId )

   SELECT ( F_LD_RJ )

   IF !use_sql_sif ( "ld_rj", .T., "LD_RJ", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_ld_rj( cId )

   SELECT ( F_LD_RJ )

   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   RETURN o_ld_rj( cId )


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



FUNCTION o_str_spr( cId )

   SELECT ( F_STRSPR )

   IF !use_sql_sif ( "strspr", .T., "STRSPR", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION select_o_str_spr( cId )

   SELECT ( F_STRSPR )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   RETURN o_str_spr( cId )


FUNCTION o_ld_vrste_posla( cId )

   SELECT ( F_VPOSLA )
   IF !use_sql_sif ( "vposla", .T., "VPOSLA", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION o_vposla( cId )
   RETURN o_ld_vrste_posla( cId )


FUNCTION select_o_vposla( cId )

   SELECT ( F_VPOSLA )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   RETURN o_vposla( cId )




FUNCTION o_koef_beneficiranog_radnog_staza( cId )

   SELECT ( F_KBENEF )

   IF !use_sql_sif ( "kbenef", .T., "KBENEF", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION o_kbenef( cId )
   RETURN o_koef_beneficiranog_radnog_staza( cId )


FUNCTION select_o_kbenef( cId )

   SELECT ( F_KBENEF )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   RETURN o_kbenef( cId )



FUNCTION o_ld_parametri_obracuna()

   SELECT ( F_PAROBR )

   IF !use_sql_sif ( "ld_parobr", .T., "PAROBR" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.





FUNCTION o_tippr( cId )

   SELECT ( F_TIPPR )

   IF !use_sql_sif ( "tippr", .T., "TIPPR", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION select_o_tippr( cId )

   SELECT ( F_TIPPR )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE
      ENDIF
   ENDIF

   IF s_cObracun <> "1" .AND. !Empty( s_cObracun )
      RETURN o_tippr2( cId, "TIPPR" )
   ENDIF

   RETURN o_tippr( cId )



FUNCTION o_tippr2( cId, cAlias )

   IF cAlias == NIL
      cAlias := "TIPPR2"
   ENDIF

   IF cAlias == "TIPPR2"
      SELECT ( F_TIPPR2 )
   ELSE
      SELECT ( F_TIPPR )
   ENDIF

   IF !use_sql_sif ( "tippr2", .T., cAlias, cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"
   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.


FUNCTION set_tippr_ili_tippr2( cObracun )

   s_cObracun := cObracun
/*
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
      IF !use_sql_sif ( "tippr2", .T., "TIPPR" )
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
*/

   RETURN .T.
