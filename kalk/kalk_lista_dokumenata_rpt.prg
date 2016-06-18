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




FUNCTION StDoks()

   LOCAL nCol1 := 0, cImeKup
   LOCAL cidfirma
   LOCAL nul, nizl, nRbr
   LOCAL m
   PRIVATE qqTipDok
   PRIVATE ddatod, ddatdo

   o_kalk_doks()

   IF reccount2() == 0
      kalk_gen_doks_iz_kalk()
   ENDIF

   my_close_all_dbf()

   SStDoks()

   RETURN





FUNCTION SStDoks()

   LOCAL lImaUkSt := .F.
   LOCAL _head
   LOCAL _n_col := 20
   LOCAL _pkonto, _mkonto
   LOCAL _qqmkonto, _qqpkonto
   LOCAL _partn_naz := "N"

   o_kalk_doks()
   O_PARTN
   o_kalk()

   cIdfirma := gFirma
   dDatOd := CToD( "" )
   dDatDo := Date()
   _mkonto := Space( 300 )
   _pkonto := Space( 300 )
   _qqpkonto := ""
   _qqmkonto := ""

   qqVD := ""

   Box(, 12, 75 )

   PRIVATE cStampaj := "N"
   qqBrDok := ""

   cIdFirma := fetch_metric( "kalk_lista_dokumenata_firma", my_user(), cIdFirma )
   qqVD := fetch_metric( "kalk_lista_dokumenata_vd", my_user(), qqVD )
   qqBrDok := fetch_metric( "kalk_lista_dokumenata_brdok", my_user(), qqBrDok )
   dDatOd := fetch_metric( "kalk_lista_dokumenata_datum_od", my_user(), dDatOd )
   dDatDo := fetch_metric( "kalk_lista_dokumenata_datum_do", my_user(), dDatDo )
   _mkonto := fetch_metric( "kalk_lista_dokumenata_mkonto", my_user(), _mkonto )
   _pkonto := fetch_metric( "kalk_lista_dokumenata_pkonto", my_user(), _pkonto )
   _partn_naz := fetch_metric( "kalk_lista_dokumenata_ispis_partnera", my_user(), _partn_naz )

   qqVD := PadR( qqVD, 2 )
   qqBrDok := PadR( qqBrDok, 60 )

   cImeKup := Space( 20 )
   cIdPartner := Space( 6 )

   DO WHILE .T.

      IF gNW == "X"
         cIdFirma := PadR( cidfirma, 2 )
         @ m_x + 1, m_y + 2 SAY "Firma - prazno svi" GET cIdFirma valid {|| .T. }
         READ
      ENDIF

      IF !Empty( cidfirma )
         @ m_x + 2, m_y + 2 SAY "Tip dokumenta (prazno svi tipovi)" GET qqVD PICT "@!"
         qqVD := "  "
      ELSE
         cIdfirma := ""
      ENDIF

      @ m_x + 3, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 3, Col() + 1 SAY "do"  GET dDatDo
      @ m_x + 5, m_y + 2 SAY "Partner" GET cIdPartner PICT "@!" VALID Empty( cidpartner ) .OR. P_Firma( @cIdPartner )
      @ m_x + 6, m_y + 2 SAY " Magacinska konta:" GET _mkonto PICT "@S30"
      @ m_x + 7, m_y + 2 SAY "Prodavnicka konta:" GET _pkonto PICT "@S30"
      @ m_x + 8, m_y + 2 SAY "Brojevi dokumenata (prazno-svi)" GET qqBrDok PICT "@!S40"
      @ m_x + 10, m_y + 2 SAY "Ispis naziva partnera (D/N)?" GET _partn_naz PICT "@!" VALID _partn_naz $ "DN"
      @ m_x + 12, m_y + 2 SAY "Izvrsiti stampanje sadrzaja ovih dokumenata ?"  GET cStampaj PICT "@!" VALID cStampaj $ "DN"

      READ

      ESC_BCR

      aUsl1 := Parsiraj( qqBrDok, "BRDOK" )

      IF !Empty( _mkonto )
         _qqmkonto := Parsiraj( _mkonto, "mkonto" )
      ENDIF

      IF !Empty( _pkonto )
         _qqpkonto := Parsiraj( _pkonto, "pkonto" )
      ENDIF

      IF aUsl1 <> NIL
         EXIT
      ENDIF

   ENDDO

   qqVD := Trim( qqVD )
   qqBrDok := Trim( qqBrDok )

   set_metric( "kalk_lista_dokumenata_firma", my_user(), cIdFirma )
   set_metric( "kalk_lista_dokumenata_vd", my_user(), qqVD )
   set_metric( "kalk_lista_dokumenata_brdok", my_user(), qqBrDok )
   set_metric( "kalk_lista_dokumenata_datum_od", my_user(), dDatOd )
   set_metric( "kalk_lista_dokumenata_datum_do", my_user(), dDatDo )
   set_metric( "kalk_lista_dokumenata_mkonto", my_user(), _mkonto )
   set_metric( "kalk_lista_dokumenata_pkonto", my_user(), _pkonto )
   set_metric( "kalk_lista_dokumenata_ispis_partnera", my_user(), _partn_naz )

   BoxC()

   SELECT kalk_doks

   IF FieldPos( "ukstavki" ) <> 0
      lImaUkSt := .T.
   ENDIF

   PRIVATE cFilt := ".t."

   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilt += ".and. DatDok>=" + dbf_quote( dDatOd ) + ".and. DatDok<=" + dbf_quote( dDatDo )
   ENDIF

   IF !Empty( qqVD )
      cFilt += ".and. idvd==" + dbf_quote( qqVD )
   ENDIF

   IF !Empty( cIdPartner )
      cFilt += ".and. idpartner==" + dbf_quote( cIdPartner )
   ENDIF

   IF !Empty( qqBrDok )
      cFilt += ( ".and." + aUsl1 )
   ENDIF

   IF !Empty( _qqmkonto )
      cFilt += ( ".and." + _qqmkonto )
   ENDIF

   IF !Empty( _qqpkonto )
      cFilt += ( ".and." + _qqpkonto )
   ENDIF

   SET FILTER to &cFilt

   qqVD := Trim( qqVD )

   SEEK cIdFirma + qqVD

   IF cStampaj == "D"
      kalk_stampa_dokumenta( .T., "IZDOKS" )
      my_close_all_dbf()
      RETURN
   ENDIF

   EOF CRET

   gaZagFix := { 6, 3 }

   START PRINT CRET
   ?

   Preduzece()

   IF gDuzKonto > 7
      P_COND2
   ELSE
      P_COND
   ENDIF

   ?? "KALK: Stampa dokumenata na dan:", Date(), Space( 10 ), "za period", dDatOd, "-", dDatDo

   IF !Empty( qqVD )
      ?? Space( 2 ), "za tipove dokumenta:", Trim( qqVD )
   ENDIF

   IF !Empty( qqBrDok )
      ?? Space( 2 ), "za brojeve dokumenta:", Trim( qqBrDok )
   ENDIF

   m := _get_rpt_line()
   _head := _get_rpt_header()

   ? m
   ? _head
   ? m

   nC := 0
   nCol1 := 30
   nNV := nVPV := nRabat := nMPV := 0
   nUkStavki := 0

   DO WHILE !Eof() .AND. IdFirma == cIdFirma

      SELECT partn
      HSEEK kalk_doks->idpartner

      SELECT kalk_doks

      ? Str( ++nC, 6 ) + "."

      @ PRow(), PCol() + 1 SAY field->datdok
      @ PRow(), PCol() + 1 SAY PadR( field->idfirma + "-" + field->idVd + "-" + field->brdok, 16 )

      IF field->idvd == "80"

         SELECT kalk
         GO TOP
         SEEK kalk_doks->idfirma + kalk_doks->idvd + kalk_doks->brdok

         IF !Empty( kalk->idkonto2 )
            @ PRow(), PCol() + 1 SAY PadR( AllTrim( field->idkonto ) + "->" + AllTrim( field->idkonto2 ), 15 )
         ELSE
            @ PRow(), PCol() + 1 SAY PadR( kalk_doks->mkonto, 7 )
            @ PRow(), PCol() + 1 SAY PadR( kalk_doks->pkonto, 7 )
         ENDIF

         SELECT kalk_doks

      ELSE
         @ PRow(), PCol() + 1 SAY PadR( kalk_doks->mkonto, 7 )
         @ PRow(), PCol() + 1 SAY PadR( kalk_doks->pkonto, 7 )
      ENDIF

      @ PRow(), _n_col := PCol() + 1 SAY PadR( field->idpartner, 6 )
      @ PRow(), PCol() + 1 SAY PadR( field->idzaduz, 6 )
      @ PRow(), PCol() + 1 SAY PadR( field->idzaduz2, 6 )

      nCol1 := PCol() + 1

      @ PRow(), PCol() + 1 SAY Str( nv, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( vpv, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( rabat, 12, 2 )
      @ PRow(), PCol() + 1 SAY Str( mpv, 12, 2 )

      IF FieldPos( "sifra" ) <> 0
         @ PRow(), PCol() + 1 SAY PadR( iif( Empty( sifra ), Space( 2 ), Left( CryptSC( sifra ), 2 ) ), 6 )
      ENDIF

      select_o_kalk_doks2()
      HSEEK kalk_doks->(idfirma+idvd+brdok)
      @ prow(), pcol() + 1 SAY kalk_doks2->datval
      SELECT kalk_doks

      // drugi red
      IF _partn_naz == "D" .AND. !Empty( field->idpartner )
         ?
         @ PRow(), _n_col SAY AllTrim( partn->naz )
      ENDIF

      nNV += NV
      nVPV += VPV
      nRabat += Rabat
      nMPV += MPV

      IF lImaUkSt
         IF field->ukStavki == 0

            nStavki := 0

            SELECT kalk
            SET ORDER TO TAG "1"
            SEEK kalk_doks->( idFirma + idVd + brDok )

            DO WHILE !Eof() .AND. idFirma + idVd + brDok == kalk_doks->( idFirma + idVd + brDok )
               nStavki := nStavki + 1
               SKIP 1
            ENDDO

            SELECT kalk_doks
            _rec := dbf_get_rec()
            _rec[ "ukstavki" ] := nStavki
            update_rec_server_and_dbf( "kalk_doks", _rec, 1, "FULL" )

         ENDIF

         nUkStavki += field->ukStavki
         @ PRow(), PCol() + 1 SAY Str( field->ukStavki, 6 )

      ENDIF

      SKIP

   ENDDO

   ? m
   ? "UKUPNO   "

   @ PRow(), nCol1 SAY Str( nnv, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nvpv, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nrabat, 12, 2 )
   @ PRow(), PCol() + 1 SAY Str( nmpv, 12, 2 )

   IF FieldPos( "sifra" ) <> 0
      ?? "       "
   ENDIF

   IF lImaUkSt
      @ PRow(), PCol() + 1 SAY Str( nUkStavki, 6 )
   ENDIF
   ? m

   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN


STATIC FUNCTION _get_rpt_header()

   LOCAL _head := ""

   _head += PadC( "Rbr", 7 )
   _head += Space( 1 )
   _head += PadC( "Datum", 8 )
   _head += Space( 1 )
   _head += PadC( "Dokument", 16 )
   _head += Space( 1 )
   _head += PadC( "M-konto", 7 )
   _head += Space( 1 )
   _head += PadC( "P-konto", 7 )
   _head += Space( 1 )
   _head += PadC( "Part.", 6 )
   _head += Space( 1 )
   _head += PadC( "Zad.", 6 )
   _head += Space( 1 )
   _head += PadC( "Zad.2", 6 )
   _head += Space( 1 )
   _head += PadC( "NV", 12 )
   _head += Space( 1 )
   _head += PadC( "VPV", 12 )
   _head += Space( 1 )
   _head += PadC( "RABATV", 12 )
   _head += Space( 1 )
   _head += PadC( "MPV", 12 )
   _head += Space( 1 )
   _head += PadC( "Op.", 6 )
   _head += Space( 1 )
   _head += PadC( "DatVal", 8 )
   RETURN _head



// ------------------------------------------------------
// vraca liniju za report
// ------------------------------------------------------
STATIC FUNCTION _get_rpt_line()

   LOCAL _line := ""

   _line += Replicate( "-", 7 )
   _line += Space( 1 )
   _line += Replicate( "-", 8 )
   _line += Space( 1 )
   _line += Replicate( "-", 16 )
   _line += Space( 1 )
   _line += Replicate( "-", 7 )
   _line += Space( 1 )
   _line += Replicate( "-", 7 )
   _line += Space( 1 )
   _line += Replicate( "-", 6 )
   _line += Space( 1 )
   _line += Replicate( "-", 6 )
   _line += Space( 1 )
   _line += Replicate( "-", 6 )
   _line += Space( 1 )
   _line += Replicate( "-", 12 )
   _line += Space( 1 )
   _line += Replicate( "-", 12 )
   _line += Space( 1 )
   _line += Replicate( "-", 12 )
   _line += Space( 1 )
   _line += Replicate( "-", 12 )
   _line += Space( 1 )
   _line += Replicate( "-", 6 )
   _line += Space( 1 )
   _line += Replicate( "-", 8 )
   
   RETURN _line




/* kalk_gen_doks_iz_kalk()
 *     Generisanje tabele DOKS na osnovu tabele KALK
 */

FUNCTION kalk_gen_doks_iz_kalk()

   // {
   o_kalk()

   SELECT kalk
   GO TOP

   DO WHILE !Eof()
      SELECT kalk_doks
      APPEND BLANK

      SELECT kalk
      cIDFirma := idfirma
      PRIVATE cBrDok := BrDok, cIdVD := IdVD, dDatDok := datdok

      cIdpartner := idpartner; cmkonto := mkonto; cpkonto := pkonto ; cIdZaduz := idzaduz; cIdzaduz2 := idzaduz2
      SELECT kalk_doks
      REPLACE idfirma WITH cidfirma, brdok WITH cbrdok, ;
         datdok WITH ddatdok, idvd WITH cidvd, ;
         idpartner WITH cIdPartner, mkonto WITH cMKONTO, pkonto WITH cPKONTO, ;
         idzaduz WITH cidzaduz, idzaduz2 WITH cidzaduz2, ;
         brfaktp WITH kalk->BrFaktP

      SELECT kalk

      nNV := nVPV := nMPV := nRABAT := 0
      DO WHILE !Eof() .AND. cIdFirma == IdFirma .AND. cIdVD == IdVD .AND. cBrDok == BrDok
         IF mu_i = "1"
            nNV += nc * ( kolicina - gkolicina - gkolicin2 )
            nVPV += vpc * ( kolicina - gkolicina - gkolicin2 )
         ELSEIF mu_i = "3"
            nVPV += vpc * ( kolicina - gkolicina - gkolicin2 )
         ELSEIF mu_i = "5"
            nNV -= nc * ( kolicina )
            nVPV -= vpc * ( kolicina )
            nRabat += vpc * rabatv / 100 * kolicina
         ENDIF

         IF pu_i == "1"
            IF Empty( mu_i )
               nNV += nc * kolicina
            ENDIF
            nMPV += mpcsapp * kolicina
         ELSEIF pu_i == "5"
            IF Empty( mu_i )
               nNV -= nc * kolicina
            ENDIF
            nMPV -= mpcsapp * kolicina
         ELSEIF pu_i == "I"
            nMPV -= mpcsapp * gkolicin2
            nNV -= nc * gkolicin2
         ELSEIF pu_i == "3"
            nMPV += mpcsapp * kolicina
         ENDIF

         SKIP
      ENDDO

      SELECT kalk_doks
      REPLACE nv WITH nnv, vpv WITH nvpv, rabat WITH nrabat, mpv WITH nmpv

      SELECT kalk

   ENDDO

   RETURN
// }
