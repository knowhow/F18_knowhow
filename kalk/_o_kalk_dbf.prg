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



FUNCTION o_kalk_imp_temp()

   RETURN o_dbf_table( F_KALK_IMP_TEMP, "kalk_imp_temp", NIL )


FUNCTION o_kalk_pript()
   RETURN o_dbf_table( F_PRIPT, { "PRIPT", "kalk_pript" }, "1" )


FUNCTION select_o_kalk_pript()
   RETURN select_o_dbf( "PRIPT", F_PRIPT, { "PRIPT", "kalk_pript" }, "1" )


FUNCTION select_o_kalk_as_pripr()
   RETURN select_o_dbf( "KALK_PRIPR", F_KALK_PRIPR, { "KALK_PRIPR", "kalk_kalk" }, "1" )


FUNCTION open_kalk_as_pripr( lSql, cIdFirma, cIdVd, cBrDok )

   hb_default( @lSql, .F. )

   IF lSql
      RETURN kalk_otvori_kumulativ_kao_pripremu( cIdFirma, cIdVd, cBrDok )
   ENDIF

   RETURN o_dbf_table( F_KALK_PRIPR, { "KALK_PRIPR", "kalk_kalk" }, "1" )


FUNCTION o_kalk_pripr()

   RETURN o_dbf_table( F_KALK_PRIPR, "kalk_pripr", "1" )


FUNCTION select_o_kalk_pripr()

   RETURN select_o_dbf( "KALK_PRIPR", F_KALK_PRIPR, "kalk_pripr", "1" )


FUNCTION o_kalk_report()

   RETURN o_dbf_table( F_KALK, "kalk", "1" )
