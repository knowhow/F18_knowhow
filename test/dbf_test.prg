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

function dbf_test()
local _i
local _plaho_dugacko_polje
local _ime_f, _alias, _wa
local _dbf_struct := {}
local _field_10

_ime_f := "test_dbf_1"
_alias := "TEST1"
_wa := 400

_i := ASCAN(gaDBFs, {|x|  x[2] == UPPER(_ime_f) })
if _i == 0
  AADD(gaDBFs, { 400,  UPPER(_ime_f),  _ime_f  } )
endif
set_a_dbf_temp( _ime_f , _alias, _wa )

_plaho_dugacko_polje := "ja_sam_plaho_dugacko_polje"

ferase_dbf(_ime_f, .t.)

AADD(_dbf_struct,      { 'ID' ,  'C' ,   2 ,  0 })
AADD(_dbf_struct,      { 'NAZ' , 'C' ,  10 ,  0 })
AADD(_dbf_struct,      { _plaho_dugacko_polje , 'C' ,  20 ,  0 })
       
DBCREATE2(_ime_f, _dbf_struct)

CREATE_INDEX("ID",  "id", _alias)  
CREATE_INDEX("NAZ", "naz", _alias)
CREATE_INDEX("NAZ2", LEFT(_plaho_dugacko_polje, 10) , _alias)

my_usex(_ime_f)


_field_10 := LEFT(_plaho_dugacko_polje, 10)

APPEND BLANK
field->ja_sam_pla := "t"
field->&_field_10  := "test"

TEST_LINE( FIELDPOS(_plaho_dugacko_polje), 0)
TEST_LINE( FIELDPOS(_field_10), 3)
TEST_LINE( field->ja_sam_pla, PADR("test", 20) )


_alias := "RN"
_ime_f := "racun"

drn_create_open_empty()
TEST_LINE(FILE(my_home() + _ime_f + "." + DBFEXT), .t.)
TEST_LINE(FILE(my_home() + _ime_f + "." + INDEXEXT), .t.)

// brisi po imenu
ferase_dbf(_ime_f, .t.)
TEST_LINE(FILE(my_home() + _ime_f + "." + DBFEXT), .f.)
TEST_LINE(FILE(my_home() + _ime_f + "." + INDEXEXT), .f.)

_alias := "DRNTEXT"
_ime_f := "dracuntext"
// brisi po aliasu
ferase_dbf(_alias, .t.) 
TEST_LINE(FILE(my_home() + _ime_f + "." + DBFEXT), .f.)
TEST_LINE(FILE(my_home() + _ime_f + "." + INDEXEXT), .f.)

return .t.
