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



function StKalk11_2(fZaTops)
local nCol0 := 0
local nCol1 := 0
local nCol2 := 0
local nPom := 0
local n11BezNC

private aPorezi
private nMarza, nMarza2

nStr := 0
cIdPartner := IdPartner
cBrFaktP := BrFaktP
dDatFaktP := DatFaktP
cIdKonto := IdKonto
cIdKonto2 := IdKonto2

if fzaTops == NIL
    fzaTops := .f.
endif

if fzatops
    n11BezNC := g11BezNC
    g11BezNc := "D"
endif

P_COND
B_ON

if cIdvd=="11"
    ?? "ZADUZENJE PRODAVNICE IZ MAGACINA"
ELSEIF CIDVD=="12"
    ?? "POVRAT IZ PRODAVNICE U MAGACIN"
ELSEIF CIDVD=="13"
    ?? "POVRAT IZ PRODAVNICE U MAGACIN RADI ZADUZENJA DRUGE PRODAVNICE"
endif

B_OFF

? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),", Datum:",DatDok

@ prow(),123 SAY "Str:"+str(++nStr,3)

select PARTN
HSEEK cIdPartner

? "OTPREMNICA Broj:",cBrFaktP,"Datum:",dDatFaktP

if cIdvd == "11"
    select KONTO
    HSEEK cIdKonto
    ?  "Prodavnica zaduzuje :",cIdKonto,"-", ALLTRIM( naz )
    HSEEK cIdKonto2
    ?  "Magacin razduzuje   :",cIdKonto2,"-", ALLTRIM( naz )
else
    select KONTO
    HSEEK cIdKonto
    ?  "Storno Prodavnica zaduzuje :",cIdKonto,"-", ALLTRIM( naz )
    HSEEK cIdKonto2
    ?  "Storno Magacin razduzuje   :",cIdKonto2,"-", ALLTRIM( naz )
endif

select kalk_pripr

m:="--- ---------- ---------- "+IF(g11bezNC=="D","","---------- ")+"---------- ---------- "+IF(g11bezNC=="D","","---------- ---------- ")+"---------- ---------- ---------- --------- -----------"

select koncij
seek trim(kalk_pripr->mkonto)
select kalk_pripr

head_11( lPrikPRUC, m )

select koncij
seek trim(kalk_pripr->pkonto)
select kalk_pripr

nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot4b:=nTot5:=nTot6:=nTot7:=0
nTot4c:=0

aPorezi:={}

private cIdd := idpartner + brfaktp + idkonto + idkonto2

do while !EOF() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    vise_kalk_dok_u_pripremi(cIdd)

    RptSeekRT()
    
    Scatter()  
    // formiraj varijable _....
   
    Marza2()
    
    nMarza := _marza   
    // izracunaj nMarza,nMarza2
    
    VTPorezi()
        
    Tarifa( field->pkonto, field->idRoba, @aPorezi, field->idtarifa )
    aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcSaPP, field->nc )

    nPor1 := aIPor[1]
    
    if lPrikPRUC
        nPRUC := aIPor[2]
        nPor2 := 0
        nMarza2 := nMarza2 - nPRUC
    else
        nPor2 := aIPor[2]
    endif
    
    DokNovaStrana( 123, @nStr, 2 )

    nTot1+=  (nU1:= FCJ*Kolicina   )
    nTot1b+= (nU1b:= VPC*Kolicina  )
    nTot2+=  (nU2:= Prevoz*Kolicina   )
    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= nmarza*Kolicina )
    nTot4b+=  (nU4b:= nmarza2*Kolicina )

    IF lPrikPRUC
        nTot4c+= ( nU4c := nPRUC*Kolicina )
    ENDIF
    
    nTot5+=  (nU5:= MPC*Kolicina )
    nTot6+=  (nU6:=(nPor1+nPor2)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""
    
    ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"

    if lKoristitiBK .and. !EMPTY( roba->barkod )
        ?? ", BK: " + roba->barkod
    endif

    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol

    nCol0:=pcol()+1
    
    IF g11bezNC != "D"
        @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
    ENDIF

    @ prow(),pcol()+1 SAY VPC                  PICTURE PicCDEM
    
    IF !lPrikPRUC
        @ prow(),pcol()+1 SAY Prevoz               PICTURE PicCDEM
    ENDIF

    IF g11bezNC != "D"
        @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
        @ prow(),pcol()+1 SAY nMarza               PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
    IF lPrikPRUC
        @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
    ENDIF
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY aPorezi[POR_PPP]     PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    // red 2 ......
    @ prow()+1,4 SAY IdTarifa+roba->tip
    IF g11bezNC == "D"
        @ prow(),nCol0-1    SAY  ""
    ELSE
        @ prow(),nCol0    SAY  fcj*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  vpc*kolicina      picture picdem
    IF !lPrikPRUC
        @ prow(),  pcol()+1 SAY  prevoz*kolicina      picture picdem
    ENDIF
    IF g11bezNC != "D"
        @ prow(),  pcol()+1 SAY  nc*kolicina      picture picdem
        @ prow(),  pcol()+1 SAY  nMarza*kolicina      picture picdem
    ENDIF
    @ prow(), nMPos:=pcol()+1 SAY  nMarza2*kolicina      picture picdem
    IF lPrikPRUC
        @ prow(),pcol()+1 SAY nU4c                PICTURE PicCDEM
    ENDIF
    @ prow(),  pcol()+1 SAY  mpc*kolicina      picture picdem
    if lPrikPRUC
        @ prow(),nCol1    SAY aPorezi[POR_PPU]   picture picproc
    else
        if IsPDV()
            @ prow(),nCol1    SAY aPorezi[POR_PPP]   picture picproc
        else
            @ prow(),nCol1    SAY PrPPUMP()   picture picproc
        endif
    endif
    if IsPDV()
        @ prow(),  pcol()+1 SAY  nU6             picture piccdem
        @ prow(),  pcol()+1 SAY  nU7             picture piccdem
    else
    @ prow(),  pcol()+1 SAY  nPor1             picture piccdem
        @ prow(),  pcol()+1 SAY  nU7               picture piccdem
    endif
    
    // red 3 .....
    if round(nc,5) <> 0
        @ prow()+1,nMPos SAY (nMarza2/nc)*100  picture picproc
    endif

    skip

enddo


DokNovaStrana(123, @nStr, 3)
? m
@ prow()+1,0        SAY "Ukupno:"
IF g11bezNC == "D"
  @ prow(),nCol0-1      SAY  ""
ELSE
  @ prow(),nCol0      SAY  nTot1        picture       PicDEM
ENDIF

@ prow(),pcol()+1   SAY  nTot1b       picture       PicDEM
IF !lPrikPRUC
  @ prow(),pcol()+1   SAY  nTot2        picture       PicDEM
ENDIF

nMarzaVP:=nTot4
IF g11bezNC != "D"
  @ prow(),pcol()+1   SAY  nTot3        picture       PicDEM
  @ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
ENDIF

@ prow(),pcol()+1   SAY  nTot4b        picture       PicDEM
IF lPrikPRUC
  @ prow(),pcol()+1  SAY nTot4c        picture         PICDEM
ENDIF
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

nTot5:=nTot6:=nTot7:=0
RekTarife()


if !IsPdvMagNab()

? "RUC:"
@ prow(),pcol()+1 SAY nTot6 pict picdem
if cidvd=="11" .and. g11bezNC != "D"
    @ prow(),pcol()+2 SAY "Od toga storno RUC u VP:"
    @ prow(),pcol()+1 SAY nMarzaVP pict picdem
    
elseif cidvd$"12#13" .and. g11bezNC!="D"
    @ prow(),pcol()+2 SAY "Od toga prenijeti RUC u VP:"
    @ prow(),pcol()+1 SAY nMarzaVP pict picdem
endif

? m

endif



if fZaTops
    g11BezNC:=n11BezNC
endif

return
*}


function head_11(lPrikPRUC, cLine)
*{
if IsPDV()
    ? cLine
    if koncij->naz=="P2"
            ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"* Plan.Cj. *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  * PROD.CJ  *   PDV %  *   PDV    * PROD.CJ  *"
    else
            ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+ "*   " + if(gPDVMagNab == "D", " NC","VPC") + "    *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA   * PROD.CJ  *   PDV %  *   PDV   * PROD.CJ  *"
    endif
    ? "*BR*          *          "+IF(g11bezNC=="D","","*   U VP   ")+"*          *   U MP   *"+IF(g11bezNC=="D","","   U MP   *   VP     *")+"   MP     * BEZ PDV  *          *         *  SA PDV  *"
    ? "*  *          *          "+IF(g11bezNC=="D","","*          ")+"*          *          *"+IF(g11bezNC=="D","","          *          *")+"          *          *          *         *          *"
else
    IF lPrikPRUC
        ? cLine
        if koncij->naz=="P2"
                ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"* Plan.Cj. *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA   * POREZ NA*    MPC   *   PPP %  *   PPP    *  MPC     *"
        else
                ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"*   VPC    *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA   * POREZ NA*    MPC   *   PPP %  *   PPP    *  MPC     *"
        endif
        ? "*BR*          *          "+IF(g11bezNC=="D","","*   U VP   ")+"*          *"+IF(g11bezNC=="D","","   U MP   *   VP     *")+"   MP     *  MARZU  *          *   PPU %  *   PPU    *  SA Por  *"
        ? "*  *          *          "+IF(g11bezNC=="D","","*          ")+"*          *"+IF(g11bezNC=="D","","          *          *")+"          *   MP    *          *          *          *          *"
    ELSE
        ? cLine
        if koncij->naz=="P2"
                ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"* Plan.Cj. *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  *    MPC   *   PPP %  *   PPP    *  MPC     *"
        else
            ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"*   VPC    *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  *    MPC   *   PPP %  *   PPP    *  MPC     *"
        endif
        ? "*BR*          *          "+IF(g11bezNC=="D","","*   U VP   ")+"*          *   U MP   *"+IF(g11bezNC=="D","","   U MP   *   VP     *")+"   MP    *          *   PPU %  *   PPU    *  SA Por  *"
        ? "*  *          *          "+IF(g11bezNC=="D","","*          ")+"*          *          *"+IF(g11bezNC=="D","","          *          *")+"         *          *          *          *          *"
    ENDIF
endif

? cLine

return
*}



