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

/*
FUNCTION KorekNC()

   LOCAL dDok := Date()
   LOCAL nPom := 0
   LOCAL cPom2
   PRIVATE cMagac := "1310   "

   IF !spec_funkcije_sifra( "SIGMAPRN" )
      RETURN
   ENDIF

   o_konto()
   IF !VarEdit( { { "Magacinski konto", "cMagac", "P_Konto(@cMagac)",, } }, 12, 5, 16, 74, ;
         'DEFINISANJE MAGACINA NA KOME CE BITI IZVRSENE PROMJENE', ;
         "B1" )
      closeret
   ENDIF

   o_kalk_pripr()
   -- o_kalk()
   GO TOP

   nCount := 0

   DO WHILE !Eof()
      IF ( nc == 0 .AND. !idvd $ "11#12" .OR. fcj == 0 .AND. idvd $ "11#12" ) .AND. mkonto == cMagac
         Scatter()
         SELECT kalk_pripr
         DO CASE
         CASE KALK->idvd $ "16#96#82#14#11#12"
            cPom2 := "X0000001"
            IF KALK->idvd $ "11#12"
               cPom2 := "X" + Right( AllTrim( KALK->idkonto ), 3 ) + "0001"
            ELSEIF KALK->idvd $ "14"
               cPom2 := "X" + PadR( AllTrim( KALK->idpartner ), 6, "0" ) + "1"
            ENDIF
            _brdok := cPom2
            _datdok := dDok
            _brfaktp := Space( 10 )
            _datfaktp := dDok
            _rbr := TraziRbr( KALK->( idfirma + idvd ) + cPom2 + "XXX" )
            _kolicina := -_kolicina

            ++ nCount

            APPEND BLANK
            Gather()
            Scatter()
            _rbr := TraziRbr( KALK->( idfirma + idvd ) + cPom2 + "XXX" )
            _kolicina := -_kolicina
            nPom := TraziNC( KALK->( idfirma + cMagac ) + idroba, KALK->datdok )
            IF KALK->idvd $ "11#12"
               _fcj := IF( nPom == 0, _vpc / 1.2, nPom )
               _marza := _vpc - _fcj
            ELSE
               _nc := IF( nPom == 0, _vpc / 1.2, nPom )
               _marza := _vpc - _nc
            ENDIF
            APPEND BLANK
            Gather()

         ENDCASE
      ENDIF
      SELECT KALK
      SKIP 1
   ENDDO

   nTArea := Select()



   SELECT ( nTArea )

   CLOSERET

*/


/* TraziRbr(cKljuc)
 *     Utvrdjuje posljednji redni broj stavke zadanog dokumenta u kalk_pripremi
 */

FUNCTION TraziRbr( cKljuc )


   LOCAL cVrati := "  1"
   SELECT kalk_pripr
   GO TOP
   SEEK cKljuc
   SKIP -1
   IF idfirma + idvd + brdok == Left( cKljuc, 12 )
      cVrati := Str( Val( rbr ) + 1, 3 )
   ENDIF

   RETURN cVrati



/* TraziNC(cTrazi,dDat)
 *     Utvrdjuje najcescu NC zadane robe na zadanom kontu do zadanog datuma


FUNCTION TraziNC( cTrazi, dDat )


   LOCAL nSlog := 0, aNiz := { { 0, 0 } }, nPom := 0, nVrati := 0


  // SELECT KALK
  // nSlog := RecNo()
  // SET ORDER TO TAG "3"
  // GO TOP

  find_kalk_by_mkonto_idroba( cIdFirma, cIdKonto )
   GO TOP

   SEEK cTrazi
   DO WHILE cTrazi == idfirma + mkonto + idroba .AND. datdok <= dDat .AND. !Eof()
      nPom := AScan( aNiz, {| x| KALK->nc == x[ 1 ] } )
      IF nPom > 0
         aNiz[ nPom, 2 ] += 1
      ELSE
         AAdd( aNiz, { KALK->nc, 1 } )
      ENDIF
      SKIP 1
   ENDDO
   SET ORDER TO TAG "1"
   GO nSlog
   ASort( aNiz,,, {| x, y| x[ 2 ] > y[ 2 ] } )
   IF aNiz[ 1, 1 ] > 0
      nVrati := aNiz[ 1, 1 ]
   ELSEIF Len( aNiz ) > 1
      nVrati := aNiz[ 2, 1 ]
   ENDIF
   SELECT kalk_pripr

   RETURN nVrati
*/
