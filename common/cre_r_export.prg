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

STATIC s_cExportDbf := "r_export"


FUNCTION create_dbf_r_export( aFieldList, lCloseDbfs )

   LOCAL cImeDbf, cImeCdx

   hb_default( @lCloseDbfs, .F. )

   IF lCloseDbfs
      my_close_all_dbf()
   ENDIF

   cImeDBf := f18_ime_dbf( "r_export" )
   cImeCdx := ImeDbfCdx( cImeDbf )

   FErase( cImeDbf )
   FErase( cImeCdx )
   IF File( cImeDbf )
      ?E "Ne mogu obrisati", cImeDbf
   ENDIF
   DbCreate2( cImeDbf, aFieldList )

   IF !File( cImeDbf )
      ?E "Ne mogu kreirati", cImeDbf
      RaiseError( "dbcreate2 " + cImeDbf + " " + pp( aFieldList ) )
      RETURN .F.
   ENDIF

   RETURN .T.


FUNCTION open_r_export_table()

   LOCAL _cmd

   my_close_all_dbf()

   _cmd := s_cExportDbf + ".dbf"

   log_write( "Export " + s_cExportDbf + " cmd: " + _cmd, 9 )

   DirChange( my_home() )
   IF f18_run( _cmd ) <> 0
      MsgBeep( "Problem sa pokretanjem ?!" )
   ENDIF

   RETURN .T.
