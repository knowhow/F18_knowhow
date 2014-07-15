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


#include "pos.ch"


// --------------------------------------------------------------------
// Ova funkcija se koristi i za Stampu zaduzenja i za stampu inventure
// --------------------------------------------------------------------
FUNCTION StampaInv( fLista, lAzurirana )

   // {
   LOCAL cRobaNaz
   LOCAL cJmj
   LOCAL cIdRoba
   LOCAL nCij
   LOCAL nCij2

   // koristi privatne vars:
   // Ako je  cIdvD = NI - nivelacija
   // cIdVD = IN - inventura
   //
   // stampa invenure / nivelacije

   LOCAL cPom, cNule := "D", cNiv := "N", nSir := 80, nRobSir := 29
   LOCAL aTarife := {}

   PRIVATE fInvent := .T.

   IF flista == NIL
      flista := .F.
   ENDIF
   IF lAzurirana == NIL
      lAzurirana := .F.
   ENDIF

   IF gVrstaRS <> "S"
      nSir := 40
   ENDIF

   SELECT PRIPRZ
   IF cIdVd == "IN"
      IF ! fLista
         cNule := Pitanje(, "Stampati stavke sa popisanom kolicinom 0  (D/N)?", "D" )
      ENDIF
      fInvent := .T.
   ELSE
      cNiv := Pitanje(, "Stampati samo stavke sa promijenjenom cijenom (D/N)?", "N" )
      fInvent := .F.
   ENDIF

   IF !lAzurirana
      GO TOP
   ENDIF

   START PRINT CRET

   IF gVrstaRS == "S"
      INI
   ENDIF

   cPom := iif ( fInvent, ;
      iif ( fLista, "Inventurna/popisna lista ", "INVENTURA " ), ;
      "NIVELACIJA " )
   IF gVrstaRS <> "S"
      cPom += AllTrim ( PRIPRZ->IdPos ) + "-"
   ENDIF

   ? PadC ( cPom + AllTrim ( PRIPRZ->BrDok ), nSir )
   ?
   SELECT ODJ
   HSEEK PRIPRZ->IdOdj
   IF gvodiodj == "D"
      ? PadC ( "Odjeljenje: " + AllTrim ( ODJ->Naz ), nSir )
   ENDIF

   SELECT PRIPRZ

   IF gPostDO == "D" .AND. ! Empty ( PRIPRZ->IdDio )
      SELECT DIO
      HSEEK PRIPRZ->IdDio
      ? PadC ( "Dio objekta: " + AllTrim ( DIO->Naz ), nSir )
      SELECT PRIPRZ
   ENDIF

   ?
   IF gVrstaRS == "S"
      P_10CPI
   ENDIF

   IF gVrstaRS <> "S"
      ?    " ------------- ---------------------- ---"
      ?    "  Sifra           Artikal             jmj"
      ?    " ------------- ---------------------- ---"
      IF fInvent
         ? " Knj. Kol  Pop.kol.   Cijena     +/-"
      ELSE
         ? "  Stanje          Cijena           Nova c."
      ENDIF
      IF fInvent
         m := "--------- --------- -------- ------------"
      ELSE
         m := "  ------------ ------------ ------------"
      ENDIF
   ELSE  // server
      ? " Sifra    Artikal"
      ?? Space ( 22 )
      ?
      ?? "   Stanje   "                 // ima jedan space ispred Stanje
      IF fInvent
         ?? "Popis.kol. Cijena    +/-"
      ELSE
         ?? "Cijena  Nova c."
      ENDIF
      IF fInvent
         m := " -------- ----------------------------- ---------- ---------- ------- --------"
      ELSE
         m := " -------- ----------------------------- ---------- ------- -------"
      ENDIF
   ENDIF

   ? m

   nCij := 0
   nKVr := nPopVr := 0
   nStVr := nNVR := 0

   SELECT PRIPRZ
   cBroj := DToS( datum ) + brdok   // stampaj broj

   DO WHILE !Eof() .AND. idvd == cidvd .AND.  cBroj == DToS( datum ) + brdok
      IF fLista .OR. ;
            ( cNiv == "N" .OR. ( cNiv == "D" .AND. PRIPRZ->cijena <> PRIPRZ->ncijena ) ) .AND. ;
            ( cNule == "D" .OR. ( cNule == "N" .AND. Kol2 <> 0 ) ) ;
            .AND.  ( Kolicina <> 0 .OR. Kol2 <> 0 )

         IF gVrstaRS == "S"
            IF PRow() > 63 -gPstranica - iif ( fLista, 2, 1 );  FF; ENDIF
         ENDIF


         cIdRoba := priprz->idroba
         nCij := PRIPRZ->cijena
         nCij2 := priprz->ncijena

         IF lAzurirana
            SELECT ( cRSdbf )
            hseek cIdRoba
            cRobaNaz := naz
            cJmj := jmj
            SELECT priprz
         ELSE
            cJmj := priprz->jmj
            cRobaNaz := priprz->robanaz
         ENDIF

         ? " " + cIdRoba
         ?? " " + PadR ( cRobaNaz, 23 )
         ?? " " + PadR ( "(" + cJmj + ")", 5 )


         IF gVrstaRS <> "S"
            ?
            IF fLista
               ?? " " + "________.___", "_________.___", Str ( nCij, 8, 2 )
            ELSE
               IF finvent
                  ? Str( kolicina, 9, 1 ), Str( kol2, 9, 1 ), ;
                     Str ( nCij, 8, 1 ), Str ( kolicina - kol2, 12, 2 )
                  ? m
               ELSE
                  // nivelacija
                  ? Str( kolicina, 14, 3 ), Str ( nCij, 12, 2 ), Str ( nCij2, 12, 2 )
                  ? m
               ENDIF
            ENDIF // flista
         ELSE  // idemo na server
            IF fLista
               ?? " " + "______.___", "______.___", Str ( nCij, 7, 2 )
            ELSE
               ?? " " + Str ( Kolicina, 10, 3 ), ""
               IF fInvent
                  ?? Str ( Kol2, 10, 3 ), ;
                     Str ( PRIPRZ->cijena, 7, 2 ), TRANS ( Kolicina - Kol2, "9999.99" )
               ELSE
                  // nivelacija
                  ?? Str ( nCij, 9, 2 ), Str ( nCij2, 9, 2 )
               ENDIF
            ENDIF // flista
         ENDIF // server

         nIzn := 0
         IF fInvent
            nKVr += nCij * Kolicina
            nPopVr += nCij * Kol2        // po starim cijenama
            nIzn := nCij * Kol2
         ELSE
            // nivelacija
            nStVr += nCij * Kolicina
            nNVr  += nCij2 * Kolicina
            nIzn := ( nCij2 - nCij ) * Kolicina
         ENDIF

         pos_setuj_tarife( PRIPRZ->IdRoba, nIzn, @aTarife )


      ENDIF // fLista .or. cnule=="N"
      SKIP
   ENDDO // !eof()

   IF !fLista .AND. fInvent
      IF gVrstaRS == "S"
         IF PRow() > 63 -gPStranica - 5
            FF
         ENDIF
      ENDIF
      ?
      ? "Ukupno knjizna  vrijednost:", Str( nKVr, 10, 2 )
      ? "Ukupno popisana vrijednost:", Str( nPopVr, 10, 2 )
      ?
      IF Round( nKVr - nPopVr, 3 ) <> 0
         IF nKvr - nPopVr > 0
            ? " Razlika MANJAK ...........", Str( nKVr - nPopVr, 10, 2 )
         ELSE
            ? " Razlika VISAK ............", Str( nKVr - nPopVr, 10, 2 )
         ENDIF
      ENDIF
   ENDIF

   IF !fLista .AND. Round( nStVr - nNVR, 3 ) <> 0
      nStVr += nPopVr
      nNVr  += nPopVr
      IF gVrstaRS == "S"
         IF PRow() > 63 -gPStranica - 7
            FF
         ENDIF
      ENDIF
      ?
      ? "PROMJENA CIJENA :"
      ?
      ? "Stara vrijednost zaliha ", Str( nStVr, 10, 2 )
      ? "Nova  vrijednost zaliha ", Str( nNVr, 10, 2 )
      ?
      ? "Razlika vrijednosti    :", Str( nNVr - nStVr, 10, 2 )
   ENDIF

   pos_rekapitulacija_tarifa( aTarife )

   IF gVrstaRS == "S"
      FF
   ELSE
      PaperFeed ()
   ENDIF

   END PRINT

   RETURN
// }

/*! \fn StampaPLI(cBrDok)
 */

FUNCTION StampaPLI( cBrDok )

   // {
   LOCAL cPom
   SELECT PRIPRZ                // invent
   GO TOP
   START PRINT RET
   cPom := "INVENTURNA-POPISNA LISTA BR. "
   IF gVrstaRS <> "S"
      cPom += AllTrim ( PRIPRZ->IdPos ) + "-"
   ENDIF
   ? PadC ( cPom + AllTrim ( cBrDok ), 40 )
   ?
   IF gvodiodj == "D"
      ? "Odjeljenje: " + PRIPRZ->IdOdj + "-" + Ocitaj( F_ODJ, IdOdj, "naz" )
   ENDIF
   ?
   ? "Sifra    Naziv robe"
   ? "            Stanje    Popisana kolicina"
   ? "----------------------------------------"
   DO WHILE ! Eof ()
      ? IdRoba + " " + RobaNaz
      ? Space ( 10 ) + Str ( Kolicina, 10, 3 ) + "  " + "____________,_____"
      ? "----------------------------------------"
      SKIP
   ENDDO
   PaperFeed ()
   END PRINT

   RETURN





FUNCTION PrepisInvNiv( fInvent )

   // prepisace azuriranu fakturu

   PRIVATE cIdOdj, cRsDBF, cRsBlok
   IF finvent
      PRIVATE cIdVd := "IN"
   ELSE
      PRIVATE cIdVd := "NI"
   ENDIF

   SELECT pos

   PushWa()
   USE

   SELECT pos_doks

   // otvori pos sa aliasom PRIPRZ, te je pozicioniraj na pravo mjesto
   SELECT ( F_POS )
   my_use( "priprz", "POS" )
   SET ORDER TO TAG "1"
   HSEEK pos_doks->( IdPos + IdVd + DToS( datum ) + BrDok )

   cIdOdj := priprz->idodj

   SELECT ODJ
   hseek cidodj

   IF ODJ->Zaduzuje == "S"
      cRSdbf := "SIROV"
      cRSblok := "P_Roba(@_IdRoba)"
      cUI_U   := S_U
      cUI_I   := S_I
   ELSE
      cRSdbf := "ROBA"
      cRSblok := "P_Roba(@_IdRoba)"
      cUI_U   := R_U
      cUI_I   := R_I
   ENDIF

   StampaInv( .F., .T. )  // drugi parametar kaze da se radi o azuriranom dok

   O_POS_DOKS
   O_POS

   PopWa()
   // vrati pos gdje je bio

   SELECT pos_doks

   RETURN
