/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"

// --------------------------------
// kontrola zbira naloga 
// bDat = datumski uslov
// lSilent - ne prikazuj box
// vraca lRet - .t. ako je sve ok, 
//              .f. ako nije
// --------------------------------
function KontrZb(bDat, lSilent)

local lRet := .t.
local nSaldo := 0
local nSintD := 0
local nSintP := 0
local nSubD := 0
local nSubP := 0
local nNalD := 0
local nNalP := 0
local nAnalP := 0
local nAnalD := 0

if (bDat == nil)
	bDat := .f.
endif

if (lSilent == nil)
	lSilent := .f.
endif

if (bDat)
	dDOd := CToD("")
	dDDo := DATE()
	Box(, 1, 40)
		@ 1+m_x, 2+m_y SAY "Datum od" GET dDOd
		@ 1+m_x, 25+m_y SAY "do" GET dDDo
		read
	BoxC()
endif

if lSilent
	MsgO("Provjeravam kontrolu zbira datoteka...")
endif

close all
O_NALOG
O_SUBAN
O_SINT
O_ANAL

if !lSilent
 Box("KZD",9,77,.f.)
 set cursor off
	@ m_x+1,m_y+11 say "³"+PADC("NALOZI",16)+"³"+PADC("SINTETIKA",16)+"³"+PADC("ANALITIKA",16)+"³"+PADC("SUBANALITIKA",16)
	@ m_x+2,m_y+1  say REPLICATE("Ä",10)+"Å"+REPLICATE("Ä",16)+"Å"+REPLICATE("Ä",16)+"Å"+REPLICATE("Ä",16)+"Å"+REPLICATE("Ä",16)
	@ m_x+3,m_y+1 say "duguje "+ValDomaca()
	@ m_x+4,m_y+1 say "potraz."+ValDomaca()
	@ m_x+5,m_y+1 say "saldo  "+ValDomaca()
	@ m_x+7,m_y+1 say "duguje "+ValPomocna()
	@ m_x+8,m_y+1 say "potraz."+ValPomocna()
	@ m_x+9,m_y+1 say "saldo  "+ValPomocna()
	FOR i:=11 TO 65 STEP 17
  		FOR j:=3 TO 9
    			@ m_x+j,m_y+i SAY "³"
  		NEXT
	NEXT
	
	picBHD:=FormPicL("9 "+gPicBHD,16)
	picDEM:=FormPicL("9 "+gPicDEM,16)
endif

altd()

select nalog
go top
	
nDug:=nPot:=nDu2:=nPo2:=0
DO WHILE !EOF() .and. INKEY()!=27
	if (bDat)
		if (field->datnal < dDOd .or. field->datnal > dDDo)
			skip
			loop
		endif
	endif
	nDug+=DugBHD
   	nPot+=PotBHD
   	nDu2+=DugDEM
   	nPo2+=PotDEM
   	SKIP
ENDDO

nSaldo += nDug - nPot
nNalD := nDug
nNalP := nPot

if !lSilent
	if LASTKEY()==K_ESC
		BoxC()
		CLOSERET
	endif
	@ m_x+3,m_y+12 SAY nDug PICTURE picBHD
	@ m_x+4,m_y+12 SAY nPot PICTURE picBHD
	@ m_x+5,m_y+12 SAY nDug-nPot PICTURE picBHD
	@ m_x+7,m_y+12 SAY nDu2 PICTURE picDEM
	@ m_x+8,m_y+12 SAY nPo2 PICTURE picDEM
	@ m_x+9,m_y+12 SAY nDu2-nPo2 PICTURE picDEM
endif

select SINT
go top
nDug:=nPot:=nDu2:=nPo2:=0
go top
DO WHILE !EOF() .and. INKEY()!=27
	if (bDat)
 		if (field->datnal < dDOd .or. field->datnal > dDDo)
			skip
			loop
		endif
	endif
	nDug+=Dugbhd
	nPot+=Potbhd
   	nDu2+=Dugdem
	nPo2+=Potdem
 	SKIP
ENDDO

nSaldo += nDug - nPot
nSintD := nDug
nSintP := nPot

if !lSilent
	ESC_BCR
	@ m_x+3,m_y+29 SAY nDug PICTURE picBHD
	@ m_x+4,m_y+29 SAY nPot PICTURE picBHD
	@ m_x+5,m_y+29 SAY nDug-nPot PICTURE picBHD
	@ m_x+7,m_y+29 SAY nDu2 PICTURE picDEM
	@ m_x+8,m_y+29 SAY nPo2 PICTURE picDEM
	@ m_x+9,m_y+29 SAY nDu2-nPo2 PICTURE picDEM
endif

select ANAL
go top
nDug:=nPot:=nDu2:=nPo2:=0
DO WHILE !EOF() .and. INKEY()!=27
	if (bDat)
		if (field->datnal < dDOd .or. field->datnal > dDDo)
			skip
			loop
		endif
	endif
	nDug+=Dugbhd
	nPot+=Potbhd
	nDu2+=Dugdem
	nPo2+=Potdem
	SKIP
ENDDO

nSaldo += nDug - nPot
nAnalD := nDug
nAnalP := nPot

if !lSilent
	ESC_BCR
	@ m_x+3,m_y+46 SAY nDug PICTURE picBHD
	@ m_x+4,m_y+46 SAY nPot PICTURE picBHD
	@ m_x+5,m_y+46 SAY nDug-nPot PICTURE picBHD
	@ m_x+7,m_y+46 SAY nDu2 PICTURE picDEM
	@ m_x+8,m_y+46 SAY nPo2 PICTURE picDEM
	@ m_x+9,m_y+46 SAY nDu2-nPo2 PICTURE picDEM
endif

select SUBAN
nDug:=nPot:=nDu2:=nPo2:=0
go top

DO WHILE !EOF() .and. INKEY()!=27
	if (bDat)
		if (field->datdok < dDOd .or. field->datdok > dDDo)
			skip
			loop
		endif
	endif
		
	if D_P=="1"
		nDug+=Iznosbhd
		nDu2+=Iznosdem
  	else
   		nPot+=Iznosbhd
		nPo2+=Iznosdem
  	endif
  	SKIP
ENDDO

nSaldo += nDug - nPot
nSubD := nDug
nSubP := nPot

if !lSilent
	ESC_BCR
	@ m_x+3,m_y+63 SAY nDug PICTURE picBHD
	@ m_x+4,m_y+63 SAY nPot PICTURE picBHD
	@ m_x+5,m_y+63 SAY nDug-nPot PICTURE picBHD
	@ m_x+7,m_y+63 SAY nDu2 PICTURE picDEM
	@ m_x+8,m_y+63 SAY nPo2 PICTURE picDEM
	@ m_x+9,m_y+63 SAY nDu2-nPo2 PICTURE picDEM
	Inkey(0)
	BoxC()
endif

// provjeri da li su podaci tacni !
if (ROUND(nSaldo, 2) > 0) .or. ( ROUND(nSubD + nNalD + nAnalD + nSintD, 2) <> ROUND(nSubP + nNalP + nAnalP + nSintP, 2) )
	lRet := .f.
endif

// upisi u params podatak o datumu povlacenja...
private cSection:="9"
private cHistory:=" "
private aHistory:={}

O_PARAMS
WPar("kd", DATE())
use

if lSilent
	MsgC()
endif

return lRet


// -------------------------------------------------
// automatsko pokretanje kontrole zbira datoteka
// -------------------------------------------------
function auto_kzb()
local dDate := DATE()
local nTArea := SELECT()
local lKzbOk
local dLastDate:=DATE()
private cSection:="9"
private cHistory:=" "
private aHistory:={}

if gnKZBdana == 0
	return
endif

O_PARAMS
RPar("kd", @dLastDate)

// ako je manje od KZBdana ne pozivaj opciju...
if (dDate - dLastDate) <= gnKZBdana
	select (nTArea)
	return
endif

lKzbOk := kontrzb(nil, .t.)

if !lKzbOk
	MsgBeep("Kontrola zbira datoteka je uocila greske!#Pregledajte greske...")
	kontrzb()
endif

select (nTArea)
return







