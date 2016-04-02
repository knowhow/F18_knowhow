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

/*
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_18.prg,v $
 * $Author: mirsad $
 * $Revision: 1.3 $
 * $Log: rpt_18.prg,v $
 * Revision 1.3  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 */


/*! \file fmk/kalk/mag/dok/1g/rpt_18.prg
 *     Stampa dokumenta tipa 18
 */


/* StKalk18()
 *     Stampa dokumenta tipa 18
 */

function StKalk18()
*{
local nCol1:=nCol2:=0,npom:=0,nCR:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

if cSeek!='IZDOKS'  // stampa se vise dokumenata odjednom
  nStr:=1
endif

cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
B_ON
?? "PROMJENA CIJENA U MAGACINU"
B_OFF
?
P_COND
? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),", Datum:",DatDok
@ prow(),122 SAY "Str:"+str(nStr,3)

select KONTO; HSEEK cidkonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz
select kalk_pripr

m:="--- ------------------------------------------------ ----------- ---------- ---------- ---------- ---------- ---------- ----------"

? m
if IsPDV()
	? "*RB*       ROBA                                     * Kolicina  * STARA PC *  RAZLIKA *  NOVA  PC*  IZNOS   *   PDV%  *  IZNOS   *"
	? "*  *                                                *           *  BEZ PDV *PC BEZ PDV*  BEZ PDV *  RAZLIKE *         *   PDV    *"
else
	? "*RB*       ROBA                                     * Kolicina  * STARA VPC*  RAZLIKA *  NOVA VPC*  IZNOS   *   PPP%  *  IZNOS   *"
	? "*  *                                                *           *          *    VPC   *          *  RAZLIKE *         *   PPP    *"
endif
? m
nTotA:=nTotB:=nTotC:=0


private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

/*
 if idpartner+brfaktp+idkonto+idkonto2<>cidd
  set device to screen
  Beep(2)
  Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
  set device to printer
 endif
*/


 select ROBA; HSEEK kalk_pripr->IdRoba
 select TARIFA; HSEEK kalk_pripr->IdTarifa
 select kalk_pripr

 KTroskovi()

if prow() > page_length()
    FF
    @ prow(),122 SAY "Str:"+str(++nStr,3)
endif

 VTPOREZI()

nTotA+=VPC*Kolicina
nTotB+=vpc/(1+_PORVT)*_PORVT*kolicina

@ prow()+1,0 SAY  Rbr PICTURE "999"
@ prow(),pcol()+1 SAY IdRoba
aNaz:=SjeciStr(trim(ROBA->naz)+" ( "+ROBA->jmj+" )",37)
@ prow(),(nCR:=pcol()+1) SAY  ""; ?? aNaz[1]
@ prow(),52 SAY Kolicina
@ prow(),pcol()+1 SAY MPCSAPP  PICTURE PicCDEM
@ prow(),pcol()+1 SAY VPC      PICTURE PicCDEM
@ prow(),pcol()+1 SAY MPCSAPP+VPC  PICTURE PicCDEM
nC1:=pcol()+1
@ prow(),pcol()+1 SAY VPC*Kolicina  PICTURE PicDEM
@ prow(),pcol()+1 SAY _porvt*100    PICTURE Picproc
@ prow(),pcol()+1 SAY vpc/(1+_PORVT)*_PORVT*kolicina   PICTURE Picdem

// novi red
if len(aNaz)>1
 @ prow()+1,0 SAY ""
 @ prow(),nCR  SAY ""; ?? aNaz[2]
endif

skip

enddo

if prow() > page_length()
    FF
    @ prow(),125 SAY "Str:"+str(++nStr,3)
endif
? m
@ prow()+1,0        SAY "Ukupno:"

@ prow(),nC1  SAY nTota         PICTURE PicDEM
@ prow(),pcol()+1  SAY 0             PICTURE PicDEM
@ prow(),pcol()+1  SAY nTotB         PICTURE PicDEM

? m

?
P_10CPI
? padl("Clanovi komisije: 1. ___________________",75)
? padl("2. ___________________",75)
? padl("3. ___________________",75)
?
return
*}
