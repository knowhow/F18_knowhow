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

FUNCTION kalk_get_1_18()

   _DatFaktP := _datdok


   @ m_x + 8, m_y + 2   SAY "Konto koji zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"
   // IF gNW <> "X"
   // @ m_x + 8, m_y + 35  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz, 21, 5 )
   // ENDIF
   read; ESC_RETURN K_ESC

   @ m_x + 10, m_y + 66 SAY "Tarif.br->"

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), m_x + 11, m_y + 2, @aPorezi )

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )
   READ
   ESC_RETURN K_ESC
   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   select_o_tarifa( _IdTarifa )
   select_o_koncij( _idkonto )
   SELECT kalk_pripr  // napuni tarifu

   _MKonto := _Idkonto
   //check_datum_posljednje_kalkulacije()
   //DuplRoba()

   dDatNab := CToD( "" )
   IF kalk_is_novi_dokument()
      _Kolicina := 0
   ENDIF
   lGenStavke := .F.
   IF !Empty( kalk_metoda_nc() ) .AND. _TBankTr <> "X"

      IF gKolicFakt == "D"
         KalkNaF( _idroba, @_kolicina )
      ELSE
         kalk_get_nabavna_mag( _datdok, _idfirma, _idroba, _idkonto, @_kolicina, NIL, NIL, NIL, @dDatNab )
      ENDIF

   ENDIF
   IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF

   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _kolicina > 0

   IF kalk_is_novi_dokument() .AND. gMagacin == "2" .AND. _TBankTr <> "X"
      nStCj := KoncijVPC()
   ELSE
      nStCj := _MPCSAPP
   ENDIF

   IF kalk_is_novi_dokument()
      nNCj := 0
   ELSE
      nNCJ := _VPC + nStCj
   ENDIF

   IF roba->tip = "X"
      MsgBeep( "Za robu tipa X ne rade se nivelacije" )
   ENDIF

   IF roba->tip $ "VK"
      cNaziv := "VPCVT"
   ELSE
      cNaziv := "VPC"
   ENDIF
   IF gmagacin == "1"
      cNaziv := "NC"
   ENDIF
   @ m_x + 17, m_y + 2    SAY "STARA CIJENA  (" + cnaziv + ") :"  GET nStCj  PICTURE PicDEM
   @ m_x + 18, m_y + 2    SAY "NOVA CIJENA   (" + cnaziv + ") :"  GET nNCj   PICTURE PicDEM

   IF gMPCPomoc == "D"
      PRIVATE _MPCPom := 0
      @ m_x + 18, m_y + 42    SAY "NOVA CIJENA  MPC :"  GET _mpcpom   PICTURE PicDEM ;
         valid {|| nNcj := iif( nNcj = 0, Round( _mpcpom / ( 1 + TARIFA->opp / 100 ) / ( 1 + TARIFA->PPP / 100 ), 2 ), nNcj ), .T. }
   ENDIF

   READ
   ESC_RETURN K_ESC

   IF _TBankTr <> "X"

      //SELECT roba
      SetujVPC( nNCJ )

      SELECT kalk_pripr
   ENDIF


   IF gMPCPomoc == "D"
      IF ( roba->mpc == 0 .OR. roba->mpc <> Round( _mpcpom, 2 ) ) .AND. Round( _mpcpom, 2 ) <> 0 .AND. Pitanje(, "Staviti MPC u sifrarnik" ) == "D"
         SELECT roba
         hRec := dbf_get_rec()
         hRec[ "mpc" ] := _mpcpom
         update_rec_server_and_dbf( Alias(), hRec, 1, "FULL" )
         SELECT kalk_pripr
      ENDIF
   ENDIF

   IF roba->tip $ "VK"
      _VPC := ( nNCJ - nStCj )
      _MPCSAPP := nStCj
   ELSE
      _VPC := nNCJ - nStCj
      _MPCSAPP := nStCj
   ENDIF

   _idpartner := ""
   _rabat := prevoz := prevoz2 := _banktr := _spedtr := _zavtr := _nc := _marza := _marza2 := _mpc := 0
   _gkolicina := _gkolicin2 := _mpc := 0

   _MKonto := _Idkonto
   _MU_I := "3"
   _PKonto := ""
   _PU_I := ""

   nStrana := 3

   RETURN LastKey()
