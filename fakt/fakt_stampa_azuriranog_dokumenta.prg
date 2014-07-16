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


FUNCTION fakt_stampa_azuriranog()

   PRIVATE cIdFirma, cIdTipDok, cBrDok

   cIdFirma := gFirma
   cIdTipDok := "10"
   cBrdok := Space( 8 )

   Box( "", 2, 35 )
   @ m_x + 1, m_y + 2 SAY "Dokument:"
   @ m_x + 2, m_y + 2 SAY " RJ-tip-broj:" GET cIdFirma
   @ m_x + 2, Col() + 1 SAY "-" GET cIdTipDok
   @ m_x + 2, Col() + 1 SAY "-" GET cBrDok
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   my_close_all_dbf()

   StampTXT( cIdFirma, cIdTipDok, cBrDok )

   SELECT F_FAKT_PRIPR
   IF Used()
      USE
   ENDIF

   RETURN


FUNCTION fakt_stampa_azuriranog_period( cIdFirma, cIdTipDok, cBrOd, cBrDo )

   LOCAL lDirekt := .F.
   LOCAL cBatch := "N"

   IF cIdFirma <> nil
      lDirekt := .T.
   ENDIF

   IF !lDirekt
	
      cIdFirma := gFirma
      cIdTipDok := "10"
      cBrOd := Space( 8 )
      cBrDo := Space( 8 )
      cBatch := "D"

      Box( "", 5, 35 )
      @ m_x + 1, m_y + 2 SAY "Dokument:"
      @ m_x + 2, m_y + 2 SAY " RJ-tip:" GET cIdFirma
      @ m_x + 2, Col() + 1 SAY "-" GET cIdTipDok
      @ m_x + 3, m_y + 2 SAY "Brojevi:"
      @ m_x + 4, m_y + 3 SAY "od" GET cBrOd VALID !Empty( cBrOd )
      @ m_x + 4, Col() + 1 SAY "do" GET cBrDo VALID !Empty( cBrDo )
      @ m_x + 5, m_y + 2 SAY "batch rezim ?" GET cBatch VALID cBatch $ "DN" ;
         PICT "@!"

      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
      ENDIF
   ENDIF

   my_close_all_dbf()

   O_FAKT_DOKS

   SET ORDER TO TAG "1"
   hseek cIdFirma + cIdTipDok

   IF Found()
      DO WHILE !Eof() .AND. fakt_doks->idfirma = cIdFirma .AND. fakt_doks->idtipdok = cIdTipDok
         nTRec := RecNo()
		
         IF AllTrim( fakt_doks->brdok ) >= AllTrim( cBrOd ) .AND. AllTrim( fakt_doks->brdok ) <= AllTrim( cBrDo )
			
            IF cBatch == "D"
               cDirPom := gcDirekt
               gcDirekt := "B"
            ENDIF
			
            StampTXT( fakt_doks->idfirma, fakt_doks->idtipdok, fakt_doks->brdok )
			
            IF cBatch == "D"
               gcDirekt := cDirPom
            ENDIF
			
         ENDIF
		
         SELECT fakt_doks
         GO ( nTRec )
         SKIP
      ENDDO
   ELSE
      MsgBeep( "Trazeni tip dokumenta ne postoji!" )
   ENDIF

   SELECT fakt_doks
   USE

   RETURN
