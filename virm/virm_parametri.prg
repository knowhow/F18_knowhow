/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "virm.ch"


function virm_parametri()
local _firma := fetch_metric("firma_id", nil, gFirma )
local _firma_naziv := fetch_metric("firma_naziv", nil, PADR( gNFirma, 100 ) )
local _pict := fetch_metric("virm_iznos_pict", nil, PADR( "999999999.99", 12 ) )
local _nule := fetch_metric("virm_stampati_nule", nil, "N" )
local _sys_datum := fetch_metric("virm_sys_datum_uplate", nil, "D" )
local _org_jed := fetch_metric("virm_org_jedinica", nil, gOrgJed )
local _mjesto := fetch_metric("virm_mjesto_uplate", nil, gMjesto )
local _datum := fetch_metric("virm_init_datum_uplate", nil, gDatum )

Box(, 8, 70 )
    
    @ m_x + 1, m_y + 2 SAY "Firma (nalogodavac) id:" GET _firma
    @ m_x + 2, m_y + 2 SAY "   Naziv:" GET _firma_naziv PICT "@S45"
    @ m_x + 3, m_y + 2 SAY "Inicijalni datum uplate:" GET _datum
    @ m_x + 4, m_y + 2 SAY "Mjesto uplate:" GET _mjesto PICT "@S45"
    @ m_x + 5, m_y + 2 SAY "Broj poreznog obveznika:" GET _org_jed PICT "@S17"
    @ m_x + 6, m_y + 2 SAY "Format iznosa:" GET _pict
    @ m_x + 7, m_y + 2 SAY "Ako je iznos = 0, treba ga stampati (D/N)?" GET _nule
    @ m_x + 8, m_y + 2 SAY "Datum uplate = sistemski datum (D/N)?" GET _sys_datum

    read

BoxC()

IF LastKey() <> K_ESC

    set_metric("firma_id", nil, _firma )
    set_metric("firma_naziv", nil, _firma_naziv )
    set_metric("virm_iznos_pict", nil, _pict )
    set_metric("virm_stampati_nule", nil, _nule )
    set_metric("virm_sys_datum_uplate", nil, _sys_datum )
    set_metric("virm_mjesto_uplate", nil, _mjesto )
    set_metric("virm_init_datum_uplate", nil, _datum )
    set_metric("virm_org_jedinica", nil, _org_jed )

ENDIF

return





