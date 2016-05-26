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

// array
STATIC aPorezi := {}
// ;


FUNCTION GetPreknM()

   // {
   LOCAL aMag // matrica sa magacinima
   LOCAL cMagKto // magacinski konto
   LOCAL nUvecaj // uvecaj broj kalkulacije za
   LOCAL cBrKalk // broj kalkulacije
   LOCAL cMKonto
   LOCAL nCnt
   LOCAL cAkciznaRoba := "D"
   Box(, 6, 65 )
   O_KONTO
   O_TARIFA
   cMagKto := Space( 7 )
   dDateOd := CToD( "" )
   dDateDo := Date()
   cPTarifa := PadR( "PDV17", 6 )

   @ 1 + m_x, 2 + m_y SAY "Preknjizenje magacinskih konta"
   @ 3 + m_x, 2 + m_y SAY "Datum od" GET dDateOd
   @ 3 + m_x, Col() + m_y SAY "datum do" GET dDateDo
   @ 4 + m_x, 2 + m_y SAY "Magacinski konto (prazno-svi):" GET cMagKto VALID Empty( cMagKto ) .OR. P_Konto( @cMagKto )
   @ 5 + m_x, 2 + m_y SAY "Preknjizenje na tarifu:" GET cPTarifa VALID P_Tarifa( @cPTarifa )
   @ 6 + m_x, 2 + m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
   READ
   BoxC()
   // prekini operaciju
   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF Pitanje(, "Izvrsiti preknjizenje (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   aMag := {}
   IF Empty( AllTrim( cMagKto ) )
      // napuni matricu sa magac kontima
      GetMagKto( @aMag )
   ELSE
      AAdd( aMag, { cMagKto } )
   ENDIF

   // provjeri velicinu matrice
   IF Len( aMag ) == 0
      MsgBeep( "Ne postoje definisane prodavnice u KONCIJ-u!" )
      RETURN
   ENDIF

   // kreiraj tabelu PRIPT
   cre_kalk_priprt()

   // pokreni preknjizenje
   Box(, 2, 65 )
   @ 1 + m_x, 2 + m_y SAY "Vrsim preknjizenje " + AllTrim( Str( Len( aMag ) ) ) + " magacina..."

   O_KALK_DOKS

   nUvecaj := 1
   FOR nCnt := 1 TO Len( aMag )
      // daj broj kalkulacije
      cBrKalk := GetNextKalkDoc( gFirma, "16", nUvecaj )
      cMKonto := aMag[ nCnt, 1 ]

      @ 2 + m_x, 2 + m_y SAY "Magacin: " + AllTrim( cMKonto ) + "   dokument: " + gFirma + "-16-" + AllTrim( cBrKalk )

      GenPreknM( cMKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .F., Date(), "", ( cAkciznaRoba == "D" ) )
      ++ nUvecaj
   NEXT

   BoxC()

   MsgBeep( "Zavrseno filovanje pomocne tabele pokrecem obradu!" )
   // Automatska obrada dokumenata
   // 0 - kreni od 0, .f. - ne pokreci asistenta
   kalk_imp_obradi_sve_dokumente( 0, .F., .F. )

   RETURN
// }


FUNCTION GetPstPreknj()

   // {
   LOCAL aMag // matrica sa prodavnicama
   LOCAL cMagKto // prodavnicki konto
   LOCAL nUvecaj // uvecaj broj kalkulacije za
   LOCAL cBrKalk // broj kalkulacije
   LOCAL cMKonto
   LOCAL nCnt
   LOCAL cMTarifa := "PDV17 "
   LOCAL cAkciznaRoba := "N"

   IF !IsPDV()
      MsgBeep( "Opcija raspoloziva samo za PDV rezim rada !!!" )
      RETURN
   ENDIF

   Box(, 9, 65 )
   O_KONTO
   O_TARIFA
   cMagKto := Space( 7 )
   dDateOd := CToD( "" )
   dDateDo := Date()
   dDatPst := Date()
   cSetCj := "1"

   @ 1 + m_x, 2 + m_y SAY "Generacija pocetnog stanja..."
   @ 3 + m_x, 2 + m_y SAY "Datum od" GET dDateOd
   @ 3 + m_x, Col() + m_y SAY "datum do" GET dDateDo
   @ 5 + m_x, 2 + m_y SAY "Datum pocetnog stanja" GET dDatPst
   @ 6 + m_x, 2 + m_y SAY "Magacinski konto (prazno-svi):" GET cMagKto VALID Empty( cMagKto ) .OR. P_Konto( @cMagKto )
   @ 8 + m_x, 2 + m_y SAY "Ubaciti set cijena (0-nista/1/2) " GET cSetCj VALID !Empty( cSetCj ) .AND. cSetCj $ "01234"
   @ 9 + m_x, 2 + m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
   READ
   BoxC()
   // prekini operaciju
   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF Pitanje(, "Izvrsiti prenos poc.st. (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   aMag := {}
   IF Empty( AllTrim( cMagKto ) )
      // napuni matricu sa magacinskim kontima
      GetMagKto( @aMag )
   ELSE
      AAdd( aMag, { cMagKto } )
   ENDIF

   // provjeri velicinu matrice
   IF Len( aMag ) == 0
      MsgBeep( "Ne postoje definisani magacini u KONCIJ-u!" )
      RETURN
   ENDIF

   // kreiraj tabelu PRIPT
   cre_kalk_priprt()

   // pokreni preknjizenje
   Box(, 2, 65 )
   @ 1 + m_x, 2 + m_y SAY "Generisem pocetna stanja " + AllTrim( Str( Len( aMag ) ) ) + " magacini..."

   O_KALK_DOKS


   nUvecaj := 1
   FOR nCnt := 1 TO Len( aMag )
      // daj broj kalkulacije
      cBrKalk := GetNextKalkDoc( gFirma, "16", nUvecaj )
      cMKonto := aMag[ nCnt, 1 ]

      @ 2 + m_x, 2 + m_y SAY "Magacin: " + AllTrim( cMKonto ) + "   dokument: " + gFirma + "-16-" + AllTrim( cBrKalk )
      // gen poc.st
      GenPreknM( cMKonto, cMTarifa, dDateOd, dDateDo, cBrKalk, .T., dDatPst, cSetCj, ( cAkciznaRoba == "D" ) )

      ++ nUvecaj
   NEXT

   BoxC()

   MsgBeep( "Zavrseno filovanje pomocne tabele pokrecem obradu!" )
   // Automatska obrada dokumenata
   kalk_imp_obradi_sve_dokumente( 0, .F., .F. )

   RETURN
// }




/* GetMagKto(aMag)
 *     Vrati matricu sa magacinima
 *   param: aMag
 */
FUNCTION GetMagKto( aMag )

   // {
   LOCAL cTip
   LOCAL cKPath

   // KONCIJ polja za provjeru
   // ============
   // ID - konto
   // NAZ - tip M1, M2
   // KUMTOPS - lokacija kumulativa tops

   o_koncij()
   SELECT koncij
   GO TOP
   DO WHILE !Eof()
      cTip := AllTrim( field->naz )
      cTip := Left( cTip, 1 )
      // daj samo prvi karakter "M" ili "V"

      // ako je cTip V onda dodaj taj magacin
      IF ( cTip == "V" ) .AND. !Empty( cKPath )
         AAdd( aMag, { field->id } )
      ENDIF

      SKIP
   ENDDO

   RETURN
// }


/* GenPreknM(cMKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst)
 *     Opcija generisanja dokumenta preknjizenja
 *   param: cMKonto - magacinski  konto
 *   param: cPrTarifa - tarifa preknjizenja
 *   param: dDatOd - datum od kojeg se pravi preknjizenje
 *   param: dDatDo - datum do kojeg se pravi preknjizenje
 *   param: cBrKalk - broj kalkulacije
 *   param: lPst - pocetno stanje
 */
FUNCTION GenPreknM( cMKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst, dDatPs, cCjSet, lAkciznaRoba )

   // {
   LOCAL cIdFirma
   LOCAL nRbr
   LOCAL fPocStanje := .T.
   LOCAL n_VpcBP_predhodna

   IF lPst
      O_ROBASEZ
      O_KALKSEZ
   ELSE
      O_KALK
   ENDIF

   IF lAkciznaRoba == NIL
      lAkciznaRoba := .F.
   ENDIF


   O_ROBA
   O_KONTO
   o_koncij()
   O_TARIFA
   o_kalk_pript() // pomocna tabela pript

   cIdFirma := gFirma

   IF lPst
      SELECT kalksez
   ELSE
      SELECT kalk
   ENDIF

   SET ORDER TO TAG "3"
   // "4","idFirma+Mkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
   GO TOP

   HSEEK cIdfirma + cMKonto

   SELECT konto
   HSEEK cMkonto
   IF lPst
      SELECT kalksez
   ELSE
      SELECT kalk
   ENDIF

   nTUlaz := 0
   nTIzlaz := 0
   nTPKol := 0
   nTMPVU := 0
   nTMPVI := 0
   nTNVU := 0
   nTNVI := 0
   nRbr := 0


   // nemoguca kombinacija
   cIzBrDok := "#X43432032032$#$#"

   IF lPst
      cBrDok := PadR( "POC.ST", 10 )
      // izvuci iz ovog dokumenta
      cIzBrDok :=  PadR( "PPP-PDV17", 10 )

      IF lAkciznaRoba
         cBrDok := PadR( "POC.ST.AK", 10 )
         // izbuci iz ovog dokumenta
         cIzBrDok := PadR( "PPP-PDV.AK", 10 )
      ENDIF
   ELSE
      cBrDok :=  PadR( "PPP-PDV17", 10 )
      IF lAkciznaRoba
         cBrDok := PadR( "PPP-PDV.AK", 10 )
      ENDIF
   ENDIF

   DO WHILE !Eof() .AND. cIdFirma + cMKonto == idfirma + Mkonto .AND. IspitajPrekid()
      cIdRoba := Idroba

      IF lPst
         SELECT robasez
      ELSE
         SELECT roba
      ENDIF
      HSEEK cIdRoba

      IF FieldPos( "ZANIV2" ) <> 0
         nAkcizaPorez := zaniv2
      ELSE
         nAkcizaPorez := 0
      ENDIF


      IF lPst
         SELECT kalksez
      ELSE
         SELECT kalk
      ENDIF


      IF lAkciznaRoba
         IF ( nAkcizaPorez == 0 )
            // samo akcizna roba
            SKIP
            LOOP
         ENDIF
      ELSE
         IF ( nAkcizaPorez <> 0 )
            // necemo akciznu robu
            SKIP
            LOOP
         ENDIF

      ENDIF

      nUlaz := 0
      nIzlaz := 0

      nVpvU := 0
      nVpvI := 0
      nNVU := 0
      nNVI := 0

      nRabat := 0


      DO WHILE !Eof() .AND. cIdFirma + cMKonto + cIdRoba == idFirma + mkonto + idroba

         IF  ( IdVd == "16" ) .AND. ( BrFaktP == cIzBrDok ) .AND. ( kolicina > 0 )
            // pozitivna stavka 16-ke
            pl_nc := nc
            pl_vpc := vpc
            pl_kolicina := kolicina
         ELSE
            IF lPst
               SKIP
               LOOP
            ENDIF
         ENDIF



         // provjeri datumski
         IF ( datdok < dDatOd ) .OR. ( datdok > dDatDo )
            SKIP
            LOOP
         ENDIF

         IF datdok >= dDatOd  // nisu predhodni podaci

            nKol := kolicina - gkolicina - gkolicin2

            IF mu_i == "1"
               IF  ( idvd $ "12#22#94" )
                  // povrat
                  nIzlaz += -nKol
                  nVpvI += vpc * -nKol
                  nNvI += nc * -nKol
               ELSE
                  nUlaz += nKol
                  nVpvU += vpc * nKol
                  nNvU += nc * nKol
               ENDIF

            ELSEIF mu_i == "5"

               nIzlaz += nKol
               nVpvI += vpc * nKol
               nNvI += nc * nKol

            ELSEIF mu_i == "3"
               // nivelacija
               nVpvU += vpc * nKol

            ENDIF
         ENDIF
         SKIP
      ENDDO

      IF Round( nVpvU - nVpvI, 4 ) <> 0
         SELECT pript

         // MPC bez poreza u + stavci
         n_VpcBP_predhodna := 0
         IF Round( nUlaz - nIzlaz, 4 ) <> 0
            IF !lPst
               // prva stavka stara tarifa
               APPEND BLANK
               ++ nRbr
               REPLACE idFirma WITH cIdfirma
               REPLACE brfaktp WITH cBrDok
               REPLACE idroba WITH cIdRoba
               REPLACE rbr WITH RedniBroj( nRbr )
               REPLACE idkonto WITH cMKonto
               REPLACE pkonto WITH cMKonto
               REPLACE datdok WITH dDatDo
               REPLACE mu_i WITH "1"
               REPLACE error WITH "0"
               REPLACE idTarifa WITH Tarifa( "", cIdRoba, @aPorezi )
               REPLACE datfaktp WITH dDatDo
               // promjeni predznak kolicine
               REPLACE kolicina WITH -( nUlaz - nIzlaz )
               REPLACE idvd WITH "16"
               REPLACE brdok WITH cBrKalk
               REPLACE nc WITH ( nNVU - nNVI ) / ( nUlaz - nIzlaz )

               REPLACE vpc WITH ( nVPVU - nVPVI ) / ( nUlaz - nIzlaz )

               REPLACE marza WITH vpc - nc
               REPLACE tMarza WITH "A"

               n_VpcBP_predhodna := vpc

               IF lAkciznaRoba
                  n_VpcBP_predhodna := vpc - nAkcizaPorez
                  IF ( n_VpcBP_predhodna <= 0 )
                     MsgBeep( ;
                        "Akcizna roba :  " + cIdRoba + " nelogicno ##- mpc bez akciznog poreza < 0 :# VPC b.p:" + ;
                        Str( n_VpcBP_predhodna, 6, 2 ) + "/ AKCIZA:" + ;
                        Str( nAkcizaPorez, 6, 2 ) )
                  ENDIF

               ENDIF

            ENDIF

            // resetuj poreze
            aPorezi := {}

            // kontra stavka PDV tarifa
            APPEND BLANK
            ++nRbr
            REPLACE idFirma WITH cIdfirma


            REPLACE brfaktp WITH cBrDok
            REPLACE idroba WITH cIdRoba
            REPLACE rbr WITH RedniBroj( nRbr )
            REPLACE idkonto WITH cMKonto
            REPLACE mkonto WITH cMKonto
            REPLACE mu_i WITH "1"
            REPLACE error WITH "0"
            IF lPst
               REPLACE datdok WITH dDatPst
            ELSE
               REPLACE datdok WITH dDatDo
            ENDIF

            REPLACE idTarifa WITH Tarifa( "", cIdRoba, @aPorezi, cPrTarifa )

            IF lPst
               REPLACE datfaktp WITH dDatPst
            ELSE
               REPLACE datfaktp WITH dDatDo
            ENDIF

            REPLACE kolicina WITH nUlaz - nIzlaz
            REPLACE idvd WITH "16"
            REPLACE brdok WITH cBrKalk
            REPLACE nc WITH ( nNVU - nNVI ) / ( nUlaz - nIzlaz )


            IF !lPst
               REPLACE vpc WITH n_VpcBP_predhodna

               IF lAkciznaRoba
                  // i nabavna cijena je manja
                  // jer ovaj porez vise nije troskovna
                  // stavka kao sto je bio u rezimu PPP-a
                  REPLACE nc WITH nc - nAkcizaPorez
               ENDIF

            ELSE
               // izvuci iz 16-ke u sezonskom podrucju podatke
               IF pl_kolicina > 0
                  REPLACE vpc WITH pl_vpc, ;
                     nc WITH pl_nc, ;
                     tmarza WITH "A", ;
                     marza WITH pl_vpc - pl_nc, ;
                     kolicina WITH pl_kolicina
               ENDIF

            ENDIF


            IF lPst
               IF Round( pl_kolicina, 4 ) <> 0
                  nNVpcBezPdv := pl_vpc

                  // ubaci novu vpc u sifrarnik robe
                  // ubaci novu tarifu robe

                  SELECT roba
                  HSEEK cIdRoba

                  IF cCjSet == "1"
                     REPLACE vpc WITH nNVpcBezPdv
                  ENDIF

                  IF cCjSet == "2"
                     REPLACE vpc2 WITH nNVpcBezPdv
                  ENDIF

                  REPLACE idtarifa WITH "PDV17 "
               ENDIF
            ENDIF

         ENDIF

         IF lPst
            SELECT kalksez
         ELSE
            SELECT kalk
         ENDIF
      ENDIF

      IF lPst
         SELECT kalksez
      ELSE
         SELECT kalk
      ENDIF

   ENDDO

   RETURN
// }
