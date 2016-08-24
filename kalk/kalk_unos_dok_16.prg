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

STATIC aPorezi := {}

FUNCTION kalk_get_1_16()

   LOCAL nRVPC

   pIzgSt := .F.   // izgenerisane stavke jos ne postoje

   SET KEY K_ALT_K TO KM94()

   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF Empty( _TMarza )
      _TMarza := "%"
   ENDIF

   IF nRbr == 1 .OR. !fNovi

      IF _idvd $ "94#97"
         @  m_x + 6, m_y + 2   SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 18 )
      ENDIF
      @  m_x + 7, m_y + 2   SAY "Faktura/Otpremnica Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP  valid {|| .T. }


      @ m_x + 9, m_y + 2 SAY8 "Magacinski konto zadužuje"  GET _IdKonto VALID Empty( _IdKonto ) .OR. P_Konto( @_IdKonto, 21, 5 )

      IF !Empty( cRNT1 )
         @ m_x + 9, m_y + 40 SAY "Rad.nalog:"   GET _IdZaduz2  PICT "@!"
      ENDIF

      IF _idvd == "16" .AND. _idkonto2 != "XXX"
         @ m_x + 10, m_y + 2   SAY "Prenos na konto          " GET _IdKonto2   VALID Empty( _idkonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 ) PICT "@!"

      ENDIF

   ELSE
      @  m_x + 6, m_y + 2   SAY "KUPAC: "; ?? _IdPartner
      @  m_x + 7, m_y + 2   SAY "Faktura Broj: "; ?? _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      @ m_x + 9, m_y + 2 SAY "Magacinski konto zaduzuje "; ?? _IdKonto


   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.br "

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, fNovi, m_x + 11, m_y + 2, @aPorezi )
   /*
   IF roba_barkod_pri_unosu()
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idRoba := PadR( _idRoba, Val( --gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
   */

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   @ m_x + 12, m_y + 2   SAY8 "Količina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT koncij
   SEEK Trim( _idkonto )

   SELECT TARIFA
   HSEEK _IdTarifa

   SELECT kalk_pripr
   _MKonto := _Idkonto
   _MU_I := "1"

   check_datum_posljednje_kalkulacije()
   DuplRoba()
   _GKolicina := 0
   IF fNovi
      SELECT ROBA
      HSEEK _IdRoba
      IF koncij->naz == "P2"
         _nc := plc
         _vpc := plc
      ELSE
         _VPC := KoncijVPC()
         _NC := NC
      ENDIF
   ENDIF
   set_pdv_public_vars()
   SELECT kalk_pripr

   @ m_x + 14, m_y + 2   SAY "NAB.CJ   "  GET _NC  PICTURE gPicNC  WHEN V_kol10()
   READ

   PRIVATE _vpcsappp := 0

   _VPC := _nc
   marza := 0

   nStrana := 2

   _marza := _vpc - _nc
   _MKonto := _Idkonto
   _MU_I := "1"
   _PKonto := ""
   _PU_I := ""

   SET KEY K_ALT_K TO

   RETURN LastKey()




// _odlval nalazi se u knjiz, filuje staru vrijednost
// _odlvalb nalazi se u knjiz, filuje staru vrijednost nabavke
FUNCTION Get1_16bPDV()

   LOCAL cSvedi := " "

   fnovi := .T.
   PRIVATE PicDEM := "9999999.99999999", PicKol := "999999.999"

   Beep( 1 )

   @ m_x + 2, m_Y + 2 SAY "PROTUSTAVKA   (svedi na staru vrijednost - kucaj S):"
   @ m_x + 2, Col() + 2 GET cSvedi VALID csvedi $ " S" PICT "@!"

   READ

   @ m_x + 11, m_y + 66 SAY "Tarif.brĿ"
   @ m_x + 12, m_y + 2  SAY "Artikal  " GET _IdRoba PICT "@!" ;
      valid  {|| P_Roba( @_IdRoba ), say_from_valid( 12, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := ROBA->idtarifa, .T. }
   @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC
   SELECT TARIFA
   HSEEK _IdTarifa
   // postavi TARIFA na pravu poziciju
   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr
   // napuni tarifu

   _PKonto := _Idkonto

   kalk_dat_poslj_promjene_prod()
   DuplRoba()

   PRIVATE fMarza := " "

   @ m_x + 13, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT ROBA
   HSEEK _IdRoba

   _VPC := KoncijVPC()
   _TMarza2 := "%"
   _TCarDaz := "%"
   _CarDaz := 0

   SELECT kalk_pripr

   set_pdv_public_vars()
   SELECT kalk_pripr



   @ m_x + 14, m_y + 2    SAY "NAB.CJ   "  GET _NC  PICTURE  gPicNC  WHEN V_kol10()

   PRIVATE _vpcsappp := 0


   // vodi se po nc
   _vpc := _nc
   marza := 0


   cBeze := " "
   @ m_x + 17, m_y + 2 GET cBeze VALID SvediM( cSvedi )



   READ


   nStrana := 2
   _marza := _vpc - _nc
   _MKonto := _Idkonto
   _MU_I := "1"
   _PKonto := ""
   _PU_I := ""
   _ERROR := "0"
   nStrana := 3

   RETURN LastKey()




/*
  *   Svodjenje kolicine u protustavci da bi se dobila ista vrijednost (kada su cijene u stavci i protustavci razlicite)
*/

STATIC FUNCTION SvediM( cSvedi )

   IF koncij->naz == "N1"
      _VPC := _NC
   ENDIF
   IF csvedi == "S"
      IF _vpc <> 0
         _kolicina := -Round( _oldval / _vpc, 4 )
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
