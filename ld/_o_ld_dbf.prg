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


FUNCTION o_kred()
   RETURN o_dbf_table( F_KRED, "kred", "ID" )

FUNCTION select_o_kred()
   RETURN select_o_dbf( "KRED", F_KRED, "kred", "ID" )


FUNCTION o_radn()
   RETURN o_dbf_table( F_RADN, "radn", "1" )

FUNCTION select_o_radn()
   RETURN select_o_dbf( "RADN", F_RADN, "radn", "1" )


FUNCTION open_rekld()

   RETURN o_dbf_table( F_REKLD, "rekld", "1" )


FUNCTION select_o_rekld()

   RETURN select_o_dbf( "REKLD", F_REKLD, "rekld", "1" )


FUNCTION open_ld_rj()

   RETURN o_dbf_table( F_LD_RJ, "ld_rj", "ID" )


FUNCTION select_open_ld_rj()

   RETURN select_o_dbf( "LD_RJ", F_LD_RJ, "ld_rj", "ID" )



/*
 strucne spreme
*/

FUNCTION o_str_spr()

   RETURN o_dbf_table( F_STRSPR, "strspr", "ID" )


FUNCTION select_o_str_spr()

   RETURN select_o_dbf( "STRSPR", F_STRSPR, "strspr", "ID" )
