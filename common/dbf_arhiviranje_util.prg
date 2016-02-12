/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"



FUNCTION IscitajCRC( cFajl )

   LOCAL cPom

   IF cFajl == NIL
      cFajl := "CRC.CRC"
   ENDIF
   cPom := FILESTR( cFajl, 22 )

   RETURN { Val( Left( cPom, 10 ) ), Val( Right( cPom, 10 ) ) }



FUNCTION NapraviCRC( cFajl, n1, n2 )

   LOCAL nH := 0

   IF cFajl == NIL; cFajl := "CRC.CRC"; ENDIF
   IF File( cFajl )
      FErase( cFajl )
   ENDIF
   nH := FCreate( cFajl, 0 )
   FWrite( nH, Str( n1, 10 ) )
   FWrite( nH, Chr( 13 ) + Chr( 10 ) )
   FWrite( nH, Str( n2, 10 ) )
   FWrite( nH, Chr( 13 ) + Chr( 10 ) )
   FClose( nH )

   RETURN


FUNCTION IntegDBF( cBaza )

   LOCAL berr, nRec := RecNo(), nExpr := 0, nExpr2 := 0, cStr := "", j := 0


   BEGIN SEQUENCE
      // SET AUTOPEN OFF
      IF cBaza != NIL
         USE ( cBaza ) NEW
      ENDIF
      GO TOP
      DO WHILE !Eof()
         FOR j := 1 TO FCount()
            IF ValType( FieldGet( j ) ) == "C"
               cStr := Trim( FieldGet( j ) )
               nExpr += Len( cStr )
               nExpr2 += NUMAT( "A", cStr )
            ENDIF
         NEXT
         SKIP 1
      ENDDO
      IF cBaza != NIL
         USE
      ELSE
         GO ( nRec )
      ENDIF
   RECOVER
      bErr := ErrorBlock( bErr )
      MsgBeep( "Ponovite prenos, podaci su osteceni !" )
      // SET AUTOPEN ON
      RETURN { 0, 0 }
   END SEQUENCE
   // SET AUTOPEN ON

   RETURN { nExpr, nExpr2 }
