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


#include "ld.ch"




FUNCTION KumPrim( cIdRadn, cIdPrim )

   LOCAL j := 0, nVrati := 0, nOdGod := 0, nDoGod := 0

   cPom77 := cIdPrim
   IF cIdRadn == NIL; cIdRadn := ""; ENDIF
   SELECT LD
   PushWA()
   SET ORDER TO TAG ( TagVO( "4" ) )
   GO BOTTOM; nDoGod := godina
   GO TOP; nOdGod := godina
   FOR j := nOdGod TO nDoGod
      GO TOP
      SEEK Str( j, 4 ) + cIdRadn
      DO WHILE godina == j .AND. cIdRadn == IdRadn
         nVrati += i&cPom77
         SKIP 1
      ENDDO
   NEXT
   SELECT LD
   PopWA()

   RETURN nVrati




STATIC FUNCTION _create_ld_tmp()

   LOCAL _i, _struct
   LOCAL _table := "_ld"
   LOCAL _ret := .T.

   // pobrisi tabelu
   IF File( my_home() + _table + ".dbf" )
      FErase( my_home() + _table + ".dbf" )
   ENDIF

   _struct := LD->( dbStruct() )

   FOR _i := 1 TO Len( _struct )
      IF _struct[ _i, 2 ] == "N" .AND. !( Upper( AllTrim( _struct[ _i, 1 ] ) ) $ "GODINA#MJESEC" )
         _struct[ _i, 3 ] += 4
      ENDIF
   NEXT

   dbCreate( my_home() + _table + ".dbf", _struct )

   IF !File( my_home() + _table + ".dbf" )
      MsgBeep( "Ne postoji " + _table + ".dbf !!!" )
      _ret := .F.
   ENDIF

   RETURN _ret




FUNCTION SortPrez( cId )

   LOCAL cVrati := ""
   LOCAL nArr := Select()

   SELECT F_RADN
   IF !Used()
      O_RADN
   ENDIF

   HSEEK cId
   cVrati := naz + ime + imerod + id

   SELECT ( nArr )

   RETURN cVrati


FUNCTION SortIme( cId )

   LOCAL cVrati := ""
   LOCAL nArr := Select()

   SELECT( F_RADN )
   IF !Used()
      reopen_exclusive( "ld_radn" )
   ENDIF
   SET ORDER TO TAG "1"

   HSEEK cId

   cVrati := ime + naz + imerod + id

   SELECT ( nArr )

   RETURN cVrati


FUNCTION SortVar( cId )

   LOCAL cVrati := ""
   LOCAL nArr := Select()

   O_RADKR
   SEEK cId
   SELECT RJES
   SEEK RADKR->naosnovu + RADKR->idradn
   cVrati := varijanta
   SELECT ( nArr )

   RETURN cVrati



FUNCTION NLjudi()
   RETURN "(" + AllTrim( Str( opsld->ljudi ) ) + ")"


FUNCTION ImaUOp( cPD, cSif )

   LOCAL lVrati := .T.

   IF ops->( FieldPos( "DNE" ) ) <> 0
      IF Upper( cPD ) = "P"
         lVrati := ! ( cSif $ OPS->pne )
      ELSE
         lVrati := ! ( cSif $ OPS->dne )
      ENDIF
   ENDIF

   RETURN lVrati


FUNCTION PozicOps( cSR )

   LOCAL nArr := Select()
   LOCAL cO := ""

   IF cSR == "1"
      // opstina stanovanja
      cO := radn->idopsst
   ELSEIF cSR == "2"
      // opstina rada
      cO := radn->idopsrad
   ELSE
      // " "
      cO := Chr( 255 )
   ENDIF

   SELECT ( F_OPS )

   IF !Used()
      O_OPS
   ENDIF

   SEEK cO

   SELECT ( nArr )

   RETURN

FUNCTION ScatterS( cG, cM, cJ, cR, cPrefix )

   PRIVATE cP7 := cPrefix

   IF cPrefix == NIL
      Scatter()
   ELSE
      Scatter( cPrefix )
   ENDIF
   SKIP 1
   DO WHILE !Eof() .AND. mjesec = cM .AND. godina = cG .AND. idradn = cR .AND. ;
         idrj = cJ
      IF cPrefix == NIL
         FOR i := 1 TO cLDPolja
            cPom    := PadL( AllTrim( Str( i ) ), 2, "0" )
            _i&cPom += i&cPom
         NEXT
         _uneto   += uneto
         _uodbici += uodbici
         _uiznos  += uiznos
      ELSE
         FOR i := 1 TO cLDPolja
            cPom    := PadL( AllTrim( Str( i ) ), 2, "0" )
            &cP7.i&cPom += i&cPom
         NEXT
         &cP7.uneto   += uneto
         &cP7.uodbici += uodbici
         &cP7.uiznos  += uiznos
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   RETURN

FUNCTION IspisObr()

   LOCAL cVrati := ""

   IF lViseObr .AND. !Empty( cObracun )
      cVrati := "/" + cObracun
   ENDIF

   RETURN cVrati


FUNCTION Obr2_9()
   RETURN lViseObr .AND. !Empty( cObracun ) .AND. cObracun <> "1"




FUNCTION SvratiUFajl()

   FErase( PRIVPATH + "xoutf.txt" )
   SET PRINTER TO ( PRIVPATH + "xoutf.txt" )

   RETURN


FUNCTION U2Kolone( nViska )

   LOCAL cImeF, nURed

   IF "U" $ Type( "cLMSK" ); cLMSK := ""; ENDIF
   nSirKol := 80 + Len( cLMSK )
   cImeF := PRIVPATH + "xoutf.txt"
   nURed := BrLinFajla( cImeF )
   aR    := DioFajlaUNiz( cImeF, 1, nURed - nViska, nURed )
   aRPom := DioFajlaUNiz( cImeF, nURed - nViska + 1, nViska, nURed )
   aR[ 1 ] = PadR( aR[ 1 ], nSirKol ) + aR[ 1 ]
   aR[ 2 ] = PadR( aR[ 2 ], nSirKol ) + aR[ 2 ]
   aR[ 3 ] = PadR( aR[ 3 ], nSirKol ) + aR[ 3 ]
   aR[ 4 ] = PadR( aR[ 4 ], nSirKol ) + aR[ 4 ]
   FOR i := 1 TO Len( aRPom )
      aR[ i + 4 ] = PadR( aR[ i + 4 ], nSirKol ) + aRPom[ i ]
   NEXT

   RETURN aR


FUNCTION SetRadnGodObr()
   RETURN

STATIC FUNCTION DioFajlaUNiz( cImeF, nPocRed, nUkRedova, nUkRedUF )

   LOCAL aVrati := {}, nTekRed := 0, nOfset := 0, aPom := {}

   IF nUkRedUF == nil; nUkRedUF := BrLinFajla( cImeF ); ENDIF
   FOR nTekRed := 1 TO nUkRedUF
      aPom := SljedLin( cImeF, nOfset )
      IF nTekRed >= nPocRed .AND. nTekRed < nPocRed + nUkRedova
         AAdd( aVrati, aPom[ 1 ] )
      ENDIF
      IF nTekRed >= nPocRed + nUkRedova - 1
         EXIT
      ENDIF
      nOfset := aPom[ 2 ]
   NEXT

   RETURN aVrati
