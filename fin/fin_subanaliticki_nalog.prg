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

#include "fin.ch"



FUNCTION fin_subanaliticki_nalog( cInd, lAuto, dDatNal )

   LOCAL nArr := Select()
   LOCAL aRez := {}
   LOCAL aOpis := {}
   LOCAL _vrste_placanja
   LOCAL _fin_params := fin_params()

   IF lAuto = NIL
      lAuto := .F.
   ENDIF

   _vrste_placanja := .F.

   O_PARTN
   __par_len := Len( partn->id )
   SELECT ( nArr )


   PicBHD := "@Z " + FormPicL( gPicBHD, 15 )
   PicDEM := "@Z " + FormPicL( gPicDEM, 10 )

   IF _fin_params[ "fin_tip_dokumenta" ]
      M := iif( cInd == "3", "------ -------------- --- ", "" ) + "---- ------- " + REPL( "-", __par_len ) + " ----------------------------" + " -- ------------- ----------- -------- -------- --------------- ---------------" + IF( gVar1 == "1", "-", " ---------- ----------" )
   ELSE
      M := iif( cInd == "3", "------ -------------- --- ", "" ) + "---- ------- " + REPL( "-", __par_len ) + " ----------------------------" + " ----------- -------- -------- --------------- ---------------" + IF( gVar1 == "1", "-", " ---------- ----------" )
   ENDIF

   IF cInd $ "1#2"
      nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0
      nStr := 0
   ENDIF

   cIdFirma := IdFirma
   cIdVN := IdVN
   cBrNal := BrNal
   b2 := {|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }

   IF cInd $ "1#2" .AND. !lAuto
      fin_zagl_analitika( dDatNal )
   ENDIF

   DO WHILE !Eof() .AND. Eval( b2 )
      IF !lAuto
         IF PRow() > 61 + iif( cInd == "3", -7, 0 ) + gPStranica
            IF cInd == "3"
               PrenosDNal()
            ELSE
               FF
            ENDIF
            fin_zagl_analitika( dDatnal )
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
               hseek ( nArr )->idkonto
               IF Found()
                  _kto_naz := konto->naz
               ENDIF

               SELECT PARTN
               hseek ( nArr )->idpartner
               IF Found()
                  _part_naz := partn->naz
                  _part_naz2 := partn->naz2
               ENDIF

               cStr := Trim( _kto_naz ) + " (" + Trim( Trim( _part_naz ) + " " + Trim( _part_naz2 ) ) + ")"

            ELSE

               SELECT PARTN
               hseek ( nArr )->idpartner
               IF Found()
                  _part_naz := partn->naz
                  _part_naz2 := partn->naz2
               ENDIF

               cStr := Trim( _part_naz ) + " " + Trim( _part_naz2 )

            ENDIF
         ELSE

            SELECT KONTO
            hseek ( nArr )->idkonto

            IF Found()
               _kto_naz := konto->naz
            ENDIF

            cStr := _kto_naz

         ENDIF

         SELECT ( nArr )

         aRez := SjeciStr( cStr, 28 )
         cStr := opis
         aOpis := SjeciStr( cStr, 20 )

         @ PRow(), PCol() + 1 SAY Idpartner( idpartner )

         nColStr := PCol() + 1

         @  PRow(), PCol() + 1 SAY PadR( aRez[ 1 ], 28 )

         nColDok := PCol() + 1

         IF gVar1 == "1"
            @ PRow(), PCol() + 1 SAY aOpis[ 1 ]
         ENDIF

         IF _fin_params[ "fin_tip_dokumenta" ]
            @ PRow(), PCol() + 1 SAY IdTipDok
            SELECT TDOK
            hseek ( nArr )->idtipdok
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
               
            @ PRow() + pok, nColDok SAY IF( i - 1 <= Len( aOpis ), aOpis[ i - 1 ], Space( 20 ) )
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

      IF cInd == "1" .AND. AScan( aNalozi, cIdFirma + cIdVN + cBrNal ) == 0  // samo ako se ne nalazi u psuban
         SELECT PSUBAN
         Scatter()
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

      IF PRow() > 58 + gPStranica
         FF
         fin_zagl_analitika( dDatNal )
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
         IF PRow() > 58 + gPStranica
               FF
               fin_zagl_analitika( dDatNal )
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
      IF PRow() > 54 + gPStranica
         PrenosDNal()
      ENDIF
   ENDIF

   RETURN


/*
    fin_zagl_analitika()
    Zaglavlje subanalitičkog/analitickog naloga
*/

FUNCTION fin_zagl_analitika( dDatNal )

   LOCAL nArr, lDnevnik := .F.
   LOCAL _fin_params := fin_params()
   LOCAL cTmp

   IF "DNEVNIKN" == PadR( Upper( ProcName( 1 ) ), 8 ) .OR. "DNEVNIKN" == PadR( Upper( ProcName( 2 ) ), 8 )
      lDnevnik := .T.
   ENDIF

   __par_len := Len( partn->id )

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
      hseek cIdfirma
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
      SELECT TNAL; hseek cidvn
      @ PRow(), PCol() + 4 SAY naz
   ENDIF

   @ PRow(), PCol() + 15 SAY "Str:" + Str( ++nStr, 3 )

   P_NRED

   ?? M

   IF !_fin_params[ "fin_tip_dokumenta" ]
      P_NRED

      cTmp := iif( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R. * KONTO *" + PadC( "PART", __par_len ) 
      cTmp +=  "*" + "    NAZIV PARTNERA ILI      "  + "*   D  O  K  U  M  E  N  T    *         IZNOS U  " + ValDomaca() + "         *" 
      cTmp += IIF( gVar1 == "1", "", "    IZNOS U " + ValPomocna() + "    *" )
      ??U cTmp
      P_NRED

      cTmp := IIF( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", __par_len ) + " " 
      cTmp += "                            " + " ----------------------------- ------------------------------- " 
      cTmp += IIF( gVar1 == "1", "", "---------------------" )
      ??U cTmp
      P_NRED

      cTmp := IIF( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", __par_len ) + "*" 
      cTmp += "    NAZIV KONTA             "  + "* BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAŽUJE " + ValDomaca() + "*" 
      cTmp += IIF( gVar1 == "1", "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
      ??U cTmp

   ELSE
      P_NRED

      cTmp := IIF( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R. * KONTO *" + PadC( "PART", __par_len ) + "*" 
      cTmp += "    NAZIV PARTNERA ILI      "  + "*           D  O  K  U  M  E  N  T             *         IZNOS U  " + ValDomaca() + "         *" 
      cTmp += IIF( gVar1 == "1", "", "    IZNOS U " + ValPomocna() + "    *" )
      ??U cTmp
      P_NRED

      cTmp := IIF( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", __par_len ) + " " 
      cTmp += "                            " + " ---------------------------------------------- ------------------------------- "
      cTmp += IIF( gVar1 == "1", "", "---------------------" )
      ??U cTmp
      P_NRED

      
      cTmp := IIF( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", __par_len ) + "*" 
      cTmp += "    NAZIV KONTA             " + "*  TIP I NAZIV   * BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAŽUJE " + ValDomaca() + "*" 
      cTmp +=  IIF( gVar1 == "1", "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
      ??U cTmp

   ENDIF

   P_NRED
   ?? M

   SELECT( nArr )

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
