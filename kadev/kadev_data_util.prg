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


#include "kadev.ch"


// --------------------------------------------------------
// da li za postojeci id postoje promjene
// --------------------------------------------------------
FUNCTION kadev_broj_promjena( id )

   LOCAL _ok := .F.
   LOCAL _server := pg_server()
   LOCAL _qry
   LOCAL _res

   _qry := "SELECT COUNT(*) FROM fmk.kadev_promj WHERE id = " + sql_quote( id )

   _res := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _res )
      RETURN 0
   ENDIF

   RETURN _res:FieldGet( 1 )




// --------------------------------------------------------
// da li za postojeci id postoje promjene
// --------------------------------------------------------
FUNCTION kadev_broj_podataka( id )

   LOCAL _server := pg_server()
   LOCAL _qry
   LOCAL _res

   _qry := "SELECT COUNT(*) FROM fmk.kadev_1 WHERE id = " + sql_quote( id )

   _res := _sql_query( _server, _qry )

   IF sql_query_bez_zapisa( _res )
      RETURN 0
   ENDIF

   RETURN _res:FieldGet( 1 )
