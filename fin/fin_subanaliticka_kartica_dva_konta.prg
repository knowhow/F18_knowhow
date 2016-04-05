/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

/* fin_suban_kartica2(lOtvSt)
 *  Subanaliticka kartica kod koje se mogu navesti dva konta i vidjeti kroz jednu karticu
 *  lOtvSt
 */
FUNCTION fin_suban_kartica2( lOtvSt )

   LOCAL cBrza := "D"
   LOCAL nSirOp := 20
   LOCAL nCOpis := 0
   LOCAL cOpis := ""
   LOCAL nC1 := 35
   LOCAL _fin_params := fin_params()
   LOCAL _fakt_params := fakt_params()

   PRIVATE fOtvSt := lOtvSt

   cIdFirma := gFirma

   PRIVATE picBHD := FormPicL( gPicBHD, 16 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE qqKonto := qqKonto2 := qqPartner := ""

   O_PARAMS
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "y1", @qqKonto )
   RPar( "y2", @qqKonto2 )
   RPar( "y3", @qqPartner )

   O_KONTO
   O_PARTN

   PRIVATE cSazeta := "N"
   PRIVATE cK14 := "1"

   cDinDem := "1"
   dDatOd := dDatDo := CToD( "" )
   cKumul := cPredh := "1"

   IF PCount() == 0
      fOtvSt := .F.
   ENDIF
   IF gNW == "D"
      cIdFirma := gFirma
   ENDIF

   cK1 := cK2 := "9"
   cK3 := cK4 := "99"

   cPoVezi := "N"
   cNula := "N"

   Box( "", 18, 65 )
   SET CURSOR ON
   IF fOtvSt
      @ m_x + 1, m_y + 2 SAY "KARTICA OTVORENIH STAVKI KONTO/KONTO2"
   ELSE
      @ m_x + 1, m_y + 2 SAY8 "SUBANALITIČKA KARTICA"
   ENDIF
   @ m_x + 2, m_y + 2 SAY "BEZ/SA kumulativnim prometom  (1/2):" GET cKumul
   @ m_x + 4, m_y + 2 SAY8 "Sažeta kartica (bez opisa) D/N" GET cSazeta  PICT "@!" VALID cSazeta $ "DN"
   READ
   DO WHILE .T.
      IF gNW == "D"
         @ m_x + 5, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 5, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      cPrelomljeno := "N"
      IF cBrza = "D"
         qqKonto := PadR( qqKonto, 7 )
         qqKonto2 := PadR( qqKonto2, 7 )
         qqPartner := PadR( qqPartner, 6 )
         @ m_x + 6, m_y + 2 SAY "Konto   " GET qqKonto  VALID P_KontoFin( @qqKonto )
         @ m_x + 7, m_y + 2 SAY "Konto 2 " GET qqKonto2  VALID P_KontoFin( @qqKonto2 ) .AND. qqKonto2 > qqkonto
         @ m_x + 8, m_y + 2 SAY "Partner (prazno svi)" GET qqPartner valid ( ";" $ qqpartner ) .OR. Empty( qqPartner ) .OR. P_Firma( @qqPartner )  PICT "@!"
      ENDIF

      @ m_x + 9, m_y + 2 SAY "Datum dokumenta od:" GET dDatod
      @ m_x + 9, Col() + 2 SAY "do" GET dDatDo   VALID dDatOd <= dDatDo

      IF fin_dvovalutno()
         @ m_x + 10, m_y + 2 SAY "Kartica za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3)"  GET cDinDem VALID cDinDem $ "123"
      ENDIF

      @ m_x + 11, m_y + 2 SAY "Sabrati po brojevima veze D/N ?"  GET cPoVezi VALID cPoVezi $ "DN" PICT "@!"
      @ m_x + 11, Col() + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cprelomljeno $ "DN" PICT "@!"
      @ m_x + 12, m_y + 2 SAY "Prikaz  K1-K4 (1); Dat.Valute (2); oboje (3)"  GET cK14 VALID cK14 $ "123"

      IF _fin_params[ "fin_k1" ]
         @ m_x + 14, m_y + 2 SAY "K1 (9 svi) :" GET cK1
      ENDIF
 		
      IF _fin_params[ "fin_k2" ]
         @ m_x + 15, m_y + 2 SAY "K2 (9 svi) :" GET cK2
      ENDIF

      IF _fin_params[ "fin_k3" ]
         @ m_x + 16, m_y + 2 SAY "K3 (" + cK3 + " svi):" GET cK3
      ENDIF

      IF _fin_params[ "fin_k4" ]
         @ m_x + 17, m_y + 2 SAY "K4 (99 svi):" GET cK4
      ENDIF

      @ m_x + 18, m_Y + 2 SAY "Prikaz kartica sa 0 stanjem " GET cNula VALID cNula $ "DN" PICT "@!"
      READ
      ESC_BCR

      IF cSazeta == "N"
         IF cDinDem == "3"
            nC1 := 68
         ELSE
            nC1 := 72
         ENDIF
      ENDIF

      IF cDinDem == "3"
         cKumul := "1"
      ENDIF

      IF cBrza == "D"
         EXIT
      ELSE
         qqKonto := Trim( qqKonto )
         qqPartner := Trim( qqPartner )
         EXIT
      ENDIF
   ENDDO
   BoxC()

   SELECT params
   // zapamti konto i konto2
   WPar( "y1", @qqKonto )
   WPar( "y2", @qqKonto2 )
   WPar( "y3", @qqPartner )

   IF cSazeta == "D"
      PRIVATE picBHD := FormPicL( gPicBHD, 14 )
   ENDIF


   IF cDinDem == "3"
      IF cSazeta == "D"
         m := "------- -- -------- ---------- -------- -------- -------------- -------------- -------------- ------------ ------------ ------------"
      ELSE
         IF gNW == "N"
            m := "------- -- -------- ---- ---------------- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ELSE
            m := "------- -- -------- ---- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ENDIF
      ENDIF
   ELSEIF cKumul == "1"
      IF cSazeta == "D"
         M := "------- -- -------- ---------- -------- -------- -------------- -------------- --------------"
      ELSE
         IF gNW == "N"
            M := "------- -- -------- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
         ELSE
            M := "------- -- -------- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ----------------"
         ENDIF
      ENDIF
   ELSE
      IF cSazeta == "D"
         M := "------- -- -------- ---------- -------- -------- -------------- -------------- -------------- -------------- ---------------"
      ELSE
         IF gNW == "N"
            M := "------- -- -------- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
         ELSE
            M := "------- -- -------- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ----------------"
         ENDIF
      ENDIF
   ENDIF

   lVrsteP := .F.

   IF _fakt_params[ "fakt_vrste_placanja" ]
      lVrsteP := .T.
      O_VRSTEP
   ENDIF

   O_SUBAN
   O_TDOK

   SELECT SUBAN

   IF cPoVezi == "D"

      // "IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)"
      SET ORDER TO TAG "3"

   ENDIF

   IF cK1 == "9"
      cK1 := ""
   ENDIF

   IF cK2 == "9"
      cK2 := ""
   ENDIF

   IF ck3 == REPL( "9", Len( cK3 ) )
      ck3 := ""
   ELSE
      cK3 := K3U256( cK3 )
   ENDIF
   IF ck4 == "99"; ck4 := ""; ENDIF

   PRIVATE cFilter

   cFilter := ".t." + IF( Empty( dDatOd ), "", ".and.DATDOK>=" + dbf_quote( dDatOd ) ) + ;
      iif( Empty( dDatDo ), "", ".and.DATDOK<=" + dbf_quote( dDatDo ) )

   IF ! ( _fin_params[ "fin_k1" ] .AND. _fin_params[ "fin_k2" ] .AND. _fin_params[ "fin_k3" ] .AND.  _fin_params[ "fin_k4" ] )
      cFilter := cFilter + ".and.k1=" + dbf_quote( ck1 ) + ".and.k2=" + dbf_quote( ck2 ) + ;
         ".and.k3=ck3.and.k4=" + dbf_quote( ck4 )
   ENDIF

   IF ";" $ qqpartner
      qqPartner := StrTran( qqpartner, ";", "" )
      cFilter += ".and. idpartner='" + Trim( qqpartner ) + "'"
      qqpartner := ""
   ENDIF

   cFilter := StrTran( cFilter, ".t..and.", "" )

   IF cfilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF


   nStr := 0

   IF Empty( qqpartner )
      qqPartner := Trim( qqpartner )
   ENDIF

   SEEK cidfirma + qqkonto + qqpartner
   IF !Found() // nema na 1200
      SEEK cidfirma + qqkonto2 + qqpartner
   ENDIF

   NFOUND CRET

   start_print_close_ret()


   nSviD := nSviP := nSviD2 := nSviP2 := 0

   nKonD := nKonP := nKonD2 := nKonP2 := 0
   cIdKonto := IdKonto

   nProlaz := 0

   IF Empty( qqpartner )  // prodji tri puta
      nProlaz := 1
      HSEEK cidfirma + qqkonto
      IF Eof()
         nProlaz := 2
         HSEEK cidfirma + qqkonto2
      ENDIF
   ENDIF

   DO WHILE .T.

      IF !Eof() .AND. idfirma == cIdFirma .AND. ;
            ( ( nProlaz = 0 .AND. ( idkonto == qqkonto .OR. idkonto == qqkonto2 ) )  .OR. ;
            ( nProlaz = 1 .AND. idkonto = qqkonto ) .OR. ;
            ( nProlaz = 2 .AND. idkonto = qqkonto2 ) ;
            )
      ELSE
         EXIT
      ENDIF


      nPDugBHD := nPPotBHD := nPDugDEM := nPPotDEM := 0  // prethodni promet
      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
      nZDugBHD := nZPotBHD := nZDugDEM := nZPotDEM := 0
      cIdPartner := IdPartner


      fZaglavlje := .F.
      fProsao := .F.
      DO WHILE !Eof() .AND. IdFirma == cIdFirma .AND. cIdPartner == idpartner .AND. ( idkonto == qqkonto .OR. idkonto == qqkonto2 )

         cIdKonto := idkonto
         cOtvSt := OtvSt
         IF !( fOtvSt .AND. cOtvSt == "9" )
            fprosao := .T.
            IF !fzaglavlje
               IF PRow() > 55 + dodatni_redovi_po_stranici()
                  FF; ZaglSif2( .T. )
               ELSE
                  ZaglSif2( iif( nstr = 0, .T., .F. ) )
               ENDIF
               fzaglavlje := .T.
            ENDIF
            ? cidkonto, IdVN
            @ PRow(), PCol() + 1 SAY BrNal
            IF cSazeta == "N"
               @ PRow(), PCol() + 1 SAY RBr
               IF gNW == "N"
                  @ PRow(), PCol() + 1 SAY IdTipDok
                  SELECT TDOK
                  HSEEK SUBAN->IdTipDok
                  @ PRow(), PCol() + 1 SAY naz
               ENDIF
            ENDIF
            SELECT SUBAN
            @ PRow(), PCol() + 1 SAY PadR( BrDok, 10 )
            @ PRow(), PCol() + 1 SAY DatDok
            IF ck14 == "1"
               @ PRow(), PCol() + 1 SAY k1 + "-" + k2 + "-" + K3Iz256( k3 ) + k4
            ELSEIF ck14 == "2"
               @ PRow(), PCol() + 1 SAY DatVal
            ELSE
               nC7 := PCol() + 1
               @ PRow(), nc7 SAY DatVal
            ENDIF

            IF cSazeta == "N"
               IF cDinDem == "3"
                  nSirOp := 16; nCOpis := PCol() + 1
                  @ PRow(), PCol() + 1 SAY Left( cOpis := AllTrim( Opis ), 16 )
               ELSE
                  nSirOp := 20; nCOpis := PCol() + 1
                  @ PRow(), PCol() + 1 SAY PadR( cOpis := AllTrim( Opis ), 20 )
               ENDIF
            ENDIF

            nC1 := PCol() + 1
         ENDIF // fOtvStr

         nDBHD := nPBHD := nDDEM := nPDEM := 0
         IF cPovezi == "D"
            cBrDok := brdok
            DO WHILE !Eof() .AND. IdFirma == cIdFirma .AND. cIdpartner == idpartner .AND. ( idkonto == qqkonto .OR. idkonto == qqkonto2 ) .AND. brdok == cBrdok
               IF D_P == "1"
                  nDBHD += iznosbhd
                  nDDEM += iznosdem
               ELSE
                  nPBHD += iznosbhd
                  nPDEM += iznosdem
               ENDIF
               SKIP
            ENDDO
            IF cPrelomljeno == "D"
               Prelomi( @nDBHD, @nPBHD )
               Prelomi( @nDDEM, @nPDEM )
            ENDIF
         ELSE
            IF D_P == "1"
               nDBHD += iznosbhd; nDDEM += iznosdem
            ELSE
               nPBHD += iznosbhd; nPDEM += iznosdem
            ENDIF
         ENDIF
         IF cDinDem == "1"
            IF fOtvSt .AND. cOtvSt == "9"
               nZDugBHD += nDBHD
               nZPotBHD += nPBHD
            ELSE
               @ PRow(), PCol() + 1 SAY nDBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPBHD  PICTURE picBHD
               nDugBHD += nDBHD
               nPotBHD += nPBHD
               IF cKumul == "2"
                  @ PRow(), PCol() + 1 SAY nDugBHD PICT picbhd
                  @ PRow(), PCol() + 1 SAY nPotBHD PICT picbhd
               ENDIF
            ENDIF
         ELSEIF cDinDem == "2"

            IF fOtvSt .AND. cOtvSt == "9"
               nZDugDEM += nDDEM
               nZPotDEM += nPDEM
            ELSE 
               @ PRow(), PCol() + 1 SAY nDDEM PICTURE picbhd
               @ PRow(), PCol() + 1 SAY nPDEM PICTURE picbhd
               nDugDEM += nDDEM
               nPotDEM += nPDEM
               IF cKumul == "2"
                  @ PRow(), PCol() + 1 SAY nDugDEM PICT picbhd
                  @ PRow(), PCol() + 1 SAY nPotDEM PICT picbhd
               ENDIF
            ENDIF
         ELSEIF cDinDem == "3"
            IF fOtvSt .AND. cOtvSt == "9"
               nZDugBHD += nDBHD; nZDugDEM += nDDEM
               nZPotBHD += nPBHD; nZPotDEM += nPDEM
            ELSE
               @ PRow(), PCol() + 1 SAY nDBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPBHD PICTURE picBHD
               nDugBHD += nDBHD
               nPotBHD += nPBHD
               @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd

               @ PRow(), PCol() + 1 SAY nDDEM PICTURE picdem
               @ PRow(), PCol() + 1 SAY nPDEM PICTURE picdem
               nDugDEM += nDDEM
               nPotDEM += nPDEM
               @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picdem
            ENDIF
         ENDIF

         IF !( fOtvSt .AND. cOtvSt == "9" )
            
            IF cDinDem = "1"
               @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
            ELSEIF cDinDem == "2"
               @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
            ENDIF

            OstatakOpisa( @cOpis, nCOpis, {|| iif( PRow() > 60 + dodatni_redovi_po_stranici(), Eval( {|| gPFF(), ZaglSif2() } ), ) }, nSirOp )
            IF ck14 == "3"
               @ PRow() + 1, nc7 SAY k1 + "-" + k2 + "-" + K3Iz256( k3 ) + k4
            ENDIF
         ENDIF
         OstatakOpisa( @cOpis, nCOpis, {|| iif( PRow() > 60 + dodatni_redovi_po_stranici(), Eval( {|| gPFF(), ZaglSif2() } ), ) }, nSirOp )
         IF cPoVezi <> "D"
            SKIP
         ENDIF
         IF nprolaz = 0 .OR. nProlaz = 1
            IF ( idkonto <> cidkonto .OR. idpartner <> cIdpartner ) .AND. cidkonto == qqkonto
               HSEEK cidfirma + qqkonto2 + cIdpartner
            ENDIF
         ENDIF

      ENDDO

      IF cNula == "D" .OR. fprosao .OR.   Round( nZDugBHD - nZPotBHD, 2 ) <> 0

         IF !fzaglavlje
            IF PRow() > 55 + dodatni_redovi_po_stranici()
               FF; ZaglSif2( .T. )
            ELSE
               ZaglSif2( iif( nstr = 0, .T., .F. ) )
            ENDIF
            fzaglavlje := .T.
         ENDIF
         ? M
         ? "UKUPNO:"

         IF cDinDem == "1"
            @ PRow(), nC1      SAY nDugBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
            IF cKumul == "2"
               @ PRow(), PCol() + 1 SAY nDugBHD PICT picbhd
               @ PRow(), PCol() + 1 SAY nPotBHD PICT picbhd
            ENDIF
            @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
         ELSEIF cDinDem == "2"
            @ PRow(), nC1      SAY nDugDEM PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picBHD
            IF cKumul == "2"
               @ PRow(), PCol() + 1 SAY nDugDEM PICT picbhd
               @ PRow(), PCol() + 1 SAY nPotDEM PICT picbhd
            ENDIF
            @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
         ELSEIF  cDinDem == "3"
            @ PRow(), nC1      SAY nDugBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd

            @ PRow(), PCol() + 1      SAY nDugDEM PICTURE picdem
            @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picdem
            @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picdem
         ENDIF


         IF fOtvST
            ? "Promet zatvorenih stavki:"
            IF cDinDem == "1"
               @ PRow(), nC1      SAY nZDugBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZPotBHD PICTURE picBHD
               IF cKumul == "2"
                  @ PRow(), PCol() + 1 SAY nZDugBHD PICT picbhd
                  @ PRow(), PCol() + 1 SAY nZPotBHD PICT picbhd
               ENDIF
               @ PRow(), PCol() + 1 SAY nZDugBHD - nZPotBHD PICT picbhd
            ELSEIF cDinDem == "2"
               @ PRow(), nC1      SAY nZDugDEM PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZPotDEM PICTURE picBHD
               IF cKumul == "2"
                  @ PRow(), PCol() + 1 SAY nZDugDEM PICT picbhd
                  @ PRow(), PCol() + 1 SAY nZPotDEM PICT picbhd
               ENDIF
               @ PRow(), PCol() + 1 SAY nZDugDEM - nZPotDEM PICT picbhd
            ELSEIF  cDinDem == "3"
               @ PRow(), nC1      SAY nZDugBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZPotBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZDugBHD - nZPotBHD PICT picbhd

               @ PRow(), PCol() + 1 SAY nZDugDEM PICTURE picdem
               @ PRow(), PCol() + 1 SAY nZPotDEM PICTURE picdem
               @ PRow(), PCol() + 1 SAY nZDugDEM - nZPotDEM PICT picdem
            ENDIF
         ENDIF

         ? m
      ENDIF

      nKonD += nDugBHD;  nKonP += nPotBHD
      nKonD2 += nDugDEM; nKonP2 += nPotDEM

      IF nProlaz = 0
         EXIT
      ELSEIF nprolaz == 1
         SEEK cidfirma + qqkonto + cidpartner + Chr( 255 )
         IF qqkonto <> idkonto
            nProlaz := 2
            SEEK cidfirma + qqkonto2
            cIdpartner := Replicate( CHR( 255 ), Len( idpartner ) )
            IF !Found()
               EXIT
            ENDIF
         ENDIF
      ENDIF


      IF nProlaz == 2
         DO WHILE .T.
            SEEK cidfirma + qqkonto2 + cIdpartner + Chr( 255 )
            nTRec := RecNo()
            IF idkonto == qqkonto2
               cIdPartner := idpartner
               HSEEK cidfirma + qqkonto + cIdpartner
               IF !Found()
                  GO nTRec
                  EXIT
               ELSE
                  LOOP
               ENDIF
            ENDIF
            EXIT
         ENDDO
      ENDIF

      ?
      ?
      ?
   ENDDO
   FF
   end_print()
   closeret

   RETURN



/*
    ZaglSif2(fStrana)
    Zaglavlje subanaliticke kartice 2
    fStrana
 */

FUNCTION ZaglSif2( fStrana )

   ?
   IF cDinDem == "3"  .OR. cKumul == "2"
      P_COND2
   ELSE
      P_COND
   ENDIF

   IF fOtvSt
      ??U "FIN: KARTICA OTVORENIH STAVKI KONTO/KONTO2 "
   ELSE
      ??U "FIN: SUBANALITIČKA KARTICA  ZA "
   ENDIF

   ?? iif( cDinDem == "1", AllTrim( ValDomaca() ), iif( cDinDem == "2", AllTrim( ValPomocna() ), AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) ) ), " NA DAN:", Date()
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "   ZA PERIOD OD", dDatOd, "DO", dDatDo
   ENDIF
   IF fstrana
      @ PRow(), 125 SAY "Str." + Str( ++nStr, 5 )
   ENDIF

   IF gNW == "D"
      ? "Firma:", gFirma, "-", gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cIdFirma, AllTrim( partn->naz ), AllTrim( partn->naz2 )
   ENDIF


   SELECT PARTN; HSEEK cIdPartner
   ? "PARTNER:", cIdPartner, AllTrim( partn->naz ), AllTrim( partn->naz2 )

   SELECT SUBAN

   IF cDinDem == "3"
      IF cSazeta == "D"
         ?  "------- ----------- --------------------------- ---------------------------- -------------- -------------------------- ------------"
         ?  "*KONTO * NALOG     *     D O K U M E N T        *      PROMET  " + ValDomaca() + "          *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO   *"
         ?  "*       ----------- ------------------- -------- -----------------------------     " + ValDomaca() + "     * -------------------------    " + ValPomocna() + "    *"
         ?  "*      * V.* BR    *   BROJ   * DATUM  *" + iif( cK14 == "1", " K1-K4 ", " VALUTA" ) + ;
            "*     DUG     *      POT     *              *      DUG    *   POT      *           *"
         ?  "*      * N.*       *          *        *       *                            *              *             *            *           *"
      ELSE
         IF gNW == "N"
            ?  "------- ---------------- -------------------------------------------------------------- --------------------------------- -------------- -------------------------- --------------"
            ?  "*KONTO *   NALOG        *                    D  O  K  U  M  E  N  T                    *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO     *"
            ?  "*       ---------------- ------------------------------------ -------- ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "     *"
            ?  "*      * V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *             *"
            ?  "*      * N.*       * Br.*     NAZIV      *          *        *        *                *               *                 *              *             *            *             *"
         ELSE
            ?  "------- ---------------- --------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
            ?  "*KONTO *   NALOG        *           D O K U M E N T                   *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO     *"
            ?  "*       ---------------- ------------------- -------- ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "     *"
            ?  "*      * V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *             *"
            ?  "*      * N.*       * Br.*          *        *        *                *               *                 *              *             *            *             *"
         ENDIF
      ENDIF
   ELSEIF cKumul == "1"
      IF cSazeta == "D"
         ?  "------- ------------ ---------------------------- --------------------------- ---------------"
         ?  "*KONTO *  NALOG     *      D O K U M E N T       *       P R O M E T         *    SALDO      *"
         ?  "*       ------------ ------------------- -------- ---------------------------                *"
         ?  "*      * V.*BR      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    DUGUJE   *   POTRA¦UJE  *              *"
         ?  "*      * N.*        *          *        *        *            *              *               *"
      ELSE
         IF gNW == "N"
            ?  "------- ---------------- ------------------------------------------------------------------ ---------------------------------- ----------------"
            ?  "*KONTO *   NALOG        *                    D  O  K  U  M  E  N  T                        *           P R O M E T            *    SALDO      *"
            ?  "*       ---------------- ------------------------------------ -------- -------------------- ----------------------------------                *"
            ?  "*      * V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRA¦UJE     *               *"
            ?  "*      * N.*       * Br.*     NAZIV      *          *        *        *                    *               *                  *               *"
         ELSE
            ?  "------- ---------------- ------------------------------------------------- ---------------------------------- ---------------"
            ?  "*KONTO *   NALOG        *              D  O  K  U  M  E  N  T             *           P R O M E T            *    SALDO      *"
            ?  "*       ---------------- ------------------- -------- -------------------- ----------------------------------                *"
            ?  "*      * V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRA¦UJE     *               *"
            ?  "*      * N.*       * Br.*          *        *        *                    *               *                  *               *"
         ENDIF
      ENDIF
   ELSE
      IF cSazeta == "D"
         ?U  "------- ----------- ---------------------------- --------------------------- ------------------------------ ---------------"
         ?U  " KONTO * NALOG     *      D O K U M E N T       *        P R O M E T        *      K U M U L A T I V       *    SALDO     *"
         ?U  "        ----------- -------------------- -------- --------------------------- ------------------------------              *"
         ?U  "       * V.*BR     *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*   DUGUJE    *  POTRAŽUJE   *    DUGUJE    *  POTRAŽUJE   *              *"
         ?U  "       *           *          *        *        *             *              *              *              *              *"
      ELSE
         IF gNW == "N"
            ?U  "------- ---------------- ------------------------------------------------------------------ ---------------------------------- ---------------------------------- ---------------"
            ?U  "*KONTO *   NALOG        *                    D  O  K  U  M  E  N  T                        *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
            ?U  "*       ---------------- ------------------------------------ -------- -------------------- ---------------------------------- ----------------------------------               *"
            ?U  "*      * V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAŽUJE     *    DUGUJE     *    POTRAŽUJE     *              *"
            ?U  "*      * N.*       * Br.*     NAZIV      *          *        *        *                    *               *                  *               *                  *              *"
         ELSE
            ?U  "------- ---------------- ------------------------------------------------- ---------------------------------- ---------------------------------- ----------------"
            ?U  "*KONTO *   NALOG        *            D O K U M E N T                      *           P R O M E T            *           K U M U L A T I V      *    SALDO      *"
            ?  "*       ---------------- ------------------- -------- -------------------- ---------------------------------- ----------------------------------                *"
            ?U  "*      * V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAŽUJE     *    DUGUJE     *    POTRAŽUJE     *               *"
            ?U  "*      * N.*       * Br.*          *        *        *                    *               *                  *               *                  *               *"
         ENDIF
      ENDIF
   ENDIF
   ? m

   RETURN
