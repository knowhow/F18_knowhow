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

STATIC aPorezi := {}


// direktni ulaz u prodavnicu
FUNCTION kalk_unos_dok_81( atrib )

   LOCAL _x := 5
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40
   LOCAL _use_opis := .F.
   LOCAL _use_rok := .F.
   LOCAL _opis := Space( 300 )
   LOCAL _rok := CToD( "" )
   LOCAL _krabat := NIL

   IF hb_HHasKey( atrib, "opis" )
      _use_opis := .T.
   ENDIF

   IF hb_HHasKey( atrib, "rok" )
      _use_rok := .T.
   ENDIF

   IF _use_opis
      IF !fNovi
         _opis := PadR( atrib[ "opis" ], 300 )
      ENDIF
   ENDIF

   IF _use_rok
      IF !fNovi
         _rok := CToD( AllTrim( atrib[ "rok" ] ) )
      ENDIF
   ENDIF

   __k_val := "N"

   IF nRbr == 1 .AND. fNovi
      _datfaktp := _datdok
   ENDIF

   IF nRbr == 1 .OR. !fNovi

      ++ _x
      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY8 "DOBAVLJAČ:" GET _IdPartner PICT "@!" ;
         VALID {|| Empty( _IdPartner ) .OR. P_Firma( @_IdPartner ), ispisi_naziv_sifre( F_PARTN, _idpartner, _kord_x - 1, 22, 20 ) }
      @ m_x + _x, 50 SAY "Broj fakture:" GET _brfaktp
      @ m_x + _x, Col() + 1 SAY "Datum:" GET _datfaktp

      ++ _x
      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY8 "Konto zadužuje:" GET _idkonto ;
         VALID {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x, 40, 30 ) } PICT "@!"

      // IF gNW <> "X"
      // @ m_x + _x, m_y + 42 SAY8 "Zadužuje: " GET _idzaduz PICT "@!" VALID Empty( _idzaduz ) .OR. P_Firma( @_idzaduz )
      // ENDIF

      READ

      ESC_RETURN K_ESC

   ELSE

      ++ _x
      @ m_x + _x, m_y + 2 SAY8 "DOBAVLJAČ: "
      ?? _idpartner
      @  m_x + _x, Col() + 1 SAY "Faktura broj: "
      ?? _brfaktp
      @  m_x + _x, Col() + 1 SAY "Datum: "
      ?? _datfaktp

      ++ _x

      @ m_x + _x, m_y + 2 SAY "Konto zaduzuje: "
      ?? _idkonto

      // IF gNW <> "X"
      // @  m_x + _x, m_y + 42 SAY "Zaduzuje: "
      // ?? _idzaduz
      // ENDIF
      READ
      ESC_RETURN K_ESC

   ENDIF

   _x += 2
   _kord_x := m_x + _x

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, fNovi, _kord_x, m_y + 2, @aPorezi, _idPartner )



   @ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _idtarifa WHEN gPromTar == "N"  VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idroba := Left( _idroba, 10 )
   ENDIF

   SELECT tarifa
   SEEK roba->idtarifa

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr

   _pkonto := _idkonto
   kalk_dat_poslj_promjene_prod()

   ++ _x
   IF _use_rok
      @ m_x + _x, m_y + 2 SAY8 "Datum isteka roka:" GET _rok
   ENDIF

   IF _use_opis
      @ m_x + _x, m_y + 30 SAY8 "Opis:" GET _opis PICT "@S40"
   ENDIF

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Količina " GET _kolicina PICT PicKol VALID _kolicina <> 0

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

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Fakturna cijena:"

   IF gDokKVal == "D"
      // konverzija valute...
      @ m_x + _x, Col() + 1 SAY "pr.->" GET __k_val VALID _val_konv( __k_val ) PICT "@!"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _fcj ;
      PICT PicDEM ;
      VALID {|| SetKey( K_ALT_T, {|| NIL } ), _fcj > 0 } ;
      WHEN VKol()
   @ m_x + _x, Col() + 1 SAY "*** <ALT+T> unos ukupne FV"

   // KASA-SKONTO ili RABAT
   ++ _x
   @ m_x + _x, m_y + 2   SAY "Rabat (%):"
   @ m_x + _x, m_y + _unos_left GET _rabat PICT PicDEM ;
      WHEN {|| SetKey( K_ALT_T, {|| _kaskadni_rabat( @_krabat ) } ), DuplRoba() } ;
      VALID {|| SetKey( K_ALT_T, {|| NIL } ), .T. }
   @ m_x + _x, Col() + 1 SAY "*** <ALT+T> unos kaskadnog rabata"

/*
   IF gNW <> "X"
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Transport. kalo:"
      @ m_x + _x, m_y + _unos_left GET _gkolicina PICT PicKol
      ++ _x
      @ m_x + _x, m_y + 2 SAY "    Ostalo kalo:"
      @ m_x + _x, m_y + _unos_left GET _gkolicin2 PICT PicKol
   ENDIF
*/
   READ

   ESC_RETURN K_ESC

   _fcj2 := _fcj * ( 1 - _rabat / 100 )

   // setuj atribute...
   IF _use_opis
      atrib[ "opis" ] := _opis
   ENDIF

   IF _use_rok
      atrib[ "rok" ] := DToC( _rok )
   ENDIF

   obracun_kalkulacija_tip_81_pdv( _x )

   RETURN LastKey()



// ---------------------------------------------
// unos kaskadnog rabata
// ---------------------------------------------
STATIC FUNCTION _kaskadni_rabat( krabat )

   LOCAL _r_1 := 0
   LOCAL _r_2 := 0
   LOCAL _r_3 := 0
   LOCAL _r_4 := 0
   LOCAL _ok := .T.
   PRIVATE GetList := {}

   Box(, 8, 50 )
   @ m_x + 1, m_y + 2 SAY "Unos kaskadnog rabata:"
   @ m_x + 3, m_y + 2 SAY "Rabat 1 (%):" GET _r_1 PICT PicDem
   @ m_x + 4, m_y + 2 SAY "Rabat 2 (%):" GET _r_2 PICT PicDem
   @ m_x + 5, m_y + 2 SAY "Rabat 3 (%):" GET _r_3 PICT PicDem
   @ m_x + 6, m_y + 2 SAY "Rabat 4 (%):" GET _r_4 PICT PicDem
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN _ok
   ENDIF

   _rabat := ( 100 - 100 * ( 1 - _r_1 / 100 ) * ;
      IF( _r_2 > 0, ( 1 - _r_2 / 100 ), 1 ) * ;
      IF( _r_3 > 0, ( 1 - _r_3 / 100 ), 1 ) * ;
      IF( _r_4 > 0, ( 1 - _r_4 / 100 ), 1 ) ;
      )

   RETURN _ok



// ---------------------------------------------
// unos ukupne fakturne vrijednosti
// ---------------------------------------------
STATIC FUNCTION _fv_ukupno()

   LOCAL _uk_fv := 0
   LOCAL _ok := .T.
   PRIVATE GetList := {}

   Box(, 1, 50 )
   @ m_x + 1, m_y + 2 SAY "Ukupna FV:" GET _uk_fv PICT PicDem
   READ
   BoxC()

   IF LastKey() == K_ESC .OR. Round( _uk_fv, 2 ) == 0
      RETURN _ok
   ENDIF

   _fcj := ( _uk_fv / _kolicina )

   RETURN _ok


STATIC FUNCTION VKol()

   SetKey( K_ALT_T, {|| _fv_ukupno() } )

   IF _kolicina < 0

      // storno

      nKolS := 0
      nKolZN := 0
      nc1 := nc2 := 0
      dDatNab := CToD( "" )

      IF !Empty( gMetodaNC )
         MsgO( "Racunam stanje na u prodavnici" )
         kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         MsgC()
         @ m_x + 12, m_y + 30 SAY "Ukupno na stanju "
         @ m_x + 12, Col() + 2 SAY nKols PICT pickol
      ENDIF

      IF dDatNab > _DatDok
         Beep( 1 )
         Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
      ENDIF

      IF nKols < Abs( _kolicina )
         sumnjive_stavke_error()
         error_bar( "KA_" + _idroba + "/" + _idkonto, _idroba + "/" + _idkonto + " kolicina nedovoljna:" + AllTrim( Str( nKols, 12, 3 ) ) )
      ENDIF
      SELECT kalk_pripr
   ENDIF

   RETURN .T.


// --------------------------------------------------------
// 81 - dokument, obracun kalkulacije
// --------------------------------------------------------
STATIC FUNCTION obracun_kalkulacija_tip_81_pdv( x_kord )

   LOCAL cSPom := " (%,A,U,R) "
   LOCAL _x := x_kord + 2
   LOCAL _unos_left := 40
   LOCAL _kord_x
   LOCAL _sa_troskovima := .T.
   PRIVATE getlist := {}
   PRIVATE fMarza := " "

   IF Empty( _TPrevoz )
      _TPrevoz := "%"
   ENDIF
   IF Empty( _TCarDaz ); _TCarDaz := "%"; ENDIF
   IF Empty( _TBankTr ); _TBankTr := "%"; ENDIF
   IF Empty( _TSpedTr ); _TSpedtr := "%"; ENDIF
   IF Empty( _TZavTr );  _TZavTr := "%" ; ENDIF
   IF Empty( _TMarza );  _TMarza := "%" ; ENDIF

   IF _sa_troskovima == .T.

      // TROSKOVNIK
      @ m_x + _x, m_y + 2 SAY "Raspored troskova kalkulacije ->"
      @ m_x + _x, m_y + _unos_left SAY c10T1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _Prevoz PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left SAY c10T2 + cSPom GET _TBankTr VALID _TBankTr $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _BankTr PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left SAY c10T3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _SpedTr PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left SAY c10T4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _CarDaz PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left SAY c10T5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _ZavTr PICT PicDEM ;
         VALID {|| NabCj(), .T. }

      ++ _x
      ++ _x

   ENDIF

   // NC

   @ m_x + _x, m_y + 2 SAY "NABAVNA CIJENA:"
   @ m_x + _x, m_y + _unos_left GET _nc PICT PicDEM

   // MARZA
   ++ _x
   @ m_x + _x, m_y + 2 SAY "MARZA:" GET _TMarza2 VALID _Tmarza2 $ "%AU" PICT "@!"
   @ m_x + _x, m_y + _unos_left GET _marza2 PICT PicDEM VALID {|| _vpc := _nc, .T. }
   @ m_x + _x, Col() + 1 GET fMarza PICT "@!"

   // PRODAJNA CIJENA
   ++ _x

   IF IsPDV()
      @ m_x + _x, m_y + 2 SAY "PC BEZ PDV:"
   ELSE
      @ m_x + _x, m_y + 2 SAY "MALOPROD. CIJENA (MPC):"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _mpc PICT PicDEM ;
      WHEN W_MPC_( "81", ( fMarza == "F" ), @aPorezi ) ;
      VALID V_Mpc_( "81", ( fMarza == "F" ), @aPorezi )

   ++ _x

   @ m_x + _x, m_y + 2 SAY "PDV (%):"
   @ m_x + _x, Col() + 2 SAY TARIFA->OPP PICTURE "99.99"

   IF glUgost
      @ m_x + _x, Col() + 2 SAY "PP (%):"
      @ m_x + _x, Col() + 2 SAY TARIFA->ZPP PICTURE "99.99"
   ENDIF

   ++ _x

   @ m_x + _x, m_y + 2 SAY "PC SA PDV:"


   @ m_x + _x, m_y + _unos_left GET _mpcsapp PICT PicDEM ;
      WHEN {|| fMarza := " ", _Marza2 := 0, .T. } ;
      VALID V_MpcSaPP_( "81", .F., @aPorezi, .T. )

   READ

   ESC_RETURN K_ESC

   SELECT koncij
   SEEK Trim( _idkonto )

   StaviMPCSif( _mpcsapp, .T. )

   SELECT kalk_pripr

   _pkonto := _idkonto
   _mkonto := ""
   _pu_i := "1"
   _mu_i := ""

   nStrana := 3

   RETURN LastKey()
