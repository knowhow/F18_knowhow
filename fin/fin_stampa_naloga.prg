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


FUNCTION StNal( lAuto )
   RETURN stampa_fin_document( lAuto )


FUNCTION stampa_fin_document( lAuto )

   PRIVATE dDatNal := Date()

   StAnalNal( lAuto )
   gen_sint_stavke( lAuto )

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
   my_dbf_zap()

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
         my_close_all_dbf()
         RETURN
      ENDIF

      IF !_izgenerisi
         f18_start_print( NIL, @_print_opt )
      ENDIF

      stampa_suban_dokument( "1", lAuto )

      IF !_izgenerisi
         my_close_all_dbf()
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

   my_close_all_dbf()

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
      ?U "FIN.P:      D N E V N I K    K NJ I Ž E NJ A    Z A    " + ;
         Upper( NazMjeseca( Month( dDatNal ) ) ) + " " + Str( Year( dDatNal ) ) + ". GODINE"
   ELSE
      ?U "FIN.P: NALOG ZA KNJIŽENJE BROJ :"
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

   lJerry := .F.

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


FUNCTION gen_sint_stavke( lAuto )

   LOCAL A
   LOCAL nStr, nD1, nD2, nP1, nP2
   LOCAL cIdFirma, cIDVn, cBrNal
   LOCAL nDugBHD, nDugDEM, nPotBHD, nPotDEM
  
   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   IF !fin_open_lock_print_tables( .T. )
         RETURN .F.
   ENDIF

   altd()
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

      nStr := 0
      nD1 := nD2 := nP1 := nP2 := 0
      cIdFirma := IdFirma; cIDVn = IdVN;cBrNal := BrNal

      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog

         cIdkonto := idkonto

         nDugBHD := nDugDEM := 0
         nPotBHD := nPotDEM := 0
         IF D_P = "1"
            nDugBHD := IznosBHD; nDugDEM := IznosDEM
         ELSE
            nPotBHD := IznosBHD; nPotDEM := IznosDEM
         ENDIF

         SELECT PANAL

         SEEK cIdfirma + cIdvn + cBrNal + cIdKonto
         fNasao := .F.

         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal .AND. IdKonto == cIdKonto
            IF gDatNal == "N"
               IF Month( psuban->datdok ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ELSE  
               // sintetika se generise na osnovu datuma naloga
               IF Month( dDatNal ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ENDIF
            SKIP
         ENDDO

         SELECT PANAL
         IF !fNasao
            APPEND BLANK
         ENDIF

         REPLACE IdFirma WITH cIdFirma, IdKonto WITH cIdKonto, IdVN WITH cIdVN, BrNal WITH cBrNal, ;
            DatNal WITH IIF( gDatNal == "D", dDatNal, Max( psuban->datdok, datnal ) ), ;
            DugBHD WITH DugBHD + nDugBHD, PotBHD WITH PotBHD + nPotBHD, ;
            DugDEM WITH DugDEM + nDugDEM, PotDEM WITH PotDEM + nPotDEM


         SELECT PSINT
         SEEK cIdfirma + cIdvn + cBrNal + Left( cIdKonto, 3 )

         fNasao := .F.

         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal .AND. Left( cIdkonto, 3 ) == idkonto
            IF gDatNal == "N"
               IF  Month( psuban->datdok ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ELSE
               IF Month( dDatNal ) == Month( datnal )
                  fNasao := .T.
                  EXIT
               ENDIF
            ENDIF

            SKIP
         ENDDO

         SELECT PSINT
         IF !fNasao
            APPEND BLANK
         ENDIF

         REPLACE IdFirma WITH cIdFirma, IdKonto WITH Left( cIdKonto, 3 ), IdVN WITH cIdVN, BrNal WITH cBrNal, DatNal WITH iif( gDatNal == "D", dDatNal,  Max( psuban->datdok, datnal ) ), ;
            DugBHD WITH DugBHD + nDugBHD, PotBHD WITH PotBHD + nPotBHD, ;
            DugDEM WITH DugDEM + nDugDEM, PotDEM WITH PotDEM + nPotDEM

         nD1 += nDugBHD; nD2 += nDugDEM; nP1 += nPotBHD; nP2 += nPotDEM

         SELECT PSUBAN
         SKIP

      ENDDO

      SELECT PNALOG
      APPEND BLANK
      REPLACE IdFirma WITH cIdFirma, IdVN WITH cIdVN, BrNal WITH cBrNal, DatNal WITH IIF( gDatNal == "D", dDatNal, Date() ), ;
         DugBHD WITH nD1, PotBHD WITH nP1, ;
         DugDEM WITH nD2, PotDEM WITH nP2

      PRIVATE cDN := "N"

      IF !lAuto
         Box(, 2, 58 )
         @ m_x + 1, m_y + 2 SAY8 "Štampanje analitike/sintetike za nalog " + cIdfirma + "-" + cIdvn + "-" + cBrnal + " ?"  GET cDN PICT "@!" VALID cDN $ "DN"
         IF gDatNal == "D"
            @ m_x + 2, m_y + 2 SAY "Datum naloga:" GET dDatNal
         ENDIF
         READ
         BoxC()
      ENDIF

      SELECT PSUBAN
      PushWa()

      IF cDN == "D"
         SELECT PANAL
         SEEK cIdfirma + cIdvn + cBrnal
         fin_stampa_sinteticki_nalog( .F. )    
      ENDIF

      my_close_all_dbf()
      fin_open_lock_print_tables( .F. )
 
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
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog
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
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal     // jedan nalog
         REPLACE rbr WITH Str( ++nRbr, 3 )
         SKIP
      ENDDO
   ENDDO

   my_close_all_dbf()

   RETURN


STATIC FUNCTION fin_open_lock_print_tables( lZap )

   O_PSUBAN
   O_PANAL
   O_PSINT
   O_PNALOG
   
   O_PARTN
   O_KONTO
   O_TNAL

   IF !lock_fin_priprema( lZap )
       RETURN .F.
   ENDIF

   SELECT PSUBAN
   SET ORDER TO TAG "2"

   RETURN .T.


/*
   1) lZap := .T. => pobrisi tabele panal, psint, pnalog
                     PSUBAN ne diraj !
              .F. => ne brisi nista

   3) lockuj sve tabele

*/
STATIC FUNCTION lock_fin_priprema( lZap )

   LOCAL nCnt
   LOCAL lLock := .T.

   nCnt := 0
   DO WHILE .T.

      ++nCnt

      IF nCnt > 5
           MsgBeep( "Neko već koristi tabele za pripreme finansijskog naloga !" )
           RETURN .F.
      ENDIF

      SELECT PANAL
      IIF( lZap, my_dbf_zap(), NIL)

      lLock := lLock .AND. my_flock()
      IF !lLock
           hb_idleSleep( 1 )
           LOOP
      ENDIF

      SELECT PSINT
      IIF( lZap, my_dbf_zap(), NIL)

      lLock := lLock .AND. my_flock()
      IF !lLock
           hb_idleSleep( 1 )
           LOOP
      ENDIF

      SELECT PNALOG
      IIF( lZap, my_dbf_zap(), NIL)
   
      lLock := lLock .AND. my_flock()
      IF !lLock
           hb_idleSleep( 1 )
           LOOP
      ENDIF


      SELECT PSUBAN
       lLock := lLock .AND. my_flock()
      IF !lLock
           hb_idleSleep( 1 )
           LOOP
      ENDIF

      // sve lock prepreke prebrođene :)
      EXIT
   ENDDO

   RETURN .T.

