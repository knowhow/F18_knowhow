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

MEMVAR cIdfirma, cIdvd, cBrdok


FUNCTION kalk_stampa_svih_dokumenata_u_pripremi()
   RETURN kalk_stampa_dokumenta( .F., NIL, .T. )

FUNCTION kalk_stampa_dokumenta( lAzuriraniDokument, cSeek, lAuto )

   LOCAL nCol1
   LOCAL nCol2
   LOCAL nPom
   LOCAL cOk
   LOCAL cNaljepniceDN := "N"
   LOCAL GetList := {}
   PRIVATE cIdfirma, cIdvd, cBrdok

   nCol1 := 0
   nCol2 := 0
   nPom := 0

   PRIVATE PicCDEM := kalk_pic_cijena_bilo_gpiccdem()
   PRIVATE PicProc := gPICPROC
   PRIVATE PicDEM  := kalk_pic_iznos_bilo_gpicdem()
   PRIVATE Pickol  := kalk_pic_kolicina_bilo_gpickol()
   PRIVATE nStr := 0

   IF ( PCount() == 0 )
      lAzuriraniDokument := .F.
   ENDIF

   IF ( lAzuriraniDokument == NIL )
      lAzuriraniDokument := .F.
   ENDIF

   IF ( lAuto == NIL )
      lAuto := .F.
   ENDIF

   IF ( cSeek == NIL )
      cSeek := ""
   ENDIF

   my_close_all_dbf()

   kalk_open_tables_unos( lAzuriraniDokument )

   SELECT kalk_pripr
   SET ORDER TO TAG "1"
   GO TOP


   fTopsD := .F.
   fFaktD := .F.

   DO WHILE .T.

      cIdFirma := field->IdFirma
      cBrDok := field->BrDok
      cIdVD := field->IdVD

      IF Eof()
         EXIT
      ENDIF

      IF Empty( cIdvd + cBrdok + cIdfirma )
         SKIP
         LOOP
      ENDIF

      IF !lAuto

         IF ( cSeek == "" )
            Box( "", 6, 65 )
            SET CURSOR ON
            @ box_x_koord() + 1, box_y_koord() + 2 SAY "KALK Dok broj:"

            @ box_x_koord() + 1, Col() + 2  SAY cIdFirma
            @ box_x_koord() + 1, Col() + 1 SAY "-" GET cIdVD  PICT "@!"
            @ box_x_koord() + 1, Col() + 1 SAY "-" GET cBrDok VALID {|| cBrdok := kalk_fix_brdok( cBrDok ), .T. }

            @ box_x_koord() + 3, box_y_koord() + 2 SAY8 "(Brdok: '00000022', '22' -> '00000022', '00005/TZ'"
            @ box_x_koord() + 4, box_y_koord() + 2 SAY8 "        '22#  ' -> '22   ', '0022' -> '00000022' ) "

            @ box_x_koord() + 6, box_y_koord() + 2 SAY8 "Štampa naljepnica D/N ?" GET cNaljepniceDN  PICT "@!" VALID cNaljepniceDN $ "DN"
            READ

            ESC_BCR
            BoxC()

            IF lAzuriraniDokument // stampa azuriranog KALK dokumenta
               open_kalk_as_pripr( cIdFirma, cIdVd, cBrDok )
            ENDIF
         ENDIF

      ENDIF

      IF ( !Empty( cSeek ) .AND. cSeek != 'IZDOKS' )
         HSEEK cSeek
         cIdfirma := SubStr( cSeek, 1, 2 )
         cIdvd := SubStr( cSeek, 3, 2 )
         cBrDok := PadR( SubStr( cSeek, 5, 8 ), 8 )
      ELSE
         HSEEK cIdFirma + cIdVD + cBrDok
      ENDIF


      IF !Empty( cOk := kalkulacija_ima_sve_cijene( cIdFirma, cIdVd, cBrDok ) ) // provjeri da li kalkulacija ima sve cijene ?
         MsgBeep( "Unutar kalkulacije nedostaju pojedine cijene bitne za obračun!##Stavke: " + cOk )
         // my_close_all_dbf()
         // RETURN .F.
      ENDIF

      IF ( cSeek != 'IZDOKS' )
         EOF CRET
      ELSE
         PRIVATE nStr := 1
      ENDIF

      IF !pdf_kalk_dokument( cIdVd )
         START PRINT CRET
         ?
      ENDIF

      DO WHILE .T.

         IF ( cSeek == 'IZDOKS' )
            IF ( PRow() > 42 ) // stampati sve odjednom
               ++nStr
               FF
            ENDIF
            SELECT kalk_pripr
            cIdfirma := kalk_pripr->idfirma
            cIdvd := kalk_pripr->idvd
            cBrdok := kalk_pripr->brdok
            HSEEK cIdFirma + cIdVD + cBrDok
         ENDIF

         IF !pdf_kalk_dokument( cIdVd )
            Preduzece()
         ENDIF

         IF cIdVD == "10"
            kalk_stampa_dok_10()

         ELSEIF ( cIdvd $ "11#12#13" )

            kalk_stampa_dok_11()

         ELSEIF ( cIdvd $ "14#94#74#KO" )
            kalk_stampa_dok_14()

         ELSEIF ( cIdvd $ "16#95#96#97" )

            kalk_stampa_dok_95()

         ELSEIF ( cidvd $ "41#42#43#47#49" )
            kalk_stampa_dok_41()

         ELSEIF ( cIdvd == "18" )
            kalk_stampa_dok_18()

         ELSEIF ( cIdvd == "19" )
            kalk_stampa_dok_19()

         ELSEIF ( cIdvd == "80" )
            kalk_stampa_dok_80()

         ELSEIF ( cIdvd == "81" )

            kalk_stampa_dok_81()

         ELSEIF ( cIdvd == "82" )
            kalk_stampa_dok_82()

         ELSEIF ( cIdvd == "IM" )
            kalk_stampa_dok_im()

         ELSEIF ( cIdvd == "IP" )
            kalk_stampa_dok_ip()

         ELSEIF ( cIdvd == "RN" )
            IF !lAzuriraniDokument
               kalk_raspored_troskova( .T. )
            ENDIF
            kalk_stampa_dok_rn()
         ELSEIF ( cidvd == "PR" )
            kalk_stampa_dok_pr()
         ENDIF

         IF ( cSeek != 'IZDOKS' )
            EXIT
         ELSE
            SELECT kalk_pripr
            SKIP
            IF Eof()
               EXIT
            ENDIF
            ?
            ?
         ENDIF


      ENDDO // cSEEK

      IF !pdf_kalk_dokument( cIdVd )
         IF ( gPotpis == "D" )
            IF ( PRow() > 57 + dodatni_redovi_po_stranici() )
               FF
               @ PRow(), 125 SAY "Str:" + Str( ++nStr, 3 )
            ENDIF
            ?
            ?
            P_12CPI
            @ PRow() + 1, 47 SAY "Obrada AOP  "; ?? Replicate( "_", 20 )
            @ PRow() + 1, 47 SAY "Komercijala "; ?? Replicate( "_", 20 )
            @ PRow() + 1, 47 SAY "Likvidatura "; ?? Replicate( "_", 20 )
         ENDIF

         ?
         ?

         FF
      ENDIF

      PushWA()
      my_close_all_dbf()

      IF !pdf_kalk_dokument( cIdVd )
         ENDPRINT
      ENDIF

      // ------------------- kraj stampe jedne kalkulacije


      kalk_open_tables_unos( lAzuriraniDokument )
      PopWa()

      IF ( cIdvd $ "80#11#81#12#13#IP#19" )
         fTopsD := .T.
      ENDIF

      IF ( cIdvd $ "10#11#81" )
         fFaktD := .T.
      ENDIF

      IF ( !Empty( cSeek ) )
         EXIT
      ENDIF

      IF lAzuriraniDokument // stampa azuriranog KALK dokumenta
         IF cNaljepniceDN == "D"
            kalk_roba_naljepnice_stampa( cIdFirma, cIdVd, cBrDok  )
         ENDIF

         cBrDok := kalk_fix_brdok_add_1( cBrDok )
         open_kalk_as_pripr( cIdFirma, cIdVd, cBrDok )

      ELSE // priprema
         IF cNaljepniceDN == "D"
            kalk_roba_naljepnice_stampa()
            o_kalk_edit()
            EXIT // podrazumjevamo da je u pripremi jedan dokument
         ENDIF
      ENDIF

   ENDDO  // vrti kroz kalkulacije

   IF ( fTopsD .AND. !lAzuriraniDokument .AND. gTops != "0 " )
      start PRINT cret
      SELECT kalk_pripr
      SET ORDER TO TAG "1"
      GO TOP
      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD
      IF ( cIdVd $ "11#12" )
         kalk_stampa_dok_11( .T. )  // maksuzija za tops - bez NC
      ELSEIF ( cIdVd == "80" )
         kalk_stampa_dok_80( .T. )
      ELSEIF ( cIdVd == "81" )
         kalk_stampa_dok_81_tops( .T. )
      ELSEIF ( cIdVd == "IP" )
         kalk_stampa_dok_ip( .T. )
      ELSEIF ( cIdVd == "19" )
         kalk_stampa_dok_19()
      ENDIF
      my_close_all_dbf()
      FF
      ENDPRINT

      kalk_generisi_tops_dokumente()

   ENDIF

   IF ( fFaktD .AND. !lAzuriraniDokument .AND. gFakt != "0 " )

      start PRINT cret
      o_kalk_edit()
      SELECT kalk_pripr
      SET ORDER TO TAG "1"
      GO TOP
      cIdFirma := IdFirma
      cBrDok := BrDok
      cIdVD := IdVD
      IF ( cIdVd $ "11#12" )
         kalk_stampa_dok_11( .T. )
      ELSEIF ( cIdVd == "10" )
         kalk_stampa_dok_10()
      ELSEIF ( cIdVd == "81" )
         kalk_stampa_dok_81( .T. )
      ENDIF
      my_close_all_dbf()
      FF
      ENDPRINT

   ENDIF

   my_close_all_dbf()

   RETURN NIL


STATIC FUNCTION pdf_kalk_dokument( cIdVd )

   IF is_legacy_ptxt()
      RETURN .F.
   ENDIF

   RETURN cIdVd $ "10#14"  // implementirano za kalk 10, 14
