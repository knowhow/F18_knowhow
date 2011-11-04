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


#include "fakt.ch"


function StDok
parameters cIdFirma,cIdTipDok,cBrDok

local i
private nCol1:=0,cTxt1,cTxt2,aMemo,nCTxtR,cpom,cpombk
private cTi,nUk,nRab,nUk2:=nRab2:=0
private nStrana:=0

if pcount()==3
 o_fakt_edit(.t.)
else
 o_fakt_edit()
endif

fDelphiRB:=.f.
cIniName:=""
if IzFmkIni('FAKT','DelphiRB','N')=='D'
  fDelphiRB:=.t.
  cIniName:=EXEPATH+'ProIzvj.ini'
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params; use

if gVarF=="1"
  if gRabProc=="D"
    M:="------ ---------- ---------------------------------------- -------------------- ----------- --- ----------- ------ -----------"
  else
    M:="------ ---------- ---------------------------------------- -------------------- ----------- --- ----------- -----------"
  endif
else
  if gRabProc=="D"
    M:="------ ---------- ---------------------------------------- ----------- --- ----------- ------ ----------- -----------"
  else
    M:="------ ---------- ---------------------------------------- ----------- --- ----------- ----------- -----------"
  endif
endif

select fakt_pripr
if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D" .or. (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

aDbf:={ {"POR","C",10,0},;
          {"IZNOS","N",17,8} ;
         }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" 
set order to tag "1"
select fakt_pripr

dDatDok:=DatDok
cidpartner:=Idpartner

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""


if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   if len(aMemo)>=5
    cTxt2:=aMemo[2]
    cTxt3a:=aMemo[3]
    cTxt3b:=aMemo[4]
    cTxt3c:=aMemo[5]
   endif
else
  Beep(2)
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif

// duzina slobodnog teksta
nLTxt2:=1
for i:=1 to len(cTxt2)
 if substr(cTxt2,i,1)=chr(13)
   ++nLTxt2
 endif
next

POCNI STAMPU

P_10CPI
for i:=1 to gnTMarg  
  // Top Margina
  ?
next


aPom:=Sjecistr(cTxt3a,30)
?? space(4),gPB_ON+padc(alltrim(aPom[1]),30)+gPB_OFF; ?? padl(get_mjesto_po_rj(cIdFirma)+", "+dtoc(datdok)+" godine",39)
for i:=2 to len(aPom)
  ? space(4),gPB_ON+padc(alltrim(aPom[i]),30)+gPB_OFF
next
// ---------------- MS 07.04.01


?  space(4),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
?  space(4),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
cStr:=idtipdok+" "+trim(brdok)
cIdTipDok:=IdTipDok

private cpom:=""
if !(cIdTipDok $ "00#01#19")
 cPom:="G"+cidtipdok+"STR"
 cStr:=&cPom+" "+trim(BrDok)
else
 if cIdTipDok $ "01"
   cStr:="PRIJEM U MAGACIN "+cIdFirma
 endif
endif

B_ON; ?? padl(cStr,39) ;B_OFF
ShowIDPar(cIdPartner,5)
for i:=1 to gOdvT2; ?; next

Zagl()

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

//idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok

do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na fakt_pripr->IdRoba

   if alltrim(podbr)=="." .or.  roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif

   if alltrim(podbr)=="."
    if prow()>48-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl()})
    endif
    ? space(gnLMarg); ?? Rbr(),""
    if gVarF=="1"
      ?? space(10),cTxt1,space(20),transform(kolicina,pickol),space(3)
    else
      ?? space(10),cTxt1,transform(kolicina,pickol),space(3)
    endif
    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok .and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena*Koef(cDinDem),nzaokr)
        nRab2+=round(kolicina*cijena*Koef(cDinDem)*rabat/100,nzaokr)
        nPor2+=round(kolicina*cijena*Koef(cDinDem)*(1-rabat/100)*Porez/100,nzaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec

       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
          cRab:=str(nRab2*100/nUk2,5,2)
       else
         cRab:=str(nRab2*100/nUk2,5,0)
       endif
       @ prow(),pcol()+1 SAY iif(kolicina==0,0,nUk2/kolicina) pict picdem
       if gRabProc=="D"
         @ prow(),pcol()+1 SAY cRab+"%"
       endif
       if gVarF=="2"
        @ prow(),pcol()+1 SAY iif(kolicina<>0,(nUk2-nRab2)/kolicina,0) pict picdem
       endif
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY nUk2 pict picdem

       if nPor2<>0
         @  prow()+1,18+gnLMarg SAY "Porez "+str(nporez,5,2)+"%"
         @  prow(),nCol1 SAY round(nPor2,nZaokr) pict picdem
       endif
    endif //
   else   // podbr nije "."
     if idtipdok $ "11#15#27"  // maloprodaja ili izlaz iz MP putem VP
       select tarifa; hseek roba->idtarifa
       IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
         nMPVBP:=fakt_pripr->(cijena*Koef(cDinDem)*kolicina)/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
       ELSE
         nMPVBP:=fakt_pripr->(cijena*Koef(cDinDem)*kolicina)/((1+tarifa->opp/100)*(1+tarifa->ppp/100)+tarifa->zpp/100)
       ENDIF
       if tarifa->opp<>0
         select por
         seek "PPP "+str(tarifa->opp,6,2)
         if !found(); append blank; replace por with "PPP "+str(tarifa->opp,6,2) ;endif
         replace iznos with iznos+nMPVBP*tarifa->opp/100
       endif
       if tarifa->ppp<>0
         select por
         seek "PPU "+str(tarifa->ppp,6,2)
         if !found(); append blank; replace por with "PPU "+str(tarifa->ppp,6,2); endif
         replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->ppp/100
       endif
       if tarifa->zpp<>0
         select por
         seek "PP  "+str(tarifa->zpp,6,2)
         if !found(); append blank; replace por with "PP  "+str(tarifa->zpp,6,2); endif
         IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
           replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->zpp/100
         ELSE
           replace iznos with iznos+nMPVBP*tarifa->zpp/100
         ENDIF
       endif
       select fakt_pripr
     endif

     aSbr:=Sjecistr(serbr,20)
     if roba->tip="U"
       aTxtR:=SjeciStr(aMemo[1],if(gVarF=="1",61,40))   // duzina naziva + serijski broj
     else
       aTxtR:=SjeciStr(roba->naz,40)
     endif


    if prow()>49-len(aSbr)-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl()})
    endif
    ? space(gnLMarg); ?? Rbr(),idroba
    nCTxtR:=pcol()+1
    @ prow(),nCTxtR SAY aTxtR[1]
    if !(roba->tip="U") .and. gVarF=="1"
     nCTxtR:=pcol()+1
     @ prow(),pcol()+1 SAY aSbr[1]
    endif
    @ prow(),pcol()+1 SAY kolicina pict pickol
    @ prow(),pcol()+1 SAY lower(ROBA->jmj)
    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
      @ prow(),pcol()+1 SAY cijena*Koef(cDinDem) pict picdem
      if rabat-int(rabat) <> 0
          cRab:=str(rabat,5,2)
      else
         cRab:=str(rabat,5,0)
      endif
      //if idtipdok=="11"
      //  @ prow(),pcol()+1 SAY roba->idtarifa
      //else
      //  @ prow(),pcol()+1 SAY cRab+"%"
      //endif
      if gRabProc=="D"
        @ prow(),pcol()+1 SAY cRab+"%"
      endif
      if gVarF=="2"
        @ prow(),pcol()+1 SAY cijena*(1-rabat/100)  pict picdem
      endif
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY kolicina*cijena*Koef(cDinDem) pict picdem

      nPor2:=kolicina*cijena*Koef(cDinDem)*(1-rabat/100)*Porez/100

      if roba->tip="U"
        for i:=2 to len(aTxtR)
          @ prow()+1,nCTxtR  SAY aTxtR[i]
        next
      else
       if gVarF=="1"
        for i:=2 to len(aSbr)
         @ prow()+1,nCTxtR  SAY aSbr[i]
        next
       endif
      endif
      if nPor2<>0
          @  prow()+1,18+gnLMarg SAY "Porez "+str(porez,5,2)+"%"
          @  prow(),nCol1 SAY nPor2 pict picdem
      endif
    endif


    nUk+=round(kolicina*cijena*Koef(cDinDem)+nPor2,nZaokr)
    nRab+=round(kolicina*cijena*Koef(cDinDem)*rabat/100,nZaokr)
   endif
   skip
enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)

if !fDelphiRB
 ? space(gnLMarg); ??  m
endif

nPor2:=0 // treba mi iznos poreza da bih vidio da li cu stampati red "Ukupno"
select por; go top
do while !eof()
 nPor2+=round(Iznos,nZaokr); skip
enddo

if gSamokol!="D"

if ((nRab<>0) .or. (nPor2<>0))
   ? space(gnLMarg); ??  padl("Ukupno ("+cDinDem+") :",98); @ prow(),nCol1 SAY nUk pict picdem
endif

if nRab<>0
  if !cidtipdok$"11#15#27"
    ? space(gnLMarg); ??  padl("Rabat ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nRab pict picdem
  endif
endif

cPor:=""
nPor2:=0
fStamp:=.f.
if ! ( cidtipdok $ "11#27" )
 select por
 go top
 nPorI:=0

 do while !eof()  // string poreza
  // odstampaj ukupno - rabat kada ima poreza
  nPor2+=round(Iznos,nZaokr)
  if nPor2<>0 .and. !fStamp .and. gFormatA5<>"0" .and. nRab<>0   // koristim ovaj parametar za varijantu 2
                      // jer se samo koristi za 22
    ? space(gnLMarg); ??  padl("Ukupno - Rab ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nUk-nRab pict picdem
   fStamp:=.t.
  endif
  ? space(gnLMarg); ?? padl(trim(por)+":",98); @ prow(),nCol1 SAY round(IF(cIdTipDok=="15",-1,1)*iznos,nzaokr) pict picdem
  skip
 enddo
 nPor2 := IF(cIdTipDok=="15",-1,1) * nPor2
endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)

? space(gnLMarg); ??  m

if gFZaok<>9 .and. round(nFzaokr,4)<>0
 ? space(gnLMarg); ?? padl("Zaokruzenje:",98); @ prow(),nCol1 SAY nFZaokr pict picdem
endif

? space(gnLMarg); ??  m
? space(gnLMarg); ??  padl("U K U P N O  ("+cDinDem+") :",98); @ prow(),nCol1 SAY round(nUk-nRab+nPor2-nFZaokr,nzaokr) pict picdem
if !empty(picdem)
 ? space(gnLmarg); ?? "slovima: ",Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
else
 ?
endif

endif // gsamokol!="D"

? space(gnLMarg); ?? m
?
ctxt2:=strtran(ctxt2,""+Chr(10),"")
ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMarg))
? space(gnLMarg); ?? ctxt2
?
?
?
select por; use
select fakt_pripr

P_12CPI

PrStr2T(cIdTipDok)

FF

ZAVRSI STAMPU

closeret
*}



/*! \fn Zagl()
 *  \brief Ispis zaglavlja
 */
 
function Zagl()
*{
P_COND
? space(gnLMarg); ?? m
if gVarF=="1"
 if gRabProc=="D"
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                    "+JokSBr()+"             kolicina   jmj   Cijena    Rabat    Ukupno"
 else
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                    "+JokSBr()+"             kolicina   jmj   Cijena      Ukupno"
 endif
else
 if gRabProc=="D"
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                     kolicina   jmj   Cijena    Rabat Cijena-Rab    Ukupno"
 else
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                     kolicina   jmj   Cijena   Cijena-Rab    Ukupno"
 endif
endif
? space(gnLMarg); ?? m
return
*}


/*! \fn NStr0(bZagl)
 *  \brief Nova strana, prelazak na novu stranu
 */
 
function NStr0(bZagl)
*{
? space(gnLmarg); ?? m
? space(gnLmarg+IF(gVarF=="9".and.gTipF=="2",14,0)),"Ukupno na strani "+str(++nStrana,3)+":"; @ prow(),nCol1  SAY nUk  pict picdem
? space(gnLmarg); ?? m
FF
Eval(bZagl)
? space(gnLmarg+IF(gVarF=="9".and.gTipF=="2",14,0)),"Prenos sa strane "+str(nStrana,3)+":"; @ prow(),nCol1  SAY nUk pict picdem
? space(gnLmarg); ?? m
return
*}


/*! \fn Koef(cDinDem)
 *  \brief Konverzija valute
 *  \param cDinDem
 */
 
function Koef(cdindem)
*{
local nNaz,nRet,nArr,dDat

if cDinDem==left(ValSekund(),3)
	return 1/UbaznuValutu(datdok)
else
 	return 1
endif
*}


/*! \fn get_mjesto_po_rj(cRJ)
 *  \brief Uzima mjesto
 *  \todo Postoji nesto slicno u db.prg, treba pogledati
 *  \param cRJ
 */


function get_mjesto_po_rj(cRJ)
*{
LOCAL cVrati:=""
  IF gMjRJ=="D"
    PushWA()
    SELECT (F_RJ)
    PushWA()
    IF !USED();  O_RJ; ENDIF
    HSEEK cRJ
    cVrati:=RJ->grad
    PopWA()
    PopWA()
  ELSE
    cVrati:=gMjStr
  ENDIF
return TRIM(cVrati)
*}



/*! \fn JokSBr()
 *  \brief
 */
 
function JokSBr()
*{
if "U" $ TYPE("BK_SB")
	BK_SB := .f.
endif
return IF(gNW=="R","  KJ/KG ", IF(glDistrib,"", IF(BK_SB, "  BARKOD   ","Ser.broj")))
*}


/*! \fn NSRNPIIdRoba(cSR,fSint)
 *  \brief Nasteli sif->roba na fakt_pripr->idroba
 *  \param cSR
 *  \param fSint  - ako je fSint:=.t. sinteticki prikaz
 */
 
function NSRNPIdRoba(cSR,fSint)
*{
if fSint=NIL
  fSint:=.f.
endif

IF cSR==NIL; cSR:=fakt_pripr->IdRoba; ENDIF
SELECT ROBA
IF (gNovine=="D" .or.  fSint)
  hseek PADR(LEFT(cSR,gnDS),LEN(cSR))
  IF !FOUND() .or. ROBA->tip!="S"
    hseek cSR
  ENDIF
ELSE
  hseek cSR
ENDIF
IF SELECT("PRIPR")!=0
  select fakt_pripr
ELSE
  SELECT (F_PRIPR)
ENDIF

return
*}


/*! \fn PrStr2T(cIdTipDok)
 *  \brief Stampa potpisa na kraju fakture
 *  \param cIdTipDok
 */
 
function PrStr2T(cIdTipDok)
*{
local cPom2:=""

if "U" $ TYPE("fDelphiRB")
	fDelphiRB:=.f.
endif
 
if "U" $ TYPE("lUgRab")
	lUgRab:=.f.
endif

private cPom:=""
private cFaxT:=""
//cIniName:=PRIVPATH+'fmk.ini'
cFaxT:=IzFmkIni('UpitFax','FaxText','UpisiProizvoljanText',PRIVPATH)

if lUgRab

	cPom2:=SPACE(gnlMarg)+PADC("KUPAC",22)+SPACE(29)+PADC("PRODAVAC",22)
   	if fDelphiRB
     		UzmiIzIni(cIniName,'Varijable','Potpis',cPom2,'WRITE')
   	else
     		if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
       			? cFaxT
     		else
       			? cPom2
     		endif
   	endif

elseif cIdTipDok $ "00#01#19"

	if fDelphiRB
     		UzmiIzIni(cIniName,'Varijable','Potpis',g10Str2T,'WRITE')
   	else
     		if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
       			? cFaxT
     		else
       			? g10Str2T
     		endif
   	endif
else

	cPom:="G"+cIdTipDok+"STR2T"
   	if fDelphiRB
     		UzmiIzIni(cIniName,'Varijable','Potpis',&cPom,'WRITE')
   	else
     		if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
       			? cFaxT
     		else

			cPotpis:=&cPom
			cPotpis:=STRTRAN(cPotpis, "?S_5?", SPACE(5) )
			cPotpis:=STRTRAN(cPotpis, "?S_10?", SPACE(10) )
			aPotpis:= lomi_tarabe(cPotpis)

			for i :=1 to LEN(aPotpis)
			   p_line( aPotpis[i], 10, .f.)
			next

     		endif
   	endif
endif

// postavi i dodatni red za tip dok. 10,11,20 i 25
if !EMPTY(gNazPotStr) .and. cIdTipDok $ "10#11#20#25"
	? gNazPotStr
endif

return
*}


/*! \fn PrStr2R(cIdTipDok)
 *  \brief Vraca tekst potpisa RTF
 *  \param cIdTipDok
 *  \return cVrati
 */
 
function PrStr2R(cIdTipDok)
*{
LOCAL cVrati:=""
 // IF "U" $ TYPE("fDelphiRB"); fDelphiRB:=.f.; ENDIF
 private cpom:=""
 if cidtipdok $ "00#01#19"
   cVrati:=g10Str2R
 else
   cpom:="G"+cidtipdok+"STR2R"
   cVrati:=&cPom
 endif
return (cVrati)
*}


/*! \fn ShowIdPar(cId,n,lNoviRed,lVratiRPBNiz)
 *  \brief Prikazi ID partnera na fakturi
 *  \param cId
 *  \param n
 *  \param lNoviRed
 *  \param lVratiRPBNiz
 */
 
function ShowIDPar(cId,n,lNoviRed,lVratiRPBNiz)
*{
local cRegBr
local cPorBr
local cUgovBr
local lPar:=.f.
local lRegB:=.f.

lBrojRjesenja:=IzFmkIni("FAKT","BrojRjes","N",KUMPATH)=="D"

if n==nil
	n:=0
endif
if lVratiRPBNiz==nil
	lVratiRPBNiz:=.f.
endif
if lNoviRed==nil
	lNoviRed:=.t.
endif
if !lVratiRPBNiz .and. IzFMkIni("FAKT","IdPartnNaF","N",KUMPATH)=="D"
	if lNoviRed
      		? (SPACE(n) + PADC("ID:"+cId,30))
    	else
      		?? (SPACE(n) + PADC("ID:"+cId,30))
      		lPar:=.t.
    	endif
endif

if IzFMkIni("FAKT","RegBrPorBr","D",KUMPATH)=="D" .or. lVratiRPBNiz
	cRegBr:=IzSifK("PARTN","REGB",cId,.f.)
    	cPorBr:=IzSifK("PARTN","PORB",cId,.f.)
	cUgovBr:=IzSifK("PARTN","UGBR",cId,.f.)
	 if lBrojRjesenja
    		cBrojRjesenja:=IzSifK('PARTN','BRJS',cId,.f.)
		cBrojUpisa:=IzSifK('PARTN','BRUP',cId,.f.)
    	 endif	
    	 if lNoviRed
      		if !EMPTY(cRegBr)
        		? (SPACE(n) + PADC("Ident.br:"+cRegBr,30))
      		endif
      		if !EMPTY(cPorBr)
        		? (SPACE(n) + PADC("Por.br:"+cPorBr,30))
      		endif
      		if !EMPTY(cUgovBr)
        		? (SPACE(n) + PADC("Broj.ug.:"+cUgovBr,30))
      		endif
      	
		if (lBrojRjesenja .and. !Empty(cBrojRjesenja))
        		? (SPACE(n+4)+ + PADC("Br.Sud.Rj:"+cBrojRjesenja,30))
      			if !Empty(cBrojUpisa)
				? (SPACE(n+4) + PADC("Br.Upisa:"+cBrojUpisa,30))
			endif
		endif		
    	 else
      		if !EMPTY(cRegBr)
        		if lPar
          			?
        		endif
        		?? (SPACE(n) + PADC("Ident.br:"+cRegBr,30))
        		lRegB:=.t.
      		endif
      		if !EMPTY(cPorBr)
        		if lPar .or. lRegB
          			?
        		endif
        		?? (SPACE(n) + PADC("Por.br:"+cPorBr,30))
      		endif
		if !EMPTY(cUgovBr)
        		if lPar .or. lRegB
          			?
        		endif
        		?? (SPACE(n) + PADC("Ugov.br:"+cUgovBr,30))
      		endif

    	 endif
	if lVratiRPBNiz
      		return {cRegBr,cPorBr}
    	endif
    	
endif
return (nil)
*}


// StAzFakt()
// Stampa azurirane fakture
function StAzFakt()
private cIdFirma, cIdTipDok, cBrDok

cIdFirma:=gFirma
cIdTipDok:="10"
cBrdok:=space(8)

Box("", 2, 35)
        @ m_x+1, m_y+2 SAY "Dokument:"
        @ m_x+2, m_y+2 SAY " RJ-tip-broj:" GET cIdFirma
        @ m_x+2, col()+1 SAY "-" GET cIdTipDok
        @ m_x+2, col()+1 SAY "-" GET cBrDok
        read
BoxC()

if LASTKEY()==K_ESC
	return
endif

close all

StampTXT(cIdFirma,cIdTipDok,cBrDok)

select fakt_pripr
use
return


// ------------------------------------
// stampa ugovora za period
// ------------------------------------
function ug_za_period()
local dDatGen
local cBrOd
local cBrDo
local cTipDok
local cDirPom

cDirPom := gcDirekt
gcDirekt := "B"
// parametri
if ug_st_od_do(@cBrOd, @cBrDo) == 0
	return
endif

// stampa....
cTipDok := "10"
StAzPeriod( gFirma, cTipDok, cBrOd, cBrDo )

gcDirekt := cDirPom
close all

return


// Stampa fiskalnih racuna od broja do broja
function st_fisc_per( cIdFirma, cIdTipDok, cBrOd, cBrDo )
local lDirekt := .f.
local lAutoStampa := .t.
local nDevice := 0
local nTRec

if cIdFirma <> nil
	lDirekt := .t.
endif

if !lDirekt
	
	cIdFirma:=gFirma
	cIdTipDok:="10"
	cBrOd:=space(8)
	cBrDo:=space(8)

	Box("", 5, 35)
        @ m_x+1, m_y+2 SAY "Dokument:"
        @ m_x+2, m_y+2 SAY " RJ-tip:" GET cIdFirma
        @ m_x+2, col()+1 SAY "-" GET cIdTipDok
        @ m_x+3, m_y+2 SAY "Brojevi:" 
	@ m_x+4, m_y+3 SAY "od" GET cBrOd VALID !EMPTY(cBrOd)
	@ m_x+4, col()+1 SAY "do" GET cBrDo VALID !EMPTY(cBrDo)
        
	read
	BoxC()

	if LASTKEY()==K_ESC
		return
	endif
endif

close all

// uzmi device iz liste uredjaja
nDevice := list_device( cIdTipDok )

O_PARTN
O_ROBA
O_SIFK
O_SIFV
O_FAKT

O_FAKT_DOKS
select fakt_doks
set order to tag "1"
hseek cIdFirma + cIdTipDok

if Found()
	do while !EOF() .and. doks->idfirma = cIdFirma ;
		.and. doks->idtipdok = cIdTipDok
		
		nTRec := RecNo()
		
		if ALLTRIM(doks->brdok) >= ALLTRIM(cBrOd) .and. ;
			ALLTRIM(doks->brdok) <= ALLTRIM(cBrDo) 
			
			// pozovi stampu fiskalnog racuna
			nErr := fisc_rn( doks->idfirma, ;
				doks->idtipdok, ;
				doks->brdok, lAutoStampa, nDevice )
		
			if ( nErr > 0 ) 
				msgbeep("Prekidam operaciju stampe radi greske!")
				exit
			endif
		
		endif
		
		select fakt_doks
		go (nTRec)
		skip
	enddo
else
	MsgBeep("Trazeni tip dokumenta ne postoji!")
endif

select fakt_doks
use

return



// Stampa azuriranih faktura od broja do broja
function StAzPeriod(cIdFirma, cIdTipDok, cBrOd, cBrDo)
local lDirekt := .f.
local cBatch := "N"

if cIdFirma <> nil
	lDirekt := .t.
endif

if !lDirekt
	
	cIdFirma:=gFirma
	cIdTipDok:="10"
	cBrOd:=space(8)
	cBrDo:=space(8)
	cBatch := "D"

	Box("", 5, 35)
        @ m_x+1, m_y+2 SAY "Dokument:"
        @ m_x+2, m_y+2 SAY " RJ-tip:" GET cIdFirma
        @ m_x+2, col()+1 SAY "-" GET cIdTipDok
        @ m_x+3, m_y+2 SAY "Brojevi:" 
	@ m_x+4, m_y+3 SAY "od" GET cBrOd VALID !EMPTY(cBrOd)
	@ m_x+4, col()+1 SAY "do" GET cBrDo VALID !EMPTY(cBrDo)
	@ m_x+5, m_y+2 SAY "batch rezim ?" GET cBatch VALID cBatch $ "DN" ;
						PICT "@!"
        
	read
	BoxC()

	if LASTKEY()==K_ESC
		return
	endif
endif

close all
O_FAKT_DOKS
set order to tag "1"
hseek cIdFirma + cIdTipDok

if Found()
	do while !EOF() .and. doks->idfirma = cIdFirma .and. doks->idtipdok = cIdTipDok
		nTRec := RecNo()
		
		if ALLTRIM(doks->brdok) >= ALLTRIM(cBrOd) .and. ALLTRIM(doks->brdok) <= ALLTRIM(cBrDo) 
			
			if cBatch == "D"
				cDirPom := gcDirekt
				gcDirekt := "B"
				// prebaci na direkt stampu
			endif
			
			StampTXT(doks->idfirma,doks->idtipdok,doks->brdok)
			
			if cBatch == "D"
				gcDirekt := cDirPom
			endif
			
		endif
		
		select fakt_doks
		go (nTRec)
		skip
	enddo
else
	MsgBeep("Trazeni tip dokumenta ne postoji!")
endif

select fakt_doks
use
return



/*! \fn RbrUNum(cRBr)
 *  \brief 
 *  \param cRBr
 */
 
function RbrUNum(cRBr)
*{
if left(cRbr,1)>"9"
   return  (asc(left(cRbr,1))-65+10)*100  + val(substr(cRbr,2,2))
else
   return val(cRbr)
endif
*}


/*! \fn GetRtmFile(cDefRtm)
 *  \brief Vraca naziv rtm fajla za stampu
 */
function GetRtmFile(cDefRtm)
*{
aRtm:={}
AADD(aRtm, {IzFmkIni("DelphiRb", "Rtm1", "", KUMPATH)})
AADD(aRtm, {IzFmkIni("DelphiRb", "Rtm2", "", KUMPATH)})
AADD(aRtm, {IzFmkIni("DelphiRb", "Rtm3", "", KUMPATH)})

// ako nema nista u matrici vrati default
if LEN(aRtm) == 0
	return cDefRtm
endif

private GetList:={}

Box(,6, 30)
	@ 1+m_x, 2+m_y GET aRtm[1, 1]
	@ 2+m_x, 2+m_y GET aRtm[1, 2]
	@ 3+m_x, 2+m_y GET aRtm[1, 3]
	read
BoxC()

return cRet
*}
