#include "f18.ch"

MEMVAR m, gnLMarg

FUNCTION fakt_real_kumulativno_po_partnerima()

   LOCAL cFilter
   LOCAL cFilterBrFaktDok, cFilterSifraKupca, cFilterTipDok
   LOCAL cUslovTipDok, cUslovIdPartner, cUslovOpcina
   LOCAL bZagl
   LOCAL GetList := {}
   LOCAL dDatOd, dDatDo
   LOCAL cIdFirma
   LOCAL nIznos, nRabat
   LOCAL nTotalIznos, nTotalRabat
   LOCAL cIdPartner

   //o_fakt_doks_dbf()
   // o_partner()
   // o_valute()
   // o_rj()

   cIdFirma := self_organizacija_id()
   dDatOd := CToD( "" )
   dDatDo := Date()

   cUslovTipDok := "10;"

   Box(, 11, 77 )

   cTabela := "N"
   cBrFakDok := Space( 40 )
   cImeKup := Space( 20 )

   cUslovIdPartner := Space( 20 )
   cUslovOpcina := Space( 20 )

   cTabela := fetch_metric( "fakt_real_tabela", my_user(), cTabela )
   cImeKup := fetch_metric( "fakt_real_ime_kupca", my_user(), cImeKup )
   cUslovIdPartner := fetch_metric( "fakt_real_partner", my_user(), cUslovIdPartner )
   cBrFakDok := fetch_metric( "fakt_real_broj_dok", my_user(), cBrFakDok )
   cIdFirma := fetch_metric( "fakt_real_id_firma", my_user(), cIdFirma )
   dDatOd := fetch_metric( "fakt_real_datum_od", my_user(), dDatOd )
   dDatDo := fetch_metric( "fakt_real_datum_do", my_user(), dDatDo )

   cUslovIdPartner := PadR( cUslovIdPartner, 20 )
   cUslovTipDok := PadR( cUslovTipDok, 40 )
   cUslovOpcina := PadR( cUslovOpcina, 20 )

   DO WHILE .T.
      cIdFirma := PadR( cIdFirma, 2 )

      fakt_getlist_rj_read( box_x_koord() + 1, box_y_koord() + 2, @GetList, @cIdFirma )

      @ box_x_koord() + 2, box_y_koord() + 2 SAY "Tip dokumenta " GET cUslovTipDok PICT "@!S20"
      @ box_x_koord() + 3, box_y_koord() + 2 SAY "Od datuma "  GET dDatOd
      @ box_x_koord() + 3, Col() + 1 SAY "do"  GET dDatDo
      @ box_x_koord() + 6, box_y_koord() + 2 SAY "Uslov po nazivu kupca (prazno svi)"  GET cUslovIdPartner PICT "@!"
      @ box_x_koord() + 7, box_y_koord() + 2 SAY "Broj dokumenta (prazno svi)"  GET cBrFakDok PICT "@!"
      @ box_x_koord() + 9, box_y_koord() + 2 SAY8 "Općina (prazno sve)" GET cUslovOpcina PICT "@!"
      READ
      ESC_BCR

      cFilterBrFaktDok := Parsiraj( cBrFakDok, "BRDOK", "C" )
      cFilterSifraKupca := Parsiraj( cUslovIdPartner, "IDPARTNER" )
      cFilterTipDok := Parsiraj( cUslovTipDok, "IdTipdok", "C" )
      IF cFilterBrFaktDok <> NIL .AND. cFilterTipDok <> NIL
         EXIT
      ENDIF
   ENDDO


   cUslovTipDok := Trim( cUslovTipDok )
   cUslovIdPartner := Trim( cUslovIdPartner )

   set_metric( "fakt_real_tabela", my_user(), cTabela )
   set_metric( "fakt_real_ime_kupca", my_user(), cImeKup )
   set_metric( "fakt_real_partner", my_user(), cUslovIdPartner )
   set_metric( "fakt_real_broj_dok", my_user(), cBrFakDok )
   set_metric( "fakt_real_id_firma", my_user(), cIdFirma )
   set_metric( "fakt_real_datum_od", my_user(), dDatOd )
   set_metric( "fakt_real_datum_do", my_user(), dDatDo )

   BoxC()


   cFilter := ".t."

   //IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
    //  cFilter += ".and.  datdok>=" + dbf_quote( dDatOd ) + ".and. datdok<=" + dbf_quote( dDatDo )
   //ENDIF

   //IF cTabela == "D"  // prikazu unutar browse-a
    //  cFilter += ".and. IdFirma=" + dbf_quote( cIdFirma )
   //ENDIF

   IF !Empty( cBrFakDok )
      cFilter += ".and." + cFilterBrFaktDok
   ENDIF

   IF !Empty( cUslovIdPartner )
      cFilter += ".and." + cFilterSifraKupca
   ENDIF

   IF !Empty( cUslovTipDok )
      cFilter += ".and." + cFilterTipDok
   ENDIF

   IF cFilter = ".t..and."
      cFilter := SubStr( cFilter, 9 )
   ENDIF


   find_fakt_doks_za_period( cIdFirma, dDatOd, dDatDo, "FAKT_DOKS", "idpartner,datdok" )
   IF cFilter == ".t."
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilter
   ENDIF

   EOF CRET

   // gaZagFix:={3,3}
   START PRINT CRET

   PRIVATE nStrana := 0
   PRIVATE m := "---- ------ -------------------------- ------------ ------------ ------------"

   bZagl := { || fakt_zagl_real_partnera( cIdFirma, @nStrana, dDatOd, dDatDo, cUslovTipDok ) }

   EVAL( bZagl )


   //find_fakt_za_period( cIdFirma, dDatOd, dDatDo, "idFirma,idpartner,idtipdok", NIL, "6" ) // "6","IdFirma+idpartner+idtipdok"

   nC := 0
   nCol1 := 10
   nTotalIznos := nTotalRabat := 0
   PRIVATE cRezerv := " "
   DO WHILE !Eof() //.AND. fakt_doks->IdFirma == cIdFirma

      IF !Empty( cUslovIdPartner )
         IF !( fakt_doks->partner = cUslovIdPartner )
            SKIP
            LOOP
         ENDIF
      ENDIF

      nIznos := 0
      nRabat := 0
      cIdPartner := fakt_doks->idpartner
      select_o_partner( cIdPartner )
      SELECT fakt_doks

      IF !Empty( cUslovOpcina )
         IF At( partn->idops, cUslovOpcina ) == 0
            SKIP
            LOOP
         ENDIF
      ENDIF

      DO WHILE !Eof() .AND. fakt_doks->idpartner == cIdpartner //IdFirma == cIdFirma .AND. field->idpartner == cIdpartner
         IF DinDem == Left( ValBazna(), 3 )
            nIznos += Round( iznos, fakt_zaokruzenje() )
            nRabat += Round( Rabat, fakt_zaokruzenje() )
         ELSE
            nIznos += Round( iznos * UBaznuValutu( datdok ), fakt_zaokruzenje() )
            nRabat += Round( Rabat * UBaznuValutu( datdok ), fakt_zaokruzenje() )
         ENDIF
         SKIP
      ENDDO

      IF PRow() > 61
         FF
         Eval( bZagl )
      ENDIF

      ? Space( gnLMarg )
      ?? Str( ++nC, 4 ) + ".", cIdPartner, PadR( partn->naz, 25 )
      nCol1 := PCol() + 1
      @ PRow(), PCol() + 1 SAY Str( nIznos + nRabat, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nRabat, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( nIznos, 12, 2 )

      nTotalIznos += nIznos
      nTotalRabat += nRabat
   ENDDO

   IF PRow() > 59
      FF
      Eval( bZagl )
   ENDIF

   ? Space( gnLMarg )
   ?? m
   ? Space( gnLMarg )
   ?? " Ukupno"
   @ PRow(), nCol1 SAY Str( nTotalIznos + nTotalRabat, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTotalRabat, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nTotalIznos, 12, 2 )
   ? Space( gnLMarg )
   ?? m

   SET FILTER TO

   FF
   ENDPRINT

   RETURN .T.


FUNCTION fakt_zagl_real_partnera( cIdFirma, nStrana, dDatOd, dDatDo, cUslovTipDok)

   ?
   P_12CPI
   ?? Space( gnLMarg )
   IspisFirme( cIdFirma )
   ?
   SET CENTURY ON
   P_12CPI
   ?U Space( gnLMarg ); ??U "FAKT: Realizacija kumulativno po partnerima na dan: ", Date(), Space( 4 ), "Strana:", Str( ++nStrana, 3 )
   ?U Space( gnLMarg ); ?? "      period:", dDatOd, "-", dDatDo
   IF cUslovTipDok <> "10;"
      ? Space( gnLMarg ); ??U "-izvještaj za tipove dokumenata :", Trim( cUslovTipDok )
   ENDIF

   SET CENTURY OFF
   P_12CPI
   ? Space( gnLMarg ); ?? m
   ? Space( gnLMarg ); ?? " Rbr  Sifra     Partner                  Ukupno        Rabat          UKUPNO"
   ? Space( gnLMarg ); ?? "                                           (1)          (2)            (1-2)"
   ? Space( gnLMarg ); ?? m

   RETURN .T.
