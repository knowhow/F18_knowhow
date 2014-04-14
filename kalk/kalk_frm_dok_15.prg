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



FUNCTION Get1_15()

   PRIVATE aPorezi := {}

   pIzgSt := .F.   // izgenerisane stavke jos ne postoje

   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1  .OR. !fnovi
      _GKolicina := _GKolicin2 := 0
      @  m_x + 6, m_y + 2   SAY "KUPAC:" GET _IdPartner PICT "@!" VALID Empty( _IdPartner ) .OR. P_Firma( @_IdPartner, 6, 18 )
      @  m_x + 7, m_y + 2   SAY "Faktura Broj:" GET _BrFaktP
      @  m_x + 7, Col() + 2 SAY "Datum:" GET _DatFaktP   ;
         valid {|| .T. }

      @ m_x + 8, m_y + 2   SAY "Prodavnicki Konto zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!"
      IF gNW <> "X"
         @ m_x + 8, m_y + 42  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. P_Firma( @_IdZaduz, 25, 1 )
      ENDIF

      @ m_x + 9, m_y + 2   SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
         VALID Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 )
      IF gNW <> "X"
         @ m_x + 9, m_y + 42 SAY "Razduzuje:" GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. P_Firma( @_IdZaduz2, 21, 5 )
      ENDIF
      read; ESC_RETURN K_ESC
   ELSE
      IF _IdVD $ "11#12#13#22"
         @  m_x + 6, m_y + 2   SAY "Otpremnica - Broj: "; ?? _BrFaktP
         @  m_x + 6, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      ENDIF
      @ m_x + 8, m_y + 2   SAY "Prodavnicki Konto zaduzuje "; ?? _IdKonto
      IF gNW <> "X"
         @ m_x + 8, m_y + 42  SAY "Zaduzuje: "; ?? _IdZaduz
      ENDIF
      @ m_x + 9, m_y + 2   SAY "Magacinski konto razduzuje "; ?? _IdKonto2
      IF gNW <> "X"
         @ m_x + 9, m_y + 42  SAY "Razduzuje: "; ?? _IdZaduz2
      ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.brÄ¿"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _IdRoba := PadR( _idroba, Val( gDuzSifIni ) ), .T. } VALID VRoba()
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" VALID VRoba()
   ENDIF

   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   IF !lPoNarudzbi
      @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0
   ENDIF
   READ
   ESC_RETURN K_ESC
   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   SELECT TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT koncij; SEEK Trim( _idkonto )
   SELECT kalk_pripr  // napuni tarifu

   _MKonto := _Idkonto2
   _PKonto := _Idkonto
   DatPosljK()
   DatPosljP()
   DuplRoba()


   _GKolicina := _GKolicin2 := 0
   IF fNovi
      SELECT roba
      _MPCSaPP := UzmiMPCSif()

      IF koncij->naz <> "N1" .OR. gPDVMagNab == "N"
         _FCJ := NC; _VPC := UzmiVPCSif( _mkonto )
      ELSE
         _FCJ := NC; _VPC := NC
      ENDIF

      SELECT koncij; SEEK Trim( _pkonto ); SELECT roba
      IF gcijene == "2"
         FaktMPC( @_MPCSAPP, _idfirma + _Pkonto + _idroba )
      ENDIF

      SELECT kalk_pripr
      _Marza2 := 0; _TMarza2 := "A"
   ENDIF

   // if gcijene=="2" .OR. ROUND(_VPC,3)=0 // uvijek nadji
   // select koncij; seek trim(_mkonto); select kalk_pripr  // magacin
   // FaktVPC(@_VPC,_idfirma+_mkonto+_idroba)
   // select koncij; seek trim(_pkonto); select kalk_pripr  // magacin
   // endif

   VTPorezi()

   _VPC :=  _mpcsapp / ( 1 + _zpp + _ppp ) / ( 1 + _opp )
   _MPC :=  _VPC


   // ////// kalkulacija nabavne cijene u magacinu
   // ////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

   nKolS := 0;nKolZN := 0;nc1 := nc2 := 0
   lGenStavke := .F.
   IF _TBankTr <> "X" .OR. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
      IF !Empty( gMetodaNC ) .OR. lPoNarudzbi
         nc1 := nc2 := 0
         dDatNab := CToD( "" )
         IF lPoNarudzbi
            aNabavke := {}
            IF !fNovi
               AAdd( aNabavke, { 0, _nc, _kolicina, _idnar, _brojnar } )
            ENDIF
            IF !fNovi
               IF _kolicina < 0
                  KalkNab3p( _idfirma, _idroba, _idkonto, aNabavke )
               ELSE
                  KalkNab3m( _idfirma, _idroba, _idkonto2, aNabavke )
               ENDIF
            ELSEIF Pitanje(, "1-storno MP putem VP , 2-prodaja MP putem VP (1/2) ?", "2", "12" ) == "2"
               KalkNab3p( _idfirma, _idroba, _idkonto, aNabavke )
            ELSE
               KalkNab3m( _idfirma, _idroba, _idkonto2, aNabavke )
            ENDIF
            IF Len( aNabavke ) > 1; lGenStavke := .T. ; ENDIF
            IF Len( aNabavke ) > 0
               // - teku†a -
               i := Len( aNabavke )
               _fcj := _nc := aNabavke[ i, 2 ]
               _kolicina := aNabavke[ i, 3 ]
               _idnar    := aNabavke[ i, 4 ]
               _brojnar  := aNabavke[ i, 5 ]
               // ----------
            ENDIF
            @ m_x + 12, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol WHEN .F.
            @ Row(), Col() + 2 SAY IspisPoNar(,, .T. )
         ELSE
            IF _kolicina > 0
               MsgO( "Racunam stanje na skladistu" )
               KalkNab( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
               MsgC()
            ELSE
               MsgO( "Racunam stanje prodavnice" )
               KalkNabP( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, dDatNab )
               MsgC()
            ENDIF
            IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );ENDIF
            IF gMetodaNC $ "13"; _fcj := nc1; ELSEIF gMetodaNC == "2"; _fcj := nc2; ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF !lPoNarudzbi
      IF _kolicina > 0
         @ m_x + 12, m_y + 30   SAY "Na stanju magacin "; @ m_x + 12, Col() + 2 SAY nkols PICT pickol
      ELSE
         @ m_x + 12, m_y + 30   SAY "Na stanju prodavn "; @ m_x + 12, Col() + 2 SAY nkols PICT pickol
      ENDIF
   ENDIF

   SELECT koncij; SEEK Trim( _idkonto2 ); SELECT kalk_pripr
   IF  koncij->naz == "N1"
      _VPC := _NC
   ENDIF

   IF koncij->naz <> "N1" .OR. gPDVMagNab == "N"
      IF _kolicina > 0
         @ m_x + 14, m_y + 2    SAY "NC  :"  GET _fcj PICTURE gPicNC VALID V_KolMag()
      ELSE // storno zaduzenja
         @ m_x + 14, m_y + 2    SAY "NC  :"  GET _fcj PICTURE gPicNC VALID V_KolPro()
      ENDIF
      @ m_x + 14, Col() + 2  SAY "VPC :"  GET _vpc PICTURE picdem ;
         when {|| iif( gCijene == "2", .F., .T. ) }
   ELSE
      _vpc := _fcj
      @ m_x + 14, m_y + 2    SAY "NABAVNA CIJENA (NC)       :"
      IF _kolicina > 0
         @ m_x + 14, m_y + 50   GET _fcj    PICTURE gPicNC ;
            VALID {|| V_KolMag(), ;
            _vpc := _Fcj, .T. }
      ELSE // storno zaduzenja prodavnice
         @ m_x + 14, m_y + 50   GET _FCJ    PICTURE PicDEM;
            VALID {|| V_KolPro(), ;
            _vpc := _fcj, .T. }
      ENDIF
   ENDIF

   SELECT koncij; SEEK Trim( _idkonto ); SELECT kalk_pripr

   IF fnovi
      _TPrevoz := "R"
   ENDIF
   IF nRbr == 1 .OR. !fnovi // prva stavka
      // @ m_x+16,m_y+2    SAY "MP trosak (A,R):" get _TPrevoz valid _TPrevoz $ "AR" pict "@!"
      // @ m_x+16,col()+2  GET _prevoz pict picdem
   ELSE
      // @ m_x+16,m_y+2    SAY "MP trosak:"; ?? "("+_TPrevoz+") "; ?? _prevoz
   ENDIF

   PRIVATE fMarza := " "
   _Tmarza := "A"
   _marza := _vpc / ( 1 + _PORVT ) -_fcj


   @ m_x + 18, m_y + 2  SAY "MALOPROD. CJENA (MPC):"

   @ m_x + 18, m_y + 50 GET _MPC PICT PicDEM WHEN WMpc( .T. ) VALID VMpc( .T. )

   // _mpc:=iif(_mpcsapp<>0 .and. empty(fmarza),_mpcsapp/(1+_opp)/(1+_ppp),_mpc),.t.} ;
   // _mpcsapp:=iif(_mpcsapp==0,_MPCSaPP:=round((1+_opp)*_MPC*(1+_ppp),2),_mpcsapp),.t.}

   @ m_x + 19, m_y + 2  SAY "PPP (%):"; @ Row(), Col() + 2 SAY  _opp * 100   PICTURE "99.99"
   @ m_x + 19, Col() + 8  SAY "PPU (%):"; @ Row(), Col() + 2  SAY _ppp * 100 PICTURE "99.99"
   @ m_x + 19, Col() + 8  SAY "PP (%):"; @ Row(), Col() + 2  SAY _zpp * 100 PICTURE "99.99"

   @ m_x + 20, m_y + 2 SAY "MPC SA POREZOM:"

   @ m_x + 20, m_y + 50 GET _MPCSaPP  PICTURE PicDEM VALID VMpcSaPP( .F. )

   READ
   ESC_RETURN K_ESC

   _Tmarza := "A"
   _marza := _vpc / ( 1 + _PORVT ) -_fcj

   SELECT koncij; SEEK Trim( _idkonto )
   StaviMPCSif( _mpcsapp, .T. )       // .t. znaci sa upitom
   SELECT kalk_pripr

   IF lPoNarudzbi
      _MKonto := _Idkonto2; _MU_I := "8"     // - 1 * ulaz , -1 *  izlaz
      _PKonto := _Idkonto;  _PU_I := "1"     // ulaz u prodavnicu
      IF lGenStavke
         pIzgSt := .T.
         // viçe od jedne stavke
         FOR i := 1 TO Len( aNabavke ) -1
            // generiçi sve izuzev posljednje
            APPEND BLANK
            _error    := IF( _error <> "1", "0", _error )
            _rbr      := RedniBroj( nRBr )
            _fcj := _nc := aNabavke[ i, 2 ]
            _kolicina := aNabavke[ i, 3 ]
            _idnar    := aNabavke[ i, 4 ]
            _brojnar  := aNabavke[ i, 5 ]
            // _vpc      := _nc
            Gather()
            ++nRBr
         NEXT
         // posljednja je teku†a
         _fcj := _nc := aNabavke[ i, 2 ]
         _kolicina := aNabavke[ i, 3 ]
         _idnar    := aNabavke[ i, 4 ]
         _brojnar  := aNabavke[ i, 5 ]
         // _vpc      := _nc
      ELSE
         // jedna ili nijedna
         IF Len( aNabavke ) > 0
            // jedna
            _fcj := _nc := aNabavke[ 1, 2 ]
            _kolicina := aNabavke[ 1, 3 ]
            _idnar    := aNabavke[ 1, 4 ]
            _brojnar  := aNabavke[ 1, 5 ]
            // _vpc      := _nc
         ELSE
            // nije izabrana koliŸina -> kao da je prekinut unos tipkom Esc
            RETURN ( K_ESC )
         ENDIF
      ENDIF
   ENDIF

   _MKonto := _Idkonto2; _MU_I := "8"     // - 1 * ulaz , -1 *  izlaz
   _PKonto := _Idkonto;  _PU_I := "1"     // ulaz u prodavnicu

   nStrana := 2

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
            REPLACE nc WITH kalk_pripr->fcj, ;
               vpc WITH _vpc, ;
               tprevoz WITH _tprevoz, ;
               prevoz WITH _prevoz, ;
               mpc    WITH _mpc, ;
               mpcsapp WITH _mpcsapp, ;
               tmarza  WITH _tmarza, ;
               marza  WITH _vpc / ( 1 + _PORVT ) -kalk_pripr->fcj, ;      // konkretna vp marza
            tmarza2  WITH _tmarza2, ;
               marza2  WITH _marza2, ;
               mkonto WITH _mkonto, ;
               mu_i WITH  _mu_i, ;
               pkonto WITH _pkonto, ;
               pu_i WITH  _pu_i,;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   RETURN LastKey()
// }
