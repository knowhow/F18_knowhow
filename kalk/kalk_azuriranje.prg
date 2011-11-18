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



function Azuriranje_kalk_dokumenta(lAuto)
local cidfirma
local cidvd
local cbrdok
local cOdg:="N"
local lgAFin:=gAFin
local lgAMat:=gAMat
// pametno azuriranje
local cPametno:="D" 
local nBrStavki:=0
local lBrStDoks:=.f.

PRIVATE aRezim:={}

if (lAuto == nil)
	lAuto := .f.
endif

if !lAuto .and. Pitanje("p1","Zelite li izvrsiti azuriranje KALK dokumenta (D/N) ?","N")=="N"
	return
endif

O_KALK_PRIPR2
zap
use

// provjerimo ima li vise dokumenata u kalk_pripremi
O_KALK_PRIPR
GO BOTTOM
cTest:=idfirma+idvd+brdok
GO TOP
lViseDok:=.f.
if cTest<>idfirma+idvd+brdok
  Beep(1)
  Msg("U kalk_pripremi je vise dokumenata! Ukoliko zelite da ih azurirate sve#"+;
      "odjednom (npr.ako ste ih preuzeli sa drugog racunara putem diskete)#"+;
      "na sljedece pitanje odgovorite sa 'D' i dokumenti ce biti azurirani#"+;
      "bez provjera koje se vrse pri redovnoj obradi podataka.")
  IF Pitanje(,"Zelite li bezuslovno dokumente azurirati? (D/N)","N")=="D"
    lViseDok:=.t.
    aRezim:={}
    AADD(aRezim, gCijene )
    AADD(aRezim, gMetodaNC )
    gCijene   := "1"
    gMetodaNC := " "
  ENDIF
elseif gCijene=="2"       // ako je samo jedan dokument u kalk_pripremi
	DO WHILE !EOF()         // i strogi rezim rada
    		IF ERROR=="1"
      			Beep(1)
      			Msg("Program je kontrolisuci redom stavke utvrdio da je stavka#"+;
          		"br."+rbr+" sumnjiva! Ukoliko bez obzira na to zelite da izvrsite#"+;
          		"azuriranje ovog dokumenta, na sljedece pitanje odgovorite#"+;
          		"sa 'D'.")
      			IF Pitanje(,"Zelite li dokument azurirati bez obzira na upozorenje? (D/N)","N")=="D"
        			aRezim:={}
        			AADD(aRezim, gCijene )
        			AADD(aRezim, gMetodaNC )
        			gCijene   := "1"
      			ENDIF
      			EXIT
    		ENDIF
    		SKIP 1
  	ENDDO
endif

if gCijene=="2"   // provjera integriteta
close all
O_KALK_DOKS
if fieldpos("ukstavki")<>0
	lBrStDoks:=.t.
endif
if !flock()
	Msg("Neko vec koristi datoteku kalk_doks")
	closeret
endif
O_KALK
if !flock()
	Msg("Neko vec koristi datoteku KALK")
	closeret
endif

O_KALK_PRIPR

if ((TPrevoz=="R" .or. TCarDaz=="R" .or. TBankTr=="R" .or. ;
   TSpedTr=="R" .or. TZavTr =="R" ) .and. idvd $ "10#81" )  .or. ;
   idvd $ "RN"
   O_SIFK
   O_SIFV
    O_ROBA
    O_TARIFA
    O_KONCIJ
    select kalk_pripr
    RaspTrosk(.t.)
    close all
    O_KALK
    O_KALK_PRIPR
endif

select kalk_pripr
go top
nBrDoks:=0
do while !eof()

++nBrDoks
cIdFirma:=idfirma; cidvd:=idvd; cbrdok:=brdok
dDatDok:=datdok
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
 if gMetodaNC<>" " .and. (ERROR=="1" .and. TBANKTR=="X")
   Beep(2)
   MSG("Izgenerisane stavke su ispravljane, azuriranje nece biti izvrseno",6)
   closeret
 endif
 if gMetodaNC<>" " .and. ERROR=="1"
   Beep(2)
   MSG("Utvrdjena greska pri obradi dokumenta, rbr: "+rbr,6)
   closeret
 endif
 if !(IsJerry() .and. cIdVd="4")
 	if gMetodaNC<>" " .and. ERROR==" "
 		Beep(2)
 		MSG("Dokument je izgenerisan, sa <a-F10> izvrsiti njegovu obradu",6)
 		closeret
 	endif
 	if dDatDok<>datdok
 		Beep(2)
 		if Pitanje(,"Datum razlicit u odnosu na prvu stavku. Ispraviti ?","D")=="D"
 			replace datdok with dDatDok
 		else
 			closeret
 		endif
 	endif
 endif
 skip
enddo
select KALK
seek cidFirma+cIdVD+cBrDok
if found()
  Beep(1)
  Msg("Vec postoji dokument pod brojem "+cidfirma+"-"+cidvd+"-"+cbrdok)
  closeret
endif

select kalk_pripr
enddo // eof, kalk_pripr

if gMetodaNC<>" " .and. nBrDoks>1
  Beep(1)
  Msg("U kalk_pripremi je vise dokumenata.Prebaci ih u smece, pa obradi pojedinacno")
  closeret
endif


close all

endif // gcijene

close all
O_KALK_PRIPR
cIdzaduz2:=idzaduz2
do while !eof()
 if idvd<>"24" .and. empty(mu_i) .and. empty(pu_i)
    Beep(2)
    Msg("Stavka broj "+Rbr+". neobradjena , sa <a-F10> pokrenite obradu")
    close all
	return
 endif
 if cidzaduz2<>idzaduz2
    Beep(2)
    Msg("Stavka broj "+Rbr+". razlicito polje RN u odnosu na prvu stavku")
    close all
	return
 endif

 skip
enddo

if gcijene=="2"
	cPametno:="D"
else
 	if gMetodaNC==" "
  		cPametno:="N"
 	elseif lAuto
		cPametno:="D"
	else
  		cPametno:=Pitanje(,"Zelite li formirati zavisne dokumente pri azuriranju","D")
 	endif
endif

if cPametno=="D"

	if !(IsMagPNab() .or. IsMagSNab())
		// ako nije slucaj da je
		// 1. pdv rezim magacin po nabavnim cijenama
		// ili
		// 2. magacin samo po nabavnim cijenama
		
		// nivelacija 10,94,16
		Niv_10()  
	endif
	
	Niv_11()  // nivelacija 11,81

	Otprema() // iz otpreme napravi ulaza
 	Iz13u11()  // prenos iz prodavnice u prodavnicu
 	
	// inventura magacina - manjak / visak
	InvManj()
	
	lOSitInv:=.f.
 	IF IzFMKIni("KALKSI","EvidentirajOtpis","N",KUMPATH)=="D"
   		lOSitInv:=Otpis16SI()
 	ENDIF
endif

O_KALK_DOKS
O_KALK
O_KALK_PRIPR
cIdFirma:=""
aOstaju:={}

do while !eof()

cIdFirma:=idfirma
cIdVd:=idvd
cBrDok:=brdok

do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
 if idvd=="11".and.vpc==0
  Beep(1)
  Msg('VPC = 0, pozovite "savjetnika" sa <Alt-H>!')
  close all
  return
 endif
 skip
enddo

select KALK
seek cidFirma+cIdVD+cBrDok
if found()
  Beep(1)
  Msg("Vec postoji dokument pod brojem "+cidfirma+"-"+cidvd+"-"+cbrdok)
  if !lViseDok
    close all
    return
  else
    AADD(aOstaju,cIdFirma+cIdVd+cBrDok)
  endif
endif

select kalk_pripr
enddo // kalk_pripr
lFormiranje11ke:=.f.

if Generisati11_ku()
	lFormiranje11ke:=.t.
	cBrojZadnje11ke:=SljBrKalk("11",gFirma)
	Generisi11ku_iz10ke(cBrojZadnje11ke)
endif

// AZURIRAJ kalk_priprEMU !!
Tone(360,2)

MsgO("Azuriram kalk_pripremu ...")

select kalk_pripr; go top

select kalk_doks; set order to 3
seek cidfirma+dtos(kalk_pripr->datdok)+chr(255)
skip -1
if datdok==kalk_pripr->datdok
   if  kalk_pripr->idvd $ "18#19" .and. kalk_pripr->TBankTr=="X"    // izgenerisani dokument
     if len(podbr)>1
       cNPodbr:=chr256(asc256(podbr)-3)
     else
       cNPodbr:=chr(asc(podbr)-3)
     endif
   else
     if len(podbr)>1
       cNPodbr:=chr256(asc256(podbr)+6)
     else
       cNPodbr:=chr(asc(podbr)+6)
     endif
   endif
else
  if len(podbr)>1
    cNPodbr:=chr256(30*256+30)
  else
    cNPodbr:=chr(30)
  endif
endif
select kalk_doks
set order to 1
select KALK

select kalk_pripr
nNV:=nVPV:=nMPV:=nRABAT:=0

do while !eof()

	cIdFirma:=idfirma
	cBrDok:=brdok
  	cIdvd:=idvd
  	private nNV:=0
	private nVPV:=0
	private nMPV:=0
	private nRabat:=0  
	// za kalk_doks.DBF
  	
	IF lViseDok .and. ASCAN(aOstaju,cIdFirma+cIdVd+cBrDok)<>0  // preskoci postojece
    		SKIP 1
    		LOOP
  	ENDIF
  	
	select kalk_doks
  	append blank
  	replace idfirma with cidfirma, brdok with cbrdok,;
        	datdok with kalk_pripr->datdok, idvd with cidvd,;
           	idpartner with kalk_pripr->idpartner, mkonto with kalk_pripr->MKONTO,;
          	pkonto with kalk_pripr->PKONTO,;
          	idzaduz with kalk_pripr->idzaduz, idzaduz2 with kalk_pripr->idzaduz2,;
          	brfaktp with kalk_pripr->BrFaktP
  	if fieldpos("sifra")<>0
     		replace sifra with SifraKorisn
  	endif
  
	if Logirati(goModul:oDataBase:cName,"DOK","AZUR")
		
		cOpis := cIDFirma + "-" + cIdVd + "-" + ALLTRIM(cBrDok)

		EventLog(nUser,goModul:oDataBase:cName,"DOK","AZUR",nil,nil,nil,nil,cOpis, "", "", kalk_pripr->datdok, Date(),"","Azuriranje dokumenta")
	
	endif

	#ifdef SR
  		O_LOGK
  		go bottom
  		Scatter()
  		_NO:=NO+1
  		append blank
  		_Id:="AZUR";_datum:=kalk_pripr->datdok; _datprom:=date()
  		_k1:=kalk_pripr->brdok; _k2:=kalk_pripr->brfaktp; Gather()
  		O_LOGKD  
		// otvori logove kumulativa
	#endif

  	select kalk_pripr
  	nBrStavki:=0
  	do while !eof() .and. cidfirma==idfirma .and. cbrdok==brdok .and. cidvd==idvd
   		nBrStavki:=nBrStavki+1
   		Scatter()
   		_Podbr:=cNPodbr
   		select kalk
   		append blank
   		Gather()
   		if cIdVd=="97"
     			append blank
       			_TBankTr := "X"
       			_mkonto  := _idkonto
       			_mu_i    := "1"
     			Gather()
   		endif
   
  		// popunjavanje roba->idpartner
  		// popunjavanje tabele prodnc
  		if IsPlanika()
			PlFillIdPartner(kalk_pripr->idpartner, kalk_pripr->idroba)
			if kalk_pripr->idvd $ "11#12#13#80#81"
				SetProdNc(kalk_pripr->pkonto, kalk_pripr->idroba, kalk_pripr->idvd, kalk_pripr->brdok, kalk_pripr->datdok, kalk_pripr->fcj)
   			endif
  		endif

   		select kalk_pripr

   		if ! ( cIdVd $ "97" )
     			SetZaDoks() 
			// setuj nnv, nmpv ....
   		endif

   		skip
  	enddo

  	select kalk_doks
  	replace nv with nnv, vpv with nvpv, rabat with nrabat, mpv with nmpv, podbr with cNPodbr

  	if lBrStDoks
  		replace ukstavki with nBrStavki
  	endif

  	select kalk_pripr
enddo

MsgC()

select KALK

if cPametno=="D"

 RekapK()
 
 if (gafin=="D" .or. gamat=="D")
   	kalk_kontiranje_naloga( .t., lAuto )
 endif

 P_Fin( lAuto )

 gAFin:=lgAFin
 gAMat:=lgAMat

 O_KALK_PRIPR
 if idvd $ "10#12#13#16#11#95#96#97#PR#RN" .and. gAFakt=="D"
 	if idvd $ "16#96"
 		cOdg:="N"
 	else
 		cOdg:="D"
 	endif
 	if Pitanje(,"Formirati dokument u FAKT ?",cOdg)=="D"
 		P_Fakt()
 	endif
 endif

endif // cpametno=="D"

O_KALK_PRIPR
select kalk_pripr

// azuriraj i kalk_pripremu p_doksrc
p_to_doksrc()

O_KALK_PRIPR
IF lViseDok .and. LEN(aOstaju)>0
  // izbrisi samo azurirane
  GO TOP
  DO WHILE !EOF()
    SKIP 1
    nRecNo:=RECNO()
    SKIP -1
    IF ASCAN(aOstaju,idfirma+idvd+brdok) = 0
      DELETE
    ENDIF
    GO (nRecNo)
  ENDDO
  __dbpack()
  MsgBeep("U kalk_pripremi su ostali dokumenti koji izgleda da vec postoje medju azuriranim!")
ELSE
  select kalk_pripr; zap
ENDIF


if cPametno=="D"

 O_KALK_PRIPR2

 if idvd $ "18#19"  // otprema
  if kalk_pripr2->(reccount2())<>0
   Beep(1)
   Box(,4,70)
    @ m_x+1,m_y+2 SAY "1. Cijene robe su promijenjene."
    @ m_x+2,m_y+2 SAY "2. Formiran je dokument nivelacije:"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
    @ m_x+3,m_y+2 SAY "3. Nove cijene su stavljene u sifrarnik."
    @ m_x+4,m_y+2 SAY "3. Obradite ovaj dokument."
    inkey(0)
   BoxC()
   select kalk_pripr
   append from kalk_pripr2
   select kalk_pripr2; zap
  endif

 elseif idvd $ "95"  // otprema
  if kalk_pripr2->(reccount2())<>0
   Beep(1)
   Box(,4,70)
    @ m_x+1,m_y+2 SAY "1. Formiran je dokument 95 na osnovu inventure."
    @ m_x+4,m_y+2 SAY "3. Obradite ovaj dokument."
    inkey(0)
   BoxC()
   select kalk_pripr
   append from kalk_pripr2
   select kalk_pripr2; zap
  endif


 elseif idvd $ "16"  .and. gGen16=="1" 
   // nakon otpreme doprema

  if kalk_pripr2->(reccount2())<>0
   Beep(1)
   Box(,4,70)
    if lOSitInv   // logicka: Otpis SITnog INVentara
      @ m_x+1,m_y+2 SAY "1. Otpis se evidentira na mjestu troska: "+pripr2->idkonto
      @ m_x+2,m_y+2 SAY "2. Formiran je dokument :"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
      @ m_x+3,m_y+2 SAY "3. Obradite ovaj dokument."
    else
      @ m_x+1,m_y+2 SAY "1. Roba je otpremljena u magacin "+pripr2->idkonto
      @ m_x+2,m_y+2 SAY "2. Formiran je dokument dopreme:"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
      @ m_x+3,m_y+2 SAY "3. Obradite ovaj dokument."
    endif
    inkey(0)
   BoxC()
   select kalk_pripr
   append from kalk_pripr2
   select kalk_pripr2; zap
  endif

 elseif idvd $ "11"  // nakon povrata unos u drugu prodavnicu
  if kalk_pripr2->(reccount2())<>0
   Beep(1)
   Box(,4,70)
    @ m_x+1,m_y+2 SAY "1. Roba je prenesena u prodavnicu "+pripr2->idkonto
    @ m_x+2,m_y+2 SAY "2. Formiran je dokument zaduzenja:"+pripr2->(idfirma+"-"+idvd+"-"+brdok)
    @ m_x+3,m_y+2 SAY "3. Obradite ovaj dokument."
    inkey(0)
    BoxC()
   select kalk_pripr
   append from kalk_pripr2
   select kalk_pripr2; zap
  endif
 endif

endif // cPametno=="D"


if lFormiranje11ke
	Get11FromSmece(cBrojZadnje11ke)
endif

close all
return


function Azur9()
local cPametno:="D" 

if Pitanje("p1","Zelite li kalk_pripremu prebaciti u smece (D/N) ?","N")=="N"
  return
endif

O_KALK_PRIPR9
O_KALK_PRIPR
do while !eof()

cIdFirma:=idfirma
cIdvd:=idvd
cBrdok:=brdok

do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
 skip
enddo

select kalk_pripr9
seek cidFirma+cIdVD+cBrDok
if found()
  Beep(1)
  Msg("U smecu vec postoji "+cidfirma+"-"+cidvd+"-"+cbrdok)
  closeret
endif

select kalk_pripr
enddo // kalk_pripr

select  kalk_pripr; go top

select kalk_pripr9
append from kalk_pripr

select kalk_pripr
go top

if Logirati(goModul:oDataBase:cName, "DOK", "SMECE")
	cOpis := cIdFirma + "-" + ;
		cIdvd + "-" + ;
		cBrdok

	EventLog(nUser, goModul:oDataBase:cName,"DOK","SMECE", ;
	nil,nil,nil,nil,;
	cOpis, "", "", ;
	kalk_pripr->datdok, DATE(), ;
	"", "prebacivanje dokumenta u smece")
endif

select kalk_pripr; zap

closeret



/*! \fn Povrat_kalk_dokumenta()
 *  \brief Povrat kalkulacije u kalk_pripremu
 */

function Povrat_kalk_dokumenta()
*{
local nRec
local gEraseKum

gEraseKum:=.f.

if Klevel<>"0"
  Beep(2)
  Msg("Nemate pristupa ovoj opciji !",4)
  closeret
endif

if gCijene=="2" .and. Pitanje(,"Zadati broj (D) / Povrat po hronologiji obrade (N) ?","D")="N"
	Beep(1)
  	PNajn()
  	closeret
endif

O_KALK_DOKS

O_KALK
set order to 1

O_KALK_PRIPR

SELECT KALK
set order to 1  // idFirma+IdVD+BrDok+RBr

cIdFirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

Box("",1,35)
	@ m_x+1,m_y+2 SAY "Dokument:"
 	if gNW $ "DX"
   		@ m_x+1,col()+1 SAY cIdFirma
 	else
   		@ m_x+1,col()+1 GET cIdFirma
 	endif
 	@ m_x+1,col()+1 SAY "-" GET cIdVD pict "@!"
 	@ m_x+1,col()+1 SAY "-" GET cBrDok
 	read
 	ESC_BCR
BoxC()

if cBrDok="."
	if !SigmaSif()
     		closeret
  	endif
	private qqBrDok:=qqDatDok:=qqIdvD:=space(80)
  	qqIdVD:=padr(cidvd+";",80)
  	Box(,3,60)
   		do while .t.
    		@ m_x+1,m_y+2 SAY "Vrste kalk.    "  GEt qqIdVD pict "@S40"
    		@ m_x+2,m_y+2 SAY "Broj dokumenata"  GEt qqBrDok pict "@S40"
    		@ m_x+3,m_y+2 SAY "Datumi         " GET  qqDatDok pict "@S40"
    		read
    		private aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
    		private aUsl2:=Parsiraj(qqDatDok,"DatDok","D")
    		private aUsl3:=Parsiraj(qqIdVD,"IdVD","C")
    		if aUsl1<>NIL .and. aUsl2<>NIL .and. ausl3<>NIL
      			exit
    		endif
   		enddo
  	Boxc()

  	if Pitanje(,"Povuci u kalk_pripremu kalk sa ovim kriterijom ?","N")=="D"
    		gEraseKum:=Pitanje(,"Izbrisati dokument iz kumulativne tabele ?", "D")=="D"
    		select kalk
    		if !flock()
			Msg("KALK je zauzeta ",3)
			closeret
		endif
    		PRIVATE cFilt1:=""
    		cFilt1 := "IDFIRMA=="+cm2str(cIdFirma)+".and."+aUsl1+".and."+aUsl2+".and."+aUsl3
    		cFilt1 := STRTRAN(cFilt1,".t..and.","")
    		IF !(cFilt1==".t.")
      			SET FILTER TO &cFilt1
    		ENDIF
    		select kalk
		go top
    		MsgO("Prolaz kroz kumulativnu datoteku KALK...")
    		do while !eof()
      			select KALK
			Scatter()
			select kalk_pripr
      			
			IF ! ( _idvd $ "97" .and. _tbanktr=="X" )
        			append ncnl; _ERROR:="";  Gather2()
      			ENDIF
			
			if gEraseKum
      				select kalk_doks
				seek kalk->(idfirma+idvd+brdok)   // izbrisi u kalk_doks
      				if Found() 
					delete
				endif
			endif
			
			select kalk
      			skip
			
			nRec:=recno()
			
			skip -1
      			
			if gEraseKum
				dbdelete2()
			endif
      			
			go nRec
    		enddo
    		select kalk
		
		MsgC()
  	endif
  	closeret
endif

if Pitanje("","Kalk. "+cIdFirma+"-"+cIdVD+"-"+cBrDok+" povuci u kalk_pripremu (D/N) ?","D")=="N"
	closeret
endif

gEraseKum:=Pitanje(,"Izbrisati dokument iz kumulativne tabele ?", "D")=="D"


select KALK
if !flock()
	Msg("KALK je zauzeta ",3)
	closeret
endif

hseek cIdFirma+cIdVd+cBrDok
EOF CRET

MsgO("Prebacujem u kalk_pripremu...")
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
	select KALK
	Scatter()
   	select kalk_pripr
   	IF ! ( _idvd $ "97" .and. _tbanktr=="X" )
     		append ncnl;_ERROR:="";  Gather2()
   	ENDIF
   	select KALK
   	skip
enddo
MsgC()

if gEraseKum
	MsgO("Brisem dokument iz KALK-a")
	select KALK
	seek cIdFirma+cIdVd+cBrDok
	do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok

   		select kalk_doks; seek kalk->(idfirma+idvd+brdok)   // izbrisi u kalk_doks
   		if found(); delete; endif
		select kalk
   		skip 1; nRec:=recno(); skip -1
   		dbdelete2()
   		go nRec
	enddo

	if Logirati(goModul:oDataBase:cName,"DOK","POVRAT")
		
		cOpis := idfirma + "-" + idvd + "-" + ALLTRIM(brdok)
		EventLog(nUser, goModul:oDataBase:cName,"DOK","POVRAT",nil,nil,nil,nil,cOpis,"","",datdok,Date(),"","KALK - Povrat dokumenta u kalk_pripremu")
	endif

	// vrati i dokument iz kalk_doksRC
	povrat_doksrc(cIdFirma, cIdVd, cBrDok)
endif

select kalk_doks
use
select kalk
use

MsgC()

closeret
return



// iz kalk_pripr 9 u kalk_pripr

/*! \fn Povrat9()
 *  \brief Povrat kalkulacije iz "smeca" u kalk_pripremu
 */

function Povrat9(cIdFirma, cIdVd, cBrDok)
*{
local nRec

if Klevel<>"0"
	Beep(2)
    	Msg("Nemate pristupa ovoj opciji !",4)
    	CLOSERET
endif

lSilent := .t.

O_KALK_PRIPR9
O_KALK_PRIPR

SELECT kalk_pripr9
set order to 1  // idFirma+IdVD+BrDok+RBr

if ((cIdFirma == nil) .and. (cIdVd == nil) .and. (cBrDok == nil))
	lSilent := .f.
endif

if !lSilent
	cIdFirma:=gFirma
	cIdVD:=SPACE(2)
	cBrDok:=SPACE(8)
endif

if !lSilent
	Box("",1,35)
 		@ m_x+1,m_y+2 SAY "Dokument:"
 		if gNW $ "DX"
   			@ m_x+1,col()+1 SAY cIdFirma
 		else
   			@ m_x+1,col()+1 GET cIdFirma
 		endif
 		@ m_x+1,col()+1 SAY "-" GET cIdVD
 		@ m_x+1,col()+1 SAY "-" GET cBrDok
 		read
 		ESC_BCR
	BoxC()

  if cBrDok="."
  private qqBrDok:=qqDatDok:=qqIdvD:=space(80)
  qqIdVD:=padr(cidvd+";",80)
  Box(,3,60)
   do while .t.
    @ m_x+1,m_y+2 SAY "Vrste dokum.   "  GEt qqIdVD pict "@S40"
    @ m_x+2,m_y+2 SAY "Broj dokumenata"  GEt qqBrDok pict "@S40"
    @ m_x+3,m_y+2 SAY "Datumi         " GET  qqDatDok pict "@S40"
    read
    private aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
    private aUsl2:=Parsiraj(qqDatDok,"DatDok","D")
    private aUsl3:=Parsiraj(qqIdVD,"IdVD","C")
    if aUsl1<>NIL .and. aUsl2<>NIL .and. ausl3<>NIL
      exit
    endif
   enddo
  Boxc()

 if Pitanje(,"Povuci u kalk_pripremu dokumente sa ovim kriterijom ?","N")=="D"
    select kalk_pripr9
    if !flock(); Msg("PRIPR9 - SMECE je zauzeta ",3); closeret; endif
    PRIVATE cFilt1:=""
    cFilt1 := "IDFIRMA=="+cm2str(cIdFirma)+".and."+aUsl1+".and."+aUsl2+".and."+aUsl3
    cFilt1 := STRTRAN(cFilt1,".t..and.","")
    IF !(cFilt1==".t.")
      SET FILTER TO &cFilt1
    ENDIF
    go top
    MsgO("Prolaz kroz SMECE...")
    do while !eof()
      select kalk_pripr9; Scatter()
      select kalk_pripr
      append ncnl;_ERROR:="";  Gather2()
      select kalk_pripr9
      skip; nRec:=recno(); skip -1
      dbdelete2()
      go nRec
    enddo
    MsgC()
  endif
  closeret
endif

endif // lSilent

if Pitanje("","Iz smeca "+cIdFirma+"-"+cIdVD+"-"+cBrDok+" povuci u kalk_pripremu (D/N) ?","D")=="N"
	if !lSilent
		CLOSERET
	else
		return
	endif
endif

select kalk_pripr9

hseek cIdFirma+cIdVd+cBrDok
EOF CRET

MsgO("PRIPREMA")
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
   select kalk_pripr9; Scatter()
   select kalk_pripr
   append ncnl;_ERROR:="";  Gather2()
   select kalk_pripr9
   skip
enddo

select kalk_pripr9
seek cidfirma+cidvd+cBrDok
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
   skip 1; nRec:=recno(); skip -1
   dbdelete2()
   go nRec
enddo
use
MsgC()

if !lSilent
	closeret
endif

O_KALK_PRIPR9
select kalk_pripr9

return
*}


// iz kalk_pripr 9 u kalk_pripr najstariju kalkulaciju

/*! \fn P9najst()
 *  \brief Povrat najstarije kalkulacije iz "smeca" u kalk_pripremu
 */

function P9najst()
*{
local nRec

if Klevel<>"0"
    Beep(2)
    Msg("Nemate pristupa ovoj opciji !",4)
    closeret
endif


O_KALK_PRIPR9
O_KALK_PRIPR

//CREATE_INDEX(PRIVPATH+"PRIPR9i3","dtos(datdok)+mu_i+pu_i",PRIVPATH+"PRIPR9")
SELECT kalk_pripr9; set order to 3  // str(datdok)
cidfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

if Pitanje(,"Povuci u kalk_pripremu najstariji dokument ?","N")=="N"
  closeret
endif
select kalk_pripr9
if !flock(); Msg("PRIPR9 - SMECE je zauzeta ",3); closeret; endif
go top

cidfirma:=idfirma
cIdVD:=idvd
cBrDok:=brdok

MsgO("PRIPREMA")
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
  select kalk_pripr9; Scatter()
  select kalk_pripr
  append ncnl;_ERROR:="";  Gather2()
  select kalk_pripr9
  skip
enddo
//CREATE_INDEX(PRIVPATH+"PRIPR9i1","idFirma+IdVD+BrDok+RBr",PRIVPATH+"PRIPR9")

set order to 1
select kalk_pripr9
seek cidfirma+cidvd+cBrDok
do while !eof() .and. cIdFirma==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
   skip 1; nRec:=recno(); skip -1
   dbdelete2()
   go nRec
enddo
use
MsgC()

closeret
*}



// iz kalk u kalk_pripr najnoviju kalkulaciju

/*! \fn Pnajn()
 *  \brief Povrat najnovije kalkulacije u kalk_pripremu
 */

function Pnajn()
*{
local nRec,cbrsm, fbof, nVraceno:=0

if Klevel<>"0"
    Beep(2)
    Msg("Nemate pristupa ovoj opciji !",4)
    closeret
endif

O_KALK_DOKS
O_KALK
O_KALK_PRIPR

SELECT kalk; set order to 5  // str(datdok)
cidfirma:=gfirma
cIdVD:=space(2)
cBrDok:=space(8)

if !flock(); Msg("KALK je zauzeta ",3); closeret; endif
go bottom
cidfirma:=idfirma
dDatDok:=datdok

if eof(); Msg("Na stanju nema dokumenata.."); closeret; endif

if Pitanje(,"Vratiti u kalk_pripremu dokumente od "+dtoc(dDatDok)+" ?","N")=="N"
  closeret
endif
select kalk

MsgO("Povrat dokumenata od "+dtoc(dDatDok)+" u kalk_priprEMU")
do while !bof() .and. cIdFirma==IdFirma .and. datdok==dDatDok
 cIDFirma:=idfirma; cIdvd:=idvd; cBrDok:=brdok
 cBrSm:=""
 do while !bof() .and. cIdFirma==IdFirma .and. cidvd==idvd .and. cbrdok==brdok
  select kalk; Scatter()
  if !( _tbanktr=="X")
   select kalk_pripr                           // izlaz, a izgenerisana je
   append ncnl;  _ERROR:=""; Gather2()    // u tom slucaju nemoj je
   nVraceno++
  elseif  _tbanktr=="X" .and. (_mu_i=="5" .or. _pu_i=="5")
    select kalk_pripr
    if rbr<>_rbr  .or. (idfirma+idvd+brdok)<>_idfirma+_idvd+_brdok
      nVraceno++
      append ncnl; _ERROR:=""
    else // na{tiklaj na postojecu stavku
      _kolicina+=kalk_pripr->kolicina
    endif
    _TBankTr:="";_ERROR:=""; Gather2()

  elseif  _tbanktr=="X" .and. (_mu_i=="3" .or. _pu_i=="3")
   if cBrSm<>(cBrSm:=idfirma+"-"+idvd+"-"+brdok)     // vracati, samo je izbrisi
     Beep(1)
     Msg("Dokument: "+cbrsm+" je izgenerisan,te je izbrisan bespovratno")
   endif
  endif
  
  select kalk
  skip -1
  
  if bof()
    fBof:=.t.
    nRec:=0
  else
    fBof:=.f.
    nRec:=recno()
    skip 1
  endif

  select kalk_doks
  seek kalk->(idfirma+idvd+brdok)   // izbrisi u kalk_doks
  if found()
  	delete
  endif

  select kalk
  dbdelete2()
  go nRec
  if fBof
  	exit
  endif
 enddo
 //if nVraceno>0; exit; endif  // vrati sve od tog datuma
enddo // bof()
MsgC()

closeret
*}


/*! \fn ErPripr9(cIdF, cIdVd, cBrDok)
 *  \brief Brise dokument iz tabele kalk_pripr9
 */
function ErPripr9(cIdF, cIdVd, cBrDok)
*{
if Pitanje(,"Sigurno zelite izbrisati dokument?","N")=="N"
	return
endif

select kalk_pripr9
seek cIdF+cIdVd+cBrDok

do while !eof() .and. cIdF==IdFirma .and. cIdVD==IdVD .and. cBrDok==BrDok
	skip 1
	nRec:=RecNo()
	skip -1
   	dbdelete2()
   	go nRec
enddo

return
*}


/*! \fn ErP9All()
 *  \brief Brisi sve zapise iz tabele kalk_pripr9
 */
function ErP9All()
*{

if Pitanje(,"Sigurno zelite izbrisati sve zapise?","N")=="N"
	return
endif

select kalk_pripr9
go top
zap

return
*}

