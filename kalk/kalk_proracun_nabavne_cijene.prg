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


MEMVAR _mkonto, _idroba, _Kolicina, m_x, m_y, GetList

STATIC s_nPragOdstupanjaNCSumnjiv := NIL
STATIC s_nStandarnaStopaMarze := NIL

/*

   ako je srednja nabavna cijena 0.2, ako je nabavna cijena posljednjeg ulaza 0.42

   irb(main):009:0> (0.2-0.42)/0.2*100
   => -109.999 %

  odstupanje je 109%, sto okida prag ako je on 99%

*/
FUNCTION prag_odstupanja_nc_sumnjiv( nSet )

   IF  s_nPragOdstupanjaNCSumnjiv == NIL
      s_nPragOdstupanjaNCSumnjiv := fetch_metric( "prag_odstupanja_nc_sumnjiv", NIL, 99.99 ) // 99,99%
   ENDIF

   IF nSet != NIL
      s_nPragOdstupanjaNCSumnjiv := nSet
      set_metric( "prag_odstupanja_nc_sumnjiv", NIL, nSet )
   ENDIF

   RETURN s_nPragOdstupanjaNCSumnjiv


/*

ako je nabavna cijena 0, ponuditi cijenu koja je roba.vpc / ( 1 + standardna_stopa_marze )
npr. vpc=1, standarna_stopa_marze = 20%, nc=0.8

IF Abs( Round( nSrednjaNabavnaCijena, 4 ) ) == 0 .AND. roba->vpc != 0
   nSrednjaNabavnaCijena := Round( roba->vpc / ( 1 + standardna_stopa_marze() / 100 ), 4 )
ENDIF

*/

FUNCTION standardna_stopa_marze( nSet )

   IF s_nStandarnaStopaMarze == NIL
      s_nStandarnaStopaMarze  := fetch_metric( "standarna_stopa_marze", NIL, 19.99 ) // 19.99%
   ENDIF

   IF nSet != NIL
      s_nStandarnaStopaMarze := nSet
      set_metric( "standarna_stopa_marze", NIL, nSet )
   ENDIF

   RETURN s_nStandarnaStopaMarze


FUNCTION korekcija_nabavne_cijene_sa_zadnjom_ulaznom( nKolicina, nZadnjiUlazKol, nZadnjaUlaznaNC, nSrednjaNabavnaCijena, lSilent )

   LOCAL nOdst
   LOCAL cDN
   LOCAL nX
   LOCAL GetList := {}

   hb_default( @lSilent, .F. )
   IF Round( nSrednjaNabavnaCijena, 4 ) == 0 .AND. Round( nZadnjaUlaznaNC, 4 ) > 0
      nSrednjaNabavnaCijena := nZadnjaUlaznaNC
      RETURN nSrednjaNabavnaCijena
   ENDIF

   IF prag_odstupanja_nc_sumnjiv() == 0 .OR. Round( nZadnjaUlaznaNC, 4 ) <= 0
      RETURN nSrednjaNabavnaCijena
   ENDIF

   nOdst := ( Round( nSrednjaNabavnaCijena, 4 ) - Round( nZadnjaUlaznaNC, 4 ) ) / ;
      Min( Abs( Round( nZadnjaUlaznaNC, 4 ) ), Abs( Round( nSrednjaNabavnaCijena, 4 ) )  ) * 100

   IF Abs( nOdst ) > prag_odstupanja_nc_sumnjiv()

      IF ( nKolicina <= 0 ) .OR. ( nSrednjaNabavnaCijena < 0 )
         cDN := "D" // kartica je u minusu - najbolje razduzi prema posljednjem ulazu
      ELSE
         cDN := "N" // metodom srednje nabavne cijene razduzi
      ENDIF
      IF !lSilent
         CLEAR TYPEAHEAD

         nX := 2
         Box( "#" + "== Odstupanje NC " + AllTrim( _mkonto ) + "/" + AllTrim( _idroba ) + " ===", 12, 70, .T. )

         @ m_x + nX, m_y + 2   SAY     "Artikal: " + AllTrim( _idroba ) + "-" + PadR( roba->naz, 20 )
         nX += 2
         @ m_x + nX++, m_y + 2 SAY8 "  količina na stanju: " + AllTrim( say_kolicina( nKolicina ) )
         @ m_x + nX, m_y + 2 SAY8 "            Srednja NC: " + AllTrim( say_cijena( nSrednjaNabavnaCijena ) ) + " <"
         nX  += 2
         @ m_x + nX++, m_y + 2 SAY8 "količina zadnji ulaz: " + AllTrim( say_kolicina( nZadnjiUlazKol ) )
         @ m_x + nX++, m_y + 2 SAY8 "      NC Zadnji ulaz: " + AllTrim( say_cijena( nZadnjaUlaznaNC ) ) + " <"
         nX += 2
         @ m_x + nX++, m_y + 2 SAY8 " Korigovati NC na zadnju ulaznu: D/N ?"  GET cDn VALID cDn $ "DN" PICT "@!"

         READ
         BoxC()
      ENDIF
      IF cDN == "D"
         nSrednjaNabavnaCijena := nZadnjaUlaznaNC
      ENDIF

   ENDIF

   RETURN nSrednjaNabavnaCijena


/*
       ako je nabavna cijena 0, ponuditi cijenu koja je roba.vpc / ( 1 + standardna_stopa_marze )
       npr. vpc=1, standarna_stopa_marze = 20%, nc=0.8
*/

FUNCTION korekcija_nabavna_cijena_0( nSrednjaNabavnaCijena )

   IF Abs( Round( nSrednjaNabavnaCijena, 4 ) ) <= 0 .AND. roba->vpc != 0
      nSrednjaNabavnaCijena := Round( roba->vpc / ( 1 + standardna_stopa_marze() / 100 ), 4 )
   ENDIF

   RETURN nSrednjaNabavnaCijena



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



/*
 *     Proracun veleprodajne marze
 */

FUNCTION Marza( fmarza )

   LOCAL SKol := 0, nPPP

   IF fmarza == NIL
      fMarza := " "
   ENDIF

   IF _nc == 0
      _nc := 9999
   ENDIF

   IF roba->tip $ "VKX"
      nPPP := 1 / ( 1 + tarifa->opp / 100 )
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
         _Marza := 100 * ( _VPC * nPPP / _NC - 1 )
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

   RETURN .T.



/*
 *     Fakticka veleprodajna cijena
 */

FUNCTION kalk_vpc_po_kartici( nVPC, cIdFirma, cMKonto, cIdRoba, dDatum )

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


   PushWA()


   // SET FILTER TO
   // nOrder:=indexord()
   // SET ORDER TO TAG "3" // idFirma+mkonto+idroba+dtos(datdok)
   // SEEK cseek + "X"
   // SKIP -1
   find_kalk_by_mkonto_idroba( cIdFirma, cMKonto, cIdRoba )


   DO WHILE !Bof() .AND. idfirma + mkonto + idroba == cIdFirma + cMKonto + cIdRoba

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

   RETURN .T.



/*
 *     Prati karticu magacina
 */

FUNCTION PratiKMag( cIdFirma, cIdKonto, cIdRoba )

   LOCAL nPom

   find_kalk_by_mkonto_idroba( cIdFirma, cIdKonto, cIdRoba )

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

   RETURN .T.




/* ObSetVPC(nNovaVrijednost)
 *     Obavezno setuj VPC
 */

FUNCTION ObSetVPC( nNovaVrijednost )

   LOCAL nArr := Select()
   LOCAL hRec
   PRIVATE cPom := "VPC"

   IF koncij->naz == "P2"
      cPom := "PLC"
   ELSEIF koncij->naz == "V2"
      cPom := "VPC2"
   ELSE
      cPom := "VPC"
   ENDIF

   SELECT roba
   hRec := dbf_get_rec()

   hRec[ Lower( cPom ) ] := nNovaVrijednost

   update_rec_server_and_dbf( "roba", hRec, 1, "FULL" )

   SELECT ( nArr )

   RETURN .T.




/* UzmiVPCSif(cMKonto,lKoncij)
 *     Za zadani magacinski konto daje odgovarajucu VPC iz sifrarnika robe
 */

FUNCTION UzmiVPCSif( cMKonto, lKoncij )

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



/*
 *     Proracun nabavne cijene za ulaznu kalkulaciju 10
 */

FUNCTION kalk_nabcj()


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

   RETURN .T.




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



/* KoncijVPC
 *     Daje odgovarajucu VPC iz sifrarnika robe
 */

FUNCTION KoncijVPC()

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




/* MMarz
 *     Preracunava iznos veleprodajne marze
 */

FUNCTION MMarza()

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




/* PrerRar
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



// Validacija u prilikom knjizenja (knjiz.prg) - VALID funkcija u get-u

// Koristi sljedece privatne varijable:
// nKols
// kalk_metoda_nc()
// _TBankTr - "X"  - ne provjeravaj - vrati .t.
// ---------------------------------------------
// Daje poruke:
// Nabavna cijena manja od 0 ??
// Ukupno na stanju samo XX robe !!

FUNCTION kalk_valid_kolicina_mag()

   IF ( ( _nc <= 0 ) .AND. !( _idvd $ "11#12#13#22" ) ) .OR. ( _fcj <= 0 .AND. _idvd $ "11#12#13#22" )
      // kod 11-ke se unosi fcj
      Msg( _idroba + " Nabavna cijena <= 0 ! STOP!" )
      error_bar( "kalk_mag", _mkonto + "/" + _idroba + " Nabavna cijena <= 0 !" )
      _ERROR := "1"
      automatska_obrada_error( .T. )
      RETURN .F.
   ENDIF

   IF roba->tip $ "UTY"; RETURN .T. ; ENDIF // usluge

   IF Empty( kalk_metoda_nc() ) .OR. _TBankTR == "X" // bez ograde
      RETURN .T.
   ENDIF

   IF nKolS < _Kolicina

      sumnjive_stavke_error()
      error_bar( "KA_" + _mkonto + "/" + _idroba, ;
         _mkonto + " / " + _idroba + "na stanju: " + AllTrim( Str( nKolS, 10, 4 ) ) + " treba " +  AllTrim( Str( _kolicina, 10, 4 ) ) )

   ENDIF

   RETURN .T.



/* V_RabatV
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
         hRec := dbf_get_rec()

         hRec[ Lower( cPom ) ] := _vpc
         update_rec_server_and_dbf( "roba", hRec, 1, "FULL" )

         SELECT kalk_pripr
         BoxC()

      ENDIF
   ENDIF

   IF roba->tip == "V"  // roba tarife
      nMarza := _VPC / ( 1 + _PORVT ) -_VPC * _RabatV / 100 -_NC
   ELSEIF roba->tip = "X"
      nMarza := _VPC * ( 1 -_RabatV / 100 ) -_NC - _MPCSAPP / ( 1 + _PORVT ) * _porvt
   ELSE
      nMarza := _VPC / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) -_NC
   ENDIF


   @ m_x + 15, m_y + 41  SAY "PC b.pdv.-RAB:"


   IF roba->tip == "V"
      @ m_x + 15, Col() + 1 SAY _Vpc / ( 1 + _PORVT ) -_VPC * _RabatV / 100 PICT picdem
   ELSEIF roba->tip == "X"
      @ m_x + 15, Col() + 1 SAY _Vpc * ( 1 -_RabatV / 100 ) - _MPCSAPP / ( 1 + _PORVT ) * _PORVT PICT picdem
   ELSE
      @ m_x + 15, Col() + 1 SAY _Vpc / ( 1 + _PORVT ) * ( 1 -_RabatV / 100 ) PICT picdem
   ENDIF

   ShowGets()

   RETURN .T.




/* ---------------------------------------------------------
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
*/


// ------------------------------------------------
// popup kod nabavne cijene
// ------------------------------------------------
FUNCTION p_nc_popup( cIdRoba )

   LOCAL nScan

   //nScan := AScan( aNC_ctrl, {| xVal| xVal[ 1 ] == cIdRoba } )

   //IF nScan <> 0

  //    nOdstupanje := Round( aNC_ctrl[ nScan, 5 ], 2 ) // prikazi odstupanje NC !
  //    MsgBeep( "Odstupanje u odnosu na zadnji ulaz je#" + AllTrim( Str( nOdstupanje ) ) + " %" )

   //ENDIF

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
   ? "- kontrolna tacka = " + AllTrim( Str( prag_odstupanja_nc_sumnjiv() ) ) + "%"
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
