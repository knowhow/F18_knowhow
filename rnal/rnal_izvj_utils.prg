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


#include "rnal.ch"


// ---------------------------------------
// prikaz informacije na izvjestaju 
// ---------------------------------------
function __rpt_info( nLeft )
local cDesc := ""

if nLeft == nil
	nLeft := pcol() + 1
endif

cDesc := "na dan: " + DTOC(DATE())
cDesc += " "
cDesc += "oper: " + goModul:oDataBase:cUser

@ prow(), nLeft SAY cDesc

return



// ----------------------------------------------
// standardni uslovi izvjestaja
// ----------------------------------------------
function std_vars( dD_f, dD_t, nOper, cStatus )

dD_f := DATE() - 30
dD_t := DATE()
nOper := 0
cStatus := "S"

Box(,6,60)

	@ m_x + 1, m_y + 2 SAY "Datum od:" GET dD_f
	
	@ m_x + 1, col() + 1 SAY "do:" GET dD_t
	
	@ m_x + 2, m_y + 2 SAY "Operater (0 - svi):" GET nOper ;
		VALID {|| nOper == 0 .or. p_users(@nOper) } ;
		PICT "999"
  	@ m_x + 3, m_y + 2 SAY "(O)tvoreni / (Z)atvoreni / (S)vi" GET cStatus ;
		VALID cStatus $ "OZS" PICT "@!"
	read

BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1

