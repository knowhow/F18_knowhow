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

// ----------------------------------------------------------
// meni opcije prenos FAKT->KALK prodavnica
// ----------------------------------------------------------
function prenos_fakt_kalk_prodavnica()
private Opc:={}
private opcexe:={}

AADD(Opc,"1. fakt->kalk (13->11) otpremnica maloprodaje        ")
AADD(opcexe,{||  prod_fa_ka_prenos_otpr()})
AADD(Opc,"2. fakt->kalk (11->41) racun maloprodaje")
AADD(opcexe,{||  FaKaPrenosRacunMP()  })
AADD(Opc,"3. fakt->kalk (11->42) paragon")
AADD(opcexe,{||  FaKaPrenosRacunMPParagon()  })
AADD(Opc,"4. fakt->kalk (11->11) racun mp u razduzenje mag.")
AADD(opcexe,{||  FaKaPrenos_MP_u_razduzenje()  })
AADD(Opc,"5. fakt->kalk (01->81) doprema u prod")
AADD(opcexe,{||  FaKaPrenos_01_doprema() })
AADD(Opc,"6. fakt->kalk (13->80) prenos iz c.m. u prodavnicu")
AADD(opcexe,{||  FaKaPrenos_cm_u_prodavnicu()  })
AADD(Opc,"7. fakt->kalk (15->15) izlaz iz MP putem VP")
AADD(opcexe,{||  FaKaPrenos_izlaz_putem_vp() })
private Izbor:=1
Menu_SC("fkpr")
CLOSERET

return


// -----------------------------------------
// prenos 11->11
// -----------------------------------------
function FaKaPrenos_MP_u_razduzenje()
local cIdFirma := gFirma
local cIdTipDok := "11"
local cBrDok := SPACE(8)
local cBrKalk := SPACE(8)
local dFaktOd := DATE() - 10
local dFaktDo := DATE()

O_KALK_PRIPR
O_KONCIJ
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT
// idfirma + DTOS(datdok)
set order to tag "7"

dDatKalk := DATE()

cIdKonto := PADR("1320", 7)
cIdKonto2 := PADR("1310", 7)

cIdZaduz2 := SPACE(6)
cIdZaduz := SPACE(6)

cSabirati := gAutoCjen
cCjenSif := "N"

if gBrojac=="D"

 	select kalk
	set order to tag "1"
	seek cIdFirma + "11X"
 	skip -1
 
 	if idvd<>"11"
   		cBrKalk := SPACE(8)
 	else
   		cBrKalk:=brdok
 	endif

endif

Box(,15,60)

if gBrojac=="D"
	cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

	nRBr := 0
  
  	@ m_x+1,m_y+2   SAY "Broj kalkulacije 11 -" GET cBrKalk pict "@!"
  	@ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  	@ m_x+3,m_y+2   SAY "Magac. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  	@ m_x+4,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  
  	cFaktFirma := cIdFirma
  
  	@ m_x+6, m_y + 2 SAY "Fakture tipa 11 u periodu od" GET dFaktOd
  	@ m_x+6, col()+1 SAY "do" GET dFaktDo
 
	@ m_x+7, m_y + 2 SAY "Uzimati MPC iz sifrarnika (D/N) ?" GET cCjenSif VALID cCjenSif $ "DN" PICT "@!"
	
	@ m_x+8, m_y + 2 SAY "Sabirati iste artikle (D/N) ?" GET cSabirati VALID cSabirati $ "DN" PICT "@!"

  	read
  
  	if lastkey()==K_ESC
  		exit
  	endif

  	select fakt
	set order to tag "1"
	go top
  	
	seek cFaktFirma + cIdTipDok
  
	MsgO("Generisem podatke....")
  
     	do while !eof() .and. cFaktFirma + cIdTipDok == IdFirma + IdTipDok
       	
       		// datumska provjera...
       		if fakt->datdok < dFaktOd .or. fakt->datdok > dFaktDo
			
			skip
			loop
			
		endif
		
       		// usluge ne prenosi takoðer
		if ALLTRIM(podbr)=="."  .or. idroba="U"
          		
			skip
          		loop
			
       		endif

		cIdRoba := fakt->idroba
       		select ROBA
       		hseek cIdRoba

		cIdTar := roba->idtarifa
       		
		select tarifa
       		hseek cIdTar
       
       		select koncij
       		seek trim(cIdKonto)
       	
		private aPorezi:={}
		
		cPKonto := cIdKonto
		
		select kalk_pripr

		if cSabirati == "D"
			set order to tag "4"
			seek cIdFirma + "11" + cIdRoba 
       		else
			set order to tag "5"
			seek cIdFirma + "11" + cIdRoba + ;
				STR(fakt->cijena, 12, 2)
		endif

		if !FOUND()
			
			APPEND BLANK
       		       		
			replace idfirma with cIdFirma
			replace rbr with str(++nRbr,3)
               		replace idvd with "11"
               		replace brdok with cBrKalk
               		replace datdok with dDatKalk
               		replace idtarifa with Tarifa(cPKonto, fakt->idroba, @aPorezi)
               		replace brfaktp with ""
               		replace datfaktp with fakt->datdok
               		replace idkonto   with cPKonto
               		replace idzaduz  with cidzaduz
               		replace idkonto2  with cidkonto2
               		replace idzaduz2  with cidzaduz2
              		replace idroba with fakt->idroba
               		replace nc  with ROBA->nc
               		replace vpc with fakt->cijena
               		replace rabatv with fakt->rabat
               		replace mpc with fakt->porez
               		replace tmarza2 with "A"
               		replace tprevoz with "A"
			
			if cCjenSif == "D"
               			replace mpcsapp with UzmiMpcSif()
			else
				replace mpcsapp with fakt->cijena
			endif
		
		endif
		
		// saberi kolicine za jedan artikal
		replace kolicina with ( kolicina + fakt->kolicina )
       		
		select fakt
       		skip
     	
	enddo
     
	MsgC()
     
	select kalk_pripr
	set order to tag "1"
	go top

	// brisi stavke koje su kolicina = 0
	do while !EOF()
		if field->kolicina = 0
			delete
		endif
		skip
	enddo
	go top

	select fakt
     
     	@ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
     	
	if gBrojac=="D"
      		cBrKalk := UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
     	endif
     	
	inkey(4)
	
     	@ m_x+8,m_y+2 SAY space(30)
     	@ m_x+10,m_y+2 SAY space(40)
	
enddo

Boxc()
closeret

return



// -----------------------------------------
// prenos 13->11
// -----------------------------------------
function prod_fa_ka_prenos_otpr()
local cIdFirma:=gFirma
local cIdTipDok:="13"
local cBrDok:=SPACE(8)
local cBrKalk:=SPACE(8)

O_KALK_PRIPR
O_KONCIJ
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to tag "1";seek cidfirma+"11X"
 skip -1
 if idvd<>"11"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 11 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Magac. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  
  if IsPlanika() .or. gVar13u11=="1"
    @ m_x+4,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  endif
  
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj otpremnice u MP: " GET cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
  @ m_x+6,col()+1 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif


  select fakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
      aMemo:=parsmemo(txt)

     select kalk_pripr
     LOCATE FOR BrFaktP==cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     if gVar13u11=="2"  .and. EMPTY(fakt->idpartner)
       @ m_x+10,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
       read
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif
     select fakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA
       hseek fakt->idroba

       select tarifa
       hseek roba->idtarifa
       select koncij
       seek trim(cidkonto)

       select fakt
       if alltrim(podbr)=="."  .or. idroba="U"
          skip
          loop
       endif

       select kalk_pripr
       APPEND BLANK
       cPKonto:=IF(gVar13u11=="1",cidkonto,fakt->idpartner)
       private aPorezi:={}
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "11",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idtarifa with Tarifa(cPKonto, fakt->idroba , @aPorezi ),;
               brfaktp with fakt->brdok,;
               datfaktp with fakt->datdok,;
               idkonto   with cPKonto ,;
               idzaduz  with cidzaduz,;
               idkonto2  with cidkonto2,;
               idzaduz2  with cidzaduz2,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc  with ROBA->nc,;
               vpc with IF(gVar13u11=="1",fakt->cijena,KoncijVPC()),;
               rabatv with fakt->rabat,;
               mpc with fakt->porez,;
               tmarza2 with "A",;
               tprevoz with "A",;
               mpcsapp with IF(gVar13u11=="1",roba->mpc,fakt->cijena)

       if gVar13u11=="1"
         replace mpcsapp with UzmiMPCSif()
       endif
       if gVar13u11=="2" .and. EMPTY(fakt->idpartner)
         replace idkonto with cidkonto
       endif

       select fakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
     @ m_x+10,m_y+2 SAY space(40)
  endif

enddo
Boxc()
closeret
return
*}


/*! \fn FaKaPrenosRacunMP()
 *  \brief Prenos maloprodajnih kalkulacija FAKT->KALK (11->41)
 */

function FaKaPrenosRacunMP()

private cIdFirma:=gFirma
private cIdTipDok:="11"
private cBrDok:=SPACE(8)
private cBrKalk:=SPACE(8)
private cFaktFirma

O_KALK_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT

dDatKalk:=Date()
cIdKonto:=PADR("1330",7)
cIdZaduz:=SPACE(6)
cBrkalk:=space(8)
cZbirno:="N"
cNac_rab := "P"

if gBrojac=="D"
	select kalk
 	select kalk
	set order to tag "1"
	seek cIdFirma+"41X"
 	skip -1
 	if idvd<>"41"
   		cBrkalk:=SPACE(8)
 	else
   		cBrKalk:=brdok
 	endif
endif

Box(,15,60)
	if gBrojac=="D"
 		cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
	endif

	do while .t.
		nRBr:=0
  		@ m_x+1,m_y+2 SAY "Broj kalkulacije 41 -" GET cBrKalk pict "@!"
  		@ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  		@ m_x+3,m_y+2 SAY "Konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  		if gNW<>"X"
   			@ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  		endif
 		@ m_x+5,m_y+2 SAY "Napraviti zbirnu kalkulaciju (D/N): " GET cZbirno VALID cZbirno$"DN" PICT "@!"
		read
		
		if cZbirno == "N"

  			cFaktFirma := cIdFirma
  			
			@ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  			@ m_x+6,col()+2 SAY "- " + cIdTipDok
  			@ m_x+6,col()+2 SAY "-" GET cBrDok
  			
			read
  		
			if (LastKey()==K_ESC)
				exit
			endif

			select fakt
  			seek cFaktFirma + cIdTipDok + cBrDok
  		
			if !Found()
     				Beep(4)
     				@ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     				Inkey(4)
     				@ m_x+14,m_y+2 SAY space(30)
     				loop
  			else
     				
				aMemo:=parsmemo(txt)
      				
				if len(aMemo)>=5
        				@ m_x+10,m_y+2 SAY padr(trim(aMemo[3]),30)
        				@ m_x+11,m_y+2 SAY padr(trim(aMemo[4]),30)
        				@ m_x+12,m_y+2 SAY padr(trim(aMemo[5]),30)
      				else
         				cTxt:=""
      				endif
      				
				if (LastKey()==K_ESC)
					exit
				endif
				
				cIdPartner:=IdPartner
      				
				@ m_x+14,m_y+2 SAY "Sifra partnera:" GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      			
				read

     				select kalk_pripr
     				locate for BrFaktP=cBrDok 
				// da li je faktura vec prenesena
     				if found()
      					Beep(4)
      					@ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      					inkey(4)
      					@ m_x+8,m_y+2 SAY space(30)
      					loop
     				endif
     				go bottom
     				if brdok==cBrKalk
					nRbr:=val(Rbr)
				endif
     				select fakt
     				if !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       					MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       					LOOP
     				endif
     				do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       					select ROBA
					hseek fakt->idroba
       					select tarifa
					hseek roba->idtarifa
       					select fakt
       					if alltrim(podbr)=="."
          					skip
          					loop
       					endif

       					select kalk_pripr
       					
					private aPorezi:={}
					
					Tarifa(cIdKonto,fakt->idRoba,@aPorezi)
					
					nMPVBP := MpcBezPor(fakt->(kolicina*cijena),aPorezi)
       				
                    append blank
					replace idfirma with cIdFirma, ;
                            rbr with str(++nRbr,3),;
                            idvd with "41", ;
                            brdok with cBrKalk, ;
                            datdok with dDatKalk, ;
                            idpartner with cIdPartner, ;
                            idtarifa with ROBA->idtarifa, ;
                            brfaktp with fakt->brdok, ;
                            datfaktp with fakt->datdok, ;
                            idkonto with cidkonto, ;
                            idzaduz with cidzaduz, ;
                            kolicina with fakt->kolicina, ;
                            idroba with fakt->idroba, ;
                            mpcsapp with fakt->cijena, ;
                            tmarza2 with "%"

					replace rabatv with ;
					     ( nMPVBP * fakt->rabat / ( fakt->kolicina * 100 ) ) // * 1.17

					select fakt
      				skip
     			enddo
			
  			endif
		else

			cFaktFirma := cIdFirma
			cIdTipDok := "11"
			dOdDatFakt := Date()
			dDoDatFakt := Date()
			
  			@ m_x+7,m_y+2 SAY "ID firma FAKT: " GET cFaktFirma
			@ m_x+8,m_y+2 SAY "Datum fakture: " 
  			@ m_x+8,col()+2 SAY "od " GET dOdDatFakt
  			@ m_x+8,col()+2 SAY "do " GET dDoDatFakt
  		
			read
  			
			if (LastKey()==K_ESC)
				exit
			endif

			select fakt
			go top
			
  			do while !eof() 			

				if (idfirma == cFaktFirma .and. ;
					idtipdok == cIdTipDok .and. ;
					datdok >= dOdDatFakt .and. ;
					datdok <= dDoDatFakt)

					cIdPartner := IdPartner
      					
					@ m_x+14, m_y+2 SAY "Sifra partnera:" GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      			
					read

					select kalk_pripr
	     				go bottom
     			
					if brdok == cBrKalk
						nRbr := val(Rbr)
					endif
     			
					select fakt
     			
					if !ProvjeriSif("!eof() .and. '" + cFaktFirma + cIdTipDok + "'==IdFirma+IdTipDok","IDROBA", F_ROBA)
       						MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       						LOOP
     					endif
     			
       					select kalk_pripr
       					
					private aPorezi:={}
					
					Tarifa(cIdKonto,fakt->idRoba,@aPorezi)
					
					nMPVBP:=MpcBezPor(fakt->(kolicina*cijena),aPorezi)
					
					append blank
       			
					replace idfirma with cIdFirma
					replace rbr with str(++nRbr,3)
					replace idvd with "41"
					replace brdok with cBrKalk
					replace datdok with dDatKalk
					replace idpartner with cIdPartner
					replace idtarifa with ROBA->idtarifa
					replace brfaktp with fakt->brdok
					replace datfaktp with fakt->datdok
					replace idkonto with cIdKonto
					replace idzaduz with cIdZaduz
					replace kolicina with fakt->kolicina
					replace idroba with fakt->idroba
					replace mpcsapp with fakt->cijena
					replace tmarza2 with "%"
					replace rabatv with ;
						( nMPVBP*fakt->rabat/(fakt->kolicina*100) ) //* 1.17
       					
					select fakt
      					skip
					loop
     				else
					skip
					loop
				endif
			enddo
     		endif	
		
		@ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
		@ m_x+11,m_y+2 SAY "Obavezno pokrenuti asistenta <opcija A>!!!"
     		
		if gBrojac=="D"
      			cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
     		endif

     		Inkey(0)
     		
		@ m_x+10,m_y+2 SAY SPACE(30)
		@ m_x+11,m_y+2 SAY SPACE(40)
	
	enddo
Boxc()

closeret
return


/*! \fn FaKaPrenos_01_doprema()
 *  \brief Prenos FAKT->KALK (01->81)
 */

function FaKaPrenos_01_doprema()
*{
local cIdFirma:=gFirma,cIdTipDok:="01",cBrDok:=cBrKalk:=space(8)
O_KALK_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320",7)
cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to tag "1";seek cidfirma+"81X"
 skip -1
 if idvd<>"81"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 81 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
   @ m_x+3,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  @ m_x+6,col()+2 SAY "- "+cidtipdok
  @ m_x+6,col()+2 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif


  select fakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
     aMemo:=parsmemo(txt)
      if len(aMemo)>=5
        @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
        @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
        @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
      else
         cTxt:=""
      endif
      cIdPartner:=IdPartner
      @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
      read

     select kalk_pripr
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif
     select fakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek fakt->idroba
       select tarifa; hseek roba->idtarifa

       select fakt
       if alltrim(podbr)=="."
          skip; loop
       endif

       select kalk_pripr
       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "81",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idpartner with cIdPartner,;
               idtarifa with ROBA->idtarifa,;
               brfaktp with fakt->brdok,;
               datfaktp with fakt->datdok,;
               idkonto   with cidkonto,;
               idzaduz  with cidzaduz,;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               mpcsapp with fakt->cijena,;
               fcj with fakt->cijena/(1+tarifa->opp/100)/(1+tarifa->ppp/100),;
               tmarza2 with "%"

       select fakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
  endif

enddo
Boxc()
closeret
return
*}





/*! \fn FaKaPrenos_cm_u_prodavnicu()
 *  \brief Otprema u mp->kalk (13->80) prebaci u prodajni objekt
 */

function FaKaPrenos_cm_u_prodavnicu()
*{
local cIdFirma:=gFirma,cIdTipDok:="13",cBrDok:=cBrKalk:=space(8)

O_KALK_PRIPR
O_KONCIJ
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320999",7)
cIdKonto2:=padr("1320",7)
cIdZaduz2:=cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to tag "1";seek cidfirma+"80X"
 skip -1
 if idvd<>"80"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 80 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif
  @ m_x+4,m_y+2   SAY "CM. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj otpremnice u MP: " GET cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
  @ m_x+6,col()+1 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif


  select fakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
      aMemo:=parsmemo(txt)


     select kalk_pripr
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     if gVar13u11=="2"  .and. EMPTY(fakt->idpartner)
       @ m_x+10,m_y+2   SAY "Prodavn. konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
       read
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif
     select fakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek fakt->idroba

       select tarifa; hseek roba->idtarifa
       select koncij; seek trim(cidkonto)

       select fakt
       if alltrim(podbr)=="."  .or. idroba="U"
          skip; loop
       endif
       cPKonto:=cIdKonto
       private aPorezi:={}
       cIdTarifa:=Tarifa(cPKonto, fakt->idroba , @aPorezi )
       select kalk_pripr;       APPEND BLANK
       replace idfirma with cIdFirma,;
               rbr     with str(++nRbr,3),;
               idvd with "80",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idtarifa with cIdTarifa,;
	       brfaktp with fakt->brdok,;
               datfaktp with fakt->datdok,;
               idkonto   with cidkonto2,;
               idzaduz  with cidzaduz2,;
               idkonto2  with cidkonto,;
               idzaduz2  with cidzaduz,;
               kolicina with -fakt->kolicina,;
               idroba with fakt->idroba,;
               nc with fakt->cijena/(1+tarifa->opp/100)/(1+tarifa->ppp/100),;
               mpc with 0,;
               tmarza2 with "A",;
               tprevoz with "A",;
               mpcsapp with fakt->cijena

       APPEND BLANK // protustavka
       replace idfirma with cIdFirma,;
               rbr     with str(nRbr,3),;
               idvd with "80",;   // izlazna faktura
               brdok with cBrKalk,;
               datdok with dDatKalk,;
               idtarifa with cIdTarifa,;
               brfaktp with fakt->brdok,;
               datfaktp with fakt->datdok,;
               idkonto   with cidkonto,;
               idzaduz  with cidzaduz,;
               idkonto2  with "XXX",;
               idzaduz2  with "",;
               kolicina with fakt->kolicina,;
               idroba with fakt->idroba,;
               nc with fakt->cijena/(1+tarifa->opp/100)/(1+tarifa->ppp/100),;
               mpc with 0,;
               tmarza2 with "A",;
               tprevoz with "A",;
               mpcsapp with fakt->cijena


       select fakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
     @ m_x+10,m_y+2 SAY space(40)
  endif

enddo
Boxc()
closeret
return
*}




/*! \fn FaKaPrenos_izlaz_putem_vp()
 *  \brief Izlaz iz MP putem VP, FAKT15->KALK15
 */

function FaKaPrenos_izlaz_putem_vp()
*{
local cIdFirma:=gFirma,cIdTipDok:="15",cBrDok:=cBrKalk:=space(8)
local dDatPl:=ctod("")
local fDoks2:=.f.

O_KALK_PRIPR
O_KONCIJ
O_KALK
if file(KUMPATH+"DOKS2.DBF"); fDoks2:=.t.; O_KALK_DOKS2; endif
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

O_FAKT

dDatKalk:=date()
cIdKonto:=padr("1320",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=cIdZaduz:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to tag "1";seek cidfirma+"15X"
 skip -1
 if idvd<>"15"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 15 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Magac. konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  @ m_x+4,m_y+2   SAY "Prodavn. konto razduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Zaduzuje:" GET cIdZaduz  pict "@!"      valid empty(cidzaduz) .or. P_Firma(@cIdZaduz)
  endif

  cFaktFirma:=cIdFirma
  @ m_x+6,m_y+2 SAY "Broj fakture: " GET cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
  @ m_x+6,col()+1 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif

  select fakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
     aMemo:=parsmemo(txt)
     if len(aMemo)>=5
       @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
       @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
       @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
     else
        cTxt:=""
     endif
     if len(aMemo)>=9
       dDatPl:=ctod(aMemo[9])
     endif

     cIdPartner:=space(6)
     if !empty(idpartner)
       cIdPartner:=idpartner
     endif
     private cBeze:=" "
     @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
     @ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze
     READ; ESC_BCR

     SELECT kalk_pripr
     LOCATE FOR BrFaktP=cBrDok // faktura je vec prenesena
     IF FOUND()
       Beep(4)
       @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
       INKEY(4)
       @ m_x+8,m_y+2 SAY SPACE(30)
       LOOP
     ENDIF

     GO BOTTOM
     if brdok==cBrKalk; nRbr:=val(Rbr); endif

     select fakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF

     if fdoks2
        select kalk_doks2; hseek cidfirma+"14"+cbrkalk
        if !found()
           append blank
           replace idvd with "14",;   // izlazna faktura
                   brdok with cBrKalk,;
                   idfirma with cidfirma
        endif
        replace DatVal with dDatPl
        select fakt
     endif

     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek fakt->idroba

       select tarifa; hseek roba->idtarifa
       select koncij; seek trim(cidkonto)

       SELECT fakt
       IF ALLTRIM(podbr)=="."  .or. idroba="U"
          SKIP
          LOOP
       ENDIF

       select kalk_pripr
       APPEND BLANK
       replace idfirma   with cIdFirma      ,;
               rbr       with str(++nRbr,3)   ,;
               idvd      with "15"            ,;   // izlaz iz MP putem VP
               brdok     with cBrKalk         ,;
               datdok    with dDatKalk        ,;
               idtarifa  with ROBA->idtarifa  ,;
               brfaktp   with fakt->brdok    ,;
               datfaktp  with fakt->datdok   ,;
               idkonto   with cidkonto        ,;
                pkonto    with cIdKonto        ,;
                 pu_i      with "1"             ,;
               idzaduz   with cidzaduz        ,;
               idkonto2  with cidkonto2       ,;
                mkonto    with cIdKonto2       ,;
                 mu_i      with "8"             ,;
               idzaduz2  with cidzaduz2       ,;
               kolicina  with -fakt->kolicina ,;
               idroba    with fakt->idroba   ,;
               nc        with ROBA->nc        ,;
               vpc       with KoncijVPC()     ,;
               rabatv    with fakt->rabat    ,;
               mpc       with fakt->porez    ,;
               tmarza2   with "A"             ,;
               tprevoz   with "R"             ,;
               idpartner with cIdPartner      ,;
               mpcsapp   with fakt->cijena

       select fakt
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
       cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
     @ m_x+10,m_y+2 SAY space(40)
  endif

enddo
Boxc()
closeret
return


// ------------------------------------------------------
// otvori tabele potrebne za prenos dokumenata
// ------------------------------------------------------
static function _o_prenos_tbls()
O_KALK_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_FAKT
return


// ------------------------------------------------------------------------
// prenos fakt->kalk dokumenti tipa 11 u paragon blok kalk->42
// ------------------------------------------------------------------------
function FaKaPrenosRacunMPParagon()
local _razl_cijene := "D"
local _kalk_tip_dok := "42"
local _auto_razd := 2
local _x := 1
local _x_dok_info := 16
local _zbirni_prenos := "D"
local _dat_kalk := DATE()

private cIdFirma := gFirma
private cIdTipDok := "11"
private cBrDok := SPACE(8)
private cBrKalk := SPACE(8)
private cFaktFirma

cIdKonto := PADR( "1330", 7 )
cIdKtoZad := PADR( "1330", 7 )
cIdZaduz := SPACE(6)
cBrkalk := space(8)

// otvori tabele za prenos...
_o_prenos_tbls()

Box(, 15, 60 ) 

	do while .t.
		
		nRBr := 0

		_x := 1
  		
		@ m_x + _x, m_y + 2 SAY "Generisati kalk dokument (1) 11 (2) 42 ?" GET _auto_razd PICT "9"

		read

		if _auto_razd == 1
			_kalk_tip_dok := "11"
		else
			_kalk_tip_dok := "42"
		endif

		if gBrojac == "D"

 			select kalk
			set order to tag "1"
			seek cIdFirma + _kalk_tip_dok + "X"
 			skip -1
 	
			if field->idvd <> _kalk_tip_dok
   				cBrkalk := SPACE(8)
 			else
   				cBrKalk := field->brdok
 			endif

 			cBrKalk := UBrojDok( VAL( LEFT( cBrKalk, 5 )) + 1, 5, RIGHT( cBrKalk, 3 ) )
	
		endif

		++ _x
		++ _x

		@ m_x + _x, m_y + 2 SAY "Broj kalkulacije " + _kalk_tip_dok + " -" GET cBrKalk pict "@!"
  		@ m_x + _x, col() + 2 SAY "Datum:" GET _dat_kalk

		++ _x

  		@ m_x + _x, m_y + 2 SAY "Konto razduzuje:" GET cIdKonto ;
				PICT "@!" ;
				VALID P_Konto( @cIdKonto )

  		if _auto_razd == 1
			@ m_x + _x, col() + 1 SAY "zaduzuje:" GET cIdKtoZad ;
				PICT "@!" ;
				VALID P_Konto( @cIdKtoZad )
		endif
  		
		if gNW <> "X"
   			@ m_x + _x, col() + 2 SAY "Partner razduzuje:" GET cIdZaduz ;
				PICT "@!" ;
				VALID empty(cIdZaduz) .or. P_Firma(@cIdZaduz)
  		endif
        
		++ _x
		++ _x
	
 		@ m_x + _x, m_y + 2 SAY "Napraviti zbirnu kalkulaciju (D/N): " ;
			GET _zbirni_prenos ;
			VALID _zbirni_prenos $ "DN" ;
			PICT "@!"
		
		++ _x

 		@ m_x + _x, m_y + 2 SAY "Razdvoji artikle razlicitih cijena (D/N): " ;
			GET _razl_cijene ;
			VALID _razl_cijene $ "DN" ;
			PICT "@!"
		
		read

		++ _x
		
		if _zbirni_prenos == "N"

  			cFaktFirma := cIdFirma

  			@ m_x + _x, m_y + 2 SAY "Broj fakture: " GET cFaktFirma
  			@ m_x + _x, col() + 2 SAY "- " + cIdTipDok
  			@ m_x + _x, col() + 2 SAY "-" GET cBrDok

  			read
  		
			if (LastKey()==K_ESC)
				exit
			endif

			select fakt
  			seek cFaktFirma + cIdTipDok + cBrDok
  		
			if !Found()
     			Beep(4)
     			@ m_x + 15, m_y + 2 SAY "Ne postoji ovaj dokument !!"
     			Inkey(4)
     			@ m_x + 15, m_y + 2 SAY space(30)
     			loop
  			else
     		
				aMemo:=parsmemo(txt)

      			if len(aMemo)>=5
        			@ m_x + _x_dok_info, m_y + 2 SAY padr(trim(aMemo[3]),30)
        			@ m_x + 1 + _x_dok_info, m_y + 2 SAY padr(trim(aMemo[4]),30)
        			@ m_x + 2 + _x_dok_info, m_y + 2 SAY padr(trim(aMemo[5]),30)
      			else
         			cTxt:=""
      			endif

      			if (LastKey()==K_ESC)
					exit
				endif

				cIdPartner:=""

     			select kalk_pripr
     			locate for BrFaktP=cBrDok 

				// da li je faktura vec prenesena
     			if found()
      				Beep(4)
      				@ m_x + 15, m_y + 2 SAY "Dokument je vec prenesen !!"
      				inkey(4)
      				@ m_x + 15, m_y + 2 SAY space(30)
      				loop
     			endif

     			go bottom

     			if brdok==cBrKalk
					nRbr:=val(Rbr)
				endif

     			select fakt
     			if !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       				MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       				LOOP
     			endif
     				

				do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok

       				select ROBA
					hseek fakt->idroba

       				select tarifa
					hseek roba->idtarifa

       				select fakt

       				if alltrim(podbr)=="."
          				skip
          				loop
       				endif

       				select kalk_pripr

					private aPorezi:={}
					Tarifa(cIdKonto,fakt->idRoba,@aPorezi)
					nMPVBP:=MpcBezPor(fakt->(kolicina*cijena),aPorezi)

       				APPEND BLANK

       				replace idfirma with cIdFirma
					replace rbr with str(++nRbr,3)
					replace idvd with _kalk_tip_dok
					replace brdok with cBrKalk
					replace datdok with _dat_kalk
					replace idpartner with cIdPartner
					replace idtarifa with ROBA->idtarifa
					replace brfaktp with fakt->brdok
					replace datfaktp with fakt->datdok
					replace idkonto with cidkonto
					replace idzaduz with cidzaduz
					replace kolicina with fakt->kolicina
					replace idroba with fakt->idroba
					replace mpcsapp with fakt->cijena
					replace tmarza2 with "%"
					replace rabatv with nMPVBP*fakt->rabat/(fakt->kolicina*100)

       				select fakt
      				skip

     			enddo
			
  			endif

		else
			
			// zbirni prenos faktura
		
			cFaktFirma := cIdFirma
			cIdTipDok := "11"
			dOdDatFakt := Date()
			dDoDatFakt := Date()
			
  			@ m_x + _x, m_y + 2 SAY "ID firma FAKT: " GET cFaktFirma

			++ _x

			@ m_x + _x, m_y + 2 SAY "Datum fakture: " 
  			@ m_x + _x, col() + 2 SAY "od " GET dOdDatFakt
  			@ m_x + _x, col() + 2 SAY "do " GET dDoDatFakt
  			
			read
  			
			if (LastKey()==K_ESC)
				exit
			endif

			select fakt
			go top
			
  			do while !eof() 				
				
				if ( field->idfirma == cFaktFirma .and. ;
					field->idtipdok == cIdTipDok .and. ;
					field->datdok >= dOdDatFakt .and. ;
					field->datdok <= dDoDatFakt )
					
					cIdPartner := ""

					select kalk_pripr
					go bottom
     			
					if field->brdok == cBrKalk
						nRbr := val(Rbr)
					endif
     			
					select fakt
     			
					if !ProvjeriSif("!eof() .and. '" + cFaktFirma + cIdTipDok + "'==IdFirma+IdTipDok","IDROBA", F_ROBA)
       						MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       						LOOP
     				endif
     			
       				select kalk_pripr
       				locate for idroba == fakt->idroba

					if ( FOUND() ;
					   .and. mpcsapp = fakt->cijena ) ;
					   .or. ( FOUND() ;
					   .and. mpcsapp <> fakt->cijena ;
					   .and. _razl_cijene == "N" )

						// samo odradi append kolicine
						my_rlock()
						replace field->kolicina with ;
							field->kolicina + ;
							fakt->kolicina 
						my_unlock()
					else
					
						private aPorezi:={}

					  	Tarifa(cIdKonto,fakt->idRoba,@aPorezi)

					  	nMPVBP := MpcBezPor(fakt->(kolicina*cijena),aPorezi)

					  	append blank
       			
					  	replace idfirma with cIdFirma
					  	replace rbr with str( ++nRbr, 3 )
					  	replace idvd with _kalk_tip_dok
					  	replace brdok with cBrKalk
					  	replace datdok with _dat_kalk
					  	replace idpartner with cIdPartner
					  	replace idtarifa with ROBA->idtarifa
					  	replace brfaktp with fakt->brdok
					  	replace datfaktp with fakt->datdok
						
						if _auto_razd == 1
							// 11-ka					  
							replace idkonto with cIdKtoZad
							replace idkonto2 with cIdKonto
						else
							// 42-ka
							replace idkonto with cIdKonto
						endif

					  	replace idzaduz with cIdZaduz
					  	replace kolicina with fakt->kolicina
					  	replace idroba with fakt->idroba
					  	replace mpcsapp with fakt->cijena
					  	
						if _auto_razd == 1
							replace tprevoz with "R"
							replace tmarza2 with "A"
						else
							replace tmarza2 with "%"
						endif

					  	replace rabatv with nMPVBP * fakt->rabat/(fakt->kolicina*100)

       				endif

					select fakt
      				skip
					loop
     			else
					skip
					loop
				endif
			enddo
     	endif	
		
		@ m_x+10,m_y+2 SAY "Dokument je prenesen !!"
		@ m_x+11,m_y+2 SAY "Obavezno pokrenuti asistenta <opcija A>!!!"
     		
		if gBrojac=="D"
      		cBrKalk:=UBrojDok(val(left(cBrKalk,5))+1,5,right(cBrKalk,3))
     	endif
     		
		Inkey(4)
     	
		@ m_x+10,m_y+2 SAY SPACE(30)
		@ m_x+11,m_y+2 SAY SPACE(40)
	
	enddo
	
Boxc()

my_close_all_dbf()

return


