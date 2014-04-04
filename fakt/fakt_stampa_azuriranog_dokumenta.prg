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

function fakt_stampa_azuriranog()
private cIdFirma, cIdTipDok, cBrDok

cIdFirma:=gFirma
cIdTipDok:="10"
cBrdok:=space(8)

Box("", 2, 35)
        @ m_x+1, m_y+2 SAY "Dokument:"
        @ m_x+2, m_y+2 SAY " RJ-tip-broj:" GET cIdFirma
        @ m_x+2, col()+1 SAY "-" GET cIdTipDok
        @ m_x+2, col()+1 SAY "-" GET cBrDok
        read
BoxC()

if LASTKEY()==K_ESC
	return
endif

my_close_all_dbf()

StampTXT(cIdFirma, cIdTipDok, cBrDok)

select F_FAKT_PRIPR
if USED()
    use
endif

return


// Stampa azuriranih faktura od broja do broja
function fakt_stampa_azuriranog_period(cIdFirma, cIdTipDok, cBrOd, cBrDo)
local lDirekt := .f.
local cBatch := "N"

if cIdFirma <> nil
	lDirekt := .t.
endif

if !lDirekt
	
	cIdFirma:=gFirma
	cIdTipDok:="10"
	cBrOd:=space(8)
	cBrDo:=space(8)
	cBatch := "D"

	Box("", 5, 35)
        @ m_x+1, m_y+2 SAY "Dokument:"
        @ m_x+2, m_y+2 SAY " RJ-tip:" GET cIdFirma
        @ m_x+2, col()+1 SAY "-" GET cIdTipDok
        @ m_x+3, m_y+2 SAY "Brojevi:" 
	@ m_x+4, m_y+3 SAY "od" GET cBrOd VALID !EMPTY(cBrOd)
	@ m_x+4, col()+1 SAY "do" GET cBrDo VALID !EMPTY(cBrDo)
	@ m_x+5, m_y+2 SAY "batch rezim ?" GET cBatch VALID cBatch $ "DN" ;
						PICT "@!"
        
	read
	BoxC()

	if LASTKEY()==K_ESC
		return
	endif
endif

my_close_all_dbf()
O_FAKT_DOKS
set order to tag "1"
hseek cIdFirma + cIdTipDok

if Found()
	do while !EOF() .and. fakt_doks->idfirma = cIdFirma .and. fakt_doks->idtipdok = cIdTipDok
		nTRec := RecNo()
		
		if ALLTRIM(fakt_doks->brdok) >= ALLTRIM(cBrOd) .and. ALLTRIM(fakt_doks->brdok) <= ALLTRIM(cBrDo) 
			
			if cBatch == "D"
				cDirPom := gcDirekt
				gcDirekt := "B"
				// prebaci na direkt stampu
			endif
			
			StampTXT(fakt_doks->idfirma,fakt_doks->idtipdok,fakt_doks->brdok)
			
			if cBatch == "D"
				gcDirekt := cDirPom
			endif
			
		endif
		
		select fakt_doks
		go (nTRec)
		skip
	enddo
else
	MsgBeep("Trazeni tip dokumenta ne postoji!")
endif

select fakt_doks
use
return


