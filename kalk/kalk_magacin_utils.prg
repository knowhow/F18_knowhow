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



FUNCTION KalkNabP( cIdFirma, cIdroba, cIdkonto, nKolicina, nKolZN, nNC, nSNC, dDatNab )

   LOCAL npom, fproso
   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nSkiniKol
   LOCAL nZadnjaUNC

   nKolicina := 0

   IF lAutoObr == .T.
      // uzmi stanje iz cache tabele
      IF knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina, ;
            @nUlNv, @nIzlNv, @nNc ) == 1
         SELECT kalk_pripr
         RETURN .F.
      ENDIF
   ENDIF

   SELECT kalk
   SET ORDER TO TAG "4"  // idFirma+pkonto+idroba+pu_i+IdVD
   SEEK cIdFirma + cIdKonto + cIdRoba + Chr( 254 )
   SKIP -1


   IF cIdfirma + cIdkonto + cIdroba == field->idfirma + field->pkonto + field->idroba .AND. _datdok < field->datdok

      error_bar( "KA_" + cIdfirma + "-" + cIdkonto + "-" + cIdroba, " KA_KART_PROD " + cIdkonto + "-" + Trim( cIdroba ) + " postoje stavke na datum< " + DToC( field->datdok ) )
      _ERROR := "1"
   ENDIF


   nLen := 1

   nKolicina := 0

   // ukupna izlazna nabavna vrijednost
   nIzlNV := 0

   // ukupna izlazna kolicina
   nIzlKol := 0
   nUlNV := 0

   // ulazna kolicina
   nUlKol := 0
   nZadnjaUNC := 0

   // ovo je prvi prolaz
   HSEEK cIdFirma + cIdKonto + cIdRoba

   DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdroba == idFirma + pkonto + idroba .AND. _datdok >= datdok

      IF pu_i == "1" .OR. pu_i == "5"
         IF ( pu_i == "1" .AND. kolicina > 0 ) .OR. ( pu_i == "5" .AND. kolicina < 0 )
            nKolicina += Abs( kolicina )       // rad metode prve i zadnje nc moramo
            nUlKol    += Abs( kolicina )       // sve sto udje u magacin strpati pod
            nUlNV     += ( Abs( kolicina ) * nc )  // ulaznom kolicinom

            IF idvd $ "10#16#96"
               nZadnjaUNC := nc
            ENDIF

         ELSE
            nKolicina -= Abs( kolicina )
            nIzlKol   += Abs( kolicina )
            nIzlNV    += ( Abs( kolicina ) * nc )
         ENDIF
      ELSEIF pu_i == "I"
         nKolicina -= gkolicin2
         nIzlKol += gkolicin2
         nIzlNV += nc * gkolicin2
      ENDIF
      SKIP

   ENDDO // ovo je prvi prolaz

   // prva nabavka  se prva skida sa stanja
   IF gMetodaNc == "3"
      HSEEK cIdFirma + cIdKonto + cIdRoba
      nSkiniKol := nIzlKol + _Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
      nNabVr := 0  // stanje nabavne vrijednosti
      DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + pkonto + idroba .AND. _datdok >= datdok

         IF pu_i == "1" .OR. pu_i == "5"
            IF ( pu_i == "1" .AND. kolicina > 0 ) .OR. ( pu_i == "5" .AND. kolicina < 0 )
               IF nSkiniKol > Abs( kolicina )
                  nNabVr   += Abs( kolicina * nc )
                  nSkinikol -= Abs( kolicina )
               ELSE
                  nNabVr   += Abs( nSkiniKol * nc )
                  nSkinikol := 0
                  dDatNab := datdok
                  nKolZN := nSkiniKol
                  EXIT // uzeta je potrebna nabavka, izadji iz do while
               ENDIF
            ENDIF
         ELSEIF pu_i == "I" .AND.  gkolicin2 < 0   // IP - storno izlaz

            IF nSkiniKol > Abs( gKolicin2 )
               nNabVr   += Abs( gkolicin2 * nc )
               nSkinikol -= Abs( gkolicin2 )
            ELSE
               nNabVr   += Abs( nSkiniKol * nc )
               nSkinikol := 0
               dDatNab := datdok
               nKolZN := nSkiniKol
               EXIT // uzeta je potrebna nabavka, izadji iz do while
            ENDIF

         ENDIF
         SKIP
      ENDDO // ovo je drugi prolaz , metoda "3"

      IF _kolicina <> 0
         nNC := ( nNabVr - nIzlNV ) / _kolicina   // nabavna cijena po metodi prve
      ELSE
         nNC := 0
      ENDIF
   ENDIF

   // metoda zadnje nabavne cijene: zadnja nabavka se prva skida sa stanja

   IF gMetodaNc == "1"

      SEEK cIdFirma + cIdKonto + cIdRoba + Chr( 254 )
      nSkiniKol := nIzlKol + _Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
      nNabVr := 0  // stanje nabavne vrijednosti
      SKIP -1
      DO WHILE !Bof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + pkonto + idroba

         IF _datdok <= datdok // preskaci novije datume
            SKIP -1
            LOOP
         ENDIF

         IF pu_i == "1" .OR. pu_i == "5"
            IF ( pu_i == "1" .AND. kolicina > 0 ) .OR. ( pu_i == "5" .AND. kolicina < 0 ) // ulaz
               IF nSkiniKol > Abs( kolicina )
                  nNabVr   += Abs( kolicina * nc )
                  nSkinikol -= Abs( kolicina )
               ELSE
                  nNabVr   += Abs( nSkiniKol * nc )
                  nSkinikol := 0
                  dDatNab := datdok
                  nKolZN := nSkiniKol
                  EXIT // uzeta je potrebna nabavka, izadji iz do while
               ENDIF
            ENDIF
         ELSEIF ( pu_i == "I"  .AND. gkolicin2 < 0 )
            IF nSkiniKol > Abs( gkolicin2 )
               nNabVr   += Abs( gkolicin2 * nc )
               nSkinikol -= Abs( gkolicin2 )
            ELSE
               nNabVr   += Abs( nSkiniKol * nc )
               nSkinikol := 0
               dDatNab := datdok
               nKolZN := nSkiniKol
               EXIT // uzeta je potrebna nabavka, izadji iz do while
            ENDIF
         ENDIF
         SKIP -1
      ENDDO // ovo je drugi prolaz , metoda "1"

      IF _kolicina <> 0
         nNC := ( nNabVr - nIzlNV ) / _kolicina   // nabavna cijena po metodi zadnje
      ELSE
         nNC := 0
      ENDIF
   ENDIF

   IF Round( nKolicina, 5 ) == 0
      nSNC := 0
   ELSE
      nSNC := ( nUlNV - nIzlNV ) / nKolicina
   ENDIF


   IF gNC_ctrl > 0 .AND. nSNC <> 0 .AND. nZadnjaUNC <> 0 // ako se koristi kontrola NC

      nTmp := Round( nSNC, 4 ) - Round( nZadnjaUNC, 4 )
      nOdst := ( nTmp / Round( nZadnjaUNC, 4 ) ) * 100

      IF Abs( nOdst ) > gNC_ctrl

         Beep( 4 )
         IF nije_dozvoljeno_azuriranje_sumnjivih_stavki()
            CLEAR TYPEAHEAD // zaustavi asistenta
         ENDIF

         MsgBeep( "Odstupanje u odnosu na zadnji ulaz je#" + ;
            AllTrim( Str( Abs( nOdst ) ) ) + " %" + "#" + ;
            "artikal: " + AllTrim( _idroba ) + " " + ;
            PadR( roba->naz, 15 ) + " nc:" + ;
            AllTrim( Str( nSNC, 12, 2 ) ) )

         // a_nc_ctrl( @aNC_ctrl, idroba, nKolicina, ;
         // nSNC, nZadnjaUNC )

         IF Pitanje(, "Napraviti korekciju NC (D/N)?", "N" ) == "D"

            nTmp_n_stanje := ( nKolicina - _kolicina )
            nTmp_n_nv := ( nTmp_n_stanje * nZadnjaUNC )
            nTmp_s_nv := ( nKolicina * nSNC )

            nSNC := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina )

         ENDIF

      ENDIF
   ENDIF

   nKolicina := Round( nKolicina, 4 )
   SELECT kalk_pripr

   RETURN .T.




FUNCTION MarzaVP( cIdVd, lNaprijed )

   LOCAL SKol := 0

   IF ( _nc == 0 )
      _nc := 9999
   ENDIF

   IF gKalo == "1" .AND. cIdvd == "10"
      Skol := _Kolicina - _GKolicina - _GKolicin2
   ELSE
      Skol := _Kolicina
   ENDIF

   IF  _Marza == 0 .OR. _VPC <> 0 .AND. !lNaprijed
      // unazad formiraj marzu
      nMarza := _VPC - _NC
      IF _TMarza == "%"
         _Marza := 100 * ( _VPC / _NC - 1 )
      ELSEIF _TMarza == "A"
         _Marza := nMarza
      ELSEIF _TMarza == "U"
         _Marza := nMarza * SKol
      ENDIF

   ELSEIF Round( _VPC, 4 ) == 0  .OR. lNaprijed
      // formiraj marzu "unaprijed" od nc do vpc
      IF _TMarza == "%"
         nMarza := _Marza / 100 * _NC
      ELSEIF _TMarza == "A"
         nMarza := _Marza
      ELSEIF _TMarza == "U"
         nMarza := _Marza / SKol
      ENDIF
      _VPC := Round( ( nMarza + _NC ), 2 )

   ELSE
      IF cIdvd $ "14#94"
         nMarza := _VPC * ( 1 -_Rabatv / 100 ) - _NC
      ELSE
         nMarza := _VPC - _NC
      ENDIF
   ENDIF
   AEval( GetList, {| o| o:display() } )

   RETURN
// }


/* Marza(fmarza)
 *     Proracun veleprodajne marze
 */

FUNCTION Marza( fmarza )

   // {
   LOCAL SKol := 0, nPPP

   IF fmarza == NIL
      fMarza := " "
   ENDIF

   IF _nc == 0
      _nc := 9999
   ENDIF

   IF roba->tip $ "VKX"
      nPPP := 1 / ( 1 + tarifa->opp / 100 )
      IF roba->tip = "X"; nPPP := nPPP * _mpcsapp / _vpc; ENDIF
   ELSE
      nPPP := 1
   ENDIF


   IF gKalo == "1" .AND. _idvd == "10"
      Skol := _Kolicina - _GKolicina - _GKolicin2
   ELSE
      Skol := _Kolicina
   ENDIF

   IF  _Marza == 0 .OR. _VPC <> 0 .AND. Empty( fMarza )
      nMarza := _VPC * nPPP - _NC
      IF roba->tip = "X"
         nMarza -= roba->mpc - _VPC
         // nmarza:= _vpc*npp-_nc - (roba->mpc-_vpc)
         // nmarza/_nc := (_vpc*nppp/nc-1 - (roba->mpc-_Vpc)/nc)
         // nmarza/_nc := ( (_vpc*nppp - roba->mpc -_vpc)/_nc-1)
      ENDIF
      IF _TMarza == "%"
         IF roba->tip = "X"
            _Marza := 100 * ( ( _VPC * nPPP - roba->mpc - _vpc ) / _NC - 1 )
         ELSE
            _Marza := 100 * ( _VPC * nPPP / _NC - 1 )
         ENDIF
      ELSEIF _TMarza == "A"
         _Marza := nMarza
      ELSEIF _TMarza == "U"
         _Marza := nMarza * SKol
      ENDIF

   ELSEIF Round( _VPC, 4 ) == 0  .OR. !Empty( fMarza )
      IF _TMarza == "%"
         nMarza := _Marza / 100 * _NC
      ELSEIF _TMarza == "A"
         nMarza := _Marza
      ELSEIF _TMarza == "U"
         nMarza := _Marza / SKol
      ENDIF
      _VPC := Round( ( nMarza + _NC ) / nPPP, 2 )
   ELSE
      IF _idvd $ "14#94"
         IF roba->tip == "V"
            nMarza := _VPC * nPPP - _VPC * _Rabatv / 100 -_NC
         ELSE
            nMarza := _VPC * nPPP * ( 1 -_Rabatv / 100 ) -_NC
         ENDIF
      ELSE
         nMarza := _VPC * nPPP - _NC
      ENDIF
   ENDIF
   AEval( GetList, {| o| o:display() } )

   RETURN
// }



/* FaktVPC(nVPC,cseek,dDatum)
 *     Fakticka veleprodajna cijena
 */

FUNCTION FaktVPC( nVPC, cseek, dDatum )

   // {
   LOCAL nOrder

   IF koncij->naz == "V2" .AND. roba->( FieldPos( "vpc2" ) ) <> 0
      nVPC := roba->vpc2
   ELSEIF koncij->naz == "P2"
      nVPC := roba->plc
   ELSEIF roba->( FieldPos( "vpc" ) ) <> 0
      nVPC := roba->vpc
   ELSE
      nVPC := 0
   ENDIF

   SELECT kalk
   PushWA()
   SET FILTER TO
   // nOrder:=indexord()
   SET ORDER TO TAG "3" // idFirma+mkonto+idroba+dtos(datdok)
   SEEK cseek + "X"
   SKIP -1


   DO WHILE !Bof() .AND. idfirma + mkonto + idroba == cseek

      IF dDatum <> NIL .AND. dDatum < datdok
         SKIP -1
         LOOP
      ENDIF

      // if mu_i=="1" //.or. mu_i=="5"
      IF idvd $ "RN#10#16#12#13"
         IF koncij->naz <> "P2"
            nVPC := vpc
         ENDIF
         EXIT
      ELSEIF idvd == "18"
         nVPC := mpcsapp + vpc
         EXIT
      ENDIF
      SKIP -1
   ENDDO
   PopWa()
   // dbsetorder(nOrder)

   RETURN
// }



/* PratiKMag(cIdFirma,cIdKonto,cIdRoba)
 *     Prati karticu magacina
 */

FUNCTION PratiKMag( cIdFirma, cIdKonto, cIdRoba )

   // {
   LOCAL nPom
   SELECT kalk ; SET ORDER TO TAG "3"
   HSEEK cIdFirma + cIdKonto + cIdRoba
   // "KALKi3","idFirma+mkonto+idroba+dtos(datdok)+PODBR+MU_I+IdVD",KUMPATH+"KALK")

   nVPV := 0
   nKolicina := 0
   DO WHILE !Eof() .AND.  cIdFirma + cIdKonto + cIdRoba == idfirma + idkonto + idroba

      dDatDok := datdok
      DO WHILE !Eof() .AND.  cIdFirma + cIdKonto + cIdRoba == idfirma + idkonto + idroba ;
            .AND. datdok == dDatDok


         nVPC := vpc   // veleprodajna cijena
         IF mu_i == "1"
            nPom := kolicina - gkolicina - gkolicin2
            nKolicina += nPom
            nVPV += nPom * vpc
         ELSEIF mu_i == "3"
            nPom := kolicina
            nVPV += nPom * vpc
            // kod ove kalk mpcsapp predstavlja staru vpc
            nVPC := vpc + mpcsapp
         ELSEIF mu_i == "5"
            nPom := kolicina
            nVPV -= nPom * VPC
         ENDIF

         IF Round( nKolicina, 4 ) <> 0
            IF Round( nVPV / nKolicina, 2 ) <> Round( nVPC, 2 )

            ENDIF
         ENDIF

      ENDDO

   ENDDO

   RETURN
// }



/* ObSetVPC(nNovaVrijednost)
 *     Obavezno setuj VPC
 */

FUNCTION ObSetVPC( nNovaVrijednost )

   LOCAL nArr := Select()
   LOCAL _rec
   PRIVATE cPom := "VPC"

   IF koncij->naz == "P2"
      cPom := "PLC"
   ELSEIF koncij->naz == "V2"
      cPom := "VPC2"
   ELSE
      cPom := "VPC"
   ENDIF

   SELECT roba
   _rec := dbf_get_rec()

   _rec[ Lower( cPom ) ] := nNovaVrijednost

   update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

   SELECT ( nArr )

   RETURN .T.




/* UzmiVPCSif(cMKonto,lKoncij)
 *     Za zadani magacinski konto daje odgovarajucu VPC iz sifrarnika robe
 */

FUNCTION UzmiVPCSif( cMKonto, lKoncij )

   // {
   LOCAL nCV := 0, nArr := Select()
   IF lKoncij = NIL; lKoncij := .F. ; ENDIF
   SELECT KONCIJ
   nRec := RecNo()
   SEEK Trim( cMKonto )
   nCV := KoncijVPC()
   IF !lKoncij
      GO ( nRec )
   ENDIF
   SELECT ( nArr )

   RETURN nCV
// }



/* NabCj()
 *     Proracun nabavne cijene za ulaznu kalkulaciju 10
 */

FUNCTION NabCj()

   // {
   LOCAL Skol

   IF gKalo == "1"
      Skol := _Kolicina - _GKolicina - _GKolicin2
   ELSE
      Skol := _Kolicina
   ENDIF


   IF _TPrevoz == "%"
      nPrevoz := _Prevoz / 100 * _FCj2
   ELSEIF _TPrevoz == "A"
      nPrevoz := _Prevoz
   ELSEIF _TPrevoz == "U"
      nPrevoz := _Prevoz / SKol
   ELSEIF _TPrevoz == "R"
      nPrevoz := 0
   ELSE
      nPrevoz := 0
   ENDIF
   IF _TCarDaz == "%"
      nCarDaz := _CarDaz / 100 * _FCj2
   ELSEIF _TCarDaZ == "A"
      nCarDaz := _CarDaz
   ELSEIF _TCArDaz == "U"
      nCarDaz := _CarDaz / SKol
   ELSEIF _TCArDaz == "R"
      nCarDaz := 0
   ELSE
      nCardaz := 0
   ENDIF
   IF _TZavTr == "%"
      nZavTr := _ZavTr / 100 * _FCj2
   ELSEIF _TZavTr == "A"
      nZavTr := _ZavTr
   ELSEIF _TZavTr == "U"
      nZavTr := _ZavTr / SKol
   ELSEIF _TZavTr == "R"
      nZavTr := 0
   ELSE
      nZavTr := 0
   ENDIF
   IF _TBankTr == "%"
      nBankTr := _BankTr / 100 * _FCj2
   ELSEIF _TBankTr == "A"
      nBankTr := _BankTr
   ELSEIF _TBankTr == "U"
      nBankTr := _BankTr / SKol
   ELSE
      nBankTr := 0
   ENDIF
   IF _TSpedTr == "%"
      nSpedTr := _SpedTr / 100 * _FCj2
   ELSEIF _TSpedTr == "A"
      nSpedTr := _SpedTr
   ELSEIF _TSpedTr == "U"
      nSpedTr := _SpedTr / SKol
   ELSE
      nSpedTr := 0
   ENDIF

   _NC := _FCj2 + nPrevoz + nCarDaz + nBanktr + nSpedTr + nZavTr

   RETURN
// }



/* NabCj2(n1,n2)
 *   param: n1 - ukucana NC
 *   param: n2 - izracunata NC
 *     Ova se f-ja koristi samo za 10-ku bez troskova (gVarijanta="1")
 */

FUNCTION NabCj2( n1, n2 )

   IF Round( _FCJ, 6 )  == 0
      Alert( "Fakturna cijene ne moze biti 0" )
      _FCJ := 1
      RETURN .F.
   ENDIF

   IF Abs( n1 - n2 ) > 0.00001
      // tj. ako je ukucana drugacija NC

      _rabat := 100 -100 * _NC / _FCJ
      _FCJ2 := _NC
      ShowGets()
   ENDIF

   RETURN .T.



/* SetujVPC(nNovaVrijednost,fUvijek)
 *   param: fUvijek -.f. samo ako je vrijednost u sifrarniku 0, .t. uvijek setuj
 *     Utvrdi varijablu VPC. U sifrarnik staviti novu vrijednost
 */

FUNCTION SetujVPC( nNovaVrijednost, lUvijek )

   LOCAL nVal
   LOCAL _vars

   IF lUvijek == nil
      lUvijek := .F.
   ENDIF

   PRIVATE cPom := "VPC"

   IF koncij->naz == "P2"
      cPom := "plc"
      nVal := roba->plc
   ELSEIF koncij->naz == "V2"
      cPom := "vpc2"
      nVal := roba->VPC2
   ELSE
      cPom := "vpc"
      nVal := roba->VPC
   ENDIF

   IF nVal == 0  .OR. Abs( Round( nVal - nNovaVrijednost, 2 ) ) > 0 .OR. lUvijek

      IF gAutoCjen == "D" .AND. Pitanje( , "Staviti Cijenu (" + cPom + ")" + " u sifrarnik ?", "D" ) == "D"
         SELECT roba

         _vars := dbf_get_rec()
         _vars[ cPom ] := nNovaVrijednost

         update_rec_server_and_dbf( "roba", _vars, 1, "FULL" )

         SELECT kalk_pripr
      ENDIF
   ENDIF

   RETURN .T.



/* KoncijVPC()
 *     Daje odgovarajucu VPC iz sifrarnika robe
 */

FUNCTION KoncijVPC()

   // {
   // podrazumjeva da je nastimana tabela koncij
   // ------------------------------------------
   IF koncij->naz == "P2"
      RETURN roba->plc
   ELSEIF koncij->naz == "V2"
      RETURN roba->VPC2
   ELSEIF koncij->naz == "V3"
      RETURN roba->VPC3
   ELSE
      RETURN roba->VPC
   ENDIF

   RETURN ( nil )
// }



/* MMarza()
 *     Preracunava iznos veleprodajne marze
 */

FUNCTION MMarza()

   // {
   LOCAL SKol := 0
   Skol := Kolicina - GKolicina - GKolicin2
   IF TMarza == "%" .OR. Empty( tmarza )
      nMarza := Skol * Marza / 100 * NC
   ELSEIF TMarza == "A"
      nMarza := Marza * Skol
   ELSEIF TMarza == "U"
      nMarza := Marza
   ENDIF

   RETURN nMarza




/* PrerRab()
 *     Rabat veleprodaje - 14
 */

FUNCTION PrerRab()

   LOCAL nPrRab

   IF cTRabat == "%"
      nPrRab := _rabatv
   ELSEIF cTRabat == "A"
      IF _VPC <> 0
         nPrRab := _RABATV / _VPC * 100
      ELSE
         nPrRab := 0
      ENDIF
   ELSEIF cTRabat == "U"
      IF _vpc * _kolicina <> 0
         nprRab := _rabatV / ( _vpc * _kolicina ) * 100
      ELSE
         nPrRab := 0
      ENDIF
   ELSE
      RETURN .F.
   ENDIF
   _rabatv := nPrRab
   cTrabat := "%"
   showgets()

   RETURN .T.
// }


// Validacija u prilikom knjizenja (knjiz.prg) - VALID funkcija u get-u

// Koristi sljedece privatne varijable:
// nKols
// gMetodaNC
// _TBankTr - "X"  - ne provjeravaj - vrati .t.
// ---------------------------------------------
// Daje poruke:
// Nabavna cijena manja od 0 ??
// Ukupno na stanju samo XX robe !!

FUNCTION V_KolMag()

   IF ( _nc < 0 ) .AND. !( _idvd $ "11#12#13#22" ) .OR.  _fcj < 0 .AND. _idvd $ "11#12#13#22"

      Msg( "Nabavna cijena manja od 0 !?" )
      _ERROR := "1"

   ENDIF

   IF roba->tip $ "UTY"; RETURN .T. ; ENDIF // usluge

   IF Empty( gMetodaNC ) .OR. _TBankTR == "X" // bez ograde
      RETURN .T.
   ENDIF

   IF nKolS < _Kolicina
      Beep( 4 )
      IF nije_dozvoljeno_azuriranje_sumnjivih_stavki()
         CLEAR TYPEAHEAD // zaustavi asistent magacin - kolicina
      ENDIF
      error_bar( "KA_" + _mkonto + "/" + _idroba, ;
         _mkonto + " / " + _idroba + "na stanju: " + AllTrim( Str( nKolS, 10, 4 ) ) + " treba " +  AllTrim( Str( _kolicina, 10, 4 ) ) )
      _ERROR := "1"
   ENDIF

   RETURN .T.



/* V_RabatV()
 *     Ispisuje vrijednost rabata u VP
 */

// Trenutna pozicija u tabeli KONCIJ (na osnovu koncij->naz ispituje cijene)
// Trenutan pozicija u tabeli ROBA (roba->tip)

FUNCTION V_RabatV()

   LOCAL nPom, nMPCVT
   LOCAL nRVPC := 0
   PRIVATE getlist := {}, cPom := "VPC"

   IF koncij->naz == "P2"
      cPom := "PLC"
   ELSEIF koncij->naz == "V2"
      cPom := "VPC2"
   ELSE
      cPom := "VPC"
   ENDIF

   IF roba->tip $ "UTY"
      RETURN .T.
   ENDIF

   nRVPC := KoncijVPC()
   IF Round( nRVPC - _vpc, 4 ) <> 0  .AND. gMagacin == "2"
      IF nRVPC == 0
         Beep( 1 )
         Box(, 3, 60 )
         @ m_x + 1, m_Y + 2 SAY "Roba u sifrarniku ima " + cPom + " = 0 !??"
         @ m_x + 3, m_y + 2 SAY "Unesi " + cPom + " u sifrarnik:" GET _vpc PICT picdem

         READ

         SELECT roba
         _rec := dbf_get_rec()

         _rec[ Lower( cPom ) ] := _vpc
         update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

         SELECT kalk_pripr
         BoxC()

      ENDIF
   ENDIF

   // roba tarife
   IF roba->tip == "V"
      nMarza := _VPC / ( 1 + _PORVT ) -_VPC * _RabatV / 100 -_NC
   ELSEIF roba->tip = "X"
      nMarza := _VPC * ( 1 -_RabatV / 100 ) -_NC - _MPCSAPP / ( 1 + _PORVT ) * _porvt
   ELSE
      nMarza := _VPC / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) -_NC
   ENDIF

   IF IsPDV()
      @ m_x + 15, m_y + 41  SAY "PC b.pdv.-RAB:"
   ELSE
      @ m_x + 15, m_y + 41  SAY "VPC b.p.-RAB:"
   ENDIF

   IF roba->tip == "V"
      @ m_x + 15, Col() + 1 SAY _Vpc / ( 1 + _PORVT ) -_VPC * _RabatV / 100 PICT picdem
   ELSEIF roba->tip == "X"
      @ m_x + 15, Col() + 1 SAY _Vpc * ( 1 -_RabatV / 100 ) - _MPCSAPP / ( 1 + _PORVT ) * _PORVT PICT picdem
   ELSE
      @ m_x + 15, Col() + 1 SAY _Vpc / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) PICT picdem
   ENDIF

   ShowGets()

   RETURN .T.



/*
  Racuna nabavnu cijenu i stanje robe u magacinu
   KalkNab(cIdFirma, cIdRoba, cIdKonto, 4-nKolicina, 5-nKolZN, 6-nNC, 7-nSNC, 8-dDatNab)

  4) kolicina na stanju
  5) nKolZN - kolicina koja je na stanju od zadnje nabavke
  6) nNC - zadnja nabavna cijena
  7) nSNC - srednja nabavna cijena
  8) param dDatNab - datum nabavke

*/

FUNCTION KalkNab( cIdFirma, cIdRoba, cIdKonto, nKolicina, nKolZN, nNC, nSNc, dDatNab )

   LOCAL nPom
   LOCAL fProso
   LOCAL nIzlNV
   LOCAL nIzlKol
   LOCAL nUlNV
   LOCAL nUlKol
   LOCAL nSkiniKol
   LOCAL nKolNeto
   LOCAL nZadnjaUNC

   // posljednje pozitivno stanje
   LOCAL nKol_poz := 0
   LOCAL nUVr_poz, nIVr_poz
   LOCAL nUKol_poz, nIKol_poz

   nKolicina := 0

   IF lAutoObr == .T.
      // uzmi stanje iz cache tabele
      IF knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina, ;
            @nUlNv, @nIzlNv, @nSNC ) == 1
         SELECT kalk_pripr
         RETURN .T.
      ENDIF
   ENDIF

   my_use_refresh_stop()
   SELECT kalk

   SET ORDER TO TAG "3"
   SEEK cIdFirma + cIdKonto + cIdRoba + "X"

   SKIP -1
   IF ( ( cIdFirma + cIdKonto + cIdRoba ) == ( field->idfirma + field->mkonto + field->idroba ) ) .AND. _datdok < field->datdok
      error_bar( "KA_" + cIdfirma + "/" + cIdKonto + "/" + cIdRoba, "Postoji dokument " + field->idfirma + "-" + field->idvd + "-" + field->brdok + " na datum: " + DToC( field->datdok ), 4 )
      _ERROR := "1"
   ENDIF

   nLen := 1

   nKolicina := 0
   nIzlNV := 0
   // ukupna izlazna nabavna vrijednost
   nUlNV := 0
   nIzlKol := 0
   // ukupna izlazna kolicina
   nUlKol := 0
   // ulazna kolicina
   nZadnjaUNC := 0


   // ovo je prvi prolaz
   // u njemu se proracunava totali za jednu karticu
   HSEEK cIdFirma + cIdKonto + cIdRoba
   DO WHILE !Eof() .AND. ( ( cIdFirma + cIdKonto + cIdRoba ) == ( idFirma + mkonto + idroba ) ) .AND. _datdok >= datdok

      IF mu_i == "1" .OR. mu_i == "5"

         IF IdVd == "10"
            // kod 10-ki je originalno predvidjeno gubitak kolicine (kalo i rastur)
            // mislim da ovo niko i ne koristi, ali eto neka stoji
            nKolNeto := Abs( kolicina - gKolicina - gKolicin2 )
         ELSE
            nKolNeto := Abs( kolicina )
         ENDIF

         IF ( mu_i == "1" .AND.  kolicina > 0 ) .OR. ( mu_i == "5" .AND. kolicina < 0 )

            // ulazi plus, storno izlaza
            nKolicina += nKolNeto
            nUlKol    += nKolNeto
            nUlNV     += ( nKolNeto * nc )

            // zapamti uvijek zadnju ulaznu NC
            IF idvd $ "10#16#96"
               nZadnjaUNC := nc
            ENDIF

         ELSE

            nKolicina -= nKolNeto

            nIzlKol   += nKolNeto
            nIzlNV    += ( nKolNeto * nc )

         ENDIF

         // ako je stanje pozitivno zapamti ga
         IF Round( nKolicina, 8 ) > 0
            nKol_poz := nKolicina

            nUKol_poz := nUlKol
            nIKol_poz := nIzlKol

            nUVr_poz := nUlNv
            nIVr_poz := nIzlNv
         ENDIF


      ENDIF
      SKIP

   ENDDO
   // ovo je bio prvi prolaz


   // koliko znam i ovo niko ne koristi svi koriste srednju nabavnu
   // gMetodaNC=="3"  // prva nabavka  se prva skida sa stanja
   IF gMetodaNc == "3"
      HSEEK cIdFirma + cIdKonto + cIdRoba
      nSkiniKol := nIzlKol + _Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
      nNabVr := 0  // stanje nabavne vrijednosti
      DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + mkonto + idroba .AND. _datdok >= datdok

         IF mu_i == "1" .OR. mu_i == "5"
            IF ( mu_i == "1" .AND. kolicina > 0 ) .OR. ( mu_i == "5" .AND. kolicina < 0 ) // ulaz
               IF nSkiniKol > Abs( kolicina )
                  nNabVr   += Abs( kolicina * nc )
                  nSkinikol -= Abs( kolicina )
               ELSE
                  nNabVr   += Abs( nSkiniKol * nc )
                  nSkinikol := 0
                  dDatNab := datdok
                  nKolZN := nSkiniKol
                  EXIT // uzeta je potrebna nabavka, izadji iz do while
               ENDIF
            ENDIF
         ENDIF
         SKIP
      ENDDO // ovo je drugi prolaz , metoda "3"

      IF _kolicina <> 0
         nNC := ( nNabVr - nIzlNV ) / _kolicina
      ELSE
         nNC := 0
      ENDIF
   ENDIF

   // koliko znam i ovo niko ne koristi svi koriste srednju nabavnu
   // gMetodaNC=="1"  // zadnja nabavka se prva skida sa stanja
   IF gMetodaNc == "1"
      SEEK cIdFirma + cIdKonto + cIdRoba + Chr( 254 )
      nSkiniKol := nIzlKol + _Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
      nNabVr := 0  // stanje nabavne vrijednosti
      SKIP -1
      DO WHILE !Bof() .AND. cIdFirma + cIdKonto + cIdRoba == idFirma + mkonto + idroba

         IF _datdok <= datdok // preskaci novije datume
            SKIP -1; LOOP
         ENDIF

         IF mu_i == "1" .OR. mu_i == "5"
            IF ( mu_i == "1" .AND. kolicina > 0 ) .OR. ( mu_i == "5" .AND. kolicina < 0 ) // ulaz
               IF nSkiniKol > Abs( kolicina )
                  nNabVr   += Abs( kolicina * nc )
                  nSkinikol -= Abs( kolicina )
               ELSE
                  nNabVr   += Abs( nSkiniKol * nc )
                  nSkinikol := 0
                  dDatNab := datdok
                  nKolZN := nSkiniKol
                  EXIT // uzeta je potrebna nabavka, izadji iz do while
               ENDIF
            ENDIF
         ENDIF
         SKIP -1
      ENDDO // ovo je drugi prolaz , metoda "1"

      IF _kolicina <> 0
         nNC := ( nNabVr - nIzlNV ) / _kolicina   // nabavna cijena po metodi zadnje
      ELSE
         nNC := 0
      ENDIF
   ENDIF

   // utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
   IF Round( nKol_poz, 8 ) == 0
      nSNc := 0
   ELSE
      // srednja nabavna cijena
      nSNc := ( nUVr_poz - nIVr_poz ) / nKol_poz
   ENDIF

   // ako se koristi kontrola NC
   IF gNC_ctrl > 0 .AND. nSNC <> 0 .AND. nZadnjaUNC <> 0

      nTmp := Round( nSNC, 4 ) - Round( nZadnjaUNC, 4 )
      nOdst := ( nTmp / Round( nZadnjaUNC, 4 ) ) * 100

      IF Abs( nOdst ) > gNC_ctrl

         Beep( 4 )
         IF nije_dozvoljeno_azuriranje_sumnjivih_stavki()
            CLEAR TYPEAHEAD
         ENDIF

         MsgBeep( "Odstupanje u odnosu na zadnji ulaz je#" + ;
            AllTrim( Str( Abs( nOdst ) ) ) + " %" + "#" + ;
            "artikal: " + AllTrim( _idroba ) + " " + ;
            PadR( roba->naz, 15 ) + " nc:" + ;
            AllTrim( Str( nSNC, 12, 2 ) ) )

         // a_nc_ctrl( @aNC_ctrl, idroba, nKolicina, ;
         // nSNC, nZadnjaUNC )

         IF Pitanje(, "Napraviti korekciju NC (D/N)?", "N" ) == "D"

            nTmp_n_stanje := ( nKolicina - _kolicina )
            nTmp_n_nv := ( nTmp_n_stanje * nZadnjaUNC )
            nTmp_s_nv := ( nKolicina * nSNC )

            nSNC := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina )

         ENDIF
      ENDIF
   ENDIF

   // daj posljednje stanje kakvo i jeste
   nKolicina := Round( nKolicina, 4 )

   SELECT kalk_pripr
   my_use_refresh_start()

   RETURN .T.


// ---------------------------------------------------------
// dodaj u matricu robu koja je problematicna
// ---------------------------------------------------------
FUNCTION a_nc_ctrl( aCtrl, cIdRoba, nKol, nSnc, nZadnjaNC )

   LOCAL nScan := 0
   LOCAL nOdst := 0

   IF nSNC <> 0 .AND. nZadnjaNC <> 0
      nTmp := Round( nSNC, 4 ) - Round( nZadnjaNC, 4 )
      nOdst := ( nTmp / Round( nZadnjaNC, 4 ) ) * 100
   ENDIF

   nScan := AScan( aCtrl, {| xVal| xVal[ 1 ] == cIdRoba } )

   IF nScan = 0
      // dodaj novi zapis
      AAdd( aCtrl, { cIdRoba, nKol, nSNC, nZadnjaNC, nOdst } )
   ELSE
      // ispravi tekuce zapise
      aCtrl[ nScan, 2 ] := nKol
      aCtrl[ nScan, 3 ] := nSNC
      aCtrl[ nScan, 4 ] := nZadnjaNC
      aCtrl[ nScan, 5 ] := nOdst

   ENDIF

   RETURN .T.

// ------------------------------------------------
// popup kod nabavne cijene
// ------------------------------------------------
FUNCTION p_nc_popup( cIdRoba )

   LOCAL nScan

   nScan := AScan( aNC_ctrl, {| xVal| xVal[ 1 ] == cIdRoba } )

   IF nScan <> 0

      // daj mi odstupanje !
      nOdstupanje := Round( aNC_ctrl[ nScan, 5 ], 2 )
      MsgBeep( "Odstupanje u odnosu na zadnji ulaz je#" + ;
         AllTrim( Str( nOdstupanje ) ) + " %" )

   ENDIF

   RETURN .T.


// ------------------------------------------------
// stampanje stanja iz kontrolne tabele
// ------------------------------------------------
FUNCTION p_nc_ctrl( aCtrl )

   LOCAL nTArea := Select()
   LOCAL i
   LOCAL cLine := ""
   LOCAL cTxt := ""
   LOCAL nCnt := 0

   IF Len( aCtrl ) = 0
      RETURN
   ENDIF

   START PRINT CRET

   ?
   ? "Kontrola odstupanja nabavne cijene"
   ? "- kontrolna tacka = " + AllTrim( Str( gNC_ctrl ) ) + "%"
   ?

   cLine += Replicate( "-", 5 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 10 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )
   cLine += Space( 1 )
   cLine += Replicate( "-", 12 )

   cTxt += PadR( "r.br", 5 )
   cTxt += Space( 1 )
   cTxt += PadR( "artikal", 10 )
   cTxt += Space( 1 )
   cTxt += PadR( "kolicina", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "zadnja NC", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "nova NC", 12 )
   cTxt += Space( 1 )
   cTxt += PadR( "odstupanje", 12 )

   ? cLine
   ? cTxt
   ? cLine

   FOR i := 1 TO Len( aCtrl )

      // rbr
      ? PadL( AllTrim( Str( ++nCnt ) ), 4 ) + "."
      // idroba
      @ PRow(), PCol() + 1 SAY aCtrl[ i, 1 ]
      // kolicina
      @ PRow(), PCol() + 1 SAY aCtrl[ i, 2 ]
      // zadnja nc
      @ PRow(), PCol() + 1 SAY aCtrl[ i, 4 ]
      // nova nc
      @ PRow(), PCol() + 1 SAY aCtrl[ i, 3 ]
      // odstupanje
      @ PRow(), PCol() + 1 SAY aCtrl[ i, 5 ] PICT "9999%"

   NEXT

   FF
   ENDPRINT

   SELECT ( nTArea )

   RETURN .T.




// -------------------------------------
// magacin samo po nabavnim cijenama
// -------------------------------------
FUNCTION IsMagSNab()

   LOCAL lN1 := .F.

   PushWA()

   // da li je uopste otvoren koncij
   SELECT F_KONCIJ
   IF Used()
      IF koncij->naz == "N1"
         lN1 := .T.
      ENDIF
   ENDIF
   PopWa()

   IF ( gMagacin == "1" ) .OR. lN1
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF
