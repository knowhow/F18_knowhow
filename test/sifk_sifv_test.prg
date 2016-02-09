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

function sifk_sifv_test()
local _ime_f := "tsifv_k"
local _dbf_struct := {}
local _i, _rec
local _id_sif, _karakteristika, _karakteristika_n
local _header
local _tmp

close all


AADD(_dbf_struct,      { 'ID' ,  'C' ,    2 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,   10 ,  0 })
AADD(_dbf_struct,      { 'DEST' , 'C' ,  60 ,  0 })

DBCREATE2(_ime_f, _dbf_struct)
cre_index_tsifv_k(_ime_f)

close all
my_usex("sifk")
delete_all_dbf_and_server("sifk")

my_usex("sifv")
select sifv
delete_all_dbf_and_server("sifv")

close all

// izbrisacu sada sifk
TEST_LINE( ferase_dbf("sifk"), .t. )
TEST_LINE( ferase_dbf("sifv"), .t. )

TEST_LINE( FILE(f18_ime_dbf("sifk")), .f.)
TEST_LINE( FILE(f18_ime_dbf("sifv")), .f.)
cre_sifk_sifv()

my_use(_ime_f)

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
_karakteristika := "ka1"
_karakteristika_n := "kaN"

O_SIFK
SET ORDER TO TAG "ID2"
SEEK _id_sif + _karakteristika

TEST_LINE( LEN(_id_sif) <= SIFK_LEN_DBF .and. LEN(_karakteristika) < SIFK_LEN_OZNAKA,  .t.)

_id_sif := PADR(_id_sif, 8)
_karakteristika   := PADR(_karakteristika, 4)
_karakteristika_n := PADR(_karakteristika_n, 4)

O_SIFV

#define K1_LEN 9
#define KN_LEN 7

TEST_LINE( sifk->(reccount()), 0)
TEST_LINE( sifv->(reccount()), 0)
append_sifk(_id_sif, _karakteristika, "C", K1_LEN, "1")
append_sifk(_id_sif, _karakteristika_n, "C", KN_LEN, "N")

//,  {"id", "oznaka"} , { |x| "ID=" + _sql_quote(x["id"]) + "and OZNAKA=" + _sql_quote(x["oznaka"]) })


SELECT F_SIFK
use

my_use("sifk")
SET ORDER TO TAG "ID2"
seek _id_sif + _karakteristika
TEST_LINE( field->id + field->oznaka, _id_sif + _karakteristika)

seek _id_sif + _karakteristika_n
TEST_LINE( field->id + field->oznaka, _id_sif + _karakteristika_n)

// izbrisacu sada sifk
TEST_LINE( ferase_dbf("sifk"), .t. )
TEST_LINE( ferase_dbf("sifv"), .t. )

cre_sifk_sifv()

// tako da forsiram full import
my_use("sifk")

SET ORDER TO TAG "ID2"
seek _id_sif + _karakteristika
_header := "NAKON FERASE: "
TEST_LINE( _header + field->id + field->oznaka + sifk->tip + sifk->veza + STR(sifk->duzina, 2), _header + _id_sif + _karakteristika + "C1" + STR(K1_LEN, 2))

seek _id_sif + _karakteristika_n
_header := "NAKON FERASE: "
TEST_LINE( _header + field->id + field->oznaka + sifk->tip + sifk->veza + STR(sifk->duzina, 2), _header + _id_sif + _karakteristika_n + "CN" + STR(KN_LEN, 2))

USE
close all


TEST_LINE(USifK(_id_sif, _karakteristika, "01", "K1VAL1"), .t.)
TEST_LINE(USifK(_id_sif, _karakteristika, "01", "K1VAL2"), .t.)
TEST_LINE(USifK(_id_sif, _karakteristika, "01", "K1VAL3"), .t.)



TEST_LINE(USifK(_id_sif, _karakteristika_n, "01", "K2VAL1,K2VAL3"), .t.)
TEST_LINE(USifK(_id_sif, _karakteristika_n, "01", "K2VAL4,K2VAL1,K2VAL2"), .t.)


TEST_LINE(IzSifk(_id_sif, _karakteristika, "01"), PADR("K1VAL3", K1_LEN ))

_tmp := PADR("K2VAL1", KN_LEN) + ","
_tmp += PADR("K2VAL2", KN_LEN) + ","
_tmp += PADR("K2VAL4", KN_LEN)

_tmp := PADR(_tmp, 190)
TEST_LINE(IzSifk(_id_sif, _karakteristika_n, "01"), _tmp)


return

// -------------------------------------------
// -------------------------------------------
static function append_sifk(id_sif, karakteristika, tip, duzina, veza, fields, where_block)
local _rec

SELECT sifk
set order to tag "ID2"
seek padr(id_sif, SIFK_LEN_DBF) + PADR(karakteristika, SIFK_LEN_OZNAKA)

if !FOUND()

    APPEND BLANK
    _rec := dbf_get_rec()
    _rec["id"] := id_sif
    _rec["oznaka"] := karakteristika
    _rec["naz"] := karakteristika + " naziv "
    _rec["tip"] := tip
    _rec["duzina"] := duzina
    _rec["veza"] := veza

    if !update_rec_server_and_dbf("sifk", _rec, fields, where_block)
        delete_with_rlock()
    endif
endif

return


function cre_index_tsifv_k(ime_f)
 CREATE_INDEX("ID",  "id", ime_f)
 CREATE_INDEX("NAZ", "naz", ime_f)
return
