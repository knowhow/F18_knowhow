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


static function cre_doc_sql_test_data()
local _sql, _dat

// 2012 ------------------
_dat := CTOD("15.12.12")
_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  _dat)
_cnt:counter := 1216
_sql := "INSERT INTO fmk.fakt_doks(idfirma, idtipdok, datdok, brdok) VALUES(" + _sql_quote("10") + "," + _sql_quote("88") + "," + _sql_quote(_dat) + "," + _sql_quote(_cnt:to_str())  +")"
run_sql_query(_sql)

_dat := CTOD("20.12.12")
_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  _dat)
_cnt:counter := 1218
_sql := "INSERT INTO fmk.fakt_doks(idfirma, idtipdok, datdok, brdok) VALUES(" + _sql_quote("10") + "," + _sql_quote("88") + "," + _sql_quote(_dat) + "," + _sql_quote(_cnt:to_str())  +")"
run_sql_query(_sql)

_dat := CTOD("21.12.12")
_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  _dat)
_cnt:counter := 1219
_sql := "INSERT INTO fmk.fakt_doks(idfirma, idtipdok, datdok, brdok) VALUES(" + _sql_quote("10") + "," + _sql_quote("88") + "," + _sql_quote(_dat) + "," + _sql_quote(_cnt:to_str())  +")"
run_sql_query(_sql)

// 2013 ------------------
_dat := CTOD("02.01.13")
_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  _dat)
_cnt:counter := 5
_sql := "INSERT INTO fmk.fakt_doks(idfirma, idtipdok, datdok, brdok) VALUES(" + _sql_quote("10") + "," + _sql_quote("88") + "," + _sql_quote(_dat) + "," + _sql_quote(_cnt:to_str())  +")"
run_sql_query(_sql)

_dat := CTOD("03.01.13")
_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  _dat)
_cnt:counter := 16
_sql := "INSERT INTO fmk.fakt_doks(idfirma, idtipdok, datdok, brdok) VALUES(" + _sql_quote("10") + "," + _sql_quote("88") + "," + _sql_quote(_dat) + "," + _sql_quote(_cnt:to_str())  +")"
run_sql_query(_sql)

return .t.



//---------------------------------------------
//---------------------------------------------
static function delete_doc_sql_test_data()
local _sql

_sql := "DELETE FROM fmk.fakt_doks WHERE idfirma=" + _sql_quote("10") + " AND idtipdok=" + _sql_quote("88") 
run_sql_query(_sql)

return .t.

// --------------------------------------------
// --------------------------------------------
function t_doc_counters()

_cnt := DocCounter():New(10, 15, 10, "P-", "/13", "0")
_cnt:inc()
_cnt:dec()
_cnt:dec()
TEST_LINE(_cnt:to_str(), PADR("P-0000000009/13", 15) )


_cnt := DocCounter():New(125, 15, 10, "Y/", "/14", "x")
_cnt:inc()
_cnt:inc()
_cnt:inc()
_cnt:dec()
TEST_LINE(_cnt:to_str(), PADR("Y/xxxxxxx127/14", 15) )


_cnt := DocCounter():New(125, 14, 8, "Y/", "/14", "x")
_cnt:counter := 1545
TEST_LINE(_cnt:to_str(), PADR("Y/xxxx1545/14", 14))
_cnt:inc()
TEST_LINE(_cnt:counter, 1546)


_cnt := DocCounter():New(0, 20, 5, "BR/", "/15", "0")
_cnt:decode(PADR("BR/P10-00222-66/15", 20))
TEST_LINE(_cnt:counter, 222)
TEST_LINE(_cnt:decoded_before_num, "P10-")
TEST_LINE(_cnt:decoded_after_num, "-66")


_cnt := DocCounter():New(0, 12, 5, "BR/", "/15", ".")
_cnt:decode("BR/PP-.....-SS/15")
TEST_LINE(_cnt:is_decoded, .f.)
TEST_LINE(_cnt:error_message, "no match")

// mora biti cetverocifren broj
_cnt := DocCounter():New(0, 20, 5, "BR/", "/15", "0")
_cnt:decode("BR/PP-.....111-SS/15")
TEST_LINE(_cnt:is_decoded, .f.)
TEST_LINE(_cnt:error_message, "no match")


_cnt := DocCounter():New(0, 16, 5, "BR/", "/15", "0")
_cnt:decode("BR/PP-0000-SS/15")
TEST_LINE(_cnt:decoded_before_num, "PP-")
TEST_LINE(_cnt:decoded_after_num, "-SS")
TEST_LINE(_cnt:is_decoded, .t.)
TEST_LINE(_cnt:counter, 0)


_cnt := DocCounter():New(0, 16, 5, "BR/", "/55", "0")
_cnt:decode("BR/PP-0000-SS/15")
TEST_LINE(_cnt:is_decoded, .f.)
TEST_LINE(_cnt:error_message, "no match")

_cnt := DocCounter():New(0, 25, 6, "11/", "/33", "0")
_cnt:decode(PADR("11/P0#000802889-7E/33", 25))
TEST_LINE(_cnt:counter, 802889)
TEST_LINE(_cnt:decoded_before_num, "P0#")
TEST_LINE(_cnt:decoded_after_num, "-7E")

_cnt := DocCounter():New(0, 18, 6, "11/", "/33")
_cnt:prefix0 := "X9#"
_cnt:counter := 7921
_cnt:suffix0 := "-1"
TEST_LINE(_cnt:to_str(), PADR("11/X9#007921-1/33", 18))

_cnt := DocCounter():New(0, 18, 6, "11/", "/33")
_cnt:prefix0 := "X9#"
_cnt:counter := 7921
_cnt:suffix0 := "-1"
TEST_LINE(_cnt:to_str(), PADR("11/X9#007921-1/33", 18))

public _TEST_CURRENT_YEAR := 2013
_cnt := DocCounter():New(0, 12, 6, "", "<G2>")
_cnt:counter := 1215
TEST_LINE(_cnt:to_str(), PADR("001215/13", 12))

public _TEST_CURRENT_YEAR := 2014
_cnt := DocCounter():New(0, 12, 6, "", "<G2>")
_cnt:counter := 1215
TEST_LINE(_cnt:to_str(), PADR("001215/14", 12))

_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  CTOD("04.01.2013"))
_cnt:counter := 20
TEST_LINE(_cnt:to_str(), PADR("000020/13", 12))
TEST_LINE(_cnt:year, 2013)

delete_doc_sql_test_data()
cre_doc_sql_test_data()
TEST_LINE(_cnt:document_counter, 16)

_cnt := DocCounter():New(0, 12, 6, "", "<G2>", "0", {"fakt", "10", "88"},  CTOD("31.12.2012"))
_cnt:counter := 1
TEST_LINE(_cnt:to_str(), PADR("000001/12", 12))
TEST_LINE(_cnt:year, 2012)
TEST_LINE(_cnt:document_counter, 1219)

delete_doc_sql_test_data()

return
