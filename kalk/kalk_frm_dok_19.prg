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



FUNCTION Get1_19()

   _DatFaktP := _datdok
   PRIVATE aPorezi := {}

   @ m_x + 8, m_y + 2   SAY "Konto koji zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"

   //IF gNW <> "X"
  //    @ m_x + 8, m_y + 35  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
   //ENDIF

   READ
   ESC_RETURN K_ESC

   @ m_x + 10, m_y + 66 SAY "Tarif.br->"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } VALID VRoba()
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" VALID VRoba()
   ENDIF

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC
   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF


   _MKonto := _Idkonto
   kalk_dat_poslj_promjene_prod()

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr  // napuni tarifu

   kalk_dat_poslj_promjene_prod()
   DuplRoba()

   dDatNab := CToD( "" )
   IF fnovi
      _Kolicina := 0
   ENDIF

   lGenStavke := .F.
   IF !Empty( gmetodaNC ) .AND. _TBankTr <> "X"
      MsgO( "Racunam kolicinu u prodavnici" )
      kalk_get_nabavna_prod( _idfirma, _idroba, _idkonto, @_kolicina, NIL, NIL, @_nc, @dDatNab )
      MsgC()
   ENDIF

   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _kolicina >= 0

   _idpartner := ""

   READ

   nStCj := nNCJ := 0

   IF fnovi
      SELECT koncij
      SEEK Trim( _idkonto )
      nStCj := Round( kalk_get_mpc_by_koncij_pravilo(), 3 )
   ELSE
      nStCj := _fcj
   ENDIF

   _PKonto := _Idkonto
   _PU_I := "3"

   IF fnovi .AND.  dozvoljeno_azuriranje_sumnjivih_stavki()
      kalk_fakticka_mpc( @nStCj, _idfirma, _pkonto, _idroba )
   ENDIF

   VTPorezi()
   SELECT kalk_pripr

   nNCJ := nStCj + _MPCSaPP

   @ m_x + 16, m_y + 2  SAY "STARA CIJENA " + if( IsPDV(), "(MPCSAPDV):", "(MPCSAPP):" )
   @ m_x + 16, m_y + 50 GET nStCj    PICT "999999.9999"
   @ m_x + 17, m_y + 2  SAY "NOVA CIJENA  " + if( IsPDV(), "(MPCSAPDV):", "(MPCSAPP):" )
   @ m_x + 17, m_y + 50 GET nNCj     PICT "999999.9999"

   SayPorezi( 19 )

   READ
   ESC_RETURN K_ESC

   _MPCSaPP := nNCj - nStCj
   _MPC := 0
   _fcj := nStCj

   _mpc := MpcBezPor( nNCj, aPorezi, , _nc ) -MpcBezPor( nStCj, aPorezi, , _nc )

   IF Pitanje(, "Staviti u sifrarnik novu cijenu", gDefNiv ) == "D"
      SELECT koncij
      SEEK Trim( _idkonto )
      SELECT roba
      StaviMPCSif( _fcj + _mpcsapp )
      SELECT kalk_pripr
   ENDIF

   nStrana := 3
   _VPC := 0
   _GKolicina := _GKolicin2 := 0
   _Marza2 := 0
   _TMarza2 := "A"

   _MKonto := ""
   _MU_I := ""

   RETURN LastKey()
