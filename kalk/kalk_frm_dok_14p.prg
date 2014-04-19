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


#include "kalk.ch"


FUNCTION Get1_14PDV()

   pIzgSt := .F.   // izgenerisane stavke jos ne postoje

   SET KEY K_ALT_K TO KM2()

   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !fnovi
      @ m_x + 6, m_y + 2   SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 18 )
      @ m_x + 7, m_y + 2   SAY "Faktura Broj:" GET _BrFaktP
      @ m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   ;
         valid {|| .T. }
      _IdZaduz := ""
      _Idkonto := "1200"
      PRIVATE cNBrDok := _brdok
      @ m_x + 9, m_y + 2 SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
         valid ( Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 ) ) .AND. ;
         MarkBrDok( fNovi )
      IF gNW <> "X"
         @ m_x + 9, m_y + 40 SAY "Razduzuje:" GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. P_Firma( @_IdZaduz2, 21, 5 )
      ENDIF
   ELSE
      @ m_x + 6, m_y + 2   SAY "KUPAC: "; ?? _IdPartner
      @ m_x + 7, m_y + 2   SAY "Faktura Broj: "; ?? _BrFaktP
      @ m_x + 7, Col() + 2 SAY "Datum: "; ?? _DatFaktP

      _IdZaduz := ""
      _Idkonto := "1200"
      @ m_x + 9, m_y + 2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
      IF gNW <> "X"
         @ m_x + 9, m_y + 40 SAY "Razduzuje: "; ?? _IdZaduz2
      ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.brĿ"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   IF !lPoNarudzbi
      @ m_x, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0
   ENDIF

   IF IsDomZdr()
      @ m_x, m_y + 2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
   ENDIF

   READ
   ESC_RETURN K_ESC

   _MKonto := _Idkonto2

   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA
   hseek _IdTarifa

   SELECT ROBA
   HSEEK _IdRoba
   SELECT koncij
   SEEK Trim( _idkonto2 )
   SELECT kalk_pripr  // napuni tarifu

   IF koncij->naz = "P"
      _FCJ := roba->PlC
   ENDIF

   DatPosljK()
   DuplRoba()

   IF fNovi
      SELECT roba
      _VPC := KoncijVPC()
      _NC := NC
      SELECT kalk_pripr
   ENDIF

   IF gCijene = "2" .AND. fNovi

      // ///// utvrdjivanje fakticke VPC
      IF gPDVMagNab == "N"
         faktVPC( @_VPC, _idfirma + _idkonto2 + _idroba )
      ENDIF
      SELECT kalk_pripr
   ENDIF

   VtPorezi()

   _GKolicina := 0

   // ////// kalkulacija nabavne cijene
   // ////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

   nKolS := 0
   nKolZN := 0
   nc1 := 0
   nc2 := 0
   dDatNab := CToD( "" )
   lGenStavke := .F.

   IF _TBankTr <> "X"   // ako je X onda su stavke vec izgenerisane
      IF !Empty( gMetodaNC )
         MsgO( "Racunam stanje na skladistu" )
         KalkNab( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         MsgC()
         @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "
         @ m_x + 12, Col() + 2 SAY nKols PICT pickol
      ENDIF
      IF dDatNab > _DatDok
         Beep( 1 )
         Msg( "Datum nabavke je " + DToC( dDatNab ), 4 )
      ENDIF
      // Vindija trazi da se uvijek nudi srednja nabavna cijena
      // kada malo razmislim najbolje da se ona uvijek nudi
      // if _kolicina >= 0
      IF gMetodaNC $ "13"
         _nc := nc1
      ELSEIF gMetodaNC == "2"
         _nc := nc2
      ENDIF
      // endif
   ENDIF
   SELECT kalk_pripr


   @ m_x + 13, m_y + 2    SAY "NAB.CJ   "  GET _NC  PICTURE PicDEM      VALID V_KolMag()

   PRIVATE _vpcsappp := 0

   @ m_x, m_y + 2   SAY "PC BEZ PDV" GET _VPC  valid {|| iif( gVarVP == "2" .AND. ( _vpc - _nc ) > 0, cisMarza := ( _vpc - _nc ) / ( 1 + tarifa->vpp ), _vpc - _nc ), .T. }  PICTURE PicDEM

   PRIVATE cTRabat := "%"
   @ m_x, m_y + 2    SAY "RABAT    " GET  _RABATV PICT picdem
   @ m_x, Col() + 2  GET cTRabat  PICT "@!" ;
      valid {|| PrerRab(), V_RabatV(), ctrabat $ "%AU" }

   _PNAP := 0

   IF IsPdv()
      _MPC := tarifa->opp
   ENDIF

   IF gPDVMagNab == "D"
      @ m_x + 16, m_y + 2 SAY "PDV (%)  " + Transform( _MPC, "99.99" )
   ELSE
      @ m_x + 16, m_y + 2 SAY "PDV (%)  " GET _MPC PICT "99.99" when {|| iif( roba->tip $ "VKX", _mpc := 0, NIL ), iif( roba->tip $ "VKX", pPDV14( .F. ), .T. ) } VALID pPDV14( .T. )
   ENDIF

   IF gVarVP == "1"
      _VPCsaPP := 0
      @ m_x, m_y + 2  SAY "PC SA PDV "
      @ m_x, m_Y + 50 GET _vpcSaPP PICTURE picdem ;
         when {|| _VPCSAPP := iif( _VPC <> 0, _VPC * ( 1 -_RabatV / 100 ) * ( 1 + _MPC / 100 ), 0 ), ShowGets(), .T. } ;
         valid {|| _vpcsappp := iif( _VPCsap <> 0, _vpcsap + _PNAP, _VPCSAPPP ), .T. }

   ELSE  // preracunate stope

      _VPCsaPP := 0
      @ m_x, m_y + 2  SAY "PC SA PDV "
      @ m_x, m_Y + 50 GET _vpcSaPP PICTURE picdem ;
         when {|| _VPCSAPP := iif( _VPC <> 0, _VPC * ( 1 -_RabatV / 100 ) * ( 1 + _MPC / 100 ), 0 ), ShowGets(), .T. } ;
         valid {|| _vpcsappp := iif( _VPCsap <> 0, _vpcsap + _PNAP, _VPCSAPPP ), .T. }
   ENDIF

   READ

   nStrana := 2

   IF roba->tip == "X"
      _marza := _vpc - _mpcsapp / ( 1 + _PORVT ) * _PORVT - _nc
   ELSE
      _mpcsapp := 0
      _marza := _vpc / ( 1 + _PORVT ) -_nc
   ENDIF


   // izlaz iz magacina
   _MKonto := _Idkonto2
   _MU_I := "5"
   _PKonto := ""; _PU_I := ""

   IF _idvd == "KO"
      _MU_I := "4" // ne utice na stanje
   ENDIF

   IF pIzgSt .AND. _kolicina > 0 .AND. LastKey() <> K_ESC // izgenerisane stavke postoje
      PRIVATE nRRec := RecNo()
      GO TOP
      my_flock()
      DO WHILE !Eof()  // nafiluj izgenerisane stavke
         IF kolicina == 0
            SKIP
            PRIVATE nRRec2 := RecNo()
            SKIP -1
            my_delete()
            GO nRRec2
            LOOP
         ENDIF
         IF brdok == _brdok .AND. idvd == _idvd .AND. Val( Rbr ) == nRbr

            nMarza := _VPC / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) -_NC  // ??????????
            REPLACE vpc WITH _vpc, ;
               rabatv WITH _rabatv, ;
               mkonto WITH _mkonto, ;
               tmarza  WITH _tmarza, ;
               mpc     WITH  _MPC, ;
               marza  WITH _vpc / ( 1 + _PORVT ) -kalk_pripr->nc, ;   // mora se uzeti nc iz ove stavke
            vpcsap WITH _VPC / ( 1 + _PORVT ) * ( 1 -_RABATV / 100 ) + iif( nMarza < 0, 0, nMarza ) * TARIFA->VPP / 100, ;
               mu_i WITH  _mu_i, ;
               pkonto WITH "", ;
               pu_i WITH  "", ;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   SET KEY K_ALT_K TO

   RETURN LastKey()




/*! \fn pPDV14(fret)
 *  \brief Prikaz PDV pri unosu 14-ke
 */

FUNCTION pPDV14( fRet )

   DevPos( m_x, m_y + 41 )
   IF roba->tip $ "VKX"
      // nista ppp
   ELSE
      QQOut( "   PDV:", Transform( _PNAP := _VPC * ( 1 -_RabatV / 100 ) * _MPC / 100, picdem ) )
   ENDIF

   _VPCSaP := iif( _VPC <> 0, _VPC * ( 1 -_RABATV / 100 ) + iif( nMarza < 0, 0, nMarza ) * TARIFA->VPP / 100, 0 )

   RETURN fret
