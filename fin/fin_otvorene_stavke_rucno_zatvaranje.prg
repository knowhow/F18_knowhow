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


FUNCTION fin_rucno_zatvaranje_otvorenih_stavki()

   open_otv_stavke_tabele()

   cIdFirma := self_organizacija_id()
   cIdPartner := Space( LEN_PARTNER_ID )

   picD := FormPicL( "9 " + gPicBHD, 14 )
   picDEM := FormPicL( "9 " + gPicDEM, 9 )

   cIdKonto := Space( Len( konto->id ) )

   Box(, 7, 66, )

   SET CURSOR ON

   @ form_x_koord() + 1, form_y_koord() + 2 SAY "ISPRAVKA BROJA VEZE - OTVORENE STAVKE"
   IF gNW == "D"
      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Firma "; ?? self_organizacija_id(), "-", self_organizacija_naziv()
   ELSE
      @ form_x_koord() + 3, form_y_koord() + 2 SAY "Firma  " GET cIdFirma valid {|| p_partner( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
   ENDIF
   @ form_x_koord() + 4, form_y_koord() + 2 SAY "Konto  " GET cIdKonto  VALID  P_Konto( @cIdKonto )
   @ form_x_koord() + 5, form_y_koord() + 2 SAY "Partner" GET cIdPartner VALID Empty( cIdPartner ) .OR. p_partner( @cIdPartner ) PICT "@!"
   IF gFinRj == "D"
      cIdRj := Space( Len( RJ->id ) )
      @ form_x_koord() + 6, form_y_koord() + 2 SAY "RJ" GET cIdRj PICT "@!" VALID Empty( cIdRj ) .OR. P_Rj( @cIdRj )
   ENDIF
   READ
   ESC_BCR

   BoxC()

   IF Empty( cIdpartner )
      cIdPartner := ""
   ENDIF

   cIdFirma := Left( cIdFirma, 2 )

   SELECT SUBAN
   SET ORDER TO TAG "1"

   IF gFinRj == "D" .AND. !Empty( cIdRJ )
      SET FILTER TO IDRJ == cIdRj
   ENDIF

   Box(, MAXROWS() - 5, MAXCOLS() - 10 )

   ImeKol := {}
   AAdd( ImeKol, { "O",          {|| OtvSt }             } )
   AAdd( ImeKol, { "Partn.",     {|| IdPartner }         } )
   AAdd( ImeKol, { "Br.Veze",    {|| BrDok }             } )
   AAdd( ImeKol, { "Dat.Dok.",   {|| DatDok }            } )
   AAdd( ImeKol, { "Opis",       {|| PadR( opis, 20 ) }, "opis",  {|| .T. }, {|| .T. }, "V"  } )
   AAdd( ImeKol, { PadR( "Duguje " + AllTrim( ValDomaca() ), 13 ), {|| Str( ( iif( D_P == "1", iznosbhd, 0 ) ), 13, 2 ) }     } )
   AAdd( ImeKol, { PadR( "Potraz." + AllTrim( ValDomaca() ), 13 ),   {|| Str( ( iif( D_P == "2", iznosbhd, 0 ) ), 13, 2 ) }     } )
   AAdd( ImeKol, { "M1",         {|| m1 }                } )
   AAdd( ImeKol, { PadR( "Iznos " + AllTrim( ValPomocna() ), 14 ),  {|| Str( iznosdem, 14, 2 ) }                       } )
   AAdd( ImeKol, { "nalog",      {|| idvn + "-" + brnal + "/" + Str( rbr, 5, 0 ) }                  } )
   Kol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   PRIVATE aPPos := { 2, 3 }
   PRIVATE bGoreRed := NIL
   PRIVATE bDoleRed := NIL
   PRIVATE bDodajRed := NIL
   PRIVATE fTBNoviRed := .F. // trenutno smo u novom redu ?
   PRIVATE TBCanClose := .T. // da li se moze zavrsiti unos podataka ?
   PRIVATE TBAppend := "N"  // mogu dodavati slogove
   PRIVATE bZaglavlje := NIL
   // PRIVATE TBSkipBlock := {| nSkip| fin_otvorene_stavke_browse_skip( nSkip ) }
   PRIVATE nTBLine := 1      // tekuca linija-kod viselinijskog browsa
   PRIVATE nTBLastLine := 1  // broj linija kod viselinijskog browsa
   PRIVATE TBPomjerise := "" // ako je ">2" pomjeri se lijevo dva
   PRIVATE TBScatter := "N"  // uzmi samo tekuce polje
   adImeKol := {}

   FOR i := 1 TO Len( ImeKol )
      AAdd( adImeKol, ImeKol[ i ] )
   NEXT

   adKol := {}
   FOR i := 1 TO Len( adImeKol )
      AAdd( adKol, i )
   NEXT

   MsgO( "Preuzimam podatke sa SQL servera ..." )
   find_suban_by_konto_partner(  cIdFirma, cIdkonto, cIdPartner, NIL, "IdFirma,IdKonto,IdPartner,brdok" )
   MsgC()

   // PRIVATE bBKUslov := {|| idFirma + idkonto + idpartner == cIdFirma + cIdkonto + cIdpartner }
   PRIVATE bBkTrazi := {|| cIdFirma + cIdkonto + cIdPartner }

   SET CURSOR ON

   PRIVATE cPomBrDok := Space( 10 )

   // SEEK Eval( bBkUslov )

   opcije_browse_pregleda()

   my_db_edit( "Ost", MAXROWS() - 10, MAXCOLS() - 10, {|| rucno_zatvaranje_otv_stavki_key_handler() }, ;
      "", "", .F., NIL, 1, {|| otvst == "9" }, 6, 0, NIL, NIL )
   // {| nSkip| fin_otvorene_stavke_browse_skip( nSkip ) } )

   BoxC()

   my_close_all_dbf()

   RETURN .T.


FUNCTION rucno_zatvaranje_otv_stavki_key_handler( l_osuban )

   LOCAL _rec
   LOCAL cMark
   LOCAL cDn  := "N"
   LOCAL nRet := DE_CONT
   LOCAL _otv_st := " "
   LOCAL _t_rec := RecNo()
   LOCAL _tb_filter := dbFilter()
   LOCAL nDbfArea := Select()

   IF l_osuban == NIL
      l_osuban := .F.
   ENDIF

   DO CASE

/*
   CASE Ch == K_ALT_E .AND. FieldPos( "_OBRDOK" ) = 0

      IF Pitanje(, "Preći u mod direktog unosa podataka u tabelu ? (D/N)", "D" ) == "D"
         log_write( "otovrene stavke, mod direktnog unosa = D", 5 )
         opcije_browse_pregleda()
         DaTBDirektni()
      ENDIF
*/

   CASE Ch == K_ENTER

      cDn := "N"

      Box(, 3, 50 )
      @ form_x_koord() + 1, form_y_koord() + 2 SAY8 "Ne preporučuje se koristenje ove opcije !"
      @ form_x_koord() + 3, form_y_koord() + 2 SAY8 "Želite li ipak nastaviti D/N" GET cDN PICT "@!" VALID cDn $ "DN"
      READ
      BoxC()

      IF cDN == "D"

         IF field->otvst <> "9"
            cMark   := ""
            _otv_st := "9"
         ELSE
            cMark   := "9"
            _otv_st := " "
         ENDIF

         _rec := dbf_get_rec()
         _rec[ "otvst" ] := _otv_st
         update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

         log_write( "otvorene stavke, set marker=" + cMark, 5 )

         nRet := DE_REFRESH

      ELSE

         nRet := DE_CONT

      ENDIF

   CASE ( Ch == Asc( "K" ) .OR. Ch == Asc( "k" ) )

      IF field->m1 <> "9"
         _otv_st := "9"
      ELSE
         _otv_st := " "
      ENDIF
      log_write( "otvorene stavke, marker=" + _otv_st, 5 )
      _rec := dbf_get_rec()
      _rec[ "m1" ] := _otv_st

      update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

      nReti := DE_REFRESH

   CASE Ch == K_F2

      cBrDok := field->BrDok
      cOpis := field->opis
      dDatDok := field->datdok
      dDatVal := field->datval

      Box( "eddok", 5, 70, .F. )
      @ form_x_koord() + 1, form_y_koord() + 2 SAY "Broj Dokumenta (broj veze):" GET cBrDok
      @ form_x_koord() + 2, form_y_koord() + 2 SAY "Opis:" GET cOpis PICT "@S50"
      @ form_x_koord() + 4, form_y_koord() + 2 SAY "Datum dokumenta: "
      ?? dDatDok
      @ form_x_koord() + 5, form_y_koord() + 2 SAY "Datum valute   :" GET dDatVal
      READ
      BoxC()

      IF LastKey() <> K_ESC

         _rec := dbf_get_rec()

         _rec[ "brdok" ] := cBrDok
         _rec[ "opis" ]  := cOpis
         _rec[ "datval" ] := dDatVal
         log_write( "otvorene stavke, ispravka broja veze, set=" + cBrDok, 5 )
         update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

      ENDIF

      nRet := DE_REFRESH

   CASE Ch == K_F5

      cPomBrDok := field->BrDok

   CASE Ch == K_F6

      IF FieldPos( "_OBRDOK" ) <> 0
         // nalazimo se u asistentu
         fin_ostav_stampa_azuriranih_promjena()

         open_otv_stavke_tabele( l_osuban )
         SELECT ( nDbfArea )
         SET FILTER to &( _tb_filter )
         GO ( _t_rec )


      ELSE
         IF Pitanje(, "Želite li da vezni broj " + BrDok + " zamijenite brojem " + cPomBrDok + " ?", "D" ) == "D"

            _rec := dbf_get_rec()
            _rec[ "brdok" ] := cPomBrDok
            log_write( "otvorene stavke, zamjena broja veze, set=" + cPomBrDok, 5 )
            update_rec_server_and_dbf( "fin_suban", _rec, 1, "FULL" )

         ENDIF
      ENDIF

      nRet := DE_REFRESH

   CASE Ch == K_CTRL_P

      fin_kartica_otvorene_stavke_po_broju_veze()

      open_otv_stavke_tabele( l_osuban )
      SELECT ( nDbfArea )
      SET FILTER to &( _tb_filter )
      GO ( _t_rec )


      nRet := DE_REFRESH

   CASE Ch == K_ALT_P

      StBrVeze()

      open_otv_stavke_tabele( l_osuban )
      SELECT ( nDbfArea )
      SET FILTER to &( _tb_filter )
      GO ( _t_rec )

      nRet := DE_REFRESH

   ENDCASE

   RETURN nRet



/*

FUNCTION fin_otvorene_stavke_browse_skip( nRequest )

   LOCAL nCount

   nCount := 0

   IF LastRec() != 0

      IF ! Eval( bBKUslov )
         SEEK Eval( bBkTrazi )
         IF ! Eval( bBKUslov )
            GO BOTTOM
            SKIP 1
         ENDIF
         nRequest = 0
      ENDIF

      IF nRequest > 0
         DO WHILE nCount < nRequest .AND. Eval( bBKUslov )
            SKIP 1
            IF Eof() .OR. !Eval( bBKUslov )
               SKIP -1
               EXIT
            ENDIF
            nCount++
         ENDDO

      ELSEIF nRequest < 0
         DO WHILE nCount > nRequest .AND. Eval( bBKUslov )
            SKIP -1
            IF ( Bof() )
               EXIT
            ENDIF
            nCount--
         ENDDO
         IF !Eval( bBKUslov )
            SKIP 1
            nCount++
         ENDIF

      ENDIF

   ENDIF

   RETURN ( nCount )
*/
