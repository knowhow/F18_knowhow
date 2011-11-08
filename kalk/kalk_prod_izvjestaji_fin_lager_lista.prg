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

// finansijsko stanje prodavnice
function FLLP()
local nKolUlaz
local nKolIzlaz

PicDem:=REPLICATE("9", VAL(gFPicDem)) + gPicDem
PicCDem:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDem

cIdFirma:=gFirma
cIdKonto:=padr("1320",gDuzKonto)

ODbKalk()

dDatOd:=ctod("")
dDatDo:=date()
qqRoba:=space(60)
qqTarifa:=qqidvd:=space(60)
private cPNab:="N"
private cNula:="D",cErr:="N"
private cTU:="2"

Box(,9,60)
do while .t.
 if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid P_Konto(@cIdKonto)
 @ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 @ m_x+5,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 @ m_x+7,m_y+2 SAY "Datum od " GET dDatOd
 @ m_x+7,col()+2 SAY "do" GET dDatDo
 @ m_x+8,m_y+2  SAY "Prikaz: roba tipa T / dokumenati IP (1/2)" GET cTU  valid cTU $ "12"
 read; ESC_BCR
 private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 private aUsl3:=Parsiraj(qqIDVD,"idvd")
 if aUsl2<>NIL; exit; endif
 if aUsl3<>NIL; exit; endif
enddo
BoxC()

//ovo je napusteno ...
fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')

// sinteticki konto
if len(trim(cidkonto))==3
  cIdkonto:=trim(cidkonto)
endif

O_KALKREP

cFilt1:="Idfirma="+cm2str(cidfirma)+".and. Pkonto="+cm2str(cIdkonto)+".and. DatDok<="+cm2str(dDatDo)
//cFilt1:="Pkonto="+cm2str(cIdkonto)
//set order to tag "D"
//set scopebottom to dDatDo
if !empty(dDatOd)
 //set order to tag "D"
 //set scopetop to  dDatOd
 cFilt1+=".and. DatDok>="+cm2str(dDatOd)
endif
if aUsl2<>".t."
 cFilt1+=".and."+aUsl2
endif
if aUsl3<>".t."
 cFilt1+=".and."+ausl3
endif

select KALK
set order to tag "5"
//("5","idFirma+dtos(datdok)+idvd+brdok+rbr","KALK")
set filter to &cFilt1

// hseek cidfirma
go top

select koncij
seek trim(cidkonto)
select KALK

EOF CRET

nLen:=1
 
aRFLLP:={}
AADD(aRFLLP, {6, "Redni", " broj"})
AADD(aRFLLP, {8, "", " Datum"})
AADD(aRFLLP, {11, " Broj", "dokumenta"})
AADD(aRFLLP, {LEN(PicDem), "  NV", " duguje"})
AADD(aRFLLP, {LEN(PicDem), "  NV", " potraz."})
AADD(aRFLLP, {LEN(PicDem), "  NV", " ukupno"})

if IsPDV()
	AADD(aRFLLP, {LEN(PicDem), "   PV", " duguje"})
	AADD(aRFLLP, {LEN(PicDem), "   PV", " potraz."})
	AADD(aRFLLP, {LEN(PicDem), "   PV", " ukupno"})
	AADD(aRFLLP, {LEN(PicDem), " PV sa PDV", " duguje"})
	AADD(aRFLLP, {LEN(PicDem), " PV sa PDV", " potraz."})
	AADD(aRFLLP, {LEN(PicDem), " Popust", ""})
	AADD(aRFLLP, {LEN(PicDem), " PV sa PDV", " ukupno"})
else
	AADD(aRFLLP, {LEN(PicDem), "  MPV", " duguje"})
	AADD(aRFLLP, {LEN(PicDem), "  MPV", " potraz."})
	AADD(aRFLLP, {LEN(PicDem), "  MPV", " ukupno"})
	AADD(aRFLLP, {LEN(PicDem), " MPV sa PP", " duguje"})
	AADD(aRFLLP, {LEN(PicDem), " MPV sa PP", " potraz."})
	AADD(aRFLLP, {LEN(PicDem), " MPV sa PP", " ukupno"})
endif

private cLine:=SetRptLineAndText(aRFLLP, 0)
private cText1:=SetRptLineAndText(aRFLLP, 1, "*")
private cText2:=SetRptLineAndText(aRFLLP, 2, "*")

start print cret
?

private nTStrana:=0
private bZagl:={|| ZaglFLLP()}
private aPorezi:={}

Eval(bZagl)
nTUlaz:=nTIzlaz:=0
ntMPVBU:=ntMPVBI:=ntMPVU:=ntMPVI:=ntNVU:=ntNVI:=0
ntPopust:=0

nCol1:=nCol0:=10
private nRbr:=0

#DEFINE CMORE

#XCOMMAND CMINIT => ncmSlogova:=cmFiltCount(); ncmRec:=1
//#DEFINE CMNEOF  !eof() .and. ncmRec<=ncmSLOGOVA
//#XCOMMAND CMSKIP => ++ncmRec; if ncmrec>ncmslogova;exit;end; skip
#DEFINE CMNEOF  !eof()
#XCOMMAND CMSKIP => skip

CMINIT
showkorner(ncmslogova,1,16)
showkorner(0,100)

//kolicine ulaz/izlaz
private nKU:=nKI:=0

nKolUlaz:=0
nKolIzlaz:=0

do while CMNEOF .and. cidfirma==idfirma .and.  IspitajPrekid()

nUlaz:=nIzlaz:=0
nMPVBU:=nMPVBI:=nMPVU:=nMPVI:=nNVU:=nNVI:=0
nPopust:=0

// nRabat:=0

dDatDok:=datdok
cBroj:=idvd+"-"+brdok
do while CMNEOF  .and. cidfirma+dtos(ddatdok)+cbroj==idFirma+dtos(datdok)+idvd+"-"+brdok .and.  IspitajPrekid()
  select roba; hseek KALK->idroba; select KALK

  showkorner(1,100)
  if cTU=="2" .and.  roba->tip $ "UT"  
     // prikaz dokumenata IP, a ne robe tipa "T"
     CMSKIP
     loop
  endif
  if cTU=="1" .and. idvd=="IP"
     CMSKIP
     loop
  endif

  select roba
  hseek KALK->idroba
  select tarifa
  hseek KALK->idtarifa
  select KALK
  VtPorezi()

  if pu_i=="1"
    nMPVBU+=mpc*kolicina
    nMPVU+=mpcsapp*kolicina
    nNVU+=nc*(kolicina)
  elseif pu_i=="5"
    if idvd $ "12#13"
     nMPVBU-=mpc*kolicina
     nMPVU-=mpcsapp*kolicina
     nNVU-=nc*kolicina
     nPopust-=rabatv
    else
     nMPVBI+=mpc*kolicina
     nMPVI+=mpcsapp*kolicina
     nNVI+=nc*kolicina
     nPopust+=rabatv
    endif
  elseif pu_i=="3"    
    // nivelacija
    nMPVBU+=mpc*kolicina
    nMPVU+=mpcsapp*kolicina
  elseif pu_i=="I"
    Tarifa(field->pkonto, field->idRoba, @aPorezi)
    nMPVBI+=DokMpc(field->idvd,aPorezi)*field->gkolicin2
    // nMPVBI+=mpcsapp/((1+_OPP)*(1+_PPP))*gkolicin2
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2
  endif

  if IsPlanika()
  	UkupnoKolP(@nKolUlaz, @nKolIzlaz)
  endif
  CMSKIP

enddo  

if round(nNVU-nNVI,4)==0 .and. round(nMPVU-nMPVI,4)==0
  loop
endif


if prow()>61+gPStranica
	FF
	eval(bZagl)
endif

? str(++nrbr,5)+".",dDatDok,cBroj
nCol1:=pcol()+1

ntNVU+=nNVU
ntNVI+=nNVI
ntMPVBU+=nMPVBU
ntMPVBI+=nMPVBI
ntMPVU+=nMPVU
ntMPVI+=nMPVI
ntPopust+=nPopust

 @ prow(),pcol()+1 SAY nNVU pict picdem
 @ prow(),pcol()+1 SAY nNVI pict picdem
 @ prow(),pcol()+1 SAY ntNVU-ntNVI pict picdem
 @ prow(),pcol()+1 SAY nMPVBU pict picdem
 @ prow(),pcol()+1 SAY nMPVBI pict picdem
 @ prow(),pcol()+1 SAY ntMPVBU-ntMPVBI pict picdem
 @ prow(),pcol()+1 SAY nMPVU pict picdem
 @ prow(),pcol()+1 SAY nMPVI pict picdem
 if IsPDV()
 	@ prow(),pcol()+1 SAY nPopust pict picdem
 endif
 @ prow(),pcol()+1 SAY ntMPVU-ntMPVI pict picdem

enddo

? cLine
? "UKUPNO:"

 @ prow(),nCol1    SAY ntNVU pict picdem
 @ prow(),pcol()+1 SAY ntNVI pict picdem
 @ prow(),pcol()+1 SAY ntNVU-ntNVI pict picdem
 @ prow(),pcol()+1 SAY ntMPVBU pict picdem
 @ prow(),pcol()+1 SAY ntMPVBI pict picdem
 @ prow(),pcol()+1 SAY ntMPVBU-ntMPVBI pict picdem
 @ prow(),pcol()+1 SAY ntMPVU pict picdem
 @ prow(),pcol()+1 SAY ntMPVI pict picdem
 if IsPDV()
 	@ prow(),pcol()+1 SAY ntPopust pict picdem
 endif
 @ prow(),pcol()+1 SAY ntMPVU-ntMPVI pict picdem

? cLine

if IsPlanika()
	if (prow()>55+gPStranica)
		FF
	endif
	PrintParovno(nKolUlaz, nKolIzlaz)
endif

FF
END PRINT

closeret
return

// zaglavlje fin.stanje
function ZaglFLLP()
select konto
hseek cIdKonto
Preduzece()

if VAL(gFPicDem) > 0
	P_COND2
else
	P_COND
endif

?? "KALK: Finansijsko stanje za period",dDatOd,"-",dDatDo," NA DAN "
?? date(), space(10),"Str:",str(++nTStrana,3)
? "Prodavnica:", cIdKonto, "-", konto->naz

select KALK
 
? cLine
? cText1
? cText2
? cLine

return

