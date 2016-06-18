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


// pregled kretanja zaliha
FUNCTION PreglKret()

   LOCAL i
   LOCAL cRSezona := ""
   LOCAL cSezStr := ""
   PRIVATE nT1 := nT4 := nT5 := nT6 := nT7 := 0
   PRIVATE nTT1 := nTT4 := nTT5 := nTT6 := nTT7 := 0
   PRIVATE n1 := n4 := n5 := n6 := n7 := 0
   PRIVATE nCol1 := 0
   PRIVATE PicCDEM := "999999.999"
   PRIVATE PicProc := "999999.99%"
   PRIVATE PicDEM := "9999999.99"
   PRIVATE Pickol := "@ 999999"
   PRIVATE dDatOd := Date()
   PRIVATE dDatDo := Date()
   PRIVATE qqKonto := PadR( "13;", 60 )
   PRIVATE qqRoba := Space( 60 )
   PRIVATE qqSezona := Space( 60 )
   PRIVATE cIdKPovrata := Space( 7 )
   PRIVATE cK7 := "N"
   PRIVATE cK1 := Space( 4 )
   PRIVATE cK9 := Space( 3 )
   PRIVATE cPrikazDob := "N"
   PRIVATE cKartica
   PRIVATE cNObjekat
   PRIVATE cLinija
   PRIVATE PREDOVA2 := 62
   PRIVATE aUTar := {}
   PRIVATE nUkObj := 0
   PRIVATE nITar := 0
   PRIVATE cRekPoRobama := "D"
   PRIVATE cRekPoDobavljacima := "D"
   PRIVATE cRekPoGrupamaRobe := "D"
   PRIVATE aUGArt := {}
   PRIVATE cPrSort := "SUBSTR(cIdRoba,3,3)"
   PRIVATE cKesiraj := "N"
   PRIVATE aUsl1
   PRIVATE aUsl2
   PRIVATE aUslR
   PRIVATE aUslSez
   PRIVATE cPlVrsta := " "
   PRIVATE cPapir := "A4 "

   O_SIFK
   O_SIFV
   O_ROBA
   O_K1
   O_OBJEKTI

   IF ( GetVars( @cNObjekat, @dDatOd, @dDatDo, @cIdKPovrata, @cRekPoRobama, @cRekPoDobavljacima, @cRekPoGrupamaRobe, @cK1, @cK7, @cK9, @cPlVrsta, @cPapir, @cPrikazDob, @aUsl1, @aUsl2, @aUslR, @aUslSez ) == 0 )
      RETURN
   ENDIF

   PRIVATE lSMark := .F.

   IF Right( Trim( qqSezona ), 1 ) = "*"
      lSMark := .T.
   ENDIF

   brisi_tabelu_pobjekti()
   napuni_tabelu_pobjekti_iz_objekti()

   CreTblRek1( "1" )

   O_POBJEKTI
   o_koncij()
   O_ROBA
   O_KONTO
   O_TARIFA
   O_K1
   O_OBJEKTI
   o_kalk()
   O_REKAP1

   GenRekap1( aUsl1, aUsl2, aUslR, cKartica, "1", cKesiraj, lSMark, cK1, cK7, cK9, cIdKPovrata, aUslSez )

   SetLinija( @cLinija, @nUkObj )

   SELECT rekap1
   SET ORDER TO TAG "2"
   GO TOP

   gaZagFix := {}
   gaKolFix := {}
   SetGaZag( cRekPoRobama, cRekPoDobavljacima, cRekPoGrupamaRobe, @gaZagFix, @gaKolFix )

   // START PRINT CRET
   gvim_print( "PKZ.TXT" )

   ?

   IF ( ( cPapir == "A3L" ) .OR. ( cPapir == "A4L" ) .OR. gPrinter == "R" )
      PREDOVA2 = 46
      ?? "#%LANDS#"
   ENDIF

   nStr := 0

   IF ( cRekPoRobama == "D" )
      ZagPKret()
   ENDIF

   nCol1 := 43

   resetuj_vrijednosti_tabele_pobjekti()

   SELECT rekap1
   nRbr := 0

   fFilovo := .F.
   DO WHILE !Eof()

      cG1 := g1
      SELECT pobjekti
      // inicijalizuj polja
      GO TOP
      my_flock()
      DO WHILE !Eof()
         // prodaja grupa
         REPLACE prodg WITH 0
         REPLACE zalg  WITH 0
         SKIP
      ENDDO
      my_unlock()
      SELECT rekap1

      fFilGr := .F.

      DO WHILE !Eof() .AND. cG1 == field->g1

         SELECT pobjekti
         GO TOP
         my_flock()
         DO WHILE !Eof()
            // prodaja tarifa,grupa
            REPLACE prodt WITH 0
            REPLACE zalt  WITH 0
            SKIP
         ENDDO
         my_unlock()
         SELECT rekap1
         cIdTarifa := idtarifa
         fFilovo := .F.

         DO WHILE !Eof() .AND. cG1 == g1 .AND. rekap1->idTarifa == cIdTarifa

            cIdroba := rekap1->idroba
            SELECT roba
            HSEEK cIdRoba

            IF !Empty( cPlVrsta ) .AND. field->vrsta <> cPlVrsta
               SELECT rekap1
               SKIP
               LOOP
            ENDIF

            // nadji mpc u nekoj prodavnici
            nMpc := NadjiPMpc()

            nK2 := nK1 := 0

            SetK1K2( cG1, cIdTarifa, cIdRoba, @nK1, @nK2 )

            IF ( Round( nK2, 3 ) == 0 .AND. Round( nK1, 2 ) == 0 )
               // stanje nula, skoci na sljedecu robu !!!!!
               SELECT rekap1
               SEEK cG1 + cIdTarifa + cIdroba + Chr( 254 )
               LOOP
            ENDIF

            fFilovo := .T.
            fFilGr := .T.

            cRSezona := IzSifKRoba( "SEZ", roba->id, .F. )

            IF !Empty( cRSezona )
               cSezStr := PadR( "sez: " + AllTrim( cRSezona ), 10 )
            ELSE
               cSezStr := PadR( "", 10 )
            ENDIF

            aStrRoba := SjeciStr( Trim( roba->naz ) + " (MPC:" + AllTrim( Str( nmpc, 7, 2 ) ) + ")", 27 )

            IF ( PRow() > PREDOVA2 + dodatni_redovi_po_stranici() - 3 )
               FF
               ZagPKret()
            ENDIF

            ++nRBr
            IF ( cRekPoRobama == "D" )
               ? Str( nRBr, 4 ) + "." + cidroba
               nColR := PCol() + 1
               @ PRow(), ncolR  SAY aStrRoba[ 1 ]
               nCol1 := PCol()
            ENDIF

            IF ( ROBA->k2 <> "X" )
               aPom := { "A", &cPrSort }
               FOR i := 1 TO nUkObj + 2
                  AAdd( aPom, { 0, 0 } )
               NEXT
               nITar := AScan( aUGArt, {| x| x[ 2 ] == aPom[ 2 ] } )
               IF nITar == 0
                  AAdd( aUGArt, aPom )
                  nITar := Len( aUGArt )
               ENDIF
            ENDIF

            // prvi red zalihe
            nK2 := 0
            // izracunajmo prvo ukupno (kolona "SVI")
            SELECT pobjekti
            GO TOP
            DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
               SELECT rekap1
               HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
               nK2 += field->k2
               SELECT pobjekti
               SKIP
            ENDDO

            IF cRekPoRobama == "D"
               // ispis kolone "SVI"
               @ PRow(), PCol() + 1 SAY nk2 PICT pickol
               // kolona "Ucesce" se preskace
               @ PRow(), PCol() + 1 SAY Space( 6 )
            ENDIF
            IF ROBA->k2 <> "X"
               aUGArt[ nITar, 3, 1 ] += nk2
            ENDIF
            // ispisi kolone za pojedine objekte
            SELECT pobjekti
            GO TOP
            i := 0

            DO WHILE ( !Eof() .AND. id < "99" )
               SELECT rekap1
               HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
               IF cRekPoRobama == "D"
                  IF k4pp <> 0
                     @ PRow(), PCol() + 1 SAY StrTran( TRANS( k2, pickol ), " ", "*" )
                  ELSE
                     @ PRow(), PCol() + 1 SAY k2 PICT pickol
                  ENDIF
               ENDIF
               ++i
               IF ROBA->k2 <> "X"
                  aUGArt[ nITar, 4 + i, 1 ] += k2
               ENDIF
               SELECT pobjekti
               IF roba->k2 <> "X"
                  // samo u finansijski zbir
                  RREPLACE zalt  WITH zalt + rekap1->k2, ;
                     zalu  WITH zalu + rekap1->k2,;
                     zalg  WITH zalg + rekap1->k2
               ENDIF
               SKIP
            ENDDO

            // ovo je objekat 99
            IF roba->k2 <> "X"
               // roba sa oznakom k2=X
               RREPLACE zalt   WITH zalt + nk2,;
                  zalu   WITH zalu + nk2,;
                  zalg   WITH zalg + nk2
            ENDIF

            // drugi red  prodaja  u mjesecu  k1
            SELECT pobjekti
            nK1 := 0
            IF cRekPoRobama == "D"
               ?

               // sezona
               @ PRow(), 5 SAY cSezStr

               IF Len( aStrRoba ) > 1
                  @ PRow(), nColR SAY aStrRoba[ 2 ]
               ENDIF

               @ PRow(), nCol1 SAY ""

            ENDIF

            // ispisi kolone za pojedine objekte
            GO TOP
            DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
               SELECT rekap1
               HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
               nK1 += field->k1
               SELECT pobjekti
               SKIP
            ENDDO

            IF cRekPoRobama == "D"
               @ PRow(), PCol() + 1 SAY nk1 PICT pickol
               IF !( nk2 + nk1 == 0 )
                  @ PRow(), PCol() + 1 SAY nk1 / ( nk2 + nk1 ) * 100 PICT "999.99%"
               ELSE
                  @ PRow(), PCol() + 1 SAY "???.??%"
               ENDIF
            ENDIF

            IF ROBA->k2 <> "X"
               aUGArt[ nITar, 3, 2 ] += nK1
            ENDIF

            SELECT pobjekti
            GO TOP
            lIzaProc := .T.
            i := 0
            DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
               SELECT rekap1
               HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
               IF cRekPoRobama == "D"
                  IF k4pp <> 0
                     @ PRow(), PCol() + 1 -IF( lIzaProc, 1, 0 ) SAY StrTran( TRANS( k1, IF( lIzaProc, "999999", pickol ) ), " ", "*" )
                  ELSE
                     @ PRow(), PCol() + 1 -IF( lIzaProc, 1, 0 ) SAY k1 PICT IF( lIzaProc, "999999", pickol )
                  ENDIF
               ENDIF
               ++i

               SELECT pobjekti
               IF roba->k2 <> "X"
                  aUGArt[ nITar, 4 + i, 2 ] += rekap1->k1
                  RREPLACE prodt  WITH  prodt + rekap1->k1, ;
                     produ  WITH  produ + rekap1->k1, ;
                     prodg  WITH  prodg + rekap1->k1
               ENDIF
               SKIP
               lIzaProc := .F.
            ENDDO

            // skipuje na polje "99"
            IF roba->k2 <> "X"
               RREPLACE prodt WITH prodt + nk1, produ WITH produ + nk1, prodg WITH prodg + nk1
            ENDIF

            IF ( cPrikazDob == "D" )
               ? PrikaziDobavljaca( cIdRoba, 6 )
            ENDIF

            IF cRekPoRobama == "D"
               ? cLinija
            ENDIF

            SELECT rekap1
            SEEK cG1 + cIdTarifa + cIdroba + Chr( 255 )

         ENDDO

         IF !fFilovo
            LOOP
         ENDIF

         // pocetak Ukupno tarifa ****************************
         IF cRekPoRobama == "D"
            IF ( PRow() > PREDOVA2 + dodatni_redovi_po_stranici() - 3 )
               FF
               ZagPKret()
            ENDIF

            // ?  cLinija
            // ? "Ukupno tarifa", cIdTarifa
         ENDIF

         aPom := { "T", cIdTarifa }
         FOR i := 1 TO nUkObj + 2
            AAdd( aPom, { 0, 0 } )
         NEXT
         AAdd( aUTar, aPom )
         nITar := Len( aUTar )

         SELECT pobjekti
         // idi na "objekat" 99 (SVI)
         GO BOTTOM
         IF cRekPoRobama == "D"
            // @ prow(),nCol1+1 SAY field->zalt PICT pickol
         ENDIF
         aUTar[ nITar, 3, 1 ] := zalt
         IF cRekPoRobama == "D"
            // kolona "Ucesce" se preskace
            // @ prow(),pcol()+1 SAY SPACE(6)
         ENDIF
         SELECT pobjekti
         GO TOP
         i := 0
         DO WHILE ( !Eof() .AND. field->id < "99" )
            IF cRekPoRobama == "D"
               // @ prow(),pcol()+1 SAY field->zalt pict pickol
            ENDIF
            ++i
            aUTar[ nITar, 4 + i, 1 ] := zalt
            SKIP
         ENDDO

         SELECT pobjekti
         // idi na "objekat" 99 (SVI)
         GO BOTTOM
         IF cRekPoRobama == "D"
            // @ prow()+1,nCol1+1 SAY field->prodt pict pickol
         ENDIF
         aUTar[ nITar, 3, 2 ] := field->prodt
         IF !( field->prodt + field->zalt == 0 )
            aUTar[ nITar, 4, 2 ] := field->prodt / ( field->prodt + field->zalt ) * 100
            IF ( cRekPoRobama == "D" )
               // @ prow(),pcol()+1 SAY field->prodt/(field->prodt+field->zalt)*100 pict "999.99%"
            ENDIF
         ELSE
            IF ( cRekPoRobama == "D" )
               // @ prow(),pcol()+1 SAY "???.??%"
            ENDIF
         ENDIF
         SELECT pobjekti
         GO TOP
         lIzaProc := .T.
         i := 0
         DO WHILE ( !Eof() .AND. field->id < "99" )
            IF ( cRekPoRobama == "D" )
               // @ prow(),pcol()+1-IF(lIzaProc,1,0) SAY field->prodt pict IF(lIzaProc,"999999",pickol)
            ENDIF
            ++i
            aUTar[ nITar, 4 + i, 2 ] := field->prodt
            SKIP
            lIzaProc := .F.
         ENDDO
         IF cRekPoRobama == "D"
            // ?  cLinija
         ENDIF
         // kraj ukupno tarifa *********************************

         SELECT rekap1

      ENDDO

      IF !fFilGr
         LOOP
      ENDIF

      IF ( cRekPoRobama == "D" )

         IF ( PRow() > PREDOVA2 + dodatni_redovi_po_stranici() - 2 )
            FF
            ZagPKret()
         ENDIF

         ? StrTran( cLinija, "-", "=" )
      ENDIF

      SELECT k1
      HSEEK cg1
      SELECT rekap1

      IF ( cRekPoRobama == "D" )
         ? "Ukupno grupa", cG1, "-", k1->naz
      ENDIF

      aPom := { "G", cG1 + " - " + k1->naz }
      FOR i := 1 TO nUkObj + 2
         AAdd( aPom, { 0, 0 } )
      NEXT
      AAdd( aUTar, aPom )
      nITar := Len( aUTar )

      SELECT pobjekti
      // idi na "objekat" 99 (SVI)
      GO BOTTOM
      IF cRekPoRobama == "D"
         @ PRow(), nCol1 + 1 SAY zalg PICT pickol
         // kolona "Ucesce" se preskace
         @ PRow(), PCol() + 1 SAY Space( 6 )
      ENDIF
      aUTar[ nITar, 3, 1 ] := zalg
      SELECT pobjekti
      GO TOP
      i := 0
      DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
         IF cRekPoRobama == "D"
            @ PRow(), PCol() + 1 SAY zalg PICT pickol
         ENDIF
         ++i
         aUTar[ nITar, 4 + i, 1 ] := zalg
         SKIP
      ENDDO
      SELECT pobjekti
      GO BOTTOM // idi na "objekat" 99 (SVI)
      IF cRekPoRobama == "D"
         @ PRow() + 1, nCol1 + 1 SAY prodg PICT pickol
      ENDIF
      aUTar[ nITar, 3, 2 ] := prodg
      IF !( prodg + zalg == 0 )
         aUTar[ nITar, 4, 2 ] := prodg / ( prodg + zalg ) * 100
         IF cRekPoRobama == "D"
            @ PRow(), PCol() + 1 SAY prodg / ( prodg + zalg ) * 100 PICT "999.99%"
         ENDIF
      ELSE
         IF cRekPoRobama == "D"
            @ PRow(), PCol() + 1 SAY "???.??%"
         ENDIF
      ENDIF

      SELECT pobjekti
      GO TOP
      lIzaProc := .T.
      i := 0
      DO WHILE ( !Eof() .AND. id < "99" )
         IF cRekPoRobama == "D"
            @ PRow(), PCol() + 1 -IF( lIzaProc, 1, 0 ) SAY prodg PICT IF( lIzaProc, "999999", pickol )
         ENDIF
         ++i
         aUTar[ nITar, 4 + i, 2 ] := prodg
         SKIP
         lIzaProc := .F.
      ENDDO

      SELECT rekap1
      IF cRekPoRobama == "D"
         StrTran( cLinija, "-", "=" )
      ENDIF

   ENDDO


   IF ( cRekPoRobama == "D" )
      IF ( PRow() > PREDOVA2 + dodatni_redovi_po_stranici() - 3 )
         FF
         ZagPKret()
      ENDIF
      // donja funkcija ne vrsi ispis zaglavlja
      RekPoRobama( cLinija, nCol1 )

   ENDIF


   IF ( cRekPoDobavljacima == "D" )
      RekPoDob( cRekPoRobama, cLinija, nCol1, nUkObj, @aUTar )
   ENDIF

   IF ( cRekPoGrupamaRobe == "D" )
      RekPoGrup( cRekPoGrupama, cRekPoDobavljacima, @aUGArt )
   ENDIF

   FF

   gvim_end()

   my_close_all_dbf()

   RETURN


STATIC FUNCTION NadjiPMpc()

   LOCAL nMpc
   LOCAL nTRec

   SELECT rekap1

   nMpc := field->mpc
   // ako sam na objektu koji je u stvari magacin nMpc=0
   // imao sam problem da je gornja cijena izvucena iz magacina
   // zato cu provrtiti dok ne nadjem prodavnicku cijenu
   IF ( nMpc == 0 )
      nTRec := RecNo()
      DO WHILE !Eof() .AND. field->idRoba = cIdRoba
         IF mpc <> 0
            nMpc := mpc
            EXIT
         ENDIF
         SKIP
      ENDDO
      GO nTRec
   ENDIF

   RETURN nMpc
// }


/* Izmj_cPrSort()
 *     Formula za kljucni dio sifre pri grupisanju roba
 *  \ingroup Planika
 */

STATIC FUNCTION Izmj_cPrSort()

   // {
   LOCAL GetList := {}
   Box(, 3, 75 )
   cPrSort := PadR( cPrSort, 80 )
   @ m_x + 2, m_y + 2 SAY "Formula za kljucni dio sifre pri grupisanju roba:" GET cPrSort PICT "@S20"
   READ
   cPrSort := AllTrim( cPrSort )
   BoxC()

   RETURN
// }

STATIC FUNCTION PaperFormatHelp()

   // {
   cPoruka := "Formati papira - legenda:"
   cPoruka += "##A3  - A3 format papira"
   cPoruka += "##A3L - A3 landscape papir"
   cPoruka += "##A4  - A4 format papira"
   cPoruka += "##A4L - A4 landscape papir"
   MsgBeep( cPoruka )

   RETURN
// }


/* \ingroup Planika
 *  \fn ZagPKret(cVarijanta)
 *     Zaglavlje izvjestaja pregled kretanja
 *   param: cVarijanta - "1" - Pregl. kret zalika, "2" - rekapitulacija po grupama dobavljaca, "3" - rekapitulacija po grupama artikala
 *
 */

STATIC FUNCTION ZagPKret( cVarijanta )

   // {
   IF cPapir == "A4L" .OR. cPapir == "A3L"
      P_COND2
   ENDIF
   IF cVarijanta == nil
      cVarijanta := "1"
   ENDIF
   IF !cPapir $ "A4L#A3L"
      ?? gTS + ":", gNFirma, Space( 40 ), "Strana:" + Str( ++nStr, 3 )
      ?
      ?  "PREGLED KRETANJA ZALIHA za period:", dDatOd, "-", dDAtDo
      ?
   ELSE
      ?? gTS + ":", gNFirma, "  PREGLED KRETANJA ZALIHA za period:", dDatOd, "-", dDAtDo
   ENDIF
   IF qqRoba = nil
      qqRoba := ""
   ENDIF
   ? "Kriterij za Objekat:", Trim( qqKonto ), "Robu:", Trim( qqRoba )
   IF !cPapir $ "A4L#A3L"
      ?
   ENDIF
   IF cVarijanta == "2"
      ?
      ?
      ?
      ?
      ? REPL( "*", 71 )
      ? PadC( "REKAPITULACIJA PO K1-DOBAVLJACIMA", 71 )
      ? REPL( "*", 71 )
      ?
   ELSEIF cVarijanta == "3"

      ?
      ?
      ?
      ?

      ? REPL( "*", 71 )
      ? PadC( "REKAPITULACIJA PO GRUPAMA ARTIKALA", 71 )
      ? REPL( "*", 71 )
      ?
   ENDIF

   IF ( cPapir == "A4L" .OR. cPapir == "A3L" )
      P_COND2
   ELSE
      P_COND
   ENDIF

   ? "---- --------------------------------------"
   SELECT pobjekti
   GO TOP
   DO WHILE !Eof()
      ?? " ------"
      SKIP
   ENDDO
   ?? " ------"

   ? " R.     SIFRA     NAZIV  ARTIKLA            "
   SELECT objekti
   GO BOTTOM
   ?? PadC( objekti->naz, 7 )
   ?? PadC( "Ucesce", 7 )
   GO TOP
   DO WHILE ( !Eof() .AND. objekti->id < "99" )
      ?? PadC( objekti->naz, 7 )
      SKIP
   ENDDO

   ? " br.                                       "
   ?? PadC( "za/pr", 7 )
   ?? Space( 7 )
   SELECT pobjekti
   GO TOP
   DO WHILE ( !Eof() .AND. field->id < "99" )
      ?? PadC( "za/pr", 7 )
      SKIP
   ENDDO

   ? "---- --------------------------------------"
   SELECT pobjekti
   GO TOP
   DO WHILE !Eof()
      ?? " ------"
      SKIP
   ENDDO

   ?? " ------"

   RETURN NIL
// }

STATIC FUNCTION GetVars( cNObjekat, dDatOd, dDatDo, cIdKPovrata, cRekPoRobama, cRekPoDobavljacima, cRekPoGrupamaRobe, cK1, cK7, cK9, cPlVrsta, cPapir, cPrikazDob,  aUsl1, aUsl2, aUslR, aUslSez )

   // {

   O_PARAMS
   PRIVATE cSection := "F", cHistory := " ", aHistory := {}
   Params1()
   RPar( "c1", @cidKPovrata )
   RPar( "c2", @qqKonto )
   RPar( "c3", @cPrSort )
   RPar( "d1", @dDatOd )
   RPar( "d2", @dDatDo )
   RPar( "cR", @qqRoba )
   RPar( "cS", @qqSezona )
   RPar( "cP", @cPrikazDob )
   RPar( "Ke", @cKesiraj )
   RPar( "fP", @cPapir )

   cKartica := "N"
   cNObjekat := Space( 20 )

   Box(, 19, 70 )
   SET CURSOR ON
   SET KEY K_F2 TO Izmj_cPrSort()
   SET KEY K_F1 TO PaperFormatHelp()
   @ m_x + 15, m_y + 15 SAY "<F2> - promjena formule za rekapit.po grup.robe"
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Konta prodavnice:" GET qqKonto PICT "@!S50"
      @ m_x + 3, m_y + 2 SAY "tekuci promet je period:" GET dDatOd
      @ m_x + 3, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 4, m_y + 2 SAY "Kriterij za robu :" GET qqRoba PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Kriterij za sezonu :" GET qqSezona PICT "@!S50"
      @ m_x + 6, m_y + 2 SAY "Magacin u koji se vrsi povrat rekl. robe:" GET cIdKPovrata PICT "@!"
      @ m_x + 9, m_Y + 2 SAY "Pregled po robama?              (D/N)" GET cRekPoRobama PICT "@!" VALID cRekPoRobama $ "DN"
      @ m_x + 10, m_Y + 2 SAY "Rekapitulacija po dobavljacima? (D/N)" GET cRekPoDobavljacima PICT "@!" VALID cRekPoDobavljacima $ "DN"
      @ m_x + 11, m_Y + 2 SAY "Rekapitulacija po grupama robe? (D/N)" GET cRekPoGrupamaRobe PICT "@!" VALID cRekPoGrupamaRobe $ "DN"
      @ m_x + 12, m_Y + 2 SAY "Prikaz za k7='*'              ? (D/N)" GET cK7 PICT "@!" VALID cK7 $ "DN"
      @ m_x + 13, m_Y + 2 SAY "Prikaz dobavljaca ? (D/N)" GET cPrikazDob PICT "@!" VALID cPrikazDob $ "DN"
      @ m_x + 16, m_Y + 2 SAY "Uslov po K1 " GET cK1
      @ m_x + 17, m_Y + 2 SAY "Uslov po K9 " GET cK9
      @ m_x + 18, m_Y + 2 SAY "Uslov po pl.vrsta " GET cPlVrsta PICT "@!"
      @ m_x + 19, m_Y + 2 SAY "Format papira " GET cPapir VALID !Empty( cPapir )
      ?? " <F1> Formati papira - legenda"
      READ
      IF ( LastKey() == K_ESC )
         BoxC()
         RETURN 0
      ENDIF
      aUsl1 := Parsiraj( qqKonto, "PKonto" )
      aUsl2 := Parsiraj( qqKonto, "MKonto" )
      aUslR := Parsiraj( qqRoba, "IdRoba" )
      aUslSez := Parsiraj( qqSezona, "IdRoba" )
      IF aUsl1 <> NIL .AND. aUslR <> nil
         EXIT
      ENDIF
   ENDDO
   SET KEY K_F2 TO
   SET KEY K_F1 TO
   BoxC()

   SELECT roba
   USE


   SELECT params
   IF Params2()
      WPar( "c1", cidKPovrata )
      WPar( "c2", qqKonto )
      WPar( "c3", cPrSort )
      WPar( "d1", dDatOd )
      WPar( "d2", dDatDo )
      WPar( "cR", @qqRoba )
      WPar( "cS", @qqSezona )
      WPar( "Ke", @cKesiraj )
      WPar( "fP", @cPapir )
   ENDIF
   SELECT params
   USE

   RETURN 1
// }


FUNCTION SetLinija( cLinija, nUkObj )

   // {
   cLinija := "---- --------- ----------------------------"
   SELECT pobjekti
   // inicijalizuj cLinija
   GO TOP
   DO WHILE !Eof() .AND. field->id < "99"
      nUkObj++
      cLinija += " ------"
      SKIP
   ENDDO
   cLinija += " ------"
   cLinija += " ------"

   RETURN
// }

FUNCTION SetGaZag( cRekPoRobama, cRekPoDobavljacima, cRekPoGrupamaRobe, gaZagFix, gaKolFix )

   // {

   IF cRekPoRobama == "D"
      // 7.red fajla, 4 reda ukupno (7.,8.,9. i 10.) (ovi redovi su zaglavlje ovog izvjestaja i fiksno se prikazuju na ekranu)
      gaZagFix := { 7, 4 }
      // 6.kolona, 38 kolona ukupno, od 7.reda ispisuj
      gaKolFix := { 1, 58, 7 }

   ELSEIF cRekPoDobavljacima == "D"
      gaZagFix := { 15, 4 }
      gaKolFix := { 1, 58, 15 }
   ELSEIF cRekPoGrupamaRobe == "D"
      gaZagFix := { 15, 4 }
      gaKolFix := { 1, 58, 15 }
   ENDIF

   RETURN
// }

FUNCTION RekPoRobama( cLinija, nCol1 )

   // {

   ? cLinija

   ? "UKUPNO:"
   SELECT pobjekti
   // idi na "objekat" 99 (SVI)
   GO BOTTOM
   @ PRow(), nCol1 + 1 SAY zalu PICT pickol
   // kolona "Ucesce" se preskace
   @ PRow(), PCol() + 1 SAY Space( 6 )
   SELECT pobjekti
   GO TOP
   DO WHILE ( !Eof() .AND. id < "99" )
      @ PRow(), PCol() + 1 SAY zalu PICT pickol
      SKIP
   ENDDO

   SELECT pobjekti
   // idi na "objekat" 99 (SVI)
   GO BOTTOM
   @ PRow() + 1, nCol1 + 1 SAY produ PICT pickol
   IF !( produ + zalu == 0 )
      @ PRow(), PCol() + 1 SAY produ / ( produ + zalu ) * 100 PICT "999.99%"
   ELSE
      @ PRow(), PCol() + 1 SAY "???.??%"
   ENDIF

   SELECT pobjekti
   GO TOP
   lIzaProc := .T.
   DO WHILE !Eof()  .AND. id < "99"
      @ PRow(), PCol() + 1 -IF( lIzaProc, 1, 0 ) SAY produ PICT IF( lIzaProc, "999999", pickol )
      SKIP
      lIzaProc := .F.
   ENDDO
   SELECT rekap1
   ? cLinija

   RETURN
// }


FUNCTION RekPoDob( cRekPoRobama, cLinija, nCol1, nUkObj, aUTar )

   // {

   aPom := { "U", "" }
   FOR i := 1 TO nUkObj + 2
      AAdd( aPom, { 0, 0 } )
   NEXT
   AAdd( aUTar, aPom )
   nITar := Len( aUTar )
   FF
   ZagPKret( "2" )

   cLinija2 := StrTran( cLinija, "-", "=" )
   FOR i := 1 TO Len( aUTar )

      IF ( PRow() > PREDOVA2 + dodatni_redovi_po_stranici() - 3 )
         FF
         ZagPKret( "2" )
      ENDIF

      IF aUTar[ i, 1 ] == "T"
         // tarife
         ? cLinija
         ? "Ukupno tarifa", aUTar[ i, 2 ]
      ELSEIF aUTar[ i, 1 ] == "G"
         // dobavljaci
         ? cLinija2
         ? "Ukupno grupa", aUTar[ i, 2 ]
      ELSE
         ? cLinija2
         ? "UKUPNO:"
      ENDIF
      @ PRow(), nCol1 + 1 SAY aUTar[ i, 3, 1 ] PICT pickol

      // kolona "Ucesce" se preskace
      @ PRow(), PCol() + 1 SAY Space( 6 )
      FOR j := 1 TO nUkObj
         @ PRow(), PCol() + 1 SAY aUTar[ i, 4 + j, 1 ] PICT pickol
      NEXT
      @ PRow() + 1, nCol1 + 1 SAY aUTar[ i, 3, 2 ] PICT pickol
      IF !( aUTar[ i, 3, 1 ] + aUTar[ i, 3, 2 ] == 0 )
         @ PRow(), PCol() + 1 SAY aUTar[ i, 3, 2 ] / ( aUTar[ i, 3, 2 ] + aUTar[ i, 3, 1 ] ) * 100 PICT "999.99%"
      ELSE
         @ PRow(), PCol() + 1 SAY "???.??%"
      ENDIF
      lIzaProc := .T.
      FOR j := 1 TO nUkObj
         @ PRow(), PCol() + 1 -IF( lIzaProc, 1, 0 ) SAY aUTar[ i, 4 + j, 2 ] PICT IF( lIzaProc, "999999", pickol )
         lIzaProc := .F.
      NEXT

      IF aUTar[ i, 1 ] == "T"
         ? cLinija
      ELSE
         ? cLinija2
      ENDIF

      IF i < nITar .AND. aUTar[ i, 1 ] == "G"
         aUTar[ nITar, 3, 1 ] += aUTar[ i, 3, 1 ]
         aUTar[ nITar, 3, 2 ] += aUTar[ i, 3, 2 ]
         FOR j := 1 TO nUkObj
            aUTar[ nITar, 4 + j, 1 ] += aUTar[ i, 4 + j, 1 ]
            aUTar[ nITar, 4 + j, 2 ] += aUTar[ i, 4 + j, 2 ]
         NEXT
      ENDIF
   NEXT

   RETURN
// }

FUNCTION RekPoGrup( cRekPoGrupama, cRekPoDobavljacima, aUGArt )

   // {

   ASort( aUGArt, , , {|x, y|  x[ 2 ] < y[ 2 ] } )
   aPom := { "U", "" }
   FOR i := 1 TO nUkObj + 2
      AAdd( aPom, { 0, 0 } )
   NEXT
   AAdd( aUGArt, aPom )
   nITar := Len( aUGArt )

   FF
   ZagPKret( "3" )
   cLinija2 := StrTran( cLinija, "-", "=" )

   FOR i := 1 TO Len( aUGArt )

      IF ( PRow() > PREDOVA2 + dodatni_redovi_po_stranici() - 3 )
         FF
         ZagPKret( "3" )
      ENDIF


      IF aUGArt[ i, 1 ] == "A"
         ? cLinija
         ? "Grupa", aUGArt[ i, 2 ]
      ELSE
         ? cLinija2
         ? "UKUPNO:"
      ENDIF

      @ PRow(), nCol1 + 1 SAY aUGArt[ i, 3, 1 ] PICT pickol
      // kolona "Ucesce" se preskace
      @ PRow(), PCol() + 1 SAY Space( 6 )
      FOR j := 1 TO nUkObj
         @ PRow(), PCol() + 1 SAY aUGArt[ i, 4 + j, 1 ] PICT pickol
      NEXT
      @ PRow() + 1, nCol1 + 1 SAY aUGArt[ i, 3, 2 ] PICT pickol
      IF !( aUGArt[ i, 3, 1 ] + aUGArt[ i, 3, 2 ] == 0 )
         @ PRow(), PCol() + 1 SAY aUGArt[ i, 3, 2 ] / ( aUGArt[ i, 3, 2 ] + aUGArt[ i, 3, 1 ] ) * 100 PICT "999.99%"
      ELSE
         @ PRow(), PCol() + 1 SAY "???.??%"
      ENDIF
      lIzaProc := .T.
      FOR j := 1 TO nUkObj
         @ PRow(), PCol() + 1 -IF( lIzaProc, 1, 0 ) SAY aUGArt[ i, 4 + j, 2 ] PICT IF( lIzaProc, "999999", pickol )
         lIzaProc := .F.
      NEXT
      IF aUGArt[ i, 1 ] == "A"
         ? cLinija
      ELSE
         ? cLinija2
      ENDIF
      IF i < nITar .AND. aUGArt[ i, 1 ] == "A"
         aUGArt[ nITar, 3, 1 ] += aUGArt[ i, 3, 1 ]
         aUGArt[ nITar, 3, 2 ] += aUGArt[ i, 3, 2 ]
         FOR j := 1 TO nUkObj
            aUGArt[ nITar, 4 + j, 1 ] += aUGArt[ i, 4 + j, 1 ]
            aUGArt[ nITar, 4 + j, 2 ] += aUGArt[ i, 4 + j, 2 ]
         NEXT
      ENDIF
   NEXT

   RETURN
// }
