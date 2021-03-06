/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2018 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


/*
#define NAZIV_PROD_LEN 15


FUNCTION PPProd()

   LOCAL i
   LOCAL dDatumOd
   LOCAL dDatumDo
   LOCAL cTbl
   LOCAL nUPari1, nUPari2, nUPari
   LOCAL nUBruto1, nUBruto2, nUBruto
   LOCAL nUNeto1, nUNeto2, nUNeto
   LOCAL nStr
   LOCAL aPolozi
   LOCAL nPolog
   LOCAL cNazivProdKonto
   LOCAL cIdKonto
   LOCAL nRow
   LOCAL cPrinter
   LOCAL cPicKol
   PRIVATE cListaKonta := Space( 140 )
   PRIVATE cPopustDN := "D"

   dDan := Date()
   cTops := "D"
   cPodvuci := "N"
   cFilterDn := "D"

   IF GetVars( @dDatumOd, @dDatumDo, @cListaKonta, @cPopustDN ) == 0
      RETURN
   ENDIF

   CrePPProd()

   MsgBeep( "Kreirane pomocne tabele !!!" )

   // otvori tabelu
   OTblPPProd()

   // formiraj pomocnu tabelu
   IF ( ScanKoncij( dDatumOd, dDatumDo ) == 0 )
      MsgBeep( "Ne postoje podaci, ili podesenja nisu korektna!" )
      RETURN
   ENDIF

   cPrinter := gPrinter
   gPrinter := "R"


   IF !start_print()
      RETURN .F.
   ENDIF
   ?
   ? "#%LANDS#"

   nStr := 0

   InitAPolozi( @aPolozi )
   P_COND
   Header( dDatumOd, dDatumDo, aPolozi, @nStr )

   nUPari := 0
   nUBruto1 := 0
   nUBruto2 := 0
   nUBruto := 0
   nUNeto1 := 0
   nUNeto2 := 0
   nUNeto := 0

   cPicKol := Replicate( "9", Len( kalk_pic_kolicina_bilo_gpickol() ) )

   SELECT ppprod
   GO TOP
   DO WHILE ( !Eof() )

      cIdKonto := field->idKonto
      cNazivProdKonto := get_prod_naz( cIdKonto )

      ? PadR( cNazivProdKonto, NAZIV_PROD_LEN )
      @ PRow(), PCol() + 1 SAY field->pari PICTURE cPicKol
      @ PRow(), PCol() + 1 SAY field->bruto1 PICTURE kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY field->bruto2 PICTURE kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY field->bruto PICTURE kalk_pic_iznos_bilo_gpicdem()

      @ PRow(), PCol() + 1 SAY field->neto1 PICTURE kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY field->neto2 PICTURE kalk_pic_iznos_bilo_gpicdem()
      @ PRow(), PCol() + 1 SAY field->neto PICTURE kalk_pic_iznos_bilo_gpicdem()

      nUPari += field->pari
      nUBruto1 += field->bruto1
      nUBruto2 += field->bruto2
      nUBruto += field->bruto
      nUNeto1 += field->neto1
      nUNeto2 += field->neto2
      nUNeto += field->neto

      FOR i := 1 TO Len( aPolozi )
         nPolog := FldPolog( i )
         @ PRow(), PCol() + 1 SAY nPolog PICTURE kalk_pic_iznos_bilo_gpicdem()
         // suma za polog vrste i
         aPolozi[ i, 2 ] += nPolog
      NEXT
      SKIP
   ENDDO

   Linija( Len( aPolozi ) )
   Footer( nUPari, nUBruto1, nUBruto2, nUBruto, nUNeto1, nUNeto2, nUNeto, aPolozi )
   Linija( Len( aPolozi ) )

   end_print()
   gPrinter := cPrinter

   CLOSERET



STATIC FUNCTION InitAPolozi( aPolozi )


   LOCAL i

   aPolozi := {}
   FOR i := 1 TO 12
      AAdd( aPolozi, { "", 0 } )
      aPolozi[ i, 1 ] := my_get_from_ini( 'POS', 'Polog' + AllTrim( Str( i ) ), "-", KUMPATH )
      IF ( AllTrim( aPolozi[ i, 1 ] ) == "-" )
         ADel( aPolozi, i )
         ASize( aPolozi, i - 1 )
         EXIT
      ENDIF
   NEXT
   // }

STATIC FUNCTION Header( dDatumOd, dDatumDo, aPolozi, nStr )

   // {
   LOCAL i
   LOCAL nSirina

   nSirina := ( Len( kalk_pic_kolicina_bilo_gpickol() ) + 1 )
   nSirina += ( 6 + Len( aPolozi ) ) * ( Len( kalk_pic_iznos_bilo_gpicdem() ) + 1 )

   print_nova_strana( nSirina - 8, @nStr, -1 )
   B_ON
   ? PadC( "KALK: PREGLED PROMETA za period " + DToC( dDatumOd ) + "-" + DToC( dDatumDo ), nSirina )
   B_OFF

   Linija( Len( aPolozi ) )
   // prvi red
   ? PadC( "Prodavnica", NAZIV_PROD_LEN )
   @ PRow(), PCol() + 1 SAY PadC( "pari", Len( kalk_pic_kolicina_bilo_gpickol() ) )
   @ PRow(), PCol() + 1 SAY PadC( "bruto", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "bruto", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "bruto", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "neto", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "neto", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "neto", Len( kalk_pic_iznos_bilo_gpicdem() ) )

   FOR i := 1 TO Len( aPolozi )
      @ PRow(), PCol() + 1 SAY PadC( aPolozi[ i, 1 ], Len( kalk_pic_iznos_bilo_gpicdem() ) )
   NEXT

   // drugi red
   ? PadC( "", NAZIV_PROD_LEN )
   @ PRow(), PCol() + 1 SAY PadC( "", Len( kalk_pic_kolicina_bilo_gpickol() ) )
   @ PRow(), PCol() + 1 SAY PadC( "visa tarifa", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "niza tarifa", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "svega", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "visa tarifa", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "niza tarifa", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   @ PRow(), PCol() + 1 SAY PadC( "svega", Len( kalk_pic_iznos_bilo_gpicdem() ) )

   FOR i := 1 TO Len( aPolozi )
      @ PRow(), PCol() + 1 SAY PadC( "", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   NEXT

   Linija( Len( aPolozi ) )

   RETURN
// }

STATIC FUNCTION Footer( nUPari, nUBruto1, nUBruto2, nUBruto, nUNeto1, nUNeto2, nUNeto, aPolozi )

   // {
   LOCAL i
   LOCAL cPicKol
   LOCAL nUkupnoPolozi

   cPicKol := Replicate( "9", Len( kalk_pic_kolicina_bilo_gpickol() ) )

   ? PadC( "UKUPNO:", NAZIV_PROD_LEN )
   @ PRow(), PCol() + 1 SAY nUPari PICTURE cPicKol
   @ PRow(), PCol() + 1 SAY nUBruto1 PICTURE kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY nUBruto2 PICTURE kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY nUBruto PICTURE kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY nUNeto1 PICTURE kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY nUNeto2 PICTURE kalk_pic_iznos_bilo_gpicdem()
   @ PRow(), PCol() + 1 SAY nUNeto PICTURE kalk_pic_iznos_bilo_gpicdem()

   nUkupnoPolozi := 0
   FOR i := 1 TO Len( aPolozi )
      @ PRow(), PCol() + 1 SAY aPolozi[ i, 2 ] PICTURE kalk_pic_iznos_bilo_gpicdem()
      nUkupnoPolozi += aPolozi[ i, 2 ]
   NEXT
   IF ( Round( nUkupnoPolozi - nUBruto, 4 ) <> 0 )
      MsgBeep( "Ukupno bruto <> suma pologa pazara !!???" )
   ENDIF

   RETURN
// }

STATIC FUNCTION Linija( nPologa )

   // {
   LOCAL i

   ? Replicate( "-", NAZIV_PROD_LEN )
   @ PRow(), PCol() + 1 SAY Replicate( "-", Len( kalk_pic_kolicina_bilo_gpickol() ) )
   FOR i := 1 TO 6
      @ PRow(), PCol() + 1 SAY Replicate( "-", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   NEXT
   FOR i := 1 TO nPologa
      @ PRow(), PCol() + 1 SAY Replicate( "-", Len( kalk_pic_iznos_bilo_gpicdem() ) )
   NEXT

   RETURN
// }


STATIC FUNCTION FldPolog( nPos )

   // {
   DO CASE
   CASE nPos == 1
      RETURN field->polog01
   CASE nPos == 2
      RETURN field->polog02
   CASE nPos == 3
      RETURN field->polog03
   CASE nPos == 4
      RETURN field->polog04
   CASE nPos == 5
      RETURN field->polog05
   CASE nPos == 6
      RETURN field->polog06
   CASE nPos == 7
      RETURN field->polog07
   CASE nPos == 8
      RETURN field->polog08
   CASE nPos == 9
      RETURN field->polog09
   CASE nPos == 10
      RETURN field->polog10
   CASE nPos == 11
      RETURN field->polog11
   CASE nPos == 12
      RETURN field->polog12
   ENDCASE

   RETURN



STATIC FUNCTION OTblPPProd()

   LOCAL cTbl

   Alert( "Ovo neko koristi OTblPPProd ?!" )

   RETURN



STATIC FUNCTION GetVars( dDatumOd, dDatumDo, cListaKonta, cPopustDN )

#ifdef PROBA

   dDatumOd := Date()
   dDatumDo := Date()
#else
   dDatumOd := Date() -1
   dDatumDo := Date() -1
#endif

   Box(, 3, 60 )
   @ box_x_koord() + 1, box_y_koord() + 2 SAY "Datum od :" GET dDatumOd
   @ box_x_koord() + 1, Col() + 1 SAY "-" GET dDatumDo
   @ box_x_koord() + 2, box_y_koord() + 2 SAY "Konta (prazno-svi)" GET cListaKonta PICT "@!S40"
   @ box_x_koord() + 3, box_y_koord() + 2 SAY "Uzeti u obzir popust " GET cPopustDN VALID !Empty( cPopustDN )
   READ
   IF ( LastKey() == K_ESC )
      BoxC()
      RETURN 0
   ENDIF
   BoxC()

   RETURN 1
// }

STATIC FUNCTION ScanKoncij( dDatumOd, dDatumDo )

   // {
   LOCAL cTSifPath
   LOCAL nSifPath
   LOCAL cTKumPath
   LOCAL nCnt
   LOCAL nMpcBp
   LOCAL aPorezi

   o_tarifa()
   o_koncij()

   IF ( FieldPos( "KUMTOPS" ) == 0 )
      MsgBeep( "Prvo izvrsite modifikaciju struktura pomocu KALK.CHS !" )
      my_close_all_dbf()
      RETURN 0
   ENDIF

   // prodji kroz koncij
   GO TOP

   Box(, 3, 60 )

   nCnt := 0

   DO WHILE ( !Eof() )

      IF !Empty( cListaKonta ) .AND. At( AllTrim( field->id ), cListaKonta ) == 0
         SKIP 1
         LOOP
      ENDIF

      cTSifPath := Trim( field->siftops )
      cTKumPath := Trim( field->kumtops )

      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Prolazim kroz tabele......."

      IF Empty( cTSifPath ) .OR. Empty( cTKumPath )
         SKIP 1
         LOOP
      ENDIF

      AddBs( @cTKumPath )
      AddBs( @cTKumPath )
      AddBs( @cTSifPath )

      IF ( !File( cTKumPath + "POS.DBF" ) .OR. !File( cTKumPath + "POS.CDX" ) )
         SKIP 1
         LOOP
      ENDIF

      Select( F_ROBA )
      // if !FILE(cTSifPath+"ROBA.DBF") .or. !FILE(cTSifPath+"ROBA.CDX")
      USE ( SIFPATH + "ROBA" )
      SET ORDER TO TAG "ID"
      // else
      // USE (cTSifPath+"ROBA")
      // SET ORDER TO TAG "ID"
      // endif

      ScanPos( dDatumOd, dDatumDo, cTKumPath )
      ScanPromVp( dDatumOd, dDatumDo, cTKumPath )

      ++ nCnt

      SELECT roba
      USE

    --  SELECT koncij
      SKIP 1
   ENDDO
   BoxC()

   IF nCnt == 0
      RETURN 0
   ENDIF

   RETURN 1
// }


STATIC FUNCTION ScanPos( dDatumOd, dDatumDo, cTKumP )

   // {
   LOCAL aPorezi

   SELECT 0
   USE ( cTKumP + "POS" )
   // dtos(datum)
   SET ORDER TO TAG "4"


   SEEK DToS( dDatumOd )
   DO WHILE ( !Eof() .AND. ( DToS( field->datum ) <= DToS( dDatumDo ) ) )
      // samo prodaja
      IF field->idvd <> "42" .AND. field->idvd <> "01"
         SKIP
         LOOP
      ENDIF

      SELECT roba
  --    SEEK pos->idroba
      SELECT pos

      set_pdv_array_by_koncij_region_roba_idtarifa_2_3( koncij->id, pos->idRoba, @aPorezi )
      // Provjeri da li je bilo popusta u POS-u
      // Popust POS se evidentira u POS->NCIJENA
      // iznos postotka npr.10 kao 10%

      nPosCijena := pos->cijena
      IF cPopustDN == "D" .AND. pos->ncijena <> 0
         nPosCijena := nPosCijena - pos->ncijena
      ENDIF

      nMpcBp := MpcBezPor( nPosCijena, @aPorezi )
      SELECT pos

      @ box_x_koord() + 3, box_y_koord() + 2 SAY "POS    :: Prodavnica: " + AllTrim( koncij->id ) + ", PATH: " + cTKumP
      IF ( "(N.T.)" $ tarifa->naz )
         // radi se o nizoj tarifi
         AFPos( koncij->id, "2", nPosCijena, nMpcBp, pos->kolicina )
      ELSE
         // radi se o visoj tarifi
         AFPos( koncij->id, "1", nPosCijena, nMpcBp, pos->kolicina )
      ENDIF

      SELECT pos
      SKIP
   ENDDO

   SELECT pos
   USE

   RETURN
// }


//* AFPos(cIdKonto, cVisaNiza, nCijena, nCijenaBp, nKolicina)
// *     (A)ppend (F)rom Table (Pos)
// *   param: cIdKonto - konto prodavnice
// *   param: cVisaNiza - "1" - niza tarifa ostala obuca; "2" - visa tarifa - djecija obuca
// *   param: nCijena
// *   param: nCijenaBp
// *   param: nKolicina - kolicina pari
// *  note  Pripadnost tarifi odredjena je sadrzajem polja tbl_tarifa_naz
// *  sa tbl_tarifa_naz
// *


STATIC FUNCTION AFPos( cIdKonto, cVisaNiza, nCijena, nCijenaBp, nKolicina )


   LOCAL nPari

   SELECT ppprod
  -- SEEK cIdKonto

   my_flock()

   IF ( !Found() )
      APPEND BLANK
      REPLACE idKonto WITH cIdKonto
   ENDIF

   IF ( Left( roba->k2, 1 ) == "X" )
      nPari := 0
   ELSE
      nPari := nKolicina
   ENDIF

   REPLACE pari WITH pari + nPari

   IF ( cVisaNiza == "1" )
      REPLACE bruto1 WITH field->bruto1 + nCijena * nKolicina
      REPLACE neto1 WITH field->neto1 + nCijenaBp * nKolicina
   ELSE
      REPLACE neto2 WITH field->neto2 + nCijenaBp * nKolicina
      REPLACE bruto2 WITH field->bruto2 + nCijena * nKolicina
   ENDIF

   REPLACE bruto  WITH field->bruto + nCijena * nKolicina
   REPLACE neto WITH field->neto + nCijenaBp * nKolicina

   my_unlock()

   SELECT pos

   RETURN


STATIC FUNCTION ScanPromVp( dDatumOd, dDatumDo, cTKumPath )

   // {

   SELECT 0
--   USE ( cTKumPath + "PROMVP" )

   IF ( FieldPos( "polog01" ) == 0 )
      MsgBeep( "Stara verzija promVp:" + cTKumPath )
      RETURN 0
   ENDIF
   // datum
   SET ORDER TO TAG "1"
--   SELECT promVp
   SEEK dDatumOd
   DO WHILE ( !Eof() .AND. ( field->datum <= dDatumDo ) )
      ARFPromVp( koncij->id, field->polog01, field->polog02, field->polog03, field->polog04, field->polog05, field->polog06, field->polog07, field->polog08, field->polog09, field->polog10, field->polog11, field->polog12 )
      SELECT promVp
    --  @ box_x_koord() + 3, box_y_koord() + 2 SAY "PROMVP :: Prodavnica: " + AllTrim( koncij->id ) + ", PATH: " + cTKumPath
      SKIP
   ENDDO

   SELECT promVp
   USE

   RETURN 1

// ARFPromVp(cIdKonto, nPolog01, nPolog02, nPolog03, nPolog04, nPolog05, nPolog06, nPolog07, nPolog08, nPolog09, nPolog10, nPolog11, nPolog12)
//      (A)ppend (R)ow (F)rom Table (PromVp)
//    param: cIdKonto - prodavnicki konto
//    param: nPolog01 - polog pazara vrste 01 (.. do nPolog12)



STATIC FUNCTION ARFPromVp( cIdKonto, nPolog01, nPolog02, nPolog03, nPolog04, nPolog05, nPolog06, nPolog07, nPolog08, nPolog09, nPolog10, nPolog11, nPolog12 )


   SELECT ppprod
   -- SEEK cIdKonto

   my_flock()

   IF !Found()
      APPEND BLANK
      REPLACE idKonto WITH cIdKonto
   ENDIF

   REPLACE polog01 WITH field->polog01 + nPolog01
   REPLACE polog02 WITH field->polog02 + nPolog02
   REPLACE polog03 WITH field->polog03 + nPolog03
   REPLACE polog04 WITH field->polog04 + nPolog04
   REPLACE polog05 WITH field->polog05 + nPolog05
   REPLACE polog06 WITH field->polog06 + nPolog06
   REPLACE polog07 WITH field->polog07 + nPolog07
   REPLACE polog08 WITH field->polog08 + nPolog08
   REPLACE polog09 WITH field->polog09 + nPolog09
   REPLACE polog10 WITH field->polog10 + nPolog10
   REPLACE polog11 WITH field->polog11 + nPolog11
   REPLACE polog12 WITH field->polog12 + nPolog12

   my_unlock()

   RETURN


*/
