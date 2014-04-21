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


#include "kalk.ch"

FUNCTION P_Fin( lAuto )

   PRIVATE gDatNal := "N"
   PRIVATE gRavnot := "D"
   PRIVATE cDatVal := "D"

   IF ( lAuto == nil )
      lAuto := .F.
   ENDIF

   IF gaFin == "D"
	
      kontrola_zbira_naloga( lAuto )
	
      IF lAuto == .F. .OR. ( lAuto == .T. .AND. gAImpPrint == "D" )
         stampa_fin_document( lAuto )
      ELSE
         gen_psuban_stavke()
         gen_sint_stavke()
      ENDIF
	
      fin_azur( lAuto )

   ENDIF

   RETURN


/*
  filovanje potrebnih tabela kod auto importa
*/
STATIC FUNCTION gen_psuban_stavke()

   my_close_all_dbf()

   O_FIN_PRIPR
   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK
   O_PSUBAN

   SELECT PSUBAN
   my_dbf_zap()

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF Eof()
      my_close_all_dbf()
      RETURN
   ENDIF

   DO WHILE !Eof()
	
      cIdFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal

      b2 := {|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }

      DO WHILE !Eof() .AND. Eval( b2 )

         SELECT PSUBAN
         Scatter()
         SELECT fin_pripr
         Scatter()

         SELECT PSUBAN
         APPEND BLANK
         Gather()

         SELECT fin_pripr
         SKIP

      ENDDO

   ENDDO

   my_close_all_dbf()

   RETURN



STATIC FUNCTION gen_sint_stavke( lAuto )

   O_PANAL
   O_PSINT
   O_PNALOG
   O_PSUBAN
   O_KONTO
   O_TNAL

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   SELECT PANAL
   my_dbf_zap()

   SELECT PSINT
   my_dbf_zap()

   SELECT PNALOG
   my_dbf_zap()

   SELECT PSUBAN
   SET ORDER TO TAG "2"
   GO TOP

   IF Empty( BrNal )
      IF lAuto == .T.
         closeret
      ELSE
         closeret2
      ENDIF
   ENDIF

   A := 0

   DO WHILE !Eof()
      // svi nalozi

      nStr := 0
      nD1 := 0
      nD2 := 0
      nP1 := 0
      nP2 := 0

      cIdFirma := IdFirma
      cIDVn := IdVN
      cBrNal := BrNal

      DO WHILE !Eof() .AND. cIdFirma == IdFirma ;
            .AND. cIdVN == IdVN ;
            .AND. cBrNal == BrNal

         cIdkonto := idkonto

         nDugBHD := 0
         nDugDEM := 0
         nPotBHD := 0
         nPotDEM := 0

         IF D_P = "1"
            nDugBHD := IznosBHD
            nDugDEM := IznosDEM
         ELSE
            nPotBHD := IznosBHD
            nPotDEM := IznosDEM
         ENDIF

         SELECT PANAL
         // analitika
         SEEK cIdFirma + cIdVn + cBrNal + cIdKonto
	
         fNasao := .F.

         DO WHILE !Eof() .AND. cIdFirma == IdFirma ;
               .AND. cIdVN == IdVN .AND. cBrNal == BrNal ;
               .AND. IdKonto == cIdKonto
		
            IF gDatNal == "N"
               IF Month( psuban->datdok ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ELSE
               // sintetika se generise na osnovu datuma naloga
               IF Month( dDatNal ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ENDIF
            SKIP
         ENDDO

         IF !fNasao
            APPEND BLANK
         ENDIF

         my_rlock()

         REPLACE IdFirma WITH cIdFirma
         REPLACE IdKonto WITH cIdKonto
         REPLACE IdVN WITH cIdVN
         REPLACE BrNal WITH cBrNal
         REPLACE DatNal WITH iif( gDatNal == "D", dDatNal, Max( psuban->datdok, datnal ) )
         REPLACE DugBHD WITH DugBHD + nDugBHD
         REPLACE PotBHD WITH PotBHD + nPotBHD
         REPLACE DugDEM WITH DugDEM + nDugDEM
         REPLACE PotDEM WITH PotDEM + nPotDEM
         my_unlock()


         SELECT PSINT
         SEEK cidfirma + cidvn + cbrnal + Left( cidkonto, 3 )
         fNasao := .F.

         DO WHILE !Eof() .AND. cIdFirma == IdFirma ;
               .AND. cIdVN == IdVN .AND. cBrNal == BrNal ;
               .AND. Left( cidkonto, 3 ) == idkonto
            IF gDatNal == "N"
               IF  Month( psuban->datdok ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ELSE // sintetika se generise na osnovu dDatNal
               IF Month( dDatNal ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ENDIF

            SKIP
         ENDDO

         IF !fNasao
            APPEND BLANK
         ENDIF

         my_rlock()
         REPLACE IdFirma WITH cIdFirma, IdKonto WITH Left( cIdKonto, 3 ), IdVN WITH cIdVN, ;
            BrNal WITH cBrNal, ;
            DatNal WITH iif( gDatNal == "D", dDatNal,  Max( psuban->datdok, datnal ) ), ;
            DugBHD WITH DugBHD + nDugBHD, PotBHD WITH PotBHD + nPotBHD, ;
            DugDEM WITH DugDEM + nDugDEM, PotDEM WITH PotDEM + nPotDEM

         my_unlock()

         nD1 += nDugBHD; nD2 += nDugDEM; nP1 += nPotBHD; nP2 += nPotDEM

         SELECT PSUBAN
         SKIP
	
      ENDDO
      // nalog

      SELECT PNALOG    // datoteka naloga
      APPEND BLANK

      my_rlock()

      REPLACE IdFirma WITH cIdFirma, IdVN WITH cIdVN, BrNal WITH cBrNal, ;
         DatNal WITH iif( gDatNal == "D", dDatNal, Date() ), ;
         DugBHD WITH nD1, PotBHD WITH nP1, ;
         DugDEM WITH nD2, PotDEM WITH nP2

      my_unlock()

      PRIVATE cDN := "N"

      SELECT PSUBAN

   ENDDO
   // svi nalozi

   SELECT PANAL
   GO TOP
   my_flock()
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO
   my_unlock()

   SELECT PSINT
   GO TOP
   my_flock()
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO
   my_unlock()

   my_close_all_dbf()

   RETURN
