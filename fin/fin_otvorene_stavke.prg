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


FUNCTION fin_otvorene_stavke()

   PRIVATE izbor := 1
   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE gnLost := 0

   AAdd( opc, "1. ručno zatvaranje                                 " )
   AAdd( opcexe, {|| fin_rucno_zatvaranje_otvorenih_stavki() } )
   AAdd( opc, "2. automatsko zatvaranje" )
   AAdd( opcexe, {|| fin_automatsko_zatvaranje_otvorenih_stavki() } )
   AAdd( opc, "3. kartica" )
   AAdd( opcexe, {|| fin_suban_kartica( .T. ) } )
   AAdd( opc, "4. usporedna kartica dva konta" )
   AAdd( opcexe, {|| fin_suban_kartica2( .T. ) } )
   AAdd( opc, "5. specifikacija" )
   AAdd( opcexe, {|| SpecOtSt() } )
   AAdd( opc, "6. ios" )
   AAdd( opcexe, {|| IOS() } )
   AAdd( opc, "7. kartice grupisane po brojevima veze" )
   AAdd( opcexe, {|| StKart( .T. ) } )
   AAdd( opc, "8. kompenzacija" )
   AAdd( opcexe, {|| Kompenzacija() } )
   AAdd( opc, "9. asistent otvorenih stavki" )
   AAdd( opcexe, {|| fin_asistent_otv_st() } )
   AAdd( opc, "B. brisanje svih markera otvorenih stavki" )
   AAdd( opcexe, {|| fin_brisanje_markera_otvorenih_stavki() } )

   Izbor := 1
   Menu_SC( "oas" )

   RETURN

// ----------------------------------------------------
// specifikacija otvorenih stavki
// ----------------------------------------------------
STATIC FUNCTION SpecOtSt()

   LOCAL nKolTot := 85
   PRIVATE bZagl := {|| ZaglSPK() }

   cIdFirma := gFirma
   nRok := 0
   cIdKonto := Space( 7 )
   picBHD := FormPicL( "9 " + gPicBHD, 21 )
   picDEM := FormPicL( "9 " + gPicDEM, 21 )

   cIdRj := "999999"
   cFunk := "99999"
   cFond := "999"

   qqBrDok := Space( 40 )

   O_PARTN
   M := "---- " + REPL( "-", Len( PARTN->id ) ) + " ------------------------------------- ----- ----------------- ---------- ---------------------- --------------------"
   O_KONTO
   dDatOd := dDatDo := CToD( "" )

   cPrelomljeno := "D"
   Box( "Spec", 13, 75, .F. )

   DO WHILE .T.
      SET CURSOR ON
      @ m_x + 1, m_y + 2 SAY "SPECIFIKACIJA OTVORENIH STAVKI"
      IF gNW == "D"
         @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 4, m_y + 2 SAY "Konto    " GET cIdKonto VALID P_KontoFin( @cIDKonto ) PICT "@!"
      @ m_x + 5, m_y + 2 SAY "Od datuma" GET dDatOd
      @ m_x + 5, Col() + 2 SAY "do" GET dDatdo
      @ m_x + 7, m_y + 2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
      @ m_x + 8, m_y + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cPrelomljeno $ "DN" PICT "@!"

      UpitK1k4( 9, .F. )

      READ; ESC_BCR
      aBV := Parsiraj( qqBrDok, "UPPER(BRDOK)", "C" )
      IF aBV <> NIL
         EXIT
      ENDIF
   ENDDO

   BoxC()

   B := 0

   IF cPrelomljeno == "N"
      m += " --------------------"
   ENDIF

   nStr := 0

   O_SUBAN

   CistiK1k4( .F. )

   SELECT SUBAN
   // IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)
   SET ORDER TO TAG "3"

   cFilt1 := "OTVST==' '"

   IF !Empty( qqBrDok )
      cFilt1 += ( ".and." + aBV )
   ENDIF

   IF !Empty( dDatOd )
      cFilt1 += ".and. IF( EMPTY(datval) , datdok>=" + dbf_quote( dDatOd ) + " , datval>=" + dbf_quote( dDatOd ) + " )"
   ENDIF

   IF !Empty( dDatDo )
      cFilt1 += ".and. IF( EMPTY(datval) , datdok<=" + dbf_quote( dDatDo ) + " , datval<=" + dbf_quote( dDatDo ) + " )"
   ENDIF

   GO TOP

   IF gRj == "D" .AND. Len( cIdrj ) <> 0
      cFilt1 += ( ".and. idrj='" + cidrj + "'" )
   ENDIF

   IF gTroskovi == "D" .AND. Len( cFunk ) <> 0
      cFilt1 += ( ".and. Funk='" + cFunk + "'" )
   ENDIF

   IF gTroskovi == "D" .AND. Len( cFond ) <> 0
      cFilt1 += ( ".and. Fond='" + cFond + "'" )
   ENDIF

   SET FILTER TO &cFilt1

   SEEK cidfirma + cidkonto
   NFOUND CRET

   START PRINT  CRET

   nDugBHD := nPotBHD := 0


   DO WHILE !Eof() .AND. cIDFirma == idfirma .AND. cIdKonto = IdKonto
      cIdPartner := IdPartner
      DO WHILE  !Eof() .AND. cIDFirma == idfirma .AND. cIdKonto = IdKonto .AND. cIdPartner = IdPartner


         IF PRow() == 0
            Eval( bZagl )
         ENDIF

         NovaStrana( bZagl )

         cBrDok := BrDok
         nIznD := 0; nIznP := 0
         DO WHILE  !Eof() .AND. cIdKonto = IdKonto .AND. cIdPartner = IdPartner ;
               .AND. cBrDok == BrDok
            IF D_P == "1"; nIznD += IznosBHD; else; nIznP += IznosBHD; ENDIF
            SKIP
         ENDDO
         @ PRow() + 1, 0 SAY ++B PICTURE '9999'
         @ PRow(), 5 SAY cIdPartner

         SELECT PARTN
         HSEEK cIdPartner

         @ PRow(), PCol() + 1 SAY PadR( naz, 37 )
         @ PRow(), PCol() + 1 SAY PadR( PTT, 5 )
         @ PRow(), PCol() + 1 SAY PadR( Mjesto, 17 )

         SELECT SUBAN

         @ PRow(), PCol() + 1 SAY PadR( cBrDok, 10 )

         IF cPrelomljeno == "D"
            IF Round( nIznD - nIznP, 4 ) > 0
               nIznD := nIznD - nIznP
               nIznP := 0
            ELSE
               nIznP := nIznP - nIznD
               nIznD := 0
            ENDIF
         ENDIF

         nKolTot := PCol() + 1
         @ PRow(), nKolTot      SAY nIznD PICTURE picBHD

         @ PRow(), PCol() + 1 SAY nIznP PICTURE picBHD
         IF cPrelomljeno == "N"
            @ PRow(), PCol() + 1 SAY nIznD - nIznP PICTURE picBHD
         ENDIF
         nDugBHD += nIznD
         nPotBHD += nIznP


      ENDDO // partner
   ENDDO  // konto

   NovaStrana( bZagl )

   ? M
   ? "UKUPNO za KONTO:"
   @ PRow(), nKolTot  SAY nDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD

   IF cPrelomljeno == "N"
      @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICTURE picBHD
   ELSE

      ? " S A L D O :"
      IF nDugBhd - nPotBHD > 0
         nDugBHD := nDugBHD - nPotBHD
         nPotBHD := 0
      ELSE
         nPotBHD := nPotBHD - nDugBHD
         nDugBHD := 0
      ENDIF
      @ PRow(), nKolTot  SAY nDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD

   ENDIF
   ? M

   nDugBHD := nPotBHD := 0

   FF
   end_print()

   my_close_all_dbf()

   RETURN



/* ZaglSpK()
 *     Zaglavlje specifikacije
 */

FUNCTION ZaglSpK()

   LOCAL nDSP := 0

   ?
   P_COND
   ?? "FIN.P: SPECIFIKACIJA OTVORENIH STAVKI  ZA KONTO ", cIdKonto
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? " ZA PERIOD ", dDatOd, "-", dDatDo
   ENDIF
   ?? "     NA DAN:", Date()
   IF !Empty( qqBrDok )
      ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '" + Trim( qqBrDok ) + "'"
   ENDIF

   @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )

   IF gNW == "D"
      ? "Firma:", gFirma, gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cidfirma, partn->naz, partn->naz2
   ENDIF

   IF cPrelomljeno == "N"
      P_COND2
   ENDIF

   ?
   PrikK1k4( .F. )

   nDSP := Len( PARTN->id )

   ? M
   ?U "*R. *" + PadC( "SIFRA", nDSP ) + "*       NAZIV POSLOVNOG PARTNERA      * PTT *      MJESTO     *  BROJ    *               IZNOS                      *" + iif( cPrelomljeno == "N", "                    *", "" )
   ?U "     " + Space( nDSP ) + "                                                                          ---------------------- --------------------" + iif( cPrelomljeno == "N", " --------------------", "" )
   ?U "*BR.*" + Space( nDSP ) + "*                                     * BROJ*                 *  VEZE    *         DUGUJE       *      POTRAZUJE    *" + iif( cPrelomljeno == "N", "       SALDO        *", "" )
   ? M
   SELECT SUBAN

   RETURN




FUNCTION fin_automatsko_zatvaranje_otvorenih_stavki( lAuto, cKto, cPtn )

   LOCAL _rec
   LOCAL  nDugBHD := 0, nPotBHD := 0
   LOCAL lOk := .T.
   LOCAL hParams

   IF lAuto == nil
      lAuto := .F.
   ENDIF

   IF cPtn == nil
      cPtn := ""
   ENDIF

   IF cKto == nil
      cKto := ""
   ENDIF

   cIdFirma := gFirma
   cIdKonto := Space( 7 )
   cIdPart := Space( 6 )

   IF lAuto
      cIdKonto := cKto
      cIdPart := cPtn
      cPobSt := "D"
   ENDIF

   qqPartner := Space( 60 )
   picD := "@Z " + FormPicL( "9 " + gPicBHD, 18 )
   picDEM := "@Z " + FormPicL( "9 " + gPicDEM, 9 )

   O_PARTN
   O_KONTO

   IF !lAuto

      Box( "AZST", 6, 65, .F. )

      SET CURSOR ON

      cPobST := "N"

      @ m_x + 1, m_y + 2 SAY "AUTOMATSKO ZATVARANJE STAVKI"
      IF gNW == "D"
         @ m_x + 3, m_y + 2 SAY "Firma "
         ?? gFirma, "-", AllTrim( gNFirma )
      ELSE
         @ m_x + 3, m_y + 2 SAY "Firma: " GET cIdFirma ;
            VALID {|| P_Firma( @cIdFirma ), cIdfirma := Left( cIdfirma, 2 ), .T. }
      ENDIF
      @ m_x + 4, m_y + 2 SAY "Konto: " GET cIdKonto VALID P_KontoFin( @cIdKonto )
      @ m_x + 5, m_y + 2 SAY "Partner (prazno-svi): " GET cIdPart ;
         VALID {|| Empty( cIdPart ) .OR. P_Firma( @cIdPart ) }
      @ m_x + 6, m_y + 2 SAY "Pobrisati stare markere zatv.stavki: " GET cPobSt PICT "@!" VALID cPobSt $ "DN"

      READ
      ESC_BCR

      BoxC()

   ENDIF

   cIdFirma := Left( cIdFirma, 2 )

   O_SUBAN

   SELECT SUBAN
   SET ORDER TO TAG "3"
   SEEK cIdFirma + cIdKonto

   EOF CRET

   IF cPobSt == "D" .AND. Pitanje(, "Želite li zaista pobrisati markere ??", "N" ) == "D"
      IF !ponisti_markere_postojecih_stavki( cIdFirma, cIdKonto, cIdPart )
         RETURN .F.
      ENDIF
   ENDIF

   Box( "count", 1, 30, .F. )

   nC := 0

   @ m_x + 1, m_y + 2 SAY "Zatvoreno:"
   @ m_x + 1, m_y + 12 SAY nC

   SEEK cidfirma + cidkonto
   EOF CRET

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabelu fin_suban !#Prekidam operaciju zatvaranja stavki." )
      RETURN .F.
   ENDIF

   DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto = IdKonto

      IF !Empty( cIdPart )
         IF ( cIdPart <> idpartner )
            SKIP
            LOOP
         ENDIF
      ENDIF

      cIdPartner := IdPartner
      cBrDok := BrDok
      cOtvSt := " "
      nDugBHD := nPotBHD := 0

      DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner .AND. cBrDok == BrDok
         IF D_P = "1"
            nDugBHD += IznosBHD
            cOtvSt := "1"
         ELSE
            nPotBHD += IznosBHD
            cOtvSt := "1"
         ENDIF
         SKIP
      ENDDO

      IF Abs( Round( nDugBHD - nPotBHD, 3 ) ) <= gnLOSt .AND. cOtvSt == "1"

         SEEK cIdFirma + cIdKonto + cIdPartner + cBrDok
         @ m_x + 1, m_y + 12 SAY ++nC

         DO WHILE !Eof() .AND. cIdKonto = IdKonto .AND. cIdPartner == IdPartner .AND. cBrDok = BrDok

            _rec := dbf_get_rec()
            _rec[ "otvst" ] := "9"

            lOk := update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

            IF !lOk
               EXIT
            ENDIF

            SKIP

         ENDDO

         log_write( "F18_DOK_OPER, automatsko zatvaranje stavki, OASIST, duguje: " + AllTrim( Str( nDugBHD, 12, 2 ) ) + ", potrazuje: " + AllTrim( Str( nPotBHD, 12, 2 ) ) + " firma: " + cIdFirma + " konto: " + cIdKonto, 2 )

      ENDIF

      IF !lOk
         EXIT
      ENDIF

   ENDDO

   IF lOk
      hParams := hb_hash()
      hParams[ "unlock" ] := { "fin_suban" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Greška sa opcijom automatskog zatvaranja stavki !#Operacija poništena." )
   ENDIF

   BoxC()

   my_close_all_dbf()

   RETURN lOk



STATIC FUNCTION ponisti_markere_postojecih_stavki( cIdFirma, cIdKonto, cIdPartner )

   LOCAL _rec
   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hParams

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      RETURN lRet
   ENDIF

   Box(, 3, 65 )

   @ m_x + 1, m_y + 2 SAY8 "Brišem markere postojećih stavki tabele..."

   DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto = IdKonto

      IF !Empty( cIdPartner )
         IF ( cIdPartner <> idpartner )
            SKIP
            LOOP
         ENDIF
      ENDIF

      _rec := dbf_get_rec()
      _rec[ "otvst" ] := " "

      @ m_x + 2, m_y + 2 SAY "nalog: " + _rec[ "idvn" ] + "-" + AllTrim( _rec[ "brnal" ] ) + " / stavka: " + _rec[ "rbr" ]

      lOk := update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF

      SKIP

   ENDDO

   BoxC()

   IF lOk
      lRet := .T.
      hParams := hb_hash()
      hParams[ "unlock" ] := { "fin_suban" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
      lRet := .F.
   ENDIF

   RETURN lRet




FUNCTION fin_brisanje_markera_otvorenih_stavki()

   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hParams

   IF Pitanje(, "Pobrisati sve markere otvorenih stavki (D/N) ?", "N" ) == "N"
      RETURN lRet
   ENDIF

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabelu fin_suban !#Operacija poništena." )
      RETURN lRet
   ENDIF

   SELECT ( F_SUBAN )
   IF !Used()
      O_SUBAN
   ENDIF

   SET ORDER TO TAG "1"
   GO TOP

   MsgO( "Brisanje markera... molimo sačekajte trenutak ..." )

   DO WHILE !Eof()

      _rec := dbf_get_rec()

      IF _rec[ "otvst" ] <> ""
         _rec[ "otvst" ] := ""
         lOk := update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SKIP

   ENDDO

   MsgC()

   IF lOk
      lRet := .T.
      hParams := hb_hash()
      hParams[ "unlock" ] := { "fin_suban" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Greška sa opcijom brisanja markera !#Operacija poništena." )
   ENDIF

   SELECT ( F_SUBAN )
   USE

   RETURN lRet



STATIC FUNCTION _o_ruc_zat( lOsuban )

   IF lOSuban == NIL
      lOSuban := .F.
   ENDIF

   O_PARTN
   O_KONTO
   O_RJ

   IF lOSuban

      SELECT ( F_SUBAN )
      USE
      SELECT ( F_OSUBAN )
      USE

      // otvaram osuban kao suban alijas
      // radi stampe kartice itd...
      SELECT ( F_SUBAN )
      my_use_temp( "SUBAN", my_home() + + my_dbf_prefix() + "osuban", .F., .F. )

   ELSE
      O_SUBAN
   ENDIF

   RETURN .T.





FUNCTION fin_rucno_zatvaranje_otvorenih_stavki()

   _o_ruc_zat()

   cIdFirma := gFirma
   cIdPartner := Space( Len( partn->id ) )

   picD := FormPicL( "9 " + gPicBHD, 14 )
   picDEM := FormPicL( "9 " + gPicDEM, 9 )

   cIdKonto := Space( Len( konto->id ) )

   Box(, 7, 66, )

   SET CURSOR ON

   @ m_x + 1, m_y + 2 SAY "ISPRAVKA BROJA VEZE - OTVORENE STAVKE"
   IF gNW == "D"
      @ m_x + 3, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
   ELSE
      @ m_x + 3, m_y + 2 SAY "Firma  " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Konto  " GET cIdKonto  VALID  P_KontoFin( @cIdKonto )
   @ m_x + 5, m_y + 2 SAY "Partner" GET cIdPartner VALID Empty( cIdPartner ) .OR. P_Firma( @cIdPartner ) PICT "@!"
   IF gRj == "D"
      cIdRj := Space( Len( RJ->id ) )
      @ m_x + 6, m_y + 2 SAY "RJ" GET cidrj PICT "@!" VALID Empty( cidrj ) .OR. P_Rj( @cidrj )
   ENDIF
   READ
   ESC_BCR

   BoxC()

   IF Empty( cIdpartner )
      cIdPartner := ""
   ENDIF

   cIdFirma := Left( cIdFirma, 2 )

   SELECT SUBAN
   SET ORDER TO TAG "1"

   IF gRJ == "D" .AND. !Empty( cIdRJ )
      SET FILTER TO IDRJ == cIdRj
   ENDIF

   Box(, MAXROWS() - 5, MAXCOLS() - 10 )

   ImeKol := {}
   AAdd( ImeKol, { "O",          {|| OtvSt }             } )
   AAdd( ImeKol, { "Partn.",     {|| IdPartner }         } )
   AAdd( ImeKol, { "Br.Veze",    {|| BrDok }             } )
   AAdd( ImeKol, { "Dat.Dok.",   {|| DatDok }            } )
   AAdd( ImeKol, { "Opis",       {|| PadR( opis, 20 ) }, "opis",  {|| .T. }, {|| .T. }, "V"  } )
   AAdd( ImeKol, { PadR( "Duguje " + AllTrim( ValDomaca() ), 13 ), {|| Str( ( iif( D_P == "1", iznosbhd, 0 ) ), 13, 2 ) }     } )
   AAdd( ImeKol, { PadR( "Potraz." + AllTrim( ValDomaca() ), 13 ),   {|| Str( ( iif( D_P == "2", iznosbhd, 0 ) ), 13, 2 ) }     } )
   AAdd( ImeKol, { "M1",         {|| m1 }                } )
   AAdd( ImeKol, { PadR( "Iznos " + AllTrim( ValPomocna() ), 14 ),  {|| Str( iznosdem, 14, 2 ) }                       } )
   AAdd( ImeKol, { "nalog",      {|| idvn + "-" + brnal + "/" + rbr }                  } )
   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   PRIVATE aPPos := { 2, 3 }
   PRIVATE bGoreRed := NIL
   PRIVATE bDoleRed := NIL
   PRIVATE bDodajRed := NIL
   PRIVATE fTBNoviRed := .F. // trenutno smo u novom redu ?
   PRIVATE TBCanClose := .T. // da li se moze zavrsiti unos podataka ?
   PRIVATE TBAppend := "N"  // mogu dodavati slogove
   PRIVATE bZaglavlje := NIL
   PRIVATE TBSkipBlock := {| nSkip| SkipDBBK( nSkip ) }
   PRIVATE nTBLine := 1      // tekuca linija-kod viselinijskog browsa
   PRIVATE nTBLastLine := 1  // broj linija kod viselinijskog browsa
   PRIVATE TBPomjerise := "" // ako je ">2" pomjeri se lijevo dva
   PRIVATE TBScatter := "N"  // uzmi samo tekuce polje
   adImeKol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( adImeKol, ImeKol[ i ] )
   NEXT

   adKol := {}
   FOR i := 1 TO Len( adImeKol )
      AAdd( adKol, i )
   NEXT

   PRIVATE bBKUslov := {|| idFirma + idkonto + idpartner = cIdFirma + cIdkonto + cIdpartner }
   PRIVATE bBkTrazi := {|| cIdFirma + cIdkonto + cIdPartner }

   SET CURSOR ON

   PRIVATE cPomBrDok := Space( 10 )

   SEEK Eval( bBkUslov )

   opcije_browse_pregleda()

   my_db_edit( "Ost", MAXROWS() - 10, MAXCOLS() - 10, {|| rucno_zatvaranje_key_handler() }, ;
      "", "", .F., NIL, 1, {|| otvst == "9" }, 6, 0, NIL, {| nSkip| SkipDBBK( nSkip ) } )

   BoxC()

   my_close_all_dbf()

   RETURN .T.


STATIC FUNCTION rucno_zatvaranje_key_handler( l_osuban )

   LOCAL _rec
   LOCAL cMark
   LOCAL cDn  := "N"
   LOCAL nRet := DE_CONT
   LOCAL _otv_st := " "
   LOCAL _t_rec := RecNo()
   LOCAL _tb_filter := dbFilter()
   LOCAL _t_area := Select()

   IF l_osuban == NIL
      l_osuban := .F.
   ENDIF

   DO CASE

   CASE Ch == K_ALT_E .AND. FieldPos( "_OBRDOK" ) = 0

      IF Pitanje(, "Preći u mod direktog unosa podataka u tabelu ? (D/N)", "D" ) == "D"
         log_write( "otovrene stavke, mod direktnog unosa = D", 5 )
         opcije_browse_pregleda()
         DaTBDirektni()
      ENDIF

   CASE Ch == K_ENTER

      cDn := "N"

      Box(, 3, 50 )
      @ m_x + 1, m_y + 2 SAY8 "Ne preporučuje se koristenje ove opcije !"
      @ m_x + 3, m_y + 2 SAY8 "Želite li ipak nastaviti D/N" GET cDN PICT "@!" VALID cDn $ "DN"
      READ
      BoxC()

      IF cDN == "D"

         IF field->otvst <> "9"
            cMark   := ""
            _otv_st := "9"
         ELSE
            cMark   := "9"
            _otv_st := " "
         ENDIF

         _rec := dbf_get_rec()
         _rec[ "otvst" ] := _otv_st
         update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

         log_write( "otvorene stavke, set marker=" + cMark, 5 )

         nRet := DE_REFRESH

      ELSE

         nRet := DE_CONT

      ENDIF

   CASE ( Ch == Asc( "K" ) .OR. Ch == Asc( "k" ) )

      IF field->m1 <> "9"
         _otv_st := "9"
      ELSE
         _otv_st := " "
      ENDIF
      log_write( "otvorene stavke, marker=" + _otv_st, 5 )
      _rec := dbf_get_rec()
      _rec[ "m1" ] := _otv_st

      update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

      nReti := DE_REFRESH

   CASE Ch == K_F2

      cBrDok := field->BrDok
      cOpis := field->opis
      dDatDok := field->datdok
      dDatVal := field->datval

      Box( "eddok", 5, 70, .F. )
      @ m_x + 1, m_y + 2 SAY "Broj Dokumenta (broj veze):" GET cBrDok
      @ m_x + 2, m_y + 2 SAY "Opis:" GET cOpis PICT "@S50"
      @ m_x + 4, m_y + 2 SAY "Datum dokumenta: "
      ?? dDatDok
      @ m_x + 5, m_y + 2 SAY "Datum valute   :" GET dDatVal
      READ
      BoxC()

      IF LastKey() <> K_ESC

         _rec := dbf_get_rec()

         _rec[ "brdok" ] := cBrDok
         _rec[ "opis" ]  := cOpis
         _rec[ "datval" ] := dDatVal
         log_write( "otvorene stavke, ispravka broja veze, set=" + cBrDok, 5 )
         update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

      ENDIF

      nRet := DE_REFRESH

   CASE Ch == K_F5

      cPomBrDok := field->BrDok

   CASE Ch == K_F6

      IF FieldPos( "_OBRDOK" ) <> 0
         // nalazimo se u asistentu
         StAz()

         _o_ruc_zat( l_osuban )
         SELECT ( _t_area )
         SET FILTER to &( _tb_filter )
         GO ( _t_rec )


      ELSE
         IF Pitanje(, "Želite li da vezni broj " + BrDok + " zamijenite brojem " + cPomBrDok + " ?", "D" ) == "D"

            _rec := dbf_get_rec()
            _rec[ "brdok" ] := cPomBrDok
            log_write( "otvorene stavke, zamjena broja veze, set=" + cPomBrDok, 5 )
            update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

         ENDIF
      ENDIF

      nRet := DE_REFRESH

   CASE Ch == K_CTRL_P

      StKart()

      _o_ruc_zat( l_osuban )
      SELECT ( _t_area )
      SET FILTER to &( _tb_filter )
      GO ( _t_rec )


      nRet := DE_REFRESH

   CASE Ch == K_ALT_P

      StBrVeze()

      _o_ruc_zat( l_osuban )
      SELECT ( _t_area )
      SET FILTER to &( _tb_filter )
      GO ( _t_rec )

      nRet := DE_REFRESH

   ENDCASE

   RETURN nRet



STATIC FUNCTION opcije_browse_pregleda()

   LOCAL _x, _y

   _x := m_x + MAXROWS() - 15
   _y := m_y + 1

   @ _x,     _y SAY " <F2>   Ispravka broja dok.       <c-P> Print   <a-P> Print Br.Dok          "
   @ _x + 1, _y SAY8 " <K>    Uključi/isključi račun za kamate         <F5> uzmi broj dok.        "
   @ _x + 2, _y SAY '<ENTER> Postavi/ukini zatvaranje                 <F6> "nalijepi" broj dok.  '

   @ _x + 3, _y SAY REPL( BROWSE_PODVUCI, MAXCOLS() - 12 )

   @ _x + 4, _y SAY ""

   ?? "Konto:", cIdKonto

   RETURN .T.



/* StKart(fSolo,fTiho,bFilter)
 *     Otvorene stavke grupisane po brojevima veze
 *   param: fSolo
 *   param: fTiho
 *   param: bFilter - npr. {|| getmjesto(cMjesto)}
 */

FUNCTION StKart( fSolo, fTiho, bFilter )

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

      O_SUBAN
      O_PARTN
      O_KONTO
      cIdFirma := gFirma
      cIdkonto := Space( 7 )
      cIdPartner := Space( 6 )

      Box(, 5, 60 )
      IF gNW == "D"
         @ m_x + 1, m_y + 2 SAY "Firma "; ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Konto:               " GET cIdkonto   PICT "@!"  VALID P_kontoFin( @cIdkonto )
      @ m_x + 3, m_y + 2 SAY "Partner (prazno svi):" GET cIdpartner PICT "@!"  VALID Empty( cIdpartner )  .OR. ( "." $ cidpartner ) .OR. ( ">" $ cidpartner ) .OR. P_Firma( @cIdPartner )
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

   SELECT suban
   SET ORDER TO TAG "3"

   IF cSvi == "D"
      SEEK cidfirma + cidkonto
   ELSE
      SEEK cidfirma + cidkonto + cidpartner
   ENDIF

   DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto == IdKonto

      IF bFilter <> NIL
         IF !Eval( bFilter )
            SKIP
            LOOP
         ENDIF
      ENDIF

      cidPartner := idpartner

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

         cBrDok := BrDok; cOtvSt := otvst
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
               aFaktura[ 2 ] := DATVAL
            ENDIF

            IF fTiho
               // poziv iz procedure RekPPG()
               // za izvjestaj maksuz radjen za Opresu³22.03.01.³
               // ------------------------------------ÀÄ MSÄÄÄÄÄÙ
               IF afaktura[ 3 ] < iif( Empty( DatVal ), DatDok, DatVal )
                  // datum zadnje promjene iif ubacen 03.11.2000 eh
                  // ----------------------------------------------
                  aFaktura[ 3 ] := iif( Empty( DatVal ), DatDok, DatVal )
               ENDIF
            ELSE
               // kao u asist.otv.stavki - koristi npr. Exclusive³22.03.01.³
               // -----------------------------------------------ÀÄ MSÄÄÄÄÄÙ
               IF afaktura[ 3 ] < DatDok
                  aFaktura[ 3 ] := DatDok
               ENDIF
            ENDIF

            SKIP 1
         ENDDO

         IF csvid == "N" .AND. Round( ndug - npot, 2 ) == 0
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
               _datval    := aFaktura[ 2 ]
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
                     ZagKStSif( .T., lEx )
                     fPrviProlaz := .F.
                  ENDIF
                  IF fPrviProlaz
                     ZagkStSif(, lEx )
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
            ZagKStSif( .T., lEx )
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
            IF PRow() > 52 + dodatni_redovi_po_stranici(); FF; ZagKStSif( .T., lEx ); fPrviProlaz := .F. ; ENDIF
            IF fPrviProlaz
               ZagkStSif(, lEx )
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
         IF PRow() > 58 + dodatni_redovi_po_stranici(); FF; ZagKStSif( .T., lEx ); ENDIF
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




/* ZagKStSif(fStrana,lEx)
 *     Zaglavlje kartice OS-a
 *   param: fStrana
 *   param: lEx
 */
FUNCTION ZagKStSif( fStrana, lEx )

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
   ? "FIRMA:", cIdFirma, "-", gNFirma

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

   RETURN




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
   SELECT suban; SET ORDER TO TAG "3"
   SEEK cidfirma + cidkonto + cidpartner + cBrDok


   nDug2 := nPot2 := 0
   nDug := nPot := 0

   Eval( bZagl )

   DO WHILE !Eof() .AND. idfirma == cidfirma .AND. cIdKonto == IdKonto .AND. cIdPartner == IdPartner ;
         .AND. brdok == cBrDok

      NovaStrana( bZagl )
      ? datdok, datval, idvn, brnal, rbr, idtipdok
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
   SELECT PARTN; HSEEK cIdFirma
   ? "FIRMA:", cIdFirma, naz, naz2

   SELECT KONTO; HSEEK cIdKonto
   ? "KONTO  :", cIdKonto, naz

   SELECT PARTN; HSEEK cIdPartner
   ? "PARTNER:", cIdPartner, Trim( naz ), " ", Trim( naz2 ), " ", Trim( mjesto )

   SELECT suban
   ? "BROJ VEZE :", cBrDok
   ? M
   IF fin_dvovalutno()
      ? "Dat.dok.*Dat.val." + "*NALOG * Rbr*TD*   dug " + ValDomaca() + "   *  pot " + ValDomaca() + "  *   saldo " + ValDomaca() + "*  dug " + ValPomocna() + "* pot " + ValPomocna() + " *saldo " + ValPomocna() + "* O"
   ELSE
      ? "Dat.dok.*Dat.val." + "*NALOG * Rbr*TD*   dug " + ValDomaca() + "   *  pot " + ValDomaca() + "  *   saldo " + ValDomaca() + "* O"
   ENDIF
   ? M

   SELECT SUBAN

   RETURN


// ------------------------------------------------------------------
// kreiraj oext
// ------------------------------------------------------------------
STATIC FUNCTION _cre_oext_struct()

   LOCAL _table := "osuban"
   LOCAL _struct
   LOCAL _ret := .T.

   FErase( my_home() + my_dbf_prefix() + _table + ".cdx" )

   SELECT SUBAN
   SET ORDER TO TAG "3"

   // uzmi suban strukturu
   _struct := suban->( dbStruct() )

   // dodaj nova polja u strukturu
   AAdd( _struct, { "_RECNO", "N",  8,  0 } )
   AAdd( _struct, { "_PPK1", "C",  1,  0 } )
   AAdd( _struct, { "_OBRDOK", "C", 10,  0 } )

   SELECT ( F_OSUBAN )

   // kreiraj tabelu
   dbCreate( my_home() + my_dbf_prefix() + "osuban.dbf", _struct )

   // otvori osuban ekskluzivno
   SELECT ( F_OSUBAN )
   my_use_temp( "OSUBAN", my_home() + my_dbf_prefix() + _table + ".dbf", .F., .T. )

   // kreiraj indekse
   INDEX ON IdFirma + IdKonto + IdPartner + DToS( DatDok ) + BrNal + RBr TAG "1"
   INDEX ON idfirma + idkonto + idpartner + brdok TAG "3"
   INDEX ON DToS( datdok ) + DToS( iif( Empty( DatVal ), DatDok, DatVal ) ) TAG "DATUM"

   RETURN _ret



FUNCTION fin_asistent_otv_st()

   LOCAL nSaldo
   LOCAL nSljRec
   LOCAL nOdem
   LOCAL _rec, _rec_suban
   LOCAL _max_rows := MAXROWS() - 5
   LOCAL _max_cols := MAXCOLS() - 5
   PRIVATE cIdKonto
   PRIVATE cIdFirma
   PRIVATE cIdPartner
   PRIVATE cBrDok

   O_KONTO
   O_PARTN
   O_SUBAN

   // ovo su parametri kartice
   cIdFirma := gFirma
   cIdKonto := Space( Len( suban->idkonto ) )
   cIdPartner := Space( Len( suban->idPartner ) )

   cIdFirma := fetch_metric( "fin_kartica_id_firma", my_user(), cIdFirma )
   cIdKonto := fetch_metric( "fin_kartica_id_konto", my_user(), cIdKonto )
   cIdPartner := fetch_metric( "fin_kartica_id_partner", my_user(), cIdPartner )

   cIdKonto := PadR( cidkonto, Len( suban->idkonto ) )
   cIdPartner := PadR( cidpartner, Len( suban->idPartner ) )
   // kupci cDugPot:=1
   cDugPot := "1"

   Box(, 3, 60 )
   @ m_x + 1, m_y + 2 SAY "Konto   " GET cIdKonto   VALID p_kontoFin( @cIdKonto )  PICT "@!"
   @ m_x + 2, m_y + 2 SAY "Partner " GET cIdPartner VALID P_Firma( @cIdPartner ) PICT "@!"
   @ m_x + 3, m_y + 2 SAY "Konto duguje / potrazuje" GET cdugpot when {|| cDugPot := iif( cidkonto = '54', '2', '1' ), .T. } VALID  cdugpot $ "12"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   set_metric( "fin_kartica_id_firma", my_user(), cIdFirma )
   set_metric( "fin_kartica_id_konto", my_user(), cIdKonto )
   set_metric( "fin_kartica_id_partner", my_user(), cIdPartner )

   // kreiraj oext
   IF !_cre_oext_struct()
      RETURN
   ENDIF

   SELECT suban
   SEEK cIdfirma + cIdkonto + cIdpartner

   // ukupan broj storno racuna za partnera
   nBrojStornoRacuna := 0

   DO WHILE !Eof() .AND. field->idfirma + field->idkonto + field->idpartner = cIdfirma + cIdkonto + cIdpartner

      cBrDok := field->brdok
      nSaldo := 0

      // proracunaj saldo za partner+dokument
      DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdpartner + cBrdok = field->idfirma + field->idkonto + field->idpartner + field->brdok

         IF cDugPot = field->d_p .AND. Empty( field->brdok )
            MsgBeep( "Postoje nepopunjen brojevi veze :" + ;
               field->idvn + "-" + field->brdok + "/" + field->rbr + "##Morate ih popuniti !" )
            my_close_all_dbf()
            RETURN
         ENDIF

         IF field->d_p = "1"
            nSaldo += field->iznosbhd
         ELSE
            nSaldo -= field->iznosbhd
         ENDIF
         SKIP
      ENDDO

      // saldo za dokument + partner postoji
      IF Round( nSaldo, 4 ) <> 0
         // napuni tabelu osuban za partner+dokument
         SEEK cIdfirma + cIdkonto + cIdpartner + cBrdok
         lStorno := .F.

         DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdpartner + cBrdok == ;
               field->idfirma + field->idkonto + field->idpartner + field->brdok

            SELECT suban
            _rec_suban := dbf_get_rec()

            SELECT osuban
            APPEND BLANK
            // upisi mi sve u osuban iz suban
            dbf_update_rec( _rec_suban )

            // a sada poradi na ovom zapisu
            _rec := dbf_get_rec()

            _rec[ "_recno" ] := suban->( RecNo() )
            _rec[ "_ppk1" ] := ""
            _rec[ "_obrdok" ] := _rec[ "brdok" ]

            IF ( _rec[ "iznosbhd" ] < 0 .AND. _rec[ "d_p" ] == cDugPot )
               lStorno := .T.
            ENDIF

            IF ( ( nSaldo > 0 .AND. cDugPot = "2" ) ) .AND. _rec[ "d_p" ] <> cDugPot
               // neko je bez veze zatvorio uplate (ili se mozda radi o avansima)
               _rec[ "brdok" ] := "AVANS"
            ENDIF

            dbf_update_rec( _rec )

            SELECT suban
            SKIP

         ENDDO

         IF lStorno
            ++nBrojStornoRacuna
         ENDIF

      ENDIF

   ENDDO

   SELECT osuban
   SET ORDER TO TAG "DATUM"

   DO WHILE .T.

      // svaki put prolazim ispocetka
      SELECT osuban
      GO TOP

      // varijabla koja kazuje da je racun/storno racun nadjen
      fNasao := .F.

      // prvi krug  (nadji ukupno stvorene obaveze za jednog partnera
      nZatvori := 0
      // nijedan brdok dokument u bazi ne moze biti chr(200)+chr(255)

      cZatvori := Chr( 200 ) + Chr( 255 )
      dDatDok := CToD( "" )

      nZatvoriStorno := 0
      cZatvoriStorno := Chr( 200 ) + Chr( 255 )
      dDatDokStorno := CToD( "" )

      // ovdje su sada sve stavke za jednog partnera, sortirane hronoloski
      DO WHILE !Eof()

         // neobradjene stavke
         IF Empty( field->_ppk1 )

            // nastanak duga
            IF !fNasao .AND. field->d_p == cDugPot


               IF ( field->iznosbhd > 0 )
                  IF nBrojStornoRacuna > 0
                     // prvo se moraju zatvoriti storno racuni
                     // zato preskacemo sve pozitivne racune koji se nalaze ispred

                     // MsgBeep("debug: pozitivne preskacem " + STR(nBrojStornoRacuna) + "  BrDok:" +  brdok )
                     SKIP
                     LOOP
                  ENDIF
                  // racun
                  nZatvori := field->iznosbhd
                  cZatvori := field->brdok
                  dDatDok := field->datdok
                  cZatvoriStorno := Chr( 200 ) + Chr( 255 )

               ELSE

                  // storno racun
                  nZatvoriStorno := field->iznosbhd
                  cZatvoriStorno := field->brdok
                  dDatDokStorno := field->datdok
                  cZatvori := Chr( 200 ) + Chr( 255 )
                  --nBrojStornoRacuna
                  // MsgBeep("debug: -- " + STR(nBrojStornoRacuna) + " / BrDok:" + BrDok)

               ENDIF

               fNasao := .T.

               _rec := dbf_get_rec()
               _rec[ "_ppk1" ] := "1"
               dbf_update_rec( _rec )
               // prosli smo ovo
               GO TOP
               // idi od pocetka da saberes czatvori
               LOOP

            ELSEIF fNasao .AND. ( cZatvori == field->brdok )

               // sve ostale stavke koje su hronoloski starije
               // koje imaju isti broj dokumenta kao nadjeni racun
               // saberi

               IF field->d_p == cDugPot
                  nZatvori += field->iznosbhd
               ELSE
                  nZatvori -= field->iznosbhd
               ENDIF

               _rec := dbf_get_rec()
               _rec[ "_ppk1" ] := "1"
               dbf_update_rec( _rec )
               // prosli smo ovo - marker

            ELSEIF fNasao .AND. ( cZatvoriStorno == field->brdok )

               // isto vrijedi i za stavke iza storno racuna
               // a koje imaju isti broj veze

               IF field->d_p == cDugPot
                  nZatvoriStorno += field->iznosbhd
               ELSE
                  nZatvoriStorno -= field->iznosbhd
               ENDIF

               _rec := dbf_get_rec()
               _rec[ "_ppk1" ] := "1"
               dbf_update_rec( _rec )
               // prosli smo ovo

            ENDIF

         ENDIF
         SKIP
      ENDDO

      IF !fNasao
         // nema racuna za zatvoriti
         MsgBeep( "prosao sve racune - nisam  nista nasao - izlazim" )
         EXIT
      ENDIF

      // drugi krug - sada se formiraju uplate
      // MsgBeep("2.krug: idem sada formirati uplate - zatvaranje racuna ")
      fNasao := .F.
      GO TOP

      DO WHILE !Eof()

         IF Empty( field->_ppk1 )

            // potrazna strana
            IF field->d_p <> cDugPot

               nUplaceno := field->iznosbhd

               // prvo cemo se rijesiti storno racuna, ako ih ima
               IF nUplaceno > 0  .AND. Abs( nZatvoriStorno ) > 0 .AND. ( dDatDokStorno <= field->datdok )

                  SKIP
                  nSljRec := RecNo()
                  SKIP -1
                  nOdem := field->iznosdem - nZatvoriStorno * field->iznosdem / field->iznosbhd

                  _rec := dbf_get_rec()

                  // zatvaram storno racun
                  _rec[ "brdok" ] := cZatvoriStorno
                  _rec[ "_ppk1" ] := "1"
                  _rec[ "iznosbhd" ] := nZatvoriStorno
                  _rec[ "iznosdem" ] := field->iznosdem - nODem

                  dbf_update_rec( _rec )

                  _rec := dbf_get_rec()
                  _rec[ "iznosbhd" ] := nUplaceno - nZatvoriStorno
                  _rec[ "iznosdem" ] := nOdem

                  IF Round( _rec[ "iznosbhd" ], 4 ) <> 0 .AND. Round( nOdem, 4 ) <> 0

                     // prebacujem ostatak uplate na novu stavku
                     APPEND BLANK

                     _rec[ "brdok" ] := "AVANS"
                     _rec[ "_ppk1" ] := ""

                     // resetuj broj zapisa iz suban tabele !
                     _rec[ "_recno" ] := 0

                     // sredi mi redni broj stavke
                     // na osnovu zadnjeg broja unutar naloga
                     _rec[ "rbr" ] := fin_dok_get_next_rbr( _rec[ "idfirma" ], _rec[ "idvn" ], _rec[ "brnal" ] )

                     dbf_update_rec( _rec )

                  ENDIF

                  nZatvoriStorno := 0
                  GO nSljRec
                  LOOP

               ELSEIF nUplaceno > 0 .AND. nZatvori > 0

                  // pozitivni iznosi
                  IF nZatvori >= nUplaceno

                     _rec := dbf_get_rec()
                     _rec[ "brdok" ] := cZatvori
                     _rec[ "_ppk1" ] := "1"
                     dbf_update_rec( _rec )
                     nZatvori -= nUplaceno

                  ELSEIF nZatvori < nUplaceno

                     // imamo i ostatak sredstava razbij uplatu !!
                     SKIP
                     nSljRec := RecNo()
                     SKIP -1

                     nOdem := field->iznosdem - nZatvori * field->iznosdem / field->iznosbhd

                     // alikvotni dio..HA HA HA

                     _rec := dbf_get_rec()

                     _rec[ "brdok" ] := cZatvori
                     _rec[ "_ppk1" ] := "1"
                     _rec[ "iznosbhd" ] := nZatvori
                     _rec[ "iznosdem" ] := field->iznosdem - nODem

                     dbf_update_rec( _rec )

                     _rec := dbf_get_rec()

                     _rec[ "iznosbhd" ] := nUplaceno - nZatvori
                     _rec[ "iznosdem" ] := nOdem

                     IF Round( _rec[ "iznosbhd" ], 4 ) <> 0 .AND. Round( nOdem, 4 ) <> 0

                        APPEND BLANK

                        _rec[ "brdok" ] := "AVANS"
                        _rec[ "_ppk1" ] := ""

                        // resetuj broj zapisa iz suban tabele !
                        _rec[ "_recno" ] := 0

                        // sredi mi redni broj stavke
                        // na osnovu zadnjeg broja unutar naloga
                        _rec[ "rbr" ] := fin_dok_get_next_rbr( _rec[ "idfirma" ], _rec[ "idvn" ], _rec[ "brnal" ] )

                        dbf_update_rec( _rec )

                     ENDIF

                     nZatvori := 0

                     GO nSljRec
                     LOOP

                  ENDIF

                  IF nZatvori <= 0
                     EXIT
                  ENDIF

               ENDIF

            ENDIF

         ENDIF

         SKIP

      ENDDO

   ENDDO

   // !!! markiraj stavke koje su postale zatvorene
   SET ORDER TO TAG "3"
   GO TOP

   DO WHILE !Eof()

      cBrDok := brdok
      nSaldo := 0
      nSljRec := RecNo()

      DO WHILE !Eof() .AND. cidfirma + cidkonto + cidpartner + cbrdok = idfirma + idkonto + idpartner + brdok
         IF d_p == "1"
            nSaldo += iznosbhd
         ELSE
            nSaldo -= iznosbhd
         ENDIF
         SKIP
      ENDDO
      IF Round( nsaldo, 4 ) = 0
         GO nSljRec
         DO WHILE !Eof() .AND. cidfirma + cidkonto + cidpartner + cbrdok = idfirma + idkonto + idpartner + brdok
            _rec := dbf_get_rec()
            _rec[ "otvst" ] := "9"
            dbf_update_rec( _rec )
            SKIP
         ENDDO
      ENDIF
   ENDDO

   SELECT ( F_SUBAN )
   USE
   SELECT ( F_OSUBAN )
   USE

   // otvaram osuban kao suban alijas
   // radi stampe kartice itd...
   SELECT ( F_SUBAN )
   my_use_temp( "SUBAN", my_home() + my_dbf_prefix() + "osuban", .F., .F. )

   SELECT suban
   SET ORDER TO TAG "1"
   // IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr

   IF RecCount() = 0
      USE
      MsgBeep( "Nema otvorenih stavki" )
      RETURN
   ENDIF

   Box(, _max_rows, _max_cols )

   ImeKol := {}
   AAdd( ImeKol, { "O.Brdok",    {|| _OBrDok }                  } )
   AAdd( ImeKol, { "Br.Veze",     {|| BrDok }                          } )
   AAdd( ImeKol, { "Dat.Dok.",   {|| DatDok }                         } )
   AAdd( ImeKol, { "Dat.Val.",   {|| DatVal }                         } )
   AAdd( ImeKol, { PadR( "Duguje " + AllTrim( ValDomaca() ), 18 ), {|| Str( ( iif( D_P == "1", iznosbhd, 0 ) ), 18, 2 ) }     } )
   AAdd( ImeKol, { PadR( "Potraz." + AllTrim( ValDomaca() ), 18 ), {|| Str( ( iif( D_P == "2", iznosbhd, 0 ) ), 18, 2 ) }     } )
   AAdd( ImeKol, { "M1",         {|| m1 }                          } )
   AAdd( ImeKol, { PadR( "Iznos " + AllTrim( ValPomocna() ), 14 ),  {|| Str( iznosdem, 14, 2 ) }                       } )
   AAdd( ImeKol, { "nalog",    {|| idvn + "-" + brnal + "/" + rbr }                  } )
   AAdd( ImeKol, { "O",          {|| OtvSt }                          } )
   AAdd( ImeKol, { "Partner",     {|| IdPartner }                          } )

   Kol := {}
   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   PRIVATE  bGoreRed := NIL
   PRIVATE  bDoleRed := NIL
   PRIVATE  bDodajRed := NIL
   PRIVATE  fTBNoviRed := .F. // trenutno smo u novom redu ?
   PRIVATE  TBCanClose := .T. // da li se moze zavrsiti unos podataka ?
   PRIVATE  TBAppend := "N"  // mogu dodavati slogove
   PRIVATE  bZaglavlje := NIL
   // zaglavlje se edituje kada je kursor u prvoj koloni
   // prvog reda
   PRIVATE  TBSkipBlock := {| nSkip| SkipDBBK( nSkip ) }
   PRIVATE  nTBLine := 1      // tekuca linija-kod viselinijskog browsa
   PRIVATE  nTBLastLine := 1  // broj linija kod viselinijskog browsa
   PRIVATE  TBPomjerise := "" // ako je ">2" pomjeri se lijevo dva
   // ovo se mo§e setovati u when/valid fjama
   PRIVATE  TBScatter := "N"  // uzmi samo tekue polje
   adImeKol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( adImeKol, ImeKol[ i ] )
   NEXT

   adKol := {}

   FOR i := 1 TO Len( adImeKol )
      AAdd( adKol, i )
   NEXT

   PRIVATE bBKUslov := {|| idFirma + idkonto + idpartner = cidFirma + cidkonto + cidpartner }
   PRIVATE bBkTrazi := {|| cIdFirma + cIdkonto + cIdPartner }
   PRIVATE aPPos := { cIdPartner, 1 }  // pozicija kolone partner, broj veze

   SET CURSOR ON

   @ m_x + ( _max_rows - 5 ), m_y + 1 SAY "****************  REZULTATI ASISTENTA ************"
   @ m_x + ( _max_rows - 4 ), m_y + 1 SAY REPL( "=", MAXCOLS() - 2 )
   @ m_x + ( _max_rows - 3 ), m_y + 1 SAY " <F2> Ispravka broja dok.       <c-P> Print      <a-P> Print Br.Dok           "
   @ m_x + ( _max_rows - 2 ), m_y + 1 SAY8 " <K> Uključi/isključi račun za kamate "
   @ m_x + ( _max_rows - 1 ), m_y + 1 SAY8 ' < F6 > Štampanje izvršenih promjena  '

   PRIVATE cPomBrDok := Space( 10 )

   SEEK Eval( bBkTrazi )

   my_db_edit( "Ost", _max_rows, _max_cols, {|| rucno_zatvaranje_key_handler( .T. ) }, "", "", .F., NIL, 1, {|| brdok <> _obrdok }, 6, 0, ;  // zadnji par: nGPrazno
   NIL, {| nSkip| SkipDBBK( nSkip ) } )

   BoxC()

   GO TOP

   fPromjene := .F.
   DO WHILE !Eof()
      IF _obrdok <> brdok
         fPromjene := .T.
         EXIT
      ENDIF
      SKIP
   ENDDO

   IF fpromjene
      GO TOP
      IF Pitanje(, "Prikazati rezultate asistenta (D/N) ?", "N" ) = "D"
         StAz()
      ENDIF
   ELSE
      SELECT suban
      USE
      RETURN
   ENDIF

   SELECT ( F_OSUBAN )
   USE
   SELECT ( F_SUBAN )
   USE

   MsgBeep( "U slucaju da ažurirate rezultate asistenta#program će izmijeniti sadržaj subanalitičkih podataka !" )

   IF Pitanje(, "Želite li izvrsiti ažuriranje rezultata asistenta u kumulativ (D/N) ?", "N" ) == "D"

      SELECT ( F_OSUBAN )
      my_use_temp( "OSUBAN", my_home() + my_dbf_prefix() + "osuban", .F., .T. )

      O_SUBAN

      IF !promjene_otvorenih_stavki_se_mogu_azurirati()
         my_close_all_dbf()
         RETURN
      ENDIF

      IF !brisi_otvorene_stavke_iz_tabele_suban()
         MsgBeep( "Greška sa brisanjem stavki iz tabele SUBAN !" )
         my_close_all_dbf()
         RETURN
      ENDIF

      IF !dodaj_promjene_iz_osuban_u_suban()
         MsgBeep( "Greška kod dodavanja stavki u kumulativnu SUBAN tabelu !" )
         my_close_all_dbf()
         RETURN
      ENDIF

      MsgBeep( "Promjene su izvršene - provjerite podatke na kartici !" )

   ENDIF

   my_close_all_dbf()

   RETURN



STATIC FUNCTION promjene_otvorenih_stavki_se_mogu_azurirati()

   LOCAL lRet := .F.

   SELECT osuban
   GO TOP

   DO WHILE !Eof()

      IF osuban->_recno == 0
         SKIP
         LOOP
      ENDIF

      SELECT suban
      GO osuban->_recno

      IF Eof() .OR. idfirma <> osuban->idfirma .OR. idvn <> osuban->idvn .OR. brnal <> osuban->brnal .OR. idkonto <> osuban->idkonto .OR. idpartner <> osuban->idpartner .OR. d_p <> osuban->d_p
         lRet := .F.
         MsgBeep( "Izgleda da je drugi korisnik radio na ovom partneru#Prekidam operaciju !!!" )
         EXIT
      ENDIF

      SELECT osuban
      SKIP

   ENDDO

   RETURN lRet



STATIC FUNCTION dodaj_promjene_iz_osuban_u_suban()

   LOCAL _rec
   LOCAL lRet := .F.
   LOCAL lOk := .T.
   LOCAL hParams

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Ne mogu zaključati tabelu fin_suban !#Operacija poništena." )
      RETURN lRet
   ENDIF

   SELECT osuban
   GO TOP

   DO WHILE !Eof()

      _rec := dbf_get_rec()

      hb_HDel( _rec, "_recno" )
      hb_HDel( _rec, "_ppk1" )
      hb_HDel( _rec, "_obrdok" )

      SELECT suban
      APPEND BLANK

      lOk := update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

      IF !lOk
         EXIT
      ENDIF

      SELECT osuban
      SKIP

   ENDDO

   IF lOk
      lRet := .T.
      hParams := hb_hash()
      hParams[ "unlock" ] := { "fin_suban" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   RETURN lRet


STATIC FUNCTION brisi_otvorene_stavke_iz_tabele_suban()

   LOCAL _rec
   LOCAL lOk := .T.
   LOCAL lRet := .F.
   LOCAL hParams

   run_sql_query( "BEGIN" )

   IF !f18_lock_tables( { "fin_suban" }, .T. )
      run_sql_query( "ROLLBACK" )
      MsgBeep( "Problem sa zaključavanjem tabele fin_suban !#Prekidam operaciju." )
      RETURN lRet
   ENDIF

   SELECT osuban
   GO TOP

   DO WHILE !Eof()

      IF osuban->_recno == 0
         SKIP
         LOOP
      ENDIF

      SELECT suban
      GO osuban->_recno

      IF !Eof()
         _rec := dbf_get_rec()
         lOk := delete_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )
      ENDIF

      IF !lOk
         EXIT
      ENDIF

      SELECT osuban
      SKIP

   ENDDO

   IF lOk
      lRet := .T.
      hParams := hb_hash()
      hParams[ "unlock" ] := { "fin_suban" }
      run_sql_query( "COMMIT", hParams )
   ELSE
      run_sql_query( "ROLLBACK" )
   ENDIF

   RETURN lRet



/* StAz()
 *     Stampa promjena
 */

FUNCTION StAz()

   aKol := {}
   AAdd( aKol, { "Originalni",    {|| _obrdok }, .F., "C", 10,  0, 1, 1    } )
   AAdd( aKol, { "Br.Veze  ",    {|| "#" }, .F., "C", 10,  0, 2, 1    } )
   AAdd( aKol, { "Br.Veze",       {|| BrDok }, .F., "C", 10, 0, 1, 2  } )

   AAdd( aKol, { "Dat.Dok",       {|| DatDok }, .F., "D", 8, 0, 1, 3  } )
   AAdd( aKol, { "Duguje",    {|| Str( ( iif( D_P == "1", iznosbhd, 0 ) ), 18, 2 ) }, .F., "C", 18, 0, 1, 4  } )
   AAdd( aKol, { "Potrazuje",    {|| Str( ( iif( D_P == "2", iznosbhd, 0 ) ), 18, 2 ) }, .F., "C", 18, 0, 1, 5  } )
   AAdd( aKol, { "Nalog",    {|| idvn + "-" + brnal + "/" + rbr }, .F., "C", 20, 0, 1, 6  } )
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
   start_print()

   print_lista_2( aKol,,, 0,, ;
      , "Rezultati asistenta otvorenih stavki za: " + idkonto + "/" + idpartner + " na datum:" + DToC( Date() ) )

   end_print()

   RETURN .T.




/* SkipDBBK(nRequest)
 *
 *   param: nRequest
 */

STATIC FUNCTION SkipDBBK( nRequest )

   LOCAL nCount

   nCount := 0

   IF LastRec() != 0

      IF ! Eval( bBKUslov )
         SEEK Eval( bBkTrazi )
         IF ! Eval( bBKUslov )
            GO BOTTOM
            SKIP 1
         ENDIF
         nRequest = 0
      ENDIF

      IF nRequest > 0
         DO WHILE nCount < nRequest .AND. Eval( bBKUslov )
            SKIP 1
            IF Eof() .OR. !Eval( bBKUslov )
               SKIP -1
               EXIT
            ENDIF
            nCount++
         ENDDO

      ELSEIF nRequest < 0
         DO WHILE nCount > nRequest .AND. Eval( bBKUslov )
            SKIP -1
            IF ( Bof() )
               EXIT
            ENDIF
            nCount--
         ENDDO
         IF !Eval( bBKUslov )
            SKIP 1
            nCount++
         ENDIF

      ENDIF

   ENDIF

   RETURN ( nCount )
