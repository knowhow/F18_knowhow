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

static __dbf_pack_algoritam := "1"

// algoritam 1 - vise od 700 deleted zapisa
static __dbf_pack_v1 := 700
// algoritam 2 - vise od 10% deleted zapisa
static __dbf_pack_v2 := 10


// ----------------------------------------------------
// ----------------------------------------------------
function f18_init_semaphores()
local _key
local _f18_dbf
local _temp_tbl

_get_dbf_from_config()

_f18_dbfs := f18_dbfs()


for each _key in _f18_dbfs:Keys

    _temp_tbl := _f18_dbfs[_key]["temp"]
    if !_temp_tbl
         refresh_me(_f18_dbfs[_key])
    endif
next

// ----------------------------------------------------
// ----------------------------------------------------
function refresh_me(a_dbf_rec)
local _wa, _del, _cnt, _msg_1, _msg_2
local _dbf_pack_algoritam

Box( "#Molimo sacekajte...", 7, 60)


dbf_open_temp(a_dbf_rec, @_cnt, @_del)

_msg_1 := a_dbf_rec["alias"] + " / " + a_dbf_rec["table"]
_msg_2 := "cnt = "  + ALLTRIM(STR(_cnt, 0)) + " / " + ALLTRIM(STR(_del, 0))

@ m_x + 1, m_y + 2 SAY _msg_1
@ m_x + 2, m_y + 2 SAY _msg_2

log_write("prije synchro " +  _msg_1 + " " + _msg_2)

SELECT (_wa)
my_use(a_dbf_rec["alias"], a_dbf_rec["alias"])

USE

 
// ponovo otvori nakon sinhronizacije
dbf_open_temp(a_dbf_rec, @_cnt, @_del)

_msg_1 := a_dbf_rec["alias"] + " / " + a_dbf_rec["table"]
_msg_2 := "cnt = "  + ALLTRIM(STR(_cnt, 0)) + " / " + ALLTRIM(STR(_del, 0))

@ m_x + 4, m_y + 2 SAY _msg_1
@ m_x + 5, m_y + 2 SAY _msg_2


log_write("nakon synchro " +  _msg_1 + " " + _msg_2)

USE

if hocu_li_pack(_cnt, _del)
    @ m_x + 7, m_y + 2 SAY "Pakujem tabelu radi brzine, molim sacekajte ..."


   SELECT (_wa)
   my_use_temp(a_dbf_rec["alias"], my_home() + a_dbf_rec["table"])

   PACK
   USE

endif

BoxC()


// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
static function dbf_open_temp(a_dbf_rec, cnt, del)

SELECT (a_dbf_rec["wa"])
my_use_temp(a_dbf_rec["alias"], my_home() + a_dbf_rec["table"], .f.)

set deleted off

count to del for deleted()
cnt := reccount()

USE
set deleted on
return


// ------------------------------------------------------------
// vraca informacije iz inija vezane za screen rezoluciju
// ------------------------------------------------------------
static function _get_dbf_from_config()
local _var_name
local _ini_params := hb_hash()

_ini_params["pack_algoritam"] := nil
_ini_params["pack_v1"] := nil
_ini_params["pack_v2"] := nil

IF !f18_ini_read( F18_DBF_INI_SECTION, @_ini_params, .t. )
    MsgBeep(F18_DBF_INI_SECTION + "  problem sa ini read")
    return
ENDIF

// setuj varijable iz inija
IF _ini_params["pack_algoritam"] != nil
    __dbf_pack_algoritam := _ini_params["pack_algoritam"]
ENDIF

IF _ini_params["pack_v1"] != nil
    __dbf_pack_v1 := VAL(_ini_params["pack_v1"])
ENDIF

IF _ini_params["pack_v2"] != nil
    __dbf_pack_v2 := VAL(_ini_params["pack_v2"])
ENDIF


return .t.

// --------------------------------------------------------------
// --------------------------------------------------------------
static function dbf_pack_algoritam()
return __dbf_pack_algoritam

// --------------------------------------------------------------
// --------------------------------------------------------------
static function dbf_pack_v1()
return __dbf_pack_v1


// --------------------------------------------------------------
// --------------------------------------------------------------
static function dbf_pack_v2()
return __dbf_pack_v2


// -------------------------------------------------------------
// provjeri da li je potrebno pakovati tabelu
// - da li se nakupilo deleted zapisa
// -------------------------------------------------------------
static function hocu_li_pack(cnt, del)
local _pack_alg 


_pack_alg := dbf_pack_algoritam()

DO CASE 
  CASE _pack_alg == "0"
 
    return .f.

  CASE _pack_alg == "1"
    
    // 1 - pakuje ako ima vise od 00 deleted() zapisa
    if del > dbf_pack_v1() 
        return .t.
    endif

  CASE _pack_alg == "2"


   if cnt > 0
      // 2 - standardno pakuje se samo ako je > 10% od broja zapisa deleted
      if (del / cnt) * 100 > dbf_pack_v2() 
             return .t.
      endif
   endif

 CASE "9"
   CASE _pack_alg == "9"
              
      // 9 - uvijek ako ima ijedan delted rec
      if del > 0
            return .t.
      endif

END CASE


return .f.

