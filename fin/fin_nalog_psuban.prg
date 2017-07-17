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

/*
   Štampa (su)banalitičkog finansijski nalog
   - ako smo na fin_pripr onda puni psuban sa sadržajem fin_pripr
*/

FUNCTION fin_nalog_stampa_fill_psuban( cInd, lAuto, dDatNal, oNalog )

   LOCAL nArr := Select()
   LOCAL aRez := {}
   LOCAL aOpis := {}
   LOCAL _vrste_placanja
   LOCAL _fin_params := fin_params()
   LOCAL nColI

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

   //o_partner()

   PicBHD := "@Z " + FormPicL( gPicBHD, 15 )
   PicDEM := "@Z " + FormPicL( pic_iznos_eur(), 10 )

   M := iif( cInd == "3", "------ -------------- --- ", "" )
   IF _fin_params[ "fin_tip_dokumenta" ]

      M +=  + "---- ------- " + REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------"
      M +=  " -- ------------- ----------- -------- -------- --------------- ---------------"

   ELSE

      M +=  "---- ------- "
      M += REPL( "-", FIELD_PARTNER_ID_LENGTH ) + " ----------------------------"
      M += " ----------- -------- -------- --------------- ---------------"

   ENDIF
   M += iif( fin_jednovalutno(), "-", " ---------- ----------" )

   IF cInd $ "1#2"
      nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0
      nStr := 0
   ENDIF


   SELECT ( nArr ) // fin_pripr
   my_flock()

   cIdFirma := field->IdFirma
   cIdVN := field->IdVN
   cBrNal := field->BrNal

   b2 := {|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }

   IF cInd $ "1#2" .AND. !lAuto
      fin_nalog_zaglavlje( dDatNal )
   ENDIF


   DO WHILE !Eof() .AND. Eval( b2 )

      Scatter()  // fin_pripr zaokruzenje iznosa na dvije decimale
      _iznosbhd := Round( _iznosbhd, 2 )
      _iznosdem := Round( _iznosdem, 2 )
      Gather()

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
            @ PRow(), 0 SAY RBr PICT "99999"
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

               select_o_partner( ( nArr )->idpartner )
               IF Found()
                  _part_naz := partn->naz
                  _part_naz2 := partn->naz2
               ENDIF

               cStr := Trim( _kto_naz ) + " (" + Trim( Trim( _part_naz ) + " " + Trim( _part_naz2 ) ) + ")"

            ELSE

               IF select_o_partner( ( nArr )->idpartner )
                  _part_naz := partn->naz
                  _part_naz2 := partn->naz2
               ENDIF

               cStr := Trim( _part_naz ) + " " + Trim( _part_naz2 )

            ENDIF
         ELSE

            IF select_o_konto( ( nArr )->idkonto )
               _kto_naz := konto->naz
            ENDIF

            cStr := _kto_naz

         ENDIF

         SELECT ( nArr )

         aRez := SjeciStr( cStr, 28 ) // konto partner
         cStr := opis
         aOpis := SjeciStr( cStr, 20 )


         @ PRow(), PCol() + 1 SAY Idpartner( idpartner ) // šifra partnera
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
            @ PRow(), PCol() + 1 SAY get_datval_field()
         ELSE
            @ PRow(), PCol() + 1 SAY Space( 8 )
         ENDIF
         s_nColIzn := PCol() + 1

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

      IF fin_dvovalutno()

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
            IF i == 2 .AND. ( !Empty( k1 + k2 + k3 + k4 ) .OR. gFinRj == "D" .OR. gFinFunkFond == "D" )
               ?? " " + k1 + "-" + k2 + "-" + K3Iz256( k3 ) + "-" + k4
               IF _vrste_placanja
                  ?? "(" + get_vrstep_naz( k4 ) + ")"
               ENDIF
               IF gFinRj == "D"
                  ?? " RJ:", idrj
               ENDIF
               IF gFinFunkFond == "D"
                  ?? "    Funk:", Funk
                  ?? "    Fond:", Fond
               ENDIF
            ENDIF
         NEXT

      ENDIF

      IF cInd == "1" .AND. AScan( aNalozi, cIdFirma + cIdVN + cBrNal ) == 0

         SELECT ( nArr ) // fin_pripr
         Scatter()

         SELECT PSUBAN
         APPEND BLANK   // fin_pripr - > psuban

         Gather()

      ENDIF

      SELECT ( nArr )
      SKIP 1
   ENDDO

   my_unlock()

   IF cInd $ "1#2" .AND. !lAuto

      IF PRow() > 58 + dodatni_redovi_po_stranici()
         FF
         fin_nalog_zaglavlje( dDatNal )
      ENDIF

      P_NRED
      ?? M
      P_NRED

      ?? "Z B I R   N A L O G A:"
      @ PRow(), s_nColIzn  SAY nUkDugBHD PICTURE picBHD
      @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE picBHD

      IF fin_dvovalutno()
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



/*
       fin_nalog_zaglavlje()
       Zaglavlje (sub)analitickog naloga
*/

FUNCTION fin_nalog_zaglavlje( dDatNal )

   LOCAL nArr, lDnevnik := is_stampa_dnevnika_naloga()
   LOCAL _fin_params := fin_params()
   LOCAL cTmp

   //IF "DNEVNIKN" == PadR( Upper( ProcName( 1 ) ), 8 ) .OR. "DNEVNIKN" == PadR( Upper( ProcName( 2 ) ), 8 )
  //    lDnevnik := .T.
   //ENDIF


   ?
   IF _fin_params[ "fin_tip_dokumenta" ] .AND. fin_dvovalutno()
      P_COND2
   ELSE
      P_COND
   ENDIF

   B_ON

   ?? Upper( tip_organizacije() ) + ":", self_organizacija_naziv()
   ?
   nArr := Select()

   IF _fin_params[ "fin_tip_dokumenta" ]
      select_o_partner( cIdfirma )
      SELECT ( nArr )
      ? cIdfirma, "-", AllTrim( partn->naz )
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
      select_o_tnal( cIdvn )
      @ PRow(), PCol() + 4 SAY naz
   ENDIF

   @ PRow(), PCol() + 15 SAY "Str:" + Str( ++nStr, 4 )

   P_NRED

   ?? M

   IF !_fin_params[ "fin_tip_dokumenta" ]
      P_NRED

      cTmp := iif( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R.   * KONTO *" + PadC( "PART", FIELD_PARTNER_ID_LENGTH )
      cTmp +=  "*" + "    NAZIV PARTNERA ILI      "  + "*   D  O  K  U  M  E  N  T    *         IZNOS U  " + ValDomaca() + "         *"
      cTmp += iif( fin_jednovalutno(), "", "    IZNOS U " + ValPomocna() + "    *" )
      ??U cTmp
      P_NRED

      cTmp := iif( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", FIELD_PARTNER_ID_LENGTH ) + " "
      cTmp += "                            " + " ----------------------------- ------------------------------- "
      cTmp += iif( fin_jednovalutno(), "", "---------------------" )
      ??U cTmp
      P_NRED

      cTmp := iif( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", FIELD_PARTNER_ID_LENGTH ) + "*"
      cTmp += "    NAZIV KONTA             "  + "* BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAŽUJE " + ValDomaca() + "*"
      cTmp += iif( fin_jednovalutno(), "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
      ??U cTmp

   ELSE
      P_NRED

      cTmp := iif( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R.   * KONTO *" + PadC( "PART", FIELD_PARTNER_ID_LENGTH ) + "*"
      cTmp += "    NAZIV PARTNERA ILI      "  + "*           D  O  K  U  M  E  N  T             *         IZNOS U  " + ValDomaca() + "         *"
      cTmp += iif( fin_jednovalutno(), "", "    IZNOS U " + ValPomocna() + "    *" )
      ??U cTmp
      P_NRED

      cTmp := iif( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "               " + PadC( "NER", FIELD_PARTNER_ID_LENGTH ) + " "
      cTmp += "                            " + " ---------------------------------------------- ------------------------------- "
      cTmp += iif( fin_jednovalutno(), "", "---------------------" )
      ??U cTmp
      P_NRED


      cTmp := iif( lDnevnik, "VNIKU *          *   *", "" ) + "*BR   *       *" + REPL( " ", FIELD_PARTNER_ID_LENGTH ) + "*"
      cTmp += "    NAZIV KONTA             " + "*  TIP I NAZIV   * BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAŽUJE " + ValDomaca() + "*"
      cTmp +=  iif( fin_jednovalutno(), "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
      ??U cTmp

   ENDIF

   P_NRED
   ?? M

   Select( nArr )

   RETURN .T.




/*
   filovanje potrebnih tabela kod auto importa
*/
FUNCTION fin_gen_psuban_stavke_auto_import()

   my_close_all_dbf()

   o_fin_pripr()
   o_konto()
   //o_partner()
   o_tnal()
   o_tdok()
   O_PSUBAN

   SELECT PSUBAN
   my_dbf_zap()

   SELECT fin_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF Eof()
      my_close_all_dbf()
      RETURN .F.
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

   RETURN .T.
