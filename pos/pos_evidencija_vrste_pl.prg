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


#include "pos.ch"




function FrmPromVp()
local cDN
local nUkupno
local nRealNaDan
local i
local nMaxLen
local cIdPos
local dDatum
// 2-d matrica; aPromet[i,1] - naslov, aPromet[i,2] - vrijednost
local aPromet

ChkTblPromVp()
O_PROMVP

cDN:='D'

nRealNaDan:=0
nUkupno:=0
dDatum:=gDatum

aPromet:={}

SET CURSOR ON
SetATitle(@aPromet, @nMaxLen)

cIdPos:=gIdPos

SET ORDER TO TAG "1"

Box(,1,60)
@ m_x+1, m_y+2 SAY "Datum: " GET dDatum
READ
BoxC()

SEEK dDatum
if FOUND()
	MsgBeep("Vec je vrsen unos prometa ...")
	LoadRec(@cIdPos, @dDatum, @aPromet)
endif

Box(,nMaxLen+4,60)
	do while .t.
		SET CURSOR ON
		
		@ m_x+1,m_y+2 SAY "Prodajno mjesto: " + cIdPos
		@ m_x+2,m_y+2 SAY "Datum: " + DTOC(dDatum)
		
		for i:=1 to nMaxLen
			if !EMPTY(aPromet[i,1])
				@ m_x+3+i,m_y+2 SAY PADR(aPromet[i,1],25) GET aPromet[i,2]  pict "999999.99"
			endif
		next
		READ
		if (LASTKEY()==K_ESC)
			BoxC()
			return 0
		endif
		
		nUkupno:=0
		for i:=1 to 12
			nUkupno+=aPromet[i,2]
		next
		SET CURSOR ON

		nRealNaDan:=RealNaDan(dDatum)
		if nRealNaDan<>nUkupno
			MsgBeep('Niste dobro unijeli realizacija po racunima je '+STR(nRealNaDan, 8,2)+"## Realizacija po vasem unosu je "+STR(nUkupno,8,2)+"## Razlika je "+STR(nRealNaDan-nUkupno,8,2))
			if (Pitanje(,"Zelite li ipak snimiti unesene podatke ?","N")=="D")
				exit
			endif
			loop
		else
			exit
		endif

		@ m_x+10,m_y+2 SAY "Ukupno      :"+STR(nUkupno) 
		@ m_x+12,m_y+2 SAY "Azurirati u tabelu prometa (D/N): " GET cDN valid cDN $ "DN" pict "@!"
		READ
		if (LASTKEY()==K_ESC)
			BoxC()
			return 0
		endif
	enddo
BoxC()

if (cDN=="D")

	SELECT PROMVP
	SET ORDER TO TAG "1"
	SEEK dDatum

	if !FOUND()
		APPEND BLANK
	endif

	ReplaceRec( cIdPos, dDatum, aPromet, nUkupno )
	
endif

ShowInfoPolog( cIdPos, dDatum )

return 1




static function SetATitle(aPromet, nMaxLen)
local cTitle
local i

for i:=1 to 12
	AADD(aPromet,{"",0})
	cTitle:=""
	do case 
		case i==1
			cTitle:="Polog KM"
		case i==2
			cTitle:="Polog Euro"
		case i==3
			cTitle:="Polog Krediti"
		case i==4
			cTitle:="Polog Kartice"
		case i==5
			cTitle:="Polog Virman"
		case i==6
			cTitle:="Cekovi"
		case i==7
			cTitle:="Troskovi"
		case i==8
			cTitle:="Unikredit kartice"
	endcase
			
	aPromet[i,1]:=IzFmkIni('POS','Polog'+ALLTRIM(STR(i)), cTitle, KUMPATH)
	if !EMPTY(aPromet[i,1])
		nMaxLen:=i
	endif
next
return



static function LoadRec(cIdPos, dDatum, aPromet)

cIdPos:=field->pm
dDatum:=field->datum

aPromet[1,2]:=field->polog01
aPromet[2,2]:=field->polog02
aPromet[3,2]:=field->polog03
aPromet[4,2]:=field->polog04
aPromet[5,2]:=field->polog05
aPromet[6,2]:=field->polog06
aPromet[7,2]:=field->polog07
aPromet[8,2]:=field->polog08
aPromet[9,2]:=field->polog09
aPromet[10,2]:=field->polog10
aPromet[11,2]:=field->polog11
aPromet[12,2]:=field->polog12

return



static function ReplaceRec(cIdPos, dDatum, aPromet, nUkupno)
local nTRec
local nPomRec

nTRec := RECNO()

SELECT promvp
SKIP

// ako ima jos slogova sa zadatim datumom, njih treba izbrisati
// moze da se desi ako su indeksi bili osteceni

f18_lock_tables({"pos_promvp"})
sql_table_update( nil, "BEGIN" )

do while ( !EOF() .and. dDatum == field->datum )  

	SKIP
	nPomRec:=RECNO()
	SKIP -1

	_rec := dbf_get_rec()
	delete_rec_server_and_dbf( "pos_promvp", _rec, 1, "CONT" )

	GO nPomRec

enddo


GO nTRec
_rec := dbf_get_rec()
_rec["pm"] := cIdPos
_rec["datum"] := dDatum
_rec["polog01"] := aPromet[ 1, 2]
_rec["polog02"] := aPromet[ 2, 2]
_rec["polog03"] := aPromet[ 3, 2]
_rec["polog04"] := aPromet[ 4, 2]
_rec["polog05"] := aPromet[ 5, 2]
_rec["polog06"] := aPromet[ 6, 2]
_rec["polog07"] := aPromet[ 7, 2]
_rec["polog08"] := aPromet[ 8, 2]
_rec["polog09"] := aPromet[ 9, 2]
_rec["polog10"] := aPromet[10, 2]
_rec["polog11"] := aPromet[11, 2]
_rec["polog12"] := aPromet[12, 2]
_rec["ukupno"] := nUkupno

update_rec_server_and_dbf( "pos_promvp", _rec, 1, "CONT" )

f18_free_tables({"pos_promvp"})
sql_table_update( nil, "END" )

return



static function ShowInfoPolog(cIdPos, dDatum)
local nUkupno


SELECT promvp
SEEK dDatum

nUkupno:=0
if FOUND()
	nUkupno+=field->polog01
	nUkupno+=field->polog02
	nUkupno+=field->polog03
	nUkupno+=field->polog04
	nUkupno+=field->polog05
	nUkupno+=field->polog06
	nUkupno+=field->polog07
	nUkupno+=field->polog08
	nUkupno+=field->polog09
	nUkupno+=field->polog10
	nUkupno+=field->polog11
	nUkupno+=field->polog12
	MsgBeep("Ukupan polog za datum : "+DTOC(dDatum)+" je "+STR(nUkupno,12,2))
else
	MsgBeep("Nema pologa ???")
endif

return

