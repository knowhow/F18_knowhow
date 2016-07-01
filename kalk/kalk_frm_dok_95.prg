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



FUNCTION Get1_95()

   // izgenerisane stavke jos ne postoje
   pIzgSt := .F.


   SET KEY K_ALT_K TO KM2()
   IF nRbr == 1 .AND. fnovi
      _DatFaktP := _datdok
   ENDIF

   IF nRbr == 1 .OR. !fnovi .OR. gMagacin == "1"
      @  m_x + 5, m_y + 2   SAY "Dokument Broj:" GET _BrFaktP
      @  m_x + 5, Col() + 1 SAY "Datum:" GET _DatFaktP   ;
         valid {|| .T. }

      _IdZaduz := ""
      @ m_x + 8, m_y + 2 SAY8 "Magacinski konto razdužuje"  GET _IdKonto2 ;
         VALID Empty( _IdKonto2 ) .OR. P_Konto( @_IdKonto2, 21, 5 )
      IF gNW <> "X"
         @ m_x + 8, m_y + 40 SAY "Razdužuje:" GET _IdZaduz2   PICT "@!"  VALID Empty( _idZaduz2 ) .OR. P_Firma( @_IdZaduz2, 21, 5 )
      ELSE
         IF !Empty( cRNT1 ) .AND. _idvd $ "97#96#95"
            IF ( IsRamaGlas() )
               @ m_x + 8, m_y + 40 SAY "Rad.nalog:" GET _IdZaduz2 PICT "@!" VALID RadNalOK()
            ELSE
               @ m_x + 8, m_y + 40 SAY "Rad.nalog:" GET _IdZaduz2   PICT "@!"
            ENDIF
         ENDIF
      ENDIF
      IF _idvd $ "97#96#95"    // ako je otprema, gdje to ide

         @ m_x + 9, m_y + 2   SAY "Konto zaduzuje            " GET _IdKonto VALID  Empty( _IdKonto ) .OR. P_Konto( @_IdKonto, 21, 5 ) PICT "@!"

         IF ( _idvd == "95" .AND. IsVindija() )

            @ m_x + 9, m_y + 40 SAY "Šifra veze otpisa:" GET _IdPartner  VALID Empty( _idPartner ) .OR. P_Firma( @_IdPartner, 21, 5 ) PICT "@!"

         ELSEIF gMagacin == "1"
            @ m_x + 9, m_y + 40 SAY8 "Partner zadužuje:" GET _IdPartner  VALID Empty( _idPartner ) .OR. P_Firma( @_IdPartner, 21, 5 ) PICT "@!"

         ELSE
            IF _idvd == "96"
               @ m_x + 9, m_y + 40 SAY8 "Partner zadužuje:" GET _IdPartner  VALID Empty( _idPartner ) .OR. P_Firma( @_IdPartner, 21, 5 ) PICT "@!"
            ENDIF
         ENDIF

      ELSE
         _idkonto := ""
      ENDIF

   ELSE
      @  m_x + 6, m_y + 2   SAY "Dokument Broj: "; ?? _BrFaktP
      @  m_x + 6, Col() + 2 SAY "Datum: "; ?? _DatFaktP
      _IdZaduz := ""
      @ m_x + 8, m_y + 2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
      @ m_x + 9, m_y + 2 SAY "Konto zaduzuje "; ?? _IdKonto
      IF gNW <> "X"
         @ m_x + 9, m_y + 40 SAY "Razduzuje: "; ?? _IdZaduz2
      ENDIF
   ENDIF

   @ m_x + 10, m_y + 66 SAY "Tarif.brÄ¿"

   IF lKoristitiBK
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!S10" when {|| _idRoba := PadR( _idRoba, Val( gDuzSifIni ) ), .T. } valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ELSE
      @ m_x + 11, m_y + 2   SAY "Artikal  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), say_from_valid( 11, 23, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
   ENDIF
   @ m_x + 11, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   read; ESC_RETURN K_ESC
   IF lKoristitiBK
      _idRoba := Left( _idRoba, 10 )
   ENDIF

   _MKonto := _Idkonto2
   check_datum_posljednje_kalkulacije()
   DuplRoba()

   SELECT koncij
   SEEK Trim( _idkonto2 )
   SELECT TARIFA
   HSEEK _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT kalk_pripr  // napuni tarifu

   @ m_x + 13, m_y + 2   SAY8 "Količina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0



   _GKolicina := 0
   IF fNovi

      SELECT ROBA; HSEEK _IdRoba
      IF koncij->naz == "P2"
         _VPC := PLC
      ELSE
         _VPC := KoncijVPC()
      ENDIF

      _NC := NC
   ENDIF

   IF dozvoljeno_azuriranje_sumnjivih_stavki() .AND. fNovi
  
      kalk_vpc_po_kartici( @_VPC, _idfirma, _idkonto2, _idroba )
      SELECT kalk_pripr
   ENDIF


   nKolS := 0
   nKolZN := 0
   nc1 := nc2 := 0
   dDatNab := CToD( "" )

   lGenStavke := .F.

   IF _TBankTr <> "X"

      IF !Empty( gMetodaNC )  .AND. !( roba->tip $ "UT" )

         MsgO( "Racunam stanje na skladistu" )
         get_kalk_nab( _idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         MsgC()

         @ m_x + 12, m_y + 30   SAY "Ukupno na stanju "; @ m_x + 12, Col() + 2 SAY nKols PICT pickol
         @ m_x + 13, m_y + 30   SAY "Srednja nc "; @ m_x + 13, Col() + 2 SAY nc2 PICT pickol

      ENDIF

      IF dDatNab > _DatDok; Beep( 1 ); Msg( "Datum nabavke je " + DToC( dDatNab ), 4 ); ENDIF

      IF !( roba->tip $ "UT" )

         IF gMetodaNC $ "13"
            _nc := nc1
         ELSEIF gMetodaNC == "2"
            _nc := nc2
         ENDIF

         IF gMetodaNc == "2"
            IF _kolicina > 0

               SELECT roba
               _rec := dbf_get_rec()
               _rec[ "nc" ] := _nc
               update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" )
               SELECT kalk_pripr // nafiluj sifrarnik robe sa nc sirovina, robe
            ENDIF
         ENDIF

      ENDIF
   ENDIF

   SELECT kalk_pripr
   @ m_x + 14, m_y + 2  SAY "NAB.CJ   "  GET _NC  PICTURE gPicNC  VALID V_KolMag()
   PRIVATE _vpcsappp := 0

   READ
   _Marza := 0; _TMarza := "A"; _VPC := _NC



   IF !IsPDV()
      _mpcsapp := 0
   ENDIF

   nStrana := 2
   _marza := _vpc - _nc
   _MKonto := _Idkonto2;_MU_I := "5"     // izlaz iz magacina
   _PKonto := ""; _PU_I := ""

   IF pIzgSt  .AND. _kolicina > 0 .AND.  LastKey() <> K_ESC // izgenerisane stavke postoje
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

            nMarza := 0
            REPLACE vpc WITH kalk_pripr->nc, ;
               vpcsap WITH  kalk_pripr->nc, ;
               rabatv WITH  0, ;
               marza WITH  0

            REPLACE  mkonto WITH _mkonto, ;
               tmarza  WITH _tmarza, ;
               mpc     WITH  _MPC, ;
               mu_i WITH  _mu_i, ;
               pkonto WITH _pkonto, ;
               pu_i WITH  _pu_i, ;
               error WITH "0"
         ENDIF
         SKIP
      ENDDO
      my_unlock()
      GO nRRec
   ENDIF

   SET KEY K_ALT_K TO

   RETURN LastKey()



FUNCTION RadNalOK()

   LOCAL nArr
   LOCAL lOK
   LOCAL nLenBrDok

   IF ( !IsRamaGlas() )
      RETURN .T.
   ENDIF
   nArr := Select()
   lOK := .T.
   nLenBrDok := Len( _idZaduz2 )
   SELECT rnal
   HSEEK PadR( _idZaduz2, 10 )
   IF !Found()
      MsgBeep( "Unijeli ste nepostojeci broj radnog naloga. Otvaram sifrarnik radnih##naloga da biste mogli izabrati neki od postojecih!" )
      P_fakt_objekti( @_idZaduz2, 8, 60 )
      _idZaduz2 := PadR( _idZaduz2, nLenBrDok )
      ShowGets()
   ENDIF
   SELECT ( nArr )

   RETURN lOK
