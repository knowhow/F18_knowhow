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


FUNCTION fin_otvorene_stavke_meni()

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE gnLost := 0

   AAdd( opc, "1. ručno zatvaranje                                 " )
   AAdd( opcexe, {|| fin_rucno_zatvaranje_otvorenih_stavki() } )

   AAdd( opc, "2. automatsko zatvaranje" )
   AAdd( opcexe, {|| fin_automatsko_zatvaranje_otvorenih_stavki() } )

   AAdd( opc, "3. kartica otvorenih stavki" )
   AAdd( opcexe, {|| fin_suban_kartica( .T. ) } )

   AAdd( opc, "4. usporedna kartica dva konta" )
   AAdd( opcexe, {|| fin_suban_kartica2( .T. ) } )

   AAdd( opc, "5. specifikacija otvorenih stavki" )
   AAdd( opcexe, {|| fin_specif_otvorene_stavke() } )

   AAdd( opc, "6. ios" )
   AAdd( opcexe, {|| IOS() } )
   AAdd( opc, "7. kartice grupisane po brojevima veze" )
   AAdd( opcexe, {|| fin_kartica_otvorene_stavke_po_broju_veze( .T. ) } )

   AAdd( opc, "8. kompenzacija" )
   AAdd( opcexe, {|| Kompenzacija() } )

   //AAdd( opc, "9. asistent otvorenih stavki" )
   //AAdd( opcexe, {|| fin_asistent_otv_st() } )

   AAdd( opc, "B. brisanje svih markera otvorenih stavki" )
   AAdd( opcexe, {|| fin_brisanje_markera_otvorenih_stavki() } )

   Izbor := 1
   f18_menu_sa_priv_vars_opc_opcexe_izbor( "oas" )

   RETURN .T.





FUNCTION fin_brisanje_markera_otvorenih_stavki()

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hParams, cSql

   IF Pitanje(, "Pobrisati sve markere otvorenih stavki (D/N) ?", "N" ) == "N"
      RETURN .F.
   ENDIF

   IF Pitanje(, "Jeste li sigurni ?!", "N" ) == "N"
      RETURN .F.
   ENDIF
   cSql := "update fmk.fin_suban set otvst=' ' where otvst='9'; select count(*) from fmk.fin_suban where otvst='9'"
   MsgO( "Brisanje markera... molimo sačekajte trenutak ..." )
   lRet := use_sql( "del_ostav", cSql )
   MsgC()

   MsgBeep( "ostav cnt=" + STR(del_ostav->count,5) )

   RETURN lRet








/* fin_kartica_otvorene_stavke_po_broju_veze(fSolo,fTiho,bFilter)
 *     Otvorene stavke grupisane po brojevima veze
 *   param: fSolo
 *   param: fTiho
 *   param: bFilter - npr. {|| getmjesto(cMjesto)}
 */

FUNCTION fin_kartica_otvorene_stavke_po_broju_veze( fSolo, fTiho, bFilter )

   LOCAL nCol1 := 72, cSvi := "N", cSviD := "N", lEx := .F.

   IF fTiho == NIL
      fTiho := .F.
   ENDIF

   PRIVATE cIdPartner

   cDokument := Space( 8 )
   picBHD := FormPicL( gPicBHD, 14 )
   picDEM := FormPicL( gPicDEM, 10 )

   IF fTiho .OR. Pitanje(, "Želite li prikaz sa datumima dokumenta i valutiranja ? (D/N)", "D" ) == "D"
      lEx := .T.
   ENDIF

   IF fsolo == NIL
      fSolo := .F.
   ENDIF

   IF fin_dvovalutno()
      M := "----------- ------------- -------------- -------------- ---------- ---------- ---------- --"
   ELSE
      M := "----------- ------------- -------------- -------------- --"
   ENDIF

   IF lEx
      m := "-------- -------- -------- " + m
   ENDIF

   nStr := 0
   fVeci := .F.
   cPrelomljeno := "N"

   IF fTiho

      cSvi := "D"

   ELSEIF fsolo

      o_suban()
      O_PARTN
      O_KONTO
      cIdFirma := self_organizacija_id()
      cIdkonto := Space( 7 )
      cIdPartner := Space( 6 )

      Box(, 5, 60 )
      IF gNW == "D"
         @ m_x + 1, m_y + 2 SAY "Firma "; ?? self_organizacija_id(), "-", self_organizacija_naziv()
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Konto:               " GET cIdkonto   PICT "@!"  VALID P_kontoFin( @cIdkonto )
      @ m_x + 3, m_y + 2 SAY "Partner (prazno svi):" GET cIdpartner PICT "@!"  VALID Empty( cIdpartner )  .OR. ( "." $ cidpartner ) .OR. ( ">" $ cidpartner ) .OR. p_partner( @cIdPartner )
      @ m_x + 5, m_y + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cPrelomljeno $ "DN" PICT "@!"
      READ
      ESC_BCR
      Boxc()
   ELSE
      IF Pitanje(, "Želite li napraviti ovaj izvjestaj za sve partnere ?", "N" ) == "D"
         cSvi := "D"
      ENDIF
   ENDIF

   IF !fTiho .AND. Pitanje(, "Prikazati dokumente sa saldom 0 ?", "N" ) == "D"
      cSviD := "D"
   ENDIF

   IF fTiho
      // onda svi
   ELSEIF !fsolo

      IF Type( 'TB' ) = "O"
         IF ValType( aPPos[ 1 ] ) = "C"
            PRIVATE cIdPartner := aPPos[ 1 ]
         ELSE
            PRIVATE cIdPartner := Eval( TB:getColumn( aPPos[ 1 ] ):Block )
         ENDIF
      ENDIF

   ELSE

      IF "." $ cidpartner
         cidpartner := StrTran( cidpartner, ".", "" )
         cIdPartner := Trim( cidPartner )
      ENDIF

      IF ">" $ cidpartner
         cidpartner := StrTran( cidpartner, ">", "" )
         cIdPartner := Trim( cidPartner )
         fVeci := .T.
      ENDIF

      IF Empty( cIdpartner )
         cidpartner := ""
      ENDIF

      cSvi := cIdpartner

   ENDIF

   IF fTiho .OR. lEx

      SELECT ( F_TRFP2 )
      IF !Used()
         O_TRFP2
      ENDIF

      HSEEK "99 " + Left( cIdKonto, 1 )
      DO WHILE !Eof() .AND. IDVD == "99" .AND. Trim( idkonto ) != Left( cIdKonto, Len( Trim( idkonto ) ) )
         SKIP 1
      ENDDO

      IF IDVD == "99" .AND. Trim( idkonto ) == Left( cIdKonto, Len( Trim( idkonto ) ) )
         cDugPot := D_P
      ELSE
         cDugPot := "1"
         Box( , 3, 60 )
         @ m_x + 2, m_y + 2 SAY8 "Konto " + cIdKonto + " duguje / potražuje (1/2)" GET cdugpot  VALID cdugpot $ "12" PICT "9"
         READ
         Boxc()
      ENDIF

      fin_create_pom_table( fTiho )

   ENDIF


   IF !fTiho
      START PRINT RET
   ENDIF

   nUkDugBHD := nUkPotBHD := 0

   // SELECT suban
   // SET ORDER TO TAG "3"

   IF cSvi == "D"
      find_suban_by_konto_partner(  cIdFirma, cIdkonto, NIL, NIL, "IdFirma,IdKonto,IdPartner,brdok" )

   ELSE
      find_suban_by_konto_partner(  cIdFirma, cIdkonto, cIdPartner, NIL, "IdFirma,IdKonto,IdPartner,brdok" )
   ENDIF

   DO WHILE !Eof() .AND. idfirma == cIdfirma .AND. cIdKonto == IdKonto

      IF bFilter <> NIL
         IF !Eval( bFilter )
            SKIP
            LOOP
         ENDIF
      ENDIF

      cIdPartner := idpartner

      nUDug2 := nUPot2 := 0
      nUDug := nUPot := 0
      fPrviprolaz := .T.

      DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner

         IF bFilter <> NIL
            IF !Eval( bFilter )
               SKIP
               LOOP
            ENDIF
         ENDIF

         cBrDok := BrDok
         cOtvSt := otvst
         nDug2 := nPot2 := 0
         nDug := nPot := 0
         aFaktura := { CToD( "" ), CToD( "" ), CToD( "" ) }

         DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner ;
               .AND. brdok == cBrDok
            IF D_P == "1"
               nDug += IznosBHD
               nDug2 += IznosDEM
            ELSE
               nPot += IznosBHD
               nPot2 += IznosDEM
            ENDIF

            IF lEx .AND. D_P == cDugPot
               aFaktura[ 1 ] := DATDOK
               aFaktura[ 2 ] := fix_dat_var( DATVAL, .T. )
            ENDIF

            IF fTiho
               // poziv iz procedure RekPPG()
               // za izvjestaj maksuz radjen za Opresu³22.03.01.³
               // ------------------------------------ÀÄ MSÄÄÄÄÄÙ
               IF aFaktura[ 3 ] < iif( Empty( fix_dat_var( DATVAL, .T. ) ), DatDok, DatVal )
                  // datum zadnje promjene iif ubacen 03.11.2000 eh
                  // ----------------------------------------------
                  aFaktura[ 3 ] := iif( Empty( fix_dat_var( DATVAL, .T. ) ), DatDok, DatVal )
               ENDIF
            ELSE
               // kao u asist.otv.stavki - koristi npr. Exclusive³22.03.01.³
               // -----------------------------------------------ÀÄ MSÄÄÄÄÄÙ
               IF aFaktura[ 3 ] < DatDok
                  aFaktura[ 3 ] := DatDok
               ENDIF
            ENDIF

            SKIP 1
         ENDDO

         IF cSvid == "N" .AND. Round( nDug - nPot, 2 ) == 0
            // nista
         ELSE
            IF lEx
               fPrviProlaz := .F.
               IF cPrelomljeno == "D"
                  IF ( ndug - npot ) > 0
                     nDug := nDug - nPot
                     nPot := 0
                  ELSE
                     nPot := nPot - nDug
                     nDug := 0
                  ENDIF
                  IF ( ndug2 - npot2 ) > 0
                     nDug2 := nDug2 - nPot2
                     nPot2 := 0
                  ELSE
                     nPot2 := nPot2 - nDug2
                     nDug2 := 0
                  ENDIF
               ENDIF
               //
               SELECT POM
               APPEND BLANK
               Scatter()
               _idpartner := cIdPartner
               _datdok    := aFaktura[ 1 ]
               _datval    := fix_dat_var( aFaktura[ 2 ], .T. )
               _datzpr    := aFaktura[ 3 ]
               IF Empty( _DatDok ) .AND. Empty( _DatVal )
                  _DatVal := _DatZPR
               ENDIF
               _brdok     := cBrDok
               _dug       := nDug
               _pot       := nPot
               _dug2      := nDug2
               _pot2      := nPot2
               _otvst     := cOtvSt
               Gather()
               SELECT SUBAN
            ELSE
               IF !fTiho
                  IF PRow() > 52 + dodatni_redovi_po_stranici()
                     FF
                     fin_zagl_ostav_grupisano_po_br_veze( .T., lEx )
                     fPrviProlaz := .F.
                  ENDIF
                  IF fPrviProlaz
                     fin_zagl_ostav_grupisano_po_br_veze(, lEx )
                     fPrviProlaz := .F.
                  ENDIF
                  ? PadR( cBrDok, 10 )
                  nCol1 := PCol() + 1
               ENDIF
               IF cPrelomljeno == "D"
                  IF ( ndug - npot ) > 0
                     nDug := nDug - nPot
                     nPot := 0
                  ELSE
                     nPot := nPot - nDug
                     nDug := 0
                  ENDIF
                  IF ( ndug2 - npot2 ) > 0
                     nDug2 := nDug2 - nPot2
                     nPot2 := 0
                  ELSE
                     nPot2 := nPot2 - nDug2
                     nDug2 := 0
                  ENDIF
               ENDIF
               IF !fTiho
                  @ PRow(), nCol1 SAY nDug PICTURE picBHD
                  @ PRow(), PCol() + 1  SAY nPot PICTURE picBHD
                  @ PRow(), PCol() + 1  SAY nDug - nPot PICTURE picBHD
                  IF fin_dvovalutno()
                     @ PRow(), PCol() + 1  SAY nDug2 PICTURE picdem
                     @ PRow(), PCol() + 1  SAY nPot2 PICTURE picdem
                     @ PRow(), PCol() + 1  SAY nDug2 - nPot2 PICTURE picdem
                  ENDIF
                  @ PRow(), PCol() + 2  SAY cOtvSt
               ENDIF
               nUDug += nDug; nUPot += nPot
               nUDug2 += nDug2; nUPot2 += nPot2
            ENDIF
         ENDIF

      ENDDO
      // partner

      IF !fTiho

         IF PRow() > 58 + dodatni_redovi_po_stranici()
            FF
            fin_zagl_ostav_grupisano_po_br_veze( .T., lEx )
         ENDIF

         IF !lEx .AND. !fPrviProlaz
            // bilo je stavki
            ? M
            ? "UKUPNO:"
            @ PRow(), nCol1 SAY nUDug PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nUPot PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nUDug - nUPot PICTURE picBHD
            IF fin_dvovalutno()
               @ PRow(), PCol() + 1 SAY nUDug2 PICTURE picdem
               @ PRow(), PCol() + 1 SAY nUPot2 PICTURE picdem
               @ PRow(), PCol() + 1 SAY nUDug2 - nUPot2 PICTURE picdem
            ENDIF
            ? m
         ENDIF
      ENDIF

      IF fTiho
         // idu svi
      ELSEIF fsolo // iz menija
         IF ( !fveci .AND. idpartner = cSvi ) .OR. fVeci
            IF !lEx .AND. !fPrviProlaz
               ? ;  ? ; ?
            ENDIF
         ELSE
            EXIT
         ENDIF
      ELSE
         IF cSvi <> "D"
            EXIT
         ELSE
            IF !lEx .AND. !fPrviProlaz
               ? ;  ? ; ?
            ENDIF
         ENDIF
      ENDIF // fsolo
   ENDDO

   IF !fTiho .AND. lEx   // ako je EXCLUSIVE, sada tek stampaj
      SELECT POM
      GO TOP
      DO WHILE !Eof()
         fPrviProlaz := .T.
         cIdPartner := IDPARTNER
         nUDug := nUPot := nUDug2 := nUPot2 := 0
         DO WHILE !Eof() .AND. cIdPartner == IdPartner
            IF PRow() > 52 + dodatni_redovi_po_stranici(); FF; fin_zagl_ostav_grupisano_po_br_veze( .T., lEx ); fPrviProlaz := .F. ; ENDIF
            IF fPrviProlaz
               fin_zagl_ostav_grupisano_po_br_veze(, lEx )
               fPrviProlaz := .F.
            ENDIF
            SELECT POM
            ? datdok, datval, datzpr, PadR( brdok, 10 )
            nCol1 := PCol() + 1
            ?? " "
            ?? Transform( dug, picbhd ), ;
               Transform( pot, picbhd ), ;
               Transform( dug - pot, picbhd )
            IF fin_dvovalutno()
               ?? " " + Transform( dug2, picdem ), ;
                  Transform( pot2, picdem ), ;
                  Transform( dug2 - pot2, picdem )
            ENDIF
            ?? "  " + otvst
            nUDug += Dug; nUPot += Pot
            nUDug2 += Dug2; nUPot2 += Pot2
            SKIP 1
         ENDDO
         IF PRow() > 58 + dodatni_redovi_po_stranici(); FF; fin_zagl_ostav_grupisano_po_br_veze( .T., lEx ); ENDIF
         SELECT POM
         IF !fPrviProlaz  // bilo je stavki
            ? M
            ? "UKUPNO:"
            @ PRow(), nCol1 SAY nUDug PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nUPot PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nUDug - nUPot PICTURE picBHD
            IF fin_dvovalutno()
               @ PRow(), PCol() + 1 SAY nUDug2 PICTURE picdem
               @ PRow(), PCol() + 1 SAY nUPot2 PICTURE picdem
               @ PRow(), PCol() + 1 SAY nUDug2 - nUPot2 PICTURE picdem
            ENDIF
            ? m
         ENDIF
         ? ; ? ; ?
      ENDDO
   ENDIF

   IF fTiho
      RETURN ( NIL )
   ENDIF

   FF

   end_print()

   SELECT ( F_POM ); USE

   IF fSolo
      CLOSERET
   ELSE
      RETURN ( NIL )
   ENDIF

FUNCTION fin_create_pom_table( fTiho, nParLen )

   LOCAL i
   LOCAL nPartLen
   LOCAL _alias := "POM"
   LOCAL _ime_dbf := my_home() + my_dbf_prefix() + "pom"
   LOCAL aDbf, aGod

   IF fTiho == NIL
      fTiho := .F.
   ENDIF

   SELECT ( F_POM )
   USE

   IF nParLen == nil
      nParLen := 6
   ENDIF

   FErase( _ime_dbf + ".dbf" )
   FErase( _ime_dbf + ".cdx" )

   aDbf := {}
   AAdd( aDBf, { 'IDPARTNER', 'C',  nParLen,  0 } )
   AAdd( aDBf, { 'DATDOK', 'D',  8,  0 } )
   AAdd( aDBf, { 'DATVAL', 'D',  8,  0 } )
   AAdd( aDBf, { 'BRDOK', 'C', 10,  0 } )
   AAdd( aDBf, { 'DUG', 'N', 17,  2 } )
   AAdd( aDBf, { 'POT', 'N', 17,  2 } )
   AAdd( aDBf, { 'DUG2', 'N', 15,  2 } )
   AAdd( aDBf, { 'POT2', 'N', 15,  2 } )
   AAdd( aDBf, { 'OTVST', 'C',  1,  0 } )
   AAdd( aDBf, { 'DATZPR', 'D',  8,  0 } )

   IF fTiho
      FOR i := 1 TO Len( aGod )
         AAdd( aDBf, { 'GOD' + aGod[ i, 1 ], 'N', 15,  2 } )
      NEXT
      AAdd( aDBf, { 'GOD' + Str( Val( aGod[ i - 1, 1 ] ) -1, 4 ), 'N', 15,  2 } )
      AAdd( aDBf, { 'GOD' + Str( Val( aGod[ i - 1, 1 ] ) -2, 4 ), 'N', 15,  2 } )
   ENDIF

   dbCreate( _ime_dbf + ".dbf", aDbf )
   USE

   SELECT ( F_POM )
   my_use_temp( _alias, _ime_dbf, .F., .T. )

   INDEX on ( IDPARTNER + DToS( DATDOK ) + DToS( iif( Empty( DATVAL ), DATDOK, DATVAL ) ) + BRDOK ) TAG "1"

   SET ORDER TO TAG "1"
   GO TOP

   RETURN .T.




/* fin_zagl_ostav_grupisano_po_br_veze(fStrana,lEx)
 *     Zaglavlje kartice OS-a
 *   param: fStrana
 *   param: lEx
 */
FUNCTION fin_zagl_ostav_grupisano_po_br_veze( fStrana, lEx )

   ?
   IF fin_dvovalutno()
      IF lEx
         P_COND
      ELSE
         F12CPI
      ENDIF
   ELSE
      F10CPI
   ENDIF
   IF fStrana == NIL
      fStrana := .F.
   ENDIF

   IF nStr = 0
      fStrana := .T.
   ENDIF

   ?? "FIN.P: OTV.STAVKE - PREGLED (GRUPISANO PO BROJEVIMA VEZE)  NA DAN "; ?? Date()
   IF fStrana
      @ PRow(), 110 SAY "Str:" + Str( ++nStr, 3 )
   ENDIF

   SELECT PARTN
   HSEEK cIdFirma
   ? "FIRMA:", cIdFirma, "-", self_organizacija_naziv()

   SELECT KONTO
   HSEEK cIdKonto

   ? "KONTO  :", cIdKonto, naz

   SELECT PARTN
   HSEEK cIdPartner
   ? "PARTNER:", cIdPartner, Trim( naz ), " ", Trim( naz2 ), " ", Trim( mjesto )

   SELECT suban
   ? M
   ?
   IF lEx
      ?? "Dat.dok.*Dat.val.*Dat.ZPR.* "
   ELSE
      ?? "*"
   ENDIF
   IF fin_dvovalutno()
      ?? "  BrDok   *   dug " + ValDomaca() + "  *   pot " + ValDomaca() + "   *  saldo  " + ValDomaca() + " * dug " + ValPomocna() + " * pot " + ValPomocna() + " *saldo " + ValPomocna() + "*O*"
   ELSE
      ?? "  BrDok   *   dug " + ValDomaca() + "  *   pot " + ValDomaca() + "   *  saldo  " + ValDomaca() + " *O*"
   ENDIF
   ? M

   SELECT SUBAN

   RETURN .T.




/* StBrVeze()
 *     Stampa broja veze
 */

FUNCTION StBrVeze()

   LOCAL nCol1 := 35
   PRIVATE bZagl := {|| ZagBrVeze() }

   cDokument := Space( 8 )
   picBHD := FormPicL( gPicBHD, 13 )
   picDEM := FormPicL( gPicDEM, 10 )
   IF fin_dvovalutno()
      M := "-------- -------- " + "------- ---- -- ------------- ------------- ------------- ---------- ---------- ---------- --"
   ELSE
      M := "-------- -------- " + "------- ---- -- ------------- ------------- ------------- --"
   ENDIF

   nStr := 0

   START PRINT RET


   IF ValType( aPPos[ 1 ] ) = "C"
      PRIVATE cIdPartner := aPPos[ 1 ]
   ELSE
      PRIVATE cIdPartner := Eval( TB:getColumn( aPPos[ 1 ] ):Block )
   ENDIF
   IF ValType( aPPos[ 2 ] ) = "C"
      PRIVATE cBrDok := aPPos[ 2 ]
   ELSE
      PRIVATE cBrDok := Eval( TB:getColumn( aPPos[ 2 ] ):Block )
   ENDIF

   nUkDugBHD := nUkPotBHD := 0
   // SELECT suban; SET ORDER TO TAG "3"
   // SEEK cidfirma + cidkonto + cidpartner + cBrDok
   find_suban_by_konto_partner( cIdfirma, cIdkonto, cIdpartner, cBrDok, "IdFirma,IdKonto,IdPartner,brdok" )


   nDug2 := nPot2 := 0
   nDug := nPot := 0

   Eval( bZagl )

   DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner ;
         .AND. brdok == cBrDok

      NovaStrana( bZagl )
      ? datdok, datval, idvn, brnal, Str( rbr, 5, 0 ), idtipdok
      nCol1 := PCol() + 1
      IF D_P == "1"
         nDug += IznosBHD
         nDug2 += IznosDEM
         @ PRow(), PCol() + 1 SAY iznosbhd PICT picbhd
         @ PRow(), PCol() + 1 SAY Space( Len( picbhd ) )
         @ PRow(), PCol() + 1  SAY nDug - nPot PICT picbhd
         IF fin_dvovalutno()
            @ PRow(), PCol() + 1 SAY iznosdem PICT picdem
            @ PRow(), PCol() + 1 SAY Space( Len( picdem ) )
            @ PRow(), PCol() + 1  SAY nDug2 - nPot2 PICT picdem
         ENDIF
      ELSE
         nPot += IznosBHD
         nPot2 += IznosDEM
         @ PRow(), PCol() + 1 SAY Space( Len( picbhd ) )
         @ PRow(), PCol() + 1 SAY iznosbhd PICT picbhd
         @ PRow(), PCol() + 1  SAY nDug - nPot  PICT picbhd
         IF fin_dvovalutno()
            @ PRow(), PCol() + 1 SAY Space( Len( picdem ) )
            @ PRow(), PCol() + 1 SAY iznosdem PICT picdem
            @ PRow(), PCol() + 1  SAY nDug2 - nPot2  PICT picdem
         ENDIF
      ENDIF
      @ PRow(), PCol() + 2  SAY OtvSt
      SKIP
   ENDDO // partner

   NovaStrana( bZagl )

   ? m
   ? "UKUPNO:"
   @ PRow(), nCol1     SAY nDug PICTURE picBHD
   @ PRow(), PCol() + 1  SAY nPot PICTURE picBHD
   @ PRow(), PCol() + 1  SAY nDug - nPot PICTURE picBHD
   IF fin_dvovalutno()
      @ PRow(), PCol() + 1  SAY nDug2 PICTURE picdem
      @ PRow(), PCol() + 1  SAY nPot2 PICTURE picdem
      @ PRow(), PCol() + 1  SAY nDug2 - nPot2 PICTURE picdem
   ENDIF
   ? m

   FF
   end_print()



/* ZagBRVeze()
 *     Zaglavlje izvjestaja broja veze
 */

FUNCTION ZagBRVeze()

   ?
   IF fin_dvovalutno()
      P_COND
   ELSE
      F12CPI
   ENDIF
   ?? "FIN.P: KARTICA ZA ODREDJENI BROJ VEZE      NA DAN "; ?? Date()
   @ PRow(), 110 SAY "Str:" + Str( ++nStr, 3 )

   SELECT PARTN
   HSEEK cIdFirma
   ? "FIRMA:", cIdFirma, naz, naz2

   SELECT KONTO
   HSEEK cIdKonto
   ? "KONTO  :", cIdKonto, naz

   SELECT PARTN
   HSEEK cIdPartner
   ? "PARTNER:", cIdPartner, Trim( naz ), " ", Trim( naz2 ), " ", Trim( mjesto )

   SELECT suban
   ? "BROJ VEZE :", cBrDok
   ? M
   IF fin_dvovalutno()
      ? "Dat.dok.*Dat.val." + "*NALOG * Rbr *TD*   dug " + ValDomaca() + "   *  pot " + ValDomaca() + "  *   saldo " + ValDomaca() + "*  dug " + ValPomocna() + "* pot " + ValPomocna() + " *saldo " + ValPomocna() + "* O"
   ELSE
      ? "Dat.dok.*Dat.val." + "*NALOG * Rbr *TD*   dug " + ValDomaca() + "   *  pot " + ValDomaca() + "  *   saldo " + ValDomaca() + "* O"
   ENDIF
   ? M

   SELECT SUBAN

   RETURN .T.







/* fin_ostav_stampa_azuriranih_promjena()
 *     Stampa promjena
 */

FUNCTION fin_ostav_stampa_azuriranih_promjena()

   aKol := {}
   AAdd( aKol, { "Originalni",    {|| _obrdok }, .F., "C", 10,  0, 1, 1    } )
   AAdd( aKol, { "Br.Veze  ",    {|| "#" }, .F., "C", 10,  0, 2, 1    } )
   AAdd( aKol, { "Br.Veze",       {|| BrDok }, .F., "C", 10, 0, 1, 2  } )

   AAdd( aKol, { "Dat.Dok",       {|| DatDok }, .F., "D", 8, 0, 1, 3  } )
   AAdd( aKol, { "Duguje",    {|| Str( ( iif( D_P == "1", iznosbhd, 0 ) ), 18, 2 ) }, .F., "C", 18, 0, 1, 4  } )
   AAdd( aKol, { "Potrazuje",    {|| Str( ( iif( D_P == "2", iznosbhd, 0 ) ), 18, 2 ) }, .F., "C", 18, 0, 1, 5  } )
   AAdd( aKol, { "Nalog",    {|| idvn + "-" + brnal + "/" + Str( rbr, 5, 0 ) }, .F., "C", 20, 0, 1, 6  } )
   AAdd( aKol, { "Partner",     {|| IdPartner }, .F., "C", 10, 0, 1, 7  } )

   GO TOP
   fPromjene := .F.
   DO WHILE !Eof()
      IF _obrdok <> brdok
         fPromjene := .T.
         EXIT
      ENDIF
      SKIP
   ENDDO

   GO TOP
   IF !start_print()
      RETURN .F.
   ENDIF

   print_lista_2( aKol,,, 0,, ;
      , "Rezultati asistenta otvorenih stavki za: " + idkonto + "/" + idpartner + " na datum:" + DToC( Date() ) )

   end_print()

   RETURN .T.
