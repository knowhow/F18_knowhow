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


#include "mat.ch"



// ----------------------------------------------------
// otvori tabele prije azuriranja
// ----------------------------------------------------
static function _o_tbls()
O_PARTN
O_MAT_PRIPR
O_MAT_SUBAN
O_MAT_PSUBAN
O_MAT_ANAL
O_MAT_PANAL
O_MAT_SINT
O_MAT_PSINT
O_MAT_NALOG
O_MAT_PNALOG
O_ROBA
return



// -------------------------------------------------------------
// razno-razne provjere dokumenta prije samog azuriranja
// -------------------------------------------------------------
static function _provjera_dokumenta()
local _valid := .t.

if !stampan_nalog()
	_valid := .f.
	return _valid
endif

if !_ispravne_sifre()
	_valid := .f.
	return _valid
endif

return _valid


// ---------------------------------------------------
// provjera sifara koristenih u dokumentu 
// ---------------------------------------------------
static function _ispravne_sifre()
local _valid := .t.

// kontrola ispravnosti sifara artikala
select mat_psuban
go top

do while !EOF()

	// provjeri prvo robu	
	select roba
	hseek mat_psuban->idroba
  	
	if !found()
    	Beep(1)
    	Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra artikla!")
    	_valid := .f.
		exit
  	endif
  
	// provjeri partnere
	select partn
	hseek mat_psuban->idpartner
  	
	if !found() .and. !EMPTY(mat_psuban->idpartner)
    	Beep(1)
    	Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra partnera!")
  		_valid := .f.
		exit
	endif
  	
	select mat_psuban
  	skip 1

enddo

// pobrisi tabele ako postoji problem
if !_valid

	select mat_psuban
	zapp()
    select mat_panal
	zapp()
    select mat_psint
	zapp()
    
endif

return _valid


// -----------------------------------------------------
// da li je nalog stampan prije azuriranja
// -----------------------------------------------------
static function _stampan_nalog()
local _valid := .t.

select mat_psuban
if reccount2() == 0
	_valid := .f.
endif

select mat_panal
if reccount2() == 0
	_valid := .f.
endif

select mat_psint
if reccount2() == 0
	_valid := .f. 
endif

if !_valid
	Beep(3)
  	Msg( "Niste izvrsili stampanje naloga ...", 10 )
endif

return _valid



// ----------------------------------------------------
// centralna funkcija za azuriranje mat naloga
// ----------------------------------------------------
function azur_mat()

if Pitanje(,"Sigurno zelite izvrsiti azuriranje (D/N)?","N")=="N"
	return
endif

// otvori potrebne tabele
_o_tbls()

// napravi bazne provjere dokumenta prije azuriranja
if !_provjera_dokumenta()
	close all
	return
endif

// azuriraj u sql
if _mat_azur_sql()
	// azuriraj u dbf
	_mat_azur_dbf()
else
	msgbeep( "Problem sa azuriranjem mat/sql !" )
endif

close all

return


// --------------------------------------------------
// azuriranje mat naloga u sql bazu
// --------------------------------------------------
static function _mat_azur_sql()
local _ok := .t.


return _ok




// --------------------------------------------------
// azuriranje mat naloga u dbf
// --------------------------------------------------
static function _mat_azur_dbf()
local _ret := .t.

Box(,7,30,.f.)
	
	// azuriranje mat_anal
	select mat_anal
	APPEND FROM mat_panal
	@ m_x+1,m_y+2 SAY "ANALITIKA"
	select mat_panal
	zapp()

	// azuriranje mat_sint
	select mat_sint
	APPEND FROM mat_psint
	@ m_x+3,m_y+2 SAY "SINTETIKA  "
	select mat_psint
	zapp()

	// azuriranje mat_nalog
	select mat_nalog
	APPEND FROM mat_pnalog
	@ m_x+5,m_y+2 SAY "NALOZI     "
	select mat_pnalog
	zapp()

	// azuriranje mat_suban...
	select mat_suban
	APPEND FROM mat_psuban
	@ m_x+7,m_y+2 SAY "SUBANALITIKA "
	
	select mat_psuban
	go top

	// brise pripremu
	do while !EOF()

   	   	select mat_pripr
   		seek mat_psuban->(idfirma+idvn+brnal)
   		if found()
			dbdelete2()
		endif

   		select mat_psuban
   		skip

	enddo

	// pobrisi i mat_suban
	select mat_psuban
	zapp()

	select mat_pripr
	__dbpack()

	Inkey(2)

BoxC()

return _ret




