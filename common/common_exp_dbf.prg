/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"
STATIC __table := "r_export"


FUNCTION t_exp_create( field_list )

   my_close_all_dbf()
   FErase( my_home() + __table + ".dbf" )
   dbcreate2( my_home() + __table, field_list )

   RETURN


FUNCTION tbl_export()

   LOCAL _cmd

   my_close_all_dbf()

   _cmd := __table + ".dbf"

   log_write( "Export " + __table + " cmd: " + _cmd, 9 )

   DirChange( my_home() )
   IF f18_run( _cmd ) <> 0
      MsgBeep( "Problem sa pokretanjem ?!!!" )
   ENDIF

   RETURN
