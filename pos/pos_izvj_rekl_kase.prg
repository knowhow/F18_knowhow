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

function ReklKase(dDOd, dDDo, cVarijanta)
private cIdPos:=gIdPos
private dDat0
private dDat1
private cFilter:=".t."

set cursor on

if (dDOd == nil)  
	dDat0:=gDatum
	dDat1:=gDatum
else
	dDat0:=dDOd
	dDat1:=dDDo
endif

if (cVarijanta==nil)
	cVarijanta:="0"
endif

o_pos_tables()

if (cVarijanta == "0")
	cIdPos:=gIdPos
else
	if FrmRptVars(@cIdPos, @dDat0, @dDat1)==0
		return 0
	endif
endif

START PRINT CRET
Zagl(dDat0, dDat1, cIdPos)

SELECT ( F_POS_DOKS )
if !USED()
	O_POS_DOKS
endif
SetFilter(@cFilter, cIdPos, dDat0, dDat1)

nCnt:=0
? "----------------------------------------"
? "Rbr  Datum     BrDok           Iznos"
? "----------------------------------------"
go top

do while !EOF() .and. idvd == VD_REK
	++ nCnt
	? STR(nCnt, 3)
	?? SPACE(2) + DTOC(field->datum)
	?? SPACE(2) + PADR(ALLTRIM(field->idvd) + "-" +  ALLTRIM(field->brdok),10)
	?? SPACE(2) + pos_iznos_dokumenta(.t., field->idpos, field->idvd, field->datum, field->brdok)
	skip
enddo

ENDPRINT

my_close_all_dbf()

return .t.


/* FrmRptVars(cIdPos, dDat0, dDat1)
 *     Uzmi varijable potrebne za izvjestaj
 *  \return 0 - nije uzeo, 1 - uzeo uspjesno
 */
static function FrmRptVars(cIdPos, dDat0, dDat1)
*{
local aNiz

aNiz:={}
cIdPos:=gIdPos

if gVrstaRS<>"K"
	AADD(aNiz,{"Prod. mjesto (prazno-sve)","cIdPos","cidpos='X'.or.EMPTY(cIdPos) .or. P_Kase(@cIdPos)","@!",})
endif

AADD(aNiz,{"Izvjestaj se pravi od datuma","dDat0",,,})
AADD(aNiz,{"                   do datuma","dDat1",,,})

do while .t.
	if cVarijanta<>"1"  // onda nema read-a
		if !VarEdit(aNiz,6,5,24,74,"USLOVI ZA IZVJESTAJ PREGLED REKLAMACIJA","B1")
			CLOSE ALL 
			return 0
		endif
	endif
enddo

return 1
*}


static function Zagl(dDat0, dDat1, cIdPos)
*{

?? gP12CPI
if glRetroakt
	? PADC("REKLAMACIJE NA DAN "+FormDat1(dDat1),40)
else
	? PADC("REKLAMACIJE NA DAN "+FormDat1(gDatum),40)
endif
? PADC("-------------------------------------",40)

O_KASE
if EMPTY(cIdPos)
	? "PRODAJNO MJESTO: SVA"
else
	? "PRODAJNO MJESTO: "+cIdPos+"-"+Ocitaj(F_KASE,cIdPos,"NAZ")
endif

? "PERIOD     : "+FormDat1(dDat0)+" - "+FormDat1(dDat1)

return
*}


static function SetFilter(cFilter, cIdPos, dDat0, dDat1)
*{

select pos_doks
SET ORDER TO TAG "2"  // "2" - "IdVd+DTOS (Datum)+Smjena"

cFilter += " .and. idvd == '98' .and. sto <> 'P   ' " 
cFilter += " .and. idpos == '" + cIdPos + "'"
if (dDat0 <> nil)
	cFilter += " .and. datum >= " + dbf_quote(dDat0) 
endif
if (dDat1 <> nil)
	cFilter += " .and. datum <= " + dbf_quote(dDat1) 
endif

if !(cFilter==".t.")
	SET FILTER TO &cFilter
endif

return
*}

static function TblCrePom()
local aDbf := {}

AADD(aDbf,{"IdPos"    ,"C",  2, 0})
AADD(aDbf,{"IdRadnik" ,"C",  4, 0})
AADD(aDbf,{"IdVrsteP" ,"C",  2, 0})
AADD(aDbf,{"IdOdj"    ,"C",  2, 0})
AADD(aDbf,{"IdRoba"   ,"C", 10, 0})
AADD(aDbf,{"IdCijena" ,"C",  1, 0})
AADD(aDbf,{"Kolicina" ,"N", 12, 3})
AADD(aDbf,{"Iznos"    ,"N", 20, 5})
AADD(aDbf,{"Iznos2"   ,"N", 20, 5})
AADD(aDbf,{"Iznos3"   ,"N", 20, 5})
AADD(aDbf,{"K1"       ,"C",  4, 0})
AADD(aDbf,{"K2"       ,"C",  4, 0})

NaprPom( aDbf )

select ( F_POM )
if used()
	use
endif
my_use_temp( "POM", my_home() + "pom", .f., .t. )

index on ( IdPos+IdRadnik+IdVrsteP+IdOdj+IdRoba+IdCijena ) tag "1"
index on ( IdPos+IdOdj+IdRoba+IdCijena ) tag "2"
index on ( IdPos+IdRoba+IdCijena ) tag "3"
index on ( IdPos+IdVrsteP ) tag "4"
index on ( IdPos+K1+idroba ) tag "K1"

set order to tag "1"

return


