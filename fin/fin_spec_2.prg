#include "f18.ch"

/*
 *     Specifikacija subanalitike po proizvoljnom sortiranju, verzija C52


FUNCTION SpecSubPro()

   LOCAL _fin_params := fin_params()
   LOCAL _fakt_params := fakt_params()

   PRIVATE fK1 := _fin_params[ "fin_k1" ]
   PRIVATE fK2 := _fin_params[ "fin_k2" ]
   PRIVATE fK3 := _fin_params[ "fin_k3" ]
   PRIVATE fK4 := _fin_params[ "fin_k4" ]

   PRIVATE cSk := "N"
   PRIVATE cSpecifSkracenaVarijantaDN := "N"

   cIdFirma := self_organizacija_id()
   picBHD := FormPicL( "9 " + gPicBHD, 20 )

   o_konto()
   //o_partner()

   dDatOd := dDatDo := CToD( "" )
   qqkonto := Space( 7 )
   qqPartner := Space( 60 )
   qqTel := Space( 60 )
   cTip := "1"
   qqBrDok := ""

   Box( "", 20, 65 )

   SET CURSOR ON

   PRIVATE cSort := "1"

   cK1 := cK2 := "9"
   cK3 := cK4 := "99"
  // cIdRj := REPLICATE("9", FIELD_LEN_FIN_RJ_ID )
   cFunk := "99999"
   cFond := "9999"

   PRIVATE nC := 65

   DO WHILE .T.
      @ box_x_koord() + 1, box_y_koord() + 6 SAY "SPECIFIKACIJA SUBANALITIKA - PROIZV.SORT."
      IF gNW == "D"
         @ box_x_koord() + 3, box_y_koord() + 2 SAY "Firma "; ?? self_organizacija_id(), "-", self_organizacija_naziv()
      ELSE
         @ box_x_koord() + 3, box_y_koord() + 2 SAY "Firma: " GET cIdFirma valid {|| p_partner( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ box_x_koord() + 4, box_y_koord() + 2 SAY "Konto   " GET qqkonto  PICT "@!" VALID p_konto( @qqkonto )
      @ box_x_koord() + 5, box_y_koord() + 2 SAY "Partner " GET qqPartner PICT "@!S50"
      @ box_x_koord() + 6, box_y_koord() + 2 SAY "Datum dokumenta od" GET dDatOd
      @ box_x_koord() + 6, Col() + 2 SAY "do" GET dDatDo
      IF fin_dvovalutno()
         @ box_x_koord() + 7, box_y_koord() + 2 SAY "Obracun za " + AllTrim( valuta_domaca_skraceni_naziv() ) + "/" + AllTrim( ValPomocna() ) + "/" + AllTrim( valuta_domaca_skraceni_naziv() ) + "-" + AllTrim( ValPomocna() ) + " (1/2/3):" GET cTip VALID ctip $ "123"
      ENDIF

      @ box_x_koord() + 9, box_y_koord() + 2 SAY "Kriterij za telefon" GET qqTel PICT "@!S30"
      @ box_x_koord() + 11, box_y_koord() + 2 SAY "Sortirati po: konto+telefon+partn (1)" GET cSort VALID csort $ "12"

      @ box_x_koord() + 15, box_y_koord() + 2 SAY ""

      IF fk1
         @ box_x_koord() + 15, box_y_koord() + 2 SAY "K1 (9 svi) :" GET cK1
      ENDIF
      IF fk2
         @ box_x_koord() + 15, Col() + 2 SAY "K2 (9 svi) :" GET cK2
      ENDIF
      IF fk3
         @ box_x_koord() + 15, Col() + 2 SAY "K3 (" + cK3 + " svi):" GET cK3
      ENDIF
      IF fk4
         @ box_x_koord() + 15, Col() + 2 SAY "K4 (99 svi):" GET cK4
      ENDIF

      READ
      ESC_BCR

      aUsl2 := Parsiraj( qqPartner, "IdPartner" )
      aUsl5 := Parsiraj( qqTel, "partn->telefon" )

      IF aUsl5 <> NIL .AND. aUsl2 <> NIL
         EXIT
      ENDIF

   ENDDO

   BoxC()

   cIdFirma := Left( cIdFirma, 2 )

   nTmpArr := 0
   nArr := 0
   cImeTmp := ""

   o_suban()
   SET RELATION TO suban->idpartner INTO partn

   IF cK1 == "9"
      cK1 := ""
   ENDIF
   IF cK2 == "9"
      cK2 := ""
   ENDIF
   IF cK3 == REPL( "9", Len( cK3 ) )
      cK3 := ""
   ELSE
      cK3 := k3u256( cK3 )
   ENDIF
   IF cK4 == "99"
      cK4 := ""
   ENDIF

   SELECT SUBAN
   SET ORDER TO TAG "1"

   IF cSort == "1"
      cSort1 := "idfirma + idkonto + partn->telefon + idpartner"
   ENDIF

   PRIVATE cFilt1 := "idfirma == " + _filter_quote( cIdFirma ) + " .and. idkonto == '" + qqkonto + "'"

   IF !( Empty( dDatOd ) .AND. Empty( dDatDo ) )
      cFilt1 += iif( Empty( cFilt1 ), "", ".and." ) + ;
         "dDatOd<=DatDok  .and. dDatDo>=DatDok"
   ENDIF

   IF ( fk1 .AND. fk2 .AND. fk3 .AND. fk4 )
      cFilt1 += if( Empty( cFilt1 ), "", ".and." ) + ;
         "(k1=ck1 .and. k2=ck2 .and. k3=ck3 .and. k4=ck4)"
   ENDIF

   IF aUsl2 <> ".t."
      cFilt1 += ".and.(" + aUsl2 + ")"
   ENDIF
   IF aUsl5 <> ".t."
      cFilt1 += ".and.(" + aUsl5 + ")"
   ENDIF

   Box(, 1, 30 )

   INDEX ON &cSort1 TO "TMPSP2" FOR &cFilt1

   BoxC()

   Pic := PicBhd

   IF !start_print()
      RETURN .F.
   ENDIF

   IF cTip == "3"
      m := "------  " + Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " ------------------------------------------------- --------------------- --------------------"
   ELSE
      m := "------  " + Replicate( "-", FIELD_PARTNER_ID_LENGTH ) + " ------------------------------------------------- --------------------- -------------------- --------------------"
   ENDIF
   nStr := 0

   nud := nup := 0      // DIN
   nud2 := nup2 := 0    // DEM

   DO WHILE !Eof()

      SELECT suban
      nkd := nkp := 0
      nkd2 := nkp2 := 0
      cIdkonto := idkonto
      IF cSort == "1"
         cBrTel := partn->telefon
         bUslov := {|| cbrtel == partn->telefon }
         cNaslov := partn->telefon + "-" + partn->mjesto
      ENDIF


      DO WHILE !Eof() .AND. idfirma == cidfirma .AND. idkonto == cidkonto .AND. Eval( bUslov )
         nd := np := 0;nd2 := np2 := 0
    --     IF PRow() == 0; zagl_fin_specif( cSpecifSkracenaVarijantaDN ); ENDIF
         cIdPartner := IdPartner
         cNazPartn := PadR( partn->naz, 25 )
         DO WHILE !Eof() .AND. idfirma == cidfirma .AND. idkonto == cidkonto .AND. Eval( bUslov ) .AND. IdPartner == cIdPartner
            IF d_P == "1"
               nd += iznosbhd; nd2 += iznosdem
            ELSE
               np += iznosbhd; np2 += iznosdem
            ENDIF
            SELECT suban
            SKIP
         ENDDO

         IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; zagl_fin_specif( cSpecifSkracenaVarijantaDN ); ENDIF
         ? cidkonto, cIdPartner, ""
         IF !Empty( cIdPartner )
            ?? PadR( cNazPARTN, 50 -DifIdp( cIdPartner ) )
         ELSE
        --    SELECT KONTO; HSEEK cidkonto; SELECT SUBAN
            ?? PadR( KONTO->naz, 50 )
         ENDIF

         nC := PCol() + 1
         IF cTip == "1"
            @ PRow(), PCol() + 1 SAY nd PICT pic
            @ PRow(), PCol() + 1 SAY np PICT pic
            @ PRow(), PCol() + 1 SAY nd - np PICT pic
         ELSEIF cTip == "2"
            @ PRow(), PCol() + 1 SAY nd2 PICT pic
            @ PRow(), PCol() + 1 SAY np2 PICT pic
            @ PRow(), PCol() + 1 SAY nd2 - np2 PICT pic
         ELSE
            @ PRow(), PCol() + 1 SAY nd - np PICT pic
            @ PRow(), PCol() + 1 SAY nd2 - np2 PICT pic
         ENDIF
         nkd += nd; nkp += np  // ukupno  za klasu
         nkd2 += nd2; nkp2 += np2  // ukupno  za klasu
            ENDDO  // csort

         IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; zagl_fin_specif( cSpecifSkracenaVarijantaDN ); ENDIF
         ? m
         IF cSort == "1"
            ?  "Ukupno za:", cNaslov, ":"
         ENDIF
         IF cTip == "1"
            @ PRow(), nC       SAY nKd PICT pic
            @ PRow(), PCol() + 1 SAY nKp PICT pic
            @ PRow(), PCol() + 1 SAY nKd - nKp PICT pic
         ELSEIF cTip == "2"
            @ PRow(), nC       SAY nKd2 PICT pic
            @ PRow(), PCol() + 1 SAY nKp2 PICT pic
            @ PRow(), PCol() + 1 SAY nKd2 - nKp2 PICT pic
         ELSE
            @ PRow(), nC       SAY nKd - nKP PICT pic
            @ PRow(), PCol() + 1 SAY nKd2 - nKP2 PICT pic
         ENDIF
         ? m
         nUd += nKd; nUp += nKp   // ukupno za sve
            nUd2 += nKd2; nUp2 += nKp2   // ukupno za sve
            enddo
         IF PRow() > 60 + dodatni_redovi_po_stranici(); FF; zagl_fin_specif( cSpecifSkracenaVarijantaDN ); ENDIF
         ? m
         ? " UKUPNO:"
         IF cTip == "1"
            @ PRow(), nC       SAY nUd PICT pic
            @ PRow(), PCol() + 1 SAY nUp PICT pic
            @ PRow(), PCol() + 1 SAY nUd - nUp PICT pic
         ELSEIF cTip == "2"
            @ PRow(), nC       SAY nUd2 PICT pic
            @ PRow(), PCol() + 1 SAY nUp2 PICT pic
            @ PRow(), PCol() + 1 SAY nUd2 - nUp2 PICT pic
         ELSE
            @ PRow(), nC       SAY nUd - nUP PICT pic
            @ PRow(), PCol() + 1 SAY nUd2 - nUP2 PICT pic
         ENDIF
         ? m
         FF
         end_print()

         closeret

         RETURN
 */
