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



function NaprPom(aDbf,cPom)

if cPom == nil
	cPom:="POM"
endif

cPomDBF := my_home() + "pom.dbf"
cPomCDX := my_home() + "pom.cdx"

if File(cPomDBF)
	FErase(cPomDBF)
endif

if File(cPomCDX)
	FErase(cPomCDX)
endif

if File(UPPER(cPomDBF))
	FErase(UPPER(cPomDBF))
endif

if File (UPPER(cPomCDX))
	FErase(UPPER(cPomCDX))
endif

// kreiraj tabelu pom.dbf
DBcreate2( "pom.dbf", aDbf )

return


 
function pos_reindex_all()

O_POS_DOKS
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_PROMVP
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_POS
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_ROBA
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_SAST
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_STRAD
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

SELECT(F_PARAMS)
my_use("params")
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

SELECT(F_KPARAMS)
my_use("kparams")
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
close

O_OSOB
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_TARIFA
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_VALUTE
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_VRSTEP
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_KASE
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_ODJ
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
close

O_DIO
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
close

O_UREDJ
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_PARTN
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

O_MARS
@ m_x+2,m_y+2 SAY padr(alias(),12)
beep(1)
reindex
__dbpack()
close

function BrisiDSif(nAreaSif)
local cId
local nTRec

GO TOP
do while !EOF()
	cId:=field->id
	skip
	if (field->id==cId)
		do while !EOF() .and. (field->id==cId)
			SKIP
			nTRec:=RECNO()
			SKIP -1
			DELETE
			GO nTRec
		enddo
	endif
enddo


function ChkTblPromVp()
local cTbl

cTbl:=DbfName(F_PROMVP,.t.)+'.'+DBFEXT
if (FILE(cTbl))
	O_PROMVP
	if (FIELDPOS("polog01")==0 .or. FIELDPOS("_SITE_")==0)
		USE
		goModul:oDatabase:kreiraj(F_PROMVP)
		USE
	endif
	USE
endif

return



function CrePosISifData()
O_STRAD
if (RECCOUNT2()==0)
	
	MsgO("Kreiram ini STRAD")
	APPEND BLANK
	replace id WITH "0"
	replace prioritet WITH "0"
	replace naz WITH "Nivo admin"
	
	APPEND BLANK
	replace id WITH "1"
	replace prioritet WITH "1"
	replace naz WITH "Nivo upravn"
	
	APPEND BLANK
	replace id WITH "3"
	replace prioritet WITH "3"
	replace naz WITH "Nivo prod"
	MsgC()
	
endif

CLOSE ALL

O_OSOB

if (RECCOUNT2()==0)
	
	MsgO("Kreiram ini OSOB")
	APPEND BLANK
	replace id with "0001"
	replace korSif with CryptSc(PADR("PARSON",6))
	replace naz with "Admin"
	replace status with "0"
	
	APPEND BLANK
	replace id with "0005"
	replace korSif with CryptSc(PADR("UPRAVN",6))
	replace naz with "Upravnik"
 	replace status with "1"

	APPEND BLANK
	replace id with "0010"
	replace korSif with CryptSc(PADR("P1",6))
	replace naz with "Prodavac 1"
 	replace status with "3"
	
	APPEND BLANK
	replace id with "0011"
	replace korSif with CryptSc(PADR("P2",6))
	replace naz with "Prodavac 2"
 	replace status with "3"
	MsgC()
endif

CLOSE ALL

return

function BrisiDupleSifre()
local nTekRec

nCounter:=0

if !SigmaSif("BRDPLS")
	return
endif

O_ROBA
select roba
set order to tag ID
go top
Box(,3,60)
aPom:={}
do while !eof()
	if (_OID_ == 0)
		// vec ova cinjenica govori nam da stavka nije u redu
		skip
		nTekRec := RECNO()
		skip -1
		AADD(aPom, {id, naz})
		DELETE
		// sljedeci zapis
		nCounter++
		go nTekRec
		// idemo na vrh petlje
		LOOP
	endif
	cId:=id
	@ m_x+1, m_y+2 SAY cId
	skip 
	if (roba->id == cId)
		// ako je dupli zapis, izbrisi drugi
		// cinjenica je medjutim da nismo siguruni da smo izbrisali pravu sifru, ali pretpostavljam da ce se uvijek naci _OID_ = 0 sifre.
		skip
		nTekRec := RECNO()
		skip  -1
		AADD(aPom, {id, naz})
		DELETE
		nCounter++
		// sljedeci zapis
		go nTekRec
		// idemo na vrh petlje
		LOOP
	else
		skip -1
	endif
	skip
enddo										BoxC()

START PRINT CRET

? "Pobrisanih sifara " + ALLTRIM(STR(nCounter))
? "---------------------------"
for i:=1 to LEN(aPom)
	? aPom[i, 1] + " - " + aPom[i, 2] 
next
?

END PRINT

return



function UzmiBkIzSez()
if !SigmaSif("BKIZSEZ")
	MsgBeep("Ne cackaj!")
	return
endif

Box(,5,60)
	cUvijekUzmi := "N"
	@ 1+m_x, 2+m_y SAY "Uvijek uzmi BARKOD iz sezone (D/N)?" GET cUvijekUzmi PICT "@!" VALID cUvijekUzmi $ "DN"
	
	read
BoxC()

O_ROBA
O_ROBASEZ

select roba

set order to tag "ID"
go top

Box(,3,60)

do while !eof()
	
	cIdRoba := roba->id
	
	select robasez
	set order to tag "ID"
	hseek cIdRoba
	
	if !Found()
		select roba
		skip
		loop
	endif
	
	cBkSez := robasez->barkod
	
	@ m_x+1,m_y+2 SAY "Roba : " + cIdRoba
	
	if (EMPTY( roba->barkod ) .and. !empty(cBkSez)) .or. ((cUvijekUzmi == "D") .and. !empty(cBkSez))
		
		select roba
		replace barkod with cBkSez
		
		@ m_x+2, m_y+2 SAY "set Barkod " + cBkSez
	endif
	
	select roba
	skip
	
enddo		

BoxC()

MsgBeep("Setovao barkodove iz sezonskog podrucja")
return

