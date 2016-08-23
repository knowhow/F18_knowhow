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

// prijem robe 16
// storno 14-ke fakture ! - 94
// storno otpreme  - 97

FUNCTION kalk_get_1_16_94()

   LOCAL nRVPC

   pIzgSt := .F.   // izgenerisane stavke jos ne postoje

   SET KEY K_ALT_K TO KM94()

   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !fnovi .OR. gMagacin == "1"
      IF _idvd $ "94#97"
         @  m_x + 6, m_y + 2   SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 18 )
      ENDIF
      @  m_x + 7, m_y + 2   SAY "Faktura/Otpremnica Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   valid {|| .T. }

      @ m_x + 9, m_y + 2 SAY "Magacinski konto zaduzuje"  GET _IdKonto VALID Empty( _IdKonto ) .OR. P_Konto( @_IdKonto, 21, 5 )
      // IF gNW <> "X"
      // @ m_x + 9, m_y + 40 SAY "Zaduzuje:" GET _IdZaduz   PICT "@!"  VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
      // ELSE
      IF !Empty( cRNT1 )
         @ m_x + 9, m_y + 40 SAY "Rad.nalog:"   GET _IdZaduz2  PICT "@!"
      ENDIF
      // ENDIF

      IF _idvd == "16"
         @ m_x + 10, m_y + 2   SAY "Prenos na konto          " GET _IdKonto2   VALID Empty( _idkonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 ) PICT "@!"
         // IF gNW <> "X"
         // @ m_x + 10, m_y + 35  SAY "Zaduzuje: "   GET _IdZaduz2  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz2, 21, 5 )
         // ENDIF
      ENDIF

   ELSE
      @  m_x + 6, m_y + 2   SAY "KUPAC: "; ?? _IdPartner
      @  m_x + 7, m_y + 2   SAY "Faktura Broj: "; ?? _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      @ m_x + 9, m_y + 2 SAY "Magacinski konto zaduzuje "; ?? _IdKonto
      // IF gNW <> "X"
      // @ m_x + 9, m_y + 40 SAY "Zaduzuje: "; ?? _IdZaduz
      // ENDIF

   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.br "

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, fNovi, m_x + 11, m_y + 2, @aPorezi, _idPartner )

/*
   IF roba_barkod_pri_unosu()
    --  @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idRoba := PadR( _idRoba, Val( --gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
    --  @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
*/
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0
   read; ESC_RETURN K_ESC
   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT koncij
   SEEK Trim( _idkonto )  // postavi TARIFA na pravu poziciju
   SELECT TARIFA
   HSEEK _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT kalk_pripr  // napuni tarifu
   _MKonto := _Idkonto
   _MU_I := "1"



   check_datum_posljednje_kalkulacije()
   DuplRoba()

   _GKolicina := 0
   IF fNovi
      SELECT ROBA; HSEEK _IdRoba
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

   @ m_x + 13, m_y + 2    SAY "NAB.CJ   "  GET _NC  PICTURE gPicNC  WHEN V_kol10()

   PRIVATE _vpcsappp := 0


   READ
   _VPC := _nc
   _marza := 0  // vodi se po nc



   _mpcsapp := 0
   nStrana := 2

   _marza := _vpc - _nc
   _MKonto := _Idkonto;_MU_I := "1"
   _PKonto := ""; _PU_I := ""
   SET KEY K_ALT_K TO

   RETURN LastKey()



/* KM94()
 *     Magacinska kartica kao pomoc pri unosu 94-ke
 */

// koristi se stkalk14   za stampu kalkulacije
// stkalk 95 za stampu 16-ke
FUNCTION KM94()

   LOCAL nR1, nR2, nR3
   PRIVATE GetList := {}

   SELECT  roba
   nR1 := RecNo()
   SELECT kalk_pripr
   nR2 := RecNo()
   SELECT tarifa
   nR3 := RecNo()
   my_close_all_dbf()
   kalk_kartica_magacin( _IdFirma, _idroba, _IdKonto )
   o_kalk_edit()
   SELECT roba
   GO nR1
   SELECT kalk_pripr
   GO nR2
   SELECT tarifa
   GO nR3
   SELECT kalk_pripr

   RETURN
