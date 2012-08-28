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


#include "kalk.ch"


function StKalk95_1()
local cKto1
local cKto2
local cIdZaduz2
local cPom
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2
cIdZaduz2 := IdZaduz2

P_12CPI
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,"  Datum:",DatDok
@ prow(),76 SAY "Str:"+str(++nStr,3)

?
if cidvd=="16"  // doprema robe
 ? "PRIJEM U MAGACIN (INTERNI DOKUMENT)"
elseif cidvd=="96"
 ? "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
elseif cidvd=="97"
 ? "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
elseif cidvd=="95"
 ? "OTPIS MAGACIN"
endif
? 

if cIdVd $ "95#96#97"
	cPom:= "Razduzuje:"
	cKto1:= cIdKonto2
	cKto2:= cIdKonto
else
	cPom:= "Zaduzuje:"
	cKto1:= cIdKonto
	cKto2:= cIdKonto2
endif

select konto
hseek cKto1


? PADL(cPom, 14), cKto1 + "- " + PADR( konto->naz, 20 )

if !empty(cKto2)

	if cIdVd $ "95#96#97"
		cPom:= "Zaduzuje:"
	else
		cPom:= "Razduzuje:"
	endif

	select konto
	hseek cKto2
        ? PADL(cPom, 14), cKto2 + "- " + PADR( konto->naz, 20 )
endif
if !empty(cIdZaduz2)
	? PADL("Rad.nalog:", 14), cIdZaduz2
endif
?

select kalk_pripr
m:="--- ----------- --------------------------- ---------- ----------- -----------"
? m
? "*R * Konto     * ARTIKAL                   * Kolicina *  NABAV.  *    NV     *"
? "*BR*           *                           *          *  CJENA   *           *"
? m

nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD


  nT4:=nT5:=nT8:=0
  cBrFaktP:=brfaktp; dDatFaktP:=datfaktp; cIdpartner:=idpartner
  do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD .and. idpartner+brfaktp+dtos(datfaktp)== cidpartner+cbrfaktp+dtos(ddatfaktp)

    if cIdVd $ "97" .and. tbanktr=="X"
      skip 1
      loop
    endif

    select ROBA
    HSEEK kalk_pripr->IdRoba
    select TARIFA
    HSEEK kalk_pripr->IdTarifa
    select kalk_pripr
    KTroskovi()

    if prow()>62+gPStranica
    	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    SKol:=Kolicina

    nT4 += (nU4:= NC * Kolicina     )  // nv

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    if idvd=="16"
     cNKonto:=idkonto
    else
     cNKonto:=idkonto2
    endif
    @ prow(),4 SAY  ""
    ?? padr(cNKonto,11), idroba, trim(LEFT(ROBA->naz, 40))+"("+ROBA->jmj+")"
    @ prow()+1,46 SAY Kolicina  PICTURE PicKol
    
    nC1:=pcol()+1
    @ prow(),pcol()+1   SAY NC                          PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nU4  pict picdem

    if is_uobrada()
    	@ prow()+1, 5 SAY "JCI br: " + PADR(jci_no,10) + " EX3 br: " + PADR(ex_no,10)
    endif
    skip
  enddo

  nTot4+=nT4
  nTot5+=nT5
  nTot8+=nT8
  
  ? m
  @ prow()+1,0        SAY "Ukupno za "
  ?? cidpartner
  ? cBrFaktP, "/", dDatFaktp
  @ prow(),nC1      SAY 0  pict "@Z "+picdem
  @ prow(),pcol()+1 SAY nT4  pict picdem
  ? m

enddo

if prow()>61+gPStranica
 FF
 @ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nc1      SAY 0  pict "@Z "+picdem
@ prow(),pcol()+1 SAY nTot4  pict picdem

? m
return
*}

