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


// sljedeci broj zakljucenja na nivou baze
FUNCTION g_next_zak_br()

   LOCAL nArr

   nArr := Select()

   nRet := 0

   SELECT pos_doks
   SET ORDER TO TAG "ZAK"
   GO BOTTOM
   HSEEK gIdPos + "42" + "XXX"
   SKIP -1

   nRet := ( field->zak_br ) + 1

   SELECT ( nArr )

   RETURN nRet

// zakljuci sto broj
FUNCTION zak_sto( nStoBr )

   // {
   LOCAL nArr
   LOCAL nNext_zak
   LOCAL cNijeZaklj := "     0"
   LOCAL nCnt := 0
   LOCAL nTRec
   LOCAL nNRec

   nArr := Select()

   // vrati sljedeci broj zakljucenja
   nNext_zak := g_next_zak_br()

   // postavi filter za nStoBr
   SELECT pos_doks
   SET ORDER TO TAG "STO"
   HSEEK gIdPos + "42" + Str( nStoBr ) + cNijeZaklj

   DO WHILE !Eof() .AND. pos_doks->idpos == gIdPos .AND. pos_doks->idvd == "42" .AND. pos_doks->sto_br == nStoBr .AND. pos_doks->zak_br == 0
      ++ nCnt
      nTRec := RecNo()
      SKIP
      nNRec := RecNo()

      GO ( nTRec )

      REPLACE zak_br WITH nNext_zak

      GO ( nNRec )
   ENDDO

   IF nCnt > 0
      show_zak_info( nNext_zak )
   ENDIF

   IF Pitanje(, "Stampati zbirni racun (D/N)?", "N" ) == "D"
      print_zak_br( nNext_zak )
   ENDIF

   SELECT ( nArr )

   RETURN nCnt
// }

// ------------------------------
// ------------------------------
FUNCTION show_zak_info( nZakBr )

   // {
   LOCAL nArr
   nArr := Select()

   o_pos_pos()
   SELECT pos_doks
   SET ORDER TO TAG "ZAK"
   HSEEK gIdPos + "42" + Str( nZakBr, 6 )


   cDokumenti := ""
   nTotal := 0
   nCnt := 0
   nStoBr := 0
   cBrDok := ""
   aPom := {}

   DO WHILE !Eof() .AND. pos_doks->idpos == gIdPos .AND. pos_doks->idvd == "42" .AND. pos_doks->zak_br == nZakBr
      nStoBr := pos_doks->sto_br
      ++ nCnt
      nTotal += Val( pos_iznos_dokumenta( .F. ) )
      cBrDok := AllTrim( pos_doks->brdok )
      cDokumenti += cBrDok + ","
      SKIP
   ENDDO

   SKIP -1

   aPom := SjeciStr( cDokumenti, 30 )

   cText := "Zbirni racun " + cBrDok + "-" + AllTrim( Str( nZakBr ) ) + "#"
   cText += "Ukupan iznos po racunima "
   FOR i := 1 TO Len( aPom )
      cText += AllTrim( aPom[ i ] ) + "#"
   NEXT
   cText += " je " + AllTrim( Str( nTotal ) ) + " KM"

   MsgBeep( cText )

   SELECT ( nArr )

   RETURN
// }

// -------------------------------------------------------
// printanje zbirnog racuna na osnovu broja zakljucenja
// -------------------------------------------------------
FUNCTION print_zak_br( nZakBr )

   LOCAL nCSum
   LOCAL cIdPos
   LOCAL cIdVd
   LOCAL cBrDok
   LOCAL cTime
   LOCAL cIdRoba
   LOCAL cIdTarifa
   LOCAL cRobaNaz
   LOCAL nPPDV
   LOCAL nKolicina
   LOCAL nCjenBPdv
   LOCAL nCjen2BPDV
   LOCAL nCjen2PDV
   LOCAL nCjenPDV
   LOCAL nIznPop
   LOCAL nUBPDV
   LOCAL nUPDV
   LOCAL nUTotal
   LOCAL nUPopust
   LOCAL nUBPdvPopust
   LOCAL dDatRn
   LOCAL cVrstaP
   LOCAL cNazVrstaP
   LOCAL cIdRadnik
   LOCAL cRdnkNaz
   LOCAL cBrZDok
   LOCAL nArr
   LOCAL cBrStola
   LOCAL cVezRacuni

   nArr := Select()

   o_pos_tables()
   close_open_racun_tbl()
   zap_racun_tbl()

   SELECT pos
   SET ORDER TO TAG "1"

   SELECT pos_doks
   SET ORDER TO TAG "ZAK"
   HSEEK gIdPos + "42" + Str( nZakBr, 6 )

   IF !Found()
      MsgBeep( "racun ZAK.STO=" + Str( nZakBr, 6 ) + " ne postoji !?" )
      CLOSE ALL
      RETURN
   ENDIF

   cZBrDok := AllTrim( pos_doks->brdok ) + "-" + AllTrim( Str( nZakBr, 6 ) )

   nCSUm := 0
   nUBPDV := 0
   nUPDV := 0
   nUTotal := 0
   nUPopust := 0
   nUBPdvPopust := 0

   cVezRacuni := ""

   DO WHILE !Eof() .AND. pos_doks->idvd == "42" .AND. pos_doks->zak_br == nZakBr

      cIdPos := pos_doks->idpos
      cIdVD := pos_doks->idvd
      cBrDok := pos_doks->brdok
      dDatRn := pos_doks->datum

      cBrStola := AllTrim( Str( pos_doks->sto_br ) )
      cIdRadnik := pos_doks->idRadnik
      cSmjena := pos_doks->smjena
      cTime := pos_doks->vrijeme
      cVrstaP := pos_doks->idvrstep

      cVezRacuni += AllTrim( cBrDok ) + ","

      SELECT osob
      SET ORDER TO TAG "NAZ"
      HSEEK cIdRadnik
      cRdnkNaz := osob->naz

      SELECT vrstep
      SET ORDER TO TAG "ID"
      HSEEK cVrstaP

      IF !Found()
         cNazVrstaP := "GOTOVINA"
      ELSE
         cNazVrstaP := AllTrim( vrstep->naz )
      ENDIF


      SELECT pos
      HSEEK pos_doks->( cIdPos + cIdVd + DToS( dDatRn ) + cBrDok )
      // -------- vrti kroz pos -------------------------
      DO WHILE !Eof() .AND. ( pos->idpos == cIdpos ) .AND. ( pos->idvd == cIdVd ) .AND.  ( pos->datum == dDatRn ) .AND. ( pos->brdok == cBrDok )

         nCjenBPDV := 0
         nCjenPDV := 0
         nKolicina := 0
         nPopust := 0
         nCjen2BPDV := 0
         nCjen2PDV := 0
         nPDV := 0
         nIznPop := 0


         cIdRoba := pos->idroba
         cIdTarifa := pos->idtarifa

         SELECT roba
         HSEEK cIdRoba
         cJmj := roba->jmj
         cRobaNaz := roba->naz

         // seek-uj tarifu
         SELECT tarifa
         HSEEK cIdTarifa
         nPPDV := tarifa->opp


         nKolicina := pos->kolicina
         nCjenPDV :=  pos->cijena
         dDatDok := pos->datum

         nCjenBPDV := nCjenPDV / ( 1 + nPPDV / 100 )
         DO CASE
         CASE gPopVar = "P" .AND. gClanPopust
            IF !Empty( cPartner )
               nIznPop := pos->ncijena
            ENDIF
         CASE gPopVar = "P" .AND. !gClanPopust
            nIznPop := pos->ncijena
         ENDCASE

         nPopust := 0

         IF Round( nIznPop, 4 ) <> 0

            // cjena 2 : cjena sa pdv - iznos popusta
            nCjen2PDV := nCjenPDV - nIznPop

            // cjena 2 : cjena bez pdv - iznos popusta bez pdv
            nCjen2BPDV := nCjenBPDV - ( nIznPop / ( 1 + nPPDV / 100 ) )

            // procenat popusta
            nPopust := ( ( nIznPop / ( 1 + nPPDV / 100 ) ) / nCjenBPDV ) * 100

         ENDIF

         // izracunaj ukupno za stavku
         nUkupno :=  ( nKolicina * nCjenPDV ) - ( nKolicina * nIznPop )
         // izracunaj ukupnu vrijednost pdv-a
         nVPDV := ( ( nKolicina * nCjenBPDV ) - ( nKolicina * ( nIznPop / ( 1 + nPPDV / 100 ) ) ) ) * ( nPPDV / 100 )

         // ukupno bez pdv-a
         nUBPDV += nKolicina * nCjenBPDV
         // ukupno pdv
         nUPDV += nVPDV
         // total racuna
         nUTotal += nUkupno

         IF Round( nCjen2BPDV, 2 ) <> 0
            // ukupno popust
            nUPopust += ( nCjenBPDV - nCjen2BPDV ) * nKolicina
         ENDIF

         // ukupno bez pdv-a - popust
         nUBPDVPopust := nUBPDV - nUPopust


         ++ nCSum

         dodaj_stavku_racuna( cZBrDok, Str( nCSum, 3 ), "", cIdRoba, cRobaNaz, cJmj, nKolicina, Round( nCjenPDV, 3 ), Round( nCjenBPDV, 3 ), Round( nCjen2PDV, 3 ), Round( nCjen2BPDV, 3 ), Round( nPopust, 2 ), Round( nPPDV, 2 ), Round( nVPDV, 3 ), Round( nUkupno, 3 ), 0, 0 )
         SELECT POS
         SKIP
      ENDDO
      // --- zavrsio sa prolaskom kroz pos stavke --

      SELECT pos_doks
      SKIP
   ENDDO


   // dodaj zapis u drn.dbf
   add_drn( cZBrDok, dDatRn, nil, nil, cTime, ;
      Round( nUBPDV, 2 ), Round( nUPopust, 2 ), Round( nUBPDVPopust, 2 ), ;
      Round( nUPDV, 2 ), Round( nUTotal, 2 ), ;
      nCSum, 0, 0, 0 )

   // mjesto nastanka racuna
   add_drntext( "R01", gRnMjesto )
   // dodaj naziv radnika
   add_drntext( "R02", cRdnkNaz )

   // dodaj podatak o smjeni
   add_drntext( "R03", cSmjena )

   // vrsta placanja
   add_drntext( "R05", cNazVrstaP )

   // dodatni text na racunu 3 linije
   add_drntext( "R06", gRnPTxt1 )
   add_drntext( "R07", gRnPTxt2 )
   add_drntext( "R08", gRnPTxt3 )

   IF gStolovi == "D"
      // broj stola
      add_drntext( "R11", cBrStola )
      // vezni racuni
      add_drntext( "R12", cVezRacuni )
   ENDIF

   // Broj linija potrebnih da se ocjepi traka
   add_drntext( "P12", AllTrim( Str( nFeedLines ) ) )
   // sekv.za otvaranje ladice
   add_drntext( "P13", gOtvorStr )
   // sekv.za cjepanje trake
   add_drntext( "P14", gSjeciStr )

   // napuni podatke o maticnoj firmi - zaglavlje
   firma_params_fill()

   SELECT pos_dokspf
   SET ORDER TO TAG "1"
   HSEEK cIdPos + VD_RN + DToS( dDatRn ) + cBrDok

   add_drntext( "K01", dokspf->knaz )
   add_drntext( "K02", dokspf->kadr )
   add_drntext( "K03", dokspf->kidbr )
   // dodaj D01 - A - azuriran dokument
   add_drntext( "D01", "A" )

   // ispisi racun
   rb_print( .T. )

   CLOSE ALL

   RETURN


// -------------------------------
// -------------------------------
FUNCTION g_otv_stolovi()

   LOCAL nArr

   nArr := Select()

   o_pos_pos()
   o_pos_doks()
   SELECT pos_doks
   SET ORDER TO TAG "ZAK"
   GO TOP
   HSEEK gIdPos + "42"

   nTotal := 0
   nStoBr := 0
   aStolovi := {}
   DO WHILE !Eof() .AND. pos_doks->zak_br == 0
      nStoBr := pos_doks->sto_br
      DO WHILE !Eof() .AND. pos_doks->zak_br == 0 .AND. pos_doks->sto_br == nStoBr
         nTotal += Val( pos_iznos_dokumenta( .F. ) )
         SKIP
      ENDDO
      AAdd( aStolovi, { nStoBr, nTotal } )
      nTotal := 0
   ENDDO

   SELECT ( nArr )

   RETURN aStolovi

// ---------------------------
// ---------------------------
FUNCTION g_zak_sto()

   // {
   LOCAL nSelected := 0
   LOCAL nStoBr := 0
   LOCAL aStolovi := {}
   LOCAL nZakBr

   // daj listu otvorenih stolova
   aStolovi := g_otv_stolovi()

   nSelected := mnu_otv_stolovi( aStolovi )

   IF ( nSelected == NIL .OR. nSelected == 0 )
      RETURN .F.
   ENDIF

   // ovo je sto odabran u meniju
   nStoBr := aStolovi[ nSelected, 1 ]


   // postavi upit za broj stola
   Box(, 3, 30 )
   SET CURSOR ON
   @ m_x + 2, m_y + 6 SAY "Unesi broj stola:" GET nStoBr ;
      VALID ( nStoBr > 0 ) ;
      PICT "999"
   READ
   BoxC()

   IF LastKey() == K_ESC
      MsgBeep( "Prekinuta operacija zakljucenja stola !" )
      RETURN
   ENDIF

   // provjeri da nije ukucan broj stola koji nema racuna
   IF AScan( aStolovi, {| aVal| aVal[ 1 ] == nStoBr } ) == 0
      MsgBeep( "Za ovaj sto ne postoje otvoreni racuni !#Prekidam operaciju !" )
      RETURN
   ENDIF

   zak_sto( nStoBr )

   RETURN
// }

// --------------------------------
// --------------------------------
FUNCTION pr_otv_stolovi( aStol )

   // {

   IF Len( aStol ) == 0
      MsgBeep( "Nema nezakljucenih stolova !" )
      RETURN .F.
   ENDIF

   START PRINT CRET

   ? "Lista otvorenih stolova:"
   ?
   ?
   ? "  Sto       Iznos"
   ? "----- -----------"

   FOR i := 1 TO Len( aStol )
      ? aStol[ i, 1 ], aStol[ i, 2 ]
   NEXT

   ?

   FF
   ENDPRINT

   RETURN .T.
// }


// --------------------------------
// --------------------------------
FUNCTION mnu_otv_stolovi( aStol )

   LOCAL i
   LOCAL nSelected
   PRIVATE Opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor

   IF Len( aStol ) == 0
      MsgBeep( "Nema nezakljucenih stolova !" )
      RETURN 0
   ENDIF


   FOR i := 1 TO Len( aStol )
      cPom := Str( aStol[ i, 1 ], 3 ) + " - stanje : " + Str( aStol[ i, 2 ], 7, 2 )
      cPom := PadR( cPom, 30 )

      AAdd( opc, cPom )
      AAdd( opcexe, {|| nSelected := Izbor, Izbor := 0  } )
   NEXT

   Izbor := 1
   // 0 - ako se kaze <ESC>
   Menu_SC( "o_s" )

   RETURN nSelected


// --------------------------------
// --------------------------------
FUNCTION zak_sve_stolove()

   // {
   LOCAL nNextZak := 0
   LOCAL nArr
   LOCAL cNijeZaklj := "     0"
   LOCAL nNRec
   nArr := Select()

   IF !spec_funkcije_sifra( "ZAKSVE" )
      MsgBeep( "Nemate pravo na koristenje ove opcije!" )
      RETURN
   ENDIF

   o_pos_doks()
   nNextZak := g_next_zak_br()

   SELECT pos_doks
   SET ORDER TO TAG "ZAK"
   GO TOP
   SEEK gIdPos + "42" + cNijeZaklj

   DO WHILE !Eof() .AND. pos_doks->idpos == gIdPos .AND. pos_doks->idvd == "42" .AND. pos_doks->zak_br == 0
      nStoBr := pos_doks->sto_br
      DO WHILE !Eof() .AND. pos_doks->idpos == gIdPos .AND. pos_doks->idvd == "42" .AND. pos_doks->zak_br == 0 .AND. pos_doks->sto_br == nStoBr
         nTRec := RecNo()
         SKIP
         nNRec := RecNo()
         SKIP -1
         REPLACE zak_br WITH nNextZak
         GO ( nNRec )
      ENDDO
      ++ nNextZak
   ENDDO

   MsgBeep( "Izvrseno zakljucenje svih racuna !" )

   SELECT ( nArr )

   RETURN
// }


// info o prethodnom stanju stola nStoBr
FUNCTION g_stanje_stola( nStoBr )

   // {
   LOCAL nArr
   LOCAL cNijeZaklj := "     0"
   nArr := Select()
   o_pos_pos()
   o_pos_doks()
   SELECT pos_doks
   SET ORDER TO TAG "STO"
   HSEEK gIdPos + "42" + Str( nStoBr ) + cNijeZaklj

   nStanje := 0

   DO WHILE !Eof() .AND. pos_doks->idpos == gIdPos .AND. pos_doks->idvd == "42" .AND. pos_doks->sto_br == nStoBr
      IF pos_doks->zak_br == 0
         nStanje += Val( pos_iznos_dokumenta( .F. ) )
      ENDIF
      SKIP
   ENDDO

   SELECT ( nArr )

   RETURN nStanje
// }
