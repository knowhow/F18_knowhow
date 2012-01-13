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


#include "rnal.ch"


// ------------------------------------------------
// otvori tabele potrebne za rad sa RNAL
// lTemporary - .t. i pripremne tabele
// ------------------------------------------------
function o_tables(lTemporary)

if lTemporary == nil
	lTemporary := .f.
endif

// otvori sifrarnike
o_sif_tables()

select F_FMKRULES
if !used()
	O_FMKRULES
endif

select F_DOCS
if !used()
	O_DOCS
endif

select F_DOC_IT
if !used()
	O_DOC_IT
endif

select F_DOC_IT2
if !used()
	O_DOC_IT2
endif

select F_DOC_OPS
if !used()
	O_DOC_OPS
endif

select F_DOC_LOG
if !used()
	O_DOC_LOG
endif

select F_DOC_LIT
if !used()
	O_DOC_LIT
endif

if lTemporary == .t.

	SELECT (F__DOCS)
	if !used()
		O__DOCS
	endif

	SELECT (F__DOC_IT)
	if !used()
		O__DOC_IT
	endif
	
	SELECT (F__DOC_IT2)
	if !used()
		O__DOC_IT2
	endif

	SELECT (F__DOC_OPS)
	if !used()
		O__DOC_OPS
	endif

	SELECT (F__FND_PAR)
	if !used()
		O__FND_PAR
	endif
	
endif

return

// -----------------------------------------
// otvara tabele sifrarnika 
// -----------------------------------------
function o_sif_tables()

select F_E_GROUPS
if !used()
	O_E_GROUPS
endif

select F_E_GR_ATT
if !used()
	O_E_GR_ATT
endif

select F_E_GR_VAL
if !used()
	O_E_GR_VAL
endif

select F_ARTICLES
if !used()
	O_ARTICLES
endif

select F_ELEMENTS
if !used()
	O_ELEMENTS
endif

select F_E_AOPS
if !used()
	O_E_AOPS
endif

select F_E_ATT
if !used()
	O_E_ATT
endif

select F_CUSTOMS
if !used()
	O_CUSTOMS
endif

select F_CONTACTS
if !used()
	O_CONTACTS
endif

select F_OBJECTS
if !used()
	O_OBJECTS
endif

select F_AOPS
if !used()
	O_AOPS
endif

select F_AOPS_ATT
if !used()
	O_AOPS_ATT
endif

select F_RAL
if !used()
	O_RAL
endif

select F_SIFK
if !used()
	O_SIFK
endif

select F_SIFV
if !used()
	O_SIFV
endif

select F_ROBA
if !used()
	O_ROBA
endif

return



// -----------------------------
// otvori tabelu _TMP1
// -----------------------------
function o_tmp1()
select F__TMP1
if !used()
	O__TMP1
endif
return



// -----------------------------
// otvori tabelu _TMP2
// -----------------------------
function o_tmp2()
select F__TMP2
if !used()
	O__TMP2
endif
return

// -----------------------------------------
// konvert doc_no -> STR(doc_no, 10)
// -----------------------------------------
function doc_str(nId)
return STR(nId, 10)


// -----------------------------------------
// konvert doc_no -> STR(doc_no, 10)
// -----------------------------------------
function docno_str(nId)
return STR(nId, 10)


// -----------------------------------------
// konvert doc_op -> STR(doc_op, 4)
// -----------------------------------------
function docop_str(nId)
return STR(nId, 4)


// -----------------------------------------
// konvert doc_it -> STR(doc_it, 4)
// -----------------------------------------
function docit_str(nId)
return STR(nId, 4)



// -------------------------------------------
// setuje novi zapis u tabeli sifrarnika
// nId - id sifrarnika
// cIdField - naziv id polja....
// -------------------------------------------
function _set_sif_id(nId, cIdField, lAuto )
local nTArea := SELECT()
local nTime
local cIndex
local _rec
private GetList:={}

if lAuto == nil
	lAuto := .f.
endif

if !(FLOCK())
	
	if gInsTimeOut == nil
		nTime := 150     
	else
		nTime := gInsTimeOut
	endif
	
      	Box(,1,40)

	do while nTime > 0
        	
		InkeySc(.125)
         	
		@ m_x + 1, m_y + 2 SAY "timeout: " + ALLTRIM(STR(nTime))

		-- nTime
         	
		if FLOCK()
          		exit
        	endif

		sleep(1)

      	enddo

	BoxC()
	
      	if nTime == 0 .AND. !(FLOCK())
        	Beep (2)
         	MsgBeep("Dodavanje nove stavke onemoguceno !!!#Pokusajte ponovo...")
         	return 0
      	endif
endif

if cIdField == "ART_ID"
	cIndex := "1"
else
	cIndex := "2"
endif

_inc_id(@nId, cIdField, cIndex, lAuto )

set_global_memvars_from_dbf()

appblank2(.f., .f.)   

cIdField := "_" + cIdField

&cIdField := nId

_rec := hb_hash()
_rec := get_dbf_global_memvars()        
dbf_update_rec( _rec )
        
DBUnlock()

select (nTArea)

return 1


// ------------------------------------------
// kreiranje tabele PRIVPATH + _TMP1
// ------------------------------------------
function cre_tmp1( aFields )
local cTbName := "_TMP1"

if LEN(aFields) == 0
	MsgBeep("Nema definicije polja u matrici!")
	return
endif

_del_tmp( PRIVPATH + cTbName + ".DBF" )  

DBcreate2(PRIVPATH + cTbName + ".DBF", aFields)

return

// ------------------------------------------
// kreiranje tabele PRIVPATH + _TMP1
// ------------------------------------------
function cre_tmp2( aFields )
local cTbName := "_TMP2"

if LEN(aFields) == 0
	MsgBeep("Nema definicije polja u matrici!")
	return
endif

_del_tmp( PRIVPATH + cTbName + ".DBF" )  

DBcreate2(PRIVPATH + cTbName + ".DBF", aFields)

return



// --------------------------------------------
// brisanje fajla 
// --------------------------------------------
static function _del_tmp( cPath )
if FILE( cPath )
	FERASE( cPath )
endif
return


// ----------------------------------------------
// promjena broja naloga 
// servisna opcija, zasticena password-om
// ----------------------------------------------
function ch_doc_no( old_doc )
local _new_no := old_doc
local _repl := .t.

if !SigmaSif("PRBRNO")
	return .f.
endif

Box(, 1, 50)
	@ m_x + 1, m_y + 2 SAY "setuj novi broj:" GET _new_no
	read
BoxC()

if LastKey() == K_ESC
	msgbeep("Prekinuta operacija !")
	return .f.
endif

// prodji kroz tabele i promjeni broj
// tabele su:
//
// - docs
// - doc_it
// - doc_it2
// - doc_ops

// odmah zamjeni u tabeli docs, jer se na njoj nalazis
if field->doc_no == old_doc
	replace field->doc_no with _new_no
else
	_repl := .t.
endif

if _repl == .f.
	msgbeep("Nisam nista zamjenio !!!")
	return .f.
endif

// doc_it
select doc_it
set order to tag "1"
go top

seek docno_str( old_doc )

if FOUND()
	set order to 0
	do while !EOF() .and. field->doc_no == old_doc
		replace field->doc_no with _new_no
		skip
	enddo
endif

// doc_it2
select doc_it2
set order to tag "1"
go top

seek docno_str( old_doc )

if FOUND()
	set order to 0
	do while !EOF() .and. field->doc_no == old_doc
		replace field->doc_no with _new_no
		skip
	enddo
endif

// doc_ops
select doc_ops
set order to tag "1"
go top

seek docno_str( old_doc )

if FOUND()
	set order to 0
	do while !EOF() .and. field->doc_no == old_doc
		replace field->doc_no with _new_no
		skip
	enddo
endif

return .t.


