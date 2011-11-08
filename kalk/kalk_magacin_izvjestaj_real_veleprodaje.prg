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


// -------------------------------------------
// realizacija vp po partnerima
// -------------------------------------------
function RealPartn()
local nT0:=nT1:=nT2:=nT3:=nT4:=0
local nCol1:=0
local nPom
local PicCDEM:=gPicCDEM       // "999999.999"
local PicProc:=gPicProc       // "999999.99%"
local PicDEM:=gPicDEM         // "9999999.99"
local Pickol:=gPicKol         // "999999.999"

O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_TARIFA
O_PARTN

private dDat1:=dDat2:=ctod("")
cIdFirma:=gFirma
cIdKonto:=padr("1310",7)

if IsVindija()
	cOpcine:=SPACE(50)
endif

qqPartn:=space(60)

cPRUC:="N"
Box(,8,70)
 do while .t.
 set cursor on
  if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
  else
   @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
  endif
  @ m_x+2,m_y+2 SAY "Magacinski konto:" GET cidKonto pict "@!" valid P_Konto(@cIdKonto)
  @ m_x+4,m_y+2 SAY "Period:" GET dDat1
  @ m_x+4,col()+1 SAY "do" GET dDat2

  @ m_x+6,m_y+2 SAY "Partneri:" GET qqPartn pict "@!S40"
  
  if IsVindija()
  	@ m_x+8,m_y+2 SAY "Opcine:" GET cOpcine pict "@!S40"
  endif
  
  read
  
  ESC_BCR

  aUslP:=Parsiraj(qqPartn,"Idpartner")
  if auslp<>NIL
     exit
  endif
  enddo
BoxC()


O_TARIFA
O_KALK
set order to tag PMAG

private cFilt1:=""

cFilt1 := ".t."+IF(EMPTY(dDat1),"",".and.DATDOK>="+cm2str(dDat1))+;
                IF(EMPTY(dDat2),"",".and.DATDOK<="+cm2str(dDat2))

cFilt1:=STRTRAN(cFilt1,".t..and.","")


IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ENDIF

hseek cIdFirma
EOF CRET

private M:="   -------------------------------- ---------- ---------- ---------- ---------- ---------- ---------- ----------" + IF(!IsPDV(), " ----------","")

START PRINT CRET
?

B:=0

private nStrana:=0
ZaglRPartn()

seek cIdFirma + cIdkonto

nVPV:=nNV:=nVPVBP:=nPRUC:=nPP:=nZarada:=nRabat:=0
nRuc:=0
nNivP:=nNivS:=0             
// nivelacija povecanje, snizenje
nUlazD:=nUlazND:=0
nUlazO:=nUlazNO:=0 
// ostali ulazi
nUlazPS:=nUlazNPS:=0  
// pocetno stanje
nIzlazP:=nIzlazNP:=0  
// izlazi prodavnica
nIzlazO:=nIzlazNO:=0  
// ostali izlazi

DO WHILE !EOF() .and. idfirma==cidfirma .and. cidkonto=mkonto .and. IspitajPrekid()

	nPaNV:=nPaVPV:=nPaPruc:=nPaRuc:=nPaPP:=nPaZarada:=nPaRabat:=0
  	cIdPartner:=idpartner
  
  	//Vindija - ispitaj opcine za partnera
  	if IsVindija() .and. !Empty(cOpcine)
  		select partn
		hseek cIdPartner
		if AT(ALLTRIM(partn->idops), cOpcine)==0
			select kalk
			skip
			loop
		endif
		select kalk
  	endif
  
  	do WHILE !EOF() .and. idfirma==cidfirma .and. idpartner==cidpartner  .and. cidkonto=mkonto .and. IspitajPrekid()

   		select roba
   		hseek kalk->idroba
   		select tarifa
   		hseek kalk->idtarifa
   		select kalk

   		if idvd = "14"
     			
			if aUslp<>".t." .and. ! &aUslP
        			skip
				loop
     			endif

     			VtPorezi()
     
     			nVPVBP := nVPV / (1 + _PORVT)
     			nPaNV += round( NC*kolicina  , gZaokr)
     			nPaVPV += round( VPC*(Kolicina), gZaokr)
     			nPaPP += round( MPC/100 * VPC * (1-RabatV / 100) * Kolicina , gZaokr)

     			nPaRabat += round( RabatV/100*VPC*Kolicina , gZaokr)
			nPom := VPC * (1-RabatV/100) - NC
     			nPaRuc += round(nPom*Kolicina,gZaokr)

     			if nPom > 0   
				// porez na ruc se obracunava 
				// samo ako je pozit. razlika
      				if gVarVP=="1"
         				nPaPRUC+=round(nPom*Kolicina*tarifa->VPP/100,gZaokr)
      				else
         				nPaPRUC+=round(nPom*Kolicina*tarifa->VPP/100/(1+tarifa->VPP/100),gZaokr)
         				// Preracunata stopa
      				endif
     			endif

   		elseif idvd=="18"
     			// nivelacija
     			if vpc>0
       				nNivP+=vpc*kolicina
    			else
       				nNivS+=vpc*kolicina
     			endif

   		elseif idvd $ "11#12#13"  
			//prodavnica
      			nIzlazNP += round(NC*(Kolicina-GKolicina-GKolicin2), gZaokr)
      			nIzlazP += round(VPC*(Kolicina-GKolicina-GKolicin2), gZaokr)
   		elseif mu_i == "2"  
			// ostali izlazi
      			nIzlazNO += round(NC*(Kolicina-GKolicina-GKolicin2), gZaokr)
      			nIzlazO += round(VPC*(Kolicina-GKolicina-GKolicin2), gZaokr)
   		elseif idvd == "10"
      			nUlazND += round(NC*(Kolicina-GKolicina-GKolicin2), gZaokr)
      			nUlazD += round(VPC*(Kolicina-GKolicina-GKolicin2), gZaokr)

   		elseif mu_i == "1"  
			//ostali ulazi
      			if day(datdok)=1 .and. month(datdok)=1 
				// datum 01.01
        			nUlazNPS += round(NC*(Kolicina-GKolicina-GKolicin2), gZaokr)
        			nUlazPS += round(VPC*(Kolicina-GKolicina-GKolicin2), gZaokr)
      			else
        			nUlazNO += round(NC*(Kolicina-GKolicina-GKolicin2), gZaokr)
        			nUlazO += round(VPC*(Kolicina-GKolicina-GKolicin2), gZaokr)
      			endif

   		endif
		skip
  	enddo

	if IsPDV()
		nPaZarada := nPaVPV - nPaNV 
	else
		nPaZarada := nPaRuc - nPaPRUC
	endif
	// zarada

  	if nPaNV=0 .and. nPAVPV=0 .and. nPaRabat=0 .and. nPaPP=0 .and. nPaZarada=0
    		loop
  	endif

  	if prow()>61
  		FF
 		ZaglRPartn()
  	endif
  	select partn
  	hseek cIdPartner
  	select kalk
  
  	? space(2), cIdPartner, PADR(partn->naz, 25)
  
  	nCol1 := pcol()+1
  
  	@ prow(), nCol1    SAY nPaNV   pict gpicdem
  	@ prow(), pcol()+1 SAY nPaRUC  pict gpicdem
  
  	if !IsPDV()
  		@ prow(), pcol()+1 SAY nPaPRuc pict gpicdem
  	endif
  
  	@ prow(), pcol()+1 SAY nPaZarada pict gpicdem
	@ prow(), pcol()+1 SAY nPaVPV  pict gpicdem
  	@ prow(), pcol()+1 SAY nPaRabat pict gpicdem
  	@ prow(), pcol()+1 SAY nPaPP  pict gpicdem
  	@ prow(), pcol()+1 SAY nPaVPV-nPaRabat+nPaPP  pict gpicdem

	nNV+=nPaNV
  	nVPV+=nPaVPV
  	nPRuc+=nPaPruc
  	nZarada+=nPaZarada
  	nRuc+=nPaRuc
  	nPP+=nPaPP
  	nRabat+=nPaRabat

enddo

if prow()>59
	FF
	ZaglRPartn()
endif

? m
? "   Ukupno:"
@ prow(), nCol1    SAY nNV   pict gpicdem
@ prow(), pcol()+1 SAY nRUC  pict gpicdem
if !IsPDV()
	@ prow(), pcol()+1 SAY nPRuc pict gpicdem
endif
@ prow(), pcol()+1 SAY nZarada pict gpicdem
@ prow(), pcol()+1 SAY nVPV  pict gpicdem
@ prow(), pcol()+1 SAY nRabat pict gpicdem
@ prow(),pcol()+1  SAY nPP  pict gpicdem
@ prow(), pcol()+1 SAY nVPV-nRabat+nPP  pict gpicdem

? m

if prow() > 50
	FF
	ZaglRPartn(.f.)
endif

P_12CPI
?
? replicate("=",45)
? "Rekapitulacija  prometa za period :"
? replicate("=",45)
?
? "--------------------------------- ---------- --------"
if IsPDV()
	? "                        Nab.vr.    Prod.vr     Ruc%"
else
	? "                        Nab.vr.       VPV      Ruc%"
endif
? "--------------------------------- ---------- --------"
?

? "**** ULAZI: ********"
if nulazPS<>0
? "-    pocetno stanje:  "
@ prow(),pcol()+1 SAY nUlazNPS pict gpicdem
@ prow(),pcol()+1 SAY nUlazPS pict gpicdem
if nulazPS<>0
  @ prow(),pcol()+1 SAY (nUlazPS-nUlazNPS)/nUlazPS*100 pict "999.99%"
endif

endif
if nulazd<>0
 ? "-       Dobavljaci :  "
 @ prow(),pcol()+1 SAY nUlazND pict gpicdem
 @ prow(),pcol()+1 SAY nUlazD pict gpicdem
if nulazD<>0
  @ prow(),pcol()+1 SAY (nUlazD-nUlazND)/nUlazD*100 pict "999.99%"
endif
endif

if nulazo<>0
? "-           ostalo :  "
@ prow(),pcol()+1 SAY nUlazNO pict gpicdem
@ prow(),pcol()+1 SAY nUlazO pict gpicdem
if nulazO<>0
  @ prow(),pcol()+1 SAY (nUlazO-nUlazNO)/nUlazO*100 pict "999.99%"
endif
endif

if nNivP<>0 .or. nNivS<>0
?
? "**** Nivelacije ****"
if nNivP<>0
? "-        povecanje :  "
@ prow(),pcol()+1 SAY space(len(gpicdem))
@ prow(),pcol()+1 SAY nNivP pict gpicdem
endif
if nNivS<>0
? "-        snizenje  :  "
@ prow(),pcol()+1 SAY space(len(gpicdem))
@ prow(),pcol()+1 SAY nNivS pict gpicdem
endif
endif

?
if IsPDV()
	? "**** IZLAZI (Prod.vr.-Rabat) **"
else
	? "**** IZLAZI (VPV-Rabat) **"
endif
? "-      realizacija :  "
@ prow(),pcol()+1 SAY nNV pict gpicdem
@ prow(),pcol()+1 SAY nVPV-nRabat pict gpicdem
if (nVPV-nRabat)<>0
  @ prow(),pcol()+1 SAY nZarada/(nVPV-nRabat)*100 pict "999.99%"
endif

if nIzlazP<>0
? "-       prodavnice :  "
@ prow(),pcol()+1 SAY nIzlazNP pict gpicdem
@ prow(),pcol()+1 SAY nIzlazP pict gpicdem
if nIzlazP<>0
  @ prow(),pcol()+1 SAY (nIzlazP-nIzlazNP)/nIzlazP*100 pict "999.99%"
endif
endif

if nIzlazO<>0
? "-           ostalo :  "
@ prow(),pcol()+1 SAY nIzlazNo pict gpicdem
@ prow(),pcol()+1 SAY nIzlazo pict gpicdem
if nIzlazO<>0
  @ prow(),pcol()+1 SAY (nIzlazO-nIzlazNO)/nIzlazO*100 pict "999.99%"
endif
endif

FF

END PRINT
closeret
return
*}




/*! \fn ZaglRPartn(fTabela)
 *  \brief Zaglavlje izvjestaja "realizacija veleprodaje po partnerima"
 */
 
function ZaglRPartn(fTabela)
*{
if ftabela=NIL
  ftabela:=.t.
endif

Preduzece()
P_12CPI
set century on
? "  KALK: REALIZACIJA VELEPRODAJE PO PARTNERIMA    na dan:",DATE()
?? space(6),"Strana:",str(++nStrana,3)
? "        Magacin:",cIdkonto,"   period:",dDat1,"DO",dDat2
set century off

P_COND

if ftabela
?
? m
if IsPDV()
? "   *           Partner            *    NV     *  ZARADA  *   RUC    * Prod.vr  *  Rabat   *   PDV    *  Ukupno *"
else
	? "   *           Partner            *    NV     *   RUC    *   PRUC   *   NETO   *   VPV    *  Rabat   *   PP     *  Ukupno *"
endif

? "   *                              *           *(RUC-RAB.)* (PV - NV) *         *          *          *          *" + IF(!IsPDV(), "         *", "")

? m
endif

return


