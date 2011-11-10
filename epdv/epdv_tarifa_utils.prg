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


#include "epdv.ch"

/*
* ----------------------------------------------------------------
*                           Copyright Sigma-com software 2006
* ----------------------------------------------------------------
*/


// ----------------------------
// napuni sifrarnik tarifa sa 
function epdv_set_sif_tarifa()


SELECT (F_TARIFA)
if !used()
	O_TARIFA
endif

// nabavka od pdv obveznika, standardna prodaja
cPom:=PADR("PDV17" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "PDV 17%"
	replace opp with 17
endif


// stopa 0
cPom:=PADR("PDV0" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "PDV 0%"
	replace opp with 0
endif


// nabavka od poljoprivrednika oporezivi dio 5%
cPom:=PADR("PDV7PO" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "POLJOPR., OPOR. DIO PDV 17%"
	replace opp with 17
endif

// nabavka od poljoprivrednika neopoprezivi dio 95%
cPom:=PADR("PDV0PO" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "POLJOPR., NEOPOR. DIO PDV 0%"
	replace opp with 0
endif



// uvoz  oporezivo
cPom:=PADR("PDV7UV" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "UVOZ OPOREZIVO, PDV 17"
	replace opp with 17
endif


// uvoz neoporezivo
cPom:=PADR("PDV0UV" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "UVOZ NEOPOREZIVO, PDV 0%"
	replace opp with 0
endif


// nabavka neposlovne svrhe - ne priznaje se ul. porez kao odbitak
// isporuka neposlovne svrhe - izl. pdv standardno
cPom:=PADR("PDV7NP" ,6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "NEPOSLOVNE SVRHE, NAB/ISP"
	replace opp with 17
endif


// nabavka i prodaja avansne fakture
cPom:=PADR("PDV7AV" , 6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "AVANSNE FAKTURE, PDV 17%"
	replace opp with 17
endif


// isporuke, izvoz
cPom:=PADR("PDV0IZ" , 6)
seek cPom
if !found()
	append blank
	replace id with cPom
	replace naz with "IZVOZ, PDV 0%"
	replace opp with 0
endif


return

