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

STATIC LEN_IT_NO := 4
STATIC LEN_DESC := 95

STATIC LEN_LINE1 := 115

STATIC COL_RBR := 3
STATIC COL_ITEM := 15

STATIC LEN_QTTY := 10
STATIC LEN_DIMENSION := 10
STATIC LEN_VALUE := 10

STATIC PIC_QTTY := "9999999.99"
STATIC PIC_VALUE := "9999999.99"
STATIC PIC_DIMENSION := "9999999.99"

STATIC LEN_PAGE := 58

STATIC RAZMAK := " "

STATIC nPage := 0
STATIC lPrintedTotal := .F.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
STATIC nDuzStrKorekcija := 0


// ----------------------------------------------
// definicija linije za glavnu tabelu sa stavkama
// nVar - 1 = nalog
// 2 = obracunski list
// ----------------------------------------------
STATIC FUNCTION g_line()

   LOCAL cLine

   IF gGnUse == "N"
      // posto nema gn-a
      // smanji glavnu liniju
      LEN_LINE1 := 92
   ENDIF

   // linija za obracunski list
   cLine := RAZMAK
   cLine += Replicate( "-", LEN_LINE1 )

   RETURN cLine


// ----------------------------------------------
// definicija linije unutar glavne tabele
// ----------------------------------------------
STATIC FUNCTION g_line2()

   LOCAL cLine

   // linija za obra�unski list
   cLine := Space( COL_ITEM )
   cLine += Replicate( "-", LEN_QTTY )
   cLine += " " + Replicate( "-", LEN_DIMENSION )
   cLine += " " + Replicate( "-", LEN_DIMENSION )

   IF gGnUse == "D"
      cLine += " " + Replicate( "-", LEN_DIMENSION )
      cLine += " " + Replicate( "-", LEN_DIMENSION )
   ENDIF

   // ukidam liniju koja je sluzila za bruto
   // cLine += " " + REPLICATE("-", LEN_VALUE)
   cLine += " " + Replicate( "-", LEN_VALUE )
   cLine += " " + Replicate( "-", LEN_VALUE )
   cLine += " " + Replicate( "-", LEN_VALUE )

   RETURN cLine



// ------------------------------------------------------
// glavna funkcija za poziv stampe obracunskog lista
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
FUNCTION obrl_print( lStartPrint )

   // ako je nil onda je uvijek .t.
   IF ( lStartPrint == nil )
      lStartPrint := .T.
   ENDIF

   LEN_QTTY := Len( PIC_QTTY )
   LEN_VALUE := Len( PIC_VALUE )
   LEN_DIMENSION := Len( PIC_DIMENSION )

   // razmak ce biti
   RAZMAK := Space( gDl_margina )
   // nek je razmak 1
   RAZMAK := Space( 1 )

   t_rpt_open()

   SELECT t_docit
   SET ORDER TO TAG "3"
   GO TOP

   // stampaj obracunski listic
   p_a4_obrl( lStartPrint )

   RETURN


// -----------------------------------
// stampa obracunskog lista...
// -----------------------------------
FUNCTION p_a4_obrl( lStartPrint )

   LOCAL lShow_zagl
   LOCAL i
   LOCAL nItem := 0
   LOCAL lPrintRek := .F.
   LOCAL cPrintRek := "N"
   LOCAL cCust
   LOCAL nCust
   LOCAL nCont

   nDuzStrKorekcija := 0
   lPrintedTotal := .F.

   IF lStartPrint

      IF !start_print()
         my_close_all_dbf()
         RETURN .F.
      ENDIF

   ENDIF

   nTTotal := Val( g_t_pars_opis( "N10" ) )

   // zaglavlje
   obrl_header()

   cLine := g_line( 2 )
   cLine2 := g_line2()

   // broj dokumenta.....
   cDoc_no := g_t_pars_opis( "N01" )
   cDoc_date := g_t_pars_opis( "N02" )
   cDoc_time := g_t_pars_opis( "N12" )
   cDocs := g_t_pars_opis( "N14" )
   nCust := Val( g_t_pars_opis( "P01" ) )
   nCont := Val( g_t_pars_opis( "P10" ) )
   cObject := g_t_pars_opis( "P21" )

   // kupac ?
   cCust := _cust_cont( nCust, nCont )

   // stampa rekapitulacije
   cPrintRek := g_t_pars_opis( "N20" )

   IF cPrintRek == "D"
      lPrintRek := .T.
   ENDIF

   // setuj len_ukupno
   LEN_TOTAL := Len( cLine )

   ? RAZMAK + "SPECIFIKACIJA, "

   IF "," $ cDocs

      ?? "prema nalozima:" + cDocs

   ELSE

      ?? "prema nalogu br.:" + cDoc_no
      ? RAZMAK + "Datum naloga: " + cDoc_date + ", vrijeme naloga: " + cDoc_time
   ENDIF

   // kupac, objekat
   ? RAZMAK + "Kupac: " + AllTrim( cCust ) + ", obj: " + AllTrim( cObject )

   ?

   SELECT t_docit
   SET ORDER TO TAG "3"
   GO TOP

   B_OFF

   P_COND

   // print header tabele
   s_tbl_header()

   SELECT t_docit
   SET ORDER TO TAG "3"

   nPage := 1
   aArt_desc := {}
   nArt_id := 0
   nArt_tmp := 0
   nUTotal := 0
   nUTot_m := 0
   nUNeto := 0
   nUBruto := 0
   nUQty := 0
   nUHeig := 0
   nUWidt := 0
   nUZHeig := 0
   nUZWidt := 0

   nTTotal := 0
   nTTot_m := 0
   nTNeto := 0
   nTBruto := 0
   nTQty := 0
   nTHeig := 0
   nTWidt := 0
   nTZHeig := 0
   nTZWidt := 0

   cDocXX := "XX"

   nItem := 0

   // stampaj podatke
   DO WHILE !Eof()

      nDoc_no := field->doc_no

      DO WHILE !Eof() .AND. field->doc_no == nDoc_no

         cArt_sh := field->art_sh_des

         // da li se stavka stampa ili ne ?
         IF field->print == "N"
            SKIP
            LOOP
         ENDIF

         cDoc_no := docno_str( field->doc_no )
         cDoc_it_no := docit_str( field->doc_it_no )

         IF cDocXX <> cDoc_no

            ? RAZMAK

            // nalog broj
            ?? "stavke naloga broj: " + AllTrim( cDoc_no )

         ENDIF

         DO WHILE !Eof() .AND. field->doc_no == nDoc_no ;
               .AND. PadR( field->art_sh_des, 150 ) == ;
               PadR( cArt_sh, 150 )

            // da li se stavka stampa ili ne ?
            IF field->print == "N"
               SKIP
               LOOP
            ENDIF

            cDoc_no := docno_str( field->doc_no )
            cDoc_it_no := docit_str( field->doc_it_no )

            nArt_id := field->art_id

            nQty := field->doc_it_qtt
            nHeig := field->doc_it_hei
            nWidt := field->doc_it_wid

            nZaHeig := field->doc_it_zhe
            nZaWidt := field->doc_it_zwi

            nNeto := field->doc_it_net
            nBruto := field->doc_it_bru

            nTotal := field->doc_it_tot
            nTot_m := field->doc_it_tm

            nUTotal += nTotal
            nUTot_m += nTot_m
            nUNeto += nNeto
            nUBruto += nBruto
            nUQty += nQty
            nUHeig += nHeig
            nUWidt += nWidt
            nUZHeig += nZaHeig
            nUZWidt += nZaWidt

            nTTotal += nTotal
            nTTot_m += nTot_m
            nTNeto += nNeto
            nTBruto += nBruto
            nTQty += nQty
            nTHeig += nHeig
            nTWidt += nWidt
            nTZHeig += nZaHeig
            nTZWidt += nZaWidt

            IF Empty( field->art_desc )
               cArt_desc := "-//-"
            ELSE
               cArt_desc := AllTrim( field->art_desc )
            ENDIF

            // redni broj u nalogu
            cArt_desc := "(" + AllTrim( Str( field->doc_it_no ) ) + ") " + cArt_desc

            // pozicija ako postotoji
            cArt_desc += "; " + AllTrim( field->doc_it_des )

            aArt_desc := SjeciStr( cArt_desc, LEN_DESC )

            // ------------------------------------------
            // prvi red...
            // ------------------------------------------

            ++ nItem

            ? RAZMAK + Space( COL_RBR )

            // r.br
            ?? PadL( AllTrim( Str( nItem ) ) + ")", LEN_IT_NO )

            ?? " "

            // proizvod, naziv robe, jmj
            ?? aArt_desc[ 1 ]

            // drugi red artikla
            IF Len( aArt_desc ) > 1

               FOR i := 2 TO Len( aArt_desc )

                  ? RAZMAK + Space( COL_RBR + LEN_IT_NO )
                  ?? " "

                  ?? aArt_desc[ i ]

                  // provjeri za novu stranicu
                  IF PRow() > LEN_PAGE - DSTR_KOREKCIJA()
                     ++ nPage
                     Nstr_a4( nPage, .T. )
                     P_COND
                  ENDIF
               NEXT

            ENDIF

            // novi red
            ? Space( COL_ITEM )

            nCol_item := PCol()

            // kolicina
            ?? show_number( nQty, nil, -10 )
            ?? " "

            // sirina
            ?? show_number( nWidt, nil, -10 )
            ?? " "

            // visina
            ?? show_number( nHeig, nil, -10 )
            ?? " "

            // zaokruzenja po GN-u
            IF gGnUse == "D"
               // sirina
               ?? show_number( nZaWidt, nil, -10 )
               ?? " "

               // visina
               ?? show_number( nZaHeig, nil, -10 )
               ?? " "

            ENDIF

            // neto
            ?? show_number( nNeto, nil, -10 )
            ?? " "

            // bruto nije potreban na nalogu....
            // bruto
            // ?? PADR( "_", 10 , "_")
            // ?? " "

            // ukupno m2
            ?? show_number( nTotal, nil, -10 )
            ?? " "

            // ukupno m
            ?? show_number( nTot_m, nil, -10 )

            // provjeri za novu stranicu
            IF PRow() > LEN_PAGE - DSTR_KOREKCIJA()

               ++ nPage
               Nstr_a4( nPage, .T. )

               P_COND

            ENDIF


            SELECT t_docit
            SKIP

         ENDDO

         nTmp := COL_ITEM
         nRepl := 94
         IF gGnUse == "N"
            nRepl := 84
         ENDIF

         // ispis totala po istim artiklima

         ? Space( nTmp - 6 )

         ?? Replicate( "-", nRepl )

         // B_ON

         ? PadL( "total:", nTmp )

         // ?? " "

         // kolicina
         ?? show_number( nUQty, nil, -10 )
         ?? " "

         // sirina - ne treba
         ?? Space( 10 )
         // ?? show_number(nUWidt, nil, -10 )
         ?? " "

         // visina - ne treba
         // ?? show_number(nUHeig, nil, -10 )
         ?? Space( 10 )
         ?? " "

         // zaokruzenja po GN-u

         IF gGnUse == "D"
            // sirina
            ?? show_number( nUZWidt, nil, -10 )
            ?? " "

            // visina
            ?? show_number( nUZHeig, nil, -10 )
            ?? " "
         ENDIF

         // neto
         ?? show_number( nUNeto, nil, -10 )
         ?? " "

         // bruto
         // ?? PADR( "", 10  )
         // ?? " "

         // ukupno m2
         ?? show_number( nUTotal, nil, -10 )
         ?? " "

         // total m
         ?? show_number( nUTot_m, nil, -10 )

         ? Space( nTmp - 6 )

         ?? Replicate( "", nRepl )

         // resetuj varijable totale

         nUTotal := 0
         nUTot_m := 0
         nUNeto := 0
         nUBruto := 0
         nUQty := 0
         nUHeig := 0
         nUWidt := 0
         nUZHeig := 0
         nUZWidt := 0

         cDocXX := cDoc_no

         // provjeri za novu stranicu
         IF PRow() > LEN_PAGE - DSTR_KOREKCIJA()

            ++ nPage
            Nstr_a4( nPage, .T. )

            P_COND

         ENDIF

      ENDDO

   ENDDO

   // provjeri za novu stranicu
   IF PRow() > LEN_PAGE - DSTR_KOREKCIJA()
      ++nPage
      Nstr_a4( nPage, .T. )
      P_COND
   ENDIF

   ? cLine

   // r.br
   ? PadL( "U K U P N O : ", COL_ITEM )

   // ?? " "

   // kolicina
   ?? show_number( nTQty, nil, -10 )
   ?? " "

   // sirina
   // ?? show_number(nTWidt, nil, -10 )
   ?? Space( 10 )
   ?? " "

   // visina
   // ?? show_number(nTHeig, nil, -10 )
   ?? Space( 10 )
   ?? " "

   // zaokruzenja po GN-u

   IF gGnUse == "D"

      // sirina
      ?? show_number( nTZWidt, nil, -10 )
      ?? " "

      // visina
      ?? show_number( nTZHeig, nil, -10 )
      ?? " "

   ENDIF

   // neto
   ?? show_number( nTNeto, nil, -10 )
   ?? " "

   // bruto
   // ?? PADR( "_", 10 , "_" )
   // ?? " "

   // ukupno m2
   ?? show_number( nTTotal, nil, -10 )
   ?? " "

   ?? show_number( nTTot_m, nil, -10 )

   ? cLine

   // prikazi GN tabelu.....
   IF gGnUse == "D"
      s_gn_tbl()
   ENDIF

   // prikazi rekapitulaciju dodatnog repromaterijala
   s_nal_rekap( lPrintRek )

   P_12CPI

   s_obrl_footer()

   IF lStartPrint
      FF
      end_print()
   ENDIF

   RETURN .T.


// ---------------------------------------------
// prikaz GN tabele
// ---------------------------------------------
STATIC FUNCTION s_gn_tbl()

   LOCAL aGn := {}
   LOCAL cLine := Space( 1 ) + Replicate( "-", 125 )
   LOCAL cTxt := Space( 1 ) + "GN tabela (izrazena u mm):"
   LOCAL i
   LOCAL nTmp
   LOCAL nTmp2
   LOCAL nX
   LOCAL nY
   LOCAL nX_pos
   LOCAL nY_pos

   // napuni gn matricu
   aGn := arr_gn()

   P_COND2

   ?
   ? cLine
   ? cTxt
   ? cLine

   FOR i := 1 TO Len( aGn )

      IF i = 1
         ? Space( 1 )
      ENDIF

      IF i % 25 = 0
         ? Space( 1 )
      ENDIF

      @ PRow(), PCol() + 1 SAY ;
         PadL( AllTrim( Str( aGn[ i, 1 ] ) ), 4 )

   NEXT

   ? cLine

   RETURN



// ----------------------------------------
// footer obracunskog lista
// ----------------------------------------
STATIC FUNCTION s_obrl_footer()

   LOCAL cPom

   cPom := "UKUPNO BRUTO: ________________________________"
   ?
   ? RAZMAK + Space( 5 ) + cPom

   cPom := "Izdao: _________________"
   cPom += Space( 10 )
   cPom += "Primio: _________________"

   ?
   ? RAZMAK + Space( 5 ) + cPom

   RETURN



// -----------------------------------------
// zaglavlje glavne tabele sa stavkama
// -----------------------------------------
STATIC FUNCTION s_tbl_header()

   LOCAL cLine
   LOCAL cLine2
   LOCAL cRow1
   LOCAL cRow2

   cLine := g_line( 2 )
   cLine2 := g_line2()

   ? cLine

   cRow1 := RAZMAK
   cRow2 := ""

   cRow1 += PadR( "nalog / artikal", 20 )

   cRow2 += Space( COL_ITEM )
   cRow2 += PadC( "Kol.", LEN_QTTY )
   cRow2 += " " + PadC( "Sir. (mm)", LEN_DIMENSION )
   cRow2 += " " + PadC( "Vis. (mm)", LEN_DIMENSION )

   IF gGnUse == "D"
      cRow2 += " " + PadC( "Sir.GN", LEN_DIMENSION )
      cRow2 += " " + PadC( "Vis.GN", LEN_DIMENSION )
   ENDIF

   cRow2 += " " + PadC( "Neto (kg)", LEN_VALUE )
   // bruto ukidamo kao kolonu
   // cRow2 += " " + PADC("Bruto (kg)", LEN_VALUE)
   cRow2 += " " + PadC( "Povrsina (m2)", LEN_VALUE )
   cRow2 += " " + PadC( "Obim (m)", LEN_VALUE )

   ? cRow1
   ? cLine2
   ? cRow2

   ? cLine

   RETURN


// -----------------------------------------
// funkcija za ispis headera
// -----------------------------------------
STATIC FUNCTION obrl_header()

   LOCAL cDLHead
   LOCAL cSLHead
   LOCAL cINaziv
   LOCAL cRazmak := Space( 2 )

   // naziv
   cINaziv  := AllTrim( gFNaziv )

   // double line header
   cDLHead := Replicate( "=", 60 )

   // single line header
   cSLHead := Replicate( "-", Len( gFNaziv ) )

   // prvo se pozicioniraj na g.marginu
   FOR i := 1 TO gDg_margina
      ?
   NEXT

   p_line( cRazmak + cDlhead, 10, .T. )
   p_line( cRazmak + cINaziv, 10, .T. )
   p_line( cRazmak + cDlhead, 10, .T. )

   ?

   RETURN
