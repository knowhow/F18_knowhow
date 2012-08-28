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



// -----------------------------------------------------------
// stampa kalkulacije tip-a 10 u pdv rezimu
// -----------------------------------------------------------
function StKalk10_PDV()
local nCol1:=0
local nCol2:=0
local nPom:=0

private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_COND2

?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok

@ prow(),125 SAY "Str:"+str(++nStr,3)

select PARTN
HSEEK cIdPartner

?  "DOBAVLJAC:",cIdPartner,"-",PADR(naz,25),SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select kalk_pripr

if is_uobrada()
    ? "Odobrenje: ", odobr_no
endif

select KONTO
HSEEK cIdKonto

?  "MAGACINSKI KONTO zaduzuje :",cIdKonto,"-",naz

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if (gMpcPomoc == "D")
 m += " ---------- ----------"
endif

? m


if gMpcPomoc == "D"
  // prikazi mpc
? "*R * ROBA     *  FCJ     * NOR.KALO * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     *  MARZA   * PROD.CIJ.*   PDV%   * PROD.CIJ.*"
  ? "*BR* TARIFA   *  KOLICINA* PRE.KALO * SKONTO   *          *          *          *          *          *          *          * BEZ.PDV  *   PDV    * SA PDV   *"

  ? "*  *          *    ä     *    ä     *   ä      *    ä     *    ä     *     ä    *    ä     *    ä     *    ä     *    ä     *    ä     *    ä     *     ä    *"
else
  // prikazi samo do neto cijene - bez pdv-a
  ? "*R * ROBA     *  FCJ     * NOR.KALO * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     *  MARZA   * PROD.CIJ.*"
  ? "*BR* TARIFA   *  KOLICINA* PRE.KALO * SKONTO   *          *          *          *          *          *          *          * BEZ.PDV  *"

  ? "*  *          *    ä     *    ä     *   ä      *    ä     *    ä     *     ä    *    ä     *    ä     *    ä     *    ä     *    ä     *"

endif

? m

nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=0
nTotB:=nTotP:=nTotM:=0

select kalk_pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD
    vise_kalk_dok_u_pripremi(cIdd)
        RptSeekRT()
        KTroskovi()
    DokNovaStrana(125, @nStr, 2)
    if gKalo=="1"
            SKol:=Kolicina-GKolicina-GKolicin2
        else
            SKol:=Kolicina
        endif

        nPDVStopa := tarifa->opp
    nPDV := MPCsaPP / (1 + (tarifa->opp/100)) * (tarifa->opp/100)

        nTot+=  (nU:=round(FCj*Kolicina,gZaokr))
        if gKalo=="1"
            nTot1+= (nU1:=round(FCj2*(GKolicina+GKolicin2),gZaokr))
        else
            // stanex
            nTot1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
        endif
        nTot2+= (nU2:=round(-Rabat/100*FCJ*Kolicina,gZaokr))
        nTot3+= (nU3:=round(nPrevoz*SKol,gZaokr))
        nTot4+= (nU4:=round(nBankTr*SKol,gZaokr))
        nTot5+= (nU5:=round(nSpedTr*SKol,gZaokr))
        nTot6+= (nU6:=round(nCarDaz*SKol,gZaokr))
        nTot7+= (nU7:=round(nZavTr* SKol,gZaokr))
        nTot8+= (nU8:=round(NC *    (Kolicina-Gkolicina-GKolicin2),gZaokr) )
        nTot9+= (nU9:=round(nMarza* (Kolicina-Gkolicina-GKolicin2),gZaokr) )
        nTotA+= (nUA:=round(VPC   * (Kolicina-Gkolicina-GKolicin2),gZaokr) )

        if gVarVP=="1"
            nTotB+= round(nU9*tarifa->vpp/100 ,gZaokr) // porez na razliku u cijeni
        else
            private cistaMar:=round(nU9/(1+tarifa->vpp/100) ,gZaokr)
            nTotB+=round( cistaMar*tarifa->vpp/100,gZaokr)  // porez na razliku u cijeni
        endif
        // total porez
    	nTotP+=(nUP:=nPDV * kolicina)
        // total mpcsapp
    	nTotM+=(nUM:=MPCsaPP * kolicina)
    
        // 1. PRVI RED
    	@ prow()+1,0 SAY rbr PICTURE "999"
        @ prow(),4 SAY ""

    	?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

        if roba->(fieldpos("KATBR"))<>0
            ?? " KATBR:", roba->katbr
        endif

		if lKoristitiBK .and. !EMPTY( roba->barkod )
			?? ", BK: " + roba->barkod
		endif

        IF lPoNarudzbi
            IspisPoNar()
        ENDIF
        @ prow()+1,4 SAY IdRoba
        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
        @ prow(),pcol()+1 SAY GKolicina             PICTURE PicKol
        @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
        @ prow(),pcol()+1 SAY nPrevoz/FCJ2*100      PICTURE PicProc
        @ prow(),pcol()+1 SAY nBankTr/FCJ2*100      PICTURE PicProc
        @ prow(),pcol()+1 SAY nSpedTr/FCJ2*100      PICTURE PicProc
        @ prow(),pcol()+1 SAY nCarDaz/FCJ2*100      PICTURE PicProc
        @ prow(),pcol()+1 SAY nZavTr/FCJ2*100       PICTURE PicProc
        @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nMarza/NC*100         PICTURE PicProc
        @ prow(),pcol()+1 SAY VPC                   PICTURE PicCDEM

    if gMpcPomoc == "D"
          @ prow(),pcol()+1 SAY nPDVStopa         PICTURE PicProc
          @ prow(),pcol()+1 SAY MPCsaPP           PICTURE PicCDEM
    endif

    // 2. DRUGI RED
        @ prow()+1,4 SAY IdTarifa
        @ prow(),nCol1    SAY Kolicina             PICTURE PicCDEM
        @ prow(),pcol()+1 SAY GKolicin2            PICTURE PicKol
        @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nPrevoz              PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nBankTr              PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nSpedTr              PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nCarDaz              PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nZavTr               PICTURE PicCDEM
        @ prow(),pcol()+1 SAY 0                    PICTURE PicDEM
        @ prow(),pcol()+1 SAY nMarza               PICTURE PicCDEM
    if gMpcPomoc == "D"
          @ prow(),pcol()+1 SAY 0          PICTURE PicCDEM
          @ prow(),pcol()+1 SAY nPDV           PICTURE PicCDEM
    endif

    // 3. TRECI RED
    @ prow()+1,nCol1   SAY nU          picture         PICDEM
        @ prow(),pcol()+1  SAY nU1         picture         PICDEM
        @ prow(),pcol()+1  SAY nU2         picture         PICDEM
        @ prow(),pcol()+1  SAY nU3         picture         PICDEM
        @ prow(),pcol()+1  SAY nU4         picture         PICDEM
        @ prow(),pcol()+1  SAY nU5         picture         PICDEM
        @ prow(),pcol()+1  SAY nU6         picture         PICDEM
        @ prow(),pcol()+1  SAY nU7         picture         PICDEM
        @ prow(),pcol()+1  SAY nU8         picture         PICDEM
        @ prow(),pcol()+1  SAY nU9         picture         PICDEM
        @ prow(),pcol()+1  SAY nUA         picture         PICDEM
    if gMpcPomoc == "D"
          @ prow(),pcol()+1  SAY nUP         picture         PICDEM
          @ prow(),pcol()+1  SAY nUM         picture         PICDEM
    endif

    skip
enddo

DokNovaStrana(125, @nStr, 5)
? m

@ prow() + 1,0 SAY "Ukupno:"
@ prow(),nCol1     SAY nTot          picture         PICDEM
@ prow(),pcol()+1  SAY nTot1         picture         PICDEM
@ prow(),pcol()+1  SAY nTot2         picture         PICDEM
@ prow(),pcol()+1  SAY nTot3         picture         PICDEM
@ prow(),pcol()+1  SAY nTot4         picture         PICDEM
@ prow(),pcol()+1  SAY nTot5         picture         PICDEM
@ prow(),pcol()+1  SAY nTot6         picture         PICDEM
@ prow(),pcol()+1  SAY nTot7         picture         PICDEM
@ prow(),pcol()+1  SAY nTot8         picture         PICDEM
@ prow(),pcol()+1  SAY nTot9         picture         PICDEM
@ prow(),pcol()+1  SAY nTotA         picture         PICDEM

if (gMpcPomoc == "D")
  @ prow(),pcol()+1  SAY nTotP         picture         PICDEM
  @ prow(),pcol()+1  SAY nTotM         picture         PICDEM
endif

? m
? "Magacin se zaduzuje po nabavnoj vrijednosti " + ALLTRIM(TRANSFORM(nTot8, picdem))

? m

return
*}


