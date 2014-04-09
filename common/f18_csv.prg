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

#include "fmk.ch"
#include "hbclass.ch"
#include "common.ch"

CLASS F18Csv

    DATA struct
    DATA csvname
    DATA memname
    DATA delimiter

    METHOD new()
    METHOD read()
   
    PROTECTED:
    
        METHOD create_mem_dbf()
        METHOD open_csv_as_local_dbf()

ENDCLASS


// -----------------------------------------------------
// -----------------------------------------------------
METHOD F18Csv:New()
::memname := "csvimp"
return self



// ------------------------------------------------------
// ------------------------------------------------------
METHOD F18Csv:read()
local _ok := .f.

if ::struct == NIL
    MsgBeep( "Struktura zaboravljena !" )
    return _ok
endif

if ::csvname == NIL
    MsgBeep( "A koji fajl da importujem ???" )
    return _ok
endif

if ::delimiter == NIL
    ::delimiter := ";"
endif

// kreiraj i otvori lokalni dbf
::create_mem_dbf()

// otvori csv u dbf
::open_csv_as_local_dbf()

return _ok


// ------------------------------------------------------
// ------------------------------------------------------
METHOD F18Csv:create_mem_dbf()
DBCREATE( ::memname, ::struct, "ARRAYRDD" )
return


// ------------------------------------------------------
// ------------------------------------------------------
METHOD F18Csv:open_csv_as_local_dbf()

SELECT (360)
USE (::memname ) VIA "ARRAYRDD"

APPEND FROM ( ::csvname ) DELIMITED
// preskoci header...
GO TOP
SKIP 1

return


