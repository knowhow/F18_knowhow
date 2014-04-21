/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

FUNCTION fin_stampa_analiticki_nalog()

   PRIVATE fK1 := fk2 := fk3 := fk4 := "N", gnLOst := 0, gPotpis := "N"
   PRIVATE dDatNal := Date()

   fin_read_params()

   O_NALOG
   O_SUBAN
   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK

   SELECT SUBAN
   SET ORDER TO TAG "4"

   cIdVN := SPACE( 2 )
   cIdFirma := gFirma
   cBrNal := SPACE( 8 )

   Box( "", 2, 35 )

   SET CURSOR ON

   @ m_x + 1, m_y + 2 SAY "Nalog:"
   @ m_x + 1, Col() + 1 SAY cIdFirma
   @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID _f_brnal( @cBrNal )

   IF gDatNal == "D"
      @ m_x + 2, m_y + 2 SAY "Datum naloga:" GET dDatNal
   ENDIF

   READ

   ESC_BCR

   BoxC()

   SELECT nalog
   SEEK cidfirma + cidvn + cbrnal

   NFOUND CRET
   dDatNal := datnal

   SELECT SUBAN
   SEEK cIdfirma + cIdvn + cBrNal

   START PRINT CRET

   fin_subanaliticki_nalog( "2" )

   END PRINT

   closeret

   RETURN

