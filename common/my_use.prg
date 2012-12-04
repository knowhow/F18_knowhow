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
#include "common.ch"


thread static __my_use_semaphore := .t.

// --------------------------------------
// iskljuci logiku provjere semafora
// neophodno u procedurama azuriranja
// 
// if azur_sql()
//       my_use_semaphore_off()
//       otvori_dbfs()
//       azur_dbf()
//       my_use_semaphore_on()
// endif
//
// --------------------------------------
function my_use_semaphore_off()
__my_use_semaphore := .f.
log_write( "stanje semafora : OFF", 6 )
f18_ispisi_status_semafora( .f. )
return

function my_use_semaphore_on()
__my_use_semaphore := .t.
log_write( "stanje semafora : ON", 6 )
f18_ispisi_status_semafora( .t. )
return

function my_use_semaphore()
return __my_use_semaphore


// vraca status semafora
function get_my_use_semaphore_status( status )
local _ret := "ON"

if status == NIL
    if my_use_semaphore() == .f.
        _ret := "OFF"
    endif
else
    if status == .f.
        _ret := "OFF"
    endif
endif

return _ret



// --------------------------------------------------------------
// --------------------------------------------------------------
function my_usex(alias, table, new_area, _rdd, semaphore_param)
return my_use(alias, table, new_area, _rdd, semaphore_param, .t.)


// ---------------------------------------------------------------
// uopste ne koristi logiku semafora, koristiti za temp tabele
// kod opcija exporta importa
// ---------------------------------------------------------------
function my_use_temp(alias, table, new_area, excl)
local _force_erase
local _err

if excl == NIL
  excl := .t.
endif

if new_area == NIL
   new_area := .f.
endif


if USED()
   use
endif

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }

          dbUseArea( new_area, DBFENGINE, table, alias, !excl, .f.)
          if FILE(ImeDbfCdx(table))
              dbSetIndex(ImeDbfCDX(table))
          endif

recover using _err

          _msg := "ERR-MYUTMP: " + _err:description + ": tbl:" + table + " alias:" + alias + " se ne moze otvoriti ?!"
          Alert(_msg)
          log_write(_msg, 2)

          if _err:description == "Read error"
             _force_erase := .t.
          endif

          //ovo trazi a_dbf_rec definisan za tabelu pa iskljucujem
          //ferase_dbf(alias, _force_erase)

          RaiseError(_msg)
          QUIT_1

end sequence

return

// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
function my_use(alias, table, new_area, _rdd, semaphore_param, excl, select_wa)
local _msg
local _err
local _pos
local _version, _last_version
local _area
local _force_erase := .f.
local _dbf
local _tmp

if excl == NIL
  excl := .f.
endif

if select_wa == NIL
  select_wa = .f.
endif

if table == NIL
    _tmp := alias
else
    // uvijek atribute utvrdjujemo prema table atributu  
    _tmp := table
endif

// trebam samo osnovne parametre
_a_dbf_rec := get_a_dbf_rec(_tmp, .t.)


if new_area == NIL
   new_area := .f.
endif

// pozicioniraj se na WA rezervisanu za ovu tabelu 
if select_wa
   SELECT (_a_dbf_rec["wa"])
endif


if (alias == NIL) .or. (table == NIL)
   // za specificne primjene kada "varamo" sa aliasom
   // my_use("fakt_pripr", "fakt_fakt")
   // tada ne diramo alias
   alias := _a_dbf_rec["alias"]
endif

table := _a_dbf_rec["table"]

if valtype(table) != "C"
   _msg := PROCNAME(2) + "(" + ALLTRIM(STR(PROCLINE(2))) + ") table name VALTYPE = " + VALTYPE(type)
   Alert(_msg)
   log_write( _msg, 5 )
   QUIT_1
endif


if _rdd == NIL
  _rdd = DBFENGINE
endif

if !(_a_dbf_rec["temp"])

    // tabela je pokrivena semaforom
    if (_rdd != "SEMAPHORE") .and. my_use_semaphore()
        dbf_semaphore_synchro(table)
    else
        // rdd = "SEMAPHORE" poziv is update from sql server procedure
        // samo otvori tabelu
        log_write("my_use table:" + table + " / rdd: " +  _rdd + " alias: " + alias + " exclusive: " + hb_ValToStr(excl) + " new: " + hb_ValToStr(new_area), 8 )
        _rdd := DBFENGINE
    endif

endif

if USED()
    use
endif

_dbf := my_home() + table

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
          dbUseArea( new_area, _rdd, _dbf, alias, !excl, .f.)
          if FILE(ImeDbfCdx(_dbf))
              dbSetIndex(ImeDbfCDX(_dbf))
          endif

recover using _err

          _msg := "ERR-MYUSE: " + _err:description + ": tbl:" + my_home() + table + " alias:" + alias + " se ne moze otvoriti ?!"
          log_write( _msg, 2)
          Alert(_msg)

          if _err:description == "Read error"
             _force_erase := .t.
          endif

          ferase_dbf(alias, _force_erase)

          repair_dbfs()
          QUIT_1

end sequence

return

// -----------------------------------------------------
// -----------------------------------------------------
function dbf_semaphore_synchro(table)
local _version, _last_version


log_write( "START dbf_semaphore_synchro", 9 )

// uzmimo od tabele stanje svog semafora
_version :=  get_semaphore_version(table)

do while .t.

    if (_version == -1)
        log_write( "full synchro version semaphore version -1", 7 )
        // odradi full sinhro i setuj vesion = last_trans_version
        update_dbf_from_server( table, "FULL" )
    else

        _last_version := last_semaphore_version(table)
        // moramo osvjeziti cache
        if (_version < _last_version)
            log_write( "dbf_semaphore_synchro/1, my_use" + table + " osvjeziti dbf cache: ver: " + ALLTRIM(STR(_version, 10)) + " last_ver: " + ALLTRIM(STR(_last_version, 10)), 5 )
            update_dbf_from_server(table, "IDS")
        endif
    endif

    // posljednja provjera ... mozda je neko 
    // u medjuvremenu mjenjao semafor
    _last_version := last_semaphore_version(table)
    _version      := get_semaphore_version(table)

    if _version >= _last_version
        exit
    endif
      
    log_write( "dbf_semaphore_synchro/2, _last_version: " + STR( _last_version ) + " _version: " + STR( _version ), 5 )

enddo

check_after_synchro(table)

log_write( "END dbf_semaphore_synchro", 9 )

return .t.



