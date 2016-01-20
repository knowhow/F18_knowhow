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

/*! \fn SkratiAZaD(aStruct)
 *  \brief skrati matricu za polje D
 
 *  \code
 *  SkratiAZaD(@aStruct)
 *  \endcode
*/
function SkratiAZaD(struct)
local _i, _len

_len := len(struct)

for _i:=1 to _len
    // sistemska polja
    if ("#" + struct[_i, 1] + "#" $ "#BRISANO#_SITE_#_OID_#_USER_#_COMMIT_#_DATAZ_#_TIMEAZ_#")
        ADEL (struct, _i)
        _len--
        _i := _i-1
    endif
next

ASIZE(struct, _len)

return nil
