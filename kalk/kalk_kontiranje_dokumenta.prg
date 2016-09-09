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


STATIC dDatMax


/*

 kontiranje naloga

 lAutomatskiSetBrojNaloga - .t. automatski se odrjedjuje broj naloga koji se formira,
                            .f. unosi se broj formiranog naloga
 lAGen - automatsko generisanje
 lViseKalk - vise kalkulacija
 cNalog - zadani broj FIN naloga, ako je EMPTY() ne uzima se !

*/

FUNCTION kalk_kontiranje_fin_naloga( lAutomatskiSetBrojNaloga, lAGen, lViseKalk, cNalog, lAutoBrojac )

   LOCAL cIdFirma
   LOCAL cIdVd
   LOCAL cBrDok
   LOCAL lAFin
   LOCAL lAMat
   LOCAL lAFin2
   LOCAL lAMat2
   LOCAL nRecNo
   LOCAL lPrvoDzok := ( fetch_metric( "kalk_kontiranje_prioritet_djokera", nil, "N" ) == "D" )
   LOCAL _fakt_params := fakt_params()
   PRIVATE lVrsteP := _fakt_params[ "fakt_vrste_placanja" ]

   IF ( lAGen == NIL )
      lAGen := .F.
   ENDIF

   IF ( lViseKalk == NIL )
      lViseKalk := .F.
   ENDIF

   IF ( dDatMax == NIL )
      dDatMax := CToD( "" )
   ENDIF


   IF ( lAutoBrojac == NIL )
      lAutoBrojac := .T.
   ENDIF

   SELECT F_SIFK
   IF !Used()
      O_SIFK
   ENDIF

   SELECT F_SIFV
   IF !Used()
      O_SIFV
   ENDIF

   SELECT F_ROBA
   IF !Used()
      O_ROBA
   ENDIF

   SELECT F_FINMAT
   IF !Used()
      O_finmat
   ENDIF

   SELECT F_TRFP
   USE
   O_TRFP

   SELECT F_KONCIJ
   IF !Used()
      o_koncij()
   ENDIF

   IF FieldPos( "IDRJ" ) <> 0
      lPoRj := .T.
   ELSE
      lPoRj := .F.
   ENDIF

   SELECT F_VALUTE
   IF !Used()
      O_VALUTE
   ENDIF

   IF lAutomatskiSetBrojNaloga == NIL
      lAutomatskiSetBrojNaloga := .F.
   ENDIF

   IF ( cNalog == NIL )
      IF is_kalk_fin_isti_broj()
         cNalog := finmat->brdok
         IF Val( AllTrim( cNalog ) ) > 0 // 00001 => 00000001, ako je 00001/BH ostaviti
            cNalog := PadL( AllTrim( cNalog ), 8, "0" )
         ENDIF
      ENDIF
   ENDIF

   lAFin := ( gAFin == "D" )

   IF lAFin

      Beep( 1 )
      IF !lAGen
         lAfin := Pitanje(, "Formirati FIN nalog?", "D" ) == "D"
      ELSE
         lAfin := .T.
      ENDIF

   ENDIF

   IF !lAFin
      RETURN .F.
   ENDIF

   lAFin2 := ( !lAutomatskiSetBrojNaloga .AND. gAFin <> "0" )
   lAMat := ( lAutomatskiSetBrojNaloga .AND. gAMat == "D" )

   IF lAMat .AND. f18_use_module( "mat" )
      Beep( 1 )
      lAMat := Pitanje(, "Formirati MAT nalog?", "D" ) == "D"
      O_TRMP
   ENDIF

   lAMat2 := ( !lAutomatskiSetBrojNaloga .AND. gAMat <> "0" )

   cBrNalF := ""
   cBrNalM := ""

   IF lAFin .OR. lAFin2

      O_FIN_PRIPR
      SET ORDER TO TAG "1"
      GO TOP

      o_nalog()
      SET ORDER TO TAG "1"

   ENDIF

   SELECT finmat
   GO TOP

   SELECT koncij
   GO TOP

   IF finmat->idvd $ "14#94#96#95"
      SEEK Trim( finmat->idkonto2 )
   ELSE
      SEEK Trim( finmat->idkonto )
   ENDIF

   SELECT trfp
   SEEK finmat->IdVD + koncij->shema

   cIdVN := IdVN
   // uzmi vrstu naloga koja ce se uzeti u odnosu na prvu kalkulaciju
   // koja se kontira

   IF KONCIJ->( FieldPos( "FN14" ) ) <> 0 .AND. !Empty( KONCIJ->FN14 ) .AND. finmat->IDVD == "14"
      cIdVN := KONCIJ->FN14
   ENDIF

   IF lAFin .OR. lAFin2

      IF Empty( cNalog )

         IF lAutoBrojac
            cBrNalF := fin_novi_broj_dokumenta( finmat->idfirma, cIdVn )
         ELSE
            cBrNalF := fin_prazan_broj_naloga()
         ENDIF

      ELSE

         cBrNalF := cNalog // ako je zadat broj naloga taj i uzmi
      ENDIF

   ENDIF

   SELECT finmat
   GO TOP

   dDatNal := datdok

   IF lAGen == .F.

      Box( "brn?", 5, 55 )

      SET CURSOR ON

      IF lAutomatskiSetBrojNaloga
         IF !lAFin
            cBrNalF := ""
         ELSE
            @ m_x + 1, m_y + 2  SAY "Broj naloga u FIN  " + finmat->idfirma + " - " + cIdvn + " - " + cBrNalF
         ENDIF

         IF !lAMat
            cBrBalM := ""
         ELSE
            @ m_x + 2, m_y + 2 SAY "Broj naloga u MAT  " + finmat->idfirma + " - " + cIdvn + " - " + cBrNalM
         ENDIF

         @ m_x + 4, m_y + 2 SAY "Datum naloga: "

         ?? dDatNal

         IF lAFin .OR. lAMat
            Inkey( 0 )
         ENDIF

      ELSE
         IF lAFin2
            @ m_x + 1, m_y + 2 SAY "Broj naloga u FIN  " + finmat->idfirma + " - " + cIdvn + " -" GET cBrNalF
         ENDIF

         IF idvd <> "24" .AND. lAMat2
            @ m_x + 2, m_y + 2 SAY "Broj naloga u MAT  " + finmat->idfirma + " - " + cIdvn + " -" GET cBrNalM
         ENDIF

         @ m_x + 5, m_y + 2 SAY "(ako je broj naloga prazan - ne vrsi se kontiranje)"
         READ
         ESC_BCR
      ENDIF

      BoxC()

   ENDIF

   nRbr := 0
   nRbr2 := 0

   MsgO( "KALK( shema kontiranja TRFP ) -> FINMAT -> FIN / " + cIdVN + " - " + cBrNalF  )

   SELECT finmat
   PRIVATE cKonto1 := NIL

   DO WHILE !Eof()

      cIDVD := finmat->IdVD
      cBrDok := finmat->BrDok

      IF ValType( cKonto1 ) <> "C"
         PRIVATE cKonto1 := ""
         PRIVATE cKonto2 := ""
         PRIVATE cKonto3 := ""
         PRIVATE cPartner1 := cPartner2 := cPartner3 := cPartner4 := cPartner5 := ""
         PRIVATE cBrFakt1 := cBrFakt2 := cBrFakt3 := cBrFakt4 := cBrFakt5 := Space( 10 )
         PRIVATE dDatFakt1 := dDatFakt2 := dDatFakt3 := dDatFakt4 := dDatFakt5 := CToD( "" )
         PRIVATE cRj1 := ""
         PRIVATE cRj2 := ""
      ENDIF

      PRIVATE dDatVal := CToD( "" )  // inicijalizuj datum valute
      PRIVATE cIdVrsteP := "  " // i vrstu placanja

      DO WHILE cIdVD == IdVD .AND. cBrDok == BrDok .AND. !Eof()

         lDatFakt := .F.

         SELECT koncij
         GO TOP

         IF finmat->idvd $ "14#94#96#95"
            SEEK finmat->idkonto2
         ELSE
            SEEK finmat->idkonto
         ENDIF

         SELECT roba
         HSEEK finmat->idroba

         SELECT trfp
         GO TOP
         SEEK cIdVD + koncij->shema

         DO WHILE !Eof() .AND. !Empty( cBrNalF ) .AND. field->idvd == cIDVD  .AND. field->shema == koncij->shema

            lDatFakt := .F.
            cStavka := Id

            SELECT finmat
            nIz := &cStavka

            SELECT trfp

            IF !Empty( trfp->idtarifa ) .AND. trfp->idtarifa <> finmat->idtarifa
               // ako u {ifrarniku parametara postoji tarifa prenosi po tarifama
               nIz := 0
            ENDIF

            IF Empty( trfp->idtarifa ) .AND. roba->tip $ "U"

               nIz := 0 // roba tipa u,t
            ENDIF

            // iskoristeno u slucaju RN, gdje se za kontiranje stavke
            // 901-999 koriste sa tarifom XXXXXX
            IF finmat->idtarifa == "XXXXXX" .AND. trfp->idtarifa <> finmat->idtarifa
               nIz := 0
            ENDIF

            IF nIz <> 0

               IF lPoRj // ako je iznos elementa <> 0, dodaj stavku u fpripr
                  IF TRFP->porj = "D"
                     cIdRj := KONCIJ->idrj
                  ELSEIF TRFP->porj = "S"
                     cIdRj := KONCIJ->sidrj
                  ELSE
                     cIdRj := ""
                  ENDIF
               ENDIF

               SELECT fin_pripr

               IF trfp->znak == "-"
                  nIz := -nIz
               ENDIF

               IF "#DF#" $ ( trfp->naz )
                  lDatFakt := .T.
               ENDIF

               dDFDok := CToD( "" )
               IF lDatFakt
                  dDFDok := finmat->DatFaktP
               ENDIF

               IF gBaznaV == "P"
                  //nIz := ROUND7( nIz, Right( trfp->naz, 2 ) )
                  //nIz2 := ROUND7( nIz * Kurs( dDFDok, "P", "D" ), Right( trfp->naz, 2 ) )
                  nIz := nIz
                  nIz2 :=  nIz * Kurs( dDFDok, "P", "D" )

               ELSE
                  //nIz2 := ROUND7( nIz, Right( trfp->naz, 2 ) )
                  // nIz := ROUND7( nIz2 * Kurs( dDFDok, "D", "P" ), Right( trfp->naz, 2 ) )
                  nIz2 := nIz
                  nIz := nIz2 * Kurs( dDFDok, "D", "P" )

               ENDIF

               IF "IDKONTO" == PadR( trfp->IdKonto, 7 )
                  cIdKonto := finmat->idkonto
               ELSEIF "IDKONT2" == PadR( trfp->IdKonto, 7 )
                  cIdKonto := finmat->idkonto2
               ELSE
                  cIdKonto := trfp->Idkonto
               ENDIF

               IF lPrvoDzok
                  cPomFK777 := Trim( gFunKon1 )
                  cIdkonto := StrTran( cidkonto, "F1", &cPomFK777 )
                  cPomFK777 := Trim( gFunKon2 )
                  cIdkonto := StrTran( cidkonto, "F2", &cPomFK777 )

                  cIdkonto := StrTran( cidkonto, "A1", Right( Trim( finmat->idkonto ), 1 ) )
                  cIdkonto := StrTran( cidkonto, "A2", Right( Trim( finmat->idkonto ), 2 ) )
                  cIdkonto := StrTran( cidkonto, "B1", Right( Trim( finmat->idkonto2 ), 1 ) )
                  cIdkonto := StrTran( cidkonto, "B2", Right( Trim( finmat->idkonto2 ), 2 ) )
               ENDIF

               IF ( cIdkonto = 'KK' )  .OR.  ( cIdkonto = 'KP' )  .OR. ( cIdkonto = 'KO' ) // pocinje sa KK, KO, KP
                  IF Right( Trim( cIdkonto ), 3 ) == "(2)"  // trazi idkonto2
                     SELECT koncij
                     nRecno := RecNo()
                     SEEK finmat->idkonto2
                     cIdkonto := StrTran( cIdkonto, "(2)", "" )
                     cIdkonto := koncij->( &cIdkonto )
                     SELECT koncij
                     GO nRecNo
                     // vrati se na glavni konto
                     SELECT fin_pripr
                     // finansije, priprema
                  ELSEIF Right( Trim( cIdkonto ), 3 ) == "(1)"  // trazi idkonto
                     SELECT koncij
                     nRecNo := RecNo()
                     SEEK finmat->idkonto
                     cIdkonto := StrTran( cIdkonto, "(1)", "" )
                     cIdkonto := koncij->( &cIdkonto )
                     SELECT koncij
                     GO nRecNo
                     // vrati se na glavni konto
                     SELECT fin_pripr
                     // finansije, priprema
                  ELSE
                     cIdkonto := koncij->( &cIdkonto )
                  ENDIF

               ELSEIF !lPrvoDzok
                  cPomFK777 := Trim( gFunKon1 )
                  cIdkonto := StrTran( cidkonto, "F1", &cPomFK777 )
                  cPomFK777 := Trim( gFunKon2 )
                  cIdkonto := StrTran( cidkonto, "F2", &cPomFK777 )

                  cIdkonto := StrTran( cidkonto, "A1", Right( Trim( finmat->idkonto ), 1 ) )
                  cIdkonto := StrTran( cidkonto, "A2", Right( Trim( finmat->idkonto ), 2 ) )
                  cIdkonto := StrTran( cidkonto, "B1", Right( Trim( finmat->idkonto2 ), 1 ) )
                  cIdkonto := StrTran( cidkonto, "B2", Right( Trim( finmat->idkonto2 ), 2 ) )
               ENDIF

               IF ValType( cIdKonto ) != "C"
                  cIdKonto := Replicate( "X", 7 )
               ENDIF
               IF ValType( cKonto1 ) != "C"
                  cKonto1 := Space( 7 )
               ENDIF
               IF ValType( cKonto2 ) != "C"
                  cKonto2 := Space( 7 )
               ENDIF
               IF ValType( cKonto3 ) != "C"
                  cKonto3 := Space( 7 )
               ENDIF

               cIdkonto := StrTran( cIdkonto, "?1", Trim( cKonto1 ) )
               cIdkonto := StrTran( cIdkonto, "?2", Trim( cKonto2 ) )
               cIdkonto := StrTran( cIdkonto, "?3", Trim( cKonto3 ) )

               cIdkonto := PadR( cIdkonto, 7 )
               cBrDok := Space( 8 )
               dDatDok := finmat->datdok

               IF trfp->Dokument == "R"
                  // radni nalog
                  cBrDok := finmat->idZaduz2
               ELSEIF trfp->Dokument == "1"
                  cBrDok := finmat->brdok
               ELSEIF trfp->Dokument == "2"
                  cBrDok := finmat->brfaktp
                  dDatDok := finmat->datfaktp
               ELSEIF trfp->Dokument == "3"
                  dDatDok := dDatNal
               ELSEIF trfp->Dokument == "9"

                  dDatDok := dDatMax // koristi se za vise kalkulacija
               ENDIF

               cIdPartner := Space( 6 )
               IF trfp->Partner == "1"  // stavi Partnera
                  cIdPartner := finmat->IdPartner
               ELSEIF trfp->Partner == "2"   // stavi  Lice koje se zaduzuje
                  cIdpartner := finmat->IdZaduz
               ELSEIF trfp->Partner == "3"   // stavi  Lice koje se zaduz2
                  cIdpartner := finmat->IdZaduz2
               ELSEIF trfp->Partner == "A"
                  cIdpartner := cPartner1
                  IF !Empty( dDatFakt1 )
                     DatDok := dDatFakt1
                  ENDIF
                  IF !Empty( cBrFakt1 )
                     cBrDok := cBrFakt1
                  ENDIF
               ELSEIF trfp->Partner == "B"
                  cIdpartner := cPartner2
                  IF !Empty( dDatFakt2 )
                     dDatDok := dDatFakt2
                  ENDIF
                  IF !Empty( cBrFakt2 )
                     cBrDok := cBrFakt2
                  ENDIF
               ELSEIF trfp->Partner == "C"
                  cIdpartner := cPartner3
                  IF !Empty( dDatFakt3 )
                     dDatDok := dDatFakt3
                  ENDIF
                  IF !Empty( cBrFakt3 )
                     cBrDok := cBrFakt3
                  ENDIF
               ELSEIF trfp->Partner == "D"
                  cIdpartner := cPartner4
                  IF !Empty( dDatFakt4 )
                     dDatDok := dDatFakt4
                  ENDIF
                  IF !Empty( cBrFakt4 )
                     cBrDok := cBrFakt4
                  ENDIF
               ELSEIF trfp->Partner == "E"
                  cIdpartner := cPartner5
                  IF !Empty( dDatFakt5 )
                     dDatDok := dDatFakt5
                  ENDIF
                  IF !Empty( cBrFakt5 )
                     cBrDok := cBrFakt5
                  ENDIF
               ELSEIF trfp->Partner == "O"   // stavi  banku
                  cIdpartner := KONCIJ->banka
               ENDIF

               fExist := .F.
               SEEK finmat->IdFirma + cIdvn + cBrNalF

               my_flock()
               IF Found()
                  fExist := .F.
                  DO WHILE !Eof() .AND. finmat->idfirma + cidvn + cBrNalF == IdFirma + idvn + BrNal
                     IF IdKonto == cIdKonto .AND. IdPartner == cIdPartner .AND. ;
                           trfp->d_p == d_p  .AND. idtipdok == finmat->idvd .AND. ;
                           PadR( brdok, 10 ) == PadR( cBrDok, 10 ) .AND. datdok == dDatDok .AND. ;
                           IF( lPoRj, Trim( idrj ) == Trim( cIdRj ), .T. )
                        // provjeriti da li se vec nalazi stavka koju dodajemo
                        fExist := .T.
                        EXIT
                     ENDIF
                     SKIP
                  ENDDO

                  IF !fExist
                     // fin_pripr
                     SEEK finmat->idfirma + cIdVN + cBrNalF + "ZZZZ"
                     SKIP -1
                     IF fin_pripr->( idfirma + idvn + brnal ) == finmat->idfirma + cIdVN + cBrNalF
                        nRbr := fin_pripr->Rbr + 1
                     ELSE
                        nRbr := 1
                     ENDIF
                     APPEND BLANK
                  ENDIF
               ELSE
                  // fin_pripr
                  SEEK finmat->idfirma + cIdVN + cBrNalF + "ZZZZ"
                  SKIP -1
                  IF idfirma + idvn + brnal == finmat->idfirma + cIdVN + cBrNalF
                     nRbr := Rbr + 1
                  ELSE
                     nRbr := 1
                  ENDIF
                  APPEND BLANK
               ENDIF

               REPLACE iznosDEM WITH iznosDEM + nIz
               REPLACE iznosBHD WITH iznosBHD + nIz2
               REPLACE idKonto  WITH cIdKonto
               REPLACE IdPartner  WITH cIdPartner
               REPLACE D_P      WITH trfp->d_P

               REPLACE idFirma  WITH finmat->idfirma, ;
                  IdVN     WITH cIdVN, ;
                  BrNal    WITH cBrNalF, ;
                  IdTipDok WITH finmat->IdVD, ;
                  BrDok    WITH cBrDok

               REPLACE DatDok   WITH dDatDok
               REPLACE opis     WITH trfp->naz

               IF Left( Right( trfp->naz, 2 ), 1 ) $ ".;"  // nacin zaokruzenja
                  REPLACE opis WITH Left( trfp->naz, Len( trfp->naz ) -2 )
               ENDIF

               IF "#V#" $  trfp->naz  // stavi datum valutiranja
                  REPLACE datval WITH dDatVal
                  REPLACE opis WITH StrTran( trfp->naz, "#V#", "" )
                  IF lVrsteP
                     REPLACE k4 WITH cIdVrsteP
                  ENDIF
               ENDIF

               // kontiraj radnu jedinicu
               IF "#RJ1#" $  trfp->naz  // stavi datum valutiranja
                  REPLACE IdRJ WITH cRj1, opis WITH StrTran( trfp->naz, "#RJ1#", "" )
               ENDIF

               IF "#RJ2#" $  trfp->naz  // stavi datum valutiranja
                  REPLACE IdRJ WITH cRj2, opis WITH StrTran( trfp->naz, "#RJ2#", "" )
               ENDIF

               IF lPoRj
                  REPLACE IdRJ WITH cIdRj
               ENDIF

               IF !fExist
                  REPLACE Rbr  WITH nRbr // fin_pripr
               ENDIF
               my_unlock()
            ENDIF // nIz <>0

            SELECT trfp
            SKIP
         ENDDO // trfp->id==cIDVD

/*
         IF gAMat <> "0"     // za materijalni nalog

            SELECT trmp
            HSEEK cIdVD

            DO WHILE !Empty( cBrNalM ) .AND. trmp->id == cIdVD .AND. !Eof()

               cIznos := naz

               // mpripr
               SELECT mpripr

               cIdPartner := ""
               IF trmp->Partner == "1"  // stavi Partnera
                  cIdpartner := finmat->IdPartner
               ENDIF

               cIdzaduz := ""
               IF trmp->Zaduz == "1"
                  cIdKonto := finmat->idkonto
                  cIdZaduz := finmat->idzaduz
               ELSEIF trmp->Zaduz == "2"
                  cIdKonto := finmat->idkonto2
                  cIdZaduz := finmat->idzaduz2
               ENDIF

               cBrDok := ""
               dDatDok := finmat->Datdok
               IF trmp->dokument == "1"
                  cBrDok := finmat->Brdok
               ELSEIF trmp->dokument == "2"
                  cBrDok := finmat->BrFaktP
                  dDatDok := finmat->DatFaktP
               ENDIF
               nKol := finmat->Kolicina
               nIz := finmat->&cIznos

               IF Trim( cIznos ) == "GKV"
                  nKol := finmat->Gkol
               ELSEIF Trim( cIznos ) == "GKV2"
                  nKol := finmat->GKol2
               ELSEIF Trim( cIznos ) == "MARZA2"
                  nKol := finmat->( Gkol + GKol2 )
               ELSEIF  Trim( cIznos ) == "RABATV"
                  nKol := 0
               ENDIF

               IF trmp->znak == "-"
                  nIz := -nIz
                  nKol := -nKol
               ENDIF

               nIz := Round( nIz, 2 )

               IF nIz == 0
                  SELECT trmp
                  SKIP
                  LOOP
               ENDIF

               GO BOTTOM
               nRbr2 := Val( rbr ) + 1
               APPEND BLANK

               REPLACE IdFirma   WITH finmat->IdFirma, ; // mpripr
               BrNal     WITH cBrNalM, ;
                  IdVN      WITH cIdVN, ;
                  IdPartner WITH cIdPartner, ;
                  IdRoba    WITH finmat->idroba, ;
                  Kolicina  WITH nKol, ;
                  IdKonto   WITH cIdKonto, ;
                  IdZaduz   WITH cIdZaduz, ;
                  IdTipDok  WITH finmat->IdVD, ;
                  BrDok     WITH cBrDok, ;
                  DatDok    WITH dDatDok, ;
                  Rbr       WITH Str( nRbr2, 4 ), ;
                  IdPartner WITH cIdPartner, ;
                  Iznos    WITH nIz, ;
                  Iznos2   WITH Round( nIz, 2 ), ;
                  Cijena   WITH iif( nKol <> 0, Iznos / nKol, 0 ), ;
                  U_I      WITH trmp->u_i, ;
                  D_P      WITH trmp->u_i


               SELECT trmp
               SKIP
            ENDDO // trmp->id = cIDVD

         ENDIF    // za materijalni nalog
*/

         SELECT finmat
         SKIP
      ENDDO
   ENDDO

   SELECT finmat
   SKIP -1

   IF lAFin .OR. lAFin2
      SELECT fin_pripr
      GO TOP
      SEEK finmat->idfirma + cIdVN + cBrNalF
      my_flock()
      IF Found()
         DO WHILE !Eof() .AND. IDFIRMA + IDVN + BRNAL == finmat->idfirma + cIdVN + cBrNalF
            cPom := Right( opis, 1 )
            // na desnu stranu opisa stavim npr "ZADUZ MAGACIN          0"
            // onda ce izvrsiti zaokruzenje na 0 decimalnih mjesta
            IF cPom $ "0125"
               nLen := Len( Trim( opis ) )
               REPLACE opis WITH Left( Trim( opis ), nLen - 1 )
               IF cPom = "5"  // zaokruzenje na 0.5 DEM
                  REPLACE iznosbhd WITH round2( iznosbhd, 2 )
                  REPLACE iznosdem WITH round2( iznosdem, 2 )
               ELSE
                  REPLACE iznosbhd WITH Round( iznosbhd, Min( Val( cPom ), 2 ) )
                  REPLACE iznosdem WITH Round( iznosdem, Min( Val( cPom ), 2 ) )
               ENDIF
            ENDIF
            SKIP
         ENDDO
      ENDIF
      my_unlock()
   ENDIF

   MsgC()

   IF !lViseKalk // ako je vise kalkulacija ne zatvaraj tabele
      my_close_all_dbf()
      RETURN .T.
   ENDIF

   RETURN .T.



// --------------------------------
// validacija broja naloga
// --------------------------------
STATIC FUNCTION __val_nalog( cNalog )

   LOCAL lRet := .T.
   LOCAL cTmp
   LOCAL cChar
   LOCAL i

   cTmp := Right( cNalog, 4 )

   // vidi jesu li sve brojevi
   FOR i := 1 TO Len( cTmp )

      cChar := SubStr( cTmp, i, 1 )

      IF cChar $ "0123456789"
         LOOP
      ELSE
         lRet := .F.
         EXIT
      ENDIF

   NEXT

   RETURN lRet



/* Konto(nBroj, cDef, cTekst)
 *   param: nBroj - koju varijablu punimo (1-cKonto1,2-cKonto2,3-cKonto3)
 *   param: cDef - default tj.ponudjeni tekst
 *   param: cTekst - opis podatka koji se unosi
 *     Edit proizvoljnog teksta u varijablu ckonto1,ckonto2 ili ckonto3 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  return 0
 */

FUNCTION Konto( nBroj, cDef, cTekst )

   PRIVATE GetList := {}

   IF ( nBroj == 1 .AND. Len( cKonto1 ) <> 0 ) .OR. ;
         ( nBroj == 2 .AND. Len( cKonto2 ) <> 0 ) .OR. ;
         ( nBroj == 3 .AND. Len( cKonto3 ) <> 0 )
      RETURN 0
   ENDIF

   Box(, 2, 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY cTekst
   IF nBroj == 1
      cKonto1 := cDef
      @ Row(), Col() + 1 GET cKonto1
   ELSEIF nBroj == 2
      cKonto2 := cDef
      @ Row(), Col() + 1 GET cKonto2
   ELSE
      cKonto3 := cDef
      @ Row(), Col() + 1 GET cKonto3
   ENDIF
   READ
   BoxC()

   RETURN 0


// Primjer SetKonto(1, IsInoDob(finmat->IdPartner) , "30", "31")
//
FUNCTION SetKonto( nBroj, lValue, cTrue, cFalse )

   LOCAL cPom

   IF ( nBroj == 1 .AND. Len( cKonto1 ) <> 0 ) .OR. ;
         ( nBroj == 2 .AND. Len( cKonto2 ) <> 0 ) .OR. ;
         ( nBroj == 3 .AND. Len( cKonto3 ) <> 0 )
      RETURN 0
   ENDIF

   IF lValue
      cPom := cTrue
   ELSE
      cPom := cFalse
   ENDIF

   IF nBroj == 1
      cKonto1 := cPom
   ELSEIF nBroj == 2
      cKonto2 := cPom
   ELSE
      cKonto3 := cPom
   ENDIF

   RETURN 0




/* RJ(nBroj,cDef,cTekst)
 *   param: nBroj - koju varijablu punimo (1-cRj1,2-cRj2)
 *   param: cDef - default tj.ponudjeni tekst
 *   param: cTekst - opis podatka koji se unosi
 *     Edit proizvoljnog teksta u varijablu cRj1 ili cRj2 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

FUNCTION RJ( nBroj, cDef, cTekst )

   PRIVATE GetList := {}

   IF ( nBroj == 1 .AND. Len( cRJ1 ) <> 0 ) .OR. ( nBroj == 2 .AND. Len( cRj2 ) <> 0 )
      RETURN 0
   ENDIF

   Box(, 2, 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY cTekst
   IF nBroj == 1
      cRJ1 := cdef
      @ Row(), Col() + 1 GET cRj1
   ELSEIF nBroj == 2
      cRJ2 := cdef
      @ Row(), Col() + 1 GET cRj2
   ENDIF
   READ
   BoxC()

   RETURN 0





FUNCTION kalk_datval()
   RETURN datval()


/*
   setovanje datuma valutiranja pri kontiranju
   treba da setuje privatnu varijablu DatVal

    ova funkcija treba setovati PRIVATE dDatVal

*/

FUNCTION DatVal()

   LOCAL _uvecaj := 15

   // LOCAL _rec
   LOCAL nRokPartner

   PRIVATE GetList := {}


   PushWA()

   IF find_kalk_doks2_by_broj_dokumenta( finmat->idfirma, finmat->idvd, finmat->brdok )
      dDatVal := field->datval
   ELSE
      dDatVal := CToD( "" )
   ENDIF

   // IF lVrsteP
   // cIdVrsteP := k2
   // ENDIF

   dDatVal := fix_dat_var( dDatVal, .T. )


   IF Empty( dDatVal )


      //IF kalk_imp_autom() // osloni se na rok placanja
         nRokPartner := IzSifkPartn( "ROKP", finmat->idpartner, .T. )
         IF nRokPartner != NIL
            _uvecaj := nRokPartner
         ENDIF
         dDatVal := finmat->datfaktp + _uvecaj

/*
      ELSE

         Box(, 3, 60 )

         SET CURSOR ON
         @ m_x + 1, m_y + 2 SAY "Datum dokumenta: "
         ??  finmat->datfaktp
         @ m_x + 2, m_y + 2 SAY "Uvecaj dana    :" GET _uvecaj PICT "999"
         @ m_x + 3, m_y + 2 SAY "Valuta         :" GET dDatVal WHEN {|| dDatVal := finmat->datfaktp + _uvecaj, .T. }

         // IF lVrsteP .AND. Empty( cIdVrsteP )
         // @ m_x + 4, m_y + 2 SAY "Sifra vrste placanja:" GET cIdVrsteP PICT "@!"
         // ENDIF

         READ
         BoxC()

      ENDIF
*/
   ENDIF

/*
      IF !find_kalk_doks2_by_broj_dokumenta( finmat->idfirma, finmat->idvd, finmat->brdok )
         APPEND BLANK // ovo se moze desiti ako je neko mjenjao dokumenta u KALK
         _rec := dbf_get_rec()
         _rec[ "idfirma" ] := finmat->idfirma
         _rec[ "idvd" ] := finmat->idvd
         _rec[ "brdok" ] := finmat->brdok
      ELSE
         _rec := dbf_get_rec()
      ENDIF

      _rec[ "datval" ] := dDatVal

      IF lVrsteP
         _rec[ "k2" ] := cIdVrsteP
      ENDIF

      update_rec_server_and_dbf( "kalk_doks2", _rec, 1, "FULL" )

*/

   PopWa()

   RETURN 0 // funkcija se koristi u kontiranju i mora vratiti 0





/* Partner(nBroj,cDef,cTekst,lFaktura,dp)
 *   param: nBroj - 1 znaci da se sifrom partnera puni varijabla cPartner1
 *   param: cDef - default tj.ponudjeni tekst
 *   param: cTekst - opis podatka koji se unosi u varijablu cPartner1
 *   param: lFaktura - .t. i ako je npr.nBroj==1 filuju se i varijable cBrFakt1 i dDatFakt1 koje cuvaju broj i datum fakture, .f. - ne edituju se ove varijable sto je i default vrijednost
 *   param: dp - duzina sifre partnera, ako se ne navede default vrijednost=6
 *     Edit sifre partnera u varijablu cPartner1...ili...cPartner5 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  return 0
 */

FUNCTION Partner( nBroj, cDef, cTekst, lFaktura, dp )

   IF lFaktura == NIL; lFaktura := .F. ; ENDIF
   IF dp == NIL; dp := 6; ENDIF
   IF cDef == NIL; cDef := ""; ENDIF
   IF cTekst == NIL; cTekst := "Sifra partnera " + AllTrim( Str( nBroj ) ); ENDIF
   PRIVATE GetList := {}

   IF ( nBroj == 1 .AND. Len( cPartner1 ) <> 0 ) .OR. ;
         ( nBroj == 2 .AND. Len( cPartner2 ) <> 0 ) .OR. ;
         ( nBroj == 3 .AND. Len( cPartner3 ) <> 0 ) .OR. ;
         ( nBroj == 4 .AND. Len( cPartner4 ) <> 0 ) .OR. ;
         ( nBroj == 5 .AND. Len( cPartner5 ) <> 0 )
      RETURN 0
   ENDIF

   Box(, 2 + IF( lFaktura, 2, 0 ), 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY cTekst
   IF nBroj == 1
      cPartner1 := PadR( cdef, dp )
      @ Row(), Col() + 1 GET cPartner1
      IF lFaktura
         @ m_x + 2, m_y + 2 SAY "Broj fakture " GET cBrFakt1
         @ m_x + 3, m_y + 2 SAY "Datum fakture" GET dDatFakt1
      ENDIF
   ELSEIF nBroj == 2
      cPartner2 := PadR( cdef, dp )
      @ Row(), Col() + 1 GET cPartner2
      IF lFaktura
         @ m_x + 2, m_y + 2 SAY "Broj fakture " GET cBrFakt2
         @ m_x + 3, m_y + 2 SAY "Datum fakture" GET dDatFakt2
      ENDIF
   ELSEIF nBroj == 3
      cPartner3 := PadR( cdef, dp )
      @ Row(), Col() + 1 GET cPartner3
      IF lFaktura
         @ m_x + 2, m_y + 2 SAY "Broj fakture " GET cBrFakt3
         @ m_x + 3, m_y + 2 SAY "Datum fakture" GET dDatFakt3
      ENDIF
   ELSEIF nBroj == 4
      cPartner4 := PadR( cdef, dp )
      @ Row(), Col() + 1 GET cPartner4
      IF lFaktura
         @ m_x + 2, m_y + 2 SAY "Broj fakture " GET cBrFakt4
         @ m_x + 3, m_y + 2 SAY "Datum fakture" GET dDatFakt4
      ENDIF
   ELSE
      cPartner5 := PadR( cdef, dp )
      @ Row(), Col() + 1 GET cPartner5
      IF lFaktura
         @ m_x + 2, m_y + 2 SAY "Broj fakture " GET cBrFakt5
         @ m_x + 3, m_y + 2 SAY "Datum fakture" GET dDatFakt5
      ENDIF
   ENDIF
   READ
   BoxC()

   RETURN 0




FUNCTION kalk_set_doks_total_fields( nNv, nVpv, nMpv, nRabat )

   IF field->mu_i = "1"
      nNV += field->nc * ( field->kolicina - field->gkolicina - field->gkolicin2 )
      nVPV += field->vpc * ( field->kolicina - field->gkolicina - field->gkolicin2 )
   ELSEIF mu_i = "P"
      nNV += field->nc * ( field->kolicina - field->gkolicina - field->gkolicin2 )
      nVPV += field->vpc * ( field->kolicina - field->gkolicina - field->gkolicin2 )
   ELSEIF mu_i = "3"
      nVPV += field->vpc * ( field->kolicina - field->gkolicina - field->gkolicin2 )
   ELSEIF mu_i == "5"
      nNV -= field->nc * ( field->kolicina )
      nVPV -= field->vpc * ( field->kolicina )
      nRabat += field->vpc * ( field->rabatv / 100 ) * field->kolicina
   ENDIF

   IF field->pu_i == "1"
      IF Empty( field->mu_i )
         nNV += field->nc * field->kolicina
      ENDIF
      nMPV += field->mpcsapp * field->kolicina
   ELSEIF field->pu_i == "P"
      IF Empty( field->mu_i )
         nNV += field->nc * field->kolicina
      ENDIF
      nMPV += field->mpcsapp * field->kolicina
   ELSEIF field->pu_i == "5"
      IF Empty( field->mu_i )
         nNV -= field->nc * field->kolicina
      ENDIF
      nMPV -= field->mpcsapp * field->kolicina
   ELSEIF field->pu_i == "I"
      nMPV -= field->mpcsapp * field->gkolicin2
      nNV -= field->nc * field->gkolicin2
   ELSEIF pu_i == "3"
      nMPV += field->mpcsapp * field->kolicina
   ENDIF

   RETURN .T.


/*
 *     Ako se radi o privremenom rezimu obrade KALK dokumenata setuju se vrijednosti parametara gCijene i kalk_metoda_nc() na vrijednosti u dvoclanom nizu aRezim


FUNCTION IspitajRezim()

   IF !Empty( aRezim )
    --  gCijene   = aRezim[ 1 ]
      kalk_metoda_nc() = aRezim[ 2 ]
   ENDIF

   RETURN .T.

 */



FUNCTION kalk_open_tabele_za_kontiranje()

   O_FINMAT
   O_KONTO
   O_PARTN
   O_TDOK
   O_ROBA
   O_TARIFA

   RETURN .T.




FUNCTION predisp()

   LOCAL _ret := .F.

   IF field->k1 == "P"
      _ret := .T.
   ENDIF

   RETURN _ret






// Ako je dan < 10
// return { 01.predhodni_mjesec , zadnji.predhodni_mjesec}
// else
// return { 01.tekuci_mjesec, danasnji dan }

FUNCTION kalk_rpt_datumski_interval( dToday )

   LOCAL nDay, nFDOm
   LOCAL dDatOd, dDatDo

   nDay := Day( dToday )
   nFDOm := BoM( dToday )

   IF nDay < 10
      // prvi dan u tekucem mjesecu - 1
      dDatDo := nFDom - 1
      // prvi dan u proslom mjesecu
      dDatOd := BoM( dDatDo )

   ELSE
      dDatOd := nFDom
      dDatDo := dToday
   ENDIF

   RETURN { dDatOd, dDatDo }
