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

function StKalk14PDV()
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
B_ON

if cidvd=="14".or.cidvd=="74"
	?? "IZLAZ KUPCU PO VELEPRODAJI"
elseif cidvd=="15"
  	?? "OBRACUN VELEPRODAJE"
else
  	?? "STORNO IZLAZA KUPCU PO VELEPRODAJI"
endif

?
B_OFF
P_COND
??

? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,", Datum:",DatDok

@ prow(),125 SAY "Str:"+str(++nStr,3)

select PARTN
HSEEK cIdPartner

?  "KUPAC:", cIdPartner, "-", PADR( naz, 20 ), SPACE(5), "DOKUMENT Broj:", cBrFaktP, "Datum:", dDatFaktP

if cidvd=="94"
	select konto
	HSEEK cidkonto2
 	?  "Storno razduzenja KONTA:", cIdKonto, "-", ALLTRIM( naz )
else
 	select konto
	HSEEK cidkonto2
 	?  "KONTO razduzuje:", kalk_pripr->mkonto, "-", ALLTRIM( naz )
 	if !empty(kalk_pripr->Idzaduz2)
		?? " Rad.nalog:", kalk_pripr->Idzaduz2
	endif
endif

select kalk_pripr
select koncij
seek trim(kalk_pripr->mkonto)
select kalk_pripr

m:="--- ---------- ---------- ----------  ---------- ---------- ---------- ----------- --------- ----------"

? m

? "*R * ROBA     * Kolicina *  NABAV.  *  MARZA   * PROD.CIJ *  RABAT    * PROD.CIJ*   PDV    * PROD.CIJ *"
? "*BR*          *          *  CJENA   *          *          *           * -RABAT  *          * SA PDV   *"

? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

fNafta:=.f.

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

    if prow() > ( RPT_PAGE_LEN + dodatni_redovi_po_stranici() )
        FF
        @ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    if kalk_pripr->idvd="15"
      SKol:= - Kolicina
    else
      SKol:=Kolicina
    endif

    nVPCIzbij:=0

    if roba->tip=="X"
      nVPCIzbij:=(MPCSAPP/(1+tarifa->opp/100)*tarifa->opp/100)
    endif

    nTot4+=  (nU4:=round(NC*Kolicina*iif(idvd="15",-1,1) ,gZaokr)     )  // nv

    if gVarVP=="1"
      if (roba->tip $ "UTY")
        nU5:=0
      else
        nTot5+=  (round(nU5:=nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr)  ) // ruc
      endif
      nTot6+=  (nU6:=round(TARIFA->VPP/100*iif(nMarza<0,0,nMarza)*Kolicina*iif(idvd="15",-1,1),gZaokr) )  //pruc
      nTot7+=  (nU7:=nU5-nU6  )    // ruc-pruc
    else
      // obracun poreza unazad - preracunata stopa
      if (roba->tip $ "UTY")
        nU5:=0
      else
      if nMarza>0
        (nU5:=round(nMarza*Kolicina*iif(idvd="15",-1,1)/(1+tarifa->vpp/100),gZaokr)) // ruc
      else
        (nU5:=round(nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr)) // ruc
      endif
      endif

      nU6:=round(TARIFA->VPP/100/(1+tarifa->vpp/100) * iif(nMarza<0,0,nMarza)*Kolicina*iif(idvd="15",-1,1),gZaokr)
      //nU6 = pruc

      // franex 20.11.200 nasteliti ruc + pruc = bruto marza !!
      if round(nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr) > 0 // pozitivna marza
        nU5 :=  round(nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr)  - nU6
                 //  bruto marza               - porez na ruc
      endif
      nU7:=nU5+nU6      // ruc+pruc

      nTot5+= nU5
      nTot6+= nU6
      nTot7+= nU7

    endif

    nTot8+=  (nU8:=round( (VPC-nVPCIzbij)*Kolicina*iif(idvd="15",-1,1),gZaokr))
    nTot9+=  (nU9:=round(RABATV/100*VPC*Kolicina*iif(idvd="15",-1,1),gZaokr))

    if roba->tip=="X"
      // kod nafte prikazi bez poreza
      nTota+=  (nUa:=round(nU8-nU9,gZaokr))
      fnafta:=.t.
    else
      nTota+=  (nUa:=round(nU8-nU9,gZaokr))     // vpv sa ukalk rabatom
    endif
    if roba->tip=="X"
       nTotb:=nUb:=0
       nTotc+=  (nUc:=round(VPC*kolicina*iif(idvd="15",-1,1),gzaokr))   // vpv+ppp
    else
       if idvd=="15" // kod 15-ke nema poreza na promet
         nUb:=0
       else
         nUb:=round(nUa*mpc/100,gZaokr) // ppp
       endif
       nTotb+=  nUb
       nTotc+=  (nUc:=nUa+nUb )   // vpv+ppp
    endif

    if koncij->naz="P"
     nTotd+=  (nUd:=round(fcj*kolicina*iif(idvd="15",-1,1),gZaokr) )  // trpa se planska cijena
    else
     nTotd+=  (nUd:=nua+nub+nu6 )   //vpc+pornapr+pornaruc
    endif

    // 1. PRVI RED
    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""
    ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"
    if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + roba->barkod
	endif
    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina*iif(idvd="15",-1,1)  PICTURE PicKol
    nC1:=pcol()+1
    @ prow(),pcol()+1 SAY NC                          PICTURE PicCDEM
    private nNc:=0
    if nc<>0
      nNC:=nc
    else
      nNC:=99999999
    endif

    @ prow(),pcol()+1 SAY (VPC-nNC)/nNC*100               PICTURE PicProc

    @ prow(),pcol()+1 SAY VPC-nVPCIzbij       PICTURE PiccDEM
    @ prow(),pcol()+1 SAY RABATV              PICTURE PicProc
    @ prow(),pcol()+1 SAY VPC*(1-RABATV/100)-nVPCIzbij  PICTURE PiccDEM

    if roba->tip $ "VKX"
      @ prow(),pcol()+1 SAY padl("VT-"+str(tarifa->opp,5,2)+"%",len(picproc))
    else
     if idvd = "15"
        @ prow(),pcol()+1 SAY 0          PICTURE PicProc
     else
        @ prow(),pcol()+1 SAY MPC        PICTURE PicProc
     endif
    endif

    if roba->tip="X"  // nafta , kolona VPC SA PP
     @ prow(),pcol()+1 SAY VPC PICTURE PicCDEM
    else
     @ prow(),pcol()+1 SAY VPC*(1-RabatV/100)*(1+mpc/100) PICTURE PicCDEM
    endif

    // 2. DRUGI RED
    @ prow()+1,4 SAY IdTarifa+roba->tip
    @ prow(),nC1    SAY nU4  pict picdem
    @ prow(),pcol()+1 SAY nu8-nU4  pict picdem
    @ prow(),pcol()+1 SAY nu8  pict picdem
    @ prow(),pcol()+1 SAY nU9  pict picdem
    @ prow(),pcol()+1 SAY nUA  pict picdem
    @ prow(),pcol()+1 SAY nub  pict picdem
    @ prow(),pcol()+1 SAY nUC  pict picdem

    skip

enddo

if prow() > ( RPT_PAGE_LEN + dodatni_redovi_po_stranici() )
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m

@ prow()+1,0        SAY "Ukupno:"
@ prow(),nc1      SAY nTot4  pict picdem
@ prow(),pcol()+1 SAY ntot8-nTot4  pict picdem
@ prow(),pcol()+1 SAY ntot8  pict picdem
@ prow(),pcol()+1 SAY ntot9  pict picdem
@ prow(),pcol()+1 SAY nTotA  pict picdem
@ prow(),pcol()+1 SAY nTotB  pict picdem
@ prow(),pcol()+1 SAY nTotC  pict picdem

? m

return
*}
