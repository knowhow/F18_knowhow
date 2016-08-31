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

STATIC s_cKonverzijaValuteDN // konverzija valute
STATIC aPorezi := {}
STATIC s_lIsNoviDokument := .F.

FUNCTION kalk_is_novi_dokument( lSet )

   IF lSet != NIL
      s_lIsNoviDokument := lSet
   ENDIF

   RETURN s_lIsNoviDokument


FUNCTION kalk_get_1_10()

   LOCAL _x := 5
   LOCAL _kord_x := 0
   LOCAL _unos_left := 40

   gVarijanta := "2"
   s_cKonverzijaValuteDN := "N"

   IF nRbr == 1 .AND. kalk_is_novi_dokument()
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1  .OR. !kalk_is_novi_dokument() .OR. gMagacin == "1"

      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY8 "DOBAVLJAČ:" GET _IdPartner PICT "@!" ;
         valid {|| Empty( _IdPartner ) .OR. P_Firma( @_IdPartner ), ispisi_naziv_sifre( F_PARTN, _idpartner, _kord_x - 1, 22, 20 ), ;
         ino_dobavljac_set_konverzija_valute( _idpartner, @s_cKonverzijaValuteDN ) }

      @ m_x + _x, 50 SAY "Broj fakture:" GET _BrFaktP

      @ m_x + _x, Col() + 1 SAY "Datum:" GET _DatFaktP


      ++ _x
      _kord_x := m_x + _x

      @ m_x + _x, m_y + 2 SAY "Magacinski Konto zaduzuje" GET _IdKonto valid {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x, 40, 30 ) } PICT "@!"

      // IF gNW <> "X"
      // @ m_x + _x, m_y + 42  SAY "Zaduzuje: " GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz )
      // ENDIF

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

      // IF gNW <> "X"
      // @ m_x + _x, m_y + 42 SAY "Zaduzuje: "
      // ?? _IdZaduz
      // ENDIF

      ino_dobavljac_set_konverzija_valute( _idpartner, @s_cKonverzijaValuteDN )

   ENDIF

   _x += 2

   _kord_x := m_x + _x


   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), _kord_x, m_y + 2, @aPorezi, _idPartner )



   @ m_x + _x, m_y + ( MAXCOLS() - 20  ) SAY "Tarifa:" GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ

   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr

   _MKonto := _Idkonto
   _MU_I := "1"
   // check_datum_posljednje_kalkulacije()

   SELECT TARIFA
   HSEEK _IdTarifa
   SELECT kalk_pripr

   ++ _x
   @ m_x + _x, m_y + 2 SAY8 "Količina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

   IF kalk_is_novi_dokument()
      SELECT ROBA
      HSEEK _IdRoba
      _VPC := KoncijVPC()
      _TCarDaz := "%"
      _CarDaz := 0
   ENDIF

   SELECT kalk_pripr

   IF _tmarza <> "%"
      _Marza := 0 // procente ne diraj
   ENDIF

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Fakturna cijena:"

   IF gDokKVal == "D"
      @ m_x + _x, Col() + 1 SAY "pr.->" GET s_cKonverzijaValuteDN VALID kalk_ulaz_preracun_fakturne_cijene( s_cKonverzijaValuteDN ) PICT "@!"
   ENDIF

   @ m_x + _x, m_y + _unos_left GET _fcj PICT gPicNC VALID {|| _fcj > 0 .AND. _set_konv( @_fcj, @s_cKonverzijaValuteDN ) } WHEN V_kol10()

   ++ _x
   @ m_x + _x, m_y + 2 SAY "Rabat (%):"
   @ m_x + _x, m_y + _unos_left GET _Rabat PICT PicDEM

   /*
   IF gNW <> "X" .OR. gVodiKalo == "D"
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Normalni . kalo:"
      @ m_x + _x, m_y + _unos_left GET _GKolicina PICTURE PicKol
      ++ _x
      @ m_x + _x, m_y + 2 SAY "Preko  kalo:    "
      @ m_x + _x, m_y + _unos_left GET _GKolicin2 PICTURE PicKol
   ENDIF
   */


   READ

   ESC_RETURN K_ESC

   _FCJ2 := _FCJ * ( 1 - _Rabat / 100 )

   kalk_get_2_10( _x )

   RETURN LastKey()



STATIC FUNCTION ino_dobavljac_set_konverzija_valute( cPartn, s_cKonverzijaValuteDN )

   IF gDokKVal == "D" .AND. kalk_is_novi_dokument() .AND. isInoDob( cPartn )
      s_cKonverzijaValuteDN := "D"
   ENDIF

   RETURN .T.



// ---------------------------------------
// validacija unosa preracuna
// ---------------------------------------
FUNCTION kalk_ulaz_preracun_fakturne_cijene( cDn )

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




STATIC FUNCTION kalk_get_2_10( x_kord )

   LOCAL cSPom := " (%,A,U,R,T) "
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


      _auto_set_trosk( kalk_is_novi_dokument() )   // automatski setuj troskove

      // TROSKOVNIK

      @ m_x + _x, m_y + 2 SAY "Raspored troskova kalkulacije ->"

      @ m_x + _x, m_y + _unos_left + 10 SAY c10T1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AURT" PICTURE "@!"
      @ m_x + _x, Col() + 2 GET _Prevoz PICT  PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T2 + cSPom  GET _TBankTr VALID _TBankTr $ "%AURT" PICT "@!"
      @ m_x + _x, Col() + 2 GET _BankTr PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AURT" PICT "@!"
      @ m_x + _x, Col() + 2 GET _SpedTr PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AURT" PICTURE "@!"
      @ m_x + _x, Col() + 2 GET _CarDaz PICT PicDEM

      ++ _x
      @ m_x + _x, m_y + _unos_left + 10 SAY c10T5 + cSPom GET _TZavTr VALID _TZavTr $ "%AURT" PICTURE "@!"
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


   IF ( gMpcPomoc == "D" )   // VPC se izracunava pomocu MPC cijene

      _mpcsapp := roba->mpc

      ++ _x

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
      RETURN .F.
   ENDIF

   // ako su automatski troskovi = "N", izadji
   IF kalk_preuzimanje_troskova_iz_sif_roba() == "N"
      RETURN .F.
   ENDIF

   IF kalk_preuzimanje_troskova_iz_sif_roba() == "0"

      IF Pitanje( , "Preuzeti troskove iz sifrarnika robe ?", "D" ) == "N"
         RETURN .F.
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

   RETURN .T.




/*
   Validacija unosa kolicine
 */

FUNCTION V_kol10()

   IF _kolicina < 0  // storno
      nKolS := 0
      nKolZN := 0
      nc1 := nc2 := 0
      dDatNab := CToD( "" )

      IF !Empty( kalk_metoda_nc() )

         kalk_get_nabavna_mag( _idfirma, _idroba, _mkonto, @nKolS, @nKolZN, @nC1, @nC2, @dDatNab )

         @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nKols PICT pickol
      ENDIF

      IF dDatNab > _DatDok
         Beep( 1 )
         Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
      ENDIF
      IF _idvd == "16"  // storno prijema
         IF kalk_metoda_nc() $ "13"
            _nc := nC1
         ELSEIF kalk_metoda_nc() == "2"
            _nc := nc2
         ENDIF
      ENDIF
      IF nKols < Abs( _kolicina )
         _ERROR := "1"
         Beep( 2 )
         error_bar( "KA_" + _idfirma + "-" + _idvd + "-" + _brdok, ;
            _idroba + " kol na stanju:" + AllTrim( Str( nKols, 12, 3 ) ) + " treba: " + AllTrim( Str( _kolicina, 12, 3 ) ) )
      ENDIF
      SELECT kalk_pripr
   ENDIF

   RETURN .T.
