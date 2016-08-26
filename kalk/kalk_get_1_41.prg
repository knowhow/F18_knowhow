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



FUNCTION kalk_get_1_41()

   LOCAL lRet

   pIzgSt := .F. // izgenerisane stavke jos ne postoje
   PRIVATE aPorezi := {}

   IF kalk_is_novi_dokument()
      _DatFaktP := _datdok
   ENDIF

   IF _idvd == "41"

      @  m_x + 6,  m_y + 2 SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 5, 30 )
      @  m_x + 7,  m_y + 2 SAY "Faktura Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP

   ELSEIF _idvd == "43"

      @  m_x + 6,  m_y + 2 SAY "DOBAVLJAC KOMIS.ROBE:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 5, 30 )

   ELSE

      _idpartner := ""
      _brfaktP := ""

   ENDIF


   @ m_x + 8, m_y + 2   SAY "Prodavnicki Konto razduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"

   // IF gNW <> "X"
   // @ m_x + 8, m_y + 50  SAY "Razduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
   // ENDIF

   _idkonto2 := ""
   _idzaduz2 := ""

   READ


   SELECT kalk_pripr
   ESC_RETURN K_ESC

   @ m_x + 10, m_y + 66 SAY "Tarif.br->"

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _idVd, kalk_is_novi_dokument(), m_x + 11, m_y + 2, @aPorezi )
/*
   IF roba_barkod_pri_unosu()
      --@ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( --gDuzSifIni ) ), .T. } VALID VRoba()
   ELSE
      --@ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" VALID VRoba()
   ENDIF
*/
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )
   @ m_x + 12, m_y + 2  SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA
   HSEEK _IdTarifa
   SELECT koncij

   SEEK _idkonto
   SELECT kalk_pripr  // napuni tarifu

   _PKonto := _Idkonto


   // check_datum_posljednje_kalkulacije()
   // kalk_dat_poslj_promjene_prod()

   _GKolicina := 0
   _GKolicin2 := 0

   IF kalk_is_novi_dokument()

      SELECT koncij
      SEEK Trim( _idkonto )
      SELECT ROBA
      HSEEK _IdRoba
      _MPCSaPP := kalk_get_mpc_by_koncij_pravilo()

      IF gMagacin == "2"
         _FCJ := NC
         _VPC := 0
      ELSE
         _FCJ := NC
         _VPC := 0
      ENDIF

      SELECT kalk_pripr
      _Marza2 := 0
      _TMarza2 := "A"

   ENDIF

   IF ( dozvoljeno_azuriranje_sumnjivih_stavki() .AND. ( _MpcSAPP == 0 .OR. kalk_is_novi_dokument() ) )
      kalk_fakticka_mpc( @_MPCSAPP, _idfirma, _idkonto, _idroba )
   ENDIF


   IF roba->( FieldPos( "PLC" ) ) <> 0

      _vpc := roba->plc // stavi plansku cijenu
   ENDIF

   set_pdv_public_vars()

   IF ( ( _idvd <> "47" ) .AND. roba->tip != "T" )


      nKolS := 0
      nKolZN := 0
      nc1 := 0
      nc2 := 0
      dDatNab := CToD( "" )
      lGenStavke := .F.

      // ako je X onda su stavke vec izgenerisane
      IF _TBankTr <> "X"
         IF !Empty( gMetodaNC )
            nc1 := 0
            nc2 := 0

            kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2 )

            IF dDatNab > _DatDok
               Beep( 1 )
               Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
            ENDIF
            IF gMetodaNC $ "13"
               _fcj := nc1
            ELSEIF gMetodaNC == "2"
               _fcj := nc2
            ENDIF
         ENDIF
      ENDIF

      @ m_x + 12, m_y + 30 SAY "Ukupno na stanju "
      @ m_x + 12, Col() + 2 SAY nKols PICT pickol

      @ m_x + 14, m_y + 2 SAY "NC  :" GET _fcj PICT picdem ;
         VALID {|| lRet := kalk_valid_kolicina_prod(), _tprevoz := "A", _prevoz := 0, _nc := _fcj, lRet }

      @ m_x + 15, m_y + 40 SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
      @ m_x + 15, Col() + 1 GET _Marza2 PICTURE  PicDEM

   ENDIF


   @ m_x + 17, m_y + 2 SAY "PRODAJNA CJENA  (PC):"


   @ m_x + 17, m_y + 50 GET _mpc PICT PicDEM WHEN W_MPC_( IdVd, .F., @aPorezi ) VALID V_Mpc_( _IdVd, .F., @aPorezi )

   PRIVATE cRCRP := gRCRP

   @ m_x + 18, m_y + 2 SAY "POPUST (C-CIJENA,P-%)" GET cRCRP VALID cRCRP $ "CP" PICT "@!"
   @ m_x + 18, m_y + 50 GET _Rabatv PICT picdem VALID RabProcToC()

   SayPorezi( 19 )

   @ m_x + 20, m_y + 2 SAY "MPC SA PDV    :"

   @ m_x + 20, m_y + 50 GET _mpcsapp PICT PicDEM VALID V_MpcSaPP_( _IdVd, .F., @aPorezi, .T. )

   READ

   ESC_RETURN K_ESC


   _PKonto := _Idkonto
   _PU_I := "5" // izlaz iz prodavnice
   nStrana := 2

   kalk_puni_polja_za_izgenerisane_stavke( pIzgSt )

   RETURN LastKey()



// ------------------------------------------
// racuna rabat za stavku...
// ------------------------------------------
STATIC FUNCTION RabProcToC()

   IF cRCRP == "P"
      _rabatv := _mpc * ( _rabatv / 100 )
      cRCRP := "C"
      ShowGets()
   ENDIF

   RETURN .T.
