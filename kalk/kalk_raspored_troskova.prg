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

MEMVAR _Prevoz, _BankTr


/*
 *     Proracun iznosa troskova pri unosu u kalk_pripremi
 */

FUNCTION kalk_set_troskovi_priv_vars_ntrosakx_nmarzax()

   LOCAL nStvarnaKolicina := 0

   IF gKalo == "1"
      nStvarnaKolicina := Kolicina - GKolicina - GKolicin2
   ELSE
      nStvarnaKolicina := Kolicina
   ENDIF


   IF field->TPrevoz == "%"
      nPrevoz := field->Prevoz / 100 * field->FCj2
   ELSEIF field->TPrevoz == "A"
      nPrevoz := field->Prevoz
   ELSEIF field->TPrevoz == "U"
      IF nStvarnaKolicina <> 0
         nPrevoz := field->Prevoz / nStvarnaKolicina
      ELSE
         nPrevoz := 0
      ENDIF
   ELSE
      nPrevoz := 0
   ENDIF

   IF field->TCarDaz == "%"
      nCarDaz := field->CarDaz / 100 * field->FCj2
   ELSEIF field->TCarDaz == "A"
      nCarDaz := field->CarDaz
   ELSEIF field->TCarDaz == "U"
      IF nStvarnaKolicina <> 0
         nCarDaz := field->CarDaz / nStvarnaKolicina
      ELSE
         nCarDaz := 0
      ENDIF
   ELSE
      nCarDaz := 0
   ENDIF

   IF field->TZavTr == "%"
      nZavTr := field->ZavTr / 100 * field->FCj2
   ELSEIF field->TZavTr == "A"
      nZavTr := field->ZavTr
   ELSEIF field->TZavTr == "U"
      IF nStvarnaKolicina <> 0
         nZavTr := field->ZavTr / nStvarnaKolicina
      ELSE
         nZavTr := 0
      ENDIF
   ELSE
      nZavTr := 0
   ENDIF

   IF field->TBankTr == "%"
      nBankTr := field->BankTr / 100 * field->FCj2
   ELSEIF field->TBankTr == "A"
      nBankTr := field->BankTr
   ELSEIF field->TBankTr == "U"
      IF nStvarnaKolicina <> 0
         nBankTr := field->BankTr / nStvarnaKolicina
      ELSE
         nBankTr := 0
      ENDIF
   ELSE
      nBankTr := 0
   ENDIF

   IF field->TSpedTr == "%"
      nSpedTr := field->SpedTr / 100 * field->FCj2
   ELSEIF field->TSpedTr == "A"
      nSpedTr := field->SpedTr
   ELSEIF field->TSpedTr == "U"
      IF nStvarnaKolicina <> 0
         nSpedTr := field->SpedTr / nStvarnaKolicina
      ELSE
         nSpedTr := 0
      ENDIF
   ELSE
      nSpedTr := 0
   ENDIF

   IF field->IdVD $ "14#94#15"   // izlaz po vp
      nMarza := field->VPC * ( 1 -field->Rabatv / 100 ) -field->NC

   ELSEIF field->idvd $ "11#12#13"
      nMarza := field->VPC - field->FCJ
   ELSE
      nMarza := field->VPC - field->NC
   ENDIF

   IF ( field->idvd $ "11#12#13" )
      nMarza2 := field->MPC - field->VPC - nPrevoz

   ELSEIF ( ( field->idvd $ "41#42#43#81" ) )
      nMarza2 := field->MPC - field->NC

   ELSE
      nMarza2 := field->MPC - field->VPC
   ENDIF

   RETURN .T.




FUNCTION kalk_raspored_troskova( fSilent )

   LOCAL nStUc := 20
   LOCAL cTipPrevoz := "0", nIznosPrevoz
   LOCAL cTipCarDaz := "0", nIznosCarDaz
   LOCAL cTipBankTr := "0", nIznosBankTr
   LOCAL cTipSpedTr := "0", nIznosSpedTr
   LOCAL cTipZavTr := "0", nIznosZavTr
   LOCAL UBankTr, UPrevoz, UZavTr, USpedTr, UCarDaz
   LOCAL nUkupanIznosFakture, nUkupnoTezina, nUkupnoKolicina, cJmj
   LOCAL cIdFirma, cIdVd, cBrDok
   LOCAL nPrviRec

   IF fsilent == NIL
      fsilent := .F.
   ENDIF
   IF !fsilent .AND.  Pitanje(, "Rasporediti troškove (D/N) ?", "N" ) == "N"
      RETURN .F.
   ENDIF

   PRIVATE qqTar := ""
   PRIVATE aUslTar := ""

   IF field->idvd $ "16#80"
      Box(, 1, 55 )
      IF idvd == "16"
         @ m_x + 1, m_y + 2 SAY8 "Stopa marže (vpc - stopa*vpc)=nc:" GET nStUc PICT "999.999"
      ELSE
         @ m_x + 1, m_y + 2 SAY8 "Stopa marže (mpc-stopa*mpcsapp)=nc:" GET nStUc PICT "999.999"
      ENDIF
      READ
      BoxC()
   ENDIF
   GO TOP

   SELECT F_KONCIJ
   IF !Used()
      o_koncij()
   ENDIF
   SELECT koncij
   SEEK Trim( kalk_pripr->mkonto )
   SELECT kalk_pripr

   IF IsVindija()
      PushWA()
      IF !Empty( qqTar )
         aUslTar := Parsiraj( qqTar, "idTarifa" )
         IF aUslTar <> NIL .AND. !aUslTar == ".t."
            SET FILTER to &aUslTar
         ENDIF
      ENDIF
   ENDIF

   DO WHILE !Eof()
      nUkupanIznosFakture := 0
      nUkupnoTezina := 0
      nUkupnoKolicina := 0
      nUkProV := 0

      cIdFirma := field->idfirma
      cIdVd := field->idvd
      cBrDok := field->Brdok

      nPrviRec := RecNo()
      DO WHILE !Eof() .AND. cIdFirma == field->idfirma .AND. cIdVd == field->idvd .AND. cBrDok == field->BrDok

         cJmj := "KG "
         nUkupnoTezina += svedi_na_jedinicu_mjere( field->kolicina, field->idroba, @cJmj )
         nUkupnoKolicina += field->kolicina

         IF cIdVd $ "10#16#81#80"
            nUkupanIznosFakture += Round( field->fcj * ( 1 - field->Rabat / 100 ) * field->kolicina, gZaokr ) // zaduzenje magacina,prodavnice


         ENDIF

         IF cIdVd $ "11#12#13"
            nUkupanIznosFakture += Round( fcj * kolicina, gZaokr ) // magacin-> prodavnica,povrat
         ENDIF

         IF cIdVd $ "RN"
            IF Val( Rbr ) < 900
               nUkProV += Round( vpc * kolicina, gZaokr )
            ELSE
               nUkupanIznosFakture += Round( nc * kolicina, gZaokr )  // sirovine
            ENDIF
         ENDIF
         SKIP
      ENDDO

      IF cIdVd $ "10#16#81#80#RN"  // zaduzenje magacina,prodavnice
         GO nPrviRec

         cTipPrevoz := "0"
         nIznosPrevoz := 0

         cTipCarDaz := "0"
         nIznosCarDaz := 0

         cTipBankTr := "0"
         nIznosBankTr := 0

         cTipSpedTr := "0"
         nIznosSpedTr := 0

         cTipZavTr := "0"
         nIznosZavTr := 0

         cTipPrevoz := field->TPrevoz
         nIznosPrevoz := field->Prevoz

         cTipCarDaz :=  field->TCarDaz
         nIznosCarDaz := field->CarDaz

         cTipBankTr := field->TBankTr
         nIznosBankTr := field->BankTr

         cTipSpedTr := field->TSpedTr
         nIznosSpedTr := field->SpedTr

         cTipZavTr := field->TZavTr
         nIznosZavTr := field->ZavTr

         UBankTr := 0   // do sada utroseno na bank tr itd, radi "sitnisha"
         UPrevoz := 0
         UZavTr := 0
         USpedTr := 0
         UCarDaz := 0
         DO WHILE !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok

            Scatter()

            IF _idvd $ "RN" .AND. Val( _rbr ) < 900
               _fcj := _fcj2 := _vpc / nUKProV * nUkupanIznosFakture // nabavne cijene izmisli proporcionalno prodajnim
            ENDIF

            IF cTipPrevoz $ "RT"  // troskovi 1 - R - raspored, T - raspored po tezini
               IF Round( nUkupanIznosFakture, 4 ) == 0
                  _Prevoz := 0
               ELSE

                  IF cTipPrevoz == "T"
                     cJmj := "KG "
                     _Prevoz := Round( svedi_na_jedinicu_mjere( _kolicina, _idroba, cJmj ) / nUkupnoTezina * nIznosPrevoz, gZaokr )
                  ELSE
                     _Prevoz := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkupanIznosFakture * nIznosPrevoz, gZaokr )
                  ENDIF

                  UPrevoz += _Prevoz

                  IF Abs( nIznosPrevoz - UPrevoz ) < 0.1 // sitnish, baci ga na zadnju st.
                     SKIP
                     IF ! ( !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok )
                        _Prevoz += ( nIznosPrevoz - UPrevoz )
                     ENDIF
                     SKIP -1
                  ENDIF
               ENDIF
               _TPrevoz := "U"
            ENDIF


            IF cTipCarDaz $ "RT"   // troskovi 2
               IF Round( nUkupanIznosFakture, 4 ) == 0
                  _CarDaz := 0
               ELSE
                  IF cTipCarDaz == "T"
                     cJmj := "KG "
                     _CarDaz := Round( svedi_na_jedinicu_mjere( _kolicina, _idroba, cJmj ) / nUkupnoTezina * nIznosCarDaz, gZaokr )
                  ELSE
                     _CarDaz := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkupanIznosFakture * nIznosCarDaz, gZaokr )
                  ENDIF

                  UCardaz += _Cardaz
                  IF Abs( nIznosCarDaz - UCardaz ) < 0.1 // sitniç, baci ga na zadnju st.
                     SKIP
                     IF ! ( !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok )
                        _Cardaz += ( nIznosCarDaz - UCardaz )
                     ENDIF
                     SKIP -1
                  ENDIF
               ENDIF
               _TCarDaz := "U"
            ENDIF

            IF cTipBankTr  $ "RT" // troskovi 3
               IF Round( nUkupanIznosFakture, 4 ) == 0
                  _BankTr := 0
               ELSE

                  IF cTipCarDaz == "T"
                     cJmj := "KG "
                     _BankTr := Round( svedi_na_jedinicu_mjere( _kolicina, _idroba, cJmj ) / nUkupnoTezina * nIznosBankTr, gZaokr )
                  ELSE

                     _BankTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkupanIznosFakture * nIznosBankTr, gZaokr )
                  ENDIF

                  UBankTr += _BankTr
                  IF Abs( nIznosBankTr - UBankTr ) < 0.1 // sitniç, baci ga na zadnju st.
                     SKIP
                     IF ! ( !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok )
                        _BankTr += ( nIznosBankTr - UBankTr )
                     ENDIF
                     SKIP -1
                  ENDIF
               ENDIF
               _TBankTr := "U"
            ENDIF

            IF cTipSpedTr  $ "RT"  // troskovi 4
               IF Round( nUkupanIznosFakture, 4 ) == 0
                  _SpedTr := 0
               ELSE

                  IF cTipCarDaz == "T"
                     cJmj := "KG "
                     _SpedTr := Round( svedi_na_jedinicu_mjere( _kolicina, _idroba, cJmj ) / nUkupnoTezina * nIznosSpedTr, gZaokr )
                  ELSE

                     _SpedTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkupanIznosFakture * nIznosSpedTr, gZaokr )
                  ENDIF

                  USpedTr += _SpedTr
                  IF Abs( nIznosSpedTr - USpedTr ) < 0.1 // sitnish baci ga na zadnju st.
                     SKIP
                     IF ! ( !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok )
                        _SpedTr += ( nIznosSpedTr - USpedTr )
                     ENDIF
                     SKIP -1
                  ENDIF
               ENDIF
               _TSpedTr := "U"
            ENDIF


            IF cTipZavTr $ "RT"   // troskovi 5
               IF Round( nUkupanIznosFakture, 4 ) == 0
                  _ZavTr := 0
               ELSE

                  IF cTipZavTr == "T"
                     cJmj := "KG "
                     _ZavTr := Round( svedi_na_jedinicu_mjere( _kolicina, _idroba, cJmj ) / nUkupnoTezina * nIznosZavTr, gZaokr )
                  ELSE
                     _ZavTr := Round( _fcj * ( 1 -_Rabat / 100 ) * _kolicina / nUkupanIznosFakture * nIznosZavTr, gZaokr )
                  ENDIF


                  UZavTR += _ZavTR
                  IF Abs( nIznosZavTr - UZavTR ) < 0.1 // sitnish, baci ga na zadnju st.
                     SKIP
                     IF ! ( !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok )
                        _ZavTR += ( nIznosZavTr - UZavTR )
                     ENDIF
                     SKIP -1
                  ENDIF
               ENDIF
               _TZavTr := "U"
            ENDIF

            SELECT roba
            SELECT tarifa
            HSEEK _idtarifa

            SELECT kalk_pripr
            IF _idvd == "RN"
               IF Val( _rbr ) < 900
                  NabCj()
               ENDIF
            ELSE
               NabCj()
            ENDIF
            IF _idvd == "16"
               _nc := _vpc * ( 1 -nStUc / 100 )
            ENDIF
            IF _idvd == "80"
               _nc := _mpc - _mpcsapp * nStUc / 100
               _vpc := _nc
               _TMarza2 := "A"
               _Marza2 := _mpc - _nc
            ENDIF
            IF koncij->naz == "N1"; _VPC := _NC; ENDIF
            IF _idvd == "RN"
               IF Val( _rbr ) < 900
                  Marza()
               ENDIF
            ELSE
               Marza()
            ENDIF
            my_rlock()
            Gather()
            my_unlock()
            SKIP
         ENDDO
      ENDIF // cIdVd $ 10

      IF cIdVd $ "11#12#13"
         GO nPrviRec
         cTipPrevoz := .F. ;nIznosPrevoz := 0
         IF TPrevoz == "R"; cTipPrevoz := .T. ;nIznosPrevoz := Prevoz; ENDIF
         nMarza2 := 0
         DO WHILE !Eof() .AND. cIdFirma == idfirma .AND. cIdVd == idvd .AND. cBrDok == BrDok
            Scatter()
            IF cTipPrevoz    // troskovi 1
               IF Round( nUkupanIznosFakture, 4 ) == 0
                  _Prevoz := 0
               ELSE
                  _Prevoz := _fcj / nUkupanIznosFakture * nIznosPrevoz
               ENDIF
               _TPrevoz := "A"
            ENDIF
            _nc := _fcj + _prevoz
            IF koncij->naz == "N1"; _VPC := _NC; ENDIF
            _marza := _VPC - _FCJ
            _TMarza := "A"
            SELECT roba
            HSEEK _idroba
            SELECT tarifa
            HSEEK _idtarifa
            SELECT kalk_pripr
            Marza2()
            _TMarza2 := "A"
            _Marza2 := nMarza2
            my_rlock()
            Gather()
            my_unlock()
            SKIP
         ENDDO
      ENDIF // cIdVd $ "11#12#13"
   ENDDO  // eof()

   IF IsVindija()
      SELECT kalk_pripr
      PopWA()
   ENDIF

   GO TOP

   RETURN .T.
