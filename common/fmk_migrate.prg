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

static __fin_fmk_tables := { {"suban", "fin_suban"}, {"anal", "fin_anal"} }

#ifdef TEST
static __test_fmk_tables := { {"t_fmk_1", "test_sem_1"}, {"test_fmk_2", "test_sem_2"} }
#endif

// --------------------------------------
// --------------------------------------
function fmk_migrate_root(fmk_root_dir)
if fmk_root_dir == NIL
#ifdef __PLATFORM__WINDOWS
   fmk_root_dir := "c:" + SLASH + "SIGMA"
#else
    #ifdef TEST 
        fmk_root_dir := hb_DirSepAdd(tmp_dir()) +  "SIGMA"
    #endif
#endif
endif

return fmk_root_dir


// -----------------------------
// -----------------------------
function fmk_migrate(cur_dir)
local _files, _file

cur_dir := fmk_migrate_root(cur_dir)

log_write(PROCNAME(1) + ": " + cur_dir)

_files := DIRECTORY(cur_dir + HB_OSPATHSEPARATOR() + "*", "D")

for each _file in _files
  if _file[5] != "D"
       if FILEEXT(LOWER(_file[1])) == "dbf"
             push_fmk_dbf_to_server(cur_dir, _file[1])
       endif 
  endif
next

for each _file in _files
  if _file[5] == "D"
        fmk_migrate(cur_dir + HB_OSPATHSEPARATOR() +  _file[1])
  endif
next

// -------------------------------------
// -------------------------------------
function push_fmk_dbf_to_server(cur_dir, dbf_name)
local _i, _org_id, _pos, _tmp_1, _tmp_2
local _year
local _curr_year := YEAR(DATE())

for _i := 1 TO 99
   _org_id := ALLTRIM(STR(_i, 2))
 
   for _year := 1994 TO _curr_year

        if _year == _curr_year
            _tmp_2 := ""
        else
            _tmp_2 := SLASH + ALLTRIM(STR(_year))
        endif
        
         _tmp_1 := RIGHT(LOWER(cur_dir), 3 + LEN(_org_id) + LEN(_tmp_2))

        if _tmp_1 == "kum" + _org_id + _tmp_2
                DO CASE
                    CASE AT(SLASH + "fin" + SLASH + _tmp_1, LOWER(cur_dir)) != 0
                        _pos := ASCAN( __fin_fmk_tables, { |x| x[1] == FILEBASE(LOWER(dbf_name)) })
                        if _pos != 0 
                                log_write( cur_dir + SLASH + dbf_name + "=> b_year=" + ALLTRIM(STR(_year)) + "  org_id=" +  _org_id + " / " + __fin_fmk_tables[_pos, 2])
                        endif
                END CASE
        endif

   
/*
   if RIGHT(cur_dir, 3 + LEN(_org_id) ) == "sif" + _org_id
       _sif
   endif
*/

   next

next

