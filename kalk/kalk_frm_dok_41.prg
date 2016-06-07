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



// -------------------------------------------------------------
// realizacija prodavnice  41-fakture maloprodaje
// 42-gotovina
// -------------------------------------------------------------

FUNCTION Get1_41()

   pIzgSt := .F.
   // izgenerisane stavke jos ne postoje
   PRIVATE aPorezi := {}

   IF fNovi
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

   IF gNW <> "X"
      @ m_x + 8, m_y + 50  SAY "Razduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
   ENDIF

   _idkonto2 := ""
   _idzaduz2 := ""

   READ


   SELECT kalk_pripr

   ESC_RETURN K_ESC

   @ m_x + 10, m_y + 66 SAY "Tarif.br->"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } VALID VRoba()
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" VALID VRoba()
   ENDIF

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )
   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA
   HSEEK _IdTarifa
   SELECT koncij

   SEEK Trim( _idkonto )
   SELECT kalk_pripr  // napuni tarifu

   _PKonto := _Idkonto

   // provjerava kada je radjen zadnji dokument za ovaj artikal
   DatPosljK()
   DatPosljP()

   _GKolicina := 0
   _GKolicin2 := 0

   IF fNovi

      SELECT koncij
      SEEK Trim( _idkonto )
      SELECT ROBA
      HSEEK _IdRoba
      _MPCSaPP := UzmiMPCSif()

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


   IF IsPdv()
      IF ( dozvoljeno_azuriranje_sumnjivih_stavki() .AND. ( _MpcSAPP == 0 .OR. fNovi ) )
         FaktMPC( @_MPCSAPP, _idfirma + _idkonto + _idroba )
      ENDIF
   ELSE

      // ppp varijanta
      // ovo dole do daljnjeg ostavljamo
      IF ( ( _idvd <> '47' ) .AND. !fnovi .AND. gcijene == "2" .AND. roba->tip != "T" .AND. _MpcSapp = 0 )
         // uzmi mpc sa kartice
         FaktMPC( @_MPCSAPP, _idfirma + _idkonto + _idroba )
      ENDIF

   ENDIF

   IF roba->( FieldPos( "PLC" ) ) <> 0
      // stavi plansku cijenu
      _vpc := roba->plc
   ENDIF

   VtPorezi()

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
            MsgO( "Racunam stanje u prodavnici" )
            KalkNabP( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2 )
            MsgC()
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
      @ m_x + 12, Col() + 2 SAY nkols PICT pickol

      @ m_x + 14, m_y + 2 SAY "NC  :" GET _fcj PICT picdem VALID {|| V_KolPro(), _tprevoz := "A", _prevoz := 0, _nc := _fcj, .T. }

      @ m_x + 15, m_y + 40 SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
      @ m_x + 15, Col() + 1 GET _Marza2 PICTURE  PicDEM

   ENDIF

   IF IsPdv()
      @ m_x + 17, m_y + 2 SAY "PRODAJNA CJENA  (PC):"
   ELSE
      @ m_x + 17, m_y + 2 SAY "MALOPROD. CJENA (MPC):"
   ENDIF

   @ m_x + 17, m_y + 50 GET _mpc PICT PicDEM WHEN W_MPC_( IdVd, .F., @aPorezi ) VALID V_Mpc_( _IdVd, .F., @aPorezi )

   PRIVATE cRCRP := gRCRP

   @ m_x + 18, m_y + 2 SAY "POPUST (C-CIJENA,P-%)" GET cRCRP VALID cRCRP $ "CP" PICT "@!"
   @ m_x + 18, m_y + 50 GET _Rabatv PICT picdem VALID RabProcToC()

   SayPorezi( 19 )

   IF IsPDV()
      @ m_x + 20, m_y + 2 SAY "MPC SA PDV    :"
   ELSE
      @ m_x + 20, m_y + 2 SAY "MPC SA POREZOM:"
   ENDIF

   @ m_x + 20, m_y + 50 GET _mpcsapp PICT PicDEM VALID V_MpcSaPP_( _IdVd, .F., @aPorezi, .T. )

   READ

   ESC_RETURN K_ESC

   // izlaz iz prodavnice
   _PKonto := _Idkonto
   _PU_I := "5"
   nStrana := 2

   FillIzgStavke( pIzgSt )

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
