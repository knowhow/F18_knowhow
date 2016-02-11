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


function P_RVrsta(cid,dx,dy)
local nSelect
private ImeKol,Kol:={}

ImeKol:={ { "ID ",  {|| id }, "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",30), {|| left(naz,30)},      "naz"       };
        }
FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT

nSelect:=SELECT()
SELECT (F_RVRSTA)
if !used()
	O_RVRSTA
endif
SELECT (nSelect)
return PostojiSifra(F_RVRSTA, 1, 10, 75, "Vrste artikala", @cid, dx, dy)


function P_PlSezona(cId) 
cPom:=IzSifKRoba("SEZ",roba->id, .f.)
if (EMPTY(cId) .and. !EMPTY(cPom) .and. Pitanje(,"Konverzija na osnovu polja SEZONA","D")=="D")
	cId:=SubStr(cPom,3)
endif

return .t.


function P_TPurchase(cId) 
return .t.



function P_IdPartner(cId) 
return .t.



function PlFill_Sezona()
local cSezonaPf
local cSezonaPk
local cSez
local nI

cSezonaPf:=SPACE(5)
cSezonaPk:=SPACE(3)

if .f.
Box(,3,60)
	@ m_x+1, m_y+2 SAY "Sezona PF-Sa   :" GET cSezonaPf
	@ m_x+2, m_y+2 SAY "Sezona Pl-Kranj:" GET cSezonaPk
	read
BoxC()
endif

if Pitanje(,"Zelite li izvrsiti konverziju ?", "N")=="D"
nI:=0
	O_ROBA
	O_SIFK
	O_SIFV
	select roba
	go top
	Box(,3,60)
	do while !eof()
	 	cSez := IzSifKRoba( "SEZ", roba->id, .f.)
		@ m_x+1, m_y+2 SAY roba->id + " " + cSez
		
		cSezonaPf = cSez
		//if EMPTY(roba->sezona) .and. ;
		//	(cSez == cSezonaPf) 
			replace sezona with RIGHT(cSezonaPf, 3)
			nI++
		//endif
		SELECT roba
		SKIP
	enddo
	BoxC()
	MsgBeep("Promjena:" + STR(nI))
endif

return



function PlFill_Vrsta()
local cVrstaPf
local cVrstaPk
local nI

cVrstaPf:=SPACE(10)
cVrstaPk:=SPACE(1)
Box(,3,60)
	@ m_x+1, m_y+2 SAY "Sifra artikla sadrzi ($):" GET cVrstaPf
	@ m_x+2, m_y+2 SAY "Vrsta Pl-Kranj:" GET cVrstaPk
	read
BoxC()

nI:=0
if Pitanje(,"Zelite li izvrsiti konverziju ?", "N")=="D"

	O_ROBA
	O_SIFK
	O_SIFV
	select roba
	go top
	MsgO("Koverzija ...")
	do while !eof()
		if EMPTY(roba->vrsta) .and. ;
		  (ALLTRIM(cVrstaPf) $ roba->id) 
			replace vrsta with cVrstaPk
			nI++
		endif
		SELECT roba
		SKIP
	enddo
	MsgC()
	MsgBeep("Promjena:" + STR(nI))
endif

return
*}

function PlFillIdPartner(cIdPartner, cIdRoba)
*{
local nArr
if EMPTY(cIdPartner) .or. EMPTY(cIdRoba)
	return
endif
nArr:=SELECT()
O_ROBA
select roba
HSEEK cIdRoba
replace field->idpartner with cIdPartner

select (nArr)
return
*}

