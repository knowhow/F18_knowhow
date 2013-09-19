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

// obracunski list poreza na promet
function KalkStOLPP()
// => stolpdv()
StOLPDV()
return


// obracunski list poreza na dodanu vrijednost
static function StOLPDV()
local ik
local cPrviKTO
local nUkPDV:=0
local nTotPDV:=0
local ii:=0
local nArr

gOstr := "D"
gnRedova := gPStranica + 64
picdem := "99999999.99"

SELECT kalk_pripr

cIdFirma := IDFIRMA
cIdVd    := IDVD
cBrDok   := BRDOK

m:="ÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ"

nC1:=10
nC2:=25
nC3:=40
nC4:=0
nC5:=0

// radi 80-ke prodji 2 puta
for ik:=1 to 2

    o_kalk_edit()

	START PRINT RET
	?

	nU1:=nU2:=nU3:=0

	if ik=2 

		// drugi konto
   		HSEEK cIdFirma+cIdVD+cBrDok
   		do while !eof()  .and. pkonto==cPrviKTO
     			skip
  		enddo
 	else
   		cPrviKTO := pkonto
 	endif
	
	ZOLPDV()
	
	private nColR := 10
	aRekPor := {}

	DO WHILE !EOF() .and. cIdfirma+cIdVd+cBrDok==IDFIRMA+IDVD+BRDOK
		if (pkonto==cPrviKTO  .and. ik=2) .or. (pkonto != cPrviKTO  .and. ik=1)
        		// ako se po drugi put nalazis u petlji i stavka je prvi konto
        		// onda preskoci
        		skip
			loop
   		endif
		
		SELECT ROBA
   		HSEEK kalk_pripr->IDROBA
   		SELECT kalk_pripr

   		aPorezi:={}
   		cTarifa:=Tarifa(kalk_pripr->pkonto, ROBA->id, @aPorezi)

   		nMpCSaPP := mpcsapp

   		if .f. 
			// kolicina==0   // nivelacija:TNAM
     			nMPC1 := MpcBezPor( iznos , aPorezi )
     			nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
   		else
			nMPC1 := MpcBezPor( nMPCSaPP , aPorezi )
     			nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )
   		endif
		if prow() > gnRedova - 2 .and. gOstr=="D"
   			FF
			ZOLPDV()
   		endif
		
                // bilo:  EJECTNA0
   		
		// 1. Redni broj
		? rbr
   		
		nColR:=pcol()+1
		aRoba:=SjeciStr(roba->naz,20)
   		
		// 2. Naziv robe
		@ prow(),pcol()+1 SAY aRoba[1]
   		
		// 3. Jedinica mjere
		@ prow(),pcol()+1 SAY roba->jmj
		
		nPom:=at("/",idTarifa)
   		IF nPom>0
    			cT1:=PadR(LEFT(cTarifa, nPom-1), 6)
   		ELSE
    			cT1:=cTarifa
   		ENDIF
		
		// 4. Kolicina
		@ prow(),pcol()+1 say kolicina pict pickol
		
		// 5. MPC Bez PDV - pojedina
		@ prow(),pcol()+1 say nMPC1 pict "99999999.99"
   		nC1:=pcol()+1
		
		// 6. MPC Bez PDV - ukupna
		@ prow(),pcol()+1 say nMPC1 * kolicina pict picdem
		
		// 7. PDV - tarifni broj
		@ prow(),pcol()+1 say cT1
		
		// 8. PDV - stopa
		@ prow(),pcol()+1 say tarifa->opp pict "99.9"
		?? "%"
   		nC4:=pcol()+1
		
		// 9. PDV - iznos
		@ prow(),pcol()+1 say (nUkPDV:=(nMPC2-nMPC1)*kolicina) pict "999999.99"
   		nTotPDV += nUkPDV
		
		// 10. MPC Sa PDV - pojedina
		@ prow(),pcol()+1 say nMPC2 pict "9999999.99"
   		nC2:=pcol()+1
		
		// 11. MPC Sa PDV - ukupna
		@ prow(),pcol()+1 say nMPC2*kolicina pict picdem
  	

		if .f. // kolicina==0     // nivelacija:TNAM
			nU1+=nMpc1
        		nU2+=nMpc2
        		//nU3+=iznos
		else
			nU1+=nMpc1*kolicina
        		nU2+=nMpc2*kolicina
        		//nU3+=nMPCsaPP*kolicina
		endif
		
		//   aRekPor       TB,  mpcbezpdv     ,  pdv   ,  mpcsapdv 
   		AADD(aRekPor, { cT1, nMpc1*kolicina, (nMpc2-nMpc1)*kolicina, nMpc2*kolicina})
		for ii=2 to len(aRoba)
    			@ prow()+1,nColR SAY aRoba[ii]
   		next
		skip 1
	ENDDO
	
	if prow() > gnRedova-4 .and. gOstr=="D"
		skip -1
		FF
		ZOLPDV()
		skip 1
	endif
	
        // bilo:  EJECTNA0
	? m
 	? "Ukupno :"
 	@ prow(),nC1 SAY nU1 pict picdem 
	// mpc bez pdv
 	@ prow(),nC4 SAY nTotPDV pict "999999.99" 
	// total pdv
 	@ prow(),nC2 SAY nU2 pict picdem 
	// mpc sa pdv
 	? STRTRAN(m," ","Ä")
 	?
	
	// rekap. tarifa
	
	? "-------------------------------------------------"
	? "Rekapitulacija tarifa:"
	? "-------------------------------------------------"
	? "TB      PDV%         MPV         PDV     MPCSAPDV"
	? "-------------------------------------------------"
	
	nArr:=SELECT()
	select tarifa
	go top
	do while !EOF()
		nCount:=0
		nUkMPCBezPP:=0
		nUkPPP:=0
		nUkMPCSaPP:=0
		for i:=1 to LEN(aRekPor)
			if ALLTRIM(field->id)==ALLTRIM(aRekPor[i, 1])	
				++ nCount
				nUkMPCBezPP+=aRekPor[i, 2]
				nUkPPP+=aRekPor[i, 3]
				nUKMPCSaPP+=aRekPor[i, 4]
			endif
		next
		if nCount>0
			? field->id
			@ PRow(), PCol()+1 SAY ALLTRIM(STR(field->opp))+"%"
			@ PRow(), PCol()+1 SAY nUkMPCBezPP pict picdem
			@ PRow(), PCol()+1 SAY nUkPPP pict picdem
			@ PRow(), PCol()+1 SAY nUkMPCSaPP pict picdem
			skip
		else
			skip
		endif
	enddo
	
	select (nArr)
	
    FF
	END PRINT
	
    if cIdVd<>"80"    
		// ako nije 80-ka samo jednom prodji
		exit
	endif

next  

return


// zaglavlje izvjestaja stolpdv
static function ZOLPDV()
local cNaslov:=StrKZN("OBRA^UNSKI LIST PDV-A","7",gKodnaS),cPom1,cPom2,c

kalk_zagl_firma()

IspisNaDan(20)

@ prow()+1,35 SAY cNaslov
?
select partn
hseek kalk_pripr->idpartner
select kalk_pripr

@ prow()+1,20 SAY "Po dokumentu: "+idvd+"-"+brdok

?? StrKZN("Sjedi{te:", "7", gKodnaS)

@ prow()+1,33 SAY "Broj: "
?? brfaktp, "od:", SrediDat(datfaktp)

P_COND2

? StrKZN("ÚÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿","7",gKodnaS)

? StrKZN("³  ³                    ³   ³          ³   Prodajna cijena     ³         PDV          ³   Prodajna cijena    ³","7",gKodnaS)
c:="³R.³       Naziv        ³jed³ koli~ina ³   bez PDV-a           ³                      ³   sa PDV-om          ³"

? StrKZN(c,"7",gKodnaS)

? StrKZN("³br³                    ³mj.³          ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ´","7",gKodnaS)
? StrKZN("³  ³                    ³   ³          ³ Pojedin.  ³   Ukupna  ³TB    ³Stopa³ Iznos   ³ Pojedin. ³  Ukupna   ³","7",gKodnaS)
? StrKZN("ÀÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÙ","7",gKodnaS)

return


