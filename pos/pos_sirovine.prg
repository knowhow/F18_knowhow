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



FUNCTION GenUtrSir( dDatOD, dDatDo, cSmjena )

   LOCAL cIdPos
   PRIVATE fTekuci

   IF cSmjena == nil
      cSmjena := ""
      fTekuci := .F.
   ELSE
      // generise se pri zakljucenju/ulasku u izvjestaje
      fTekuci := .T.
   ENDIF

   IF PCount() == 0
      // kad radim forsirano generisanje utroska sirovina
      Box(, 5, 60 )
      dDatOd := CToD( "" )
      dDatDo := gDatum    // DATE()
      cSmjena := ""
      @ m_x + 1, m_y + 5 SAY "Generisi za period pocevsi od:" GET dDatOd
      @ m_x + 3, m_y + 5 SAY "                 zakljucno sa:" GET dDatDo
      READ
      ESC_BCR
      BoxC()
   ENDIF

   MsgO( "SACEKAJTE ... GENERISEM UTROSAK SIROVINA ..." )

   O_PRIPRG
   O_SIFK
   O_SIFV
   O_SAST
   O_ROBA
   O_ODJ
   O_DIO
   O_POS_DOKS
   O_POS

   IF Empty( cSmjena ) // za period ponovo izgenerisi
      SELECT pos_doks
      SET ORDER TO TAG "2" // IdVd+DTOS (Datum)+Smjena
      // prvo pobrisem stare dokumente razduzenja sirovina
      SEEK "96" + DToS ( dDatOd )
      DO WHILE !Eof() .AND. pos_doks->IdVd == "96" .AND. pos_doks->Datum <= dDatDo
         @ m_x + 1, m_y + 15 SAY "B/" + DToC( datum ) + Brdok
         SELECT POS
         SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
         DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
            Del_Skip()
         ENDDO
         SELECT pos_doks
         Del_Skip()
      ENDDO
   ENDIF  // za period ponovo izgenerisi

   RazdPoNorm( dDatOd, dDatDo, cSmjena, fTekuci )

   MsgC()

   CLOSERET
   // }


/* RazdPoNorm(dDatOd,dDatDo,cSmjena,fTekuci)
 *
 */

FUNCTION RazdPoNorm( dDatOd, dDatDo, cSmjena, fTekuci )

   LOCAL i := 1
   LOCAL cVrsta
   LOCAL fNaso

   // ispraznim pripremu
   SELECT PRIPRG
   my_dbf_zap()

   Scatter()

   SELECT pos_doks
   SET ORDER TO TAG "2"

   FOR i := 1 TO 2
      IF i == 1
         cVrsta := "42"
      ELSE
         cVrsta := "01"
      ENDIF
      SEEK cVrsta + DToS ( dDatOd )
      DO WHILE !Eof() .AND. pos_doks->IdVd == cVrsta .AND. pos_doks->Datum <= dDatDo
         IF fTekuci .AND. ( pos_doks->Smjena <> cSmjena .OR. pos_doks->M1 == OBR_JEST )
            SKIP
            LOOP
         ENDIF
         SELECT POS
         SEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
         @ m_x + 1, m_y + 15 SAY "G/" + DToC( datum ) + Brdok
         DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok ) == pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )
            IF POS->M1 == OBR_JEST
               SKIP
               LOOP
            ENDIF
            Scatter()     // uzmi podatke o promjeni
            SELECT sast
            SEEK _idroba
            IF Found()  // idemo po sastavnici
               DO WHILE !Eof() .AND. sast->Id == _idroba
                  SELECT roba
                  HSEEK sast->Id2
                  IF Found ()
                     _Cijena := roba->mpc
                  ELSE
                     _Cijena := 0
                  ENDIF
                  SELECT PRIPRG
                  HSEEK _IdPos + _IdOdj + _IdDio + sast->Id2 + DToS( _Datum ) + _Smjena
                  IF !Found ()
                     APPEND BLANK // priprg
                     _IdVd := "96"
                     _MU_I := S_I
                     _BrDok := Space( Len( _BrDok ) )
                     _IdRadnik := Space( Len( _IdRadnik ) )
                     Gather()  // priprg
                     // priprg
                     REPLACE IdRoba WITH sast->Id2, Kolicina WITH _Kolicina * sast->Kolicina
                  ELSE
                     REPLACE Kolicina WITH Kolicina + _Kolicina * sast->Kolicina
                  ENDIF
                  SELECT sast
                  SKIP
               ENDDO
            ELSE // u sastavnici nema robe
               SELECT PRIPRG
               HSEEK _IdPos + _IdOdj + _IdDio + _IdRoba + DToS( _Datum ) + _Smjena
               IF !Found ()
                  APPEND BLANK
                  _IdVd := "96"
                  _MU_I := S_I
                  _BrDok := Space( Len( _BrDok ) )
                  _IdRadnik := Space( Len( _IdRadnik ) )
                  Gather() // priprg
               ELSE
                  // priprg
                  REPLACE Kolicina WITH _Kolicina + Kolicina
               ENDIF
            ENDIF
            SELECT POS
            SKIP
         ENDDO // POS
         SELECT pos_doks
         SKIP
      ENDDO

   NEXT // i

   // prebaci dokumente razduzenja u DOKS/POS

   SELECT pos_doks
   SET ORDER TO TAG "2"
   SELECT POS
   SET ORDER TO TAG "1"
   SELECT PRIPRG
   SET ORDER TO TAG "2"
   GO TOP
   WHILE !Eof()
      cIdPos := PRIPRG->IdPos
      DO WHILE !Eof() .AND. PRIPRG->IdPos == cIdPos
         xDatum := PRIPRG->Datum
         DO WHILE !Eof() .AND. PRIPRG->IdPos == cIdPos .AND. PRIPRG->Datum == xDatum
            xSmjena := PRIPRG->Smjena
            Scatter()
            SELECT pos_doks
            SEEK "96" + DToS ( xDatum ) + xSmjena
            IF !Found()
               SET ORDER TO TAG "1"
               cBrDok := _BrDok := pos_novi_broj_dokumenta( cIdPos, VD_RZS )
               IF ( gBrojSto == "D" )
                  _zakljucen := "Z"
               ENDIF
               SET ORDER TO TAG "2"
               APPEND BLANK
               Gather()
            ELSE
               cBrDok := ""
               DO WHILE !Eof() .AND. pos_doks->IdVd == "96" .AND. pos_doks->Datum == xDatum .AND. pos_doks->Smjena == xSmjena
                  IF pos_doks->IdPos == cIdPos
                     cBrDok := pos_doks->BrDok
                     EXIT
                  ENDIF
                  SKIP
               ENDDO
               IF Empty( cBrDok )
                  // ne postoji RZS za cIdPos
                  SET ORDER TO TAG "1"
                  cBrDok := _BrDok := pos_novi_broj_dokumenta( cIdPos, VD_RZS )
                  IF ( gBrojSto == "D" )
                     _zakljucen := "Z"
                  ENDIF
                  SET ORDER TO TAG "2"
                  APPEND BLANK
                  Gather()
               ENDIF
            ENDIF
            SELECT PRIPRG    // xDatum je priprg->datum
            DO WHILE !Eof() .AND. PRIPRG->IdPos == cIdPos .AND. PRIPRG->Datum == xDatum .AND. PRIPRG->Smjena == xSmjena
               Scatter()
               _BrDok := cBrDok
               _Prebacen := OBR_NIJE
               fNaso := .F.
               SELECT POS
               SEEK cIdPos + "96" + DToS( xDatum ) + cBrDok + _IdRoba
               DO WHILE !Eof() .AND. POS->( IdPos + IdVd + DToS( datum ) + BrDok + IdRoba ) == cIdPos + VD_RZS + DToS( xDatum ) + cBrDok + _IdRoba
                  IF POS->Cijena == PRIPRG->Cijena .AND. POS->IdCijena == PRIPRG->IdCijena .AND. pos->idodj == priprg->idodj
                     fNaso := .T.
                     EXIT
                  ENDIF
                  SKIP
               ENDDO
               IF fNaso
                  // POS
                  REPLACE Kolicina WITH Kolicina + _Kolicina
                  REPLSQL Kolicina WITH Kolicina + _Kolicina
               ELSE
                  APPEND BLANK
                  _BrDok := cBrDok
                  Gather()
               ENDIF
               SELECT PRIPRG
               SKIP
            ENDDO
         ENDDO
      ENDDO
   ENDDO

   // oznaci da si obradio racune

   FOR i := 1 TO 2
      IF i == 1
         cVrsta := "42"
      ELSE
         cVrsta := "01"
      ENDIF
      SELECT pos_doks
      SET ORDER TO TAG "2"
      SEEK cVrsta + DToS ( dDatOd )
      DO WHILE !Eof() .AND. pos_doks->IdVd == cVrsta .AND. pos_doks->Datum <= dDatDo
         IF fTekuci .AND. ( pos_doks->Smjena <> cSmjena .OR. pos_doks->M1 == OBR_JEST )
            SKIP
            LOOP
         ENDIF
         // doks
         REPLACE M1 WITH OBR_JEST
         REPLSQL M1 WITH OBR_JEST
         SKIP
      ENDDO
   NEXT // i

   SELECT PRIPRG

   my_dbf_zap()

   RETURN
