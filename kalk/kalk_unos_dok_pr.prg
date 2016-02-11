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

MEMVAR GetList, m_x, m_y
MEMVAR nRbr, fNovi
MEMVAR _DatFaktP, _datDok, _brFaktP

FUNCTION kalk_unos_dok_pr()

   LOCAL nTRec
   LOCAL bProizvod := {|| Round( Val( field->rBr ) / 100, 0 )  }
   LOCAL bDokument := {| cIdFirma, cIdVd, cBrDok |   cIdFirma == field->idFirma .AND. ;
      cIdVd == field->IdVd .AND. cBrDok == field->BrDok }
   LOCAL cIdFirma, cIdVd, cBrDok

   SELECT F_SAST
   IF !Used()
      O_SAST
   ENDIF

   SELECT kalk_pripr
   SET FILTER TO Val( field->rBr ) < 10

   IF nRbr < 10 .AND. fNovi
      _DatFaktP := _datDok
   ENDIF

   // IF nRbr < 10

   @ m_x + 6, m_y + 2 SAY8 "Broj fakture" GET _brFaktP
   @ m_x + 7, m_y + 2 SAY8 "Mag .got.proizvoda zadužuje" GET _IdKonto ;
      VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!" ;
      WHEN {|| nRbr == 1 }
   @ m_x + 8, m_y + 2 SAY8 "Mag. sirovina razdužuje    " GET _IdKonto2 ;
      PICT "@!" VALID P_Konto( @_IdKonto2 ) ;
      WHEN {|| nRbr == 1 }


   @ m_x + 12, m_y + 2 SAY8 "Proizvod  " GET _IdRoba PICT "@!" ;
      VALID  {|| P_Roba( @_IdRoba, NIL, NIL, "IDP" ), ;
      Reci( 12, 24, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   SELECT tarifa
   HSEEK _IdTarifa

   SELECT kalk_pripr

   @ m_x + 13, m_y + 2 SAY8 "Količina  " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   READ

   SELECT kalk_pripr
   cIdFirma := field->idFirma
   cIdVd := field->idVd
   cBrDok := field->brDok

   PushWa()
   SET FILTER TO
   my_flock()
   GO TOP
   DO WHILE !EOF()

      SKIP
      nTrec := RecNo()
      SKIP -1
      IF Val( field->rbr ) > 99 .AND. ;
       Eval( bDokument, cIdFirma, cIdVd, cBrDok ) .AND. ;
            ( InRange( Val( field->rBr ), nRbr * 100 + 1, nRbr * 100 + 99 ) .OR. ; // nRbr = 2, delete 201-299
              Val( field->rBr ) > 900 )
         my_delete()
      ENDIF
      GO nTrec

   ENDDO
   my_unlock()

   SELECT ROBA
   HSEEK _idroba
   IF roba->tip = "P" .AND. nRbr < 10   // radi se o proizvodu
      nRbr2 := nRbr * 100
      SELECT sast
      HSEEK _idroba

      DO WHILE !Eof() .AND. sast->id == _idroba // prolazak kroz sastavnicu

         SELECT roba
         HSEEK sast->id2

         SELECT kalk_pripr
         APPEND BLANK
         REPLACE field->idfirma WITH _IdFirma, ;
            field->rbr WITH Str( ++nRbr2, 3 ), ;
            field->idvd WITH "PR", ;
            field->brdok WITH _Brdok, ;
            field->datdok WITH _Datdok, ;
            field->idtarifa WITH ROBA->idtarifa, ;
            field->brfaktp WITH _brfaktp, ;
            field->datfaktp WITH _Datdok, ;
            field->idkonto   WITH _idkonto, ;
            field->idkonto2  WITH _idkonto2, ;
            field->kolicina WITH _kolicina * sast->kolicina, ;
            field->idroba WITH sast->id2, ;
            field->nc WITH 0, ;
            field->vpc WITH 0, ;
            field->pu_i WITH "", ;
            field->mu_i WITH "5", ;
            field->error WITH "0", ;
            field->mkonto WITH _idkonto2

         PushWa()
         // kalkulacija nabavne cijene
         // nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
         nKolS := 0
         nKolZN := 0
         nC1 := 0
         nC2 := 0
         dDatNab := CToD( "" )

         IF _TBankTr <> "X"
            // ako je X onda su stavke vec izgenerisane
            IF !Empty( gMetodaNC )  .AND. !( roba->tip $ "UT" )
               MsgO( "Racunam stanje na skladistu" )
               KalkNab( _idfirma, sast->id2, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
               MsgC()
            ENDIF

            IF dDatNab > _DatDok
               Beep( 1 )
               Msg( "Datum nabavke je " + DToC( dDatNab ) + " sirovina " + sast->id2, 4 )
            ENDIF

            IF _kolicina >= 0 .OR. Round( _NC, 3 ) == 0 .AND. !( roba->tip $ "UT" )

               SELECT roba
               _rec := dbf_get_rec()
               _rec[ "nc" ] := _nc
               update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" ) // nafiluj sifarnik robe sa nc sirovina, robe
               SELECT kalk_pripr

            ENDIF

            PopWa()

            RREPLACE field->nc WITH nc2, field->gkolicina WITH nKolS


         ENDIF
         SELECT sast
         SKIP
      ENDDO

      PopWa()

      READ

      ESC_RETURN K_ESC
   ELSE

      @ m_x + 7, m_y + 2   SAY8 "Mag.gotovih proizvoda zadužuje " ; ?? _IdKonto
      @ m_x + 8, m_y + 2   SAY8 "Mag.sirovina razdužuje         " ; ?? _IdKonto2


   ENDIF

   @ m_x + 11, m_y + 66 SAY "Tarif.br v"

   IF nRbr > 99
      @ m_x + 12, m_y + 2  SAY8 "Sirovina  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 12, 24, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
      @ m_x + 13, m_y + 2   SAY8 "Količina  " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0
   ENDIF

   READ
   ESC_RETURN K_ESC

   AltD()
   IF nRbr > 99  // sirovine
      // kalkulacija nabavne cijene
      nKolS := 0
      nKolZN := 0
      nC1 := 0
      nC2 := 0
      dDatNab := CToD( "" )

      IF !( roba->tip $ "UT" )
         MsgO( "Računam stanje na skladistu" )
         KalkNab( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         MsgC()
      ENDIF
      IF dDatNab > _DatDok
         Beep( 1 )
         Msg( "Datum nabavke je " + DToC( dDatNab ) + " sirovina " + sast->id2, 4 )
      ENDIF
      IF Round( nKols - _kolicina, 4 ) < 0
         error_tab( "Na stanju je samo :" + Str( nKols, 15, 3 ) )
         _error := "1"
      ENDIF
   ENDIF
   SELECT kalk_pripr


   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr

   _MKonto := _Idkonto
   _MU_I := "1"

   DatPosljK()

   IF fNovi
      SELECT ROBA
      HSEEK _IdRoba
      _VPC := KoncijVPC()
      _TCarDaz := "%"
      _CarDaz := 0
   ENDIF

   SELECT kalk_pripr
   IF _tmarza <> "%"  // procente ne diraj
      _Marza := 0
   ENDIF

   IF nRbr > 99
      @ m_x + 15, m_y + 2   SAY "N.CJ Sirovina:"
      @ m_x + 15, m_y + 50  GET _NC PICTURE PicDEM VALID _nc >= 0
      READ
      _Mkonto := _idkonto2
      _mu_i := "5"
   ENDIF

   PushWa()

   SELECT kalk_pripr
   SET FILTER TO
   SET ORDER TO TAG "1"
   GO TOP

   nNV := 0  // ncj proizvod
   DO WHILE !Eof()

      IF Eval( bDokument, cIdFirma, cIdVd, cBrDok ) .AND. ;   // gledaj samo stavke jednog dokumenta ako ih ima vise u pripremi
         Eval( bProizvod ) == nRbr // when field->rbr == 301, 302, 303 ...  EVAL( bProizvod ) = 3
         nNV += field->NC * field->kolicina
         IF nRbr == 1 .AND. field->gkolicina < field->kolicina
            error_tab( "Na stanju " + field->idkonto2 + " se nalazi samo " + Str( field->gkolicina, 9, 2 ) + " sirovine " + field->idroba, 0 )
            _error := "1"
         ENDIF
      ENDIF
      SKIP
   ENDDO

   IF Round( _kolicina, 4 ) == 0
      _fcj := 0.0
   ELSE
      _fcj := nNV / _kolicina
   ENDIF

   PopWa()

   _fcj := nNV / _kolicina
   @ m_x + 15, m_y + 2   SAY "Nabc.CJ Proizvod :"
   @ m_x + 15, m_y + 50  GET _FCJ PICTURE PicDEM VALID _fcj > 0 WHEN V_kol10()
   READ
   ESC_RETURN K_ESC

   _FCJ2 := _FCJ * ( 1 - _Rabat / 100 )

   RETURN LastKey()



// --------------------------------------------
// druga stranica unosa dokumenta PR
// --------------------------------------------
FUNCTION Get2_PR()

   LOCAL cSPom := " (%,A,U,R) "

   IF nRbr > 9
      RETURN K_ENTER
   ENDIF

   PRIVATE GetList := {}

   IF Empty( _TPrevoz ); _TPrevoz := "%"; ENDIF
   IF Empty( _TCarDaz ); _TCarDaz := "%"; ENDIF
   IF Empty( _TBankTr ); _TBankTr := "%"; ENDIF
   IF Empty( _TSpedTr ); _TSpedtr := "%"; ENDIF
   IF Empty( _TZavTr );  _TZavTr := "%" ; ENDIF
   IF Empty( _TMarza );  _TMarza := "%" ; ENDIF

   @ m_x + 2, m_y + 2 SAY cRNT1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
   @ m_x + 2, m_y + 40 GET _Prevoz PICTURE PicDEM

   @ m_x + 3, m_y + 2 SAY cRNT2 + cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" PICT "@!"
   @ m_x + 3, m_y + 40 GET _BankTr PICTURE PicDEM

   @ m_x + 4, m_y + 2 SAY cRNT3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AUR" PICT "@!"
   @ m_x + 4, m_y + 40 GET _SpedTr PICTURE PicDEM

   @ m_x + 5, m_y + 2 SAY cRNT4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
   @ m_x + 5, m_y + 40 GET _CarDaz PICTURE PicDEM

   @ m_x + 6, m_y + 2 SAY cRNT5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
   @ m_x + 6, m_y + 40 GET _ZavTr PICTURE PicDEM VALID {|| NabCj(), .T. }

   @ m_x + 8, m_y + 2 SAY "CIJENA KOST.  "
   @ m_x + 8, m_y + 50 GET _NC PICTURE PicDEM

   IF koncij->naz <> "N1"

      PRIVATE fMarza := " "
      @ m_x + 10, m_y + 2 SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
      @ m_x + 10, m_y + 40 GET _Marza PICTURE PicDEM
      @ m_x + 10, Col() + 1 GET fMarza PICT "@!"
      @ m_x + 12, m_y + 2 SAY "VELEPRODAJNA CJENA  (VPC)   :"
      @ m_x + 12, m_y + 50 GET _VPC PICT PicDEM VALID {|| Marza( fMarza ), .T. }

      READ
      SetujVPC( _vpc )

   ELSE

      READ
      _Marza := 0
      _TMarza := "A"
      _VPC := _NC

   ENDIF

   IF nRbr = 1
      _MKonto := _Idkonto; _MU_I := "1"
   ENDIF
   nStrana := 3

   RETURN LastKey()
