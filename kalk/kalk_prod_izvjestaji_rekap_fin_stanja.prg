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

// rekapitulacija finansijskog stanja po objektima
function RFLLP()
local nKolUlaz
local nKolIzlaz

private aPorezi
aPorezi:={}

PicDem:=REPLICATE("9", VAL(gFPicDem)) + gPicDem
PicCDem:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDem

cIdFirma:=gFirma
cIdKonto:=padr("132.",gDuzKonto)

O_SIFK
O_SIFV
O_ROBA
O_TARIFA
O_KONCIJ
O_KONTO
O_PARTN

dDatOd:=ctod("")
dDatDo:=date()
qqRoba:=space(60)
qqTarifa:=qqidvd:=space(60)
private cPNab:="N"
private cNula:="D",cErr:="N"
private cTU:="2"
if IsPlanika()
	private cK9:=SPACE(3)
endif

Box(,9,60)
do while .t.
	if gNW $ "DX"
   		@ m_x+1,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
 	else
  		@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 	endif
 	@ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid "." $ cidkonto .or.P_Konto(@cIdKonto)
 	@ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 	@ m_x+5,m_y+2 SAY "Artikli " GET qqRoba   pict "@!S50"
 	@ m_x+6,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 	@ m_x+7,m_y+2 SAY "Datum od " GET dDatOd
 	@ m_x+7,col()+2 SAY "do" GET dDatDo
 	@ m_x+8,m_y+2  SAY "Prikaz: roba tipa T / dokumenata IP (1/2)" GET cTU  valid cTU $ "12"
 	if IsPlanika()
 		@ m_x+9,m_y+2 SAY "Prikaz po K9" GET cK9 PICT "@!"
 	endif
 	read
 	ESC_BCR
 	private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 	private aUsl3:=Parsiraj(qqIDVD,"idvd")
 	private aUslR:=Parsiraj(qqRoba,"idroba")
 	if aUsl2<>NIL
		exit
	endif
 	if aUsl3<>NIL
		exit
	endif
 	if aUsl4<>NIL
		exit
	endif
enddo
BoxC()

// sinteticki konto
if len(trim(cIdKonto))<=3 .or. "." $ cIdKonto
	if "." $ cIdKonto
     		cIdKonto:=strtran(cIdKonto,".","")
  	endif
  	cIdkonto:=trim(cIdKonto)
endif

O_KALKREP
select kalk
set order to 4
//"idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD"

cFilt1:="Pkonto="+cm2Str(cIdkonto)

if !empty(dDatOd) .or. !empty(dDatdo)
	cFilt1+=".and.DATDOK>="+cm2str(dDatOd)+".and.DATDOK<="+cm2str(dDatDo)
endif

if aUsl2<>".t."
	cFilt1+=".and."+aUsl2
endif
if aUsl3<>".t."
 	cFilt1+=".and."+aUsl3
endif
if aUslR<>".t."
 	cFilt1+=".and."+aUslR
endif

cFilt1:=strtran(cFilt1,".t..and.","")
set filter to &cFilt1

hseek cIdFirma

select koncij
seek trim(cIdKonto)
select kalk

EOF CRET

nLen:=1

aZaglTxt:={}
AADD(aZaglTxt, {5, "R.br",""})
AADD(aZaglTxt, {11, " Konto",""})
AADD(aZaglTxt, {LEN(PicDem), " MPV.Dug",""})
AADD(aZaglTxt, {LEN(PicDem), " MPV.Pot",""})
AADD(aZaglTxt, {LEN(PicDem), " MPV",""})
AADD(aZaglTxt, {LEN(PicDem), " MPV sa PP","  Dug"})
AADD(aZaglTxt, {LEN(PicDem), " MPV sa PP","  Pot"})
AADD(aZaglTxt, {LEN(PicDem), " MPV sa PP",""})

private cLine:=SetRptLineAndText(aZaglTxt, 0)
private cText1:=SetRptLineAndText(aZaglTxt, 1, "*")
private cText2:=SetRptLineAndText(aZaglTxt, 2, "*")

start print cret
?

private nTStrana:=0
private bZagl:={|| ZaglRFLLP()}

Eval(bZagl)
nTUlaz:=nTIzlaz:=0
ntMPVU:=ntMPVI:=nTNVU:=nTNVI:=0
ntMPVBU:=ntMPVBI:=0
// nTRabat:=0
nCol1:=nCol0:=50
private nRbr:=0

nMPVBU:=nMPVBI:=0
aRTar:={}
nKolUlaz:=0
nKolIzlaz:=0

do while !eof() .and. cIdFirma==idfirma .and. IspitajPrekid()
	nUlaz:=nIzlaz:=0
	nMPVU:=nMPVI:=nNVU:=nNVI:=0
	nMPVBU:=nMPVBI:=0
	dDatDok:=datdok
	cBroj:=pkonto
	do while !eof() .and. cIdFirma+cBroj==idFirma+pkonto .and. IspitajPrekid()
		select roba
  		hseek kalk->idroba
		// uslov po K9, planika
  		if (IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9)
    			select kalk
    			skip
    			loop
  		endif
  		
		select kalk
  		if cTU=="2" .and.  roba->tip $ "UT"  
			// prikaz dokumenata IP, a ne robe tipa "T"
     			skip
			loop
  		endif
  		if cTU=="1" .and. idvd=="IP"
     			skip
			loop
  		endif

		select roba
		hseek kalk->idroba
  		select tarifa
		hseek kalk->idtarifa
		select kalk

  		Tarifa(pkonto,idroba,@aPorezi)
  		VtPorezi()

  		nBezP:=0
  		nSaP:=0
  		nNV:=0

  		if pu_i=="1"
    			nBezP:=mpc*kolicina
    			nMPVBU+=nBezP
    			nSaP:=mpcsapp*kolicina
    			nMPVU+=nSaP
    			nNVU+=nc*(kolicina)
    			nNV+=nc*(kolicina)
  		elseif pu_i=="5"
    			nBezP:=-mpc*kolicina
    			nSaP:=-mpcsapp*kolicina
    			if idvd $ "12#13"
     				nMPVBU+=nBezP
     				nMPVU+=nSaP
     				nNVU-=nc*kolicina
     				nNV-=nc*kolicina
    			else
     				nMPVBI-=nBezP
     				nMPVI-=nSaP
     				nNVI+=nc*kolicina
     				nNV-=nc*kolicina
    			endif
  		elseif pu_i=="3"    
    			nBezP:=mpc*kolicina
    			nMPVBU+=nBezP
    			nSaP:=mpcsapp*kolicina
    			nMPVU+=nSaP
  		elseif pu_i=="I"
    			nBezP:=-MpcBezPor(mpcsapp,aPorezi,,nc)*gkolicin2
    			nMPVBI-=nBezP
    			nSaP:=-mpcsapp*gkolicin2
    			nMPVI+=-nSaP
    			nNVI+=nc*gkolicin2
    			nNV-=nc*gkolicin2
  		endif

  		if IsPlanika()
  			UkupnoKolP(@nKolUlaz, @nKolIzlaz)
  		endif
  
  		nElem := ASCAN( aRTar , {|x| x[1]==TARIFA->ID} )

  		if glUgost
  			nP1:=Izn_P_PPP(nBezP,aPorezi,,nSaP)
  			nP2:=Izn_P_PRugost(nSaP,nBezP,nNV,aPorezi)
  			nP3:=Izn_P_PPUgost(nSaP,nP2,aPorezi)
  		else
  			nP1:=Izn_P_PPP(nBezP,aPorezi,,nSaP)
  			nP2:=Izn_P_PPU(nBezP,aPorezi)
  			nP3:=Izn_P_PP(nBezP,aPorezi)
  		endif

  		if nElem>0
    			aRTar[nElem, 2] += nBezP
    			aRTar[nElem, 6] += nP1
    			aRTar[nElem, 7] += nP2
    			aRTar[nElem, 8] += nP3
    			aRTar[nElem, 9] += nP1+nP2+nP3
    			aRTar[nElem,10] += nSaP
  		else
    			AADD(aRTar, {TARIFA->ID, nBezP, _OPP*100, PrPPUMP(), _ZPP*100, nP1, nP2, nP3, nP1+nP2+nP3, nSaP })
  		endif
		skip
	enddo
	
	if round(nNVU-nNVI,4)==0 .and. round(nMPVU-nMPVI,4)==0
  		loop
	endif

	if prow()>61+gPStranica
		FF
		eval(bZagl)
	endif
	
	? str(++nRbr,4)+".",padr(cBroj,11)
	nCol1:=pcol()+1

	nTMPVU+=nMPVU
	nTMPVI+=nMPVI
	nTMPVBU+=nMPVBU
	nTMPVBI+=nMPVBI
	nTNVU+=nNVU
	nTNVI+=nNVI

	@ prow(),pcol()+1 SAY nMPVBU pict picdem
 	@ prow(),pcol()+1 SAY nMPVBI pict picdem
 	@ prow(),pcol()+1 SAY nMPVBU-nMPVBI pict picdem
 	@ prow(),pcol()+1 SAY nMPVU pict picdem
 	@ prow(),pcol()+1 SAY nMPVI pict picdem
 	@ prow(),pcol()+1 SAY nMPVU-nMPVI pict picdem
enddo

? cLine
? "UKUPNO:"

@ prow(),nCol1 SAY ntMPVBU pict picdem
@ prow(),pcol()+1 SAY ntMPVBI pict picdem
@ prow(),pcol()+1 SAY ntMPVBU-ntMPVBI pict picdem
@ prow(),pcol()+1 SAY ntMPVU pict picdem
@ prow(),pcol()+1 SAY ntMPVI pict picdem
@ prow(),pcol()+1 SAY ntMPVU-ntMPVI pict picdem

? cLine

aRptRTar:={}
AADD(aRptRTar, {15, " TARIF", " BROJ"})
AADD(aRptRTar, {LEN(PicDem), " MPV", " "})
AADD(aRptRTar, {LEN(gPicProc), " PPP", "  %"})
AADD(aRptRTar, {LEN(gPicProc), " PPU", "  %"})
AADD(aRptRTar, {LEN(gPicProc), " PP", "  %"})
AADD(aRptRTar, {LEN(PicDem), " PPP", ""})
AADD(aRptRTar, {LEN(PicDem), " PPU", ""})
AADD(aRptRTar, {LEN(PicDem), " PP", ""})
AADD(aRptRTar, {LEN(PicDem), " UKUPNO", " POREZ"})
AADD(aRptRTar, {LEN(PicDem), " MPV", " sa Por"})

cRTLine:=SetRptLineAndText(aRptRTar, 0)
cRTTxt1:=SetRptLineAndText(aRptRTar, 1, "*")
cRTTxt2:=SetRptLineAndText(aRptRTar, 2, "*")

if VAL(gFPicDem) > 0
	P_COND2
else
	P_COND
endif

?
?
?
? "REKAPITULACIJA PO TARIFAMA"
? "--------------------------"
? cRTLine
? cRTTxt1
? cRTTxt2
? cRTLine

ASORT(aRTar,,,{|x,y| x[1]<y[1] })

nT1:=nT4:=nT5:=nT6:=nT7:=nT5a:=0

for i:=1 TO LEN(aRTar)
	if prow()>62+gPStranica
  		FF
  	endif
  	@ prow()+1,0        SAY space(6)+aRTar[i,1]
  	nCol1:=pcol()+4
  	@ prow(),pcol()+4   SAY aRTar[i, 2]  PICT  PicDEM
  	@ prow(),pcol()+1   SAY aRTar[i, 3]  PICT  gPicProc
  	@ prow(),pcol()+1   SAY aRTar[i, 4]  PICT  gPicProc
  	@ prow(),pcol()+1   SAY aRTar[i, 5]  PICT  gPicProc
  	@ prow(),pcol()+1   SAY aRTar[i, 6]  PICT  PicDEM
  	@ prow(),pcol()+1   SAY aRTar[i, 7]  PICT  PicDEM
  	@ prow(),pcol()+1   SAY aRTar[i, 8]  PICT  PicDEM
  	@ prow(),pcol()+1   SAY aRTar[i, 9]  PICT  PicDEM
  	@ prow(),pcol()+1   SAY aRTar[i,10]  PICT  PicDEM
  	nT1+=aRTar[i,2]
  	nT4+=aRTar[i,6]
  	nT5+=aRTar[i,7]
  	nT5a+=aRTar[i,8]
  	nT6+=aRTar[i,9]
  	nT7+=aRTar[i,10]
next

if prow()>60+gPStranica
	FF
endif
? cRTLine
? "UKUPNO:"
@ prow(),nCol1     SAY  nT1  pict picdem
@ prow(),pcol()+1  SAY  0    pict "@Z "+gPicProc
@ prow(),pcol()+1  SAY  0    pict "@Z "+gPicProc
@ prow(),pcol()+1  SAY  0    pict "@Z "+gPicProc
@ prow(),pcol()+1  SAY  nT4  pict picdem
@ prow(),pcol()+1  SAY  nT5  pict picdem
@ prow(),pcol()+1  SAY  nT5a pict picdem
@ prow(),pcol()+1  SAY  nT6  pict picdem
@ prow(),pcol()+1  SAY  nT7  pict picdem
? cRTLine

if IsPlanika()
	if (prow()>55+gPStranica)
		FF
	endif
	PrintParovno(nKolUlaz, nKolIzlaz)
endif

FF
end print

closeret
return


// zaglavlje izvjestaja
function ZaglRFLLP()
Preduzece()
P_12CPI
select konto
hseek cidkonto
?? space(60)," DATUM "
?? date(), space(5),"Str:",str(++nTStrana,3)
IspisNaDan(5)
?
?
? "KALK: Rekapitulacija fin. stanja po objektima za period",dDatOd,"-",dDatDo
?
?
? "Kriterij za objekte:",cIdKonto,"-",konto->naz
?
if len(aUslR)<>0
	? "Kriterij za artikle:",qqRoba
endif

if IsPlanika() .and. !EMPTY(cK9)
 	? "Uslov po K9:", cK9
endif

select kalk

if VAL(gFPicDem) > 0
	P_COND2
else
	P_COND
endif

?
? cLine
? cText1
? cText2
? cLine

return


