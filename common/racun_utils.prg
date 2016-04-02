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



/* ShowIznRac(nIznos)
 *     Ispisuje iznos racuna velikim slovima
 */

FUNCTION ShowIznRac( nIznos )


   LOCAL cIzn, nCnt, Char, NextY, nPrevRow := Row(), nPrevCol := Col()
   SetPos ( 0, 0 )

   Box (, 9, 77 )
   cIzn := AllTrim ( Transform ( nIznos, "9999999.99" ) )
   @ m_x, m_y + 28 SAY "  IZNOS RACUNA JE  " COLOR F18_COLOR_INVERT 
   NextY := m_y + 76
   FOR nCnt := Len ( cIzn ) TO 1 STEP -1
      Char := SubStr ( cIzn, nCnt, 1 )
      DO CASE
      CASE Char = "1"
         NextY -= 6
         @ m_x + 2, NextY SAY " ��"
         @ m_x + 3, NextY SAY "  �"
         @ m_x + 4, NextY SAY "  �"
         @ m_x + 5, NextY SAY "  �"
         @ m_x + 6, NextY SAY "  �"
         @ m_x + 7, NextY SAY "  �"
         @ m_x + 8, NextY SAY "  �"
         @ m_x + 9, NextY SAY "�����"
      CASE Char = "2"
         NextY -= 8
         @ m_x + 2, NextY SAY "�������"
         @ m_x + 3, NextY SAY "      �"
         @ m_x + 4, NextY SAY "      �"
         @ m_x + 5, NextY SAY "�������"
         @ m_x + 6, NextY SAY "�"
         @ m_x + 7, NextY SAY "�"
         @ m_x + 8, NextY SAY "�     �"
         @ m_x + 9, NextY SAY "�������"
      CASE Char = "3"
         NextY -= 8
         @ m_x + 2, NextY SAY " ������"
         @ m_x + 3, NextY SAY "      �"
         @ m_x + 4, NextY SAY "      �"
         @ m_x + 5, NextY SAY "  ����"
         @ m_x + 6, NextY SAY "      �"
         @ m_x + 7, NextY SAY "      �"
         @ m_x + 8, NextY SAY "      �"
         @ m_x + 9, NextY SAY "�������"
      CASE Char = "4"
         NextY -= 8
         @ m_x + 2, NextY SAY "�"
         @ m_x + 3, NextY SAY "�"
         @ m_x + 4, NextY SAY "�     �"
         @ m_x + 5, NextY SAY "�     �"
         @ m_x + 6, NextY SAY "�������"
         @ m_x + 7, NextY SAY "      �"
         @ m_x + 8, NextY SAY "      �"
         @ m_x + 9, NextY SAY "      �"
      CASE Char = "5"
         NextY -= 8
         @ m_x + 2, NextY SAY "�������"
         @ m_x + 3, NextY SAY "�"
         @ m_x + 4, NextY SAY "�"
         @ m_x + 5, NextY SAY "�������"
         @ m_x + 6, NextY SAY "      �"
         @ m_x + 7, NextY SAY "      �"
         @ m_x + 8, NextY SAY "�     �"
         @ m_x + 9, NextY SAY "�������"
      CASE Char = "6"
         NextY -= 8
         @ m_x + 2, NextY SAY "�������"
         @ m_x + 3, NextY SAY "�"
         @ m_x + 4, NextY SAY "�"
         @ m_x + 5, NextY SAY "�������"
         @ m_x + 6, NextY SAY "�     �"
         @ m_x + 7, NextY SAY "�     �"
         @ m_x + 8, NextY SAY "�     �"
         @ m_x + 9, NextY SAY "�������"
      CASE Char = "7"
         NextY -= 8
         @ m_x + 2, NextY SAY "�������"
         @ m_x + 3, NextY SAY "      �"
         @ m_x + 4, NextY SAY "     �"
         @ m_x + 5, NextY SAY "    �"
         @ m_x + 6, NextY SAY "   �"
         @ m_x + 7, NextY SAY "  �"
         @ m_x + 8, NextY SAY " �"
         @ m_x + 9, NextY SAY "�"
      CASE Char = "8"
         NextY -= 8
         @ m_x + 2, NextY SAY "�������"
         @ m_x + 3, NextY SAY "�     �"
         @ m_x + 4, NextY SAY "�     �"
         @ m_x + 5, NextY SAY " ����� "
         @ m_x + 6, NextY SAY "�     �"
         @ m_x + 7, NextY SAY "�     �"
         @ m_x + 8, NextY SAY "�     �"
         @ m_x + 9, NextY SAY "�������"
      CASE Char = "9"
         NextY -= 8
         @ m_x + 2, NextY SAY "�������"
         @ m_x + 3, NextY SAY "�     �"
         @ m_x + 4, NextY SAY "�     �"
         @ m_x + 5, NextY SAY "�������"
         @ m_x + 6, NextY SAY "      �"
         @ m_x + 7, NextY SAY "      �"
         @ m_x + 8, NextY SAY "�     �"
         @ m_x + 9, NextY SAY "�������"
      CASE Char = "0"
         NextY -= 8
         @ m_x + 2, NextY SAY " ����� "
         @ m_x + 3, NextY SAY "�     �"
         @ m_x + 4, NextY SAY "�     �"
         @ m_x + 5, NextY SAY "�     �"
         @ m_x + 6, NextY SAY "�     �"
         @ m_x + 7, NextY SAY "�     �"
         @ m_x + 8, NextY SAY "�     �"
         @ m_x + 9, NextY SAY " �����"
      CASE Char = "."
         NextY -= 4
         @ m_x + 9, NextY SAY "���"
      CASE Char = "-"
         NextY -= 6
         @ m_x + 5, NextY SAY "�����"
      ENDCASE
   NEXT
   SetPos ( nPrevRow, nPrevCol )

   RETURN
// }


// sekvenca za cjepanje trake
FUNCTION sjeci_traku( cSekv )

   // {
   IF Empty( cSekv )
      RETURN .F.
   ENDIF
   Setpxlat()
   IF gPrinter <> "R"
      QQOut( cSekv )
   ENDIF

   RETURN .T.
// }


// otvaranje ladice
FUNCTION otvori_ladicu( cSekv )

   // {
   IF Empty( cSekv )
      RETURN
   ENDIF
   Setpxlat()
   IF gPrinter <> "R"
      QQOut( cSekv )
   ENDIF

   RETURN .T.


// ----------------------------------------------
// zaokruzenje na 5 pf
// ----------------------------------------------
FUNCTION zaokr_5pf( nIznos )

   LOCAL nRet := 0
   LOCAL nTmp := 0

   nTmp := Round( nIznos * 2, 1 ) / 2
   nRet := ( nIznos - nTmp )

   RETURN nRet
