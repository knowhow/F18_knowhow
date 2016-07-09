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
   LOCAL oReport, cSql
   LOCAL cIdKonto := PadR( "2110", 7 )
   LOCAL cIdPartner := SPACE(6)

   Box(, 3, 60 )
   @ m_x + 1, m_y + 2  SAY "         Konto duguje: " GET cIdKonto
   @ m_x + 2, m_y + 2  SAY "Partner% (prazno svi): " GET cIdPartner
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF
   oReport := YargReport():New( "kupci_pregled_dugovanja", "xlsx", "Header#BandSql1" )
   cSql := "select * from v_dugovanja WHERE i_ukupno<>0  and trim(konto_id)=" + sql_quote( TRIM(cIdKonto) )

   IF !empty(cIdPartner)
     cSql += "AND trim(partner_id) LIKE " + sql_quote( TRIM( cIdPartner) + "%" )
   ENDIF
   // cSql += " WHERE i_ukupno"+to_xml_encoding("<>")+"0"
   // cSql += " AND idkonto=" + to_xml_encoding(sql_quote( Padr( "2110", 7) ))
   oReport:aSql := { cSql }



/*   oReport:aRecords := {}


   FOR i := 1 TO 1000
      hRec := hb_Hash()
      hRec[ "partner_id" ] := "000" + AllTrim( Str ( i ) )
      hRec[ "partner_naz" ] := "naz " + Str( i )
      hRec[ "i_ukupno" ] := i

      AAdd( oReport:aRecords, hRec )
   NEXT
*/
   oReport:run()

   RETURN .T.
