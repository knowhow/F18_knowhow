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

#include "fmk.ch"

     
/*
   generisi psuban, psint, pnalog
*/

FUNCTION fin_gen_ptabele_stampa_naloga( lAuto )

   LOCAL dDatNal := Date()

   IF fin_gen_psuban_stampa_naloga( lAuto, @dDatNal )
       fin_gen_sint_stavke( lAuto, dDatNal )
   ENDIF

   RETURN


FUNCTION fin_gen_psuban_stampa_naloga( lAuto, dDatNal )

   LOCAL _print_opt := "V"
   LOCAL oNalog, oNalozi := FinNalozi():New()

   PRIVATE aNalozi := {}

   IF lAuto == NIL
      lAuto := .F.
   ENDIF

   fin_open_psuban()

   __par_len := Len( partn->id )

   SELECT PSUBAN
   my_dbf_zap()

   SELECT fin_pripr
   SET ORDER TO TAG "1"

   GO TOP

   EOF CRET


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

      altd()
      fin_nalog( "1", lAuto, dDatNal, @oNalog )
      oNalozi:addNalog( oNalog )

      IF !lAuto
         PushWa()
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
      PushWa()

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


FUNCTION fin_gen_panal_psint( cIdFirma, cIdVn, cBrNal, dDatNal )

   LOCAL fNasao, nStr, nD1, nD2, nP1, nP2
   LOCAL nDugBhd, nPotBHD, nDugDEM, nPotDEM

   nStr := 0
   nD1 := nD2 := nP1 := nP2 := 0


   DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVN == IdVN .AND. cBrNal == BrNal

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
         DatNal WITH iif( gDatNal == "D", dDatNal, Max( psuban->datdok, datnal ) ), ;
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
   REPLACE IdFirma WITH cIdFirma, IdVN WITH cIdVN, BrNal WITH cBrNal, DatNal WITH iif( gDatNal == "D", dDatNal, Date() ), ;
      DugBHD WITH nD1, PotBHD WITH nP1, ;
      DugDEM WITH nD2, PotDEM WITH nP2

   RETURN



FUNCTION box_fin_nalog( cIdFirma, cIdVn, cBrNal, dDatNal )

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

   BoxC()

   IF LastKey() == K_ESC
      RETURN .F.
   ENDIF

   RETURN .T.


/*
   otvori psuban i ostale potrebne ostale tabele
*/
STATIC FUNCTION fin_open_psuban()

   O_VRSTEP
   O_KONTO
   O_PARTN
   O_TNAL
   O_TDOK
   O_PSUBAN

   O_FIN_PRIPR
   RETURN .T.

/*
    otvori psuban, panal, psint i ostale potrebne tabele 
*/
STATIC FUNCTION fin_open_lock_panal( lZap )

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
      iif( lZap, my_dbf_zap(), NIL )

      lLock := lLock .AND. my_flock()
      IF !lLock
         hb_idleSleep( 1 )
         LOOP
      ENDIF

      SELECT PSINT
      iif( lZap, my_dbf_zap(), NIL )

      lLock := lLock .AND. my_flock()
      IF !lLock
         hb_idleSleep( 1 )
         LOOP
      ENDIF

      SELECT PNALOG
      iif( lZap, my_dbf_zap(), NIL )

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
