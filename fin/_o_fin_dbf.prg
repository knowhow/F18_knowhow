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


FUNCTION o_fin_pripr()

   RETURN o_dbf_table( F_FIN_PRIPR, "fin_pripr", "1" )

FUNCTION select_o_fin_pripr()

   select_o_dbf( "FIN_PRIPR", F_FIN_PRIPR, "fin_pripr", "1" )


FUNCTION o_nalog()
   RETURN o_dbf_table( F_NALOG, "nalog", "1" )

FUNCTION o_suban()
   RETURN o_dbf_table( F_SUBAN, "suban", "1" )

FUNCTION o_anal()
   RETURN o_dbf_table( F_ANAL, "anal", "1" )

FUNCTION o_sint()
   RETURN o_dbf_table( F_SINT, "sint", "1" )



FUNCTION o_ulimit()
   RETURN o_dbf_table( F_ULIMIT, "ulimit", "ID" )


FUNCTION o_vrnal()
   RETURN o_dbf_table( F_VRNAL, "vrnal", "1" )

FUNCTION o_relac()
   RETURN o_dbf_table( F_RELAC, "relac", "ID" )

FUNCTION o_funk()
   RETURN o_dbf_table( F_FUNK, "funk", "ID" )

FUNCTION o_fond()
   RETURN o_dbf_table( F_FOND, "fond", "ID" )


FUNCTION o_ostav()
   RETURN o_dbf_table( F_OSTAV, "ostav", "1" )
