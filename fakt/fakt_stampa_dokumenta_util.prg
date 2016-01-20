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

function KatBr()
if roba->(fieldpos("KATBR"))<>0
  if !empty(roba->katbr)
     return " (" + TRIM(roba->katbr) + ")"
  endif
endif
return ""

 
function GetRegion()
local cRegion:=" "
local nArr

nArr := SELECT()
SELECT (F_ROBA)
if !USED()
  O_ROBA
endif

if ROBA->(FIELDPOS("IDTARIFA2")<>0)
   cRegion := Pitanje( , "Porezi za region (1/2/3) ?" , "1" , " 123" )
endif
SELECT (nArr)
return cRegion

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


function pocni_stampu()
	if !lSSIP99 .and. !StartPrint()
		my_close_all_dbf()
		return
	endif
return


function zavrsi_stampu()
	if !lSSIP99
        my_close_all_dbf() 
		EndPrint()
	endif
return


// --------------------------------------------------------
// --------------------------------------------------------
function StampTXT(cIdFirma, cIdTipDok, cBrDok, lJFill)

private InPicDEM:=PicDEM
private InPicCDEM:=PicCDEM  

if lJFill == nil
        lJFill := .f.
endif

if cIdFirma == nil
  StDokPDV()
else
  StDokPDV(cIdFirma, cIdTipDok, cBrDok, lJFill)
endif
    
return

// ------------------------------------------
// fakt_zagl_firma()
// Ispis zaglavlja na izvjestajima
// ------------------------------------------
function fakt_zagl_firma()
?

P_12CPI
U_OFF
B_OFF
I_OFF

?? "Subjekt:"; U_ON; ?? PADC(TRIM(gTS) + " " + TRIM(gNFirma), 39); U_OFF
?  "Prodajni objekat:"; U_ON; ?? PADC(ALLTRIM(NazProdObj()), 30) ; U_OFF
?  "(poslovnica-poslovna jedinica)"
?  "Datum:"; U_ON; ?? PADC(SrediDat(DATDOK),18); U_OFF
?
?
return


