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

#include "fakt.ch"

// ------------------------------------------------------
// vraca ukupno sa pdv
// ------------------------------------------------------
function _uk_sa_pdv( cIdTipDok, cPartner, nIznos )
local nRet := 0
local nTArea := SELECT()

if cIdTipDok $ "11#13#23"
    nRet := nIznos
else
    if !IsIno( cPartner ) .and. !IsOslClan( cPartner )
        nRet := ( nIznos * 1.17 )
    else
        nRet := nIznos
    endif
endif

select (nTArea)
return nRet


