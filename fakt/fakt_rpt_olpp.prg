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

function FaktStOLPP()
// sada se koristi StOLPDV()
StOLPDV()
return

// stampa obracunskog lista PDV-a
static function StOLPDV()
local nUkPDV:=0
local nTotPDV:=0
local ii:=0
local InPicDem:=picdem
local GetList:={}
local InPicKol:=pickol

private cRegion:=GetRegion()

O_PARTN
O_ROBA
O_TARIFA
O_FAKT_PRIPR

gOstr    := "D"
gnRedova := gPStranica+64
picdem   := "99999999.99"
pickol   := SUBSTR(pickol,2)

select fakt_pripr

IF glCij13Mpc
	cPmp:="9"
ELSEIF EMPTY(g13dcij) .and. gVar13!="2"
	Box(,1,50)
  		cPmp:="9"
  		@ m_x+1,m_y+2 SAY "Prikaz MPC ( 1/2/3/4/5/6/9 iz fakt-a) " GET cPMP valid cpmp $ "1234569"
  		read
 	BoxC()
ELSE
	cPMP:=g13dcij
ENDIF

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

cIdFirma := IDFIRMA
cIdVd    := IDTIPDOK
cBrDok   := BRDOK

m:="ÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ"

nC1:=10
nC2:=25
nC3:=40
nC4:=0
nC5:=0

START PRINT RET

nU1:=nU2:=nU3:=0

ZOlPDV()

PRIVATE nColR:=10

DO WHILE !EOF() .and. cIdfirma+cIdVd+cBrDok==IDFIRMA+IDTIPDOK+BRDOK

	NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na fakt_pripr->IdRoba

   	aPorezi:={}
   	select fakt_pripr
   	cTarifa:=TarifaR(cRegion,ROBA->id,@aPorezi)

	IF gVar13!="2"
     		if cPMP=="2"
      			nMPCSAPP:=roba->mpc2
     		elseif cPMP=="3"
      			nMPCSAPP:=roba->mpc3
     		elseif cPMP=="4"
      			nMPCSAPP:=roba->mpc4
     		elseif cPMP=="5"
      			nMPCSAPP:=roba->mpc5
     		elseif cPMP=="6"
      			nMPCSAPP:=roba->mpc6
     		elseif cpmp=="1"
      			nMPCSAPP:=roba->mpc
     		else
      			nMPCSAPP:=fakt_pripr->cijena
     		endif
   	ELSE
     		nMPCSaPP:=cijena
   	ENDIF

   	if kolicina==0   
     		nMPC1 := MpcBezPor( iznos , aPorezi )
     		nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
   	else
     		nMPC1 := MpcBezPor( nMPCSaPP , aPorezi )
     		nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
   	endif

   	if prow()>gnRedova-2 .and. gOstr=="D"
   		FF
		ZOlPDV()
   	endif

   	// 1 red
   	? rbr
   	nColR:=pcol()+1
   	// 2 red
   	aRoba:=SjeciStr(roba->naz,20)
   	@ prow(),pcol()+1 SAY aRoba[1]
   	// 3 red
   	@ prow(),pcol()+1 SAY roba->jmj

   	nPom:=at("/",ctarifa)
   	IF nPom>0
    		cT1:=padr( left(ctarifa,npom-1),6)
   	ELSE
    		cT1:=cTarifa
   	ENDIF

   	// 4 red
   	@ prow(),pcol()+1 say kolicina pict pickol
   
   	// 5 red // mpc bez pdv pojedinacno
   	@ prow(),pcol()+1 say nMPC1 pict "99999999.99"
   	nC1:=pcol()+1

   	// 6 red // mpc bez pdv ukupno
   	@ prow(),pcol()+1 say nMPC1*kolicina pict picdem
   
   	// 7 red // TB
   	@ prow(),pcol()+1 say cT1

   	// 8 red // TB %
   	@ prow(),pcol()+1 say aPorezi[POR_PPP] pict "99.9"
	?? "%"
   	nC4:=pcol()+1

   	// 9 red  // PDV ukupno
   	@ prow(),pcol()+1 say (nUkPDV:=(nMPC2-nMPC1)*kolicina) pict "999999.99"
   	nTotPDV+=nUkPDV

   	// 10 red // MPC sa PDV pojedinacno
   	@ prow(),pcol()+1 say nMPC2 pict "9999999.99"
   	nC2:=pcol()+1

   	// 11 red // MPC sa PDV ukupno
   	@ prow(),pcol()+1 say nMPC2*kolicina pict picdem
   	

	if kolicina==0     // nivelacija:TNAM
    		nU1+=nMpc1
		nU2+=nMpc2
   	else
     		nU1+=nMpc1*kolicina
		nU2+=nMpc2*kolicina
   	endif

	// ostatak robe naziva ako postoji
   	for ii=2 to len(aRoba)
    		@ prow()+1,nColR SAY aRoba[ii]
   	next

   	skip 1

ENDDO

if prow()>gnRedova-4 .and. gOstr=="D"
	FF
	ZOlPDV()
endif

? m
? "Ukupno :"
@ prow(),nC1   say    nU1  pict picdem
@ prow(),nC4   say nTotPDV pict "999999.99"
@ prow(),nC2   say    nU2  pict picdem
? STRTRAN(m," ","Ä")
?

FF

END PRINT

picdem:=InPicDem
pickol:=InPicKol

return
*}

// ----------------------------------
// zaglavlje obracunskog lista 
// ----------------------------------
static function ZOLPDV()
LOCAL cNaslov:=StrKZN("OBRA^UNSKI LIST PDV-A","7",gKodnaS)
local cPom1
local cPom2
local c
fakt_zagl_firma()
@ prow()+1,35 SAY cNaslov
?
select partn
hseek fakt_pripr->idpartner
select fakt_pripr
@ prow()+1,20 SAY "Po dokumentu: "+idtipdok+"   "
?? StrKZN("Sjedi{te:","7",gKodnaS)
@ prow()+1,33 SAY "Broj: "; ?? brdok,"od:",SrediDat(datdok)

P_COND2

? StrKZN("ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿","7", gKodnaS)

? StrKZN("³  ³                    ³   ³          ³   Prodajna cijena     ³         PDV          ³   Prodajna cijena    ³","7",gKodnaS)
c:="³R.³       Naziv        ³jed³ koli~ina ³   bez PDV-a           ³                      ³   sa PDV-om          ³"

? StrKZN(c,"7",gKodnaS)

? StrKZN("³br³                    ³mj.³          ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ´","7",gKodnaS)
? StrKZN("³  ³                    ³   ³          ³ Pojedin.  ³   Ukupna  ³TB    ³Stopa³ Iznos   ³ Pojedin. ³  Ukupna   ³","7",gKodnaS)
? StrKZN("ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÙ","7",gKodnaS)

return

