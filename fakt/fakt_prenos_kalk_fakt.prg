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


#include "f18.ch"



// ------------------------------------------------
// kalkulacija -> faktura : prenos
// ------------------------------------------------
function KaFak()
local izb:=1
public gDirKalk:=""

private izbor := 1
private opc := {}
private opcexe := {}

AADD( opc, "1. prenos kalk -> fakt            " )
AADD( opcexe, {|| kalk_2_fakt() })
AADD( opc, "2. prenos kalk->fakt za partnera  " )
AADD( opcexe, {|| kalkp_2_fakt() })
AADD( opc, "3. parametri prenosa" )
AADD( opcexe, {|| _params() })

Menu_SC("prenosfakt")

return


// ---------------------------------------
// parametri prenosa
// ---------------------------------------
static function _params()

O_PARAMS

private cSection:="T"
private cHistory:=" "
private aHistory:={}

Box(,3,70)
	@ m_x+1,m_y+2 SAY "Radni direktorij KALK (KALK.DBF):" GET gDirKalk PICT "@S30"
  	read
BoxC()

gDirKalk := TRIM(gDirKalk)

IF LASTKEY()<>K_ESC
	WPar("dk", gDirKalk)
ENDIF

select params
use

return


// -----------------------------------------
// prenos kalk u fakt
// -----------------------------------------
function kalk_2_fakt()
local cIdFirma := gFirma
local cIdTipDok := "10"
local cBrDok := space(8)
local cBrFakt
local cDir:=space(25)
local lToRacun := .f.
local cFaktPartn := SPACE(6)
local lFirst

_o_tables()

select kalk
set order to tag "1"

Box(,15,60)

do while .t.
	
	cIdTipDok := "10"
  	cBrDok := SPACE(8)
  	
	@ m_x+2,m_y+2 SAY "Broj KALK dokumenta:"
  
  	if gNW=="N"
   		@ m_x+2,col()+1 GET cIdFirma pict "@!"
  	else
   		@ m_x+2,col()+1 SAY cIdFirma pict "@!"
  	endif
  	
	@ m_x+2,col()+1 SAY "- " GET cIdTipDok
  	@ m_x+2,col()+1 SAY "-" GET cBrDok
  	
	read
	
	if LastKey() == K_ESC
		exit
	endif
	
	// vrati tip dokumenta za fakturisanje
	cTipFakt := _g_fakt_type( cIdTipDok )
	
	cBrFakt := cBrDok
  	cIdRj := cIdFirma
  	
	@ m_x+3,m_y+2 SAY "Broj dokumenta u modulu FAKT: "
  	@ m_x+3,col()+1 GET cIdRJ pict "@!"
  	@ m_x+3,col()+2 SAY "-" GET cTipFakt
  	@ m_x+3,col()+2 SAY "-" GET cBrFakt ;
		WHEN _set_brdok( cIdRj, cTipFakt, @cBrFakt )
	
	read
	
	if LastKey() == K_ESC
		exit
	endif
	
	// ako je kalk 10 i fakt 10 onda je to fakt racun...
	if cTipFakt == "10" .and. cIdTipDok == "10"
		lToRacun := .t.
	endif
	
	// partner kojem se fakturise.....
	if lToRacun == .t.
		@ m_x + 4, m_y + 2 SAY "Partner kojem se fakturise:" GET cFaktPartn VALID p_firma(@cFaktPartn)
		
		read
		
		if LastKey() == K_ESC
			exit
		endif
	endif
	
  	select FAKT
  	seek cIdRj + cTipFakt + cBrFakt
  	
	if Found()
     		Beep(4)
     		@ m_x+14,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
     		inkey(4)
     		@ m_x+14,m_y+2 SAY space(37)
     		loop
  	endif
	
	select KALK
  	seek cIdFirma+cIdTipDok+cBrDok
  	
	if !Found()
     		
		Beep(4)
     		@ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     		inkey(4)
     		@ m_x+14,m_y+2 SAY space(30)
  		loop
	
	endif
	
	// pozicioniraj se na rj
	select RJ
	set order to tag "ID"
	go top
	seek cIdRj	
	
    select KALK
	lFirst := .t.

	// rok placanja...
	nRokPl := 0
	
	dDatPl := kalk->datdok
	dDatDok := kalk->datdok
     	
	do while !eof() .and. cIdFirma+cIdTipDok+cBrDok==IdFirma+IdVD+BrDok

		// nastimaj robu....
		select roba
		hseek kalk->idroba
		
		select kalk

		if lFirst == .t.
		
        		select PARTN
			
			if lToRacun == .t.
				
				hseek cFaktPartn
			
				nRokPl := IzSifKPartn( "ROKP", cFaktPartn, .f.)
				if VALTYPE(nRokPl) == "N" .and. nRokPl > 0
					dDatPl := dDatDok + nRokPl
				else
					nRokPl := 0
				endif
				
			else
				hseek KALK->idpartner
			endif

			cTxta := PADR(partn->naz, 30)
        		cTxtb := PADR(partn->naz2, 30)
        		cTxtc := PADR(partn->mjesto, 30)
        		
			@ m_x+10, m_Y+2 SAY "Partner " GET cTxta
        		@ m_x+11, m_Y+2 SAY "        " GET cTxtb
        		@ m_x+12, m_Y+2 SAY "Mjesto  " GET cTxtc
        		
			if nRokPl > 0
        			@ m_x+14, m_y + 2 SAY "Rok placanja: " + ;
					ALLTRIM(STR(nRokPl)) + " dana"
			endif
			
			read
          			
			cTxt := Chr(16) + " " + Chr(17)+;
        	       		Chr(16) + " " + Chr(17)+;
                 		Chr(16) + cTxta + Chr(17)+;
				Chr(16) + cTxtb + Chr(17)+;
                 		Chr(16) + cTxtc + Chr(17)
			
			if lToRacun == .t.
			
				cTxt += Chr(16) + "" + Chr(17) + ;
					Chr(16) + DTOC(dDatDok) + Chr(17) + ;
					Chr(16) + "" + Chr(17) + ;
					Chr(16) + DTOC(dDatPl) + Chr(17)
           		
			endif
			
	   		lFirst := .f.

          	select fakt_pripr
          	append blank
          		
			replace txt with cTxt
			replace idpartner with kalk->idpartner
			
			if lToRacun == .t.
				replace idpartner with cFaktPartn
			endif
			
       		else
        		select fakt_pripr
        		APPEND BLANK
       		endif

       		private nKolicina := kalk->kolicina
       			
		if kalk->idvd == "11" .and. cTipFakt = "0"
			nKolicina:=-nKolicina
       		endif
       			
		replace idfirma with cIdRj
                replace rbr with KALK->Rbr
               	replace	idtipdok with cTipFakt
               	replace	brdok with cBrFakt 
               	replace	datdok with kalk->datdok 
               	replace	kolicina with nKolicina 
               	replace	idroba with kalk->idroba 
		replace cijena with kalk->fcj
		replace	rabat with kalk->rabat
               	replace	dindem with "KM"
       		replace idpartner with kalk->idpartner
      		 
		if lToRacun == .t.
			replace cijena with _g_fakt_cijena()
			replace idpartner with cFaktPartn
		endif
		
		select KALK
       		skip
     	enddo
     	
	@ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
	
     	inkey(4)
     	
	@ m_x+8,m_y+2 SAY space(30)
  		
enddo

BoxC()

my_close_all_dbf()

return



// --------------------------------
// otvara tabele prenosa
// --------------------------------
static function _o_tables()
O_FAKT_DOKS
O_ROBA
O_RJ
O_KALK
O_FAKT
O_FAKT_PRIPR
O_SIFK
O_SIFV
O_PARTN
return



// -------------------------------------
// vraca cijenu za fakturu
// -------------------------------------
static function _g_fakt_cijena()
local nCijena := kalk->fcj

if rj->tip == "V1"
	nCijena := roba->vpc	
elseif rj->tip == "V2"
	nCijena := roba->vpc2
elseif rj->tip == "M1"
	nCijena := roba->mpc
elseif rj->tip == "M2"
	nCijena := roba->mpc2
elseif rj->tip == "M3"
	nCijena := roba->mpc3
else
	nCijena := roba->vpc
endif

return nCijena


// --------------------------------------------------
// setuje broj fakture
// --------------------------------------------------
static function _set_brdok( cIdRj, cTip, cBroj )

// daj novi broj fakture....
cBroj := PADR( REPLICATE( "0", gNumDio ), 8 )

return .t.



// ----------------------------------------------------
// vraca tip dokumenta fakt na osnovu kalk tipa
// ----------------------------------------------------
static function _g_fakt_type( cKalkType )
local xType := "01"

do case
	case cKalkType == "10"
		xType := "01"
	case cKalkType == "11"
		xType := "12"
	case cKalkType == "14"
		xType := "10"
endcase

return xType




// -------------------------------------------------
// prenos kalk -> fakt period
// -------------------------------------------------
function kalkp_2_fakt()
local lFirst
local cFaktPartn

_o_tables()

select fakt_pripr  
set order to tag "3"     
// idfirma+idroba+rbr

cIdFirma   := gFirma
dOd := DATE() 
dDo := DATE()
dDatPl := DATE()
cIdPartner := SPACE(LEN(PARTN->id))
cFaktPartn := cIdPartner
qqIdVd     := PADR("41;",40)
cIdTipDok  := "11"

select kalk
SET ORDER TO TAG "7"  

Box("#KALK->FAKT za partnera", 17, 75)

DO WHILE .T.
	
	@ m_x+1,m_y+2 SAY "Firma/RJ:"
    	
	if gNW=="N"
      		@ m_x+1,col()+1 GET cIdFirma pict "@!"
    	else
      		@ m_x+1,col()+1 SAY cIdFirma pict "@!"
    	endif
    	
	@ m_x+2,m_y+2 SAY "Kalk partner" GET cIdPartner ;
		VALID P_Firma(@cIdPartner)
    	@ m_x+3,m_y+2 SAY "Vrste KALK dokumenata" GET qqIdVd PICT "@!S30"
    	@ m_x+4,m_y+2 SAY "Za period od" GET dOd
    	@ m_x+4,col()+1 SAY "do" GET dDo

    	cTipFakt := cIdTipDok
    	cBrFakt  := SPACE(8)
    	cIdRj    := cIdFirma
    	
	@ m_x+6,m_y+2 SAY "Broj dokumenta u modulu FAKT: "
    	@ m_x+6,col()+1 GET cIdRJ pict "@!"
    	@ m_x+6,col()+2 SAY "-" GET cTipFakt
    	@ m_x+6,col()+2 SAY "-" GET cBrFakt WHEN SljedBrFakt()
    	
	read
    	
	if lastkey()==K_ESC
		exit
	endif
    	
	lToRacun := .f.
	
	if ( cTipFakt == "10" ) .and. ( "10" $ qqIdVd )
		lToRacun := .t.
	endif
	
	if lToRacun == .t.
		@ m_x + 8, m_y + 2 SAY "Fakturisati partneru" GET cFaktPartn VALID p_firma(@cFaktPartn)
		read
		if LastKey() == K_ESC
			exit
		endif
	endif
	
	IF (aUsl1 := Parsiraj(qqIdVd,"IDVD")) == NIL
		LOOP
	ENDIF

    	select FAKT
	seek cIdRj + cTipFakt + cBrFakt
    	
	if Found()
       		Beep(4)
       		@ m_x+14,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
       		inkey(4)
       		@ m_x+14,m_y+2 SAY space(37)
       		loop
    	endif

    	select KALK
    	
	cFilter := "idfirma == cIdFirma"
	cFilter += ".and." 
	cFilter += "datdok >= dOd"
	cFilter += ".and."
	cFilter += "datdok <= dDo"
	cFilter += ".and."
	cFilter += "idpartner == cIdPartner"
    	
	IF !EMPTY(qqIdVd)
		cFilter += ".and." + aUsl1
	ENDIF
    	
	SET FILTER TO &cFilter
    	GO TOP

    	IF EOF()
      		Beep(4)
      		@ m_x+14,m_y+2 SAY "Trazeno ne postoji u KALK-u !"
      		INKEY(4)
      		@ m_x+14,m_y+2 SAY space(30)
      		LOOP
    	ELSE
     		
		// nasteli partnera
		select partn
		
		if lToRacun == .t.
			hseek cFaktPartn
		else
			hseek cIdPartner
		endif
		
		nRokPl := 0

		if lToRacun == .t.
			nRokPl := IzSifKPartn( "ROKP", cFaktPartn, .f. )
		else
			nRokPl := IzSifKPartn( "ROKP", cIdPartner, .f. )
		endif

		if VALTYPE(nRokPl) == "N"
			dDatPl := dDo + nRokPl
		else
			nRokPl := 0
		endif
		
		// imamo filterisan KALK, slijedi generacija FAKT iz KALK
      		select KALK
      		
		lFirst := .t.

      		DO WHILE !EOF()
        		
			nKalkCijena := IF(cTipFakt $ "00#01", KALK->nc, ;
                       	  IF( cTipFakt $ "11#27", KALK->mpcsapp, KALK->vpc ))
        		
			nKalkRabat := IF( cTipFakt $ "00#01", 0, KALK->rabatv)
        		
			private nKolicina := kalk->kolicina
        		
			if kalk->idvd=="11" .and. cTipFakt="0"
          			nKolicina := -nKolicina
        		endif

        		cArtikal := idroba
        		SKIP 1
        		
			DO WHILE !EOF() .and. cArtikal==idroba
          			n2KalkCijena := IF(cTipFakt$"00#01",KALK->nc,;
                         	IF(cTipFakt$"11#27",KALK->mpcsapp,KALK->vpc))
          			n2KalkRabat := IF(cTipFakt$"00#01",0,KALK->rabatv)
          			n2Kolicina:=kalk->kolicina
          			if kalk->idvd=="11" .and. cTipFakt="0"
            				n2Kolicina := -n2Kolicina
          			endif
          			IF nKalkCijena<>n2KalkCijena .or. nKalkRabat<>n2KalkRabat
            				EXIT
          			ENDIF
          			nKolicina += (n2Kolicina)
          			SKIP 1
        		ENDDO
        		
			SKIP -1

        		if lFirst
          			
				nRBr:=1
          			select PARTN
				
				if lToRacun == .t.
					hseek cFaktPartn
				else
					hseek cIdPartner
				endif
				
          			_Txt3a:=padr(cIdPartner+".",30)
				_txt3b:=_txt3c:=""
				IzSifre(.t.)
          			
				cTxta:=_txt3a
          			cTxtb:=_txt3b
          			cTxtc:=_txt3c
          			
				@ m_x+10,m_Y+2 SAY "Partner " GET cTxta
          			@ m_x+11,m_Y+2 SAY "        " GET cTxtb
          			@ m_x+12,m_Y+2 SAY "Mjesto  " GET cTxtc
          		
				if nRokPl > 0
          				@ m_x+13,m_Y+2 SAY "Rok placanja " + ;
						ALLTRIM(STR(nRokPl)) + " dana"
				endif
			
				read
          			
				cTxt:=Chr(16)+" " +Chr(17)+;
                		  Chr(16)+" "+Chr(17)+;
               			  Chr(16)+cTxta+ Chr(17)+;
				  Chr(16)+cTxtb+Chr(17)+;
                		  Chr(16)+cTxtc+Chr(17)
          			
			 	cTxt += Chr(16) + "" + Chr(17)
			 	cTxt += Chr(16) + DTOC(dDo) + Chr(17)
			 	cTxt += Chr(16) + "" + Chr(17)
			 	cTxt += Chr(16) + DTOC(dDatPl) + Chr(17)
				
				
				lFirst := .f.
          			
				select fakt_pripr
          			append blank
          			replace txt with cTxt
				
        		else
          			
				select fakt_pripr
          			
				HSEEK cIdFirma+KALK->idroba
          			IF FOUND() .and. ROUND(nKalkCijena-cijena,5)==0 .and.( cTipFakt="0" .or. ROUND(nKalkRabat-rabat,5)==0 )
            				Scatter()
            				_kolicina += nKolicina
                            my_rlock()
            				Gather()
                            my_unlock()
            				SELECT KALK
					SKIP 1
					LOOP
          			ELSE
            				++nRBr
            				APPEND BLANK
         			ENDIF
        		endif
        		
			replace idfirma with cIdRj
                	replace	rbr with STR(nRBr,3)
                	replace idtipdok with cTipFakt
                	replace brdok with cBrFakt
                	replace datdok with dDo
			if lToRacun == .t.
                		replace idpartner with cFaktPartn
			else
                		replace idpartner with cIdPartner
			endif
                	replace kolicina with nKolicina
                	replace	idroba with KALK->idroba
                	replace cijena with nKalkCijena
                	replace rabat with nKalkRabat
                	replace dindem with "KM"
        		
			select KALK
        		SKIP 1
      		
		ENDDO

      		@ m_x+15,m_y+2 SAY "Dokument je prenesen !"
      		INKEY(4)
      		@ m_x+15,m_y+2 SAY space(30)
      		
		// snimi parametre !!!
      		O_PARAMS
      		private cSection:="K"
		private cHistory:=" "
		private aHistory:={}
      		
		WPar("c1",cDir)
      		WPar("p1",dOd)
      		WPar("p2",dDo)
      		WPar("p3",cIdPartner)
      		WPar("p4",qqIdVd)
      		WPar("p5",cIdTipDok)
      		
		select params
		use
      		SELECT KALK
    	ENDIF
ENDDO
Boxc()

my_close_all_dbf()
return



// -----------------------------------------
// naredni broj fakture
// -----------------------------------------
static function SljedBrFakt()
LOCAL nArr:=SELECT()
IF EMPTY(cBrFakt)
    _datdok := dDo
    _idpartner := cIdPartner
    cBrFakt := fakt_novi_broj_dokumenta( cIdRJ, cTipFakt )
    SELECT (nArr)
ENDIF
return .t.



