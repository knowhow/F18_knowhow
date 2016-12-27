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



FUNCTION Get1_RN()


   IF nRbr == 1 .AND. kalk_is_novi_dokument()
      _DatFaktP := _datdok
   ENDIF

   IF nRbr > 900
      beep( 2 )
      Msg( "Razduzenja materijala se ne mogu ispravljati" )
      KEYBOARD K_ESC
      nStrana := 3
      RETURN  LastKey()
   ENDIF

   IF nRbr == 1  .OR. !kalk_is_novi_dokument() .OR. gMagacin == "1"
      @  m_x + 6, m_y + 2   SAY "ZATVORITI RADNI NALOG:" GET _IdZaduz2 PICT "@!"
      @  m_x + 7, m_y + 2   SAY "Mag. proivod. u toku :" GET _IdKonto2 PICT "@!" VALID P_Konto( @_IdKonto2 )
      @ m_x + 10, m_y + 2   SAY "Mag. gotovih proizvoda zaduzuje" GET _IdKonto VALID  P_Konto( @_IdKonto, 24 ) PICT "@!"
      READ
      _BrFaktP := _idzaduz2
      // sada trazim trebovanja u proizvod. u toku i filujem u stavke od 100 pa nadalje
      // ove stavke imace  mu_i=="5", mkonto=_idkonto2, nc,nv
      // "KALKi7","idFirma+mkonto+IDZADUZ2+idroba+dtos(datdok)","KALK")

      nTPriPrec := RecNo()


      SELECT kalk_pripr
      GO BOTTOM
      my_flock()
      DO WHILE !Bof() .AND. Val( rbr ) > 900
         SKIP -1
         nTrec := RecNo()
         SKIP
         my_delete()
         GO nTrec
      ENDDO
      my_unlock()
      my_dbf_pack()

      SELECT kalk_doks
      SET ORDER TO TAG "2"
      // CREATE_INDEX("DOKSi2","IdFirma+MKONTO+idzaduz2+idvd+brdok","DOKS")


      IF find_kalk_doks_by_broj_radnog_naloga( _IdFirma, _IdKonto, _IdZaduz2, "RN" )  // npr: 10 5100 564   RN
         Beep( 2 )
         Msg( "Vec postoji dokument RN broj " + kalk_doks->brdok + " za radni nalog:"  + _IdZaduz2 )
         SELECT kalk_pripr
         KEYBOARD K_ESC
         nStrana := 3
         RETURN  LastKey()
      ENDIF

      SEEK _idfirma + _idkonto2 + _idzaduz2  // 10 5000 564
      nII := 0
      nCntR := 0
      DO WHILE !Eof() .AND. ;
            ( _idfirma + _idkonto2 + _idzaduz2 = idfirma + mkonto + idzaduz2 )

         SELECT kalk
         SET ORDER TO TAG "1"
         SEEK kalk_doks->( idfirma + idvd + brdok )
         nKolicina := 0   ; nNabV := 0
         DO WHILE !Eof() .AND. kalk_doks->( idfirma + idvd + brdok ) == ( idfirma + idvd + brdok )


            SELECT kalk_pripr
            SET ORDER TO TAG "3" // kalk pripr tag 3 idFirma+idvd+brdok+idroba+rbr
            SEEK _idfirma + _idvd + _brdok + kalk->idroba + "9" // nadji odgovoarajucu stavku iznad 900


            IF !Found()
               ++nCntR
               APPEND BLANK
               REPLACE idfirma WITH _idfirma, idvd WITH _idvd, brdok WITH _brdok, ;
                  rbr  WITH Str( 900 + nCntR, 3 ), idroba WITH kalk->idroba, ;
                  mkonto WITH kalk->mkonto, ;
                  mu_i WITH "5", ;
                  error WITH "0", ;
                  datdok WITH _datdok, ;
                  datfaktp WITH _datdok, ;
                  idzaduz2 WITH _idzaduz2, ;
                  idkonto WITH _idkonto, idkonto2 WITH _idkonto2, ;
                  idtarifa WITH "XXXXXX", ;
                  brfaktp WITH _brfaktp



            ENDIF

            my_rlock()
            IF KALK->mu_i == "1"
               REPLACE kolicina WITH kalk->kolicina + kolicina, ;
                  nc WITH nc + kalk->( kolicina * nc )
            ELSEIF KALK->mu_i = "5"
               REPLACE kolicina WITH -kalk->kolicina + kolicina, ;
                  nc WITH nc - kalk->( kolicina * nc )
            ENDIF
            my_unlock()

            SELECT kalk_pripr; SET ORDER TO TAG "1"
            SELECT kalk
            SKIP

         ENDDO

         SELECT kalk_doks
         SKIP
      ENDDO

      SELECT kalk_pripr; SET ORDER TO TAG "1"; GO TOP
      nNV := 0
      my_flock()
      DO WHILE !Eof()
         IF Val( RBr ) > 900
            nNV += NC  // ovo je u stvari nabavna vrijednost
            REPLACE NC WITH NC / Kolicina, ;
               vpc WITH NC, ;
               fcj WITH nc
         ENDIF
         SKIP
      ENDDO
      my_unlock()

      GO  nTPriPrec
      SELECT kalk_pripr
    //  IF gNW <> "X"
      //   @ m_x + 10, m_y + 42  SAY "Zaduzuje: "   GET _IdZaduz  PICT "@!" VALID Empty( _idZaduz ) .OR. p_partner( @_IdZaduz, 24 )
      //ENDIF
      read; ESC_RETURN K_ESC
   ELSE

      @ m_x + 10, m_y + 2   SAY "Mag. gotovih proizvoda zaduzuje ";?? _IdKonto
      //IF gNW <> "X"
      //   @ m_x + 10, m_y + 42  SAY "Zaduzuje: "; ?? _IdZaduz
      //ENDIF
   ENDIF


   @ m_x + 11, m_y + 66 SAY "Tarif.brĿ"
   @ m_x + 12, m_y + 2  SAY "Proizvod  " GET _IdRoba PICT "@!" ;
      valid  {|| P_Roba( @_IdRoba ), say_from_valid( 12, 25, Trim( roba->naz ) + " (" + ROBA->jmj + ")", 40 ), ;
      _IdTarifa := iif( kalk_is_novi_dokument(), ROBA->idtarifa, _IdTarifa ), .T. }
   @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   read; ESC_RETURN K_ESC
   SELECT koncij; HSEEK Trim( _idkonto ); SELECT kalk_pripr

   _MKonto := _Idkonto; _MU_I := "1"
   //check_datum_posljednje_kalkulacije()

   SELECT TARIFA
   HSEEK _IdTarifa  // postavi TARIFA na pravu poziciju
   SELECT kalk_pripr  // napuni tarifu

   @ m_x + 13, m_y + 2   SAY "Kolicina " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0
   READ
   IF kalk_is_novi_dokument()
      SELECT ROBA; HSEEK _IdRoba
      IF koncij->naz == "P2"
         _VPC := PlC
      ELSE
         _VPC := KoncijVPC()
      ENDIF
      _TCarDaz := "%"
      _CarDaz := 0
   ENDIF

   SELECT kalk_pripr
   IF _tmarza <> "%"  // procente ne diraj
      _Marza := 0
   ENDIF

   IF nRbr == 1
      _fcj := _fcj2 := nNV / _kolicina
   ENDIF

   @ m_x + 15, m_y + 2   SAY "N.CJ.(DEM/JM):"
   @ m_x + 15, m_y + 50  GET _FCJ PICTURE PicDEM VALID _fcj > 0 when {|| _fcj := iif( nRbr > 1 .AND. kalk_is_novi_dokument(), _vpc, _fcj ), V_kol10() }

/*
   --IF gNW <> "X"
      @ m_x + 18, m_y + 2   SAY "Transport. kalo:"
      @ m_x + 18, m_y + 40  GET _GKolicina PICTURE PicKol

      @ m_x + 19, m_y + 2   SAY "Ostalo kalo:    "
      @ m_x + 19, m_y + 40  GET _GKolicin2 PICTURE PicKol
   ENDIF
*/

   read; ESC_RETURN K_ESC

   _FCJ2 := _FCJ * ( 1 -_Rabat / 100 )

   RETURN LastKey()
// }




/* Get2_RN()
 *     Druga strana maske za unos dokumenta tipa RN
 */

FUNCTION Get2_RN()

   // {
   LOCAL cSPom := " (%,A,U,R) "
   PRIVATE getlist := {}

   IF Empty( _TPrevoz ); _TPrevoz := "%"; ENDIF
   IF Empty( _TCarDaz ); _TCarDaz := "%"; ENDIF
   IF Empty( _TBankTr ); _TBankTr := "%"; ENDIF
   IF Empty( _TSpedTr ); _TSpedtr := "%"; ENDIF
   IF Empty( _TZavTr );  _TZavTr := "%" ; ENDIF
   IF Empty( _TMarza );  _TMarza := "%" ; ENDIF

   @ m_x + 2, m_y + 2     SAY cRNT1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
   @ m_x + 2, m_y + 40    GET _Prevoz PICTURE  PicDEM

   @ m_x + 3, m_y + 2     SAY cRNT2 + cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" PICT "@!"
   @ m_x + 3, m_y + 40    GET _BankTr PICTURE PicDEM

   @ m_x + 4, m_y + 2     SAY cRNT3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AUR" PICT "@!"
   @ m_x + 4, m_y + 40    GET _SpedTr PICTURE PicDEM

   @ m_x + 5, m_y + 2     SAY cRNT4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
   @ m_x + 5, m_y + 40    GET _CarDaz PICTURE PicDEM

   @ m_x + 6, m_y + 2     SAY cRNT5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
   @ m_x + 6, m_y + 40    GET _ZavTr PICTURE PicDEM ;
      VALID {|| kalk_nabcj(), .T. }

   @ m_x + 8, m_y + 2     SAY "CIJENA KOST.  "
   @ m_x + 8, m_y + 50    GET _NC     PICTURE PicDEM

   IF koncij->naz <> "N1"  // vodi se po vpc
      PRIVATE fMarza := " "
      @ m_x + 10, m_y + 2    SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
      @ m_x + 10, m_y + 40 GET _Marza PICTURE PicDEM
      @ m_x + 10, Col() + 1 GET fMarza PICT "@!"
      IF koncij->naz == "P2"
         @ m_x + 12, m_y + 2    SAY "PLANSKA CIJENA (PLC)        :"
      ELSE
         @ m_x + 12, m_y + 2    SAY "VELEPRODAJNA CJENA  (VPC)   :"
      ENDIF
      @ m_x + 12, m_y + 50 GET _VPC    PICTURE PicDEM;
         VALID {|| Marza( fMarza ), .T. }

      READ
      IF koncij->naz == "P2"
         IF roba->plc == 0
            IF Pitanje(, "Staviti PLC  u sifrarnik ?", "D" ) == "D"
               SELECT roba
               REPLACE plc WITH _vpc
               SELECT kalk_pripr
            ENDIF
         ENDIF
      ELSE
         IF KoncijVPC() == 0 .OR. Round( KoncijVPC(), 4 ) <> Round( _vpc, 4 )
            SetujVPC( _vpc, Round( KoncijVPC(), 4 ) <> Round( _vpc, 4 ) )
         ELSE
            IF ( _vpc <> KoncijVPC() )
               Beep( 1 )
               Msg( "Cijena u sifrarniku je " + Str( KoncijVPC(), 11, 3 ), 6 )
            ENDIF
         ENDIF
      ENDIF
   ELSE
      READ
      _Marza := 0; _TMarza := "A"; _VPC := _NC
   ENDIF

   _MKonto := _Idkonto; _MU_I := "1"
   nStrana := 3

   RETURN LastKey()
// }
