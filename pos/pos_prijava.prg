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


FUNCTION PosPrijava( Fx, Fy )

   LOCAL nChar
   LOCAL cKorSif
   LOCAL nSifLen
   LOCAL nPom
   LOCAL cLevel
   LOCAL cBrojac
   LOCAL nPrevKorRec

   CLOSE ALL

   nSifLen := 6

   DO WHILE .T.

      SetPos ( Fx + 4, Fy + 15 )

      cKorSif := Upper( pos_get_lozinka( nSifLen ) )
      IF Empty( cKorSif )
         MsgBeep( "ERR unijeti lozinku" )
         LOOP
      ENDIF

      IF ( AllTrim( cKorSif ) == "ADMIN" )
         gIdRadnik := "XXXX"
         gKorIme   := "bring.out servis / ADMIN mode"
         gSTRAD  := "A"
         cLevel := L_SYSTEM
         EXIT
      ENDIF

      // obradi specijalne sifre
      HSpecSifre( cKorSif )

      IF ( goModul:lTerminate )
         RETURN .F.
      ENDIF

      SET CURSOR OFF
      SetColor ( F18_COLOR_NORMAL )

      IF SetUser( cKorSif, nSifLen, @cLevel ) == 0
         LOOP
      ELSE
         EXIT
      ENDIF

   ENDDO

   pos_status_traka()

   CLOSE ALL

   RETURN ( cLevel )



// obrada specijalnih sifara...
FUNCTION HSpecSifre( sifra )

   IF Trim( Upper( sifra ) ) $ "X"
      goModul:lTerminate := .T.
   ELSEIF Trim( Upper( sifra ) ) = "M"
      goModul:quit()
   ENDIF

   RETURN
