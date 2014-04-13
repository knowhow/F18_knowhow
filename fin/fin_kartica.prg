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

#include "fin.ch"


/*
 finansijska kartica
*/
FUNCTION fin_kartice_menu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE picBHD := FormPicL( gPicBHD, 16 )

   AAdd( _opc, "1. subanalitika                           " )
   AAdd( _opcexe, {|| subKartMnu() } )
   AAdd( _opc, "2. analitika" )
   AAdd( _opcexe, {|| AnKart() } )
   AAdd( _opc, "3. sintetika" )
   AAdd( _opcexe, {|| SinKart() } )
   AAdd( _opc, "4. sintetika - po mjesecima" )
   AAdd( _opcexe, {|| SinKart2() } )

   f18_menu( "fin_kart", .F., _izbor, _opc, _opcexe )

   RETURN


// ------------------------------------------------------------
// subanaliticka kartica - menu
// ------------------------------------------------------------
STATIC FUNCTION subkartmnu()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1


   AAdd( _opc, "1. subanalitička kartica (txt) " )
   AAdd( _opcexe, {|| SubKart() } )
   AAdd( _opc, "2. subanalitička kartica (odt)           " )
   AAdd( _opcexe, {|| fin_suban_kartica_sql( NIL ) } )
   f18_menu( "fin_subkart", .F., _izbor, _opc, _opcexe )

   RETURN



// ---------------------------------------------
// SubKart(lOtvst)
// Subanaliticka kartica
// param lOtvst  - .t. otvorene stavke
// ---------------------------------------------
FUNCTION SubKart( lOtvst )

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

   PRIVATE fK1 := _fin_params[ "fin_k1" ]
   PRIVATE fK2 := _fin_params[ "fin_k2" ]
   PRIVATE fK3 := _fin_params[ "fin_k3" ]
   PRIVATE fK4 := _fin_params[ "fin_k4" ]

   PRIVATE cIdFirma := gFirma
   PRIVATE fOtvSt := lOtvSt
   PRIVATE c1k1z := "N"
   PRIVATE picBHD := FormPicL( gPicBHD, 16 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )

   o_kart_tbl()

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

   cBoxName := "SUBANALITICKA KARTICA"

   IF fOtvSt
      cBoxName += " - OTVORENE STAVKE"
   ENDIF

   Box( "#" + cBoxName, 23, 65 )
   SET CURSOR ON
   @ m_x + 2, m_y + 2 SAY "BEZ/SA kumulativnim prometom  (1/2):" GET cKumul
   @ m_x + 3, m_y + 2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh
   @ m_x + 4, m_y + 2 SAY "Brza kartica (D/N)" GET cBrza PICT "@!" VALID cBrza $ "DN"
   @ m_x + 4, Col() + 2 SAY8 "Sažeta kartica (bez opisa) D/N" GET cSazeta  PICT "@!" VALID cSazeta $ "DN"
   READ
   DO WHILE .T.
      IF gDUFRJ == "D"
         cIdFirma := PadR( gFirma + ";", 30 )
         @ m_x + 5, m_y + 2 SAY "Firma: " GET cIdFirma PICT "@!S20"
      ELSE
         IF gNW == "D"
            @ m_x + 5, m_y + 2 SAY "Firma "
            ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + 5, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
         ENDIF
      ENDIF
      IF cBrza = "D"
         qqKonto := PadR( qqKonto, 7 )
         qqPartner := PadR( qqPartner, Len( partn->id ) )
         @ m_x + 6, m_y + 2 SAY "Konto  " GET qqKonto  VALID P_KontoFin( @qqKonto )
         @ m_x + 7, m_y + 2 SAY "Partner" GET qqPartner VALID Empty( qqPartner ) .OR. RTrim( qqPartner ) == ";" .OR. P_Firma( @qqPartner ) PICT "@!"
      ELSE
         qqKonto := PadR( qqkonto, 100 )
         qqPartner := PadR( qqPartner, 100 )
         @ m_x + 6, m_y + 2 SAY "Konto  " GET qqKonto  PICTURE "@!S50"
         @ m_x + 7, m_y + 2 SAY "Partner" GET qqPartner PICTURE "@!S50"
      ENDIF
      @ m_x + 8, m_y + 2 SAY "Datum dokumenta od:" GET dDatod
      @ m_x + 8, Col() + 2 SAY "do" GET dDatDo   VALID dDatOd <= dDatDo
      @ m_x + 10, m_y + 2 SAY "Uslov za vrstu naloga (prazno-sve)" GET cIdVN PICT "@!S20"
      IF gVar1 == "0"
         @ m_x + 11, m_y + 2 SAY "Kartica za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3)"  GET cDinDem VALID cDinDem $ "123"
      ELSE
         cDinDem := "1"
      ENDIF

      @ m_x + 12, m_y + 2 SAY "Prikaz  K1-K4 (1); Dat.Valute (2); oboje (3)" + iif( _fin_params[ "fin_tip_dokumenta" ] .AND. cSazeta == "N", "; nista (4)", "" )  GET cK14 VALID cK14 $ "123" + iif( _fin_params[ "fin_tip_dokumenta" ] .AND. cSazeta == "N", "4", "" )

      cRasclaniti := "N"

      IF gRJ == "D"
         @ m_x + 13, m_y + 2 SAY8 "Raščlaniti po RJ/FUNK/FOND; "  GET cRasclaniti PICT "@!" VALID cRasclaniti $ "DN"
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
      cLaunch := exp_report()
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

   o_kart_tbl()

   IF _fakt_params[ "fakt_vrste_placanja" ]
      lVrsteP := .T.
      O_VRSTEP
   ENDIF

   SELECT SUBAN

   CistiK1k4()

   cFilter := ".t." + iif( !Empty( cIdVN ), ".and." + aUsl3, "" ) + ;
      iif( cBrza == "N", ".and." + aUsl1 + ".and." + aUsl2, "" ) + ;
      iif( Empty( dDatOd ) .OR. cPredh == "2", "", ".and.DATDOK>=" + cm2str( dDatOd ) ) + ;
      iif( Empty( dDatDo ), "", ".and.DATDOK<=" + cm2str( dDatDo ) ) + ;
      iif( fk1 .AND. Len( ck1 ) <> 0, ".and.k1=" + cm2str( ck1 ), "" ) + ;
      iif( fk2 .AND. Len( ck2 ) <> 0, ".and.k2=" + cm2str( ck2 ), "" ) + ;
      iif( fk3 .AND. Len( ck3 ) <> 0, ".and.k3=ck3", "" ) + ;
      iif( fk4 .AND. Len( ck4 ) <> 0, ".and.k4=" + cm2str( ck4 ), "" ) + ;
      iif( gRj == "D" .AND. Len( cIdrj ) <> 0, iif( gDUFRJ == "D", ".and." + aUsl5, ".and.idrj=" + cm2str( cIdRJ ) ), "" ) + ;
      iif( gTroskovi == "D" .AND. Len( cFunk ) <> 0, ".and.funk=" + cm2str( cFunk ), "" ) + ;
      iif( gTroskovi == "D" .AND. Len( cFond ) <> 0, ".and.fond=" + cm2str( cFond ), "" ) + ;
      iif( gDUFRJ == "D", ".and." + aUsl4, ;
      iif( Len( cIdFirma ) < 2, ".and. IDFIRMA=" + cm2str( cIdFirma ), "" ) + ;
      iif( Len( cIdFirma ) < 2 .AND. cBrza == "D", ".and.IDKONTO==" + cm2str( qqKonto ), "" ) + ;
      iif( Len( cIdFirma ) < 2 .AND. cBrza == "D" .AND. !( RTrim( qqPartner ) == ";" ), ".and.IDPARTNER==" + cm2str( qqPartner ), "" ) )

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
   START PRINT CRET

   PrikK1k4()

   nSviD := 0
   nSviP := 0
   nSviD2 := 0
   nSviP2 := 0

   DO WHILE !Eof() .AND. iif( gDUFRJ != "D", IdFirma == cIdFirma, .T. )
      nKonD := 0
      nKonP := 0
      nKonD2 := 0
      nKonP2 := 0
      cIdKonto := IdKonto
      IF nStr == 0
         ZaglSif( .T. )
      ENDIF
      IF cBrza == "D"
         IF IdKonto <> qqKonto .OR. IdPartner <> qqPartner .AND. RTrim( qqPartner ) != ";"
            EXIT
         ENDIF
      ENDIF
      IF !Empty( qqNazKonta )
         SELECT konto
         hseek cIdKonto
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
    		
         IF cBrza == "D"   // "brza" kartica
            IF IdKonto <> qqKonto .OR. IdPartner <> qqPartner .AND. RTrim( qqPartner ) != ";"
               EXIT
            ENDIF
         ENDIF

         IF PRow() > 55 + gPStranica
            FF
            ZaglSif( .T. )
         ENDIF

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
    		
         IF c1k1z == "D"
            ZaglSif( .F. )
         ELSE
            ? m
         ENDIF
    	
         fPrviPr := .T.  // prvi prolaz

         DO WHILE !Eof() .AND. cIdKonto == IdKonto .AND. ( cIdPartner == IdPartner .OR. ( cBrza == "D" .AND. RTrim( qqPartner ) == ";" ) ) .AND. Rasclan() .AND. iif( gDUFRJ != "D", IdFirma == cIdFirma, .T. )
			
            IF PRow() > 62 + gPStranica
               FF
               ZaglSif( .T. )
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
                  endif
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

               OstatakOpisa( @cOpis, nCOpis, {|| iif( PRow() > 60 + gPStranica, Eval( {|| gPFF(), ZaglSif( .T. ) } ), ) }, nSirOp )

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

            OstatakOpisa( @cOpis, nCOpis, {|| iif( PRow() > 60 + gPStranica, Eval( {|| gPFF(), ZaglSif( .T. ) } ), ) }, nSirOp )

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

         IF PRow() > 56 + gPStranica
            FF
            ZaglSif( .T. )
         ENDIF

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
               IzFMKIni( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
            nLimit  := Abs( Ocitaj( F_ULIMIT, k3iz256( ck3 ) + cIdPartner, "f_limit" ) )
            nSLimit := Abs( nDugBHD - nPotBHD )
            ? "------------------------------"
            ? "LIMIT PO K3  :", TRANS( nLimit,"999999999999.99" )
            ? "SALDO PO K3  :", TRANS( nSLimit,"999999999999.99" )
            ? "R A Z L I K A:", TRANS( nLimit - nSLimit, "999999999999.99" )
            ? "------------------------------"
         ENDIF

         IF gnRazRed == 99
            FF
            ZaglSif( .T. )
         ELSE
            i := 0
            DO WHILE PRow() <= 55 + gPstranica .AND. gnRazRed > i
               ?
               ++i
            ENDDO
         ENDIF

      ENDDO // konto

      IF cBrza == "N"
         IF PRow() > 56 + gPStranica; FF; ZaglSif( .T. ); ENDIF
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

         FF
         ZaglSif( .T. )

      ELSE

         i := 0
         DO WHILE ( PRow() <= 55 + gPstranica ) .AND. ( gnRazRed > i )
            ?
            ++i
         ENDDO

      ENDIF

   ENDDO


   IF cBrza == "N"

      IF PRow() > 56 + gPStranica
         FF
         ZaglSif( .T. )
      ENDIF

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

   FF
   ENDPRINT

   IF cExpDbf == "D"
      my_close_all_dbf()
      tbl_export( cLaunch )
   ENDIF

   my_close_all_dbf()

   RETURN


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

   RETURN



/*! \fn Telefon(cTel)
 *  \brief Postavlja uslov za partnera (npr. Telefon('417'))
 *  \param cTel  - Broj telefona
 */

FUNCTION Telefon( cTel )

   LOCAL nSelect

   nselect := Select()
   SELECT partn
   hseek suban->idpartner
   SELECT ( nselect )

   RETURN partn->telefon = cTel



/*  ZaglSif(lPocStr)
 *  Zaglavlje subanaliticke kartice ili kartice otvorenih stavki
 *  lPocStr
 */

FUNCTION ZaglSif( lPocStr )

   LOCAL _fin_params := fin_params()

   ?

   IF lPocStr == NIL
      lPocStr := .F.
   ENDIF

   IF c1k1z == NIL
      c1k1z := "N"
   ENDIF

   IF c1k1z <> "D" .OR. lPocStr
      Preduzece()
      IF cDinDem == "3"  .OR. cKumul == "2"
         P_COND2
      ELSE
         P_COND
      ENDIF
      IF fOtvSt
         ? "FIN: KARTICA OTVORENIH STAVKI "
      ELSE
         ? "FIN: SUBANALITICKA KARTICA  ZA "
      ENDIF

      ?? iif( cDinDem == "1", ValDomaca(), iif( cDinDem == "2", ValPomocna(), ValDomaca() + "-" + ValPomocna() ) ), " NA DAN:", Date()
      IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
         ?? "   ZA PERIOD OD", dDatOd, "DO", dDatDo
      ENDIF
      IF !Empty( qqBrDok )
         ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '" + Trim( qqBrDok ) + "'"
      ENDIF
      @ PRow(), 125 SAY "Str." + Str( ++nStr, 5 )
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
            ?U "*V.*BR  *   BROJ   *  DATUM *" + IIF( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    DUGUJE   *   POTRAŽUJE  *             *"
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

   RETURN




/*! Rasclan()
 *  Rasclanjuje SUBAN->(IdRj+Funk+Fond)
 */

FUNCTION Rasclan()

   IF cRasclaniti == "D"
      RETURN cRasclan == suban->( idrj + funk + fond )
   ELSE
      RETURN .T.
   ENDIF



/*! SubKart2(lOtvSt)
 *  Subanaliticka kartica kod koje se mogu navesti dva konta i vidjeti kroz jednu karticu
 *  lOtvSt
 */

FUNCTION SubKart2( lOtvSt )

   LOCAL cBrza := "D"
   LOCAL nSirOp := 20
   LOCAL nCOpis := 0
   LOCAL cOpis := ""
   LOCAL nC1 := 35
   LOCAL _fin_params := fin_params()
   LOCAL _fakt_params := fakt_params()

   PRIVATE fOtvSt := lOtvSt

   cIdFirma := gFirma

   PRIVATE picBHD := FormPicL( gPicBHD, 16 )
   PRIVATE picDEM := FormPicL( gPicDEM, 12 )
   PRIVATE qqKonto := qqKonto2 := qqPartner := ""

   O_PARAMS
   PRIVATE cSection := "1"
   PRIVATE cHistory := " "
   PRIVATE aHistory := {}

   RPar( "y1", @qqKonto )
   RPar( "y2", @qqKonto2 )
   RPar( "y3", @qqPartner )

   O_KONTO
   O_PARTN

   PRIVATE cSazeta := "N"
   PRIVATE cK14 := "1"

   cDinDem := "1"
   dDatOd := dDatDo := CToD( "" )
   cKumul := cPredh := "1"

   IF PCount() == 0
      fOtvSt := .F.
   ENDIF
   IF gNW == "D"
      cIdFirma := gFirma
   ENDIF

   cK1 := cK2 := "9"
   cK3 := cK4 := "99"

   IF IzFMKIni( "FIN", "LimitiPoUgovoru_PoljeK3", "N", SIFPATH ) == "D"
      cK3 := "999"
   ENDIF
   cPoVezi := "N"
   cNula := "N"

   Box( "", 18, 65 )
   SET CURSOR ON
   IF fOtvSt
      @ m_x + 1, m_y + 2 SAY "KARTICA OTVORENIH STAVKI KONTO/KONTO2"
   ELSE
      @ m_x + 1, m_y + 2 SAY8 "SUBANALITIČKA KARTICA"
   ENDIF
   @ m_x + 2, m_y + 2 SAY "BEZ/SA kumulativnim prometom  (1/2):" GET cKumul
   @ m_x + 4, m_y + 2 SAY "Sazeta kartica (bez opisa) D/N" GET cSazeta  PICT "@!" VALID cSazeta $ "DN"
   READ
   DO WHILE .T.
      IF gNW == "D"
         @ m_x + 5, m_y + 2 SAY "Firma "
         ?? gFirma, "-", gNFirma
      ELSE
         @ m_x + 5, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      cPrelomljeno := "N"
      IF cBrza = "D"
         qqKonto := PadR( qqKonto, 7 )
         qqKonto2 := PadR( qqKonto2, 7 )
         qqPartner := PadR( qqPartner, 6 )
         @ m_x + 6, m_y + 2 SAY "Konto   " GET qqKonto  VALID P_KontoFin( @qqKonto )
         @ m_x + 7, m_y + 2 SAY "Konto 2 " GET qqKonto2  VALID P_KontoFin( @qqKonto2 ) .AND. qqKonto2 > qqkonto
         @ m_x + 8, m_y + 2 SAY "Partner (prazno svi)" GET qqPartner valid ( ";" $ qqpartner ) .OR. Empty( qqPartner ) .OR. P_Firma( @qqPartner )  PICT "@!"
      ENDIF

      @ m_x + 9, m_y + 2 SAY "Datum dokumenta od:" GET dDatod
      @ m_x + 9, Col() + 2 SAY "do" GET dDatDo   VALID dDatOd <= dDatDo

      IF gVar1 == "0"
         @ m_x + 10, m_y + 2 SAY "Kartica za " + AllTrim( ValDomaca() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3)"  GET cDinDem VALID cDinDem $ "123"
      ENDIF

      @ m_x + 11, m_y + 2 SAY "Sabrati po brojevima veze D/N ?"  GET cPoVezi VALID cPoVezi $ "DN" PICT "@!"
      @ m_x + 11, Col() + 2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno VALID cprelomljeno $ "DN" PICT "@!"
      @ m_x + 12, m_y + 2 SAY "Prikaz  K1-K4 (1); Dat.Valute (2); oboje (3)"  GET cK14 VALID cK14 $ "123"

      IF _fin_params[ "fin_k1" ]
         @ m_x + 14, m_y + 2 SAY "K1 (9 svi) :" GET cK1
      ENDIF
 		
      IF _fin_params[ "fin_k2" ]
         @ m_x + 15, m_y + 2 SAY "K2 (9 svi) :" GET cK2
      ENDIF

      IF _fin_params[ "fin_k3" ]
         @ m_x + 16, m_y + 2 SAY "K3 (" + cK3 + " svi):" GET cK3
      ENDIF

      IF _fin_params[ "fin_k4" ]
         @ m_x + 17, m_y + 2 SAY "K4 (99 svi):" GET cK4
      ENDIF

      @ m_x + 18, m_Y + 2 SAY "Prikaz kartica sa 0 stanjem " GET cNula VALID cNula $ "DN" PICT "@!"
      READ
      ESC_BCR

      IF cSazeta == "N"
         IF cDinDem == "3"
            nC1 := 68
         ELSE
            nC1 := 72
         ENDIF
      ENDIF

      IF cDinDem == "3"
         cKumul := "1"
      ENDIF

      IF cBrza == "D"
         EXIT
      ELSE
         qqKonto := Trim( qqKonto )
         qqPartner := Trim( qqPartner )
         EXIT
      ENDIF
   ENDDO
   BoxC()

   SELECT params
   // zapamti konto i konto2
   WPar( "y1", @qqKonto )
   WPar( "y2", @qqKonto2 )
   WPar( "y3", @qqPartner )

   IF cSazeta == "D"
      PRIVATE picBHD := FormPicL( gPicBHD, 14 )
   ENDIF


   IF cDinDem == "3"
      IF cSazeta == "D"
         m := "------- -- -------- ---------- -------- -------- -------------- -------------- -------------- ------------ ------------ ------------"
      ELSE
         IF gNW == "N"
            m := "------- -- -------- ---- ---------------- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ELSE
            m := "------- -- -------- ---- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
         ENDIF
      ENDIF
   ELSEIF cKumul == "1"
      IF cSazeta == "D"
         M := "------- -- -------- ---------- -------- -------- -------------- -------------- --------------"
      ELSE
         IF gNW == "N"
            M := "------- -- -------- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
         ELSE
            M := "------- -- -------- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ----------------"
         ENDIF
      ENDIF
   ELSE
      IF cSazeta == "D"
         M := "------- -- -------- ---------- -------- -------- -------------- -------------- -------------- -------------- ---------------"
      ELSE
         IF gNW == "N"
            M := "------- -- -------- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
         ELSE
            M := "------- -- -------- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ----------------"
         ENDIF
      ENDIF
   ENDIF

   lVrsteP := .F.

   IF _fakt_params[ "fakt_vrste_placanja" ]
      lVrsteP := .T.
      O_VRSTEP
   ENDIF

   O_SUBAN
   O_TDOK

   SELECT SUBAN

   IF cPoVezi == "D"

      // SUBANi3","IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)",KUMPATH+"SUBAN")
      SET ORDER TO TAG "3"

   ENDIF

   IF cK1 == "9"
      cK1 := ""
   ENDIF

   IF cK2 == "9"
      cK2 := ""
   ENDIF

   IF ck3 == REPL( "9", Len( cK3 ) )
      ck3 := ""
   ELSE
      cK3 := K3U256( cK3 )
   ENDIF
   IF ck4 == "99"; ck4 := ""; ENDIF

   PRIVATE cFilter

   cFilter := ".t." + IF( Empty( dDatOd ), "", ".and.DATDOK>=" + cm2str( dDatOd ) ) + ;
      iif( Empty( dDatDo ), "", ".and.DATDOK<=" + cm2str( dDatDo ) )

   IF ! ( _fin_params[ "fin_k1" ] .AND. _fin_params[ "fin_k2" ] .AND. _fin_params[ "fin_k3" ] .AND.  _fin_params[ "fin_k4" ] )
      cFilter := cFilter + ".and.k1=" + cm2str( ck1 ) + ".and.k2=" + cm2str( ck2 ) + ;
         ".and.k3=ck3.and.k4=" + cm2str( ck4 )
   ENDIF

   IF ";" $ qqpartner
      qqPartner := StrTran( qqpartner, ";", "" )
      cFilter += ".and. idpartner='" + Trim( qqpartner ) + "'"
      qqpartner := ""
   ENDIF

   cFilter := StrTran( cFilter, ".t..and.", "" )

   IF cfilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER to &cFilter
   ENDIF


   nStr := 0

   IF Empty( qqpartner )
      qqPartner := Trim( qqpartner )
   ENDIF

   SEEK cidfirma + qqkonto + qqpartner
   IF !Found() // nema na 1200
      SEEK cidfirma + qqkonto2 + qqpartner
   ENDIF

   NFOUND CRET

   START PRINT CRET


   nSviD := nSviP := nSviD2 := nSviP2 := 0

   nKonD := nKonP := nKonD2 := nKonP2 := 0
   cIdKonto := IdKonto

   nProlaz := 0

   IF Empty( qqpartner )  // prodji tri puta
      nProlaz := 1
      HSEEK cidfirma + qqkonto
      IF Eof()
         nProlaz := 2
         HSEEK cidfirma + qqkonto2
      ENDIF
   ENDIF

   DO WHILE .T.

      IF !Eof() .AND. idfirma == cIdFirma .AND. ;
            ( ( nProlaz = 0 .AND. ( idkonto == qqkonto .OR. idkonto == qqkonto2 ) )  .OR. ;
            ( nProlaz = 1 .AND. idkonto = qqkonto ) .OR. ;
            ( nProlaz = 2 .AND. idkonto = qqkonto2 ) ;
            )
      ELSE
         EXIT
      ENDIF


      nPDugBHD := nPPotBHD := nPDugDEM := nPPotDEM := 0  // prethodni promet
      nDugBHD := nPotBHD := nDugDEM := nPotDEM := 0
      nZDugBHD := nZPotBHD := nZDugDEM := nZPotDEM := 0
      cIdPartner := IdPartner


      fZaglavlje := .F.
      fProsao := .F.
      DO WHILE !Eof() .AND. IdFirma == cIdFirma .AND. cIdPartner == idpartner .AND. ( idkonto == qqkonto .OR. idkonto == qqkonto2 )

         cIdKonto := idkonto
         cOtvSt := OtvSt
         IF !( fOtvSt .AND. cOtvSt == "9" )
            fprosao := .T.
            IF !fzaglavlje
               IF PRow() > 55 + gpstranica
                  FF; ZaglSif2( .T. )
               ELSE
                  ZaglSif2( iif( nstr = 0, .T., .F. ) )
               ENDIF
               fzaglavlje := .T.
            ENDIF
            ? cidkonto, IdVN
            @ PRow(), PCol() + 1 SAY BrNal
            IF cSazeta == "N"
               @ PRow(), PCol() + 1 SAY RBr
               IF gNW == "N"
                  @ PRow(), PCol() + 1 SAY IdTipDok
                  SELECT TDOK
                  HSEEK SUBAN->IdTipDok
                  @ PRow(), PCol() + 1 SAY naz
               ENDIF
            ENDIF
            SELECT SUBAN
            @ PRow(), PCol() + 1 SAY PadR( BrDok, 10 )
            @ PRow(), PCol() + 1 SAY DatDok
            IF ck14 == "1"
               @ PRow(), PCol() + 1 SAY k1 + "-" + k2 + "-" + K3Iz256( k3 ) + k4
            ELSEIF ck14 == "2"
               @ PRow(), PCol() + 1 SAY DatVal
            ELSE
               nC7 := PCol() + 1
               @ PRow(), nc7 SAY DatVal
            ENDIF

            IF cSazeta == "N"
               IF cDinDem == "3"
                  nSirOp := 16; nCOpis := PCol() + 1
                  @ PRow(), PCol() + 1 SAY Left( cOpis := AllTrim( Opis ), 16 )
               ELSE
                  nSirOp := 20; nCOpis := PCol() + 1
                  @ PRow(), PCol() + 1 SAY PadR( cOpis := AllTrim( Opis ), 20 )
               ENDIF
            ENDIF

            nC1 := PCol() + 1
         ENDIF // fOtvStr

         nDBHD := nPBHD := nDDEM := nPDEM := 0
         IF cPovezi == "D"
            cBrDok := brdok
            DO WHILE !Eof() .AND. IdFirma == cIdFirma .AND. cIdpartner == idpartner .AND. ( idkonto == qqkonto .OR. idkonto == qqkonto2 ) .AND. brdok == cBrdok
               IF D_P == "1"
                  nDBHD += iznosbhd
                  nDDEM += iznosdem
               ELSE
                  nPBHD += iznosbhd
                  nPDEM += iznosdem
               ENDIF
               SKIP
            ENDDO
            IF cPrelomljeno == "D"
               Prelomi( @nDBHD, @nPBHD )
               Prelomi( @nDDEM, @nPDEM )
            ENDIF
         ELSE
            IF D_P == "1"
               nDBHD += iznosbhd; nDDEM += iznosdem
            ELSE
               nPBHD += iznosbhd; nPDEM += iznosdem
            ENDIF
         ENDIF
         IF cDinDem == "1"
            IF fOtvSt .AND. cOtvSt == "9"
               nZDugBHD += nDBHD
               nZPotBHD += nPBHD
            ELSE // otvorena stavka
               @ PRow(), PCol() + 1 SAY nDBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPBHD  PICTURE picBHD
               nDugBHD += nDBHD
               nPotBHD += nPBHD
               IF cKumul == "2"   // prikaz kumulativa
                  @ PRow(), PCol() + 1 SAY nDugBHD PICT picbhd
                  @ PRow(), PCol() + 1 SAY nPotBHD PICT picbhd
               ENDIF
            ENDIF
         ELSEIF cDinDem == "2"   // devize

            IF fOtvSt .AND. cOtvSt == "9"
               nZDugDEM += nDDEM
               nZPotDEM += nPDEM
            ELSE  // otvorena stavka
               @ PRow(), PCol() + 1 SAY nDDEM PICTURE picbhd
               @ PRow(), PCol() + 1 SAY nPDEM PICTURE picbhd
               nDugDEM += nDDEM
               nPotDEM += nPDEM
               IF cKumul == "2"   // prikaz kumulativa
                  @ PRow(), PCol() + 1 SAY nDugDEM PICT picbhd
                  @ PRow(), PCol() + 1 SAY nPotDEM PICT picbhd
               ENDIF
            ENDIF
         ELSEIF cDinDem == "3"
            IF fOtvSt .AND. cOtvSt == "9"
               nZDugBHD += nDBHD; nZDugDEM += nDDEM
               nZPotBHD += nPBHD; nZPotDEM += nPDEM
            ELSE  // otvorene stavke
               @ PRow(), PCol() + 1 SAY nDBHD PICTURE picBHD
               @ PRow(), PCol() + 1 SAY nPBHD PICTURE picBHD
               nDugBHD += nDBHD
               nPotBHD += nPBHD
               @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd

               @ PRow(), PCol() + 1 SAY nDDEM PICTURE picdem
               @ PRow(), PCol() + 1 SAY nPDEM PICTURE picdem
               nDugDEM += nDDEM
               nPotDEM += nPDEM
               @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picdem
            ENDIF
         ENDIF

         IF !( fOtvSt .AND. cOtvSt == "9" )
            // ******* saldo ..........
            IF cDinDem = "1"
               @ PRow(), PCol() + 1 SAY nDugBHD - nPotBHD PICT picbhd
            ELSEIF cDinDem == "2"
               @ PRow(), PCol() + 1 SAY nDugDEM - nPotDEM PICT picbhd
            ENDIF

            OstatakOpisa( @cOpis, nCOpis, {|| iif( PRow() > 60 + gPStranica, Eval( {|| gPFF(), ZaglSif2() } ), ) }, nSirOp )
            IF ck14 == "3"
               @ PRow() + 1, nc7 SAY k1 + "-" + k2 + "-" + K3Iz256( k3 ) + k4
            ENDIF
         ENDIF
         OstatakOpisa( @cOpis, nCOpis, {|| iif( PRow() > 60 + gPStranica, Eval( {|| gPFF(), ZaglSif2() } ), ) }, nSirOp )
         IF cPoVezi <> "D"
            SKIP
         ENDIF
         IF nprolaz = 0 .OR. nProlaz = 1
            IF ( idkonto <> cidkonto .OR. idpartner <> cIdpartner ) .AND. cidkonto == qqkonto
               hseek cidfirma + qqkonto2 + cIdpartner
            ENDIF
         ENDIF

      ENDDO // konto

      IF cNula == "D" .OR. fprosao .OR.   Round( nZDugBHD - nZPotBHD, 2 ) <> 0

         IF !fzaglavlje
            IF PRow() > 55 + gpstranica
               FF; ZaglSif2( .T. )
            ELSE
               ZaglSif2( iif( nstr = 0, .T., .F. ) )
            ENDIF
            fzaglavlje := .T.
         ENDIF
         ? M
         ? "UKUPNO:"

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
      ENDIF // fprosao

      nKonD += nDugBHD;  nKonP += nPotBHD
      nKonD2 += nDugDEM; nKonP2 += nPotDEM

      IF nProlaz = 0
         EXIT
      ELSEIF nprolaz == 1
         SEEK cidfirma + qqkonto + cidpartner + Chr( 255 )
         IF qqkonto <> idkonto // nema vise
            nProlaz := 2
            SEEK cidfirma + qqkonto2
            cIdpartner := Replicate( "", Len( idpartner ) )
            IF !Found()
               EXIT
            ENDIF
         ENDIF
      ENDIF


      IF nProlaz == 2
         DO WHILE .T.
            SEEK cidfirma + qqkonto2 + cidpartner + Chr( 255 )
            nTRec := RecNo()
            IF idkonto == qqkonto2
               cIdPartner := idpartner
               hseek cidfirma + qqkonto + cIdpartner
               IF !Found() // ove kartice nije bilo
                  GO nTRec
                  EXIT
               ELSE
                  LOOP  // vrati se traziti
               ENDIF
            ENDIF
            EXIT
         ENDDO
      ENDIF

      ?
      ?
      ?
   ENDDO
   FF
   ENDPRINT
   closeret

   RETURN



/*
    ZaglSif2(fStrana)
    Zaglavlje subanaliticke kartice 2
    fStrana
 */

FUNCTION ZaglSif2( fStrana )

   ?
   IF cDinDem == "3"  .OR. cKumul == "2"
      P_COND2
   ELSE
      P_COND
   ENDIF

   IF fOtvSt
      ?? "FIN: KARTICA OTVORENIH STAVKI KONTO/KONTO2 "
   ELSE
      ?? "FIN: SUBANALITICKA KARTICA  ZA "
   ENDIF

   ?? iif( cDinDem == "1", AllTrim( ValDomaca() ), iif( cDinDem == "2", AllTrim( ValPomocna() ), AllTrim( ValDomaca() ) + "-" + AllTrim( ValPomocna() ) ) ), " NA DAN:", Date()
   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      ?? "   ZA PERIOD OD", dDatOd, "DO", dDatDo
   ENDIF
   IF fstrana
      @ PRow(), 125 SAY "Str." + Str( ++nStr, 5 )
   ENDIF

   IF gNW == "D"
      ? "Firma:", gFirma, "-", gNFirma
   ELSE
      SELECT PARTN; HSEEK cIdFirma
      ? "Firma:", cIdFirma, AllTrim( partn->naz ), AllTrim( partn->naz2 )
   ENDIF


   SELECT PARTN; HSEEK cIdPartner
   ? "PARTNER:", cIdPartner, AllTrim( partn->naz ), AllTrim( partn->naz2 )

   SELECT SUBAN

   IF cDinDem == "3"
      IF cSazeta == "D"
         ?  "------- ----------- --------------------------- ---------------------------- -------------- -------------------------- ------------"
         ?  "*KONTO * NALOG     *     D O K U M E N T        *      PROMET  " + ValDomaca() + "          *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO   *"
         ?  "*       ----------- ------------------- -------- -----------------------------     " + ValDomaca() + "     * -------------------------    " + ValPomocna() + "    *"
         ?  "*      * V.* BR    *   BROJ   * DATUM  *" + iif( cK14 == "1", " K1-K4 ", " VALUTA" ) + ;
            "*     DUG     *      POT     *              *      DUG    *   POT      *           *"
         ?  "*      * N.*       *          *        *       *                            *              *             *            *           *"
      ELSE
         IF gNW == "N"
            ?  "------- ---------------- -------------------------------------------------------------- --------------------------------- -------------- -------------------------- --------------"
            ?  "*KONTO *   NALOG        *                    D  O  K  U  M  E  N  T                    *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO     *"
            ?  "*       ---------------- ------------------------------------ -------- ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "     *"
            ?  "*      * V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *             *"
            ?  "*      * N.*       * Br.*     NAZIV      *          *        *        *                *               *                 *              *             *            *             *"
         ELSE
            ?  "------- ---------------- --------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
            ?  "*KONTO *   NALOG        *           D O K U M E N T                   *          PROMET  " + ValDomaca() + "           *    SALDO     *       PROMET  " + ValPomocna() + "       *   SALDO     *"
            ?  "*       ---------------- ------------------- -------- ---------------- ----------------------------------      " + ValDomaca() + "    * --------------------------    " + ValPomocna() + "     *"
            ?  "*      * V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *             *"
            ?  "*      * N.*       * Br.*          *        *        *                *               *                 *              *             *            *             *"
         ENDIF
      ENDIF
   ELSEIF cKumul == "1"
      IF cSazeta == "D"
         ?  "------- ------------ ---------------------------- --------------------------- ---------------"
         ?  "*KONTO *  NALOG     *      D O K U M E N T       *       P R O M E T         *    SALDO      *"
         ?  "*       ------------ ------------------- -------- ---------------------------                *"
         ?  "*      * V.*BR      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    DUGUJE   *   POTRA¦UJE  *              *"
         ?  "*      * N.*        *          *        *        *            *              *               *"
      ELSE
         IF gNW == "N"
            ?  "------- ---------------- ------------------------------------------------------------------ ---------------------------------- ----------------"
            ?  "*KONTO *   NALOG        *                    D  O  K  U  M  E  N  T                        *           P R O M E T            *    SALDO      *"
            ?  "*       ---------------- ------------------------------------ -------- -------------------- ----------------------------------                *"
            ?  "*      * V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRA¦UJE     *               *"
            ?  "*      * N.*       * Br.*     NAZIV      *          *        *        *                    *               *                  *               *"
         ELSE
            ?  "------- ---------------- ------------------------------------------------- ---------------------------------- ---------------"
            ?  "*KONTO *   NALOG        *              D  O  K  U  M  E  N  T             *           P R O M E T            *    SALDO      *"
            ?  "*       ---------------- ------------------- -------- -------------------- ----------------------------------                *"
            ?  "*      * V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRA¦UJE     *               *"
            ?  "*      * N.*       * Br.*          *        *        *                    *               *                  *               *"
         ENDIF
      ENDIF
   ELSE
      IF cSazeta == "D"
         ?  "------- ----------- ---------------------------- --------------------------- ------------------------------ ---------------"
         ?  " KONTO * NALOG     *      D O K U M E N T       *        P R O M E T        *      K U M U L A T I V       *    SALDO     *"
         ?  "        ----------- -------------------- -------- --------------------------- ------------------------------              *"
         ?  "       * V.*BR     *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*   DUGUJE    *  POTRAZUJE   *    DUGUJE    *  POTRAZUJE   *              *"
         ?  "       *           *          *        *        *             *              *              *              *              *"
      ELSE
         IF gNW == "N"
            ?  "------- ---------------- ------------------------------------------------------------------ ---------------------------------- ---------------------------------- ---------------"
            ?  "*KONTO *   NALOG        *                    D  O  K  U  M  E  N  T                        *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
            ?  "*       ---------------- ------------------------------------ -------- -------------------- ---------------------------------- ----------------------------------               *"
            ?  "*      * V.*BR     * R. *     TIP I      *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRA¦UJE     *    DUGUJE     *    POTRA¦UJE     *              *"
            ?  "*      * N.*       * Br.*     NAZIV      *          *        *        *                    *               *                  *               *                  *              *"
         ELSE
            ?  "------- ---------------- ------------------------------------------------- ---------------------------------- ---------------------------------- ----------------"
            ?  "*KONTO *   NALOG        *            D O K U M E N T                      *           P R O M E T            *           K U M U L A T I V      *    SALDO      *"
            ?  "*       ---------------- ------------------- -------- -------------------- ---------------------------------- ----------------------------------                *"
            ?  "*      * V.*BR     * R. *   BROJ   *  DATUM *" + iif( cK14 == "1", " K1-K4  ", " VALUTA " ) + "*    OPIS            *    DUGUJE     *    POTRAZUJE     *    DUGUJE     *    POTRA¦UJE     *               *"
            ?  "*      * N.*       * Br.*          *        *        *                    *               *                  *               *                  *               *"
         ENDIF
      ENDIF
   ENDIF
   ? m

   RETURN



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

   RETURN

STATIC FUNCTION o_kart_tbl()

   my_close_all_dbf()

   O_KONTO
   O_PARTN
   O_SIFK
   O_SIFV
   O_RJ
   O_SUBAN
   O_TDOK

   RETURN
