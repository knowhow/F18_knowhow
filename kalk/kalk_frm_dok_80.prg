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


// ------------------------------------------------------------
// prijem prodavnica, predispozicija
// ------------------------------------------------------------
FUNCTION Get1_80( atrib )

   LOCAL _x := 5
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40
   PRIVATE aPorezi := {}
   PRIVATE fMarza := " "

   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !fnovi

      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY "Temeljnica:" GET _BrFaktP
      @ m_x + _x, Col() + 1 SAY "Datum:" GET _DatFaktP

      ++ _x
      @ m_x + _x, m_y + 2 SAY "Konto zaduzuje/razduzuje:" GET _IdKonto VALID {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x - 1, 40, 20 ) } PICT "@!"

      //IF gNW <> "X"
      //   @ m_x + _x, m_y + 50  SAY "Partner zaduzuje:" GET _IdZaduz PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz )
      //ENDIF

      ++ _x
      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY "Prenos na konto:" GET _IdKonto2 VALID {|| Empty( _idkonto2 ) .OR. P_Konto( @_IdKonto2 ), ispisi_naziv_sifre( F_KONTO, _idkonto2, _kord_x, 30, 20 )  } PICT "@!"

      //IF gNW <> "X"
      //   @ m_x + _x, m_y + 50 SAY "Partner zaduzuje:" GET _IdZaduz2 PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz2 )
      //ENDIF

      READ

      ESC_RETURN K_ESC


   ELSE

      @ m_x + _x, m_y + 2 SAY "Temeljnica: "
      ?? _BrFaktP
      @ m_x + _x, Col() + 2 SAY "Datum: "
      ?? _DatFaktP

      ++ _x

      @ m_x + _x, m_y + 2 SAY "Konto zaduzuje/razduzuje: "
      ?? _IdKonto
      //IF gNW <> "X"
      //   @ m_x + _x, Col() + 2  SAY "Partner zaduzuje: "
      //   ?? _IdZaduz
      //ENDIF

      ++ _x
      @ m_x + _x, m_y + 2 SAY "Prenos na konto: "
      ?? _IdKonto2
      //IF gNW <> "X"
      //   @ m_x + _x, Col() + 2 SAY "Partner zaduzuje: "
      //   ?? _IdZaduz2
      //ENDIF

      READ
      ESC_RETURN K_ESC

   ENDIF

   SELECT kalk_pripr

   _x += 2

   _kord_x := m_x + _x

   IF lKoristitiBK
      @ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba PICT "@!S10" ;
         WHEN {|| _IdRoba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } ;
         VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ) }
   ELSE
      @ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba PICT "@!" ;
         VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ) }
   ENDIF

   @ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _IdTarifa ;
      WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   VTPorezi()

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT roba
   HSEEK _idroba

   SELECT tarifa
   SEEK roba->idtarifa

   SELECT koncij
   SEEK Trim( _idkonto )

   SELECT kalk_pripr

   _pkonto := _idkonto

   kalk_dat_poslj_promjene_prod()
   DuplRoba()

   IF fNovi

      SELECT koncij
      SEEK Trim( _idkonto )

      SELECT roba
      HSEEK _idroba

      _mpcsapp := kalk_get_mpc_by_koncij_pravilo()

      _TMarza2 := "%"
      _TCarDaz := "%"
      _CarDaz := 0

   ENDIF

   SELECT kalk_pripr


   _x += 2 // NC


   _kord_x := m_x + _x

   @ m_x + _x, m_y + 2 SAY "NABAVNA CJENA:"
   @ m_x + _x, m_y + _unos_left GET _nc WHEN VKol( _kord_x - 2 ) PICT PicDEM

   ++ _x
   @ m_x + _x, m_y + 2 SAY "MARZA:" GET _TMarza2 VALID _Tmarza2 $ "%AU" PICT "@!"
   @ m_x + _x, m_y + _unos_left GET _Marza2 PICT PicDEM VALID {|| _vpc := _nc, .T. }
   @ m_x + _x, Col() + 1 GET fMarza PICT "@!"

   ++ _x
   @ m_x + _x, m_y + 2 SAY "MALOPROD. CIJENA (MPC):"
   @ m_x + _x, m_y + _unos_left GET _mpc ;
      PICT PicDEM;
      WHEN W_MPC_( "80", ( fMarza == "F" ), @aPorezi ) ;
      VALID V_Mpc_( "80", ( fMarza == "F" ), @aPorezi )

   ++ _x
   SayPorezi_lv( _x, aPorezi )

   ++ _x
   IF IsPDV()
      @ m_x + _x, m_y + 2 SAY "PC SA PDV:"
   ELSE
      @ m_x + _x, m_y + 2 SAY "MPC SA POREZOM:"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _MPCSaPP PICT PicDEM VALID V_MpcSaPP_( "80", .F., @aPorezi, .T. )

   READ
   ESC_RETURN K_ESC


   SELECT koncij
   SEEK Trim( _idkonto )

   StaviMPCSif( _MpcSapp, .T. )

   SELECT kalk_pripr

   _PKonto := _Idkonto
   _PU_I := "1"
   _MKonto := ""
   _MU_I := ""

   nStrana := 3

   RETURN LastKey()




// PROTUSTAVKA 80-ka, druga strana
// _odlval nalazi se u knjiz, filuje staru vrijenost
// _odlvalb nalazi se u knjiz, filuje staru vrijenost nabavke
FUNCTION Get1_80b()

   LOCAL cSvedi := fetch_metric( "kalk_dok_80_predispozicija_set_cijena", my_user(), " " )
   LOCAL _x := 2
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40
   PRIVATE aPorezi := {}
   PRIVATE PicDEM := "9999999.99999999"

   fnovi := .T.

   PicKol := "999999.999"

   Beep( 1 )

   @ m_x + _x, m_y + 2 SAY "PROTUSTAVKA   ( S - svedi M - mpc sifr i ' ' - ne diraj ):"
   @ m_x + _x, Col() + 2 GET cSvedi VALID cSvedi $ " SM" PICT "@!"

   READ

   // zapamti zadnji unos
   set_metric( "kalk_dok_80_predispozicija_set_cijena", my_user(), cSvedi )

   _x := 12
   _kord_x := m_x + _x

   @ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba PICT "@!" ;
      VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 21, 20 ) }

   @ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" ;
      GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ

   ESC_RETURN K_ESC

   SELECT koncij
   SEEK Trim( _idkonto )

   SELECT kalk_pripr

   _pkonto := _idkonto

   kalk_dat_poslj_promjene_prod()

   PRIVATE fMarza := " "

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   SELECT koncij
   SEEK Trim( _idkonto )

   SELECT ROBA
   HSEEK _idroba

   // ako nije popunjeno
   _mpcsapp := kalk_get_mpc_by_koncij_pravilo()
   _TMarza2 := "%"
   _TCarDaz := "%"
   _CarDaz := 0

   SELECT kalk_pripr

   // NC
   ++ _x

   _kord_x := m_x + _x

   @ m_x + _x, m_y + 2 SAY "NABAVNA CIJENA:"
   @ m_x + _x, m_y + _unos_left GET _NC PICT PicDEM WHEN VKol( _kord_x )

   // MARZA
   ++ _x
   @ m_x + _x, m_y + 2 SAY "MARZA:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICT "@!"
   @ m_x + _x, m_y + _unos_left  GET _Marza2 PICT PicDEM valid {|| _vpc := _nc, .T. }
   @ m_x + _x, Col() + 1 GET fMarza PICT "@!"

   ++ _x
   IF IsPDV()
      @ m_x + _x, m_y + 2  SAY "PROD.CIJENA BEZ PDV:"
   ELSE
      @ m_x + _x, m_y + 2  SAY "MALOPROD. CJENA (MPC):"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _mpc PICT PicDEM ;
      WHEN WMpc_lv( nil, nil, aPorezi ) ;
      VALID VMpc_lv( nil, nil, aPorezi )

   ++ _x

   SayPorezi_lv( _x, aPorezi )

   ++ _x

   IF IsPDV()
      @ m_x + _x, m_y + 2 SAY "P.CIJENA SA PDV:"
   ELSE
      @ m_x + _x, m_y + 2 SAY "MPC SA POREZOM:"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _mpcsapp PICT PicDEM ;
      valid {|| Svedi( cSvedi ), VMpcSapp_lv( nil, nil, aPorezi ) }

   READ

   ESC_RETURN K_ESC

   SELECT koncij
   SEEK Trim( _idkonto )

   StaviMPCSif( _mpcsapp, .T. )

   SELECT kalk_pripr

   _PKonto := _Idkonto
   _PU_I := "1"
   _MKonto := ""
   _MU_I := ""

   nStrana := 3

   RETURN LastKey()





FUNCTION Svedi( cSvedi )

   IF cSvedi == "M"

      SELECT koncij
      SEEK Trim( _idkonto )
      SELECT roba
      HSEEK _idroba
      _mpcsapp := kalk_get_mpc_by_koncij_pravilo()

   ELSEIF cSvedi == "S"

      IF _mpcsapp <> 0
         _kolicina := -Round( _oldval / _mpcsapp, 4 )
      ELSE
         _kolicina := 99999999
      ENDIF

      IF _kolicina <> 0
         _nc := Abs( _oldvaln / _kolicina )
      ELSE
         _nc := 0
      ENDIF
   ENDIF

   RETURN .T.




/* VKol()
 *     Validacija unesene kolicine u dokumentu tipa 80
 */

STATIC FUNCTION VKol( x_kord )

   IF _kolicina < 0


      nKolS := 0
      nKolZN := 0

      nc1 := nc2 := 0

      dDatNab := CToD( "" )

      IF !Empty( gMetodaNC )
         MsgO( "Računam stanje u prodavnici" )
         kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nC1, @nC2, @dDatNab )
         MsgC()
         @ x_kord, m_y + 30 SAY "Ukupno na stanju "
         @ x_kord, Col() + 2 SAY nKols PICT pickol
      ENDIF

      IF dDatNab > _DatDok
         Beep( 1 )
         Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
      ENDIF

      IF _nc == 0
         _nc := nc2
      ENDIF

      IF nKols < Abs( _kolicina )

       sumnjive_stavke_error()

         error_bar( "KA_" + _idkonto + " / " + _idroba, _idkonto + " / " + _idroba + " kolicina:" + ;
            AllTrim( Str( nKols, 12, 3 ) ) +  " treba: " + AllTrim( Str( _kolicina, 12, 3 ) ) )
      ENDIF

      SELECT kalk_pripr

   ENDIF

   RETURN .T.
