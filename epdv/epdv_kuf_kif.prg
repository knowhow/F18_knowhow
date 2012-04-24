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


#include "epdv.ch"

// -------------------------------------------
// azuriranje kufa
// -------------------------------------------
function azur_kif()
return azur_ku_ki("KIF")

// -------------------------------------------
// azuriranje kif-a
// -------------------------------------------
function azur_kuf()
return azur_ku_ki("KUF")


// -------------------------------------------
// povrat kuf dokument
// -------------------------------------------
function pov_kuf( nBrDok )
return pov_ku_ki("KUF", nBrDok )

// -------------------------------------------
// povrat kif dokument
// -------------------------------------------
function pov_kif(nBrDok)
return pov_ku_ki("KIF", nBrDok)


// -------------------------------------------
// -------------------------------------------
function azur_ku_ki(cTbl)
local nBrDok
local _rec
public __br_dok := 0

if cTbl == "KUF"
	o_kuf(.t.)
	// privatno podrucje
	nPArea := F_P_KUF
	
	// kumulativ 
	nKArea := F_KUF
else
	o_kif(.t.)
	nPArea := F_P_KIF
	nKArea := F_KIF
endif


Box(, 2, 60)

nCount := 0

SELECT (nPArea)
if RECCOUNT2() == 0
	return 0
endif

nNextGRbr:= next_g_r_br(cTbl)


SELECT (nPArea)
GO TOP

// novi dokument je u pripremi i nema uopste postavljen
// broj dokumenta
if (field->br_dok == 0)
	nNextBrDok := next_br_dok(cTbl)
	nBrdok := nNextBrDok
else
	nBrDok := field->br_dok
endif

// azuriraj u sql bazu
if kuf_kif_azur_sql( cTbl, nNextGRbr, nBrDok )
	
	select (nPArea)
	go top

	// azuriraj podatke u dbf
	do while !eof()
	
        set_global_memvars_from_dbf()
	
		// datum azuriranja
		_datum_2 := DATE()
		_g_r_br := nNextGRbr
	
		_br_dok := nBrDok
		__br_dok := _br_dok

		++nCount
		@ m_x+1, m_y+2 SAY PADR("Dodajem P_KIF -> KUF " + transform(nCount, "9999"), 40)
		@ m_x+2, m_y+2 SAY PADR("   "+ cTbl +" G.R.BR: " + transform(nNextGRbr, "99999"), 40)

		nNextGRbr ++
	
		SELECT (nKArea)
		APPEND BLANK

        _rec := get_dbf_global_memvars()
        dbf_update_rec( _rec )

		select (nPArea)
		SKIP
	enddo

else

	msgbeep("Neuspjesno azuriranje epdv/sql !")
	return 

endif

SELECT (nKArea)
use

@ m_x+1, m_y+2 SAY PADR("Brisem pripremu ...", 40)

// sve je ok brisi pripremu
SELECT (nPArea)
zap
use

if (cTbl == "KUF")
	o_kuf(.t.)
else
	o_kuf(.t.)
endif	

BoxC()

MsgBeep("Azuriran je " + cTbl + " dokument " + STR( __br_dok, 6, 0) )

return __br_dok



// azuriranje kuf, kif tabela u sql
function kuf_kif_azur_sql( tbl, next_g_rbr, next_br_dok )
local lOk := .t.
local record := hb_hash()
local _tbl_epdv
local _i
local _tmp_id
local _ids := {}
local __area

if tbl == "KIF"
	__area := F_P_KIF
elseif tbl == "KUF"
	__area := F_P_KUF
endif

// npr. LOWER( "KUF" )
_tbl_epdv := "epdv_" + LOWER( tbl )

lock_semaphore( _tbl_epdv, "lock" )

lOk := .t.

if lOk = .t.

  // azuriraj kuf
  MsgO( "sql " + _tbl_epdv )

  select ( __area )
  go top

  sql_table_update( nil, "BEGIN")

  do while !eof()

   record := dbf_get_rec()	  
   record["datum_2"] := DATE()
   record["br_dok"] := next_br_dok
   record["g_r_br"] := next_g_rbr

   if tbl == "KIF"
   		record["src_pm"] := field->src_pm
   endif
               
   _tmp_id := PADR( ALLTRIM( STR( record["br_dok"], 6 ) ), 6 ) 
   
   if !sql_table_update(_tbl_epdv, "ins", record )
       		lOk := .f.
       		exit
   	endif

   skip

  enddo

  MsgC()

endif

if !lOk

	// vrati sve nazad...  	
	sql_table_update(nil, "ROLLBACK")

else
	
	// napravi update-e
	// zavrsi transakcije 
 
	AADD( _ids, _tmp_id )

	update_semaphore_version( _tbl_epdv, .t. )
	push_ids_to_semaphore( _tbl_epdv, _ids ) 
  	
	sql_table_update(nil, "END")

endif

lock_semaphore( _tbl_epdv, "free" )

return lOk



// -------------------------------------------
// povrat kuf/kif dokumenata u pripremu
// -------------------------------------------
function pov_ku_ki( cTbl, nBrDok )
local _del_rec, _ok
local _rec
local _p_area
local _k_area
local _cnt
local _table

if (cTbl == "KUF")
	o_kuf(.t.)
	// privatno podrucje
	_p_area := F_P_KUF
	// kumulativ 
	_k_area := F_KUF
	_table := "epdv_kuf"
else
	o_kif(.t.)
	_p_area := F_P_KIF
	_k_area := F_KIF
	_table := "epdv_kif"
endif

_cnt := 0

SELECT ( _k_area )
set order to tag "BR_DOK"
seek STR(nBrdok, 6, 0)


if !found()
	SELECT ( _p_area )
	return 0
endif

SELECT ( _p_area )
if RECCOUNT2()>0
	MsgBeep("U pripremi postoji dokument#ne moze se izvrsiti povrat#operacija prekinuta !")
	return -1
endif

Box(, 2, 60)
SELECT ( _k_area )

// dodaj u pripremu dokument
do while !eof() .and. (br_dok == nBrDok)
	
	++ _cnt
	@ m_x+1, m_y+2 SAY PADR("P_" + cTbl +  " -> " + cTbl + " :" + transform( _cnt, "9999"), 40)
	
	SELECT ( _k_area )
	_rec := dbf_get_rec()
	
	SELECT ( _p_area )
	// dodaj zapis
	APPEND BLANK
	dbf_update_rec( _rec )
	
	// kumulativ tabela
	SELECT ( _k_area )
	SKIP	
enddo

if ( cTbl == "KUF" )
	o_kuf(.t.)
else
	o_kif(.t.)
endif	

SELECT ( _k_area )
set order to tag "BR_DOK"
seek STR(nBrdok, 6, 0)

// setuj zapis koji zelis obrisati
_del_rec := dbf_get_rec()

_ok := .t.

MsgO("del " + cTbl )

my_use_semaphore_off()
sql_table_update( nil, "BEGIN" )

_ok := delete_rec_server_and_dbf( _table, _del_rec, 2, "CONT" )

sql_table_update( nil, "END" )
my_use_semaphore_on()
    
MsgC()

if !_ok
  MsgBeep("Operacija brisanja dokumenta nije uspjesna, dokument: " + ALLTRIM( STR( nBrDok )) )
endif

SELECT ( _k_area )
use

if ( cTbl == "KUF" )
	o_kuf(.t.)
else
	o_kif(.t.)
endif	

BoxC()

if _ok
    MsgBeep("Izvrsen je povrat dokumenta " + STR( nBrDok, 6, 0) + " u pripremu" )
endif

return nBrDok


// --------------------------------------
// renumeracija rednih brojeva - priprema
// --------------------------------------
function renm_rbr(cTbl, lShow)
local _rec

if lShow == nil
	lShow := .t.
endif

if cTbl == "P_KUF"
	SELECT F_P_KUF
	if !used()
		O_P_KUF
	endif
	
elseif cTbl == "P_KIF"
	SELECT F_P_KIF
	
	SELECT F_P_KIF
	if !used()
		O_P_KIF
	endif
endif

SET ORDER TO TAG "datum"
// "datum" - "dtos(datum)+src_br_2"
GO TOP
nRbr := 1

do while !eof()
    _rec := dbf_get_rec()
    _rec["r_br"] := nRbr
    dbf_update_rec( _rec )
	++nRbr
	SKIP
enddo

if lShow
	MsgBeep("Renumeracija izvrsena")
endif

return


// --------------------------------------
// renumeracija rednih brojeva - priprema
// --------------------------------------
function renm_g_rbr(cTbl, lShow)
local nRbr, _rec
local nLRbr

if lShow == nil
	lShow := .t.
endif

if cTbl == "KUF"
	SELECT F_KUF
	if !used()
		O_KUF
	endif
	
elseif cTbl == "P_KIF"
	SELECT F_KIF
	
	SELECT F_KIF
	if !used()
		O_KIF
	endif
endif

SET ORDER TO TAG "l_datum"
// "l_datum" - "lock+tos(datum)+src_br_2"

SET SOFTSEEK ON
SEEK "DZ" 
SKIP -1
if lock == "D"
	// postljednji zauzet broj
	nLRbr := g_r_br
else
	nLRbr := 0
endif

PRIVATE cFilter := "!(lock == 'D')"

// iskljuci lockovane slogove 
SET FILTER TO &cFilter
GO TOP

Box(,3, 60)
nRbr:= nLRbr
do while !eof()

 	++nRbr
	@ m_x+1, m_y+2 SAY cTbl + ":" + STR(nRbr, 8, 0)	
    _rec := dbf_get_rec()
    _rec["g_r_br"] := nRbr
    dbf_update_rec( _rec )	
	
	++nRbr
	SKIP
enddo
BoxC()

USE

if lShow
	MsgBeep( cTbl + " : G.Rbr Renumeracija izvrsena")
endif

return

