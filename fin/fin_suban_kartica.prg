/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

MEMVAR m, GetList, m_x, m_y
MEMVAR gNFirma, gFirma
MEMVAR cIdFirma, fk1, fk2, fk3, fk4, cK1, cK2, cK3, cK4
MEMVAR qqKonto, qqPartner
MEMVAR nStr
MEMVAR gPicBHD, gPicDEM, picDEM, picBHD, fOtvSt

FUNCTION fin_suban_kartica( lOtvst ) // param lOtvst  - .t. otvorene stavke

   LOCAL cBrza := "D"
   LOCAL nC1 := 37
   LOCAL nSirOp := 20
   LOCAL nCOpis := 0
   LOCAL cOpis := ""
   LOCAL cBoxName
   LOCAL dPom := CToD( "" )
   LOCAL cOpcine := Space( 20 )
   LOCAL cExpDbf := "N"
   LOCAL aExpFields
   LOCAL __vr_nal
   LOCAL __br_nal
   LOCAL __br_veze
   LOCAL __r_br
   LOCAL __dat_val
   LOCAL __dat_nal
   LOCAL __opis
   LOCAL __p_naz
   LOCAL __k_naz
   LOCAL __dug
   LOCAL __pot
   LOCAL _fin_params := fin_params()
   LOCAL _fakt_params := fakt_params()
   LOCAL cLibreOffice := "N"
   LOCAL nX := 2
   LOCAL bZagl  :=  {|| zagl_suban_kartica( .T. ) }
   LOCAL bZagl2 :=  {|| zagl_suban_kartica( .F. ) }

   LOCAL oPDF, xPrintOpt


   PRIVATE fK1 := _fin_params[ "fin_k1" ]
   PRIVATE fK2 := _fin_params[ "fin_k2" ]
   PRIVATE fK3 := _fin_params[ "fin_k3" ]
   PRIVATE fK4 := _fin_params[ "fin_k4" ]

   PRIVATE cIdFirma := gFirma
   PRIVATE fOtvSt := lOtvSt
   PRIVATE c1k1z := "N"
   PRIVATE picBHD := FormPicL( gPicBHD, 16 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )


   PRIVATE cSazeta := "N"
   PRIVATE cK14 := "1"

   cDinDem := "1"
   dDatOd := CToD( "" )
   dDatDo := CToD( "" )
   cKumul := "1"
   cPredh := "1"
   qqKonto := ""
   qqPartner := ""
   qqBrDok := Space( 40 )
   qqNazKonta := Space( 40 )

   IF PCount() == 0
      fOtvSt := .F.
   ENDIF

   cKumul := fetch_metric( "fin_kart_kumul", my_user(), cKumul )
   cPredh := fetch_metric( "fin_kart_predhodno_stanje", my_user(), cPredh )
   cBrza := fetch_metric( "fin_kart_brza", my_user(), cBrza )
   cSazeta := fetch_metric( "fin_kart_sazeta", my_user(), cSazeta )
   cIdFirma := fetch_metric( "fin_kart_org_id", my_user(), cIdFirma )
   qqKonto := fetch_metric( "fin_kart_konto", my_user(), qqKonto )
   qqPartner := fetch_metric( "fin_kart_partner", my_user(), qqPartner )
   qqBrDok := fetch_metric( "fin_kart_broj_dokumenta", my_user(), qqBrDok )
   dDatOd := fetch_metric( "fin_kart_datum_od", my_user(), dDatOd )
   dDatDo := fetch_metric( "fin_kart_datum_do", my_user(), dDatDo )
   cDinDem := fetch_metric( "fin_kart_valuta", my_user(), cDinDem )
   c1K1Z := fetch_metric( "fin_kart_kz", my_user(), c1K1Z )
   cK14 := fetch_metric( "fin_kart_k14", my_user(), cK14 )

   IF gNW == "D"
      cIdFirma := gFirma
   ENDIF

   cK1 := "9"
   cK2 := "9"
   cK3 := "99"
   cK4 := "99"

   IF gDUFRJ == "D"
      cIdRj := Space( 60 )
   ELSE
      cIdRj := "999999"
   ENDIF

   cFunk := "99999"
   cFond := "9999"

   PRIVATE cRasclaniti := "N"
   PRIVATE cIdVN := Space( 40 )

   cBoxName := "SUBANALITIČKA KARTICA"

   IF fOtvSt
      cBoxName += " - OTVORENE STAVKE"
   ENDIF

   Box( "#" + cBoxName, 23, 65 )

   SET CURSOR ON
   @ m_x + nX, m_y + 2 SAY "LibreOffice kartica (D/N) ?" GET cLibreOffice PICT "@!"
   READ

   IF cLibreOffice == "D"
      BoxC()
      RETURN fin_suban_kartica_sql( lOtvSt )
   ENDIF

   ++nX
   @ m_x + ( ++nX ), m_y + 2 SAY "BEZ/SA kumulativnim prometom  (1/2):" GET cKumul
   @ m_x + ( ++nX ), m_y + 2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh
   @ m_x + ( ++nX ), m_y + 2 SAY "Brza kartica (D/N)" GET cBrza PICT "@!" VALID cBrza $ "DN"
   @ m_x + nX, Col() + 2 SAY8 "Sažeta kartica (bez opisa) D/N" GET cSazeta  PICT "@!" VALID cSazeta $ "DN"
   READ

   DO WHILE .T.

      close_open_kartica_tbl()

      IF gDUFRJ == "D"
         cIdFirma := PadR( gFirma + ";", 30 )
         @ m_x + ( ++nX ), m_y + 2 SAY "Firma: " GET cIdFirma PICT "@!S20"
      ELSE
         IF gNW == "D"
            @ m_x + ( ++nX ), m_y + 2 SAY "Firma "
            ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + ( ++nX ), m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cIdfirma := Left( cIdFirma, 2 ), .T. }
         ENDIF
      ENDIF

      IF cBrza == "D"
         qqKonto := PadR( qqKonto, 7 )
         qqPartner := PadR( qqPartner, Len( partn->id ) )
         @ m_x + ( ++nX ), m_y + 2 SAY "Konto  " GET qqKonto  VALID P_KontoFin( @qqKonto )
         @ m_x + ( ++nX ), m_y + 2 SAY "Partner" GET qqPartner VALID Empty( qqPartner ) .OR. RTrim( qqPartner ) == ";" .OR. P_Firma( @qqPartner ) PICT "@!"
      ELSE
         qqKonto := PadR( qqkonto, 100 )
         qqPartner := PadR( qqPartner, 100 )
         @ m_x + ( ++nX ), m_y + 2 SAY "Konto  " GET qqKonto  PICTURE "@!S50"
         @ m_x + ( ++nX ), m_y + 2 SAY "Partner" GET qqPartner PICTURE "@!S50"
      ENDIF

      @ m_x + ( ++nX ), m_y + 2 SAY "Datum dokumenta od:" GET dDatod
      @ m_x + nX, Col() + 2 SAY "do" GET dDatDo   VALID dDatOd <= dDatDo
      @ m_x + ( ++nX ), m_y + 2 SAY "Uslov za vrstu naloga (prazno-sve)" GET cIdVN PICT "@!S20"

      IF fin_dvovalutno()
         @ m_x + ( ++nX ), m_y + 2 SAY "Kartica za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3)"  GET cDinDem VALID cDinDem $ "123"
      ELSE
         cDinDem := "1"
      ENDIF

      @ m_x + ( ++nX ), m_y + 2 SAY "Prikaz  K1-K4 (1); Dat.Valute (2); oboje (3)" + iif( _fin_params[ "fin_tip_dokumenta" ] .AND. cSazeta == "N", "; nista (4)", "" )  GET cK14 VALID cK14 $ "123" + iif( _fin_params[ "fin_tip_dokumenta" ] .AND. cSazeta == "N", "4", "" )

      cRasclaniti := "N"

      IF gRJ == "D"
         @ m_x + ( ++nX ), m_y + 2 SAY8 "Raščlaniti po RJ/FUNK/FOND; "  GET cRasclaniti PICT "@!" VALID cRasclaniti $ "DN"
      ENDIF

      UpitK1K4( 14 )

      @ Row() + 1, m_y + 2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"

      IF cBrza <> "D"
         @ Row() + 1, m_y + 2 SAY "Uslov za naziv konta (prazno-svi) " GET qqNazKonta PICT "@!S20"
      ENDIF

      @ Row() + 1, m_y + 2 SAY8 "Općina (prazno-sve):" GET cOpcine
      @ Row() + 1, m_y + 2 SAY "Svaka kartica treba da ima zaglavlje kolona ? (D/N)"  GET c1k1z PICT "@!" VALID c1k1z $ "DN"
      @ Row() + 1, m_y + 2 SAY "Export kartice u dbf ? (D/N)"  GET cExpDbf PICT "@!" VALID cExpDbf $ "DN"

      READ
      ESC_BCR

      IF !( cK14 $ "123" ) .AND. ( cSazeta == "D" .OR. gNW == "D" )
         cK14 := "3"
      ENDIF
      IF cSazeta == "N"
         IF cDinDem == "3"
            nC1 := 59 + iif( _fin_params[ "fin_tip_dokumenta" ], 17, 0 )
         ELSE
            nC1 := 63 + iif( _fin_params[ "fin_tip_dokumenta" ], 17, 0 )
         ENDIF
      ENDIF

      IF cDinDem == "3"
         cKumul := "1"
      ENDIF

      aUsl3 := parsiraj( cIdVN, "IDVN", "C" )

      IF gDUFRJ == "D"
         aUsl4 := Parsiraj( cIdFirma, "IdFirma" )
         aUsl5 := Parsiraj( cIdRJ, "IdRj" )
      ENDIF

      aBV := Parsiraj( qqBrDok, "UPPER(BRDOK)", "C" )
      aNK := Parsiraj( qqNazKonta, "UPPER(naz)", "C" )

      IF cBrza == "D"
         IF aBV <> NIL .AND. aUsl3 <> NIL .AND. iif( gDUFRJ == "D", aUsl4 <> NIL .AND. aUsl5 <> NIL, .T. )
            EXIT
         ENDIF
      ELSE
         qqKonto := Trim( qqKonto )
         qqPartner := Trim( qqPartner )
         aUsl1 := parsiraj( qqKonto, "IdKonto", "C" )
         aUsl2 := parsiraj( qqPartner, "IdPartner", "C" )

         IF aBV <> NIL .AND. aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. aUsl3 <> NIL .AND. iif( gDUFRJ == "D", aUsl4 <> NIL .AND. aUsl5 <> NIL, .T. )
            EXIT
         ENDIF
      ENDIF

   ENDDO
   BoxC()

   IF cSazeta == "D"
      PRIVATE picBHD := FormPicL( gPicBHD, 14 )
   ENDIF

   set_metric( "fin_kart_kumul", my_user(), cKumul )
   set_metric( "fin_kart_predhodno_stanje", my_user(), cPredh )
   set_metric( "fin_kart_brza", my_user(), cBrza )
   set_metric( "fin_kart_sazeta", my_user(), cSazeta )
   set_metric( "fin_kart_org_id", my_user(), cIdFirma )
   set_metric( "fin_kart_konto", my_user(), qqKonto )
   set_metric( "fin_kart_partner", my_user(), qqPartner )
   set_metric( "fin_kart_broj_dokumenta", my_user(), qqBrDok )
   set_metric( "fin_kart_datum_od", my_user(), dDatOd )
   set_metric( "fin_kart_datum_do", my_user(), dDatDo )
   set_metric( "fin_kart_valuta", my_user(), cDinDem )
   set_metric( "fin_kart_kz", my_user(), c1K1Z )
   set_metric( "fin_kart_k14", my_user(), cK14 )

   IF cExpDbf == "D"
      // inicijalizuj export
      aExpFields := g_exp_fields()
      t_exp_create( aExpFields )
   ENDIF

   cIdFirma := Trim( cIdFirma )

   IF cDinDem == "3"
      IF cSazeta == "D"
         m := "-- -------- ---------- -------- -------- -------------- -------------- -------------- ------------ ------------ ------------"
      ELSE
         IF _fin_params[ "fin_tip_dokumenta" ] .AND. cK14 == "4"
            m := "-- -------- ---- ---------------- ---------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ELSEIF _fin_params[ "fin_tip_dokumenta" ]
            m := "-- -------- ---- ---------------- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ELSE
            m := "-- -------- ---- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ENDIF
      ENDIF
   ELSEIF cKumul == "1"
      IF cSazeta == "D"
         m := "-- -------- ---------- -------- -------- -------------- -------------- --------------"
      ELSE
         IF _fin_params[ "fin_tip_dokumenta" ]
            m := "-- -------- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
         ELSE
            m := "-- -------- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
         ENDIF
      ENDIF
   ELSE
      IF cSazeta == "D"
         m := "-- -------- ---------- -------- -------- -------------- ------------- --------------- -------------- --------------"
      ELSE
         IF _fin_params[ "fin_tip_dokumenta" ] .AND. cK14 == "4"
            m := "-- -------- ---- ---------------- ---------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
         ELSEIF _fin_params[ "fin_tip_dokumenta" ]
            m := "-- -------- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
         ELSE
            m := "-- -------- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
         ENDIF
      ENDIF
   ENDIF

   lVrsteP := .F.

   close_open_kartica_tbl()

   IF _fakt_params[ "fakt_vrste_placanja" ]
      lVrsteP := .T.
      O_VRSTEP
   ENDIF

   SELECT SUBAN

   CistiK1k4()

   cFilter := ".t." + iif( !Empty( cIdVN ), ".and." + aUsl3, "" ) + ;
      iif( cBrza == "N", ".and." + aUsl1 + ".and." + aUsl2, "" ) + ;
      iif( Empty( dDatOd ) .OR. cPredh == "2", "", ".and.DATDOK>=" + dbf_quote( dDatOd ) ) + ;
      iif( Empty( dDatDo ), "", ".and.DATDOK<=" + dbf_quote( dDatDo ) ) + ;
      iif( fk1 .AND. Len( ck1 ) <> 0, ".and.k1=" + dbf_quote( ck1 ), "" ) + ;
      iif( fk2 .AND. Len( ck2 ) <> 0, ".and.k2=" + dbf_quote( ck2 ), "" ) + ;
      iif( fk3 .AND. Len( ck3 ) <> 0, ".and.k3=ck3", "" ) + ;
      iif( fk4 .AND. Len( ck4 ) <> 0, ".and.k4=" + dbf_quote( ck4 ), "" ) + ;
      iif( gRj == "D" .AND. Len( cIdrj ) <> 0, iif( gDUFRJ == "D", ".and." + aUsl5, ".and.idrj=" + dbf_quote( cIdRJ ) ), "" ) + ;
      iif( gTroskovi == "D" .AND. Len( cFunk ) <> 0, ".and.funk=" + dbf_quote( cFunk ), "" ) + ;
      iif( gTroskovi == "D" .AND. Len( cFond ) <> 0, ".and.fond=" + dbf_quote( cFond ), "" ) + ;
      iif( gDUFRJ == "D", ".and." + aUsl4, ;
      iif( Len( cIdFirma ) < 2, ".and. IDFIRMA=" + dbf_quote( cIdFirma ), "" ) + ;
      iif( Len( cIdFirma ) < 2 .AND. cBrza == "D", ".and.IDKONTO==" + dbf_quote( qqKonto ), "" ) + ;
      iif( Len( cIdFirma ) < 2 .AND. cBrza == "D" .AND. !( RTrim( qqPartner ) == ";" ), ".and.IDPARTNER==" + dbf_quote( qqPartner ), "" ) )

   IF !Empty( qqBrDok )
      cFilter += ( ".and." + aBV )
   ENDIF

   cFilter := StrTran( cFilter, ".t..and.", "" )

   IF Len( cIdFirma ) < 2 .OR. gDUFRJ == "D"
      SET INDEX TO
      IF cRasclaniti == "D"
         INDEX ON idkonto + idpartner + idrj + funk + fond TO SUBSUB for &cFilter
      ELSEIF cBrza == "D" .AND. RTrim( qqPartner ) == ";"
         INDEX ON IdKonto + DToS( DatDok ) + idpartner TO SUBSUB for &cFilter
      ELSE
         INDEX ON IdKonto + IdPartner + DToS( DatDok ) + BrNal + RBr TO SUBSUB for &cFilter
      ENDIF
   ELSE
      IF cRasclaniti == "D"
         SET INDEX TO
         INDEX ON idfirma + idkonto + idpartner + idrj + funk + fond TO SUBSUB for &cFilter
      ELSE
         IF cfilter == ".t."
            SET FILTER TO
         ELSE
            SET FILTER to &cFilter
         ENDIF
      ENDIF
   ENDIF

   IF Len( cIdFirma ) < 2 .OR. gDUFRJ == "D"
      GO TOP
   ELSE
      IF cBrza == "N"
         HSEEK cIdFirma
      ELSE
         IF RTrim( qqPartner ) == ";"
            SET ORDER TO TAG "5"
            GO TOP
            HSEEK cIdFirma + qqKonto
         ELSE
            HSEEK cIdFirma + qqKonto + qqPartner
         ENDIF
      ENDIF
   ENDIF


   EOF RET

   nStr := 0

   PrikK1k4()

   nSviD := 0
   nSviP := 0
   nSviD2 := 0
   nSviP2 := 0


   IF !is_legacy_ptxt()
      oPDF := PDFClass():New()
      xPrintOpt := hb_Hash()
      xPrintOpt[ "tip" ] := "PDF"
      xPrintOpt[ "layout" ] := "portrait"
      xPrintOpt[ "font_size" ] := 7
      xPrintOpt[ "opdf" ] := oPDF
      xPrintOpt[ "left_space" ] := 0
   ENDIF
   start_print_close_ret( xPrintOpt )

   Eval( bZagl )

   DO WHILE !Eof() .AND. iif( gDUFRJ != "D", IdFirma == cIdFirma, .T. )
      nKonD := 0
      nKonP := 0
      nKonD2 := 0
      nKonP2 := 0
      cIdKonto := IdKonto

      IF cBrza == "D"
         IF IdKonto <> qqKonto .OR. IdPartner <> qqPartner .AND. RTrim( qqPartner ) != ";"
            EXIT
         ENDIF
      ENDIF
      IF !Empty( qqNazKonta )
         SELECT konto
         HSEEK cIdKonto
         IF !( &( aNK ) )
            SELECT suban
            SKIP 1
            LOOP
         ELSE
            SELECT suban
         ENDIF
      ENDIF

      DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. iif( gDUFRJ != "D", IdFirma == cIdFirma, .T. )

         __k_naz := ""
         __p_naz := ""

         nPDugBHD := 0
         nPPotBHD := 0
         nPDugDEM := 0
         nPPotDEM := 0  // prethodni promet
         nDugBHD := 0
         nPotBHD := 0
         nDugDEM := 0
         nPotDEM := 0
         nZDugBHD := 0
         nZPotBHD := 0
         nZDugDEM := 0
         nZPotDEM := 0
         cIdPartner := IdPartner

         nTarea := Select()

         IF !Empty( cOpcine )
            SELECT partn
            SEEK cIdPartner
            IF Found() .AND. field->id == cIdPartner .AND. AllTrim( field->idops ) $ AllTrim( cOpcine )
               //
            ELSE
               SELECT ( nTarea )
               SKIP
               LOOP
            ENDIF
         ENDIF

         SELECT ( nTarea )

         IF cRasclaniti == "D"
            cRasclan := idrj + funk + fond
         ELSE
            cRasclan := ""
         ENDIF

         IF cBrza == "D"
            IF IdKonto <> qqKonto .OR. IdPartner <> qqPartner .AND. RTrim( qqPartner ) != ";"
               EXIT
            ENDIF
         ENDIF

         check_nova_strana( bZagl, oPdf )

         ? m
         ? "KONTO   "
         @ PRow(), PCol() + 1 SAY cIdKonto
         SELECT KONTO
         HSEEK cIdKonto
         __k_naz := field->naz

         @ PRow(), PCol() + 2 SAY naz
         ? "Partner "
         @ PRow(), PCol() + 1 SAY iif( cBrza == "D" .AND. RTrim( qqPartner ) == ";", ":  SVI", cIdPartner )
         IF cRasclaniti == "D"
            SELECT rj
            SET ORDER TO TAG "ID"
            SEEK cRasclan
            ? "        "
            @ PRow(), PCol() + 1 SAY Left( cRasclan, 6 ) + "/" + SubStr( cRasclan, 7, 5 ) + "/" + SubStr( cRasclan, 12 ) + " / " + Ocitaj( F_RJ, Left( cRasclan, 6 ), "NAZ" )
            SELECT konto
         ENDIF

         IF !( cBrza == "D" .AND. RTrim( qqPartner ) == ";" )
            SELECT PARTN
            HSEEK cIdPartner
            __p_naz := field->naz
            @ PRow(), PCol() + 1 SAY AllTrim( naz )
            @ PRow(), PCol() + 1 SAY AllTrim( naz2 )
            @ PRow(), PCol() + 1 SAY ZiroR
         ENDIF

         SELECT SUBAN

         IF c1K1z == "D"
            check_nova_strana( bZagl2, oPdf )
         ELSE
            ? m
         ENDIF

         fPrviPr := .T.  // prvi prolaz

         DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. ( cIdPartner == IdPartner .OR. ( cBrza == "D" .AND. RTrim( qqPartner ) == ";" ) ) .AND. Rasclan() .AND. iif( gDUFRJ != "D", IdFirma == cIdFirma, .T. )

            IF check_nova_strana( bZagl, oPdf )

               ? m
               ? "KONTO   "
               @ PRow(), PCol() + 1 SAY cIdKonto
               SELECT KONTO
               HSEEK cIdKonto
               @ PRow(), PCol() + 2 SAY naz
               ? "Partner "
               @ PRow(), PCol() + 1 SAY iif( cBrza == "D" .AND. RTrim( qqPartner ) == ";", ":  SVI", cIdPartner )
               IF !( cBrza == "D" .AND. RTrim( qqPartner ) == ";" )
                  SELECT PARTN
                  HSEEK cIdPartner
                  @ PRow(), PCol() + 1 SAY AllTrim( naz )
                  @ PRow(), PCol() + 1 SAY AllTrim( naz2 )
                  @ PRow(), PCol() + 1 SAY ZiroR
               ENDIF
               ? "        "
               @ PRow(), PCol() + 1 SAY Left( cRasclan, 6 ) + "/" + SubStr( cRasclan, 7, 5 ) + "/" + SubStr( cRasclan, 12 )
               SELECT SUBAN
               ? m
            ENDIF

            IF cPredh == "2" .AND. fPrviPr
               fPrviPr := .F.
               DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. ( cIdPartner == IdPartner .OR. ( cBrza == "D" .AND. RTrim( qqPartner ) == ";" ) ) .AND. Rasclan() .AND. dDatOd > DatDok  .AND. iif( gDUFRJ != "D", IdFirma == cIdFirma, .T. )
                  IF fOtvSt .AND. OtvSt == "9"
                     IF d_P == "1"
                        nZDugBHD += iznosbhd
                        nZDugDEM += iznosdem
                     ELSE
                        nZPotBHD += iznosbhd
                        nZPotDEM += iznosdem
                     ENDIF
                  ELSE
                     IF d_P == "1"
                        nPDugBHD += iznosbhd
                        nPDugDEM += iznosdem
                     ELSE
                        nPPotBHD += iznosbhd
                        nPPotDEM += iznosdem
                     ENDIF
                  ENDIF
                  SKIP
               ENDDO  // prethodni promet

               ? "PROMET DO "; ?? dDatOd
               IF cSazeta == "D"
                  IF cDinDem == "3"
                     @ PRow(), 36 SAY ""
                  ELSE
                     @ PRow(), 36 SAY ""
                  ENDIF
               ELSE
                  IF cDinDem == "3"
                     IF _fin_params[ "fin_tip_dokumenta" ]
                        @ PRow(), 58 + iif( cK14 == "4", 8, 17 ) SAY ""
                     ELSE
                        @ PRow(), 58 SAY ""
                     ENDIF
                  ELSE
                     IF _fin_params[ "fin_tip_dokumenta" ]
                        @ PRow(), 62 + iif( cK14 == "4", 8, 17 ) SAY ""
                     ELSE
                        @ PRow(), 62 SAY ""
                     ENDIF
                  ENDIF
               ENDIF

               nC1 := PCol() + 1
               IF cDinDem == "1"
                  @ PRow(), PCol() + 1 SAY nPDugBHD PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY nPPotBHD PICTURE picBHD
                  nDugBHD += nPDugBHD
                  nPotBHD += nPPotBHD
               ELSEIF cDinDem == "2"   // devize
                  @ PRow(), PCol() + 1 SAY nPDugDEM PICTURE picbhd
                  @ PRow(), PCol() + 1 SAY nPPotDEM PICTURE picbhd
                  nDugDEM += nPDugDEM
                  nPotDEM += nPPotDEM
               ELSEIF cDinDem == "3"   // devize
                  @ PRow(), PCol() + 1 SAY nPDugBHD PICTURE picBHD
                  @ PRow(), PCol() + 1 SAY nPPotBHD PICTURE picBHD
                  nDugBHD += nPDugBHD
                  nPotBHD += nPPotBHD
                  @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
                  @ PRow(), PCol() + 1 SAY nPDugDEM PICTURE picdem
                  @ PRow(), PCol() + 1 SAY nPPotDEM PICTURE picdem
                  nDugDEM += nPDugDEM
                  nPotDEM += nPPotDEM
                  @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picdem
               ENDIF

               IF cKumul == "2"  // sa kumulativom
                  IF cDinDem == "1"
                     @ PRow(), PCol() + 1 SAY nDugBHD PICTURE picbhd
                     @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picbhd
                  ELSE
                     @ PRow(), PCol() + 1 SAY nDugDEM PICTURE picbhd
                     @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picbhd
                  ENDIF
               ENDIF

               IF cDinDem == "1"  // dinari
                  @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
               ELSEIF cDinDem == "2"
                  @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
               ENDIF

               IF !( cIdKonto == IdKonto .AND. ( cIdPartner == IdPartner .OR. ( cBrza == "D" .AND. RTrim( qqPartner ) == ";" ) ) ) .AND. Rasclan()
                  LOOP
               ENDIF

            ENDIF

            IF !( fOtvSt .AND. OtvSt == "9" )

               __vr_nal := field->idvn
               __br_nal := field->brnal
               __r_br := field->rbr
               __dat_nal := field->datdok
               __dat_val := field->datval
               __opis := field->opis
               __br_veze := field->brdok

               ? IdVN
               @ PRow(), PCol() + 1 SAY BrNal
               IF cSazeta == "N"
                  @ PRow(), PCol() + 1 SAY RBr
                  IF _fin_params[ "fin_tip_dokumenta" ]
                     @ PRow(), PCol() + 1 SAY IdTipDok
                     SELECT TDOK
                     HSEEK SUBAN->IdTipDok
                     @ PRow(), PCol() + 1 SAY PadR( naz, 13 )
                  ENDIF
               ENDIF

               SELECT SUBAN

               @ PRow(), PCol() + 1 SAY PadR( BrDok, 10 )
               @ PRow(), PCol() + 1 SAY datdok

               IF ck14 == "1"
                  @ PRow(), PCol() + 1 SAY k1 + "-" + k2 + "-" + K3Iz256( k3 ) + k4
               ELSEIF ck14 == "2"
                  @ PRow(), PCol() + 1 SAY DatVal
               ELSEIF ck14 == "3"
                  nC7 := PCol() + 1
                  @ PRow(), nc7 SAY DatVal
               ENDIF

               IF cSazeta == "N"
                  IF cDinDem == "3"
                     nSirOp := 16
                     nCOpis := PCol() + 1
                     @ PRow(), PCol() + 1 SAY PadR( cOpis := AllTrim( Opis ), 16 )
                  ELSE
                     nSirOp := 20
                     nCOpis := PCol() + 1
                     @ PRow(), PCol() + 1 SAY PadR( cOpis := AllTrim( Opis ), 20 )
                  ENDIF
               ENDIF

               nC1 := PCol() + 1
            ENDIF

            IF cDinDem == "1"
               IF fOtvSt .AND. OtvSt == "9"
                  IF D_P == "1"
                     nZDugBHD += IznosBHD
                  ELSE
                     nZPotBHD += IznosBHD
                  ENDIF
               ELSE // otvorena stavka
                  IF D_P == "1"
                     @ PRow(), PCol() + 1 SAY IznosBHD PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY 0 PICT picBHD
                     nDugBHD += IznosBHD
                  ELSE
                     @ PRow(), PCol() + 1 SAY 0 PICT picBHD
                     @ PRow(), PCol() + 1 SAY IznosBHD PICTURE picBHD
                     nPotBHD += IznosBHD
                  ENDIF

                  IF cKumul == "2"   // prikaz kumulativa
                     @ PRow(), PCol() + 1 SAY nDugBHD PICT picbhd
                     @ PRow(), PCol() + 1 SAY nPotBHD PICT picbhd
                  ENDIF
               ENDIF

            ELSEIF cDinDem == "2"

               IF fOtvSt .AND. OtvSt == "9"
                  IF D_P == "1"
                     nZDugDEM += IznosDEM
                  ELSE
                     nZPotDEM += IznosDEM
                  ENDIF
               ELSE
                  IF D_P == "1"
                     @ PRow(), PCol() + 1 SAY IznosDEM PICTURE picbhd
                     @ PRow(), PCol() + 1 SAY 0 PICTURE picbhd
                     nDugDEM += IznosDEM
                  ELSE
                     @ PRow(), PCol() + 1 SAY 0        PICTURE picbhd
                     @ PRow(), PCol() + 1 SAY IznosDEM PICTURE picbhd
                     nPotDEM += IznosDEM
                  ENDIF
                  IF cKumul == "2"
                     @ PRow(), PCol() + 1 SAY nDugDEM PICT picbhd
                     @ PRow(), PCol() + 1 SAY nPotDEM PICT picbhd
                  ENDIF
               ENDIF

            ELSEIF cDinDem == "3"
               IF fOtvSt .AND. OtvSt == "9"
                  IF D_P == "1"
                     nZDugBHD += IznosBHD
                     nZDugDEM += IznosDEM
                  ELSE
                     nZPotBHD += IznosBHD
                     nZPotDEM += IznosDEM
                  ENDIF
               ELSE  // otvorene stavke
                  IF D_P == "1"
                     @ PRow(), PCol() + 1 SAY IznosBHD PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY 0        PICTURE picBHD
                     nDugBHD += IznosBHD
                  ELSE
                     @ PRow(), PCol() + 1 SAY 0        PICTURE picBHD
                     @ PRow(), PCol() + 1 SAY IznosBHD PICTURE picBHD
                     nPotBHD += IznosBHD
                  ENDIF
                  @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
                  IF D_P == "1"
                     @ PRow(), PCol() + 1 SAY IznosDEM PICTURE picdem
                     @ PRow(), PCol() + 1 SAY 0        PICTURE picdem
                     nDugDEM += IznosDEM
                  ELSE
                     @ PRow(), PCol() + 1 SAY 0        PICTURE picdem
                     @ PRow(), PCol() + 1 SAY IznosDEM PICTURE picdem
                     nPotDEM += IznosDEM
                  ENDIF
                  @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picdem
               ENDIF
            ENDIF

            IF !( fOtvSt .AND. OtvSt == "9" )
               IF cDinDem = "1"
                  @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
               ELSEIF cDinDem == "2"
                  @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
               ENDIF

               fin_print_ostatak_opisa( @cOpis, nCOpis, {|| check_nova_strana( bZagl, oPDF ) }, nSirOp )

               IF ck14 == "3"
                  @ PRow() + 1, nc7 SAY k1 + "-" + k2 + "-" + K3Iz256( k3 ) + k4
                  IF gRj == "D"
                     @ PRow(), PCol() + 1 SAY "RJ:" + idrj
                  ENDIF
                  IF gTroskovi == "D"
                     @ PRow(), PCol() + 1 SAY "Funk.:" + Funk
                     @ PRow(), PCol() + 1 SAY "Fond.:" + Fond
                  ENDIF
               ENDIF
            ENDIF
            fin_print_ostatak_opisa( @cOpis, nCOpis, {|| check_nova_strana( bZagl, oPDF ) }, nSirOp )

            IF cExpDbf == "D"

               IF field->d_p == "1"
                  __dug := field->iznosbhd
                  __pot := 0
               ELSE
                  __dug := 0
                  __pot := field->iznosbhd
               ENDIF

               _add_to_export( cIdKonto, __k_naz, cIdPartner, __p_naz, __vr_nal, __br_nal, __r_br, ;
                  __br_veze, __dat_nal, __dat_val, __opis, __dug, __pot, ( __dug - __pot ) )
            ENDIF

            SKIP 1
         ENDDO

         check_nova_strana( bZagl, oPdf )

         ? M
         ? "UKUPNO:" + cIdkonto + IF( cBrza == "D" .AND. RTrim( qqPartner ) == ";", "", "-" + cIdPartner )
         IF cRasclaniti == "D"
            @ PRow(), PCol() + 1 SAY Left( cRasclan, 6 ) + "/" + SubStr( cRasclan, 7, 5 ) + "/" + SubStr( cRasclan, 12 ) + " / " + Ocitaj( F_RJ, Left( cRasclan, 6 ), "NAZ" )
         ENDIF

         IF cDinDem == "1"
            @ PRow(), nC1      SAY nDugBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
            IF cKumul == "2"
               @ PRow(), PCol() + 1 SAY nDugBHD PICT picbhd
               @ PRow(), PCol() + 1 SAY nPotBHD PICT picbhd
            ENDIF
            @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
         ELSEIF cDinDem == "2"
            @ PRow(), nC1      SAY nDugDEM PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picBHD
            IF cKumul == "2"
               @ PRow(), PCol() + 1 SAY nDugDEM PICT picbhd
               @ PRow(), PCol() + 1 SAY nPotDEM PICT picbhd
            ENDIF
            @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
         ELSEIF  cDinDem == "3"
            @ PRow(), nC1      SAY nDugBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nPotBHD PICTURE picBHD
            @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd

            @ PRow(), PCol() + 1      SAY nDugDEM PICTURE picdem
            @ PRow(), PCol() + 1 SAY nPotDEM PICTURE picdem
            @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picdem
         ENDIF


         IF fOtvST
            ? "Promet zatvorenih stavki:"
            IF cDinDem == "1"
               @ PRow(), nC1      SAY nZDugBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZPotBHD PICTURE picBHD
               IF cKumul == "2"
                  @ PRow(), PCol() + 1 SAY nZDugBHD PICT picbhd
                  @ PRow(), PCol() + 1 SAY nZPotBHD PICT picbhd
               ENDIF
               @ PRow(), PCol() + 1 SAY nZDugBHD - nZPotBHD PICT picbhd
            ELSEIF cDinDem == "2"
               @ PRow(), nC1      SAY nZDugDEM PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZPotDEM PICTURE picBHD
               IF cKumul == "2"
                  @ PRow(), PCol() + 1 SAY nZDugDEM PICT picbhd
                  @ PRow(), PCol() + 1 SAY nZPotDEM PICT picbhd
               ENDIF
               @ PRow(), PCol() + 1 SAY nZDugDEM - nZPotDEM PICT picbhd
            ELSEIF  cDinDem == "3"
               @ PRow(), nC1      SAY nZDugBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZPotBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nZDugBHD - nZPotBHD PICT picbhd

               @ PRow(), PCol() + 1 SAY nZDugDEM PICTURE picdem
               @ PRow(), PCol() + 1 SAY nZPotDEM PICTURE picdem
               @ PRow(), PCol() + 1 SAY nZDugDEM - nZPotDEM PICT picdem
            ENDIF
         ENDIF

         ? m

         nKonD += nDugBHD;  nKonP += nPotBHD
         nKonD2 += nDugDEM; nKonP2 += nPotDEM

         IF _fin_params[ "fin_k1" ] .AND. !Len( ck3 ) = 0 .AND. cBrza == "D" .AND. ;
               my_get_from_ini( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
            nLimit  := Abs( Ocitaj( F_ULIMIT, k3iz256( ck3 ) + cIdPartner, "f_limit" ) )
            nSLimit := Abs( nDugBHD - nPotBHD )
            ? "------------------------------"
            ? "LIMIT PO K3  :", TRANS( nLimit, "999999999999.99" )
            ? "SALDO PO K3  :", TRANS( nSLimit, "999999999999.99" )
            ? "R A Z L I K A:", TRANS( nLimit - nSLimit, "999999999999.99" )
            ? "------------------------------"
         ENDIF

         IF gnRazRed == 99
            check_nova_strana( bZagl, oPdf, .T. )
         ELSE
            i := 0
            DO WHILE PRow() <= 55 + dodatni_redovi_po_stranici() .AND. gnRazRed > i
               ?
               ++i
            ENDDO
         ENDIF

      ENDDO // konto

      IF cBrza == "N"
         check_nova_strana( bZagl, oPdf )
         ? M
         ? "UKUPNO ZA KONTO:" + cIdKonto
         IF cDinDem == "1"
            @ PRow(), nC1            SAY nKonD  PICTURE picBHD
            @ PRow(), PCol() + 1       SAY nKonP  PICTURE picBHD
            IF cKumul == "2"
               @ PRow(), PCol() + 1       SAY nKonD  PICTURE picBHD
               @ PRow(), PCol() + 1       SAY nKonP  PICTURE picBHD
            ENDIF
            @ PRow(), PCol() + 1  SAY nKonD - nKonP PICT picbhd
         ELSEIF cDinDem == "2"
            @ PRow(), nC1            SAY nKonD2 PICTURE picBHD
            @ PRow(), PCol() + 1       SAY nKonP2 PICTURE picBHD
            IF cKumul == "2"
               @ PRow(), PCol() + 1       SAY nKonD2 PICTURE picBHD
               @ PRow(), PCol() + 1       SAY nKonP2 PICTURE picBHD
            ENDIF
            @ PRow(), PCol() + 1  SAY nKonD2 - nKonP2 PICT picbhd
         ELSEIF cDinDem == "3"
            @ PRow(), nC1            SAY nKonD  PICTURE picBHD
            @ PRow(), PCol() + 1       SAY nKonP  PICTURE picBHD
            @ PRow(), PCol() + 1  SAY nKonD - nKonP PICT picbhd
            @ PRow(), PCol() + 1       SAY nKonD2 PICTURE picdem
            @ PRow(), PCol() + 1       SAY nKonP2 PICTURE picdem
            @ PRow(), PCol() + 1  SAY nKonD2 - nKonP2 PICT picdem

         ENDIF
         ? M
      ENDIF

      nSviD += nKonD; nSviP += nKonP
      nSviD2 += nKonD2; nSviP2 += nKonP2

      IF gnRazRed == 99
         check_nova_strana( bZagl, oPDF, .T. )
      ELSE

         i := 0
         DO WHILE ( PRow() <= 55 + dodatni_redovi_po_stranici() ) .AND. ( gnRazRed > i )
            ?
            ++i
         ENDDO

      ENDIF

   ENDDO

   IF cBrza == "N"

      check_nova_strana( bZagl, oPdf )
      ? M
      ? "UKUPNO ZA SVA KONTA:"
      IF cDinDem == "1"
         @ PRow(), nC1       SAY nSviD        PICTURE picBHD
         @ PRow(), PCol() + 1  SAY nSviP        PICTURE picBHD
         IF cKumul == "2"
            @ PRow(), PCol() + 1  SAY nSviD        PICTURE picBHD
            @ PRow(), PCol() + 1  SAY nSviP        PICTURE picBHD
         ENDIF
         @ PRow(), PCol() + 1  SAY nSviD - nSviP  PICTURE picBHD
      ELSEIF cDinDem == "2"
         @ PRow(), nC1       SAY nSviD2        PICTURE picBHD
         @ PRow(), PCol() + 1  SAY nSviP2        PICTURE picBHD
         IF cKumul == "2"
            @ PRow(), PCol() + 1  SAY nSviD2       PICTURE picBHD
            @ PRow(), PCol() + 1  SAY nSviP2       PICTURE picBHD
         ENDIF
         @ PRow(), PCol() + 1  SAY nSviD2 - nSviP2 PICTURE picBHD
      ELSEIF cDinDem == "3"
         @ PRow(), nC1       SAY nSviD        PICTURE picBHD
         @ PRow(), PCol() + 1  SAY nSviP        PICTURE picBHD
         @ PRow(), PCol() + 1  SAY nSviD - nSviP  PICTURE picBHD
         @ PRow(), PCol() + 1  SAY nSviD2        PICTURE picdem
         @ PRow(), PCol() + 1  SAY nSviP2        PICTURE picdem
         @ PRow(), PCol() + 1  SAY nSviD2 - nSviP2 PICTURE picdem
      ENDIF
      ? M
      ?
   ENDIF

   end_print( xPrintOpt )

   IF cExpDbf == "D"
      my_close_all_dbf()
      tbl_export()
   ENDIF

   my_close_all_dbf()

   RETURN .T.


STATIC FUNCTION g_exp_fields()

   LOCAL aDbf := {}

   AAdd( aDbf, { "id_konto", "C", 7, 0 }  )
   AAdd( aDbf, { "naz_konto", "C", 100, 0 }  )
   AAdd( aDbf, { "id_partn", "C", 6, 0 }  )
   AAdd( aDbf, { "naz_partn", "C", 50, 0 }  )
   AAdd( aDbf, { "vrsta_nal", "C", 2, 0 }  )
   AAdd( aDbf, { "broj_nal", "C", 8, 0 }  )
   AAdd( aDbf, { "nal_rbr", "C", 4, 0 }  )
   AAdd( aDbf, { "broj_veze", "C", 10, 0 }  )
   AAdd( aDbf, { "dat_nal", "D", 8, 0 }  )
   AAdd( aDbf, { "dat_val", "D", 8, 0 }  )
   AAdd( aDbf, { "opis_nal", "C", 100, 0 }  )
   AAdd( aDbf, { "duguje", "N", 15, 5 }  )
   AAdd( aDbf, { "potrazuje", "N", 15, 5 }  )
   AAdd( aDbf, { "saldo", "N", 15, 5 }  )

   RETURN aDbf

/*
   upisuje u export tabelu podatke
*/
STATIC FUNCTION _add_to_export( cKonto, cK_naz, cPartn, cP_naz, cVn, cBr, cRbr, cBrVeze, dDatum, dDatVal, cOpis, nDug, nPot, nSaldo )

   LOCAL nTArea := Select()

   O_R_EXP
   SELECT r_export

   APPEND BLANK
   REPLACE field->id_konto WITH cKonto
   REPLACE field->naz_konto with ( cK_naz )
   REPLACE field->id_partn WITH cPartn
   REPLACE field->naz_partn with ( cP_naz )
   REPLACE field->vrsta_nal WITH cVn
   REPLACE field->broj_nal WITH cBr
   REPLACE field->nal_rbr WITH cRbr
   REPLACE field->broj_veze with ( cBrVeze )
   REPLACE field->dat_nal WITH dDatum
   REPLACE field->dat_val WITH dDatVal
   REPLACE field->opis_nal with ( cOpis )
   REPLACE field->duguje WITH nDug
   REPLACE field->potrazuje WITH nPot
   REPLACE field->saldo WITH nSaldo

   SELECT ( nTArea )

   RETURN .T.



/* Telefon(cTel)
 *     Postavlja uslov za partnera (npr. Telefon('417'))
 *   param: cTel  - Broj telefona
 */

FUNCTION Telefon( cTel )

   LOCAL nSelect

   nselect := Select()
   SELECT partn
   HSEEK suban->idpartner
   SELECT ( nselect )

   RETURN partn->telefon = cTel




FUNCTION zagl_suban_kartica( lPocStr )

   LOCAL _fin_params := fin_params()

   IF is_legacy_ptxt()
      ?
   ENDIF
   IF lPocStr == NIL
      lPocStr := .F.
   ENDIF

   IF c1K1z == NIL
      c1K1z := "N"
   ENDIF

   IF c1K1z <> "D" .OR. lPocStr
      Preduzece()
      IF cDinDem == "3"  .OR. cKumul == "2"
         P_COND2
      ELSE
         P_COND
      ENDIF
      IF fOtvSt
         ?U "FIN: KARTICA OTVORENIH STAVKI "
      ELSE
         ?U "FIN: SUBANALITIČKA KARTICA  ZA "
      ENDIF

      ?? iif( cDinDem == "1", ValDomaca(), iif( cDinDem == "2", ValPomocna(), ValDomaca() + "-" + ValPomocna() ) ), " NA DAN:", Date()
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         ?? "   ZA PERIOD OD", dDatOd, "DO", dDatDo
      ENDIF
      IF !Empty( qqBrDok )
         ?U "Izvještaj pravljen po uslovu za broj veze/računa: '" + Trim( qqBrDok ) + "'"
      ENDIF

      IF is_legacy_ptxt()
         @ PRow(), 125 SAY "Str." + Str( ++nStr, 5 )
      ENDIF
   ENDIF

   SELECT SUBAN
   IF c1k1z <> "D" .OR. !lPocStr
      IF cDinDem == "3"
         IF cSazeta == "D"
            ?  "----------- --------------------------- ---------------------------- -------------- -------------------------- ------------"
            ?  "*NALOG     *    D O K U M E N T        *      PROMET  " + ValDomaca() + "          *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO   *"
            ?  "----------- ------------------- -------- -----------------------------     " + ValDomaca() + "     * -------------------------    " + ValPomocna() + "    *"
            ?  "*V.* BR    *   BROJ   * DATUM  *" + iif( cK14 == "1", " K1-K4 ", " VALUTA" ) + "*     DUG     *      POT     *              *      DUG    *   POT      *           *"
            ?  "*N.*       *          *        *       *                            *              *             *            *           *"
         ELSE
            IF _fin_params[ "fin_tip_dokumenta" ] .AND. cK14 == "4"
               ? "---------------- ----------------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
               ? "*  NALOG        *               D  O  K  U  M  E  N  T                *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO    *"
               ? "---------------- ------------------------------------ ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "    *"
               ? "*V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *            *"
               ? "*N.*       * Br.*     NAZIV      *          *        *                *               *                 *              *             *            *            *"
            ELSEIF _fin_params[ "fin_tip_dokumenta" ]
               ? "---------------- -------------------------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
               ? "*  NALOG        *                       D  O  K  U  M  E  N  T                 *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO    *"
               ? "---------------- ------------------------------------ -------- ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "    *"
               ? "*V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *            *"
               ? "*N.*       * Br.*     NAZIV      *          *        *        *                *               *                 *              *             *            *            *"
            ELSE
               ? "---------------- --------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
               ? "*  NALOG        *           D O K U M E N T                   *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO    *"
               ? "---------------- ------------------- -------- ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "    *"
               ? "*V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *            *"
               ? "*N.*       * Br.*          *        *        *                *               *                 *              *             *            *            *"
            ENDIF
         ENDIF
      ELSEIF cKumul == "1"
         IF cSazeta == "D"
            ?U "------------ ---------------------------- --------------------------- ---------------"
            ?U "* NALOG     *      D O K U M E N T       *       P R O M E T         *    SALDO     *"
            ?U "------------ ------------------- -------- ---------------------------               *"
            ?U "*V.*BR  *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    DUGUJE   *   POTRAŽUJE  *             *"
            ? "*N.*    *          *        *        *            *              *              *"
         ELSE
            IF _fin_params[ "fin_tip_dokumenta" ]
               ?U  "---------------- ------------------------------------------------------------------ ---------------------------------- ---------------"
               ?U  "*  NALOG        *                       D  O  K  U  M  E  N  T                     *           P R O M E T            *    SALDO     *"
               ?U  "---------------- ------------------------------------ -------- -------------------- ----------------------------------               *"
               ?U  "*V.*BR     * R. *     TIP I      *  BROJ    *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAŽUJE     *              *"
               ?  "*N.*       * Br.*     NAZIV      *          *        *        *                    *               *                  *              *"
            ELSE
               ?U  "---------------- ------------------------------------------------- ---------------------------------- ---------------"
               ?U  "*  NALOG        *            D O K U M E N T                      *           P R O M E T            *    SALDO     *"
               ?U  "---------------- ------------------- -------- -------------------- ----------------------------------               *"
               ?U  "*V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAŽUJE     *              *"
               ?  "*N.*       * Br.*          *        *        *                    *               *                  *              *"
            ENDIF
         ENDIF
      ELSE
         IF cSazeta == "D"
            ?U  "------------ ---------------------------- --------------------------- ----------------------------- ---------------"
            ?U  "* NALOG     *    D O K U M E N T         *        P R O M E T        *      K U M U L A T I V      *    SALDO     *"
            ?U  "------------ ------------------- -------- --------------------------- ------------------------------              *"
            ?U  "*V.*BR      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*   DUGUJE   *  POTRAŽUJE   *    DUGUJE    *  POTRAŽUJE   *              *"
            ?  "*N.*        *          *        *        *            *              *              *              *              *"
         ELSE
            IF _fin_params[ "fin_tip_dokumenta" ] .AND. cK14 == "4"
               ?U  "---------------- --------------------------------------------------------- ---------------------------------- ---------------------------------- ---------------"
               ?U  "*  NALOG        *               D  O  K  U  M  E  N  T                    *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
               ?U  "---------------- ------------------------------------ -------------------- ---------------------------------- ----------------------------------               *"
               ?U  "*V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *    OPIS            *    DUGUJE     *    POTRAŽUJE     *    DUGUJE     *    POTRA¦UJE     *              *"
               ?U  "*N.*       * Br.*     NAZIV      *          *        *                    *               *                  *               *                  *              *"
            ELSEIF _fin_params[ "fin_tip_dokumenta" ]
               ?U  "---------------- ------------------------------------------------------------------ ---------------------------------- ---------------------------------- ---------------"
               ?U  "*  NALOG        *                       D  O  K  U  M  E  N  T                     *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
               ?U  "---------------- ------------------------------------ -------- -------------------- ---------------------------------- ----------------------------------               *"
               ?U  "*V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAŽUJE     *    DUGUJE     *    POTRAŽUJE     *              *"
               ?U  "*N.*       * Br.*     NAZIV      *          *        *        *                    *               *                  *               *                  *              *"
            ELSE
               ?U  "---------------- ------------------------------------------------- ---------------------------------- ---------------------------------- ---------------"
               ?U  "*  NALOG        *            D O K U M E N T                      *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
               ?  "---------------- ------------------- -------- -------------------- ---------------------------------- ----------------------------------               *"
               ?U  "*V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAZUJE     *    DUGUJE     *    POTRAŽUJE     *              *"
               ?U  "*N.*       * Br.*          *        *        *                    *               *                  *               *                  *              *"
            ENDIF
         ENDIF
      ENDIF
      ? m
   ENDIF

   RETURN .T.




/* Rasclan()
 *  Rasclanjuje SUBAN->(IdRj+Funk+Fond)
 */

FUNCTION Rasclan()

   IF cRasclaniti == "D"
      RETURN cRasclan == suban->( idrj + funk + fond )
   ELSE
      RETURN .T.
   ENDIF



/*
    V_Firma
     Validacija firme - unesi firmu po referenci
     cIdfirma  - id firme
 */

FUNCTION V_Firma( cIdFirma )

   P_Firma( @cIdFirma )
   cIdFirma := Trim( cIdFirma )
   cIdFirma := Left( cIdFirma, 2 )

   RETURN .T.



/*
   Prelomi(nDugX,nPotX)
 */
FUNCTION Prelomi( nDugX, nPotX )

   IF ( ndugx - npotx ) > 0
      nDugX := nDugX - nPotX
      nPotX := 0
   ELSE
      nPotX := nPotX - nDugX
      nDugX := 0
   ENDIF

   RETURN .T.

STATIC FUNCTION close_open_kartica_tbl()

   my_close_all_dbf()

   O_KONTO
   O_PARTN
   O_SIFK
   O_SIFV
   O_RJ
   O_SUBAN
   O_TDOK

   RETURN .T.
