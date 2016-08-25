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


FUNCTION kalk_get_1_12()

   LOCAL lRet

   pIzgSt := .F.   // izgenerisane stavke jos ne postoje
   PRIVATE aPorezi := {}

   _GKolicina := _GKolicin2 := 0
   _IdPartner := ""
   IF nRbr == 1 .OR. !fnovi
      @ m_x + 6, m_y + 2   SAY "Otpremnica - Broj:" GET _BrFaktP
      @ m_x + 6, Col() + 2 SAY "Datum:" GET _DatFaktP
      _DatFaktP := _datdok

      @ m_x + 8, m_y + 2   SAY "Prodavnicki konto razduzuje " GET _IdKonto VALID P_Konto( @_IdKonto, 21, 5 ) PICT "@!"

      // IF gNW <> "X"
      // @ m_x + 8, m_y + 40  SAY "Razduzuje "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
      // ENDIF

      @ m_x + 9, m_y + 2   SAY "Magacinski konto zaduzuje   "  GET _IdKonto2 ;
         VALID Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 24 )
      // IF gNW <> "X"
      // @ m_x + 9, m_y + 40  SAY "Zaduzuje  " GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. P_Firma( @_IdZaduz2, 21, 5 )
      // ENDIF
      read; ESC_RETURN K_ESC
   ELSE
      @ m_x + 6, m_y + 2   SAY "Otpremnica - Broj: "; ?? _BrFaktP
      @ m_x + 6, Col() + 2 SAY "Datum: "; ??  _DatFaktP

      @ m_x + 8, m_y + 2   SAY "Prodavnicki konto razduzuje "; ?? _IdKonto

      @ m_x + 9, m_y + 2   SAY "Magacinski konto zaduzuje   "; ?? _IdKonto2
   ENDIF
   @ m_x + 10, m_y + 66 SAY "Tarif.br->"

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, fNovi, m_x + 11, m_y + 2, @aPorezi )
   /*
   IF roba_barkod_pri_unosu()
    --  @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( --gDuzSifIni ) ), .T. } VALID VRoba()
   ELSE
    --  @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" VALID VRoba()
   ENDIF
   */

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr

   _PKonto := _Idkonto
   _MKonto := _Idkonto2
   //kalk_dat_poslj_promjene_prod()
   //check_datum_posljednje_kalkulacije()
   // DuplRoba()

   _GKolicina := 0

   IF fNovi
      SELECT koncij
      SEEK Trim( _idkonto )
      SELECT ROBA
      HSEEK _IdRoba

      _MPCSaPP := kalk_get_mpc_by_koncij_pravilo()


      _FCJ := NC
      _VPC := NC

      SELECT kalk_pripr
      _Marza2 := 0
      _TMarza2 := "A"
   ENDIF

   IF nije_dozvoljeno_azuriranje_sumnjivih_stavki()
      kalk_fakticka_mpc( @_Mpcsapp, _idfirma, _pkonto, _idroba )
      kalk_vpc_po_kartici( @_VPC, _idfirma, _mkonto, _idroba )
   ENDIF

   set_pdv_public_vars()

   nKolS := 0;nKolZN := 0;nc1 := nc2 := 0;dDatNab := CToD( "" )
   lGenStavke := .F.
   IF _TBankTr <> "X"
      IF !Empty( gMetodaNC )
         // MsgO( "Racunam stanje na skladistu" )
         kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, dDatNab )
         // MsgC()
         IF dDatNab > _DatDok
            Beep( 1 )
            Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
         ENDIF
         IF gMetodaNC $ "13"; _fcj := nc1; ELSEIF gMetodaNC == "2"; _fcj := nc2; ENDIF
      ENDIF
   ENDIF

   @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nkols PICT pickol

   @ m_x + 14, m_y + 2    SAY "NABAVNA CIJENA (NC)         :"
   @ m_x + 14, m_y + 50   GET _FCJ    PICTURE PicDEM VALID {|| lRet := kalk_valid_kolicina_prod(), _vpc := _fcj, lRet }


   _TPrevoz := "R"

   @ m_x + 16, m_y + 2  SAY8 "MP marža:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
   @ m_x + 16, Col() + 1  GET _Marza2 PICTURE  PicDEM ;
      valid {|| _nc := _fcj + iif( _TPrevoz == "A", _Prevoz, 0 ), _Tmarza := "A", ;                // VP marza
      _marza := _vpc / ( 1 + _PORVT ) -_fcj, .T. }       // VP marza

   @ m_x + 17, m_y + 2  SAY "MALOPROD. CJENA (MPC):"
   @ m_x + 17, m_y + 50 GET _MPC PICT PicDEM WHEN WMpc() VALID VMpc()

   SayPorezi( 19 )

   IF IsPDV()
      @ m_x + 19, m_y + 2 SAY "MPC SA PDV    :"
   ELSE
      @ m_x + 19, m_y + 2 SAY "MPC SA POREZOM:"
   ENDIF

   @ m_x + 19, m_y + 50 GET _MPCSaPP PICT PicDEM VALID VMpcSaPP()

   READ

   ESC_RETURN K_ESC

   nStrana := 2

   _MKonto := _Idkonto2;_MU_I := "1"
   _PKonto := _Idkonto; _PU_I := "5"

   kalk_puni_polja_za_izgenerisane_stavke( pIzgSt )

   RETURN LastKey()
