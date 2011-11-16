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


#include "pos.ch"



function pos_menu_modem()
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. aktiviraj DIAL-UP Servera W9X")
AADD(opcexe,{|| DialUpOn()}) 
AADD(opc, "2. deaktiviraj DIAL-UP Server W9X")
AADD(opcexe,{|| DialUpOff()})
AADD(opc, "3. poziv modem (PcAny)")
AADD(opcexe,{|| ModemPcAny()})

Menu_SC("modem")

return .f.




function ModemPcAny()

private cKom

if FILE("c:\tops\modem.bhf")
	cKom:="start c:\tops\modem.bhf"
else
       	copy file ("c:\windows\desktop\modem.bhf") TO ("c:\tops\modem.bhf")
       	cKom:="start c:\windows\desktop\modem.bhf"
endif
run &cKom

return



function DialUpOn()
private cKom:=""
if Pitanje(,"Aktivirati Dial-up Servera D ?","D")=="D"
	if gOpSist$"W2000WXP"
		cKom:="start "
	endif
	cKom+="serverok /ON"
        run &ckom
endif

return


function DialUpOff()

private cKom:=""

if pitanje(,"DEAKTIVIRATI Dial-up Server D ?","D")=="D"
	if gOpSist$"W2000WXP"
		cKom:="start "
	endif
	cKom+="serverok /OFF"    
	run &ckom
endif

return



