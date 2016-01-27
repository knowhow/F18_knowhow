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


// -----------------------------------------------------
// provjerava da li postoji polje u tabelama os/sii
// -----------------------------------------------------
function os_postoji_polje( naziv_polja )
local _ret := .f.

if gOsSii == "O"
    if os->(fieldpos( naziv_polja )) <> 0
        _ret := .t.
    endif
else
    if sii->(fieldpos( naziv_polja )) <> 0
        _ret := .t.
    endif
endif

return _ret


// ----------------------------------------
// selektuje potrebnu tabelu
// ----------------------------------------
function select_os_sii()

if gOsSii == "O"
    select os
else
    select sii
endif

return


// ----------------------------------------
// selektuje potrebnu tabelu
// ----------------------------------------
function select_promj()

if gOsSii == "O"
    select promj
else
    select sii_promj
endif

return

// ----------------------------------------
// otvara potrebnu tabelu
// ----------------------------------------
function o_os_sii()

if gOsSii == "O"
    O_OS
else
    O_SII
endif

return


// ----------------------------------------
// otvara potrebnu tabelu
// ----------------------------------------
function o_os_sii_promj()

if gOsSii == "O"
    O_PROMJ
else
    O_SII_PROMJ
endif

return


// -----------------------------------------
// vraca naziv tabele na osnovu alias-a
// -----------------------------------------
function get_os_table_name( alias )
local _ret := "os_os"

if UPPER( alias ) == "OS"
    _ret := "os_os"
else
    _ret := "sii_sii"
endif

return _ret



// -----------------------------------------
// vraca naziv tabele na osnovu alias-a
// -----------------------------------------
function get_promj_table_name( alias )
local _ret := "os_promj"

if UPPER( alias ) == "PROMJ"
    _ret := "os_promj"
else
    _ret := "sii_promj"
endif

return _ret





// -----------------------------------------
// unificiraj invent. brojeve
// -----------------------------------------
function Unifid()
local nTrec, nTSRec
local nIsti
local _rec

o_os_sii()

set order to tag "1"

do while !eof()

    cId := field->id
    nIsti := 0

    do while !eof() .and. field->id == cId
        ++ nIsti
        skip
    enddo

    if nIsti > 1  
        // ima duplih slogova
        seek cId 
        // prvi u redu
        nProlaz:=0
        do while !eof() .and. field->id == cId
            skip
            ++nProlaz
            nTrec:=recno()   // sljedeci
            skip -1
            nTSRec:=recno()
            cNovi:=""
            if len(trim(cid))<=8
                cNovi:=trim(id)+idrj
            else
                cNovi:=trim(id)+chr(48+nProlaz)
            endif
            seek cnovi
            if found()
                msgbeep("vec postoji "+cid)
            else
                go nTSRec
                _rec := dbf_get_rec()
                _rec["id"] := cNovi
                update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" ) 
            endif
            go nTrec
        enddo
    endif

enddo
return



function RazdvojiDupleInvBr()
if sigmasif("UNIF")
    if pitanje(,"Razdvojiti duple inv.brojeve ?","N")=="D"
        UnifId()
    endif
endif
return



