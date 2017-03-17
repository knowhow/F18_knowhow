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

   SET KEY K_ALT_K TO kalk_kartica_magacin_pomoc_unos_14()

   IF nRbr == 1 .OR. !kalk_is_novi_dokument()
      @  form_x_koord() + 7, form_y_koord() + 2   SAY "Faktura Broj:" GET _BrFaktP
      @  form_x_koord() + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   ;
         VALID {|| .T. }
      _IdZaduz := ""

      _Idkonto2 := ""

      @ form_x_koord() + 9, form_y_koord() + 2 SAY "Magacinski konto razduzuje"  GET _IdKonto ;
         VALID Empty( _IdKonto ) .OR. P_Konto( @_IdKonto, 21, 5 )
      // IF gNW <> "X"
      // @ form_x_koord() + 9, form_y_koord() + 40 SAY "Razduzuje:" GET _IdZaduz   PICT "@!"  VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz, 21, 5 )
      // ENDIF
   ELSE
      // @  form_x_koord()+6,form_y_koord()+2   SAY "KUPAC: "; ?? _IdPartner
      @  form_x_koord() + 7, form_y_koord() + 2   SAY "Faktura Broj: "; ?? _BrFaktP
      @  form_x_koord() + 7, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      _IdZaduz := ""
      _Idkonto2 := ""
      @ form_x_koord() + 9, form_y_koord() + 2 SAY "Magacinski konto razduzuje "; ?? _IdKonto
      // IF gNW <> "X"
      // @ form_x_koord() + 9, form_y_koord() + 40 SAY "Razduzuje: "; ?? _IdZaduz
      // ENDIF
   ENDIF

   @ form_x_koord() + 10, form_y_koord() + 66 SAY "Tarif.br->"


   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), form_x_koord() + 11, form_y_koord() + 2, @aPorezi )


   @ form_x_koord() + 11, form_y_koord() + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   select_o_tarifa( _IdTarifa )
   select_o_koncij( _idkonto )

   SELECT kalk_pripr  // napuni tarifu

   _MKonto := _Idkonto2
   // DuplRoba()
   // check_datum_posljednje_kalkulacije()

   @ form_x_koord() + 12, form_y_koord() + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   _GKolicina := 0

   IF kalk_is_novi_dokument()

      select_o_roba( _IdRoba )
      _VPC := KoncijVPC()
      _NC := NC
   ENDIF

   IF dozvoljeno_azuriranje_sumnjivih_stavki() .AND. kalk_is_novi_dokument()
      kalk_vpc_po_kartici( @_VPC, _idfirma, _idkonto, _idroba )
      SELECT kalk_pripr
   ENDIF
   set_pdv_public_vars()

   nKolS := 0
   nKolZN := 0
   nc1 := nc2 := 0
   dDatNab := CToD( "" )

   lGenStavke := .F.
   IF _TBankTr <> "X"

      kalk_get_nabavna_mag( _datdok, _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )

      IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
      IF kalk_metoda_nc() $ "13"; _nc := nc1; ELSEIF kalk_metoda_nc() == "2"; _nc := nc2; ENDIF
   ENDIF
   SELECT kalk_pripr

   @ form_x_koord() + 12, form_y_koord() + 30   SAY "Ukupno na stanju "; @ form_x_koord() + 12, Col() + 2 SAY nkols PICT pickol
   @ form_x_koord() + 13, form_y_koord() + 2    SAY "NAB.CJ   "  GET _NC  PICTURE PicDEM      VALID kalk_valid_kolicina_mag()

   PRIVATE _vpcsappp := 0

   @ form_x_koord() + 14, form_y_koord() + 2   SAY "VPC      " GET _VPC    PICTURE PicDEM ;
      VALID {|| iif( gVarVP == "2" .AND. ( _vpc - _nc ) > 0, cisMarza := ( _vpc - _nc ) / ( 1 + tarifa->vpp ), _vpc - _nc ), ;
      _mpcsapp := _MPCSaPP := ( 1 + _OPP ) * _VPC * ( 1 - _Rabatv / 100 ) * ( 1 + _PPP ), ;
      _mpcsapp := Round( _mpcsapp, 2 ), .T. }

   _RabatV := 0

   @ form_x_koord() + 19, form_y_koord() + 2  SAY "PPP (%):"; @ Row(), Col() + 2 SAY  _OPP * 100 PICTURE "99.99"
   @ form_x_koord() + 19, Col() + 8  SAY "PPU (%):"; @ Row(), Col() + 2  SAY _PPP * 100 PICTURE "99.99"

   @ form_x_koord() + 20, form_y_koord() + 2 SAY "MPC SA POREZOM:"
   @ form_x_koord() + 20, form_y_koord() + 50 GET _MPCSaPP  PICTURE PicDEM ;
      VALID {|| _mpc := iif( _mpcsapp <> 0, _mpcsapp / ( 1 + _opp ) / ( 1 + _PPP ), _mpc ), ;
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
            nMarza := _VPC * ( 1 - _RabatV / 100 ) - _NC
            REPLACE vpc WITH _vpc, ;
               rabatv WITH _rabatv, ;
               mkonto WITH _mkonto, ;
               tmarza  WITH _tmarza, ;
               mpc     WITH  _MPC, ;
               marza  WITH _vpc - kalk_pripr->nc, ;   // mora se uzeti nc iz ove stavke
               mu_i WITH  _mu_i, ;
               pkonto WITH _pkonto, ;
               pu_i WITH  _pu_i, ;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   SET KEY K_ALT_K TO

   RETURN LastKey()
