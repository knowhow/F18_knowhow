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


#include "fakt.ch"


function Mnu_Narudzba()
*{
local cNarFirma:=gFirma
local cNarIdVD:=SPACE(2)
local cNarBrDok:=SPACE(8)
local cPripr:="N"
local lPripr:=.f.

Box(,5,70)
	@ m_x+1, m_y+2 SAY "Stampa narudzbenice:                 "
	@ m_x+2, m_y+2 SAY "-------------------------------------"
	@ m_x+3, m_y+2 SAY "Na osnovu dokumenta u pripremi" GET cPripr VALID cPripr$"DN" PICT "@!"
	read
	if cPripr=="N"
		@ m_x+3, m_y+2 SAY SPACE(60)
		@ m_x+4, m_y+2 SAY "Narudzbenica na osnovu dokumenta: "
		@ m_x+5, m_y+2 SAY "" GET cNarFirma 
		@ m_x+5, m_y+6 SAY "-" GET cNarIdVD
		@ m_x+5, m_y+11 SAY "-" GET cNarBrDok
	endif
	read
BoxC()

if LastKey()==K_ESC
	return
endif
if cPripr=="D"
	lPripr:=.t.
endif

Rpt_Narudzbenica(cNarFirma, cNarIdVD, cNarBrDok, lPripr)

return
*}


function Rpt_Narudzbenica(cIdFirma, cIdVD, cBrDok, lPriprema)
*{
private cComArgs:=""


cFmkNETExec:="start sc.fmk.winui.exe "
cNarudzbaArgs:=" /FAKT /NARUDZBA "
cDokArgs:="/IdFirma=" + cIdFirma + " /IdTipDok=" + cIdVD + " /BrNal=" + cBrDok

cComArgs+=cFmkNETExec + cNarudzbaArgs

if lPriprema 
	cComArgs+="/IdFirma=PRIPR" 
endif	

if !lPriprema
	cComArgs+=cDokArgs 
endif

run &cComArgs

return
*}







