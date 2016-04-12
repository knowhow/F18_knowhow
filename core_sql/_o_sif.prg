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


FUNCTION o_sifk()

   Select( F_SIFK )
   USE

   RETURN use_sql_sifk()


FUNCTION o_koncij()

   SELECT ( F_KONCIJ )

   IF !use_sql_sif  ( "koncij" )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.




FUNCTION select_o_sifk()

   IF Select( "SIFK" ) == 0
      IF !use_sql_sifk()
         RETURN .F.
      ENDIF
   ELSE
      SELECT F_SIFK
   ENDIF

   RETURN .T.


FUNCTION select_o_sifv()

   IF Select( "SIFV" ) == 0
      IF !use_sql_sifv()
         RETURN .F.
      ENDIF
   ELSE
      SELECT F_SIFV
   ENDIF

   RETURN .T.


FUNCTION o_tarifa()

   SELECT ( F_TARIFA )
   IF !use_sql_tarifa()
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.
