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

// Izvjestaj "rekapitulacija prometa u magacinu po tarifama"
FUNCTION RekMagTar()

   LOCAL nT1 := nT4 := nT5 := nT6 := nT7 := 0
   LOCAL nTT1 := nTT4 := nTT5 := nTT6 := nTT7 := 0
   LOCAL n1 := n4 := n5 := n6 := n7 := 0
   LOCAL nCol1 := 0
   LOCAL PicCDEM := kalk_prosiri_pic_cjena_za_2()
   LOCAL PicProc := gPicProc
   LOCAL PicDEM := kalk_prosiri_pic_iznos_za_2()
   LOCAL Pickol := kalk_pic_kolicina_bilo_gpickol()

   dDat1 := dDat2 := CToD( "" )
   qqKonto := PadR( "1310;", 60 )
   qqPartn := qqRoba := Space( 60 )
   cNRUC := "N"
   Box(, 5, 70 )
   SET CURSOR ON
   DO WHILE .T.
      @ box_x_koord() + 1, box_y_koord() + 2 SAY "Magacinski konto   " GET qqKonto PICT "@!S50"
      @ box_x_koord() + 2, box_y_koord() + 2 SAY "Artikli            " GET qqRoba  PICT "@!S50"
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "Partneri           " GET qqPartn PICT "@!S50"
      @ box_x_koord() + 4, box_y_koord() + 2 SAY "Izvjestaj za period" GET dDat1
      @ box_x_koord() + 4, Col() + 1 SAY "do" GET dDat2
      read;ESC_BCR
      aUsl1 := Parsiraj( qqKonto, "mkonto" )
      aUsl2 := Parsiraj( qqRoba, "IdRoba" )
      aUsl3 := Parsiraj( qqPartn, "IdPartner" )
      IF aUsl1 <> NIL; exit; ENDIF
   ENDDO
   BoxC()

   SET SOFTSEEK OFF
--   o_sifk()
   o_sifv()
  // o_roba()
   o_tarifa()
   -- o_kalk()
   SET ORDER TO TAG "6"
   // "idFirma+IDTarifa+idroba"

   PRIVATE cFilt1 := ""

   cFilt1 := ".t." + IF( Empty( dDat1 ), "", ".and.DATDOK>=" + dbf_quote( dDat1 ) ) + ;
      IF( Empty( dDat2 ), "", ".and.DATDOK<=" + dbf_quote( dDat2 ) ) + ;
      ".and." + aUsl1 + ".and." + aUsl2 + ".and." + aUsl3

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )

   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ENDIF

   GO TOP
   // samo  zaduz prod. i povrat iz prod.

   aRpt := {}
   AAdd( aRpt, { 12, " TARIF", " BROJ" } )
   AAdd( aRpt, { Len( PicDem ), " NV DUG", "" } )
   AAdd( aRpt, { Len( PicDem ), " NV POT", "" } )
   AAdd( aRpt, { Len( PicDem ), " NABAVNA", " VR." } )
   AAdd( aRpt, { Len( PicDem ), " VPV DUG", "" } )
   AAdd( aRpt, { Len( PicDem ), " VPV POT", "" } )
   AAdd( aRpt, { Len( PicDem ), " RABAT", "" } )
   AAdd( aRpt, { Len( PicDem ), " VPV POT", " - RABAT" } )
   AAdd( aRpt, { Len( PicDem ), " VPV", " SALDO" } )
   cLine := SetRptLineAndText( aRpt, 0 )
   cText1 := SetRptLineAndText( aRpt, 1, "*" )
   cText2 := SetRptLineAndText( aRpt, 2, "*" )

   START PRINT CRET
   ?

   n1:= 0
   n2:= 0
   n3:= 0
   n5:= 0
   n5b:= 0
   n6:=0

   cVT := .F.

   DO WHILE !Eof() .AND. IspitajPrekid()
      B := 0
      cIdFirma := KALK->IdFirma
      Preduzece()
      P_COND
      ? "KALK: REKAPITULACIJA PROMETA PO TARIFAMA ZA PERIOD OD", dDat1, "DO", dDAt2, "      NA DAN:", Date()

      aUsl2 := Parsiraj( qqRoba, "IdRoba" )
      aUsl3 := Parsiraj( qqPartn, "IdPartner" )
      IF Len( aUsl2 ) > 0
         ? "Kriterij za Artikle :", Trim( qqRoba )
      ENDIF
      IF Len( aUsl3 ) > 0
         ? "Kriterij za Partnere:", Trim( qqPartn )
      ENDIF

      ?
      ? cLine
      ? cText1
      ? cText2
      ? cLine

      nT1 := nT2 := nT3 := nT4 := nT5 := nT6 := nT7 := nT8 := 0
      DO WHILE !Eof() .AND. cIdFirma == KALK->IdFirma .AND. IspitajPrekid()
         cIdKonto := IdKonto
         cIdTarifa := IdTarifa
      --   SELECT tarifa
      --   HSEEK cIdTarifa
         SELECT kalk
         nVPP := TARIFA->VPP
         nNVD := nNVP := 0
         nVPVD := nVPVP := 0
         nRabatV := 0
         DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdtarifa == IdTarifa .AND. IspitajPrekid()

            SELECT KALK

            SELECT roba
      --      HSEEK kalk->idroba
            SELECT kalk
            set_pdv_public_vars()
            IF _PORVT <> 0
               cVT := .T.
            ENDIF

            IF mu_i == "1"
               nNVD += NC * ( Kolicina - GKolicina - gKolicin2 )
               nVPVD += VPC / ( 1 + _PORVT ) * ( Kolicina - GKolicina - gKolicin2 )
            ELSEIF mu_i == "3"
               nVPVD += VPC / ( 1 + _PORVT ) * ( Kolicina - GKolicina - gKolicin2 )
            ELSEIF mu_i == "5"
               nVPVP += VPC / ( 1 + _PORVT ) * ( Kolicina )
               nRabatV += VPC * RabatV / 100 * kolicina
            ENDIF

            SKIP
         ENDDO // tarifa

         IF PRow() > page_length()
            FF
         ENDIF
         @ PRow() + 1, 0        SAY Space( 6 ) + cIdTarifa
         nCol1 := PCol() + 1
         @ PRow(), nCol1      SAY n1 := nNVD         PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n2 := nNVP         PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n3 := nNVD - nNVP    PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n4 := nVPVD        PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n5 := nVPVP        PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n6 := nRabatV       PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n7 := nVPVP - nRabatV PICT   PicDEM
         @ PRow(), PCol() + 1   SAY n8 := nVPVD - nVPVP  PICT   PicDEM
         nT1 += n1;  nT2 += n2;  nT3 += n3; nT4 += n4;  nT5 += n5
         nT6 += n6;  nT7 += n7
         nT8 += n8

      ENDDO // konto

      IF PRow() > page_length()
         FF
      ENDIF
      ? cLine
      ? "UKUPNO:"
      @ PRow(), nCol1     SAY  nT1     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT2     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT3     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT4     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT5     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT6     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT7     PICT picdem
      @ PRow(), PCol() + 1  SAY  nT8     PICT picdem
      ? cLine

   ENDDO // eof

   IF cVT
      ?
      ? "Napomena: Za robu visoke tarife VPV je prikazana umanjena za iznos poreza"
      ? "koji je ukalkulisan u cijenu ( jer ta umanjena vrijednost odredjuje osnovicu)"
   ENDIF
   ?
   FF

   ENDPRINT

   SET SOFTSEEK ON
   closeret

*/
