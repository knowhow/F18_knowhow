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

#include "fakt.ch"

FUNCTION fiskalni_racuni_za_period( cIdFirma, cIdTipDok, cBrOd, cBrDo )

   LOCAL lDirekt := .F.
   LOCAL lAutoStampa := .T.
   LOCAL _dev_id := 0
   LOCAL _dev_params
   LOCAL nTRec

   IF cIdFirma <> nil
      lDirekt := .T.
   ENDIF

   IF !lDirekt
	
      cIdFirma := gFirma
      cIdTipDok := "10"
      cBrOd := Space( 8 )
      cBrDo := Space( 8 )

      Box( "", 5, 35 )
      @ m_x + 1, m_y + 2 SAY "Dokument:"
      @ m_x + 2, m_y + 2 SAY " RJ-tip:" GET cIdFirma
      @ m_x + 2, Col() + 1 SAY "-" GET cIdTipDok
      @ m_x + 3, m_y + 2 SAY "Brojevi:"
      @ m_x + 4, m_y + 3 SAY "od" GET cBrOd VALID !Empty( cBrOd )
      @ m_x + 4, Col() + 1 SAY "do" GET cBrDo VALID !Empty( cBrDo )

      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
      ENDIF
   ENDIF

   my_close_all_dbf()

   // uzmi device iz liste uredjaja
   _dev_id := get_fiscal_device( my_user() )
   _dev_params := get_fiscal_device_params( _dev_id, my_user() )

   O_PARTN
   O_ROBA
   O_SIFK
   O_SIFV
   O_FAKT

   O_FAKT_DOKS
   SELECT fakt_doks
   SET ORDER TO TAG "1"
   hseek cIdFirma + cIdTipDok

   IF Found()
      DO WHILE !Eof() .AND. fakt_doks->idfirma == cIdFirma .AND. fakt_doks->idtipdok == cIdTipDok
		
         nTRec := RecNo()
		
         IF AllTrim( fakt_doks->brdok ) >= AllTrim( cBrOd ) .AND. AllTrim( fakt_doks->brdok ) <= AllTrim( cBrDo )
			
            nErr := fakt_fiskalni_racun( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok, lAutoStampa, _dev_params )
		
            IF ( nErr > 0 )
               MsgBeep( "Prekidam operaciju štampe radi greske!" )
               EXIT
            ENDIF
		
         ENDIF
		
         SELECT fakt_doks
         GO ( nTRec )
         SKIP
      ENDDO
   ELSE
      MsgBeep( "Traženi tip dokumenta ne postoji!" )
   ENDIF

   SELECT fakt_doks
   USE

   RETURN
