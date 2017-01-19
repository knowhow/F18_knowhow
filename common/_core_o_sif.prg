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

/*
FUNCTION o_konto()

   RETURN o_dbf_table( F_KONTO, "konto", "ID" )


FUNCTION select_o_konto()

   RETURN select_o_dbf( "KONTO", F_KONTO, "konto", "ID" )


FUNCTION o_partner()

   RETURN o_dbf_table( F_PARTN, "partn", "ID" )


FUNCTION select_o_partner()

   RETURN select_o_dbf( "PARTN", F_PARTN, "partn", "ID" )


FUNCTION o_roba()

   SELECT ( F_ROBA )
   my_use ( "roba" )
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_roba()

   RETURN select_o_dbf( "ROBA", F_ROBA, "roba", "ID" )
*/


FUNCTION o_roba()

   LOCAL cTabela := "roba"

   SELECT ( F_ROBA )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_roba()

   SELECT ( F_ROBA )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_roba()


FUNCTION o_partner()

   LOCAL cTabela := "partn"

   SELECT ( F_PARTN )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_partner()

   SELECT ( F_PARTN )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_partner()


FUNCTION o_konto()

   LOCAL cTabela := "konto"

   SELECT ( F_KONTO )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION select_o_konto()

   SELECT ( F_KONTO )
   IF Used()
      RETURN .T.
   ENDIF

   RETURN o_konto()


FUNCTION o_vrste_placanja()

   LOCAL cTabela := "vrstep"

   SELECT ( F_VRSTEP )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


/*

FUNCTION o_vrnal()

--   LOCAL cTabela := "vrnal"

   SELECT ( F_VRNAL )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   RETURN .T.
  */

/*
--FUNCTION o_relac()

   LOCAL cTabela := "relac"

   SELECT ( F_RELAC )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   RETURN .T.
*/


FUNCTION o_tdok()

   LOCAL cTabela := "tdok"

   SELECT ( F_TDOK )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION o_tnal()

   LOCAL cTabela := "tnal"

   SELECT ( F_TNAL )
   IF !use_sql_sif  ( cTabela )
      error_bar( "o_sql", "open sql " + cTabela )
      RETURN .F.
   ENDIF

   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_valute()

   SELECT ( F_VALUTE )
   use_sql_valute()
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_refer()

   SELECT ( F_REFER )
   use_sql_sif  ( "refer" )
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_ops()

   SELECT ( F_OPS )
   use_sql_opstine()
   SET ORDER TO TAG "ID"

   RETURN .T.



FUNCTION o_trfp()

   SELECT ( F_TRFP )
   use_sql_trfp()
   SET ORDER TO TAG "ID"

   RETURN .T.


FUNCTION o_trfp2()

   SELECT ( F_TRFP2 )
   use_sql_trfp2()
   SET ORDER TO TAG "ID"

   RETURN .T.
