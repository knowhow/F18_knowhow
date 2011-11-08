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

#define D_MAX_FILES     150


// preuzimanje podataka iz TOPS-a
function UzmiIzTopsa()
local Izb3
local OpcF
local aPom1 := {}
local aPom2 := {}
local l42u11
local cTopsKPath
local cTopsKChkPath
local cSrcOpis
private h

// kreirati dokument 42 ili 11
l42u11 := ( IzFMKINI("KALK", "POS42uKALK11", "N") == "D" )

// primjer matrice:
// [TOPSuKALK]    |=CHR(124)
// UslovKontoIMarkerZaRazvrstReal=left(idroba,2)="90"|1320KF|KF;left(idroba,2)="91"|1320KF2|KF2
// ----------------------------------------
cRazdvoji := IzFMKIni("TOPSuKALK","UslovKontoIMarkerZaRazvrstReal","-",KUMPATH)

IF ( cRazdvoji <> "-" )
	// razdvajanje realizacije na vise konta
  	// -------------------------------------
  	lRazdvoji:=.t.
  	aRazdvoji := TOKuNIZ(cRazdvoji, ";", "|")
  	
	AADD(aRazdvoji,{".t.","","",0})
  	
	FOR i:=1 TO LEN(aRazdvoji)
    		DO WHILE LEN(aRazdvoji[i])<4
      			DO CASE
        			CASE LEN( aRazdvoji[i] ) < 1
                                	AADD( aRazdvoji[i] , ".t." )
        			CASE LEN( aRazdvoji[i] ) < 2
                                	AADD( aRazdvoji[i] , "" )
        			CASE LEN( aRazdvoji[i] ) < 3
                                 	AADD( aRazdvoji[i] , "" )
        			CASE LEN( aRazdvoji[i] ) < 4
                                	AADD( aRazdvoji[i] , 0 )
      			ENDCASE
    		ENDDO
  	NEXT
ELSE

	// standardni prenos
	// -----------------
  	lRazdvoji := .f.

ENDIF

O_KONCIJ
go top

if gModemVeza == "D"
	
	OpcF:={}

 	select koncij
	
 	do while !EOF()
    
  		if !EMPTY(field->idprodmjes)
   			
			cTopsKPath := TRIM(gTopsDest) + TRIM(field->idprodmjes) + SLASH
			cTopsKChkPath := STRTRAN(cTopsKPath, ":\", ":\chk\")
			
			// brisi fajlove iz prenosa....
			BrisiSFajlove( cTopsKPath , 7)
			// brisi fajlove iz chk lokacije...
   			BrisiSFajlove( cTopsKChkPath, 7 )

   			aFiles := DIRECTORY(cTopsKPath + "TK*.dbf")
   			
			ASORT(aFiles,,,{|x,y| DTOS(x[3]) + x[4] > DTOS(y[3]) + y[4] })
			
			AEVAL(aFiles, { |elem| AADD( OpcF, PADR(ALLTRIM(koncij->idprodmjes) + SLASH + TRIM(elem[1]), 20) + " " + UChkPostoji(cTopsKPath + TRIM(elem[1]) ) + " " + DTOC(elem[3]) + 	" " + elem[4] ) } , 1, D_MAX_FILES)  
  		
		endif
  		
		skip
 	enddo

	// R/X + datum + vrijeme
 	ASORT(OpcF,,,{|x,y| right(x, 19) > right(y, 19) })  
 	
	h := ARRAY(LEN(OpcF))
 	
	for i:=1 to len(h)
   		h[i]:=""
 	next
 	
	if LEN(OpcF)==0
   		MsgBeep("U direktoriju za prenos nema podataka")
   		closeret
 	endif
else
	MsgBeep("Pripremi disketu za prenos ....#te pritisni nesto za nastavak")
endif

O_ROBA
O_TARIFA
O_PRIPR
O_KALK

if gModemVeza == "D"
	Izb3:=1
  	fPrenesi:=.f.
  	do while .t.
   		Izb3:=Menu("izdat",opcF,Izb3,.f.)
		if Izb3==0
     			exit
   		else
     			cTopsDBF := TRIM(gTopsDEST) + TRIM(left(opcf[Izb3], 15))
     			
			save screen to cS
     			
			Vidifajl(strtran(cTopsDBF, ".DBF", ".TXT"))  
			// vidi TK1109.TXT
     			
			restore screen from cS
     			
			if Pitanje(,"Zelite li izvrsiti prenos ?","D")=="D"
         			fPrenesi:=.t.
         			Izb3:=0
     			else
         			// close all 
				// vrati se u petlju
         			loop
     			endif
   		endif
  	enddo
	
  	if !fprenesi
        	return .f.
  	endif
else
	// CRC gledamo ako nije modemska veza
 	cTOPSDBF:=TRIM(gTopsDEST) + "TOPSKA"
 	aPom1 := IscitajCRC( trim(gTopsDest) + "CRCTK.CRC" )
 	aPom2 := IntegDBF(cTopsDBF)
	IF !(aPom1[1]==aPom2[1] .and. aPom1[2]==aPom2[2])
   		Msg("CRCTK.CRC se ne slaze. Greska na disketi !",4)
   		CLOSERET
 	ENDIF
endif

usex (cTopsDBF) NEW alias TOPSKA

go bottom
cBRKALK:=LEFT(STRTRAN(DTOC(datum),".",""),4) + "/" + idpos
// dobija se broj u formi 1210/1     - 1210 - posljednji, najveci datum
cIdVd := TOPSKA->IdVd

if (l42u11)
	cPom:=IzFmkIni("POS42uKALK11","Kase"," ",KUMPATH)
	if !(EMPTY(cPom) .or. topska->idPos$cPom)
		l42u11:=.f.
	endif
endif

IF (cIdVD=="42" .and. l42u11) .or. (cIdVD=="12")
	O_KONTO
  	cIdKonto2:=PADR("1310",7)
  	Box(,3,60)
  		@ m_x+2, m_y+2 SAY "Magacinski konto:" GET cIdKonto2 VALID P_Konto(@cIdKonto2)
  		READ
  	BoxC()
ENDIF

select koncij
locate for idprodmjes==topska->idpos
if !found()
	MsgBeep("U sifrarniku KONTA-TIPOVI CIJENA nije postavljeno#nigdje prodajno mjesto :"+idProdMjes+"#Prenos nije izvrsen.")
  	closeret
endif

select kalk
IF (cIdVD=="42" .and. l42u11)
	seek gFirma+"11"+"X"
  	skip -1
  	if idvd<>"11"
    		cBrKalk:=space(8)
  	else
    		cBrKalk:=brdok
  	endif
  	cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
ELSE
  	seek gfirma+cIdVd+cBRKALK
  	if found()
		Msg("Vec postoji dokument pod brojem "+gfirma+"-"+cIdVd+"-"+cbrkalk+"#Prenos nece biti izvrsen")
		closeret
	endif
ENDIF

select topska
go top
if topska->(FieldPos("barkod"))<>0
	if Pitanje(,"Mjenjati barkod-ove ?","N")=="D"
		lReplace:=.t.
		nReplaceBK:=0
	else
		lReplace:=.f.
	endif
	if lReplace .and. Pitanje(,"Mjenjati sve barkod-ove bez provjere ?","N")=="D"
		lReplaceAll:=.t.
	else
		lReplaceAll:=.f.
	endif
else
	lReplace:=.f.
endif

lSortNR:=.f.

if IsJerry()
	if Pitanje(,"Napraviti sort rednih brojeva","D")=="D"
		select pripr
		go bottom
		lSortNR:=.t.
		nSortNR:=VAL(pripr->rbr)
		go top
		cKalkulacija:=SPACE(8)
		Box(,4,60)
		@ 1+m_x, 2+m_y SAY "Uslov za sortiranje rednih brojeva:"
		@ 2+m_x, 2+m_y SAY "Zadnji redni broj u pripremi: " GET nSortNr PICT "999"
		@ 3+m_x, 2+m_y SAY "0 - od pocetka"
		@ 4+m_x, 2+m_y SAY "Priljepi na broj dokumenta: " GET cKalkulacija
		read
		BoxC()
		if LastKey()==K_ESC
			return
		endif
	endif
endif

// pobrisi prvo p_doksrc
zap_p_doksrc()

nRbr:=0
do while !eof()
	if lRazdvoji
    		FOR i:=1 TO LEN(aRazdvoji)
      			cPom := aRazdvoji[i,1]
      			IF &cPom
        			cBrDok    := TRIM(cBrKalk)+aRazdvoji[i,3]
        			cIdKonto  := aRazdvoji[i,2]
        			IF EMPTY(cIdKonto)
					cIdKonto := KONCIJ->id
				ENDIF
        			aRazdvoji[i,4] := aRazdvoji[i,4]+1
        			cRBr      := STR(aRazdvoji[i,4],3)
        			EXIT
      			ENDIF
    		NEXT
  	else
    		cBrDok    := cBrKalk
    		cIdKonto  := KONCIJ->id
    		if IsJerry() .and. lSortNR
			cRbr:=STR(++nSortNr,3)
			if !EMPTY(cKalkulacija)
				cBrDok:=cKalkulacija
			endif
			if nSortNr>0
				select pripr
				go bottom
			endif
		else
			cRBr      := STR(++nRBr,3)
		endif
  	endif
	
	IF (cIdVd=="42" .and. l42u11) .or. (cIdVd=="12")
		// formiraj 11-ku umjesto 42-ke
		if (topska->kolicina<>0)
			SELECT pripr
			APPEND BLANK
			replace idfirma  with gfirma          ,;
			idvd     with "11"            ,;
			brdok    with cBrDok          ,;
			datdok   with topska->datum   ,;
			datfaktp with topska->datum   ,;
			kolicina with topska->kolicina,;
			idkonto  with cIdKonto        ,;
			idkonto2 with cIdKonto2       ,;
			idroba   with topska->idroba  ,;
			rbr      with cRBr            ,;
			tmarza2  with "%"             ,;
			idtarifa with topska->idtarifa,;
			mpcsapp  with topska->(mpc-stmpc),;
			tprevoz  with "R"
			if IsTehnoprom()
				replace idpartner with topska->idpartner
			endif
		endif
	else
		if (topska->kolicina<>0)		
			SELECT pripr
			APPEND BLANK
			replace idfirma  with gfirma          ,;
			idvd     with topska->IdVd    ,;
			brdok    with cBrDok          ,;
			datdok   with topska->datum   ,;
			datfaktp with topska->datum   ,;
			kolicina with topska->kolicina,;
			idkonto  with cIdKonto        ,;
			idroba   with topska->idroba  ,;
			rbr      with cRBr            ,;
			tmarza2  with "%"             ,;
			idtarifa with topska->idtarifa,;
			mpcsapp  with topska->mpc     ,;
			RABATV   with topska->stmpc
			if (cIdVd=="19")
				REPLACE fcj with topska->stmpc
			endif
			if IsTehnoprom()
				replace idpartner with topska->idpartner
			endif
		endif
	endif
  	
	// a sada barkod ako ga ima
	if lReplace
	    	select roba
	   	set order to tag "ID"
	    	seek topska->idroba
	    	if Found()
	    		cBarKod:=roba->barkod
			if !EMPTY(topska->barkod) .and. topska->barkod<>cBarKod
				MsgBeep("Postoji promjena barkod-a:##Artikal: "+ ALLTRIM(roba->id) + "-" + ALLTRIM(roba->naz) + "##KALK barkod -> " + roba->barkod + "##TOPS barkod -> " + topska->barkod)
				if lReplaceAll .or. Pitanje(,"Zamjeniti barkod u sifrarniku ?","N")=="D"
					replace roba->barkod with topska->barkod
					++nReplaceBK
				endif
			endif
	    	endif
	endif
	
	select pripr

	cSrcOpis := ""
	if pripr->idvd == "42"
		cSrcOpis := "Prodaja"
	endif
	if pripr->idvd == "12"
		cSrcOpis := "Reklamacija"
	endif
	
	// dodaj stavku i u p_doksrc
	add_p_doksrc( gFirma, pripr->idvd, pripr->brdok, ;
		pripr->datdok, "TOPS", topska->idpos, topska->idvd, ;
		topska->brdok, topska->datpos, pripr->idkonto, "" ,;
		topska->idpartner, cSrcOpis)

	
	select topska
  	skip
enddo


close all

if (lReplace .and. nReplaceBK > 0)
	MsgBeep("Zamjena izvrsena na " + ALLTRIM(STR(nReplaceBK)) + " polja barkod !")
endif

if gModemVeza=="D" .and. fPrenesi
	// pobrisi fajlove...
	FileDelete(cTopsDBF)
	FileDelete(STRTRAN(UPPER(cTopsDBF), ".DBF", ".TXT"))
endif

IF IzFMKINI("KALK","PrimPak","N",KUMPATH)=="D"
	NaPrPak2()
ENDIF

return


// da li postoji fajl u chk lokaciji, vraca oznaku
// R - realizovan
// X - nije obradjen
function UChkPostoji(cFullFileName)
if FILE(STRTRAN(cFullFileName,":" + SLASH, ":" + SLASH + "chk" + SLASH))
	return "R"
else
   	return "X"
endif



// ---------------------------------------------
// uzmi sifrarnik robe iz tops-a
// ---------------------------------------------
function RobaFromTops()
local GetList := {}
local cTopsSif := PADR("c:\tops\sif1\",100)
local cPrenos := "N"
local cPrepisi := "N"
local cSinCjen := "D"
local cTopsRoba

Box(, 7, 70)
	@ m_x + 1, m_y + 2 SAY "**** prenos sifrarnika iz tops-a"
	@ m_x + 3, m_y + 2 SAY "lokacija sifrarnika tops-a" GET cTopsSif PICT "@S30" VALID !EMPTY(cTopsSif)
 	@ m_x + 4, m_y + 2 SAY "prepisi istu robu iz tops-a (D/N)?" GET cPrepisi VALID cPrepisi $ "DN" PICT "@!"
 	@ m_x + 5, m_y + 2 SAY "samo sinhroniziraj cijene (D/N)?" GET cSinCjen VALID cSinCjen $ "DN" PICT "@!"
	@ m_x + 7, m_y + 2 SAY "izvrsiti prenos (D/N)?" GET cPrenos VALID cPrenos $ "DN" PICT "@!"
	
	read
BoxC()

if cPrenos == "N"
	return
endif

cTopsSif := ALLTRIM(cTopsSif)

// otvori tabelu roba.tops

O_ROBA

select 245
use (cTopsSif + "ROBA") alias TROBA
select troba

set order to tag "1"

go top

nCnt := 0

do while !EOF()

	cTopsRoba := field->id
	
	select roba
	hseek cTopsRoba

	if cSinCjen == "N"
	  if !Found() .and. roba->id <> cTopsRoba
		
		append blank
		replace field->id with troba->id	
	
	  elseif Found() .and. roba->id == cTopsRoba .and. ;
		cPrepisi == "N"
		
		select troba
		skip
		loop

	  endif
	endif
	
	// sinhronizacija cijena - samo
	if cSinCjen == "D"
	 
	  if FOUND()
	    replace field->mpc with troba->cijena1
	    replace field->mpc2 with troba->cijena2
	  endif
	 
	else

	  replace field->id with troba->id
	  replace field->naz with troba->naz
	  replace field->mpc with troba->cijena1
	  replace field->mpc2 with troba->cijena2
	  replace field->idtarifa with troba->idtarifa
	  replace field->barkod with troba->barkod
	  replace field->jmj with troba->jmj
	
	endif

	++ nCnt

	select troba
	skip
enddo

if nCnt > 0
	msgbeep("Izmjenjeno " + ALLTRIM(STR(nCnt)) + " sifri !")
endif

select troba
use

return


