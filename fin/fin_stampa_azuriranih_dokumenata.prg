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


FUNCTION MnuStampaAzurNaloga()

   LOCAL izb := 1
   PRIVATE opc[ 2 ]

   opc[ 1 ] := "1. subanalitika        "
   opc[ 2 ] := "2. analitika/sintetika"

   DO WHILE .T.
      izb := menu( "onal", opc, izb, .F. )
      DO CASE
      CASE izb == 0
         EXIT
      CASE izb == 1
         StOANal()
      CASE izb == 2
         StOSNal()
      CASE izb == 3
         izb := 0
      ENDCASE
   ENDDO

   RETURN



/*
   Stampanje proknjizenog analitickog naloga
 */

FUNCTION StOANal()

   PRIVATE fK1 := fk2 := fk3 := fk4 := "N", gnLOst := 0, gPotpis := "N"
   PRIVATE dDatNal := Date()

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

   IF gNW == "D"
      @ m_x + 1, Col() + 1 SAY cIdFirma
   ELSE
      @ m_x + 1, Col() + 1 GET cIdFirma
   ENDIF

   @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
   @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID _f_brnal( @cBrNal )

   IF gDatNal == "D"
      @ m_x + 2, m_y + 2 SAY "Datum naloga:" GET dDatNal
   ENDIF
   READ
   ESC_BCR
   BoxC()

   SELECT nalog
   SEEK cidfirma + cidvn + cbrnal

   NFOUND CRET
   dDatNal := datnal

   SELECT SUBAN
   SEEK cIdfirma + cIdvn + cBrNal

   START PRINT CRET

   stampa_suban_dokument( "2" )

   END PRINT

   closeret

   RETURN



/*! \fn StOSNal(fKum)
 *  \brief Stampa sintetickog naloga
 *  \param fKum  - if fkum = .t. - stampa naloga iz anal.dbf, if fkum = .f. - stampa naloga iz panal.dbf
 */

FUNCTION StOSNal( fkum )

   IF fKum == NIL
      fkum := .T.
   ENDIF


   PicBHD := "@Z " + FormPicL( gPicBHD, 17 )
   PicDEM := "@Z " + FormPicL( gPicDEM, 12 )
   M := "---- -------- ------- --------------------------------------------- ----------------- -----------------" + IF( gVar1 == "1", "-", " ------------ ------------" )

   IF fkum  // stampa starog naloga - naloga iz kumulativa - datoteka anal

      SELECT ( F_ANAL )
      my_usex( "panal", "fin_anal" )
      SET ORDER TO TAG "2"

      O_KONTO
      O_PARTN
      O_TNAL
      O_NALOG

      cIdVN := Space( 2 )
      cIdFirma := gFirma
      cBrNal := Space( 8 )

      Box( "", 1, 35 )
      @ m_x + 1, m_y + 2 SAY "Nalog:"
      IF gNW == "D"
         @ m_x + 1, Col() + 1 SAY cIdFirma
      ELSE
         @ m_x + 1, Col() + 1 GET cIdFirma
      ENDIF
      @ m_x + 1, Col() + 1 SAY "-" GET cIdVN PICT "@!"
      @ m_x + 1, Col() + 1 SAY "-" GET cBrNal VALID _f_brnal( @cBrNal )
      READ
      ESC_BCR
      BoxC()
      SELECT nalog
      SEEK cidfirma + cidvn + cbrnal
      NFOUND CRET  // ako ne postoji
      dDatNal := datnal

      SELECT PANAL
      SEEK cidfirma + cidvn + cbrNal
      START PRINT CRET

   ELSE
      cIdFirma := idfirma
      cidvn := idvn
      cBrNal := brnal
      SEEK cidfirma + cidvn + cbrNal
      START PRINT RET
   ENDIF

   nStr := 0
   b1 := {|| !Eof() }

   nCol1 := 70

   cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
   b2 := {|| cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal }
   b3 := {|| cIdSinKon == Left( IdKonto, 3 ) }
   b4 := {|| cIdKonto == IdKonto }
   nDug3 := nPot3 := 0
   nRbr2 := 0 // brojac sint stavki
   nRbr := 0
   nUkUkDugBHD := nUkUkPotBHD := nUkUkDugDEM := nUkUkPotDEM := 0
   Zagl12()
   DO WHILE Eval( b1 ) .AND. Eval( b2 )     // jedan nalog

      IF PRow() > 61 + gPStranica
         FF
         Zagl12()
      ENDIF

      cIdSinKon := Left( IdKonto, 3 )
      nUkDugBHD := nUkPotBHD := nUkDugDEM := nUkPotDEM := 0
      DO WHILE  Eval( b1 ) .AND. Eval( b2 ) .AND. Eval( b3 )  // sinteticki konto

         cIdKonto := IdKonto
         nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
         IF PRow() > 61 + gPStranica; FF; Zagl12(); ENDIF
         DO WHILE  Eval( b1 ) .AND. Eval( b2 ) .AND. Eval( b4 )  // analiticki konto
            SELECT KONTO; hseek cidkonto
            SELECT PANAL
            P_NRED
            @ PRow(), 0 SAY  ++nRBr PICTURE '9999'
            @ PRow(), PCol() + 1 SAY IF( gDatNal == "D", Space( 8 ), datnal )
            @ PRow(), PCol() + 1 SAY cIdKonto
            @ PRow(), PCol() + 1 SAY Left( KONTO->naz, 45 )
            nCol1 := PCol() + 1
            @ PRow(), nCol1 SAY DugBHD PICTURE PicBHD
            @ PRow(), PCol() + 1 SAY PotBHD PICTURE PicBHD
            IF gVar1 != "1"
               @ PRow(), PCol() + 1 SAY DugDEM PICTURE PicDEM
               @ PRow(), PCol() + 1 SAY PotDEM PICTURE PicDEM
            ENDIF
            nDugBHD += DugBHD; nDugDEM += DUGDEM
            nPotBHD += PotBHD; nPotDEM += POTDEM
            SKIP
         ENDDO

         nUkDugBHD += nDugBHD; nUkPotBHD += nPotBHD
         nUkDugDEM += nDugDEM; nUkPotDEM += nPotDEM
      ENDDO  // siteticki konto

      IF PRow() > 61 + gPStranica; FF; Zagl12(); ENDIF
      P_NRED; ?? M
      P_NRED
      @ PRow(), 1 SAY ++nRBr2 PICTURE '999'
      @ PRow(), PCol() + 1 SAY PadR( cIdSinKon, 6 )
      SELECT KONTO; HSEEK cIdSinKon
      @ PRow(), PCol() + 1 SAY Left( Naz, 45 )
      SELECT PANAL
      @ PRow(), nCol1 SAY nUkDugBHD PICTURE PicBHD
      @ PRow(), PCol() + 1 SAY nUkPotBHD PICTURE PicBHD
      IF gVar1 != "1"
         @ PRow(), PCol() + 1 SAY nUkDugDEM PICTURE PicDEM
         @ PRow(), PCol() + 1 SAY nUkPotDEM PICTURE PicDEM
      ENDIF
      P_NRED; ?? M

      nUkUkDugBHD += nUkDugBHD
      nUKUkPotBHD += nUkPotBHD
      nUkUkDugDEM += nUkDugDEM
      nUkUkPotDEM += nUkPotDEM

   ENDDO  // nalog

   IF PRow() > 61 + gPStranica; FF; Zagl12(); ENDIF

   P_NRED; ?? M
   P_NRED; ?? "ZBIR NALOGA:"
   @ PRow(), nCol1 SAY nUkUkDugBHD PICTURE PicBHD
   @ PRow(), PCol() + 1 SAY nUkUkPotBHD PICTURE PicBHD
   IF gVar1 != "1"
      @ PRow(), PCol() + 1 SAY nUkUkDugDEM PICTURE PicDEM
      @ PRow(), PCol() + 1 SAY nUkUkPotDEM PICTURE PicDEM
   ENDIF
   P_NRED; ?? M

   FF

   END PRINT

   IF fkum
      closeret
   ENDIF

   RETURN



/*! \fn Zagl12()
 *  \brief Zaglavlje sintetickog naloga
 */

FUNCTION Zagl12()

   LOCAL nArr

   ?
   P_COND
   F10CPI
   ?? gTS + ":", gNFirma
   IF gNW == "N"
      SELECT partn; hseek cidfirma; SELECT panal
      ? cidfirma, "-", partn->naz
   ENDIF
   ?
   P_COND
   ? "FIN.P: ANALITIKA/SINTETIKA -  NALOG ZA KNJIZENJE BROJ : "
   @ PRow(), PCol() + 2 SAY cIdFirma + " - " + cIdVn + " - " + cBrNal
   IF gDatNal == "D"
      @ PRow(), PCol() + 4 SAY "DATUM: "
      ?? dDatNal
   ENDIF

   SELECT TNAL; HSEEK cIdVN; SELECT PANAL
   @ PRow(), PCol() + 4 SAY tnal->naz
   @ PRow(), PCol() + 15 SAY "Str:" + Str( ++nStr, 3 )
   P_NRED; ?? m
   P_NRED; ?? "*RED*" + PadC( IF( gDatNal == "D", "", "DATUM" ), 8 ) + "*           NAZIV KONTA                               *            IZNOS U " + ValDomaca() + "           *" + IF( gVar1 == "1", "", "     IZNOS U " + ValPomocna() + "       *" )
   P_NRED; ?? "    *        *                                                      ----------------------------------- " + IF( gVar1 == "1", "", "-------------------------" )
   P_NRED; ?? "*BR *        *                                                     * DUGUJE  " + ValDomaca() + "    * POTRAZUJE  " + ValDomaca() + " *" + IF( gVar1 == "1", "", " DUG. " + ValPomocna() + "  * POT. " + ValPomocna() + " *" )
   P_NRED; ?? m

   RETURN
