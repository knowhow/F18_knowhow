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



FUNCTION kontiranje_vise_dokumenata_period()

   LOCAL dD_f := Date() -30
   LOCAL dD_t := Date()
   LOCAL cId_td := PadR( "14;", 100 )
   LOCAL cId_mkto := PadR( "", 100 )
   LOCAL cId_pkto := PadR( "", 100 )
   LOCAL cChBrNal := "N"


   Box( , 5, 65 )

   @ m_x + 1, m_y + 2 SAY "Datum od:" GET dD_f
   @ m_x + 1, Col() + 1 SAY "do:" GET dD_t

   @ m_x + 2, m_y + 2 SAY "tipovi dok. (prazno-svi):" GET cId_td ;
      PICT "@S20"

   @ m_x + 3, m_y + 2 SAY "mag.konta (prazno-sva):" GET cId_mkto ;
      PICT "@S20"
   @ m_x + 4, m_y + 2 SAY " pr.konta (prazno-sva):" GET cId_pkto ;
      PICT "@S20"

   @ m_x + 5, m_y + 2 SAY "koriguj broj naloga (D/N)" GET cChBrNal ;
      PICT "@!" VALID cChBrNal $ "DN"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   kont_dokumente( dD_f, dD_t, cId_td, cId_mkto, cId_pkto, cChBrNal )

   RETURN .T.


STATIC FUNCTION kont_dokumente( dD_f, dD_t, cId_td, cId_mkto, cId_pkto, cChBrNal )

   LOCAL nCount := 0
   LOCAL nTNRec
   LOCAL cNalog := ""


   find_kalk_doks_by_tip_datum( gFirma, cId_td, dD_f, dD_t )

   cId_td := AllTrim( cId_td )
   cId_mkto := AllTrim( cId_mkto )
   cId_pkto := AllTrim( cId_pkto )

   GO TOP

   DO WHILE !Eof()

      IF ( field->datdok < dD_f .OR. field->datdok > dD_t )
         SKIP
         LOOP
      ENDIF

      IF !Empty( cId_td )
         IF field->idvd $ cId_td
            // idi dalje...
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      // provjeri magacinska konta
      IF !Empty( cId_mkto )
         IF AllTrim( field->mkonto ) $ cId_mkto
            // idi dalje...
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF


      IF !Empty( cId_pkto ) // provjeri prodavnicka konta
         IF AllTrim( field->pkonto ) $ cId_pkto
            // idi dalje...
         ELSE
            SKIP
            LOOP
         ENDIF
      ENDIF

      nTNRec := RecNo()
      cD_firma := field->idfirma
      cD_tipd := field->idvd
      cD_brdok := field->brdok


      kalk_generisi_finmat( .T., cD_firma, cD_tipd, cD_brdok, .T. )  // napuni FINMAT


      kalk_kontiranje_naloga( .T., .T., .F., NIL, .F. ) // kontiraj

      ++ nCount

      SELECT kalk_doks
      GO ( nTNRec )
      SKIP

   ENDDO

   IF nCount > 0
      MsgBeep( "Kontirao " + AllTrim( Str( nCount ) ) + " dokumenata !" )
   ENDIF

   RETURN .T.
