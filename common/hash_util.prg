/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

function check_hash_key(rec, key)
local _msg

if !HB_HHASKEY(rec, key)
    _msg := RECI_GDJE_SAM + " record ne sadrzi key:" + key + " rec=" + pp(rec)
    Alert(_msg)
    log_write( _msg, 7 )
    RaiseError(_msg)
    QUIT_1
endif

return .t.
