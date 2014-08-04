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


#include "kalk.ch"

STATIC dDatMax


// -----------------------------------------------------------------------
// kontiranje naloga
//
// fAuto - .t. automatski se odrjedjuje broj naloga koji se formira,
// .f. getuje se broj formiranog naloga - default vrijednost
// lAGen - automatsko generisanje
// lViseKalk - vise kalkulacija
// cNalog - broj naloga koji ce se uzeti, ako je EMPTY() ne uzima se !
// -----------------------------------------------------------------------
FUNCTION kalk_kontiranje_naloga( fAuto, lAGen, lViseKalk, cNalog, auto_brojac )

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

   IF ( cNalog == NIL )
      cNalog := ""
   ENDIF

   IF ( auto_brojac == NIL )
      auto_brojac := .T.
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
      O_KONCIJ
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

   IF fAuto == NIL
      fAuto := .F.
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

   lAFin2 := ( !fAuto .AND. gAFin <> "0" )
   lAMat := ( fAuto .AND. gAMat == "D" )

   IF lAMat .AND. f18_use_module( "mat" )
      Beep( 1 )
      lAMat := Pitanje(, "Formirati MAT nalog?", "D" ) == "D"
      O_TRMP
   ENDIF

   lAMat2 := ( !fAuto .AND. gAMat <> "0" )

   cBrNalF := ""
   cBrNalM := ""

   IF lAFin .OR. lAFin2

      O_FIN_PRIPR
      SET ORDER TO TAG "1"
      GO TOP

      O_NALOG
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

         IF auto_brojac
            cBrNalF := fin_novi_broj_dokumenta( finmat->idfirma, cIdVn )
         ELSE
            cBrNalF := fin_prazan_broj_naloga()
         ENDIF

      ELSE
         // ako je zadat broj naloga taj i uzmi...
         cBrNalF := cNalog
      ENDIF

   ENDIF

   SELECT finmat
   GO TOP

   dDatNal := datdok

   IF lAGen == .F.

      Box( "brn?", 5, 55 )

      SET CURSOR ON

      IF fAuto
         IF !lAFin
            cBrNalF := ""
         ELSE
            @ m_x + 1, m_y + 2  SAY "Broj naloga u FIN  " + finmat->idfirma + " - " + cidvn + " - " + cBrNalF
         ENDIF

         IF !lAMat
            cBrBalM := ""
         ELSE
            IF idvd <> "24" // kalkulacija usluge
               @ m_x + 2, m_y + 2 SAY "Broj naloga u MAT  " + finmat->idfirma + " - " + cidvn + " - " + cBrNalM
            ENDIF
         ENDIF

         @ m_x + 4, m_y + 2 SAY "Datum naloga: "

         ?? dDatNal

         IF lAFin .OR. lAMat
            Inkey( 0 )
         ENDIF

      ELSE
         IF lAFin2
            @ m_x + 1, m_y + 2 SAY "Broj naloga u FIN  " + finmat->idfirma + " - " + cidvn + " -" GET cBrNalF
         ENDIF

         IF idvd <> "24" .AND. lAMat2
            @ m_x + 2, m_y + 2 SAY "Broj naloga u MAT  " + finmat->idfirma + " - " + cidvn + " -" GET cBrNalM
         ENDIF

         @ m_x + 5, m_y + 2 SAY "(ako je broj naloga prazan - ne vrsi se kontiranje)"
         READ
         ESC_BCR
      ENDIF

      BoxC()

   ENDIF

   nRbr := 0
   nRbr2 := 0

   MsgO( "Prenos KALK -> FIN" )

   SELECT finmat
   PRIVATE cKonto1 := NIL

   DO WHILE !Eof()

      // datoteka finmat
      cIDVD := IdVD
      cBrDok := BrDok

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

      PRIVATE dDatVal := CToD( "" )
      // inicijalizuj datum valute
      PRIVATE cIdVrsteP := "  "
      // i vrstu placanja

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
         hseek finmat->idroba

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
               // roba tipa u,t
               nIz := 0
            ENDIF

            // iskoristeno u slucaju RN, gdje se za kontiranje stavke
            // 901-999 koriste sa tarifom XXXXXX
            IF finmat->idtarifa == "XXXXXX" .AND. trfp->idtarifa <> finmat->idtarifa
               nIz := 0
            ENDIF

            IF nIz <> 0

               // ako je iznos elementa <> 0, dodaj stavku u fpripr
               IF lPoRj
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
                  nIz := ROUND7( nIz, Right( trfp->naz, 2 ) )
                  nIz2 := ROUND7( nIz * Kurs( dDFDok, "P", "D" ), Right( trfp->naz, 2 ) )
               ELSE
                  nIz2 := ROUND7( nIz, Right( trfp->naz, 2 ) )
                  nIz := ROUND7( nIz2 * Kurs( dDFDok, "D", "P" ), Right( trfp->naz, 2 ) )
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

               IF ( cIdkonto = 'KK' )  .OR.  ( cIdkonto = 'KP' )  .OR. ( cIdkonto = 'KO' )
                  IF Right( Trim( cIdkonto ), 3 ) == "(2)"  // gonjaj idkonto2
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
                  ELSEIF Right( Trim( cIdkonto ), 3 ) == "(1)"  // gonjaj idkonto
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

               cIdkonto := StrTran( cidkonto, "?1", Trim( ckonto1 ) )
               cIdkonto := StrTran( cidkonto, "?2", Trim( ckonto2 ) )
               cIdkonto := StrTran( cidkonto, "?3", Trim( ckonto3 ) )
               cIdkonto := PadR( cidkonto, 7 )
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
                  // koristi se za vise kalkulacija
                  dDatDok := dDatMax
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
               SEEK finmat->IdFirma + cidvn + cBrNalF

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
                     SEEK finmat->idfirma + cIdVN + cBrNalF + "ZZZZ"
                     SKIP -1
                     IF idfirma + idvn + brnal == finmat->idfirma + cIdVN + cBrNalF
                        nRbr := Val( Rbr ) + 1
                     ELSE
                        nRbr := 1
                     ENDIF
                     APPEND BLANK
                  ENDIF
               ELSE
                  SEEK finmat->idfirma + cIdVN + cBrNalF + "ZZZZ"
                  SKIP -1
                  IF idfirma + idvn + brnal == finmat->idfirma + cIdVN + cBrNalF
                     nRbr := Val( Rbr ) + 1
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
                  REPLACE Rbr  WITH Str( nRbr, 4 )
               ENDIF
               my_unlock()
            ENDIF // nIz <>0

            SELECT trfp
            SKIP
         ENDDO // trfp->id==cIDVD

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

               REPLACE IdFirma   WITH finmat->IdFirma, ;
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

   // ako je vise kalkulacija ne zatvaraj tabele
   IF !lViseKalk
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



/*! \fn Konto(nBroj,cDef,cTekst)
 *  \param nBroj - koju varijablu punimo (1-ckonto1,2-ckonto2,3-ckonto3)
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi
 *  \brief Edit proizvoljnog teksta u varijablu ckonto1,ckonto2 ili ckonto3 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

FUNCTION Konto( nBroj, cDef, cTekst )

   PRIVATE GetList := {}

   IF ( nBroj == 1 .AND. Len( ckonto1 ) <> 0 ) .OR. ;
         ( nBroj == 2 .AND. Len( ckonto2 ) <> 0 ) .OR. ;
         ( nBroj == 3 .AND. Len( ckonto3 ) <> 0 )
      RETURN 0
   ENDIF

   Box(, 2, 60 )
   SET CURSOR ON
   @ m_x + 1, m_y + 2 SAY cTekst
   IF nBroj == 1
      ckonto1 := cdef
      @ Row(), Col() + 1 GET cKonto1
   ELSEIF nBroj == 2
      ckonto2 := cdef
      @ Row(), Col() + 1 GET cKonto2
   ELSE
      ckonto3 := cdef
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




/*! \fn RJ(nBroj,cDef,cTekst)
 *  \param nBroj - koju varijablu punimo (1-cRj1,2-cRj2)
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi
 *  \brief Edit proizvoljnog teksta u varijablu cRj1 ili cRj2 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
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





/*! \fn DatVal()
 *  \brief Odredjivanje datuma valute - varijabla dDatVal
 */

FUNCTION DatVal()

   LOCAL _uvecaj := 15
   LOCAL _rec
   PRIVATE GetList := {}

   // uzmi datval iz doks2
   PushWa()

   O_KALK_DOKS2
   SET ORDER TO TAG "1"
   GO TOP
   SEEK finmat->( idfirma + idvd + brdok )

   IF Found()
      dDatVal := field->datval
   ELSE
      dDatVal := CToD( "" )
   ENDIF

   IF lVrsteP
      cIdVrsteP := k2
   ENDIF

   IF !Empty( dDatVal )
      _uvecaj := ( dDatVal - finmat->datfaktp )
   ENDIF

   IF dDatVal == CToD( "" )

      Box(, 3 + iif( lVrsteP .AND. Empty( cIdVrsteP ), 1, 0 ), 60 )

      SET CURSOR ON

      @ m_x + 1, m_y + 2 SAY "Datum dokumenta: "
      ??  finmat->datfaktp

      @ m_x + 2, m_y + 2 SAY "Uvecaj dana    :" GET _uvecaj PICT "999"
      @ m_x + 3, m_y + 2 SAY "Valuta         :" GET dDatVal WHEN {|| dDatVal := finmat->datfaktp + _uvecaj, .T. }

      IF lVrsteP .AND. Empty( cIdVrsteP )
         @ m_x + 4, m_y + 2 SAY "Sifra vrste placanja:" GET cIdVrsteP PICT "@!"
      ENDIF

      READ

      BoxC()

      SELECT kalk_doks2
      GO TOP
      SEEK finmat->( idfirma + idvd + brdok )

      IF !Found()
         APPEND BLANK
         // ovo se moze desiti ako je neko mjenjao dokumenta u KALK
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

   ENDIF

   PopWa()

   RETURN 0





/*! \fn Partner(nBroj,cDef,cTekst,lFaktura,dp)
 *  \param nBroj - 1 znaci da se sifrom partnera puni varijabla cPartner1
 *  \param cDef - default tj.ponudjeni tekst
 *  \param cTekst - opis podatka koji se unosi u varijablu cPartner1
 *  \param lFaktura - .t. i ako je npr.nBroj==1 filuju se i varijable cBrFakt1 i dDatFakt1 koje cuvaju broj i datum fakture, .f. - ne edituju se ove varijable sto je i default vrijednost
 *  \param dp - duzina sifre partnera, ako se ne navede default vrijednost=6
 *  \brief Edit sifre partnera u varijablu cPartner1...ili...cPartner5 ukoliko je izabrana varijabla duzine 0 tj.nije joj vec dodijeljena vrijednost
 *  \return 0
 */

FUNCTION Partner( nBroj, cDef, cTekst, lFaktura, dp )

   // {
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

   RETURN






/*! \fn IspitajRezim()
 *  \brief Ako se radi o privremenom rezimu obrade KALK dokumenata setuju se vrijednosti parametara gCijene i gMetodaNC na vrijednosti u dvoclanom nizu aRezim
 */

FUNCTION IspitajRezim()

   IF !Empty( aRezim )
      gCijene   = aRezim[ 1 ]
      gMetodaNC = aRezim[ 2 ]
   ENDIF

   RETURN





/*! \fn RekapK()
 *  \param fstara - .f. znaci poziv iz tabele pripreme, .t. radi se o azuriranoj kalkulaciji pa se prvo getuje broj dokumenta (cIdFirma,cIdVD,cBrdok)
 *  \brief Pravi rekapitulaciju kalkulacija a ako je ulazni parametar fstara==.t. poziva se i kontiranje dokumenta
 */

FUNCTION RekapK()

   PARAMETERS fStara, cIdFirma, cIdVd, cBrDok, lAuto

   LOCAL fprvi
   LOCAL n1 := n2 := n3 := n4 := n5 := n6 := n7 := n8 := n9 := na := nb := 0
   LOCAL nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := nTotb := 0
   LOCAL nCol1 := nCol2 := nCol3 := 0
   LOCAL _fin_auto_broj := "N"

   // kontira se vise kalkulacija
   LOCAL lViseKalk := .F.
   LOCAL _predispozicija := .F.
   PRIVATE aPorezi

   aPorezi := {}

   IF PCount() == 0
      fstara := .F.
   ENDIF

   IF lAuto == nil
      lAuto := .F.
   ENDIF

   lVoSaTa := .F.

   // prvi prolaz
   fprvi := .T.

   DO WHILE .T.

      _predispozicija := .F.

      close_open_rekap_tables()

      IF fStara
         // otvara se KALK sa aliasom priprema
         SELECT F_KALK
         IF !Used()
            O_SKALK
         ENDIF
      ELSE
         SELECT F_KALK_PRIPR
         IF !Used()
            O_KALK_PRIPR
         ENDIF
      ENDIF

      SELECT finmat
      my_dbf_zap()

      SELECT KALK_PRIPR
      // idfirma+ idvd + brdok+rbr
      SET ORDER TO TAG "1"

      IF fPrvi
         // nisu prosljedjeni parametri
         IF cIdFirma == nil

            cIdFirma := IdFirma
            cIdVD := IdVD
            cBrdok := brdok
            IF Empty( cIdFirma )
               cIdFirma := gFirma
            ENDIF
            lViseKalk := .F.

         ELSE
            // parametri su prosljedjeni RekapK funkciji
            lViseKalk := .T.
         ENDIF
         fPrvi := .F.

      ENDIF

      IF fStara

         IF !lViseKalk

            Box( "", 1, 50 )
            SET CURSOR ON
            @ m_x + 1, m_y + 2 SAY "Dokument broj:"
            IF gNW $ "DX"
               @ m_x + 1, Col() + 2  SAY cIdFirma
            ELSE
               @ m_x + 1, Col() + 2 GET cIdFirma
            ENDIF
            @ m_x + 1, Col() + 1 SAY "-" GET cIdVD
            @ m_x + 1, Col() + 1 SAY "-" GET cBrDok
            READ
            ESC_BCR
            BoxC()
         ENDIF

         hseek cIdFirma + cIdVd + cBrDok

      ELSE
         GO TOP
         cIdFirma := IdFirma
         cIdVD := IdVD
         cBrdok := brdok
      ENDIF

      // potrebno je ispitati da li je predispozicija !
      IF idvd == "80" .AND. !Empty( idkonto2 )
         _predispozicija := .T.
      ENDIF

      EOF CRET

      IF fStara .AND. lAuto == .F.

         // - info o izabranom dokumentu -
         Box( "#DOKUMENT " + cIdFirma + "-" + cIdVd + "-" + cBrDok, 9, 77 )

         cDalje := "D"
         cAutoRav := gAutoRavn

         SELECT PARTN
         HSEEK KALK_PRIPR->IDPARTNER
         SELECT KONTO
         HSEEK KALK_PRIPR->MKONTO
         cPom := naz
         SELECT KONTO
         HSEEK KALK_PRIPR->PKONTO
         SELECT kalk_pripr
         @ m_x + 2, m_y + 2 SAY "DATUM------------>"             COLOR "W+/B"
         @ m_x + 2, Col() + 1 SAY DToC( DATDOK )                   COLOR "N/W"
         @ m_x + 3, m_y + 2 SAY "PARTNER---------->"             COLOR "W+/B"
         @ m_x + 3, Col() + 1 SAY IDPARTNER + "-" + PadR( partn->naz, 20 ) COLOR "N/W"
         @ m_x + 4, m_y + 2 SAY "KONTO MAGACINA--->"             COLOR "W+/B"
         @ m_x + 4, Col() + 1 SAY MKONTO + "-" + PadR( cPom, 49 )       COLOR "N/W"
         @ m_x + 5, m_y + 2 SAY "KONTO PRODAVNICE->"             COLOR "W+/B"
         @ m_x + 5, Col() + 1 SAY PKONTO + "-" + PadR( KONTO->naz, 49 ) COLOR "N/W"
         @ m_x + 7, m_y + 2 SAY "Automatski uravnotezi dokument? (D/N)" GET cAutoRav VALID cAutoRav $ "DN" PICT "@!"
         @ m_x + 8, m_y + 2 SAY "Zelite li kontirati dokument? (D/N)" GET cDalje VALID cDalje $ "DN" PICT "@!"
         @ m_x + 9, m_y + 2 SAY "Automatski broj fin.naloga? (D/N)" GET _fin_auto_broj VALID _fin_auto_broj $ "DN" PICT "@!"

         READ

         BoxC()

         IF LastKey() == K_ESC .OR. cDalje <> "D"
            IF lViseKalk
               EXIT
            ELSE
               LOOP
            ENDIF
         ENDIF
      ENDIF

      IF cIdVd == "24"
         START PRINT CRET
         ?
      ENDIF

      nStr := 0
      nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := nTotb := nTotC := 0
      
      DO WHILE !Eof() .AND. cIdFirma == idfirma .AND. cidvd == idvd

         cBrDok := BrDok
         cIdPartner := IdPartner
         cBrFaktP := BrFaktP
         dDatFaktP := DatFaktP
         cIdKonto := IdKonto
         cIdKonto2 := IdKonto2

         IF cIdVd == "24" .AND. ( PRow() == 0 .OR. PRow() > 55 )
            IF PRow() -gPStranica > 55
               FF
            ENDIF
            P_COND
            ?? "KALK: REKAPITULACIJA NA DAN:", Date()
            @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
         ENDIF

         IF cIdVd == "24"
            ?
            ? "KALKULACIJA BR:",  cIdFirma + "-" + cIdVD + "-" + cBrDok, Space( 2 ), P_TipDok( cIdVD, -2 ), Space( 2 ), "Datum:", DatDok
            SELECT PARTN
            HSEEK cIdPartner
            ?  "KUPAC:", cIdPartner, "-", naz, Space( 5 ), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP
         ENDIF

         SELECT KONTO
         HSEEK cIdKonto

         HSEEK cIdKonto2
         SELECT KALK_PRIPR

         m := ""
         IF cidvd == "24"
            m := "---- -------------- -------------- -------------- -------------- -------------- ---------- ---------- ---------- ---------- ----------"
            P_COND2
            ? m
            IF IsPDV()
               ? "*R. * " + Left( c24T1, 12 ) + " * " + Left( c24T2, 12 ) + " * " + Left( c24T3, 12 ) + " * " + Left( c24T4, 12 ) + " * " + Left( c24T5, 12 ) + " *   FV     *   PDV    *   PDV    *   FV     * PRIHOD  *"
               ? "*Br.* " + Left( c24T6, 12 ) + " * " + Left( c24T7, 12 ) + " * " + Left( c24T8, 12 ) + " * " + Space( 12 ) + " * " + Space( 12 ) + " * BEZ PDV  *   %      *          * SA PDV   *         *"
            ELSE
               ? "*R. * " + Left( c24T1, 12 ) + " * " + Left( c24T2, 12 ) + " * " + Left( c24T3, 12 ) + " * " + Left( c24T4, 12 ) + " * " + Left( c24T5, 12 ) + " *   FV     * POREZ    *  POREZ   *   FV     * PRIHOD  *"
               ? "*Br.* " + Left( c24T6, 12 ) + " * " + Left( c24T7, 12 ) + " * " + Space( 12 ) + " * " + Space( 12 ) + " * " + Space( 12 ) + " * BEZ POR  *   %      *          * SA POR   *         *"
            ENDIF
            ? m
         ENDIF

         IF lVoSaTa
            cIdd := idpartner + idkonto + idkonto2
         ELSE
            cIdd := idpartner + brfaktp + idkonto + idkonto2
         ENDIF

         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdVD == IdVD

            IF cIdVd == "97"
               IF field->tbanktr == "X"
                  SKIP
                  LOOP
               ENDIF
            ENDIF

            IF gMagacin <> "1" .AND. ( !lVoSaTa .AND. idpartner + brfaktp + idkonto + idkonto2 <> cidd .OR. lVoSaTa .AND. idpartner + idkonto + idkonto2 <> cidd )
               SET DEVICE TO SCREEN
               IF ! ( ( idvd $ "16#80" )  .AND. !Empty( idkonto2 )  )
                  IF !idvd $ "24"
                     Beep( 2 )
                     Msg( "Unutar kalkulacije se pojavilo vise dokumenata !", 6 )
                  ENDIF
               ENDIF
               IF cidvd == "24"
                  SET DEVICE TO PRINTER
               ENDIF
            ENDIF

            // iznosi troskova koji se izracunavaju u KTroskovi()
            PRIVATE nPrevoz, nCarDaz, nZavTr, nBankTr, nSpedTr, nMarza, nMarza2

            nFV := FCj * Kolicina

            IF gKalo == "1"
               SKol := Kolicina - GKolicina - GKolicin2
            ELSE
               SKol := Kolicina
            ENDIF

            IF cidvd == "24" .AND. PRow() > 62
               FF
               @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
            ENDIF

            SELECT ROBA
            HSEEK KALK_PRIPR->IdRoba
            SELECT TARIFA
            HSEEK KALK_PRIPR->idtarifa
            SELECT KALK_PRIPR

            IF cIdVd == "24"
               Tarifa( pkonto, idroba, @aPorezi, kalk_pripr->idtarifa )
            ELSE
               Tarifa( pkonto, idroba, @aPorezi )
            ENDIF

            KTroskovi()

            IF cidvd == "24"
               @ PRow() + 1, 0 SAY  Rbr PICTURE "999"
            ENDIF

            IF cidvd == "24"
               nCol1 := PCol() + 6
               @ PRow(), PCol() + 6 SAY n1 := prevoz    PICT picdem
               @ PRow(), PCol() + 5 SAY n2 := banktr    PICT picdem
               @ PRow(), PCol() + 5 SAY n3 := spedtr    PICT picdem
               @ PRow(), PCol() + 5 SAY n4 := cardaz    PICT picdem
               @ PRow(), PCol() + 5 SAY n5 := zavtr     PICT picdem
               @ PRow(), PCol() + 1 SAY n6 := fcj       PICT picdem

               IF IsPDV()
                  @ PRow(), PCol() + 1 SAY tarifa->opp   PICT picproc
               ELSE
                  @ PRow(), PCol() + 1 SAY tarifa->vpp   PICT picproc
               ENDIF

               @ PRow(), PCol() + 1 SAY n7 := nc - fcj    PICT picdem
               @ PRow(), PCol() + 1 SAY n8 := nc        PICT picdem
               @ PRow(), PCol() + 1 SAY n9 := marza     PICT picdem
               @ PRow() + 1, nCol1  SAY nA := mpc       PICT picdem
               @ PRow(), PCol() + 5 SAY nB := mpcsapp PICT picdem
               @ PRow(), PCol() + 5 SAY nJCI := fcj3 PICT picdem
               nTot1 += n1; nTot2 += n2; nTot3 += n3; nTot4 += n4
               nTot5 += n5; nTot6 += n6; nTot7 += n7; nTot8 += n8
               nTot9 += n9; nTotA += na; nTotB += nB; nTotC += nJCI
            ENDIF

            VtPorezi()

            aIPor := RacPorezeMP( aPorezi, mpc, mpcSaPP, nc )

            SELECT finmat
            APPEND BLANK

            REPLACE IdFirma   WITH kalk_PRIPR->IdFirma, ;
               IdKonto   WITH kalk_PRIPR->IdKonto, ;
               IdKonto2  WITH kalk_pripr->IdKonto2, ;
               IdTarifa  WITH kalk_pripr->IdTarifa, ;
               IdPartner WITH kalk_pripr->IdPartner, ;
               IdZaduz   WITH kalk_pripr->IdZaduz, ;
               IdZaduz2  WITH kalk_pripr->IdZaduz2, ;
               BrFaktP   WITH kalk_pripr->BrFaktP, ;
               DatFaktP  WITH kalk_pripr->DatFaktP, ;
               IdVD      WITH kalk_pripr->IdVD, ;
               BrDok     WITH kalk_pripr->BrDok, ;
               DatDok    WITH kalk_pripr->DatDok, ;
               GKV       WITH Round( kalk_PRIPR->( GKolicina * FCJ2 ), gZaokr ), ;   // vrijednost transp.kala
            GKV2      WITH Round( kalk_PRIPR->( GKolicin2 * FCJ2 ), gZaokr )   // vrijednost ostalog kala

            REPLACE Prevoz    WITH Round( kalk_PRIPR->( nPrevoz * SKol ), gZaokr ), ;
               CarDaz    WITH Round( kalk_PRIPR->( nCarDaz * SKol ), gZaokr ), ;
               BankTr    WITH Round( kalk_PRIPR->( nBankTr * SKol ), gZaokr ), ;
               SpedTr    WITH Round( kalk_PRIPR->( nSpedTr * SKol ), gZaokr ), ;
               ZavTr     WITH Round( kalk_PRIPR->( nZavTr * SKol ), gZaokr ), ;
               NV        WITH Round( kalk_PRIPR->( NC * ( Kolicina - GKolicina - GKolicin2 ) ), gZaokr ), ;
               Marza     WITH Round( kalk_PRIPR->( nMarza * ( Kolicina - GKolicina - GKolicin2 ) ), gZaokr ), ;           // marza se ostvaruje nad stvarnom kolicinom
            VPV       WITH Round( kalk_PRIPR->( VPC * ( Kolicina - GKolicina - GKolicin2 ) ), gZaokr )        // vpv se formira nad stvarnom kolicinom


            nPom := kalk_pripr->( RabatV / 100 * VPC * Kolicina )
            nPom := Round( nPom, gZaokr )
            REPLACE RABATV  WITH nPom

            IF IsPDV() .AND.  kalk_pripr->idvd == "24"
               nPom := kalk_pripr->( FCJ3 * Skol )
               nPom := Round( nPom, gZaokr )
               REPLACE VPVSAP WITH nPom
            ELSE
               nPom := kalk_pripr->( VPCSaP * Kolicina )
               nPom := Round( nPom, gZaokr )
               REPLACE VPVSAP WITH  nPom
            ENDIF

            nPom := kalk_pripr->( nMarza2 * ( Kolicina - GKolicina - GKolicin2 ) )
            nPom := Round( nPom, gZaokr )
            REPLACE Marza2 WITH nPom

            IF kalk_pripr->idvd $ "14#94"
               nPom := kalk_pripr->( VPC * ( 1 -RabatV / 100 ) * MPC / 100 * Kolicina )
            ELSE
               nPom := kalk_pripr->( MPC * ( Kolicina - GKolicina - GKolicin2 ) )
            ENDIF
            nPom := Round( nPom, gZaokr )
            REPLACE MPV WITH nPom

            // PDV

            nPom := kalk_pripr->( aIPor[ 1 ] * ( Kolicina - GKolicina - GKolicin2 ) )
            nPom := Round( nPom, gZaokr )
            REPLACE Porez WITH nPom

            // ugostiteljstvo porez na potr
            REPLACE Porez2    WITH Round( kalk_PRIPR->( aIPor[ 3 ] * ( Kolicina - GKolicina - GKolicin2 ) ), gZaokr )


            nPom := kalk_pripr->( MPCSaPP * ( Kolicina - GKolicina - GKolicin2 ) )
            nPom := Round( nPom, gZaokr )
            REPLACE MPVSaPP WITH nPom

            // porezv je aIPor[2] koji se ne koristi
            nPom := kalk_pripr->( aIPor[ 2 ] * ( Kolicina - GKolicina - GKolicin2 ) )
            nPom := Round( nPom, gZaokr )
            REPLACE Porezv WITH nPom

            REPLACE idroba    WITH kalk_pripr->idroba
            REPLACE  Kolicina  WITH kalk_pripr->( Kolicina - GKolicina - GKolicin2 )

            IF !( kalk_pripr->IdVD $ "IM#IP" )
               REPLACE   FV        WITH Round( nFV, gZaokr )
               REPLACE   Rabat     WITH Round( kalk_pripr->( nFV * Rabat / 100 ), gZaokr )
            ENDIF

            IF idvd == "IP"
               REPLACE  GKV2  WITH Round( kalk_pripr->( ( Gkolicina - Kolicina ) * MPcSAPP ), gZaokr ), ;
                  GKol2 WITH kalk_pripr->( Gkolicina - Kolicina )
            ENDIF

            IF idvd $ "14#94"
               REPLACE  MPVSaPP   WITH  kalk_pripr->( VPC * ( 1 -RabatV / 100 ) * ( Kolicina - GKolicina - GKolicin2 ) )
            ENDIF

            IF !Empty( kalk_pripr->mu_i )
               SELECT tarifa
               hseek roba->idtarifa
               SELECT finmat
               IF IsPDV()
                  REPLACE UPOREZV WITH  Round( kalk_pripr->( nMarza * kolicina * TARIFA->OPP / 100 / ( 1 + TARIFA->OPP / 100 ) ), gZaokr )
               ELSE
                  REPLACE UPOREZV WITH  Round( kalk_pripr->( nMarza * kolicina * TARIFA->VPP / 100 / ( 1 + TARIFA->VPP / 100 ) ), gZaokr )
               ENDIF
               SELECT tarifa
               hseek roba->idtarifa
               SELECT finmat
            ENDIF

            IF gKalo == "2" .AND.  kalk_pripr->idvd $ "10#81"  // kalo ima vrijednost po NC
               REPLACE GKV   WITH Round( kalk_pripr->( GKolicina * NC ), gZaokr ), ;   // vrijednost transp.kala
               GKV2  WITH Round( kalk_pripr->( GKolicin2 * NC ), gZaokr ), ;   // vrijednost ostalog kala
               GKol  WITH Round( kalk_pripr->GKolicina, gZaokr ), ;
                  GKol2 WITH Round( kalk_pripr->GKolicin2, gZaokr ), ;
                  POREZV WITH Round( nMarza * kalk_pripr->( GKolicina + Gkolicin2 ), gZaokr ) // negativna marza za kalo
            ENDIF

            IF kalk_pripr->idvd == "24"
               REPLACE mpv     WITH kalk_pripr->mpc, ;
                  mpvsapp WITH kalk_pripr->mpcsapp
            ENDIF

            IF kalk_pripr->IDVD $ "18#19"
               REPLACE Kolicina WITH 0
            ENDIF

            IF ( kalk_pripr->IdVD $ "41#42" )
               // popust maloprodaje se smjesta ovdje
               REPLACE Rabat WITH kalk_pripr->RabatV * kalk_pripr->kolicina
               IF AllTrim( gnFirma ) == "TEST FIRMA"
                  MsgBeep( "Popust MP = finmat->rabat " + Str( Rabat, 10, 2 ) )
               ENDIF
            ENDIF

            IF !IsPdv()

               IF glUgost
                  REPLACE prucmp WITH Round( kalk_pripr->( aIPor[ 2 ] * ( Kolicina - GKolicina - GKolicin2 ) ), gZaokr )
                  REPLACE porpot WITH Round( kalk_pripr->( aIPor[ 3 ] * ( Kolicina - GKolicina - GKolicin2 ) ), gZaokr )
               ENDIF


               IF  idvd $ "14#94"
                  // / ppp porezi
                  IF  gVarVP == "2"  // unazad VPC - preracunata stopa
                     REPLACE POREZV WITH Round( TARIFA->VPP / 100 / ( 1 + tarifa->vpp / 100 ) * iif( nMarza < 0, 0, nMarza ) * Kolicina, gZaokr )
                  ENDIF
               ENDIF
            ENDIF

            // napuni marker da se radi o predispoziciji...
            IF _predispozicija
               REPLACE k1 WITH "P"
            ENDIF

            SELECT kalk_pripr
            SKIP
         ENDDO // brdok

         IF cIdVd == "24"
            ? m
         ELSE
            IF fStara
               EXIT
            ENDIF
         ENDIF

      ENDDO // idfirma,idvd

      IF cidvd == "24" .AND. PRow() > 60
         FF
         @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
      ENDIF

      IF cidvd == "24"
         ?
         ? m
         @ PRow() + 1, 0      SAY  "Ukup." + cIdVD + ":"
         @ PRow(), nCol1    SAY  nTot1         PICTURE   picdem
         @ PRow(), PCol() + 5 SAY  nTot2         PICTURE   picdem
         @ PRow(), PCol() + 5 SAY  nTot3         PICTURE   picdem
         @ PRow(), PCol() + 5 SAY  nTot4         PICTURE   picdem
         @ PRow(), PCol() + 5 SAY  nTot5         PICTURE   picdem
         @ PRow(), PCol() + 1 SAY  nTot6         PICTURE   picdem
         @ PRow(), PCol() + 1 SAY  Space( Len( picproc ) )
         @ PRow(), PCol() + 1  SAY  nTot7        PICTURE   picdem
         @ PRow(), PCol() + 1  SAY  nTot8        PICTURE   picdem
         @ PRow(), PCol() + 1  SAY  nTot9        PICTURE   picdem
         @ PRow() + 1, nCol1   SAY  nTota         PICTURE   picdem
         @ PRow(), PCol() + 5  SAY  nTotb         PICTURE   picdem
         @ PRow(), PCol() + 5  SAY  nTotC         PICTURE   picdem
         ? m
         ?
         ENDPRINT
      ENDIF

      IF !fStara .OR. lAuto == .T.
         EXIT
      ELSE

         cIdFirma := idfirma
         cIdVd := idvd
         cBrdok := brdok

         IF !lViseKalk
            my_close_all_dbf()
         ENDIF

         // kontiranje dokumenta...
         kalk_kontiranje_naloga( .F., NIL, lViseKalk, NIL, _fin_auto_broj == "D" )

         // automatska ravnoteza naloga
         IF cAutoRav == "D"
            kontrola_zbira_naloga( .T. )
         ENDIF

         // ne vrti se ukrug u ovoj do wile petlji
         IF lViseKalk
            EXIT
         ENDIF

      ENDIF

   ENDDO

   IF fStara .AND. !lViseKalk
      SELECT kalk_pripr
      USE
   ENDIF

   IF !lViseKalk
      my_close_all_dbf()
      RETURN
   ENDIF

   RETURN




STATIC FUNCTION close_open_rekap_tables()
   O_FINMAT
   O_KONTO
   O_PARTN
   O_TDOK
   O_ROBA
   O_TARIFA
   RETURN 





FUNCTION predisp()

   LOCAL _ret := .F.

   IF field->k1 == "P"
      _ret := .T.
   ENDIF

   RETURN _ret




// -----------------------------------
// kontiraj vise dokumenata u jedan
// -----------------------------------
FUNCTION KontVise()

   LOCAL nCount
   LOCAL aD
   LOCAL dDatOd
   LOCAL dDatDo
   LOCAL cVrsta
   LOCAL cMKonto
   LOCAL cPKonto

   aD := kalk_rpt_datumski_interval( Date() )

   cVrsta := Space( 2 )

   dDatOd := aD[ 1 ]
   dDatDo := aD[ 2 ]

   cMKonto := PadR( "", 7 )
   cPKonto := PadR( "", 7 )

   SET CURSOR ON
   Box(, 6, 60 )
   @ m_x + 1, m_y + 2 SAY  "Vrsta kalkulacije " GET cVrsta ;
      PICT "@!" ;
      VALID !Empty( cVrsta )

   @ m_x + 3, m_y + 2 SAY  "Magacinski konto (prazno svi) " GET cMKonto ;
      PICT "@!"

   @ m_x + 4, m_y + 2 SAY "Prodavnicki kto (prazno svi)  " GET cPKonto ;
      PICT "@!"


   @ m_x + 6, m_y + 2 SAY  "Kontirati za period od " GET dDatOd
   @ m_x + 6, Col() + 2  SAY  " do " GET dDatDo

   READ

   BoxC()

   // koristi se kao datum kontiranja za trfp.dokument = "9"
   dDatMax := dDatDo

   IF LastKey() == K_ESC
      my_close_all_dbf()
      RETURN
   ENDIF

   SELECT F_KALK_DOKS
   IF !Used()
      O_KALK_DOKS
   ENDIF


   // "1","IdFirma+idvd+brdok"
   PRIVATE cFilter := "DatDok >= "  + cm2str( dDatOd ) + ".and. DatDok <= " + cm2str( dDatDo ) + ".and. IdVd==" + cm2str( cVrsta )

   IF !Empty( cMKonto )
      cFilter += ".and. mkonto==" + cm2str( cMKonto )
   ENDIF

   IF !Empty( cPKonto )
      cFilter += ".and. pkonto==" + cm2str( cPKonto )
   ENDIF

   SET FILTER TO &cFilter
   GO TOP

   nCount := 0
   DO WHILE !Eof()
      nCount ++
      cIdFirma := idFirma
      cIdVd := idvd
      cBrDok := brdok

      RekapK( .T., cIdFirma, cIdVd, cBrDok )

      SELECT KALK_DOKS
      SKIP
   ENDDO

   MsgBeep( "Obradjeno " + Str( nCount, 7, 0 ) + " dokumenata" )
   my_close_all_dbf()

   RETURN



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
