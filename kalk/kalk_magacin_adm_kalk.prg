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


// -----------------------------------------------------
// korekcija nc pomocu dokumenta 95 - nc iz sif.robe
// -----------------------------------------------------
FUNCTION KorekNC2()

   LOCAL nPom := 0
   PRIVATE cMagac := "1310   "
   PRIVATE dDok := Date()

   IF !SigmaSif( "SIGMAPR2" )
      RETURN
   ENDIF

   O_KONCIJ
   O_KONTO

   IF !VarEdit( { { "Magacinski konto", "cMagac", "P_Konto(@cMagac)",, }, { "Datum dokumenta", "dDok",,, } }, 12, 5, 16, 74, ;
         'DEFINISANJE MAGACINA NA KOME CE BITI IZVRSENE PROMJENE', ;
         "B1" )
      CLOSERET
   ENDIF
   O_ROBA
   O_KALK_PRIPR
   O_KALK

   nTUlaz := 0
   nTIzlaz := 0
   nTVPVU := 0
   nTVPVI := 0
   nTNVU := 0
   nTNVI := 0
   nTRabat := 0

   PRIVATE nRbr := 0

   SELECT kalk

   cBr95 := kalk_sljedeci( gFirma, "95" )

   SELECT koncij
   SEEK Trim( cMagac )
   SELECT kalk
   SET ORDER TO TAG "3"
   HSEEK gFirma + cMagac

   DO WHILE !Eof() .AND. idfirma + mkonto = gFirma + cMagac

      cIdRoba := Idroba
      nUlaz := nIzlaz := 0
      nVPVU := nVPVI := nNVU := nNVI := 0
      nRabat := 0
      SELECT roba
      HSEEK cIdRoba
      SELECT kalk

      IF roba->tip $ "TU"
         SKIP
         LOOP
      ENDIF

      cIdkonto := mkonto
      DO WHILE !Eof() .AND. gFirma + cidkonto + cidroba == idFirma + mkonto + idroba

         IF roba->tip $ "TU"
            SKIP
            LOOP
         ENDIF

         IF mu_i == "1"
            IF !( idvd $ "12#22#94" )
               nUlaz += kolicina - gkolicina - gkolicin2
               nVPVU += vpc * ( kolicina - gkolicina - gkolicin2 )
               nNVU += nc * ( kolicina - gkolicina - gkolicin2 )
            ELSE
               nIzlaz -= kolicina
               nVPVI -= vpc * kolicina
               nNVI -= nc * kolicina
            ENDIF
         ELSEIF mu_i == "5"
            nIzlaz += kolicina
            nVPVI += vpc * kolicina
            nRabat += vpc * rabatv / 100 * kolicina
            nNVI += nc * kolicina
         ELSEIF mu_i == "3"    // nivelacija
            nVPVU += vpc * kolicina
         ENDIF
         SKIP
      ENDDO

      SELECT kalk_pripr
      IF Round( nulaz - nizlaz, 4 ) <> 0
         IF Round( roba->nc - ( nNVU - nNVI ) / ( nulaz - nizlaz ), 4 ) <> 0
            ++nRbr
            APPEND BLANK
            REPLACE idfirma WITH gFirma, idroba WITH cIdRoba, idkonto2 WITH cIdKonto, ;
               datdok WITH dDok, ;
               idtarifa WITH roba->idtarifa, ;
               datfaktp WITH dDok, ;
               kolicina WITH nulaz - nizlaz, ;
               idvd WITH "95", brdok WITH cBr95,;
               rbr WITH Str( nRbr, 3 ), ;
               mkonto WITH cMagac, ;
               mu_i WITH "5", ;
               nc with ( nNVU - nNVI ) / ( nulaz - nizlaz ), ;
               vpc WITH KoncijVPC(), ;
               marza WITH KoncijVPC() -( nNVU - nNVI ) / ( nulaz - nizlaz )
            APPEND BLANK
            REPLACE idfirma WITH gFirma, idroba WITH cIdRoba, idkonto2 WITH cIdKonto, ;
               datdok WITH dDok, ;
               idtarifa WITH roba->idtarifa, ;
               datfaktp WITH dDok, ;
               kolicina WITH -( nulaz - nizlaz ), ;
               idvd WITH "95", brdok WITH Left( cBr95, 5 ) + "/2",;
               rbr WITH Str( nRbr, 3 ), ;
               mkonto WITH cMagac, ;
               mu_i WITH "5", ;
               nc WITH roba->nc, ;
               vpc WITH KoncijVPC(), ;
               marza WITH KoncijVPC() -roba->nc
         ENDIF
      ENDIF
      SELECT kalk

   ENDDO


   CLOSERET

   RETURN
// }
