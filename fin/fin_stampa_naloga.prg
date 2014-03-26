/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


// izbaciti StNal

FUNCTION StNal( lAuto )
   RETURN stampa_fin_document( lAuto )


FUNCTION stampa_fin_document( lAuto )

   PRIVATE dDatNal := Date()

   StAnalNal( lAuto )
   SintStav( lAuto )

   RETURN


FUNCTION StAnalNal( lAuto )

   LOCAL _print_opt := "V"
   LOCAL _izgenerisi := .F.
   PRIVATE aNalozi := {}

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   O_VRSTEP
   O_FIN_PRIPR
   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK
   O_PSUBAN

   __par_len := Len( partn->id )

   SELECT PSUBAN
   ZAPP()


   SELECT fin_pripr
   SET ORDER TO TAG "1"

   GO TOP

   EOF CRET

   _izgenerisi := .F.

   IF lAuto
      _izgenerisi := .T.
   ENDIF

   IF lAuto
      _print_opt := "D"
   ENDIF

   IF lAuto
      Box(, 3, 75 )
      @ m_x + 0, m_y + 2 SAY "PROCES FORMIRANJA SINTETIKE I ANALITIKE"
   ENDIF

   DO WHILE !Eof()

      cIdFirma := IdFirma
      cIdVN := IdVN
      cBrNal := BrNal

      IF !_izgenerisi

         Box( "", 2, 50 )

         SET CURSOR ON

         @ m_x + 1, m_y + 2 SAY "Nalog broj:"

         IF gNW == "D"
            cIdFirma := gFirma
            @ m_x + 1, Col() + 1 SAY cIdFirma
         ELSE
            @ m_x + 1, Col() + 1 GET cIdFirma
         ENDIF

         @ m_x + 1, Col() + 1 SAY "-" GET cIdVn
         @ m_x + 1, Col() + 1 SAY "-" GET cBrNal

         IF gDatNal == "D"
            @ m_x + 2, m_y + 2 SAY "Datum naloga:" GET dDatNal
         ENDIF

         READ

         ESC_BCR
         BoxC()

      ENDIF

      HSEEK cIdFirma + cIdVN + cBrNal

      IF Eof()
         CLOSE ALL
         RETURN
      ENDIF

      IF !_izgenerisi
         f18_start_print( NIL, @_print_opt )
      ENDIF

      stampa_suban_dokument( "1", lAuto )

      IF !_izgenerisi
         CLOSE ALL
         f18_end_print( NIL, @_print_opt )
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

   IF _izgenerisi .AND. !lAuto
      Beep( 2 )
      Msg( "Sve stavke su stavljene na stanje" )
   ENDIF

   CLOSE ALL

   RETURN



/*! \fn fin_zagl_11()
 *  \brief Zaglavlje analitickog naloga
 */

FUNCTION fin_zagl_11()

   LOCAL nArr, lDnevnik := .F.
   LOCAL _fin_params := fin_params()

   IF "DNEVNIKN" == PadR( Upper( ProcName( 1 ) ), 8 ) .OR. ;
         "DNEVNIKN" == PadR( Upper( ProcName( 2 ) ), 8 )
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
      ? "FIN.P:      D N E V N I K    K NJ I Z E NJ A    Z A    " + ;
         Upper( NazMjeseca( Month( dDatNal ) ) ) + " " + Str( Year( dDatNal ) ) + ". GODINE"
   ELSE
      ? "FIN.P: NALOG ZA KNJIZENJE BROJ :"
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

   lJerry := ( IzFMKIni( "FIN", "JednovalutniNalogJerry", "N", KUMPATH ) == "D" )

   P_NRED

   ?? M

   IF !_fin_params[ "fin_tip_dokumenta" ]
      P_NRED
      ?? IF( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R. * KONTO *" + PadC( "PART", __par_len ) + "*" + IF( gVar1 == "1" .AND. lJerry, "       NAZIV PARTNERA         *                    ", "    NAZIV PARTNERA ILI      " ) + "*   D  O  K  U  M  E  N  T    *         IZNOS U  " + ValDomaca() + "         *" + IF( gVar1 == "1", "", "    IZNOS U " + ValPomocna() + "    *" )
      P_NRED
      ?? IF( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", __par_len ) + " " + IF( gVar1 == "1" .AND. lJerry, "            ILI                      O P I S       ", "                            " ) + " ----------------------------- ------------------------------- " + IF( gVar1 == "1", "", "---------------------" )
      P_NRED; ?? IF( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", __par_len ) + "*" + IF( gVar1 == "1" .AND. lJerry, "        NAZIV KONTA           *                    ", "    NAZIV KONTA             " ) + "* BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAZUJE " + ValDomaca() + "*" + IF( gVar1 == "1", "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
   ELSE
      P_NRED
      ?? IF( lDnevnik, "R.BR. *   BROJ   *DAN*", "" ) + "*R. * KONTO *" + PadC( "PART", __par_len ) + "*" + IF( gVar1 == "1" .AND. lJerry, "       NAZIV PARTNERA         *                    ", "    NAZIV PARTNERA ILI      " ) + "*           D  O  K  U  M  E  N  T             *         IZNOS U  " + ValDomaca() + "         *" + IF( gVar1 == "1", "", "    IZNOS U " + ValPomocna() + "    *" )
      P_NRED
      ?? IF( lDnevnik, "U DNE-*  NALOGA  *   *", "" ) + "             " + PadC( "NER", __par_len ) + " " + IF( gVar1 == "1" .AND. lJerry, "            ILI                      O P I S       ", "                            " ) + " ---------------------------------------------- ------------------------------- " + IF( gVar1 == "1", "", "---------------------" )
      P_NRED
      ?? IF( lDnevnik, "VNIKU *          *   *", "" ) + "*BR *       *" + REPL( " ", __par_len ) + "*" + IF( gVar1 == "1" .AND. lJerry, "        NAZIV KONTA           *                    ", "    NAZIV KONTA             " ) + "*  TIP I NAZIV   * BROJ VEZE * DATUM  * VALUTA *  DUGUJE " + ValDomaca() + "  * POTRAZUJE " + ValDomaca() + "*" + IF( gVar1 == "1", "", " DUG. " + ValPomocna() + "* POT." + ValPomocna() + "*" )
   ENDIF
   P_NRED
   ?? M
   SELECT( nArr )

   RETURN



STATIC FUNCTION _o_tables()

   O_PSUBAN
   O_PARTN
   O_PANAL
   O_PSINT
   O_PNALOG
   O_KONTO
   O_TNAL

   RETURN


/*! \fn SintStav(lAuto)
 *  \brief Formiranje sintetickih stavki
 *  \param lAuto
 */

FUNCTION SintStav( lAuto )

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   _o_tables()

   SELECT PANAL
   zapp()
   SELECT PSINT
   zapp()
   SELECT PNALOG
   zapp()

   SELECT PSUBAN
   SET ORDER TO TAG "2"
   GO TOP

   IF Empty( BrNal )
      CLOSE ALL
      RETURN
   ENDIF

   A := 0

   // svi nalozi
   DO WHILE !Eof()

      nStr := 0
      nD1 := nD2 := nP1 := nP2 := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal

      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog

         cIdkonto := idkonto

         nDugBHD := nDugDEM := 0
         nPotBHD := nPotDEM := 0
         IF D_P = "1"
            nDugBHD := IznosBHD; nDugDEM := IznosDEM
         ELSE
            nPotBHD := IznosBHD; nPotDEM := IznosDEM
         ENDIF

         SELECT PANAL     // analitika

         SEEK cidfirma + cidvn + cbrnal + cidkonto
         fNasao := .F.

         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal ;
               .AND. IdKonto == cIdKonto
            IF gDatNal == "N"
               IF Month( psuban->datdok ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ELSE  // sintetika se generise na osnovu datuma naloga
               IF Month( dDatNal ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ENDIF
            SKIP
         ENDDO

         IF !fNasao
            APPEND BLANK
         ENDIF

         REPLACE IdFirma WITH cIdFirma, IdKonto WITH cIdKonto, IdVN WITH cIdVN, ;
            BrNal WITH cBrNal, ;
            DatNal WITH iif( gDatNal == "D", dDatNal, Max( psuban->datdok, datnal ) ), ;
            DugBHD WITH DugBHD + nDugBHD, PotBHD WITH PotBHD + nPotBHD, ;
            DugDEM WITH DugDEM + nDugDEM, PotDEM WITH PotDEM + nPotDEM


         SELECT PSINT
         SEEK cidfirma + cidvn + cbrnal + Left( cidkonto, 3 )

         fNasao := .F.

         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal ;
               .AND. Left( cidkonto, 3 ) == idkonto
            IF gDatNal == "N"
               IF  Month( psuban->datdok ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ELSE // sintetika se generise na osnovu dDatNal
               IF Month( dDatNal ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ENDIF

            SKIP
         ENDDO

         IF !fNasao
            APPEND BLANK
         ENDIF

         REPLACE IdFirma WITH cIdFirma, IdKonto WITH Left( cIdKonto, 3 ), IdVN WITH cIdVN, ;
            BrNal WITH cBrNal, ;
            DatNal WITH iif( gDatNal == "D", dDatNal,  Max( psuban->datdok, datnal ) ), ;
            DugBHD WITH DugBHD + nDugBHD, PotBHD WITH PotBHD + nPotBHD, ;
            DugDEM WITH DugDEM + nDugDEM, PotDEM WITH PotDEM + nPotDEM

         nD1 += nDugBHD; nD2 += nDugDEM; nP1 += nPotBHD; nP2 += nPotDEM

         SELECT PSUBAN
         SKIP

      ENDDO  // nalog

      SELECT PNALOG    // datoteka naloga
      APPEND BLANK
      REPLACE IdFirma WITH cIdFirma, IdVN WITH cIdVN, BrNal WITH cBrNal, ;
         DatNal WITH iif( gDatNal == "D", dDatNal, Date() ), ;
         DugBHD WITH nD1, PotBHD WITH nP1, ;
         DugDEM WITH nD2, PotDEM WITH nP2

      PRIVATE cDN := "N"

      IF !lAuto
         Box(, 2, 58 )
         @ m_x + 1, m_y + 2 SAY "Stampanje analitike/sintetike za nalog " + cIdfirma + "-" + cIdvn + "-" + cBrnal + " ?"  GET cDN PICT "@!" VALID cDN $ "DN"
         IF gDatNal == "D"
            @ m_x + 2, m_y + 2 SAY "Datum naloga:" GET dDatNal
         ENDIF
         READ
         BoxC()
      ENDIF

      _rec_suban := psuban->( RecNo() )

      IF cDN == "D"
         SELECT panal
         SEEK cIdfirma + cIdvn + cBrnal
         StOSNal( .F. )    // stampa se priprema
      ENDIF

      _o_tables()
      SELECT PSUBAN
      GO ( _rec_suban )

   ENDDO

   // svi nalozi

   SELECT PANAL
   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   SELECT PSINT
   GO TOP
   DO WHILE !Eof()
      nRbr := 0
      cIdFirma := IdFirma;cIDVn = IdVN;cBrNal := BrNal
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   CLOSE ALL

   RETURN
