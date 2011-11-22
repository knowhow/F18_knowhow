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

static LEN_KOLICINA := 8
static LEN_CIJENA := 10
static LEN_VRIJEDNOST := 12
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_CIJENA := ""


// ------------------------------------------------
// stampa dokumenta u odt formatu
// ------------------------------------------------
function stdokodt( cIdf, cIdVd, cBrDok )
local cPath := "c:\"
local cFilter := "f*.odt"
local cTemplate := ""

if !EMPTY( gJODTemplate )
	cPath := ALLTRIM( gJODTemplate )
endif

// samo napuni pomocne tabele
stdokpdv( cIdF, cIdVd, cBrDok, .t. )

// generisi xml fajl
_gen_xml()

// uzmi template koji ces koristiti
g_afile( cPath, cFilter, @cTemplate, .t. )

// pozovi odt stampu
_odt_print( cPath, cTemplate )

return


// ---------------------------------------------
// generisi xml sa podacima
// ---------------------------------------------
static function _gen_xml()
local cXML := "c:\data.xml"
local i
local cTmpTxt := ""

PIC_KOLICINA :=  PADL(ALLTRIM(RIGHT(PicKol, LEN_KOLICINA)), LEN_KOLICINA, "9")
PIC_VRIJEDNOST := PADL(ALLTRIM(RIGHT(PicDem, LEN_VRIJEDNOST)), LEN_VRIJEDNOST, "9")
PIC_CIJENA := PADL(ALLTRIM(RIGHT(PicCDem, LEN_CIJENA)), LEN_CIJENA, "9")

// DRN tabela
// brdok, datdok, datval, datisp, vrijeme, zaokr, ukbezpdv, ukpopust
// ukpoptp, ukbpdvpop, ukpdv, ukupno, ukkol, csumrn

open_xml( cXml )
xml_head()
xml_subnode("invoice", .f.)

select drn
go top

// totali
xml_node("u_bpdv", show_number( field->ukbezpdv, PIC_VRIJEDNOST ) )
xml_node("u_pop", show_number( field->ukpopust, PIC_VRIJEDNOST ) )
xml_node("u_poptp", show_number( field->ukpoptp, PIC_VRIJEDNOST ) )
xml_node("u_bpdvpop", show_number( field->ukbpdvpop, PIC_VRIJEDNOST ) )
xml_node("u_pdv", show_number( field->ukpdv, PIC_VRIJEDNOST ) )
xml_node("u_kol", show_number( field->ukkol, PIC_KOLICINA ) )
xml_node("u_total", show_number( field->ukupno, PIC_VRIJEDNOST ) )
xml_node("u_zaokr", show_number( field->zaokr, PIC_VRIJEDNOST ) )
xml_node("u_tottp", show_number( field->ukupno - field->ukpoptp, PIC_VRIJEDNOST ) )
// dokument iz tabele
xml_node("dbr", ALLTRIM( field->brdok ) )
xml_node("ddat", DTOC( field->datdok ) )
xml_node("ddval", DTOC( field->datval ) )
xml_node("ddisp", DTOC( field->datisp ) )
xml_node("dvr", ALLTRIM( field->vrijeme ) )

// dokument iz teksta
cTmp := ALLTRIM(get_dtxt_opis("D01"))
xml_node("dmj", to_xml_encoding(cTmp))
cTmp := ALLTRIM(get_dtxt_opis("D02"))
xml_node("ddok", to_xml_encoding(cTmp))
cTmp := ALLTRIM(get_dtxt_opis("D04"))
xml_node("dslovo", to_xml_encoding(cTmp))
xml_node("dotpr", ALLTRIM(get_dtxt_opis("D05")) )
xml_node("dnar", ALLTRIM(get_dtxt_opis("D06")) )
xml_node("ddin", ALLTRIM(get_dtxt_opis("D07")) )

// destinacija na fakturi
cTmp := ALLTRIM(get_dtxt_opis("D08"))
if EMPTY(cTmp)
	// ako je prazno, uzmi adresu partnera
	cTmp := get_dtxt_opis("K02")
endif

xml_node("ddest", to_xml_encoding(cTmp))
xml_node("dtdok", ALLTRIM(get_dtxt_opis("D09")) )
xml_node("drj", ALLTRIM(get_dtxt_opis("D10")) )
xml_node("didpm", ALLTRIM(get_dtxt_opis("D11")) )
// broj fiskalnog racuna
xml_node("fisc", ALLTRIM(get_dtxt_opis("O10")) )

cTmp := ALLTRIM(get_dtxt_opis("F10"))
xml_node("dsign", to_xml_encoding(cTmp))

// broj veze
nLines := VAL( get_dtxt_opis("D30") )
cTmp := ""
nTmp := 30
for i:=1 to nLines
	cTmp += get_dtxt_opis("D" + ALLTRIM(STR( nTmp + i )))
next
xml_node("dveza", to_xml_encoding(cTmp))

// zaglavlje
cTmp := ALLTRIM(get_dtxt_opis("I01"))
xml_node("fnaz", to_xml_encoding(cTmp))
cTmp := ALLTRIM(get_dtxt_opis("I02"))
xml_node("fadr", to_xml_encoding(cTmp))
xml_node("fid", ALLTRIM(get_dtxt_opis("I03")) )
xml_node("ftel", ALLTRIM(get_dtxt_opis("I10")) )
xml_node("feml", ALLTRIM(get_dtxt_opis("I11")) )
xml_node("fbnk", ALLTRIM(get_dtxt_opis("I09")) )
cTmp := ALLTRIM(get_dtxt_opis("I12"))
xml_node("fdt1", to_xml_encoding(cTmp))
cTmp := ALLTRIM(get_dtxt_opis("I13"))
xml_node("fdt2", to_xml_encoding(cTmp))
cTmp := ALLTRIM(get_dtxt_opis("I14"))
xml_node("fdt3", to_xml_encoding(cTmp))

// partner
xml_node("knaz", to_xml_encoding(ALLTRIM(get_dtxt_opis("K01"))) )
xml_node("kadr", to_xml_encoding(ALLTRIM(get_dtxt_opis("K02"))) )
xml_node("kid", to_xml_encoding(ALLTRIM(get_dtxt_opis("K03"))) )
xml_node("kpbr", ALLTRIM(get_dtxt_opis("K05")) )
xml_node("kmj", to_xml_encoding(ALLTRIM(get_dtxt_opis("K10"))) )
xml_node("kptt", ALLTRIM(get_dtxt_opis("K11")) )
xml_node("ktel", ALLTRIM(get_dtxt_opis("K13")) )
xml_node("kfax", ALLTRIM(get_dtxt_opis("K14")) )


// dodatni tekst na fakturi....
// koliko ima redova ?
nTxtR := VAL( get_dtxt_opis("P02") )

for i := 20 to ( 20 + nTxtR )
	
	cTmp := "F" + ALLTRIM( STR(i) )
	cTmpTxt := ALLTRIM( get_dtxt_opis(cTmp) )

	xml_subnode("text", .f.)
	xml_node("row", to_xml_encoding(cTmpTxt) )
	xml_subnode("text", .t.)

next


// RN
// brdok, rbr, podbr, idroba, robanaz, jmj, kolicina, cjenpdv, cjenbpdv
// cjen2pdv, cjen2bpdv, popust, ppdv, vpdv, ukupno, poptp, vpoptp
// c1, c2, c3, opis

// predji sada na stavke fakture
select rn
go top

do while !EOF()
	
	xml_subnode( "item", .f. )
	
	xml_node( "rbr", ALLTRIM( field->rbr ) )
	xml_node( "pbr", ALLTRIM( field->podbr ) )
	xml_node( "id", to_xml_encoding(ALLTRIM( field->idroba )) )
	xml_node( "naz", to_xml_encoding(ALLTRIM( field->robanaz )))
	xml_node( "jmj", to_xml_encoding(ALLTRIM( field->jmj )) )
	xml_node( "kol", show_number( field->kolicina, PIC_KOLICINA ) )
	xml_node( "cpdv", show_number( field->cjenpdv, PIC_CIJENA ) )
	xml_node( "cbpdv", show_number( field->cjenbpdv, PIC_CIJENA ) )
	xml_node( "c2pdv", show_number( field->cjen2pdv, PIC_CIJENA ) )
	xml_node( "c2bpdv", show_number( field->cjen2bpdv, PIC_CIJENA ) )
	xml_node( "pop", show_number( field->popust, PIC_VRIJEDNOST ) )
	xml_node( "ppdv", show_number( field->ppdv, PIC_VRIJEDNOST ) )
	xml_node( "vpdv", show_number( field->vpdv, PIC_VRIJEDNOST ) )
	// ukupno bez pdv
	xml_node( "ukbpdv", show_number( field->cjenbpdv * field->kolicina, ;
		PIC_VRIJEDNOST ) )
	// ukupno sa pdv
	xml_node( "ukpdv", show_number( field->ukupno, PIC_VRIJEDNOST ) )
	// ukupno bez pdv-a sa popustom
	xml_node( "uk2bpdv", show_number( field->cjen2bpdv * field->kolicina, ;
		PIC_VRIJEDNOST ) )
	// ukupno sa pdv-om sa popustom
	xml_node( "uk2pdv", show_number( field->cjen2pdv * field->kolicina, ;
		PIC_VRIJEDNOST ) )
	xml_node( "ptp", show_number( field->poptp, PIC_VRIJEDNOST ) )
	xml_node( "vtp", show_number( field->vpoptp, PIC_VRIJEDNOST ) )
	xml_node( "c1", to_xml_encoding( ALLTRIM( field->c1 )) )
	xml_node( "c2", to_xml_encoding( ALLTRIM( field->c2 )) )
	xml_node( "c3", to_xml_encoding( ALLTRIM( field->c3 )) )
	xml_node( "opis", to_xml_encoding( ALLTRIM( field->opis )) )

	xml_subnode( "item", .t. )
	
	skip

enddo

xml_subnode("invoice", .t.)
close_xml()

return


// ----------------------------------------------
// printaj odt dokument
// ----------------------------------------------
static function _odt_print( cPath, cTemplate, lDirectPrint )
local cJodPath 
local cOOPath
local cOOParams := ""
local cJavaStart := ALLTRIM( gJavaStart )

private cCmdLine

if lDirectPrint == nil
	lDirectPrint := .f.
endif

cJodPath := ALLTRIM(gJODRep)
cOOPath := '"' + ALLTRIM(gOOPath) + ALLTRIM(gOOWriter) + '"'

cCmdLine := cJavaStart + " " + cJodPath + " " + cPath + cTemplate + ;
	" c:\data.xml c:\out.odt" 

save screen to cScreen
run &cCmdLine
restore screen from cScreen

if lDirectPrint == .t.
	cOOParams := " -pt "
endif

cCmdLine := "start " + cOOPath + " " + cOOParams + " c:\out.odt"
run &cCmdLine

return


