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

STATIC picdem := "9999999999.99"
STATIC gDatObr
STATIC gKumKam
STATIC gPdvObr

// -----------------------------------------------
// glavni menij za obradu kamata
// -----------------------------------------------
FUNCTION fin_kamate_menu()

   LOCAL _izbor := 1
   LOCAL _opc := {}
   LOCAL _opcexe := {}

   AAdd( _opc, "1. obračun pojedinacnog dokumenta              " )
   AAdd( _opcexe, {|| kamate_obracun_pojedinacni() } )
   AAdd( _opc, "2. unos/ispravka pripreme kamata   " )
   AAdd( _opcexe, {|| kamate_unos() } )
   AAdd( _opc, "3. prenos FIN->kamate         " )
   AAdd( _opcexe, {|| prenos_fin_kam() } )
   AAdd( _opc, "4. kontrola cjelovitosti kamatnih stopa   " )
   AAdd( _opcexe, {|| kontrola_cjelovitosti_ks() } )
   AAdd( _opc, "5. lista kamatnih stopa  " )
   AAdd( _opcexe, {|| p_ks() } )

   gDatObr := Date()

   f18_menu( "kamat", .F., _izbor, _opc, _opcexe )

   RETURN .T.


// ---------------------------------------------
// unos kamata
// ---------------------------------------------
FUNCTION kamate_unos()

   LOCAL _i
   LOCAL _x := MAXROWS() - 15
   LOCAL _y := MAXCOLS() - 5
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   O_Edit()

   ImeKol := { ;
      { "KONTO",         {|| IdKonto  }, "Idkonto"   }, ;
      { "Partner",       {|| IdPartner }, "IdPartner" }, ;
      { "Brdok",         {|| Brdok    }, "Brdok"     }, ;
      { "DatOd",         {|| DatOd    }, "DatOd"     }, ;
      { "DatDo",         {|| DatDo    }, "DatDo"     }, ;
      { "Osnovica",      {|| Osnovica }, "Osnovica"  }, ;
      { "M1",            {|| M1       }, "M1"        }  ;
      }

   FOR _i := 1 TO Len( imekol )
      AAdd( Kol, _i )
   NEXT

   Box(, _x, _y )
   @ m_x + ( _x - 2 ), m_y + 2 SAY " <c-N>  Nove Stavke      ³ <ENT> Ispravi stavku   ³ <c-T> Brisi Stavku"
   @ m_x + ( _x - 1 ), m_y + 2 SAY " <c-A>  Ispravka Dokum.  ³ <c-P> Stampa svi KL    ³ <c-U> Lista uk.dug"
   @ m_x + _x, m_y + 2 SAY " <c-F9> Brisi pripremu   ³ <a-P> Stampa pojedinac.³                   "
   my_db_edit( "PNal", _x, _y, {|| _key_handler() }, "", "KAMATE Priprema.....ÍÍÍÍÍ", , , , , 3 )
   BoxC()

   my_close_all_dbf()

   RETURN .T.


// otvaranje potrebnih tabela
STATIC FUNCTION O_Edit()

   O_KS
   O_PARTN
   O_KONTO
   O_KAM_PRIPR
   O_KAM_KAMAT
   SELECT kam_pripr
   SET ORDER TO TAG "1"
   GO TOP

   RETURN



// korekcija unos/ispravka
STATIC FUNCTION ispravka_unosa( l_novi )

   IF l_novi
      _idkonto := PadR( "2110", 7 )
   ENDIF

   SET CURSOR ON

   @ m_x + 1, m_y + 2  SAY "Partner  :" GET _IdPartner PICT "@!" VALID P_Firma( @_idpartner )
   @ m_x + 3, m_y + 2  SAY "Broj Veze:" GET _BrDok
   @ m_x + 5, m_y + 2  SAY "Datum od  " GET _datOd VALID PostojiLi( _idPartner, _brDok, _datOd, l_novi )
   @ m_x + 5, Col() + 2 SAY "do" GET _datDo
   @ m_x + 7, m_y + 2  SAY "Osnovica  " GET _Osnovica PICT "999999999.99"

   READ

   ESC_RETURN 0

   RETURN 1



// postoji li zapis vec
STATIC FUNCTION PostojiLi( idp, brd, dod, fNovi )

   LOCAL _vrati := .T.
   LOCAL _rec_no

   PushWA()

   SELECT kam_pripr
   _rec_no := RecNo()
   GO TOP

   DO WHILE !Eof()
      IF idpartner == idp .AND. brdok == brd .AND. DToC( datod ) == DToC( dod ) .AND. ( RecNo() != _rec_no .OR. fNovi )
         _vrati := .F.
         Msg( "Greska! Vec ste unijeli ovaj podatak!", 3 )
         EXIT
      ENDIF
      SKIP 1
   ENDDO

   GO ( _rec_no )

   PopWA()

   RETURN _vrati


// -----------------------------------------------
// obrada dogadjaja tastature
// -----------------------------------------------
STATIC FUNCTION _key_handler()

   LOCAL nTr2

   IF ( Ch == K_CTRL_T .OR. Ch == K_ENTER ) .AND. reccount2() == 0
      RETURN DE_CONT
   ENDIF

   SELECT kam_pripr

   DO CASE

   CASE Ch == K_CTRL_T
      RETURN browse_brisi_stavku()

   CASE Ch = K_CTRL_F9
      RETURN browse_brisi_pripremu()

      // ispravka stavke
   CASE Ch == K_ENTER

      Box( "ist", 20, 75, .F. )

      Scatter()

      IF ispravka_unosa( .F. ) == 0
         BoxC()
         RETURN DE_CONT
      ELSE
         my_rlock()
         Gather()
         my_unlock()
         BoxC()
         RETURN DE_REFRESH
      ENDIF

   CASE Ch == K_CTRL_K

      fin_kamate_generisi_mj_uplate()
      RETURN DE_CONT

   CASE Ch == K_CTRL_A

      PushWA()

      SELECT kam_pripr
      GO TOP

      Box( "anal", 13, 75, .F., "Ispravka stavki dokumenta" )

      nDug := 0
      nPot := 0

      DO WHILE !Eof()
         SKIP
         nTR2 := RecNo()
         SKIP - 1
         Scatter()
         @ m_x + 1, m_y + 1 CLEAR TO m_x + 12, m_y + 74
         IF ispravka_unosa( .F. ) == 0
            EXIT
         ENDIF
         SELECT kam_pripr
         my_rlock()
         Gather()
         my_unlock()
         GO nTR2
      ENDDO

      PopWA()

      BoxC()

      RETURN DE_REFRESH

      // unos nove stavke
   CASE Ch == K_CTRL_N

      nDug := 0
      nPot := 0
      nPrvi := 0

      GO BOTTOM

      Box( "knjn", 13, 77, .F., "Unos novih stavki" )

      DO WHILE .T.
         Scatter()
         @ m_x + 1, m_y + 1 CLEAR TO m_x + 12, m_y + 76
         IF ispravka_unosa( .T. ) == 0
            EXIT
         ENDIF
         SELECT kam_pripr
         APPEND BLANK
         my_rlock()
         Gather()
         my_unlock()
      ENDDO

      BoxC()
      RETURN DE_REFRESH

      // printanje kamatnog lista
   CASE Ch == K_CTRL_P

      fin_kamate_print()
      RETURN DE_REFRESH

      // lista
   CASE Ch == K_CTRL_U

      nArr := Select()
      nUD1 := 0
      nUD2 := 0
      nUD3 := 0

      IF File( my_home() + "pom.dbf" )

         SELECT ( F_TMP_1 )
         USE
         my_use_temp( "POM", my_home() + "pom", .F., .T. )

         SELECT pom
         GO TOP

         start_print_close_ret()

         ? "PREGLED UKUPNIH DUGOVANJA PO KUPCIMA"
         ? "------------------------------------"
         ?
         ? "      SIFRA I NAZIV KUPCA            DUG         KAMATA       UKUPNO   "
         ? "-------------------------------- ------------ ------------ ------------"

         DO WHILE !Eof()
            ? field->idpartner, PadR( Ocitaj( F_PARTN, field->idpartner, "naz" ), 25 ), ;
               Str( field->osndug, 12, 2 ), Str( field->kamate, 12, 2 ), Str( field->osndug + field->kamate, 12, 2 )
            nUd1 += field->osndug
            nUd2 += field->kamate
            nUd3 += ( field->osndug + field->kamate )
            SKIP 1
         ENDDO

         ? "-------------------------------- ------------ ------------ ------------"
         ? "UKUPNO SVI KUPCI................", ;
            Str( nUd1, 12, 2 ), Str( nUd2, 12, 2 ), Str( nUd3, 12, 2 )

         end_print()
         USE
      ENDIF

      O_KAM_PRIPR
      SELECT ( nArr )
      RETURN DE_REFRESH

   CASE Ch == K_ALT_P

      SELECT kam_pripr

      PRIVATE nKamMala := 0
      PRIVATE nOsnDug := 0
      PRIVATE nSOsnSD := 0
      PRIVATE nKamate := 0
      PRIVATE cVarObrac := "Z"

      cIdpartner := Eval( ( TB:getColumn( 2 ) ):Block )

      Box(, 2, 70 )
      @ m_x + 1, m_y + 2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET cVarObrac VALID cVarObrac $ "ZP" PICT "@!"
      READ
      BoxC()

      start_print_close_ret()

      IF ObracV( cIdPartner, .F., cVarObrac ) > nKamMala
         ObracV( cIdPartner, nil, cVarObrac )
      ENDIF

      end_print()

      O_KAM_PRIPR
      SELECT kam_pripr
      GO TOP

      RETURN DE_REFRESH

   CASE is_key_alt_a( Ch )
      RETURN DE_REFRESH

   ENDCASE

   RETURN DE_CONT




STATIC FUNCTION rekalkulisi_osnovni_dug()

   LOCAL _date := Date()
   LOCAL _t_rec, _id_partner
   LOCAL _osn_dug, _br_dok, _racun
   LOCAL _predhodni
   LOCAL _l_prvi

   Box(, 1, 50 )
   @ m_x + 1, m_y + 2 SAY "Ukucaj tacan datum:" GET _date
   READ
   BoxC()

   gDatObr := _date

   SELECT kam_pripr
   GO TOP

   DO WHILE !Eof()

      _id_partner := field->idpartner

      SELECT kam_pripr

      _t_rec := RecNo()
      _osn_dug := 0

      DO WHILE !Eof() .AND. _id_partner == field->idpartner

         _br_dok := field->brdok
         _racun := 0
         _predhodni := 0
         _l_prvi := .F.

         DO WHILE !Eof() .AND. _id_partner == field->idpartner .AND. field->brdok == _br_dok

            IF _l_prvi
               _racun := field->osnovica
               _l_prvi := .F.
            ELSE
               _racun := _racun - ( _predhodni - field->osnovica )
            ENDIF

            _racun := iznosnadan( _racun, _date, field->datod )
            _predhodni := field->osnovica
            SKIP
         ENDDO

         _osn_dug += _racun
      ENDDO

      GO _t_rec

      DO WHILE !Eof() .AND. _id_partner == field->idpartner
         my_rlock()
         REPLACE field->osndug WITH _osn_dug
         my_unlock()
         SKIP
      ENDDO

   ENDDO

   RETURN



// ------------------------------------------------------
STATIC FUNCTION kreiraj_pomocnu_tabelu()

   LOCAL aDbf := {}

   AAdd ( aDbf, { "IDPARTNER", "C",  6, 0 } )
   AAdd ( aDbf, { "OSNDUG", "N", 12, 2 } )
   AAdd ( aDbf, { "KAMATE", "N", 12, 2 } )
   AAdd ( aDbf, { "PDV", "N", 12, 2 } )

   FErase( my_home() + "pom.dbf" )
   FErase( my_home() + "pom.cdx" )

   dbCreate( my_home() + "pom.dbf", aDbf )
   USE

   SELECT ( F_TMP_1 )
   my_use_temp( "POM", my_home() + "pom.dbf", .F., .T. )
   GO TOP

   RETURN


// -------------------------------------------------------
STATIC FUNCTION fin_kamate_print()

   LOCAL _mala_kamata := 15
   LOCAL _var_obr := "Z"
   LOCAL _kum_kam := "D"
   LOCAL _pdv_obr := "D"

   IF pitanje(, "Rekalkulisati osnovni dug ?", "N" ) == "D"
      rekalkulisi_osnovni_dug()
   ENDIF

   // kreiraj pomocnu tabelu
   kreiraj_pomocnu_tabelu()

   Box(, 6, 70 )

   @ m_x + 1, m_y + 2 SAY "Ne ispisuj kam.listove za iznos kamata ispod" GET _mala_kamata ;
      PICT "999999.99"

   @ m_x + 2, m_y + 2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET _var_obr ;
      VALID _var_obr $ "ZP" PICT "@!"

   @ m_x + 4, m_y + 2 SAY "Prikazivati kolonu 'kumulativ kamate' (D/N) ?" GET _kum_kam ;
      VALID _kum_kam $ "DN" PICT "@!"

   @ m_x + 5, m_y + 2 SAY "Dodaj PDV na obracun kamate (D/N) ?" GET _pdv_obr ;
      VALID _pdv_obr $ "DN" PICT "@!"

   READ

   BoxC()

   gKumKam := _kum_kam
   gPdvObr := _pdv_obr

   start_print_close_ret()

   ?

   O_KAM_PRIPR
   SELECT kam_pripr
   GO TOP

   DO WHILE !Eof()

      _id_partner := field->idpartner

      PRIVATE nOsnDug := 0
      PRIVATE nKamate := 0
      PRIVATE nSOsnSD := 0
      PRIVATE nPdv := 0
      PRIVATE nPdvTotal := 0
      PRIVATE nKamTotal := 0

      IF ObracV( _id_partner, .F., _var_obr ) > _mala_kamata

         my_flock()

         SELECT pom
         APPEND BLANK

         REPLACE field->idpartner WITH _id_partner
         REPLACE field->osndug WITH nOsnDug
         REPLACE field->kamate WITH nKamate
         REPLACE field->pdv WITH nPdvTotal

         my_unlock()

         SELECT kam_pripr

         ObracV( _id_partner, .T., _var_obr )

      ENDIF

      SELECT kam_pripr
      SEEK _id_partner + Chr( 250 )

   ENDDO

   end_print()

   O_KAM_PRIPR
   SELECT kam_pripr
   GO TOP

   RETURN



// -----------------------------------------------------------
// obracun kamate
// -----------------------------------------------------------
STATIC FUNCTION ObracV( cIdPartner, fprint, cVarObrac )

   LOCAL nKumKamSD := 0
   LOCAL cTxtPdv
   LOCAL cTxtUkupno

   IF fprint == NIL
      fprint := .T.
   ENDIF

   nGlavn := 2892359.28
   dDatOd := CToD( "01.02.92" )
   dDatDo := CToD( "30.09.96" )

   O_KS
   SELECT ks
   SET ORDER TO TAG "2"

   nStr := 0

   IF fprint

      nPdvTotal := nKamate * ( 17 / 100 )

      cTxtPdv := "PDV (17%)"
      cTxtPdv += " "
      cTxtPdv += Replicate( ".", 44 )
      cTxtPdv += Str( nPdvTotal, 12, 2 )
      cTxtPdv += " KM"

      cTxtUkupno := "Ukupno sa PDV"
      cTxtUkupno += " "
      cTxtUkupno += Replicate( ".", 40 )
      cTxtUkupno += Str( nKamate + nPdvTotal, 12, 2 )
      cTxtUkupno += " KM"

      ?
      P_10CPI
      ?? PadC( "- Strana " + Str( ++nStr, 4 ) + "-", 80 )
      ?

      SELECT partn
      HSEEK cIdPartner

      cPom := Trim( partn->adresa )

      IF !Empty( partn->telefon )
         cPom += ", TEL:" + partn->telefon
      ENDIF

      cPom := PadR( cPom, 42 )
      dDatPom := gDatObr

   ENDIF

   SELECT kam_pripr
   SEEK cIdPartner

   IF fPrint

      IF PRow() > 40
         FF
         ?
         P_10CPI
         ?? PadC( "- Strana " + Str( ++nStr, 4 ) + "-", 80 )
         ?
      ENDIF

      P_10CPI
      B_ON
      ? Space( 20 ), PadC( "K A M A T N I    L I S T", 30 )
      B_OFF

      IF gKumKam == "N"
         P_12CPI
      ELSE
         P_COND
      ENDIF

      ?
      ?
      ?

      IF cVarObrac == "Z"
         m := " ---------- -------- -------- --- ------------- ------------- -------- ------- -------------" + IF( gKumKam == "D", " -------------", "" )
      ELSE
         m := " ---------- -------- -------- --- ------------- ------------- -------- -------------" + IF( gKumKam == "D", " -------------", "" )
      ENDIF

      NStrana( "1" )

   ENDIF

   nSKumKam := 0
   SELECT kam_pripr
   cIdPartner := field->idpartner

   IF !fprint
      nOsnDug := field->osndug
   ENDIF

   DO WHILE !Eof() .AND. field->idpartner == cIdPartner

      fStampajBr := .T.
      fPrviBD := .T.
      nKumKamBD := 0
      nKumKamSD := 0
      cBrDok := field->brdok
      cM1 := field->m1
      nOsnovSD := kam_pripr->osnovica

      DO WHILE !Eof() .AND. field->idpartner == cIdpartner .AND. field->brdok == cBrdok

         dDatOd := kam_pripr->datod
         dDatdo := kam_pripr->datdo
         nOsnovSD := kam_pripr->osnovica

         IF fprviBD
            nGlavnBD := kam_pripr->osnovica
            fPrviBD := .F.
         ELSE

            IF cVarObrac == "Z"
               nGlavnBD := kam_pripr->osnovica + nKumKamSD
            ELSE
               nGlavnBD := kam_pripr->osnovica
            ENDIF
         ENDIF

         nGlavn := nGlavnBD

         SELECT ks
         SEEK DToS( dDatOd )

         IF dDatOd < field->DatOd .OR. Eof()
            SKIP -1
         ENDIF

         DO WHILE .T.

            dDDatDo := Min( field->DatDO, dDatDo )
            nPeriod := dDDatDo - dDatOd + 1

            IF ( cVarObrac == "P" )
               IF ( Prestupna( Year( dDatOd ) ) )
                  nExp := 366
               ELSE
                  nExp := 365
               ENDIF
            ELSE
               IF field->tip == "G"
                  IF field->duz == 0
                     nExp := 365
                  ELSE
                     nExp := field->duz
                  ENDIF
               ELSEIF field->tip == "M"
                  IF field->duz == 0
                     dExp := "01."
                     IF Month( ddDatdo ) == 12
                        dExp += "01." + AllTrim( Str( Year( dDDatdo ) + 1 ) )
                     ELSE
                        dExp += AllTrim( Str( Month( dDDatdo ) + 1 ) ) + "." + AllTrim( Str( Year( dDDatdo ) ) )
                     ENDIF
                     nExp := Day( CToD( dExp ) - 1 )
                  ELSE
                     nExp := field->duz
                  ENDIF
               ELSEIF field->tip == "3"
                  nExp := field->duz
               ELSE
                  nExp := field->duz
               ENDIF
            ENDIF

            IF field->den <> 0 .AND. dDatOd == field->datod
               IF fprint
                  ? "********* Izvrsena Denominacija osnovice sa koeficijentom:", den, "****"
               ENDIF
               nOsnovSD := Round( nOsnovSD * field->den, 2 )
               nGlavn := Round( nGlavn * field->den, 2 )
               nKumKamSD := Round( nKumKamSD * field->den, 2 )
            ENDIF

            IF ( cVarObrac == "Z" )
               nKKam := ( ( 1 + field->stkam / 100 ) ^ ( nPeriod / nExp ) - 1.00000 )
               nIznKam := nKKam * nGlavn
            ELSE
               nKStopa := field->stkam / 100
               cPom777 := my_get_from_ini( "KAM", "FormulaZaProstuKamatu", "nGlavn*nKStopa*nPeriod/nExp", KUMPATH )
               nIznKam := &( cPom777 )
            ENDIF

            nIznKam := Round( nIznKam, 2 )

            IF fprint

               IF PRow() > 55
                  FF
                  Nstrana()
               ENDIF

               IF fStampajbr
                  ? " " + cBrdok + " "
                  fStampajBr := .F.
               ELSE
                  ? " " + Space( 10 ) + " "
               ENDIF

               ?? dDatOd, dDDatDo

               @ PRow(), PCol() + 1 SAY nPeriod PICT "999"
               @ PRow(), PCol() + 1 SAY nOsnovSD PICT picdem
               @ PRow(), PCol() + 1 SAY nGlavn PICT picdem

               IF ( cVarObrac == "Z" )
                  @ PRow(), PCol() + 1 SAY field->tip
                  @ PRow(), PCol() + 1 SAY field->stkam PICT "999.99"
                  @ PRow(), PCol() + 1 SAY nKKam * 100 PICT "9999.99"
               ELSE
                  @ PRow(), PCol() + 1 SAY field->stkam PICT "999.99"
               ENDIF

               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY nIznKam PICT picdem

            ENDIF

            IF ( cVarObrac == "Z" )
               nGlavnBD += nIznKam
            ENDIF

            nKumKamBD += nIznKam
            nKumKamSD += nIznKam

            IF ( cVarObrac == "Z" )
               nGlavn += nIznKam
            ENDIF

            IF fprint .AND. gKumKam == "D"
               @ PRow(), PCol() + 1 SAY nKumKamSD PICT picdem
            ENDIF

            IF dDatDo <= field->DatDo
               SELECT kam_pripr
               EXIT
            ENDIF

            SKIP

            IF Eof()
               Msg( "PARTNER: " + kam_pripr->idpartner + ", BR.DOK.: " + kam_pripr->brdok + ;
                  "#GRESKA : Fali datumski interval u kam.stopama!", 10 )
               EXIT
            ENDIF

            dDatOd := field->DatOd

         ENDDO

         SELECT kam_pripr
         SKIP

      ENDDO

      nKumKamSD := IznosNaDan( nKumKamSD, gDatObr, IF( Empty( cM1 ), KS->datdo, KS2->datdo ), cM1 )

      IF fprint
         IF PRow() > 59
            FF
            Nstrana()
         ENDIF
         ? m
         ? " UKUPNO ZA", cBrdok
         @ PRow(), nCol1 SAY nKumKamBD PICT picdem

         ? " UKUPNO NA DAN", gDatObr, ":"
         @ PRow(), nCol1 SAY nKumKamSD PICT picdem
         ? m
      ENDIF

      nSKumKam += nKumKamSD

      SELECT kam_pripr

   ENDDO

   IF fprint

      IF PRow() > 54
         FF
         NStrana()
      ENDIF

      ? m
      ? " SVEUKUPNO KAMATA NA DAN " + DToC( gDatObr ) + ":"
      @ PRow(), PCol() SAY nOsnDug PICT picdem
      @ PRow(), ncol1  SAY nSKumKam PICT picdem
      ? m

      P_10CPI

      IF PRow() < 62 + dodatni_redovi_po_stranici()
         FOR i := 1 TO 62 + dodatni_redovi_po_stranici() - PRow()
            ?
         NEXT
      ENDIF

      _potpis()

      FF

   ENDIF

   IF !fprint
      nKamate := nSKumKam
   ENDIF

   RETURN nSKumKam



STATIC FUNCTION _potpis()

   ?  PadC( "     Obradio:                                 Direktor:    ", 80 )
   ?
   ?  PadC( "_____________________                    __________________", 80 )
   ?

   RETURN



STATIC FUNCTION NStrana( cTip, cVarObrac )

   IF cTip == NIL
      cTip := ""
   ENDIF

   IF cTip == ""
      ?
      P_10CPI
      ?? PadC( "- Strana " + Str( ++nStr, 4 ) + "-", 80 )
      ?
   ENDIF

   IF cTip == "1" .OR. cTip = ""

      IF gKumKam == "N"
         P_12CPI
      ELSE
         P_COND
      ENDIF

      ? m

      IF cVarObrac == "Z"
         ? "   Broj          Period      dana     ostatak       kamatna   Tip kam  Konform.    Iznos    " + IF( gKumKam == "D", "   kumulativ   ", "" )
         ? "  racuna                              racuna       osnovica   i stopa   koef       kamate   " + IF( gKumKam == "D", "    kamate     ", "" )
      ELSE
         ? "   Broj          Period      dana     ostatak       kamatna    Stopa       Iznos    " + IF( gKumKam == "D", "   kumulativ   ", "" )
         ? "  racuna                              racuna       osnovica                kamate   " + IF( gKumKam == "D", "    kamate     ", "" )
      ENDIF

      ? m

   ENDIF

   RETURN



STATIC FUNCTION IznosNaDan( nIznos, dTrazeni, dProsli, cM1 )

   // * dtrazeni = 30.06.98
   // * dprosli  = 15.05.94
   // * znaci: uracunaj sve denominacije od 15.05.94 do 30.06.98
   LOCAL nK := 1

   PushWA()
   SELECT KS
   GO TOP
   DO WHILE !Eof()
      IF DToS( dTrazeni ) < DToS( DatOd )
         EXIT
      ELSEIF DToS( dProsli ) >= DToS( DatOd )
         SKIP 1
         LOOP
      ENDIF
      IF field->den <> 0
         nK := nK * field->den
      ENDIF
      SKIP 1
   ENDDO
   PopWA()

   RETURN nIznos * nK
