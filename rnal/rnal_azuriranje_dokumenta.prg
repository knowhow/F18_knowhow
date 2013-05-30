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


#include "rnal.ch"


static __doc_no
static __doc_stat
static __doc_desc


// -------------------------------------------
// azuriranje dokumenta u kumulativnu bazu
// cDesc - opis kod azuriranja
// -------------------------------------------
function doc_insert( cDesc )

if cDesc == nil
    cDesc := ""
endif

o_tables( .t. )

// skloni filtere
select _docs
set filter to

select _doc_it
set filter to

select _doc_it2
set filter to

select _doc_ops
set filter to

select _docs
go top

if RECCOUNT2() == 0
    return 0
endif

__doc_desc := cDesc
__doc_no := _docs->doc_no
__doc_stat := _docs->doc_status

if __doc_stat < 3 .and. !rnal_doc_no_exist( __doc_no )
    
    MsgBeep("Nalog " + ALLTRIM(STR( __doc_no )) + " nije moguce azurirati !!!#Status dokumenta = " + ALLTRIM(STR(__doc_stat)) )
    
    // resetuj dokument broj
    select _docs
        
    fill__doc_no( 0, .t. )
        
    select _docs
    go top

    msgbeep("Ponovite operaciju stampe i azuriranja naloga !")

    return 0
    
endif


// azuriranje naloga u toku...
// lokuj sve tabele

// probaj prvo docs lokovati....
if !f18_lock_tables( { "docs" } )
    MsgBeep("Tabele zauzete... ponovite ponovo.... lock docs !!!")
    return 0
endif

// ----- pocetak transakcije
// lock ostalih tabela....
if !f18_lock_tables( { "doc_it", "doc_it2", "doc_ops", "doc_log", "doc_lit" } )
    MsgBeep( "Ne mogu lock-ovati tabele !!!!")
    return 0
endif

sql_table_update( nil, "BEGIN" )

MsgO( "Azuriranje naloga u toku..." )

Beep(1)

// doc busy....
if __doc_stat == 3
    
    // napravi deltu dokumenta
    doc_delta( __doc_no, __doc_desc ) 
    // brisi dokument iz kumulativa
    doc_erase( __doc_no )
    
    // zavrsi trenutnu transakciju
    sql_table_update( nil, "END" )
    // zapocni novu transakciju
    // kako bi ovo sto je i izbrisano bilo vidljivo
    sql_table_update( nil, "BEGIN" )
 
    O_DOCS
    
endif

// azuriranje tabele _DOCS
_docs_insert( __doc_no  )

// azuriranje tabele _DOC_IT
_doc_it_insert( __doc_no )

// azuriranje tabele _DOC_IT2
_doc_it2_insert( __doc_no )

// azuriranje tabele _DOC_OPS
_doc_op_insert( __doc_no )

// setuj marker dokumenta
set_doc_marker( __doc_no, 0, "CONT" )

if __doc_stat <> 3
    // logiraj promjene na dokumentu
    doc_logit( __doc_no )
endif

f18_free_tables( { "docs", "doc_it", "doc_it2", "doc_ops", "doc_log", "doc_lit" } )
sql_table_update( nil, "END" )

// logiranje
log_write( "F18_DOK_OPER: rnal, azuriranje dokumenta broj: " + ALLTRIM( STR( __doc_no ) ) + ;
            ", status: " + ALLTRIM( STR( __doc_stat ) ), 2 )

// ------ kraj transakcije

// sve je ok brisi pripremu
select _docs
zapp()

select _doc_it
zapp()

select _doc_it2
zapp()

select _doc_ops
zapp()

use

Beep(1)

o_tables(.t.)

MsgC()

return 1



// --------------------------------------------------
// azuriranje DOCS
// --------------------------------------------------
static function _docs_insert( nDoc_no )
local _rec

select _docs
set order to tag "1"
go top

_rec := dbf_get_rec()

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if !FOUND()
    append blank
endif

update_rec_server_and_dbf( "docs", _rec, 1, "CONT" )
        
set order to tag "1"

return


// ------------------------------------------
// azuriranje tabele _DOC_IT
// ------------------------------------------
static function _doc_it_insert( nDoc_no )
local _rec, _id_fields, _where_bl

select _doc_it

if RECCOUNT2() == 0
    return
endif

set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. ( field->doc_no == nDoc_no )
    
    _rec := dbf_get_rec()
    
    select doc_it
    
    append blank
    
    update_rec_server_and_dbf( "doc_it", _rec, 1, "CONT" )
    
    select _doc_it
    
    skip
    
enddo

return

// ------------------------------------------
// azuriranje tabele _DOC_IT2
// ------------------------------------------
static function _doc_it2_insert( nDoc_no )
local _rec, _id_fields, _where_bl

select _doc_it2

if RECCOUNT2() == 0
    return
endif

set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. ( field->doc_no == nDoc_no )
    
    _rec := dbf_get_rec()
    
    select doc_it2
    
    append blank
       
    update_rec_server_and_dbf( "doc_it2", _rec, 1, "CONT" )
    
    select _doc_it2
    
    skip    

enddo

return





// ------------------------------------------
// azuriranje tabele _DOC_OP
// ------------------------------------------
static function _doc_op_insert( nDoc_no )
local _rec, _id_fields, _where_bl

select _doc_ops

if RECCOUNT2() == 0
    return
endif

set order to tag "1"
go top
seek docno_str( nDoc_no )

do while !EOF() .and. ( field->doc_no == nDoc_no )
    
    // ako ima operacija...
    if field->aop_id + field->aop_att_id <> 0
        
        _rec := dbf_get_rec()
   
        select doc_ops
        append blank
 
        update_rec_server_and_dbf( "doc_ops", _rec, 1, "CONT" )
        
    endif
    
    select _doc_ops
    skip

enddo

return



// -------------------------------------------
// procedura povrata dokumenta u pripremu...
// -------------------------------------------
function doc_2__doc( nDoc_no )

o_tables(.t.)

select docs
set filter to
select doc_it
set filter to
select doc_it2
set filter to
select doc_ops
set filter to

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if !Found()
    MsgBeep("Nalog " + ALLTRIM(STR( nDoc_no )) + " ne postoji !!!")
    select _docs
    return 0
endif

select _docs

if RECCOUNT2() > 0
    MsgBeep("U pripremi vec postoji dokument#ne moze se izvrsiti povrat#operacija prekinuta !")
    return 0
endif

MsgO("Vrsim povrat dokumenta u pripremu....")

// markiraj da je dokument busy
set_doc_marker( nDoc_no, 3 )

// povrat maticne tabele RNAL
_docs_erase( nDoc_no )

// povrat stavki RNST
_doc_it_erase( nDoc_no )

// povrat stavki RNST
_doc_it2_erase( nDoc_no )

// povrat operacija RNOP
_doc_op_erase( nDoc_no ) 


select docs
use

o_tables(.t.)

MsgC()

return 1


// ----------------------------------------
// markiranje statusa dokumenta busy
// nDoc_no - dokument broj
// nMarker - 0, 1, 2, 3, 4, 5
// ----------------------------------------
function set_doc_marker( nDoc_no, nMarker, cont )
local _rec, _id_fields, _where_bl
local nTArea
nTArea := SELECT()

if cont == NIL
    cont := "FULL"
endif

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
    
    _rec := dbf_get_rec()
    _rec["doc_status"] := nMarker
 
    update_rec_server_and_dbf( "docs", _rec, 1, cont )
 
endif

select (nTArea)
return



// ------------------------------------
// provjerava da li je dokument zauzet
// ------------------------------------
function is_doc_busy()
local lRet := .f.
if field->doc_status == 3
    lRet := .t.
endif
return lRet


// -------------------------------------
// provjerava da li je dokument rejected
// -------------------------------------
function is_doc_rejected()
local lRet := .f.
if field->doc_status == 2
    lRet := .t.
endif
return lRet



//----------------------------------------------
// povrat dokumenta iz tabele DOCS
//----------------------------------------------
static function _docs_erase( nDoc_no )
local _rec 

select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
    
    select docs
        
    _rec := dbf_get_rec()
        
    select _docs
        
    APPEND BLANK
        
    dbf_update_rec( _rec )

endif

select docs

return


//----------------------------------------------
// povrat tabele DOC_IT
//----------------------------------------------
static function _doc_it_erase( nDoc_no )
local _rec

select doc_it
set order to tag "1"
go top

seek docno_str( nDoc_no )

if FOUND()
    
    // dodaj u pripremu dokument
    do while !EOF() .and. ( field->doc_no == nDoc_no )
    
        select doc_it
        
        _rec := dbf_get_rec()
    
        select _doc_it
        
        APPEND BLANK
        
        dbf_update_rec( _rec )
    
        select doc_it
        
        skip
    enddo
endif

select doc_it

return


//----------------------------------------------
// povrat tabele DOC_IT2
//----------------------------------------------
static function _doc_it2_erase( nDoc_no )
local _rec

select doc_it2
set order to tag "1"
go top

seek docno_str( nDoc_no )

if FOUND()
    
    // dodaj u pripremu dokument
    do while !EOF() .and. ( field->doc_no == nDoc_no )
    
        select doc_it2
        
        _rec := dbf_get_rec()
 
        select _doc_it2
        
        APPEND BLANK
        
        dbf_update_rec( _rec )
    
        select doc_it2
        
        skip
    enddo
endif

select doc_it2

return


//----------------------------------------------
// povrat tabele DOC_OP
//----------------------------------------------
static function _doc_op_erase( nDoc_no )
local _rec

select doc_ops
set order to tag "1"
go top

seek docno_str( nDoc_no )

if FOUND()
    
    // dodaj u pripremu dokument
    do while !EOF() .and. (field->doc_no == nDoc_no)
    
        select doc_ops
        _rec := dbf_get_rec()
    
        select _doc_ops
        APPEND BLANK
        dbf_update_rec( _rec )
    
        select doc_ops
        
        skip
    enddo
    
endif

select doc_ops

return



//-----------------------------------------------
// brisi sve vezano za dokument iz kumulativa
//-----------------------------------------------
static function doc_erase( nDoc_no )
local _del_rec

// DOCS
select docs
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
    _del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "docs", _del_rec, 1, "CONT" )
endif

// DOC_IT
select doc_it
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
    _del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "doc_it", _del_rec, 2, "CONT" )
endif

// DOC_IT2
select doc_it2
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
    _del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "doc_it2", _del_rec, 2, "CONT" )
endif

// DOC_OP
select doc_ops
set order to tag "1"
go top
seek docno_str( nDoc_no )

if FOUND()
    _del_rec := dbf_get_rec()
    delete_rec_server_and_dbf( "doc_ops", _del_rec, 2, "CONT" )
endif

return 1



//--------------------------------------------
// da li postoji dokument u tabeli
//--------------------------------------------
function doc_exist( nDoc_no )
local nArea
local lRet := .f.

nArea := SELECT()

select DOCS
set order to tag "A"
go top
seek d_busy() + docno_str( nDoc_no )

if FOUND() .and. docs->doc_no == nDoc_no
    lRet := .t.
endif

set order to tag "1"
select (nArea)

return lRet




// ----------------------------------------------
// napuni pripremne tabele sa brojem naloga
// ----------------------------------------------
function fill__doc_no( nDoc_no, lForce )
local nTRec
local nTArea
local nAPPRec
local _rec

if lForce == nil
    lForce := .f.
endif

// ako je broj 0 ne poduzimaj nista....
if ( nDoc_no == 0 .and. lForce == .f. )
    return
endif

nTArea := SELECT()
nTRec := RecNo()

// _DOCS
select _docs
set order to tag "1"
go top

_rec := dbf_get_rec()

_rec["doc_no"] := nDoc_no
if EMPTY( _rec["doc_time"] )
    _rec["doc_time"] := PADR( TIME(), 5 )
endif

dbf_update_rec( _rec )

// _DOC_IT
select _doc_it
set order to tag "1"
go top
do while !EOF()
    
    skip
    nAPPRec := RecNo()
    skip -1
    
    _rec := dbf_get_rec()
    _rec["doc_no"] := nDoc_no
    dbf_update_rec( _rec )
    
    go (nAPPRec)
enddo

// _DOC_IT2
select _doc_it2
set order to tag "1"
go top
do while !EOF()
    
    skip
    nAPPRec := RecNo()
    skip -1
    
    _rec := dbf_get_rec()
    _rec["doc_no"] := nDoc_no
    dbf_update_rec( _rec )
   
    go (nAPPRec)
enddo

// _DOC_OPS
select _doc_ops
set order to tag "1"
go top
do while !EOF()
    
    skip
    nAPPRec := RecNo()
    skip -1
 
    _rec := dbf_get_rec()
    _rec["doc_no"] := nDoc_no
    dbf_update_rec( _rec )
    
    go (nAPPRec)
enddo

select (nTArea)
go (nTRec)

return


// -----------------------------------------
// formira string za _doc_status - opened
// -----------------------------------------
static function d_opened()
return STR(0, 2)

// -----------------------------------------
// formira string za _doc_status - closed
// -----------------------------------------
static function d_closed()
return STR(1, 2)

// -----------------------------------------
// formira string za _doc_status - rejected
// -----------------------------------------
static function d_rejected()
return STR(2, 2)

// -----------------------------------------
// formira string za _doc_status - busy
// -----------------------------------------
static function d_busy()
return STR(3, 2)



