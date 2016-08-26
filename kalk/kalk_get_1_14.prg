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

FUNCTION kalk_get_1_14()

   LOCAL dDatVal := CToD( "" )

   pIzgSt := .F.

   SET KEY K_ALT_K TO kalk_kartica_magacin_pomoc_unos_14()

   IF nRbr == 1 .AND. kalk_is_novi_dokument()
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !kalk_is_novi_dokument()
      @ m_x + 6, m_y + 2   SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 18 )
      @ m_x + 7, m_y + 2   SAY "Faktura Broj:" GET _BrFaktP
      @ m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   valid {|| .T. }
      @ m_x + 7, Col() + 2 SAY "DatVal:" GET dDatVal ;
         WHEN  {|| dDatVal := get_kalk_14_datval( _brdok ), .T. } ;
         VALID {|| update_kalk_14_datval( _BrDok, dDatVal ), .T. }
      _IdZaduz := ""
      _Idkonto := "2110"
      PRIVATE cNBrDok := _brdok
      @ m_x + 9, m_y + 2 SAY8 "Magacinski konto razdužuje"  GET _IdKonto2  valid ( Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 ) )


   ELSE
      @ m_x + 6, m_y + 2   SAY8 "KUPAC: "; ?? _IdPartner
      @ m_x + 7, m_y + 2   SAY8 "Faktura Broj: "; ?? _BrFaktP
      @ m_x + 7, Col() + 2 SAY8 "Datum: "; ?? _DatFaktP

      _IdZaduz := ""
      _Idkonto := "2110"
      @ m_x + 9, m_y + 2 SAY8 "Magacinski konto razdužuje "; ?? _IdKonto2
      // IF gNW <> "X"
      // @ m_x + 9, m_y + 40 SAY8 "Razdužuje: "; ?? _IdZaduz2
      // ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.br "

   kalk_pripr_form_get_roba( @_idRoba, @_idTarifa, _IdVd, kalk_is_novi_dokument(), m_x + 11, m_y + 2, @aPorezi )


   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   @ m_x + 12, m_y + 2   SAY8 "Količina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

   READ
   ESC_RETURN K_ESC

   _MKonto := _Idkonto2

   IF roba_barkod_pri_unosu()
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA
   HSEEK _IdTarifa

   SELECT ROBA
   HSEEK _IdRoba

   SELECT koncij
   SEEK Trim( _idkonto2 )
   SELECT kalk_pripr

   IF koncij->naz = "P"
      _FCJ := roba->PlC
   ENDIF

   //check_datum_posljednje_kalkulacije()
   //DuplRoba()

   IF kalk_is_novi_dokument()
      SELECT roba
      _VPC := KoncijVPC()
      _NC := NC
      SELECT kalk_pripr
   ENDIF

   IF dozvoljeno_azuriranje_sumnjivih_stavki() .AND. kalk_is_novi_dokument()
      SELECT kalk_pripr
   ENDIF

   set_pdv_public_vars()

   _GKolicina := 0

   nKolS := 0
   nKolZN := 0
   nc1 := 0
   nc2 := 0
   dDatNab := CToD( "" )
   lGenStavke := .F.

   IF _TBankTr <> "X"   // ako je X onda su stavke vec izgenerisane

      IF !Empty( gMetodaNC )

         kalk_get_nabavna_mag( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )

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
      IF gMetodaNC == "2"
         _nc := nc2
      ENDIF

   ENDIF
   SELECT kalk_pripr


   @ m_x + 13, m_y + 2    SAY8 "Nab.Cjena "  GET _NC  PICTURE PicDEM   VALID kalk_valid_kolicina_mag()

   PRIVATE _vpcsappp := 0

   @ m_x + 14, m_y + 2   SAY8 "PC BEZ PDV" GET _VPC  valid {|| iif( gVarVP == "2" .AND. ( _vpc - _nc ) > 0, cisMarza := ( _vpc - _nc ) / ( 1 + tarifa->vpp ), _vpc - _nc ), .T. }  PICTURE PicDEM

   PRIVATE cTRabat := "%"
   @ m_x + 15, m_y + 2    SAY8 "RABAT    " GET  _RABATV PICT picdem
   @ m_x + 15, Col() + 2  GET cTRabat  PICT "@!"  valid {|| PrerRab(), V_RabatV(), ctrabat $ "%AU" }

   _PNAP := 0

   _MPC := tarifa->opp

   @ m_x + 16, m_y + 2 SAY8 "PDV (%)  " + Transform( _MPC, "99.99" )

   IF gVarVP == "1"
      _VPCsaPP := 0
      @ m_x + 17, m_y + 2  SAY8 "PC SA PDV "
      @ m_x + 17, m_Y + 50 GET _vpcSaPP PICTURE picdem ;
         when {|| _VPCSAPP := iif( _VPC <> 0, _VPC * ( 1 -_RabatV / 100 ) * ( 1 + _MPC / 100 ), 0 ), ShowGets(), .T. } ;
         valid {|| _vpcsappp := iif( _VPCsap <> 0, _vpcsap + _PNAP, _VPCSAPPP ), .T. }

   ELSE
      _VPCsaPP := 0
      @ m_x + 17, m_y + 2  SAY8 "PC SA PDV "
      @ m_x + 17, m_Y + 50 GET _vpcSaPP PICTURE picdem ;
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

            nMarza := _VPC / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) -_NC
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




/*
   pPDV14(fret)
   Prikaz PDV pri unosu 14-ke
 */

FUNCTION pPDV14( lRet )

   DevPos( m_x, m_y + 41 )
   IF roba->tip $ "VKX"
      // nista ppp
   ELSE
      QQOut( "   PDV:", Transform( _PNAP := _VPC * ( 1 -_RabatV / 100 ) * _MPC / 100, picdem ) )
   ENDIF

   _VPCSaP := iif( _VPC <> 0, _VPC * ( 1 -_RABATV / 100 ) + iif( nMarza < 0, 0, nMarza ) * TARIFA->VPP / 100, 0 )

   RETURN lRet
