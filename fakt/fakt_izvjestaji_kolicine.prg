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


// ---------------------------------
// otvara potrebne tabele
// ---------------------------------
static function _o_tables()
O_FAKT
O_PARTN
O_VALUTE
O_RJ
O_SIFK
O_SIFV
O_ROBA
return


// --------------------------------------------
// vraca matricu sa robom i definicijom polja
// --------------------------------------------
static function _g_ini_roba( )
local aRoba := {}
local i

for i := 1 to 100
  
  cSif := IzFmkIni("SpecKol", "ROBA" + ALLTRIM(STR(i)), nil, KUMPATH )

  if cSif <> nil
    AADD(aRoba, { cSif, "ROBA" + ALLTRIM(STR(i)), 0 } )	
  endif

next


return aRoba



// --------------------------------------------------
// vraca matricu sa definicijom polja exp.tabele
// aRoba = [ field_naz, sifra_robe, opis_robe   ] 
// --------------------------------------------------
static function _g_exp_fields( aRoba )
local aFields := {}
local i

AADD(aFields, {"rbr", "C", 10, 0 })
AADD(aFields, {"distrib", "C", 60, 0 })
AADD(aFields, {"pm_idbroj", "C", 13, 0 })
AADD(aFields, {"pm_naz", "C", 100, 0 })
AADD(aFields, {"pm_tip", "C", 20, 0 })
AADD(aFields, {"pm_mjesto", "C", 20, 0 })
AADD(aFields, {"pm_ptt", "C", 10, 0 })
AADD(aFields, {"pm_adresa", "C", 60, 0 })
AADD(aFields, {"pm_kt_br", "C", 20, 0 })

for i := 1 to LEN( aRoba )
	AADD(aFields, { aRoba[i, 2], "N", 15, 5 })
next

AADD(aFields, {"ukupno", "N", 15, 5 })

return aFields


// -------------------------------------------
// filuje export tabelu sa podacima
// -------------------------------------------
static function fill_exp_tbl( cRbr, cDistrib, cPmId, cPmNaz, ;
		cPmTip, cPmMj, cPmPtt, cPmAdr, cPmKtBr, aRoba )
local nArr
local i
local nTotal := 0

nArr := SELECT()

O_R_EXP
append blank
replace field->rbr with cRbr
replace field->distrib with cDistrib
replace field->pm_idbroj with cPmId
replace field->pm_naz with cPmNaz
replace field->pm_tip with cPmTip
replace field->pm_mjesto with cPmMj
replace field->pm_ptt with cPmPtt
replace field->pm_adresa with cPmAdr
replace field->pm_kt_br with cPmKtBr

for i:=1 to LEN( aRoba )
	replace field->&(aRoba[i, 2]) with aRoba[i, 3]
	nTotal += aRoba[i, 3]
next

replace field->ukupno with nTotal 

select (nArr)

return



// ---------------------------------------
// specifikacija prodaje
// ---------------------------------------
function spec_kol_partn()
local nX := 1
local aRoba 
local cPartner
local cRoba
local cIdFirma
local dDatod
local dDatDo
local cFilter
local cDistrib

_o_tables()
O_OPS

cIdfirma:=gFirma
dDatOd:=ctod("")
dDatDo:=date()
cDistrib := PADR("10", 6)

Box("#SPECIFIKACIJA PRODAJE PO PARTNERIMA",12,77)

	cIdFirma:=PADR(cIdFirma,2)
 		
	@ m_x + nX, m_y+2 SAY "RJ            " GET cIdFirma ;
		valid {|| empty(cIdFirma) .or. ;
		cIdFirma==gFirma .or. P_RJ(@cIdFirma) }
 		
	++nX

	@ m_x + nX, m_y+2 SAY "Od datuma "  get dDatOd
 		
	@ m_x + nX, col()+1 SAY "do"  get dDatDo
	
	++nX
	
	@ m_x + nX, m_y+2 SAY "Distributer   " GET cDistrib ;
		valid P_Firma(@cDistrib)
	read
 		
	ESC_BCR
	
BoxC()

// inicijalizuj matricu "aRoba"
aRoba := _g_ini_roba()

if LEN(aRoba) = 0
	msgbeep("potrebno ubaciti u fmk.ini podatke o robi !!!")
	return
endif

aExpFields := _g_exp_fields( aRoba )
t_exp_create(aExpFields)
cLaunch := exp_report()

_o_tables()

select partn
seek cDistrib
cDistNaz := field->naz

select fakt
set order to tag "6"
//idfirma + idpartner + idroba + idtipdok + dtos(datum)

// postavi filter
cFilter := "idtipdok == '10' "

if (!empty(dDatOd) .or. !empty(dDatDo))
	cFilter+=".and.  datdok>=" + Cm2Str(dDatOd) + " .and. datdok<="+Cm2Str(dDatDo)
endif

if (!empty(cIdFirma))
	cFilter+=" .and. IdFirma=" + Cm2Str(cIdFirma)
endif

// postavi filter
set filter to &cFilter 

select fakt
go top

nCount := 0

Box( , 2, 50)

@ m_x + 1, m_y + 2 SAY "generisem podatke za xls...."

do while !EOF() .and. field->idfirma == cIdFirma
	
	// resetuj aroba matricu
	_reset_aroba( @aRoba )

	cPartner := field->idpartner
	
	lUbaci := .f.
	
	// idi za jednog partnera
	do while !EOF() .and. field->idfirma == cIdFirma ;
			.and. field->idpartner == cPartner 
			
		cRoba := field->idroba
		nKol := field->kolicina
		
		nScan := ASCAN( aRoba, {|xvar| xvar[1] == ALLTRIM(cRoba)  })

		// ubaci u matricu...
		if nScan <> 0

			lUbaci := .t.
			
			aRoba[ nScan, 3 ] := aRoba[ nScan, 3 ] + nKol	
			
			@ m_x + 2, m_y + 2 SAY "  scan: " + cRoba
		endif
		
		skip
	
	enddo

	if lUbaci == .t.
		
		select partn
		seek cPartner
		select fakt

		fill_exp_tbl( ;
			ALLTRIM(STR(++nCount)), ;
			cDistNaz, ;
			IzSifK( "PARTN", "REGB", cPartner, .f.), ;
			partn->naz, ;
			IzSifK( "PARTN", "TIP", cPartner, .f. ), ;
			partn->mjesto, ;
			partn->ptt, ;
			partn->adresa, ;
			_k_br(cPartner), ;
			aRoba )

	endif

enddo

BoxC()

tbl_export( cLaunch )

return

// ----------------------------------------
// vraca broj kuce partnera
// djemala bijedica "22" <-----
// ----------------------------------------
static function _k_br( cPartn )
local cTmp := "bb"
local cRet := ""

cRet := IzSifK("PARTN", "KBR", cPartn, .f. )

if EMPTY(cRet)
	cRet := cTmp
endif
return cRet


// -----------------------------------------------
// resetuj vrijednosti u aRoba matrici
// -----------------------------------------------
static function _reset_aroba( aRoba )
local i

for i:=1 to LEN(aRoba)
	aRoba[i, 3] := 0
next

return


