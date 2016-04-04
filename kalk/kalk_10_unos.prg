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


// konverzija valute
STATIC __k_val

// -----------------------------------------------
// unos dokumenta tip "10" - prva stranica
// -----------------------------------------------
FUNCTION Get1_10PDV()

   LOCAL _x := 5
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40

   gVarijanta := "2"
   __k_val := "N"

   IF nRbr == 1 .AND. fNovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1  .OR. !fNovi .OR. gMagacin == "1"

      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY "DOBAVLJAC:" GET _IdPartner PICT "@!" valid {|| Empty( _IdPartner ) .OR. P_Firma( @_IdPartner ), ispisi_naziv_sifre( F_PARTN, _idpartner, _kord_x - 1, 22, 20 ), _ino_dob( _idpartner ) }

      @ m_x + _x, 50 SAY "Broj fakture:" GET _BrFaktP

      @ m_x + _x, Col() + 1 SAY "Datum:" GET _DatFaktP


      ++ _x
      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY "Magacinski Konto zaduzuje" GET _IdKonto valid {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x, 40, 30 ) } PICT "@!"

      IF gNW <> "X"
         @ m_x + _x, m_y + 42  SAY "Zaduzuje: " GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz )
      ENDIF

      IF !Empty( cRNT1 )
         @ m_x + _x, m_y + 42  SAY "Rad.nalog:" GET _IdZaduz2  PICT "@!"
      ENDIF

      READ

      ESC_RETURN K_ESC

   ELSE

      @ m_x + _x, m_y + 2 SAY "DOBAVLJAC: "
      ?? _IdPartner
      @ m_x + _x, Col() + 1 SAY "Faktura dobavljaca - Broj: "
      ?? _BrFaktP
      @ m_x + _x, Col() + 1 SAY "Datum: "
      ?? _DatFaktP

      ++ _x
      @ m_x + _x, m_y + 2 SAY "Magacinski Konto zaduzuje "
      ?? _IdKonto

      IF gNW <> "X"
         @ m_x + _x, m_y + 42 SAY "Zaduzuje: "
         ?? _IdZaduz
      ENDIF

      _ino_dob( _idpartner )

   ENDIF

   ++ _x
   ++ _x
   _kord_x := m_x + _x

   IF lKoristitiBK
      @ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba ;
         PICT "@!S10" ;
         WHEN {|| _idroba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } ;
         VALID {|| ;
         _idroba := iif( Len( Trim( _idroba ) ) < 10, Left( _idroba, 10 ), _idroba ), ;
         _ocitani_barkod := _idroba, ;
         P_Roba( @_IdRoba ), ;
         if ( !tezinski_barkod_get_tezina( @_ocitani_barkod, @_kolicina ), .T., .T. ), ;
         ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ), ;
         _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), zadnji_ulazi_info( _idpartner, _idroba, "M" ),  ;
         .T. }
   ELSE
      @ m_x + _x, m_y + 2  SAY "Artikal  " GET _IdRoba ;
         PICT "@!" ;
         VALID {|| ;
         _idroba := iif( Len( Trim( _idroba ) ) < 10, Left( _idroba, 10 ), _idroba ), ;
         P_Roba( @_IdRoba, nil, nil, gArtCDX ), ;
         ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ), ;
         _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), zadnji_ulazi_info( _idpartner, _idroba, "M" ), ;
         .T. }

   ENDIF

   @ m_x + _x, m_y + ( MAXCOLS() - 20  ) SAY "Tarifa:" GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

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
   HSEEK _IdTarifa
   SELECT kalk_pripr

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   IF fNovi
      SELECT ROBA
      HSEEK _IdRoba
      _VPC := KoncijVPC()
      _TCarDaz := "%"
      _CarDaz := 0
   ENDIF

   SELECT kalk_pripr

   IF _tmarza <> "%"
      // procente ne diraj
      _Marza := 0
   ENDIF


   ++ _x
   @ m_x + _x, m_y + 2 SAY "Fakturna cijena:"

   IF gDokKVal == "D"
      @ m_x + _x, Col() + 1 SAY "pr.->" GET __k_val VALID _val_konv( __k_val ) PICT "@!"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _fcj PICT gPicNC VALID {|| _fcj > 0 .AND. _set_konv( @_fcj, @__k_val ) } WHEN V_kol10()

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Rabat (%):"
   @ m_x + _x, m_y + _unos_left GET _Rabat PICT PicDEM WHEN DuplRoba()

   IF gNW <> "X" .OR. gVodiKalo == "D"
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Normalni . kalo:"
      @ m_x + _x, m_y + _unos_left GET _GKolicina PICTURE PicKol
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Preko  kalo:    "
      @ m_x + _x, m_y + _unos_left GET _GKolicin2 PICTURE PicKol
   ENDIF



   READ

   ESC_RETURN K_ESC

   _FCJ2 := _FCJ * ( 1 - _Rabat / 100 )

   obracun_kalkulacija_tip_10_pdv( _x )

   RETURN LastKey()



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



// --------------------------------------------------
// da li je dobavljac ino, setuje valutiranje
// --------------------------------------------------
STATIC FUNCTION _ino_dob( cPartn )

   IF gDokKVal == "D" .AND. fNovi .AND. isInoDob( cPartn )
      __k_val := "D"
   ENDIF

   RETURN .T.



// ---------------------------------------
// validacija unosa preracuna
// ---------------------------------------
FUNCTION _val_konv( cDn )

   LOCAL lRet := .T.

   IF cDN $ "DN"
      RETURN lRet
   ELSE
      MsgBeep( "Preracun: " + valpomocna() + "=>" + valdomaca() + "#Unjeti 'D' ili 'N' !" )
      lRet := .F.
      RETURN lRet
   ENDIF

   RETURN .T.


// --------------------------------------
// konverzija fakturne cijene
// --------------------------------------
FUNCTION _set_konv( nFcj, cPretv )

   IF cPretv == "D"
      a_val_convert()
      cPretv := "N"
      showgets()
   ENDIF

   RETURN .T.



// --------------------------------------------------
// unos dokumenta "10" - druga stranica
// --------------------------------------------------
STATIC FUNCTION obracun_kalkulacija_tip_10_pdv( x_kord )

   LOCAL cSPom := " (%,A,U,R) "
   LOCAL _x := x_kord + 4
   LOCAL _unos_left := 40
   LOCAL _kord_x
   LOCAL _sa_troskovima := .T.
   PRIVATE getlist := {}

   IF Empty( _TPrevoz )
      _TPrevoz := "%"
   ENDIF
   IF Empty( _TCarDaz )
      _TCarDaz := "%"
   ENDIF
   IF Empty( _TBankTr )
      _TBankTr := "%"
   ENDIF
   IF Empty( _TSpedTr )
      _TSpedtr := "%"
   ENDIF
   IF Empty( _TZavTr )
      _TZavTr := "%"
   ENDIF
   IF Empty( _TMarza )
      _TMarza := "%"
   ENDIF

   IF _sa_troskovima

      // automatski setuj troskove....
      _auto_set_trosk( fNovi )

      // TROSKOVNIK

      @ m_x + _x, m_y + 2 SAY "Raspored troskova kalkulacije ->"

      @ m_x + _x, m_y + _unos_left + 10 SAY c10T1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
      @ m_x + _x, Col() + 2 GET _Prevoz PICT  PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T2 + cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _BankTr PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AUR" PICT "@!"
      @ m_x + _x, Col() + 2 GET _SpedTr PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
      @ m_x + _x, Col() + 2 GET _CarDaz PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
      @ m_x + _x, Col() + 2 GET _ZavTr PICT PicDEM VALID {|| NabCj(), .T. }

      _x += 2

   ENDIF

   @ m_x + _x, m_y + 2 SAY "NABAVNA CJENA:"
   @ m_x + _x, m_y + _unos_left GET _nc PICT gPicNC



   PRIVATE fMarza := " "

   ++ _x
   @ m_x + _x, m_y + 2    SAY8 "Magacin. Marža           :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
   @ m_x + _x, Col() + 2 GET _Marza PICT PicDEM
   @ m_x + _x, Col() + 1 GET fMarza PICT "@!" VALID {|| Marza( fMarza ), fMarza := " ", .T. }

   // PRODAJNA CIJENA / PLANSKA CIJENA
   ++ _x
   IF koncij->naz == "P2"
      @ m_x + _x, m_y + 2    SAY "PLANSKA CIJENA  (PLC)       :"
   ELSE
      @ m_x + _x, m_y + 2    SAY "PROD.CJENA BEZ PDV   :"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _vpc PICT PicDEM VALID {|| MarzaVP( _Idvd, ( fMarza == "F" ) ), .T. }


   IF ( gMpcPomoc == "D" )

      _mpcsapp := roba->mpc

      ++ _x

      // VPC se izracunava pomocu MPC cijene !!
      @ m_x + _x, m_y + 2 SAY "PROD.CJENA SA PDV:"
      @ m_x + _x, m_y + _unos_left GET _mpcsapp PICT PicDEM ;
         valid {|| _mpcsapp := iif( _mpcsapp = 0, Round( _vpc * ( 1 + TARIFA->opp / 100 ) / ( 1 + TARIFA->PPP / 100 ), 2 ), _mpcsapp ), _mpc := _mpcsapp / ( 1 + TARIFA->opp / 100 ) / ( 1 + TARIFA->PPP / 100 ), ;
         iif( _mpc <> 0, _vpc := Round( _mpc, 2 ), _vpc ), ShowGets(), .T. }

   ENDIF

   READ

   IF ( gMpcPomoc == "D" )

      IF ( roba->mpc == 0 .OR. roba->mpc <> Round( _mpcsapp, 2 ) ) .AND. Pitanje(, "Staviti MPC u sifrarnik" ) == "D"

         SELECT roba
         _rec := dbf_get_rec()
         _rec[ "mpc" ] := _mpcsapp

         update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )

         SELECT kalk_pripr

      ENDIF

   ENDIF

   SetujVPC( _vpc )



   _MKonto := _Idkonto
   _MU_I := "1"

   nStrana := 3

   RETURN LastKey()



// ------------------------------------------------------
// automatsko setovanje troskova kalkulacije
// na osnovu sifrarnika robe
//
// lNewItem - radi se o novoj stavci
// ------------------------------------------------------
STATIC FUNCTION _auto_set_trosk( lNewItem )

   LOCAL lForce := .F.

   // ako nema polja TROSK1 u robi idi dalje....
   // nemas sta raditi

   IF roba->( FieldPos( "TROSK1" ) ) == 0
      RETURN
   ENDIF

   // ako su automatski troskovi = "N", izadji
   IF gRobaTrosk == "N"
      RETURN
   ENDIF

   IF gRobaTrosk == "0"

      IF Pitanje( , "Preuzeti troskove iz sifrarnika robe ?", "D" ) == "N"
         RETURN
      ENDIF

      // setuj forirano uzimanje troska.....
      lForce := .T.

   ENDIF

   IF ( _Prevoz == 0 .OR. lForce == .T. .OR. lNewItem == .T. )

      _Prevoz := roba->trosk1

      IF !Empty( gRobaTr1Tip )
         _TPrevoz := gRobaTr1Tip
      ENDIF

   ENDIF

   IF ( _BankTr == 0 .OR. lForce == .T. .OR. lNewItem == .T. )

      _BankTr := roba->trosk2

      IF !Empty( gRobaTr2Tip )
         _TBankTr := gRobaTr2Tip
      ENDIF

   ENDIF

   IF ( _SpedTr == 0 .OR. lForce == .T. .OR. lNewItem == .T. )

      _SpedTr := roba->trosk3

      IF !Empty( gRobaTr3Tip )
         _TSpedTr := gRobaTr3Tip
      ENDIF

   ENDIF

   IF ( _CarDaz == 0 .OR. lForce == .T. .OR. lNewItem == .T. )

      _CarDaz := roba->trosk4

      IF !Empty( gRobaTr4Tip )
         _TCarDaz := gRobaTr4Tip
      ENDIF

   ENDIF

   IF ( _ZavTr == 0 .OR. lForce == .T. .OR. lNewItem == .T. )

      _ZavTr := roba->trosk5

      IF !Empty( gRobaTr5Tip )
         _TZavTr := gRobaTr5Tip
      ENDIF

   ENDIF

   RETURN




/*
   V_kol10()
   Validacija unosa kolicine
 */

FUNCTION V_kol10()

   IF _kolicina < 0  // storno
      nKolS := 0
      nKolZN := 0
      nc1 := nc2 := 0
      dDatNab := CToD( "" )

      IF !Empty( gMetodaNC )
         MsgO( "Računam stanje na skladištu" )
         KalkNab( _idfirma, _idroba, _mkonto, @nKolS, @nKolZN, @nC1, @nC2, @dDatNab )
         MsgC()
         @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nKols PICT pickol
      ENDIF

      IF dDatNab > _DatDok
         Beep( 1 )
         Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
      ENDIF
      IF _idvd == "16"  // storno prijema
         IF gMetodaNC $ "13"
            _nc := nC1
         ELSEIF gMetodaNC == "2"
            _nc := nc2
         ENDIF
      ENDIF
      IF nKols < Abs( _kolicina )
         _ERROR := "1"
         Beep( 2 )
         error_bar( "k:" + _idfirma + "-" + _idvd + "-" + _brdok, ;
            _idroba + " kol na stanju:" + AllTrim( Str( nKols, 12, 3 ) ) + " treba: " + AllTrim( Str( _kolicina, 12, 3 ) ) )
      ENDIF
      SELECT kalk_pripr
   ENDIF

   RETURN .T.
