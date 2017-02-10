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


FUNCTION o_sifv()

   Select( F_SIFV )
   USE

   RETURN use_sql_sifv()


FUNCTION select_o_sifv()

   SELECT ( F_SIFV )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_sifv()

/*
   CREATE TABLE fmk.koncij
   (
     id character(7),
     match_code character(10),
     shema character(1),
     naz character(2),
     idprodmjes character(2),
     region character(2),
     sufiks character(3),
     kk1 character(7),
     kk2 character(7),
     kk3 character(7),
     kk4 character(7),
     kk5 character(7),
     kk6 character(7),
     kk7 character(7),
     kk8 character(7),
     kk9 character(7),
     kp1 character(7),
     kp2 character(7),
     kp3 character(7),
     kp4 character(7),
     kp5 character(7),
     kp6 character(7),
     kp7 character(7),
     kp8 character(7),
     kp9 character(7),
     kpa character(7),
     kpb character(7),
     kpc character(7),
     kpd character(7),
     ko1 character(7),
     ko2 character(7),
     ko3 character(7),
     ko4 character(7),
     ko5 character(7),
     ko6 character(7),
     ko7 character(7),
     ko8 character(7),
     ko9 character(7),
     koa character(7),
     kob character(7),
     koc character(7),
     kod character(7)
   )
*/



FUNCTION select_o_koncij( cId )

   SELECT ( F_KONCIJ )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_koncij( cId )


FUNCTION o_koncij( cId )

   SELECT ( F_KONCIJ )
   IF !use_sql_sif  ( "koncij", .T., "KONCIJ", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.



FUNCTION select_o_tarifa( cId )

   SELECT ( F_TARIFA )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_tarifa( cId )


FUNCTION o_tarifa( cId )

   SELECT ( F_TARIFA )
   IF !use_sql_sif  ( "tarifa", .T., "TARIFA", cId )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN .T.
