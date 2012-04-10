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
return

function my_use_semaphore_on()
__my_use_semaphore := .t.
return

function my_use_semaphore()
return __my_use_semaphore


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
  excl := .f.
endif

if new_area == NIL
   new_area := .f.
endif


if USED()
   use
endif

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
          dbUseArea( new_area, "DBFCDX", table, alias, !excl, .f.)
 
recover using _err

          _msg := "ERR: " + _err:description + ": tbl:" + table + " alias:" + alias + " se ne moze otvoriti ?!"
          Alert(_msg)
         
          if _err:description == "Read error"
             _force_erase := .t.
          endif
 
          //ovo trazi a_dbf_rec definisan za tabelu pa iskljucujem
          //ferase_dbf(alias, _force_erase)

          QUIT

end sequence

return





// ----------------------------------------------------------------
// semaphore_param se prosjedjuje eval funkciji ..from_sql_server
// ----------------------------------------------------------------
function my_use(alias, table, new_area, _rdd, semaphore_param, excl)
local _msg
local _err
local _pos
local _version, _last_version
local _area
local _force_erase := .f.

if excl == NIL
  excl := .f.
endif

if table == NIL
  _a_dbf_rec := get_a_dbf_rec(alias)
else
   // uvijek atribute utvrdjujemo prema table atributu  
   _a_dbf_rec := get_a_dbf_rec(table)
endif


if new_area == NIL
   new_area := .f.
   // pozicioniraj se na WA rezervisanu za ovu tabelu 
   //SELECT (_a_dbf_rec["wa"])
endif

table := _a_dbf_rec["table"]

if alias == NIL
   // za specificne primjene kada "varamo" sa aliasom
   // my_use("fakt_pripr", "fakt_fakt")
   // tada ne diramo alias
   alias := _a_dbf_rec["alias"]
endif

if valtype(table) != "C"
   _msg := PROCNAME(2) + "(" + ALLTRIM(STR(PROCLINE(2))) + ") table name VALTYPE = " + VALTYPE(type)
   Alert(_msg)
   log_write(_msg)
   QUIT
endif


if _rdd == NIL
  _rdd = "DBFCDX"
endif

if !_a_dbf_rec["temp"] 


   // tabela je pokrivena semaforom
   if (_rdd != "SEMAPHORE") .and. my_use_semaphore()
        dbf_semaphore_synchro(table)
   else
     // rdd = "SEMAPHORE" poziv is update from sql server procedure
     // samo otvori tabelu
     if gDebug > 5
          log_write("my_use table:" + table + " / rdd: " +  _rdd + " alias: " + alias + " exclusive: " + hb_ValToStr(excl) + " new: " + hb_ValToStr(new_area))
     endif
     _rdd := "DBFCDX" 
   endif

endif

if USED()
   use
endif

begin sequence with { |err| err:cargo := { ProcName(1), ProcName(2), ProcLine(1), ProcLine(2) }, Break( err ) }
          dbUseArea( new_area, _rdd, my_home() + table, alias, !excl, .f.)
 
recover using _err

          _msg := "ERR: " + _err:description + ": tbl:" + my_home() + table + " alias:" + alias + " se ne moze otvoriti ?!"
          Alert(_msg)
         
          if _err:description == "Read error"
             _force_erase := .t.
          endif
 
          ferase_dbf(alias, _force_erase)


          repair_dbfs()
          QUIT

end sequence

return

// -----------------------------------------------------
// -----------------------------------------------------
function dbf_semaphore_synchro(table)
local _version, _last_version

// uzmimo od tabele stanje svog semafora
_version :=  get_semaphore_version(table)

do while .t.

    if (_version == -1)

        // semafor je resetovan
        // lockuj da drugi korisnici ne bi mijenjali tablelu dok je ucitavam
        sql_table_update(nil, "BEGIN")
        if lock_semaphore(table, "lock")
            update_dbf_from_server(table, "FULL")
            update_semaphore_version(table, .f.)
            lock_semaphore(table, "free")
            sql_table_update(nil, "END")
        else
            sql_table_update(nil, "ROLLBACK")
        endif

     else

            _last_version := last_semaphore_version(table)
            // moramo osvjeziti cache
            if _version < _last_version

                log_write("my_use " + table + " osvjeziti dbf cache: ver: " + ALLTRIM(STR(_version, 10)) + " last_ver: " + ALLTRIM(STR(_last_version, 10))) 
                sql_table_update(nil, "BEGIN")
                if lock_semaphore(table, "lock")
                    update_dbf_from_server(table, "IDS")
                    update_semaphore_version(table, .f.)
                    lock_semaphore(table, "free")
                    sql_table_update(nil, "END")
                else
                    sql_table_update(nil, "ROLLBACK")
                endif

            endif

      endif

      // posljednja provjera ... mozda je neko 
      // u medjuvremenu mjenjao semafor
      _last_version := last_semaphore_version(table)
      _version      := get_semaphore_version(table)
            
      if _version >= _last_version
            exit
      endif
                        
enddo

// sada bi lokalni cache morao biti ok, idemo to provjeriti
check_after_synchro(table)


return .t.

