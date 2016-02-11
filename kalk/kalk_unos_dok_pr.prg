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

   LOCAL bProizvod := {|| Round( Val( field->rBr ) / 100, 0 )  }

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


   @ m_x + 12, m_y + 2 SAY8 "Proizvod  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 12, 24, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   SELECT tarifa
   HSEEK _IdTarifa

   SELECT kalk_pripr

   @ m_x + 13, m_y + 2 SAY8 "Količina  " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   READ

   // _BrFaktP := _idzaduz2
   // sada trazim trebovanja u proizvod. u toku i filujem u stavke
   // od 100 pa nadalje
   // ove stavke imace  mu_i=="5", mkonto=_idkonto2, nc,nv
   // "KALKi7","idFirma+mkonto+IDZADUZ2+idroba+dtos(datdok)","KALK")

   //nTPriPrec := RecNo()

   SELECT kalk_pripr

   PushWa()
   SET FILTER TO
   GO BOTTOM
   // IF ( Val( field->rbr ) > 100 ;
   // .AND. Pitanje(, "Želite li izbrisati izgenerisane sirovine ?", "N" ) == "D" )

   my_flock()
   AltD()
   DO WHILE !Bof() .AND. Val( field->rbr ) > 99
      SKIP -1

      IF InRange( Val( field->rBr ), nRbr * 100 + 1, nRbr * 100 + 99 ) // nRbr = 2, delete 201-299
         nTrec := RecNo()
         SKIP
         my_delete()
         GO nTrec
      ENDIF

   ENDDO
   my_unlock()

   SELECT ROBA
   HSEEK _idroba
   IF roba->tip = "P" .AND. nRbr < 10
      // radi se o proizvodu, prva stavka
      nRbr2 := nRbr * 100
      SELECT sast
      HSEEK _idroba

      DO WHILE !Eof() .AND. sast->id == _idroba // prolazak kroz sastavnicu

         SELECT roba
         hseek sast->id2

         //SELECT kalk_pripr
         // LOCATE FOR field->idroba == sast->id2

         // IF Found()
         // RREPLACE kolicina WITH kolicina + kalk_pripr->kolicina * sast->kolicina
         // ELSE
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

         nTTKNrec := RecNo()
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
               IF gMetodanc == "2"
                  SELECT roba
                  _rec := dbf_get_rec()
                  _rec[ "nc" ] := _nc
                  update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
                  SELECT kalk_pripr
                  // nafiluj sifrarnik robe sa nc sirovina, robe
               ENDIF
            ENDIF

            SELECT kalk_pripr
            GO nTTKNRec
            my_rlock()
            REPLACE field->nc WITH nc2, ;
               field->gkolicina WITH nKolS
            my_unlock()

            // ENDIF
         ENDIF
         SELECT sast
         SKIP
      ENDDO
      // ENDIF

      PopWa()  // roba->tip == "P"
      AltD()
      // ENDIF

      SELECT kalk_pripr
      //GO nTPriPrec

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

ALTD()
   IF nRbr > 99  // sirovine
      // kalkulacija nabavne cijene
      nKolS := 0
      nKolZN := 0
      nc1 := 0
      nc2 := 0
      dDatNab := CToD( "" )

      IF _TBankTr <> "X"
         // ako je X onda su stavke vec izgenerisane
         IF !Empty( gMetodaNC )  .AND. !( roba->tip $ "UT" )
            MsgO( "Racunam stanje na skladistu" )
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
   ENDIF

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
   altd()
   DO WHILE !Eof()
      IF EVAL( bProizvod ) == nRbr // when field->rbr == 301, 302, 303 ...  EVAL( bProizvod ) = 3

        // IF Val( field->rbr ) == nRbr
        //    nNV += _NC * _kolicina
        // ELSE
            nNV += field->NC * field->kolicina
            // ovo je u stvari nabavna vrijednost
        // ENDIF
         IF nRbr == 1 .AND. field->gkolicina < field->kolicina
            error_tab( "Na stanju " + field->idkonto2 + " se nalazi samo " + Str( field->gkolicina, 9, 2 ) + " sirovine " + field->idroba, 0 )
            _error := "1"
         ENDIF
      ENDIF
      SKIP
   ENDDO

   IF nRbr == 1
      IF Round( _kolicina, 4 ) == 0
         _fcj := 0.0
      ELSE
         _fcj := nNV / _kolicina
      ENDIF
   ELSE
      IF !fnovi
         GO TOP
         IF Val( field->rbr ) == 1
            IF Round( field->kolicina, 4 ) == 0
               _fcj := 0.0
            ELSE
               _fcj := nNV / field->kolicina
            ENDIF
            RREPLACE field->fcj WITH _fcj
         ENDIF
      ENDIF
   ENDIF

   PopWa()

   //IF nRbr < 10
      _fcj := nNV / _kolicina
      @ m_x + 15, m_y + 2   SAY "Nabc.CJ Proizvod :"
      @ m_x + 15, m_y + 50  GET _FCJ PICTURE PicDEM VALID _fcj > 0 WHEN V_kol10()
      READ
      ESC_RETURN K_ESC
   //ENDIF

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

   PRIVATE getlist := {}

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

      // vodi se po vpc
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
