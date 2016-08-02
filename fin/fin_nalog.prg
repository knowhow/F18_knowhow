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

STATIC s_nColIzn := 20

MEMVAR M

/*
   Štampa ažuriranog finansijskog naloga
*/

FUNCTION fin_nalog_azurirani()

   LOCAL dDatNal
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N", gnLOst := 0, gPotpis := "N"

   fin_read_params()

   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK

   cIdVN := Space( 2 )
   cIdFirma := gFirma
   cBrNal := Space( 8 )

   Box( "", 2, 35 )

   SET CURSOR ON

   @ m_x + 1, m_y + 2 SAY "Nalog:"
   @ m_x + 1, Col() + 1 SAY cIdFirma
   @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID fin_fix_broj_naloga( @cBrNal )

   READ

   ESC_BCR

   BoxC()

   find_nalog_by_broj_dokumenta( cIdFirma, cIdvn, cBrnal )
   GO TOP
   EOF CRET

   dDatNal := datnal

   find_suban_by_broj_dokumenta( cIdFirma, cIdvn, cBrnal )

   IF !start_print()
      RETURN .F.
   ENDIF

   fin_nalog_stampa_fill_psuban( "2", NIL, dDatNal )
   my_close_all_dbf()

   end_print()

   RETURN .T.


FUNCTION fin_nalog_priprema()

   my_close_all_dbf()
   fin_gen_ptabele_stampa_nalozi()

   RETURN NIL


FUNCTION formiraj_finansijski_nalog( lAuto )

   IF !f18_use_module( "fin" )
      RETURN .F.
   ENDIF

   IF ( gaFin == "D" .OR. gaMat == "D" )
      IF kalk_kontiranje_fin_naloga( .T., lAuto )
         fin_nalog_priprema_auto_import( lAuto )
      ENDIF
   ENDIF

   RETURN .T.
/*
   Koristi se u KALK za štampu finansijskog naloga
*/

FUNCTION fin_nalog_priprema_auto_import( lAuto )

   PRIVATE gDatNal := "N"
   PRIVATE gRavnot := "D"
   PRIVATE cDatVal := "D"

   IF ( lAuto == NIL )
      lAuto := .F.
   ENDIF

   IF gaFin == "D"

      fin_nalog_fix_greska_zaokruzenja( lAuto )

      IF lAuto == .F. .OR. ( lAuto == .T. .AND. gAImpPrint == "D" )
         fin_gen_ptabele_stampa_nalozi( lAuto )
      ELSE
         fin_gen_psuban_stavke_auto_import()
         fin_gen_sint_stavke_auto_import()
      ENDIF

      fin_azuriranje_naloga( lAuto )

   ENDIF

   RETURN .T.



FUNCTION fin_nalog_fix_greska_zaokruzenja( lAuto )

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

   @ m_x + 1, m_y + 2 SAY "Nalog broj: " + cIdfirma + "-" + cIdvn + "-" + cBrNal

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
         cDN := "D" // uravnoteziti nalog ako je auto import
      ENDIF

      IF cDN == "D"

         _Opis := "GRESKA ZAOKRUZ."
         _BrDok := ""
         _D_P := "2"
         _IdKonto := Space( 7 )

         IF lAuto == .F.

            @ m_x + 11, m_y + 2 SAY "Staviti na konto ?" GET _IdKonto VALID P_Konto( @_IdKonto )
            @ m_x + 11, Col() + 1 SAY "Datum dokumenta:" GET _DatDok

            READ

         ELSE

            _idkonto := kalk_auto_import_podataka_konto()

         ENDIF

         IF lAuto == .T. .OR. LastKey() <> K_ESC

            _Rbr := _Rbr + 1
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



FUNCTION fin_nalog_fix_greska_zaokruzenja_fin_pripr( cIdFirma, cIdVn, cBrNal )

   LOCAL dug := 0
   LOCAL dug2 := 0
   LOCAL Pot := 0
   LOCAL Pot2 := 0

   PushWa()

   SELECT fin_pripr

   SEEK cIdFirma + cIdVn + cBrNal

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


   IF Round( Dug - Pot, 2 ) <> 0 .AND. Pitanje(, "Zelite li uravnoteziti nalog (D/N) ?", "N" ) == "D"


      _Opis := "GRESKA ZAOKRUZ."
      _BrDok := ""
      _D_P := "2"

      _idkonto := kalk_auto_import_podataka_konto()


      _Rbr := _Rbr + 1
      _IdPartner := ""
      _IznosBHD := Dug - Pot

      nTArea := Select()

      konverzija_valute( NIL, NIL, "_IZNOSBHD" )

      SELECT ( nTArea )

      APPEND BLANK

      Gather()

   ENDIF

   PopWa()

   RETURN .T.


/*
   generisi psuban, psint, pnalog, štampaj sve naloge
*/
FUNCTION fin_gen_ptabele_stampa_nalozi( lAuto )

   LOCAL dDatNal := Date()

   IF fin_gen_psuban_stampa_nalozi( lAuto, @dDatNal )
      fin_gen_sint_stavke( lAuto, dDatNal )
   ENDIF

   RETURN .T.








/* PrenosDNal()
 *     Ispis prenos na sljedecu stranicu
 */

FUNCTION PrenosDNal()

   ? m
   ? PadR( "UKUPNO NA STRANI " + AllTrim( Str( nStr ) ), 30 ) + ":"
   @ PRow(), s_nColIzn  SAY nTSDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nTSPotBHD PICTURE picBHD
   IF fin_dvovalutno()
      @ PRow(), PCol() + 1 SAY nTSDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nTSPotDEM PICTURE picDEM
   ENDIF
   ? m
   ? PadR( "DONOS SA PRETHODNE STRANE", 30 ) + ":"
   @ PRow(), s_nColIzn  SAY nUkDugBHD - nTSDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nUkPotBHD - nTSPotBHD PICTURE picBHD
   IF fin_dvovalutno()
      @ PRow(), PCol() + 1 SAY nUkDugDEM - nTSDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM - nTSPotDEM PICTURE picDEM
   ENDIF
   ? m
   ? PadR( "PRENOS NA NAREDNU STRANU", 30 ) + ":"
   @ PRow(), s_nColIzn  SAY nUkDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD
   IF fin_dvovalutno()
      @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE picDEM
   ENDIF
   ? m
   FF
   nTSDugBHD := nTSPotBHD := nTSDugDEM := nTSPotDEM := 0   // tekuca strana

   RETURN .T.
