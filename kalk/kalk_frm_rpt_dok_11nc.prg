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

function StKalk11_1()
local nCol0:=nCol1:=nCol2:=0,npom:=0

Private nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),123 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "OTPREMNICA Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz
HSEEK cIdKonto2
?  "KONTO razduzuje:",cIdKonto2,"-",naz

select kalk_pripr

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------" + if(!IsPDV() .or. gPDVMagNab == "N"," ----------","")

head_11_1(lPrikPRUC, m)

nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot4B:=nTot5:=nTot6:=nTot7:=0
nTot4c:=0

private aPorezi
aPorezi:={}

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

    scatter()  // formiraj varijable _....
    Marza2(); nMarza:=_marza   // izracunaj nMarza,nMarza2

    select ROBA; HSEEK kalk_pripr->IdRoba
    select TARIFA; HSEEK kalk_pripr->IdTarifa

    select kalk_pripr
    Tarifa(field->pkonto,field->idroba,@aPorezi)

    // inicijalizuj poreze za odre�enu robu
    VTPorezi()

    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    nPor1:=aIPor[1]
    if lPrikPRUC
      nPRUC:=aIPor[2]
      nPor2:=0
      nMarza2:=nMarza2-nPRUC
    else
      nPor2:=aIPor[2]
    endif

    if prow() > ( RPT_PAGE_LEN + gPStranica )
        FF
        @ prow(),123 SAY "Str:"+str(++nStr,3)
    endif

    nTot1+=  (nU1:= FCJ*Kolicina   )
    nTot2+=  (nU2:= Prevoz*Kolicina   )
    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= nmarza*Kolicina )
    nTot4b+=  (nU4b:= nmarza2*Kolicina )
    IF lPrikPRUC
      nTot4c+= (nU4c:=nPRUC*Kolicina)
    ENDIF
    nTot5+=  (nU5:= MPC*Kolicina )
    nTot6+=  (nU6:=(nPor1+nPor2)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol

    nCol0:=pcol()+1
    @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
    IF !lPrikPRUC
      @ prow(),pcol()+1 SAY Prevoz               PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
    if !IsPDV() .or. gPDVMagNab == "N"
    	@ prow(),pcol()+1 SAY nMarza              PICTURE PicCDEM
    endif

    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM

    IF lPrikPRUC
      @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
    ENDIF
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY aPorezi[POR_PPP]     PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    // drugi red ....
    @ prow()+1,nCol0    SAY  fcj*kolicina      picture picdem
    IF !lPrikPRUC
      @ prow(),  pcol()+1 SAY  prevoz*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  nc*kolicina      picture picdem
    if !IsPDV() .or. gPDVMagNab == "N"
    	@ prow(),  pcol()+1 SAY  nmarza*kolicina      picture picdem
    endif
    @ prow(),  nMPos:=pcol()+1 SAY  nmarza2*kolicina      picture picdem
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY nU4c                PICTURE PicCDEM
    ENDIF
    @ prow(),  pcol()+1 SAY  mpc*kolicina      picture picdem
    if !IsPDV()
    	if lPrikPRUC
    		@ prow(),nCol1 SAY aPorezi[POR_PPU]  picture picproc
    	else
    		@ prow(),nCol1 SAY PrPPUMP()  picture picproc
    	endif
    	@ prow(),  pcol()+1 SAY  nPor2             picture piccdem
    else
	@ prow(), pcol()+1 SAY aPorezi[POR_PPP] picture picproc
	@ prow(), pcol()+1 SAY nU6 picture piccdem
	@ prow(), pcol()+1 SAY nU7 picture piccdem
    endif

    // treci red .....
    if round(nc, 5) <> 0
    	@ prow()+1,nMPos SAY (nMarza2/nc)*100  picture picproc
    endif


    skip 1

enddo

if prow() > ( RPT_PAGE_LEN + gPStranica )
    FF
    @ prow(),123 SAY "Str:"+str(++nStr,3)
endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol0      SAY  nTot1        picture       PicDEM
IF !lPrikPRUC
  @ prow(),pcol()+1   SAY  nTot2        picture       PicDEM
ENDIF
@ prow(),pcol()+1   SAY  nTot3        picture       PicDEM

if !IsPDV() .or. gPDVMagNab == "N"
	@ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
endif

@ prow(),pcol()+1   SAY  nTot4b        picture       PicDEM
IF lPrikPRUC
  @ prow(),pcol()+1  SAY nTot4c        picture         PICDEM
ENDIF
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

Rektarife()

? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
? m

return
*}



function head_11_1(lPrikPRUC, cLine)
*{
if IsPDV()
	? cLine
  	? "*R * ROBA     * Kolicina *  NAB.CJ  *  TROSAK  *  NAB.CJ  *" + if(gPDVMagNab == "N", "MARZA   *", "") + "  MARZA   * PROD.CJ  *   PDV %  *   PDV    * PROD.CJ *"
  	? "*BR*          *          *   U VP   *   U MP   *   U MP   *" + if(gPDVMagNab == "N","   VP     *", "") + "    MP    * BEZ PDV  *          *          * SA PDV  *"
  	? "*  *          *          *          *          *          *" + if(gPDVMagNab == "N", "         *", "") + "          *          *          *          *         *"
else
	IF lPrikPRUC
  		? cLine
  		? "*R * ROBA     * Kolicina *  NAB.CJ  *  NAB.CJ  *  MARZA   *  MARZA   * POREZ NA *    MPC   *   PPP %  *   PPP    * MPC     *"
  		? "*BR*          *          *   U VP   *   U MP   *   VP     *    MP    *  MARZU   *          *   PPU %  *   PPU    * SA Por  *"
  		? "*  *          *          *          *          *          *          *    MP    *          *          *          *         *"
	ELSE
 		? cLine
  		? "*R * ROBA     * Kolicina *  NAB.CJ  *  TROSAK  *  NAB.CJ  *  MARZA   *  MARZA   *    MPC   *   PPP %  *   PPP    * MPC     *"
  		? "*BR*          *          *   U VP   *   U MP   *   U MP   *   VP     *    MP    *          *   PPU %  *   PPU    * SA Por  *"
  		? "*  *          *          *          *          *          *          *          *          *          *          *         *"
	ENDIF
endif
? cLine

return
*}
