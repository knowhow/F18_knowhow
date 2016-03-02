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


function StKalk80(fBezNc)
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

if fbezNc==NIL
 fBezNC:=.f.
endif

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP

cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
?
? "PRIJEM U PRODAVNICU (INTERNI DOKUMENT)"
?
P_COND
? "KALK. DOKUMENT BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN
HSEEK cIdPartner

?  "DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO
HSEEK cIdKonto

?  "KONTO zaduzuje :",cIdKonto,"-",ALLTRIM( naz )


m:="--- -------------------------------------------- ----------"+;
   iif(fBezNC,""," ---------- ----------")+;
   " ---------- ----------"


? m

if !IsPdv()
   // 1. red
   ? "*R.* Roba                                       * kolicina *"+;
   iif(fBezNC, "", "  Nab.cj  * marza    *")+;
   "   MPC    *  MPC    *"
   // 2.red
   ? "*br* Tarifa                                     *          *"+;
   iif(fBezNC,"","          *          *")+;
   "          * sa PPP  *"
else
   // 1. red
   ? "*R.* Roba                                       * kolicina *"+;
   iif(fBezNC, "", "  Nab.cj  * marza    *")+;
   "   MPC    *  MPC    *"
   // 2.red
   ? "*br* Tarifa                                     *          *"+;
   iif(fBezNC,"","          *          *")+;
   "  bez PDV * sa PDV  *"

endif

? m

select kalk_pripr
nRec:=recno()
private cIdd:=idpartner+brfaktp+idkonto+idkonto2
if !empty(idkonto2)
  cidkont:=idkonto
  cIdkont2:=idkonto2
  nProlaza:=2
else
  cidkont:=idkonto
  nProlaza:=1
endif

unTot:=unTot1:=unTot2:=unTot3:=unTot4:=unTot5:=unTot6:=unTot7:=unTot8:=unTot9:=unTotA:=unTotb:=0
unTot9a:=0

private aPorezi
aPorezi:={}

for i:=1 to nprolaza
nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
nTot9a:=0
go nRec
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    if idkonto2="XXX"
         cIdkont2:=Idkonto
    else
         cIdkont:=Idkonto
    endif
    
    KTroskovi()

    if empty(idkonto2)
    	vise_kalk_dok_u_pripremi(cIdd)
    else
      if (i==1 .and. left(idkonto2,3)<>"XXX") .or. (i==2 .and. left(idkonto2,3)=="XXX")
         // nastavi
      else
         skip
         loop
      endif
    endif

    KTroskovi()
    RptSeekRT()

    Tarifa(field->pkonto,field->idroba,@aPorezi)
    
	aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    print_nova_strana(125, @nStr, 2)

    if gKalo == "1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot8+= (nU8:=NC *    (Kolicina-Gkolicina-GKolicin2) )
    nTot9+= (nU9:=nMarza2* (Kolicina-Gkolicina-GKolicin2) )
    nTotA+= (nUA:=MPC   * (Kolicina-Gkolicina-GKolicin2) )
    nTotB+= (nUB:=MPCSAPP* (Kolicina-Gkolicina-GKolicin2) )

    @ prow() + 1, 0 SAY rbr PICT "999"
    @ prow(), 4 SAY ""
	?? TRIM( LEFT( ROBA->naz, 40 )), "(", ROBA->jmj, ")"
    
	if lKoristitiBK .and. !EMPTY( roba->barkod )
		?? ", BK: " + ROBA->barkod 
	endif

    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+35  SAY Kolicina             PICTURE PicCDEM
    nCol1:=pcol()+1
    if !fBezNC  // bez nc
      @ prow(),nCol1    SAY NC                    PICTURE PicCDEM
      if round(nc,5)<>0
        @ prow(),pcol()+1 SAY nMarza2/NC*100        PICTURE PicProc
      else
        @ prow(),pcol()+1 SAY 0        PICTURE PicProc
      endif
    endif
    @ prow(),pcol()+1 SAY MPC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPCSaPP               PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa
    IF !fBezNC
      @ prow(),nCol1     SAY nU8         picture         PICDEM
      @ prow(),pcol()+1  SAY nU9         picture         PICDEM
      @ prow(),pcol()+1  SAY nUA         picture         PICDEM
      @ prow(),pcol()+1  SAY nUB         picture         PICDEM
    ELSE
      @ prow(),nCol1     SAY nUA         picture         PICDEM
      @ prow(),pcol()+1  SAY nUB         picture         PICDEM
    ENDIF

  skip
enddo

 if nprolaza==2
   ? m
   ? "Konto "
   if i==1
     ?? cidkont
   else
     ?? cidkont2
   endif
   IF !fBezNC
     @ prow(),nCol1     SAY nTot8         picture         PICDEM
     @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
     @ prow(),pcol()+1  SAY nTotA         picture         PICDEM
     @ prow(),pcol()+1  SAY nTotB         picture         PICDEM
   ELSE
     @ prow(),nCol1     SAY nTotA         picture         PICDEM
     @ prow(),pcol()+1  SAY nTotB         picture         PICDEM
   ENDIF
   ? m
 endif
 unTot8  += nTot8
 unTot9  += nTot9
 unTot9a += nTot9a
 unTotA  += nTotA
 unTotB  += nTotB
next

print_nova_strana(125, @nStr, 3)
? m
@ prow()+1,0        SAY "Ukupno:"
if !fBezNC
	@ prow(),nCol1     SAY unTot8         picture         PICDEM
	@ prow(),pcol()+1  SAY unTot9         picture         PICDEM
	@ prow(),pcol()+1  SAY unTotA         picture         PICDEM
	@ prow(),pcol()+1  SAY unTotB         picture         PICDEM
else
	@ prow(),nCol1     SAY unTotA         picture         PICDEM
	@ prow(),pcol()+1  SAY unTotB         picture         PICDEM
endif
? m

print_nova_strana(125, @nStr, 8)
nRec:=recno()
RekTarife()

// potpis na dokumentu
dok_potpis( 90, "L", nil, nil )

return

