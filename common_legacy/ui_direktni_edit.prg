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



FUNCTION DaTBDirektni( lIzOBJDB )

   LOCAL i, j, k

   IF lIzOBJDB == NIL; lIzOBJDB := .F. ; ENDIF

   IF aParametri[ 9 ] == 0
      IF !lIzOBJDB; BoxC(); ENDIF
      Box( aParametri[ 1 ], aParametri[ 2 ], aParametri[ 3 ], aParametri[ 4 ], aParametri[ 5 ] )
   ELSE
      @ m_x + aParametri[ 2 ] -aParametri[ 9 ], m_y + 1 SAY PadC( "-", aParametri[ 3 ], "-" )
   ENDIF

   IF ! ( "U" $ Type( "adImeKol" ) )
      ImeKol := adImeKol
   ENDIF
   IF ! ( "U" $ Type( "adKol" ) )
      Kol := adKol
   ENDIF

   // @ m_x,m_y+2 SAY aParametri[8]+"█UPOZORENJE: Mod direktnog unosa u tabelu!"
   @ m_x, m_y + 2 SAY aParametri[ 8 ] + IF( !lIzOBJDB, REPL( "#", 42 ), "" )
   // @ m_x+aParametri[2]+1,m_y+2 SAY aParametri[7]+"█UPOZORENJE: Mod direktnog unosa u tabelu!"
   @ m_x + aParametri[ 2 ] + 1, m_y + 2 SAY aParametri[ 7 ] COLOR "GR+/B"

   @ m_x + 1, m_y + aParametri[ 3 ] -6 SAY Str( RecCount2(), 5 )
   TB := TBrowseDB( m_x + 2 + aParametri[ 10 ], m_y + 1, m_x + aParametri[ 2 ] -aParametri[ 9 ] -iif( aParametri[ 9 ] <> 0, 1, 0 ), m_y + aParametri[ 3 ] )
   Tb:skipBlock     := TBSkipBlock
   Tb:goTopBlock    := {|| GoTopDB( @nTbLine ) }
   Tb:goBottomBlock := {|| GoBottomDB( @nTBLine ) }

   // Dodavanje kolona  za stampanje
   FOR k := 1 TO Len( Kol )
      i := AScan( Kol, k )
      IF i <> 0
         TCol := TBColumnNew( ImeKol[ i, 1 ], ImeKol[ i, 2 ] )
         IF aParametri[ 11 ] <> NIL
            TCol:colorBlock := {|| iif( Eval( aParametri[ 11 ] ), { 5, 2 }, { 1, 2 } ) }
         ENDIF
         TB:addColumn( TCol )
      END IF
   NEXT
   TB:headSep := Chr( 220 )

   // TB:colsep :=CHR(219)
   TB:colsep := BROWSE_COL_SEP

   IF aParametri[ 6 ] == NIL
      TB:Freeze := 1
   ELSE
      Tb:Freeze := aParametri[ 6 ]
   ENDIF

   RETURN .T.



STATIC FUNCTION GoBottomDB( nTBLine )

   // You are receiving a reference
   dbGoBottom()
   nTBLine := nTBLastLine

   RETURN ( NIL )



STATIC FUNCTION GoTopDB( nTBLine )

   // You are receiving a reference
   dbGoTop()
   // Since you are pointing to the first record
   // your current line should be 1
   nTBLine := 1

   RETURN ( NIL )



FUNCTION SkipDB( nRequest, nTBLine )

   // nTBLine is a reference
   LOCAL nActually := 0

   IF nRequest == 0
      dbSkip( 0 )

   ELSEIF nRequest > 0 .AND. !Eof()
      WHILE nActually < nRequest
         IF nTBLine < nTBLastLine
            // This will print up to nTBLastLine of text
            // Some of them (or even all) might be empty
            ++nTBLine

         ELSE
            // Go to the next record
            dbSkip( + 1 )
            nTBLine := 1

         ENDIF
         IF Eof()
            dbSkip( -1 )
            nTBLine := nTBLastLine
            EXIT
         ENDIF
         nActually++

      END

   ELSEIF nRequest < 0
      WHILE nActually > nRequest
         // Go to previous line
         IF nTBLine > 1
            --nTBLine

         ELSE
            dbSkip( -1 )
            IF !Bof()
               nTBLine := nTBLastLine

            ELSE
               // You need this. Believe me!
               nTBLine := 1
               GOTO RecNo()
               EXIT

            ENDIF

         ENDIF
         nActually--

      END

   ENDIF

   RETURN ( nActually )
