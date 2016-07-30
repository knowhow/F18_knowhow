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


FUNCTION o_kalk_tabele_izvj()

   O_SIFK
   O_SIFV
   O_TARIFA
   O_ROBA
   o_koncij()
   O_KONTO
   O_PARTN
   o_kalk_doks()
   o_kalk()

   RETURN


FUNCTION Gen9999()

   IF !( gRadnoPodr == "9999" )
      // sezonsko kumulativno podrucje za zbirne izvjeçtaje
      MsgBeep( "Ova operacija se radi u 9999 podrucju" )
      RETURN
   ENDIF

   nG0 := nG1 := Year( Date() )
   Box( "#Generacija zbirne baze dokumenata", 5, 75 )
   @ m_x + 2, m_y + 2 SAY "Od sezone:" GET nG0 VALID nG0 > 0 .AND. nG1 >= nG0 PICT "9999"
   @ m_x + 3, m_y + 2 SAY "do sezone:" GET nG1 VALID nG1 > 0 .AND. nG1 >= nG0 PICT "9999"
   READ; ESC_BCR
   BoxC()

   // spaja se sve izuzev dokumenata 16 i 80 na dan 01.01.XX gdje XX oznacava
   // sve sezone izuzev pocetne
   // -----------------------------------------------------------------------

   my_close_all_dbf()

   RETURN .T.


/* KalkNaF(cidroba,nKols)
 *     Stanje zadanog artikla u FAKT
 */

FUNCTION KalkNaF( cidroba, nKols )

   SELECT ( F_FAKT )
   IF !Used(); O_FAKT; ENDIF

   SELECT fakt
   SET ORDER TO TAG "3" // fakt idroba
   nKols := 0
   SEEK cidroba
   DO WHILE !Eof() .AND. cidroba == idroba
      IF idtipdok = "0"  // ulaz
         nKols += kolicina
      ELSEIF idtipdok = "1"   // izlaz faktura
         IF !( serbr = "*" .AND. idtipdok == "10" ) // za fakture na osnovu otpremince ne ra~unaj izlaz
            nKols -= kolicina
         ENDIF
      ENDIF
      SKIP
   ENDDO
   SELECT kalk_pripr

   RETURN .T.





FUNCTION kalk_dokument_postoji( cFirma, cIdVd, cBroj, lSilent )

   LOCAL lExist := .F.
   LOCAL cWhere

   hb_default( @lSilent, .T. )

   cWhere := "idfirma = " + sql_quote( cFirma )
   cWhere += " AND idvd = " + sql_quote( cIdVd )
   cWhere += " AND brdok = " + sql_quote( cBroj )

   IF table_count( F18_PSQL_SCHEMA_DOT + "kalk_doks", cWhere ) > 0
      lExist := .T.
   ENDIF

   IF !lSilent .AND. !lExist
      MsgBeep( "Dokument " + Trim( cFirma ) + "-" + Trim( cIdVd ) + "-" + Trim( cBroj ) + " ne postoji !" )
   ENDIF

   RETURN lExist




/* VVT()
 *     Prikaz PPP i proracun marze za visokotarifnu robu
 */

FUNCTION VVT()

   @ m_x + 13, m_y + 2 SAY "PPP:"
   @ m_x + 13, Col() + 2 SAY tarifa->opp PICT "99.99%"
   IF roba->tip = "X"
      @ m_x + 13, Col() + 2 SAY roba->mpc / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 PICT picdem
      _marza := roba->mpc / ( 1 + tarifa->opp / 100 ) -_nc
   ELSE
      @ m_x + 13, Col() + 2 SAY _vpc / ( 1 + tarifa->opp / 100 ) * tarifa->opp / 100 PICT picdem
      _marza := _vpc / ( 1 + tarifa->opp / 100 ) -_nc
   ENDIF
   _tmarza := "A"

   RETURN .T.


/* DuplRoba()
 *     Obrada slucaja pojavljivanja duplog unosa robe u dokumentu
 */

FUNCTION DuplRoba()

/*
   LOCAL nRREC, fdupli := .F., dkolicina := 0, dfcj := 0
   PRIVATE GetList := {}


   // pojava robe vise puta unutar kalkulacije!!!
   IF ( ( roba->tip $ "UTY" ) .OR. Empty( gMetodaNC ) .OR. gMagacin == "1" )
      RETURN .T.
   ENDIF
   SELECT kalk_pripr
   SET ORDER TO TAG "3"
   nRRec := RecNo()
   SEEK _idfirma + _idvd + _brdok + _idroba
   fdupli := .F.
   dkolicina := _kolicina
   dfcj := _fcj
   DO WHILE !Eof() .AND. _idfirma + _idvd + _brdok + _idroba == idfirma + idvd + brdok + idroba
      IF Val( rbr ) <> nRbr .AND. ( nRRec <> RecNo() .OR. fnovi )
         Beep( 2 )
         // skocio je na donji zapis
         IF Pitanje(, "Artikal " + _idroba + " se pojavio vise puta unutar - spojiti ?", "N" ) == "D"
            fdupli := .T.
            dfcj := ( dfcj * dkolicina + fcj * kolicina ) / ( dkolicina + kolicina )
            dkolicina += kolicina
            my_delete()
         ELSE
            _ERROR := "1"
         ENDIF
      ENDIF
      SKIP
   ENDDO
   GO nRRec
   IF fdupli
      _kolicina := dkolicina
      _fcj := dfcj
   ENDIF
   SELECT kalk_pripr
   SET ORDER TO TAG "1"

   RETURN .T.
*/
   RETURN .T.


/* check_datum_posljednje_kalkulacije()
 *     Ispituje da li je datum zadnje promjene na zadanom magacinu i za zadani artikal noviji od one koja se unosi
 */

FUNCTION check_datum_posljednje_kalkulacije()

/*
   SELECT kalk
   --SET ORDER TO TAG "3"
   SEEK _idfirma + _mkonto + _idroba + Chr( 254 )
   SKIP -1
*/

   info_bar( "kalk_unos", "START chk datdok: " + _IdFirma + "/" + _MKonto + "/" + _IdRoba )
   find_kalk_by_mkonto_idroba( _IdFirma, _MKonto, _IdRoba )
   info_bar( "kalk_unos", "END chk datdok: " + _IdFirma + "/" + _MKonto + "/" + _IdRoba )
   GO BOTTOM

   IF _idfirma + _idkonto + _idroba == field->idfirma + field->mkonto + field->idroba .AND. _datdok < field->datdok
      error_bar( "KA_" + _idfirma + "-" + _idvd + "-" + _brdok, _mkonto + " / " + _idroba + " zadnji dokument: " + DToC( field->datdok ) )
      _ERROR := "1"
   ENDIF

   SELECT kalk_pripr

   RETURN .T.


/*
 *  Ispituje da li je datum zadnje promjene na zadanoj prodavnici i za zadani artikal noviji od one koja se unosi
 */

FUNCTION kalk_dat_poslj_promjene_prod()

   find_kalk_by_pkonto_idroba( _IdFirma, _IdKonto, _IdRoba )
   GO BOTTOM

   IF _datdok < field->datdok
      error_bar( "KA_" + _idfirma + "-" + _idkonto + "-" + _idroba, _idkonto + " / " + _idroba + " zadnji dokument: " + DToC( field->datdok ) )
      _ERROR := "1"
   ENDIF

   SELECT kalk_pripr

   RETURN .T.



/* kalk_sljedeci_broj(cidfirma,cIdvD,nMjesta)
 *     Sljedeci slobodan broj dokumenta za zadanu firmu i vrstu dokumenta
 */

FUNCTION kalk_sljedeci_broj( cIdfirma, cIdvD, nMjesta )

   LOCAL cReturn := "0"

   find_kalk_doks_za_tip( cIdFirma, cIdVd )
   GO BOTTOM
   IF field->idvd <> cIdVd
      cBrKalk := Space( 8 )
   ELSE
      cBrKalk := field->brdok
   ENDIF


   IF AllTrim( cReturn ) >= "99999"
      cReturn := PadR( novasifra( AllTrim( cReturn ) ), 5 )
   ELSE
      cReturn := UBrojDok( Val( Left( cReturn, 5 ) ) + 1, 5, Right( cReturn ) )
   ENDIF

   RETURN cReturn








/* MMarza2()
 *     Daje iznos maloprodajne marze
 */

FUNCTION MMarza2()

   IF TMarza2 == "%" .OR. Empty( tmarza2 )
      nMarza2 := kolicina * Marza2 / 100 * VPC
   ELSEIF TMarza2 == "A"
      nMarza2 := Marza2 * kolicina
   ELSEIF TMarza2 == "U"
      nMarza2 := Marza2
   ENDIF

   RETURN nMarza2





/* KnjizSt()
 *     Proracun knjiznog stanja za zadanu robu i prodavnicu
 */

FUNCTION KnjizSt()

   LOCAL nUlaz := nIzlaz := 0
   LOCAL nMPVU := nMPVI := nNVU := nNVI := 0
   LOCAL cIdRoba := _idroba
   LOCAL cIdfirma := _idfirma
   LOCAL cIdkonto := _idkonto
   LOCAL nRabat := 0

   SELECT roba
   HSEEK cIdRoba
   SELECT koncij
   HSEEK cIdKonto

   SELECT kalk

   PushWA()

   SET ORDER TO TAG "4"

   HSEEK cIdfirma + cIdKonto + cIdroba

   DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdroba == field->idfirma + field->pkonto + field->idroba

      IF _datdok < field->datdok
         // preskoci
         SKIP
         LOOP
      ENDIF

      IF roba->tip $ "UT"
         SKIP
         LOOP
      ENDIF

      IF field->pu_i == "1"
         nUlaz += field->kolicina - field->GKolicina - field->GKolicin2
         nMPVU += field->mpcsapp * field->kolicina
         nNVU += field->nc * field->kolicina

      ELSEIF field->pu_i == "5" .AND. !( field->idvd $ "12#13#22" )
         nIzlaz += field->kolicina
         nMPVI += field->mpcsapp * field->kolicina
         nNVI += field->nc * field->kolicina

      ELSEIF field->pu_i == "5" .AND. ( field->idvd $ "12#13#22" )
         // povrat
         nUlaz -= field->kolicina
         nMPVU -= field->mpcsapp * field->kolicina
         nNvu -= field->nc * field->kolicina

      ELSEIF field->pu_i == "3"
         // nivelacija
         nMPVU += field->mpcsapp * field->kolicina

      ELSEIF field->pu_i == "I"
         nIzlaz += field->gkolicin2
         nMPVI += field->mpcsapp * field->gkolicin2
         nNVI += field->nc * field->gkolicin2
      ENDIF

      SKIP

   ENDDO

   _gkolicina := nUlaz - nIzlaz
   _fcj := nMpvu - nMpvi

   // stanje mpvsapp

   IF Round( nUlaz - nIzlaz, 4 ) <> 0
      _mpcsapp := Round( ( nMPVU - nMPVI ) / ( nUlaz - nIzlaz ), 3 )
      _nc := Round( ( nNvu - nNvi ) / ( nUlaz - nIzlaz ), 3 )
   ELSE
      _mpcsapp := 0
   ENDIF

   PopWa()

   SELECT kalk_pripr

   RETURN

// -------------------------------------------------
// brisanje pripreme od do
// -------------------------------------------------
FUNCTION kalk_pripr_brisi_od_do()

   LOCAL _ret := .F.
   LOCAL _od := Space( 4 )
   LOCAL _do := Space( 4 )

   SELECT kalk_pripr
   GO TOP

   _od := PadR( field->rbr, 4 )

   Box(, 1, 60 )
   @ m_x + 1, m_y + 2 SAY8 "Briši stavke od" GET _od PICT "@S4"
   @ m_x + 1, Col() + 1 SAY "do" GET _do PICT "@S4"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN _ret
   ENDIF

   DO WHILE !Eof()
      IF AllTrim( field->rbr ) >= AllTrim( _od ) .AND. IF( AllTrim( _do ) <> "", AllTrim( field->rbr ) <= AllTrim( _do ), .T. )
         my_delete()
      ENDIF
      SKIP
   ENDDO

   my_dbf_pack()
   SELECT kalk_pripr
   GO TOP

   _ret := .T.

   RETURN _ret



// -------------------------------------------------------------
// Prenumerisanje stavki zadanog dokumenta u kalk_pripremi
// -------------------------------------------------------------
FUNCTION renumeracija_kalk_pripr( cDok, cIdvd, silent )

   LOCAL _rbr

   IF silent == NIL
      silent := .T.
   ENDIF

   IF !silent
      IF Pitanje(, "Renumerisati pripremu ?", "N" ) == "N"
         RETURN
      ENDIF
   ENDIF

   SELECT ( F_KALK_PRIPR )
   IF !Used()
      o_kalk_pripr()
   ENDIF

   SELECT kalk_pripr
   SET ORDER TO
   GO TOP

   _rbr := 0

   my_flock()
   DO WHILE !Eof()
      REPLACE field->rbr WITH RedniBroj( ++_rbr )
      SKIP
   ENDDO
   my_unlock()

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN



FUNCTION IspitajPrekid()

   Inkey()

   RETURN IF( LastKey() == 27, PrekSaEsc(), .T. )



// Kalkulacija stanja za karticu artikla u prodavnici
FUNCTION KaKaProd( nUlaz, nIzlaz, nMPV, nNV )

   IF pu_i == "1"
      nUlaz += kolicina - GKolicina - GKolicin2
      nMPV += mpcsapp * kolicina
      nNV += nc * kolicina
   ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
      nIzlaz += kolicina
      nMPV -= mpcsapp * kolicina
      nNV -= nc * kolicina
   ELSEIF pu_i == "I"
      nIzlaz += gkolicin2
      nMPV -= mpcsapp * gkolicin2
      nNV -= nc * gkolicin2
   ELSEIF pu_i == "5" .AND. ( idvd $ "12#13#22" )
      // povrat
      nUlaz -= kolicina
      nMPV -= mpcsapp * kolicina
      nNV -= nc * kolicina
   ELSEIF pu_i == "3"
      // nivelacija
      nMPV += mpcsapp * kolicina
   ENDIF

   RETURN



/* NCuMP(_idfirma,_idroba,_idkonto,nKolicina,dDatDok)
 *     Proracun stanja i nabavne vrijednosti za zadani artikal i prodavnicu
 */

FUNCTION NCuMP( _idfirma, _idroba, _idkonto, nKolicina, dDatDok )

   LOCAL nArr := Select()

   nKolS := 0
   nKolZN := 0
   nc1 := nc2 := 0
   dDatNab := CToD( "" )
   _kolicina := nKolicina
   _datdok   := dDatDok
   SELECT KALK
   PushWA()
   MsgO( "Računam stanje u prodavnici" )
   kalk_nabavna_prod( _idfirma, PadR( _idroba, Len( idroba ) ), _idkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
   MsgC()
   SELECT KALK
   PopWA()
   SELECT ( nArr )

   RETURN nc2




/* KalkTrUvoz()
 *     Proracun carine i ostalih troskova koji se javljaju pri uvozu
 *  \todo samo otvorena f-ja
 */

FUNCTION KalkTrUvoz()

   // {
   LOCAL nT1 := 0, nT2 := 0, nT3 := 0, nT4 := 0, nT5 := 0, CP := "999999999.999999999"
   Box( "#Unos troskova", 7, 75 )
   @ m_x + 2, m_y + 2 SAY c10T1 GET nT1 PICT CP
   @ m_x + 3, m_y + 2 SAY c10T2 GET nT2 PICT CP
   @ m_x + 4, m_y + 2 SAY c10T3 GET nT3 PICT CP
   @ m_x + 5, m_y + 2 SAY c10T4 GET nT4 PICT CP
   @ m_x + 6, m_y + 2 SAY c10T5 GET nT5 PICT CP
   READ
   BoxC()
   MsgBeep( "Opcija jos nije u funkciji jer je dorada u toku!" )
   CLOSERET
   // }


/* ObracunPorezaUvoz()
 *     Proracun poreza pri uvozu
 */

FUNCTION ObracunPorezaUvoz()

   // {
   LOCAL nTP, qqT1, qqT2, aUT1, aUT2

   o_kalk_pripr()

   IF !( kalk_pripr->idvd $ "10#81" )
      MsgBeep( "Ova opcija vrijedi samo za dokumente tipa 10 i 81 !" )
      CLOSERET
   ENDIF

   nTP := 5
   qqT1 := PadR( my_get_from_ini( "RasporedTroskova", "UslovPoTarifamaT1", "", KUMPATH ), 40 )
   qqT2 := PadR( my_get_from_ini( "RasporedTroskova", "UslovPoTarifamaT2", "", KUMPATH ), 40 )

   Box( "#Obracun poreza pri uvozu", 7, 75 )
   DO WHILE .T.
      @ m_x + 2, m_y + 2 SAY "Porez je u trosku br.(1-5)" GET nTP PICT "9" VALID nTP > 0 .AND. nTP < 6
      @ m_x + 3, m_y + 2 SAY "Uslov za sifre tarifa grupe 1 (20%)" GET qqT1 PICT "@!S30"
      @ m_x + 4, m_y + 2 SAY "Uslov za sifre tarifa grupe 2 (10%)" GET qqT2 PICT "@!S30"
      READ
      aUT1 := Parsiraj( qqT1, "idTarifa" )
      aUT2 := Parsiraj( qqT2, "idTarifa" )
      IF aUT1 <> NIL .AND. aUT2 <> nil
         EXIT
      ENDIF
   ENDDO
   BoxC()

   IF LastKey() <> K_ESC
      // proracun poreza
      SELECT kalk_pripr
      GO TOP
      DO WHILE !Eof()
         Scatter()
         PRIVATE cPom := ImePoljaTroska( nTP )

         IF gKalo == "1"
            skol := _kolicina - _gkolicina - _gkolicin2
         ELSE
            skol := _kolicina
         ENDIF

         if &aUT1
            _t&cPom := "U"
            _&cPom := skol * _nc * 0.2
         elseif &aUT2
            _t&cPom := "U"
            _&cPom := skol * _nc * 0.1
         ENDIF

         NabCj()
         my_rlock()
         Gather()
         my_unlock()
         SKIP 1
      ENDDO
   ENDIF

   CLOSERET

   RETURN


FUNCTION ImePoljaTroska( n )

   LOCAL aTros

   aTros := { "Prevoz", "BankTr", "SpedTr", "CarDaz", "ZavTr" }

   RETURN aTros[ n ]


/* KTroskovi()
 *     Proracun iznosa troskova pri unosu u kalk_pripremi
 */

FUNCTION KTroskovi()

   LOCAL Skol := 0, nPPP := 0

   IF gKalo == "1"
      Skol := Kolicina - GKolicina - GKolicin2
   ELSE
      Skol := Kolicina
   ENDIF
   IF roba->tip $ "VKX"
      nPPP := 1 / ( 1 + tarifa->opp / 100 )
      // if roba->tip="X"; nPPP:=nPPP*roba->mpc/vpc; endif
   ELSE
      nPPP := 1
   ENDIF

   IF TPrevoz == "%"
      nPrevoz := Prevoz / 100 * FCj2
   ELSEIF TPrevoz == "A"
      nPrevoz := Prevoz
   ELSEIF TPrevoz == "U"
      IF skol <> 0
         nPrevoz := Prevoz / SKol
      ELSE
         nPrevoz := 0
      ENDIF
   ELSE
      nPrevoz := 0
   ENDIF
   IF TCarDaz == "%"
      nCarDaz := CarDaz / 100 * FCj2
   ELSEIF TCarDaz == "A"
      nCarDaz := CarDaz
   ELSEIF TCarDaz == "U"
      IF skol <> 0
         nCarDaz := CarDaz / SKol
      ELSE
         nCarDaz := 0
      ENDIF
   ELSE
      nCarDaz := 0
   ENDIF
   IF TZavTr == "%"
      nZavTr := ZavTr / 100 * FCj2
   ELSEIF TZavTr == "A"
      nZavTr := ZavTr
   ELSEIF TZavTr == "U"
      IF skol <> 0
         nZavTr := ZavTr / SKol
      ELSE
         nZavTr := 0
      ENDIF
   ELSE
      nZavTr := 0
   ENDIF
   IF TBankTr == "%"
      nBankTr := BankTr / 100 * FCj2
   ELSEIF TBankTr == "A"
      nBankTr := BankTr
   ELSEIF TBankTr == "U"
      IF skol <> 0
         nBankTr := BankTr / SKol
      ELSE
         nBankTr := 0
      ENDIF
   ELSE
      nBankTr := 0
   ENDIF
   IF TSpedTr == "%"
      nSpedTr := SpedTr / 100 * FCj2
   ELSEIF TSpedTr == "A"
      nSpedTr := SpedTr
   ELSEIF TSpedTr == "U"
      IF skol <> 0
         nSpedTr := SpedTr / SKol
      ELSE
         nSpedTr := 0
      ENDIF
   ELSE
      nSpedTr := 0
   ENDIF

   IF IdVD $ "14#94#15"   // izlaz po vp
      IF roba->tip == "V"
         nMarza := VPC * nPPP - VPC * Rabatv / 100 -NC
      ELSEIF roba->tip == "X"
         nMarza := VPC * ( 1 -Rabatv / 100 ) -NC - mpcsapp * nPPP * tarifa->opp / 100
      ELSE
         nMarza := VPC * nPPP * ( 1 -Rabatv / 100 ) -NC
      ENDIF
   ELSEIF idvd == "24"  // usluge
      nMarza := marza
   ELSEIF idvd $ "11#12#13"
      nMarza := VPC * nPPP - FCJ
   ELSE
      IF roba->tip == "X"
         nMarza := VPC - NC - mpcsapp * nPPP * tarifa->opp / 100
      ELSE
         nMarza := VPC * nPPP - NC
      ENDIF
   ENDIF

   IF ( idvd $ "11#12#13" )
      IF ( roba->tip == "K" )
         nMarza2 := MPC - VPC * nPPP - nPrevoz
      ELSEIF ( roba->tip == "X" )
         MsgBeep( "nije odradjeno" )
      ELSE
         nMarza2 := MPC - VPC - nPrevoz
      ENDIF
   ELSEIF ( ( idvd $ "41#42#43#81" ) )
      IF ( roba->tip == "V" )
         nMarza2 := ( MPC - roba->VPC ) + roba->vpc * nPPP - NC
      ELSEIF ( roba->tip == "X" )
         MsgBeep( "nije odradjeno" )
      ELSE
         nMarza2 := MPC - NC
      ENDIF
   ELSE
      nMarza2 := MPC - VPC
   ENDIF

   RETURN






/* ima_u_kalk_kumulativ(cKljuc,cTag)
 *     Ispituje postojanje zadanog kljuca u zadanom indeksu kumulativa KALK
 */

FUNCTION ima_u_kalk_kumulativ( cKljuc, cTag )

   // {
   LOCAL lVrati := .F.
   LOCAL lUsed := .T.
   LOCAL nArr := Select()
   SELECT ( F_KALK )
   IF !Used()
      lUsed := .F.
      o_kalk()
   ELSE
      PushWA()
   ENDIF
   IF !Empty( IndexKey( Val( cTag ) + 1 ) )
      SET ORDER TO TAG ( cTag )
      SEEK cKljuc
      lVrati := Found()
   ENDIF
   IF !lUsed
      USE
   ELSE
      PopWA()
   ENDIF
   SELECT ( nArr )

   RETURN lVrati
// }



/* \fn UkupnoKolP(nTotalUlaz, nTotalIzlaz)
 *    Obracun kolicine za prodavnicu
 * \note funkciju staviti unutar petlje koja prolazi kroz kalk
 * \code
 *    nUlazKP:=0
 *    nIzlazKP:=0
 *    do while .t.
 *      SELECT KALK
 *      UkupnoKolP(@nUlazKP,@nIzlazKP)
 *      SKIP
 *    enddo
 *    ? nUlazKP, nIzlazKP
 * \endcode
 */

FUNCTION UkupnoKolP( nTotalUlaz, nTotalIzlaz )

   // {
   LOCAL cIdRoba
   LOCAL lUsedRoba

   cIdRoba := field->idRoba

   nSelect := Select()

   lUsedRoba := .T.
   Select( F_ROBA )
   IF !Used()
      lUsedRoba := .F.
      O_ROBA
   ELSE
      Select( F_ROBA )
   ENDIF
   SEEK cIdRoba

   SELECT ( nSelect )

   IF field->pu_i == "1"
      SumirajKolicinu( kolicina, 0, @nTotalUlaz, 0 )
   ELSEIF field->pu_i == "5"
      IF field->idvd $ "12#13"
         SumirajKolicinu( -kolicina, 0, @nTotalUlaz, 0 )
      ELSE
         SumirajKolicinu( 0, kolicina, 0, @nTotalIzlaz )
      ENDIF
   ELSEIF field->pu_i == "3"
      // nivelacija
   ELSEIF field->pu_i == "I"
      SumirajKolicinu( 0, gkolicin2, 0, @nTotalIzlaz )
   ENDIF

   RETURN
// }

/* UkupnoKolM(nTotalUlaz, nTotalIzlaz)
 *  \sa UkupnoKolP
 */

FUNCTION UkupnoKolM( nTotalUlaz, nTotalIzlaz )

   // {
   LOCAL cIdRoba
   LOCAL lUsedRoba

   cIdRoba := field->idRoba

   nSelect := Select()

   lUsedRoba := .T.
   Select( F_ROBA )
   IF !Used()
      lUsedRoba := .F.
      O_ROBA
   ELSE
      Select( F_ROBA )
   ENDIF
   SEEK cIdRoba

   SELECT ( nSelect )
   IF field->mu_i == "1"
      IF !( field->idVd $ "12#22#94" )
         SumirajKolicinu( field->kolicina - field->gKolicina - field->gKolicin2, 0, @nTotalUlaz, 0 )

      ELSE
         SumirajKolicinu( 0, -field->kolicina, 0, @nTotalIzlaz )
      ENDIF

   ELSEIF field->mu_i == "5"
      SumirajKolicinu( 0, field->kolicina, 0, @nTotalIzlaz )

   ELSEIF field->mu_i == "3"

   ELSEIF field->mu_i == "8"
      // sta je mu_i==8 ??
      SumirajKolicinu( -field->kolicina, -field->kolicina, @nTotUlaz, @nTotalIzlaz )
   ENDIF

   RETURN
// }


FUNCTION RptSeekRT()

   // {
   LOCAL nArea

   nArea := Select()
   SELECT ROBA
   HSEEK ( nArea )->IdRoba
   SELECT tarifa
   HSEEK ( nArea )->IdTarifa
   SELECT ( nArea )

   RETURN
// }


/* UzmiIzP(cSta)
 *     Uzmi iz parametara
 *   param: cSta - "KOL", "NV", "MPV", MPVBP"...
 */
FUNCTION UzmiIzP( cSta )

   // {
   LOCAL nVrati := 0, nArr := 0
   IF cSta == "KOL"
      IF pu_i == "1"
         nVrati := kolicina - GKolicina - GKolicin2
      ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
         nVrati := -kolicina
      ELSEIF pu_i == "I"
         nVrati := -gkolicin2
      ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )    // povrat
         nVrati := -kolicina
      ELSEIF pu_i == "3"    // nivelacija
      ENDIF
   ELSEIF cSta == "NV"
      IF pu_i == "1"
         nVrati := + nc * kolicina
      ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
         nVrati := -nc * kolicina
      ELSEIF pu_i == "I"
         nVrati := -nc * gkolicin2
      ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )    // povrat
         nVrati := -nc * kolicina
      ELSEIF pu_i == "3"    // nivelacija
      ENDIF
   ELSEIF cSta == "MPV"
      IF pu_i == "1"
         nVrati := + mpcsapp * kolicina
      ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
         nVrati := -mpcsapp * kolicina
      ELSEIF pu_i == "I"
         nVrati := -mpcsapp * gkolicin2
      ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )    // povrat
         nVrati := -mpcsapp * kolicina
      ELSEIF pu_i == "3"    // nivelacija
         nVrati := + mpcsapp * kolicina
      ENDIF
   ELSEIF cSta == "MPVBP"
      IF pu_i == "1"
         nVrati := + mpc * kolicina
      ELSEIF pu_i == "5"  .AND. !( idvd $ "12#13#22" )
         nVrati := -mpc * kolicina
      ELSEIF pu_i == "I"
         nArr := Select()
         SELECT TARIFA; HSEEK ( nArr )->IDTARIFA; VTPorezi()
         SELECT ( nArr )
         nVrati := -mpcsapp / ( ( 1 + _OPP ) * ( 1 + _PPP ) ) * gkolicin2
      ELSEIF pu_i == "5"  .AND. ( idvd $ "12#13#22" )    // povrat
         nVrati := -mpc * kolicina
      ELSEIF pu_i == "3"    // nivelacija
         nVrati := + mpc * kolicina
      ENDIF
   ENDIF

   RETURN nVrati
// }


FUNCTION Generisi11ku_iz10ke( cBrDok )

   // {
   LOCAL nArr
   nArr := Select()
   O_TARIFA
   o_koncij()
   O_ROBA
   o_kalk_pripr9()
   cOtpremnica := Space( 10 )
   cIdKonto := "1320   "
   nBrojac := 0
   Box(, 2, 50 )
   @ 1 + m_x, 2 + m_y SAY "Prod.konto zaduzuje: " GET cIdKonto VALID !Empty( cIdKonto )
   @ 2 + m_x, 2 + m_y SAY "Po otpremnici: " GET cOtpremnica
   READ
   BoxC()

   SELECT kalk_pripr
   GO TOP
   DO WHILE !Eof()
      aPorezi := {}
      fMarza := " "
      ++nBrojac
      cKonto := kalk_pripr->idKonto
      cRoba := kalk_pripr->idRoba
      cTarifa := kalk_pripr->idtarifa
      SELECT roba
      SEEK cRoba
      SELECT tarifa
      SEEK cTarifa
      SetAPorezi( @aPorezi )
      VTPorezi()
      SELECT kalk_pripr
      Scatter()
      SELECT kalk_pripr9
      APPEND BLANK
      _idvd := "11"
      _brDok := cBrDok
      _idKonto := cIdKonto
      _idKonto2 := cKonto
      _brFaktP := cOtpremnica
      _tPrevoz := "R"
      _tMarza := "A"
      _marza := _vpc / ( 1 + _PORVT ) -_fcj
      _tMarza2 := "A"
      _mpcsapp := UzmiMpcSif()
      VMPC( .F., fMarza )
      VMPCSaPP( .F., fMarza )
      _MU_I := "5"
      _PU_I := "1"
      _mKonto := cKonto
      _pKonto := cIdKonto
      Gather()
      SELECT kalk_pripr
      SKIP

   ENDDO

   SELECT ( nArr )

   MsgBeep( "Formirao dokument " + AllTrim( gFirma ) + "-11-" + AllTrim( cBrDok ) )

   RETURN
// }


FUNCTION Get11FromSmece( cBrDok )

   // {
   LOCAL nArr
   nArr := Select()

   o_kalk_pripr9()
   SELECT kalk_pripr9
   GO TOP
   DO WHILE !Eof()
      IF ( field->idvd == "11" .AND. field->brdok == cBrDok )
         Scatter()
         SELECT kalk_pripr
         APPEND BLANK
         Gather()
         SELECT kalk_pripr9
         my_delete()
         SKIP
      ELSE
         SKIP
      ENDIF
   ENDDO

   SELECT ( nArr )
   MsgBeep( "Asistentom obraditi dokument !" )

   RETURN .F.



FUNCTION Generisati11_ku()

   // {
   // daj mi vrstu dokumenta kalk_pripreme
   nTRecNo := RecNo()
   GO TOP
   cIdVD := kalk_pripr->idvd
   GO ( nTRecNo )
   // ako se ne radi o 10-ci nista
   IF ( cIdVD <> "10" )
      RETURN .F.
   ENDIF
   IF my_get_from_ini( "KALK", "AutoGen11", "N", KUMPATH ) == "D" .AND. Pitanje(, "Formirati 11-ku (D/N)?", "D" ) == "D"
      RETURN .T.
   ELSE
      RETURN .F.
   ENDIF

   RETURN


// ---------------------------------------------
// kopiraj set cijena iz jednog u drugi
// ---------------------------------------------
FUNCTION kopiraj_set_cijena()

   LOCAL _set_from := " "
   LOCAL _set_to := "1"
   LOCAL _tip := "M"
   LOCAL _tmp1, _tmp2, _rec
   LOCAL _tmp, _count, _i

   SET CURSOR ON

   Box(, 5, 60 )
   @ 1 + m_x, 2 + m_y SAY "Kopiranje seta cijena iz - u..."
   @ 3 + m_x, 3 + m_y SAY "Tip cijene: [V] VPC [M] MPC" GET _tip VALID _tip $ "VM" PICT "@!"
   @ 4 + m_x, 3 + m_y SAY "Kopiraj iz:" GET _set_from VALID _set_from $ " 123456789"
   @ 4 + m_x, Col() + 1 SAY "u:" GET _set_to VALID _set_to $ " 123456789"
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   // odredi sta ce se kopirati...
   DO CASE

      // ako se radi o MPC
   CASE _tip == "M"

      _tmp1 := "mpc" + AllTrim( _set_from )
      _tmp2 := "mpc" + AllTrim( _set_to )

      // ako se radi o VPC
   CASE _tip == "V"

      _tmp1 := "vpc" + AllTrim( _set_from )
      _tmp2 := "vpc" + AllTrim( _set_to )

   ENDCASE

   O_ROBA
   _count := RecCount()

   SELECT roba
   SET ORDER TO TAG "ID"
   GO TOP

   _i := 0

   Box(, 1, 60 )

   DO WHILE !Eof()

      ++ _i
      _rec := dbf_get_rec()
      // kopiraj cijenu...
      _rec[ _tmp2 ] := _rec[ _tmp1 ]

      _tmp := AllTrim( Str( _i, 12 ) ) + "/" + AllTrim( Str( _count, 12 ) )

      @ m_x + 1, m_y + 2 SAY PadR( "odradio: " + _tmp, 60 )

      update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

      SKIP

   ENDDO

   BoxC()

   RETURN .T.




// kopiraj stavke u pript tabelu iz KALK
FUNCTION cp_dok_pript( cIdFirma, cIdVd, cBrDok )

   // kreiraj pript
   cre_kalk_priprt()

   o_kalk_pript()
   o_kalk()

   SELECT kalk
   SET ORDER TO TAG "1"

   HSEEK cIdFirma + cIdVd + cBrDok

   IF Found()
      MsgO( "Kopiram dokument u pript..." )
      DO WHILE !Eof() .AND. ( kalk->( idfirma + idvd + brdok ) == cIdFirma + cIdVd + cBrDok )
         Scatter()
         SELECT pript
         APPEND BLANK
         Gather()
         SELECT kalk
         SKIP
      ENDDO
      MsgC()
   ELSE
      MsgBeep( "Dokument " + cIdFirma + "-" + cIdVd + "-" + AllTrim( cBrDok ) + " ne postoji !!!" )
      RETURN 0
   ENDIF

   RETURN 1



// --------------------------------------------------
// vraca oznaku PU_I za pojedini dokument prodavnice
// --------------------------------------------------
FUNCTION get_pu_i( cIdVd )

   LOCAL cRet := " "

   DO CASE
   CASE cIdVd $ "11#15#80#81"
      cRet := "1"
   CASE cIdVd $ "12#41#42#43"
      cRet := "5"
   CASE cIdVd == "19"
      cRet := "3"
   CASE cIdVd == "IP"
      cRet := "I"

   ENDCASE

   RETURN cRet


// --------------------------------------------------
// vraca oznaku MU_I za pojedini dokument magacina
// --------------------------------------------------
FUNCTION get_mu_i( cIdVd )

   LOCAL cRet := " "

   DO CASE
   CASE cIdVd $ "10#12#16#94"
      cRet := "1"
   CASE cIdVd $ "11#14#82#95#96#97"
      cRet := "5"
   CASE cIdVd == "15"
      cRet := "8"
   CASE cIdVd == "18"
      cRet := "3"
   CASE cIdVd == "IM"
      cRet := "I"

   ENDCASE

   RETURN cRet


// ------------------------------------------------------------
// da li je dokument u procesu
// provjerava na osnovu polja PU_I ili MU_I
// ------------------------------------------------------------
FUNCTION dok_u_procesu( cFirma, cIdVd, cBrDok )

   LOCAL nTArea := Select()
   LOCAL lRet := .F.

   SELECT kalk

   IF cIdVD $ "#80#81#41#42#43#12#19#IP"
      SET ORDER TO TAG "PU_I2"
   ELSE
      SET ORDER TO TAG "MU_I2"
   ENDIF

   GO TOP
   SEEK "P" + cFirma + cIdVd + cBRDok

   IF Found()
      lRet := .T.
   ENDIF

   SELECT kalk
   SET ORDER TO TAG "1"

   SELECT ( nTArea )

   RETURN lRet

// -----------------------------------------------------
// izvjestaj o dokumentima stavljenim na stanje
// -----------------------------------------------------
STATIC FUNCTION rpt_dok_na_stanju( aDoks )

   LOCAL i

   IF Len( aDoks ) == 0
      MsgBeep( "Nema novih dokumenata na stanju !" )
      RETURN
   ENDIF

   START PRINT CRET

   ? "Lista dokumenata stavljenih na stanje:"
   ? "--------------------------------------"
   ?

   FOR i := 1 TO Len( aDoks )
      ? aDoks[ i, 1 ], aDoks[ i, 2 ]
   NEXT

   ?

   FF
   ENDPRINT

   RETURN


// --------------------------------------------------------------
// da li je vezni tops dokument na stanju
//
// funkcija vraca nNaStanju
// 0 = nije na stanju
// 1 = na stanju je
// -1 = nije nesto podeseno u konciju
// 2 = nije prenesen u TOPS
// --------------------------------------------------------------
STATIC FUNCTION tops_dok_na_stanju( cFirma, cIdVd, cBrDok, cKonto )

   LOCAL nTArea := Select()
   LOCAL nNaStanju := 1
   LOCAL cTKPath := ""
   LOCAL cTSPath := ""
   LOCAL cTPM := ""

   SELECT koncij
   SET ORDER TO TAG "ID"
   HSEEK cKonto

   IF Found()
      cTKPath := AllTrim( field->kumtops )
      cTSPath := AllTrim( field->siftops )
      cTPm := field->idprodmjes
   ELSE
      SELECT ( nTArea )
      RETURN -1
   ENDIF

   AddBS( @cTKPath )
   AddBS( @cTSPath )

   // otvori kalk_doksRC i kalk_doks
   IF File( cTKPath + "DOKSRC.DBF" )
      SELECT ( 248 )
      USE ( cTKPath + "DOKSRC" ) ALIAS TDOKSRC
      SET ORDER TO TAG "2"
   ELSE
      SELECT ( nTArea )
      RETURN -1
   ENDIF
   IF File( cTKPath + "DOKS.DBF" )
      SELECT ( 249 )
      USE ( cTKPath + "DOKS" ) ALIAS TDOKS
      SET ORDER TO TAG "2"
   ELSE
      SELECT ( nTArea )
      RETURN -1
   ENDIF

   SELECT tdoksrc
   GO TOP
   SEEK PadR( "KALK", 10 ) + cFirma + cIdvd + cBrDok

   // pronadji dokument TOPS - vezni
   IF Found()

      cTBrDok := tdoksrc->brdok
      cTIdPos := tdoksrc->idfirma
      cTIdVd := tdoksrc->idvd
      dTDatum := tdoksrc->datdok

      SELECT tdoks
      SET ORDER TO TAG "1"
      GO TOP
      SEEK cTIdPos + cTIdVd + DToS( dTDatum ) + cTBrDok

      IF Found()
         IF AllTrim( tdoks->sto ) == "N"
            nNaStanju := 0
         ENDIF
      ENDIF

   ELSE
      nNaStanju := 2
   ENDIF

   SELECT ( 248 )
   USE

   SELECT ( 249 )
   USE

   SELECT ( nTArea )

   RETURN nNaStanju








// --------------------------------------------
// otvori pomocnu tabelu
// --------------------------------------------
STATIC FUNCTION o_p_tbl( cPath, cSezona, cT_sezona )

   IF cSezona = "RADP" .OR. cSezona == cT_sezona
      cSezona := ""
   ENDIF

   IF !Empty( cSezona )
      cSezona := cSezona + SLASH
   ENDIF

   SELECT ( 248 )
   USE ( cPath + cSezona + "KALK" ) ALIAS "kalk_s"
   SELECT ( 249 )
   USE ( cPath + cSezona + "DOKS" ) ALIAS "doks_s"

   RETURN

// ----------------------------------------------
// zatvori pomocne sezonske tabele
// ----------------------------------------------
STATIC FUNCTION c_p_tbl()

   SELECT ( 248 )
   USE
   SELECT ( 249 )
   USE

   RETURN
