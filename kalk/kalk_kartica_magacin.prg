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

STATIC __line
STATIC __txt1
STATIC __txt2

FUNCTION kalk_kartica_magacin()

   PARAMETERS cIdFirma, cIdRoba, cIdKonto

   LOCAL nNV := 0
   LOCAL nVPV := 0
   LOCAL cLine
   LOCAL cTxt1
   LOCAL cTxt2
   LOCAL cPrikSredNc := "N"
   LOCAL cIdvd := Space( 50 )
   LOCAL nNc, nSredNc, nOdstupanje, cTransakcija
   LOCAL lPrikaziObradjeno := .F.
   LOCAL cOrderBy
   LOCAL hParams := hb_Hash(), cExportDN := "N", lExport := .F.

   PRIVATE fKNabC := .F.
   PRIVATE fVeci := .F.
   PRIVATE PicCDEM := Replicate( "9", Val( gFPicCDem ) ) + gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := Replicate( "9", Val( gFPicDem ) ) + gPicDem
   PRIVATE Pickol :=  "@Z " + Replicate( "9", Val( gFPicKol ) ) + gPickol

   kartica_magacin_open_tabele()

   IF cIdFirma != NIL
      dDatOd := CToD( "" )
   ELSE
      dDatOd := Date()
   ENDIF

   dDatDo := Date()
   cPredh := "N"

   PRIVATE cIdR := cIdRoba

   cBrFDa := "N"
   cPrikFCJ2 := "N"

   IF !Empty( cRNT1 )
      PRIVATE cRNalBroj := PadR( "", 40 )
   ENDIF

   cIdPArtner := Space( 6 )
   cPVSS := "D"

   IF cIdKonto == NIL

      cIdFirma := gFirma
      cIdRoba := Space( 10 )
      cIdKonto := PadR( "1320", gDuzKonto )

      cIdRoba := fetch_metric( "kalk_kartica_magacin_id_roba", my_user(), cIdRoba )
      cIdKonto := fetch_metric( "kalk_kartica_magacin_id_konto", my_user(), cIdKonto )
      dDatOd := fetch_metric( "kalk_kartica_magacin_datum_od", my_user(), dDatOd )
      dDatDo := fetch_metric( "kalk_kartica_magacin_datum_do", my_user(), dDatDo )
      cPredh := fetch_metric( "kalk_kartica_magacin_prethodni_promet", my_user(), cPredh )
      cBrFDa := fetch_metric( "kalk_kartica_magacin_prikaz_broja_fakture", my_user(), cBrFDa )
      cPrikFCJ2 := fetch_metric( "kalk_kartica_magacin_prikaz_fakturne_cijene", my_user(), cPrikFCJ2 )
      cPVSS := fetch_metric( "kalk_kartica_magacin_prikaz_samo_saldo", my_user(), cPVSS )
      cIdKonto := PadR( cIdKonto, gDuzKonto )

      Box(, 16, 60 )
      DO WHILE .T.

         @ m_x + 1, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma

         @ m_x + 2, m_y + 2 SAY "Konto  " GET cIdKonto VALID P_Konto( @cIdKonto )


         form_get_roba_id( @cIdRoba, m_x + 3, m_y + 2 )


         IF !Empty( cRNT1 )
            @ m_x + 4, m_y + 2 SAY "Broj radnog naloga:" GET cRNalBroj PICT "@S20"
         ENDIF

         @ m_x + 5, m_y + 2 SAY "Partner (prazno-svi)"  GET cIdPArtner  VALID Empty( cIdPartner ) .OR. P_Firma( @cIdPartner )  PICT "@!"
         @ m_x + 7, m_y + 2 SAY "Datum od " GET dDatOd
         @ m_x + 7, Col() + 2 SAY "do" GET dDatDo
         @ m_x + 8, m_y + 2 SAY "sa prethodnim prometom (D/N)" GET cPredh PICT "@!" VALID cpredh $ "DN"
         @ m_x + 9, m_y + 2 SAY "Prikaz broja fakt/otpremice D/N"  GET cBrFDa  VALID cBrFDa $ "DN" PICT "@!"
         @ m_x + 10, m_y + 2 SAY "Prikaz fakturne cijene kod ulaza (KALK 10) D/N"  GET cPrikFCJ2  VALID cPrikFCJ2 $ "DN" PICT "@!"

         @ m_x + 11, m_y + 2 SAY "Prikaz vrijednosti samo u saldu ? (D/N)"  GET cPVSS VALID cPVSS $ "DN" PICT "@!"

         @ m_x + 12, m_y + 2 SAY "Tip dokumenta (;) :"  GET cIdVd PICT "@S20"
         @ m_x + 14, m_y + 2 SAY "Prikaz srednje nabavne cijene ?" GET cPrikSredNc VALID cPrikSredNc $ "DN" PICT "@!"

         @ m_x + 16, m_y + 2 SAY "Eksport u dbf:"  GET cExportDn PICT "@!" VALID cExportDN $ "DN"
         READ
         ESC_BCR

         IF cExportDN == "D"
            lExport := .T.

            create_dbf_r_export( kalk_kartica_magacin_export_dbf_struct() )
         ENDIF
         IF !Empty( cRnT1 ) .AND. !Empty( cRNalBroj )
            PRIVATE aUslRn := Parsiraj( cRNalBroj, "idzaduz2" )
         ENDIF

         IF ( Empty( cRNT1 ) .OR. Empty( cRNalBroj ) .OR. aUslRn <> NIL )
            EXIT
         ENDIF

      ENDDO
      BoxC()

      IF Empty( cIdRoba )
         IF pitanje(, "Niste zadali sifru artikla, izlistati sve kartice ?", "N" ) == "N"
            my_close_all_dbf()
            RETURN .F.
         ELSE
            cIdR := ""
         ENDIF
      ELSE
         cIdr := cIdRoba
      ENDIF

      IF Right( Trim( cIdroba ), 1 ) == ";"
         fVeci := .F.
         cIdr := Trim( StrTran( cIdroba, ";", "" ) )

      ELSEIF Right( Trim( cIdRoba ), 1 ) == ">"
         cIdr := Trim( StrTran( cIdroba, ">", "" ) )
         fVeci := .T.
      ENDIF

      IF LastKey() <> K_ESC
         set_metric( "kalk_kartica_magacin_id_roba", my_user(), cIdRoba )
         set_metric( "kalk_kartica_magacin_id_konto", my_user(), cIdKonto )
         set_metric( "kalk_kartica_magacin_datum_od", my_user(), dDatOd )
         set_metric( "kalk_kartica_magacin_datum_do", my_user(), dDatDo )
         set_metric( "kalk_kartica_magacin_prethodni_promet", my_user(), cPredh )
         set_metric( "kalk_kartica_magacin_prikaz_broja_fakture", my_user(), cBrFDa )
         set_metric( "kalk_kartica_magacin_prikaz_fakturne_cijene", my_user(), cPrikFCJ2 )
         set_metric( "kalk_kartica_magacin_prikaz_samo_saldo", my_user(), cPVSS )
      ENDIF

   ENDIF


   IF server_db_version() >= 25
      lPrikaziObradjeno := .T.
      cOrderBy := "idfirma,mkonto,idroba,datdok,obradjeno,mu_i,idvd"
   ELSE
      cOrderBy := "idfirma,mkonto,idroba,datdok,mu_i,idvd"
   ENDIF

   lBezG2 := .F.
   nKolicina := 0



   PRIVATE cFilt := ".t."

   IF !Empty( cIdPartner )
      cFilt += ".and.IdPartner==" + dbf_quote( cIdPartner )
   ENDIF

   IF !Empty( cRNT1 ) .AND. !Empty( cRNalBroj )
      cFilt += ".and." + aUslRn
   ENDIF

   IF Empty( cIdRoba )
      find_kalk_by_mkonto_idroba_idvd( cIdFirma, cIdVd, cIdKonto, NIL, cOrderBy )
   ELSE
      find_kalk_by_mkonto_idroba_idvd( cIdFirma, cIdVd, cIdKonto, cIdRoba, cOrderBy )
   ENDIF

   IF !( cFilt == ".t." )
      SET FILTER to &cFilt
   ENDIF
   GO TOP

   EOF CRET

   SELECT koncij
   SEEK Trim( cIdKonto )

   SELECT kalk

   gaZagFix := { 7, 4 }

   START PRINT CRET

   nLen := 1

   _set_zagl( @cLine, @cTxt1, @cTxt2, cPvSS )
   __line := cLine
   __txt1 := cTxt1
   __txt2 := cTxt2

   PRIVATE nTStrana := 0

   zagl_mag_kart()

   DO WHILE !Eof() .AND. iif( fVeci, idfirma + mkonto + idroba >= cIdFirma + cIdKonto + cIdR, idfirma + mkonto + idroba = cIdFirma + cIdKonto + cIdR )

      IF field->mkonto <> cIdKonto .OR. field->idfirma <> cIdFirma
         EXIT
      ENDIF

      cIdRoba := hb_UTF8ToStr( field->idroba )
      SELECT roba
      HSEEK cIdRoba

      SELECT tarifa
      HSEEK roba->idtarifa
      ? __line
      ? "Artikal:", cIdRoba, "-", Trim( Left( roba->naz, 40 ) ) + iif( roba_barkod_pri_unosu(), " BK:" + roba->barkod, "" ) + " (" + roba->jmj + ")"

      ? __line
      SELECT kalk

      nCol1 := 10
      nUlaz := nIzlaz := 0
      nRabat := nNV := nVPV := 0
      tnNVd := tnNVp := tnVPVd := tnVPVp := 0
      fPrviProl := .T.
      nColDok := 9
      nColFCJ2 := 68
      cLastPar := ""
      cSKGrup := ""

      DO WHILE !Eof() .AND. cIdFirma + cIdKonto + cIdRoba == field->idFirma + field->mkonto + hb_UTF8ToStr( field->idroba )
         nNVd := nNVp := nVPVd := nVPVp := 0

         IF lBezG2 .AND. field->idvd == "14"
            IF !( cLastPar == field->idpartner )
               cLastPar := field->idpartner
               cSKGrup := IzSifKPartn( "GRUP", idpartner, .F. ) // uzmi iz sifk karakteristiku GRUP
            ENDIF
            IF cSKGrup == "2"
               SKIP 1
               LOOP
            ENDIF
         ENDIF
         IF datdok < ddatod .AND. cPredh == "N"
            SKIP
            LOOP
         ENDIF
         IF datdok > ddatdo
            SKIP
            LOOP
         ENDIF

         IF cPredh == "D" .AND. datdok >= dDatod .AND. fPrviProl


            fPrviprol := .F. // ispis predhodnog stanja

            ? "Stanje do ", dDatOd

            @ PRow(), 35 SAY say_kolicina( nUlaz  )
            @ PRow(), PCol() + 1 SAY say_kolicina( nIzlaz )
            @ PRow(), PCol() + 1 SAY say_kolicina( nUlaz - nIzlaz )


            IF Round( nUlaz - nIzlaz, 4 ) <> 0
               @ PRow(), PCol() + 1 SAY say_kolicina( nNV / ( nUlaz - nIzlaz )   ) // NC
            ELSE
               @ PRow(), PCol() + 1 SAY say_kolicina( 0  )
            ENDIF

            IF cPVSS == "N"
               @ PRow(), PCol() + 1 SAY say_iznos( tnNVd ) // NV dug. NV pot.
               @ PRow(), PCol() + 1 SAY say_iznos( tnNVp )
            ENDIF


            @ PRow(), PCol() + 1 SAY say_iznos( nNV ) // NV

            @ PRow(), PCol() + 1 SAY say_kolicina( nRabat ) // RABAT


            IF Round( nUlaz - nIzlaz, 4 ) <> 0
               @ PRow(), PCol() + 1 SAY say_cijena( nVPV / ( nUlaz - nIzlaz ) ) // VPC
            ENDIF


         ENDIF

         IF PRow() -dodatni_redovi_po_stranici() > 62
            FF
            zagl_mag_kart()
         ENDIF

         IF field->mu_i == "1" .AND. !( field->idvd $ "12#22#94" )
            nUlaz += kolicina - gkolicina - gkolicin2
            IF field->datdok >= dDatod
               ? datdok, idvd + "-" + brdok, idtarifa
               ?? "", idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY say_kolicina( kolicina - gkolicina - gkolicin2 )
               @ PRow(), PCol() + 1 SAY say_kolicina( 0    )
               @ PRow(), PCol() + 1 SAY say_kolicina( nUlaz - nIzlaz    )

               nNc := field->nc
               cTransakcija := "   U"
               IF field->kolicina < 0
                  cTransakcija := "-U=I"
               ENDIF
               @ PRow(), PCol() + 1 SAY say_cijena( nNC )

            ENDIF

            nNVd := field->nc * ( kolicina - gkolicina - gkolicin2 )
            tnNVd += nNVd
            nNV += field->nc * ( kolicina - gkolicina - gkolicin2 )

            IF koncij->naz == "P2"
               nVPVd := roba->plc * ( kolicina - gkolicina - gkolicin2 )
               tnVPVd += nVPVd
               nVPV += roba->plc * ( kolicina - gkolicina - gkolicin2 )
            ELSE
               nVPVd := vpc * ( kolicina - gkolicina - gkolicin2 )
               tnVPVd += nVPVd
               nVPV += vpc * ( kolicina - gkolicina - gkolicin2 )
            ENDIF

            IF datdok >= dDatod

               IF cPVSS == "N" // NV dug. NV pot.
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVd   )
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVp   )
               ENDIF


               @ PRow(), PCol() + 1 SAY say_iznos( nNV   )


               @ PRow(), PCol() + 1 SAY say_cijena( 0 ) // RABAT

               IF koncij->naz == "P2" // VPC
                  @ PRow(), PCol() + 1 SAY say_cijena( roba->plc )
               ELSE
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc )
               ENDIF


               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY field->brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "
                     ?? idzaduz2
                  ENDIF
               ENDIF

               IF cPrikFCJ2 == "D" .AND. field->idvd == "10"
                  @ PRow() + iif( cBrFDa == "D", 0, 1 ), nColFCJ2 SAY say_cijena( field->fcj2 )
               ENDIF
            ENDIF

         ELSEIF mu_i == "5"

            nIzlaz += kolicina
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, field->idtarifa
               ?? "", field->idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY say_kolicina( 0         )
               @ PRow(), PCol() + 1 SAY say_kolicina( kolicina  )
               @ PRow(), PCol() + 1 SAY say_kolicina( nUlaz - nIzlaz    )

               nNc := field->nc
               cTransakcija := "   I"
               IF field->kolicina < 0
                  cTransakcija := "-I=U"
               ENDIF
               @ PRow(), PCol() + 1 SAY say_cijena( nNc )

            ENDIF

            nNVp := field->nc * ( kolicina )
            tnNVp += nNVp
            nNV -= nc * ( kolicina )
            IF koncij->naz == "P2"
               nVPVp := roba->plc * ( kolicina )
               tnVPVp += nVPVp
               nVPV -= roba->plc * ( kolicina )
            ELSE
               nVPVp := vpc * ( kolicina )
               tnVPVp += nVPVp
               nVPV -= vpc * ( kolicina )
            ENDIF
            nRabat += field->vpc * field->rabatv / 100 * field->kolicina

            IF field->datdok >= dDatod

               // NV pot. NV dug.
               IF cPVSS == "N"
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVd )
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVp )
               ENDIF

               @ PRow(), PCol() + 1 SAY say_iznos( nNV )

               // VPC
               IF koncij->naz == "P2"
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc * rabatv / 100 * kolicina  )
                  @ PRow(), PCol() + 1 SAY say_cijena( roba->plc )
               ELSE
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc * rabatv / 100 * kolicina  )
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc )
               ENDIF

               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( field->idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF

         ELSEIF mu_i == "1" .AND. ( idvd $ "12#22#94" )    // povrat
            nIzlaz -= kolicina
            IF datdok >= ddatod
               ? datdok, idvd + "-" + brdok, idtarifa
               ?? "", idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY say_kolicina( 0          )
               @ PRow(), PCol() + 1 SAY say_kolicina( -kolicina  )
               @ PRow(), PCol() + 1 SAY say_kolicina( nUlaz - nIzlaz    )


               nNc := field->nc
               @ PRow(), PCol() + 1 SAY say_cijena( nNc )

               // NC pot. NC dug.
               IF cPVSS == "N"
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVd   )
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVp   )
               ENDIF

               @ PRow(), PCol() + 1 SAY say_iznos( nNV )

            ENDIF
            nNVp := -field->nc * ( kolicina )
            tnNVp += nNVp
            nNV += nc * ( kolicina )
            IF koncij->naz == "P2"
               nVPVp := -roba->plc * ( kolicina )
               tnVPVp += nVPVp
               nVPV += roba->plc * ( kolicina )
            ELSE
               nVPVp := -vpc * ( kolicina )
               tnVPVp += nVPVp
               nVPV += vpc * ( kolicina )
            ENDIF
            IF datdok >= dDatod

               @ PRow(), PCol() + 1 SAY say_cijena( 0  ) // RABAT

               IF koncij->naz == "P2"
                  @ PRow(), PCol() + 1 SAY say_cijena( roba->plc )  // planska cijena
               ELSE
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc )
               ENDIF

               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF

         ELSEIF field->mu_i == "3"   // nivelacija

            IF field->datdok >= dDatod
               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa
            ENDIF // cpredh

            nVPVd := field->vpc * ( field->kolicina )
            tnVPVd += nVPVd
            nVPV += field->vpc * ( field->kolicina )
            IF field->datdok >= dDatod

               @ PRow(), PCol() + 1 SAY PadR( "NIV   (" + Transform( kolicina, pickol ) + ")", Len( pickol ) * 2 + 1 )
               @ PRow(), PCol() + 1 SAY PadR( " stara VPC:", Len( pickol ) -2 )
               @ PRow(), PCol() + 1 SAY say_cijena( mpcsapp       )  // kod ove kalk to predstavlja staru vpc
               @ PRow(), PCol() + 1 SAY PadR( "nova VPC:", Len( piccdem ) + iif( cPVSS == "N", 2 * ( Len( picdem ) + 1 ), 0 ) )
               @ PRow(), PCol() + 1 SAY say_cijena( vpc + mpcsapp )
               @ PRow(), PCol() + 1 SAY say_cijena( vpc         )

               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY brfaktp
                  IF !Empty( idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? idzaduz2
                  ENDIF
               ENDIF
            ENDIF

         ELSEIF mu_i == "8"
            // 15-ka

            nIzlaz +=  - kolicina
            nUlaz +=  - kolicina
            IF datdok >= dDatod
               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa
               ?? "", field->idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY say_kolicina( -kolicina  )
               @ PRow(), PCol() + 1 SAY say_kolicina( -kolicina  )
               @ PRow(), PCol() + 1 SAY say_kolicina( nUlaz - nIzlaz    )

               nNc := field->nc
               cTransakcija := "   x"
               @ PRow(), PCol() + 1 SAY say_cijena( nNc )

            ENDIF

            nRabat += vpc * rabatv / 100 * kolicina
            IF field->datdok >= dDatod

               IF cPVSS == "N"
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVd   )
                  @ PRow(), PCol() + 1 SAY say_iznos( nNVp   )
               ENDIF
               @ PRow(), PCol() + 1 SAY say_iznos( nNv  )
               IF koncij->naz == "P2"
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc * rabatv / 100 * kolicina  )
                  @ PRow(), PCol() + 1 SAY say_cijena( roba->plc  )
               ELSE
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc * rabatv / 100 * kolicina  )
                  @ PRow(), PCol() + 1 SAY say_cijena( vpc  )
               ENDIF

               IF cBrFDa == "D"
                  @ PRow() + 1, nColDok SAY field->brfaktp
                  IF !Empty( field->idzaduz2 )
                     @ PRow(), PCol() + 1 SAY " RN: "; ?? field->idzaduz2
                  ENDIF
               ENDIF
            ENDIF
         ENDIF

         IF cPrikSredNc == "D"

            IF Round( nUlaz - nIzlaz, 4 ) == 0
               nSredNc := 0
               nOdstupanje := 0
            ELSE
               nSredNc := nNv / ( nUlaz - nIzlaz )
               IF Round( nSredNC, 4 ) == 0
                  nOdstupanje := 0
               ELSE
                  nOdstupanje := Abs( Round( ( nSredNc - nNc ) / nSredNc * 100, 0 ) )
               ENDIF

               IF Round( nNc, 4 ) == 0 // a nStanje <> 0
                  nOdstupanje := 9999
               ELSE
                  nOdstupanje := Max( Abs( Round( ( nSredNc - nNc ) / nNc * 100, 0 ) ), nOdstupanje )
               ENDIF
            ENDIF

            ? Space( 48 )
            IF lPrikaziObradjeno
               ?? field->obradjeno
            ELSE
               ?? Space( 20 )
            ENDIF

            ?? cTransakcija, " SNc:", say_kolicina( nSredNc ), ""

            IF Abs( nOdstupanje ) > 60
               ?? ">>>> ODST SNc-Nc: "
            ELSE
               ?? "     odst snc-nc: "
            ENDIF
            ?? AllTrim(  say_kolicina( Abs( nOdstupanje ) ) ) + "%"
            ?
         ENDIF


         IF lExport
            hParams[ "idkonto" ] := cIdKonto
            hParams[ "idroba" ] := cIdRoba
            hParams[ "idpartner" ] := cIdPartner
            hParams[ "kolicina" ] := field->kolicina
            hParams[ "brdok" ] := field->brdok
            hParams[ "idvd" ] := field->idvd
            hParams[ "datdok" ] := field->datdok
            hParams[ "brfaktp" ] := field->brfaktp
            hParams[ "nc" ] := nNc
            hParams[ "nv" ] := nNV
            hParams[ "rabatv" ] := field->rabatv
            hParams[ "vpc" ] := field->vpc
            hParams[ "stanje" ] := nUlaz - nIzlaz

            kalk_kartica_magacin_add_item_to_r_export( hParams )
         ENDIF
         SKIP

      ENDDO




      ? __line
      ? "Ukupno:"
      @ PRow(), nCol1    SAY say_kolicina( nUlaz )
      @ PRow(), PCol() + 1 SAY say_kolicina( nIzlaz )
      @ PRow(), PCol() + 1 SAY say_kolicina( nUlaz - nIzlaz )


      IF Round( nulaz - nizlaz, 4 ) <> 0
         @ PRow(), PCol() + 1 SAY say_kolicina( nNV / ( nUlaz - nIzlaz ) )
      ELSE
         @ PRow(), PCol() + 1 SAY say_kolicina( 0 )
      ENDIF
      IF cPVSS == "N"
         @ PRow(), PCol() + 1 SAY say_iznos( tnNVd )
         @ PRow(), PCol() + 1 SAY say_iznos( tnNVp )
      ENDIF
      @ PRow(), PCol() + 1 SAY say_iznos( nNV )
      @ PRow(), PCol() + 1 SAY say_kolicina( nRabat  )



      ? __line
      ?
      ?

   ENDDO

   FF
   endprint

   my_close_all_dbf()
   IF lExport
      open_r_export_table()
   ENDIF

   RETURN .T.



STATIC FUNCTION kartica_magacin_open_tabele()

   SELECT ( F_SIFK )
   IF Used()
      USE
   ENDIF

   SELECT ( F_SIFV )
   IF Used()
      USE
   ENDIF

   SELECT ( F_PARTN )
   IF Used()
      USE
   ENDIF

   SELECT ( F_TARIFA )
   IF Used()
      USE
   ENDIF

   SELECT ( F_ROBA )
   IF Used()
      USE
   ENDIF

   SELECT ( F_KONTO )
   IF Used()
      USE
   ENDIF

   SELECT ( F_KALK )
   IF Used()
      USE
   ENDIF

   SELECT ( F_KONCIJ )
   IF Used()
      USE
   ENDIF

   O_PARTN
   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO
   o_koncij()
   o_kalk() // kalk_kartica

   RETURN .T.


STATIC FUNCTION _set_zagl( cLine, cTxt1, cTxt2, cPVSS, cPicKol, cPicCDem )

   LOCAL nPom
   LOCAL aKMag := {}

   nPom := 8
   // datum
   AAdd( aKMag, { nPom, PadC( "Datum", nPom ), PadC( "", nPom ) } )

   nPom := 11
   // dokument
   AAdd( aKMag, { nPom, PadC( "Dokument", nPom ), PadC( "", nPom ) } )

   nPom := 6
   // tarifa
   AAdd( aKMag, { nPom, PadC( "Tarifa", nPom ), PadC( "", nPom ) } )

   // partner
   AAdd( aKMag, { nPom, PadC( "Part-", nPom ), PadC( "ner", nPom ) } )

   nPom := Len( PicKol ) - 3
   // ulaz, izlaz, stanje
   AAdd( aKMag, { nPom, PadC( "Ulaz", nPom ), PadC( "1", nPom ) } )
   AAdd( aKMag, { nPom, PadC( "Izlaz", nPom ), PadC( "2", nPom ) } )
   AAdd( aKMag, { nPom, PadC( "Stanje", nPom ), PadC( "(1 - 2)", nPom ) } )


   nPom := Len( PicCDem )
   // NC, NV
   AAdd( aKMag, { nPom, PadC( "NC", nPom ), PadC( "", nPom ) } )

   IF cPVSS == "N"

      nPom := Len( PicDem )
      // nv.dug
      AAdd( aKMag, { nPom, PadC( "NV Dug.", nPom ), PadC( "", nPom ) } )
      // nv.pot
      AAdd( aKMag, { nPom, PadC( "NV Pot.", nPom ), PadC( "", nPom ) } )

   ENDIF

   nPom := Len( PicCDem )
   // NV
   AAdd( aKMag, { nPom, PadC( "NV", nPom ), PadC( "", nPom ) } )

   nPom := Len( PicKol ) - 3
   // RABAT
   AAdd( aKMag, { nPom, PadC( "RABAT", nPom ), PadC( "", nPom ) } )

   nPom := Len( PicDem )
   // PC
   AAdd( aKMag, { nPom, PadC( "PC", nPom ), PadC( "bez PDV", nPom ) } )



   cLine := SetRptLineAndText( aKMag, 0 )
   cTxt1 := SetRptLineAndText( aKMag, 1, "*" )
   cTxt2 := SetRptLineAndText( aKMag, 2, "*" )

   RETURN .T.



STATIC FUNCTION zagl_mag_kart()

   SELECT konto
   HSEEK cIdKonto

   ?

   Preduzece()
   P_12CPI

   ?? "KARTICA MAGACIN za period", ddatod, "-", ddatdo, Space( 10 ), "Str:", Str( ++nTStrana, 3 )
   IspisNaDan( 5 )
   ? "Konto: ", cIdKonto, "-", konto->naz

   SELECT kalk


   IF cPVSS == "N"
      P_COND2
   ELSE
      P_COND
   ENDIF

   ? __line
   ? __txt1
   ? __txt2
   ? __line

   RETURN ( nil )



STATIC FUNCTION kalk_kartica_magacin_add_item_to_r_export( hParams )

   LOCAL nTArea := Select()

   O_R_EXP
   SELECT r_export

   APPEND BLANK
   REPLACE field->idkonto WITH hParams[ "idkonto" ], ;
      field->idvd WITH hParams[ "idvd" ], ;
      field->idroba WITH hParams[ "idroba" ], ;
      field->brdok WITH hParams[ "brdok" ], ;
      field->datdok WITH hParams[ "datdok" ], ;
      field->kolicina WITH hParams[ "kolicina" ], ;
      field->nc WITH hParams[ "nc" ], ;
      field->stanje WITH hParams[ "stanje" ], ;
      field->nv WITH hParams[ "nv" ], ;
      field->rabatv WITH hParams[ "rabatv" ], ;
      field->vpc WITH hParams[ "vpc" ], ;
      field->brfaktp WITH hParams[ "brfaktp" ], ;
      field->idpartner WITH hParams[ "idpartner" ]

   SELECT ( nTArea )

   RETURN .T.


FUNCTION kalk_kartica_magacin_export_dbf_struct()

   LOCAL aDbf := {}

   AAdd( aDbf, { "idkonto", "C", 7, 0 }  )
   AAdd( aDbf, { "idroba", "C", 10, 0 }  )
   AAdd( aDbf, { "idpartner", "C", 6, 0 }  )
   AAdd( aDbf, { "idvd", "C", 2, 0 }  )
   AAdd( aDbf, { "brdok", "C", 8, 0 }  )
   AAdd( aDbf, { "brfaktp", "C", 10, 0 }  )
   AAdd( aDbf, { "datdok", "D", 8, 0 }  )
   AAdd( aDbf, { "kolicina", "N", 15, 3 }  )
   AAdd( aDbf, { "stanje", "N", 15, 3 }  )
   AAdd( aDbf, { "nc", "N", 15, 3 }  )
   AAdd( aDbf, { "nv", "N", 15, 3 }  )
   AAdd( aDbf, { "rabatv", "N", 15, 3 }  )
   AAdd( aDbf, { "vpc", "N", 15, 3 }  )

   RETURN aDbf
