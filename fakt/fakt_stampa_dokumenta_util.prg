/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"

function KatBr()
if roba->(fieldpos("KATBR"))<>0
  if !empty(roba->katbr)
     return " ("+trim(roba->katbr)+")"
  endif
endif
return ""

 
function GetRegion()
local cRegion:=" "
local nArr

nArr:=SELECT()
SELECT (F_ROBA)
if !USED()
  O_ROBA
endif
if ROBA->(FIELDPOS("IDTARIFA2")<>0)
   cRegion := Pitanje( , "Porezi za region (1/2/3) ?" , "1" , " 123" )
endif
SELECT (nArr)
return cRegion


/*! \fn NSRNPIIdRoba(cSR,fSint)
 *  \brief Nasteli sif->roba na fakt_pripr->idroba
 *  \param cSR
 *  \param fSint  - ako je fSint:=.t. sinteticki prikaz
 */
 
function NSRNPIdRoba(cSR,fSint)
if fSint=NIL
  fSint:=.f.
endif

IF cSR==NIL; cSR:=fakt_pripr->IdRoba; ENDIF
SELECT ROBA
IF (gNovine=="D" .or.  fSint)
  hseek PADR(LEFT(cSR,gnDS),LEN(cSR))
  IF !FOUND() .or. ROBA->tip!="S"
    hseek cSR
  ENDIF
ELSE
  hseek cSR
ENDIF
IF SELECT("PRIPR")!=0
  select fakt_pripr
ELSE
  SELECT (F_PRIPR)
ENDIF

return

/*! \fn GetRtmFile(cDefRtm)
 *  \brief Vraca naziv rtm fajla za stampu
 */
function GetRtmFile(cDefRtm)
aRtm:={}
AADD(aRtm, {IzFmkIni("DelphiRb", "Rtm1", "", KUMPATH)})
AADD(aRtm, {IzFmkIni("DelphiRb", "Rtm2", "", KUMPATH)})
AADD(aRtm, {IzFmkIni("DelphiRb", "Rtm3", "", KUMPATH)})

// ako nema nista u matrici vrati default
if LEN(aRtm) == 0
	return cDefRtm
endif

private GetList:={}

Box(,6, 30)
	@ 1+m_x, 2+m_y GET aRtm[1, 1]
	@ 2+m_x, 2+m_y GET aRtm[1, 2]
	@ 3+m_x, 2+m_y GET aRtm[1, 3]
	read
BoxC()

return cRet


// prebacio u funkcije iz fakt.ch #command
function pocni_stampu()
	if !lSSIP99 .and. !StartPrint()
		close all
		return
	endif
return

function zavrsi_stampu()
	if !lSSIP99 
		EndPrint()
	endif
return

 
function JokSBr()
if "U" $ TYPE("BK_SB")
	BK_SB := .f.
endif
return IF(gNW=="R","  KJ/KG ", IIF(glDistrib,"", IIF(BK_SB, "  BARKOD   ", "Ser.broj")))

/*! \fn Koef(cDinDem)
 *  \brief Konverzija valute
 *  \param cDinDem
 */
 
function Koef(cdindem)
local nNaz,nRet,nArr,dDat

if cDinDem==left(ValSekund(),3)
	return 1/UbaznuValutu(datdok)
else
 	return 1
endif

