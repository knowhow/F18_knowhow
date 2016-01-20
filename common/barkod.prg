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


FUNCTION roba_ocitaj_barkod( id_roba )

   LOCAL _t_area := Select()
   LOCAL _bk := ""

   IF !Empty( id_roba )
      SELECT roba
      SEEK id_roba
      _bk := field->barkod
      SELECT ( _t_area )
   ENDIF

   RETURN _bk



FUNCTION DodajBK( cBK )

   IF Empty( cBK ) .AND. IzFmkIni( "BARKOD", "Auto", "N", SIFPATH ) == "D" .AND. IzFmkIni( "BARKOD", "Svi", "N", SIFPATH ) == "D" .AND. ( Pitanje(, "Formirati Barkod ?", "N" ) == "D" )
      cBK := NoviBK_A()
   ENDIF

   RETURN .T.



FUNCTION KaLabelBKod()

   LOCAL cIBK
   LOCAL cPrefix
   LOCAL cSPrefix

   PRIVATE cKomLin

   O_SIFK
   O_SIFV
   O_ROBA
   SET ORDER TO TAG "ID"

   O_BARKOD
   O_KALK_PRIPR

   SELECT KALK_PRIPR

   PRIVATE aStampati := Array( RecCount() )

   GO TOP

   FOR i := 1 TO Len( aStampati )
      aStampati[ i ] := "D"
   NEXT

   ImeKol := { { "IdRoba", {|| IdRoba } }, { "Kolicina", {|| Transform( Kolicina, picv ) } },{ "Stampati?", {|| IF( aStampati[ RecNo() ] == "D", "-> DA <-", "      NE" ) } } }

   Kol := {}
   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   Box(, 20, 50 )
   ObjDbedit( "PLBK", 20, 50, {|| KaEdPrLBK() }, "<SPACE> markiranje             Í<ESC> kraj", "Priprema za labeliranje bar-kodova...", .T., , , , 0 )
   BoxC()

   nRezerva := 0

   cLinija2 := PadR( "Uvoznik:" + gNFirma, 45 )

   Box(, 4, 75 )
   @ m_x + 0, m_y + 25 SAY " LABELIRANJE BAR KODOVA "
   @ m_x + 2, m_y + 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva >= 0 PICT "99"
   @ m_x + 3, m_y + 2 SAY "Linija 2  :" GET cLinija2
   READ
   ESC_BCR
   BoxC()

   cPrefix := IzFmkIni( "Barkod", "Prefix", "", SIFPATH )
   cSPrefix := pitanje(, "Stampati barkodove koji NE pocinju sa +'" + cPrefix + "' ?", "N" )

   SELECT BARKOD
   my_dbf_zap()

   SELECT KALK_PRIPR
   GO TOP

   DO WHILE !Eof()
      IF aStampati[ RecNo() ] == "N"
         SKIP 1
         LOOP
      ENDIF
      SELECT ROBA
      HSEEK KALK_PRIPR->idroba
      IF Empty( barkod ) .AND. ( IzFmkIni( "BarKod", "Auto", "N", SIFPATH ) == "D" )
         PRIVATE cPom := IzFmkIni( "BarKod", "AutoFormula", "ID", SIFPATH )
         // kada je barkod prazan, onda formiraj sam interni barkod
         cIBK := IzFmkIni( "BARKOD", "Prefix", "", SIFPATH ) + &cPom
         IF IzFmkIni( "BARKOD", "EAN", "", SIFPATH ) == "13"
            cIBK := NoviBK_A()
         ENDIF
         PushWa()
         SET ORDER TO TAG "BARKOD"
         SEEK cIBK
         IF Found()
            PopWa()
            MsgBeep( "Prilikom formiranja internog barkoda##vec postoji kod: " + cIBK + "??##" + "Moracete za artikal " + kalk_pripr->idroba + " sami zadati jedinstveni barkod !" )
            REPLACE barkod WITH "????"
         ELSE
            PopWa()
            REPLACE barkod WITH cIBK
         ENDIF
      ENDIF
      IF cSprefix == "N"
         // ne stampaj koji nemaju isti prefix
         IF Left( barkod, Len( cPrefix ) ) != cPrefix
            SELECT kalk_pripr
            SKIP
            LOOP
         ENDIF
      ENDIF

      SELECT BARKOD
      FOR i := 1 TO kalk_pripr->kolicina + IF( kalk_pripr->kolicina > 0, nRezerva, 0 )
         APPEND BLANK
         REPLACE id WITH kalk_pripr->idRoba
         REPLACE naziv WITH Trim( ROBA->naz ) + " (" + Trim( ROBA->jmj ) + ")"
         REPLACE l1 WITH DToC( kalk_pripr->datdok ) + ", " + Trim( kalk_pripr->( idfirma + "-" + idvd + "-" + brdok ) )
         REPLACE l2 WITH cLinija2
         REPLACE vpc WITH ROBA->vpc
         REPLACE mpc WITH ROBA->mpc
         REPLACE barkod WITH roba->barkod
      NEXT
      SELECT kalk_pripr
      SKIP 1
   ENDDO
   my_close_all_dbf()

   f18_rtm_print( "barkod", "barkod", "1" )

   my_close_all_dbf()

   RETURN


/*! \fn KaEdPrLBK()
 *  \brief Obrada dogadjaja u browse-u tabele "Priprema za labeliranje bar-kodova"
 *  \sa KaLabelBKod()
 */

FUNCTION KaEdPrLBK()

   // {
   IF Ch == Asc( ' ' )
      IF aStampati[ RecNo() ] == "N"
         aStampati[ RecNo() ] := "D"
      ELSE
         aStampati[ RecNo() ] := "N"
      ENDIF
      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT
// }

/*! \fn FaLabelBKod()
 *  \brief Priprema za labeliranje barkodova
 *  \todo Spojiti
 */
FUNCTION FaLabelBKod()

   // {
   LOCAL cIBK, cPrefix, cSPrefix

   O_SIFK
   O_SIFV

   O_ROBA
   SET ORDER TO TAG "ID"
   O_BARKOD
   O_FAKT_PRIPR

   SELECT fakt_pripr

   PRIVATE aStampati := Array( RecCount() )

   GO TOP

   FOR i := 1 TO Len( aStampati )
      aStampati[ i ] := "D"
   NEXT

   ImeKol := { { "IdRoba",      {|| IdRoba  }      },;
      { "Kolicina",    {|| Transform( Kolicina, Pickol ) }     },;
      { "Stampati?",   {|| IF( aStampati[ RecNo() ] == "D", "-> DA <-", "      NE" ) }      } ;
      }

   Kol := {}; FOR i := 1 TO Len( ImeKol ); AAdd( Kol, i ); NEXT
   Box(, 20, 50 )
   ObjDbedit( "PLBK", 20, 50, {|| KaEdPrLBK() }, "<SPACE> markiranjeÍÍÍÍÍÍÍÍÍÍÍÍÍÍ<ESC> kraj", "Priprema za labeliranje bar-kodova...", .T., , , , 0 )
   BoxC()

   nRezerva := 0

   cLinija1 := PadR( "Proizvoljan tekst", 45 )
   cLinija2 := PadR( "Uvoznik:" + gNFirma, 45 )
   Box(, 4, 75 )
   @ m_x + 0, m_y + 25 SAY " LABELIRANJE BAR KODOVA "
   @ m_x + 2, m_y + 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva >= 0 PICT "99"
   IF IzFmkIni( "Barkod", "BrDok", "D", SIFPATH ) == "N"
      @ m_x + 3, m_y + 2 SAY "Linija 1  :" GET cLinija1
   ENDIF
   @ m_x + 4, m_y + 2 SAY "Linija 2  :" GET cLinija2
   READ
   ESC_BCR
   BoxC()

   cPrefix := IzFmkIni( "Barkod", "Prefix", "", SIFPATH )
   cSPrefix := pitanje(, "Stampati barkodove koji NE pocinju sa +'" + cPrefix + "' ?", "N" )

   SELECT BARKOD
   my_dbf_zap()

   SELECT fakt_pripr
   GO TOP
   DO WHILE !Eof()


      IF aStampati[ RecNo() ] == "N"; SKIP 1; loop; ENDIF
      SELECT ROBA
      HSEEK fakt_pripr->idroba
      IF Empty( barkod ) .AND. (  IzFmkIni( "BarKod", "Auto", "N", SIFPATH ) == "D" )
         PRIVATE cPom := IzFmkIni( "BarKod", "AutoFormula", "ID", SIFPATH )
         // kada je barkod prazan, onda formiraj sam interni barkod

         cIBK := IzFmkIni( "BARKOD", "Prefix", "", SIFPATH ) + &cPom

         IF IzFmkIni( "BARKOD", "EAN", "", SIFPATH ) == "13"
            cIBK := NoviBK_A()
         ENDIF

         PushWa()
         SET ORDER TO TAG "BARKOD"
         SEEK cIBK
         IF Found()
            PopWa()
            MsgBeep( ;
               "Prilikom formiranja internog barkoda##vec postoji kod: "  + cIBK + "??##" + ;
               "Moracete za artikal " + fakt_pripr->idroba + " sami zadati jedinstveni barkod !" )
            REPLACE barkod WITH "????"
         ELSE
            PopWa()
            REPLACE barkod WITH cIBK
         ENDIF

      ENDIF
      IF cSprefix == "N"
         // ne stampaj koji nemaju isti prefix
         IF Left( barkod, Len( cPrefix ) ) != cPrefix
            SELECT fakt_pripr
            SKIP
            LOOP
         ENDIF
      ENDIF


      SELECT BARKOD
      FOR  i := 1  TO  fakt_pripr->kolicina + IF( fakt_pripr->kolicina > 0, nRezerva, 0 )

         APPEND BLANK
         REPLACE ID       WITH  KonvZnWin( fakt_pripr->idroba )

         IF IzFmkIni( "Barkod", "BrDok", "D", SIFPATH ) == "D"
            REPLACE L1 WITH KonvZnWin( DToC( fakt_pripr->datdok ) + ", " + Trim( fakt_pripr->( idfirma + "-" + idtipdok + "-" + brdok ) ) )
         ELSE
            REPLACE L1 WITH KonvZnWin( cLinija1 )
         ENDIF

         REPLACE L2 WITH KonvZnWin( cLinija2 ), VPC WITH ROBA->vpc, MPC WITH ROBA->mpc, BARKOD WITH roba->barkod

         IF IzFmkIni( "BarKod", "JMJ", "D", SIFPATH ) == "N"
            REPLACE NAZIV WITH  KonvZnWin( Trim( ROBA->naz ) )
         ELSE
            REPLACE NAZIV WITH  KonvZnWin( Trim( ROBA->naz ) + " (" + Trim( ROBA->jmj ) + ")" )
         ENDIF

      NEXT
      SELECT FAKT_PRIPR
      SKIP 1

   ENDDO

   my_close_all_dbf()

   f18_rtm_print( "barkod", "barkod", "1" )

   my_close_all_dbf()

   RETURN



/*! \fn FaEdPrLBK()
 *  \brief Priprema barkodova
 */

FUNCTION FaEdPrLBK()

   IF Ch == Asc( ' ' )
      aStampati[ RecNo() ] := IF( aStampati[ RecNo() ] == "N", "D", "N" )
      RETURN DE_REFRESH
   ENDIF

   RETURN DE_CONT


/*!
 @function    NoviBK_A
 @abstract    Novi Barkod - automatski
 @discussion  Ova fja treba da obezbjedi da program napravi novi interni barkod
              tako sto ce pogledati Barkod/Prefix iz fmk.ini i naci zadnji

       dodjeljen barkod. Njeno ponasanje ovisno je op parametru
              Barkod / EAN ; Za EAN=13 vraca trinaestocifreni EANKOD,
              Kada je EAN<>13 vraca broj duzine DuzSekvenca BEZ PREFIXA
*/
FUNCTION NoviBK_A( cPrefix )

   LOCAL cPom, xRet
   LOCAL nDuzPrefix, nDuzSekvenca, cEAN

   PushWA()

   nCount := 1

   IF cPrefix = NIL
      cPrefix := IzFmkIni( "Barkod", "Prefix", "", SIFPATH )
   ENDIF
   cPrefix := Trim( cPrefix )
   nDuzPrefix := Len( cPrefix )

   nDuzSekv :=  Val ( IzFmkIni( "Barkod", "DuzSekvenca", "", SIFPATH ) )
   cEAN := IzFmkIni( "Barkod", "EAN", "", SIFPATH )

   cRez := PadL(  AllTrim( Str( 1 ) ), nDuzSekv, "0" )
   IF cEAN = "13"
      cRez := cPrefix + cRez + KEAN13( cRez )
      // 0387202   000001   6
   ELSE
      cRez := cRez
   ENDIF

   SET FILTER TO // pocisti filter
   SET ORDER TO TAG "BARKOD"
   SEEK cPrefix + "á" // idi na kraj
   SKIP -1 // lociraj se na zadnji slog iz grupe prefixa
   IF Left( barkod, nDuzPrefix ) == cPrefix
      IF cEAN == "13"
         cPom :=   AllTrim ( Str( Val ( SubStr( BARKOD, nDuzPrefix + 1, nDuzSekv ) ) + 1 ) )
         cPom :=   PadL( cPom, nDuzSekv, "0" )
         cRez :=   cPrefix + cPom
         cRez :=   cRez + KEAN13( cRez )
      ELSE
         // interni barkod varijanta planika koristicemo Code128 standard
         cPom :=   AllTrim ( Str( Val ( SubStr( BARKOD, nDuzPrefix + 1, nDuzSekv ) ) + 1 ) )
         cPom :=   PadL( cPom, nDuzSekv, "0" )
         cRez :=   cPom  // Prefix dio ce dodati glavni alogritam
      ENDIF
   ENDIF

   PopWa()

   RETURN cRez


/*!
 @function   KEAN13 ( ckod)
 @abstract   Uvrdi ean13 kontrolni broj
 @discussion xx
 @param      ckod   kod od dvanaest mjesta
*/
FUNCTION KEAN13( cKod )

   LOCAL n2, n4
   LOCAL n1 := Val( SubStr( cKod, 2, 1 ) ) + Val( SubStr( cKod, 4, 1 ) ) + Val( SubStr( ckod, 6, 1 ) ) + Val( SubStr ( ckod, 8, 1 ) ) + Val( SubStr( ckod, 10, 1 ) ) + Val( SubStr( ckod, 12, 1 ) )
   LOCAL n3 := Val( SubStr( cKod, 1, 1 ) ) + Val( SubStr( cKod, 3, 1 ) ) + Val( SubStr( ckod, 5, 1 ) ) + Val( SubStr ( ckod, 7, 1 ) ) + Val( SubStr( ckod, 9, 1 ) ) + Val( SubStr( ckod, 11, 1 ) )

   n2 := n1 * 3

   n4 := n2 + n3
   n4 := n4 % 10
   IF n4 = 0
      RETURN  "0"   // n5
   ELSE
      RETURN  Str( 10 - n4, 1 )   // n5
   ENDIF




   // --------------------------------------------------------------------------------------
   // provjerava i pozicionira sifranik artikala na polje barkod po trazeno uslovu
   // --------------------------------------------------------------------------------------

FUNCTION barkod( cId )

   LOCAL cIdRoba := ""
   LOCAL _barkod := ""

   gOcitBarCod := .F.

   SELECT roba

   IF !Empty( cId )

      SET ORDER TO TAG "BARKOD"
      GO TOP
      SEEK cId

      IF Found() .AND. PadR( cId, 13, "" ) == field->barkod
         cId := field->id
         gOcitBarCod := .T.
         _barkod := AllTrim( field->barkod )
      ENDIF

   ENDIF

   cId := PadR( cId, 10 )

   RETURN _barkod



// -------------------------------------------------------------------------------------
// ova funkcija vraca tezinu na osnovu tezinskog barkod-a
// znaci samo je izracuna
// -------------------------------------------------------------------------------------
FUNCTION tezinski_barkod_get_tezina( barkod, tezina )

   LOCAL _tb := param_tezinski_barkod()
   LOCAL _tb_prefix := AllTrim( fetch_metric( "barkod_prefiks_tezinskog_barkoda", nil, "" ) )
   LOCAL _tb_barkod, _tb_tezina
   LOCAL _bk_len := fetch_metric( "barkod_tezinski_duzina_barkoda", nil, 0 )
   LOCAL _tez_len := fetch_metric( "barkod_tezinski_duzina_tezina", nil, 0 )
   LOCAL _tez_div := fetch_metric( "barkod_tezinski_djelitelj", nil, 10000 )
   LOCAL _val_tezina := 0
   LOCAL _a_prefix
   LOCAL _i

   IF _tb == "N"
      RETURN .F.
   ENDIF

   // matrica sa prefiksima...
   // "55"
   // "21"
   // itd...
   _a_prefix := TokToNiz( _tb_prefix, ";" )

   IF AScan( _a_prefix, {|var| var == PadR( barkod, Len( var ) ) } ) == 0
      RETURN .F.
   ENDIF

   // odrezi ocitano na 7, tu je barkod koji trebam pretraziti
   _tb_barkod := Left( barkod, _bk_len )

   IF Len( AllTrim( _tb_barkod ) ) <> _bk_len
      // ne slaze se sa tezinskim barkodom... ovo je laznjak..
      RETURN .F.
   ENDIF

   _tb_tezina := PadR( Right( barkod, _tez_len ), _tez_len - 1 )

   // sredi mi i tezinu...
   IF !Empty( _tb_tezina )
      _val_tezina := Val( _tb_tezina )
      tezina := Round( ( _val_tezina / _tez_div ), 4 )
      RETURN .T.
   ENDIF

   RETURN .F.


// --------------------------------------------------------------------------------------
// provjerava tezinski barod
// --------------------------------------------------------------------------------------
FUNCTION tezinski_barkod( id, tezina, pop_push )

   LOCAL _ocitao := .F.
   LOCAL _tb := param_tezinski_barkod()
   LOCAL _tb_prefix := AllTrim( fetch_metric( "barkod_prefiks_tezinskog_barkoda", nil, "" ) )
   LOCAL _tb_barkod, _tb_tezina
   LOCAL _bk_len := fetch_metric( "barkod_tezinski_duzina_barkoda", nil, 0 )
   LOCAL _tez_len := fetch_metric( "barkod_tezinski_duzina_tezina", nil, 0 )
   LOCAL _tez_div := fetch_metric( "barkod_tezinski_djelitelj", nil, 10000 )
   LOCAL _val_tezina := 0
   LOCAL _a_prefix
   LOCAL _i

   IF pop_push == NIL
      pop_push := .T.
   ENDIF

   gOcitBarCod := _ocitao

   IF _tb == "N"
      RETURN _ocitao
   ENDIF

   IF Empty( id )
      RETURN _ocitao
   ENDIF

   // matrica sa prefiksima...
   // "55"
   // "21"
   // itd...
   _a_prefix := TokToNiz( _tb_prefix, ";" )

   IF AScan( _a_prefix, {|var| var == PadR( id, Len( var ) ) } ) <> 0
      // ovo je ok...
   ELSE
      RETURN _ocitao
   ENDIF

   // odrezi ocitano na 7, tu je barkod koji trebam pretraziti
   _tb_barkod := Left( id, _bk_len )
   _tb_tezina := PadR( Right( id, _tez_len ), _tez_len - 1 )

   IF pop_push
      PushWa()
   ENDIF

   SELECT roba
   SET ORDER TO TAG "BARKOD"
   SEEK _tb_barkod

   IF Found() .AND. AllTrim( _tb_barkod ) == AllTrim( field->barkod )

      id := roba->id
      _ocitao := .T.

      gOcitBarCod := _ocitao

      // sredi mi i tezinu...
      IF !Empty( _tb_tezina )

         _val_tezina := Val( _tb_tezina )
         tezina := Round( ( _val_tezina / _tez_div ), 4 )

      ENDIF

   ENDIF

   id := PadR( id, 10 )

   SELECT roba
   SET ORDER TO TAG "ID"

   IF pop_push
      PopWa()
   ENDIF

   RETURN _ocitao
