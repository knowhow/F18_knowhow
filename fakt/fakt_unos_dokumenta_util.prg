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



STATIC slChanged := .F.


FUNCTION IzSifre( silent )

   LOCAL _pos
   LOCAL _sif := _idpartner
   LOCAL _tmp

   IF silent == NIL
      silent := .F.
   ENDIF

   IF Right( _sif, 1 ) = "." .AND. Len( _sif ) <= 7

      _pos := RAt( ".", _sif )
      _sif := Left( _sif, _pos - 1 )

      IF !silent
         P_Firma( PadR( _sif, 6 ) )
      ENDIF

      _idpartner := partn->id

   ENDIF

   IF gShSld == "D"
      g_box_stanje( PadR( _idpartner, 6 ), gFinKtoDug, gFinKtoPot )
   ENDIF

   RETURN  .T.




FUNCTION V_Rj()

   IF gDetPromRj == "D" .AND. gFirma <> _IdFirma
      Beep ( 3 )
      Msg ( "Mijenjate radnu jedinicu!#" )
   ENDIF

   RETURN .T.


FUNCTION V_Podbr()

   LOCAL fRet := .F., nTRec, nPrec, nPkolicina := 1, nPRabat := 0

   PRIVATE GetList := {}

   IF ( Left( _podbr, 1 ) $ " .0123456789" ) .AND. ( Right( _podbr, 1 ) $ " .0123456789" )
      fRet := .T.
   ENDIF

   IF Val( _podbr ) > 0
      _podbr := Str( Val( _podbr ), 2, 0 )
   ENDIF


   IF AllTrim( _podbr ) == "."
      _podbr := " ."
      cPRoba := ""  // proizvod sifra
      nPKolicina := _kolicina
      _idroba := Space( Len( _idroba ) )
      Box(, 5, 50 )
      @ m_x + 1, m_y + 2 SAY "Proizvod:" GET _idroba valid {|| Empty( _idroba ) .OR. P_roba( @_idroba ) } PICT "@!"
      READ
      IF !Empty( _idroba )
         @ m_x + 3, m_y + 2 SAY8 "količina        :" GET nPkolicina PICT pickol
         @ m_x + 4, m_y + 2 SAY "rabat %         :" GET nPRabat    PICT "999.999"
         @ m_x + 5, m_y + 2 SAY "Varijanta cijene:" GET cTipVPC
         READ
      ENDIF
      BoxC()
      IF !Empty( _idroba )
         _txt1 := PadR( roba->naz, 40 )
         nTRec := RecNo()
         GO TOP
         nTRbr := nRbr
         DO WHILE !Eof()
            skip; nPRec := RecNo(); SKIP -1
            IF nTrbr == Val( rbr ) .AND. AllTrim( podbr ) <> "."
               // pobrisi stare zapise
               my_delete()
            ENDIF
            GO nPrec
         ENDDO
         SELECT sast
         cPRoba := _idroba
         cptxt1 := _txt1
         SEEK cPRoba
         nPbr := 0
         DO WHILE !Eof() .AND. cPRoba == id
            SELECT roba
            HSEEK sast->id2  // pozicioniraj se na materijal
            SELECT fakt_pripr
            APPEND ncnl
            my_flock()
            _rbr := Str( nTrbr, 3, 0 )
            _podbr := Str( ++nPbr, 2, 0 )
            _idroba := sast->id2
            _kolicina := sast->kolicina * npkolicina
            _rabat := nPRabat
            fakt_setuj_cijenu( cTipVPC )

            IF roba->tip == "U"
               _txt1 := Trim( Left( roba->naz, 40 ) )
            ELSE
               _txt1 := ""
            ENDIF
            IF _podbr == " ." .OR.  roba->tip = "U"
               _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 ) + Chr( 16 ) + _txt2 + Chr( 17 ) + ;
                  Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
                  Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
                  Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
                  Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
                  Chr( 16 ) + _BrNar + Chr( 17 ) + ;
                  Chr( 16 ) + DToC( _DatPl ) + Chr( 17 )
            ENDIF
            Gather()
            my_unlock()
            SELECT sast
            SKIP
         ENDDO
         SELECT fakt_pripr
         GO nTRec
         _podbr := " ."
         _cijena := 0
         _idroba := cPRoba
         _kolicina := npkolicina
         _txt1 := cptxt1
      ENDIF
      _txt1 := PadR( _txt1, 40 )
      _porez := _rabat := 0
      IF Empty( cPRoba )
         _idroba := ""
         _Cijena := 0
      ENDIF
      _SerBr := ""
   ENDIF

   RETURN fRet



FUNCTION fakt_setuj_cijenu( tip_cijene )

   LOCAL _rj := .F.
   LOCAL _tmp

   SELECT ( F_RJ )
   IF Used()
      _rj := .T.
      HSEEK _idfirma
   ENDIF

   SELECT roba

   IF _idtipdok == "13" .AND. ( gVar13 == "2" .OR. glCij13Mpc ) .OR. _idtipdok == "19"

      _tmp := "mpc"

      IF g13dcj <> "1"
         _tmp += g13dcij
      ENDIF

      _cijena := roba->&_tmp

   ELSEIF _rj .AND. rj->tip = "M"

      _cijena := fakt_mpc_iz_sifrarnika()

   ELSEIF _idtipdok $ "11#15#27"

      IF gMP == "1"
         _cijena := roba->mpc
      ELSEIF gMP == "2"
         _cijena := Round( roba->vpc * ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 ), 2 )
      ELSEIF gMP == "3"
         _cijena := roba->mpc2
      ELSEIF gMP == "4"
         _cijena := roba->mpc3
         // ELSEIF gMP == "5"
         // _cijena := roba->mpc4
         // ELSEIF gMP == "6"
         // _cijena := roba->mpc5
         // ELSEIF gMP == "7"
         // _cijena := roba->mpc6
      ENDIF

   ELSE

      IF tip_cijene == "1"
         _cijena := roba->vpc
      ELSEIF FieldPos( "vpc2" ) <> 0
         IF gVarC == "1"
            _cijena := roba->vpc2
         ELSEIF gVarc == "2"
            _cijena := roba->vpc
            IF _cijena <> 0
               _rabat := ( roba->vpc - roba->vpc2 ) / _cijena * 100
            ENDIF
         ELSEIF gVarc == "3"
            _cijena := roba->nc
         ENDIF
      ELSE
         _cijena := 0
      ENDIF
   ENDIF

   SELECT fakt_pripr

   RETURN



FUNCTION V_Kolicina( tip_vpc )

   LOCAL cRjTip
   LOCAL nUl := 0
   LOCAL nIzl := 0
   LOCAL nRezerv := 0
   LOCAL nRevers := 0

   IF _kolicina == 0
      RETURN .F.
   ENDIF

   IF JeStorno10()
      _kolicina := - Abs( _kolicina )
   ENDIF

   IF _podbr <> " ."

      SELECT rj
      HSEEK _idfirma

      cRjTip := rj->tip

      NSRNPIdRoba( _IDROBA )

      SELECT ROBA

      IF !( roba->tip = "U" )
         IF _idtipdok == "13" .AND. ( gVar13 == "2" .OR. glCij13Mpc ) .AND. gVarNum == "1"
            IF gVar13 == "2" .AND. _idtipdok == "13"
               _cijena := fakt_mpc_iz_sifrarnika()
            ELSE
               // IF g13dcij == "6"
               // _cijena := MPC6
               // ELSEIF g13dcij == "5"
               // _cijena := MPC5
               IF g13dcij == "4"
                  _cijena := MPC4
               ELSEIF g13dcij == "3"
                  _cijena := MPC3
               ELSEIF g13dcij == "2"
                  _cijena := MPC2
               ELSE
                  _cijena := MPC
               ENDIF
            ENDIF
         ELSEIF _idtipdok == "13" .AND. ( gVar13 == "2" .OR. glCij13Mpc ) .AND. gVarNum == "2"
            // IF g13dcij == "6"
            // _cijena := MPC6
            // ELSEIF g13dcij == "5"
            // _cijena := MPC5
            IF g13dcij == "4"
               _cijena := MPC4
            ELSEIF g13dcij == "3"
               _cijena := MPC3
            ELSEIF g13dcij == "2"
               _cijena := MPC2
            ELSE
               _cijena := MPC
            ENDIF
         ELSEIF cRjtip = "M"
            _cijena := fakt_mpc_iz_sifrarnika()

         ELSEIF _idtipdok $ "11#15#27"

            IF gMP == "1"
               _Cijena := MPC
            ELSEIF gMP == "2"
               _Cijena := Round( VPC * ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 ), 2 )
            ELSEIF gMP == "3"
               _Cijena := MPC2
            ELSEIF gMP == "4"
               _Cijena := MPC3
            ELSEIF gMP == "5"
               _Cijena := MPC4
               // ELSEIF gMP == "6"
               // _Cijena := MPC5
               // ELSEIF gMP == "7"
               // _Cijena := MPC6
            ENDIF

         ELSEIF _idtipdok == "25" .AND. _cijena <> 0
         ELSEIF cRjTip = "V" .AND. _idTipDok $ "10#20"
            _cijena := fakt_vpc_iz_sifrarnika()

         ELSE
            IF tip_vpc == "1"
               _Cijena := vpc
            ELSEIF FieldPos( "vpc2" ) <> 0
               IF gVarC == "1"
                  _Cijena := vpc2
               ELSEIF gVarc == "2"
                  _Cijena := vpc
                  IF vpc <> 0
                     _Rabat := ( vpc - vpc2 ) / vpc * 100
                  ENDIF
               ELSEIF gVarc == "3"
                  _Cijena := nc
               ENDIF
            ELSE
               _Cijena := 0
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   SELECT fakt
   SET ORDER TO TAG "3"

   lBezMinusa := .F.

   IF !( roba->tip = "U" ) .AND. !Empty( _IdRoba ) .AND.  Left( _idtipdok, 1 ) $ "12" .AND. ( gPratiK == "D" .OR. lBezMinusa = .T. ) .AND. !( Left( _idtipdok, 1 ) == "1" .AND. Left( _serbr, 1 ) = "*" )

      MsgO( "Izračunavam trenutno stanje ..." )

      SEEK _idroba

      nUl := 0
      nIzl := 0
      nRezerv := 0
      nRevers := 0

      DO WHILE !Eof()  .AND. roba->id == IdRoba

         IF fakt->IdFirma <> _IdFirma
            SKIP
            LOOP
         ENDIF

         IF idtipdok = "0"
            nUl  += kolicina
         ELSEIF idtipdok = "1"
            IF !( Left( serbr, 1 ) == "*" .AND. idtipdok == "10" )
               nIzl += kolicina
            ENDIF
         ELSEIF idtipdok $ "20#27"
            IF serbr = "*"
               nRezerv += kolicina
            ENDIF
         ELSEIF idtipdok == "21"
            nRevers += kolicina
         ENDIF
         SKIP
      ENDDO

      MsgC()

      IF ( ( nUl - nIzl - nRevers - nRezerv - _kolicina ) < 0 )

         fakt_box_stanje( { { _IdFirma, nUl, nIzl, nRevers, nRezerv } }, _idroba )

         IF _idtipdok = "1" .AND. lBezMinusa = .T.
            SELECT fakt_pripr
            RETURN .F.
         ENDIF

      ENDIF
   ENDIF

   SELECT fakt_pripr

   IF _idtipdok == "26" .AND. glDistrib .AND. !UGenNar()
      RETURN .F.
   ENDIF

   RETURN .T.




FUNCTION W_Roba()

   PRIVATE Getlist := {}

   IF _podbr == " ."
      @ m_x + 15, m_y + 2  SAY "Roba     " GET _txt1 PICT "@!"
      READ
      RETURN .F.
   ELSE
      RETURN .T.
   ENDIF

   RETURN




FUNCTION V_Roba( lPrikTar )

   LOCAL cPom
   LOCAL nArr
   PRIVATE cVarIDROBA

   cVarIDROBA := "_IDROBA"

   IF lPrikTar == nil
      lPrikTar := .T.
   ENDIF

   IF Right( Trim ( &cVarIdRoba ), 2 ) = "--"
      cPom := PadR( Left( &cVarIdRoba, Len( Trim( &cVarIdRoba ) ) -2 ), Len( &cVarIdRoba ) )
      SELECT roba
      SEEK cPom
      IF Found()
         FaktStanje( roba->id )    // prelistaj kalkulacije
         &cVarIdRoba := cPom
      ENDIF
   ENDIF

   P_Roba( @_Idroba, nil, nil, gArtCDX )

   SELECT roba
   SELECT fakt_pripr

   SELECT tarifa
   SEEK roba->idtarifa

   IF lPrikTar
      @ m_x + 16, m_y + 28 SAY "TBr: "
      ?? roba->idtarifa, "PDV", Str( tarifa->opp, 7, 2 ) + "%"
      IF _IdTipdok == "13"
         IF IsPDV()
            @ m_X + 18, m_y + 47 SAY "MPC.s.PDV sif:"
         ELSE
            @ m_X + 18, m_y + 47 SAY "MPC u sif:"
         ENDIF
         ?? Str( roba->mpc, 8, 2 )
      ENDIF
   ENDIF

   IF gRabIzRobe == "D"
      _rabat := roba->n1
   ENDIF

   SELECT fakt_pripr

   RETURN .T.


FUNCTION V_Porez()

   LOCAL nPor

   IF _porez <> 0
      IF roba->tip = "U"
         nPor := tarifa->ppp
      ELSE
         nPor := tarifa->opp
      ENDIF
      IF nPor <> _Porez
         Beep( 2 )
         Msg( "Roba pripada tarifnom stavu " + roba->idtarifa + "#kod koga je porez " + Str( nPor, 5, 2 ) )
      ENDIF
   ENDIF

   RETURN .T.




FUNCTION w_brotp( novi )

   IF novi
      _datotp := _datdok
      _datpl := _datdok
   ENDIF

   RETURN .T.



FUNCTION V_Rabat( tip_rabata )

   IF tip_rabata $ " U"

      IF _cijena * _kolicina <> 0
         _rabat := _rabat * 100 / ( _cijena * _kolicina )
      ELSE
         _rabat := 0
      ENDIF

   ELSEIF tip_rabata = "A"

      IF _cijena <> 0
         _rabat := _rabat * 100 / _cijena
      ELSE
         _rabat := 0
      ENDIF

   ELSEIF tip_rabata == "C"

      IF _cijena <> 0
         _rabat := ( _cijena - _rabat ) / _cijena * 100
      ELSE
         _rabat := 0
      ENDIF

   ELSEIF tip_rabata == "I"

      IF _kolicina * _cijena <> 0
         _rabat := ( _kolicina * _cijena - _rabat ) / ( _kolicina * _cijena ) * 100
      ELSE
         _rabat := 0
      ENDIF

   ENDIF

   IF ( _rabat > 99 .OR. _rabat < 0 )
      Beep( 2 )
      Msg( "Rabat ne može biti > 99% ili < 0%", 6 )
      _rabat := 0
   ENDIF

   IF _idtipdok $ "11#15#27"
      _porez := 0
   ELSE
      IF roba->tip == "V"
         _porez := 0
      ENDIF
   ENDIF

   set_cijena( _idtipdok, _idroba, _cijena, _rabat )

   ShowGets()

   RETURN .T.




FUNCTION UzorTxt()

   LOCAL cId := "  "
   LOCAL _user_name

   IF _IdTipDok $ "10#20" .AND. IsIno( _IdPartner )
      InoKlauzula()
      IF Empty( AllTrim( _txt2 ) )
         cId := "IN"
      ENDIF
   ENDIF

   IF IsPdv() .AND. _IdTipDok == "12" .AND. IsProfil( _IdPartner, "KMS" )
      KmsKlauzula()
      IF Empty( AllTrim( _txt2 ) )
         cId := "KS"
      ENDIF
   ENDIF

   IF ( nRbr == 1 .AND. Val( _podbr ) < 1 )

      Box(, 9, 75 )

      @ m_x + 1, m_Y + 1  SAY "Uzorak teksta (<c-W> za kraj unosa teksta):"  GET cId PICT "@!"
      READ

      IF LastKey() <> K_ESC .AND. !Empty( cId )

         P_Ftxt( @cId )

         SELECT ftxt
         SEEK cId

         SELECT fakt_pripr

         _txt2 := Trim( ftxt->naz )

         _user_name := AllTrim( GetFullUserName( GetUserID() ) )

         IF !Empty( _user_name ) .AND. _user_name <> "?user?"
            _txt2 += " Dokument izradio: " + _user_name
         ENDIF

         SELECT fakt_pripr

         IF glDistrib .AND. _IdTipdok == "26"
            IF cId $ ";"
               _k2 := "OPOR"
            ELSE
               _k2 := ""
            ENDIF
         ENDIF

      ENDIF

      SetColor( gColorInvert  )

      PRIVATE fUMemu := .T.

      _txt2 := MemoEdit( _txt2, m_x + 3, m_y + 1, m_x + 9, m_y + 76 )

      fUMemu := NIL

      SetColor( Normal )

      BoxC()

   ENDIF

   RETURN



// -------------------------------------------------
// uzorak teksta na kraju fakture
// verzija sa listom...
// -------------------------------------------------
FUNCTION UzorTxt2( cList, redni_broj )

   LOCAL cId := "  "
   LOCAL cU_txt
   LOCAL aList := {}
   LOCAL i
   LOCAL nCount := 1

   IF cList == nil
      cList := ""
   ENDIF

   cList := AllTrim( cList )

   IF !Empty( cList )
      IF Empty( _txt2 )
         IF Pitanje(, "Dokument sadrži txt listu, koristiti je ?", "D" ) == "N"
            cList := ""
         ENDIF
         aList := TokToNiz( cList, ";" )
      ENDIF
   ENDIF

   IF IsPdv() .AND. _IdTipDok $ "10#20" .AND. IsIno( _IdPartner )
      InoKlauzula()
      IF Empty( AllTrim( _txt2 ) )
         cId := "IN"
         AAdd( aList, cId )
      ENDIF
   ENDIF

   IF IsPdv() .AND. _IdTipDok == "12" .AND. IsProfil( _IdPartner, "KMS" )
      KmsKlauzula()
      IF Empty( AllTrim( _txt2 ) )
         cId := "KS"
         AAdd( aList, cId )
      ENDIF
   ENDIF

   IF !Empty( cList )
      FOR i := 1 TO Len( aList )
         cU_txt := aList[ i ]
         _add_to_txt( cU_txt, nCount, .T. )
         cId := "MX"
         ++ nCount
      NEXT
   ENDIF

   IF ( redni_broj == 1 .AND. Val( _podbr ) < 1 )

      Box(, 11, 75 )

      DO WHILE .T.

         @ m_x + 1, m_y + 1 SAY8 "Odaberi uzorak teksta iz šifrarnika:" ;
            GET cId PICT "@!"

         @ m_x + 11, m_y + 1 SAY8 "<c+W> dodaj novi ili snimi i izađi <ESC> poništi"

         READ

         IF LastKey() == K_ESC
            EXIT
         ENDIF

         IF LastKey() <> K_ESC .AND. !Empty( cId )
            IF cId <> "MX"
               P_Ftxt( @cId )
               _add_to_txt( cId, nCount, .T. )
               ++ nCount
               cId := "  "
            ENDIF
         ENDIF

         SetColor( gColorInvert  )
         PRIVATE fUMemu := .T.

         _txt2 := MemoEdit( _txt2, m_x + 3, m_y + 1, m_x + 9, m_y + 76 )

         fUMemu := NIL
         SetColor( normal )

         IF LastKey() == K_ESC
            EXIT
         ENDIF

         IF LastKey() == K_CTRL_W
            IF Pitanje(, "Nastaviti sa unosom teksta ? (D/N)", "N" ) == "N"
               EXIT
            ENDIF
         ENDIF

      ENDDO
      BoxC()
   ENDIF

   RETURN



// ---------------------------------------------------------
// dodaj tekst u _txt2
// ---------------------------------------------------------
FUNCTION _add_to_txt( cId_txt, nCount, lAppend )

   LOCAL cTmp
   LOCAL _user_name

   IF lAppend == nil
      lAppend := .F.
   ENDIF
   IF nCount == nil
      nCount := 1
   ENDIF

   // prazan tekst - ne radi nista
   IF Empty( cId_Txt )
      RETURN
   ENDIF

   SELECT ftxt
   SEEK cId_txt
   SELECT fakt_pripr

   IF lAppend == .F.
      _txt2 := Trim( ftxt->naz )
   ELSE
      cTmp := ""

      IF nCount > 1
         cTmp += Chr( 13 ) + Chr( 10 )
      ENDIF

      cTmp += Trim( ftxt->naz )

      _txt2 := _txt2 + cTmp
   ENDIF

   IF nCount = 1
      _user_name := AllTrim( GetFullUserName( GetUserID() ) )
      IF !Empty( _user_name ) .AND. _user_name <> "?user?"
         _txt2 += " Dokument izradio: " + _user_name
      ENDIF
   ENDIF

   RETURN


// ----------------------------
// ino klauzula
// ----------------------------
FUNCTION InoKlauzula()

   LOCAL _rec

   PushWA()

   SELECT FTXT
   SEEK "IN"

   IF !Found()


      APPEND BLANK
      _rec := dbf_get_rec()

      _rec[ "id" ] := "IN"
      _rec[ "naz" ] := "Porezno oslobadjanje na osnovu (nulta stopa) na osnovu clana 27. stav 1. tacka 1. ZPDV - izvoz dobara iz BIH"

      update_rec_server_and_dbf( "ftxt", _rec, 1, "FULL" )

   ENDIF

   PopWa()

   RETURN


// ----------------------------
// komision klauzula
// ----------------------------
FUNCTION KmsKlauzula()

   LOCAL _rec

   PushWA()

   SELECT FTXT
   SEEK "KS"

   IF !Found()

      APPEND BLANK
      _rec := dbf_get_rec()

      _rec[ "id" ] := "KS"
      _rec[ "naz" ] := "Dostava nije oporeziva, na osnovu Pravilnika o primjeni Zakona o PDV-u" + Chr( 13 ) + Chr( 10 ) + "clan 6. tacka 3."

      update_rec_server_and_dbf( "ftxt", _rec, 1, "FULL" )



   ENDIF

   PopWa()

   RETURN


// -------------------------------------------------------
// usluga na unosu dokumenta
// -------------------------------------------------------
FUNCTION artikal_kao_usluga( fNovi )

   PRIVATE GetList := {}

   IF !( roba->tip = "U" )
      DevPos( m_x + 15, m_y + 25 )
      ?? Space( 40 )
      DevPos( m_x + 15, m_y + 25 )

      ?? Trim( Left( roba->naz, 40 ) ), "(" + roba->jmj + ")"
   ENDIF

   IF roba->tip $ "UT" .AND. fnovi
      _kolicina := 1
   ENDIF

   IF roba->tip == "U"

      _txt1 := PadR( iif( fNovi, roba->naz, _txt1 ), 320 )

      IF fNovi
         _cijena := roba->vpc
      ENDIF

      _porez := 0

      @ Row() - 1, m_y + 25 SAY "opis usl.:" GET _txt1 PICT "@S50"

      READ

      _txt1 := Trim( _txt1 )

   ELSE

      _txt1 := ""

   ENDIF

   RETURN .T.


// -------------------------------------------------
// provjerava duplu stavku na unosu
// -------------------------------------------------
FUNCTION NijeDupla( fNovi )

   LOCAL nEntBK, ibk, uEntBK
   LOCAL nPrevRec

   // ako se radi o stornu fakture -> preuzimamo rabat i porez iz fakture
   IF JeStorno10()
      RabPor10()
   ENDIF

   SELECT fakt_pripr

   nPrevRec := RecNo()

   LOCATE FOR idfirma + idtipdok + brdok + idroba == _idfirma + _idtipdok + _brdok + _idroba .AND. ( RecNo() <> nPrevrec .OR. fnovi )

   IF Found ()
      IF !( roba->tip $ "UT" )
         Beep ( 2 )
         Msg ( "Roba se već nalazi na dokumentu, stavka " + AllTrim ( fakt_pripr->rbr ), 30 )
      ENDIF
   ENDIF

   GO nPrevRec

   RETURN ( .T. )




/*! \fn Prepak(cIdRoba,cPako,nPak,nKom,nKol,lKolUPak)
 *  \brief Preracunavanje paketa i komada ...
 *  \param cIdRoba  - sifra artikla
 *  \param nPak     - broj paketa/kartona
 *  \param nKom     - broj komada u ostatku (dijelu paketa/kartona)
 *  \param nKol     - ukupan broj komada
 *  \param nKOLuPAK - .t. -> preracunaj pakete (nPak,nKom) .f. -> preracunaj komade (nKol)
 */

FUNCTION Prepak( cIdRoba, cPako, nPak, nKom, nKol, lKolUPak )

   LOCAL lVrati := .F., nArr := Select(), aNaz := {}, cKar := "AMB ", nKO := 1, n_Pos := 0

   IF lKOLuPAK == NIL; lKOLuPAK := .T. ; ENDIF
   SELECT SIFV
   SET ORDER TO TAG "ID"
   HSEEK "ROBA    " + cKar + PadR( cIdRoba, 15 )
   DO WHILE !Eof() .AND. id + oznaka + idsif == "ROBA    " + cKar + PadR( cIdRoba, 15 )

      IF !Empty( naz )
         AAdd( aNaz, naz )
      ENDIF
      SKIP 1

   ENDDO

   IF Len( aNaz ) > 0
      nOpc  := 1  // za sad ne uvodim meni
      n_Pos := At( "_", aNaz[ nOpc ] )
      cPako := "(" + AllTrim( Left( aNaz[ nOpc ], n_Pos - 1 ) ) + ")"
      nKO   := Val( AllTrim( SubStr( aNaz[ nOpc ], n_Pos + 1 ) ) )
      IF nKO <> 0
         IF lKOLuPAK
            nPak := Int( nKol / nKO )
            nKom := nKol - nPak * nKO
         ELSE
            nKol := nPak * nKO + nKom
         ENDIF
      ENDIF
      lVrati := .T.
   ELSEIF lKOLuPAK
      nPak := 0
      nKom := nKol
   ENDIF
   SELECT ( nArr )

   RETURN lVrati



/*! \fn UGenNar()
 *  \brief U Generalnoj Narudzbi
 */

FUNCTION UGenNar()

   LOCAL lVrati := .T., nArr := Select(), nIsporuceno, nNaruceno, dNajstariji := CToD( "" )

   SELECT ( F_UGOV )
   IF !Used()
      O_UGOV
   ENDIF
   SET ORDER TO TAG "1"
   HSEEK "D" + "G" + _idpartner
   IF Found()
      SELECT ( F_RUGOV )
      IF !Used()
         O_RUGOV
      ENDIF
      SET ORDER TO TAG "ID"
      SELECT UGOV
      nNaruceno := 0
      // izracunajmo ukupnu narucenu kolicinu i utvrdimo datum najstarije
      // / narudzbe
      DO WHILE !Eof() .AND. aktivan + vrsta + idpartner == "D" + "G" + _idpartner
         SELECT RUGOV
         HSEEK UGOV->id + _idroba
         IF Found()
            IF Empty( dNajstariji )
               dNajstariji := UGOV->datod
            ELSE
               dNajstariji := Min( UGOV->datod, dNajstariji )
            ENDIF
            nNaruceno += kolicina
         ENDIF
         SELECT UGOV
         SKIP 1
      ENDDO
      // izracunati dosadasnju isporuku (nIsporuceno)
      nIsporuceno := 0
      SELECT FAKT
      SET ORDER TO TAG "6"
      // sabiram sve isporuke od datuma vazenja najstarijeg ugovora do danas
      SEEK _idfirma + _idpartner + _idroba + "10" + DToS( dNajstariji )
      DO WHILE !Eof() .AND. idfirma + idpartner + idroba + idtipdok == ;
            _idfirma + _idpartner + _idroba + "10"
         nIsporuceno += kolicina
         SKIP 1
      ENDDO
      IF _kolicina + nIsporuceno > nNaruceno
         lVrati := .F.
         MsgBeep( "Količina: " + AllTrim( TRANS( _kolicina, PicKol ) ) + ". Naručeno: " + AllTrim( TRANS( nNaruceno, PicKol ) ) + ". Dosad isporuceno: " + AllTrim( TRANS( nIsporuceno, PicKol ) ) + ". #" + ;
            "Za ovoliku isporuku artikla morate imati novu generalnu narudžbenicu!" )
      ENDIF
   ENDIF
   SELECT ( nArr )

   RETURN lVrati



FUNCTION v_pretvori( cPretvori, cDinDem, dDatDok, nCijena )

   IF !( cPretvori $ "DN" )
      MsgBeep( "preračunati cijenu u valutu dokumenta " + cDinDem + " ##(D)a ili (N)e ?" )
      RETURN .F.
   ENDIF

   IF cPretvori == "D"
      nCijena := nCijena * OmjerVal( ValBazna(), cDinDem, dDatDok )
      cPretvori := "N"
   ENDIF

   ShowGets()

   RETURN .T.




// ------------------------------------------------
// setuje cijenu i rabat u sifrarniku robe
// ------------------------------------------------
FUNCTION set_cijena( cIdTipDok, cIdRoba, nCijena, nRabat )

   LOCAL nTArea := Select()
   LOCAL lFill := .F.
   LOCAL _vars

   SELECT roba
   GO TOP
   SEEK cIdRoba

   IF Found()

      // provjeri da li je cijena ista ?
      _vars := dbf_get_rec()

      IF cIdTipDok $ "#10#01#12#20#" .AND. nCijena <> 0
         IF field->vpc <> nCijena .AND. ;
               Pitanje(, "Postaviti novu VPC u šifrarnik ?", "N" ) == "D"
            _vars[ "vpc" ] := nCijena
            lFill := .T.
         ENDIF
      ELSEIF cIdTipDok $ "11#13#" .AND. nCijena <> 0
         IF field->mpc <> nCijena .AND. ;
               Pitanje(, "Postaviti novu MPC u šifrarnik ?", "N" ) == "D"
            _vars[ "mpc" ] := nCijena
            lFill := .T.
         ENDIF
      ENDIF

      IF gRabIzRobe == "D" .AND. lFill == .T. .AND. nRabat <> 0 .AND. ;
            nRabat <> field->n1
         _vars[ "n1" ] := nRabat
      ENDIF

      IF lFill == .T.
         update_rec_server_and_dbf( "roba", _vars, 1, "FULL" )
      ENDIF

   ENDIF

   SELECT ( nTArea )

   RETURN



/*! \fn IniVars()
 *  \brief Ini varijable
 */

FUNCTION IniVars()

   SET CURSOR ON

   // varijable koje se inicijalizuju iz baze
   _txt1 := _txt2 := _txt3a := _txt3b := _txt3c := ""        // txt1  -  naziv robe,usluge
   _BrOtp := Space( 8 )
   _DatOtp := CToD( "" )
   _BrNar := Space( 8 )
   _DatPl := CToD( "" )
   _VezOtpr := ""

   aMemo := ParsMemo( _txt )
   IF Len( aMemo ) > 0
      _txt1 := aMemo[ 1 ]
   ENDIF
   IF Len( aMemo ) >= 2
      _txt2 := aMemo[ 2 ]
   ENDIF
   IF Len( aMemo ) >= 5
      _txt3a := aMemo[ 3 ]; _txt3b := aMemo[ 4 ]; _txt3c := aMemo[ 5 ]
   ENDIF
   IF Len( aMemo ) >= 9
      _BrOtp := aMemo[ 6 ]; _DatOtp := CToD( aMemo[ 7 ] ); _BrNar := amemo[ 8 ]; _DatPl := CToD( aMemo[ 9 ] )
   ENDIF
   IF Len ( aMemo ) >= 10
      _VezOtpr := aMemo[ 10 ]
   ENDIF



/*! \fn SetVars()
 *  \brief Setuj varijable
 */

FUNCTION SetVars()

   // {
   IF _podbr == " ." .OR.  roba->tip = "U" .OR. ( Val( _Rbr ) <= 1 .AND. Val( _podbr ) < 1 )
      _txt2 := OdsjPLK( _txt2 )           // odsjeci na kraju prazne linije
      IF ! "Faktura formirana na osnovu" $ _txt2
         _txt2 += Chr( 13 ) + Chr( 10 ) + _VezOtpr
      ENDIF
      _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 ) + Chr( 16 ) + _txt2 + Chr( 17 ) + ;
         Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
         Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
         Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
         Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
         Chr( 16 ) + _BrNar + Chr( 17 ) + ;
         Chr( 16 ) + DToC( _DatPl ) + Chr( 17 ) + ;
         iif ( Empty ( _VezOtpr ), "", Chr( 16 ) + _VezOtpr + Chr( 17 ) )
   ELSE
      _txt := ""
   ENDIF

   RETURN
// }




FUNCTION Tb_V_RBr()

   REPLACE Rbr WITH Str( nRbr, 3 )

   RETURN .T.



FUNCTION Tb_W_IdRoba()

   _idroba := PadR( _idroba, 15 )

   RETURN W_Roba()


FUNCTION TbRobaNaz()

   NSRNPIdRoba()

   RETURN Left( Roba->naz, 25 )



FUNCTION ObracunajPP( cSetPor, dDatDok )

   SELECT ( F_FAKT_PRIPR )
   IF !Used()
      O_FAKT_PRIPR
   ENDIF
   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF
   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF

   SELECT fakt_pripr
   GO TOP
   IF dDatDok = NIL
      dDatDok := fakt_pripr->DatDok
   ENDIF
   IF cSetPor = NIL
      cSetPor := "D"
   ENDIF

   DO WHILE !Eof()
      IF cSetPor == "D"
         NSRNPIdRoba()
         // select roba; HSEEK fakt_pripr->idroba
         SELECT tarifa; HSEEK roba->idtarifa
         IF Found()
            SELECT fakt_pripr
            REPLACE porez WITH tarifa->opp
         ENDIF
      ENDIF
      IF datDok <> dDatdok
         REPLACE DatDok WITH dDatDok
      ENDIF
      SELECT fakt_pripr
      SKIP
   ENDDO

   GO TOP

   RETURN


/*! \fn TarifaR(cRegion, cIdRoba, aPorezi)
 *  \brief Tarifa na osnovu region + roba
 *  \param cRegion
 *  \param cIdRoba
 *  \param aPorezi
 *  \note preradjena funkcija jer Fakt nema cIdKonto
 */

FUNCTION TarifaR( cRegion, cIdRoba, aPorezi )

   // {
   LOCAL cTarifa
   PRIVATE cPolje

   PushWA()

   IF Empty( cRegion )
      cPolje := "IdTarifa"
   ELSE
      IF cRegion == "1" .OR. cRegion == " "
         cPolje := "IdTarifa"
      ELSEIF cRegion == "2"
         cPolje := "IdTarifa2"
      ELSEIF cRegion == "3"
         cPolje := "IdTarifa3"
      ELSE
         cPolje := "IdTarifa"
      ENDIF
   ENDIF

   SELECT ( F_ROBA )
   IF !Used()
      O_ROBA
   ENDIF
   SEEK cIdRoba
   cTarifa := &cPolje

   SELECT ( F_TARIFA )
   IF !Used()
      O_TARIFA
   ENDIF
   SEEK cTarifa

   SetAPorezi( @aPorezi )

   PopWa()

   RETURN tarifa->id
// }


// ----------------------------------------
// Promjena cijene u sifrarniku
// ----------------------------------------

FUNCTION fakt_promjena_cijene_u_sif()

   NSRNPIdRoba()
   SELECT fakt_pripr

   RETURN .T.

// ---------------------------------------------
// NSRNPIIdRoba(cSR,fSint)
// Nasteli sif->roba na fakt_pripr->idroba
// cSR
// fSint  - ako je fSint:=.t. sinteticki prikaz
// -----------------------------------------------

FUNCTION NSRNPIdRoba( cSR, fSint )

   IF fSint == NIL
      fSint := .F.
   ENDIF

   IF cSR == NIL
      cSR := fakt_pripr->IdRoba
   ENDIF

   SELECT ROBA

   IF ( fSint )
      HSEEK PadR( Left( cSR, gnDS ), Len( cSR ) )
      IF !Found() .OR. ROBA->tip != "S"
         HSEEK cSR
      ENDIF
   ELSE
      HSEEK cSR
   ENDIF

   IF cSr == NIL
      SELECT fakt_pripr
   ENDIF

   RETURN



FUNCTION get_serbr_opis()

   LOCAL _tmp := "Ser.broj"

   // ovo rudnik koristi za preracunavanje kj/kg
   // if _is_rudnik
   // _tmp := "  KJ/KG"
   // endif

   RETURN _tmp




FUNCTION Koef( cdindem )

   LOCAL nNaz, nRet, nArr, dDat

   IF cDinDem == Left( ValSekund(), 3 )
      RETURN 1 / UbaznuValutu( datdok )
   ELSE
      RETURN 1
   ENDIF




/*! \fn SljBrDok13(cBrD,nBrM,cKon)
 *  \brief
 *  \param cBrD
 *  \param nBrM
 *  \param cKon
 */

FUNCTION SljBrDok13( cBrD, nBrM, cKon )

   LOCAL nPom
   LOCAL cPom := ""
   LOCAL cPom2

   cPom2 := PadL( AllTrim( Str( Val( AllTrim( SubStr( cKon, 4 ) ) ) ) ), 2, "0" )
   nPom := At( "/", cBrD )

   IF Val( SubStr( cBrD, nPom + 1, 2 ) ) != nBrM
      cPom := "01"
   ELSE
      cPom := NovaSifra( SubStr( cBrD, nPom - 2, 2 ) )
   ENDIF

   RETURN cPom2 + cPom + "/" + PadL( AllTrim( Str( nBrM ) ), 2, "0" )


/*! \fn IsprUzorTxt(fSilent,bFunc)
 *  \brief Ispravka teksta ispod fakture
 *  \param fSilent
 *  \param bFunc
 */

FUNCTION IsprUzorTxt( fSilent, bFunc )

   LOCAL cListaTxt := ""

   IF fSilent == nil
      fSilent := .F.
   ENDIF

   lDoks2 := .T.

   IF !fSilent
      Scatter()
   ENDIF

   _BrOtp := Space( 50 )
   _DatOtp := CToD( "" )
   _BrNar := Space( 50 )
   _DatPl := CToD( "" )
   _VezOtpr := ""
   _txt1 := _txt2 := _txt3a := _txt3b := _txt3c := ""
   // txt1  -  naziv robe,usluge
   nRbr := RbrUNum( RBr )

   IF lDoks2
      d2k1 := Space( 15 )
      d2k2 := Space( 15 )
      d2k3 := Space( 15 )
      d2k4 := Space( 20 )
      d2k5 := Space( 20 )
      d2n1 := Space( 12 )
      d2n2 := Space( 12 )
   ENDIF

   aMemo := ParsMemo( _txt )
   IF Len( aMemo ) > 0
      _txt1 := aMemo[ 1 ]
   ENDIF
   IF Len( aMemo ) >= 2
      _txt2 := aMemo[ 2 ]
   ENDIF
   IF Len( aMemo ) >= 5
      _txt3a := aMemo[ 3 ]; _txt3b := aMemo[ 4 ]; _txt3c := aMemo[ 5 ]
   ENDIF

   IF Len( aMemo ) >= 9
      _BrOtp := aMemo[ 6 ]; _DatOtp := CToD( aMemo[ 7 ] ); _BrNar := amemo[ 8 ]; _DatPl := CToD( aMemo[ 9 ] )
   ENDIF
   IF Len ( aMemo ) >= 10 .AND. !Empty( aMemo[ 10 ] )
      _VezOtpr := aMemo[ 10 ]
   ENDIF

   IF lDoks2
      IF Len ( aMemo ) >= 11
         d2k1 := aMemo[ 11 ]
      ENDIF
      IF Len ( aMemo ) >= 12
         d2k2 := aMemo[ 12 ]
      ENDIF
      IF Len ( aMemo ) >= 13
         d2k3 := aMemo[ 13 ]
      ENDIF
      IF Len ( aMemo ) >= 14
         d2k4 := aMemo[ 14 ]
      ENDIF
      IF Len ( aMemo ) >= 15
         d2k5 := aMemo[ 15 ]
      ENDIF
      IF Len ( aMemo ) >= 16
         d2n1 := aMemo[ 16 ]
      ENDIF
      IF Len ( aMemo ) >= 17
         d2n2 := aMemo[ 17 ]
      ENDIF
   ENDIF

   IF !fSilent
      cListaTxt := g_txt_tipdok( _idtipdok )
      UzorTxt2( cListaTxt, nRbr )
   ENDIF

   IF bFunc <> nil
      Eval( bFunc )
   ENDIF

   _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 ) + Chr( 16 ) + _txt2 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrNar + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatPl ) + Chr( 17 ) + ;
      iif ( Empty ( _VezOtpr ), Chr( 16 ) + "" + Chr( 17 ), Chr( 16 ) + _VezOtpr + Chr( 17 ) ) + ;
      IF( lDoks2, Chr( 16 ) + d2k1 + Chr( 17 ), "" ) + ;
      IF( lDoks2, Chr( 16 ) + d2k2 + Chr( 17 ), "" ) + ;
      IF( lDoks2, Chr( 16 ) + d2k3 + Chr( 17 ), "" ) + ;
      IF( lDoks2, Chr( 16 ) + d2k4 + Chr( 17 ), "" ) + ;
      IF( lDoks2, Chr( 16 ) + d2k5 + Chr( 17 ), "" ) + ;
      IF( lDoks2, Chr( 16 ) + d2n1 + Chr( 17 ), "" ) + ;
      IF( lDoks2, Chr( 16 ) + d2n2 + Chr( 17 ), "" )

   IF !fSilent
      my_rlock()
      Gather()
      my_unlock()
   ENDIF

   RETURN




FUNCTION edit_fakt_doks2()

   LOCAL cPom := ""
   LOCAL nArr := Select()
   LOCAL GetList := {}

   cPom := IzFMKINI( "FAKT", "Doks2Edit", "N", KUMPATH )
   IF cPom == "N"
      RETURN
   ENDIF

   cPom := IzFMKINI( "FAKT", "Doks2opis", "dodatnih podataka", KUMPATH )

   IF Pitanje( , "Želite li unos/ispravku " + cPom + "? (D/N)", "N" ) == "N"
      Select( nArr )
      RETURN
   ENDIF

   // ucitajmo dodatne podatke iz FMK.INI u aDodPar
   // ---------------------------------------------
   aDodPar := {}

   AAdd( aDodPar, IzFMKINI( "Doks2", "ZK1", "K1", KUMPATH )  )
   AAdd( aDodPar, IzFMKINI( "Doks2", "ZK2", "K2", KUMPATH )  )
   AAdd( aDodPar, IzFMKINI( "Doks2", "ZK3", "K3", KUMPATH )  )
   AAdd( aDodPar, IzFMKINI( "Doks2", "ZK4", "K4", KUMPATH )  )
   AAdd( aDodPar, IzFMKINI( "Doks2", "ZK5", "K5", KUMPATH )  )
   AAdd( aDodPar, IzFMKINI( "Doks2", "ZN1", "N1", KUMPATH )  )
   AAdd( aDodPar, IzFMKINI( "Doks2", "ZN2", "N2", KUMPATH )  )

   nd2n1 := Val( d2n1 )
   nd2n2 := Val( d2n2 )

   Box(, 9, 75 )
   @ m_x + 0, m_y + 2 SAY "Unos/ispravka " + cPom COLOR "GR+/B"
   @ m_x + 2, m_y + 2 SAY PadL( aDodPar[ 1 ], 30 ) GET d2k1
   @ m_x + 3, m_y + 2 SAY PadL( aDodPar[ 2 ], 30 ) GET d2k2
   @ m_x + 4, m_y + 2 SAY PadL( aDodPar[ 3 ], 30 ) GET d2k3
   @ m_x + 5, m_y + 2 SAY PadL( aDodPar[ 4 ], 30 ) GET d2k4
   @ m_x + 6, m_y + 2 SAY PadL( aDodPar[ 5 ], 30 ) GET d2k5
   @ m_x + 7, m_y + 2 SAY PadL( aDodPar[ 6 ], 30 ) GET nd2n1 PICT "999999999.99"
   @ m_x + 8, m_y + 2 SAY PadL( aDodPar[ 7 ], 30 ) GET nd2n2 PICT "999999999.99"
   READ
   BoxC()

   IF LastKey() <> K_ESC
      d2n1 := IF( nd2n1 <> 0, AllTrim( Str( nd2n1 ) ), "" )
      d2n2 := IF( nd2n2 <> 0, AllTrim( Str( nd2n2 ) ), "" )
   ENDIF

   SELECT ( nArr )

   RETURN




// -------------------------------------------------
// provjeri cijenu sa cijenom iz sifrarnika
// -------------------------------------------------
FUNCTION c_cijena( nCijena, cTipDok, lNovidok )

   LOCAL lRet := .T.
   LOCAL nRCijena := nil

   IF !lNoviDok
      RETURN lRet
   ENDIF

   IF cTipDok $ "11#15#27"

      IF gMP == "1"
         nRCijena := roba->mpc
      ELSEIF gMP == "3"
         nRCijena := roba->mpc2
      ELSEIF gMP == "4"
         nRCijena := roba->mpc3
      ELSEIF gMP == "5"
         nRCijena := roba->mpc4
         // ELSEIF gMP == "6"
         // nRCijena := roba->mpc5
         // ELSEIF gMP == "7"
         // nRCijena := roba->mpc6
      ENDIF

   ELSEIF cTipDok $ "10#"
      nRCijena := roba->vpc
   ENDIF

   IF gPratiC == "D" .AND. nRCijena <> NIL .AND. nCijena <> nRCijena
      MsgBeep( "Unesena cijena različita od cijene u šifrarniku !" + ;
         "#Trenutna: " + AllTrim( Str( nCijena, 12, 2 ) ) + ;
         ", šifrarnik: " + AllTrim( Str( nRCijena, 12, 2 ) ) )
      IF Pitanje(, "Koristiti ipak ovu cijenu (D/N) ?", "D" ) == "N"
         lRet := .F.
      ENDIF
   ENDIF

   RETURN lRet





FUNCTION GetKarC3N2( mx )

   LOCAL nKor := 0
   LOCAL nDod := 0
   LOCAL x := 0
   LOCAL y := 0

   IF ( fakt_pripr->( FieldPos( "C1" ) ) <> 0 .AND. gKarC1 == "D" )
      @ mx + ( ++nKor ), m_y + 2 SAY "C1" GET _C1 PICT "@!"
      nDod++
   ENDIF

   IF ( fakt_pripr->( FieldPos( "C2" ) ) <> 0 .AND. gKarC2 == "D" )
      SljPozGet( @x, @y, @nKor, mx, nDod )
      @ x, y SAY "C2" GET _C2 PICT "@!"
      nDod++
   ENDIF

   IF ( fakt_pripr->( FieldPos( "C3" ) ) <> 0 .AND. gKarC3 == "D" )
      SljPozGet( @x, @y, @nKor, mx, nDod )
      @ x, y SAY "C3" GET _C3 PICT "@!"
      nDod++
   ENDIF

   IF ( fakt_pripr->( FieldPos( "N1" ) ) <> 0 .AND. gKarN1 == "D" )
      SljPozGet( @x, @y, @nKor, mx, nDod )
      @ x, y SAY "N1" GET _N1 PICT "999999.999"
      nDod++
   ENDIF

   IF ( fakt_pripr->( FieldPos( "N2" ) ) <> 0 .AND. gKarN2 == "D" )
      SljPozGet( @x, @y, @nKor, mx, nDod )
      @ x, y SAY "N2" GET _N2 PICT "999999.999"
      nDod++
   ENDIF

   IF ( fakt_pripr->( FieldPos( "opis" ) ) <> 0 )
      SljPozGet( @x, @y, @nKor, mx, nDod )
      @x, y SAY "Opis" GET _opis PICT "@S40"
      nDod++
   ENDIF

   IF nDod > 0
      ++nKor
   ENDIF

   RETURN nKor


FUNCTION SljPozGet( x, y, nKor, mx, nDod )

   IF nDod > 0
      IF nDod % 3 == 0
         x := mx + ( ++nKor )
         y := m_y + 2
      ELSE
         x := mx + nKor
         y := Col() + 2
      ENDIF
   ELSE
      x := mx + ( ++nKor )
      y := m_y + 2
   ENDIF

   RETURN


// ----------------------------------------------------------------------
// ispisuje informaciju o tekucem dokumentu na vrhu prozora
// ----------------------------------------------------------------------
FUNCTION TekDokument()

   LOCAL nRec
   LOCAL aMemo
   LOCAL cTxt

   cTxt := PadR( "-", 60 )

   IF RecCount2() <> 0
      nRec := RecNo()
      GO TOP
      aMemo := ParsMemo( txt )
      IF Len( aMemo ) >= 5
         cTxt := Trim( amemo[ 3 ] ) + " " + Trim( amemo[ 4 ] ) + "," + Trim( amemo[ 5 ] )
      ELSE
         cTxt := ""
      ENDIF
      cTxt := PadR( cTxt, 30 )
      cTxt := " " + AllTrim( cTxt ) + ", Broj: " + idfirma + "-" + idtipdok + "-" + brdok + ", od " + DToC( datdok ) + " "
      GO nRec
   ENDIF

   @ m_x + 0, m_y + 2 SAY cTxt

   RETURN


// Rbr()
// Redni broj

FUNCTION Rbr()

   LOCAL cRet

   IF Eof()
      cRet := ""
   ELSEIF Val( fakt_pripr->podbr ) == 0
      cRet := fakt_pripr->rbr + ")"
   ELSE
      cRet := fakt_pripr->rbr + "." + AllTrim( fakt_pripr->podbr )
   ENDIF

   RETURN PadR( cRet, 6 )

/*! \fn CijeneOK(cStr)
 *  \brief
 *  \param cStr
 */

FUNCTION CijeneOK( cStr )

   LOCAL fMyFlag := .F., lRetFlag := .T., nTekRec

   SELECT fakt_pripr
   nTekRec := RecNo ()
   IF fakt_pripr->IdTipDok $ "10#11#15#20#25#27"
      // PROVJERI IMA LI NEODREDJENIH CIJENA ako se radi o fakturi
      Scatter()
      SET ORDER TO TAG "1"
      Seek2 ( _IdFirma + _IdTipDok + _BrDok )
      DO WHILE ! Eof() .AND. IdFirma == _IdFirma .AND. ;
            IdTipDok == _IdTipDok .AND. BrDok == _BrDok
         IF Cijena == 0 .AND. Empty ( PodBr )
            Beep ( 3 )
            Msg ( "Utvrđena greška na stavci broj " + ;
               AllTrim ( rbr ) + "!#" + ;
               "CIJENA NIJE ODREĐENA!!!", 30 )
            fMyFlag := .T.
         ENDIF
         SKIP
      END
      IF fMyFlag
         Msg ( cStr + " nije dozvoljeno!#Vraćate se u pripremu!", 30 )
         lRetFlag := .F.
      ENDIF
   ENDIF
   GO nTekRec

   RETURN ( lRetFlag )
// }



/*! \fn renumeracija_fakt_pripr(cVezOtpr,dNajnoviji)
 *  \brief
 *  \param cVezOtpr
 *  \param dNajnoviji - datum posljednje radjene otpremnice
 */

FUNCTION renumeracija_fakt_pripr( veza_otpremnica, datum_max )

   // poziva se samo pri generaciji otpremnica u fakturu

   LOCAL dDatDok
   LOCAL lSetujDatum := .F.
   PRIVATE nRokPl := 0
   PRIVATE cSetPor := "N"

   SELECT fakt_pripr
   SET ORDER TO TAG "1"
   GO TOP

   IF RecCount2 () == 0
      RETURN
   ENDIF

   nRbr := 999
   GO BOTTOM

   my_flock()

   DO WHILE !Bof()
      REPLACE rbr WITH Str( --nRbr, 3 )
      SKIP -1
   ENDDO

   nRbr := 0
   DO WHILE !Eof()
      SKIP
      nTrec := RecNo()
      SKIP -1
      IF Empty( podbr )
         REPLACE rbr WITH Str( ++nRbr, 3, 0 )
      ELSE
         IF nRbr == 0
            nRbr := 1
         ENDIF
         REPLACE rbr WITH Str( nRbr, 3, 0 )
      ENDIF
      GO nTrec
   ENDDO

   my_unlock()

   GO TOP

   Scatter()

   _txt1 := _txt2 := _txt3a := _txt3b := _txt3c := ""
   _dest := Space( 150 )
   _m_dveza := Space( 500 )

   IF IzFmkIni( 'FAKT', 'ProsiriPoljeOtpremniceNa50', 'N', KUMPATH ) == 'D'
      _BrOtp := Space( 50 )
   ELSE
      _BrOtp := Space( 8 )
   ENDIF

   _DatOtp := CToD( "" )
   _BrNar := Space( 8 )
   _DatPl := CToD( "" )

   IF veza_otpremnica == nil
      veza_otpremnica := ""
   ENDIF

   aMemo := ParsMemo( _txt )
   IF Len( aMemo ) > 0
      _txt1 := aMemo[ 1 ]
   ENDIF
   IF Len( aMemo ) >= 2
      _txt2 := aMemo[ 2 ]
   ENDIF
   IF Len( aMemo ) >= 5
      _txt3a := aMemo[ 3 ]
      _txt3b := aMemo[ 4 ]
      _txt3c := aMemo[ 5 ]
   ENDIF
   IF Len( aMemo ) >= 9
      _BrOtp := aMemo[ 6 ]
      _DatOtp := CToD( aMemo[ 7 ] )
      _BrNar := amemo[ 8 ]
      _DatPl := CToD( aMemo[ 9 ] )
   ENDIF
   IF Len( aMemo ) >= 10 .AND. !Empty( aMemo[ 10 ] )
      cVezOtpr := aMemo[ 10 ]
   ENDIF

   // destinacija
   IF Len( aMemo ) >= 18
      _dest := PadR( aMemo[ 18 ], 150 )
   ENDIF

   IF Len( aMemo ) >= 19
      _m_dveza := PadR( aMemo[ 19 ], 500 )
   ENDIF

   nRbr := 1

   Box( "#PARAMETRI DOKUMENTA:", 10, 75 )

   IF gDodPar == "1"
      @  m_x + 1, m_y + 2 SAY "Otpremnica broj:" GET _brotp
      @  m_x + 2, m_y + 2 SAY "          datum:" GET _Datotp
      @  m_x + 3, m_y + 2 SAY8 "Ugovor/narudžba:" GET _brNar
      @  m_x + 4, m_y + 2 SAY "    Destinacija:" GET _dest PICT "@S45"
      @  m_x + 5, m_y + 2 SAY "Vezni dokumenti:" GET _m_dveza PICT "@S45"
   ENDIF

   IF gDodPar == "1" .OR. gDatVal == "D"

      nRokPl := gRokPl

      @  m_x + 6, m_y + 2 SAY "Datum fakture  :" GET _DatDok

      IF datum_max <> NIL
         @  m_x + 6, m_y + 35 SAY "Datum posljednje otpremnice:" GET datum_max WHEN .F. COLOR "GR+/B"
      ENDIF

      @ m_x + 7, m_y + 2 SAY8 "Rok plać.(dana):" GET nRokPl PICT "999" WHEN valid_rok_placanja( @nRokPl, "0", .T. ) ;
         VALID valid_rok_placanja( nRokPl, "1", .T. )
      @ m_x + 8, m_y + 2 SAY8 "Datum plaćanja :" GET _DatPl VALID valid_rok_placanja( nRokPl, "2", .T. )

      READ
   ENDIF

   READ

   BoxC()

   dDatDok := _Datdok

   UzorTxt()

   IF !Empty ( veza_otpremnica )
      _txt2 += Chr( 13 ) + Chr( 10 ) + veza_otpremnica
   ENDIF

   _txt := Chr( 16 ) + Trim( _txt1 ) + Chr( 17 ) + Chr( 16 ) + _txt2 + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3a ) + Chr( 17 ) + Chr( 16 ) + _txt3b + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _txt3c ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrOtp + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatOtp ) + Chr( 17 ) + ;
      Chr( 16 ) + _BrNar + Chr( 17 ) + ;
      Chr( 16 ) + DToC( _DatPl ) + Chr( 17 ) + ;
      iif( Empty ( veza_otpremnica ), "", Chr( 16 ) + veza_otpremnica + Chr( 17 ) ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _dest ) + Chr( 17 ) + ;
      Chr( 16 ) + Trim( _m_dveza ) + Chr( 17 )

   IF datDok <> dDatDok
      lSetujDatum := .T.
   ENDIF

   my_rlock()
   Gather()
   my_unlock()

   RETURN



FUNCTION Part1Stavka()

   LOCAL cRet := ""

   IF AllTrim( fakt_pripr->rbr ) == "1"
      cRet += Trim( fakt_pripr->idpartner ) + ": "
   ENDIF

   RETURN cRet



FUNCTION Roba()

   LOCAL cRet := ""

   cRet += Trim( StIdROBA() ) + " "
   DO CASE
   CASE Eof()
      cRet := ""
   CASE  AllTrim( podbr ) == "."
      aMemo := ParsMemo( txt )
      cRet += aMemo[ 1 ]
   OTHERWISE

      SELECT F_ROBA

      IF !Used()
         O_ROBA
      ENDIF

      SELECT roba
      SEEK fakt_pripr->IdRoba
      SELECT fakt_pripr
      cRet += Left( ROBA->naz, 40 )
   ENDCASE

   RETURN PadR( cRet, 30 )


// -------------------------------------------------
// JedinaStavka()
// U dokumentu postoji samo jedna stavka
//
// -------------------------------------------------
FUNCTION JedinaStavka()

   nTekRec   := RecNo()
   nBrStavki := 0
   cIdFirma  := IdFirma
   cIdTipDok := IdTipDok
   cBrDok    := BrDok

   GO TOP

   HSEEK cIdFirma + cIdTipDok + cBrDok
   DO WHILE ! Eof () .AND. ( IdFirma == cIdFirma ) .AND. ( IdTipDok == cIdTipDok ) ;
         .AND. ( BrDok == cBrDok )
      nBrStavki++
      SKIP
   ENDDO

   GO nTekRec

   RETURN iif( nBrStavki == 1, .T., .F. )


// -------------------------------------------
// brisanje stavke
// -------------------------------------------
FUNCTION fakt_brisi_stavku_pripreme()

   LOCAL _secur_code
   LOCAL _log_opis
   LOCAL _log_stavka
   LOCAL _log_artikal, _log_kolicina, _log_cijena
   LOCAL _log_datum
   LOCAL _t_area
   LOCAL _rec, _t_rec
   LOCAL _tek, _prva
   LOCAL _id_tip_dok, _id_firma, _br_dok, _r_br
   LOCAL oAtrib
   LOCAL _update_rbr

   IF Pitanje(, "Želite izbrisati ovu stavku ?", "D" ) == "N"
      RETURN 0
   ENDIF

   _id_firma := field->idfirma
   _id_tip_dok := field->idtipdok
   _br_dok := field->brdok
   _r_br := field->rbr

   log_write( "F18_DOK_OPER: fakt, brisanje stavke iz pripreme: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok + " stavka br: " + _r_br, 5 )

   IF ( RecCount2() == 1 ) .OR. JedinaStavka()
      fakt_reset_broj_dokumenta( _id_firma, _id_tip_dok, _br_dok )
   ENDIF

   IF _r_br == PadL( "1", 3 ) .AND. ( RecCount() > 1 )

      _prva := dbf_get_rec()

      SKIP

      _tek := dbf_get_rec()

      _update_rbr := _tek[ "rbr" ]

      _tek[ "txt" ] := _prva[ "txt" ]
      _tek[ "rbr" ] := _prva[ "rbr" ]

      dbf_update_rec( _tek )

      SKIP -1

   ENDIF

   PushWA()

   // pobrisi i fakt atribute ove stavke...
   oAtrib := F18_DOK_ATRIB():new( "fakt", F_FAKT_ATRIB )
   oAtrib:dok_hash[ "idfirma" ] := _id_firma
   oAtrib:dok_hash[ "idtipdok" ] := _id_tip_dok
   oAtrib:dok_hash[ "brdok" ] := _br_dok
   oAtrib:dok_hash[ "rbr" ] := _r_br
   oAtrib:dok_hash[ "update_rbr" ] := _update_rbr
   oAtrib:delete_atrib()

   IF _update_rbr <> NIL
      oAtrib:update_atrib_rbr()
   ENDIF

   PopWa()

   my_delete()

   RETURN 1


// -------------------------------------------------------
// matrica sa tipovima dokumenata
// -------------------------------------------------------
FUNCTION fakt_tip_dok_arr()

   LOCAL _arr := {}

   AAdd( _arr, "00 - Pocetno stanje                " )
   AAdd( _arr, "01 - Ulaz / Radni nalog " )
   AAdd( _arr, "10 - Porezna faktura" )
   AAdd( _arr, "11 - Porezna faktura gotovina" )
   AAdd( _arr, "12 - Otpremnica" )
   AAdd( _arr, "13 - Otpremnica u maloprodaju" )
   AAdd( _arr, "19 - Izlaz po ostalim osnovama" )
   AAdd( _arr, "20 - Ponuda/Avansna faktura" )
   AAdd( _arr, "21 - Revers" )
   AAdd( _arr, "22 - Realizovane otpremnice   " )
   AAdd( _arr, "23 - Realizovane otpremnice MP" )
   AAdd( _arr, "25 - Knjizna obavijest " )
   AAdd( _arr, "26 - Narudzbenica " )
   AAdd( _arr, "27 - Ponuda/Avansna faktura gotovina" )

   RETURN _arr
