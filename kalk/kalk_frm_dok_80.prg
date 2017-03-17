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

   LOCAL nX := 5
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40
   PRIVATE aPorezi := {}
   PRIVATE fMarza := " "

   IF nRbr == 1 .AND. kalk_is_novi_dokument()
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !kalk_is_novi_dokument()

      _kord_x := form_x_koord() + nX

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Temeljnica:" GET _BrFaktP
      @ form_x_koord() + nX, Col() + 1 SAY "Datum:" GET _DatFaktP

      ++nX
      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Konto zaduzuje/razduzuje:" GET _IdKonto VALID {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x - 1, 40, 20 ) } PICT "@!"

      // IF gNW <> "X"
      // @ form_x_koord() + nX, form_y_koord() + 50  SAY "Partner zaduzuje:" GET _IdZaduz PICT "@!" VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz )
      // ENDIF

      ++nX
      _kord_x := form_x_koord() + nX

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Prenos na konto:" GET _IdKonto2 VALID {|| Empty( _idkonto2 ) .OR. P_Konto( @_IdKonto2 ), ispisi_naziv_sifre( F_KONTO, _idkonto2, _kord_x, 30, 20 )  } PICT "@!"

      // IF gNW <> "X"
      // @ form_x_koord() + nX, form_y_koord() + 50 SAY "Partner zaduzuje:" GET _IdZaduz2 PICT "@!" VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz2 )
      // ENDIF

      READ

      ESC_RETURN K_ESC


   ELSE

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Temeljnica: "
      ?? _BrFaktP
      @ form_x_koord() + nX, Col() + 2 SAY "Datum: "
      ?? _DatFaktP

      ++nX

      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Konto zaduzuje/razduzuje: "
      ?? _IdKonto
      // IF gNW <> "X"
      // @ form_x_koord() + nX, Col() + 2  SAY "Partner zaduzuje: "
      // ?? _IdZaduz
      // ENDIF

      ++nX
      @ form_x_koord() + nX, form_y_koord() + 2 SAY "Prenos na konto: "
      ?? _IdKonto2
      // IF gNW <> "X"
      // @ form_x_koord() + nX, Col() + 2 SAY "Partner zaduzuje: "
      // ?? _IdZaduz2
      // ENDIF

      READ
      ESC_RETURN K_ESC

   ENDIF

   SELECT kalk_pripr

   nX += 2

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), form_x_koord() + nX, form_y_koord() + 2, @aPorezi )

   @ form_x_koord() + nX, form_y_koord() + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _IdTarifa  WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   set_pdv_public_vars()

   ++nX
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   select_o_roba( _idroba )

   select_o_tarifa( roba->idtarifa )
   select_o_koncij( _idkonto )

   SELECT kalk_pripr

   _pkonto := _idkonto

   // kalk_dat_poslj_promjene_prod()
   // DuplRoba()

   IF kalk_is_novi_dokument()

      select_o_koncij( _idkonto )
      select_o_roba( _idroba )

      _mpcsapp := kalk_get_mpc_by_koncij_pravilo()

      _TMarza2 := "%"
      _TCarDaz := "%"
      _CarDaz := 0

   ENDIF

   SELECT kalk_pripr


   nX += 2 // NC


   _kord_x := form_x_koord() + nX

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "NABAVNA CJENA:"
   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _nc WHEN VKol( _kord_x - 2 ) PICT PicDEM

   ++nX
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "MARZA:" GET _TMarza2 VALID _Tmarza2 $ "%AU" PICT "@!"
   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _Marza2 PICT PicDEM VALID {|| _vpc := _nc, .T. }
   @ form_x_koord() + nX, Col() + 1 GET fMarza PICT "@!"

   ++nX
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "MALOPROD. CIJENA (MPC):"
   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _mpc ;
      PICT PicDEM;
      WHEN W_MPC_( "80", ( fMarza == "F" ), @aPorezi ) ;
      VALID V_Mpc_( "80", ( fMarza == "F" ), @aPorezi )

   ++nX
   SayPorezi_lv( nX, aPorezi )

   ++nX

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "PC SA PDV:"


   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _MPCSaPP PICT PicDEM VALID V_MpcSaPP_( "80", .F., @aPorezi, .T. )

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
FUNCTION kalk_get_1_80_protustavka()

   LOCAL cSvedi := fetch_metric( "kalk_dok_80_predispozicija_set_cijena", my_user(), " " )
   LOCAL nX := 2
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40
   PRIVATE aPorezi := {}
   PRIVATE PicDEM := "9999999.99999999"

   kalk_is_novi_dokument( .T. )


   PicKol := "999999.999"

   Beep( 1 )

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "PROTUSTAVKA   ( S - svedi M - mpc sifr i ' ' - ne diraj ):"
   @ form_x_koord() + nX, Col() + 2 GET cSvedi VALID cSvedi $ " SM" PICT "@!"

   READ


   set_metric( "kalk_dok_80_predispozicija_set_cijena", my_user(), cSvedi ) // zapamti zadnji unos

   nX := 12
   _kord_x := form_x_koord() + nX

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), form_x_koord() + nX, form_y_koord() + 2, @aPorezi )



   @ form_x_koord() + nX, form_y_koord() + ( MAXCOLS() - 20 ) SAY "Tarifa:" ;
      GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ

   ESC_RETURN K_ESC

   select_o_koncij( _idkonto )

   SELECT kalk_pripr

   _pkonto := _idkonto

   // kalk_dat_poslj_promjene_prod()

   PRIVATE fMarza := " "

   ++nX
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   SELECT koncij
   SEEK Trim( _idkonto )

   select_o_roba( _idroba )

   // ako nije popunjeno
   _mpcsapp := kalk_get_mpc_by_koncij_pravilo()
   _TMarza2 := "%"
   _TCarDaz := "%"
   _CarDaz := 0

   SELECT kalk_pripr

   // NC
   ++nX

   _kord_x := form_x_koord() + nX

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "NABAVNA CIJENA:"
   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _NC PICT PicDEM WHEN VKol( _kord_x )

   // MARZA
   ++nX
   @ form_x_koord() + nX, form_y_koord() + 2 SAY "MARZA:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICT "@!"
   @ form_x_koord() + nX, form_y_koord() + _unos_left  GET _Marza2 PICT PicDEM VALID {|| _vpc := _nc, .T. }
   @ form_x_koord() + nX, Col() + 1 GET fMarza PICT "@!"

   ++nX

   @ form_x_koord() + nX, form_y_koord() + 2  SAY "PROD.CIJENA BEZ PDV:"


   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _mpc PICT PicDEM ;
      WHEN WMpc_lv( NIL, NIL, aPorezi ) ;
      VALID VMpc_lv( NIL, NIL, aPorezi )

   ++nX

   SayPorezi_lv( nX, aPorezi )

   ++nX

   @ form_x_koord() + nX, form_y_koord() + 2 SAY "P.CIJENA SA PDV:"


   @ form_x_koord() + nX, form_y_koord() + _unos_left GET _mpcsapp PICT PicDEM ;
      VALID {|| Svedi( cSvedi ), VMpcSapp_lv( NIL, NIL, aPorezi ) }

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
      select_o_roba( _idroba )
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


      kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nC1, @nC2, @dDatNab )

      @ x_kord, form_y_koord() + 30 SAY "Ukupno na stanju "
      @ x_kord, Col() + 2 SAY nKols PICT pickol


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
