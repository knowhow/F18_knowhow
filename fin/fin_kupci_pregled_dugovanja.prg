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



FUNCTION fin_kupci_pregled_dugovanja()

   LOCAL i
   LOCAL oReport, hRec

   oReport := YargReport():New( "kupci_pregled_dugovanja", "xlsx", "Header#Band1" )
   oReport:aRecords := {}


   FOR i := 1 TO 1000
      hRec := hb_Hash()
      hRec[ "partner_id" ] := "000" + AllTrim( Str ( i ) )
      hRec[ "partner_naz" ] := "naz " + Str( i )
      hRec[ "i_ukupno" ] := i

      AAdd( oReport:aRecords, hRec )
   NEXT
   oReport:run()

   RETURN .T.
