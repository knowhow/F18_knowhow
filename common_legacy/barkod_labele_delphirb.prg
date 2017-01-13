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


// -----------------------------------------
// funkcija za labeliranje barkodova
// -----------------------------------------
FUNCTION label_bkod()

   LOCAL cIBK
   LOCAL cPrefix
   LOCAL cSPrefix
   LOCAL cBoxHead
   LOCAL cBoxFoot
   LOCAL lDelphi := .T.
   PRIVATE cKomLin
   PRIVATE Kol
   PRIVATE ImeKol

   O_SIFK
   O_SIFV
   O_PARTN
   O_ROBA
   SET ORDER TO TAG "ID"
   O_BARKOD
   O_FAKT_PRIPR

   SELECT FAKT_PRIPR

   PRIVATE aStampati := Array( RecCount() )

   GO TOP

   FOR i := 1 TO Len( aStampati )
      aStampati[ i ] := "D"
   NEXT

   // setuj kolone za pripremu...
   set_a_kol( @ImeKol, @Kol )

   cBoxHead := "<SPACE> markiranje    |    <ESC> kraj"
   cBoxFoot := "Priprema za labeliranje bar-kodova..."

   Box(, 20, 50 )

   my_db_edit( "PLBK", 20, 50, {|| key_handler() }, cBoxHead, cBoxFoot, .T., , , , 0 )

   BoxC()

   IF lDelphi
      print_delphi_label( aStampati )
   ELSE
      // stampanje deklaracija...
      // label_2_deklar(aStampati)
   ENDIF

   my_close_all_dbf()

   RETURN .T.


// --------------------------------
// nastimaj pointer na partnera...
// --------------------------------
FUNCTION seek_partner( cPartner )

   SELECT partn
   SET ORDER TO TAG "ID"
   HSEEK cPartner

   RETURN


// -----------------------------------------------------
// setovanje kolone opcije pregleda labela....
// -----------------------------------------------------
STATIC FUNCTION set_a_kol( aImeKol, aKol )

   LOCAL nI

   aImeKol := {}
   aKol := {}

   AAdd( aImeKol, { "IdRoba", {|| IdRoba } } )
   AAdd( aImeKol, { "Kolicina", {|| Transform( Kolicina, "99999999.9" ) } } )
   AAdd( aImeKol, { "Stampati?", {|| bk_stamp_dn( aStampati[ RecNo() ] ) } } )

   aKol := {}
   FOR nI := 1 TO Len( aImeKol )
      AAdd( aKol, nI )
   NEXT

   RETURN


// --------------------------------
// prikaz stampati ili ne stampati
// --------------------------------
STATIC FUNCTION bk_stamp_dn( cDN )

   LOCAL cRet := ""

   IF cDN == "D"
      cRet := "-> DA <-"
   ELSE
      cRet := "      NE"
   ENDIF

   RETURN cRet



// --------------------------------
// Obrada dogadjaja u browse-u
// tabele "Priprema za labeliranje
// bar-kodova"
// --------------------------------
STATIC FUNCTION key_handler()

   IF Ch == Asc( ' ' )

      IF aStampati[ RecNo() ] == "N"
         aStampati[ RecNo() ] := "D"
      ELSE
         aStampati[ RecNo() ] := "N"
      ENDIF

      RETURN DE_REFRESH

   ENDIF

   RETURN DE_CONT



// ------------------------------------------------
// parametri labeliranja i barkod-ova
// ------------------------------------------------
FUNCTION label_params()

   LOCAL _box_x, _box_y
   LOCAL _x := 1
   LOCAL _br_dok := fetch_metric( "labeliranje_ispis_brdok", nil, "N" )
   LOCAL _jmj := fetch_metric( "labeliranje_ispis_jmj", nil, "N" )
   LOCAL _prefix := fetch_metric( "labeliranje_barkod_prefix", nil, Space( 10 ) )
   LOCAL _auto_gen := fetch_metric( "labeliranje_barkod_automatsko_generisanje", nil, "N" )
   LOCAL _auto_formula := fetch_metric( "labeliranje_barkod_auto_formula", nil, Space( 10 ) )
   LOCAL _ean_code := fetch_metric( "labeliranje_barkod_auto_ean_kod", nil, Space( 10 ) )
   LOCAL _tb := fetch_metric( "barkod_tezinski_barkod", nil, "N" )
   LOCAL _tb_prefix := PadR( fetch_metric( "barkod_prefiks_tezinskog_barkoda", nil, Space( 100 ) ), 100 )
   LOCAL _bk_len := fetch_metric( "barkod_tezinski_duzina_barkoda", nil, 0 )
   LOCAL _tez_len := fetch_metric( "barkod_tezinski_duzina_tezina", nil, 0 )
   LOCAL _tez_div := fetch_metric( "barkod_tezinski_djelitelj", nil, 10000 )

   _box_x := 20
   _box_y := 70

   Box(, _box_x, _box_y )

   @ m_x + _x, m_y + 2 SAY "*** Barkod stampa, podesenja"

   ++ _x
   ++ _x

   @ m_x + _x, m_y + 2 SAY "Prikaz broja dokumenta na naljepnici    (D/N)" GET _br_dok VALID _br_dok $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Prikaz jedinice mjere kod opisa artikla (D/N)" GET _jmj VALID _jmj $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Barkod prefix" GET _prefix

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Automatsko generisanje barkod-a (D/N)" GET _auto_gen VALID _auto_gen $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Automatsko generisanje, auto formula:" GET _auto_formula
   @ m_x + _x, Col() + 1 SAY "EAN:" GET _ean_code

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Koristenje tezinskog barkod-a (D/N)" GET _tb VALID _tb $ "DN" PICT "@!"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Prefiks tezinskog barkod-a" GET _tb_prefix PICT "@S30"

   ++ _x

   @ m_x + _x, m_y + 2 SAY "Tezinski: duzina barkod-a" GET _bk_len PICT "99"
   @ m_x + _x, Col() + 2 SAY "duzina tezine:" GET _tez_len PICT "99"
   @ m_x + _x, Col() + 2 SAY "djelitelj:" GET _tez_div PICT "99999999"

   READ

   BoxC()

   IF LastKey() <> K_ESC

      // save params
      set_metric( "labeliranje_ispis_brdok", nil, _br_dok )
      set_metric( "labeliranje_ispis_jmj", nil, _jmj )
      set_metric( "labeliranje_barkod_prefix", nil, _prefix )
      set_metric( "labeliranje_barkod_automatsko_generisanje", nil, _auto_gen )
      set_metric( "labeliranje_barkod_auto_formula", nil, _auto_formula )
      set_metric( "labeliranje_barkod_auto_ean_kod", nil, _ean_code )
      set_metric( "barkod_tezinski_barkod", nil, _tb )
      set_metric( "barkod_prefiks_tezinskog_barkoda", nil, AllTrim( _tb_prefix ) )
      set_metric( "barkod_tezinski_duzina_barkoda", nil, _bk_len )
      set_metric( "barkod_tezinski_duzina_tezina", nil, _tez_len )
      set_metric( "barkod_tezinski_djelitelj", nil, _tez_div )

   ENDIF

   RETURN




// -----------------------------------
// labeliranje delphi
// -----------------------------------
STATIC FUNCTION print_delphi_label( aStampati, modul )

   LOCAL nRezerva
   LOCAL cIBK
   LOCAL cLinija1
   LOCAL cLinija2
   LOCAL cPrefix
   LOCAL cSPrefix
   LOCAL nRobNazLen
   LOCAL cIdTipDok
   LOCAL lBKBrDok := .F.
   LOCAL lBKJmj := .F.
   LOCAL cBrDok

   IF modul == NIL
      modul := "FAKT"
   ENDIF

   IF fetch_metric( "labeliranje_ispis_jmj", nil, "N" ) == "D"
      lBKJmj := .T.
   ENDIF

   IF fetch_metric( "labeliranje_ispis_brdok", nil, "N" ) == "D"
      lBKBrDok := .T.
   ENDIF

   IF modul == "KALK"
      cIdTipDok := "IDVD"
   ELSE
      cIdTipDok := "IDTIPDOK"
   ENDIF

   nRezerva := 0

   cLinija1 := PadR( "Proizvoljan tekst", 45 )
   cLinija2 := PadR( "Uvoznik:" + AllTrim( self_organizacija_naziv() ), 45 )

   Box(, 4, 75 )

   @ m_x + 0, m_y + 25 SAY " LABELIRANJE BAR KODOVA "

   @ m_x + 2, m_y + 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva >= 0 PICT "99"

   IF !lBKBrDok
      @ m_x + 3, m_y + 2 SAY "Linija 1  :" GET cLinija1
   ENDIF

   @ m_x + 4, m_y + 2 SAY "Linija 2  :" GET cLinija2

   READ

   ESC_BCR

   BoxC()

   cPrefix := AllTrim( fetch_metric( "labeliranje_barkod_prefix", nil, "" ) )
   cSPrefix := "N"

   IF !Empty( cPrefix )
      cSPrefix := Pitanje(, "Stampati barkodove koji NE pocinju sa +'" + cPrefix + "' ?", "N" )
   ENDIF

   SELECT BARKOD
   my_dbf_zap()

   SELECT FAKT_PRIPR
   GO TOP

   DO WHILE !Eof()

      IF aStampati[ RecNo() ] == "N"
         SKIP 1
         LOOP
      ENDIF

      SELECT ROBA
      HSEEK FAKT_PRIPR->idroba

      IF Empty( field->barkod ) .AND. fetch_metric( "labeliranje_barkod_automatsko_generisanje", nil, "N" )

         PRIVATE cPom := AllTrim( fetch_metric( "labeliranje_barkod_auto_formula", nil, "" ) )

         // kada je barkod prazan, onda formiraj sam interni barkod
         cIBK := AllTrim( fetch_metric( "labeliranje_barkod_prefix", nil, "" ) ) + &cPom

         IF AllTrim( fetch_metric( "labeliranje_barkod_auto_ean_kod", nil, "" ) ) == "13"
            cIBK := NoviBK_A()
         ENDIF

         PushWA()

         SET ORDER TO TAG "BARKOD"
         SEEK cIBK

         IF Found()
            PopWa()
            MsgBeep( "Prilikom formiranja internog barkoda##vec postoji kod: " + cIBK + "??##" + "Moracete za artikal " + fakt_pripr->idroba + " sami zadati jedinstveni barkod !" )
            REPLACE barkod WITH "????"
         ELSE
            PopWa()
            REPLACE barkod WITH cIBK
         ENDIF
      ENDIF

      IF cSprefix == "N"
         // ne stampaj koji nemaju isti prefix
         IF Left( field->barkod, Len( cPrefix ) ) != cPrefix
            SELECT fakt_pripr
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT BARKOD

      FOR i := 1 TO fakt_pripr->kolicina + IF( fakt_pripr->kolicina > 0, nRezerva, 0 )

         APPEND BLANK
         REPLACE id WITH ( fakt_pripr->idRoba )

         IF lBKBrDok
            cBrDok := Trim( fakt_pripr->( idfirma + "-" + &cIdTipDok + "-" + brdok ) )
            REPLACE l1 WITH ( DToC( fakt_pripr->datdok ) + ", " + cBrDok )
         ELSE
            REPLACE l1 WITH ( cLinija1 )
         ENDIF

         REPLACE l2 WITH ( cLinija2 )

         REPLACE vpc WITH ROBA->vpc
         REPLACE mpc WITH ROBA->mpc
         REPLACE barkod WITH roba->barkod

         nRobNazLen := Len( roba->naz )

         IF !lBKJmj
            REPLACE naziv WITH ( Trim( Left( ROBA->naz, nRobNazLen ) ) )
         ELSE
            REPLACE naziv WITH ( Trim( Left( ROBA->naz, nRobNazLen ) ) + " (" + Trim( ROBA->jmj ) + ")" )
         ENDIF
      NEXT

      SELECT FAKT_PRIPR
      SKIP 1

   ENDDO

   SELECT ( F_BARKOD )
   USE

   my_close_all_dbf()

   f18_rtm_print( "barkod", "barkod", "1" )

   RETURN
