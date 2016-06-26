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

MEMVAR GetList, m_x, m_y
MEMVAR nRbr, fNovi, fMarza, nStrana
MEMVAR _IdFirma, _IdVd, _BrDok, _TBankTr, _TPrevoz, _TSpedTr, _TZavTr, _TCarDaz, _SpedTr, _ZavTr, _BankTr, _CarDaz, _MArza, _Prevoz
MEMVAR _TMarza, _IdKonto, _IdKonto2, _IdTarifa, _IDRoba, _Kolicina, _DatFaktP, _datDok, _brFaktP, _VPC, _NC, _FCJ, _FCJ2, _Rabat
MEMVAR _MKonto, _MU_I, _Error
MEMVAR PicDEM, PicKol
MEMVAR gPromTar, cRNT1, cRNT2, cRNT3, cRNT4, cRNT5

FUNCTION kalk_unos_dok_pr()

   LOCAL bProizvodPripadajuceSirovine := {|| Round( Val( field->rBr ) / 100, 0 )  }
   LOCAL bDokument := {| cIdFirma, cIdVd, cBrDok |   cIdFirma == field->idFirma .AND. ;
      cIdVd == field->IdVd .AND. cBrDok == field->BrDok }
   LOCAL cIdFirma, cIdVd, cBrDok
   LOCAL nNV

   IF is_legacy_kalk_pr()
      RETURN leg_Get1_PR()
   ENDIF

   SELECT F_SAST
   IF !Used()
      O_SAST
   ENDIF

   SELECT kalk_pripr

   IF nRbr < 10 .AND. fNovi
      _DatFaktP := _datDok
   ENDIF


   @ m_x + 6, m_y + 2 SAY8 "Broj fakture" GET _brFaktP
   @ m_x + 7, m_y + 2 SAY8 "Magacin gotovih proizvoda zadužuje " GET _IdKonto ;
      VALID  P_Konto( @_IdKonto, 21, 5 ) PICT "@!" ;
      WHEN {|| nRbr == 1 }

   @ m_x + 8, m_y + 2 SAY8 "Magacin sirovina razdužuje         " GET _IdKonto2 ;
      PICT "@!" VALID P_Konto( @_IdKonto2 ) ;
      WHEN {|| nRbr == 1 }


   IF nRbr < 10
      @ m_x + 12, m_y + 2 SAY8 "Proizvod  " GET _IdRoba PICT "@!" ;
         VALID  {|| P_Roba( @_IdRoba, NIL, NIL, "IDP" ), ;
         Reci( 12, 24, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }

      @ m_x + 13, m_y + 2 SAY8 "Količina  " GET _Kolicina PICT PicKol ;
         VALID {|| _Kolicina <> 0 .AND. iif( InRange( nRbr, 10, 99 ), error_bar( _idFirma + "-" + _idvd + "-" + _brdok, "PR dokument max 9 artikala" ), .T. ) }

   ELSE

      @ m_x + 12, m_y + 2  SAY8 "Sirovina  " GET _IdRoba PICT "@!" valid  {|| P_Roba( @_IdRoba ), Reci( 12, 24, Trim( Left( roba->naz, 40 ) ) + " (" + ROBA->jmj + ")", 40 ), _IdTarifa := iif( fnovi, ROBA->idtarifa, _IdTarifa ), .T. }
      @ m_x + 13, m_y + 2   SAY8 "Količina  " GET _Kolicina PICTURE PicKol VALID _Kolicina <> 0

      @ m_x + 15, m_y + 2   SAY "N.CJ Sirovina:"
      @ m_x + 15, m_y + 50  GET _NC PICTURE PicDEM VALID _nc >= 0

      _Mkonto := _idkonto2
      _mu_i := "5"

   ENDIF

   @ m_x + 11, m_y + 66 SAY "Tarif.br v"
   @ m_x + 12, m_y + 70 GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

   READ
   ESC_RETURN K_ESC

   SELECT kalk_pripr
   cIdFirma := _idFirma
   cIdVd := _idVd
   cBrDok := _brDok


   IF nRbr > 10
      RETURN LastKey()
   ENDIF

   PushWa()
   LOCATE FOR Eval( bProizvodPripadajuceSirovine ) == nRbr // stavke

   IF Found()
      info_bar( _idFirma + "-" + _idvd + "-" + _brdok,  "postoje proizvodi za rbr" + AllTrim( Str( nRbr ) ) )
      IF Pitanje( , "pobrisati za stavku " + AllTrim( Str( nRbr ) ) + " sirovine?", "N" ) == "D"
         kalk_pripr_pobrisi_sirovine( cIdFirma, cIdVd, cBrDok, nRbr, bDokument )
         kalk_pripr_napuni_sirovine_za( nRbr, _idroba, _kolicina )
      ENDIF

   ELSE
      kalk_pripr_napuni_sirovine_za( nRbr, _idroba, _kolicina )
   ENDIF

   PopWa()

   SELECT tarifa
   HSEEK _IdTarifa

   SELECT koncij
   SEEK Trim( _idkonto )
   SELECT kalk_pripr

   _MKonto := _Idkonto
   _MU_I := "1"

   check_datum_posljednje_kalkulacije()

   IF fNovi
      SELECT ROBA
      HSEEK _IdRoba
      _VPC := KoncijVPC()
      _TCarDaz := "%"
      _CarDaz := 0
   ENDIF


   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   IF _tmarza <> "%"  // procente ne diraj
      _Marza := 0
   ENDIF


   nNV := kalk_pripr_pr_nv_proizvod( cIdFirma, cIdVd, cBrDok, nRbr, bDokument, bProizvodPripadajuceSirovine )

   IF Round( _kolicina, 4 ) == 0
      _fcj := 0.0
   ELSE
      _fcj := nNV / _kolicina
   ENDIF

   _fcj := nNV / _kolicina
   @ m_x + 15, m_y + 2   SAY "Nabc.CJ Proizvod :"
   @ m_x + 15, m_y + 50  GET _FCJ PICTURE PicDEM VALID _fcj > 0 WHEN V_kol10()
   READ
   ESC_RETURN K_ESC


   _FCJ2 := _FCJ * ( 1 - _Rabat / 100 )

   RETURN LastKey()




FUNCTION Get2_PR()

   LOCAL cSPom := " (%,A,U,R) "

   IF is_legacy_kalk_pr()
      RETURN leg_Get2_PR()
   ENDIF

   IF nRbr > 9
      RETURN K_ENTER
   ENDIF

   PRIVATE GetList := {}

   IF Empty( _TPrevoz ); _TPrevoz := "%"; ENDIF
   IF Empty( _TCarDaz ); _TCarDaz := "%"; ENDIF
   IF Empty( _TBankTr ); _TBankTr := "%"; ENDIF
   IF Empty( _TSpedTr ); _TSpedtr := "%"; ENDIF
   IF Empty( _TZavTr );  _TZavTr := "%" ; ENDIF
   IF Empty( _TMarza );  _TMarza := "%" ; ENDIF


   @ m_x + 2, m_y + 2 SAY cRNT1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
   @ m_x + 2, m_y + 40 GET _Prevoz PICTURE PicDEM

   @ m_x + 3, m_y + 2 SAY cRNT2 + cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" PICT "@!"
   @ m_x + 3, m_y + 40 GET _BankTr PICTURE PicDEM

   @ m_x + 4, m_y + 2 SAY cRNT3 + cSPom GET _TSpedTr VALID _TSpedTr $ "%AUR" PICT "@!"
   @ m_x + 4, m_y + 40 GET _SpedTr PICTURE PicDEM

   @ m_x + 5, m_y + 2 SAY cRNT4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
   @ m_x + 5, m_y + 40 GET _CarDaz PICTURE PicDEM

   @ m_x + 6, m_y + 2 SAY cRNT5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
   @ m_x + 6, m_y + 40 GET _ZavTr PICTURE PicDEM VALID {|| NabCj(), .T. }

   @ m_x + 8, m_y + 2 SAY8 "CIJENA KOŠTANJA  "
   @ m_x + 8, m_y + 50 GET _NC PICTURE PicDEM

   IF koncij->naz <> "N1"

      PRIVATE fMarza := " "
      @ m_x + 10, m_y + 2 SAY8 "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
      @ m_x + 10, m_y + 40 GET _Marza PICTURE PicDEM
      @ m_x + 10, Col() + 1 GET fMarza PICT "@!"
      @ m_x + 12, m_y + 2 SAY8 "VELEPRODAJNA CJENA  (VPC)   :"
      @ m_x + 12, m_y + 50 GET _VPC PICT PicDEM VALID {|| Marza( fMarza ), .T. }

      READ
      SetujVPC( _vpc )

   ELSE

      READ
      _Marza := 0
      _TMarza := "A"
      _VPC := _NC

   ENDIF

   IF nRbr = 1
      _MKonto := _Idkonto
      _MU_I := "1"
   ENDIF
   nStrana := 3

   RETURN LastKey()



FUNCTION kalk_pripr_pobrisi_sirovine( cIdFirma, cIdVd, cBrDok, nRbr, bDokument )

   LOCAL nTRec

   my_flock()
   GO TOP
   DO WHILE !Eof()

      SKIP
      nTrec := RecNo()
      SKIP -1
      IF Val( field->rbr ) > 99 .AND. ;
            Eval( bDokument, cIdFirma, cIdVd, cBrDok ) .AND. ;
            ( InRange( Val( field->rBr ), nRbr * 100 + 1, nRbr * 100 + 99 ) .OR. ; // nRbr = 2, delete 201-299
         Val( field->rBr ) > 900 )
         my_delete()
      ENDIF
      GO nTrec

   ENDDO
   my_unlock()

   RETURN .T.




FUNCTION kalk_pripr_napuni_sirovine_za( nRbr, _idroba, _kolicina )

   LOCAL nRbr100
   LOCAL nKolS, nKolZN, nC1, nC2, dDatNab
   LOCAL _rec

   SELECT ROBA
   HSEEK _idroba

   SELECT kalk_pripr

   IF nRbr > 9 .OR. roba->tip != "P"  // ne radi se o proizvodu
      RETURN .F.
   ENDIF

   PushWa()
   nRbr100 := nRbr * 100

   SELECT SAST  // prolazak kroz sastavnicu proizvoda
   HSEEK _idroba
   DO WHILE !Eof() .AND. sast->id == _idroba

      SELECT roba
      HSEEK sast->id2

      SELECT kalk_pripr
      APPEND BLANK
      REPLACE field->idfirma WITH _IdFirma, ;
         field->rbr WITH Str( ++nRbr100, 3 ), ;
         field->idvd WITH "PR", ;
         field->brdok WITH _Brdok, ;
         field->datdok WITH _Datdok, ;
         field->idtarifa WITH ROBA->idtarifa, ;
         field->brfaktp WITH _brfaktp, ;
         field->datfaktp WITH _Datdok, ;
         field->idkonto   WITH _idkonto, ;
         field->idkonto2  WITH _idkonto2, ;
         field->kolicina WITH _kolicina * sast->kolicina, ;
         field->idroba WITH sast->id2, ;
         field->nc WITH 0, ;
         field->vpc WITH 0, ;
         field->pu_i WITH "", ;
         field->mu_i WITH "5", ;
         field->error WITH "0", ;
         field->mkonto WITH _idkonto2


      nKolS := 0
      nKolZN := 0
      nC1 := 0
      nC2 := 0
      dDatNab := CToD( "" )

      info_bar( _idkonto2 + "/" + sast->id2, "sirovina: " + _idkonto2 + "/" + sast->id2 )
      KalkNab( _idfirma, sast->id2, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
      info_bar( _idkonto2 + "/" + sast->id2, NIL )

      IF dDatNab > _DatDok
         error_bar( _idFirma + "-" + _idvd + "-" + _brdok, "Datum nabavke je " + DToC( dDatNab ) + " sirovina " + sast->id2 )
      ENDIF

      IF _kolicina >= 0 .OR. Round( _NC, 3 ) == 0 .AND. !( roba->tip $ "UT" )

         SELECT roba
         _rec := dbf_get_rec()
         _rec[ "nc" ] := _nc
         update_rec_server_and_dbf( Alias(), _rec, 1, "FULL" ) // nafiluj sifarnik robe sa nc sirovina, robe

      ENDIF

      SELECT kalk_pripr // nc sirovine, gkolicina se puni sa kolicinom na stanju
      RREPLACE field->nc WITH nC2, field->gKolicina WITH nKolS

      SELECT sast
      SKIP
   ENDDO

   PopWa()

   RETURN .T.



FUNCTION kalk_pripr_pr_nv_proizvod( cIdFirma, cIdVd, cBrDok, nRbr, bDokument, bProizvodPripadajuceSirovine )

   LOCAL nNV

   PushWa()

   SELECT kalk_pripr
   GO TOP
   nNV := 0  // nab vrijednost proizvod
   DO WHILE !Eof()

      IF Eval( bDokument, cIdFirma, cIdVd, cBrDok ) .AND. ;   // gledaj samo stavke jednog dokumenta ako ih ima vise u pripremi
         Eval( bProizvodPripadajuceSirovine ) == nRbr // when field->rbr == 301, 302, 303 ...  EVAL( bProizvod ) = 3
         nNV += field->NC * field->kolicina
         IF field->gkolicina < field->kolicina
            error_bar(  "KA_" + cIdFirma + "-" + cIdVD + "-" + cBrDok, ;
               field->idkonto2 + "/" + field->idroba + " stanje " + AllTrim( Str( field->gkolicina, 9, 3 ) ) + " potrebno: " + AllTrim( Str( field->kolicina, 10, 3 ) ) )
            _error := "1"
            RREPLACE field->error WITH "1"
         ENDIF
      ENDIF
      SKIP
   ENDDO

   PopWa()

   RETURN nNV




FUNCTION proizvod_proracunaj_nc_za( nRbr, cIdFirma, cIdVd, cBrDok, bDokument, bProizvod )

   LOCAL nNV

   PushWa()

   SELECT kalk_pripr
   SET FILTER TO
   SET ORDER TO TAG "1"
   GO TOP

   nNV := 0  // nab vrijednost proizvod
   DO WHILE !Eof()

      IF Eval( bDokument, cIdFirma, cIdVd, cBrDok ) .AND. ;   // gledaj samo stavke jednog dokumenta ako ih ima vise u pripremi
         Eval( bProizvod ) == nRbr // when field->rbr == 301, 302, 303 ...  EVAL( bProizvod ) = 3
         nNV += field->NC * field->kolicina
         IF field->gKolicina < field->kolicina
            error_bar( "KA_" + cIdfirma + "-" + cIdvd + "-" + cBrDok, ;
               AllTrim( field->idkonto2 ) + " / " + field->idRoba + " stanje: " + AllTrim( Str( field->gKolicina, 10, 3 ) ) + ;
               " treba: " + AllTrim( Str( field->kolicina, 10, 3 ) ) )
            RREPLACE field->error WITH "1"
         ENDIF
      ENDIF
      SKIP
   ENDDO


   PopWa()

   RETURN nNV
