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

static LEN_IT_NO := 4
static LEN_DESC := 95

static LEN_LINE1 := 115

static COL_RBR := 3
static COL_ITEM := 15

static LEN_QTTY := 10
static LEN_DIMENSION := 10
static LEN_VALUE := 10

static PIC_QTTY := "9999999.99"
static PIC_VALUE := "9999999.99"
static PIC_DIMENSION := "9999999.99"

static LEN_PAGE := 58

static RAZMAK := " "

static nPage := 0
static lPrintedTotal := .f.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0


// ----------------------------------------------
// definicija linije za glavnu tabelu sa stavkama
// nVar - 1 = nalog
//        2 = obracunski list
// ----------------------------------------------
static function g_line( )
local cLine

if gGnUse == "N"
    // posto nema gn-a
    // smanji glavnu liniju
    LEN_LINE1 := 92
endif

// linija za obra�unski list
cLine := RAZMAK
cLine += REPLICATE("-", LEN_LINE1 )

return cLine


// ----------------------------------------------
// definicija linije unutar glavne tabele
// ----------------------------------------------
static function g_line2( )
local cLine

// linija za obra�unski list
cLine := SPACE( COL_ITEM )
cLine += REPLICATE("-", LEN_QTTY)
cLine += " " + REPLICATE("-", LEN_DIMENSION)
cLine += " " + REPLICATE("-", LEN_DIMENSION)

if gGnUse == "D"
    cLine += " " + REPLICATE("-", LEN_DIMENSION)
    cLine += " " + REPLICATE("-", LEN_DIMENSION)
endif

// ukidam liniju koja je sluzila za bruto
//cLine += " " + REPLICATE("-", LEN_VALUE)
cLine += " " + REPLICATE("-", LEN_VALUE)
cLine += " " + REPLICATE("-", LEN_VALUE)
cLine += " " + REPLICATE("-", LEN_VALUE)

return cLine



// ------------------------------------------------------
// glavna funkcija za poziv stampe obracunskog lista
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
function obrl_print( lStartPrint )

// ako je nil onda je uvijek .t.
if ( lStartPrint == nil )
    lStartPrint := .t.
endif

LEN_QTTY := LEN(PIC_QTTY)
LEN_VALUE := LEN(PIC_VALUE)
LEN_DIMENSION := LEN(PIC_DIMENSION)

// razmak ce biti
RAZMAK := SPACE(gDl_margina)
// nek je razmak 1
RAZMAK := SPACE(1)

t_rpt_open()

select t_docit
set order to tag "3"
go top

// stampaj obracunski listic
p_a4_obrl( lStartPrint )

return


// -----------------------------------
// stampa obracunskog lista...
// -----------------------------------
function p_a4_obrl(lStartPrint)
local lShow_zagl
local i
local nItem := 0
local lPrintRek := .f.
local cPrintRek := "N"
local cCust
local nCust
local nCont

nDuzStrKorekcija := 0
lPrintedTotal := .f.

if lStartPrint

    if !StartPrint(nil, nil)
        my_close_all_dbf()
        return
    endif

endif

nTTotal := VAL(g_t_pars_opis("N10"))

// zaglavlje
obrl_header()

cLine := g_line(2)
cLine2 := g_line2()

// broj dokumenta.....
cDoc_no := g_t_pars_opis("N01")
cDoc_date := g_t_pars_opis("N02")
cDoc_time := g_t_pars_opis("N12")
cDocs := g_t_pars_opis("N14")
nCust := VAL(g_t_pars_opis("P01"))
nCont := VAL(g_t_pars_opis("P10"))
cObject := g_t_pars_opis("P21")

// kupac ?
cCust := _cust_cont( nCust, nCont )

// stampa rekapitulacije
cPrintRek := g_t_pars_opis("N20")

if cPrintRek == "D"
    lPrintRek := .t.
endif

// setuj len_ukupno
LEN_TOTAL := LEN( cLine )

? RAZMAK + "SPECIFIKACIJA, "

if "," $ cDocs

    ?? "prema nalozima:" + cDocs

else

    ?? "prema nalogu br.:" + cDoc_no
    ? RAZMAK + "Datum naloga: " + cDoc_date + ", vrijeme naloga: " + cDoc_time
endif

// kupac, objekat
? RAZMAK + "Kupac: " + ALLTRIM( cCust ) + ", obj: " + ALLTRIM( cObject )

?

select t_docit
set order to tag "3"
go top

B_OFF

P_COND

// print header tabele
s_tbl_header()

select t_docit
set order to tag "3"

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
do while !EOF()

    nDoc_no := field->doc_no

    do while !EOF() .and. field->doc_no == nDoc_no

        cArt_sh := field->art_sh_des

        // da li se stavka stampa ili ne ?
        if field->print == "N"
            skip
            loop
        endif

        cDoc_no := docno_str( field->doc_no )
        cDoc_it_no := docit_str( field->doc_it_no )

        if cDocXX <> cDoc_no

            ? RAZMAK

            // nalog broj
            ?? "stavke naloga broj: " + ALLTRIM( cDoc_no )

        endif

        do while !EOF() .and. field->doc_no == nDoc_no ;
            .and. PADR(field->art_sh_des,150) == ;
                PADR(cArt_sh,150)

            // da li se stavka stampa ili ne ?
            if field->print == "N"
                skip
                loop
            endif

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

            if EMPTY( field->art_desc )
                cArt_desc := "-//-"
            else
                cArt_desc := ALLTRIM( field->art_desc )
            endif

            // redni broj u nalogu
            cArt_desc := "(" + ALLTRIM(STR(field->doc_it_no)) + ") " + cArt_desc

            // pozicija ako postotoji
            cArt_desc += "; " + ALLTRIM( field->doc_it_des )

            aArt_desc := SjeciStr( cArt_desc, LEN_DESC )

            // ------------------------------------------
            // prvi red...
            // ------------------------------------------

            ++ nItem

            ? RAZMAK + SPACE( COL_RBR )

            // r.br
            ?? PADL(ALLTRIM( STR(nItem) ) + ")", LEN_IT_NO)

            ?? " "

            // proizvod, naziv robe, jmj
            ?? aArt_desc[1]

            // drugi red artikla
            if LEN(aArt_desc) > 1

                for i:=2 to LEN(aArt_desc)

                    ? RAZMAK + SPACE( COL_RBR + LEN_IT_NO )
                    ?? " "

                    ?? aArt_desc[ i ]

                    // provjeri za novu stranicu
                    if prow() > LEN_PAGE - DSTR_KOREKCIJA()
                        ++ nPage
                        Nstr_a4(nPage, .t.)
                        P_COND
                    endif
                next

            endif

            // novi red
            ? SPACE( COL_ITEM )

            nCol_item := pcol()

            // kolicina
            ?? show_number(nQty, nil, -10 )
            ?? " "

            // sirina
            ?? show_number(nWidt, nil, -10 )
            ?? " "

            // visina
            ?? show_number(nHeig, nil, -10 )
            ?? " "

            // zaokruzenja po GN-u
            if gGnUse == "D"
                // sirina
                ?? show_number(nZaWidt, nil, -10 )
                ?? " "

                // visina
                ?? show_number(nZaHeig, nil, -10 )
                ?? " "

            endif

            // neto
            ?? show_number(nNeto, nil, -10 )
            ?? " "

            // bruto nije potreban na nalogu....
            // bruto
            //?? PADR( "_", 10 , "_")
            //?? " "

            // ukupno m2
            ?? show_number(nTotal, nil, -10 )
            ?? " "

            // ukupno m
            ?? show_number(nTot_m, nil, -10 )

            // provjeri za novu stranicu
            if prow() > LEN_PAGE - DSTR_KOREKCIJA()

                ++ nPage
                Nstr_a4(nPage, .t.)

                P_COND

            endif


            select t_docit
            skip

        enddo

        nTmp := COL_ITEM
        nRepl := 94
        if gGnUse == "N"
            nRepl := 84
        endif

        // ispis totala po istim artiklima

        ? SPACE( nTmp - 6 )

        ?? REPLICATE( "-", nRepl )

        //B_ON

        ? PADL( "total:", nTmp )

        //?? " "

        // kolicina
        ?? show_number(nUQty, nil, -10 )
        ?? " "

        // sirina - ne treba
        ?? SPACE(10)
        //?? show_number(nUWidt, nil, -10 )
        ?? " "

        // visina - ne treba
        //?? show_number(nUHeig, nil, -10 )
        ?? SPACE(10)
        ?? " "

        // zaokruzenja po GN-u

        if gGnUse == "D"
            // sirina
            ?? show_number(nUZWidt, nil, -10 )
            ?? " "

            // visina
            ?? show_number(nUZHeig, nil, -10 )
            ?? " "
        endif

        // neto
        ?? show_number(nUNeto, nil, -10 )
        ?? " "

        // bruto
        //?? PADR( "", 10  )
        //?? " "

        // ukupno m2
        ?? show_number(nUTotal, nil, -10 )
        ?? " "

        // total m
        ?? show_number(nUTot_m, nil, -10 )

        ? SPACE( nTmp - 6 )

        ?? REPLICATE( "", nRepl )

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
        if prow() > LEN_PAGE - DSTR_KOREKCIJA()

            ++ nPage
            Nstr_a4(nPage, .t.)

            P_COND

        endif

    enddo

enddo

// provjeri za novu stranicu
if prow() > LEN_PAGE - DSTR_KOREKCIJA()
    ++nPage
    Nstr_a4(nPage, .t.)
    P_COND
endif

? cLine

// r.br
? PADL( "U K U P N O : ", COL_ITEM )

//?? " "

// kolicina
?? show_number(nTQty, nil, -10 )
?? " "

// sirina
//?? show_number(nTWidt, nil, -10 )
?? SPACE(10)
?? " "

// visina
//?? show_number(nTHeig, nil, -10 )
?? SPACE(10)
?? " "

// zaokruzenja po GN-u

if gGnUse == "D"

    // sirina
    ?? show_number(nTZWidt, nil, -10 )
    ?? " "

    // visina
    ?? show_number(nTZHeig, nil, -10 )
    ?? " "

endif

// neto
?? show_number(nTNeto, nil, -10 )
?? " "

// bruto
//?? PADR( "_", 10 , "_" )
//?? " "

// ukupno m2
?? show_number(nTTotal, nil, -10 )
?? " "

?? show_number(nTTot_m, nil, -10 )

? cLine

// prikazi GN tabelu.....
if gGnUse == "D"
    s_gn_tbl()
endif

// prikazi rekapitulaciju dodatnog repromaterijala
s_nal_rekap( lPrintRek )

P_12CPI

s_obrl_footer()

if lStartPrint
    FF
    EndPrint()
endif

return


// ---------------------------------------------
// prikaz GN tabele
// ---------------------------------------------
static function s_gn_tbl()
local aGn := {}
local cLine := SPACE(1) + REPLICATE("-", 125)
local cTxt := SPACE(1) + "GN tabela (izrazena u mm):"
local i
local nTmp
local nTmp2
local nX
local nY
local nX_pos
local nY_pos

// napuni gn matricu
aGn := arr_gn()

P_COND2

?
? cLine
? cTxt
? cLine

for i := 1 to LEN( aGn )

    if i = 1
        ? SPACE(1)
    endif

    if i%25 = 0
        ? SPACE(1)
    endif

    @ prow(), pcol() + 1 SAY ;
        PADL( ALLTRIM( STR( aGn[ i, 1 ] )), 4 )

next

? cLine


return



// ----------------------------------------
// footer obracunskog lista
// ----------------------------------------
static function s_obrl_footer()
local cPom

cPom := "UKUPNO BRUTO: ________________________________"
?
? RAZMAK + SPACE(5) + cPom

cPom := "Izdao: _________________"
cPom += SPACE(10)
cPom += "Primio: _________________"

?
? RAZMAK + SPACE(5) + cPom

return



// -----------------------------------------
// zaglavlje glavne tabele sa stavkama
// -----------------------------------------
static function s_tbl_header()
local cLine
local cLine2
local cRow1
local cRow2

cLine := g_line(2)
cLine2 := g_line2()

? cLine

cRow1 := RAZMAK
cRow2 := ""

cRow1 += PADR("nalog / artikal", 20)

cRow2 += SPACE( COL_ITEM )
cRow2 += PADC("Kol.", LEN_QTTY)
cRow2 += " " + PADC("Sir. (mm)", LEN_DIMENSION)
cRow2 += " " + PADC("Vis. (mm)", LEN_DIMENSION)

if gGnUse == "D"
    cRow2 += " " + PADC("Sir.GN", LEN_DIMENSION)
    cRow2 += " " + PADC("Vis.GN", LEN_DIMENSION)
endif

cRow2 += " " + PADC("Neto (kg)", LEN_VALUE)
// bruto ukidamo kao kolonu
//cRow2 += " " + PADC("Bruto (kg)", LEN_VALUE)
cRow2 += " " + PADC("Povrsina (m2)", LEN_VALUE)
cRow2 += " " + PADC("Obim (m)", LEN_VALUE)

? cRow1
? cLine2
? cRow2

? cLine

return


// -----------------------------------------
// funkcija za ispis headera
// -----------------------------------------
static function obrl_header()
local cDLHead
local cSLHead
local cINaziv
local cRazmak := SPACE(2)

// naziv
cINaziv  := ALLTRIM(gFNaziv)

// double line header
cDLHead := REPLICATE("=", 60)

// single line header
cSLHead := REPLICATE("-", LEN(gFNaziv))

// prvo se pozicioniraj na g.marginu
for i:=1 to gDg_margina
    ?
next

p_line(cRazmak + cDlhead, 10, .t.)
p_line(cRazmak + cINaziv, 10, .t.)
p_line(cRazmak + cDlhead, 10, .t.)

?

return
