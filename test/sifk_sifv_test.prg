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

function sifk_sifv_test()
local _ime_f := "tsifv_k"
local _dbf_struct := {}
local _i, _rec
local _id_sif, _karakteristika, _karakteristika_2
local _header

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  altd()
  AADD(gaDBFs, { 101,  UPPER(_ime_f),  _ime_f  } )
endif

AADD(_dbf_struct,      { 'ID' ,  'C' ,    2 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,   10 ,  0 })
AADD(_dbf_struct,      { 'DEST' , 'C' ,  60 ,  0 })
       
DBCREATE2(_ime_f, _dbf_struct)

CREATE_INDEX("ID",  "id", _ime_f)  
CREATE_INDEX("NAZ", "naz", _ime_f)

my_use(ime_f)

APPEND BLANK
if !rlock()
   return .f.
endif

replace id with "01"
replace naz with "naz 01"
replace naz with "dest 01"

replace id with "02"
replace naz with "naz 02"
replace dest with "dest 02"

_id_sif := "tsifv_k"
_karakteristika := "k1"
_karakteristika_2 := "k2"
SEEK _id_sif + _karakteristika

TEST_LINE( LEN(_id_sif) <= 8 .and. LEN(_karakteristika) < 4,  .t.)

append_sifk(_id_sif, _karakteristika)
append_sifk(_id_sif, _karakteristika_2, {"id", "oznaka"} , { |x| "ID=" + _sql_quote(x["id"]) + "|| OZNAKA=" + _sql_quote(x["oznaka"]) })


SELECT F_SIFK
use
my_use("sifk")

seek padr(_id_sif, 8) + PADR(_karakteristika, 4)
TEST_LINE( field->id + field->oznaka, padr(_id_sif, 8) + PADR(_karakteristika, 4)) 

seek padr(_id_sif, 8) + PADR(_karakteristika_2, 4)
TEST_LINE( field->id + field->oznaka, padr(_id_sif, 8) + PADR(_karakteristika_2, 4)) 

USE

// izbrisacu sada sifk
FERASE(f18_ime_dbf("sifk"))
// tako da forsiram full import
my_use("sifk")

seek padr(_id_sif, 8) + PADR(_karakteristika, 4)
_header := "NAKON FERASE: "
TEST_LINE( _header + field->id + field->oznaka, _header + padr(_id_sif, 8) + PADR(_karakteristika, 4)) 

seek padr(_id_sif, 8) + PADR(_karakteristika_2, 4)
_header := "NAKON FERASE: "
TEST_LINE( _header + field->id + field->oznaka, _header + padr(_id_sif, 8) + PADR(_karakteristika_2, 4)) 

USE
close all

TEST_LINE( 0 == 0, .t.)
return

// -------------------------------------------
// -------------------------------------------
static function append_sifk(_id_sif, _karakteristika, fields, where_block)

SELECT sifk
set order to tag "ID2"
seek padr(_id_sif, 8) + PADR(_karakteristika, 4)

if !FOUND()
    APPEND BLANK
    _rec := hbhash()
    _rec["id"] := _id_sif
    _rec["oznaka"] := _karakteristika
    _rec["naz"] := "karakteristika 1"
    _rec["veza"] := "N"
    // sirina karakteristike 1 je 15 znakova 
    _rec["duzina"] := 15
    _rec["tip"] := "C"

    if !update_rec_server_and_dbf(_rec, fields, where_block) 
        delete_with_rlock()
    endif
endif

return
