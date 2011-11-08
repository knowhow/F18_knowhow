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

 

// Pregled finansijskog obrta magacin/prodavnica
function ObrtPoMjF()
local nOpseg
local nKorekcija:=1
local cLegenda
// aMersed
local nRekaRecCount

private  nCol1:=0
private PicCDem := REPLICATE("9", VAL(gFPicCDem)) + gPicCDem
private PicProc := gPicProc
private PicDEM  := REPLICATE("9", VAL(gFPicDem)) + gPicDEM
private Pickol:= "@ 999999"
// sirina kolone "+povecanje -snizenje" je za 3 
// karaktera veca od ostalih, tj. ima vise cifara
private PicPSDEM := REPLICATE("9", 3) + PicDEM
private dDatOd:=date()
private dDatDo:=date()
private qqKonto:=padr("13;",60)
private qqRoba:=space(60)
private cIdKPovrata:=space(7)
private ck7:="N"
// P-prodajna (bez poreza)
// N-nabavna
private cCijena:="P" 
private cVpRab:="N"
if IsPlanika()
	private cPlVrsta:=SPACE(1)
	private cK9:=SPACE(3)
	private cGrupeK1:=SPACE(45)
	private cPrDatOd:="N"
endif
private PREDOVA2:= 62

O_SIFK
O_SIFV
O_ROBA

cLegenda:="D"

O_PARAMS
private cSection:="F"
private cHistory:=" "
private aHistory:={}

Params1()
RPar("c1",@cIdKPovrata)
RPar("c2",@qqKonto)
RPar("c4",@cCijena)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
RPar("d3",@cVpRab)
RPar("d4",@cPrDatOd)

cLegenda:="D"
cKolDN:="N"

Box(, 17, 75)
 set cursor on
 cNObjekat:=space(20)
 cKartica:="D"
 do while .t.
  @ m_x+1,m_y+2 SAY "Konta prodavnice:" GET qqKonto pict "@!S50"
  @ m_x+3,m_y+2 SAY "tekuci promet je period:" GET dDatOd
  @ m_x+3,col()+2 SAY "do" GET dDatDo
  @ m_x+4,m_y+2 SAY "Kriterij za robu :" GET qqRoba pict "@!S50"
  @ m_x+6,m_y+2 SAY "Magacin u koji se vrsi povrat rekl. robe:" GET cIdKPovrata pict "@!"
  @ m_x+8,m_y+2 SAY "Prikaz kolicina:" GET cKolDN pict "@!" valid cKolDN $"DN"
  @ m_x+9, m_y+2 SAY "Cijena (P-prodajna,N-nabavna):" GET cCijena pict "@!" valid cCijena $"PN"
  @ m_x+10, m_y+2 SAY "VP sa uracunatim rabatom (D/N)?" GET cVpRab pict "@!" valid cVpRab $ "DN"
  @ m_x+11, m_y+2 SAY "Prodaja pocinje od 'Datum od' (D/N)?" GET cPrDatOd pict "@!" valid cPrDatOd $ "DN"
  read
  nKorekcija:= 12/(month(dDatDo)-month(dDatOd)+1)
  @ m_x+12,m_y+2 SAY "Korekcija (12/broj radnih mjeseci):" GET nKorekcija pict "999.99"
  @ m_x+13,m_y+2 SAY "Ostampati legendu za kolone " GET cLegenda PICT "@!" VALID cLegenda $ "DN"  
  if IsPlanika()
  	@ m_x+14,m_y+2 SAY "Uslov po pl.vrsta " GET cPlVrsta PICT "@!"  
  	@ m_x+15,m_y+2 SAY "Izdvoji grupe: " GET cGrupeK1  
  	@ m_x+16,m_y+2 SAY "(npr. 0001;0006;0019;)"  
  	@ m_x+17,m_y+2 SAY "Uslov po K9 " GET cK9 PICT "@!"  
  endif
  READ
  ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"pkonto")
  aUsl2:=Parsiraj(qqKonto,"mkonto")
  aUslR:=Parsiraj(qqRoba,"IdRoba")
  if aUsl1<>NIL .and. aUslR<>NIL
  	exit
  endif
 enddo
BoxC()
 
if Params2()
  WPar("c1",cidKPovrata)
  WPar("c2",qqKonto)
  WPar("c4",cCijena)
  WPar("d1",dDatOd)
  WPar("d2",dDatDo)
  WPar("d3",cVpRab)
  WPar("d4",cPrDatOd)
endif
SELECT params
use
 
private fSMark:=.f.
if Right(trim(qqRoba),1)="*"
	fSMark:=.t.
endif

CreTblRek2()

O_REKAP2
O_REKA22
O_KONCIJ
O_ROBA
O_KONTO
O_TARIFA
O_KALK
O_K1
O_OBJEKTI

lVpRabat := .f.
if cVpRab == "D"
	lVpRabat := .t.
endif
lPrDatumOd := .f.
if cPrDatOd == "D"
	lPrDatumOd := .t.
endif

GenRekap2(.t., cCijena, lPrDatumOd, lVpRabat, fSMark )

// setuj liniju za izvjestaj
aLineArgs:={}
AADD(aLineArgs, {25, "GRUPACIJA", ""})
AADD(aLineArgs, {LEN(PicDem), "POCETNA", "ZALIHA"})
AADD(aLineArgs, {LEN(PicDem), "NABAVKA", "MAGACIN"})
AADD(aLineArgs, {LEN(PicDem), "ZADUZENJE", "PROD."})
if cCijena == "P"
	AADD(aLineArgs, {LEN(PicDem), "MALOPROD.", "RUC"})
endif
AADD(aLineArgs, {LEN(PicDem), "KUMULAT.", "PRODAJA"})
if cCijena == "P"
	AADD(aLineArgs, {LEN(PicDem), "OSTVARENI", "RUC"})
endif
AADD(aLineArgs, {LEN(PicDem), "ZALIHA", "REK.ROBE"})
AADD(aLineArgs, {LEN(PicDem), "ZALIHA", "NA DAN"})
if cCijena == "P"
 	AADD(aLineArgs, {LEN(PicPSDEM), "+POVECANJE", "-SNIZENJE"})
endif
AADD(aLineArgs, {LEN(PicDem), "PROSJECNA", "ZALIHA"})
AADD(aLineArgs, {LEN(PicDem), "GOD.KEOF", "OBRTA"})

private m := SetRptLineAndText(aLineArgs, 0)
private cZText1 := SetRptLineAndText(aLineArgs, 1)
private cZText2 := SetRptLineAndText(aLineArgs, 2)

SELECT reka22
set order to 1

go top

gaZagFix:={9,4}
start print cret
?

if gPrinter="R"
   PREDOVA2=62
   ?? "#%PORTR#"
endif


nStr:=0
ZagOPomF()
nCol1:=10

SELECT reka22

nRekaRecCount=reccount()

GO TOP

nT1:=0
nT2:=0
nT3:=0
nT3R:=0
nT4R:=0
nT4:=0
nT5:=0
nT6:=0
nT7:=0
nK1:=0
nK2:=0
nK3:=0
nK3R:=0
nK4R:=0
nK4:=0
nK5:=0
nK6:=0
nT2a:=0
nK2a:=0
nT2b:=0
lIzdvojiGrupe:=.f.

do while !eof()
   cG1:=g1   
   if (!EMPTY(cGrupeK1) .and. AT(cG1, cGrupeK1)<>0)
   	skip
	loop
   endif
   
   if prow()>PREDOVA2
     FF 
     ZagOPomF()
   endif
   
   ? cG1
   SELECT k1
   hseek cG1
   SELECT reka22
   @ prow(),pcol()+1 SAY k1->naz
   nCol1:=pcol()+1
   @ prow(),pcol()+1 SAY zalihaf  pict picdem
   if cCijena=="P"
     @ prow(),pcol()+1 SAY nabavf   pict picdem  
     @ prow(),pcol()+1 SAY pnabavf  pict picdem
     @ prow(),pcol()+1 SAY omprucf  pict picdem
   else
     @ prow(),pcol()+1 SAY nabavf   pict picdem
     @ prow(),pcol()+1 SAY pnabavf  pict picdem
   endif
   @ prow(),pcol()+1 SAY prodkumf  pict picdem
   if cCijena=="P"
     @ prow(),pcol()+1 SAY orucf     pict picdem
   endif
   @ prow(),pcol()+1 SAY stanjrf  pict picdem
   @ prow(),pcol()+1 SAY stanjef  pict picdem
   if cCijena=="P"
	// povisenje
	@ prow(),pcol()+1 SAY povecanje-snizenje  pict PicPSDEM
   endif
   
   //  prosjecna zaliha  
   @ prow(),pcol()+1 SAY proszalf pict picdem 

   // koef obrta na dan
   @ prow(),pcol()+1 SAY KOBrDan*nKorekcija pict picdem

   if ckolDN=="D"
    
     if prow()>PREDOVA2
       FF
       ZagOPomF()
     endif
   
     @ prow()+1,nCol1 SAY zalihak pict strtran(picdem,".","9")
     if cCijena=="P"
       @ prow(),pcol()+1 SAY nabavk  pict strtran(picdem,".","9")
       @ prow(),pcol()+1 SAY pnabavk  pict strtran(picdem,".","9")
       @ prow(),pcol()+1 SAY 0  pict strtran(picdem,".","9")
     else
       @ prow(),pcol()+1 SAY nabavk  pict strtran(picdem,".","9")
       @ prow(),pcol()+1 SAY pnabavk  pict strtran(picdem,".","9")
     endif
     @ prow(),pcol()+1 SAY prodkumk  pict strtran(picdem,".","9")
     if cCijena=="P"
       @ prow(),pcol()+1 SAY 0     pict strtran(picdem,".","9")
     endif
     @ prow(),pcol()+1 SAY stanjrk  pict strtran(picdem,".","9")
     @ prow(),pcol()+1 SAY stanjek  pict strtran(picdem,".","9")
     if cCijena=="P"
       @ prow(),pcol()+1 SAY 0  pict strtran(PicPSDEM,".","9")  // povisenje
     endif
     @ prow(),pcol()+1 SAY proszalk pict strtran(picdem,".","9")  //  prosjeŸna zaliha
     IF proszalk>0
       @ prow(),pcol()+1 SAY prodkumk/proszalk*nKorekcija pict picdem  // koef.kol.obrta
     ELSE
       if nRekaRecCount==1 // jedini u grupi
		@ prow(),pcol()+1 SAY 0 pict picdem  // koef.kol.obrta
	else
		@ prow(),pcol()+1 SAY PADC("?",LEN(picdem))  // koef.kol.obrta
     	endif
     ENDIF
     ?
   endif

   nT1+=zalihaf

   nT2+=nabavf
   nT2a+=pnabavf
   nT2b+=omprucf

   nT3+=prodkumf
   nT3R+=orucf
   nT4R+=stanjrf
   nT4+=stanjef
   nT5+=povecanje-snizenje
   nT6+=ProsZalf

   nK1+=zalihak
   nK2+=nabavk
   nK2a+=pnabavk
   nK3+=prodkumk
   nK3R+=0
   nK4R+=stanjrk
   nK4+=stanjek
   nK5+=0
   nK6+=ProsZalk
   skip

enddo

if prow()>(PREDOVA2-5)
     FF
     ZagOPomF()
endif

? m
? "UKUPNO"

// nije sigurno da ce proci kroz gornji if
// postaviti ispravno poravananje
nCol1:=26

@ PROW(),nCol1 SAY  nT1 pict picdem
@ PROW(),pcol()+1 SAY  nT2 pict picdem
@ PROW(),pcol()+1 SAY  nT2a pict picdem
if cCijena=="P"
  @ prow(),pcol()+1 SAY nT2b  pict strtran(picdem,".","9")
endif
@ PROW(),pcol()+1 SAY  nT3 pict picdem
if cCijena=="P"
  @ PROW(),pcol()+1 SAY  nT3R pict picdem
endif
@ PROW(),pcol()+1 SAY  nT4R pict picdem
@ PROW(),pcol()+1 SAY  nT4 pict picdem
if cCijena=="P"
  @ PROW(),pcol()+1 SAY  nT5 pict PicPSDEM // povecanje/snizenje
endif
@ PROW(),pcol()+1 SAY  nT6 pict picdem

nOpseg:=int((dDatDo-dDatOd+2)/30)

IF !( nT6==0 )
 // nT7:=nT3/nT6*12/nOpseg   // prodaja/przaliha * 12
 nT7:=nT3/nT6 * nKorekcija
 // t3 - kumulativna prodaja / t6 prosjecne zaliha
 @ PROW(),pcol()+1 SAY  nT7 pict picdem
ENDIF

? "KOLIC "
@ PROW(),nCol1 SAY  nK1 pict strtran(picdem,".","9")
@ PROW(),pcol()+1 SAY  nK2 pict strtran(picdem,".","9")
@ PROW(),pcol()+1 SAY  nK2a pict strtran(picdem,".","9")
if cCijena=="P"
  @ PROW(),pcol()+1 SAY  0 pict strtran(picdem,".","9")
endif
@ PROW(),pcol()+1 SAY  nK3 pict strtran(picdem,".","9")
if cCijena=="P"
  @ PROW(),pcol()+1 SAY  nK3R pict strtran(picdem,".","9")
endif
@ PROW(),pcol()+1 SAY  nK4R pict strtran(picdem,".","9")
@ PROW(),pcol()+1 SAY  nK4 pict strtran(picdem,".","9")
if cCijena=="P"
  @ PROW(),pcol()+1 SAY  nK5 pict strtran(PicPSDEM,".","9")
endif
@ PROW(),pcol()+1 SAY  nK6 pict strtran(picdem,".","9")
IF nK6>0
	@ prow(),pcol()+1 SAY nK3/nK6*nKorekcija pict picdem  // koef.kol.obrta
ELSE
       if nRekaRecCount==1 // jedini u grupi
		@ prow(),pcol()+1 SAY 0 pict picdem  // koef.kol.obrta
	else
		@ prow(),pcol()+1 SAY PADC("?",LEN(picdem))  // koef.kol.obrta
     	endif
ENDIF

? m
?
if !EMPTY(cGrupeK1)
	? "IZDVOJENE GRUPE:"
	? m
	nZalihaF:=nNabavF:=nPNabavF:=nOmPrucF:=nProdKumF:=nORucF:=nStanjeRF:=nStanjeF:=nPovSni:=nProsZalF:=nKoBrDan:=nZalihaK:=nNabavK:=nPNabavK:=nProdKumK:=nStanjeRK:=nStanjeK:=nProsZalK:=0
	select reka22
	go top
	do while !EOF()
		cGK1:=g1
		if AT(cGK1, cGrupeK1)<>0
			? cGK1
   			select k1
   			hseek cGK1
   			select reka22
   			@ prow(),pcol()+1 SAY k1->naz
   			nCol:=pcol()+1
			@ prow(),pcol()+1 SAY zalihaf  pict picdem
			nZalihaF+=zalihaf
   			nZalihaK+=zalihak
			if cCijena=="P"
     				@ prow(),pcol()+1 SAY nabavf   pict picdem  
     				@ prow(),pcol()+1 SAY pnabavf  pict picdem
     				@ prow(),pcol()+1 SAY omprucf  pict picdem
   			else
     				@ prow(),pcol()+1 SAY nabavf   pict picdem
     				@ prow(),pcol()+1 SAY pnabavf  pict picdem
   			endif
			nNabavF+=nabavf
			nPNabavF+=pnabavf
			nOmPrucF+=omprucf
			nNabavK+=nabavk
			nPNabavK+=pnabavk
   			@ prow(),pcol()+1 SAY prodkumf  pict picdem
			nProdKumF+=prodkumf
   			nProdKumK+=prodkumk
			if cCijena=="P"
     				@ prow(),pcol()+1 SAY orucf     pict picdem
				nORucF+=orucf
   			endif
   			@ prow(),pcol()+1 SAY stanjrf  pict picdem
   			@ prow(),pcol()+1 SAY stanjef  pict picdem
   			nStanjeRF+=stanjrf
			nStanjeRK+=stanjrk
			nStanjeF+=stanjef
			nStanjeK+=stanjek
			if cCijena=="P"
				@ prow(),pcol()+1 SAY povecanje-snizenje  pict PicPSDEM
   				nPovSni+=povecanje-snizenje
			endif
   			@ prow(),pcol()+1 SAY proszalf pict picdem 
   			@ prow(),pcol()+1 SAY KOBrDan*nKorekcija pict picdem
			nProsZalF+=proszalf
			nProsZalK+=proszalk
			nKoBrDan+=kobrdan*nKorekcija
			skip
		else
			skip
			loop
		endif
	enddo
	? m
	? "UKUPNO"
	@ PROW(),nCol1 SAY nZalihaF pict picdem
	@ PROW(),pcol()+1 SAY nNabavF pict picdem
	@ PROW(),pcol()+1 SAY nPNabavF pict picdem
	if cCijena=="P"
  		@ prow(),pcol()+1 SAY nOmPrucF pict strtran(picdem,".","9")
	endif
	@ PROW(),pcol()+1 SAY nProdKumF pict picdem
	if cCijena=="P"
  		@ PROW(),pcol()+1 SAY nORucF pict picdem
	endif
	@ PROW(),pcol()+1 SAY nStanjeRF pict picdem
	@ PROW(),pcol()+1 SAY nStanjeF pict picdem
	if cCijena=="P"
  		@ PROW(),pcol()+1 SAY nPovSni pict PicPSDEM
	endif
	@ PROW(),pcol()+1 SAY nProsZalF pict picdem
	nOpseg:=int((dDatDo-dDatOd+2)/30)
	IF !( nT6==0 )
 		nT7:=nT3/nT6 * nKorekcija
 		@ PROW(),pcol()+1 SAY nKoBrDan pict picdem
	ENDIF
	? "KOLIC"
	@ PROW(),nCol1 SAY nZalihaK pict StrTran(picdem,".","9")
	@ PROW(),pcol()+1 SAY nNabavK pict StrTran(picdem,".","9")
	@ PROW(),pcol()+1 SAY nPNabavK pict StrTran(picdem,".","9")
	if cCijena=="P"
		@ PROW(),pcol()+1 SAY 0 pict picdem
	endif
	@ PROW(),pcol()+1 SAY nProdKumK pict StrTran(picdem,".","9")
	if cCijena=="P"
		@ PROW(),pcol()+1 SAY 0 pict picdem	
	endif
	@ PROW(),pcol()+1 SAY nStanjeRK pict StrTran(picdem,".","9")	
	@ PROW(),pcol()+1 SAY nStanjeK pict StrTran(picdem,".","9")
	if cCijena=="P"
		@ PROW(),pcol()+1 SAY 0 pict PicPSDEM
	endif
	@ PROW(),pcol()+1 SAY nProsZalK pict StrTran(picdem,".","9")
	if nProsZalK>0
		@ PROW(),pcol()+1 SAY nProdKumK/nProsZalK*nKorekcija pict picdem
	else
  		@ prow(),pcol()+1 SAY PADC("?",LEN(picdem))  // koef.kol.obrta
	endif
	? m
	?
	?
	? "UKUPNO + UKUPNO IZDVOJENO"
	? m
	? "UKUPNO"
	@ PROW(),nCol1 SAY  nT1+nZalihaF pict picdem
	@ PROW(),pcol()+1 SAY  nT2+nNabavF pict picdem
	@ PROW(),pcol()+1 SAY  nT2a+nPNabavF pict picdem
	if cCijena=="P"
  		@ prow(),pcol()+1 SAY nT2b+nOmPrucF pict strtran(picdem,".","9")
	endif
	@ PROW(),pcol()+1 SAY  nT3+nProdKumF pict picdem
	if cCijena=="P"
  		@ PROW(),pcol()+1 SAY nT3R+nORucF pict picdem
	endif
	@ PROW(),pcol()+1 SAY  nT4R+nStanjeRF pict picdem
	@ PROW(),pcol()+1 SAY  nT4+nStanjeF pict picdem
	if cCijena=="P"
  		@ PROW(),pcol()+1 SAY  nT5+nPovSni pict PicPSDEM
	endif
	@ PROW(),pcol()+1 SAY  nT6+nProsZalF pict picdem
	nOpseg:=int((dDatDo-dDatOd+2)/30)
	IF !( nT6==0 )
 		nT7:=nT3/nT6 * nKorekcija
 		@ PROW(),pcol()+1 SAY nT7+nKoBrDan pict picdem
	ENDIF
	? "KOLIC"
	@ PROW(),nCol1 SAY  nK1+nZalihaK pict StrTran(picdem,".","9")
	@ PROW(),pcol()+1 SAY  nK2+nNabavK pict StrTran(picdem, ".", "9")
	@ PROW(),pcol()+1 SAY  nK2a+nPNabavK pict StrTran(picdem, ".", "9")
	if cCijena=="P"
		@ PROW(),pcol()+1 SAY 0 pict picdem
	endif
	@ PROW(),pcol()+1 SAY  nK3+nProdKumK pict StrTran(picdem,".","9")
	if cCijena=="P"
		@ PROW(),pcol()+1 SAY 0 pict picdem
	endif
	@ PROW(),pcol()+1 SAY  nK4R+nStanjeRK pict StrTran(picdem,".","9")
	@ PROW(),pcol()+1 SAY  nK4+nStanjeK pict StrTran(picdem,".","9")
	if cCijena=="P"
		@ PROW(),pcol()+1 SAY 0 pict PicPSDEM
	endif
	@ PROW(),pcol()+1 SAY  nK6+nProsZalK pict StrTran(picdem,".","9")	
	if (nProsZalK>0)
        	if nRekaRecCount==1 // jedini u grupi
  			@ prow(),pcol()+1 SAY (nProdKumK/nProsZalK*nKorekcija) pict picdem
		else
			if (nK6>0)
  				@ prow(),pcol()+1 SAY (nK3/nK6*nKorekcija)+(nProdKumK/nProsZalK*nKorekcija) pict picdem
			else
				@ prow(),pcol()+1 SAY PADC("?",LEN(picdem))  // koef.kol.obrta
			endif
     		endif
	else
  		@ prow(),pcol()+1 SAY PADC("?",LEN(picdem))  // koef.kol.obrta
	endif
	? m
	?
endif


if (cLegenda=="D")
	if prow()>(PREDOVA2-12)
	     FF
	     ZagOPomF()
	endif
	Legenda()
endif

end print

#ifdef CAX
  close all
#endif
closeret
*}

static function Legenda()
*{

? "Legenda:" 
? "( 1) Pocetna zaliha: sadrzi stanje zalihe na Datum-od i to "
? "     SVI magacini i SVE prodavnice"
? "( 2) Nabavka magacin: sumira SAMO ulaze od dobavljaca"
? "( 3) Zaduz. prodavnica: sumira sva zaduzenja u prodavnice"
? "( 4) Maloprodajni RUC - ruc koji je ukalkulisan u prodavnice pri zaduzenju"
? "( 5) Kumulativna prodaja - ostvarena prodaja u MAG + PROD"
? "( 6) Zaliha reklamirane robe - stanje zaliha po vpc na skladistu reklam.r."
? "( 7) Zaliha na dan - ukupno stanje zaliha - SVI magacini i SVE prod."
? "( 8) povecanje, snizenje - suma povecanja i snizenja cijena"
? "( 9) prosjecna zaliha u toku zadatog perioda"
? "(10) Godisnji koeficijent obrta = (5)/(9)*zadana korekcija"

FF
return
*}


/*! \fn ZagOPoMF()
 *  \brief Zaglavlje obrta 
 */
 
function ZagOPoMF()
*{
P_10CPI
//if gPrinter<>"R"
//	B_ON
//endif
?? gTS+":", gNFirma, space(40), "Strana:"+str(++nStr,3)
?
?  "Pregled FINANSIJSKOG OBRTA za period:", dDatOd, "-", dDAtDo
IspisNaDan(10)
?
if (cCijena=="P")
	?  "Obracun prometa utvrdjen po cijenama sa ukalkulisanom marzom BEZ POREZA"
else
	?  "Obracun prometa utvrdjen po nabavnim cijenama"
endif
?
IF (qqRoba==nil)
	qqRoba:=""
ENDIF
? "Kriterij za Objekat:",trim(qqKonto), "Robu:",TRIM(qqRoba)
?
if cCijena=="P"
  P_COND2
else
  P_COND
endif
? m

? cZText1
? cZText2

/*
if (cCijena=="P")
 ? "    GRUPACIJA               POCETNA      NABAVKA        ZADUZ.          MALOPROD.          KUMULAT.       OSTVARENI          ZALIHA           ZALIHA         +POVECANJE       PROSJECNA      GOD. KOEF."
 ? "                            ZALIHA       MAGACIN      PRODAVNICE           RUC             PRODAJA          RUC              REKL.R           NA DAN         -SNIZENJE          ZALIHA         OBRTA  "
else
 ? "    GRUPACIJA               POCETNA      NABAVKA        ZADUZ.          KUMULAT.          ZALIHA          ZALIHA          PROSJECNA      GOD. KOEF."
 ? "                            ZALIHA       MAGACIN      PRODAVNICA        PRODAJA           REKL.R          NA DAN            ZALIHA         OBRTA  "
endif
*/

? m
return
*}

