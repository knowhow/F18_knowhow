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

// ---------------------------------------
// prikaz informacije na izvjestaju
// ---------------------------------------
FUNCTION __rpt_info( nLeft )

   LOCAL cDesc := ""

   IF nLeft == nil
      nLeft := PCol() + 1
   ENDIF

   cDesc := "na dan: " + DToC( danasnji_datum() )
   cDesc += " "
   cDesc += "oper: " + f18_user()

   @ PRow(), nLeft SAY cDesc

   RETURN .T.



// ----------------------------------------------
// standardni uslovi izvjestaja
// ----------------------------------------------
FUNCTION std_vars( dD_f, dD_t, nOper, cStatus, cExport )

   dD_t := danasnji_datum()
   dD_f := ( dD_t - 30 )
   nOper := 0
   cStatus := "S"
   cExport := "N"

   Box(, 6, 60 )

   @ m_x + 1, m_y + 2 SAY "Datum od:" GET dD_f

   @ m_x + 1, Col() + 1 SAY "do:" GET dD_t

   @ m_x + 2, m_y + 2 SAY "Operater (0 - svi):" GET nOper ;
      VALID {|| nOper == 0, iif( nOper == -99, choose_f18_user_from_list( @nOper ), .T. ) } ;
      PICT "9999999999"

   @ m_x + 3, m_y + 2 SAY "(O)tvoreni / (Z)atvoreni / (S)vi" GET cStatus ;
      VALID cStatus $ "OZS" PICT "@!"

   @ m_x + 5, m_y + 2 SAY "Export izvjestaja (D/N)?" GET cExport VALID cExport $ "DN" PICT "@!"

   READ

   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   RETURN 1
