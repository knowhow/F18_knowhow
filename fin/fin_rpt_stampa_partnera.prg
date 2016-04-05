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

#include "f18.ch"

FUNCTION Rpt_StanjePartnera()

   O_PRENHH
   O_PARTN

   Box(, 5, 60 )
   cDN := "N"
   cPartner := Space( 6 )
   @ 1 + m_x, 2 + m_y SAY "Partner: " GET cPartner VALID Empty( cPartner ) .OR. P_Firma( @cPartner )
   @ 2 + m_x, 2 + m_y SAY "Prikazati samo ukupno stanje " GET cDN VALID cDN $ "DN" PICT "@!"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   SELECT prenhh
   SET ORDER TO TAG "1"
   GO TOP

   start_print_close_ret()
   IF !Empty( cPartner )
      SEEK cPartner
   ENDIF

   nUkupno := 0
   nBrojac := 0

   ? "Izvjestaj izgenerisanih podataka o stanju partnera"
   ? "na dan: ", Date()
   ?
   IF cDN == "N"
      ? "Legenda: "
      ? "         F-POCST   - pocetno stanje FIN"
      ? "         F-61-0022 - FIN nalog 61-0022 (primjer)"
   ENDIF
   ?
   ? "----------------------------------------------------------------------------------------------"
   ? "Rbr. IDPartner/Naziv                    Datum    DatVal    Dok.    Veza       Dug/Pot   Iznos "
   ? "----------------------------------------------------------------------------------------------"
   DO WHILE !Eof() .AND. if( !Empty( cPartner ), idpartner == cPartner, .T. )
      IF cDN == "N"
         IF AllTrim( field->dokument ) == "STPART"
            SKIP
            LOOP
         ENDIF
      ELSE
         IF AllTrim( field->dokument ) <> "STPART"
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT partn
      HSEEK PadR( prenhh->idpartner, 6 )
      cNazPartn := field->naz

      SELECT prenhh


      ++nBrojac

      ? Str( nBrojac, 4 ) + ". "
      ?? field->idpartner
      ?? cNazPartn
      ?? field->datum, " "
      ?? field->datval, " "
      IF cDN == "N"
         ?? field->dokument
      ELSE
         ?? Space( 10 )
      ENDIF
      ?? field->veza, Space( 3 )
      ?? field->d_p
      ?? field->iznos

      IF field->d_p == "D"
         nUkupno += field->iznos
      ELSE
         nUkupno -= field->iznos
      ENDIF

      SKIP
   ENDDO

   ?
   ? "-------------------------------------------------------------------------------------------"
   ? "UKUPNO: " + Space( 60 ), nUkupno
   ?

   FF

   end_print()

   RETURN
