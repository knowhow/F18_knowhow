/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


FUNCTION os_pregled_revalorizacije()

   LOCAL cIdKonto := qIdkonto := Space( 7 ), cidsk := "", ndug := ndug2 := npot := npot2 := ndug3 := npot3 := 0
   LOCAL nCol1 := 10
   LOCAL _sr_id

   O_KONTO
   O_RJ

   o_os_sii_promj()
   o_os_sii()

   cIdrj := Space( 4 )
   cPromj := "2"
   cPocinju := "N"
   cFiltK1 := Space( 40 )
   cON := " " // novo!

   Box(, 10, 77 )
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Radna jedinica (prazno - svi):" GET cidrj VALID Empty( cIdRj ) .OR. p_rj( @cIdrj )
      @ m_x + 1, Col() + 2 SAY "sve koje pocinju " GET cpocinju VALID cpocinju $ "DN" PICT "@!"
      @ m_x + 2, m_y + 2 SAY "Konto (prazno - svi):" GET qIdKonto PICT "@!" VALID Empty( qidkonto ) .OR. P_Konto( @qIdKonto )
      @ m_x + 4, m_y + 2 SAY "Za sredstvo prikazati vrijednost:"
      @ m_x + 5, m_y + 2 SAY "1 - bez promjena"
      @ m_x + 6, m_y + 2 SAY "2 - osnovni iznos + promjene"
      @ m_x + 7, m_y + 2 SAY "3 - samo promjene           " GET cPromj VALID cpromj $ "123"
      @ m_x + 8, m_y + 2 SAY "Filter po grupaciji K1:" GET cFiltK1 PICT "@!S20"
      @ m_x + 9, m_y + 2 SAY "Prikaz svih os ( )      /   neotpisanih (N)     / otpisanih   (O) "
      @ m_x + 10, m_y + 2 SAY "/novonabavljenih   (B) / iz proteklih godina (G)" GET cON VALID con $ "ONBG " PICT "@!"
      read; ESC_BCR
      aUsl1 := Parsiraj( cFiltK1, "K1" )
      IF aUsl1 <> NIL; exit; ENDIF
   ENDDO
   BoxC()

   IF Empty( qidkonto ); qidkonto := ""; ENDIF
   IF Empty( cIdrj ); cidrj := ""; ENDIF
   IF cpocinju == "D"
      cIdRj := Trim( cidrj )
   ENDIF

   os_rpt_default_valute()

   start PRINT cret
   PRIVATE nStr := 0  // strana
   SELECT rj
   HSEEK cIdrj
   select_os_sii()

   IF !Empty( cFiltK1 )
      SET FILTER to &aUsl1
   ENDIF

   P_10CPI
   ? gTS + ":", gnFirma
   IF !Empty( cidrj )
      ? "Radna jedinica:", cidrj, rj->naz
   ENDIF
   ? "OS: Pregled obracuna revalorizacije po kontima "
   ?? "", PrikazVal(), "    Datum:", gDatObr
   P_COND2

   PRIVATE m := "----- ---------- ---- -------- ------------------------------ --- ------" + REPL( " " + REPL( "-", Len( gPicI ) ), 5 )

   select_os_sii()

   IF Empty( cidrj )
      SET ORDER TO TAG "4"
      // "OSi4","idkonto+idrj+id"
      SEEK qidkonto
   ELSE
      SET ORDER TO TAG "3"
      // "OSi3","idrj+idkonto+id"
      SEEK cidrj + qidkonto
   ENDIF

   PRIVATE nrbr := 0

   nDug1 := nDug2 := nPot1 := nPot2 := 0

   os_zagl_reval()

   nA1 := 0
   nA2 := 0

   DO WHILE !Eof() .AND. ( idrj = cidrj .OR. Empty( cidrj ) )

      cIdSK := Left( idkonto, 3 )
      nDug21 := 0
      nDug22 := 0
      nPot21 := 0
      nPot22 := 0

      DO WHILE !Eof() .AND. ( field->idrj = cIdrj .OR. Empty( cIdrj ) ) .AND. Left( field->idkonto, 3 ) == cIdSK

         cIdKonto := field->idkonto
         nDug31 := 0
         nDug32 := 0
         nPot31 := 0
         nPot32 := 0

         DO WHILE !Eof() .AND. ( field->idrj = cIdrj .OR. Empty( cIdrj ) ) .AND. field->idkonto == cIdkonto

            IF PRow() > 60
               FF
               os_zagl_reval()
            ENDIF

            IF !( ( cON == "N" .AND. Empty( field->datotp ) ) .OR. ;
                  ( con == "O" .AND. !Empty( field->datotp ) ) .OR. ;
                  ( con == "B" .AND. Year( field->datum ) = Year( gdatobr ) ) .OR. ;
                  ( con == "G" .AND. Year( field->datum ) < Year( gdatobr ) ) .OR. ;
                  Empty( con ) )
               SKIP 1
               LOOP
            ENDIF

            fIma := .T.

            IF cPromj == "3"
               // ako zelim samo promjene vidi ima li za sr.
               // uopste promjena

               // id sredstva
               _sr_id := field->id

               select_promj()
               HSEEK _sr_id

               fIma := .F.

               DO WHILE !Eof() .AND. field->id == _sr_id .AND. field->datum <= gDatObr
                  fIma := .T.
                  SKIP
               ENDDO

               select_os_sii()

            ENDIF

            IF fIma
               ? Str( ++nRbr, 4 ) + ".", field->id, field->idrj, field->datum, field->naz, field->jmj, Str( field->kolicina, 6, 1 )
               nCol1 := PCol() + 1
            ENDIF

            IF cPromj <> "3"
               @ PRow(), ncol1    SAY field->nabvr * nBBK PICT gpici
               @ PRow(), PCol() + 1 SAY field->otpvr * nBBK + field->amp * nBBK PICT gpici
               @ PRow(), PCol() + 1 SAY field->revd * nBBK PICT gpici
               @ PRow(), PCol() + 1 SAY field->revp * nBBK PICT gpici
               @ PRow(), PCol() + 1 SAY field->nabvr * nBBK + field->revd * nBBK - ( field->otpvr + field->amp + field->revp ) * nBBK PICT gpici
               nDug31 += nabvr
               nPot31 += otpvr + amp
               nDug32 += revd
               nPot32 += revp
            ENDIF

            IF cPromj $ "23"
               // prikaz promjena

               _sr_id := field->id
               _sr_id_rj := field->idrj

               select_promj()
               HSEEK os->id

               DO WHILE !Eof() .AND. field->id == _sr_id .AND. field->datum <= gDatObr
                  ? Space( 5 ), Space( Len( _sr_id ) ), Space( Len( _sr_id_rj ) ), field->datum, field->opis
                  nA1 := 0
                  nA2 := field->amp
                  @ PRow(), ncol1    SAY nabvr * nBBK PICT gpici
                  @ PRow(), PCol() + 1 SAY otpvr * nBBK + amp * nBBK PICT gpici
                  @ PRow(), PCol() + 1 SAY revd * nBBK PICT gpici
                  @ PRow(), PCol() + 1 SAY revp * nBBK PICT gpici
                  @ PRow(), PCol() + 1 SAY nabvr * nBBK + revd * nBBK - ( otpvr + amp + revp ) * nBBK PICT gpici
                  nDug31 += nabvr
                  nPot31 += otpvr + amp
                  nDug32 += revd
                  nPot32 += revp
                  SKIP
               ENDDO
               select_os_sii()
            ENDIF

            SKIP
         ENDDO

         IF PRow() > 60
            FF
            os_zagl_reval()
         ENDIF
         ? m
         ? " ukupno ", cIdkonto
         @ PRow(), ncol1    SAY ndug31 * nBBK PICT gpici
         @ PRow(), PCol() + 1 SAY npot31 * nBBK PICT gpici
         @ PRow(), PCol() + 1 SAY ndug32 * nBBK PICT gpici
         @ PRow(), PCol() + 1 SAY npot32 * nBBK PICT gpici
         @ PRow(), PCol() + 1 SAY ndug31 * nBBK + nDug32 * nBBK - npot31 * nBBK - npot32 * nBBK PICT gpici
         ? m
         nDug21 += nDug31
         nPot21 += nPot31
         nDug22 += nDug32
         nPot22 += nPot32
         IF !Empty( qidkonto )
            EXIT
         ENDIF

      ENDDO

      IF !Empty( qidkonto )
         EXIT
      ENDIF

      IF PRow() > 60
         FF
         os_zagl_reval()
      ENDIF

      ? m
      ? " UKUPNO ", cIdsk
      @ PRow(), ncol1    SAY ndug21 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY npot21 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY ndug22 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY npot22 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY ndug21 * nBBK + nDug22 * nBBK - npot21 * nBBK - npot22 * nBBK PICT gpici
      ? m
      nDug1 += nDug21
      nPot1 += nPot21
      nDug2 += nDug22
      nPot2 += nPot22

   ENDDO

   IF Empty( qidkonto )
      IF PRow() > 60
         FF
         os_zagl_reval()
      ENDIF
      ?
      ? m
      ? " U K U P N O :"
      @ PRow(), ncol1    SAY ndug1 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY npot1 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY ndug2 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY npot2 * nBBK PICT gpici
      @ PRow(), PCol() + 1 SAY ndug1 * nBBK + nDug2 * nBBK - npot1 * nBBK - npot2 * nBBK PICT gpici
      ? m
   ENDIF

   ?
   ? "Napomena: Kolona 'Otp. vrijednost' prikazuje otpisanu vrijednost sredstva sa uracunatom amortizacijom za ovu godinu"
   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN


FUNCTION os_zagl_reval()

   ?
   P_COND
   @ PRow(), 125 SAY "Str." + Str( ++nStr, 3 )
   IF !Empty( cFiltK1 ); ? "Filter grupacija K1 pravljen po uslovu: '" + Trim( cFiltK1 ) + "'"; ENDIF
   IF con = "N"
      ? "PRIKAZ NEOTPISANIH SREDSTAVA:"
   ELSEIF con == "B"
      ? "PRIKAZ NOVONABAVLJENIH SREDSTAVA:"
   ELSEIF con == "G"
      ? "PRIKAZ SREDSTAVA IZ PROTEKLIH GODINA:"
   ELSEIF con == "O"
      ? "PRIKAZ OTPISANIH SREDSTAVA:"
   ELSEIF   con == " "
      ? "PRIKAZ SVIH SREDSTAVA:"
   ENDIF
   ? m
   ? " Rbr.  Inv.broj   RJ    Datum    Sredstvo                     jmj  kol  " + " " + PadC( "NabVr", Len( gPicI ) ) + " " + PadC( "OtpVr", Len( gPicI ) ) + " " + PadC( "Rev.Dug.", Len( gPicI ) ) + " " + PadC( "Rev.Pot.", Len( gPicI ) ) + " " + PadC( "SadVr", Len( gPicI ) )
   ? m

   RETURN
