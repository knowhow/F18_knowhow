/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


FUNCTION pos_prijava( Fx, Fy )

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
#ifdef F18_DEBUG
      ?E "pos_prijava", cKorSif
#endif
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


      pos_spec_sifre( cKorSif ) // obradi specijalne sifre

      IF ( goModul:lTerminate )
         RETURN "X"
      ENDIF

      SET CURSOR OFF
      SetColor ( f18_color_normal() )

      IF pos_set_user( cKorSif, nSifLen, @cLevel ) == 0
         LOOP
      ELSE
         EXIT
      ENDIF

   ENDDO

   pos_status_traka()

   CLOSE ALL

   RETURN cLevel



// obrada specijalnih sifara...
FUNCTION pos_spec_sifre( cSifra )

   IF Trim( Upper( cSifra ) ) $ "X"
      goModul:lTerminate := .T.
   ELSEIF Trim( Upper( cSifra ) ) = "M"
      goModul:quit()
   ENDIF

   RETURN .T.
