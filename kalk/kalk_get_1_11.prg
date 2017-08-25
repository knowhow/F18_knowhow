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



FUNCTION kalk_get_1_11()

   LOCAL lRet

   pIzgSt := .F.   // izgenerisane stavke jos ne postoje

   IF nRbr == 1 .AND. kalk_is_novi_dokument()
      _DatFaktP := _datdok
   ENDIF

   PRIVATE aPorezi := {}

   IF nRbr == 1  .OR. !kalk_is_novi_dokument()
      _GKolicina := _GKolicin2 := 0
      IF _IdVD $ "11#12#13#22"
         _IdPartner := ""
         @  box_x_koord() + 6, box_y_koord() + 2   SAY "Otpremnica - Broj:" GET _BrFaktP
         @  box_x_koord() + 6, Col() + 2 SAY "Datum:" GET _DatFaktP
      ENDIF

      @ box_x_koord() + 8, box_y_koord() + 2   SAY8 "Prodavnički Konto zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"
      // IF gNW <> "X"
      // @ box_x_koord() + 8, box_y_koord() + 42  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz, 24 )
      // ENDIF

      @ box_x_koord() + 9, box_y_koord() + 2   SAY8 "Magacinski konto razdužuje"  GET _IdKonto2 ;
         VALID Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 )
      // IF gNW <> "X"
      // @ box_x_koord() + 9, box_y_koord() + 42 SAY "Razduzuje:" GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. p_partner( @_IdZaduz2, 24 )
      // ENDIF
      read; ESC_RETURN K_ESC
   ELSE
      IF _IdVD $ "11#12#13#22"
         @  box_x_koord() + 6, box_y_koord() + 2   SAY "Otpremnica - Broj: "; ?? _BrFaktP
         @  box_x_koord() + 6, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      ENDIF
      @ box_x_koord() + 8, box_y_koord() + 2   SAY8 "Prodavnicki Konto zadužuje "; ?? _IdKonto
      // IF gNW <> "X"
      // @ box_x_koord() + 8, box_y_koord() + 42  SAY "Zaduzuje: "; ?? _IdZaduz
      // ENDIF
      @ box_x_koord() + 9, box_y_koord() + 2   SAY8 "Magacinski konto razdužuje "; ?? _IdKonto2
      // IF gNW <> "X"
      // @ box_x_koord() + 9, box_y_koord() + 42  SAY "Razduzuje: "; ?? _IdZaduz2
      // ENDIF
   ENDIF

   @ box_x_koord() + 10, box_y_koord() + 66 SAY "Tarifa ->"

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), box_x_koord() + 11, box_y_koord() + 2, @aPorezi )
   /*
   IF roba_barkod_pri_unosu()
    --  @ box_x_koord() + 11, box_y_koord() + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val(-- gDuzSifIni ) ), .T. } VALID VRoba()
   ELSE
    --  @ box_x_koord() + 11, box_y_koord() + 2   SAY "Artikal  " GET _IdRoba PICT "@!" VALID VRoba()
   ENDIF
*/
   @ box_x_koord() + 11, box_y_koord() + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   @ box_x_koord() + 12, box_y_koord() + 2   SAY8 "Količina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   _MKonto := _Idkonto2
   _PKonto := _Idkonto

   select_o_koncij( _pkonto )


   SELECT kalk_pripr  // napuni tarifu

   // check_datum_posljednje_kalkulacije()
   // kalk_dat_poslj_promjene_prod()
   // DuplRoba()


   _GKolicina := _GKolicin2 := 0
   IF kalk_is_novi_dokument()
      // SELECT roba
      _MPCSaPP := kalk_get_mpc_by_koncij_pravilo( _pkonto )

      SELECT roba
      _FCJ := NC
      _VPC := NC

      SELECT kalk_pripr
      _Marza2 := 0
      _TMarza2 := "A"
   ENDIF

   IF nije_dozvoljeno_azuriranje_sumnjivih_stavki() .OR. Round( _VPC, 3 ) = 0 // uvijek nadji
      select_o_koncij( _mkonto )
      SELECT kalk_pripr  // magacin
      kalk_vpc_po_kartici( @_VPC, _idfirma, _mkonto, _idroba )

      select_o_koncij( _pkonto )
      SELECT kalk_pripr  // magacin
   ENDIF

   set_pdv_public_vars()

   nKolS := 0
   nKolZN := 0
   nc1 := 0
   nc2 := 0
   lGenStavke := .F.
   IF _TBankTr <> "X"
      IF !Empty( kalk_metoda_nc() )
         nc1 := nc2 := 0
         dDatNab := CToD( "" )
         IF _kolicina > 0
            kalk_get_nabavna_mag( _datdok, _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         ELSE
            kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, dDatNab )

         ENDIF
         IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
         IF kalk_metoda_nc() $ "13"; _fcj := nc1; ELSEIF kalk_metoda_nc() == "2"; _fcj := nc2; ENDIF
      ENDIF
   ENDIF

   IF _kolicina > 0
      @ box_x_koord() + 12, box_y_koord() + 30   SAY "Na stanju magacin "; @ box_x_koord() + 12, Col() + 2 SAY nkols PICT pickol
   ELSE
      @ box_x_koord() + 12, box_y_koord() + 30   SAY "Na stanju prodavn "; @ box_x_koord() + 12, Col() + 2 SAY nkols PICT pickol
   ENDIF

   select_o_koncij( _idkonto2 )
   SELECT kalk_pripr


   _vpc := _fcj
   @ box_x_koord() + 14, box_y_koord() + 2    SAY "NABAVNA CIJENA (NC)       :"
   IF _kolicina > 0
      @ box_x_koord() + 14, box_y_koord() + 50   GET _FCj   PICTURE gPicNC ;
         VALID {|| lRet := kalk_valid_kolicina_mag(), _vpc := _fcj, lRet }
   ELSE
      @ box_x_koord() + 14, box_y_koord() + 50   GET _FCJ   PICTURE PicDEM;
         VALID {|| lRet := kalk_valid_kolicina_prod(), _vpc := _fcj, lRet }
   ENDIF


   // prodavnica
   select_o_koncij( _idkonto )
   SELECT kalk_pripr

   IF kalk_is_novi_dokument()
      _TPrevoz := "R"
   ENDIF

   IF nRBr == 1 .OR. !kalk_is_novi_dokument() // prva stavka
      @ box_x_koord() + 15, box_y_koord() + 2 SAY "MP trosak (A,R):" GET _TPrevoz VALID _tPrevoz $ "AR"
      @ box_x_koord() + 15, Col() + 2 GET _prevoz PICT PICDEM
   ELSE
      @ box_x_koord() + 15, box_y_koord() + 2 SAY "MP trosak:"; ?? "(" + _tPrevoz + ") "; ?? _prevoz
   ENDIF

   PRIVATE cProracunMarzeUnaprijed := " "
   @ box_x_koord() + 16, box_y_koord() + 2 SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
   @ box_x_koord() + 16, Col() + 1  GET _Marza2 PICTURE  PicDEM ;
      VALID {|| _nc := _fcj + iif( _TPrevoz == "A", _Prevoz, 0 ), ;
      _Tmarza := "A", ;
      _marza := _vpc / ( 1 + _PORVT ) - _fcj, .T. }
   @ box_x_koord() + 16, Col() + 1 GET cProracunMarzeUnaprijed PICT "@!"   VALID {|| kalk_Marza_11( cProracunMarzeUnaprijed ), cProracunMarzeUnaprijed := " ", .T. }


   @ box_x_koord() + 18, box_y_koord() + 2  SAY "PRODAJNA CJENA       :"


   @ box_x_koord() + 18, box_y_koord() + 50 GET _MPC PICTURE PicDEM VALID VMpc( .F., cProracunMarzeUnaprijed ) WHEN WMpc( .F., cProracunMarzeUnaprijed )

   SayPorezi( 19 )


   @ box_x_koord() + 20, box_y_koord() + 2 SAY "PROD.C. SA PDV:"

   @ box_x_koord() + 20, box_y_koord() + 50 GET _MPCSaPP  PICTURE PicDEM VALID VMPCSaPP( .F., cProracunMarzeUnaprijed )

   READ
   ESC_RETURN K_ESC

   select_o_koncij( _idkonto )
   StaviMPCSif( _mpcsapp, .T. )       // .t. znaci sa upitom
   SELECT kalk_pripr

   // izlaz iz magacina
   _MKonto := _Idkonto2
   _MU_I := "5"

   // ulaz u prodavnicu
   _PKonto := _Idkonto
   _PU_I := "1"

   nStrana := 2

   kalk_puni_polja_za_izgenerisane_stavke( pIzgSt )

   RETURN LastKey()
