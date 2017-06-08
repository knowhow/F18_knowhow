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


FUNCTION kalk_ukalkulisani_porez_prodavnice()

   LOCAL  i := 0
   LOCAL nT1 := 0
   LOCAL nT4 := 0
   LOCAL nT5 := 0
   LOCAL nT5a := 0
   LOCAL nT6 := 0
   LOCAL nT7 := 0
   LOCAL nTT1 := 0
   LOCAL nTT4 := 0
   LOCAL nTT5 := 0
   LOCAL nTT5a := 0
   LOCAL nTT6 := 0
   LOCAL nTT7 := 0
   LOCAL n1 := 0
   LOCAL n4 := 0
   LOCAL n5 := 0
   LOCAL n5a := 0
   LOCAL n6 := 0
   LOCAL n7 := 0
   LOCAL nCol1 := 0
   LOCAL PicCDEM := Replicate( "9", Val( gFPicCDem ) ) + gPicCDEM
   LOCAL PicProc := gPicProc
   LOCAL PicDEM := Replicate( "9", Val( gFPicDem ) ) + gPicDEM
   LOCAL Pickol := gPicKol
	 LOCAL cIdFirma := self_organizacija_id()
   LOCAL aPorezi
	 LOCAL cLine, cText1, cText2

   dDat1 := dDat2 := CToD( "" )
   cVDok := "99"
   //cStope := "N"

   qqKonto := PadR( "1330;", 60 )
   Box(, 5, 75 )
   SET CURSOR ON
   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Konto prodavnice:" GET qqKonto PICT "@!S50"
      @ m_x + 2, m_y + 2 SAY "Tip dokumenta (11/12/13/15/19/80/81/99):" GET cVDok  VALID cVDOK $ "11/12/13/15/19/16/22/80/81/99"
      @ m_x + 3, m_y + 2 SAY "Kalkulacije od datuma:" GET dDat1
      @ m_x + 3, Col() + 1 SAY "do" GET dDat2
      //@ m_x + 4, m_y + 2 SAY "Prikaz stopa ucesca pojedinih tarifa:" GET cStope VALID cstope $ "DN" PICT "@!"
      READ
      ESC_BCR

      cUslovPKonto := Parsiraj( qqKonto, "Pkonto" )
      IF cUslovPKonto <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()


   IF cVDOK == "99"
      cVDOK := "11#80#81#12#13#15#19"
      //IF cStope == "D"
      //   cVDOK += "#42#43"
      //ENDIF
   ENDIF

	 find_kalk_za_period( cIdFirma, NIL, NIL, NIL, dDat1, dDat2 )

   PRIVATE cFilt1 := ""


   cFilt1 := cUslovPKonto + ".and.(IDVD$" + dbf_quote( cVDOK ) + ")"

   SET FILTER TO &cFilt1

   GO TOP   // samo  zaduz prod. i povrat iz prod.
   EOF CRET


   aRUP := {}
   AAdd( aRUP, { 15, " TARIF", " BROJ" } )

   AAdd( aRUP, { Len( PicDem ), " MPV", "" } )
   AAdd( aRUP, { Len( PicProc ), " PDV", " %" } )

   AAdd( aRUP, { Len( PicDem ), " PDV", "" } )

   AAdd( aRUP, { Len( PicDem ), " MPV", " SA Por" } )



   cLine := SetRptLineAndText( aRUP, 0 )
   cText1 := SetRptLineAndText( aRUP, 1, "*" )
   cText2 := SetRptLineAndText( aRUP, 2, "*" )

   START PRINT CRET
   ?

   n1 := 0
   n4 := 0
   n5 := 0
   n5a := 0
   n6 := 0
   n7 := 0

   aPorezi := {}
   DO WHILE !Eof() .AND. IspitajPrekid()
      B := 0
      cIdFirma := KALK->IdFirma
      Preduzece()

      //IF Val( gFPicDem ) > 0
      //   P_COND2
      //ELSE
      //   P_COND
      //ENDIF

      ? "KALK: PREGLED UKALKULISANI PDV " + Trim( qqKonto ) + " ZA PERIOD OD", dDat1, "DO", dDAt2, "  NA DAN:", Date()
      ?

/*
      ? "Prodavnica: "
      aUsl2 := Parsiraj( qqKonto, "id" )
      SELECT KONTO
      GO TOP
      SEEK "132"
      DO WHILE id = "132"
         IF Tacno( aUsl2 )
            ?? id + " - " + naz
            ? Space( 12 )
         ENDIF
         SKIP
      ENDDO
*/
      ?
      ? cLine
      ? cText1
      ? cText2
      ? cLine

      nT1 := 0
      nT4 := 0
      nT5 := 0
      nT5a := 0
      nT6 := 0
      nT7 := 0
      //PRIVATE aTarife := {}, nReal := 0

      SELECT KALK
      DO WHILE !Eof() .AND. cIdFirma == KALK->IdFirma .AND. IspitajPrekid()

         cIdKonto := PKonto
         cIdTarifa := IdTarifa
         select_o_tarifa( cIdtarifa )

         SELECT kalk

         //cIdTarifa := Tarifa( pkonto, idRoba, @aPorezi, cIdTarifa )

         nMPV := 0
         nMPVSaPP := 0
         nNV := 0
         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdtarifa == IdTarifa .AND. IspitajPrekid()

            SELECT KALK
            //IF  idvd == "42" .OR. idvd == "43"
            //   nReal += mpcsapp * kolicina
            IF IdVD $ "12#13" // povrat robe se uzima negativno
               nMPV -= MPC * ( Kolicina )
               nMPVSaPP -= MPCSaPP * ( Kolicina )
               nNV -= nc * kolicina
            ELSE
               nMPV += MPC * ( Kolicina )
               nMPVSaPP += MPCSaPP * ( Kolicina )
               nNV += nc * kolicina
            ENDIF

            SKIP
         ENDDO

         //IF cStope == "D"
          //  AAdd( aTarife, { cIdTarifa, nMPVSAPP } )
         //ENDIF
         IF PRow() > ( RPT_PAGE_LEN + gPStranica )
            FF
         ENDIF

         // porez na promet
         //nPorez := Izn_P_PPP( nMpv, aPorezi, , nMpvSaPP )

         set_pdv_array_by_koncij_region_roba_idtarifa_2_3( cIdKonto, NIL, @aPorezi, cIdTarifa )


         @ PRow() + 1, 0 SAY Space( 6 ) + cIdTarifa
         nCol1 := PCol() + 4
         @ PRow(), PCol() + 4 SAY n1 := nMPV PICT PicDEM
         @ PRow(), PCol() + 1 SAY aPorezi[ POR_PPP ] PICT PicProc

         @ PRow(), PCol() + 1 SAY n4 := nPorez PICT PicDEM

         @ PRow(), PCol() + 1 SAY n7 := nMPVSAPP PICTURE PicDEM
         nT1 += n1
         nT4 += n4
         nT7 += n7
      ENDDO

      IF PRow() > ( RPT_PAGE_LEN + gPStranica )
         FF
      ENDIF
      ? cLine
      ? "UKUPNO:"
      @ PRow(), nCol1     SAY  nT1     PICT picdem
      @ PRow(), PCol() + 1  SAY  0       PICT "@Z " + picproc

      @ PRow(), PCol() + 1  SAY  nT4     PICT picdem

      @ PRow(), PCol() + 1  SAY  nT7     PICT picdem
      ? cLine

/*
      IF cStope == "D"
         ?
         ? "Prikaz ucesca pojedinih tarifa:"
         ? cLine
         FOR ii := 1 TO Len( aTarife )
            ? aTarife[ ii, 1 ]
            @ PRow(), PCol() + 1 SAY aTarife[ ii, 2 ] / nT7 * 100 PICT "99.999%"
            ?? " * "
            @ PRow(), PCol() + 1 SAY nReal PICT  picdem
            ?? " = "
            @ PRow(), PCol() + 1 SAY nReal * aTarife[ ii, 2 ] / nT7 PICT picdem
         NEXT
         ? cLine
      ENDIF
*/

   ENDDO

   ?
   FF
   ENDPRINT
   SET SOFTSEEK ON

   closeret

   RETURN .T.
