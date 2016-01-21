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


/*! \file fmk/kalk/prod/dok/1g/rpt_19.prg
 *  \brief Stampa dokumenta tipa 19
 */


/*! \fn StKalk19()
 *  \brief Stampa dokumenta tipa 19
 */

function StKalk19()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2, aPorezi
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

aPorezi:={}
nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_10CPI
B_ON
?? "PROMJENA CIJENA U PRODAVNICI"
?
B_OFF
P_COND
? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,", Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN
HSEEK cIdPartner             // izbaciti?  19.5.00
select KONTO
HSEEK cidkonto               // dodano     19.5.00

?  "KONTO zaduzuje :", cIdKonto, "-", naz

select kalk_pripr

if (cIdVD=="19")
	m:= "--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
 	? m
	head_19()
	? m
 	nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0
endif

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVd==IdVd

    vise_kalk_dok_u_pripremi(cIdd)
    RptSeekRT()
    KTroskovi()
    VTPOREZI()

    Tarifa(kalk_pripr->pkonto,kalk_pripr->idroba,@aPorezi)

    // nova cijena
    nMpcSaPP1:=field->mpcSaPP+field->fcj
    nMpc1:=MpcBezPor(nMpcSaPP1,aPorezi,,field->nc)
    aIPor1:=RacPorezeMP(aPorezi,nMpc1,nMpcSaPP1,field->nc)
    
    // stara cijena
    nMpcSaPP2:=field->fcj
    nMpc2:=MpcBezPor(nMpcSaPP2,aPorezi,,field->nc)
    aIPor2:=RacPorezeMP(aPorezi,nMpc2,nMpcSaPP2,field->nc)
    
    DokNovaStrana(125, @nStr, 2)

      nTot3+=  (nU3:= MPC*Kolicina )

      nPor1:=aIPor1[1]-aIPor2[1]
      nPor2:=aIPor1[2]-aIPor2[2]

      nTot4+=  (nU4:=(nPor1+nPor2)*Kolicina)
      nTot5+=  (nU5:= MPcSaPP*Kolicina )
      
      // 1. red

      @ prow()+1,0 SAY  Rbr PICTURE "999"
      @ prow(),4 SAY  ""
      ?? trim(LEFT(ROBA->naz,40)),"(",ROBA->jmj,")"
      @ prow()+1,4 SAY IdRoba
      @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
      nC0:=pcol()+1
      @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
      nC1:=pcol()+1
      @ prow(),pcol()+1 SAY aPorezi[POR_PPP]            PICTURE PicProc
      @ prow(),pcol()+1 SAY nPor1                         PICTURE PicDEM
      @ prow(),pcol()+1 SAY nPor1*Kolicina                PICTURE PicDEM
      @ prow(),pcol()+1 SAY MPCSAPP                       PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP+FCJ                   PICTURE PicCDEM
      
      // 2. red

      @ prow()+1,nC1 SAY PrPPUMP()                        PICTURE PicProc
      @ prow(),pcol()+1 SAY nPor2                         PICTURE PicDEM
      @ prow(),pcol()+1 SAY nPor2*Kolicina                PICTURE PicDEM
      @ prow(),pcol()+1 SAY (MPCSAPP/FCJ)*100  picture picproc
      @ prow(),pcol()+1 SAY space(len(PicCDEM))

    skip

enddo

DokNovaStrana(125, @nStr, 3)

? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nC0        SAY  nTot3         PICTURE        PicDEM
@ prow(),pcol()+1   SAY  space(len(picdem))
@ prow(),pcol()+1   SAY  space(len(picdem))
@ prow(),pcol()+1   SAY  nTot4         PICTURE        PicDEM
@ prow(),pcol()+1   SAY  nTot5         PICTURE        PicDEM
? m

?
Rektarife()

PrnClanoviKomisije()
return
*}


function head_19()
*{
if IsPDV()
	? "*R * ROBA     * Kolicina *  STARA   * RAZLIKA  * PDV   %  *IZN. PDV  * UK. PDV  * RAZLIKA  *  NOVA   *"
	? "*BR*          *          *MPC SA PDV*   MPC    *          *          *          *MPC SA PDV*MPC SA PDV*"
	? "*  *          *          *    �     *    �     *          *    �     *    �     *    �     *    �    *"
else
	? "*R * ROBA     * Kolicina *  STARA   * RAZLIKA  * PPP   %  *IZN. PPP  * UK. PPP  * RAZLIKA  *  NOVA   *"
	? "*BR*          *          *MPC SA PP *   MPC    * PPU   %  *IZN. PPU  * UK. PPU  * MPC SA PP*MPC SA PP*"
	? "*  *          *          *    �     *    �     *          *    �     *    �     *    �     *    �    *"
endif

return
*}


/*! \fn Obraz19()
 *  \brief Stampa dokumenta tipa 19 - obrazac nivelacije
 */

function Obraz19()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

cProred:="N"
cPodvuceno:="N"
Box(,2,60)
 @ m_x+1,m_y+2 SAY "Prikazati sa proredom:" GET cProred valid cprored $"DN" pict "@!"
 @ m_x+2,m_y+2 SAY "Prikazati podvuceno  :" GET cPodvuceno valid cpodvuceno $ "DN" pict "@!"
 read
 ESC_BCR
BoxC()

START PRINT CRET
?
Preduzece()

P_10CPI
B_ON
? padl("Prodavnica __________________________",74)
?
?
? PADC("PROMJENA CIJENA U PRODAVNICI ___________________, Datum _________",80)
?
B_OFF

select kalk_pripr

P_COND
?
@ prow(),110 SAY "Str:"+str(++nStr,3)

if cIdVD == "19"
	m:= "--- --------------------------------------------------- ---------- ---------- ---------- ------------- ------------- -------------"
 	? m
 	? "*R *  Sifra   *        Naziv                           *  STARA   *   NOVA   * promjena *  zaliha     *   iznos     *  ukupno    *"
 	? "*BR*          *                                        *  cijena  *  cijena  *  cijene  * (kolicina)  *   poreza    * promjena   *"
 	? m
 nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0
endif

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    vise_kalk_dok_u_pripremi(cIdd)

    select ROBA
    HSEEK kalk_pripr->IdRoba
    select TARIFA
    HSEEK kalk_pripr->IdTarifa
    select kalk_pripr
    
    
    DokNovaStrana(110, @nStr, IIF(cProred=="D",2,1))
      
      ?
      if cPodvuceno=="D"
       U_ON
      endif
      ?? rbr+" "+idroba+" "+PADR(trim(LEFT(ROBA->naz,40))+" ("+ROBA->jmj+")",40)
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP+FCJ          PICTURE PicCDEM
      @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM
      if cPodvuceno=="D"
       U_OFF
      endif
      @ prow(),pcol()+1 SAY "_____________"
      @ prow(),pcol()+1 SAY "_____________"
      @ prow(),pcol()+1 SAY "_____________"
      if cProred=="D"
        ?
      endif
    skip

enddo


DokNovaStrana(110, @nStr, 12)

? m
? " UKUPNO "
? m
?
?
?
P_10CPI

PrnClanoviKomisije()

END PRINT

return
*}




