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


FUNCTION Get1_18()

   _DatFaktP := _datdok


   @ m_x + 8, m_y + 2   SAY "Konto koji zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"
   IF gNW <> "X"
      @ m_x + 8, m_y + 35  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 21, 5 )
   ENDIF
   read; ESC_RETURN K_ESC

   @ m_x + 10, m_y + 66 SAY "Tarif.brĿ"
   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idRoba := PadR( _idRoba, Val( gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC
   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA
   HSEEK _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr  // napuni tarifu

   _MKonto := _Idkonto
   DatPosljK()
   DuplRoba()

   dDatNab := CToD( "" )
   IF fnovi
      _Kolicina := 0
   ENDIF
   lGenStavke := .F.
   IF !Empty( gmetodaNC ) .AND. _TBankTr <> "X"
      MsgO( "Racunam kolicinu robe na skladistu" )
      IF gKolicFakt == "D"
         KalkNaF( _idroba, @_kolicina ) 
      ELSE
         KalkNab( _idfirma, _idroba, _idkonto, @_kolicina, NIL, NIL, NIL, @dDatNab )
      ENDIF
      MsgC()
   ENDIF
   IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
      
   @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _kolicina > 0

   IF fnovi .AND. gMagacin == "2" .AND. _TBankTr <> "X"
      nStCj := KoncijVPC()
   ELSE
      nStCj := _MPCSAPP
   ENDIF

   IF fnovi
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

      SELECT roba
      SetujVPC( nNCJ )

      SELECT kalk_pripr
   ENDIF


   IF gMPCPomoc == "D"
      IF ( roba->mpc == 0 .OR. roba->mpc <> Round( _mpcpom, 2 ) ) .AND. Round( _mpcpom, 2 ) <> 0 .AND. Pitanje(, "Staviti MPC u sifrarnik" ) == "D"
         SELECT roba
         _rec := dbf_get_rec()
         _rec[ "mpc" ] := _mpcpom
         update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
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

