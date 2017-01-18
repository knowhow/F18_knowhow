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

FUNCTION o_koncij()

   SELECT ( F_KONCIJ )

   IF !use_sql_sif ( "koncij" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_koncij()

   LOCAL lRet := .T.

   IF Select( "KONCIJ" ) == 0 // nije otvoren, otvori
      lRet := o_koncij()
   ENDIF

   Select( F_KONCIJ )

   RETURN lRet


FUNCTION o_tarifa()

   SELECT ( F_TARIFA )
   IF !use_sql_tarifa()
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_tarifa()

   SELECT F_TARIFA
   IF !Used()
      RETURN o_tarifa()
   ENDIF

   RETURN .T.


FUNCTION select_o_roba()

   RETURN select_o_dbf( "ROBA", F_ROBA, "roba", "ID" )
