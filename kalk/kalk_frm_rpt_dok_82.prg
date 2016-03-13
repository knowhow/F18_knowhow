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


function StKalk82()
local nCol0:=nCol1:=nCol2:=0,npom:=0

Private nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

select KONTO; HSEEK cIdKonto
?  "Magacin razduzuje:",cIdKonto,"-",ALLTRIM(naz)

select kalk_pripr

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "*R * ROBA     * Kolicina *   NC     *  VPC    *    MPC   *   PPP %  *   PPP    *  MPC     *"
? "*BR*          *          *          *         *          *   PPU %  *   PPU    *  SA Por  *"
? "*  *          *          *   sum    *         *    sum   *    sum   *   sum    *   sum    *"
? m
nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0

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
    Marza2R()   // izracunaj nMarza2
    KTroskovi()

    select ROBA; HSEEK kalk_pripr->IdRoba
    select TARIFA; HSEEK kalk_pripr->IdTarifa
    select kalk_pripr
    VtPorezi()

    if prow() > ( RPT_PAGE_LEN + dodatni_redovi_po_stranici() )
        FF
        @ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= vpc*(1-rabatv/100)*Kolicina )
    nTot5+=  (nU5:= MPC*Kolicina )
    nPor1:=  MPC*_OPP
    nPor2:=  MPC*(1+_OPP)*_PPP
    nTot6+=  (nU6:=(nPor1+nPor2)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

	if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + roba->barkod
	endif

    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol

    nCol0:=pcol()+1
    @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY vpc*(1-rabatv/100)   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY TARIFA->OPP          PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1, nCol0     SAY  nc*kolicina      picture picdem
    @ prow(),   pcol()+1  SAY  vpc*(1-rabatv/100)*kolicina  picture picdem
    @ prow(),   pcol()+1  SAY  mpc*kolicina      picture picdem

    @ prow(),nCol1    SAY    _PPP       picture picproc
    @ prow(),  pcol()+1 SAY  nPor2             picture piccdem

    skip

enddo

if prow() > ( RPT_PAGE_LEN + dodatni_redovi_po_stranici() )
    FF
    @ prow(),125 SAY "Str:"+str(++nStr,3)
endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol0      SAY  nTot3        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

IF prow() > ( RPT_PAGE_LEN + dodatni_redovi_po_stranici() )
    FF
    @ prow(),125 SAY "Str:"+str(++nStr,3)
endif
nRec:=recno()
select kalk_pripr
set order to tag "2"
seek cidfirma+cidvd+cbrdok
m:="------ ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "* Tar *  PPP%    *   PPU%   *    MPV   *    PPP   *   PPU    * MPVSAPP *"
? m
nTot1:=nTot2:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
do while !eof() .and. cidfirma+cidvd+cbrdok==idfirma+idvd+brdok
  cidtarifa:=idtarifa
  nU1:=nU2:=nU3:=nU4:=0
  select tarifa; HSEEK cidtarifa
  select kalk_pripr
  do while !eof() .and. cidfirma+cidvd+cbrdok==idfirma+idvd+brdok .and. idtarifa==cidtarifa
    select roba; HSEEK kalk_pripr->idroba; select kalk_pripr
    VtPorezi()
    nU1+=mpc*kolicina
    nU2+=mpc*_OPP*kolicina
    nU3+=mpc*(1+_OPP)*_PPP*kolicina
    nU4+=mpcsapp*kolicina
    nTot5+=(mpc-nc)*kolicina
    skip
  enddo
  nTot1+=nu1; nTot2+=nU2; nTot3+=nU3
  nTot4+=nU4
  ? cidtarifa
  @ prow(),pcol()+1   SAY _OPP*100 pict picproc
  @ prow(),pcol()+1   SAY _PPP*100 pict picproc
  nCol1:=pcol()+1
  @ prow(),pcol()+1   SAY nu1 pict picdem
  @ prow(),pcol()+1   SAY nu2 pict picdem
  @ prow(),pcol()+1   SAY nu3 pict picdem
  @ prow(),pcol()+1   SAY nu4 pict picdem
enddo
IF prow() > ( RPT_PAGE_LEN + dodatni_redovi_po_stranici() )
    FF
    @ prow(),125 SAY "Str:"+str(++nStr,3)
endif
? m
? "UKUPNO"
@ prow(),nCol1      SAY nTot1 pict picdem
@ prow(),pcol()+1   SAY nTot2 pict picdem
@ prow(),pcol()+1   SAY nTot3 pict picdem
@ prow(),pcol()+1   SAY nTot4 pict picdem
? m
? "RUC:";  @ prow(),pcol()+1 SAY nTot5 pict picdem
? m

set order to tag "1"
go nRec
return
