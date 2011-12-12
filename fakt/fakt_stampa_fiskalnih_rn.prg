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

// Stampa fiskalnih racuna od broja do broja
function st_fisc_per( cIdFirma, cIdTipDok, cBrOd, cBrDo )
local lDirekt := .f.
local lAutoStampa := .t.
local nDevice := 0
local nTRec

if cIdFirma <> nil
	lDirekt := .t.
endif

if !lDirekt
	
	cIdFirma:=gFirma
	cIdTipDok:="10"
	cBrOd:=space(8)
	cBrDo:=space(8)

	Box("", 5, 35)
        @ m_x+1, m_y+2 SAY "Dokument:"
        @ m_x+2, m_y+2 SAY " RJ-tip:" GET cIdFirma
        @ m_x+2, col()+1 SAY "-" GET cIdTipDok
        @ m_x+3, m_y+2 SAY "Brojevi:" 
	@ m_x+4, m_y+3 SAY "od" GET cBrOd VALID !EMPTY(cBrOd)
	@ m_x+4, col()+1 SAY "do" GET cBrDo VALID !EMPTY(cBrDo)
        
	read
	BoxC()

	if LASTKEY()==K_ESC
		return
	endif
endif

close all

// uzmi device iz liste uredjaja
nDevice := list_device( cIdTipDok )

O_PARTN
O_ROBA
O_SIFK
O_SIFV
O_FAKT

O_FAKT_DOKS
select fakt_doks
set order to tag "1"
hseek cIdFirma + cIdTipDok

if Found()
	do while !EOF() .and. fakt_doks->idfirma = cIdFirma ;
		.and. fakt_doks->idtipdok = cIdTipDok
		
		nTRec := RecNo()
		
		if ALLTRIM(doks->brdok) >= ALLTRIM(cBrOd) .and. ;
			ALLTRIM(doks->brdok) <= ALLTRIM(cBrDo) 
			
			// pozovi stampu fiskalnog racuna
			nErr := fakt_fisc_rn( fakt_doks->idfirma, ;
				doks->idtipdok, ;
				doks->brdok, lAutoStampa, nDevice )
		
			if ( nErr > 0 ) 
				msgbeep("Prekidam operaciju stampe radi greske!")
				exit
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


