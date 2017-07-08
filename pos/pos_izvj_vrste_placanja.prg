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


FUNCTION PrometVPl()

   o_pos_kase()
   O_PROMVP

   cIdPos := gIdPos
   dDatOd := dDatDo := gDatum

   SET CURSOR ON
   Box(, 3, 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY "Prod.mjesto    :  "  GET  cIdPos  VALID Empty( cIdPos ) .OR. P_Kase( @cIdPos ) PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Datumski period:" GET dDatOd
   @ m_x + 2, Col() + 2 SAY "-" GET dDatDo
   READ
   BoxC()

   SELECT PROMVP; GO TOP

   nIznPKM := nIznPEURO := nIznKred := nIznVirm := nIznU := nIznU2 := nIznTrosk := 0

   DO WHILE !Eof()
      IF PM == cIdPos .AND. Datum >= dDatOd .AND. Datum <= dDatDo
         nIznPKM += PROMVP->PologKM
         nIznPEURO += PROMVP->PologEU
         nIznKred += PROMVP->Krediti
         nIznVirm += PROMVP->Virmani
         nIznTrosk += PROMVP->Trosk
         nIznU2 += PROMVP->Ukupno2
         SKIP
      ELSE
         SKIP
      ENDIF
   ENDDO

   cLm := Space( 5 )

   // -- stampaj izvjestaj
   START PRINT CRET

   ZagFirma()

   IF gVrstaRS == "S"
      P_INI  ; P_10CPI
   ENDIF

   ? "PREGLED PROMETA PO VRSTI PLACANJA NA DAN " + DToC( gDatum )
   ? "-------------------------------------------------"
   ?
   IF Empty( cIdPos )
      ? "Prodajno mjesto: SVI"
   ELSE
      ? "Prodajno mjesto: " + cIdPos
   ENDIF
   ? "PERIOD         : " + DToC( dDatOd ) + " - " + DToC( dDatDo )
   ? "-------------------------------------------"
   ?
   ? cLm + "Polog KM    : " + Str( nIznPKM )
   ? cLm + "Polog EURO  : " + Str( nIznPEURO )
   ? cLm + "Krediti     : " + Str( nIznKred )
   ? cLm + "Virmani     : " + Str( nIznVirm )
   ? cLm + "Troskovi    : " + Str( nIznTrosk )
   ? cLm + "------------------------------------"
   ? cLm + "UKUPNO      : " + Str( nIznU2 )
   ? cLm + "------------------------------------"

   ENDPRINT
   CLOSERET
   // }
