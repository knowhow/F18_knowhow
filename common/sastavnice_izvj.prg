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


FUNCTION ISast()

   LOCAL nArr := Select()

   qqProiz := Space( 60 )
   cBrisi := "N"
   cSamoBezSast := "N"
   cNCVPC := "D"

   DO WHILE .T.
      Box(, 7, 60 )
      @ m_x + 1, m_y + 2 SAY "Proizvodi :" GET qqProiz  PICT "@!S30"
      @ m_x + 3, m_y + 2 SAY "Brisanje prekinutih sastavnica ? (D/N)" GET cBrisi  PICT "@!" VALID cBrisi $ "DN"
      @ m_x + 5, m_y + 2 SAY "Prikazati samo proizvode bez sastavnica ? (D/N)" GET cSamoBezSast  PICT "@!" VALID cSamoBezSast $ "DN"
      @ m_x + 7, m_y + 2 SAY "Prikazati NC i VPC ? (D/N)" GET cNCVPC VALID cNCVPC $ "DN" PICT "@!"
      READ
      BoxC()

      IF LastKey() == K_ESC
         RETURN
      ENDIF

      PRIVATE aUsl1 := Parsiraj( qqProiz, "Id" )
      IF aUsl1 <> NIL
         EXIT
      ENDIF

   ENDDO

   SELECT ( nArr )
   PushWA()

//   SELECT ( F_ROBA )
//   IF !Used()
//      o_roba()
//   ENDIF
//   SET ORDER TO TAG "ID"

   SELECT ( F_SAST )
   IF !Used()
      o_sastavnica()
   ELSE
      USE
      o_sastavnica()
   ENDIF

   IF cBrisi == "D"
      SELECT sast
      SET ORDER TO
      GO TOP
      DO WHILE !Eof()
         SKIP
         nTrec := RecNo()
         SKIP -1
         select_o_roba( sast->id )  // nema "svog proizvoda"
         IF !Found()
            SELECT sast
            DELETE
         ENDIF
         SELECT sast
         GO nTRec
      ENDDO
      SELECT sast
      SET ORDER TO TAG "ID"
      GO TOP
   ENDIF

   START PRINT CRET

   IF cSamoBezSast == "D"

      SELECT ROBA

      IF Len( aUsl1 ) <> 0
         aUsl1 += ".and. tip=='P'"
         SET FILTER to &( aUsl1 )
      ELSE
         SET FILTER TO tip == "P"
      ENDIF

      m := "----------------------------------------------------------------------------------------------"
      nCol1 := 60
      P_10CPI
      ? "Pregled proizvoda koji nemaju definisane sastavnice"
      ?
      ? self_organizacija_naziv(), Space( 20 ), "na dan", Date()
      GO TOP
      P_12CPI
      ?
      nRBr := 0
      DO WHILE !Eof()
         cId := id
         SELECT SAST
         HSEEK ROBA->ID
         IF !Found()
            IF PRow() > 62 + dodatni_redovi_po_stranici()
               FF
            ENDIF
            ? Str( ++nRBr, 3 ) + ".", ;
               roba->id, ;
               Left( roba->naz, 40 ), ;
               roba->jmj
         ENDIF
         SELECT ROBA
         SKIP 1
      ENDDO
      ? m

   ELSE

      SELECT sast

      IF Len( aUsl1 ) <> 0
         SET FILTER to &( aUsl1 )
      ELSE
         SET FILTER TO
      ENDIF

      IF cNCVPC == "D"
         m := "----------------------------------------------------------------------------------------------"
         z := "                                                              Kolicina         NV        VPV"
      ELSE
         m := "------------------------------------------------------------------------"
         z := "                                                              Kolicina"
      ENDIF

      nCol1 := 20 + Len( ROBA->( id + naz ) )
      P_10CPI

      ? "Pregled sastavnica-normativa za proizvode"
      ?
      ? self_organizacija_naziv(), Space( 20 ), "na dan", Date()

      GO TOP

      P_COND

      DO WHILE !Eof()

         aPom := {}
         cId := field->id

         SELECT roba
         GO TOP
         SEEK cId

         SELECT sast

         AAdd( aPom, "" )
         AAdd( aPom, m )
         AAdd( aPom, roba->id + " " + ;
            PadR( AllTrim( roba->naz ), 40 ) + " " + roba->jmj )
         AAdd( aPom, m )
         AAdd( aPom, z )
         AAdd( aPom, m )

         nRbr := 0
         nNC := 0
         nVPC := 0

         DO WHILE !Eof() .AND. sast->id == cId

            cIdSast := field->id2

            SELECT roba
            GO TOP
            SEEK cIdSast

            SELECT sast

            AAdd( aPom, Str( ++nrbr, 5 ) + ". " + ;
               roba->id + " " + ;
               PadR( AllTrim( roba->naz ), 40 ) + " " + ;
               Transform( sast->kolicina, "999999.9999" ) + " " + ;
               IF( cNCVPC == "D", Transform( roba->nc * sast->kolicina,fakt_pic_iznos() ) + " " + ;
               Transform( roba->vpc * sast->kolicina, fakt_pic_iznos() ), "" );
               )

            nNC += roba->nc * sast->kolicina
            nVPC += roba->vpc * sast->kolicina
            SKIP 1
         ENDDO

         IF cNCVPC == "D"
            AAdd( aPom, m )
            AAdd( aPom, PadR( " Ukupno:", nCol1 ) + " " + ;
               Transform( nNC, fakt_pic_iznos() ) + " " + ;
               Transform( nVPC, fakt_pic_iznos() );
               )
         ENDIF
         AAdd( aPom, m )
         IF PRow() + Len( aPom ) > 62 + dodatni_redovi_po_stranici()
            FF
         ENDIF
         FOR i := 1 TO Len( aPom )
            ? aPom[ i ]
         NEXT
      ENDDO

   ENDIF

   FF
   ENDPRINT
   SELECT ( nArr )
   PopWA()

   RETURN
