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

/*! \fn Get1_14()
 *  \brief Prva strana maske za unos dokumenta tipa 14
 */

FUNCTION Get1_14()

   // {
   pIzgSt := .F.   // izgenerisane stavke jos ne postoje
   // private cisMarza:=0

   SET KEY K_ALT_K TO KM2()
   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF
   IF nRbr == 1 .OR. !fnovi
      @  m_x + 6, m_y + 2   SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 18 )
      @  m_x + 7, m_y + 2   SAY "Faktura Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   ;
         valid {|| .T. }
      _IdZaduz := ""

      _Idkonto := "1200"
      PRIVATE cNBrDok := _brdok
      @ m_x + 9, m_y + 2 SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
         valid ( Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 24 ) ) .AND. ;
         MarkBrDok( fNovi )
      IF gNW <> "X"
         @ m_x + 9, m_y + 40 SAY "Razduzuje:" GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. P_Firma( @_IdZaduz2, 24 )
      ENDIF
   ELSE
      @  m_x + 6, m_y + 2   SAY "KUPAC: "; ?? _IdPartner
      @  m_x + 7, m_y + 2   SAY "Faktura Broj: "; ?? _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      _IdZaduz := ""
      _Idkonto := "1200"
      @ m_x + 9, m_y + 2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
      IF gNW <> "X"
         @ m_x + 9, m_y + 40 SAY "Razduzuje: "; ?? _IdZaduz2
      ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.brÄ¿"
   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   IF !lPoNarudzbi
      @ m_x + 12 + IF( lPoNarudzbi, 1, 0 ), m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0
   ENDIF

   IF IsDomZdr()
      @ m_x + 13 + IF( lPoNarudzbi, 1, 0 ), m_y + 2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
   ENDIF

   read; ESC_RETURN K_ESC

   _MKonto := _Idkonto2

   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT ROBA; HSEEK _IdRoba
   SELECT koncij; SEEK Trim( _idkonto2 )
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
      IF roba->tip = "X"
         _MPCSAPP := roba->mpc   // pohraniti za naftu MPC !!!!
      ENDIF
      SELECT kalk_pripr
   ENDIF
   IF gCijene = "2" .AND. fNovi
      // ///// utvrdjivanje fakticke VPC
      faktVPC( @_VPC, _idfirma + _idkonto2 + _idroba )
      SELECT kalk_pripr
   ENDIF
   VtPorezi()

   IF roba->tip = "X" .AND. _MPCSAPP = 0
      _MPCSAPP := roba->mpc   // pohraniti za naftu MPC !!!!
   ENDIF

   _GKolicina := 0
   // ////// kalkulacija nabavne cijene
   // ////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
   nKolS := 0;nKolZN := 0;nc1 := nc2 := 0; dDatNab := CToD( "" )
   lGenStavke := .F.
   IF _TBankTr <> "X" .OR. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
      IF !Empty( gMetodaNC ) .OR. lPoNarudzbi
         IF lPoNarudzbi
            aNabavke := {}
            IF !fNovi
               AAdd( aNabavke, { 0, _nc, _kolicina, _idnar, _brojnar } )
            ENDIF
            KalkNab3m( _idfirma, _idroba, _idkonto2, aNabavke, @nKolS )
            IF Len( aNabavke ) > 1; lGenStavke := .T. ; ENDIF
            IF Len( aNabavke ) > 0
               // - tekua -
               i := Len( aNabavke )
               _nc       := aNabavke[ i, 2 ]
               _kolicina := aNabavke[ i, 3 ]
               _idnar    := aNabavke[ i, 4 ]
               _brojnar  := aNabavke[ i, 5 ]
               // ----------
            ENDIF
            @ m_x + 12 + IF( lPoNarudzbi, 1, 0 ), m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol WHEN .F.
            @ Row(), Col() + 2 SAY IspisPoNar(,, .T. )
         ELSE
            MsgO( "Racunam stanje na skladistu" )
            KalkNab( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
            MsgC()
            @ m_x + 12 + IF( lPoNarudzbi, 1, 0 ), m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12 + IF( lPoNarudzbi, 1, 0 ), Col() + 2 SAY nkols PICT pickol
         ENDIF
      ENDIF
      IF !lPoNarudzbi
         IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
         IF _kolicina >= 0
            IF gMetodaNC $ "13"; _nc := nc1; ELSEIF gMetodaNC == "2"; _nc := nc2; ENDIF
         ENDIF
      ENDIF
   ENDIF
   SELECT kalk_pripr

   @ m_x + 13 + IF( lPoNarudzbi, 1, 0 ), m_y + 2    SAY "NAB.CJ   "  GET _NC  PICTURE PicDEM      VALID V_KolMag()

   PRIVATE _vpcsappp := 0

   @ m_x + 14 + IF( lPoNarudzbi, 1, 0 ), m_y + 2   SAY "VPC      " GET _VPC  valid {|| iif( gVarVP == "2" .AND. ( _vpc - _nc ) > 0, cisMarza := ( _vpc - _nc ) / ( 1 + tarifa->vpp ), _vpc - _nc ), .T. }  PICTURE PicDEM

   PRIVATE cTRabat := "%"
   @ m_x + 15 + IF( lPoNarudzbi, 1, 0 ), m_y + 2    SAY "RABAT    " GET  _RABATV PICT picdem
   @ m_x + 15 + IF( lPoNarudzbi, 1, 0 ), Col() + 2  GET cTRabat  PICT "@!" ;
      valid {|| PrerRab(), V_RabatV(), ctrabat $ "%AU" }

   _PNAP := 0
   @ m_x + 16 + IF( lPoNarudzbi, 1, 0 ), m_y + 2    SAY "PPP (%)  " GET _MPC PICT "99.99" ;
      when {|| iif( roba->tip $ "VKX", _mpc := 0, NIL ), iif( roba->tip $ "VKX", ppp14( .F. ), .T. ) } ;
      VALID ppp14( .T. )

   @ m_x + 17 + IF( lPoNarudzbi, 1, 0 ), m_y + 2    SAY "PRUC (%) "; QQOut( Transform( TARIFA->VPP, "99.99" ) )

   IF gVarVP == "1"
      _VPCsaPP := 0
      @ m_x + 19 + IF( lPoNarudzbi, 1, 0 ), m_y + 2  SAY "VPC + PPP  "
      @ m_x + 19 + IF( lPoNarudzbi, 1, 0 ), m_Y + 50 GET _vpcSaPP PICTURE picdem ;
         when {|| _VPCSAPP := iif( _VPC <> 0, _VPC * ( 1 -_RabatV / 100 ) * ( 1 + _MPC / 100 ), 0 ), ShowGets(), .T. } ;
         valid {|| _vpcsappp := iif( _VPCsap <> 0, _vpcsap + _PNAP, _VPCSAPPP ), .T. }

   ELSE  // preracunate stope
      _VPCsaPP := 0
      @ m_x + 19 + IF( lPoNarudzbi, 1, 0 ), m_y + 2  SAY "VPC + PPP  "
      @ m_x + 19 + IF( lPoNarudzbi, 1, 0 ), m_Y + 50 GET _vpcSaPP PICTURE picdem ;
         when {|| _VPCSAPP := iif( _VPC <> 0, _VPC * ( 1 -_RabatV / 100 ) * ( 1 + _MPC / 100 ), 0 ), ShowGets(), .T. } ;
         valid {|| _vpcsappp := iif( _VPCsap <> 0, _vpcsap + _PNAP, _VPCSAPPP ), .T. }
   ENDIF

   IF gMagacin == "1"  // ovu cijenu samo prikazati ako se vodi po nabavnim cijenama
      _VPCSAPPP := 0
      @ m_x + 20 + IF( lPoNarudzbi, 1, 0 ), m_y + 2 SAY "VPC + PPP + PRUC:"
      @ m_x + 20 + IF( lPoNarudzbi, 1, 0 ), m_Y + 50 GET _vpcSaPPP PICTURE picdem  ;
         VALID {||  VPCSAPPP() }

   ENDIF
   READ
   nStrana := 2
   IF roba->tip = "X"
      _marza := _vpc - _mpcsapp / ( 1 + _PORVT ) * _PORVT - _nc
   ELSE
      _mpcsapp := 0
      _marza := _vpc / ( 1 + _PORVT ) -_nc
   ENDIF

   IF lPoNarudzbi
      _MKonto := _Idkonto2;_MU_I := "5"     // izlaz iz magacina
      _PKonto := ""; _PU_I := ""
      IF _idvd == "KO"
         _MU_I := "4" // ne utice na stanje
      ENDIF
      IF lGenStavke
         pIzgSt := .T.
         // viçe od jedne stavke
         FOR i := 1 TO Len( aNabavke ) -1
            // generiçi sve izuzev posljednje
            APPEND BLANK
            _error    := IF( _error <> "1", "0", _error )
            _rbr      := RedniBroj( nRBr )
            _nc       := aNabavke[ i, 2 ]
            _kolicina := aNabavke[ i, 3 ]
            _idnar    := aNabavke[ i, 4 ]
            _brojnar  := aNabavke[ i, 5 ]
            // _vpc      := _nc
            Gather()
            ++nRBr
         NEXT
         // posljednja je tekua
         _nc       := aNabavke[ i, 2 ]
         _kolicina := aNabavke[ i, 3 ]
         _idnar    := aNabavke[ i, 4 ]
         _brojnar  := aNabavke[ i, 5 ]
         // _vpc      := _nc
      ELSE
         // jedna ili nijedna
         IF Len( aNabavke ) > 0
            // jedna
            _nc       := aNabavke[ 1, 2 ]
            _kolicina := aNabavke[ 1, 3 ]
            _idnar    := aNabavke[ 1, 4 ]
            _brojnar  := aNabavke[ 1, 5 ]
            // _vpc      := _nc
         ELSE
            // nije izabrana koliina -> kao da je prekinut unos tipkom Esc
            RETURN ( K_ESC )
         ENDIF
      ENDIF
   ENDIF

   _MKonto := _Idkonto2;_MU_I := "5"     // izlaz iz magacina
   _PKonto := ""; _PU_I := ""
   IF _idvd == "KO"
      _MU_I := "4" // ne utice na stanje
   ENDIF

   IF pIzgSt  .AND. _kolicina > 0 .AND. LastKey() <> K_ESC // izgenerisane stavke postoje
      PRIVATE nRRec := RecNo()
      GO TOP
      DO WHILE !Eof()  // nafiluj izgenerisane stavke
         IF kolicina == 0
            SKIP
            PRIVATE nRRec2 := RecNo()
            SKIP -1
            dbdelete2()
            GO nRRec2
            LOOP
         ENDIF
         IF brdok == _brdok .AND. idvd == _idvd .AND. Val( Rbr ) == nRbr

            nMarza := _VPC / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) -_NC  // ??????????
            RREPLACE vpc WITH _vpc, ;
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
      GO nRRec
   ENDIF

   SET KEY K_ALT_K TO

   RETURN LastKey()
// }




/*! \fn PPP14(fret)
 *  \brief Prikaz poreza pri unosu 14-ke
 */

FUNCTION PPP14( fret )

   // {
   DevPos( m_x + 16 + IF( lPoNarudzbi, 1, 0 ), m_y + 41 )
   IF roba->tip $ "VKX"
      // nista ppp
   ELSE
      QQOut( "    PPP:", Transform( _PNAP := _VPC * ( 1 -_RabatV / 100 ) * _MPC / 100, picdem ) )
   ENDIF
   DevPos( m_x + 17 + IF( lPoNarudzbi, 1, 0 ), m_y + 41 )
   QQOut( "   PRUC:", Transform( iif( nmarza < 0, 0, nmarza ) * ;
      iif( gVarVP == "1", tarifa->vpp / 100, tarifa->vpp / 100 / ( 1 + tarifa->vpp / 100 ) ), picdem ) )
   _VPCSaP := iif( _VPC <> 0, _VPC * ( 1 -_RABATV / 100 ) + iif( nMarza < 0, 0, nMarza ) * TARIFA->VPP / 100, 0 )

   RETURN fret
// }




/*! \fn KM2()
 *  \brief Magacinska kartica kao pomoc pri unosu 14-ke
 */

FUNCTION KM2()

   LOCAL nR1, nR2, nR3
   PRIVATE GetList := {}

   SELECT  roba
   nR1 := RecNo()
   SELECT kalk_pripr
   nR2 := RecNo()
   SELECT tarifa
   nR3 := RecNo()
   my_close_all_dbf()
   Kartica_magacin( _IdFirma, _idroba, _IdKonto2 )
   o_kalk_edit()
   SELECT roba
   GO nR1
   SELECT kalk_pripr
   GO nR2
   SELECT tarifa
   GO nR3
   SELECT kalk_pripr

   RETURN NIL


/*! \fn MarkBrDok(fNovi)
 *  \brief Odredjuje sljedeci broj dokumenta uzimajuci u obzir marker definisan u polju koncij->m1
 */

FUNCTION MarkBrDok( fNovi )

   LOCAL nArr := Select()

   _brdok := cNBrDok
   IF fNovi .AND. KONCIJ->( FieldPos( "M1" ) ) <> 0
      SELECT KONCIJ; HSEEK _idkonto2
      IF !Empty( m1 )
         SELECT kalk; SET ORDER TO TAG "1"; SEEK _idfirma + _idvd + "X"
         SKIP -1
         _brdok := Space( 8 )
         DO WHILE !Bof() .AND. idvd == _idvd
            IF Upper( Right( brdok, 3 ) ) == Upper( KONCIJ->m1 )
               _brdok := brdok
               EXIT
            ENDIF
            SKIP -1
         ENDDO
         _Brdok := UBrojDok( Val( Left( _brdok, 5 ) ) + 1, 5, KONCIJ->m1 )
      ENDIF
      SELECT ( nArr )
   ENDIF
   @  m_x + 2, m_y + 46  SAY _BrDok COLOR INVERT

   RETURN .T.
