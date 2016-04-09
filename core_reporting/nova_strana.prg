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

MEMVAR gTS, gNFirma

FUNCTION zagl_organizacija( nLeft )

   ? " "
   ? Space( nLeft ) + AllTrim( gTS ) + " :", AllTrim( gNFirma ) + ", baza (" + my_server_params()[ "database" ] + ")"
   ? " "

   RETURN .T.



FUNCTION check_nova_strana( bZagl, oPDF, lForceBreakPage )

   LOCAL nMaxRow

   hb_default( @lForceBreakPage, .F. )

   IF ValType( oPDF ) == "O"
      nMaxRow := oPDF:MaxRow()
   ELSE
      nMaxRow := page_length()
   ENDIF

   IF lForceBreakPage .OR. PRow() > nMaxRow
      IF ValType( oPDF ) == "O"
         oPDF:DrawText( oPDF:MaxRow() + 1, 0, "" )
         oPDF:PageHeader()
      ELSE
         FF
      ENDIF
      SetPRC( 0, 0 )
      IF ( bZagl <> NIL )
         PushWa()
         Eval( bZagl )
         PopWa()
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.
