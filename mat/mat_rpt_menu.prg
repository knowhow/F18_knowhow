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


#include "f18.ch"


function mat_izvjestaji()
local _opc := {}
local _opcexe := {}
local _izbor := 1

//PRIVATE PicDEM:="99999999.99"
//PRIVATE PicBHD:="999999999.99"
//PRIVATE PicKol:="999999.999"

AADD( _opc, "1. kartica                                " )
AADD( _opcexe, { || mat_kartica() } )
AADD( _opc, "2. specifikacija" )
AADD( _opcexe, { || mat_specifikacija() } )
AADD( _opc, "3. specifikacija sinteticki" )
AADD( _opcexe, { || mat_sint_specifikacija() } )
AADD( _opc, "4. porez na realizaciju" )
AADD( _opcexe, { || pornar() } )

// rudnik varijanta, treba parametar
AADD( _opc, "5. materijal po mjestima troska" )
AADD( _opcexe, { || pomjetros() } )

AADD( _opc, "6. cijena artikla po dobavljacima" )
AADD( _opcexe, { || cardob() } )
AADD( _opc, "7. specifikacija artikla po mjestu troska" )
AADD( _opcexe, { || iartpopogonima() } )
AADD( _opc, "8. specifikacija zaliha po roc.intervalima" )
AADD( _opcexe, { || mat_spec_br_dan() } )

f18_menu( "matizv", .f., _izbor, _opc, _opcexe )

my_close_all_dbf()

return




