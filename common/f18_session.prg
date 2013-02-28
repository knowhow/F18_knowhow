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

#include "hbthread.ch"

// broj f18 sesija. kod svake nove sesije + 1
static __f18_session_count := 1
// oznaka sesije
thread static __f18_session := { 'id' => 1 }

// ---------------------------------------
// ---------------------------------------
function  new_f18_session_thread()

if Pitanje(, "Pokrenuti novu F18 sesiju ?", "N") == "N"
   return 
endif

//hb_threadStart( HB_THREAD_INHERIT_PUBLIC, @start_new_session())
hb_threadStart(@start_new_session())

return


// --------------------------------------
// --------------------------------------
function setup_session_params()

log_create()

return

// --------------------------------------
// --------------------------------------
function start_new_session()
local _w, _cnt
local p1 := p2 := p3 := p4 := p5 := NIL

#ifdef  __PLATFORM__WINDOWS 
    _w := hb_gtCreate("WVT")
#else
    _w := hb_gtCreate("XWC")
#endif

_cnt := f18_session_count(1)
f18_session('id', _cnt)

hb_gtSelect(_w)
set_screen_dimensions()
hb_gtReload(_w)

setup_session_params()

module_menu(nil, nil, nil, nil, nil)

log_close()
QUIT

return



// ------------------------------------------------------
// npr. nalazim se u sesiji 2 - to je prva child sesija
// { 'id' => 2 }
// ------------------------------------------------------
function f18_session(key, val)

if key != NIL
   __f18_session[key] := val
endif

return __f18_session

// ----------------------------
// 5 - otvorene 4 dodatne sesije
// ----------------------------
function f18_session_count(inc)

if inc != NIL
   __f18_session_count += inc
endif

return __f18_session_count

