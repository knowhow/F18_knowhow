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



FUNCTION Get1_82()

   pIzgSt := .F.

   // izgenerisane stavke jos ne postoje
   // private cisMarza:=0

   SET KEY K_ALT_K TO KM2()

   IF nRbr == 1 .OR. !fnovi
      @  m_x + 7, m_y + 2   SAY "Faktura Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   ;
         valid {|| .T. }
      _IdZaduz := ""

      _Idkonto2 := ""

      @ m_x + 9, m_y + 2 SAY "Magacinski konto razduzuje"  GET _IdKonto ;
         VALID Empty( _IdKonto ) .OR. P_Konto( @_IdKonto, 21, 5 )
      //IF gNW <> "X"
      //   @ m_x + 9, m_y + 40 SAY "Razduzuje:" GET _IdZaduz   PICT "@!"  VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
      //ENDIF
   ELSE
      // @  m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
      @  m_x + 7, m_y + 2   SAY "Faktura Broj: "; ?? _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      _IdZaduz := ""
      _Idkonto2 := ""
      @ m_x + 9, m_y + 2 SAY "Magacinski konto razduzuje "; ?? _IdKonto
      //IF gNW <> "X"
      //   @ m_x + 9, m_y + 40 SAY "Razduzuje: "; ?? _IdZaduz
      //ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.brĿ"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idRoba := PadR( _idRoba, Val( gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   read; ESC_RETURN K_ESC
   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA; HSEEK _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT koncij; SEEK Trim( _idkonto )
   SELECT kalk_pripr  // napuni tarifu

   _MKonto := _Idkonto2
   DuplRoba()
   check_datum_posljednje_kalkulacije()

   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   _GKolicina := 0

   IF fNovi
      SELECT ROBA; HSEEK _IdRoba
      _VPC := KoncijVPC()
      _NC := NC
   ENDIF
   IF dozvoljeno_azuriranje_sumnjivih_stavki() .AND. fNovi
      kalk_vpc_po_kartici( @_VPC, _idfirma, _idkonto, _idroba )
      SELECT kalk_pripr
   ENDIF
   VtPorezi()

   nKolS := 0
   nKolZN := 0
   nc1 := nc2 := 0
   dDatNab := CToD( "" )

   lGenStavke := .F.
   IF _TBankTr <> "X"
      IF !Empty( gMetodaNC )
         MsgO( "Racunam stanje na skladistu" )
         kalk_get_nabavna_mag( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         MsgC()
      ENDIF
      IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
      IF gMetodaNC $ "13"; _nc := nc1; ELSEIF gMetodaNC == "2"; _nc := nc2; ENDIF
   ENDIF
   SELECT kalk_pripr

   @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nkols PICT pickol
   @ m_x + 13, m_y + 2    SAY "NAB.CJ   "  GET _NC  PICTURE PicDEM      VALID kalk_valid_kolicina_mag()

   PRIVATE _vpcsappp := 0

   @ m_x + 14, m_y + 2   SAY "VPC      " GET _VPC    PICTURE PicDEM ;
      valid {|| iif( gVarVP == "2" .AND. ( _vpc - _nc ) > 0, cisMarza := ( _vpc - _nc ) / ( 1 + tarifa->vpp ), _vpc - _nc ), ;
      _mpcsapp := _MPCSaPP := ( 1 + _OPP ) * _VPC * ( 1 -_Rabatv / 100 ) * ( 1 + _PPP ), ;
      _mpcsapp := Round( _mpcsapp, 2 ), .T. }

   _RabatV := 0

   @ m_x + 19, m_y + 2  SAY "PPP (%):"; @ Row(), Col() + 2 SAY  _OPP * 100 PICTURE "99.99"
   @ m_x + 19, Col() + 8  SAY "PPU (%):"; @ Row(), Col() + 2  SAY _PPP * 100 PICTURE "99.99"

   @ m_x + 20, m_y + 2 SAY "MPC SA POREZOM:"
   @ m_x + 20, m_y + 50 GET _MPCSaPP  PICTURE PicDEM ;
      valid {|| _mpc := iif( _mpcsapp <> 0,_mpcsapp / ( 1 + _opp ) / ( 1 + _PPP ), _mpc ), ;
      _marza2 := 0, ;
      Marza2R(), ShowGets(), .T. }
   read; ESC_RETURN K_ESC

   nStrana := 2
   _marza := _vpc - _nc

   _MKonto := _Idkonto;_MU_I := "5"     // izlaz iz magacina
   _PKonto := ""; _PU_I := ""

   IF pIzgSt   .AND. _kolicina > 0 .AND. LastKey() <> K_ESC
      // izgenerisane stavke postoje
      PRIVATE nRRec := RecNo()
      GO TOP
      my_flock()
      DO WHILE !Eof()  // nafiluj izgenerisane stavke
         IF kolicina == 0
            SKIP
            PRIVATE nRRec2 := RecNo()
            SKIP -1
            my_delete()
            GO nRRec2
            LOOP
         ENDIF
         IF brdok == _brdok .AND. idvd == _idvd .AND. Val( Rbr ) == nRbr
            nMarza := _VPC * ( 1 -_RabatV / 100 ) -_NC
            REPLACE vpc WITH _vpc, ;
               rabatv WITH _rabatv, ;
               mkonto WITH _mkonto, ;
               tmarza  WITH _tmarza, ;
               mpc     WITH  _MPC, ;
               marza  WITH _vpc - kalk_pripr->nc, ;   // mora se uzeti nc iz ove stavke
            mu_i WITH  _mu_i, ;
               pkonto WITH _pkonto, ;
               pu_i WITH  _pu_i,;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   SET KEY K_ALT_K TO

   RETURN LastKey()
