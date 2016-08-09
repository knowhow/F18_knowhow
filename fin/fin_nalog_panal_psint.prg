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


/*
   Generiše psuban, pa štampa sve naloge
*/

FUNCTION fin_gen_psuban_stampa_nalozi( lAuto, dDatNal )

   LOCAL oNalog, oNalozi := FinNalozi():New()

   PRIVATE aNalozi := {}

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

#ifdef F18_DEBUG_FIN_AZUR
   AltD() // F18_DEBUG_FIN_AZUR
#endif

   fin_open_psuban_and_ostalo()

   SELECT PSUBAN
   my_dbf_zap()

   SELECT fin_pripr
   SET ORDER TO TAG "1"

   GO TOP

   EOF CRET .F.

   IF lAuto
      // _print_opt := "D"
      Box(, 3, 75 )
      @ m_x + 0, m_y + 2 SAY8 "Formiranje sintetičkih i analitičkih stavki"
   ENDIF

   DO WHILE !Eof()

      cIdFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal

      IF !lAuto
         IF !box_fin_nalog( @cIdFirma, @cIdVn, @cBrNal, @dDatNal )
            RETURN .F.
         ENDIF
      ENDIF

      HSEEK cIdFirma + cIdVN + cBrNal
      IF Eof()
         my_close_all_dbf()
         RETURN .F.
      ENDIF

      IF !lAuto
         IF !start_print()
            my_close_all_dbf()
            RETURN .F.
         ENDIF
      ENDIF

      oNalog := FinNalog():New( cIdFirma, cIdVn, cBrNal )

      fin_nalog_fix_greska_zaokruzenja_fin_pripr( cIdFirma, cIdVn, cBrNal, .F. )

      fin_nalog_stampa_fill_psuban( "1", lAuto, dDatNal, @oNalog )
      
      oNalozi:addNalog( oNalog )

      IF !lAuto
         PushWA()
         my_close_all_dbf()
         end_print()
         fin_open_psuban_and_ostalo()
         PopWa()
      ENDIF


      IF AScan( aNalozi, cIdFirma + cIdVN + cBrNal ) == 0

         AAdd( aNalozi, cIdFirma + cIdVN + cBrNal ) // lista naloga koji su otisli
         IF lAuto
            @ m_x + 2, m_y + 2 SAY "Formirana sintetika i analitika za nalog:" + cIdFirma + "-" + cIdVN + "-" + cBrNal
         ENDIF
      ENDIF

   ENDDO

   IF lAuto
      BoxC()
   ENDIF

   my_close_all_dbf()

   IF !oNalozi:valid()
      oNalozi:showErrors()
   ENDIF

   RETURN .T.




FUNCTION fin_gen_sint_stavke( lAuto, dDatNal )

   LOCAL A, cDN := "N"
   LOCAL nStr, nD1, nD2, nP1, nP2
   LOCAL cIdFirma, cIDVn, cBrNal
   LOCAL nDugBHD, nDugDEM, nPotBHD, nPotDEM
   LOCAL nRbr

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   IF !fin_open_lock_panal( .T. )
      RETURN .F.
   ENDIF

   SELECT PSUBAN
   SET ORDER TO TAG "2"
   GO TOP
   IF Empty( PSUBAN->BrNal )
      MsgBeep( "subanalitika prazna" )
      my_close_all_dbf()
      RETURN .F.
   ENDIF

   A := 0
   DO WHILE !Eof()

      cIdFirma := psuban->IdFirma
      cIDVn = psuban->IdVN
      cBrNal := psuban->BrNal

      fin_gen_panal_psint( cIdFirma, cIdVn, cBrNal, dDatNal )

      IF !lAuto
         Box(, 2, 58 )
         @ m_x + 1, m_y + 2 SAY8 "Štampanje analitike/sintetike za nalog " + cIdfirma + "-" + cIdvn + "-" + cBrnal + " ?"  GET cDN PICT "@!" VALID cDN $ "DN"
         READ
         BoxC()
      ENDIF

      SELECT PSUBAN
      PushWA()

      IF cDN == "D"
         SELECT PANAL
         SEEK cIdfirma + cIdvn + cBrnal
         fin_sinteticki_nalog( .F. )
      ENDIF

      my_close_all_dbf()
      fin_open_lock_panal( .F. )

      PopWa()

   ENDDO

   SELECT PANAL
   my_flock()

   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma
      cIDVn = IdVN
      cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   SELECT PSINT
   my_flock()

   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma
      cIDVn = IdVN
      cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   my_close_all_dbf()

   RETURN .T.
