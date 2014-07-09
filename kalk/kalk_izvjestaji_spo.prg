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


#include "kalk.ch"

STATIC nCol1 := 0
STATIC cPicCDem
STATIC cPicProc
STATIC cPicDem
STATIC cPicKol
STATIC cStrRedova2 := 62
STATIC cPrikProd := "N"
STATIC qqKonto
STATIC qqRoba
STATIC cUslov1
STATIC cUslov2
STATIC cObjUsl
STATIC cUslovRoba
STATIC cK9
STATIC cNObjekat
STATIC cLinija

#define ROBAN_LEN 40
#define KOLICINA_LEN 10

FUNCTION kalk_izvj_stanje_po_objektima()

   LOCAL i
   LOCAL nT1
   LOCAL nT4
   LOCAL nT5
   LOCAL nT6
   LOCAL nT7
   LOCAL nTT1
   LOCAL nTT4
   LOCAL nTT5
   LOCAL nTT6
   LOCAL nTT7
   LOCAL n1
   LOCAL n4
   LOCAL n5
   LOCAL n6
   LOCAL n7
   LOCAL nRecno, _rec
   LOCAL cPodvuci
   LOCAL lMarkiranaRoba
   PRIVATE dDatOd
   PRIVATE dDatDo
   PRIVATE aUTar := {}
   PRIVATE nUkObj := 0
   PRIVATE nITar := 0
   PRIVATE aUGArt := {}
   PRIVATE cPrSort := "SUBSTR(cIdRoba,3,3)"

   cPodvuci := "N"

   O_SIFK
   O_SIFV
   O_ROBA
   O_K1
   O_OBJEKTI

   lMarkiranaRoba := .F.
   cPicCDem := "999999.999"
   cPicProc := "999999.99%"
   cPicDem := "9999999.99"
   cPicKol := gPicKol
   qqKonto := PadR( "13;", 60 )
   qqRoba := Space( 60 )

   IF GetVars( @cNObjekat ) == 0
      RETURN
   ENDIF

   IF Right( Trim( qqRoba ), 1 ) = "*"
      lMarkiranaRoba := .T.
   ENDIF

   CreTblPobjekti()
   CreTblRek1( "1" )

   O_POBJEKTI
   O_KONCIJ
   O_ROBA
   O_KONTO
   O_TARIFA
   O_K1
   O_OBJEKTI
   O_KALK
   O_REKAP1

   GenRekap1( cUslov1, cUslov2, cUslovRoba, "N", "1", "N", lMarkiranaRoba, nil, cK9 )

   SetLinSpo()

   SELECT rekap1
   SET ORDER TO TAG "2"
   GO TOP

   SetGaZagSpo()

   START PRINT CRET
   ?

   IF ( gPrinter = "R" )
      cStrRedova2 := 40
      ?? "#%LANDS#"
   ENDIF

   nStr := 0

   ZaglSPo( @nStr )

   nCol1 := 43

   FillPObjekti()

   SELECT rekap1
   nRbr := 0
   nRecno := 0
   fFilovo := .F.

   DO WHILE !Eof()
	
      cG1 := rekap1->g1

      SELECT pobjekti

      GO TOP
      DO WHILE !Eof()
         _rec := dbf_get_rec()
         _rec[ "prodg" ] := 0
         _rec[ "zalg" ] := 0
         dbf_update_rec( _rec )
         SKIP
      ENDDO

      SELECT rekap1

      fFilGr := .F.
      fFilovo := .F.
	
      DO WHILE ( !Eof() .AND. cG1 == field->g1 )
         ++nRecno

         ShowKorner( nRecno, 100 )
         cIdroba := rekap1->idRoba
		
         SELECT roba
         HSEEK cIdRoba
         cIdTarifa := roba->idTarifa

         SELECT rekap1
		
         nK2 := nK1 := 0
         SetK1K2( cG1, cIdTarifa, cIdRoba, @nK1, @nK2 )
		
         IF ( ( Round( nK2, 3 ) == 0 .AND. Round( nK1, 2 ) == 0 ) )
            SELECT rekap1
            SEEK cG1 + cIdTarifa + cIdroba + Chr( 254 )
            LOOP
         ENDIF

         fFilovo := .T.
         fFilGr := .T.
		
         aStrRoba := SjeciStr( Trim( roba->naz ), ROBAN_LEN )
		
         IF ( PRow() > cStrRedova2 )
            FF
            ZaglSPo( @nStr )
         ENDIF
		
         ++nRBr
         ? Str( nRBr, 4 ) + "." + PadR( cIdRoba, 10 )
         nColR := PCol() + 1
         @ PRow(), nColR  SAY PadR( aStrRoba[ 1 ], ROBAN_LEN )
         nCol1 := PCol()

         PrintZal( cG1, cIdTarifa, cIdRoba, cObjUsl )
		
         nK1 := 0
         IF ( ( cPrikProd == "D" ) .OR. Len( aStrRoba ) > 1 )
            ?
            IF Len( aStrRoba ) > 1
               @ PRow(), nColR SAY PadR( aStrRoba[ 2 ], ROBAN_LEN )
            ENDIF
            @ PRow(), nCol1 SAY ""
            IF ( cPrikProd == "D" )
               PrintProd( cG1, cIdTarifa, cIdRoba, cObjUsl )
            ENDIF
         ENDIF
		
         IF cPodvuci == "D"
            ? cLinija
         ENDIF

         SELECT rekap1
         SEEK cG1 + cIdTarifa + cIdroba + Chr( 255 )
      ENDDO

      IF !fFilGr
         LOOP
      ENDIF
	
      IF ( PRow() > cStrRedova2 )
         FF
         ZaglSPo( @nStr )
      ENDIF

      ? StrTran( cLinija, "-", "=" )

      SELECT k1
      HSEEK cG1
      SELECT rekap1
      StrTran( cLinija, "-", "=" )
   ENDDO

   IF ( PRow() > cStrRedova2 )
      FF
      ZaglSPo( @nStr )
   ENDIF

   FF
   endprint

   my_close_all_dbf()

   RETURN



FUNCTION SetK1K2( cG1, cIdTarifa, cIdRoba, nK1, nK2 )

   nK2 := 0
   nK1 := 0
   SELECT pobjekti
   GO TOP
   DO WHILE ( !Eof()  .AND. field->id < "99" )
      SELECT rekap1
      hseek  cG1 + cIdtarifa + cIdroba + pobjekti->idobj
      nK2 += field->k2
      nK1 += field->k1
      SELECT pobjekti
      SKIP
   ENDDO

   RETURN


STATIC FUNCTION SetLinSpo()

   LOCAL nObjekata

   cLinija := Replicate( "-", 4 ) + " " + Replicate( "-", 10 ) + " " + Replicate( "-", ROBAN_LEN )

   SELECT pobjekti
   GO TOP

   nObjekata := 0

   DO WHILE !Eof()

      IF field->id <> "99" .AND. !Empty( cObjUsl ) .AND. !( &cObjUsl )
         SKIP
         LOOP
      ENDIF

      cLinija := cLinija + " " + Replicate( "-", KOLICINA_LEN )

      ++ nObjekata

      SKIP

   ENDDO

   RETURN




STATIC FUNCTION ZaglSPo( nStr )

   LOCAL nObjekata

   ? gTS + ":", gNFirma, Space( 40 ), "Strana:" + Str( ++nStr, 3 )
   ?
   ?  "Stanje artikala po objektima za period:", dDatOd, "-", dDatDo
   ?
   IF ( qqRoba == nil )
      qqRoba := ""
   ENDIF
   ? "Kriterij za Objekat:", Trim( qqKonto ), "Robu:", Trim( qqRoba )
   ?

   P_COND

   ? cLinija

   ? PadC( "Rbr", 4 ) + " " + PadC( "Sifra", 10 ) + " " + PadC( "NAZIV  ARTIKLA", ROBAN_LEN )
   SELECT objekti
   GO BOTTOM
   ?? " " + PadC( AllTrim( objekti->naz ), KOLICINA_LEN )
   GO TOP
   DO WHILE ( !Eof() .AND. objekti->id < "99" )
	
      IF !Empty( cObjUsl ) .AND. !( &cObjUsl )
         SKIP
         LOOP
      ENDIF

      ?? " " + PadC( AllTrim( objekti->naz ), KOLICINA_LEN )
	
      SKIP

   ENDDO

   ? PadC( " ", 4 ) + " " + PadC( " ", 10 ) + " " + PadC( " ", ROBAN_LEN )
   ?? " " + PadC( "za/pr", KOLICINA_LEN )
   SELECT pobjekti
   GO TOP
   DO WHILE ( !Eof() .AND. field->id < "99" )
	
      IF !Empty( cObjUsl ) .AND. !( &cObjUsl )
         SKIP
         LOOP
      ENDIF

      ?? " " + PadC( "zal/pr", KOLICINA_LEN )
      SKIP
   ENDDO

   ? cLinija

   RETURN NIL

STATIC FUNCTION GetVars( cNObjekat )

   cUslov1 := ""
   cUslov2 := ""
   cObjUsl := ""
   cUslovR := ""
   dDatOd := Date()
   dDatDo := Date()

   O_PARAMS
   PRIVATE cSection := "F", cHistory := " ", aHistory := {}

   Params1()
   RPar( "c2", @qqKonto )
   RPar( "c3", @cPrSort )
   RPar( "d1", @dDatOd )
   RPar( "d2", @dDatDo )
   RPar( "cR", @qqRoba )

   cKartica := "N"
   cNObjekat := Space( 20 )

   cPrikProd := "N"

   Box(, 10, 70 )
   SET CURSOR ON

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Konta objekata:" GET qqKonto PICT "@!S50"
      @ m_x + 3, m_y + 2 SAY "tekuci promet je period:" GET dDatOd
      @ m_x + 3, Col() + 2 SAY "do" GET dDatDo
      @ m_x + 4, m_y + 2 SAY "Kriterij za robu :" GET qqRoba PICT "@!S50"
      @ m_x + 5, m_y + 2 SAY "Prikaz prodaje (D/N)" GET cPrikProd PICT "@!" VALID cPrikProd $ "DN"
      READ

      IF ( LastKey() == K_ESC )
         BoxC()
         RETURN 0
      ENDIF
      cUslov1 := Parsiraj( qqKonto, "PKonto" )
      cUslov2 := Parsiraj( qqKonto, "MKonto" )
      cObjUsl := Parsiraj( qqKonto, "IDOBJ" )
      cUslovRoba := Parsiraj( qqRoba, "IdRoba" )
	
      IF ( cUslov1 <> NIL .AND. cUslovRoba <> nil )
         EXIT
      ENDIF
   ENDDO
   BoxC()

   SELECT roba
   USE

   SELECT params
   IF Params2()
      WPar( "c2", qqKonto )
      WPar( "c3", cPrSort )
      WPar( "d1", dDatOd )
      WPar( "d2", dDatDo )
      WPar( "cR", @qqRoba )
   ENDIF
   SELECT params
   USE

   RETURN 1

STATIC FUNCTION SetGaZagSpo()
   RETURN


STATIC FUNCTION PrintZal( cG1, cIdTarifa, cIdRoba, cDUslov )

   LOCAL nK2

   nK2 := 0
   SELECT pobjekti
   GO TOP
   DO WHILE ( !Eof() .AND. field->id < "99" )
      SELECT rekap1
      HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
      nK2 += field->k2
      SELECT pobjekti
      SKIP
   ENDDO

   @ PRow(), PCol() + 1 SAY nK2 PICT cPicKol

   SELECT pobjekti
   GO TOP
   DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
	
      SELECT pobjekti

      IF !Empty( cDUslov ) .AND. !( &cDUslov )
         SKIP
         LOOP
      ENDIF
	
      SELECT rekap1
      HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
      IF k4pp <> 0
         @ PRow(), PCol() + 1 SAY StrTran( TRANS( k2, cPicKol ), " ", "*" )
      ELSE
         @ PRow(), PCol() + 1 SAY k2 PICT cPicKol
      ENDIF
      SELECT pobjekti
      IF roba->k2 <> "X"
         _rec := dbf_get_rec()
         _rec[ "zalt" ] := _rec[ "zalt" ] + rekap1->k2
         _rec[ "zalu" ] := _rec[ "zalu" ] + rekap1->k2
         _rec[ "zalg" ] := _rec[ "zalg" ] + rekap1->k2
         dbf_update_rec( _rec )
      ENDIF
      SKIP
   ENDDO

   IF ( roba->k2 <> "X" )
      _rec := dbf_get_rec()
      _rec[ "zalt" ] := _rec[ "zalt" ] + nK2
      _rec[ "zalu" ] := _rec[ "zalu" ] + nK2
      _rec[ "zalg" ] := _rec[ "zalg" ] + nK2
      dbf_update_rec( _rec )
   ENDIF

   RETURN


STATIC FUNCTION PrintProd( cG1, cIdTarifa, cIdRoba, cDUslov )

   LOCAL nK1

   SELECT pobjekti
   nK1 := 0
   GO TOP
   DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
      SELECT rekap1
      HSEEK cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
      nK1 += field->k1
      SELECT pobjekti
      SKIP
   ENDDO

   @ PRow(), PCol() + 1 SAY nK1 PICT cPicKol

   SELECT pobjekti
   GO TOP
   lIzaProc := .T.
   i := 0
   DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
	
      SELECT pobjekti
      IF !Empty( cDUslov ) .AND. !( &cDUslov )
         SKIP
         LOOP
      ENDIF
	
      SELECT rekap1
      hseek cG1 + cIdTarifa + cIdRoba + pobjekti->idobj
      IF k4pp <> 0
         @ PRow(), PCol() + 1 SAY StrTran( TRANS( k1, cPicKol ), " ", "*" )
      ELSE
         @ PRow(), PCol() + 1 SAY k1 PICT cPicKol
      ENDIF
      ++i
	
      SELECT pobjekti
      IF ( roba->k2 <> "X" )

         _rec := dbf_get_rec()
         _rec[ "prodt" ] := _rec[ "prodt" ] + rekap1->k1
         _rec[ "produ" ] := _rec[ "produ" ] + rekap1->k1
         _rec[ "prodg" ] := _rec[ "prodg" ] + rekap1->k1
         dbf_update_rec( _rec )

      ENDIF
      SKIP
   ENDDO

   IF roba->k2 <> "X"

      _rec := dbf_get_rec()
      _rec[ "prodt" ] := _rec[ "prodt" ] + nK1
      _rec[ "produ" ] := _rec[ "produ" ] + nK1
      _rec[ "prodg" ] := _rec[ "prodg" ] + nK1
      dbf_update_rec( _rec )

   ENDIF

   RETURN

STATIC FUNCTION PrintZalGr()

   SELECT pobjekti
   GO BOTTOM
   @ PRow(), nCol1 + 1 SAY zalg PICT cPicKol
   SELECT pobjekti
   GO TOP
   i := 0
   DO WHILE ( !Eof() .AND. pobjekti->id < "99" )
      @ PRow(), PCol() + 1 SAY zalg PICT cPicKol
      ++i
      SKIP
   ENDDO

   RETURN

STATIC FUNCTION PrintProdGr()

   SELECT pobjekti
   GO BOTTOM
   @ PRow() + 1, nCol1 + 1 SAY prodg PICT cPicKol
   SELECT pobjekti
   GO TOP
   i := 0
   DO WHILE ( !Eof()  .AND. field->id < "99" )
      @ PRow(), PCol() + 1 SAY prodg PICT cPicKol
      ++i
      SKIP
   ENDDO
