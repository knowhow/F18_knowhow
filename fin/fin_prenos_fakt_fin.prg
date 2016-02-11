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

#include "f18.ch"

FUNCTION FaktFin()

   O_PARAMS
   PRIVATE cSection := "(", cHistory := " "; aHistory := {}

   lNCPoSast := ( IzFMKINI( "FAKTFIN", "NCPoSastavnici", "N", KUMPATH ) == "D" )
   cKonSir   := PadR( IzFMKINI( "FAKTFIN", "KontoSirovinaIzSastavnice", "1010", KUMPATH ), 7 )

   gFaktKum := ""
   gKalkKum := ""
   gDzokerF1 := ""

   cOdradjeno := "D"

   Rpar( "a1", @gFaktKum )
   Rpar( "a2", @gDzokerF1 )
   Rpar( "a3", @gKalkKum )

   gDzokerF1 := Trim( gDzokerF1 )

   IF Empty( gFaktKum ) .OR. cOdradjeno = "N"
      gFaktKum := Trim( StrTran( cDirRad, "FIN", "FAKT" ) ) + "\"
      Wpar( "a1", @gFaktKum )
   ENDIF

   IF Empty( gKalkKum ) .OR. cOdradjeno = "N"
      gKalkKum := Trim( StrTran( cDirRad, "FIN", "KALK" ) ) + "\"
      Wpar( "a3", @gKalkKum )
   ENDIF

   cIdRjFakt := "10"
   cIdFakt := "10"
   dDAtOd := Date()
   dDatDo := Date()
   qqDok := Space( 30 )
   cSetPAr := "N"
   cSetIdRj := "N"

   Box(, 10, 60 )
   @ m_x + 1, m_y + 2 SAY "RJ u fakt:" GET cIdRjFakt
   @ m_x + 1, Col() + 2 SAY "postaviti IdRj u FIN ?" GET cSetIdRj ;
      PICT "@!" ;
      VALID ( cSetIdRj $ "DN" )

   @ m_x + 2, m_y + 2 SAY "Vrsta dokumenta u fakt:" GET cIdFakt
   @ m_x + 3, m_y + 2 SAY "Dokumenti u periodu:" GET dDAtOd
   @ m_x + 3, Col() + 2 SAY "do" GET dDatDo
   @ m_x + 5, m_y + 2 SAY "Broj dokumenta" GET qqDok

   @ m_x + 6, m_y + 2 SAY "Podesiti parametre prenosa" GET cSetPAr VALID csetpar $ "DN" PICT "@!"
   READ
   IF cSetPar == "D"
      gFaktKum := PadR( gFaktKum, 35 )
      gKalkKum := PadR( gKalkKum, 35 )
      gDzokerF1 := PadR( gDzokerF1, 80 )
      @ m_x + 8, m_y + 2 SAY "FAKT Kumulativ" GET gFaktKum  PICT "@S25"
      @ m_x + 9, m_y + 2 SAY "Dzoker F1(formula)" GET gDzokerF1  PICT "@S25"
      IF lNCPoSast
         @ m_x + 10, m_y + 2 SAY "KALK Kumulativ" GET gKalkKum  PICT "@S25"
      ENDIF
      READ
      gFaktKum := Trim( gFaktKum )
      gKalkKum := Trim( gKalkKum )
      gDzokerF1 := Trim( gDzokerF1 )
      Wpar( "a1", @gFaktKum )
      Wpar( "a2", @gDzokerF1 )
      Wpar( "a3", @gKalkKum )
   ENDIF

   BoxC()

   SELECT params
   USE

   IF LastKey() == K_ESC
      my_close_all_dbf()
      RETURN
   ENDIF

   // ovo dole je ukradeno iz KALK/REKAPK

   O_FINMAT
   O_KONTO
   O_PARTN
   O_TDOK
   O_ROBA
   O_TARIFA

   IF lNCPoSast
      O_SAST
      SELECT ( F_KALK )
      IF !Used()
         O_KALK
      ENDIF
      SET ORDER TO TAG "1"
   ENDIF

   SELECT ( F_FAKT )
   IF !Used()
      O_FAKT
   ENDIF
   
   // "1","IdFirma+idtipdok+brdok+rbr+podbr",KUMPATH+"FAKT")
   SET ORDER TO TAG "1"

   SELECT FINMAT
   my_dbf_zap()

   aUsl := Parsiraj( qqDok, "Brdok", "C" )

   PRIVATE cFilter := "DatDok>=" + cm2str( dDatOd ) + ".and.DatDok<=" + cm2str( dDatDo ) + ".and. idtipdok==" + cm2str( cIdFakt ) + ".and. IdFirma==" + cm2str( cIdRjFakt )

   IF aUsl <> ".t."
      cFilter += ".and." + aUsl
   ENDIF


   SELECT fakt
   SET FILTER to &cFilter
   GO TOP


   nTot1 := nTot2 := nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := nTot9 := nTota := nTotb := 0
   DO WHILE !Eof()

      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdTipDok := IdTipdok

      SELECT fakt

      cIdPartner := idpartner
      IF Empty( IdPartner )
         Box(, 6, 66 )
         aMemo := parsmemo( txt )
         IF Len( aMemo ) >= 5
            @ m_x + 1,m_y + 2 SAY "FAKT broj:" + BrDOK
            @ m_x + 2, m_y + 2 SAY PadR( Trim( amemo[ 3 ] ), 30 )
            @ m_x + 3, m_y + 2 SAY PadR( Trim( amemo[ 4 ] ), 30 )
            @ m_x + 4, m_y + 2 SAY PadR( Trim( amemo[ 5 ] ), 30 )
         ELSE
            cTxt := ""
         ENDIF
         @ m_x + 6, m_y + 2 SAY "Sifra partnera:"  GET cIdpartner PICT "@!" VALID P_Firma( @cIdPartner )
         READ
         BoxC()
      ENDIF

      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND.  cBrDok == BrDok .AND. cIdTipDok == IdTipDok

         nFV := Cijena * Kolicina
         nRabat := Cijena * kolicina * Rabat / 100

         SELECT ROBA
         HSEEK FAKT->IdRoba
         SELECT TARIFA
         HSEEK roba->idtarifa
         SELECT fakt

         nNV := 0
         IF lNCPoSast .AND. ROBA->tip == "P"
            SELECT SAST
            HSEEK FAKT->idroba
            DO WHILE !Eof() .AND. id == FAKT->idroba
               nNV += FAKT->kolicina * SAST->kolicina * IzKalk( SAST->id2, cKonSir, "NC" )
               SKIP 1
            ENDDO
         ENDIF

         SELECT FINMAT
         APPEND BLANK
         cIdVD := fakt->IdTipdok
         RREPLACE IdFirma   WITH gFirma, ;
            IdTarifa  WITH roba->IdTarifa, ;
            IdPartner WITH cIdPartner, ;
            IdVD      WITH cIdVD, ;
            BrDok     WITH fakt->BrDok, ;
            DatDok    WITH fakt->DatDok, ;
            FV        WITH nFV,;
            NV        WITH nNV,;
            Marza     WITH 0, ;
            VPV       WITH nFV, ;
            RABATV    WITH nRabat, ;
            Porez     WITH IF( cIdVD <> "11", ( nFV - nRabat ) * fakt->( porez / 100 ), ;
            PorezMP( "PP" ) ), ;
            POREZV    WITH IF( cIdVD <> "11", Porez, ;
            PorezMP( "PPU" ) ), ;
            POREZ2    WITH IF( cIdVD <> "11", 0, ;
            PorezMP( "PPP" ) ), ;
            idroba    WITH fakt->idroba, ;
            Kolicina  WITH fakt->Kolicina

         IF ( cSetIdRj == "D" )
            RREPLACE IdRj WITH cIdRjFakt
         ENDIF

         IF cIDVD == "11" .AND. lNCPoSast .AND. TARIFA->mpp <> 0 .AND. FieldPos( "POREZ3" ) > 0
            RREPLACE porez3 WITH PorezMP( "MPP" )
         ENDIF
         SELECT fakt
         SKIP
      ENDDO // brdok

   ENDDO

   SELECT finmat
   IF reccount2() > 0
      my_close_all_dbf()
      fin_kontiranje_naloga( dDatDo )
   ELSE
      MsgBeep( "Nema dokumenata za prenos ..." )
   ENDIF
   closeret




/*! \fn PorezMp(cVar)
 *  \brief Porez u maloprodaji
 *  \param cVar
 */

FUNCTION PorezMp( cVar )

   LOCAL nVrati, nCSP, nD, nMBVBP
   LOCAL nPor1, nPor2, nPor3
   LOCAL nMPP, nPPP, nPP, nPPU

   nMPP := tarifa->mpp / 100
   nPPP := tarifa->opp / 100
   nPP := tarifa->zpp / 100
   nPPU := tarifa->ppp / 100

   nCSP := nFV - nRabat     // cijena sa porezima

   IF gUVarPP == "T"
      nPor1 := nCSP * nPPP / ( 1 + nPPP )
      nPor2 := ( nCSP - nPor1 - nNV ) * nMPP / ( 1 + nMPP )
      nPor3 := ( nCSP - nPor2 ) * nPP
      DO CASE
      CASE cVar == "PP"
         nVrati := nPor3
      CASE cVar == "PPP"
         nVrati := nPor1
      CASE cVar == "PPU"
         nVrati := 0
      CASE cVar == "MPP"
         nVrati := nPor2
      ENDCASE
      RETURN nVrati
   ENDIF

   IF  gUVarPP == "D"
      nD := 1 + TARIFA->zpp / 100 + TARIFA->ppp / 100
   ELSE
      nD := ( 1 + TARIFA->opp / 100 ) * ( 1 + TARIFA->ppp / 100 ) + TARIFA->zpp / 100
   ENDIF

   DO CASE
   CASE cVar == "PP"
      nVrati := nCSP * ( TARIFA->zpp / 100 ) / nD
   CASE cVar == "PPU"
      IF gUVarPP == "D"
         nVrati := nCSP * ( TARIFA->ppp / 100 ) / nD
      ELSE
         nVrati := nCSP * ( TARIFA->ppp / 100 ) * ( 1 + TARIFA->opp / 100 ) / nD
      ENDIF
   CASE cVar == "PPP"
      IF gUVarPP == "D"
         nVrati := nCSP * ( TARIFA->opp / 100 ) / ( ( 1 + TARIFA->opp / 100 ) * nD )
      ELSE
         nVrati := nCSP * ( TARIFA->opp / 100 ) / nD
      ENDIF

   CASE cVar == "MPP"
      IF gUVarPP == "D"
         nMPVBP := nCSP / ( ( 1 + TARIFA->opp / 100 ) * nD )
      ELSE
         nMPVBP := nCSP / nD
      ENDIF
      nPom   := nMPVBP - nNV
      nVrati := Max( nCSP * ( TARIFA->dlruc / 100 ) * ( TARIFA->mpp / 100 ), TARIFA->mpp * nPom / ( 100 + TARIFA->mpp ) )
   END CASE

   RETURN nVrati




/*! \fn fin_kontiranje_naloga(dDatNal)
 *  \brief Kontiranje naloga
 *  \param dDatNal  - datum naloga
 */

FUNCTION fin_kontiranje_naloga( dDatNal )

   LOCAL cidfirma, cidvd, cbrdok, lafin, lafin2

   O_ROBA
   O_FINMAT
   O_TRFP2
   O_KONCIJ
   O_VALUTE

   lAFin := .T.
   IF lafin
      Beep( 1 )
      lafin := Pitanje(, "Formirati FIN nalog?", "D" ) == "D"
   ENDIF

   cBrNalF := ""

   O_NALOG
   O_FIN_PRIPR

   SELECT FINMAT
   GO TOP
   SELECT trfp2
   SEEK finmat->IdVD + " "

   cIdVN := IdVN   // uzmi vrstu naloga koja ce se uzeti u odnosu na prvu kalkulaciju
   // koja se kontira

   IF lAFin
      cBrNalF := fin_novi_broj_dokumenta( finmat->idfirma, cIdVn )
      SELECT nalog
      USE
   ENDIF

   SELECT finmat
   GO TOP

   Box( "brn?", 5, 55 )
   // dDatNal:=datdok
   SET CURSOR ON
   @ m_x + 1, m_y + 2  SAY "Broj naloga u FIN  " + finmat->idfirma + " - " + cidvn + " -" GET cBrNalF
   @ m_x + 5, m_y + 2 SAY "(ako je broj naloga prazan - ne vrsi se kontiranje)"
   READ
   ESC_BCR
   BoxC()
   nRbr := 0; nRbr2 := 0

   MsgO( "Prenos FAKT -> FIN" )

   SELECT finmat
   PRIVATE cKonto1 := NIL
   PRIVATE KursLis := "1"

   DO WHILE !Eof()    // datoteka finmat
      cIDVD := IdVD
      cBrDok := BrDok
      IF ValType( cKonto1 ) <> "C"
         PRIVATE cKonto1 := "";cKonto2 := "";cKonto3 := ""
         PRIVATE cPartner1 := "";cPartner2 := cPartner3 := ""
      ENDIF
      DO WHILE cIdVD == IdVD .AND. cBrDok == BrDok .AND. !Eof()
         SELECT roba
         HSEEK finmat->idroba
         SELECT trfp2
         SEEK cIdVD + " "
         // nemamo vise sema kontiranja kao u kalk
         DO WHILE !Empty( cBrNalF ) .AND. idvd == cIDVD  .AND. shema = " " .AND. !Eof()
            cStavka := Id
            SELECT finmat
            nIz := &cStavka
            SELECT trfp2
            IF !Empty( trfp2->idtarifa ) .AND. trfp2->idtarifa <> finmat->idtarifa
               // ako u {ifrarniku parametara postoji tarifa prenosi po tarifama
               nIz := 0
            ENDIF
            IF nIz <> 0
               // ako je iznos elementa <> 0, dodaj stavku u fpripr
               SELECT fin_pripr
               IF trfp2->znak == "-"
                  nIz := -nIz
               ENDIF
               nIz := round7( nIz, Right( TRFP2->naz, 2 ) )

               // DEM - pomocna valuta
               nIz2 := nIz * Kurs( dDatNal, "D", "P" )

               cIdKonto := trfp2->Idkonto
               cIdkonto := StrTran( cidkonto, "?1", Trim( ckonto1 ) )
               cIdkonto := StrTran( cidkonto, "?2", Trim( ckonto2 ) )
               cIdkonto := StrTran( cidkonto, "?3", Trim( ckonto3 ) )
               IF "F1" $ cIdKonto
                  IF Empty( gDzokerF1 )
                     cPom := ""
                  ELSE
                     cPom := &gDzokerF1
                  ENDIF
                  cIdkonto := StrTran( cidkonto, "F1", cPom )
               ENDIF
               cIdkonto := PadR( cidkonto, 7 )
               cIdPartner := Space( 6 )
               IF trfp2->Partner == "1"  // stavi Partnera
                  cIdpartner := FINMAT->IdPartner
               ELSEIF trfp2->Partner == "A"   // stavi  Lice koje se zaduz2
                  cIdpartner := PadR( cPartner1, 7 )
               ELSEIF trfp2->Partner == "B"   // stavi  Lice koje se zaduz2
                  cIdpartner := PadR( cPartner2, 7 )
               ELSEIF trfp2->Partner == "C"   // stavi  Lice koje se zaduz2
                  cIdpartner := PadR( cPartner3, 7 )
               ENDIF
               cBrDok := Space( 8 )
               dDatDok := FINMAT->datdok
               IF trfp2->Dokument == "1"
                  cBrDok := FINMAT->brdok
               ELSEIF trfp2->Dokument == "3"
                  dDatDok := dDatNal
               ENDIF
               fExist := .F.
               SEEK FINMAT->IdFirma + cidvn + cBrNalF
               IF Found()
                  fExist := .F.
                  DO WHILE FINMAT->idfirma + cidvn + cBrNalF == IdFirma + idvn + BrNal
                     IF IdKonto == cIdKonto .AND. IdPartner == cIdPartner .AND. trfp2->d_p == d_p  .AND. idtipdok == FINMAT->idvd .AND. PadR( brdok, 10 ) == PadR( cBrDok, 10 ) .AND. datdok == dDatDok
                        // provjeriti da li se vec nalazi stavka koju dodajemo
                        fExist := .T.
                        EXIT
                     ENDIF
                     SKIP
                  ENDDO
                  IF !fExist
                     GO BOTTOM
                     nRbr := Val( Rbr ) + 1
                     APPEND BLANK
                  ENDIF
               ELSE
                  GO BOTTOM
                  nRbr := Val( rbr ) + 1
                  APPEND BLANK
               ENDIF

               RREPLACE iznosDEM WITH iznosDEM + nIz2, ;
                  iznosBHD WITH iznosBHD + nIz, ;
                  idKonto  WITH cIdKonto, ;
                  IdPartner  WITH cIdPartner, ;
                  D_P      WITH trfp2->d_P, ;
                  idFirma  WITH FINMAT->idfirma, ;
                  IdVN     WITH cidvn, ;
                  BrNal    WITH cBrNalF, ;
                  IdTipDok WITH FINMAT->IdVD, ;
                  BrDok    WITH cBrDok, ;
                  DatDok   WITH dDatDok, ;
                  opis     WITH trfp2->naz

               IF !fExist
                  RREPLACE Rbr  WITH Str( nRbr, 4 )
               ENDIF

            ENDIF // nIz <>0

            SELECT trfp2
            SKIP
         ENDDO // trfp2->id==cIDVD


         SELECT FINMAT
         SKIP
      ENDDO

   ENDDO

   IF lAFin

      SELECT fin_pripr; GO TOP

      my_flock()
      DO WHILE !Eof()
         cPom := Right( Trim( opis ), 1 )
         // na desnu stranu opisa stavim npr "ZADUZ MAGACIN          0"
         // onda ce izvrsiti zaokruzenje na 0 decimalnih mjesta
         IF cPom $ "0125"
            nLen := Len( Trim( opis ) )
            REPLACE opis WITH Left( Trim( opis ), nLen - 1 )
            REPLACE iznosbhd WITH Round( iznosbhd, IF( Val( cPom ) == 0 .AND. cPom != "0", 2, Val( cPom ) ) )
            REPLACE iznosdem WITH Round( iznosdem, IF( Val( cPom ) == 0 .AND. cPom != "0", 2, Val( cPom ) ) )
            IF cPom = "5"
               REPLACE iznosbhd WITH round2( iznosbhd, 2 )
               REPLACE iznosdem WITH round2( iznosdem, 2 )
            ENDIF
         ENDIF // cpom
         SKIP
      ENDDO // fpripr

      my_unlock()
   ENDIF // lafin , lafin2

   MsgC()

   closeret

   RETURN



/*! \fn RasKon(cRoba,aSifre,aKonta)
 *  \brief Trazi poziciju cRoba u aSifre i ako nadje vraca element iz aKonta koji je na nadjenoj poziciji
 *  \param cRoba
 *  \param aSifre
 *  \param aKonta
 */

FUNCTION RasKon( cRoba, aSifre, aKonta )

   LOCAL nPom

   nPom := AScan( aSifre, cRoba )

   RETURN IF( nPom > 0, aKonta[ nPom ], "" )




/*! \fn PrStopa(nProc)
 *  \brief  Preracunata stopa
 *  \nProc - Broj
 */

FUNCTION PrStopa( nProc )

   RETURN ( if( nProc == 0, 0, 1 / ( 1 + 1 / ( nProc / 100 ) ) ) )




/*! \fn IzKalk(cIdRoba,cKonSir,cSta)
 *  \brief
 *  \param cIdRoba
 *  \param cKonSir
 *  \param cSta
 */

FUNCTION IzKalk( cIdRoba, cKonSir, cSta )

   LOCAL x := 0, nArr := Select(), nNV, nUlaz, nIzlaz

   SELECT KALK
   DO CASE
   CASE cSta == "NC"
      // "idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD"
      SET ORDER TO TAG "3"
      SEEK gFirma + cKonSir + cIdRoba
      nNV := nUlaz := nIzlaz := 0
      DO WHILE !Eof() .AND. idfirma + mkonto + idroba == gFirma + cKonSir + cIdRoba
         IF mu_i == "1" .AND. !( idvd $ "12#22#94" )
            nUlaz  += kolicina - gkolicina - gkolicin2
            nNV    += nc * ( kolicina - gkolicina - gkolicin2 )
         ELSEIF mu_i == "5"
            nIzlaz += kolicina
            nNV    -= nc * ( kolicina )
         ELSEIF mu_i == "1" .AND. ( idvd $ "12#22#94" )    // povrat
            nIzlaz -= kolicina
            nNV    += nc * ( kolicina )
         ENDIF
         SKIP 1
      ENDDO
      IF nUlaz - nIzlaz <> 0
         x := nNV / ( nUlaz - nIzlaz )
      ENDIF
      IF x <= 0
         MsgBeep( "GRESKA! Artikal:" + cIdRoba + ", konto:" + cKonSir + ", NC=" + Str( x ) + " !?" + ;
            "#FAKT dok.:" + FAKT->( idfirma + "-" + idtipdok + "-" + brdok ) + ", stavka br." + FAKT->rbr + ;
            "#Proizvod:" + FAKT->idroba )
      ENDIF
   ENDCASE
   SELECT ( nArr )

   RETURN x
