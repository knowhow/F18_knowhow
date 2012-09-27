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

static cTblKontrola:=""
static aPorezi:={}
static __line
static __txt1
static __txt2
static __txt3

// lager lista prodavnice
function LLP()
parameters lPocStanje
// indikator gresaka
local lImaGresaka:=.f.  
local cKontrolnaTabela
local cPicKol := gPicKol
local cPicCDEm := gPicCDem
local cPicDem := gPicDem
local cSrKolNula := "0"
local _curr_user := "<>"
local cMpcIzSif := "N"

gPicCDEM:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDEM 
gPicDEM:= REPLICATE("9", VAL(gFPicDem)) + gPicDem
gPicKol :=REPLICATE("9", VAL(gFPicKol)) + gPicKol

cIdFirma:=gFirma
cIdKonto:=PadR("1320",gDuzKonto)
O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_PARTN

cKontrolnaTabela:="N"

if (lPocStanje==nil)
	lPocStanje:=.f.
else
   	lPocStanje:=.t.
   	O_KALK_PRIPR
   	cBrPSt:="00001   "
   	Box(,2,60)
     		@ m_x+1,m_y+2 SAY "Generacija poc. stanja  - broj dokumenta 80 -" GET cBrPSt
     		read
   	BoxC()
endif

cNula:="D"
cK9:=SPACE(3)
dDatOd := DATE()
dDatDo := DATE()
qqRoba:=SPACE(60)
qqTarifa:=SPACE(60)
qqidvd:=SPACE(60)
qqIdPartn:=SPACE(60)
private cPNab:="N"
private cNula:="D"
private cTU:="N"
private cSredCij:="N"
private cPrikazDob:="N"
private cPlVrsta:=SPACE(1)
private cPrikK2:="N"
private aPorezi

if IsDomZdr()
	private cKalkTip:=SPACE(1)
endif

Box(,18,68)

cGrupacija:=space(4)
cPredhStanje:="N"

if !lPocStanje

 cIdKonto := fetch_metric("kalk_lager_lista_prod_id_konto", _curr_user, cIdKonto )
 cPNab := fetch_metric("kalk_lager_lista_prod_po_nabavnoj", _curr_user, cPNab )
 cNula := fetch_metric("kalk_lager_lista_prod_prikaz_nula", _curr_user, cNula )
 dDatOd := fetch_metric("kalk_lager_lista_prod_datum_od", _curr_user, dDatOd )
 dDatDo := fetch_metric("kalk_lager_lista_prod_datum_do", _curr_user, dDatDo )

endif

do while .t.
	if gNW $ "DX"
   		@ m_x+1,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
 	else
  		@ m_x+1,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 	endif
 	@ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid P_Konto(@cIdKonto)
 	@ m_x+3,m_y+2 SAY "Artikli " GET qqRoba pict "@!S50"
 	@ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 	@ m_x+5,m_y+2 SAY "Partneri" GET qqIdPartn pict "@!S50"
 	@ m_x+6,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 	@ m_x+7,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 	@ m_x+7,col()+1 SAY "MPC iz sifrarnika D/N" GET cMpcIzSif valid cMpcIzSif $ "DN" pict "@!"
 	@ m_x+8,m_y+2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 	@ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
 	@ m_x+9,col()+2 SAY "do" GET dDatDo
	
	if lPocStanje
		@ m_x+11,m_y+2 SAY "sredi kol=0, nv<>0 (0/1/2)" GET cSrKolNula ;
			VALID cSrKolNula $ "012" PICT "@!"
 	endif

	@ m_x+12,m_y+2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU valid cTU $ "DN" pict "@!"
 	@ m_x+12, COL()+2 SAY " generisati kontrolnu tabelu ? " GET cKontrolnaTabela VALID cKontrolnaTabela $ "DN" PICT "@!"
 	@ m_x+13,m_y+2 SAY "Odabir grupacije (prazno-svi) GET" GET cGrupacija pict "@!"
 	@ m_x+14,m_y+2 SAY "Prikaz prethodnog stanja" GET cPredhStanje pict "@!" valid cPredhStanje $ "DN"
 
	if IsPlanika()
 		@ m_x+15,m_y+2 SAY "Prikaz dobavljaca (D/N) ?" GET cPrikazDob pict "@!" valid cPrikazDob $ "DN"
		@ m_x+16,m_y+2 SAY "Prikaz po K9 (uslov)" GET cK9 pict "@!"
		@ m_x+17,m_y+2 SAY "Prikaz po pl.vrsta (uslov)" GET cPlVrsta pict "@!"
		@ m_x+18,m_y+2 SAY "Prikazati K2 = 'X' (D/N)" GET cPrikK2 pict "@!" valid cPrikK2$"DN"
 	endif
	
	if IsVindija()	
		cGr := SPACE(10)
		cPSPDN := "N"
 		@ m_x+16,m_y+2 SAY "Grupa " GET cGr
 		@ m_x+17,m_y+2 SAY "Pregled samo prodaje (D/N) " GET cPSPDN VALID !Empty(cPSPDN) .and. cPSPDN$"DN"  pict "@!"
	endif
  
	read
 	ESC_BCR
 	private aUsl1 := Parsiraj(qqRoba,"IdRoba")
 	private aUsl2 := Parsiraj(qqTarifa,"IdTarifa")
 	private aUsl3 := Parsiraj(qqIDVD,"idvd")
	private aUsl4 := Parsiraj(qqIdPartn, "IdPartner")
 	if aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL 
   		exit
 	endif
	if aUsl4<>NIL
		exit
	endif
enddo
BoxC()

if !lPocStanje
 
 set_metric("kalk_lager_lista_prod_id_konto", _curr_user, cIdKonto )
 set_metric("kalk_lager_lista_prod_po_nabavnoj", _curr_user, cPNab )
 set_metric("kalk_lager_lista_prod_prikaz_nula", _curr_user, cNula )
 set_metric("kalk_lager_lista_prod_datum_od", _curr_user, dDatOd )
 set_metric("kalk_lager_lista_prod_datum_do", _curr_user, dDatDo )

endif

CLOSE ALL

if (cKontrolnaTabela=="D")
	CreTblKontrola()
endif

if lPocStanje
	O_KALK_PRIPR
endif
lPrikK2 := .f.
if cPrikK2 == "D"
	lPrikK2 := .t.
endif

O_SIFK
O_SIFV
O_ROBA
O_TARIFA
O_KONTO
O_PARTN
O_KONCIJ
O_KALKREP

private lSMark:=.f.
if right(trim(qqRoba),1)="*"
	lSMark:=.t.
endif

private cFilter:=".t."

if aUsl1<>".t."
  	cFilter += ".and." + aUsl1   // roba
endif
if aUsl2<>".t."
  	cFilter += ".and." + aUsl2   // tarifa
endif
if aUsl3<>".t."
  	cFilter += ".and." + aUsl3   // idvd
endif
if aUsl4<>".t."
	cFilter += ".and." + aUsl4   // partner
endif
// po tipu sredstva
if IsDomZdr() .and. !Empty(cKalkTip)
	cFilter+=".and. tip="+Cm2Str(cKalkTip)
endif

select KALK

set order to tag "4"

set filter to &cFilter
//"4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")

hseek cIdfirma+cIdkonto
EOF CRET

nLen:=1

m:="----- ---------- -------------------- ---"
nPom := LEN(gPicKol)
m+=" " + REPL("-", nPom)
m+=" " + REPL("-", nPom)
m+=" " + REPL("-", nPom)
nPom := LEN(gPicDem)
m+=" " + REPL("-", nPom)
m+=" " + REPL("-", nPom)
m+=" " + REPL("-", nPom)
m+=" " + REPL("-", nPom)

if cPredhstanje=="D"
	nPom := LEN(gPicKol) - 2
	m+=" " + REPL("-", nPom)
endif
if cSredCij=="D"
	nPom := LEN(gPicCDem)
	m+=" " + REPL("-", nLen)
endif

__line := m

start print cret
?
select konto
hseek cIdKonto
select KALK

private nTStrana:=0

private bZagl:={|| ZaglLLP()}

nTUlaz:=0
nTIzlaz:=0
nTPKol:=0
nTMpv := 0
nTMPVU:=0
nTMPVI:=0
nTNVU:=0
nTNVI:=0
// predhodna vrijednost
nTPMPV:=0
nTPNV:=0  
nTRabat:=0
nCol1:=50
nCol0:=50
nRbr:=0

Eval( bZagl )

do while !EOF() .and. cIdFirma + cIdKonto == field->idfirma + field->pkonto .and. IspitajPrekid()
	
    cIdRoba := field->Idroba
	
    if lSMark .and. SkLoNMark("ROBA",cIdroba)
   		skip
   		loop
	endif

	select roba
	hseek cIdRoba
	
	if IsVindija()
		if !EMPTY(cGr)
			if ALLTRIM(cGr) <> ALLTRIM(IzSifK("ROBA", "GR1", cIdRoba, .f.))
				select kalk
				skip
				loop
			endif
		endif
		
		if (cPSPDN == "D")
			select kalk
			if !(kalk->idvd $ "41#42#43") .and. !(kalk->pu_i == "5")
				skip
				loop
			endif
			select roba
		endif
	endif
	
	// uslov po K9
	if (IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9)
		select kalk
		skip
		loop
	endif

	// uslov po PL.VRSTA
	if (IsPlanika() .and. !EMPTY(cPlVrsta) .and. roba->vrsta <> cPlVrsta) 
		select kalk
		skip
		loop
	endif

	select KALK

	nPKol:=0
	nPNV:=0
	nPMPV:=0
	nUlaz:=0
	nIzlaz:=0
	nMPVU:=0
	nMPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0

	if cTU=="N" .and. roba->tip $ "TU"
		skip
		loop
	endif

	do while !EOF() .and. cIdfirma + cIdkonto + cIdroba == field->idFirma + field->pkonto + field->idroba .and. IspitajPrekid()
	    
        if lSMark .and. SkLoNMark("ROBA",cIdroba)
     		skip
     		loop
  		endif

  		if cPredhStanje=="D"
    		if field->datdok < dDatOd
     			if field->pu_i == "1"

       				SumirajKolicinu( field->kolicina, 0, @nPKol, 0, lPocStanje, lPrikK2)
       				nPMPV += field->mpcsapp * field->kolicina
       				nPNV += field->nc * (field->kolicina)

     			elseif field->pu_i=="5"
                    
                    aPorezi := {}        
                    Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
                    aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
                    nPor1 := aIPor[1]
                    VtPorezi()

       				SumirajKolicinu( -(field->kolicina), 0, @nPKol, 0, lPocStanje, lPrikK2)

                    // vrijednost sa popustom
       				//nPMPV -= ( field->mpc + nPor1 ) * field->kolicina

       				nPMPV -= field->mpcsapp * field->kolicina
       				nPNV -= field->nc * field->kolicina

     			elseif field->pu_i=="3"    
       				// nivelacija
       				nPMPV += field->mpcsapp * field->kolicina
     			elseif pu_i == "I"
       				SumirajKolicinu(-(field->gKolicin2), 0, @nPKol, 0, lPocStanje, lPrikK2)
       				nPMPV -= field->mpcsapp * field->gkolicin2
       				nPNV -= field->nc * field->gkolicin2
     			endif
    		endif
  		else
    		if field->datdok < dDatod .or. field->datdok > dDatdo
      			skip
      			loop
    		endif
  		endif 

  		if cTU=="N" .and. roba->tip $ "TU"
  			skip
			loop
  		endif

  		if !empty(cGrupacija)
    		if cGrupacija<>roba->k1
      			skip
      			loop
    		endif
  		endif

  		if field->DatDok >= dDatOd  
            // nisu predhodni podaci
  			if field->pu_i == "1"
    			SumirajKolicinu( field->kolicina, 0, @nUlaz, 0, lPocStanje, lPrikK2)
    			nCol1 := pcol()+1
    			nMPVU += field->mpcsapp * field->kolicina
    			nNVU += field->nc * ( field->kolicina )
  			elseif field->pu_i == "5"
                    
                aPorezi := {}        
                Tarifa( field->pkonto, field->idroba, @aPorezi, field->idtarifa )
                aIPor := RacPorezeMP( aPorezi, field->mpc, field->mpcsapp, field->nc )
                nPor1 := aIPor[1]
                VtPorezi()

    			if idvd $ "12#13"
     				SumirajKolicinu( -(field->kolicina), 0, @nUlaz, 0, lPocStanje, lPrikK2)
     				nMPVU -= field->mpcsapp * field->kolicina
     				nNVU -= field->nc * field->kolicina
    			else
     				SumirajKolicinu( 0, field->kolicina, 0, @nIzlaz, lPocStanje, lPrikK2)
     				// vrijednost sa popustom
                    //nMPVI += ( field->mpc + nPor1 ) * field->kolicina
     				nMPVI += field->mpcsapp * field->kolicina
     				nNVI += field->nc * field->kolicina
    			endif

  			elseif field->pu_i=="3"    
			    // nivelacija
    			nMPVU += field->mpcsapp * field->kolicina
  			elseif field->pu_i=="I"
    	        SumirajKolicinu(0, field->gkolicin2, 0, @nIzlaz, lPocStanje, lPrikK2)
    			nMPVI += field->mpcsapp * field->gkolicin2
    			nNVI += field->nc * field->gkolicin2
			endif
  		endif
		skip
	enddo
	
	// ne prikazuj stavke 0
	if cNula == "D" .or. ROUND( nMPVU - nMPVI + nPMPV, 2 ) <> 0 
		
        if PROW() > 61 + gPStranica
			FF
			EVAL(bZagl)
		endif
		
        select roba
		hseek cIdRoba
		
        select kalk
		aNaz := Sjecistr( roba->naz, 20 )

		? str(++nRbr,4)+".",cIdRoba

		nCr:=pcol()+1

		@ prow(),pcol()+1 SAY aNaz[1]
		@ prow(),pcol()+1 SAY roba->jmj

		if lPoNarudzbi .and. cPKN=="D"
  			@ prow(),pcol()+1 SAY cIdNar
		endif
		
		nCol0:=pCol()+1
		
		if cPredhStanje=="D"
 			@ prow(),pcol()+1 SAY nPKol pict gpickol
		endif
		
		@ prow(),pcol()+1 SAY nUlaz pict gpickol
		@ prow(),pcol()+1 SAY nIzlaz pict gpickol
		@ prow(),pcol()+1 SAY nUlaz-nIzlaz+nPkol pict gpickol
		
		if lPocStanje
  			
			select kalk_pripr
  			
			if round( nUlaz - nIzlaz, 4 ) <> 0 .and. cSrKolNula $ "01"
     				
				append blank
     				
				replace idFirma with cIdfirma
				replace idroba with cIdRoba
				replace idkonto with cIdKonto
				replace datdok with dDatDo+1
				replace idTarifa with Tarifa(cIdKonto, cIdRoba, @aPorezi)
				replace datfaktp with dDatDo+1
				replace kolicina with nulaz-nizlaz
				replace idvd with "80"
				replace brdok with cBRPST
				replace nc with (nNVU-nNVI+nPNV)/(nulaz-nizlaz+nPKol)
				replace mpcsapp with (nMPVU-nMPVI+nPMPV)/(nulaz-nizlaz+nPKol)
				replace TMarza2 with "A"
				
				if koncij->NAZ=="N1"
             		replace vpc with nc
     			endif
			
			elseif cSrKolNula $ "12" .and. round(nUlaz-nIzlaz,4) = 0
				
				if ( nMPVU - nMPVI + nPMPV ) <> 0
					
					// 1 stavka (minus)
					append blank
     				
					replace idFirma with cIdfirma
					replace idroba with cIdRoba
					replace idkonto with cIdKonto
					replace datdok with dDatDo+1
					replace idTarifa with Tarifa(cIdKonto, cIdRoba, @aPorezi)
					replace datfaktp with dDatDo+1
					replace kolicina with -1
					replace idvd with "80"
					replace brdok with cBRPST
					replace nc with 0
					replace mpcsapp with 0
					replace TMarza2 with "A"
				
					if koncij->NAZ=="N1"
             			replace vpc with nc
     				endif
					
					// 2 stavka (plus i razlika mpv)
					append blank
     				
					replace idFirma with cIdfirma
					replace idroba with cIdRoba
					replace idkonto with cIdKonto
					replace datdok with dDatDo+1
					replace idTarifa with Tarifa(cIdKonto, cIdRoba, @aPorezi)
					replace datfaktp with dDatDo+1
					replace kolicina with 1
					replace idvd with "80"
					replace brdok with cBRPST
					replace nc with 0
					replace mpcsapp with ;
						(nMPVU-nMPVI+nPMPV)
					replace TMarza2 with "A"
				
					if koncij->NAZ=="N1"
             			replace vpc with nc
     				endif
			
				endif

			endif
  			
			select KALK

		endif

		nCol1 := pcol()+1

		@ prow(), pcol()+1 SAY nMPVU pict gPicDem
		@ prow(), pcol()+1 SAY nMPVI pict gPicDem
		@ prow(), pcol()+1 SAY nMPVU - nMPVI + nPMPV pict gPicDem

		select koncij
		seek trim(cIdKonto)

		select roba
		hseek cIdRoba

		_mpc := UzmiMPCSif()

		select kalk

		if ROUND( nUlaz - nIzlaz + nPKOL, 2 ) <> 0

 			//if cMpcIzSif == "D"
                //@ prow(), pcol() + 1 SAY _mpc pict gpiccdem
                //nTMpv += ( ( nUlaz - nIzlaz + nPKOL ) * _mpc )
            //else
                // mpcsapdv
                @ prow(), pcol() + 1 SAY ( nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol ) pict gpiccdem

 			    //if ROUND(( nMPVU - nMPVI + nPMPV ) / ( nUlaz - nIzlaz + nPKol ), 2) <> ROUND( _mpc, 2 )
   				  //  ?? " ERR MPC =", ALLTRIM( STR( _mpc, 12, 2 )  )
 			    //endif
            //endif

		else

            // stanje artikla je 0
 			@ prow(), pcol() + 1 SAY 0 pict gpicdem

 			if ROUND(( nMPVU - nMPVI + nPMPV ), 4 ) <> 0
   	            ?? " ERR"
   				lImaGresaka := .t.
 			endif

		endif

		if cSredCij == "D"
			@ prow(), pcol()+1 SAY (nNVU-nNVI+nPNV+nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)/2 PICT "9999999.99"
		endif

		if LEN(aNaz)>1 .or. cPredhStanje=="D" .or. cPNab=="D"
  			@ prow()+1,0 SAY ""
  			if len(aNaz)>1
    				@ prow(),nCR  SAY aNaz[2]
  			endif
  			@ prow(),nCol0-1 SAY ""
		endif

		if (cKontrolnaTabela=="D")
			AzurKontrolnaTabela(cIdRoba, nUlaz-nIzlaz+nPkol, nMpvU-nMpvI+nPMpv)
		endif

		if cPredhStanje=="D"
 			@ prow(),pcol()+1 SAY nPMPV pict gpicdem
		endif

		if cPNab == "D"

 			@ prow(), pcol()+1 SAY space(len(gpickol))
 			@ prow(), pcol()+1 SAY space(len(gpickol))

 			if round( nUlaz - nIzlaz + nPKol, 4 ) <> 0
  				@ prow(), pcol()+1 SAY (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol) pict gpicdem
 			else 
  				@ prow(), pcol()+1 SAY space(len(gpicdem))
 			endif

 			@ prow(), nCol1 SAY nNVU pict gpicdem
 			//@ prow(),pcol()+1 SAY space(len(gpicdem))
 			@ prow(), pcol()+1 SAY nNVI pict gpicdem
 			@ prow(), pcol()+1 SAY nNVU-nNVI+nPNV pict gpicdem
 			@ prow(), pcol()+1 SAY _mpc pict gpiccdem

		endif


		nTULaz+=nUlaz
		nTIzlaz+=nIzlaz

		nTPKol+=nPKol

		nTMPVU+=nMPVU
		nTMPVI+=nMPVI

		nTNVU+=nNVU
		nTNVI+=nNVI

		nTRabat+=nRabat

		nTPMPV+=nPMPV
		nTPNV+=nPNV

		if (IsPlanika() .and. cPrikazDob=="D")
		   ? PrikaziDobavljaca(cIdRoba, 6) 
		endif

		if lKoristitiBK
		   ? SPACE(6) + roba->barkod
		endif
		
	endif 

enddo

? __line
? "UKUPNO:"

@ prow(), nCol0-1 SAY ""

if cPredhStanje=="D"
	@ prow(),pcol()+1 SAY nTPMPV pict gpickol
endif

@ prow(),pcol()+1 SAY nTUlaz pict gpickol
@ prow(),pcol()+1 SAY nTIzlaz pict gpickol
@ prow(),pcol()+1 SAY nTUlaz-nTIzlaz+nTPKol pict gpickol

nCol1:=pcol()+1

@ prow(),pcol()+1 SAY nTMPVU pict gpicdem
@ prow(),pcol()+1 SAY nTMPVI pict gpicdem

@ prow(),pcol()+1 SAY nTMPVU-nTMPVI+nTPMPV pict gpicdem
@ prow(),pcol()+1 SAY nTMpv pict gpicdem

if cPNab=="D"
	@ prow()+1,nCol0-1 SAY ""
	if cPredhStanje=="D"
 		@ prow(),pcol()+1 SAY nTPNV pict gpickol
	endif
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY nTNVU pict gpicdem
	@ prow(),pcol()+1 SAY nTNVI pict gpicdem
	@ prow(),pcol()+1 SAY nTNVU-nTNVI+nTPNV pict gpicdem
endif

? __line

FF
END PRINT

if lImaGresaka
	MsgBeep("Pogledajte artikle za koje je u izvjestaju stavljena oznaka ERR - GRESKA")
endif

if lPocStanje
	if lImaGresaka .and. Pitanje(,"Nulirati pripremu (radi ponavljanja procedure) ?","D")=="D"
   		select kalk_pripr
   		zap
 	else
   		renumeracija_kalk_pripr( cBrPSt, "80" )
 	endif
endif

gPicDem := cPicDem
gPicKol := cPicKol
gPicCDem := cPicCDem

close all
return



// zaglavlje llp
function ZaglLLP(lSint)
if lSint==NIL
	lSint:=.f.
endif

Preduzece()
P_COND
?? "KALK: LAGER LISTA  PRODAVNICA ZA PERIOD",dDatOd,"-",dDatDo," NA DAN "
?? date(), space(12),"Str:",str(++nTStrana,3)

if !lSint .and. !EMPTY(qqIdPartn)
	? "Obuhvaceni sljedeci partneri:", TRIM(qqIdPartn)
endif

if lSint
	? "Kriterij za prodavnice:",qqKonto
else
 	select konto
	hseek cidkonto
 	? "Prodavnica:", cIdKonto, "-", konto->naz
endif

if IsDomZdr() .and. !Empty(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

cSC1:=""
cSC2:=""

select kalk
? __line

if cPredhStanje=="D"
	
	if IsPDV()
		
		cTmp := " R.  * Artikal  *   Naziv            *jmj*"
		nPom := LEN(gPicKol)
		cTmp += PADC("Predh.st", nPom) + "*"
		cTmp += PADC("ulaz", nPom) + " " + PADC("izlaz", nPom) + "*"
		cTmp += PADC("STANJE", nPom) + "*"
		nPom := LEN(gPicDem)
		cTmp += PADC("PV.Dug.", nPom) + "*"
		cTmp += PADC("PV.Pot.", nPom) + "*"
		cTmp += PADC("PV", nPom) + "*"
		nPom := LEN(gPicCDem)
		cTmp += PADC("PC.SA PDV", nPom) + "*" 
		cTmp += cSC1
  		
		? cTmp
		
	else
		
		cTmp := " R.  * Artikal  *   Naziv            *jmj*"
		nPom := LEN(gPicKol)
		cTmp += PADC("Predh.st", nPom) + "*"
		cTmp += PADC("ulaz", nPom) + " " + PADC("izlaz", nPom) + "*"
		cTmp += PADC("STANJE", nPom) + "*"
		nPom := LEN(gPicDem)
		cTmp += PADC("MPV.Dug.", nPom) + "*"
		cTmp += PADC("MPV.Pot.", nPom) + "*"
		cTmp += PADC("MPV", nPom) + "*"
		nPom := LEN(gPicCDem)
		cTmp += PADC("MPC sa PP", nPom) + "*" 
		cTmp += cSC1
  	
		? cTmp
	endif
	
	cTmp := " br. *          *                    *   *"
	nPom := LEN(gPicKol)
	cTmp += PADC("Kol/MPV", nPom) + "*"
	cTmp += REPL(" ", nPom) + " " + REPL(" ", nPom) + "*"
	nPom := LEN(gPicDem)
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += cSC2
	
  	? cTmp
	
	if cPNab=="D"
  		
		cTmp := "     *          *                    *   *"
		nPom := LEN(gPicKol)
		cTmp += REPL(" ", nPom) + "*"
		cTmp += REPL(" ", nPom) + " " + REPL(" ", nPom) + "*"
		nPom := LEN(gPicDem)
		cTmp += PADC("SR.NAB.C", nPom) + "*"
		cTmp += PADC("NV.Dug.", nPom) + "*"
		cTmp += PADC("NV.Pot", nPom) + "*"
		cTmp += PADC("NV", nPom) + "*"
		cTmp += REPL(" ", nPom) + "*"
		cTmp += cSC2
		
  		? cTmp
	endif
else
	if IsPDV()
		
		cTmp := " R.  * Artikal  *   Naziv            *jmj*"
		nPom := LEN(gPicKol)
		cTmp += PADC("ulaz", nPom) + " " + PADC("izlaz", nPom) + "*"
		cTmp += PADC("STANJE", nPom) + "*"
		nPom := LEN(gPicDem)
		cTmp += PADC("PV.Dug.", nPom) + "*"
		cTmp += PADC("PV.Pot.", nPom) + "*"
		cTmp += PADC("PV", nPom) + "*"
		cTmp += PADC("PC.SA PDV", nPom) + "*" 
		cTmp += cSC1
  	
  		? cTmp
	else
		
		cTmp := " R.  * Artikal  *   Naziv            *jmj*"
		nPom := LEN(gPicKol)
		cTmp += PADC("ulaz", nPom) + " " + PADC("izlaz", nPom) + "*"
		cTmp += PADC("STANJE", nPom) + "*"
		nPom := LEN(gPicDem)
		cTmp += PADC("MPV.Dug.", nPom) + "*"
		cTmp += PADC("MPV.Pot.", nPom) + "*"
		cTmp += PADC("MPV", nPom) + "*"
		cTmp += PADC("MPC sa PP", nPom) + "*" 
		cTmp += cSC1
  	
		? cTmp
	
	endif
	
	cTmp := " br. *          *                    *   *"
	nPom := LEN(gPicKol)
	cTmp += REPL(" ", nPom) + " " + REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	nPom := LEN(gPicDem)
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += REPL(" ", nPom) + "*"
	cTmp += cSC2
	
	? cTmp
	
	if cPNab=="D"
  		
		cTmp := "     *          *                    *   *"
		nPom := LEN(gPicKol)
		cTmp += REPL(" ", nPom) + " " + REPL(" ", nPom) + "*"
		nPom := LEN(gPicDem)
		cTmp += PADC("SR.NAB.C", nPom) + "*"
		cTmp += PADC("NV.Dug.", nPom) + "*"
		cTmp += PADC("NV.Pot", nPom) + "*"
		cTmp += PADC("NV", nPom) + "*"
		cTmp += REPL(" ", nPom) + "*"
		cTmp += cSC2
	
		? cTmp
		
	endif
endif

if cPredhStanje=="D"
	
	cTmp := "     *    1     *        2           * 3 *"
	nPom := LEN(gPicKol)
	cTmp += PADC("4", nPom) + "*"
	cTmp += PADC("5", nPom) + "*"
	cTmp += PADC("6", nPom) + "*"
	cTmp += PADC("5 - 6", nPom) + "*"
	nPom := LEN(gPicDem)
	cTmp += PADC("7", nPom) + "*"
	cTmp += PADC("8", nPom) + "*"
	cTmp += PADC("7 - 8", nPom) + "*"
	cTmp += PADC("9", nPom) + "*"
	cTmp += cSC2
  	
	? cTmp
	
else
	
	cTmp := "     *    1     *        2           * 3 *"
	nPom := LEN(gPicKol)
	cTmp += PADC("4", nPom) + "*"
	cTmp += PADC("5", nPom) + "*"
	cTmp += PADC("4 - 5", nPom) + "*"
	nPom := LEN(gPicDem)
	cTmp += PADC("6", nPom) + "*"
	cTmp += PADC("7", nPom) + "*"
	cTmp += PADC("6 - 7", nPom) + "*"
	cTmp += PADC("8", nPom) + "*"
	cTmp += cSC2
	
	? cTmp
	
endif

? __line

return


// kreiranje kontrolne tabele
static function CreTblKontrola()
local aDbf
local cCdx

aDbf := {}
cTblKontrola := my_home() + "kontrola.dbf"

AADD(aDbf, { "ID", "C", 10, 0})
AADD(aDbf, { "kolicina", "N", 12, 2})
AADD(aDbf, { "Mpv", "N", 10, 2})

DBCREATE( cTblKontrola , aDbf )
my_use_temp( "KONTROLA", cTblKontrola, .f., .t. )
index on id tag "ID"

return


// azuriranje kontrolne tabele
static function AzurKontrolnaTabela(cIdRoba, nStanje, nMpv)
local nArea

nArea:=SELECT()

SELECT (F_TMP_1)

if !USED()
	USE (cTblKontrola)
endif

SELECT kontrola
APPEND BLANK
REPLACE id WITH cIdRoba
REPLACE kolicina WITH nStanje
REPLACE Mpv WITH nMpv

SELECT(nArea)
return


