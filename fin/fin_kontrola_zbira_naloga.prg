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

FUNCTION kontrola_zbira_naloga()

   PushWA()

   SELECT ( F_FIN_PRIPR )
   IF !Used()
      O_FIN_PRIPR
   ENDIF

   Box( "kzb", 12, 70, .F., "Kontrola zbira naloga" )

   SET CURSOR ON

   cIdFirma := IdFirma
   cIdVN := IdVN
   cBrNal := BrNal

   @ m_x + 1, m_y + 1 SAY "       Firma: " + cIDFirma
   @ m_x + 2, m_y + 1 SAY "Vrsta naloga:" GET cIdVn VALID browse_tnal( @cIdVN, 2, 20 )
   @ m_x + 3, m_y + 1 SAY " Broj naloga:" GET cBrNal

   READ

   IF LastKey() == K_ESC
      BoxC()
      PopWA()
      RETURN DE_CONT
   ENDIF

   SET CURSOR OFF
   cIdFirma := Left( cIdFirma, 2 )


   SET ORDER TO TAG "1"
   SEEK cIdFirma + cIdVn + cBrNal
   IF !( IdFirma + IdVn + BrNal == cIdFirma + cIdVn + cBrNal )
      Msg( "Ovaj nalog nije unesen ...", 10 )
      BoxC()
      PopWa()
      RETURN DE_CONT
   ENDIF

   dug := dug2 := Pot := Pot2 := 0
   DO WHILE  !Eof() .AND. ( IdFirma + IdVn + BrNal == cIdFirma + cIdVn + cBrNal )
      IF D_P == "1"
         dug  += IznosBHD
         dug2 += iznosdem
      ELSE
         pot  += IznosBHD
         pot2 += iznosdem
      ENDIF
      SKIP
   ENDDO
   SKIP -1

   Scatter()

   cPic := FormPicL( "9 " + gPicBHD, 20 )

   @ m_x + 5, m_y + 2 SAY "Zbir naloga:"
   @ m_x + 6, m_y + 2 SAY "     Duguje:"
   @ m_x + 6, Col() + 2 SAY Dug PICTURE cPic
   @ m_x + 6, Col() + 2 SAY Dug2 PICTURE cPic
   @ m_x + 7, m_y + 2 SAY "  Potrazuje:"
   @ m_x + 7, Col() + 2 SAY Pot  PICTURE cPic
   @ m_x + 7, Col() + 2 SAY Pot2  PICTURE cPic
   @ m_x + 8, m_y + 2 SAY "      Saldo:"
   @ m_x + 8, Col() + 2 SAY Dug - Pot  PICTURE cPic
   @ m_x + 8, Col() + 2 SAY Dug2 - Pot2  PICTURE cPic
   Inkey( 0 )


   IF Round( Dug - Pot, 2 ) <> 0  .AND. gRavnot == "D"

      cDN := "N"
      SET CURSOR ON
      @ m_x + 10, m_y + 2 SAY8 "Želite li uravnoteziti nalog (D/N) ?" GET cDN valid ( cDN $ "DN" ) PICT "@!"
      READ

      IF cDN == "D"

         _Opis := PadR( "?", Len( _opis ) )
         _BrDok := ""
         _D_P := "2"
         _IdKonto := Space( 7 )

         @ m_x + 11, m_y + 2 SAY "Opis" GET _opis  PICT "@S40"
         @ m_x + 12, m_y + 2 SAY "Staviti na konto ?" GET _IdKonto VALID P_Konto( @_IdKonto )
         @ m_x + 12, Col() + 1 SAY "Datum dokumenta:" GET _DatDok
         READ

         IF LastKey() <> K_ESC
            _Rbr := Str( Val( _Rbr ) + 1, 4 )
            _IdPartner := ""
            _IznosBHD := Dug - Pot
            konverzija_valute( NIL, NIL, "_IZNOSBHD" )
            APPEND BLANK
            my_rlock()
            Gather()
            my_unlock()
         ENDIF

      ENDIF

   ENDIF
   BoxC()

   PopWA()

   RETURN .T.


FUNCTION kontrola_zbira_naloga_kalk( lAuto )

   O_KONTO
   O_VALUTE
   O_FIN_PRIPR

   IF lAuto == nil
      lAuto := .F.
   ENDIF

   Box( "kzb", 12, 70, .F., "Kontrola zbira FIN naloga" )

   SET CURSOR ON

   cIdFirma := IdFirma
   cIdVN := IdVN
   cBrNal := BrNal

   @ m_x + 1, m_y + 2 SAY "Nalog broj: " + cidfirma + "-" + cidvn + "-" + cBrNal

   SET ORDER TO TAG "1"
   SEEK cIdFirma + cIdVn + cBrNal

   PRIVATE dug := 0
   PRIVATE dug2 := 0
   PRIVATE Pot := 0
   PRIVATE Pot2 := 0


   DO WHILE  !Eof() .AND. ( IdFirma + IdVn + BrNal == cIdFirma + cIdVn + cBrNal )

      IF D_P == "1"
         dug += IznosBHD
         dug2 += iznosdem
      ELSE
         pot += IznosBHD
         pot2 += iznosdem
      ENDIF

      SKIP
   ENDDO

   SKIP -1

   Scatter()

   cPic := "999 999 999 999.99"

   @ m_x + 5, m_y + 2 SAY "Zbir naloga:"
   @ m_x + 6, m_y + 2 SAY "     Duguje:"
   @ m_x + 6, Col() + 2 SAY Dug PICTURE cPic
   @ m_x + 6, Col() + 2 SAY Dug2 PICTURE cPic
   @ m_x + 7, m_y + 2 SAY "  Potrazuje:"
   @ m_x + 7, Col() + 2 SAY Pot  PICTURE cPic
   @ m_x + 7, Col() + 2 SAY Pot2  PICTURE cPic
   @ m_x + 8, m_y + 2 SAY "      Saldo:"
   @ m_x + 8, Col() + 2 SAY Dug - Pot  PICTURE cPic
   @ m_x + 8, Col() + 2 SAY Dug2 - Pot2  PICTURE cPic

   IF Round( Dug - Pot, 2 ) <> 0

      PRIVATE cDN := "D"

      IF lAuto == .F.

         SET CURSOR ON

         @ m_x + 10, m_y + 2 SAY "Zelite li uravnoteziti nalog (D/N) ?" GET cDN valid ( cDN $ "DN" ) PICT "@!"

         READ

      ELSE
         // uravnoteziti nalog ako je auto import
         cDN := "D"
      ENDIF

      IF cDN == "D"

         _Opis := "GRESKA ZAOKRUZ."
         _BrDok := ""
         _D_P := "2"
         _IdKonto := Space( 7 )

         IF lAuto == .F.

            @ m_x + 11, m_y + 2 SAY "Staviti na konto ?" ;
               GET _IdKonto VALID P_Konto( @_IdKonto )
            @ m_x + 11, Col() + 1 SAY "Datum dokumenta:" GET _DatDok

            READ

         ELSE

            _idkonto := gAImpRKonto

            IF Empty( _idkonto )
               _idkonto := "1370   "
            ENDIF

         ENDIF

         IF lAuto == .T. .OR. LastKey() <> K_ESC

            _Rbr := Str( Val( _Rbr ) + 1, 4 )
            _IdPartner := ""
            _IznosBHD := Dug - Pot

            nTArea := Select()

            konverzija_valute( NIL, NIL, "_IZNOSBHD" )

            SELECT ( nTArea )

            APPEND BLANK

            Gather()

         ENDIF
      ENDIF
   ENDIF
   BoxC()

   my_close_all_dbf()

   RETURN .T.
