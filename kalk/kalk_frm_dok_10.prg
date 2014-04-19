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


// privatne varijable:
// - fNovi
// - nRbr

/*! \fn Get1_10()
 *  \brief Prvi ekran maske za unos dokumenta tipa 10
 */

FUNCTION Get1_10()

   // ovim funkcijama je proslijedjen parametar fnovi kao privatna varijabla
   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1  .OR. !fnovi .OR. gMagacin == "1"
      @  m_x + 6, m_y + 2   SAY "DOBAVLJAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 22 )
      @  m_x + 7, m_y + 2   SAY "Faktura dobavljaca - Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP
      @ m_x + 10, m_y + 2   SAY "Magacinski Konto zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 24 ) PICT "@!"
      IF gNW <> "X"
         @ m_x + 10, m_y + 42  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 24 )
      ENDIF
      IF !Empty( cRNT1 )
         @ m_x + 10, m_y + 42  SAY "Rad.nalog:"   GET _IdZaduz2  PICT "@!"
      ENDIF
      READ
      ESC_RETURN K_ESC
   ELSE
      @ m_x + 6, m_y + 2 SAY "DOBAVLJAC: "
      ?? _IdPartner
      @ m_x + 7, m_y + 2 SAY "Faktura dobavljaca - Broj: "
      ?? _BrFaktP
      @ m_x + 7, Col() + 2 SAY "Datum: "
      ?? _DatFaktP
      @ m_x + 10, m_y + 2 SAY "Magacinski Konto zaduzuje "
      ?? _IdKonto
      IF gNW <> "X"
         @ m_x + 10, m_y + 42 SAY "Zaduzuje: "
         ?? _IdZaduz
      ENDIF
   ENDIF

   @ m_x + 11, m_y + 66 SAY "Tarif.brĿ"

   IF lKoristitiBK
      @ m_x + 12, m_y + 2  SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idroba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } valid  {|| _idroba := iif( Len( Trim( _idroba ) ) < 10, Left( _idroba, 10 ), _idroba ), P_Roba( @_IdRoba ), Reci( 12, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 12, m_y + 2  SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| _idroba := iif( Len( Trim( _idroba ) ) < 10, Left( _idroba, 10 ), _idroba ), P_Roba( @_IdRoba ), Reci( 12, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF

   @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC

   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr

   _MKonto := _Idkonto
   _MU_I := "1"
   DatPosljK()

   SELECT TARIFA
   hseek _IdTarifa 
   SELECT kalk_pripr

   @ m_x + 13, m_y + 2   SAY8 "Količina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   IF fNovi
      SELECT ROBA
      HSEEK _IdRoba
      _VPC := KoncijVPC()
      _TCarDaz := "%"
      _CarDaz := 0
      IF roba->tip = "X"
         _MPCSAPP := roba->mpc   // pohraniti za naftu MPC !!!!
      ENDIF
   ENDIF

   SELECT kalk_pripr

   IF _tmarza <> "%"  // procente ne diraj
      _Marza := 0
   ENDIF

   IF gVarEv == "1"
      @ m_x, m_y + 2   SAY "F.CJ.(DEM/JM):"
      @ m_x, m_y + 50  GET _FCJ PICTURE gPicNC VALID _fcj > 0 WHEN V_kol10()
      @ m_x, m_y + 2   SAY "KASA-SKONTO(%):"
      @ m_x, m_y + 40 GET _Rabat PICTURE PicDEM WHEN DuplRoba()
      IF gNW <> "X"   .OR. gVodiKalo == "D"
         @ m_x, m_y + 2   SAY "Normalni . kalo:"
         @ m_x, m_y + 40  GET _GKolicina PICTURE PicKol
         @ m_x, m_y + 2   SAY "Preko  kalo:    "
         @ m_x, m_y + 40  GET _GKolicin2 PICTURE PicKol
      ENDIF
   ENDIF

   READ
   ESC_RETURN K_ESC

   _FCJ2 := _FCJ * ( 1 -_Rabat / 100 )

   RETURN LastKey()



/* 
 Drugi ekran maske za unos dokumenta tipa 10
 */

FUNCTION Get2_10()

   LOCAL cSPom := " (%,A,U,R) "
   PRIVATE getlist := {}

   IF Empty( _TPrevoz ); _TPrevoz := "%"; ENDIF
   IF Empty( _TCarDaz ); _TCarDaz := "%"; ENDIF
   IF Empty( _TBankTr ); _TBankTr := "%"; ENDIF
   IF Empty( _TSpedTr ); _TSpedtr := "%"; ENDIF
   IF Empty( _TZavTr );  _TZavTr := "%" ; ENDIF
   IF Empty( _TMarza );  _TMarza := "%" ; ENDIF

   @ m_x + 2, m_y + 2     SAY c10T1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
   @ m_x + 2, m_y + 40    GET _Prevoz PICTURE  PicDEM

   @ m_x + 3, m_y + 2     SAY c10T2 + cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" PICT "@!"
   @ m_x + 3, m_y + 40    GET _BankTr PICTURE PicDEM

   @ m_x + 4, m_y + 2     SAY c10T3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AUR" PICT "@!"
   @ m_x + 4, m_y + 40    GET _SpedTr PICTURE PicDEM

   @ m_x + 5, m_y + 2     SAY c10T4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
   @ m_x + 5, m_y + 40    GET _CarDaz PICTURE PicDEM

   @ m_x + 6, m_y + 2     SAY c10T5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
   @ m_x + 6, m_y + 40    GET _ZavTr PICTURE PicDEM ;
      VALID {|| NabCj(), .T. }

   @ m_x + 8, m_y + 2     SAY "NABAVNA CJENA:"
   @ m_x + 8, m_y + 50    GET _NC     PICTURE gPicNC

   IF koncij->naz <> "N1"  // vodi se po vpc
      PRIVATE fMarza := " "
      @ m_x + 10, m_y + 2    SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
      @ m_x + 10, m_y + 40 GET _Marza PICTURE PicDEM
      @ m_x + 10, Col() + 1 GET fMarza PICT "@!" valid {|| Marza( fMarza ), fMarza := " ", .T. }
      IF roba->tip $ "VKX"
         @ m_x + 14, m_y + 2  SAY "VELEPRODAJNA CJENA VT          :"
         @ m_x + 14, m_y + 40 GET _VPC PICT picdem ;
            valid {|| Marza( fMarza ), vvt() }
      ELSE
         IF koncij->naz == "P2"
            @ m_x + 12, m_y + 2    SAY "PLANSKA CIJENA  (PLC)       :"
         ELSE
            @ m_x + 12, m_y + 2    SAY "VELEPRODAJNA CIJENA (VPC)   :"
         ENDIF
         @ m_x + 12, m_y + 50 GET _VPC    PICTURE PicDEM;
            VALID {|| Marza( fMarza ), .T. }

      ENDIF

      IF gMPCPomoc == "D"
         _mpcsapp := roba->mpc
         // VPC se izracunava pomocu MPC cijene !!
         @ m_x + 16, m_y + 2 SAY "MPC SA POREZOM:"
         @ m_x + 16, m_y + 50 GET _MPCSaPP  PICTURE PicDEM ;
            valid {|| _mpcsapp := iif( _mpcsapp = 0, Round( _vpc * ( 1 + TARIFA->opp / 100 ) / ( 1 + TARIFA->PPP / 100 ), 2 ), _mpcsapp ), _mpc := _mpcsapp / ( 1 + TARIFA->opp / 100 ) / ( 1 + TARIFA->PPP / 100 ), ;
            iif( _mpc <> 0, _vpc := Round( _mpc, 2 ), _vpc ), ShowGets(), .T. }

      ENDIF
      READ

      IF gMpcPomoc == "D"
         IF ( roba->mpc == 0 .OR. roba->mpc <> Round( _mpcsapp, 2 ) ) .AND. Pitanje(, "Staviti MPC u sifrarnik" ) == "D"
            SELECT roba; REPLACE mpc WITH _mpcsapp
            SELECT kalk_pripr
         ENDIF
      ENDIF

      SetujVPC( _VPC, .F. )
   ELSE
      READ
      _Marza := 0; _TMarza := "A"; _VPC := _NC
   ENDIF

   _MKonto := _Idkonto; _MU_I := "1"
   nStrana := 3

   RETURN LastKey()



/*! \fn Get1_10s()
 *  \brief
 */

FUNCTION Get1_10s()

   LOCAL nNCpom := 0

   IF nRbr == 1  .OR. !fnovi
      _DatFaktP := _datdok
      @  m_x + 6, m_y + 2   SAY8 "DOBAVLJAČ:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 22 )
      @  m_x + 7, m_y + 2   SAY8 "Faktura dobavljača - Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY8 "Datum:" GET _DatFaktP
      @ m_x + 10, m_y + 2   SAY8 "Magacinski Konto zadužuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 24 ) PICT "@!"

      IF gNW <> "X"
         @ m_x + 10, m_y + 42  SAY8 "Zadužuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 24 )
      ENDIF
      read
      ESC_RETURN K_ESC

   ELSE
      @  m_x + 6, m_y + 2   SAY8 "DOBAVLJAČ: " ; ?? _IdPartner
      @  m_x + 7, m_y + 2   SAY8 "Faktura dobavljaca - Broj: " ; ?? _BrFaktP
      @  m_x + 7, Col() + 2 SAY8 "Datum: " ; ?? _DatFaktP

      @ m_x + 10, m_y + 2   SAY8 "Magacinski Konto zadužuje " ; ?? _IdKonto

      IF gNW <> "X"
         @ m_x + 10, m_y + 42  SAY8 "Zadužuje: "; ?? _IdZaduz
      ENDIF
   ENDIF

   @ m_x + 11, m_y + 66 SAY "Tarif.br "
   
   @ m_x + 12, m_y + 2  SAY "Artikal  " GET _IdRoba PICT "@!" ;
      valid  {|| P_Roba( @_IdRoba ), Reci( 12, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   IF !glEkonomat
      @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )
   ENDIF

   read; ESC_RETURN K_ESC

   SELECT koncij
   SEEK Trim( _IdKonto )
   SELECT TARIFA
   hseek _IdTarifa  // postavi TARIFA na pravu poziciju

   SELECT kalk_pripr  // napuni tarifu
   _MKonto := _Idkonto; _MU_I := "1"

   DatPosljK()
   DuplRoba()


   @ m_x + 13, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   IF fNovi
      SELECT ROBA
      HSEEK _IdRoba
      _VPC := KoncijVPC()
   ENDIF

   SELECT kalk_pripr
   IF _tmarza <> "%"  // procente ne diraj
      _Marza := 0
   ENDIF

   IF gVarEv == "1"

      IF !glEkonomat
         @ m_x + 15, m_y + 2   SAY "F.CJ.(DEM/JM):"
         @ m_x + 15, Col() + 2 GET _FCJ PICTURE gPicNC VALID _fcj > 0 WHEN V_kol10()

         @ m_x + 15, m_y + 36   SAY "Rabat(%):"
         @ m_x + 15, Col() + 2 GET _Rabat PICTURE PicDEM valid {|| _FCJ2 := _FCJ * ( 1 -_Rabat / 100 ), NabCj(), nNCpom := _NC, .T. }
      ENDIF

      @ m_x + 17, m_y + 2     SAY "NABAVNA CJENA:"
      @ m_x + 17, Col() + 2    GET _NC     PICTURE gPicNC VALID NabCj2( _NC, nNCpom )

      IF Empty( _TPrevoz ); _TPrevoz := "%"; ENDIF
      IF Empty( _TCarDaz ); _TCarDaz := "%"; ENDIF
      IF Empty( _TBankTr ); _TBankTr := "%"; ENDIF
      IF Empty( _TSpedTr ); _TSpedtr := "%"; ENDIF
      IF Empty( _TZavTr );  _TZavTr := "%" ; ENDIF
      IF Empty( _TMarza );  _TMarza := "%" ; ENDIF

      IF koncij->naz <> "N1"  // vodi se po vpc
         PRIVATE fMarza := " "
         @ m_x + 17, m_y + 36   SAY "Magacin. Marza   :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
         @ m_x + 17, Col() + 1  GET _Marza PICTURE PicDEM
         @ m_x + 17, Col() + 1 GET fMarza PICT "@!" valid {|| Marza( fMarza ), fMarza := " ", .T. }
         @ m_x + 19, m_y + 2    SAY "VELEPRODAJNA CJENA:"
         @ m_x + 19, Col() + 2  GET _VPC    PICTURE PicDEM;
            VALID {|| Marza( fMarza ), .T. }
         READ

         SetujVpc( _vpc )
      ELSE
         READ
         _Marza := 0; _TMarza := "A"; _VPC := _NC
      ENDIF

   ELSE   // tj. gVarEv=="2" (bez cijena)
      READ
   ENDIF

   _MKonto := _Idkonto; _MU_I := "1"
   nStrana := 3

   RETURN LastKey()



/*! \fn V_kol10()
 *  \brief Validacija unosa kolicine
 */

FUNCTION V_kol10()

   IF _kolicina < 0  // storno
      nKolS := 0;nKolZN := 0;nc1 := nc2 := 0; dDatNab := CToD( "" )
      IF !Empty( gMetodaNC )
         MsgO( "Računam stanje na skladištu" )
         KalkNab( _idfirma, _idroba, _mkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         MsgC()
         @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nkols PICT pickol
      ENDIF
      IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
      IF _idvd == "16"  // storno prijema
         IF gMetodaNC $ "13"; _nc := nc1; ELSEIF gMetodaNC == "2"; _nc := nc2; ENDIF
      ENDIF
      IF nkols < Abs( _kolicina )
         _ERROR := "1"
         Beep( 2 )
         Msg( "Na stanju je samo kolicina:" + Str( nkols, 12, 3 ) )
      ENDIF
      SELECT kalk_pripr
   ENDIF

   RETURN .T.
