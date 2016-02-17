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



FUNCTION FaktKonsig()

   PRIVATE Opc := {}
   PRIVATE opcexe := {}

   AAdd( Opc, "1. fakt->kalk (16->10) ulaz od dobavljaca  " )
   AAdd( opcexe, {|| Prenos16() } )
   PRIVATE Izbor := 1
   Menu_SC( "fkon" )
   CLOSERET

   RETURN .F.


/*! \fn Prenos16()
 *  \brief Racun konsignacije (FAKT 16) -> ulaz od dobavljaca (KALK 10)
 */

FUNCTION Prenos16()

   LOCAL cIdFirma := gFirma, cIdTipDok := "16", cBrDok := cBrKalk := Space( 8 )
   LOCAL cTipKalk := "10"

   O_KONCIJ
   O_KALK_PRIPR
   O_KALK
   O_ROBA
   O_KONTO
   O_PARTN
   O_TARIFA

   O_FAKT

   dDatKalk := Date()

   cIdKonto := PadR( "1310", 7 )
   cIdKonto2 := PadR( "", 7 )

   cIdZaduz2 := Space( 6 )

   cBrkalk := Space( 8 )
   IF gBrojac == "D"
      SELECT kalk
      SELECT kalk; SET ORDER TO TAG "1"
      SEEK cidfirma + cTipkalk + "X"
      SKIP -1
      IF cTipkalk <> IdVD
         cbrkalk := Space( 8 )
      ELSE
         cbrkalk := brdok
      ENDIF
   ENDIF
   Box(, 15, 60 )

   IF gBrojac == "D"
      cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
   ENDIF

   DO WHILE .T.

      nRBr := 0
      @ m_x + 1, m_y + 2   SAY "Broj kalkulacije " + cTipKalk + " -" GET cBrKalk PICT "@!"
      @ m_x + 1, Col() + 2 SAY "Datum:" GET dDatKalk
      @ m_x + 3, m_y + 2   SAY "Konto zaduzuje :" GET cIdKonto  PICT "@!" VALID P_Konto( @cIdKonto )
      IF gNW <> "X"
         @ m_x + 4, Col() + 2 SAY "Razduzuje:" GET cIdZaduz2  PICT "@!"      VALID Empty( cidzaduz2 ) .OR. P_Firma( @cIdZaduz2 )
      ENDIF

      cFaktFirma := "20"  // pretpostavljam da se odvaja RJ u FAKT za konsignaciju

      @ m_x + 6, m_y + 2 SAY "Broj " + IF( Left( cIdTipDok, 1 ) != "0", "otpremnice", "dokumenta u FAKT" ) + ": " GET  cFaktFirma
      @ m_x + 6, Col() + 1 SAY "- " + cidtipdok
      @ m_x + 6, Col() + 1 SAY "-" GET cBrDok
      READ
      IF LastKey() == K_ESC; exit; ENDIF

      SELECT fakt
      SEEK cFaktFirma + cIdTipDok + cBrDok
      IF !Found()
         Beep( 4 )
         @ m_x + 14, m_y + 2 SAY "Ne postoji ovaj dokument !!"
         Inkey( 4 )
         @ m_x + 14, m_y + 2 SAY Space( 30 )
         LOOP
      ELSE
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ m_x + 10, m_y + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ m_x + 11, m_y + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ m_x + 12, m_y + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF
         cIdPartner := IDPARTNER
         PRIVATE cBeze := " "

         IF cTipKalk $ "10"
            @ m_x + 14, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )
            @ m_x + 15, m_y + 2 SAY "<ENTER> - prenos" GET cBeze
            READ
         ENDIF

         SELECT kalk_pripr
         LOCATE FOR BrFaktP = cBrDok // faktura je vec prenesena
         IF Found()
            Beep( 4 )
            @ m_x + 8, m_y + 2 SAY "Dokument je vec prenesen !!"
            Inkey( 4 )
            @ m_x + 8, m_y + 2 SAY Space( 30 )
            LOOP
         ENDIF
         GO BOTTOM
         IF brdok == cBrKalk; nRbr := Val( Rbr ); ENDIF

         SELECT KONCIJ; SEEK Trim( cIdKonto )

         SELECT fakt
         IF !ProvjeriSif( "!eof() .and. '" + cFaktFirma + cIdTipDok + cBrDok + "'==IdFirma+IdTipDok+BrDok", "IDROBA", F_ROBA )
            MsgBeep( "U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!" )
            LOOP
         ENDIF
         DO WHILE !Eof() .AND. cFaktFirma + cIdTipDok + cBrDok == IdFirma + IdTipDok + BrDok
            SELECT ROBA; HSEEK fakt->idroba

            SELECT tarifa; HSEEK roba->idtarifa

            SELECT fakt
            IF AllTrim( podbr ) == "."  .OR. idroba = "U"
               SKIP
               LOOP
            ENDIF

            SELECT kalk_pripr
            APPEND BLANK

            REPLACE idfirma   WITH cIdFirma,;
               rbr       WITH Str( ++nRbr, 3 ),;
               idvd      WITH cTipKalk,;
               brdok     WITH cBrKalk,;
               datdok    WITH dDatKalk,;
               idpartner WITH cIdPartner,;
               idtarifa  WITH ROBA->idtarifa,;
               brfaktp   WITH fakt->brdok,;
               datfaktp  WITH fakt->datdok,;
               idkonto   WITH cidkonto,;
               idkonto2  WITH cidkonto2,;
               idzaduz2  WITH cidzaduz2,;
               kolicina  WITH fakt->kolicina,;
               idroba    WITH fakt->idroba,;
               fcj       WITH fakt->cijena,;
               nc        WITH fakt->cijena,;
               rabatv    WITH fakt->rabat

            REPLACE vpc       WITH KoncijVPC()

            SELECT fakt
            SKIP 1
         ENDDO
         @ m_x + 8, m_y + 2 SAY "Dokument je prenesen !!"
         IF gBrojac == "D"
            cbrkalk := UBrojDok( Val( Left( cbrkalk, 5 ) ) + 1, 5, Right( cBrKalk, 3 ) )
         ENDIF
         Inkey( 4 )
         @ m_x + 8, m_y + 2 SAY Space( 30 )
      ENDIF

   ENDDO
   BoxC()
   CLOSERET

   RETURN
// }
