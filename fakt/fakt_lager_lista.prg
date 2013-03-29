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


function fakt_lager_lista()

parameters lPocStanje, cIdFirma, qqRoba, dDatOd, dDatDo

local nKU,nKI, fSaberiKol
local aPorezi:={}, cPoTar:="N"

private nRezerv,nRevers
private nUl, nIzl, nRbr, cRR, nCol1:=0
private m:=""
// tekuca strana
private nStr:=0 
private cProred:="N"
private nGrZn:=99
private cLastIdRoba:=""

//testni counter globalna varijabla
gCnt1:=0

lBezUlaza := ( IzFMKINI("IZVJESTAJI","BezUlaza","N",KUMPATH)=="D" )

if lPocStanje==NIL
   lPocStanje:=.f.
else
   lPocStanje:=.t.
   O_FAKT_PRIPR
   nRbrPst:=0
   cBrPSt:="00001   "
   Box(,2,60)
     @ m_x+1,m_y+2 SAY "Generacija poc. stanja  - broj dokumenta 00 -" GET cBrPSt
     read
   BoxC()
endif

if lPocStanje
	private fId_J:=.f.
	if IzFmkIni("SifRoba","ID_J","N")=="D"
		fId_J:=.t.
	endif
endif

O_FAKT_DOKS
O_TARIFA
O_PARTN
O_SIFK
O_SIFV
O_ROBA
O_RJ

if fId_J
	O_FAKT
	// idroba+dtos(datDok)
	set order to tag "3J" 
else
	O_FAKT
	// idroba+dtos(datDok)
	set order to tag "3" 
endif


fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')
nKU:=nKI:=0

if !gAppSrv
	 cIdfirma:=gFirma
	 qqRoba:=""
	 dDatOd:=ctod("")
	 dDatDo:=date()
endif

cSaldo0:="N"
qqPartn:=space(20)
private qqTipdok:="  "

Box(,20+IIF(lPoNarudzbi,2,0), 66)


O_PARAMS
private cSection:="5"
private cHistory:=" "
private aHistory:={}
Params1()

if !gAppSrv
	RPar("c1",@cIdFirma)
	RPar("c2",@qqRoba)
	RPar("c7",@qqPartn)
	RPar("c8",@qqTipDok)
	RPar("d1",@dDatOd)
	RPar("d2",@dDatDo)
endif


select fakt


if gNW$"DR"
 //cIdfirma:=gFirma
endif
qqRoba:=padr(qqRoba,60)
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,2)

cRR:="N"
cUI:="S"

private cTipVPC:="1"

cK1:=cK2:=space(4)

do while .t.
 if gNW$"DR"
   @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma), cIdFirma := LEFT( cIdFirma, 2 ), .t. }
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
@ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
@ m_x+3,m_y+2 SAY "Naziv partnera (prazno - svi)"  GET qqPartn   pict "@!"
@ m_x+4,m_y+2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
@ m_x+5,m_y+2 SAY "Od datuma "  get dDatOd
@ m_x+5,col()+1 SAY "do"  get dDatDo

IF lBezUlaza
  cRR:="N"
ELSE
  @ m_x+6,m_y+2 SAY "Prikaz rezervacija, reversa (D)"
  @ m_x+7,m_y+2 SAY "Prikaz bez rezervacija, reversa (N)"
  @ m_x+8,m_y+2 SAY "Prikaz fakturisanog na osnovu otpremnica (F) "  get cRR   pict "@!" valid cRR $ "DNF"
ENDIF

@ m_x+10,m_y+2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  get cSaldo0 pict "@!" valid cSaldo0 $ "DN"
if gVarC $ "12"
 @ m_x+11,m_y+2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
endif
@ m_x+12,m_y+2 SAY "Napraviti prored (D/N)    "  get cProred pict "@!" valid cProred $ "DN"
if !lPocStanje
 @ m_x+13,m_y+ 2 SAY "Prikaz grupacija, grupa ima (99-ne prikazivati)" GET nGrZn pict "99"
 @ m_x+13,m_y+53 SAY "znakova"
endif
if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
 @ m_x+14,m_y+ 2 SAY "K1" GET  cK1 pict "@!"
 @ m_x+14,m_y+15 SAY "K2" GET  cK2 pict "@!"
endif

cPopis:="N"
@ m_x+15,m_y+2 SAY "Prikazati obrazac za popis D/N" GET  cPopis pict "@!" valid cPopis $ "DN"

cRealizacija:="N"
IF !lBezUlaza
  @ row()+1,m_y+2 SAY "Prikazati realizaciju " GET  cRealizacija pict "@!" valid cRealizacija $ "DN"
ENDIF

cSintetika:=IzFmkIni("FAKT","Sintet","N")

IF !lPocStanje .and. cSintetika=="D"
  @ row()+1,m_y+2 SAY "Sinteticki prikaz? (D/N) " GET  cSintetika pict "@!" valid cSintetika $ "DN"
ELSE
  cSintetika:="N"
ENDIF

IF !lBezUlaza
  @ row()+1,m_y+2 SAY "Prikaz kolicina (U-samo ulaz, I-samo izlaz, S-sve)" GET cUI VALID cUI$"UIS" PICT "@!"
ELSE
  cUI:="S"
ENDIF

@ row()+1, m_y+2 SAY "Prikaz stanja po tarifama? (D/N)" GET cPoTar VALID cPoTar$"DN" PICT "@!"

read

 ESC_BCR
 if fID_J
   aUsl1:=Parsiraj(qqRoba,"IdRoba_J")
 else
   aUsl1:=Parsiraj(qqRoba,"IdRoba")
 endif

 if aUsl1<>NIL 
   exit
 endif

enddo

IF lBezUlaza
  m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- ---"
ELSE

  if cRR $ "NF"
   m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+IF(cUI=="S"," ----------- -----------","")+" ----------- --- --------- -----------"
  else
   m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- ----------- ----------- ----------- --- --------- -----------"
  endif

  if gVarC=="4"
    m+=" "+replicate("-",12)
  endif

  if cRealizacija=="D"
   m+=" "+replicate("-",12)+" "+replicate("-",12)
  endif
ENDIF


select params
qqRoba:=trim(qqRoba)


if !gAppSrv
 WPar("c1",cIdFirma)
 WPar("c2",qqRoba)
 WPar("c7",qqPartn)
 WPar("c8",qqTipDok)
 WPar("d1",dDatOd)
 WPar("d2",dDatDo)
endif

use

BoxC()

fSMark:=.f.
if right(qqRoba,1)="*"
  // izvrsena je markacija robe ..
  fSMark:=.t.
endif

select FAKT

IF lPoNarudzbi .and. cPKN=="D"
  SET ORDER TO TAG "3N"
ENDIF

private cFilt:=".t."

if aUsl1<>".t."
  cFilt+=".and."+aUsl1
endif

if lPoNarudzbi .and. aUslN<>".t."
  cFilt+=".and."+aUslN
endif

if gAppSrv
  ? DTOS(dDatOd),DTOS(dDatDo)
endif

if !empty(dDatOd) .or. !empty(dDatDo)
    cFilt+= ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
endif

cTMPFAKT:=""
if cFilt==".t."
   set filter to
  else
   set filter to &cFilt
endif

if gAppSrv
  ? "Filter:", cFilt
  //set filter to
endif

go top


EOF CRET


START PRINT CRET

Zaglfakt_lager_lista()

_cijena:=0
_cijena2:=0

nRbr:=0
nIzn:=0
nIzn2:=0
nIznR:=0 // iznos rabata
nRezerv:=nRevers:=0
qqPartn:=trim(qqPartn)
cidfirma:=trim(cidfirma)

if cSintetika=="D"
    bWhile1:= {|| !eof() .and. LEFT(cIdroba,gnDS)==LEFT(IdRoba,gnDS)  }
else
    if fId_J
      bWhile1:= {|| !eof() .and. cIdRoba==IdRoba_J+IdRoba }
    else
      bWhile1:= {|| !eof() .and. cIdRoba==IdRoba }
    endif
endif

do while !eof()
  if fID_J
    cIdRoba:=IdRoba_J+IdRoba
  else
    cIdRoba:=IdRoba
  endif

  if cSintetika=="D"
    NSRNPIdRoba(cIdRoba,.t.); SELECT FAKT
  endif

  IF lPoNarudzbi .and. cPKN=="D"
    cIdNar:=idnar
  ENDIF

  nUl:=nIzl:=0
  nRezerv:=nRevers:=0
  // nReal1 realizacija , nReal2 - rabat
  nReal1:=0
  nReal2:=0 

  if cSintetika=="D"
      bWhile1:= {|| !eof() .and.;
                    LEFT(cIdroba,gnDS)==LEFT(IdRoba,gnDS) .and.;
                    IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)  }
  else
      if fId_J
        bWhile1:= {|| !eof() .and. cIdRoba==IdRoba_J+IdRoba .and.;
                      IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)  }
      else
        bWhile1:= {|| !eof() .and. cIdRoba==IdRoba .and.;
                      IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)  }
      endif
  endif
 
 // skip & loop gdje je roba->_M1_ != "*"
  if fSMark .and. SkLoNMark("ROBA",SiSiRo())
      skip; loop
  endif


  do while eval(bWhile1)

    
    // skip & loop gdje je roba->_M1_ != "*"
    if fSMark .and. SkLoNMark("ROBA",SiSiRo()) 
        skip
	loop
    endif

    if !empty(qqTipDok)
       if idtipdok<>qqTipDok
         skip
	 loop
       endif
    endif
    
    if !empty(cidfirma)
      if idfirma<>cidfirma
     	skip
	    loop
	  endif
    endif

    if !empty(qqPartn)
        select fakt_doks
        hseek fakt->(IdFirma+idtipdok+brdok)
        select fakt

	  if !(fakt_doks->partner = qqPartn)
        skip
	    loop
      endif
    endif

    // atributi
    if !empty(cK1); if ck1<>K1; skip; loop; end; end

    if !empty(cK2); if ck2<>K2;  skip; loop; end; end

    if !empty(cIdRoba)
    if cRR<>"F"
     // ulaz
     if idtipdok="0" 
        nUl+=kolicina
        if fSaberikol .and. !( roba->K2 = 'X')
         nKU+=kolicina
        endif
     // izlaz faktura
     elseif idtipdok="1"  
       if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremnice ne racunaj izlaz
          nIzl+=kolicina
          nReal1+=round( kolicina*Cijena, ZAOKRUZENJE)
          nReal2+=round( kolicina*Cijena*(Rabat/100) , ZAOKRUZENJE)
          if fSaberikol .and. !( roba->K2 = 'X')
            nKI+=kolicina
          endif
       endif
     elseif idtipdok$"20#27"
        if serbr="*"
          nRezerv+=kolicina
        endif
     elseif idtipdok=="21"
        nRevers+=kolicina
        if fSaberikol .and. !( roba->K2 = 'X')
            nKI+=kolicina
        endif
     endif
    else
     // za fakture na osnovu otpremince ne racunaj izlaz
     if (serbr="*" .and. idtipdok=="10") 
          nIzl+=kolicina
          // finansijski da !
          nReal1+=round( kolicina*Cijena , ZAOKRUZENJE)
          nReal2+=round( kolicina*Cijena*(Rabat/100) , ZAOKRUZENJE)
          if fSaberikol .and. !( roba->K2 = 'X')
            nKI+=kolicina
          endif
     endif
    endif // crr=="F"
    endif  // empty(
    skip
  enddo
  	
	if prow()>61-iif(cProred="D",1,0)
  		Zaglfakt_lager_lista()
	endif

  if !empty(cIdRoba)
   if !(cSaldo0=="N" .and. (nUl-nIzl)==0)
     if fID_J
         NSRNPIdRoba(substr(cIdRoba, 11), (cSintetika=="D"))  
	 // desni dio sifre je interna sifra
     else
         NSRNPIdRoba(cIdRoba, (cSintetika=="D") )
     endif
    
    IF nGrZn<>99 .and. ( EMPTY(cLastIdRoba) .or. LEFT(cLastIdRoba,nGrZn)<>LEFT(cIdRoba,nGrZn) )
      SELECT ROBA
      PushWA()
      SEEK LEFT(cIdRoba,nGrZn)
      IF FOUND() .and. RIGHT(TRIM(id),1)=="."
        cNazivGrupacije := LEFT(cIdRoba,nGrZn)+" "+naz
      ELSE
        cNazivGrupacije := LEFT(cIdRoba,nGrZn)
      ENDIF
      PopWA()
      if cProred=="D"
        ? space(gnLMarg); ?? m
      endif
      ? space(gnLMarg)
      ?? "GRUPA ARTIKALA: "+cNazivGrupacije
      cLastIdRoba:=cIdRoba
    ENDIF
    select FAKT
    if cProred=="D"
       ? space(gnLMarg); ?? m
    endif
    ? space(gnLMarg)
    ?? str(++nRbr,4),;
      IF(cSintetika=="D".and.ROBA->tip=="S",;
         ROBA->id, Left(cidroba,10)), PADR(ROBA->naz,40)

    if lPoNarudzbi .and. cPKN=="D"
      ?? "", cIdNar
    endif

    if cRR $ "NF" .and. !lBezUlaza
     IF cUI $ "US"
       @ prow(),pcol()+1 SAY nUl  pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ENDIF
     IF cUI $ "IS"
       @ prow(),pcol()+1 SAY nIzl pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ENDIF
    endif

    IF lBezUlaza
      nCol1 := pcol()+1
    ENDIF
    IF cUI == "S"
      @ prow(),pcol()+1 SAY nUl-nIzl pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
    ENDIF

    if cRR=="D"
      @ prow(),pcol()+1 SAY nRevers pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
      @ prow(),pcol()+1 SAY nRezerv pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
      @ prow(),pcol()+1 SAY nUl-nIzl-nRevers-nRezerv pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
    endif
    @ prow(),pcol()+1 SAY roba->jmj
    if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
      _cijena:=roba->vpc2
    else
      _cijena := if ( !EMPTY(cIdFirma) , fakt_mpc_iz_sifrarnika(), roba->vpc )
    endif
    if gVarC=="4"
     _cijena2:=roba->mpc
    endif

    if lPocStanje
      select fakt_pripr
      if cRR="D"
        nPrenesi:=-nRevers-nRezerv
      else
        nPrenesi:=nUl-nIzl
      endif
      if round(nPrenesi,4)<>0
         append blank
         replace idfirma with cidfirma, idroba with left(cIdRoba,10),;
                 datdok with dDatDo+1,;
                 idtipdok with "00", brdok with cBRPST ,;
                 cijena with _cijena,;
                 dindem with "KM ",;
                 Rbr with Rednibroj(++nRbrPst),;
                 kolicina with nPrenesi

         if fId_J
           replace idroba_J with left(cIdRoba,10),;
                   idroba with substr(cIdroba,11)
         endif
        replace txt   with chr(16)+""+chr(17)+;
                      chr(16)+""+chr(17)+chr(16)+"POCETNO STANJE"+chr(17)+;
                      chr(16)+""+chr(17)+chr(16)+""+chr(17)

      endif
      select fakt
    endif

    if cPoTar=="D"
	nMpv:=(nUl-nIzl)*roba->mpc
	nPom:=ASCAN(aPorezi,{|x| x[1]==roba->idTarifa})
	if nPom>0
		aPorezi[nPom,2]:=aPorezi[nPom,2]+nMpv
	else
		AADD(aPorezi, {roba->idTarifa, nMpv})
	endif
    endif

    if cRealizacija=="D"
       if nIzl>0
         @ prow(),pcol()+1 SAY (nReal1-nReal2)/nIzl  pict "99999.999"
       else
         @ prow(),pcol()+1 SAY 0  pict "99999.999"
       endif
       nCol1:=pcol()+1
       @ prow(),nCol1 SAY nReal1  pict picdem
       @ prow(),pcol()+1 SAY nReal2  pict picdem
       @ prow(),pcol()+1 SAY nReal1-nReal2  pict picdem
       nIzn+=nReal1
       nIznR+=nReal2
    else
       nPomSt := IF( cUI=="S" , nUl-nIzl , IF( cUI=="I" , nIzl , nUl ) )
       IF !lBezUlaza
         @ prow(),pcol()+1 SAY _cijena  pict "99999.999"
         nCol1:=pcol()+1
         @ prow(),nCol1 SAY nPomSt*_cijena   pict iif(cPopis=="N",picdem,replicate("_",len(Picdem)) )
       ENDIF
       nIzn += nPomSt*_cijena
       if gVarC=="4" // uporedo
         IF !lBezUlaza
           @ prow(),pcol()+1 SAY _cijena2   pict picdem
         ENDIF
         nIzn2 += nPomSt*_cijena2
       endif
    endif

   endif
  endif

enddo

if prow()>59
	Zaglfakt_lager_lista()
endif

IF !lBezUlaza
  ? space(gnLMarg)
  ?? m
  ? space(gnLMarg)
  ?? " Ukupno:"
  if cPopis=="N"
    @ prow(),nCol1 SAY nIzn  pict picdem
    if cRealizacija=="D"
      @ prow(),pcol()+1 SAY nIznR  pict picdem
      @ prow(),pcol()+1 SAY nIzn-nIznR  pict picdem
    endif
    if gVarC=="4"
      ? space(gnLMarg)
      if IsPDV()
      	?? " Ukupno  PV:"
      else
      	?? " Ukupno MPV:"
      endif
      
      @ prow(),nCol1 SAY nIzn2  pict picdem
    endif
  endif
ENDIF

? space(gnLMarg)
?? m

if fSaberikol
 ? space(gnLMarg); ?? " Ukupno (kolicine):"
 IF lBezUlaza
   @ prow(),nCol1 SAY nKU-nKI picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
 ELSE
   IF cUI $ "US"
     @ prow(), nCol1 - ( len(picdem)+1 )* 4 - 2  SAY nKU  picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
   ENDIF
   IF cUI $ "IS"
     IF cUI == "I"
       @ prow(),nCol1 - ( len(picdem)+1 )* 4 - 2 SAY nKI  picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ELSE
       @ prow(),pcol()+1 SAY nKI  picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ENDIF
   ENDIF
   IF cUI == "S"
     @ prow(),pcol()+1 SAY nKU-nKI picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
   ENDIF
 ENDIF
 ? space(gnLMarg)
 ?? m
endif

if cPoTar=="D"
	if prow()>59
		Zaglfakt_lager_lista()
	endif
	?
	z0:="Rekapitulacija stanja po tarifama:"
	? z0
	m:="------"+REPL(" "+REPL("-",LEN(gPicProc)),3)+REPL(" "+REPL("-",LEN(PicDem)),5)
	? m
	z1:="Tarifa"+PADC("PPP%",LEN(gPicProc)+1)+PADC("PPU%",LEN(gPicProc)+1)+PADC("PP%",LEN(gPicProc)+1)+PADC("MPV",LEN(PicDem)+1)+PADC("PPP",LEN(PicDem)+1)+PADC("PPU",LEN(PicDem)+1)+PADC("PP",LEN(PicDem)+1)+PADC("MPV+por",LEN(PicDem)+1)
	? z1
	? m
	ASORT(aPorezi,{|x,y| x[1]<y[1]})
	nUMPV:=nUMPV0:=nUPor1:=nUPor2:=nUPor3:=0
	for i:=1 to len(aPorezi)
		if prow()>59
			Zaglfakt_lager_lista()
			?
			? z0
			? m
			? z1
			? m
		endif
		select tarifa
		hseek aPorezi[i,1]
		fakt_vt_porezi()
		nMPV:=aPorezi[i,2]
		nMPV0:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP)), ZAOKRUZENJE)
		nPor1:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP))*_OPP, ZAOKRUZENJE)
		nPor2:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP)*(1+_OPP))*_PPP, ZAOKRUZENJE)
		nPor3:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP))*_ZPP, ZAOKRUZENJE)
		? aPorezi[i,1], TRANS(100*_OPP,gPicProc), TRANS(100*_PPP,gPicProc), TRANS(100*_ZPP,gPicProc), TRANS(nMPV0,PicDem), TRANS(nPor1,PicDem), TRANS(nPor2,PicDem), TRANS(nPor3,PicDem), TRANS(nMPV,PicDem)
		nUMPV+=nMPV
		nUMPV0+=nMPV0
		nUPor1+=nPor1
		nUPor2+=nPor2
		nUPor3+=nPor3
	next
	? m
	? PADR("UKUPNO:",3*(LEN(gPicProc)+1)+6), TRANS(nUMPV0,PicDem), TRANS(nUPor1,PicDem), TRANS(nUPor2,PicDem), TRANS(nUPor3,PicDem), TRANS(nUMPV,PicDem)
	?
endif

FF
END PRINT


CLOSE ALL
MyFERASE(cTMPFAKT)

// MsgBeep("gCnt1="+STR(gCnt1,6))

CLOSERET
return
*}



/*! \fn Zaglfakt_lager_lista()
 *  \brief Zaglavlje lager liste
 */
 
function Zaglfakt_lager_lista()
local cPomZK
local _rj_tip := ""

if rj->(fieldpos("tip")) <> 0
    _rj_tip := rj->tip
endif

if nStr>0
	FF
endif

?
P_COND
set century on
? space(4), "   FAKT: Lager lista robe na dan", DATE(), "      za period od", dDatOd, "-", dDatDo, space(6), "Strana:",str(++nStr,3)
set century off
?

IF cUI=="U"
    ? space(4),"         (prikaz samo ulaza)"
    ?
ELSEIF cUI=="I"
    ? space(4),"         (prikaz samo izlaza)"
    ?
ENDIF

IF cRR=="D"
    P_COND2
ELSE
    P_COND
ENDIF

if cRealizacija=="D"
    P_COND2
    ?
    ? space(gnLMarg)
    ?? "**** FINANSIJSKI: PRIKAZ REALIZACIJE *****"
    ?
endif

? space(gnLMarg)
IspisFirme(cidfirma)

if !empty(qqRoba)
    ? space(gnLMarg)
    ?? "Roba:",qqRoba
endif

if !empty(cK1)
    ?
    ? space(gnlmarg), "- Roba sa osobinom K1:",ck1
endif

if !empty(cK2)
    ?
    ? space(gnlmarg), "- Roba sa osobinom K2:",ck2
endif

if lPoNarudzbi .and. !EMPTY(qqIdNar)
    ?
    ? "Prikaz za sljedece narucioce:",TRIM(qqIdNar)
endif

?

if cRealizacija=="N" .and. cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
    ? space(gnlmarg)
    ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: "+cTipVPC
endif

?
? space(gnLMarg)
?? m
? space(gnLMarg)

IF lBezUlaza
    ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+"  Stanje    jmj     "
ELSE
    cPomZK := IF( cUI $ "US" , PADC("Ulaz",12) , "" )+;
            IF( cUI $ "IS" , PADC("Izlaz",12) , "" )+;
            IF( cUI $ "S" , PADC("Stanje",12) , "" )
    if cRR $ "NF"
        if IsPDV()
 	        ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+cPomZK+"jmj     "+IIF(_rj_tip$"N1#M1#M2".and.!EMPTY(cIdFirma),"Cij.",iif(cRealizacija=="D","PR.C"," PC "))+;
                iif(cREalizacija=="N","      Iznos","       PV        Rabat      Realizovano")
        else
     	    ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+cPomZK+"jmj     "+IIF(_rj_tip$"N1#M1#M2".and.!EMPTY(cIdFirma),"Cij.",iif(cRealizacija=="D","PR.C","VPC "))+;
                iif(cREalizacija=="N","      Iznos","      VPV        Rabat      Realizovano")
        endif
    else
        ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi .and. cPKN=="D","Naruc. ","")+"  Stanje       Revers    Rezervac.   Ostalo     jmj     "+IF(RJ->tip$"N1#M1#M2" .and. !EMPTY(cIdFirma),"Cij.  Cij.","VPC    VPC")+"*Stanje"
    endif
    if gVarC=="4"
        ?? padc("MPV",13)
    endif
ENDIF

? space(gnLMarg)
?? m

ShowKorner(nStr,1,16)

return





// -----------------------------------------------------------------
// uslovi izvjestaja lager lista
// -----------------------------------------------------------------
function fakt_lager_lista_vars( param, ps )
local _ret := 1
local _x := 1
local _id_firma, _usl_roba, _usl_partn, _usl_tip_dok
local _date_from, _date_to
local _stavke_nula, _tip_prikaza
local _date_ps 

if ps == NIL
    // nije pocetno stanje
    _date_ps := NIL
    ps := .f.
    _date_from := fetch_metric( "fakt_lager_lista_datum_od", my_user(), DATE() )
    _date_to := fetch_metric( "fakt_lager_lista_datum_do", my_user(), DATE() )
else
    // pocetno stanje je u pitanju
    _date_ps := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) ) ) )
    _date_from := CTOD( "01.01." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
    _date_to := CTOD( "31.12." + ALLTRIM( STR( YEAR( DATE() ) -1 ) ) )
endif

_stavke_nula := "N"
_tip_prikaza := "S"
_usl_roba := SPACE(300)
_usl_partn := SPACE(300)
_usl_tip_dok := SPACE(200)
_id_firma := gFirma

Box(, 10, 70 )

    @ m_x + _x, m_y + 2 SAY "RJ (prazno-sve): " GET _id_firma VALID {|| EMPTY( _id_firma), P_RJ( @_id_firma ), _id_firma := LEFT( _id_firma, 2 ), .t. }

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Datum od:" GET _date_from
    @ m_x + _x, col() + 1 SAY "do:" GET _date_to

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Roba   " GET _usl_roba PICT "@S40"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Naziv partnera (prazno - svi)" GET _usl_partn PICT "@S40"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Tip dokumenta (prazno - svi)" GET _usl_tip_dok PICT "@S40" 

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Prikaz stavki sa stanjem 0 (D/N)    " GET _stavke_nula PICT "@!" VALID _stavke_nula $ "DN"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Prikaz kolicina ( U-samo ulaz, I-samo izlaz, S-sve )" GET _tip_prikaza VALID _tip_prikaza $ "UIS" PICT "@!"

    if ps
        ++ _x
        ++ _x
        @ m_x + _x, m_y + 2 SAY "Datum pocetnog stanja:" GET _date_ps 
    endif

    read

BoxC()

if LastKey() == K_ESC
    _ret := 0
endif

// snimi db parametre
// nemoj ako je pocetno stanje u pitanju...
if !ps
    set_metric( "fakt_lager_lista_datum_od", my_user(), _date_from )
    set_metric( "fakt_lager_lista_datum_do", my_user(), _date_to )
endif

// snimi parametre
param["datum_od"] := _date_from
param["datum_do"] := _date_to
param["datum_ps"] := _date_ps
param["artikli"] := _usl_roba
param["partneri"] := _usl_partn
param["dokumenti"] := _usl_tip_dok
param["stavke_nula"] := _stavke_nula
param["tip_prikaza"] := _tip_prikaza
param["id_firma"] := _id_firma

return _ret




// -----------------------------------------------------------------
// generisanje xml fajla za lager listu
// -----------------------------------------------------------------
static function lager_lista_xml( table, params )
local _ret := .t.
local _row
local _id_roba, _ulaz, _izlaz, _stanje
local _count := 0
local _t_ulaz := 0
local _t_izlaz := 0
local _t_stanje := 0

O_ROBA
O_PARTN

// ima li zapisa...
if table:LastRec() == 0
    return .f.
endif

open_xml( _xml )
xml_subnode( "lager", .f. )

// podaci zaglavlja...
// xml_node( "firma", gFirma )
// xml_node( "datum_od", gFirma )
// xml_node( "datum_do", gFirma )
// xml_node( "roba", gFirma )


do while !table:EOF()

    _row := table:GetRow()

    _id_roba := _row:FieldGet( _row:FieldPos("idroba") ) 
    _ulaz := _row:FieldGet( _row:FieldPos("ulaz") ) 
    _izlaz := _row:FieldGet( _row:FieldPos("izlaz") )

    if params["tip_prikaza"] == "U"
        _izlaz := 0
    elseif params["tip_prikaza"] == "I"
        _ulaz := 0
    endif

    _stanje := ( _ulaz - _izlaz ) 

    _t_stanje += _stanje
    _t_ulaz += _ulaz
    _t_izlaz += _izlaz

    select roba
    hseek _id_roba

    _cijena := roba->vpc

    // sta sa uslugama ???
    if roba->tip == "U"
    endif
    
    if params["stavke_nula"] == "N" .and. ROUND( _stanje, 2 ) == 0
        table:Skip()
        loop
    endif

    xml_subnode( "item", .f. )
    
    xml_node( "rbr", ALLTRIM( STR( ++_count ) ) )
    xml_node( "id", to_xml_encoding( _id_roba ) )
    xml_node( "naz", to_xml_encoding( roba->naz ) )
    xml_node( "jmj", to_xml_encoding( roba->jmj ) )
    xml_node( "ulaz", STR( _ulaz, 12, 2 ) )
    xml_node( "izlaz", STR( _izlaz, 12, 2 ) )
    xml_node( "stanje", STR( _stanje, 12, 2 ) )
    xml_node( "cijena", STR( _cijena, 12, 2 ) )

    xml_subnode( "item", .t. )
    
    table:Skip()
    
enddo
 
// totali lagerice
xml_node( "t_ulaz", STR( _t_ulaz, 12, 2 ) )
xml_node( "t_izlaz", STR( _t_izlaz, 12, 2 ) )
xml_node( "t_stanje", STR( _t_stanje, 12, 2 ) )

xml_subnode( "lager", .t. )
close_xml()

return _ret



// ------------------------------------------------------------------
// lager lista sql
// ------------------------------------------------------------------
function fakt_lager_lista_sql( param, ps )
local _table
local _tek_database := my_server_params()["database"]
local _db_params := my_server_params()

// ako nema parametara setuj mi ih...
if param == NIL
    if fakt_lager_lista_vars( @param ) == 0
        return
    endif
endif

if ps == NIL
    ps := .f.
endif

// formiranje sql upita za lager listu
_table := fakt_lager_lista_get_data( param, ps )

return _table



// -----------------------------------------------------------------
// daj mi podatke za lager listu...
// -----------------------------------------------------------------
static function fakt_lager_lista_get_data( params, ps )
local _tek_database := my_server_params()["database"]
local _db_params := my_server_params()
local _table, _qry, _server
local _date_from, _date_to, _data_ps
local _id_firma, _usl_roba, _usl_partn, _usl_tip_dok

_date_from := params["datum_od"]
_date_to := params["datum_do"]
_id_firma := params["id_firma"]
_usl_roba := params["artikli"]
_usl_partn := params["partneri"]
_usl_tip_dok := params["dokumenti"]
_date_ps := params["datum_ps"]

// pocetno stanje
if ps == NIL
    ps := .f.
endif

if ps    
    my_server_logout()
    _db_params["database"] := LEFT( _tek_database, LEN( _tek_database ) - 4 ) + ALLTRIM( STR( YEAR( _date_from ) ) )
    my_server_params( _db_params )
    my_server_login( _db_params )
endif

_server := pg_server()

_qry := "SELECT " + ; 
            "f.idroba, r.naz, " + ;
            "SUM( CASE " + ;
                "WHEN idtipdok LIKE '0%' THEN kolicina  " + ; 
            "END ) as ulaz, " + ;
            "SUM( CASE " + ;
                "WHEN idtipdok LIKE '1%' THEN kolicina " + ;
            "END ) as izlaz, " + ;
            "r.jmj, " + ;
            "r.vpc " + ;
        "FROM fmk.fakt_fakt f " + ;
        "LEFT JOIN fmk.roba r ON f.idroba = r.id "

// where cond ...
_qry += " WHERE "
_qry += _sql_cond_parse( "idfirma", _id_firma )
_qry += " AND " + _sql_date_parse( "datdok", _date_from, _date_to )

if !EMPTY( _usl_roba )
    _qry += " AND " + _sql_cond_parse( "idroba", _usl_roba )
endif

if !EMPTY( _usl_partn )
    _qry += " AND " + _sql_cond_parse( "idpartner", _usl_partn )
endif

if !EMPTY( _usl_tip_dok )
    _qry += " AND " + _sql_cond_parse( "idtipdok", _usl_tip_dok )
endif

_qry += " GROUP BY f.idroba, r.naz, r.jmj, r.vpc "
_qry += " ORDER BY f.idroba "

// podaci pocetnog stanja su ovdje....
_table := _sql_query( _server, _qry )
_table:Refresh()

// vrni se na tekuce podrucje
if ps
    my_server_logout()
    _db_params["database"] := LEFT( _tek_database, LEN( _tek_database ) - 4 ) + ALLTRIM( STR( YEAR( _date_ps ) ) )
    my_server_params( _db_params )
    my_server_login( _db_params )
    _server := pg_server()
endif

return _table




