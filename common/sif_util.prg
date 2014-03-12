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
// ------------------------------------
// ------------------------------------
function sif_ispisi_naziv(nDbf, dx, dy)
local cTmp  := ""

if (nDbf)->(FIELDPOS("naz")) <> 0
   cTmp := TRIM( ToStr( (nDbf)->naz ) )
endif

if (nDbf)->(FIELDPOS("naziv")) <> 0
   cTmp := TRIM( ToStr( (nDbf)->naziv ) )
endif

if dx <> NIL .and. dy <> nil

    if (nDbf)->(fieldpos("naz")) <> 0
        @ m_x + dx, m_y + dy SAY PADR( cTmp, 70 - dy)
    endif

    if (nDbf)->(fieldpos("naziv")) <> 0
        @ m_x + dx, m_y + dy SAY PADR( cTmp, 70 - dy)
    endif

elseif dx <> NIL .and. dx > 0 .and. dx < 25

    CentrTxt( cTmp, dx)

endif

return
