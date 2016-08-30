/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

THREAD STATIC aMenuStack := {} // thread safe


MEMVAR m_x, m_y, Ch, goModul

FUNCTION f18_menu( cIzp, main_menu, izbor, opc, opcexe )

   LOCAL cOdgovor
   LOCAL nIzbor
   LOCAL _menu_opc

   IF main_menu == NIL
      main_menu := .F.
   ENDIF

   IF main_menu
      @ 4, 5 SAY ""
   ENDIF

   DO WHILE .T.
      Izbor := menu( cIzp, opc, izbor, .F. )
      nIzbor := retitem( izbor )
      DO CASE
      CASE izbor == 0
         IF main_menu
            cOdgovor := Pitanje( "", "Želite izaći iz programa ?", 'N' )
            IF cOdgovor == "D"
               EXIT
            ELSEIF cOdgovor == "L"
               Izbor := 1
               @ 4, 5 SAY ""
               LOOP
            ELSE
               Izbor := 1
               @ 4, 5 SAY ""
               LOOP
            ENDIF
         ELSE
            EXIT
         ENDIF

      OTHERWISE

         IF opcexe[ nIzbor ] <> nil

            _menu_opc := opcexe[ nIzbor ]

            IF ValType( _menu_opc ) == "B"
               Eval( _menu_opc )
            ELSE
               MsgBeep( "meni cudan ?" + hb_ValToStr( nIzbor ) )
            ENDIF

         ENDIF
      ENDCASE

   ENDDO

   RETURN




FUNCTION Menu_SC( cIzp, lMain )

   // pretpostavljamo privatne varijable Izbor, Opc, OpcExe

   RETURN f18_menu( cIzp, lMain, Izbor, Opc, Opcexe )



/*
 *
 *  Prikazuje zadati meni, vraca odabranu opciju
 *
 *  cMeniId  - identifikacija menija     C
 *  aItems   - niz opcija za izbor       {}
 *  nItemNo  - Broj pocetne pozicije     N
 *  lInvert     - da li je meni F18_COLOR_INVERT ovan  L
 *
 *  Broj izabrane opcije, 0 kraj
 *
 Privatna varijable:
  - Ch - character

*/

FUNCTION MENU( cMeniId, aItems, nItemNo, lInvert, cHelpT, nPovratak, aFixKoo, nMaxVR )

   LOCAL nLength
   LOCAL nN1
   LOCAL cOldColor
   LOCAL cLocalColor
   LOCAL cLocalInvertedColor
   LOCAL ItemSav
   LOCAL i
   LOCAL aMenu := {}
   LOCAL cPom := Set( _SET_DEVICE )
   LOCAL lFK := .F.

   SET DEVICE TO SCREEN

   IF nPovratak == NIL
      nPovratak := 0
   ENDIF
   IF nMaxVR == NIL
      nMaxVR := 16
   ENDIF
   IF aFixKoo == NIL
      aFixKoo := {}
   ENDIF
   IF Len( aFixKoo ) == 2
      lFK := .T.
   ENDIF

   nN1 := iif( Len( aItems ) > nMaxVR, nMaxVR, Len( aItems ) )
   nLength := Len( aItems[ 1 ] ) + 1

   IF lInvert == NIL
      lInvert := .F.
   ENDIF

   cLocalColor  := iif( lInvert, F18_COLOR_INVERT, F18_COLOR_NORMAL )
   cLocalInvertedColor := iif( lInvert, F18_COLOR_NORMAL, F18_COLOR_INVERT  )

   cOldColor := SetColor( cLocalColor )

   // Ako se meni zove prvi put, upisi ga na stek
   IF Len( aMenuStack ) == 0 .OR. ( Len( aMenuStack ) <> 0 .AND. cMeniId <> ( StackTop( aMenuStack ) )[ 1 ] )
      IF lFK
         m_x := aFixKoo[ 1 ]
         m_y := aFixKoo[ 2 ]
      ELSE

         Calc_xy( @m_x, @m_y, nN1, nLength ) // odredi koordinate menija
      ENDIF

      StackPush( aMenuStack, { cMeniId, ;
         m_x, ;
         m_y, ;
         SaveScreen( m_x, m_y, m_x + nN1 + 2 -IF( lFK, 1, 0 ), m_y + nLength + 4 - iif( lFK, 1, 0 ) ), ;
         nItemNo, ;
         cHelpT;
         } )

   ELSE
      aMenu := StackTop( aMenuStack ) // Ako se meni ne zove prvi put, uzmi koordinate sa steka
      m_x := aMenu[ 2 ]
      m_y := aMenu[ 3 ]

   END IF

   @ m_x, m_y CLEAR TO m_x + nN1 + 1, m_y + nLength + 3
   IF lFK
      @ m_x, m_y TO m_x + nN1 + 1, m_y + nLength + 3
   ELSE
      @ m_x, m_y TO m_x + nN1 + 1, m_y + nLength + 3 DOUBLE
      @ m_x + nN1 + 2, m_y + 1 SAY Replicate( Chr( 177 ), nLength + 4 )

      FOR i := 1 TO nN1 + 1
         @ m_x + i, m_y + nLength + 4 SAY Chr( 177 )
      NEXT

   ENDIF

   SetColor( F18_COLOR_INVERT  )
   IF nItemNo == 0
      CentrTxt( h[ 1 ], MAXROWS() -1 )
   END IF

   SetColor( cLocalColor )

   // IF Len( aItems ) > nMaxVR
   nItemNo := AChoice3( m_x + 1, m_y + 2, m_x + nN1 + 1, m_y + nLength + 1, aItems, RetItem( nItemNo ) ) // , RetItem( nItemNo )-1 )
   // ELSE
   // nItemNo := Achoice2( m_x + 1, m_y + 2, m_x + nN1 + 1, m_y + nLength + 1, aItems, .T., "MenuFunc", RetItem( nItemNo ), RetItem( nItemNo ) -1 )
   // ENDIF

   nTItemNo := RetItem( nItemNo )

   aMenu := StackTop( aMenuStack )
   m_x := aMenu[ 2 ]
   m_y := aMenu[ 3 ]
   aMenu[ 5 ] := nTItemNo

   @ m_x, m_y TO m_x + nN1 + 1, m_y + nLength + 3


   IF nTItemNo <> 0 // Ako nije pritisnuto ESC, <-, ->, oznaci izabranu opciju
      SetColor( cLocalInvertedColor )
      @ m_x + Min( nTItemNo, nMaxVR ), m_y + 1 SAY8 " " + aItems[ nTItemNo ] + " "
      @ m_x + Min( nTItemNo, nMaxVR ), m_y + 2 SAY ""
   END IF

   Ch := LastKey()


   IF Ch == K_ESC .OR. nTItemNo == 0 .OR. nTItemNo == nPovratak  // Ako je ESC meni treba odmah izbrisati (nItemNo=0),  skini meni sa steka
      @ m_x, m_y CLEAR TO m_x + nN1 + 2 - iif( lFK, 1, 0 ), m_y + nLength + 4 - iif( lFK, 1, 0 )
      aMenu := StackPop( aMenuStack )
      RestScreen( m_x, m_y, m_x + nN1 + 2 -iif( lFK, 1, 0 ), m_y + nLength + 4 - iif( lFK, 1, 0 ), aMenu[ 4 ] )
   END IF


   SetColor( cOldColor )
   Set( _SET_DEVICE, cPom )

   RETURN nItemNo


FUNCTION meni_fiksna_lokacija( nX1, nY1, aNiz, nIzb )

   LOCAL xM := 0, nYm := 0

   xM := Len( aNiz )
   AEval( aNiz, {| x| iif( Len( x ) > nYm, nYm := Len( x ), ) } )

   Prozor1( nX1, nY1, nX1 + xM + 1, nY1 + nYm + 1,,,,,, 0 )

   nIzb := Achoice3( nX1 + 1, nY1 + 1, nX1 + xM, nY1 + nYm, aNiz, nIzb )

   Prozor0()

   RETURN nIzb


FUNCTION KorMenu2

   LOCAL nVrati := 2, nTipka := LastKey()

   DO CASE
   CASE nTipka == K_ESC
      nVrati := 0
   CASE nTipka == K_ENTER
      nVrati := 1
   ENDCASE

   RETURN nVrati



FUNCTION AChoice3( nX1, nY1, nX2, nY2, aItems, nItemNo )

   LOCAL nI, nWidth, nLen, nOldCurs, cOldColor, nOldItemNo, cSavC
   LOCAL nGornja
   LOCAL nVisina
   LOCAL nCtrlKeyVal := 0
   LOCAL nChar
   LOCAL lExitFromMeni

   IF nItemNo == 0
      RETURN nItemNo
   ENDIF

   lExitFromMeni := .F.

   nOldCurs := iif( SetCursor() == 0, 0, iif( ReadInsert(), 2, 1 ) )
   cOldColor := SetColor()
   SET CURSOR OFF

   nWidth := nY2 - nY1
   nLen := Len( aItems )
   nVisina := nX2 - nX1
   nGornja := iif( nItemNo > nVisina, nItemNo - nVisina + 1, 1 )

   @ nX1, nY1 CLEAR TO nX2 - 1, nY2

   DO WHILE .T.

      IF in_calc()
         hb_idleSleep( 0.5 )
         LOOP
      ENDIF
      IF nVisina < nLen
         @   nX2, nY1 + Int( nWidth / 2 ) SAY iif( nGornja == 1, " ^ ", iif( nItemNo == nLen, " v ", " v " ) )
         @   nX1 - 1, nY1 + Int( nWidth / 2 ) SAY iif( nGornja == 1, " v ", iif( nItemNo == nLen, " ^ ", " ^ " ) )
      ENDIF

      FOR nI := nGornja TO nVisina + nGornja - 1
         IF nI == nItemNo
            IF Left( cOldColor, 3 ) == Left( F18_COLOR_NORMAL, 3 )
               SetColor( F18_COLOR_INVERT  )
            ELSE
               SetColor( F18_COLOR_NORMAL )
            ENDIF
         ELSE
            SetColor( cOldColor )
         ENDIF
         IF nLen >= nI
            @ nX1 + nI - nGornja, nY1 SAY8 PadR( aItems[ nI ], nWidth )
         ENDIF
      NEXT

      SetColor( F18_COLOR_INVERT  )
      SetColor( cOldColor )

      IF lExitFromMeni
         EXIT
      ENDIF

      nChar := Inkey( 0 )

      IF ValType( goModul ) == "O"
         goModul:GProc( nChar )
      ENDIF

      nOldItemNo := nItemNo
      DO CASE
      CASE nChar == K_ESC
         nItemNo := 0
         EXIT
      CASE nChar == K_HOME
         nItemNo := 1
      CASE nChar == K_END
         nItemNo := nLen
      CASE nChar == K_DOWN
         nItemNo++
      CASE nChar == K_UP
         nItemNo--
      CASE nChar == K_ENTER
         EXIT

      CASE IsAlpha( Chr( nChar ) ) .OR. IsDigit( Chr( nChar ) )
         FOR nI := 1 TO nLen
            IF IsDigit( Chr( nChar ) ) // cifra
               IF Chr( nChar ) $ Left( aItems[ nI ], 3 ) // provjera postojanja
                  nItemNo := nI  // broja u stavki samo u prva 3 karaktera
                  lExitFromMeni := .T.
               ENDIF
            ELSE // veliko slovo se trazi po citavom stringu - promijenjeno
               IF ( aItems[ nI ] <> NIL ) .AND. Upper( Chr( nChar ) ) $ Left( aItems[ nI ], 3 )
                  nItemNo := nI
                  lExitFromMeni := .T.
               ENDIF
            ENDIF
         NEXT

      CASE nChar == K_CTRL_N
         nCtrlKeyVal := 10000
         EXIT

      CASE nChar == K_F2
         nCtrlKeyVal := 20000
         EXIT

      CASE nChar == K_CTRL_T
         nCtrlKeyVal := 30000
         EXIT

      ENDCASE

      IF nItemNo > nLen
         nItemNo--
      ENDIF
      IF nItemNo < 1; nItemNo++; ENDIF

      nGornja := iif( nItemNo > nVisina, nItemNo - nVisina + 1, 1 )

   ENDDO

   SetCursor( iif( nOldCurs == 0, 0, iif( ReadInsert(), 2, 1 ) ) )
   SetColor( cOldColor )

   RETURN nItemNo + nCtrlKeyVal
