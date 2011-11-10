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


#include "ld.ch" 

// -----------------------------------------
// unos datuma isplate plaæe
// -----------------------------------------
function unos_disp()
// datum isplate
local dDatPr 
local dDat1
local dDat2
local dDat3
local dDat4
local dDat5
local dDat6
local dDat7
local dDat8
local dDat9
local dDat10
local dDat11
local dDat12
// mjesec isplate
local nMjPr
local nMj1
local nMj2
local nMj3
local nMj4
local nMj5
local nMj6
local nMj7
local nMj8
local nMj9
local nMj10
local nMj11
local nMj12
// isplata za
local cIsZaPr
local cIsZa1
local cIsZa2
local cIsZa3
local cIsZa4
local cIsZa5
local cIsZa6
local cIsZa7
local cIsZa8
local cIsZa9
local cIsZa10
local cIsZa11
local cIsZa12
// vrsta isplate
local cVrIsPr
local cVrIs1
local cVrIs2
local cVrIs3
local cVrIs4
local cVrIs5
local cVrIs6
local cVrIs7
local cVrIs8
local cVrIs9
local cVrIs10
local cVrIs11
local cVrIs12

local nGod := YEAR(DATE())
local cObr := " "
local cRj := "  "
local nX := 1
local cOk := "D"

O_OBRACUNI

if obracuni->(FIELDPOS("DAT_ISPL")) == 0 .or. obracuni->(FIELDPOS("OBR")) == 0
	MsgBeep("Potrebna modifikacija struktura LD.CHS !!!#Prekidam operaciju")
	return
endif


Box(, 20, 65)
	
	@ m_x + nX, m_y + 2 SAY "*** Unos datuma isplata placa" COLOR "I"
	
	++nX
	++nX
	
	@ m_x + nX, m_y + 2 SAY "Tekuca godina:" GET nGod PICT "9999"
	
	@ m_x + nX, col() + 2 SAY "Radna jedinica:" GET cRJ PICT "99" ;
		VALID EMPTY(cRJ) .or. P_RJ(@cRJ)
	
	@ m_x + nX, col() + 2 SAY "Obracun:" GET cObr VALID cObr $ " 123456789"
	
	++nX
	
	@ m_x + nX, m_y + 2 SAY "----------------------------------------"  
	++nX

	read

	// uzmi parametre postojece
	// prethodna godina
	dDatPr := g_isp_date( cRj, nGod - 1, 12, cObr, @nMjPr, @cIsZaPr, ;
		@cVrIsPr )
	
	// od mjeseca 1 do mjeseca 12 tekuce godine
	dDat1 := g_isp_date( cRj, nGod, 1, cObr, @nMj1, @cIsZa1, @cVrIs1 )
	dDat2 := g_isp_date( cRj, nGod, 2, cObr, @nMj2, @cIsZa2, @cVrIs2 )
	dDat3 := g_isp_date( cRj, nGod, 3, cObr, @nMj3, @cIsZa3, @cVrIs3 )
	dDat4 := g_isp_date( cRj, nGod, 4, cObr, @nMj4, @cIsZa4, @cVrIs4 )
	dDat5 := g_isp_date( cRj, nGod, 5, cObr, @nMj5, @cIsZa5, @cVrIs5 )
	dDat6 := g_isp_date( cRj, nGod, 6, cObr, @nMj6, @cIsZa6, @cVrIs6 )
	dDat7 := g_isp_date( cRj, nGod, 7, cObr, @nMj7, @cIsZa7, @cVrIs7 )
	dDat8 := g_isp_date( cRj, nGod, 8, cObr, @nMj8, @cIsZa8, @cVrIs8 )
	dDat9 := g_isp_date( cRj, nGod, 9, cObr, @nMj9, @cIsZa9, @cVrIs9 )
	dDat10 := g_isp_date( cRj, nGod, 10, cObr, @nMj10, @cIsZa10, @cVrIs10 )
	dDat11 := g_isp_date( cRj, nGod, 11, cObr, @nMj11, @cIsZa11, @cVrIs11 )
	dDat12 := g_isp_date( cRj, nGod, 12, cObr, @nMj12, @cIsZa12, @cVrIs12 )

	@ m_x + nX, m_y + 2 SAY PADL("datum", 7) + ;
		PADL("mj.ispl.", 18) + ;
		PADL("isplata za", 18) + ;
		PADL("vrsta ispl.", 18)

	++nX

	@ m_x + nX, m_y + 2 SAY "12." + ALLTRIM(STR(nGod-1)) + ;
		" => " GET dDatPr
	@ m_x + nX, col() + 2 SAY "" GET nMjPr PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZaPr PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIsPr PICT "@S15"
	
	++nX
	
	@ m_x + nX, m_y + 2 SAY "01." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat1
	@ m_x + nX, col() + 2 SAY "" GET nMj1 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa1 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs1 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "02." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat2
	@ m_x + nX, col() + 2 SAY "" GET nMj2 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa2 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs2 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "03." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat3
	@ m_x + nX, col() + 2 SAY "" GET nMj3 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa3 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs3 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "04." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat4
	@ m_x + nX, col() + 2 SAY "" GET nMj4 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa4 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs4 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "05." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat5
	@ m_x + nX, col() + 2 SAY "" GET nMj5 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa5 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs5 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "06." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat6
	@ m_x + nX, col() + 2 SAY "" GET nMj6 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa6 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs6 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "07." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat7
	@ m_x + nX, col() + 2 SAY "" GET nMj7 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa7 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs7 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "08." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat8
	@ m_x + nX, col() + 2 SAY "" GET nMj8 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa8 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs8 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "09." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat9
	@ m_x + nX, col() + 2 SAY "" GET nMj9 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa9 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs9 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "10." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat10
	@ m_x + nX, col() + 2 SAY "" GET nMj10 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa10 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs10 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "11." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat11
	@ m_x + nX, col() + 2 SAY "" GET nMj11 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa11 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs11 PICT "@S15"

	++nX
	
	@ m_x + nX, m_y + 2 SAY "12." + ALLTRIM(STR(nGod)) + ;
		" => " GET dDat12
	@ m_x + nX, col() + 2 SAY "" GET nMj12 PICT "99"
	@ m_x + nX, col() + 2 SAY "" GET cIsZa12 PICT "@S15"
	@ m_x + nX, col() + 2 SAY "" GET cVrIs12 PICT "@S15"

	
	++nX
	++nX
	
	@ m_x + nX, m_y + 2 SAY "Unos ispravan (D/N)" GET cOk ;
		VALID cOK $ "DN" ;
		PICT "@!"

	read
BoxC()

if LastKey() <> K_ESC

	if cOk == "N"
		return
	endif
	
	nGodina := nGod

	// setuj promjene
	// prethodna godina
	s_isp_date( cRJ, nGodina - 1 , 12, cObr, dDatPr, nMjPr, cIsZaPr, ;
		cVrIsPr )

	// od 1 do 12 mjeseca tekuce
	s_isp_date( cRJ, nGodina, 1, cObr, dDat1, nMj1, cIsZa1, cVrIs1 )
	s_isp_date( cRJ, nGodina, 2, cObr, dDat2, nMj2, cIsZa2, cVrIs2 )
	s_isp_date( cRJ, nGodina, 3, cObr, dDat3, nMj3, cIsZa3, cVrIs3 )
	s_isp_date( cRJ, nGodina, 4, cObr, dDat4, nMj4, cIsZa4, cVrIs4 )
	s_isp_date( cRJ, nGodina, 5, cObr, dDat5, nMj5, cIsZa5, cVrIs5 )
	s_isp_date( cRJ, nGodina, 6, cObr, dDat6, nMj6, cIsZa6, cVrIs6 )
	s_isp_date( cRJ, nGodina, 7, cObr, dDat7, nMj7, cIsZa7, cVrIs7 )
	s_isp_date( cRJ, nGodina, 8, cObr, dDat8, nMj8, cIsZa8, cVrIs8 )
	s_isp_date( cRJ, nGodina, 9, cObr, dDat9, nMj9, cIsZa9, cVrIs9 )
	s_isp_date( cRJ, nGodina, 10, cObr, dDat10, nMj10, cIsZa10, cVrIs10 )
	s_isp_date( cRJ, nGodina, 11, cObr, dDat11, nMj11, cIsZa11, cVrIs11 )
	s_isp_date( cRJ, nGodina, 12, cObr, dDat12, nMj12, cIsZa12, cVrIs12 )

endif

return


// --------------------------------------------
// vraca tekuce isplate za godinu
// --------------------------------------------
function g_isp_date( cRj, nGod, nMjesec, cObr, nMjIsp, cIsplZa, cVrsta )
local dDate := CTOD("")
local nTArea := SELECT()

nMjIsp := 0
cIsplZa := SPACE(50)
cVrsta := SPACE(50)

O_OBRACUNI

select obracuni
set order to tag "RJ"
go top

seek  cRJ + ALLTRIM(STR( nGod )) + FmtMjesec( nMjesec ) + "G" + cObr

if field->rj == cRj .and. ;
	field->mjesec = nMjesec .and. ;
	field->godina = nGod .and. ;
	field->obr == cObr .and. ;
	field->status == "G"

	dDate := field->dat_ispl
	nMjIsp := field->mj_ispl
	cIsplZa := field->ispl_za
	cVrsta := field->vr_ispl

else
	dDate := CTOD("")
endif

select (nTArea)
return dDate


// ----------------------------------------
// setuje datum isplate za mjesec
// ----------------------------------------
static function s_isp_date( cRj, nGod, nMjesec, cObr, dDatIspl, nMjIspl, ;
	cIsplZa, cVrsta )

local nTArea := SELECT()

O_OBRACUNI

select obracuni
set order to tag "RJ"
go top
seek  cRJ + ALLTRIM(STR( nGod )) + FmtMjesec( nMjesec ) + "G" + cObr


if field->rj == cRj .and. ;
	field->mjesec = nMjesec .and. ;
	field->godina = nGod .and. ;
	field->obr == cObr .and. ;
	field->status == "G"
	
	replace dat_ispl with dDatIspl
	replace mj_ispl with nMjIspl
	replace ispl_za with cIsplZa
	replace vr_ispl with cVrsta

else
	append blank
	replace rj with cRj
	replace godina with nGod
	replace mjesec with nMjesec
	replace obr with cObr
	replace status with "G"
	replace dat_ispl with dDatIspl
	replace mj_ispl with nMjIspl
	replace ispl_za with cIsplZa
	replace vr_ispl with cVrsta
endif


select (nTArea)
return


