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

MEMVAR M // linija - crtice koja se štampaju na izvještaju

/*
   Štampa ažuriranog finansijskog naloga
*/

FUNCTION fin_nalog_azurirani()

   LOCAL dDatNal
   PRIVATE fK1 := fk2 := fk3 := fk4 := "N", gnLOst := 0, gPotpis := "N"

   fin_read_params()

   O_NALOG
   O_SUBAN
   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK

   SELECT SUBAN
   SET ORDER TO TAG "4"

   cIdVN := Space( 2 )
   cIdFirma := gFirma
   cBrNal := Space( 8 )

   Box( "", 2, 35 )

   SET CURSOR ON

   @ m_x + 1, m_y + 2 SAY "Nalog:"
   @ m_x + 1, Col() + 1 SAY cIdFirma
   @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID _f_brnal( @cBrNal )

   READ

   ESC_BCR

   BoxC()

   SELECT nalog
   SEEK cIdfirma + cIdvn + cBrnal

   NFOUND CRET
   dDatNal := datnal

   SELECT SUBAN
   SEEK cIdfirma + cIdvn + cBrNal

   START PRINT CRET

   fin_nalog_stampa( "2", NIL, dDatNal )
   my_close_all_dbf()

   ENDPRINT

   RETURN .T.


FUNCTION fin_nalog_priprema()

   my_close_all_dbf()
   fin_gen_ptabele_stampa_nalozi()

   RETURN NIL

/*
   Koristi se u KALK za štampu finansijskog naloga

*/

FUNCTION fin_nalog_priprema_kalk( lAuto )

   PRIVATE gDatNal := "N"
   PRIVATE gRavnot := "D"
   PRIVATE cDatVal := "D"

   IF ( lAuto == NIL )
      lAuto := .F.
   ENDIF

   IF gaFin == "D"

      kontrola_zbira_naloga_kalk( lAuto )

      IF lAuto == .F. .OR. ( lAuto == .T. .AND. gAImpPrint == "D" )
         fin_gen_ptabele_stampa_nalozi( lAuto )
      ELSE
         fin_gen_psuban_stavke_kalk()
         fin_gen_sint_stavke_kalk()
      ENDIF

      fin_azuriranje_naloga( lAuto )

   ENDIF

   RETURN .T.


/*
   generisi psuban, psint, pnalog, štampaj sve naloge
*/
FUNCTION fin_gen_ptabele_stampa_nalozi( lAuto )

   LOCAL dDatNal := Date()

   IF fin_gen_psuban_stampa_nalozi( lAuto, @dDatNal )
      fin_gen_sint_stavke( lAuto, dDatNal )
   ENDIF

   RETURN .T.



/*
   Generiše psuban, pa štampa sve naloge
*/
FUNCTION fin_gen_psuban_stampa_nalozi( lAuto, dDatNal )

   LOCAL _print_opt := "V"
   LOCAL oNalog, oNalozi := FinNalozi():New()

   PRIVATE aNalozi := {}

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

#ifdef F18_DEBUG_FIN_AZUR
   AltD() // F18_DEBUG_FIN_AZUR
#endif

   fin_open_psuban()


   SELECT PSUBAN
   my_dbf_zap()

   SELECT fin_pripr
   SET ORDER TO TAG "1"

   GO TOP

   EOF CRET .F.


   IF lAuto
      _print_opt := "D"
      Box(, 3, 75 )
      @ m_x + 0, m_y + 2 SAY "PROCES FORMIRANJA SINTETIKE I ANALITIKE"
   ENDIF

   DO WHILE !Eof()

      cIdFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal

      IF !lAuto
         IF !box_fin_nalog( @cIdFirma, @cIdVn, @cBrNal, @dDatNal )
            RETURN .F.
         ENDIF
      ENDIF

      HSEEK cIdFirma + cIdVN + cBrNal
      IF Eof()
         my_close_all_dbf()
         RETURN .F.
      ENDIF

      oNalog := FinNalog():New( cIdFirma, cIdVn, cBrNal )

      IF !lAuto
         f18_start_print( NIL, @_print_opt )
      ENDIF

      fin_nalog_stampa( "1", lAuto, dDatNal, @oNalog )
      oNalozi:addNalog( oNalog )

      IF !lAuto
         PushWA()
         my_close_all_dbf()
         f18_end_print( NIL, @_print_opt )
         fin_open_psuban()
         PopWa()
      ENDIF


      IF AScan( aNalozi, cIdFirma + cIdVN + cBrNal ) == 0

         AAdd( aNalozi, cIdFirma + cIdVN + cBrNal )
         // lista naloga koji su otisli
         IF lAuto
            @ m_x + 2, m_y + 2 SAY "Formirana sintetika i analitika za nalog:" + cIdFirma + "-" + cIdVN + "-" + cBrNal
         ENDIF
      ENDIF

   ENDDO


   IF lAuto
      BoxC()
   ENDIF

   my_close_all_dbf()

   IF !oNalozi:valid()
      oNalozi:showErrors()
   ENDIF

   RETURN .T.



/*
   Štampa (su)banalitičkog finansijski nalog
   - ako smo na fin_pripr onda puni psuban sa sadržajem fin_pripr
*/

FUNCTION fin_nalog_stampa( cInd, lAuto, dDatNal, oNalog )

   LOCAL nArr := Select()
   LOCAL aRez := {}
   LOCAL aOpis := {}
   LOCAL _vrste_placanja
   LOCAL _fin_params := fin_params()

#ifdef F18_DEBUG_FIN_AZUR
   AltD() // F18_DEBUG_FIN_AZUR
#endif

   IF lAuto = NIL
      lAuto := .F.
   ENDIF

   IF dDatNal == NIL
      dDatNal := Date()
   ENDIF

   _vrste_placanja := .F.

   O_PARTN
   SELECT ( nArr )


   PicBHD := "@Z " + FormPicL( gPicBHD, 15 )
   PicDEM := "@Z " + FormPicL( gPicDEM, 10 )

   M := iif( cInd == "3", "------ -------------- --- ", "" )
   IF _fin_params[ "fin_tip_dokumenta" ]

      M +=  + "---- ------- " + REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------"
      M +=  " -- ------------- ----------- -------- -------- --------------- ---------------"

   ELSE

      M +=  "---- ------- "
      M += REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------"
      M += " ----------- -------- -------- --------------- ---------------"

   ENDIF
   M +=  iif( gVar1 == "1", "-", " ---------- ----------" )

   IF cInd $ "1#2"
      nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0
      nStr := 0
   ENDIF

   cIdFirma := field->IdFirma
   cIdVN := field->IdVN
   cBrNal := field->BrNal

   b2 := {|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }

   IF cInd $ "1#2" .AND. !lAuto
      fin_nalog_zaglavlje( dDatNal )
   ENDIF

   DO WHILE !Eof() .AND. Eval( b2 )

      IF oNalog != NIL
         oNalog:addStavka( field->datDok )
      ENDIF

      IF !lAuto

         IF PRow() > 61 + iif( cInd == "3", -7, 0 ) + dodatni_redovi_po_stranici()
            IF cInd == "3"
               PrenosDNal()
            ELSE
               FF
            ENDIF
            fin_nalog_zaglavlje( dDatnal )
         ENDIF
         P_NRED

         IF cInd == "3"
            @ PRow(), 0 SAY Str( ++nRBrDN, 6 )
            @ PRow(), PCol() + 1 SAY cIdFirma + "-" + cIdVN + "-" + cBrNal
            @ PRow(), PCol() + 1 SAY " " + Left( DToC( dDatNal ), 2 )
            @ PRow(), PCol() + 1 SAY RBr
         ELSE
            @ PRow(), 0 SAY RBr
         ENDIF

         @ PRow(), PCol() + 1 SAY IdKonto

         _kto_naz := ""
         _part_naz := ""
         _part_naz2 := ""

         IF !Empty( IdPartner )

            IF gVSubOp == "D"

               SELECT KONTO
               HSEEK ( nArr )->idkonto
               IF Found()
                  _kto_naz := konto->naz
               ENDIF

               SELECT PARTN
               HSEEK ( nArr )->idpartner
               IF Found()
                  _part_naz := partn->naz
                  _part_naz2 := partn->naz2
               ENDIF

               cStr := Trim( _kto_naz ) + " (" + Trim( Trim( _part_naz ) + " " + Trim( _part_naz2 ) ) + ")"

            ELSE

               SELECT PARTN
               HSEEK ( nArr )->idpartner
               IF Found()
                  _part_naz := partn->naz
                  _part_naz2 := partn->naz2
               ENDIF

               cStr := Trim( _part_naz ) + " " + Trim( _part_naz2 )

            ENDIF
         ELSE

            SELECT KONTO
            HSEEK ( nArr )->idkonto

            IF Found()
               _kto_naz := konto->naz
            ENDIF

            cStr := _kto_naz

         ENDIF

         SELECT ( nArr )

         // konto partner
         aRez := SjeciStr( cStr, 28 )
         cStr := opis
         aOpis := SjeciStr( cStr, 20 )

         // šifra partnera
         @ PRow(), PCol() + 1 SAY Idpartner( idpartner )
         nColStr := PCol() + 1


         @  PRow(), PCol() + 1 SAY PadR( aRez[ 1 ], 28 )
         nColDok := PCol() + 1

         IF _fin_params[ "fin_tip_dokumenta" ]

            @ PRow(), PCol() + 1 SAY IdTipDok

            SELECT TDOK
            HSEEK ( nArr )->idtipdok
            @ PRow(), PCol() + 1 SAY PadR( naz, 13 )

            SELECT ( nArr )
            @ PRow(), PCol() + 1 SAY PadR( BrDok, 11 )

         ELSE
            @ PRow(), PCol() + 1 SAY PadR( BrDok, 11 )
         ENDIF

         @ PRow(), PCol() + 1 SAY DatDok
         IF gDatVal == "D"
            @ PRow(), PCol() + 1 SAY DatVal
         ELSE
            @ PRow(), PCol() + 1 SAY Space( 8 )
         ENDIF
         nColIzn := PCol() + 1

      ENDIF

      IF D_P == "1"

         IF !lAuto
            @ PRow(), PCol() + 1 SAY IznosBHD PICTURE PicBHD
            @ PRow(), PCol() + 1 SAY 0 PICTURE PicBHD
         ENDIF
         nUkDugBHD += IznosBHD
         IF cInd == "3"
            nTSDugBHD += IznosBHD
         ENDIF

      ELSE

         IF !lAuto
            @ PRow(), PCol() + 1 SAY 0 PICTURE PicBHD
            @ PRow(), PCol() + 1 SAY IznosBHD PICTURE PicBHD
         ENDIF
         nUkPotBHD += IznosBHD
         IF cInd == "3"
            nTSPotBHD += IznosBHD
         ENDIF

      ENDIF

      IF gVar1 != "1"

         IF D_P == "1"
            IF !lAuto
               @ PRow(), PCol() + 1 SAY IznosDEM PICTURE PicDEM
               @ PRow(), PCol() + 1 SAY 0 PICTURE PicDEM
            ENDIF
            nUkDugDEM += IznosDEM
            IF cInd == "3"
               nTSDugDEM += IznosDEM
            ENDIF

         ELSE

            IF !lAuto
               @ PRow(), PCol() + 1 SAY 0 PICTURE PicDEM
               @ PRow(), PCol() + 1 SAY IznosDEM PICTURE PicDEM
            ENDIF
            nUkPotDEM += IznosDEM
            IF cInd == "3"
               nTSPotDEM += IznosDEM
            ENDIF
         ENDIF

      ENDIF

      IF !lAuto

         Pok := 0
         FOR i := 2 TO Max( Len( aRez ), Len( aOpis ) + 1 )
            IF i <= Len( aRez )
               @ PRow() + 1, nColStr SAY aRez[ i ]
            ELSE
               pok := 1
            ENDIF

            @ PRow() + pok, nColDok SAY iif( i - 1 <= Len( aOpis ), aOpis[ i - 1 ], Space( 20 ) )
            IF i == 2 .AND. ( !Empty( k1 + k2 + k3 + k4 ) .OR. grj == "D" .OR. gtroskovi == "D" )
               ?? " " + k1 + "-" + k2 + "-" + K3Iz256( k3 ) + "-" + k4
               IF _vrste_placanja
                  ?? "(" + Ocitaj( F_VRSTEP, k4, "naz" ) + ")"
               ENDIF
               IF gRj == "D"
                  ?? " RJ:", idrj
               ENDIF
               IF gTroskovi == "D"
                  ?? "    Funk:", Funk
                  ?? "    Fond:", Fond
               ENDIF
            ENDIF
         NEXT

      ENDIF

      IF cInd == "1" .AND. AScan( aNalozi, cIdFirma + cIdVN + cBrNal ) == 0

         // priprema
         SELECT ( nArr )
         Scatter()
         SELECT PSUBAN
         APPEND BLANK

         Gather()
      ENDIF

      SELECT ( nArr )
      SKIP 1
   ENDDO

   IF cInd $ "1#2" .AND. !lAuto

      IF PRow() > 58 + dodatni_redovi_po_stranici()
         FF
         fin_nalog_zaglavlje( dDatNal )
      ENDIF

      P_NRED
      ?? M
      P_NRED

      ?? "Z B I R   N A L O G A:"
      @ PRow(), nColIzn  SAY nUkDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD

      IF gVar1 != "1"
         @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE picDEM
         @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE picDEM
      ENDIF

      P_NRED
      ?? M

      nUkDugBHD := nUKPotBHD := nUkDugDEM := nUKPotDEM := 0

      IF gPotpis == "D"
         IF PRow() > 58 + dodatni_redovi_po_stranici()
            FF
            fin_nalog_zaglavlje( dDatNal )
         ENDIF
         P_NRED
         P_NRED
         F12CPI
         P_NRED
         @ PRow(), 55 SAY "Obrada AOP "; ?? Replicate( "_", 20 )
         P_NRED
         @ PRow(), 55 SAY "Kontirao   "; ?? Replicate( "_", 20 )
      ENDIF
      FF

   ELSEIF cInd == "3"
      IF PRow() > 54 + dodatni_redovi_po_stranici()
         PrenosDNal()
      ENDIF
   ENDIF

   RETURN .T.





FUNCTION fin_gen_sint_stavke( lAuto, dDatNal )

   LOCAL A, cDN := "N"
   LOCAL nStr, nD1, nD2, nP1, nP2
   LOCAL cIdFirma, cIDVn, cBrNal
   LOCAL nDugBHD, nDugDEM, nPotBHD, nPotDEM

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   IF !fin_open_lock_panal( .T. )
      RETURN .F.
   ENDIF

   SELECT PSUBAN
   SET ORDER TO TAG "2"
   GO TOP
   IF Empty( PSUBAN->BrNal )
      MsgBeep( "subanalitika prazna" )
      my_close_all_dbf()
      RETURN
   ENDIF

   A := 0
   DO WHILE !Eof()

      cIdFirma := psuban->IdFirma
      cIDVn = psuban->IdVN
      cBrNal := psuban->BrNal

      fin_gen_panal_psint( cIdFirma, cIdVn, cBrNal, dDatNal )

      IF !lAuto
         Box(, 2, 58 )
         @ m_x + 1, m_y + 2 SAY8 "Štampanje analitike/sintetike za nalog " + cIdfirma + "-" + cIdvn + "-" + cBrnal + " ?"  GET cDN PICT "@!" VALID cDN $ "DN"
         READ
         BoxC()
      ENDIF

      SELECT PSUBAN
      PushWA()

      IF cDN == "D"
         SELECT PANAL
         SEEK cIdfirma + cIdvn + cBrnal
         fin_sinteticki_nalog( .F. )
      ENDIF

      my_close_all_dbf()
      fin_open_lock_panal( .F. )

      PopWa()

   ENDDO

   SELECT PANAL
   my_flock()

   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma
      cIDVn = IdVN
      cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   SELECT PSINT
   my_flock()

   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma
      cIDVn = IdVN
      cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   my_close_all_dbf()

   RETURN


/*
    fin_nalog_zaglavlje()
    Zaglavlje (sub)analitickog naloga
*/

FUNCTION fin_nalog_zaglavlje( dDatNal )

   LOCAL nArr, lDnevnik := .F.
   LOCAL _fin_params := fin_params()
   LOCAL cTmp

   IF "DNEVNIKN" == PadR( Upper( ProcName( 1 ) ), 8 ) .OR. "DNEVNIKN" == PadR( Upper( ProcName( 2 ) ), 8 )
      lDnevnik := .T.
   ENDIF


   ?
   IF _fin_params[ "fin_tip_dokumenta" ] .AND. gVar1 == "0"
      P_COND2
   ELSE
      P_COND
   ENDIF

   B_ON

   ?? Upper( gTS ) + ":", gNFirma
   ?
   nArr := Select()

   IF _fin_params[ "fin_tip_dokumenta" ]
      SELECT partn
      HSEEK cIdfirma
      SELECT ( nArr )
      ? cidfirma, "-", AllTrim( partn->naz )
   ENDIF

   ?
   IF lDnevnik
      ?U "FIN:      D N E V N I K    K NJ I Ž E NJ A    Z A    " + ;
         Upper( NazMjeseca( Month( dDatNal ) ) ) + " " + Str( Year( dDatNal ) ) + ". GODINE"
   ELSE
      ?U "FIN: NALOG ZA KNJIŽENJE BROJ :"
      @ PRow(), PCol() + 2 SAY cIdFirma + " - " + cIdVn + " - " + cBrNal
   ENDIF

   B_OFF
   IF gDatNal == "D" .AND. !lDnevnik
      @ PRow(), PCol() + 4 SAY "DATUM: "
      ?? dDatNal
   ENDIF

   IF !lDnevnik
      SELECT TNAL; HSEEK cidvn
      @ PRow(), PCol() + 4 SAY naz
   ENDIF

   @ PRow(), PCol() + 15 SAY "Str:" + Str( ++nStr, 3 )

   P_NRED

   ?? M

   IF !_fin_params[ "fin_tip_dokumenta" ]
      P_NRED

      cTmp := iif( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R. * KONTO *" + PadC( "PART", FIELD_PARTNER_ID_LENGTH )
      cTmp +=  "*" + "    NAZIV PARTNERA ILI      "  + "*   D  O  K  U  M  E  N  T    *         IZNOS U  " + ValDomaca() + "         *"
      cTmp += iif( gVar1 == "1", "", "    IZNOS U " + ValPomocna() + "    *" )
      ??U cTmp
      P_NRED

      cTmp := iif( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", FIELD_PARTNER_ID_LENGTH ) + " "
      cTmp += "                            " + " ----------------------------- ------------------------------- "
      cTmp += iif( gVar1 == "1", "", "---------------------" )
      ??U cTmp
      P_NRED

      cTmp := iif( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", FIELD_PARTNER_ID_LENGTH ) + "*"
      cTmp += "    NAZIV KONTA             "  + "* BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAŽUJE " + ValDomaca() + "*"
      cTmp += iif( gVar1 == "1", "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
      ??U cTmp

   ELSE
      P_NRED

      cTmp := iif( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R. * KONTO *" + PadC( "PART", FIELD_PARTNER_ID_LENGTH ) + "*"
      cTmp += "    NAZIV PARTNERA ILI      "  + "*           D  O  K  U  M  E  N  T             *         IZNOS U  " + ValDomaca() + "         *"
      cTmp += iif( gVar1 == "1", "", "    IZNOS U " + ValPomocna() + "    *" )
      ??U cTmp
      P_NRED

      cTmp := iif( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", FIELD_PARTNER_ID_LENGTH ) + " "
      cTmp += "                            " + " ---------------------------------------------- ------------------------------- "
      cTmp += iif( gVar1 == "1", "", "---------------------" )
      ??U cTmp
      P_NRED


      cTmp := iif( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", FIELD_PARTNER_ID_LENGTH ) + "*"
      cTmp += "    NAZIV KONTA             " + "*  TIP I NAZIV   * BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAŽUJE " + ValDomaca() + "*"
      cTmp +=  iif( gVar1 == "1", "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
      ??U cTmp

   ENDIF

   P_NRED
   ?? M

   Select( nArr )

   RETURN


/*! \fn PrenosDNal()
 *  \brief Ispis prenos na sljedecu stranicu
 */

FUNCTION PrenosDNal()

   ? m
   ? PadR( "UKUPNO NA STRANI " + AllTrim( Str( nStr ) ), 30 ) + ":"
   @ PRow(), nColIzn  SAY nTSDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nTSPotBHD PICTURE picBHD
   IF gVar1 != "1"
      @ PRow(), PCol() + 1 SAY nTSDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nTSPotDEM PICTURE picDEM
   ENDIF
   ? m
   ? PadR( "DONOS SA PRETHODNE STRANE", 30 ) + ":"
   @ PRow(), nColIzn  SAY nUkDugBHD - nTSDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nUkPotBHD - nTSPotBHD PICTURE picBHD
   IF gVar1 != "1"
      @ PRow(), PCol() + 1 SAY nUkDugDEM - nTSDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM - nTSPotDEM PICTURE picDEM
   ENDIF
   ? m
   ? PadR( "PRENOS NA NAREDNU STRANU", 30 ) + ":"
   @ PRow(), nColIzn  SAY nUkDugBHD PICTURE picBHD
   @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD
   IF gVar1 != "1"
      @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE picDEM
      @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE picDEM
   ENDIF
   ? m
   FF
   nTSDugBHD := nTSPotBHD := nTSDugDEM := nTSPotDEM := 0   // tekuca strana

   RETURN
