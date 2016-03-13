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

STATIC __line
STATIC __txt1
STATIC __txt2
STATIC __txt3



FUNCTION kalk_kartica_prodavnica()

   PARAMETERS cIdFirma, cIdRoba, cIdKonto

   LOCAL cLine
   LOCAL cTxt1
   LOCAL cTxt2
   LOCAL cTxt3
   LOCAL _is_rok, _dok_hash, _item_istek_roka

   PRIVATE PicCDEM := Replicate( "9", Val( gFPicCDem ) ) + gPicCDEM
   PRIVATE PicProc := gPicProc
   PRIVATE PicDEM := Replicate( "9", Val( gFPicDem ) ) + gPicDem
   PRIVATE Pickol := "@Z " + Replicate( "9", Val( gFPicKol ) ) + gPickol
   PRIVATE nMarza, nMarza2, nPRUC, aPorezi

   _is_rok := fetch_metric( "kalk_definisanje_roka_trajanja", NIL, "N" ) == "D"

   O_TARIFA
   O_SIFK
   O_SIFV
   O_ROBA
   O_KONTO
   O_PARTN

   cPredh := "N"
   dDatOd := Date()
   dDatDo := Date()
   aPorezi := {}
   nMarza := nMarza2 := nPRUC := 0

   IF PCount() == 0

      cIdFirma := gFirma
      cIdRoba := Space( 10 )
      cIdKonto := PadR( "1330", 7 )
      cPredh := "N"
      cIdRoba := fetch_metric( "kalk_kartica_prod_id_roba", my_user(), cIdRoba )
      cIdKonto := fetch_metric( "kalk_kartica_prod_id_konto", my_user(), cIdKonto )
      dDatOd := fetch_metric( "kalk_kartica_prod_datum_od", my_user(), dDatOd )
      dDatDo := fetch_metric( "kalk_kartica_prod_datum_do", my_user(), dDatDo )
      cPredh := fetch_metric( "kalk_kartica_prod_prethodni_promet", my_user(), cPredh )

      Box(, 8, 60 )

      DO WHILE .T.

         IF gNW $ "DX"
            @ m_x + 1, m_y + 2 SAY "Firma "
            ?? gFirma, "-", gNFirma
         ELSE
            @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma VALID {|| P_Firma( @cIdFirma ), cIdFirma := Left( cIdFirma, 2 ), .T. }
         ENDIF

         @ m_x + 2, m_y + 2 SAY "Konto " GET cIdKonto VALID P_Konto( @cIdKonto )

         IF lKoristitiBK
            @ m_x + 3, m_y + 2 SAY "Roba  " GET cIdRoba WHEN {|| cIdRoba := PadR( cIdRoba, Val( gDuzSifIni ) ), .T. } VALID {|| Empty( cIdRoba ), cIdRoba := iif( Len( Trim( cIdRoba ) ) <= 10, Left( cIdRoba, 10 ), cIdRoba ), P_Roba( @cIdRoba ) } PICT "@!"
         ELSE
            @ m_x + 3, m_y + 2 SAY "Roba  " GET cIdRoba VALID Empty( cidroba ) .OR. P_Roba( @cIdRoba ) PICT "@!"
         ENDIF

         @ m_x + 5, m_y + 2 SAY "Datum od " GET dDatOd
         @ m_x + 5, Col() + 2 SAY "do" GET dDatDo
         @ m_x + 6, m_y + 2 SAY "sa prethodnim prometom (D/N)" GET cPredh PICT "@!" VALID cpredh $ "DN"

         READ
         ESC_BCR

         EXIT

      ENDDO

      BoxC()

      IF LastKey() != K_ESC

         set_metric( "kalk_kartica_prod_id_roba", my_user(), cIdRoba )
         set_metric( "kalk_kartica_prod_id_konto", my_user(), cIdKonto )
         set_metric( "kalk_kartica_prod_datum_od", my_user(), dDatOd )
         set_metric( "kalk_kartica_prod_datum_do", my_user(), dDatDo )
         set_metric( "kalk_kartica_prod_prethodni_promet", my_user(), cPredh )

      ENDIF

      IF Empty( cIdRoba )
         IF Pitanje(, "Niste zadali šifru artikla, izlistati sve kartice (D/N) ?", "N" ) == "N"
            my_close_all_dbf()
            RETURN
        ENDIF
      ELSE
         cIdr := cIdRoba
      ENDIF

   ELSE
      cIdR := cIdRoba
      dDatOd := CToD( "" )
   ENDIF

   O_KALK

   nKolicina := 0

   SELECT kalk
   SET ORDER TO TAG "4"

   PRIVATE cFilt := ".t."

   IF !( cFilt == ".t." )
      SET FILTER to &cFilt
   ENDIF

   HSEEK cIdFirma + cIdKonto + cIdR

   EOF CRET

   gaZagFix := { 7, 3 }

   START PRINT CRET

   ?

   nLen := 1

   _set_zagl( @cLine, @cTxt1 )
   __line := cLine
   __txt1 := cTxt1

   nTStrana := 0

   Zagl()

   nCol1 := 10
   nUlaz := nIzlaz := 0
   nMPV := nNV := 0
   nMPVP := 0
   fPrviProl := .T.

   DO WHILE !Eof() .AND. field->idfirma + field->pkonto + field->idroba = cIdFirma + cIdKonto + cIdR

      cIdRoba := idroba

      SELECT roba
      HSEEK cIdRoba

      SELECT tarifa
      HSEEK roba->idtarifa

      ? __line

      ? "Artikal:", cIdRoba, "-", Trim( Left( roba->naz, 40 ) ) + ;
         iif( lKoristitiBK, " BK: " + roba->barkod, "" ) + " (" + AllTrim( roba->jmj ) + ")"

      ? __line

      SELECT kalk

      nCol1 := 10
      nUlaz := nIzlaz := 0
      nNV := nMPV := 0
      fPrviProl := .T.
      nRabat := 0
      nColDok := 9
      nColFCJ2 := 68

      DO WHILE !Eof() .AND. cIdfirma + cIdkonto + cIdroba == field->idFirma + field->pkonto + field->idroba

         IF field->datdok < dDatOd .AND. cPredh == "N"
            SKIP
            LOOP
         ENDIF

         IF field->datdok > dDatDo
            SKIP
            LOOP
         ENDIF

         IF cPredh == "D" .AND. field->datdok >= dDatod .AND. fPrviProl

            fPrviprol := .F.

            ? "Stanje do ", dDatOd

            @ PRow(), 35 SAY nUlaz PICT pickol
            @ PRow(), PCol() + 1 SAY nIzlaz       PICT pickol
            @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol

            IF Round( nUlaz - nIzlaz, 4 ) <> 0
               @ PRow(), PCol() + 1 SAY nNV / ( nUlaz - nIzlaz ) PICT piccdem
               @ PRow(), PCol() + 1 SAY 0            PICT pickol
               @ PRow(), PCol() + 1 SAY nMPV / ( nUlaz - nIzlaz ) PICT piccdem
            ELSEIF Round( nMpv, 3 ) <> 0
               @ PRow(), PCol() + 1 SAY 0            PICT pickol
               @ PRow(), PCol() + 1 SAY 0            PICT pickol
               @ PRow(), PCol() + 1 SAY PadC( "ERR", Len( piccdem ) )
            ELSE
               @ PRow(), PCol() + 1 SAY 0            PICT pickol
            ENDIF
         ENDIF

         IF ( PRow() - dodatni_redovi_po_stranici() ) > 62
            FF
            Zagl()
         ENDIF

         IF field->pu_i == "1"

            nUlaz += field->kolicina - field->GKolicina - field->GKolicin2

            IF field->datdok >= dDatod

               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa, field->idpartner

               nCol1 := PCol() + 1

               @ PRow(), PCol() + 1 SAY field->kolicina PICT pickol
               @ PRow(), PCol() + 1 SAY 0 PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
               @ PRow(), PCol() + 1 SAY field->nc PICT piccdem
               @ PRow(), PCol() + 1 SAY field->vpc PICT piccdem
               @ PRow(), PCol() + 1 SAY field->mpcsapp PICT piccdem

            ENDIF

            nMPVP += field->mpcsapp * field->kolicina
            nMPV += field->mpcsapp * field->kolicina
            nNV += field->nc * field->kolicina

            IF field->datdok >= dDatOd
               @ PRow(), PCol() + 1 SAY nMpv PICT picdem
            ENDIF

            IF _is_rok
               _dok_hash := hb_Hash()
               _dok_hash[ "idfirma" ] := field->idfirma
               _dok_hash[ "idtipdok" ] := field->idvd
               _dok_hash[ "brdok" ] := field->brdok
               _dok_hash[ "rbr" ] := field->rbr
               _item_istek_roka := CToD( get_kalk_atribut_rok( _dok_hash, .T. ) )
               IF DToC( _item_istek_roka ) <> DToC( CToD( "" ) )
                  @ PRow(), PCol() + 1 SAY  "rok: " + DToC( _item_istek_roka )
               ENDIF
            ENDIF


         ELSEIF field->pu_i == "5" .AND. !( field->idvd $ "12#13#22" )

            aPorezi := {}

            nIzlaz += field->kolicina

            Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
            aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
            nPor1 := aIPor[ 1 ]
            VtPorezi()

            IF field->datdok >= dDatod

               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa, field->idpartner

               nCol1 := PCol() + 1

               @ PRow(), PCol() + 1 SAY 0 PICT pickol
               @ PRow(), PCol() + 1 SAY field->kolicina PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
               @ PRow(), PCol() + 1 SAY field->nc PICT piccdem
               @ PRow(), PCol() + 1 SAY field->mpc PICT piccdem
               @ PRow(), PCol() + 1 SAY field->mpcsapp PICT piccdem

            ENDIF

            nMPVP -= ( field->mpc + nPor1 ) * field->kolicina
            nMPV -= field->mpcsapp * field->kolicina
            nNV -= field->nc * field->kolicina

            IF field->datdok >= dDatOd
               @ PRow(), PCol() + 1 SAY nMpv PICT picdem
            ENDIF

         ELSEIF field->pu_i == "I"
            nIzlaz += field->gkolicin2

            IF field->datdok >= dDatod
               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa, field->idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY 0 PICT pickol
               @ PRow(), PCol() + 1 SAY field->gkolicin2 PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
               @ PRow(), PCol() + 1 SAY field->nc PICT piccdem
               @ PRow(), PCol() + 1 SAY 0 PICT piccdem
               @ PRow(), PCol() + 1 SAY field->mpcsapp PICT piccdem
            ENDIF

            nMPVP -= field->mpcsapp * field->gkolicin2
            nMPV -= field->mpcsapp * field->gkolicin2
            nNV -= field->nc * field->gkolicin2

            IF field->datdok >= dDatod
               @ PRow(), PCol() + 1 SAY nMpv PICT picdem
            ENDIF

         ELSEIF field->pu_i == "5" .AND. ( field->idvd $ "12#13#22" )

            nUlaz -= field->kolicina

            IF field->datdok >= dDatod
               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa, field->idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY -( field->kolicina ) PICT pickol
               @ PRow(), PCol() + 1 SAY 0 PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
               @ PRow(), PCol() + 1 SAY field->nc PICT piccdem
               @ PRow(), PCol() + 1 SAY field->vpc PICT piccdem
               @ PRow(), PCol() + 1 SAY field->mpcsapp PICT piccdem
            ENDIF

            nMPVP -= field->mpcsapp * field->kolicina
            nMPV -= field->mpcsapp * field->kolicina
            nNV -= field->nc * field->kolicina

            IF field->datdok >= dDatod
               @ PRow(), PCol() + 1 SAY nMpv PICT picdem
            ENDIF

         ELSEIF field->pu_i == "3"

            // nivelacija

            IF field->datdok >= dDatod
               ? field->datdok, field->idvd + "-" + field->brdok, field->idtarifa, field->idpartner
               nCol1 := PCol() + 1
               @ PRow(), PCol() + 1 SAY field->kolicina PICT pickol
               @ PRow(), PCol() + 1 SAY 0 PICT pickol
               @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
               @ PRow(), PCol() + 1 SAY field->fcj PICT piccdem
               @ PRow(), PCol() + 1 SAY field->mpcsapp PICT piccdem
               @ PRow(), PCol() + 1 SAY field->fcj + field->mpcsapp PICT piccdem
            ENDIF

            nMPVP += field->mpcsapp * field->kolicina
            nMPV += field->mpcsapp * field->kolicina

            IF field->datdok >= dDatod
               @ PRow(), PCol() + 1 SAY nMpv PICT picdem
            ENDIF

         ENDIF

         SKIP

      ENDDO

      ? __line
      ? "Ukupno:"

      @ PRow(), nCol1 SAY nUlaz PICT pickol
      @ PRow(), PCol() + 1 SAY nIzlaz PICT pickol
      @ PRow(), PCol() + 1 SAY nUlaz - nIzlaz PICT pickol
      IF Round( nUlaz - nIzlaz, 4 ) <> 0
         @ PRow(), PCol() + 1 SAY nNV / ( nUlaz - nIzlaz ) PICT piccdem
         @ PRow(), PCol() + 1 SAY 0 PICT pickol
         @ PRow(), PCol() + 1 SAY nMPV / ( nUlaz - nIzlaz ) PICT piccdem
      ELSEIF Round( nMpv, 3 ) <> 0
         @ PRow(), PCol() + 1 SAY 0 PICT pickol
         @ PRow(), PCol() + 1 SAY 0 PICT pickol
         @ PRow(), PCol() + 1 SAY PadC( "ERR", Len( piccdem ) )
      ELSE
         @ PRow(), PCol() + 1 SAY 0 PICT pickol
      ENDIF

      @ PRow(), PCol() + 1 SAY nMpv PICT picdem

      ? __line
      ?
      ? Replicate( "-", 60 )
      ? "     Ukupna vrijednost popusta u mp:", Str( Abs( nMPVP - nMPV ), 12, 2 )
      ? "Ukupna prodajna vrijednost - popust:", Str( nMPVP, 12, 2 )
      ? Replicate( "-", 60 )
      ?

   ENDDO

   my_close_all_dbf()

   FF
   ENDPRINT

   RETURN .T.



STATIC FUNCTION _set_zagl( cLine, cTxt1 )

   LOCAL aKProd := {}
   LOCAL nPom

   nPom := 8
   AAdd( aKProd, { nPom, PadC( "Datum", nPom ) } )
   nPom := 11
   AAdd( aKProd, { nPom, PadC( "Dokument", nPom ) } )
   nPom := 6
   AAdd( aKProd, { nPom, PadC( "Tarifa", nPom ) } )
   nPom := 6
   AAdd( aKProd, { nPom, PadC( "Partn", nPom ) } )

   nPom := Len( gPicKol )
   AAdd( aKProd, { nPom, PadC( "Ulaz", nPom ) } )
   AAdd( aKProd, { nPom, PadC( "Izlaz", nPom ) } )
   AAdd( aKProd, { nPom, PadC( "Stanje", nPom ) } )

   nPom := Len( gPicCDem )
   AAdd( aKProd, { nPom, PadC( "NC", nPom ) } )
   AAdd( aKProd, { nPom, PadC( "PC", nPom ) } )
   AAdd( aKProd, { nPom, PadC( "PC sa PDV", nPom ) } )
   AAdd( aKProd, { nPom, PadC( "PV", nPom ) } )

   cLine := SetRptLineAndText( aKProd, 0 )
   cTxt1 := SetRptLineAndText( aKProd, 1, "*" )

   RETURN .T.


FUNCTION Test( cIdRoba )

   IF Len( Trim( cIdRoba ) ) <= 10
      cIdRoba := Left( cIdRoba, 10 )
   ELSE
      cIdRoba := cIdRoba
   ENDIF

   RETURN cIdRoba



STATIC FUNCTION Zagl()

   SELECT konto
   HSEEK cIdKonto

   Preduzece()
   P_12CPI
   ?? "KARTICA PRODAVNICA za period", ddatod, "-", ddatdo, Space( 10 ), "Str:", Str( ++nTStrana, 3 )
   IspisNaDan( 10 )

   ? "Konto: ", cidkonto, "-", konto->naz
   SELECT kalk
   P_COND
   ? __line
   IF IsPDV()
      ? __txt1
   ELSE
      ? " Datum     Dokument  Tarifa  Partn " + "    Ulaz      Izlaz     Stanje      NC         VPC       MPCSAPP        MPV"
   ENDIF
   ? __line

   RETURN


FUNCTION NPArtikli()

   LOCAL PicDEM := gPicDem
   LOCAL Pickol := "@Z " + gpickol

   qqKonto := "132;"
   qqRoba  := ""
   cSta    := "O"
   dDat0   := Date()
   dDat1   := Date()
   nTop    := 20
   aNiz := {   { "Uslov za prodavnice (prazno-sve)", "qqKonto",              , "@!S30", } }
   AAdd ( aNiz, { "Uslov za robu/artikle (prazno-sve)", "qqRoba",              , "@!S30", } )
   AAdd ( aNiz, { "Pregled po Iznosu/Kolicini/Oboje (I/K/O)", "cSta", "cSta$'IKO'", "@!", } )
   AAdd ( aNiz, { "Izvjestaj se pravi od datuma", "dDat0",              ,         , } )
   AAdd ( aNiz, { "                   do datuma", "dDat1",              ,         , } )
   AAdd ( aNiz, { "Koliko artikala ispisati?", "nTop", "nTop > 0", "999", } )

   O_PARAMS
   PRIVATE cSection := "F", cHistory := " ", aHistory := {}
   Params1()
   RPar( "c2", @qqKonto )
   RPar( "c5", @qqRoba )
   RPar( "d1", @dDat0 ); RPar( "d2", @dDat1 )

   qqKonto := PadR( qqKonto, 60 )
   qqRoba  := PadR( qqRoba, 60 )

   DO WHILE .T.
      IF !VarEdit( aNiz, 9, 1, 19, 78, ;
            'USLOVI ZA IZVJESTAJ "NAJPROMETNIJI ARTIKLI"', ;
            "B1" )
         CLOSERET
      ENDIF
      aUsl1 := Parsiraj( qqRoba, "IDROBA", "C" )
      aUsl2 := Parsiraj( qqKonto, "PKONTO", "C" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. dDat0 <= dDat1
         EXIT
      ELSEIF aUsl2 == NIL
         Msg( "Kriterij za prodavnice nije korektno postavljen!" )
      ELSEIF aUsl1 == NIL
         Msg( "Kriterij za robu nije korektno postavljen!" )
      ELSE
         Msg( "'Datum do' ne smije biti stariji nego 'datum od'!" )
      ENDIF
   ENDDO

   IF Params2()
      WPar( "c2", qqKonto )
      WPar( "c5", qqRoba )
      WPar( "d1", dDat0 )
      WPar( "d2", dDat1 )
   ENDIF
   SELECT params
   USE

   O_KALK

   cFilt := aUsl1 + " .and. " + aUsl2 + " .and. DATDOK>=" + dbf_quote( dDat0 ) + ;
      " .and. DATDOK<=" + dbf_quote( dDat1 ) + ;
      ' .and. PU_I=="5"' + ;
      ' .and. !(IDVD $ "12#13#22")'

   SET ORDER TO TAG "7"
   SET FILTER TO &cFilt

   nMinI := 999999999999
   nMinK := 999999999999
   aTopI := {}
   aTopK := {}

   MsgO( "Priprema izvještaja..." )

   GO TOP
   DO WHILE !Eof()
      cIdRoba   := IDROBA
      nKolicina := 0
      nIznos    := 0
      DO WHILE !Eof() .AND. IDROBA == cIdRoba
         nKolicina += kolicina
         nIznos    += kolicina * mpcsapp
         SKIP 1
      ENDDO
      IF Len( aTopI ) < nTop
         AAdd( aTopI, { cIdRoba, nIznos } )
         nMinI := Min( nIznos, nMinI )
      ELSEIF nIznos > nMinI
         nPom := AScan( aTopI, {| x| x[ 2 ] <= nMinI } )
         IF nPom < 1 .OR. nPom > Len( aTopI )
            MsgBeep( "nPom=" + Str( nPom ) + " ?!" )
         ENDIF
         aTopI[ nPom ] := { cIdRoba, nIznos }
         nMinI := nIznos
         AEval( aTopI, {| x| nMinI := Min( nMinI, x[ 2 ] ) } )
      ENDIF
      IF Len( aTopK ) < nTop
         AAdd( aTopK, { cIdRoba, nKolicina } )
         nMinK := Min( nKolicina, nMinK )
      ELSEIF nKolicina > nMinK
         nPom := AScan( aTopK, {| x| x[ 2 ] <= nMinK } )
         IF nPom < 1 .OR. nPom > Len( aTopK )
            MsgBeep( "nPom=" + Str( nPom ) + " ?!" )
         ENDIF
         aTopK[ nPom ] := { cIdRoba, nKolicina }
         nMinK := nKolicina
         AEval( aTopK, {| x| nMinK := Min( nMinK, x[ 2 ] ) } )
      ENDIF
   ENDDO

   MsgC()

   ASort( aTopI,,, {| x, y| x[ 2 ] > y[ 2 ] } )
   ASort( aTopK,,, {| x, y| x[ 2 ] > y[ 2 ] } )

   O_ROBA
   SELECT ROBA

   START PRINT CRET
   ?
   Preduzece()
   ?? "Najprometniji artikli za period", ddat0, "-", ddat1
   ?U "Obuhvaćene prodavnice:", IF( Empty( qqKonto ), "SVE", "'" + Trim( qqKonto ) + "'" )
   ?U "Obuhvaćeni artikli   :", IF( Empty( qqRoba ), "SVI", "'" + Trim( qqRoba ) + "'" )
   ?

   IF cSta $ "IO"
      m := AllTrim( Str( Min( nTop, Len( aTopI ) ) ) ) + " NAJPROMETNIJIH ARTIKALA POSMATRANO PO IZNOSIMA:"
      ? __line
      ? REPL( "-", Len( m ) )
      ?
      ?U PadC( "ŠIFRA", Len( id ) ) + " " + PadC( "NAZIV", Len( naz ) ) + " " + PadC( "IZNOS", 20 )
      ? REPL( "-", Len( id ) ) + " " + REPL( "-", Len( naz ) ) + " " + REPL( "-", 20 )
      FOR i := 1 TO Len( aTopI )
         cIdRoba := aTopI[ i, 1 ]
         SEEK cIdRoba
         ? cIdRoba, Left( ROBA->naz, 40 ), PadC( Transform( aTopI[ i, 2 ], picdem ), 20 )
      NEXT
      ? REPL( "-", Len( id ) ) + " " + REPL( "-", Len( naz ) ) + " " + REPL( "-", 20 )

   ENDIF

   IF cSta $ "KO"
      IF cSta == "O"
         ?
         ?
         ?
      ENDIF
      m := AllTrim( Str( Min( nTop, Len( aTopK ) ) ) ) + " NAJPROMETNIJIH ARTIKALA POSMATRANO PO KOLICINAMA:"
      ? __line
      ? REPL( "-", Len( m ) )
      ?
      ?U PadC( "ŠIFRA", Len( id ) ) + " " + PadC( "NAZIV", Len( naz ) ) + " " + PadC( "KOLICINA", 20 )
      ? REPL( "-", Len( id ) ) + " " + REPL( "-", Len( naz ) ) + " " + REPL( "-", 20 )

      FOR i := 1 TO Len( aTopK )
         cIdRoba := aTopK[ i, 1 ]
         SEEK cIdRoba
         ? cIdRoba, Left( ROBA->naz, 40 ), PadC( Transform( aTopK[ i, 2 ], pickol ), 20 )
      NEXT
      ? REPL( "-", Len( id ) ) + " " + REPL( "-", Len( naz ) ) + " " + REPL( "-", 20 )

   ENDIF

   FF

   ENDPRINT

   CLOSERET

   RETURN
