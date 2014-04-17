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


#include "fakt.ch"


// -------------------------------------------------
// specificne rudnik opcije
// -------------------------------------------------
FUNCTION mnu_sp_rudnik()

   LOCAL _opc := {}
   LOCAL _opcexe := {}
   LOCAL _izbor := 1

   AAdd( _opc, "1. isporučeni asortiman po kupcima                " )
   AAdd( _opcexe, {|| rpt_sp_isporuke_po_kup_asort() } )
   AAdd( _opc, "2. fakture asortimana za kupca" )
   AAdd( _opcexe, {|| rpt_sp_fakture_asort() } )
   AAdd( _opc, "3. isporučeni asortiman za kupca po pogonima" )
   AAdd( _opcexe, {|| rpt_sp_isporuke_pogon() } )
   AAdd( _opc, "4. pregled faktura usluga za kupca" )
   AAdd( _opcexe, {|| rpt_sp_fakture_usluga() } )
   AAdd( _opc, "5. pregled poreza" )
   AAdd( _opcexe, {|| rpt_sp_pregled_poreza() } )

   f18_menu( "rizv", .F., _izbor, _opc, _opcexe )

   RETURN


// -------------------------------------------------
// isporuceni asortiman po kupcima i asortimanu
// -------------------------------------------------
FUNCTION rpt_sp_isporuke_po_kup_asort()

   O_PARTN
   O_FAKT

   qqRoba := Space( 60 )
   qqRoba1 := Space( 60 ); cRoba1 := Space( 10 )
   qqRoba2 := Space( 60 ); cRoba2 := Space( 10 )
   qqRoba3 := Space( 60 ); cRoba3 := Space( 10 )
   qqRoba4 := Space( 60 ); cRoba4 := Space( 10 )
   qqRoba5 := Space( 60 ); cRoba5 := Space( 10 )
   qqRoba6 := Space( 60 ); cRoba6 := Space( 10 )
   dDatOd := CToD( "" ); dDatDo := Date(); gOstr := "D"
   cProsCij := "N"

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}

   Params1()

   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "O1", @cRoba1 ); RPar( "O2", @cRoba2 ); RPar( "O3", @cRoba3 )
   RPar( "O4", @cRoba4 ); RPar( "O5", @cRoba5 ); RPar( "O6", @cRoba6 )
   RPar( "F0", @qqRoba )
   RPar( "F1", @qqRoba1 ); RPar( "F2", @qqRoba2 ); RPar( "F3", @qqRoba3 )
   RPar( "F4", @qqRoba4 ); RPar( "F5", @qqRoba5 ); RPar( "F6", @qqRoba6 )
   RPar( "F9", @cProsCij )

   qqRoba := PadR( qqRoba, 60 )
   qqRoba1 := PadR( qqRoba1, 60 ); qqRoba2 := PadR( qqRoba2, 60 ); qqRoba3 := PadR( qqRoba3, 60 )
   qqRoba4 := PadR( qqRoba4, 60 ); qqRoba5 := PadR( qqRoba5, 60 ); qqRoba6 := PadR( qqRoba6, 60 )


   Box(, 12, 70 )
   DO WHILE .T.

      @ m_X + 1, m_Y + 15 SAY "NAZIV               USLOV"

      @ m_X + 2, m_Y + 2 SAY "Asortiman 1" GET cRoba1
      @ m_X + 2, m_Y + 26 GET qqRoba1    PICT "@!S30"
      @ m_X + 3, m_Y + 2 SAY "Asortiman 2" GET cRoba2
      @ m_X + 3, m_Y + 26 GET qqRoba2    PICT "@!S30"
      @ m_X + 4, m_Y + 2 SAY "Asortiman 3" GET cRoba3
      @ m_X + 4, m_Y + 26 GET qqRoba3    PICT "@!S30"
      @ m_X + 5, m_Y + 2 SAY "Asortiman 4" GET cRoba4
      @ m_X + 5, m_Y + 26 GET qqRoba4    PICT "@!S30"
      @ m_X + 6, m_Y + 2 SAY "Asortiman 5" GET cRoba5
      @ m_X + 6, m_Y + 26 GET qqRoba5    PICT "@!S30"
      @ m_X + 7, m_Y + 2 SAY "Asortiman 6" GET cRoba6
      @ m_X + 7, m_Y + 26 GET qqRoba6    PICT "@!S30"

      @ m_X + 8, m_Y + 2 SAY "USLOV ZA POGON (prazno-svi)" GET qqRoba PICT "@!S30"

      @ m_X + 9, m_Y + 2 SAY "Za period od" GET dDatOD
      @ m_X + 9, Col() + 2 SAY "do" GET dDatDo

      @ m_X + 10, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"
      @ m_X + 11, m_y + 2 SAY "Prikazati prosjecne cijene ? (D/N)" GET cProsCij VALID cProsCij $ "DN" PICT "@!"

      read; ESC_BCR
      aUsl0 := Parsiraj( qqRoba, "IDROBA" )
      aUsl1 := Parsiraj( qqRoba1, "IDROBA" )
      aUsl2 := Parsiraj( qqRoba2, "IDROBA" )
      aUsl3 := Parsiraj( qqRoba3, "IDROBA" )
      aUsl4 := Parsiraj( qqRoba4, "IDROBA" )
      aUsl5 := Parsiraj( qqRoba5, "IDROBA" )
      aUsl6 := Parsiraj( qqRoba6, "IDROBA" )
      IF aUsl0 <> NIL .AND. aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. aUsl3 <> NIL .AND. aUsl4 <> NIL .AND. aUsl5 <> NIL .AND. aUsl6 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   Params2()
   qqRoba := Trim( qqRoba )
   qqRoba1 := Trim( qqRoba1 ); qqRoba2 := Trim( qqRoba2 ); qqRoba3 := Trim( qqRoba3 )
   qqRoba4 := Trim( qqRoba4 ); qqRoba5 := Trim( qqRoba5 ); qqRoba6 := Trim( qqRoba6 )

   WPar( "d1", dDatOd ) ; WPar( "d2", dDatDo )
   WPar( "O1", cRoba1 ) ; WPar( "O2", cRoba2 ) ; WPar( "O3", cRoba3 )
   WPar( "O4", cRoba4 ) ; WPar( "O5", cRoba5 ) ; WPar( "O6", cRoba6 )
   WPar( "F0", qqRoba )
   WPar( "F1", qqRoba1 ); WPar( "F2", qqRoba2 ); WPar( "F3", qqRoba3 )
   WPar( "F4", qqRoba4 ); WPar( "F5", qqRoba5 ); WPar( "F6", qqRoba6 )
   WPar( "F9", cProsCij )

   SELECT params
   USE

   SELECT FAKT

   cTMPFAKT := ""
   cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. " + aUsl0
   // INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt EVAL(TekRec()) EVERY 1

   SET ORDER TO TAG "IDPARTN"
   SET FILTER to &cFilt

   GO TOP

   IF Eof()
      Msg( "Ne postoje trazeni podaci...", 6 )
      my_close_all_dbf()
      RETURN
   ENDIF

   START PRINT CRET

   PRIVATE cIdPartner := "", cNPartnera := "", nUkRoba := 0, nUkIznos := 0
   PRIVATE nRoba1 := 0, nRoba2 := 0, nRoba3 := 0, nRoba4 := 0, nRoba5 := 0, nRoba6 := 0
   PRIVATE nPCR1 := nPCR2 := nPCR3 := nPCR4 := nPCR5 := nPCR6 := nPCRU := 0
   PRIVATE nIzR1 := nIzR2 := nIzR3 := nIzR4 := nIzR5 := nIzR6 := 0

   IF cProsCij == "D"

      aKol := { { "SIFRA", {|| cIdPartner             }, .F., "C", 6, 0, 1, 1 }, ;
         { "KUPAC", {|| cNPartnera             }, .F., "C", 50, 0, 1, 2 }, ;
         { cRoba1, {|| nRoba1                 }, .T., "N", 12, 2, 1, 3 }, ;
         { cRoba2, {|| nRoba2                 }, .T., "N", 12, 2, 1, 4 }, ;
         { cRoba3, {|| nRoba3                 }, .T., "N", 12, 2, 1, 5 }, ;
         { cRoba4, {|| nRoba4                 }, .T., "N", 12, 2, 1, 6 }, ;
         { cRoba5, {|| nRoba5                 }, .T., "N", 12, 2, 1, 7 }, ;
         { cRoba6, {|| nRoba6                 }, .T., "N", 12, 2, 1, 8 }, ;
         { "UKUPNO KOL.", {|| nUkRoba                }, .T., "N", 12, 2, 1, 9 }, ;
         { "UKUPNO IZNOS", {|| Round( nUkIznos, gFZaok ) }, .T., "N", 12, 2, 3, 9 } }

      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR1 }, .F., "N", 12, 2, 2, 3 } )
      AAdd( aKol, { "IZNOS", {|| nIzR1 }, .T., "N", 12, 2, 3, 3 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR2 }, .F., "N", 12, 2, 2, 4 } )
      AAdd( aKol, { "IZNOS", {|| nIzR2 }, .T., "N", 12, 2, 3, 4 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR3 }, .F., "N", 12, 2, 2, 5 } )
      AAdd( aKol, { "IZNOS", {|| nIzR3 }, .T., "N", 12, 2, 3, 5 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR4 }, .F., "N", 12, 2, 2, 6 } )
      AAdd( aKol, { "IZNOS", {|| nIzR4 }, .T., "N", 12, 2, 3, 6 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR5 }, .F., "N", 12, 2, 2, 7 } )
      AAdd( aKol, { "IZNOS", {|| nIzR5 }, .T., "N", 12, 2, 3, 7 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR6 }, .F., "N", 12, 2, 2, 8 } )
      AAdd( aKol, { "IZNOS", {|| nIzR6 }, .T., "N", 12, 2, 3, 8 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCRU }, .F., "N", 12, 2, 2, 9 } )

   ELSE

      aKol := { { "SIFRA", {|| cIdPartner             }, .F., "C", 6, 0, 1, 1 }, ;
         { "KUPAC", {|| cNPartnera             }, .F., "C", 50, 0, 1, 2 }, ;
         { cRoba1, {|| nRoba1                 }, .T., "N", 10, 2, 1, 3 }, ;
         { cRoba2, {|| nRoba2                 }, .T., "N", 10, 2, 1, 4 }, ;
         { cRoba3, {|| nRoba3                 }, .T., "N", 10, 2, 1, 5 }, ;
         { cRoba4, {|| nRoba4                 }, .T., "N", 10, 2, 1, 6 }, ;
         { cRoba5, {|| nRoba5                 }, .T., "N", 10, 2, 1, 7 }, ;
         { cRoba6, {|| nRoba6                 }, .T., "N", 10, 2, 1, 8 }, ;
         { "UKUPNO KOL.", {|| nUkRoba                }, .T., "N", 11, 2, 1, 9 }, ;
         { "UKUPNO IZNOS", {|| Round( nUkIznos, gFZaok ) }, .T., "N", 12, 2, 1, 10 } }

   ENDIF

   ?
   P_12CPI

   ?? Space( gnLMarg ); ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg ); ?? "POGONI: " + IF( Empty( qqRoba ), "SVI", qqRoba )

   StampaTabele( aKol, {|| FSvaki1() },, gTabela,, ;
      , "Isporuceni asortiman - pregled po kupcima za period od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor1() }, IF( gOstr == "D",, -1 ),, cProsCij == "D",,, )

   FF
   ENDPRINT

   my_close_all_dbf()

   RETURN



STATIC FUNCTION FFor1()

   cIdPartner := idpartner
   nRoba1 := nRoba2 := nRoba3 := nRoba4 := nRoba5 := nRoba6 := nUkRoba := nUkIznos := 0
   nIzR1 := nIzR2 := nIzR3 := nIzR4 := nIzR5 := nIzR6 := 0
   cNPartnera := Ocitaj( F_PARTN, idpartner, "TRIM(naz)+' '+TRIM(naz2)" )

   DO WHILE !Eof() .AND. idpartner == cIdPartner

      IF &aUsl1; nRoba1 += kolicina; nIzR1 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr ); ENDIF
      IF &aUsl2; nRoba2 += kolicina; nIzR2 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr ); ENDIF
      IF &aUsl3; nRoba3 += kolicina; nIzR3 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr ); ENDIF
      IF &aUsl4; nRoba4 += kolicina; nIzR4 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr ); ENDIF
      IF &aUsl5; nRoba5 += kolicina; nIzR5 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr ); ENDIF
      IF &aUsl6; nRoba6 += kolicina; nIzR6 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr ); ENDIF
      IF &( aUsl1 + ".or." + aUsl2 + ".or." + aUsl3 + ".or." + ;
            aUsl4 + ".or." + aUsl5 + ".or." + aUsl6 )
         nUkIznos += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr )
      ENDIF

      SKIP 1

   ENDDO

   nPCR1 := Round( IF( nRoba1 <> 0, nIzR1 / nRoba1, 0 ), 2 )
   nPCR2 := Round( IF( nRoba2 <> 0, nIzR2 / nRoba2, 0 ), 2 )
   nPCR3 := Round( IF( nRoba3 <> 0, nIzR3 / nRoba3, 0 ), 2 )
   nPCR4 := Round( IF( nRoba4 <> 0, nIzR4 / nRoba4, 0 ), 2 )
   nPCR5 := Round( IF( nRoba5 <> 0, nIzR5 / nRoba5, 0 ), 2 )
   nPCR6 := Round( IF( nRoba6 <> 0, nIzR6 / nRoba6, 0 ), 2 )

   nUkRoba := nRoba1 + nRoba2 + nRoba3 + nRoba4 + nRoba5 + nRoba6
   nPCRU := Round( IF( nUkRoba <> 0, nUkIznos / nUkRoba, 0 ), 2 )

   SKIP -1

   RETURN .T.



STATIC FUNCTION FSvaki1()
   RETURN




STATIC FUNCTION TekRec()

   nSlog++
   @ m_x + 1, m_y + 2 SAY PadC( AllTrim( Str( nSlog ) ) + "/" + AllTrim( Str( nUkupno ) ), 20 )
   @ m_x + 2, m_y + 2 SAY "Obuhvaceno: " + Str( nSlog )

   RETURN ( nil )




/*! \fn rpt_sp_fakture_asort()
 *  \brief Pregled faktura asortimana za kupca
 *  \brief Izvjestaj specificno radjen za Rudnik
 */

FUNCTION rpt_sp_fakture_asort()

   // {
   O_PARTN
   O_FAKT

   cVarijanta := "1"               // 1 - sa porezom i rabatom
   // 2 - bez     - ll -
   cIdFirma := Space( 6 )
   qqRoba1 := Space( 60 ); cRoba1 := Space( 10 )
   qqRoba2 := Space( 60 ); cRoba2 := Space( 10 )
   qqRoba3 := Space( 60 ); cRoba3 := Space( 10 )
   qqRoba4 := Space( 60 ); cRoba4 := Space( 10 )
   qqRoba5 := Space( 60 ); cRoba5 := Space( 10 )
   qqRoba6 := Space( 60 ); cRoba6 := Space( 10 )
   dDatOd := CToD( "" ); dDatDo := Date(); gOstr := "D"

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "O1", @cRoba1 ); RPar( "O2", @cRoba2 ); RPar( "O3", @cRoba3 )
   RPar( "O4", @cRoba4 ); RPar( "O5", @cRoba5 ); RPar( "O6", @cRoba6 )
   RPar( "F7", @cIdFirma )
   RPar( "F1", @qqRoba1 ); RPar( "F2", @qqRoba2 ); RPar( "F3", @qqRoba3 )
   RPar( "F4", @qqRoba4 ); RPar( "F5", @qqRoba5 ); RPar( "F6", @qqRoba6 )

   cIdFirma := PadR( cIdFirma, 6 )
   qqRoba1 := PadR( qqRoba1, 60 ); qqRoba2 := PadR( qqRoba2, 60 ); qqRoba3 := PadR( qqRoba3, 60 )
   qqRoba4 := PadR( qqRoba4, 60 ); qqRoba5 := PadR( qqRoba5, 60 ); qqRoba6 := PadR( qqRoba6, 60 )


   Box(, 12, 70 )
   DO WHILE .T.

      @ m_X + 1, m_Y + 15 SAY "NAZIV               USLOV"

      @ m_X + 2, m_Y + 2 SAY "Asortiman 1" GET cRoba1
      @ m_X + 2, m_Y + 26 GET qqRoba1    PICT "@!S30"
      @ m_X + 3, m_Y + 2 SAY "Asortiman 2" GET cRoba2
      @ m_X + 3, m_Y + 26 GET qqRoba2    PICT "@!S30"
      @ m_X + 4, m_Y + 2 SAY "Asortiman 3" GET cRoba3
      @ m_X + 4, m_Y + 26 GET qqRoba3    PICT "@!S30"
      @ m_X + 5, m_Y + 2 SAY "Asortiman 4" GET cRoba4
      @ m_X + 5, m_Y + 26 GET qqRoba4    PICT "@!S30"
      @ m_X + 6, m_Y + 2 SAY "Asortiman 5" GET cRoba5
      @ m_X + 6, m_Y + 26 GET qqRoba5    PICT "@!S30"
      @ m_X + 7, m_Y + 2 SAY "Asortiman 6" GET cRoba6
      @ m_X + 7, m_Y + 26 GET qqRoba6    PICT "@!S30"

      @ m_X + 8, m_Y + 2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ) } PICT "@!S30"

      @ m_X + 9, m_Y + 2 SAY "Za period od" GET dDatOD
      @ m_X + 9, Col() + 2 SAY "do" GET dDatDo

      @ m_X + 10, m_y + 2 SAY "Varijanta ( 1-sa por.i rab. , 2-bez por.i rab. ) ? " GET cVarijanta VALID cVarijanta $ "12" PICT "9"
      @ m_X + 11, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"

      read; ESC_BCR
      aUsl1 := Parsiraj( qqRoba1, "IDROBA" )
      aUsl2 := Parsiraj( qqRoba2, "IDROBA" )
      aUsl3 := Parsiraj( qqRoba3, "IDROBA" )
      aUsl4 := Parsiraj( qqRoba4, "IDROBA" )
      aUsl5 := Parsiraj( qqRoba5, "IDROBA" )
      aUsl6 := Parsiraj( qqRoba6, "IDROBA" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. aUsl3 <> NIL .AND. aUsl4 <> NIL .AND. aUsl5 <> NIL .AND. aUsl6 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   Params2()
   // qqKupac:=trim(qqKupac)
   qqRoba1 := Trim( qqRoba1 ); qqRoba2 := Trim( qqRoba2 ); qqRoba3 := Trim( qqRoba3 )
   qqRoba4 := Trim( qqRoba4 ); qqRoba5 := Trim( qqRoba5 ); qqRoba6 := Trim( qqRoba6 )

   WPar( "d1", dDatOd ) ; WPar( "d2", dDatDo )
   WPar( "O1", cRoba1 ) ; WPar( "O2", cRoba2 ) ; WPar( "O3", cRoba3 )
   WPar( "O4", cRoba4 ) ; WPar( "O5", cRoba5 ) ; WPar( "O6", cRoba6 )
   WPar( "F7", cIdFirma )
   WPar( "F1", qqRoba1 ); WPar( "F2", qqRoba2 ); WPar( "F3", qqRoba3 )
   WPar( "F4", qqRoba4 ); WPar( "F5", qqRoba5 ); WPar( "F6", qqRoba6 )

   SELECT params; USE

   SELECT FAKT

   cTMPFAKT := ""
   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "DTOS(DATDOK)+IDTIPDOK+BRDOK"
   cFilt  := "DATDOK>=" + cm2str( dDatOd ) + ".and. DATDOK<=" + cm2str( dDatDo )
   cFilt += ".and. (EMPTY(" + cm2str( cIdFirma ) + ") .or. Idpartner==" + cm2str( cIdFirma ) + ")"
   cFilt += ".and. (" + aUsl1 + ".or." + aUsl2 + ".or." + aUsl3 + ".or." + aUsl4 + ".or." + aUsl5 + ".or." + aUsl6 + ")"
   INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt Eval( TekRec() ) EVERY 1
   BoxC()
   GO TOP
   IF Eof(); Msg( "Ne postoje trazeni podaci...", 6 ); closeret; ENDIF

   START PRINT CRET

   PRIVATE nUkKol := 0, nUkIznos := 0
   PRIVATE cIdTipDok := "", cBrDok := "", dDatum := CToD( "" )

   aKol := { { "DATUM",   {|| dDatum                                        }, .F., "D", 8, 0, 1, 1 }, ;
      { "TIP DOKUM.",   {|| cIdTipDok                                     }, .F., "C", 10, 0, 1, 2 }, ;
      { "BROJ DOKUMENTA", {|| cbrdok                                        }, .F., "C", 14, 0, 1, 3 }, ;
      { "KOLICINA",   {|| nUkKol                                        }, .T., "N", 13, 2, 1, 4 }, ;
      { "CIJENA",   {|| IF( nUkKol == 0, 0, Round( nUkIznos, gFZaok ) / nUkKol ) }, .F., "N", 13, 2, 1, 5 }, ;
      { "VRIJEDNOST",   {|| Round( nUkIznos, gFZaok )                        }, .T., "N", 14, 2, 1, 6 } }

   ?
   P_12CPI
   ?? Space( gnLMarg ); ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg ); ?? "KUPAC: " + IF( Empty( cIdFirma ), "SVI", cIdFirma + " " + Ocitaj( F_PARTN, cIdFirma, "naz" ) )

   StampaTabele( aKol, {|| FSvaki2() },, gTabela,, ;
      , "Isporuceni asortiman - pregled po fakturama za period od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor2() }, IF( gOstr == "D",, -1 ),,,,, )
   FF
   ENDPRINT
   my_close_all_dbf(); MyFERASE( cTMPFAKT )

   CLOSERET

   RETURN
// }


/*! \fn FFor2()
 *  \brief
 */

STATIC FUNCTION FFor2()

   // {
   cIdTipDok := idtipdok; cBrDok := brdok; dDatum := datdok
   nUkKol := 0; nUkIznos := 0
   DO WHILE !Eof() .AND. datdok == dDatum .AND. idtipdok == cIdTipDok .AND. brdok == cBrDok
      nUkKol += kolicina
      IF cVarijanta == "1"
         nUkIznos += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE )
      ELSE
         nUkIznos += Round( kolicina * cijena * PrerCij(), ZAOKRUZENJE )
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.
// }



/*! \fn rpt_sp_isporuke_pogon()
 *  \brief Pregled isporucenog asortimana za kupca po pogonima
 *  \brief Izvjestaj specifican za rudnik
 */

FUNCTION rpt_sp_isporuke_pogon()

   // {
   O_PARTN
   O_RJ
   O_FAKT

   cVarijanta := "1"               // 1 - sa porezom i rabatom
   // 2 - bez     - ll -
   cIdFirma := Space( 6 )
   qqRoba1 := Space( 60 ); cRoba1 := Space( 10 )
   qqRoba2 := Space( 60 ); cRoba2 := Space( 10 )
   qqRoba3 := Space( 60 ); cRoba3 := Space( 10 )
   qqRoba4 := Space( 60 ); cRoba4 := Space( 10 )
   qqRoba5 := Space( 60 ); cRoba5 := Space( 10 )
   qqRoba6 := Space( 60 ); cRoba6 := Space( 10 )
   dDatOd := CToD( "" ); dDatDo := Date(); gOstr := "D"
   cProsCij := "N"

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "O1", @cRoba1 ); RPar( "O2", @cRoba2 ); RPar( "O3", @cRoba3 )
   RPar( "O4", @cRoba4 ); RPar( "O5", @cRoba5 ); RPar( "O6", @cRoba6 )
   RPar( "F7", @cIdFirma )
   RPar( "F1", @qqRoba1 ); RPar( "F2", @qqRoba2 ); RPar( "F3", @qqRoba3 )
   RPar( "F4", @qqRoba4 ); RPar( "F5", @qqRoba5 ); RPar( "F6", @qqRoba6 )
   RPar( "F9", @cProsCij )

   cIdFirma := PadR( cIdFirma, 6 )
   qqRoba1 := PadR( qqRoba1, 60 ); qqRoba2 := PadR( qqRoba2, 60 ); qqRoba3 := PadR( qqRoba3, 60 )
   qqRoba4 := PadR( qqRoba4, 60 ); qqRoba5 := PadR( qqRoba5, 60 ); qqRoba6 := PadR( qqRoba6, 60 )


   Box(, 13, 70 )
   DO WHILE .T.

      @ m_X + 1, m_Y + 15 SAY "NAZIV               USLOV"

      @ m_X + 2, m_Y + 2 SAY "Asortiman 1" GET cRoba1
      @ m_X + 2, m_Y + 26 GET qqRoba1    PICT "@!S30"
      @ m_X + 3, m_Y + 2 SAY "Asortiman 2" GET cRoba2
      @ m_X + 3, m_Y + 26 GET qqRoba2    PICT "@!S30"
      @ m_X + 4, m_Y + 2 SAY "Asortiman 3" GET cRoba3
      @ m_X + 4, m_Y + 26 GET qqRoba3    PICT "@!S30"
      @ m_X + 5, m_Y + 2 SAY "Asortiman 4" GET cRoba4
      @ m_X + 5, m_Y + 26 GET qqRoba4    PICT "@!S30"
      @ m_X + 6, m_Y + 2 SAY "Asortiman 5" GET cRoba5
      @ m_X + 6, m_Y + 26 GET qqRoba5    PICT "@!S30"
      @ m_X + 7, m_Y + 2 SAY "Asortiman 6" GET cRoba6
      @ m_X + 7, m_Y + 26 GET qqRoba6    PICT "@!S30"

      @ m_X + 8, m_Y + 2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ) } PICT "@!S30"

      @ m_X + 9, m_Y + 2 SAY "Za period od" GET dDatOD
      @ m_X + 9, Col() + 2 SAY "do" GET dDatDo

      @ m_X + 10, m_y + 2 SAY "Varijanta ( 1-sa por.i rab. , 2-bez por.i rab. ) ? " GET cVarijanta VALID cVarijanta $ "12" PICT "9"
      @ m_X + 11, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"
      @ m_X + 12, m_y + 2 SAY "Prikazati prosjecne cijene ? (D/N)" GET cProsCij VALID cProsCij $ "DN" PICT "@!"

      read; ESC_BCR
      aUsl1 := Parsiraj( qqRoba1, "IDROBA" )
      aUsl2 := Parsiraj( qqRoba2, "IDROBA" )
      aUsl3 := Parsiraj( qqRoba3, "IDROBA" )
      aUsl4 := Parsiraj( qqRoba4, "IDROBA" )
      aUsl5 := Parsiraj( qqRoba5, "IDROBA" )
      aUsl6 := Parsiraj( qqRoba6, "IDROBA" )
      IF aUsl1 <> NIL .AND. aUsl2 <> NIL .AND. aUsl3 <> NIL .AND. aUsl4 <> NIL .AND. aUsl5 <> NIL .AND. aUsl6 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   Params2()
   // qqKupac:=trim(qqKupac)
   qqRoba1 := Trim( qqRoba1 ); qqRoba2 := Trim( qqRoba2 ); qqRoba3 := Trim( qqRoba3 )
   qqRoba4 := Trim( qqRoba4 ); qqRoba5 := Trim( qqRoba5 ); qqRoba6 := Trim( qqRoba6 )

   WPar( "d1", dDatOd ) ; WPar( "d2", dDatDo )
   WPar( "O1", cRoba1 ) ; WPar( "O2", cRoba2 ) ; WPar( "O3", cRoba3 )
   WPar( "O4", cRoba4 ) ; WPar( "O5", cRoba5 ) ; WPar( "O6", cRoba6 )
   WPar( "F7", cIdFirma )
   WPar( "F1", qqRoba1 ); WPar( "F2", qqRoba2 ); WPar( "F3", qqRoba3 )
   WPar( "F4", qqRoba4 ); WPar( "F5", qqRoba5 ); WPar( "F6", qqRoba6 )
   WPar( "F9", cProsCij )

   SELECT params; USE

   SELECT FAKT

   cTMPFAKT := ""
   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "IDROBA"
   cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. ( EMPTY(cIdFirma) .or. cIdFirma==IDPARTNER ) .and. ( " + aUsl1 + ".or." + aUsl2 + ".or." + aUsl3 + ".or." + aUsl4 + ".or." + aUsl5 + ".or." + aUsl6 + ")"
   INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt Eval( TekRec() ) EVERY 1
   BoxC()

   GO TOP
   IF Eof(); Msg( "Ne postoje trazeni podaci...", 6 ); closeret; ENDIF

   START PRINT CRET

   PRIVATE cIdRj := "", cNazRj := "", nUkRoba := 0, nUkIznos := 0
   PRIVATE nRoba1 := 0, nRoba2 := 0, nRoba3 := 0, nRoba4 := 0, nRoba5 := 0, nRoba6 := 0
   PRIVATE nPCR1 := nPCR2 := nPCR3 := nPCR4 := nPCR5 := nPCR6 := nPCRU := 0
   PRIVATE nIzR1 := nIzR2 := nIzR3 := nIzR4 := nIzR5 := nIzR6 := 0

   IF cProsCij == "D"

      aKol := { { "SIFRA", {|| cIdRj                   }, .F., "C", 6, 0, 1, 1 }, ;
         { "POGON (R.JED.)", {|| cNazRj                  }, .F., "C", 30, 0, 1, 2 }, ;
         { cRoba1, {|| nRoba1                  }, .T., "N", 12, 2, 1, 3 }, ;
         { cRoba2, {|| nRoba2                  }, .T., "N", 12, 2, 1, 4 }, ;
         { cRoba3, {|| nRoba3                  }, .T., "N", 12, 2, 1, 5 }, ;
         { cRoba4, {|| nRoba4                  }, .T., "N", 12, 2, 1, 6 }, ;
         { cRoba5, {|| nRoba5                  }, .T., "N", 12, 2, 1, 7 }, ;
         { cRoba6, {|| nRoba6                  }, .T., "N", 12, 2, 1, 8 }, ;
         { "UKUPNO KOL.", {|| nUkRoba                 }, .T., "N", 12, 2, 1, 9 }, ;
         { "UKUPNO IZNOS", {|| Round( nUkIznos, gFZaok )  }, .T., "N", 12, 2, 3, 9 } }

      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR1 }, .F., "N", 12, 2, 2, 3 } )
      AAdd( aKol, { "IZNOS", {|| nIzR1 }, .T., "N", 12, 2, 3, 3 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR2 }, .F., "N", 12, 2, 2, 4 } )
      AAdd( aKol, { "IZNOS", {|| nIzR2 }, .T., "N", 12, 2, 3, 4 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR3 }, .F., "N", 12, 2, 2, 5 } )
      AAdd( aKol, { "IZNOS", {|| nIzR3 }, .T., "N", 12, 2, 3, 5 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR4 }, .F., "N", 12, 2, 2, 6 } )
      AAdd( aKol, { "IZNOS", {|| nIzR4 }, .T., "N", 12, 2, 3, 6 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR5 }, .F., "N", 12, 2, 2, 7 } )
      AAdd( aKol, { "IZNOS", {|| nIzR5 }, .T., "N", 12, 2, 3, 7 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCR6 }, .F., "N", 12, 2, 2, 8 } )
      AAdd( aKol, { "IZNOS", {|| nIzR6 }, .T., "N", 12, 2, 3, 8 } )
      AAdd( aKol, { "PROSJ.CIJ.", {|| nPCRU }, .F., "N", 12, 2, 2, 9 } )

   ELSE

      aKol := { { "SIFRA", {|| cIdRj                   }, .F., "C", 6, 0, 1, 1 }, ;
         { "POGON (R.JED.)", {|| cNazRj                  }, .F., "C", 30, 0, 1, 2 }, ;
         { cRoba1, {|| nRoba1                  }, .T., "N", 10, 2, 1, 3 }, ;
         { cRoba2, {|| nRoba2                  }, .T., "N", 10, 2, 1, 4 }, ;
         { cRoba3, {|| nRoba3                  }, .T., "N", 10, 2, 1, 5 }, ;
         { cRoba4, {|| nRoba4                  }, .T., "N", 10, 2, 1, 6 }, ;
         { cRoba5, {|| nRoba5                  }, .T., "N", 10, 2, 1, 7 }, ;
         { cRoba6, {|| nRoba6                  }, .T., "N", 10, 2, 1, 8 }, ;
         { "UKUPNO KOL.", {|| nUkRoba                 }, .T., "N", 11, 2, 1, 9 }, ;
         { "UKUPNO IZNOS", {|| Round( nUkIznos, gFZaok )  }, .T., "N", 12, 2, 1, 10 } }

   ENDIF

   P_12CPI
   ?
   ?? Space( gnLMarg ); ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg ); ?? "KUPAC: " + IF( Empty( cIdFirma ), "SVI", cIdFirma + " " + Ocitaj( F_PARTN, cIdFirma, "naz" ) )

   StampaTabele( aKol, {|| FSvaki3() },, gTabela,, ;
      , "Isporuceni asortiman - pregled za kupca po pogonima od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor3() }, IF( gOstr == "D",, -1 ),, cProsCij == "D",,, )
   FF
   ENDPRINT
   my_close_all_dbf(); MyFERASE( cTMPFAKT )

   CLOSERET

   RETURN
// }


/*! \fn FFor3()
 *  \brief
 */

STATIC FUNCTION FFor3()

   // {
   cIdRj := Left( IDROBA, 2 )
   nRoba1 := nRoba2 := nRoba3 := nRoba4 := nRoba5 := nRoba6 := nUkRoba := nUkIznos := 0
   nIzR1 := nIzR2 := nIzR3 := nIzR4 := nIzR5 := nIzR6 := 0
   cNazRJ := Ocitaj( F_RJ, cIdRj, "TRIM(naz)" )

   DO WHILE !Eof() .AND. cIdRj == Left( IDROBA, 2 )

      IF &aUsl1; nRoba1 += kolicina; nIzR1 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE ); ENDIF
      IF &aUsl2; nRoba2 += kolicina; nIzR2 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE ); ENDIF
      IF &aUsl3; nRoba3 += kolicina; nIzR3 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE ); ENDIF
      IF &aUsl4; nRoba4 += kolicina; nIzR4 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE ); ENDIF
      IF &aUsl5; nRoba5 += kolicina; nIzR5 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE ); ENDIF
      IF &aUsl6; nRoba6 += kolicina; nIzR6 += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE ); ENDIF
      IF &( aUsl1 + ".or." + aUsl2 + ".or." + aUsl3 + ".or." + ;
            aUsl4 + ".or." + aUsl5 + ".or." + aUsl6 )
         nUkIznos += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE )
      ENDIF

      SKIP 1

   ENDDO

   nPCR1 := Round( IF( nRoba1 <> 0, nIzR1 / nRoba1, 0 ), 2 )
   nPCR2 := Round( IF( nRoba2 <> 0, nIzR2 / nRoba2, 0 ), 2 )
   nPCR3 := Round( IF( nRoba3 <> 0, nIzR3 / nRoba3, 0 ), 2 )
   nPCR4 := Round( IF( nRoba4 <> 0, nIzR4 / nRoba4, 0 ), 2 )
   nPCR5 := Round( IF( nRoba5 <> 0, nIzR5 / nRoba5, 0 ), 2 )
   nPCR6 := Round( IF( nRoba6 <> 0, nIzR6 / nRoba6, 0 ), 2 )

   nUkRoba := nRoba1 + nRoba2 + nRoba3 + nRoba4 + nRoba5 + nRoba6
   nPCRU := Round( IF( nUkRoba <> 0, nUkIznos / nUkRoba, 0 ), 2 )

   SKIP -1

   RETURN .T.
// }


/*! \fn FSvaki3()
 *  \brief
 */
FUNCTION FSvaki3()

   // {

   RETURN
// }



/*! \fn rpt_sp_fakture_usluga()
 *  \brief Pregled faktura usluga za kupca
 *  \brief Izvjestaj specifican za runik
 */

FUNCTION rpt_sp_fakture_usluga()

   // {
   O_PARTN
   O_FAKT

   cVarijanta := "1"               // 1 - sa porezom i rabatom
   // 2 - bez     - ll -
   cIdFirma := Space( 6 )
   gZaokP4 := 2
   qqUsluge := "U;" + Space( 58 )
   dDatOd := CToD( "" ); dDatDo := Date(); gOstr := "D"
   PRIVATE aUsl1

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo )
   RPar( "F7", @cIdFirma )
   RPar( "F8", @qqUsluge )

   cIdFirma := PadR( cIdFirma, 6 )
   qqUsluge := PadR( qqUsluge, 60 )

   Box(, 11, 70 )
   DO WHILE .T.

      @ m_X + 2, m_Y + 2 SAY "Uslov za usluge (po sifri)" GET qqUsluge PICT "@!S30"

      @ m_X + 4, m_Y + 2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ) } PICT "@!S30"

      @ m_X + 6, m_Y + 2 SAY "Za period od" GET dDatOD
      @ m_X + 6, Col() + 2 SAY "do" GET dDatDo

      @ m_X + 8, m_y + 2 SAY "Varijanta ( 1-sa por.i rab. , 2-bez por.i rab. ) ? " GET cVarijanta VALID cVarijanta $ "12" PICT "9"
      @ m_X + 9, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"
      @ m_X + 10, m_y + 2 SAY "Zaokruzivanje na (br.decimala)" GET gZaokP4  PICT "9"

      read; ESC_BCR
      aUsl1 := Parsiraj( qqUsluge, "IDROBA" )
      IF aUsl1 <> NIL
         EXIT
      ENDIF
   ENDDO
   BoxC()

   Params2()
   // qqKupac:=trim(qqKupac)
   qqUsluge := Trim( qqUsluge )

   WPar( "d1", dDatOd ) ; WPar( "d2", dDatDo )
   WPar( "F7", cIdFirma )
   WPar( "F8", qqUsluge )

   SELECT params; USE

   SELECT FAKT
   cTMPFAKT := ""
   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "DTOS(DATDOK)+IDTIPDOK+BRDOK"
   cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. ( EMPTY(cIdFirma) .or. cIdFirma==IDPARTNER ).and." + aUsl1
   INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt Eval( TekRec() ) EVERY 1
   BoxC()

   GO TOP
   IF Eof(); Msg( "Ne postoje trazeni podaci...", 6 ); closeret; ENDIF

   START PRINT CRET

   PRIVATE nUkKol := 0, nUkIznos := 0
   PRIVATE cIdTipDok := "", cBrDok := "", dDatum := CToD( "" )

   aKol := { { "DATUM",   {|| DToC( dDatum )            }, .F., "C", 12, 0, 1, 1 }, ;
      { "TIP DOKUM.",   {|| cIdTipDok               }, .F., "C", 12, 0, 1, 2 }, ;
      { "BROJ DOKUMENTA", {|| cbrdok                  }, .F., "C", 20, 0, 1, 3 }, ;
      { "VRIJEDNOST",   {|| Round( nUkIznos, gZaokP4 ) }, .T., "N", 20, 2, 1, 4 } }

   P_12CPI
   ?
   ?? Space( gnLMarg ); ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg ); IspisFirme( "" )
   ? Space( gnLMarg ); ?? "KUPAC: " + IF( Empty( cIdFirma ), "SVI", cIdFirma + " " + Ocitaj( F_PARTN, cIdFirma, "naz" ) )

   StampaTabele( aKol, {|| FSvaki4() },, gTabela,, ;
      , "Fakture usluga - pregled za kupca za period od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor4() }, IF( gOstr == "D",, -1 ),,,,, )
   FF
   ENDPRINT
   my_close_all_dbf(); MyFERASE( cTMPFAKT )

   CLOSERET

   RETURN
// }


/*! \fn FFor4()
 *  \brief
 */

STATIC FUNCTION FFor4()

   // {
   cIdTipDok := idtipdok; cBrDok := brdok; dDatum := datdok
   nUkKol := 0; nUkIznos := 0
   DO WHILE !Eof() .AND. datdok == dDatum .AND. idtipdok == cIdTipDok .AND. brdok == cBrDok
      nUkKol += kolicina
      IF cVarijanta == "1"
         nUkIznos += Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), ZAOKRUZENJE )
      ELSE
         nUkIznos += Round( kolicina * cijena * PrerCij(), ZAOKRUZENJE )
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.
// }

/*! \fn FSvaki4()
 */

STATIC FUNCTION FSvaki4()

   // {

   RETURN
// }


/*! \fn rpt_sp_pregled_poreza()
 *  \brief Pregled poreza po fakturama
 *  \brief Izvjestaj specifican za rudnik
 */
FUNCTION rpt_sp_pregled_poreza()

   // {
   O_PARTN
   O_FAKT

   cIdFirma := Space( 6 )
   qqPorez1 := 10
   qqPorez2 := 15
   qqPorez3 := 20
   qqPorez4 := qqPorez5 := 0

   dDatOd := CToD( "" ); dDatDo := Date(); gOstr := "D"

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()

   RPar( "d1", @dDatOd ); RPar( "d2", @dDatDo ); RPar( "F7", @cIdFirma )
   RPar( "o7", @qqPorez1 ); RPar( "o8", @qqPorez2 ); RPar( "o9", @qqPorez3 )
   RPar( "oA", @qqPorez4 ); RPar( "oB", @qqPorez5 )

   cIdFirma := PadR( cIdFirma, 6 )

   Box(, 12, 70 )
   DO WHILE .T.

      @ m_X + 1, m_Y + 19 SAY "(%)"

      @ m_X + 2, m_Y + 2 SAY "Iznos poreza 1" GET qqPorez1  PICT "999.99"
      @ m_X + 3, m_Y + 2 SAY "Iznos poreza 2" GET qqPorez2  PICT "999.99"
      @ m_X + 4, m_Y + 2 SAY "Iznos poreza 3" GET qqPorez3  PICT "999.99"
      @ m_X + 5, m_Y + 2 SAY "Iznos poreza 4" GET qqPorez4  PICT "999.99"
      @ m_X + 6, m_Y + 2 SAY "Iznos poreza 5" GET qqPorez5  PICT "999.99"

      @ m_X + 8, m_Y + 2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID {|| Empty( cIdFirma ) .OR. P_Firma( @cIdFirma ) } PICT "@!S30"

      @ m_X + 9, m_Y + 2 SAY "Za period od" GET dDatOD
      @ m_X + 9, Col() + 2 SAY "do" GET dDatDo

      @ m_X + 11, m_y + 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr $ "DN" PICT "@!"

      read; ESC_BCR
      EXIT
   ENDDO
   BoxC()

   Params2()
   // qqKupac:=trim(qqKupac)

   WPar( "d1", dDatOd ) ; WPar( "d2", dDatDo )
   WPar( "F7", cIdFirma )
   WPar( "o7", qqPorez1 ); WPar( "o8", qqPorez2 ); WPar( "o9", qqPorez3 )
   WPar( "oA", qqPorez4 ); WPar( "oB", qqPorez5 )

   SELECT params; USE

   SELECT FAKT
   cTMPFAKT := ""

   Box(, 2, 30 )
   nSlog := 0; nUkupno := RECCOUNT2()
   cSort1 := "DTOS(DATDOK)+IDTIPDOK+BRDOK"
   cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. ( EMPTY(cIdFirma) .or. cIdFirma==IDPARTNER ) .and. ( porez==qqPorez1.and.qqPorez1>0 .or. porez==qqPorez2.and.qqPorez2>0 .or. porez==qqPorez3.and.qqPorez3>0 .or. porez==qqPorez4.and.qqPorez4>0 .or. porez==qqPorez5.and.qqPorez5>0 )"
   INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt Eval( TekRec() ) EVERY 1
   BoxC()

   GO TOP
   IF Eof(); Msg( "Ne postoje trazeni podaci...", 6 ); closeret; ENDIF

   START PRINT CRET

   PRIVATE cIdTipDok := "", cBrDok := "", dDatum := CToD( "" )
   PRIVATE nPor1 := nPor2 := nPor3 := nPor4 := nPor5 := nUkPor := 0
   PRIVATE nKPor1 := nKPor2 := nKPor3 := nKPor4 := nKPor5 := nKUkPor := 0

   aKol := { { "DATUM", {|| dDatum       }, .F., "D", 8, 0, 1, 1 }, ;
      { "TIP DOKUM.", {|| cIdTipDok    }, .F., "C", 10, 0, 1, 2 }, ;
      { "BROJ DOKUMENTA", {|| cbrdok       }, .F., "C", 14, 0, 1, 3 } }

   i := 3
   IF qqPorez1 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez1, 6, 2 ) + "%", {|| nPor1 }, .T., "N", 13, 2, 1, ++i } )
   ENDIF
   IF qqPorez2 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez2, 6, 2 ) + "%", {|| nPor2 }, .T., "N", 13, 2, 1, ++i } )
   ENDIF
   IF qqPorez3 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez3, 6, 2 ) + "%", {|| nPor3 }, .T., "N", 13, 2, 1, ++i } )
   ENDIF
   IF qqPorez4 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez4, 6, 2 ) + "%", {|| nPor4 }, .T., "N", 13, 2, 1, ++i } )
   ENDIF
   IF qqPorez5 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez5, 6, 2 ) + "%", {|| nPor5 }, .T., "N", 13, 2, 1, ++i } )
   ENDIF
   AAdd( aKol, { "UKUPNO POREZI", {|| nUkPor }, .T., "N", 13, 2, 1, ++i } )

   IF qqPorez1 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez1, 6, 2 ) + "%", {|| nKPor1 }, .F., "N", 13, 2, 1, ++i } )
      AAdd( aKol, { "KUMULATIVNO", {|| "#" }, .F., "N", 13, 2, 2, i } )
   ENDIF
   IF qqPorez2 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez2, 6, 2 ) + "%", {|| nKPor2 }, .F., "N", 13, 2, 1, ++i } )
      AAdd( aKol, { "KUMULATIVNO", {|| "#" }, .F., "N", 13, 2, 2, i } )
   ENDIF
   IF qqPorez3 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez3, 6, 2 ) + "%", {|| nKPor3 }, .F., "N", 13, 2, 1, ++i } )
      AAdd( aKol, { "KUMULATIVNO", {|| "#" }, .F., "N", 13, 2, 2, i } )
   ENDIF
   IF qqPorez4 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez4, 6, 2 ) + "%", {|| nKPor4 }, .F., "N", 13, 2, 1, ++i } )
      AAdd( aKol, { "KUMULATIVNO", {|| "#" }, .F., "N", 13, 2, 2, i } )
   ENDIF
   IF qqPorez5 > 0
      AAdd( aKol, { "POREZ " + Str( qqPorez5, 6, 2 ) + "%", {|| nKPor5 }, .F., "N", 13, 2, 1, ++i } )
      AAdd( aKol, { "KUMULATIVNO", {|| "#" }, .F., "N", 13, 2, 2, i } )
   ENDIF
   AAdd( aKol, { "UKUPNO POREZI", {|| nKUkPor }, .F., "N", 13, 2, 1, ++i } )
   AAdd( aKol, { "KUMULATIVNO", {|| "#" }, .F., "N", 13, 2, 2, i } )

   ?
   P_12CPI
   ?? Space( gnLMarg ); ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg )
   IspisFirme( "" )
   ? Space( gnLMarg ); ?? "KUPAC: " + IF( Empty( cIdFirma ), "SVI", cIdFirma + " " + Ocitaj( F_PARTN, cIdFirma, "naz" ) )

   StampaTabele( aKol, {|| FSvaki5() },, gTabela,, ;
      , "Pregled poreza po fakturama za period od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor5() }, IF( gOstr == "D",, -1 ),,,,, )
   FF
   ENDPRINT
   my_close_all_dbf(); MyFERASE( cTMPFAKT )

   CLOSERET

   RETURN
// }


/*! \fn FFor5()
 *  \brief
 */

STATIC FUNCTION FFor5()

   // {
   cIdTipDok := IDTIPDOK; cBrDok := BRDOK; dDatum := DATDOK
   nPor1 := nPor2 := nPor3 := nPor4 := nPor5 := nUkPor := 0
   DO WHILE !Eof() .AND. datdok == dDatum .AND. idtipdok == cIdTipDok .AND. brdok == cBrDok
      IF qqPorez1 == Round( porez, 0 )
         nPor1 += Round( CIJENA * KOLICINA * PrerCij() * ( 1 -RABAT / 100 ) * POREZ / 100, ZAOKRUZENJE )
      ENDIF
      IF qqPorez2 == Round( porez, 0 )
         nPor2 += Round( CIJENA * KOLICINA * PrerCij() * ( 1 -RABAT / 100 ) * POREZ / 100, ZAOKRUZENJE )
      ENDIF
      IF qqPorez3 == Round( porez, 0 )
         nPor3 += Round( CIJENA * KOLICINA * PrerCij() * ( 1 -RABAT / 100 ) * POREZ / 100, ZAOKRUZENJE )
      ENDIF
      IF qqPorez4 == Round( porez, 0 )
         nPor4 += Round( CIJENA * KOLICINA * PrerCij() * ( 1 -RABAT / 100 ) * POREZ / 100, ZAOKRUZENJE )
      ENDIF
      IF qqPorez5 == Round( porez, 0 )
         nPor5 += Round( CIJENA * KOLICINA * PrerCij() * ( 1 -RABAT / 100 ) * POREZ / 100, ZAOKRUZENJE )
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1
   nPor1 := Round( nPor1, FIELD->zaokr )
   nPor2 := Round( nPor2, FIELD->zaokr )
   nPor3 := Round( nPor3, FIELD->zaokr )
   nPor4 := Round( nPor4, FIELD->zaokr )
   nPor5 := Round( nPor5, FIELD->zaokr )
   nUkPor := nPor1 + nPor2 + nPor3 + nPor4 + nPor5
   nKUkPor += nUkPor; nKPor1 += nPor1; nKPor2 += nPor2
   nKPor3  += nPor3;  nKPor4 += nPor4; nKPor5 += nPor5

   RETURN .T.
// }


/*! \fn FSvaki5()
 */
STATIC FUNCTION FSvaki5()

   // {

   RETURN
// }


/*! \fn FFor6()
 *  \brief
 */

STATIC FUNCTION FFor6()

   // {
   LOCAL nIznos := 0
   IF fSMark .AND. SkLoNMark( "ROBA", SiSiRo() )
      RETURN .F.
   ENDIF
   IF cVarSubTot == "1"
      IF PARTN->idops <> cIdOps .AND. Len( cIdOps ) > 0
         lSubTot6 := .T.
         cSubTot6 := cIdOps
      ENDIF
   ELSE
      IF SubStr( idpartner, 2, 2 ) <> SubStr( cIdPartner, 2, 2 ) .AND. Len( cIdPartner ) > 0
         lSubTot6 := .T.
         cSubTot6 := SubStr( cIdPartner, 2, 2 )
      ENDIF
   ENDIF
   cIdPartner := idpartner
   cIdOps := PARTN->idops
   nUkIznos := 0
   nOpor := nNeOpor := 0
   IF cVarSubTot == "1"
      cNPartnera := PARTN->( Trim( naz ) + ' ' + Trim( naz2 ) )
   ELSE
      cNPartnera := Ocitaj( F_PARTN, idpartner, "TRIM(naz)+' '+TRIM(naz2)" )
   ENDIF
   DO WHILE !Eof() .AND. idpartner == cIdPartner
      IF fSMark .AND. SkLoNMark( "ROBA", SiSiRo() ) // skip+loop gdje je roba->_M1_ != "*"
         SKIP 1; LOOP
      ENDIF
      nIznos := Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr )
      nUkIznos += nIznos
      SELECT ROBA; HSEEK PadR( Left( FAKT->idroba, gnDS ), Len( id ) )
      SELECT TARIFA; HSEEK ROBA->idtarifa; SELECT FAKT
      IF !Oporezovana()
         nNeOpor += nIznos
      ELSE
         nOpor   += nIznos
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.
// }


/*! \fn FSvaki6()
 *  \brief
 */

STATIC FUNCTION FSvaki6()
   RETURN


/*! \fn SubTot6()
 *  \brief
 */

STATIC FUNCTION SubTot6()

   LOCAL aVrati := { .F., "" }, cOps := "", cIdOpc := ""

   IF lSubTot6 .OR. Eof()
      IF cVarSubTot == "1"
         cIdOpc := IF( Eof(), cIdOps, cSubTot6 )
         cOps   := Trim( Ocitaj( F_OPS, cIdOpc, "naz" ) )
      ELSE
         cIdOpc := IF( Eof(), SubStr( cIdPartner, 2, 2 ), cSubTot6 )
         cOps   := IzFMKINI( "NOVINE", "NazivOpstine" + cIdOpc, "-", KUMPATH )
      ENDIF
      aVrati := { .T., "OPSTINA " + cIdOpc + "-" + cOps }
      lSubTot6 := .F.
   ENDIF

   RETURN aVrati


/*! \fn VRobPoIzd()
 *  \brief Vrijednost robe po izdavacima/dobavljacima
 */

FUNCTION VRobPoIzd()

   // {

   O_SIFK
   O_SIFV
   O_RJ
   O_ROBA
   O_TARIFA
   O_FAKT

   cTMPFAKT := ""

   cIdfirma := gFirma
   qqRoba := ""
   dDatOd := CToD( "" )
   dDatDo := Date()
   qqTipdok := "  "

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "c1", @cIdFirma ); RPar( "c2", @qqRoba )
   RPar( "c8", @qqTipDok )
   RPar( "d1", @dDatOd ) ; RPar( "d2", @dDatDo )
   qqRoba := PadR( qqRoba, 80 )

   Box(, 5, 75 )
   DO WHILE .T.
      IF gNW $ "DR"
         @ m_x + 1, m_y + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cidfirma == gFirma .OR. P_RJ( @cIdFirma ) }
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Roba   "  GET qqRoba   PICT "@!S40"
      @ m_x + 4, m_y + 2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
      @ m_x + 5, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 5, Col() + 1 SAY "do"  GET dDatDo
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqRoba, "IDROBA" )
      IF aUsl1 <> NIL; EXIT; ENDIF
   ENDDO
   BoxC()

   SELECT params
   qqRoba := Trim( qqRoba )
   WPar( "c1", cIdFirma ); WPar( "c2", qqRoba )
   WPar( "c8", qqTipDok )
   WPar( "d1", dDatOd ); WPar( "d2", dDatDo )
   USE

   fSMark := .F.
   IF Right( qqRoba, 1 ) = "*"
      // izvrsena je markacija robe ..
      fSMark := .T.
   ENDIF

   SELECT FAKT

   cSort1 := "idroba"
   cFilt1 := aUsl1
   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilt1 += ".and. DatDok>=" + cm2str( dDatOd ) + ".and. DatDok<=" + cm2str( dDatDo )
   ENDIF
   IF !Empty( qqTipDok )
      cFilt1 += ".and. IDTIPDOK==" + cm2str( qqTipDok )
   ENDIF
   IF !Empty( cIdFirma )
      cFilt1 += ".and. IDFIRMA==" + cm2str( cIdFirma )
   ENDIF

   INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt1

   START PRINT CRET

   PRIVATE cIdRoba := "", cNRobe := "", nUkIznos := 0, lSubTot7 := .F., cSubTot7 := ""
   gOstr := "D"
   nOpor := nNeOpor := 0

   nPP7 := Val( IzFMKINI( "NOVINE", "USifriRobe_PocPozSifIzdavaca", "1", KUMPATH ) )
   nDS7 := Val( IzFMKINI( "NOVINE", "USifriRobe_DuzinaSifIzdavaca", "3", KUMPATH ) )

   aKol := { { "SIFRA", {|| cIdRoba                }, .F., "C", 10, 0, 1, 1 }, ;
      { "IZDANJE", {|| cNRobe                 }, .F., "C", 50, 0, 1, 2 }, ;
      { "Neoporezovani", {|| Round( nNeOpor, gFZaok ) }, .T., "N", 13, 2, 1, 3 }, ;
      { "iznos", {|| "#"                    }, .F., "C", 13, 0, 2, 3 }, ;
      { "Oporezovani", {|| Round( nOpor, gFZaok )   }, .T., "N", 13, 2, 1, 4 }, ;
      { "iznos", {|| "#"                    }, .F., "C", 13, 0, 2, 4 }, ;
      { "UKUPNO IZNOS", {|| Round( nUkIznos, gFZaok ) }, .T., "N", 13, 2, 1, 5 } }

   ?
   P_12CPI
   ?? Space( gnLMarg )
   ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg )
   IspisFirme( "" )
   ? Space( gnLMarg )
   ?? "RJ: " + IF( Empty( cIdFirma ), "SVE", cIdFirma )

   StampaTabele( aKol, {|| FSvaki7() },, gTabela,, ;
      , "Vrijednost isporuke robe po izdavacima za period od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor7() }, IF( gOstr == "D",, -1 ),,, {|| SubTot7() },, )

   FF
   ENDPRINT
   my_close_all_dbf(); MyFERASE( cTMPFAKT )
   CLOSERET

   RETURN


/*! \fn FFor7()
 *  \brief
 */

STATIC FUNCTION FFor7()

   // {
   LOCAL nIznos := 0
   IF fSMark .AND. SkLoNMark( "ROBA", SiSiRo() ) // skip+loop gdje je roba->_M1_ != "*"
      RETURN .F.
   ENDIF
   IF SubStr( idroba, nPP7, nDS7 ) <> SubStr( cIdRoba, nPP7, nDS7 ) .AND. Len( cIdRoba ) > 0
      lSubTot7 := .T.
      cSubTot7 := SubStr( cIdRoba, nPP7, nDS7 )
   ENDIF
   cIdRoba := Left( idroba, gnDS )
   nUkIznos := 0
   nOpor := nNeOpor := 0
   cNRobe := Ocitaj( F_ROBA, PadR( cidroba, Len( idroba ) ), "TRIM(naz)" )
   DO WHILE !Eof() .AND. Left( idroba, gnDS ) == cIdRoba
      nIznos := Round( kolicina * cijena * PrerCij() * ( 1 -rabat / 100 ) * ( 1 + porez / 100 ), FIELD->zaokr )
      nUkIznos += nIznos
      SELECT ROBA; HSEEK PadR( Left( FAKT->idroba, gnDS ), Len( id ) )
      SELECT TARIFA; HSEEK ROBA->idtarifa; SELECT FAKT
      IF TARIFA->opp = 0 .AND. TARIFA->ppp = 0 .AND. TARIFA->zpp = 0
         nNeOpor += nIznos
      ELSE
         nOpor   += nIznos
      ENDIF
      SKIP 1
   ENDDO
   SKIP -1

   RETURN .T.
// }


/*! \fn FSvaki7()
 */

STATIC FUNCTION FSvaki7()

   // {

   RETURN
// }



/*! \fn SubTot7()
 *  \brief
 */

STATIC FUNCTION SubTot7()

   // {
   LOCAL aVrati := { .F., "" }, cIzd := "", cIdIzd := ""
   IF lSubTot7 .OR. Eof()
      cIdIzd := IF( Eof(), SubStr( cIdRoba, nPP7, nDS7 ), cSubTot7 )
      cIzd := IzFMKINI( "NOVINE", "NazivIzdavaca" + cIdIzd, "-", KUMPATH )
      aVrati := { .T., "IZDAVAC " + cIdIzd + "-" + cIzd }
      lSubTot7 := .F.
   ENDIF

   RETURN aVrati
// }


/*! \fn PorPoOps()
 *  \brief Porezi po tarifama i po opstinama
 */

FUNCTION PorPoOps()

   O_SIFK
   O_SIFV
   O_ROBA
   O_TARIFA
   O_RJ
   O_PARTN
   O_FAKT

   cTMPFAKT := ""

   cIdfirma := gFirma
   qqRoba := ""
   dDatOd := CToD( "" )
   dDatDo := Date()
   qqTipdok := "  "

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "c1", @cIdFirma ); RPar( "c2", @qqRoba )
   RPar( "c8", @qqTipDok )
   RPar( "d1", @dDatOd ) ; RPar( "d2", @dDatDo )
   qqRoba := PadR( qqRoba, 80 )

   Box(, 5, 75 )
   DO WHILE .T.
      IF gNW $ "DR"
         @ m_x + 1, m_y + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cidfirma == gFirma .OR. P_RJ( @cIdFirma ) }
      ELSE
         @ m_x + 1, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF
      @ m_x + 2, m_y + 2 SAY "Roba   "  GET qqRoba   PICT "@!S40"
      @ m_x + 4, m_y + 2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
      @ m_x + 5, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 5, Col() + 1 SAY "do"  GET dDatDo
      READ; ESC_BCR
      aUsl1 := Parsiraj( qqRoba, "IDROBA" )
      IF aUsl1 <> NIL; EXIT; ENDIF
   ENDDO
   BoxC()

   SELECT params
   qqRoba := Trim( qqRoba )
   WPar( "c1", cIdFirma ); WPar( "c2", qqRoba )
   WPar( "c8", qqTipDok )
   WPar( "d1", dDatOd ); WPar( "d2", dDatDo )
   USE

   fSMark := .F.
   IF Right( qqRoba, 1 ) = "*"
      // izvrsena je markacija robe ..
      fSMark := .T.
   ENDIF

   SELECT FAKT

   cSort1 := "idpartner"
   cFilt1 := aUsl1
   IF !Empty( dDatOd ) .OR. !Empty( dDatDo )
      cFilt1 += ".and. DatDok>=" + cm2str( dDatOd ) + ".and. DatDok<=" + cm2str( dDatDo )
   ENDIF
   IF !Empty( qqTipDok )
      cFilt1 += ".and. IDTIPDOK==" + cm2str( qqTipDok )
   ENDIF
   IF !Empty( cIdFirma )
      cFilt1 += ".and. IDFIRMA==" + cm2str( cIdFirma )
   ENDIF

   INDEX ON &cSort1 TO ( cTMPFAKT := TMPFAKT() ) FOR &cFilt1

   // kreiranje pomocne izvjestajne baze
   // ----------------------------------
   aDbf := {  { "OPS", "C", 10, 0 }, ;
      { "POR", "C", 10, 0 }, ;
      { "PPP", "N", 17, 8 }, ;
      { "PPU", "N", 17, 8 }, ;
      { "PP", "N", 17, 8 }, ;
      { "IZNOS", "N", 17, 8 } ;
      }
   dbcreate2( PRIVPATH + "por", aDbf )
   O_POR   // select 95
   INDEX  ON BRISANO TAG "BRISAN"
   INDEX  ON OPS + POR  TAG "1" ;  SET ORDER TO TAG "1"
   SELECT FAKT
   GO TOP
   DO WHILE !Eof()
      IF fSMark .AND. SkLoNMark( "ROBA", SiSiRo() ) // skip+loop gdje je roba->_M1_ != "*"
         SKIP 1; LOOP
      ENDIF
      aPor := {}
      cOps := SubStr( idpartner, 2, 2 )
      DO WHILE !Eof() .AND. cOps == SubStr( idpartner, 2, 2 )
         IF fSMark .AND. SkLoNMark( "ROBA", SiSiRo() ) // skip+loop gdje je roba->_M1_ != "*"
            SKIP 1; LOOP
         ENDIF
         SELECT ROBA; HSEEK PadR( Left( FAKT->idroba, gnDS ), Len( id ) )
         SELECT TARIFA; HSEEK ROBA->idtarifa; SELECT FAKT

         IF IzFMKINI( "POREZI", "PPUgostKaoPPU", "D" ) == "D"
            n0 := ( cijena * Koef( DinDem ) * kolicina ) / ( 1 + tarifa->zpp / 100 + tarifa->ppp / 100 ) / ( 1 + tarifa->opp / 100 )
            n1 := n0 * tarifa->opp / 100
            n2 := n0 * ( 1 + tarifa->opp / 100 ) * tarifa->ppp / 100
            n3 := n0 * ( 1 + tarifa->opp / 100 ) * tarifa->zpp / 100
         ELSE
            n0 := ( cijena * Koef( DinDem ) * kolicina ) / ( ( 1 + tarifa->opp / 100 ) * ( 1 + tarifa->ppp / 100 ) + tarifa->zpp / 100 )
            n1 := n0 * tarifa->opp / 100
            n2 := n0 * ( 1 + tarifa->opp / 100 ) * tarifa->ppp / 100
            n3 := n0 * tarifa->zpp / 100
         ENDIF

         IF Len( aPor ) < 1
            AAdd( aPor, { TARIFA->id, kolicina * cijena, n1, n2, n3 } )
         ELSE
            nPom := AScan( aPor, {| x| x[ 1 ] == TARIFA->id } )
            IF nPom > 0
               aPor[ nPom, 2 ] += kolicina * cijena
               aPor[ nPom, 3 ] += n1
               aPor[ nPom, 4 ] += n2
               aPor[ nPom, 5 ] += n3
            ELSE
               AAdd( aPor, { TARIFA->id, kolicina * cijena, n1, n2, n3 } )
            ENDIF
         ENDIF
         SKIP 1
      ENDDO
      SELECT POR
      nU1 := 0
      nU2 := 0
      nU3 := 0
      nU4 := 0
      FOR i := 1 TO Len( aPor )
         nU1 += aPor[ i, 2 ]
         nU2 += aPor[ i, 3 ]
         nU3 += aPor[ i, 4 ]
         nU4 += aPor[ i, 5 ]
         APPEND BLANK
         REPLACE ops WITH cOps, por WITH aPor[ i, 1 ], iznos WITH aPor[ i, 2 ], ;
            ppp WITH aPor[ i, 3 ], ppu WITH aPor[ i, 4 ], pp  WITH aPor[ i, 5 ]
         HSEEK "UKUPNO  T." + aPor[ i, 1 ]
         IF Found()
            REPLACE iznos WITH iznos + aPor[ i, 2 ], ;
               ppp   WITH ppp + aPor[ i, 3 ], ;
               ppu   WITH ppu + aPor[ i, 4 ], ;
               pp    WITH pp + aPor[ i, 5 ]
         ELSE
            APPEND BLANK
            REPLACE ops WITH "UKUPNO  T.", por WITH aPor[ i, 1 ], iznos WITH aPor[ i, 2 ], ;
               ppp WITH aPor[ i, 3 ], ppu WITH aPor[ i, 4 ], pp  WITH aPor[ i, 5 ]
         ENDIF
      NEXT
      APPEND BLANK
      REPLACE ops   WITH cOps, ;
         por   WITH "ÄUKUPNO", ;
         iznos WITH nU1, ;
         ppp   WITH nU2, ;
         ppu   WITH nU3, ;
         pp    WITH nU4
      HSEEK "UKUPNO SVE"
      IF Found()
         REPLACE iznos WITH iznos + nU1, ;
            ppp   WITH ppp   + nU2, ;
            ppu   WITH ppu   + nU3, ;
            pp    WITH pp    + nU4
      ELSE
         APPEND BLANK
         REPLACE ops   WITH "UKUPNO SVE", ;
            por   WITH "", ;
            iznos WITH nU1, ;
            ppp   WITH nU2, ;
            ppu   WITH nU3, ;
            pp    WITH nU4
      ENDIF
      SELECT FAKT
   ENDDO
   // -----------------------------------------------

   SELECT POR
   GO TOP

   START PRINT CRET

   PRIVATE cIdPartner := "", cNPartnera := "", nUkIznos := 0
   gOstr := "D"
   nOpor := nNeOpor := 0

   aKol := { { "OPSTINA", {|| ops                 }, .F., "C", 10, 0, 1, 1 }, ;
      { "TARIFA", {|| por                 }, .F., "C", 10, 0, 1, 2 }, ;
      { "PPP", {|| Str( ppp, 13, 2 )       }, .F., "C", 13, 0, 1, 3 }, ;
      { "PPU", {|| Str( ppu, 13, 2 )       }, .F., "C", 13, 0, 1, 4 }, ;
      { "PP", {|| Str( pp, 13, 2 )       }, .F., "C", 13, 0, 1, 5 }, ;
      { "MPV", {|| Str( iznos, 13, 2 )     }, .F., "C", 13, 0, 1, 6 } }

   ?
   P_12CPI
   ?? Space( gnLMarg )
   ?? "FAKT: Izvjestaj na dan", Date()
   ? Space( gnLMarg )
   IspisFirme( "" )
   ? Space( gnLMarg )
   ?? "RJ: " + IF( Empty( cIdFirma ), "SVE", cIdFirma )

   SELECT POR

   StampaTabele( aKol, {|| FSvaki8() },, gTabela,, ;
      , "Porezi po tarifama i opstinama za period od " + DToC( ddatod ) + " do " + DToC( ddatdo ), ;
      {|| FFor8()},IF(gOstr=="D",,-1),,,,,)

   ENDPRINT

   my_close_all_dbf()
   MyFERASE( cTMPFAKT )
   CLOSERET

   RETURN


STATIC FUNCTION FFor8()

   RETURN .T.


/*! \fn FSvaki8()
 *  \brief
 */

STATIC FUNCTION FSvaki8()

   // {
   IF por = "ÄUKUPNO"
      RETURN "PODVUCI="
   ENDIF
   SKIP 1
   IF por = "ÄUKUPNO" .OR. ops = "UKUPNO SVE"
      SKIP -1
      RETURN "PODVUCI "
   ELSE
      SKIP -1
   ENDIF

   RETURN ( NIL )
// }


/*! \fn SiSiRo()
 *  \brief Sirina sifre robe
 *  \brief specificno za opresu - novine
 */

FUNCTION SiSiRo()

   LOCAL cSR := FAKT->idroba

   RETURN cSR



/*! \fn KarticaKons()
 *  \brief Kartica konsignacije
 */

FUNCTION KarticaKons()

   // {
   LOCAL cidfirma, nRezerv, nRevers
   LOCAL nul, nizl, nRbr, nCol1 := 0, cKolona, cBrza := "N"
   LOCAL lpickol := "@Z " + pickol

   PRIVATE m := ""

   O_SIFK
   O_SIFV
   O_PARTN
   O_ROBA
   O_TARIFA
   O_RJ
   O_FAKT_DOKS; O_FAKT
   IF fId_J
      SET ORDER TO TAG "3J" // idroba_J+Idroba+dtos(datDok)
   ELSE
      SET ORDER TO TAG "3" // idroba+dtos(datDok)
   ENDIF

   cIdfirma := gFirma
   PRIVATE qqRoba := ""
   PRIVATE dDatOd := CToD( "" )
   PRIVATE dDatDo := Date()
   PRIVATE qqPartn := Space( 60 )

   Box( "#KARTICA ISPORUCENE KONSIGNACIONE ROBE", 17, 60 )

   cOstran := IzFMKINI( "FAKT", "OstraniciKarticu", "N", SIFPATH )

   O_PARAMS
   PRIVATE cSection := "5", cHistory := " "; aHistory := {}
   Params1()
   RPar( "c1", @cIdFirma )
   RPar( "c9", @qqPartn )
   RPar( "d1", @dDatOd )
   RPar( "d2", @dDatDo )

   qqPartn := PadR( qqPartn, 60 )

   PRIVATE cTipVPC := "1"

   PRIVATE ck1 := cK2 := Space( 4 )   // atributi

   DO WHILE .T.
      @ m_x + 1, m_y + 2 SAY "Brza kartica (D/N)" GET cBrza PICT "@!" VALID cBrza $ "DN"
      READ
      IF gNW $ "DR"
         @ m_x + 2, m_y + 2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| Empty( cIdFirma ) .OR. cidfirma == gFirma .OR. P_RJ( @cIdFirma ) }
      ELSE
         @ m_x + 2, m_y + 2 SAY "Firma: " GET cIdFirma valid {|| P_Firma( @cIdFirma ), cidfirma := Left( cidfirma, 2 ), .T. }
      ENDIF

      IF cBrza == "D"
         RPar( "c3", @qqRoba )
         qqRoba := PadR( qqRoba, 10 )
         IF fID_J
            @ m_x + 3, m_y + 2 SAY "Roba " GET qqRoba PICT "@!" valid {|| P_Roba( @qqRoba ), qqRoba := roba->id_j, .T. }
         ELSE
            @ m_x + 3, m_y + 2 SAY "Roba " GET qqRoba PICT "@!" VALID P_Roba( @qqRoba )
         ENDIF
      ELSE
         RPar( "c2", @qqRoba )
         qqRoba := PadR( qqRoba, 60 )
         @ m_x + 3, m_y + 2 SAY "Roba " GET qqRoba PICT "@!S40"
      ENDIF

      @ m_x + 4, m_y + 2 SAY "Od datuma "  GET dDatOd
      @ m_x + 4, Col() + 1 SAY "do"  GET dDatDo
      IF gVarC $ "12"
         @ m_x + 7, m_y + 2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  GET cTipVpc PICT "@!" VALID cTipVPC $ "12"
      ENDIF
      @ m_x + 8, m_y + 2 SAY "Partneri kupci (prazno - svi)"  GET qqPartn   PICT "@!S20"
      IF fakt->( FieldPos( "K1" ) ) <> 0 .AND. gDK1 == "D"
         @ m_x + 9, m_y + 2 SAY "K1" GET  cK1 PICT "@!"
         @ m_x + 10, m_y + 2 SAY "K2" GET  cK2 PICT "@!"
      ENDIF

      IF cBrza == "N"
         @ m_x + 15, m_y + 2 SAY "Svaka kartica na novu stranicu? (D/N)"  GET cOstran VALID cOstran $ "DN" PICT "@!"
      ELSE
         cOstran := "N"
      ENDIF

      read; ESC_BCR

      aUsl2 := Parsiraj( qqPartn, "IdPartner" )

      IF fID_J .AND. cBrza == "D"
         qqRoba := roba->( ID_J + ID )
      ENDIF

      cSintetika := IzFmkIni( "FAKT", "Sintet", "N" )
      IF cSintetika == "D" .AND.  IF( cBrza == "D", ROBA->tip == "S", .T. )
         @ m_x + 17, m_y + 2 SAY "Sinteticki prikaz? (D/N) " GET  cSintetika PICT "@!" VALID cSintetika $ "DN"
      ELSE
         cSintetika := "N"
      ENDIF
      read; ESC_BCR

      IF cBrza == "N"
         IF fID_J
            aUsl1 := Parsiraj( qqRoba, "IdRoba_J" )
         ELSE
            aUsl1 := Parsiraj( qqRoba, "IdRoba" )
         ENDIF
      ENDIF
      IF IF( cBrza == "N", aUsl1 <> NIL, .T. ) .AND. aUsl2 <> NIL
         EXIT
      ENDIF
   ENDDO
   m := "---- ------------------ -------- ------ " + Replicate( "-", 20 ) + ;
      " ----------- ----------- ----------- ----------- ----- -----------"
   Params2()
   qqPartn := Trim( qqPartn )
   WPar( "c1", cIdFirma )
   WPar( "c9", qqPartn ); WPar( "d1", dDatOd ); WPar( "d2", dDatDo )
   qqRoba := Trim( qqRoba )
   IF cBrza == "D"
      WPar( "c3", qqRoba )
   ELSE
      WPar( "c2", qqRoba )
   ENDIF
   SELECT params; USE

   BoxC()

   fSMark := .F.
   IF Right( qqRoba, 1 ) = "*"
      // izvrsena je markacija robe ..
      fSMark := .T.
   ENDIF

   O_FAKT_DOKS  // otvori datoteku dokumenata

   SELECT FAKT

   PRIVATE cFilt1 := ""
   cFilt1 := IF( cBrza == "N", aUsl1, ".t." ) + IF( Empty( dDatOd ), "", ".and.DATDOK>=" + cm2str( dDatOd ) ) + ;
      IF( Empty( dDatDo ), "", ".and.DATDOK<=" + cm2str( dDatDo ) ) + ".and. IDTIPDOK='1'" + ;
      ".and. left(serbr,1)<>'*'"

   IF !Empty( cIdFirma )
      cFilt1 += ( ".and. IDFIRMA==" + cm2str( cIdFirma ) )
   ENDIF
   IF !Empty( qqPartn )
      cFilt1 += ( ".and." + aUsl2 )
   ENDIF

   cFilt1 := StrTran( cFilt1, ".t..and.", "" )
   IF !( cFilt1 == ".t." )
      SET FILTER TO &cFilt1
   ELSE
      SET FILTER TO
   ENDIF

   IF cBrza == "N"
      GO TOP
      EOF CRET
   ELSE
      SEEK qqRoba
   ENDIF

   START PRINT CRET
   ?
   P_12CPI
   ?? Space( gnLMarg )
   ?? "FAKT: Kartica isporuke robe na dan",  Date(),  "      za period od", dDatOd, "-", dDatDo
   ? Space( gnLMarg ); IspisFirme( cidfirma )
   IF !Empty( qqRoba )
      ? Space( gnLMarg )
      IF !Empty( qqRoba ) .AND. cBrza = "N"
         ?? "Uslov za artikal:", qqRoba
      ENDIF
   ENDIF
   ?
   IF cTipVPC == "2" .AND.  roba->( FieldPos( "vpc2" ) <> 0 )
      ? Space( gnlmarg ); ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: " + cTipVPC
   ENDIF
   IF !Empty( cK1 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K1:", ck1
   ENDIF
   IF !Empty( cK2 )
      ?
      ? Space( gnlmarg ), "- Roba sa osobinom K2:", ck2
   ENDIF

   _cijena := 0
   _cijena2 := 0
   nRezerv := nRevers := 0

   qqPartn := Trim( qqPartn )
   IF !Empty( qqPartn )
      ?
      ? Space( gnlmarg ), "- Prikaz za partnere obuhvacene sljedecim uslovom (sifre):"
      ? Space( gnlmarg ), " ", qqPartn
      ?
   ENDIF

   P_COND

   nStrana := 1
   lPrviProlaz := .T.

   DO WHILE !Eof()
      IF cBrza == "D"
         IF qqRoba <> iif( fID_j, IdRoba_J + IdRoba, IdRoba ) .AND. ;
               IF( cSintetika == "D", Left( qqRoba, gnDS ) != Left( IdRoba, gnDS ), .T. )
            // tekuci slog nije zeljena kartica
            EXIT
         ENDIF
      ENDIF
      IF fId_j
         cIdRoba := IdRoba_J + IdRoba
      ELSE
         cIdRoba := IdRoba
      ENDIF
      nUl := nIzl := nIznos := 0
      nRezerv := nRevers := 0
      nRbr := 0
      nIzn := 0

      IF fId_j
         NSRNPIdRoba( SubStr( cIdRoba, 11 ), cSintetika == "D" )
      ELSE
         NSRNPIdRoba( cIdRoba, cSintetika == "D" )
      ENDIF
      SELECT FAKT

      IF fSMark .AND. SkLoNMark( "ROBA", SiSiRo() ) // skip & loop gdje je roba->_M1_ != "*"
         skip; LOOP
      ENDIF

      IF cTipVPC == "2" .AND. roba->( FieldPos( "vpc2" ) <> 0 )
         _cijena := roba->vpc2
      ELSE
         _cijena := if ( !Empty( cIdFirma ), fakt_mpc_iz_sifrarnika(), roba->vpc )
      ENDIF

      IF gVarC == "4" // uporedo vidi i mpc
         _cijena2 := roba->mpc
      ENDIF

      IF PRow() -gPStranica > 50; FF; ++nStrana; ENDIF

      ZagKartKons( lPrviProlaz )
      lPrviProlaz := .F.

      // GLAVNA DO-WHILE
      aUkKol := {}
      DO WHILE !Eof() .AND. IF( cSintetika == "D" .AND. ROBA->tip == "S", ;
            Left( cIdRoba, gnDS ) == Left( IdRoba, gnDS ), ;
            cIdRoba == iif( fID_J, IdRoba_J + IdRoba, IdRoba ) )
         cKolona := "N"

         IF !Empty( cidfirma ); IF idfirma <> cidfirma; skip; loop; end; END
         IF !Empty( cK1 ); IF ck1 <> K1 ; skip; loop; end; END // uslov ck1
            IF !Empty( cK2 ); IF ck2 <> K2; skip; loop; end; END // uslov ck2

         // if !empty(qqPartn)
         // select fakt_doks; hseek fakt->(IdFirma+idtipdok+brdok)
         // select fakt; if !(doks->partner=qqPartn); skip; loop; endif
         // endif

         IF !Empty( cIdRoba )
            IF !( Left( serbr, 1 ) == "*" .AND. idtipdok == "10" )  // za fakture na osnovu otpremnice ne racunaj izlaz
               nIzl += kolicina
               nIznos += kolicina * cijena * ( 1 -Rabat / 100 )
               cKolona := "I"
            ENDIF

            IF cKolona != "N"

               IF PRow() -gPStranica > 55; FF; ++nStrana; ZagKartKons(); ENDIF

               ? Space( gnLMarg ); ?? Str( ++nRbr, 3 ) + ".   " + idfirma + "-" + idtipdok + "-" + brdok + Left( serbr, 1 ) + "  " + DToC( datdok )

               SELECT fakt_doks; hseek fakt->( IdFirma + idtipdok + brdok ); SELECT fakt
               @ PRow(), PCol() + 1 SAY fakt_doks->idPartner
               @ PRow(), PCol() + 1 SAY PadR( fakt_doks->Partner, 20 )

               @ PRow(), PCol() + 1 SAY kolicina PICT lpickol

               IF Len( aUkKol ) < 1 .OR. ;
                     ( nPK := AScan( aUkKol, {| x| Round( x[ 1 ], 4 ) == Round( cijena, 4 ) } ) ) <= 0
                  AAdd( aUkKol, { cijena, kolicina } )
               ELSE
                  aUkKol[ nPK, 2 ] += kolicina
               ENDIF

               @ PRow(), PCol() + 1 SAY ROBA->nc PICT picdem
               @ PRow(), PCol() + 1 SAY _cijena PICT picdem
               @ PRow(), PCol() + 1 SAY Cijena PICT picdem
               @ PRow(), PCol() + 1 SAY Rabat  PICT "99.99"
               @ PRow(), PCol() + 1 SAY kolicina * Cijena * ( 1 -Rabat / 100 ) PICT picdem
            ENDIF

            IF FieldPos( "k1" ) <> 0  .AND. gDK1 == "D"
               @ PRow(), PCol() + 1 SAY k1
            ENDIF
            IF FieldPos( "k2" ) <> 0  .AND. gDK2 == "D"
               @ PRow(), PCol() + 1 SAY k2
            ENDIF

            IF roba->tip = "U"
               aMemo := ParsMemo( txt )
               aTxtR := SjeciStr( aMemo[ 1 ], 60 )   // duzina naziva + serijski broj
               FOR ui = 1 TO Len( aTxtR )
                  ? Space( gNLMarg )
                  @ PRow(), PCol() + 7 SAY aTxtR[ ui ]
               NEXT
            ENDIF

         ENDIF

         SKIP
      ENDDO
      // GLAVNA DO-WHILE

      IF PRow() -gPStranica > 55; FF; ++nStrana; ZagKartKons(); ENDIF

      ? Space( gnLMarg ); ?? m
      ? Space( gnLMarg ) + PadL( "UKUPNO IZNOS: ", 115 ) + TRANS( nIznos, picdem )
      ? Space( gnLMarg ); ?? m
      FOR i := 1 TO Len( aUkKol )
         ? Space( gnLMarg )
         ?? PadL( "UKUPNO KOLICINE PO CIJENAMA", 60 ), TRANS( aUkKol[ i, 2 ], lPicKol )
         ?? Space( 24 ), TRANS( aUkKol[ i, 1 ], picdem )
      NEXT
      ? Space( gnLMarg ); ?? m
      ?
      IF cOstran == "D"    // kraj kartice => zavrsavam stranicu
         FF; ++nStrana
      ENDIF
   ENDDO

   IF cOstran != "D"
      FF
   ENDIF

   ENDPRINT
   closeret

   RETURN
// }


/*! \fn ZagKartKons(lIniStrana)
 *  \brief Zaglavlje kartice konsignacije
 */

STATIC FUNCTION ZagKartKons( lIniStrana )

   // {

   // static integer
   STATIC nZStrana := 0
   // ;

   IF lIniStrana = NIL; lIniStrana := .F. ; ENDIF
   IF lIniStrana; nZStrana := 0; ENDIF
   B_ON
   IF nStrana > nZStrana
      ?? Space( 66 ) + "Strana: " + AllTrim( Str( nStrana ) )
   ENDIF
   ?
   ? Space( gnLMarg ); ?? m
   ? Space( gnLMarg ); ?? "SIFRA:"
   IF fID_J
      ?? IF( cSintetika == "D" .AND. ROBA->tip == "S", ROBA->ID_J, Left( cidroba, 10 ) ), PadR( ROBA->naz, 40 )
   ELSE
      ?? IF( cSintetika == "D" .AND. ROBA->tip == "S", ROBA->id, cidroba ), PadR( ROBA->naz, 40 )
   ENDIF
   ? Space( gnLMarg ); ?? m
   B_OFF
   ? Space( gnLMarg )
   ?? "R.br  RJ Br.dokumenta   Dat.dok. "
   ?? " Sifra "
   ?? PadC( "i naziv partnera", 21 )
   ?? "  Kolicina  " + PadC( "NC(sifr.)", 12 ) + PadC( "VPC(sifr.)", 12 ) + "  Cijena    Rab%     Iznos  "

   ? Space( gnLMarg ); ?? m
   nZStrana = nStrana

   RETURN
// }


/*! \fn Oporezovana(cIdTarifa)
 *  \brief
 */

FUNCTION Oporezovana( cIdTarifa )

   // {
   LOCAL nArr
   IF cIdTarifa <> NIL
      nArr := Select()
      SELECT TARIFA; HSEEK cIdTarifa
      SELECT ( nArr )
   ENDIF

   RETURN ( TARIFA->opp <> 0 .OR. TARIFA->ppp <> 0 .OR. TARIFA->zpp <> 0 )
// }




/*! \fn SortFakt(cId,cSort)
 *  \brief Sortiranje faktura
 *  \param cId
 *  \param cSort
 */

FUNCTION SortFakt( cId, cSort )

   // {
   LOCAL cVrati := "", nArr := Select()
   SELECT ROBA
   HSEEK cId
   DO CASE
   CASE cSort == "N"
      cVrati := naz + id
   CASE cSort == "T"
      cVrati := idtarifa + id
   CASE cSort == "J"
      cVrati := jmj + id
   ENDCASE
   SELECT ( nArr )

   RETURN cVrati



FUNCTION TmpFakt()
   RETURN TempFile( KUMPATH, "CDX", 0 )


FUNCTION MyFErase()

   PARAMETERS cFajl

   IF !( cFajl == NIL .OR. "U" $ Type( "cFajl" ) )
      FErase( cFajl )
   ENDIF

   RETURN
