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



FUNCTION Niv_10()

   LOCAL nRVPC := 0

   o_koncij()
   O_KALK_PRIPR
   O_KALK_PRIPR2
   O_KALK
   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA

   SELECT kalk_pripr; GO TOP
   PRIVATE cIdFirma := idfirma, cIdVD := idvd, cBrDok := brdok

   IF !( cidvd $ "14#96#95#10#94#16" ) .AND. !Empty( gMetodaNC )
      closeret
   ENDIF

   IF kalk_pripr->idvd $ "14#94#96#95"
      SELECT koncij; SEEK Trim( kalk_pripr->idkonto2 )
   ELSE
      SELECT koncij; SEEK Trim( kalk_pripr->idkonto )
   ENDIF
   IF koncij->naz $ "N1#P1#P2"
      closeret
   ENDIF

   PRIVATE cBrNiv := "0"
   SELECT kalk
   SEEK cidfirma + "18�"
   SKIP -1
   IF idvd <> "18"
      cBrNiv := Space( 8 )
   ELSE
      cBrNiv := brdok
   ENDIF
   cBrNiv := UBrojDok( Val( Left( cBrNiv, 5 ) ) + 1, 5, Right( cBrNiv, 3 ) )


   SELECT kalk_pripr
   GO TOP
   PRIVATE nRBr := 0
   fNivelacija := .F.
   cPromCj := "N"
   DO WHILE !Eof() .AND. cidfirma == idfirma .AND. cidvd == idvd .AND. cbrdok == brdok

      IF kalk_pripr->idvd $ "14#94#96#95"   // ako je vise konta u igri - kao 16-ka
         SELECT koncij; SEEK Trim( kalk_pripr->idkonto2 )
      ELSE
         SELECT koncij; SEEK Trim( kalk_pripr->idkonto )
      ENDIF
      SELECT kalk_pripr
      IF koncij->naz $ "N1#P1#P2"
         skip; LOOP
      ENDIF



      scatter()
      SELECT roba; HSEEK _idroba
      SELECT tarifa; HSEEK roba->idtarifa
      frazlika := .F.
      nRVPC := KoncijVPC()
      IF gCijene = "2"  .AND. gNiv14 = "1"
         // nivel.se vrsi na ukupnu kolicinu
         // ///// utvrdjivanje fakticke VPC
         faktVPC( @nRVPC, _idfirma + _mkonto + _idroba )
         SELECT kalk_pripr
      ENDIF
      IF Round( _vpc, 3 ) <> Round( nRVPC, 3 )  // izvrsiti nivelaciju

         IF !fNivelacija  .AND. ; // prva stavka za nivelaciju
            !( cidvd == "14" .AND. gNiv14 == "2" )   // minex
            cPromCj := Pitanje(, "Postoje promjene cijena. Staviti nove cijene u sifrarnik ?", "D" )
         ENDIF
         fNivelacija := .T.

         PRIVATE nKolZn := nKols := nc1 := nc2 := 0, dDatNab := CToD( "" )
         IF gKolicFakt == "D"
            KalkNaF( _idroba, @nKolS ) // uzmi iz FAKTA
         ELSE
            KalkNab( _idfirma, _idroba, _mkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
         ENDIF
         IF dDatNab > _DatDok; Beep( 1 );Msg( "Datum nabavke je " + DToC( dDatNab ), 4 );_ERROR := "1";ENDIF


         SELECT kalk_pripr2
         // append blank


         _idpartner := ""
         _rabat := prevoz := prevoz2 := _banktr := _spedtr := _zavtr := _nc := _marza := _marza2 := _mpc := 0
         _gkolicina := _gkolicin2 := _mpc := 0
         _VPC := kalk_pripr->vpc - nRVPC
         _MPCSAPP := nRVPC
         _kolicina := nKolS
         _brdok := cBrniv
         _idkonto := _mkonto
         _idkonto2 := ""
         _MU_I := "3"     // ninvelacija
         _PKonto := "";      _PU_I := ""
         _idvd := "18"

         _TBankTr := "X"    // izgenerisani dokument
         _ERROR := ""
         IF cIdVD $ "94" // storno fakture,storno otpreme - niveli{i na stornirano
            _kolicina := kalk_pripr->kolicina
            _vpc := nRVPC - kalk_pripr->vpc
            _mpcsapp := kalk_pripr->vpc
            _MKonto := _Idkonto
         ENDIF
         IF   ( cidvd == "14" .AND. gNiv14 == "2" )  // minex,
            _kolicina := kalk_pripr->kolicina
            _MKonto := _Idkonto
            IF _kolicina < 0 // radi se storno fakture
               _kolicina := -_kolicina
               _vpc := -_vpc
               _mpcsapp := kalk_pripr->vpc
            ENDIF

         ENDIF
         IF Round( _kolicina, 4 ) <> 0
            _rbr := Str( ++nRbr, 3 )
            APPEND ncnl
            gather2()
         ENDIF
         IF cPromCj == "D"
            IF cIdVD $ "10#16#14#96" ;  // samo ako je ulaz,izlaz u magacin promjeni stanje VPC u sif.robe
               .AND. !( cidvd == "14" .AND. gNiv14 == "2" )   // minex
               SELECT roba         // promjeni stanje robe !!!!
               ObSetVPC( kalk_pripr->vpc )

            ENDIF
         ENDIF
      ENDIF
      SELECT kalk_pripr
      SKIP
   ENDDO

   closeret

   RETURN
// }
