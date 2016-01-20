/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// --------------------------------------
// otvara tabele za unos podataka
// --------------------------------------
function o_pk_tbl()

select F_PK_RADN
if !used()
	O_PK_RADN
endif

select F_PK_DATA
if !used()
	O_PK_DATA
endif

return



// ------------------------------------------
// brisanje poreske kartice radnika
// ------------------------------------------
function pk_delete( cIdRadn )
local nTA

if Pitanje(,"Izbrisati podatke poreske kartice radnika ?", "N") == "N"
	return
endif

nTA := SELECT()
nCnt := 0

o_pk_tbl()

f18_lock_tables({"ld_pk_radn"})
sql_table_update( nil, "BEGIN" )

// izbrisi pk_radn
select pk_radn
go top
seek cIdRadn

do while !EOF() .and. field->idradn == cIdRadn

	_del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "ld_pk_radn", _del_rec, 1, "CONT" )

	++ nCnt
	skip

enddo

// izbrisi pk_data
select pk_data
go top
seek cIdRadn

if FOUND()
    _del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "ld_pk_data", _del_rec, 2, "CONT" )
endif

f18_free_tables({"ld_pk_radn"})
sql_table_update( nil, "END" )

if nCnt > 0 
	msgbeep("Izbrisano " + ALLTRIM(STR(nCnt)) + " zapisa !")
endif

return 


// ------------------------------------
// vraca novi zahtjev 
// ------------------------------------
function n_zahtjev()
local nRet := 0
local nTArea := SELECT()
local nBroj := 9999999

select pk_radn
set order to tag "2"

seek nBroj
skip -1

if field->zahtjev = 0
	nRet := 1
else
	nRet := field->zahtjev + 1
endif

set order to tag "1"

select (nTArea)
return nRet



// --------------------------------
// vraca srodstvo za "kod"
// --------------------------------
function g_srodstvo( nId )
local cRet := "???"
local aPom
local nScan

// napuni matricu sa srodstvima
aPom := a_srodstvo()

nScan := ASCAN( aPom, {|xVal| xVal[1] = nId } )

if nScan <> 0
	cRet := aPom[ nScan, 2 ]
endif

return cRet



// ---------------------------------------------
// vraca matricu popunjenu sa srodstvima
// ---------------------------------------------
function a_srodstvo()
local aRet := {}

AADD( aRet, { 1, "Otac" } )
AADD( aRet, { 2, "Majka" } )
AADD( aRet, { 3, "Otac supruznika" } )
AADD( aRet, { 4, "Majka supruznika" } )
AADD( aRet, { 5, "Sin" } )
AADD( aRet, { 6, "Kcerka" } )
AADD( aRet, { 7, "Unuk" } )
AADD( aRet, { 8, "Unuka" } )
AADD( aRet, { 9, "Djed" } )
AADD( aRet, { 10, "Baka" } )
AADD( aRet, { 11, "Djed supruznika" } )
AADD( aRet, { 12, "Baka supruznika" } )
AADD( aRet, { 13, "Bivsi supruznik" } )
AADD( aRet, { 14, "Poocim" } )
AADD( aRet, { 15, "Pomajka" } )
AADD( aRet, { 16, "Poocim supruznika" } )
AADD( aRet, { 17, "Pomajka supruznika" } )
AADD( aRet, { 18, "Pocerka" } )
AADD( aRet, { 19, "Posinak" } )

return aRet


// -----------------------------------------
// lista srodstva u GET rezimu na unosu
// odabir srodstva
// -----------------------------------------
function sr_list( nSrodstvo )
local nXX := m_x
local nYY := m_y

if nSrodstvo > 0
	return .t.
endif

// napuni matricu sa srodstvima
aSrodstvo := a_srodstvo()

// odaberi element
nSrodstvo := _pick_srodstvo( aSrodstvo )

m_x := nXX
m_y := nYY

return .t.

// -----------------------------------------
// uzmi element...
// -----------------------------------------
static function _pick_srodstvo( aSr )
local nChoice := 1
local nRet
local i
local cPom
private GetList:={}
private izbor := 1
private opc := {}
private opcexe := {}

for i:=1 to LEN( aSr )

	cPom := PADL( ALLTRIM(STR( aSr[i, 1] )), 2 ) + ". " + PADR( aSr[i, 2] , 20 )
	
	AADD(opc, cPom)
	AADD(opcexe, {|| nChoice := izbor, izbor := 0 })
	
next

Menu_sc("izbor")

if LastKey() == K_ESC

	nChoice := 0
	nRet := 0
	
else
	nRet := aSr[ nChoice, 1 ]
endif

return nRet


// -------------------------------------------------
// vraca odbitak za clanove po identifikatoru
// -------------------------------------------------
function lo_clan( cIdent, cIdRadn )
local nOdb := 0
local nTArea := SELECT()

select pk_data
set order to tag "1"

seek cIdRadn + cIdent

do while !EOF() .and. field->idradn == cIdRadn ;
		.and. field->ident == cIdent

	nOdb += field->koef
	skip
enddo

select (nTArea)
return nOdb


// ----------------------------------------------
// setovanje datuma za sve poreske kartice
// ----------------------------------------------
function pk_set_date()
local nTArea := SELECT()
local dN_date
local dT_date
local cGrDate
local nCnt := 0
local _rec

if g_date( @dT_date, @dN_date, @cGrDate ) == 0
	return
endif

select pk_radn
set order to tag "1"

go top

do while !EOF()
	
	if ( cGrDate == "D" )
		if ( field->datum <= dT_date )
            _rec := dbf_get_rec()
            _rec["datum"] := dN_date
            update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )
			++ nCnt 
		endif
	else
        _rec := dbf_get_rec()
        _rec["datum"] := dN_date
        update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )
		++ nCnt 
	endif
	
	skip
enddo

if nCnt > 0
	msgbeep("izvrsene " + ALLTRIM(STR(nCnt)) + " promjene !!!")
endif

select (nTArea)

return


static function g_date( dTmp_date, dDate, cGrDate )
local nRet := 1
private GetList := {}

dDate := CTOD("01.01.09")
dTmp_date := DATE()
cGrDate := "N"

box(, 4, 65 )
	@ m_x + 1, m_y + 2 SAY "postavi tekuci datum na:" GET dDate
	@ m_x + 2, m_y + 2 SAY "gledati granicni datum ?" GET cGrDate ;
		VALID cGrDate $ "DN" PICT "@!"
	read
	
	if cGrDate == "D"
		@ m_x + 3, m_y + 2 SAY "<= od" GET dTmp_Date
		read
	endif
	
boxc()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet


