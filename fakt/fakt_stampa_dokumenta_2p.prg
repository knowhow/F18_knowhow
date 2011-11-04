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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

 
function StDok2P_rb( c1, c2, c3)

private cIdFirma := c1
private cIdTipDok := c2
private cBrDok := c3


private i,nCol1:=0
private cTxt1
private cTxt2
private aMemo
private nMPVBP:=0
private nVPVBP:=0
private cpom,cpombk
private cTi,nUk,nRab,nUk2:=nRab2:=0

private nStrana:=0
private nCTxtR:=10
private nPorZaIspis:=0


if gAppSrv
   nH:=fcreate(PRIVPATH+"outf.txt")
   fwrite(nH,"-nepostojeci podaci-")
   fclose(nH)
endif

close all

if pcount()==3
	o_fakt_edit(.t.)
else
	o_fakt_edit()
endif

// neka divlja varijabla
if "U" $ TYPE("lSSIP99") .or. !VALTYPE(lSSIP99)=="L" 
	lSSIP99:= .f.
endif

fDelphiRB:=.t.
cIniName:=EXEPATH+'ProIzvj.ini'

// fPBarkod - .t. stampati barkod, .f. ne stampati
private cPombk:=IzFmkIni("SifRoba","PBarkod","0",SIFPATH)
private fPBarkod:=.f.
if cPombk $ "12"  // pitanje, default "N"
   fPBarkod := ( Pitanje(,"Zelite li ispis barkodova ?",iif(cPombk=="1","N","D"))=="D")
endif

cRTM:=IzFmkIni('FAKT','NazRTM','fakt1')
cRTMF:=IzFmkIni('FAKT','NazRTMFax','fax1')
if IzFmkIni('FAKT','StampaWin2000','N',EXEPATH)=='D'
    cPoziv:=IzFmkIni('FAKT','PozivDelphiRB','DelphiRB',EXEPATH)
endif

if fPBarkod
     cRTM := ALLTRIM(cRTM) + "bk"
endif

if IzFmkIni('FAKT','10Duplo','N')=='D' .and. fakt_pripr->(reccount2())<=10
     // dupli prored fakture do deset stavki !!!
     cRTM := ALLTRIM(cRTM) + "dp"
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1", cHistory:=" "
aHistory:={}
RPar("c1",@cTI)
select params
use

select fakt_pripr
// za fakture maloprodaje dodaj "mp" kao nastavak na RTM filename
if fDelphiRb .and. (IdTipDok $ "11#27")
	cRTM := ALLTRIM(cRTM) + "mp"
endif

// za otpremnice dodaj "op"
if fDelphiRb .and. (IdTipDok $ "10") .and. (gDodPar == "1")
	cRTM := ALLTRIM(cRTM) + "op"
endif


if pcount()==0  // poziva se faktura iz pripreme
 	cIdTipdok:=idtipdok
	cIdFirma:=IdFirma
	cBrDok:=BrDok
endif

seek cIdFirma+cIdTipDok+cBrDok

NFOUND CRET

IF idtipdok=="01" .and. kolicina<0 .and. gPovDob$"DN"
	lPovDob:=(Pitanje(,"Stampati dokument povrata dobavljacu? (D/N)",gPovDob)=="D")
ELSE
	lPovDob:=.f.
ENDIF

IF glDistrib .and. cIdTipDok $ "10#21"
	mamb := " -------"
ELSE
	mamb := ""
ENDIF


aDbf:={ ; 
          {"POR","C",10,0},;
          {"IZNOS","N",18, 8} ;
      }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" 
set order to tag "1"
select fakt_pripr

cIdFirma:=IdFirma
cBrDok:=BRDok
dDatDok:=DatDok
cIdTipDok:=IdTipDok
cidpartner:=Idpartner

select partn
seek cIdpartner
if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
    //set relation to idops into ops
    cOpcina:=Idops
endif
select fakt_pripr

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""

cRegBr:=cPorDjBr:=""
//pri pozivu DelphiRb-a uzima iz Sifk por. i reg. broj

RegPorBrGet(@cRegBr,@cPorDjBr)

if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
    cKanton:="K: " + cOpcina
endif

if val(podbr)=0  .and. val(rbr)==1
	aMemo:=ParsMemo(txt)
   	if len(aMemo)>0
     		cTxt1:=padr(aMemo[1],40)
   	endif
   	if len(aMemo)>=5
    		cTxt3a:=aMemo[3]
    		cTxt3b:=aMemo[4]
    		cTxt3c:=aMemo[5]
   	endif
else
	Beep(2)
  	Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  	return
endif


_BrOtp:=space(8)
_DatOtp:=ctod("")
_BrNar:=space(8)
_DatPl:=ctod("")

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
     if len(aMemo)>=9
      _BrOtp:=aMemo[6]
      _DatOtp:=ctod(aMemo[7])
      _BrNar:=amemo[8]
      _DatPl:=ctod(aMemo[9])
     endif
  else
    Beep(2)
    Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
    return
  endif

   UzmiIzIni(cIniName,'Varijable','BrOtp',_BrOtp,'WRITE')
   UzmiIzIni(cIniName,'Varijable','DatOtp',dtoc(_DatOtp),'WRITE')
   UzmiIzIni(cIniName,'Varijable','BrNar',_BrNar,'WRITE')
   UzmiIzIni(cIniName,'Varijable','DatPl',dtoc(_DatPl),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija1',IzFmkIni("Zaglavlje","Linija1",gNFirma,KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija2',IzFmkIni("Zaglavlje","Linija2","-",KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija3',IzFmkIni("Zaglavlje","Linija3","-",KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija4',IzFmkIni("Zaglavlje","Linija4","-",KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija5',IzFmkIni("Zaglavlje","Linija5","-",KUMPATH),'WRITE')



// duzina slobodnog teksta
nLTxt2:=1
for i:=1 to len(cTxt2)
  if substr(cTxt2,i,1)=chr(13)
   ++nLTxt2
  endif
next
if idtipdok $ "10#11"
	nLTxt2+=7
endif

if fDelphiRB
   aDBf:={}
   AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'SIFRA'               , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'BARKOD'              , 'C' ,  13 ,  0 })
   if gDest
   	AADD(aDBf,{ 'DEST'                , 'C' ,  20 ,  0 })
   endif
   AADD(aDBf,{ 'NAZIV'               , 'C' ,  200 ,  0 })
   AADD(aDBf,{ 'JMJ'                 , 'C' ,   3 ,  0 })
   AADD(aDBf,{ 'Cijena'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'KOLICINA'            , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'SERBR'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'POREZ1'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'POREZ2'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'POREZ3'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'RABAT'               , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'POR'                 , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'UKUPNO'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'UKUPNO2'             , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
   AADD(aDBf,{ 'Cijena2'             , 'C' ,  12 ,  0 }) 


   nSek0 := SECONDS()
   nSekW := VAL( IzFMKIni("FAKT","CekanjeNaSljedeciPozivDRB","6",KUMPATH) )
   DO WHILE FILE(PRIVPATH+"POM.DBF")
     FERASE(PRIVPATH+"POM.DBF")
     IF SECONDS()-nSek0 > nSekW
       IF Pitanje(,"Zauzet POM.DBF (112). Pokusati ponovo? (D/N)","D")=="D"
         nSek0 := SECONDS()
         LOOP
       ELSE
         goModul:quit()
       ENDIF
     ENDIF
   ENDDO

dbcreate2(PRIVPATH+'POM.DBF',aDbf)
select ( F_POM )
usex (PRIVPATH+'POM')
INDEX ON RBR  TAG "1"
select fakt_pripr

cIdTipdok:=idtipdok
cBrDok:=brdok

StKupac(.t.)


nUk:=0
nUk2:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

do while idfirma==cIdFirma .and. idtipdok==cIdTipDok .and. brdok==cBrDok .and. !eof()
	NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na fakt_pripr->IdRoba

	SELECT ROBA
	seek fakt_pripr->idroba
	
	SELECT TARIFA
	seek roba->idtarifa

	select fakt_pripr

	cIdPartner := fakt_pripr->idpartner
	
	if alltrim(podbr)=="." .or. roba->tip="U"
     		aMemo:=ParsMemo(txt)
      		cTxt1:=padr(aMemo[1],40)
   	endif
	
   	if roba->tip="U"
      		cTxtR:=aMemo[1]
   	endif
	
       	select tarifa
	hseek roba->idtarifa
	select fakt_pripr
		
	aSbr:=Sjecistr(serbr,10)
    		
	if roba->tip="U"
     			aTxtR:=SjeciStr(aMemo[1],iif(gVarF=="1".and.!idtipdok$"11#27",51,if(.f.,if(idtipdok$"11#27",22,31),40)))   // duzina naziva + serijski broj
       			select pom
       			append blank  //prvo se stavlja naziv!!!
       			replace naziv with fakt_pripr->(aMemo[1])
       			select fakt_pripr
    	else
			
			cK1:=""
     			cK2:=""
     			
			if fakt_pripr->(fieldpos("k1"))<>0 
     				cK1:=k1
				cK2:=k2
			endif
     			
			aTxtR:=SjeciStr(trim(roba->naz)+iif(!empty(ck1+ck2)," "+ck1+" "+ck2,"")+Katbr()+IspisiPoNar(),if(.f.,if(idtipdok$"11#27",22,31),40))
       			select pom
       			append blank // prvo se stavlja naziv!!
       			replace naziv with fakt_pripr->(trim(roba->naz)+iif(!empty(ck1+ck2)," "+ck1+" "+ck2,"")+Katbr()+IspisiPoNar())
       			replace serbr with fakt_pripr->serbr
       			replace idtarifa with roba->idtarifa
			select fakt_pripr
	endif
			
			
	    
	nStopa := tarifa->opp
	cIdTarifa := tarifa->id
	if IsIno(cIdPartner)
		cPDV := "0"
		nStopa := 0
	else
	       	cPDV:= STR(tarifa->opp, 2, 0)+"%"
	endif
	

      	select pom
      	replace rbr with fakt_pripr->(RBr()) ,;
                   Sifra  with fakt_pripr->(StIdROBA(idroba))
      	select fakt_pripr

       	select pom
       	replace POREZ1 with transform(nStopa, "9999.9%")
       	select fakt_pripr
     	
	select pom
      	replace kolicina with transform(fakt_pripr->(kolicina()),pickol)
        replace jmj with lower(ROBA->jmj)
      	select fakt_pripr

        select pom
        replace cijena with fakt_pripr->(transform(cijena*Koef(cDinDem),piccdem))
        select fakt_pripr

        if rabat-int(rabat) <> 0
             cRab:=str(rabat,5,2)
        else
             cRab:=str(rabat,5,0)
        endif
	   
             if gRabProc=="D"
                select pom
                replace Rabat with fakt_pripr->(cRab+"%")
                select fakt_pripr
             endif
	     
             select pom
	     nCijena2 := fakt_pripr->cijena * (1- fakt_pripr->rabat/100) * Koef(cDinDem)

              replace Cijena2 with fakt_pripr->(transform(nCijena2 , piccdem))


		nStopa := tarifa->opp
		cIdTarifa := tarifa->id
		if IsIno(cIdPartner)
			cPDV := "0"
			nStopa := 0
		else
	       		cPDV:= STR(nStopa, 2, 0)+"%"
		endif

	        select pom
                replace POR with fakt_pripr->(cPDV)
               
                replace UKUPNO with fakt_pripr->(transform(round(kolicina()* cijena * Koef(cDinDem), nZaokr), picdem))
                replace UKUPNO2 with fakt_pripr->(transform(round(kolicina()*nCijena2*Koef(cDinDem), nZaokr), picdem))
              select fakt_pripr
           
	        nPDV:=ROUND(kolicina()* Koef(cDinDem)* nCijena2, nZaokr) * nStopa/100

             	// napuni tabelu poreza
	        select por
	     
                seek cPDV
               
	        if !found()
         	  ++nPorZaIspis
	      	  append blank
	      	  replace por with cPDV
	        endif
	       
                replace iznos with iznos+nPDV
                select fakt_pripr
	      
       if fPBarKod
         select pom
         replace BARKOD with roba->barkod
       endif
       
       select fakt_pripr
       nUk+=round(kolicina()*cijena*Koef(cDinDem),nZaokr)
       nUk2+=round(kolicina()*nCijena2*Koef(cDinDem),nZaokr)
       nRab+=round(kolicina()*cijena*Koef(cDinDem)*rabat/100,nZaokr)
   skip
enddo

nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)
nUk2:= round(nUk2, nZaokr)

// treba mi iznos poreza da bih vidio da li cu stampati red "Ukupno"
nPDV:=0 
select por
go top
do while !eof()
 nPDV+=round(Iznos, nZaokr)
 skip
enddo


UzmiIzIni(cIniName,'Varijable','UkupnoRabat',transform(0,picdem),'WRITE')
UzmiIzIni(cIniName,'Varijable','DINDEM',cDinDEM,'WRITE')
UzmiIzIni(cIniName,'Varijable','Ukupno', transform(nUk,picdem),'WRITE')
UzmiIzIni(cIniName,'Varijable','Ukupno2',transform(nUk2,picdem),'WRITE')


UzmiIzIni(cIniName,'Varijable','DINDEM', cDinDEM, 'WRITE')
if nRab<>0
    UzmiIzIni(cIniName,'Varijable','UkupnoRabat', transform(nRab,picdem),'WRITE')
endif

cPDV:=""
fStamp:=.f.

select por
 go top
 nPorI:=0

 UzmiIzIni(cIniName,'Varijable','PorezStopa1',"-",'WRITE')
 UzmiIzIni(cIniName,'Varijable','Porez1',"0",'WRITE')
 for i:=2 to 5
    UzmiIzIni(cIniName,'Varijable','Porez'+alltrim(str(i)),"",'WRITE')
 next

 nPDV := 0
 do while !eof()  // string poreza
  // odstampaj ukupno - rabat kada ima poreza
  nPDV += round(Iznos, nZaokr)
  UzmiIzIni(cIniName,'Varijable','PorezStopa'+alltrim(str(++nPori)),trim(por),'WRITE')
  UzmiIzIni(cIniName,'Varijable','Porez'+ alltrim(str(nPori)), transform(round(IF(cIdTipDok=="15",-1,1)*iznos,nzaokr),picdem),'WRITE')
  skip
 enddo

nFZaokr:=round(nUk-nRab+nPDV, nZaokr) - round2(round(nUk-nRab+nPDV, nZaokr), gFZaok)

if gFZaok<>9 .and. round(nFzaokr,4)<>0 
   UzmiIzIni(cIniName,'Varijable','Zaokruzenje',transform(nFZaokr,picdem),'WRITE')
endif

cPom:=Slovima(round(nUk-nRab+nPDV-nFzaokr, nZaokr), cDinDem)


UzmiIzIni(cIniName,'Varijable','UkupnoMRabat',transform(round(nUk-nRab,nzaokr),picdem),'WRITE')
UzmiIzIni(cIniName,'Varijable','UkupnoPDV',transform(round(nPDV, nzaokr), picdem),'WRITE')
UzmiIzIni(cIniName,'Varijable','UkupnoSaPDV',transform(round(nUk-nRab+nPDV-nFzaokr,nzaokr),picdem),'WRITE')
UzmiIzIni(cIniName,'Varijable','Slovima',cPom,'WRITE')



cTxt2:=strtran(cTxt2,"ç"+Chr(10),"")
cTxt2:=strtran(cTxt2, Chr(13)+Chr(10), "####"+Chr(200))

for i:=1 to 25
  UzmiIzIni(cIniName,'Varijable','KrajTxt'+alltrim(str(i)),"",'WRITE')
next


for i:=1 to numtoken(cTxt2, Chr(200) )
	UzmiIzIni(cIniName,'Varijable','KrajTxt'+alltrim(str(i)), token(KonvZnWin(@cTxt2, gKonvZnWin), Chr(200), i) ,'WRITE')
next
  

PrStr2T(cIdTipDok)

cSwitch:=""
SELECT (F_POM)
USE
UzmiIzIni(EXEPATH+"FMK.INI",'DELPHIRB','Aktivan',"1",'WRITE')

if IzFmkIni('FAKT','StampaWin2000','N',EXEPATH)=='D'
    private cKomLin:=cPoziv+" "+ALLTRIM(cRTM)+" "+PRIVPATH+"  pom  1"
    private cKomLinF:=cPoziv+" "+ALLTRIM(cRTMF)+" "+PRIVPATH+"  pom  1"
else
    private cKomLin:="start " + cSwitch + " DelphiRB "+ALLTRIM(cRTM)+" "+PRIVPATH+"  pom  1"
    private cKomLinF:="start " + cSwitch + " DelphiRB "+ALLTRIM(cRTMF)+" "+PRIVPATH+"  pom  1"
endif

BEEP(1)


IF lSSIP99
    cKomLin += " /P"
ENDIF

if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
    run &cKomLinF
else
    run &cKomLin
endif

IF lSSIP99
    MsgO("Cekam da DelphiRB zavrsi svoj posao...")
    DO WHILE IzFMKIni('DELPHIRB','Aktivan',"1")<>"0"
      IniRefresh()
      nSek0 := SECONDS()
      DO WHILE SECONDS()-nSek0<1.5
        //OL_Yield()
      ENDDO
      IniRefresh()
    ENDDO
    MsgC()
  ENDIF
endif

CLOSERET
*}


/*! \fn StKupac()
 */
 
static function StKupac()
*{
local cMjesto:=padl(get_mjesto_po_rj(cIdFirma)+", "+dtoc(ddatdok),iif(gFPZag=99,gnTMarg3,0)+39)

IF "U" $ TYPE("lPartic")
	lPartic:=.f.
ENDIF

aPom:=Sjecistr(cTxt3a,30)

for i:=1 to len(aPom)
     UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(i)),aPom[i],'WRITE')
next

UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(i)),cTxt3b,'WRITE')
UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(++i)),cTxt3c,'WRITE')

FOR j:=5 TO i+1 STEP -1
     UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(j)),"",'WRITE')
NEXT

UzmiIzIni(cIniName,'Varijable','REGBR',cRegBr,'WRITE')
UzmiIzIni(cIniName,'Varijable','PORDJBR',cPorDjBr,'WRITE')
if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
     UzmiIzIni(cIniName,'Varijable','KANTON',cKanton,'WRITE')
endif

cStr:=cidtipdok+" "+trim(cbrdok)

UzmiIzIni(cIniName,'Varijable','Mjesto',cMjesto,'WRITE')

private cpom:=""
if !(cIdTipDok $ "00#01#19")
   cPom:="G"+cidtipdok+"STR"
   cStr:=&cPom
endif

cStrRN:=""

if cIdTipDok == "01"
  if cIdFirma="TE"
    cStr:="RADNI NALOG"
  else
    IF lPovDob
      cStr:="POVRAT DOBAVLJACU "+cIdFirma
    ELSE
      cStr:="PRIJEM U MAGACIN "+cIdFirma
    ENDIF
  endif
elseif cidtipdok="19"
  if cIdFirma="TE"
    cStr:="REALIZACIJA R.N."
  else
   if IzFMKIni("FAKT","I19jeOtpremnica","N",KUMPATH)=="D"
      cStr:="OTPREMNICA (19) "+cIdFirma
   elseif lPartic
      cStr:=StrKZN("RA¨UN PARTICIPACIJE","8",gKodnaS)+" (19) "+cIdFirma
   else
      cStr:="IZLAZ (19) "+cIdFirma
   endif
  endif
endif

UzmiIzIni(cIniName,'Varijable','Dokument',cStr,'WRITE')
UzmiIzIni(cIniName,'Varijable','BROJDOK',cBrDok,'WRITE')

if !(cIdTipDok == "10")
    UzmiIzIni(cIniName,'Varijable','BrNar',' ---- ','WRITE')
    UzmiIzIni(cIniName,'Varijable','DatPl',' ---- ','WRITE')
    UzmiIzIni(cIniName,'Varijable','BrOtp',' ---- ','WRITE')
    UzmiIzIni(cIniName,'Varijable','DatOtp',' ---- ','WRITE')
endif

return
*}

