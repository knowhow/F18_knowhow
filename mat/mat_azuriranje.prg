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

if !_stampan_nalog()
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
	if !_mat_azur_dbf()
		msgbeep( "Problem sa azuriranjem mat/dbf !" )
	endif
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
local _ids := {}
local record
local _tmp_id
local _tbl_suban
local _tbl_anal
local _tbl_sint
local _tbl_nalog
local _i

_tbl_suban := "mat_suban"
_tbl_anal := "mat_anal"
_tbl_nalog := "mat_nalog"
_tbl_sint := "mat_sint"

for _i := 1 to SEMAPHORE_LOCK_RETRY_NUM
	
	// lock suban  
	if get_semaphore_status( _tbl_suban ) == "lock"
    	MsgBeep("tabela zakljucana: " + _tbl_suban )
      	hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
  	else
    	lock_semaphore( _tbl_suban, "lock" )
  	endif

	// lock anal  
	if get_semaphore_status( _tbl_anal ) == "lock"
    	MsgBeep("tabela zakljucana: " + _tbl_anal )
      	hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
  	else
    	lock_semaphore( _tbl_anal, "lock" )
  	endif
	
	// lock sint
	if get_semaphore_status( _tbl_sint ) == "lock"
    	MsgBeep("tabela zakljucana: " + _tbl_sint )
      	hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
  	else
    	lock_semaphore( _tbl_sint, "lock" )
  	endif
	
	// lock nalog
	if get_semaphore_status( _tbl_nalog ) == "lock"
    	MsgBeep("tabela zakljucana: " + _tbl_nalog )
      	hb_IdleSleep( SEMAPHORE_LOCK_RETRY_IDLE_TIME )
  	else
    	lock_semaphore( _tbl_nalog, "lock" )
  	endif

next
   

if _ok = .t.
  
  MsgO("sql mat_suban")
  
  record := hb_hash()

  select mat_psuban
  go top

  sql_mat_suban_update("BEGIN")
  
  do while !eof()
 
     record["id_firma"] := field->IdFirma
     record["id_vn"] := field->IdVn
     record["br_nal"] := field->BrNal
     _tmp_id := record["id_firma"] + record["id_vn"] + record["br_nal"]

     record["r_br"] := field->Rbr
     record["dat_dok"] := field->DatDok
     record["id_roba"] := field->idroba
     record["id_konto"] := field->idkonto
     record["id_partner"] := field->IdPartner
     record["d_p"] := field->d_p
     record["iznos"] := field->iznos
     record["iznos2"] := field->iznos2
     record["id_tip_dok"] := field->IdTipDok
     record["br_dok"] := field->brdok
     record["u_i"] := field->u_i
     record["kolicina"] := field->kolicina
     record["id_zaduz"] := field->idzaduz
     record["dat_kurs"] := field->datkurs
     record["k1"] := field->k1
     record["k2"] := field->k2
     record["k3"] := field->k3
     record["k4"] := field->k4

     if !sql_mat_suban_update("ins", record )
       _ok := .f.
       exit
     endif

     skip
  
  enddo

  MsgC()

endif

// idi dalje, na anal ... ako je ok
if _ok = .t.
  
  MsgO("sql mat_anal")

  record := hb_hash()

  select mat_panal
  go top
  
  sql_mat_anal_update("BEGIN")
  
  do while !eof()
 
   record["id_firma"] := field->IdFirma
   record["id_vn"] := field->IdVn
   record["br_nal"] := field->BrNal
   record["r_br"] := field->Rbr
   record["dat_nal"] := field->Datnal
   record["id_konto"] := field->IdKonto
   record["dug"] := field->dug
   record["pot"] := field->pot
   record["dug2"] := field->dug2
   record["pot2"] := field->pot2

   if !sql_mat_anal_update("ins", record )
       _ok := .f.
       exit
    endif
   skip
  enddo

  MsgC()

endif


// idi dalje, na sint ... ako je ok
if _ok = .t.
  
  MsgO("sql mat_sint")

  record := hb_hash()

  select mat_psint
  go top
  
  sql_mat_sint_update("BEGIN")
  
  do while !eof()
 
   record["id_firma"] := field->IdFirma
   record["id_vn"] := field->IdVn
   record["br_nal"] := field->BrNal
   record["r_br"] := field->Rbr
   record["dat_nal"] := field->Datnal
   record["id_konto"] := LEFT( field->IdKonto, 3 )
   record["dug"] := field->dug
   record["pot"] := field->pot
   record["dug2"] := field->dug2
   record["pot2"] := field->pot2

   if !sql_mat_sint_update("ins", record )
       _ok := .f.
       exit
    endif
   skip
  enddo

  MsgC()

endif


// idi dalje, na nalog ... ako je ok
if _ok = .t.
  
  MsgO("sql mat_nalog")

  record := hb_hash()

  select mat_pnalog
  go top

  sql_mat_nalog_update("BEGIN")

  do while !eof()
 
   record["id_firma"] := field->IdFirma
   record["id_vn"] := field->IdVn
   record["br_nal"] := field->BrNal
   record["dat_nal"] := field->Datnal
   record["dug"] := field->dug
   record["pot"] := field->pot
   record["dug2"] := field->dug2
   record["pot2"] := field->pot2

   if !sql_mat_nalog_update("ins", record )
       _ok := .f.
       exit
    endif
   skip
  enddo

  MsgC()

endif


if ! _ok

	// vrati sve promjene...  	
	sql_mat_suban_update( "ROLLBACK" )
	sql_mat_sint_update( "ROLLBACK" )
	sql_mat_anal_update( "ROLLBACK" )
	sql_mat_nalog_update( "ROLLBACK" )

else

	// dodaj ids
  	AADD(_ids, _tmp_id) 
	
	// suban  
	update_semaphore_version( _tbl_suban, .t.)
  	push_ids_to_semaphore( _tbl_suban, _ids )
  	sql_mat_suban_update("END")

	// anal
	update_semaphore_version( _tbl_anal, .t.)
  	push_ids_to_semaphore( _tbl_anal, _ids )
  	sql_mat_anal_update("END")
	
	// sint
	update_semaphore_version( _tbl_sint, .t.)
  	push_ids_to_semaphore( _tbl_sint, _ids )
  	sql_mat_sint_update("END")
	
	// nalog
	update_semaphore_version( _tbl_nalog, .t.)
  	push_ids_to_semaphore( _tbl_nalog, _ids )
  	sql_mat_nalog_update("END")

endif

// otkljucaj sve tabele
lock_semaphore(_tbl_suban, "free")
lock_semaphore(_tbl_anal, "free")
lock_semaphore(_tbl_sint, "free")
lock_semaphore(_tbl_nalog, "free")

return _ok




// --------------------------------------------------
// azuriranje mat naloga u dbf
// --------------------------------------------------
static function _mat_azur_dbf()
local _ret := .t.
local _vars

Box(,7,30,.f.)

	
	@ m_x + 1, m_y + 2 SAY "ANALITIKA"
	select mat_panal
	go top

	do while !EOF()
		
		_vars := dbf_get_rec() 
		
		select mat_anal
		append blank
		
		update_rec_dbf_and_server(_vars)
		
		select mat_panal
		skip
	
	enddo

	select mat_panal
	zapp()

	@ m_x + 3, m_y + 2 SAY "SINTETIKA"
	select mat_psint
	go top

	do while !EOF()
		
		_vars := dbf_get_rec() 
		
		select mat_sint
		append blank
		
		update_rec_dbf_and_server( _vars )
		
		select mat_psint
		skip
	
	enddo

	select mat_psint
	zapp()

	@ m_x + 5, m_y + 2 SAY "NALOZI"
	select mat_pnalog
	go top

	do while !EOF()
		
		_vars := dbf_get_rec() 
		
		select mat_nalog
		append blank
		
		update_rec_dbf_and_server( _vars )
		
		select mat_pnalog
		skip
	
	enddo

	select mat_pnalog
	zapp()

	@ m_x + 7, m_y + 2 SAY "SUBANALITIKA"
	select mat_psuban
	go top

	do while !EOF()
		
		_vars := dbf_get_rec() 
		
		select mat_suban
		append blank
		
		update_rec_dbf_and_server( _vars )
		
		select mat_psuban
		skip
	
	enddo

	select mat_psuban
	zapp()

	select mat_pripr
	zapp()

	Inkey(2)

BoxC()

return _ret




