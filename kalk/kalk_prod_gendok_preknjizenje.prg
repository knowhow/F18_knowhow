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


FUNCTION GetPreknj()

   // {
   LOCAL aProd // matrica sa prodavnicama
   LOCAL cProdKto // prodavnicki konto
   LOCAL nUvecaj // uvecaj broj kalkulacije za
   LOCAL cBrKalk // broj kalkulacije
   LOCAL cPKonto
   LOCAL nCnt
   LOCAL cAkciznaRoba := "N"
   LOCAL cZasticeneCijene := "N"
   Box(, 7, 65 )
   O_KONTO
   O_TARIFA
   cProdKto := Space( 7 )
   dDateOd := CToD( "" )
   dDateDo := Date()
   cPTarifa := PadR( "PDV17", 6 )

   @ 1 + m_x, 2 + m_y SAY "Preknjizenje prodavnickih konta"
   @ 3 + m_x, 2 + m_y SAY "Datum od" GET dDateOd
   @ 3 + m_x, Col() + m_y SAY "datum do" GET dDateDo
   @ 4 + m_x, 2 + m_y SAY "Prodavnicki konto (prazno-svi):" GET cProdKto VALID Empty( cProdKto ) .OR. P_Konto( @cProdKto )
   @ 5 + m_x, 2 + m_y SAY "Preknjizenje na tarifu:" GET cPTarifa VALID P_Tarifa( @cPTarifa )
   @ 6 + m_x, 2 + m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
   @ 7 + m_x, 2 + m_y SAY "Artikli sa zasticenim cijenama " GET cZasticeneCijene VALID cZasticeneCijene $ "DN" PICT "@!"
   READ
   BoxC()
   // prekini operaciju
   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF Pitanje(, "Izvrsiti preknjizenje (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   aProd := {}
   IF Empty( AllTrim( cProdKto ) )
      // napuni matricu sa prodavnckim kontima
      GetProdKto( @aProd )
   ELSE
      AAdd( aProd, { cProdKto } )
   ENDIF

   // provjeri velicinu matrice
   IF Len( aProd ) == 0
      MsgBeep( "Ne postoje definisane prodavnice u KONCIJ-u!" )
      RETURN
   ENDIF

   // kreiraj tabelu PRIPT
   cre_kalk_priprt()

   // pokreni preknjizenje
   Box(, 2, 65 )
   @ 1 + m_x, 2 + m_y SAY "Vrsim preknjizenje " + AllTrim( Str( Len( aProd ) ) ) + " prodavnice..."

   O_KALK_DOKS

   nUvecaj := 1
   FOR nCnt := 1 TO Len( aProd )
      // daj broj kalkulacije
      cBrKalk := GetNextKalkDoc( gFirma, "80", nUvecaj )
      cPKonto := aProd[ nCnt, 1 ]

      @ 2 + m_x, 2 + m_y SAY "Prodavnica: " + AllTrim( cPKonto ) + "   dokument: " + gFirma + "-80-" + AllTrim( cBrKalk )

      GenPreknj( cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .F., Date(), "", ( cAkciznaRoba == "D" ), ( cZasticeneCijene == "D" ) )
      ++ nUvecaj
   NEXT

   BoxC()

   MsgBeep( "Zavrseno filovanje pomocne tabele pokrecem obradu!" )
   // Automatska obrada dokumenata
   // 0 - kreni od 0, .f. - ne pokreci asistenta
   ObradiImport( 0, .F., .F. )

   RETURN
// }


FUNCTION GetPstPDV()

   // {
   LOCAL aProd // matrica sa prodavnicama
   LOCAL cProdKto // prodavnicki konto
   LOCAL nUvecaj // uvecaj broj kalkulacije za
   LOCAL cBrKalk // broj kalkulacije
   LOCAL cPKonto
   LOCAL nCnt
   LOCAL cPTarifa := "PDV17 "
   LOCAL cAkciznaRoba := "N"
   LOCAL cZasticeneCijene := "N"

   IF !IsPDV()
      MsgBeep( "Opcija raspoloziva samo za PDV rezim rada !!!" )
      RETURN
   ENDIF

   Box(, 10, 65 )
   O_KONTO
   O_TARIFA
   cProdKto := Space( 7 )
   dDateOd := CToD( "" )
   dDateDo := Date()
   dDatPst := Date()
   cSetCj := "1"

   @ 1 + m_x, 2 + m_y SAY "Generacija pocetnog stanja..."
   @ 3 + m_x, 2 + m_y SAY "Datum od" GET dDateOd
   @ 3 + m_x, Col() + m_y SAY "datum do" GET dDateDo
   @ 5 + m_x, 2 + m_y SAY "Datum pocetnog stanja" GET dDatPst
   @ 6 + m_x, 2 + m_y SAY "Prodavnicki konto (prazno-svi):" GET cProdKto VALID Empty( cProdKto ) .OR. P_Konto( @cProdKto )
   @ 8 + m_x, 2 + m_y SAY "Ubaciti set cijena (0-nista/1-mpc/2-mpc2) " GET cSetCj VALID !Empty( cSetCj ) .AND. cSetCj $ "0123"
   @ 9 + m_x, 2 + m_y SAY "Akcizna roba D/N " GET cAkciznaRoba VALID cAkciznaRoba $ "DN"  PICT "@!"
   @ 10 + m_x, 2 + m_y SAY "Artikli sa zasticenim cijenama " GET cZasticeneCijene VALID cZasticeneCijene $ "DN" PICT "@!"
   READ
   BoxC()
   // prekini operaciju
   IF LastKey() == K_ESC
      RETURN
   ENDIF

   IF Pitanje(, "Izvrsiti prenos poc.st. (D/N)?", "D" ) == "N"
      RETURN
   ENDIF

   aProd := {}
   IF Empty( AllTrim( cProdKto ) )
      // napuni matricu sa prodavnckim kontima
      GetProdKto( @aProd )
   ELSE
      AAdd( aProd, { cProdKto } )
   ENDIF

   // provjeri velicinu matrice
   IF Len( aProd ) == 0
      MsgBeep( "Ne postoje definisane prodavnice u KONCIJ-u!" )
      RETURN
   ENDIF

   // kreiraj tabelu PRIPT
   cre_kalk_priprt()

   // pokreni preknjizenje
   Box(, 2, 65 )
   @ 1 + m_x, 2 + m_y SAY "Generisem pocetna stanja " + AllTrim( Str( Len( aProd ) ) ) + " prodavnice..."

   O_KALK_DOKS


   nUvecaj := 1
   FOR nCnt := 1 TO Len( aProd )
      // daj broj kalkulacije
      cBrKalk := GetNextKalkDoc( gFirma, "80", nUvecaj )
      cPKonto := aProd[ nCnt, 1 ]

      @ 2 + m_x, 2 + m_y SAY "Prodavnica: " + AllTrim( cPKonto ) + "   dokument: " + gFirma + "-80-" + AllTrim( cBrKalk )
      // gen poc.st
      GenPreknj( cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .T., dDatPst, cSetCj, ( cAkciznaRoba == "D" ), ( cZasticeneCijene == "D" ) )

      ++ nUvecaj
   NEXT

   BoxC()

   MsgBeep( "Zavrseno filovanje pomocne tabele pokrecem obradu!" )
   // Automatska obrada dokumenata
   ObradiImport( 0, .F., .F. )

   RETURN
// }




/* GetProdKto(aProd)
 *     Vrati matricu sa prodavnicama
 *   param: aProd
 */
FUNCTION GetProdKto( aProd )

   // {
   LOCAL cTip
   LOCAL cKPath

   // KONCIJ polja za provjeru
   // ============
   // ID - konto
   // NAZ - tip M1, M2
   // KUMTOPS - lokacija kumulativa tops

   O_KONCIJ
   SELECT koncij
   GO TOP
   DO WHILE !Eof()
      cTip := AllTrim( field->naz )
      cTip := Left( cTip, 1 ) // daj samo prvi karakter "M" ili "V"
      cKPath := AllTrim( field->KUMTOPS )

      // ako je cTip M onda dodaj tu prodavnicu
      IF ( cTip == "M" ) .AND. !Empty( cKPath )
         AAdd( aProd, { field->id } )
      ENDIF

      SKIP
   ENDDO

   RETURN
// }


FUNCTION roba_pdv17()

   // {
   IF !IsPDV()
      MsgBeep( "Opcija raspoloziva samo za PDV rezim!" )
      RETURN
   ENDIF

   MsgO( "Setujem tarifa PDV17..." )
   O_ROBA
   SET ORDER TO
   GO TOP
   DO WHILE !Eof()
      IF IsPDV()
         // prelazak na PDV 01.01.2006
         REPLACE IDTARIFA WITH "PDV17"
      ENDIF

      SKIP
   ENDDO
   MsgC()

   RETURN
// }


/* GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst)
 *     Opcija generisanja dokumenta preknjizenja
 *   param: cPKonto - prodavnicki konto
 *   param: cPrTarifa - tarifa preknjizenja
 *   param: dDatOd - datum od kojeg se pravi preknjizenje
 *   param: dDatDo - datum do kojeg se pravi preknjizenje
 *   param: cBrKalk - broj kalkulacije
 *   param: lPst - pocetno stanje
 */
FUNCTION GenPreknj( cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst, dDatPs, cCjSet, lAkciznaRoba, lZasticeneCijene )

   // {
   LOCAL cIdFirma
   LOCAL nRbr
   LOCAL fPocStanje := .T.
   LOCAL n_MpcBP_predhodna
   LOCAL nAkcizaPorez
   LOCAL nZasticenaCijena

   IF lPst
      O_ROBASEZ
      O_KALKSEZ
   ELSE
      O_KALK
   ENDIF

   IF lAkciznaRoba == NIL
      lAkciznaRoba := .F.
   ENDIF
   IF lZasticeneCijene == NIL
      lZasticeneCijene := .F.
   ENDIF


   O_ROBA
   O_KONTO
   O_KONCIJ
   O_TARIFA
   o_kalk_pript() // pomocna tabela pript

   cIdFirma := gFirma

   IF lPst
      SELECT kalksez
   ELSE
      SELECT kalk
   ENDIF

   SET ORDER TO TAG "4"
   // "4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
   GO TOP

   HSEEK cIdfirma + cPKonto

   SELECT konto
   HSEEK cPKonto
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

      IF lZasticeneCijene
         cBrDok := PadR( "POC.ST.AZ", 10 )
         // izbuci iz ovog dokumenta
         cIzBrDok := PadR( "PPP-PDV.AZ", 10 )
      ENDIF

   ELSE
      cBrDok :=  PadR( "PPP-PDV17", 10 )
      IF lAkciznaRoba
         cBrDok := PadR( "PPP-PDV.AK", 10 )
      ENDIF

      IF lZasticeneCijene
         cBrDok := PadR( "PPP-PDV.AZ", 10 )
      ENDIF
   ENDIF

   DO WHILE !Eof() .AND. cIdFirma + cPKonto == idfirma + pkonto .AND. IspitajPrekid()
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

      IF FieldPos( "ZANIVEL" ) <> 0
         nZasticenaCijena := zanivel
      ELSE
         nZasticenaCijena := 0
      ENDIF

      IF lZasticeneCijene
         IF ( nZasticenaCijena == 0 )
            // ovo nije zasticeni artikal
            // posto mu nije setovana zasticena cijena
            //
            IF lPst
               SELECT kalksez
            ELSE
               SELECT kalk
            ENDIF
            SKIP
            LOOP
         ENDIF

      ELSE
         IF ( nZasticenaCijena <> 0 )
            // ovo je zasticeni artikal
            // a mi sada ne zelimo preknjizenje ovih artikala
            IF lPst
               SELECT kalksez
            ELSE
               SELECT kalk
            ENDIF
            SKIP
            LOOP
         ENDIF

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

      nPKol := 0
      nPNV := 0
      nPMPV := 0
      nUlaz := 0
      nIzlaz := 0
      nMPVU := 0
      nMPVI := 0
      nNVU := 0
      nNVI := 0
      nRabat := 0

      // usluge
      IF lPst
         IF robasez->tip $ "TU"
            SKIP
            LOOP
         ENDIF
      ELSE
         IF roba->tip $ "TU"
            SKIP
            LOOP
         ENDIF
      ENDIF

      DO WHILE !Eof() .AND. cIdFirma + cPKonto + cIdRoba == idFirma + pkonto + idroba

         IF  ( IdVd == "80" ) .AND. ( BrFaktP == cIzBrDok ) .AND. ( kolicina > 0 )
            // pozitivna stavka 80-ke
            pl_mpc := mpc
            pl_mpcSaPP := mpcSaPP
            pl_kolicina := kolicina
            pl_nc := nc
         ENDIF



         // provjeri datumski
         IF ( field->datdok < dDatOd ) .OR. ( field->datdok > dDatDo )
            SKIP
            LOOP
         ENDIF

         IF lPst
            IF robasez->tip $ "TU"
               SKIP
               LOOP
            ENDIF
         ELSE
            IF roba->tip $ "TU"
               SKIP
               LOOP
            ENDIF
         ENDIF

         IF field->datdok >= dDatOd  // nisu predhodni podaci
            IF field->pu_i == "1"
               SumirajKolicinu( kolicina, 0, @nUlaz, 0, .T. )
               nMPVU += mpcsapp * kolicina
               nNVU += nc * ( kolicina )

            ELSEIF field->pu_i == "5"
               IF idvd $ "12#13"
                  SumirajKolicinu( -kolicina, 0, @nUlaz, 0, .T. )
                  nMPVU -= mpcsapp * kolicina
                  nNVU -= nc * kolicina
               ELSE
                  SumirajKolicinu( 0, kolicina, 0, @nIzlaz, .T. )
                  nMPVI += mpcsapp * kolicina
                  nNVI += nc * kolicina
               ENDIF

            ELSEIF field->pu_i == "3"
               // nivelacija
               nMPVU += mpcsapp * kolicina
            ELSEIF field->pu_i == "I"
               SumirajKolicinu( 0, gkolicin2, 0, @nIzlaz, .T. )
               nMPVI += mpcsapp * gkolicin2
               nNVI += nc * gkolicin2
            ENDIF
         ENDIF
         SKIP
      ENDDO

      IF Round( nMPVU - nMPVI + nPMPV, 4 ) <> 0
         SELECT pript

         // MPC bez poreza u + stavci
         n_MpcBP_predhodna := 0
         IF Round( nUlaz - nIzlaz, 4 ) <> 0
            IF !lPst
               // prva stavka stara tarifa
               APPEND BLANK
               ++ nRbr
               REPLACE idFirma WITH cIdfirma
               REPLACE brfaktp WITH cBrDok
               REPLACE idroba WITH cIdRoba
               REPLACE rbr WITH RedniBroj( nRbr )
               REPLACE idkonto WITH cPKonto
               REPLACE pkonto WITH cPKonto
               REPLACE datdok WITH dDatDo
               REPLACE pu_i WITH "1"
               REPLACE error WITH "0"
               REPLACE idTarifa WITH Tarifa( cPKonto, cIdRoba, @aPorezi )
               REPLACE datfaktp WITH dDatDo
               // promjeni predznak kolicine
               REPLACE kolicina WITH -( nUlaz - nIzlaz )
               REPLACE idvd WITH "80"
               REPLACE brdok WITH cBrKalk
               REPLACE nc WITH ( nNVU - nNVI + nPNV ) / ( nUlaz - nIzlaz + nPKol )
               // replace mpcsapp with nStCijena
               REPLACE mpcsapp WITH ( nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol )
               REPLACE vpc WITH nc
               REPLACE TMarza2 WITH "A"
               // setuj marzu i mpc
               Scatter()
               IF WMpc_lv( nil, nil, aPorezi )
                  VMpc_lv( nil, nil, aPorezi )
                  VMpcSaPP_lv( nil, nil, aPorezi, .F. )
               ENDIF

               // uzmi cijenu bez poreza za + stavku
               n_MpcBP_predhodna := _mpc

               IF lAkciznaRoba
                  n_MpcBP_predhodna := _mpc - nAkcizaPorez
                  IF ( n_MpcBP_predhodna <= 0 )
                     MsgBeep( ;
                        "Akcizna roba :  " + cIdRoba + " nelogicno ##- mpc bez akciznog poreza < 0 :# MPC b.p:" + ;
                        Str( n_MpcBP_predhodna, 6, 2 ) + "/ AKCIZA:" + ;
                        Str( nAkcizaPorez, 6, 2 ) )
                  ENDIF

               ENDIF

               Gather()

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
            REPLACE idkonto WITH cPKonto
            REPLACE pkonto WITH cPKonto
            REPLACE pu_i WITH "1"
            REPLACE error WITH "0"
            IF lPst
               REPLACE datdok WITH dDatPst
            ELSE
               REPLACE datdok WITH dDatDo
            ENDIF

            REPLACE idTarifa WITH Tarifa( cPKonto, cIdRoba, @aPorezi, cPrTarifa )

            IF lPst
               REPLACE datfaktp WITH dDatPst
            ELSE
               REPLACE datfaktp WITH dDatDo
            ENDIF

            REPLACE kolicina WITH nUlaz - nIzlaz
            REPLACE idvd WITH "80"
            REPLACE brdok WITH cBrKalk
            REPLACE nc WITH ( nNVU - nNVI + nPNV ) / ( nUlaz - nIzlaz + nPKol )


            IF !lPst
               // replace mpc with n_MpcBP_predhodna := _mpc
               _mpc := n_MpcBP_predhodna
               REPLACE mpc WITH _mpc

               IF lAkciznaRoba
                  // i nabavna cijena je manja
                  // jer ovaj porez vise nije troskovna
                  // stavka kao sto je bio u rezimu PPP-a
                  REPLACE nc WITH nc - nAkcizaPorez
               ENDIF

               // formiraj mpc bez poreza na osnovu
               // zasticene cijene
               IF lZasticeneCijene
                  REPLACE mpcSapp WITH nZasticenaCijena, ;
                     mpc WITH 0
               ENDIF


            ELSE
               // "sasin" algoritam - ispocetka racunaj poc.st
               IF !lAkciznaRoba
                  REPLACE mpcsapp WITH ( nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol )
               ELSE
                  // izvuci iz 80-ke u seznoskom podrucju podatke
                  _mpc := pl_mpc
                  _mpcSaPP := pl_mpcSaPP
                  _nc := pl_nc
                  _kolicina := pl_kolicina

                  REPLACE mpcsapp WITH pl_mpcSaPP, ;
                     mpc WITH pl_mpc, ;
                     nc WITH pl_nc, ;
                     kolicina WITH pl_kolicina

               ENDIF
            ENDIF

            REPLACE vpc WITH nc
            REPLACE TMarza2 WITH "A"
            // setuj marzu i MPC
            Scatter()
            IF WMpc_lv( nil, nil, aPorezi )
               VMpc_lv( nil, nil, aPorezi )
               VMpcSaPP_lv( nil, nil, aPorezi, .F. )
            ENDIF

            IF lPst
               nNMpcSaPDV := _mpcsapp
            ENDIF

            Gather()

            // ubaci novu mpc u sifrarnik robe
            // ubaci novu tarifu robe

            IF lPst
               SELECT roba
               HSEEK cIdRoba

               IF cCjSet == "0"
                  // nista - cijene se ne diraju
               ENDIF

               IF cCjSet == "1"
                  REPLACE mpc WITH nNMpcSaPDV
               ENDIF

               IF cCjSet == "2"
                  REPLACE mpc2 WITH nNMpcSaPDV
               ENDIF

               IF cCjSet == "3"
                  REPLACE mpc3 WITH nNMpcSaPDV
               ENDIF

               REPLACE idtarifa WITH "PDV17 "
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
