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


function P_Fakt()
local cIdFirma:=gFirma,cIdTipDok:="10",cBrDok:=space(8),cBrFakt
local cDir:=space(25), cFaktFirma:="", lRJKonto:=.f.
local lRJKon97:=.f.
local lRJKon97_2:=.f.
local cFF97:=""
local cFF97_2:=""
local cIdFakt97:="01"
local cIdFakt97_2:="19"

cOldVar10 := IzFMKIni("PrenosKALK10_FAKT","NazivPoljaCijeneKojaSePrenosiIzKALK","-",KUMPATH)   // nekad bilo FCJ
cOldVar16 := IzFMKIni("PrenosKALK16_FAKT","NazivPoljaCijeneKojaSePrenosiIzKALK","-",KUMPATH)   // nekad bilo NC

O_FAKT
O_FAKT_PRIPR
O_PARTN
O_KONTO
O_KALK_PRIPR
USE (gDirFakk+"RJ.DBF") NEW; set order to tag "ID"
SELECT PRIPR

Box(,3,60)

do while .t.
  cIdFirma:=pripr->idfirma

  SELECT RJ; GO TOP

  IF pripr->idvd $ "97"
	  LOCATE FOR konto==PRIPR->idkonto2
	  if found()
		  lRJKon97_2:=.t.
		  cFF97_2:=id
	  endif
	  GO TOP
	  LOCATE FOR konto==PRIPR->idkonto
	  if found()
		  lRJKon97:=.t.
		  cFF97:=id
	  endif
  	  if !(lRJKon97.or.lRJKon97_2)
		  // ako nijedan konto ne postoji u RJ.DBF u FAKT-u, nece se
		  // formirati FAKT dokument za KALK 97-icu
		  exit
	  endif
  ELSE
	  IF pripr->idvd $ "11#12#13#95#96"
	    LOCATE FOR konto==PRIPR->idkonto2
	  ELSE
	    LOCATE FOR konto==PRIPR->idkonto
	  ENDIF

	  IF FOUND()
	    lRJKonto:=.t.     // ovo znaci da se oznaka firme u FAKT-dokumentu
	    cFaktFirma:=id    // uzima iz sifrarnika RJ koji se nalazi u FAKT-u
	  ELSE
	    cFaktFirma:=cIdFirma
	  ENDIF
  ENDIF

  SELECT PRIPR

  // cFaktFirma je uvedena za slucaj komisiona koji se treba voditi u
  // FAKT-u pod drugom radnom jedinicom (definicija u parametrima - gKomFakt)
  // gKomKonto je konto komisiona definisan takodje u parametrima
  /////////////
  IF pripr->idvd=="16".and.pripr->idkonto==gKomKonto
    cFaktFirma:=gKomFakt
  ENDIF

  cIdTipDok:=pripr->idvd
  cBrDok:=pripr->brdok
  read

  select XFAKT
  private gNumDio:=5, cIdFakt:=""

  if pripr->idvd $ "97"
    cBrFakt:=cidtipdok+"-"+right(alltrim(cBrDok),5)

    if lRJKon97
    	seek cFF97+cIdFakt97+cBrFakt
    	@ m_x+2,m_y+2 SAY "Broj dokumenta u modulu FAKT: "+cFF97+" - "+cIdFakt97+" - " + cBrFakt
    	if found()
    		Beep(4)
    		Box(,1,50)
    		@ m_x+1,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
    		inkey(0)
    		BoxC()
    		exit
    	endif
    endif

    if lRJKon97_2
    	seek cFF97_2+cIdFakt97_2+cBrFakt
    	@ m_x+3,m_y+2 SAY "Broj dokumenta u modulu FAKT: "+cFF97_2+" - "+cIdFakt97_2+" - " + cBrFakt
    	if found()
    		Beep(4)
    		Box(,1,50)
    		@ m_x+1,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
    		inkey(0)
    		BoxC()
    		exit
    	endif
    endif

  elseif pripr->idvd $ "10#16#PR#RN"
    cIdFakt:="01"
    
    //cBrFakt:=cidtipdok+"-"+right(alltrim(cBrDok),5)
    cBrFakt:=right(alltrim(cBrDok),6)
    
    seek cFaktFirma+cidfakt+cBrFakt
  else
    if pripr->idvd $ "11#12#13"
       cIdFakt:="13"
    elseif pripr->idvd $ "95#96"
       cIdFakt:="19"
    endif
//    seek pripr->idfirma+cidfakt+"È"
    seek cFaktFirma+cidfakt+"È"
    skip -1
    if  cidfakt<>idtipdok
        cbrfakt:=padr("00001",len(brdok))
    else
       cbrfakt:=padl(alltrim(str(val(left(brdok,gNumDio))+1)),gNumDio,"0")+right(brdok,len(brdok)-gNumDio)
    endif
    seek cFaktFirma+cidfakt+cBrFakt
  endif

  if pripr->idvd<>"97"
  	@ m_x+2,m_y+2 SAY "Broj dokumenta u modulu FAKT: "+cFaktFirma+" - "+cidfakt+" - " + cBrFakt
  	//read
  	//if lastkey()==K_ESC; exit; endif

  	if found()
     		Beep(4)
     		Box(,1,50)
      		@ m_x+1,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
      		inkey(0)
     		BoxC()
     		exit
  	endif
  endif

     select PRIPR
     fFirst:=.t.
     do while !eof() .and. cIdFirma+cIdTipDok+cBrDok==IdFirma+IdVD+BrDok

       private nKolicina:=pripr->(kolicina-gkolicina-gkolicin2)
       if pripr->idvd $ "12#13"  // ove transakcije su storno otpreme
           nKolicina:=-nKolicina
       endif

       if pripr->idvd $ "PR#RN"
           if val(pripr->rbr)>899
		skip
		loop
	   endif
       endif

       select XPRIPR
       if pripr->idvd=="97"
		if lRJKon97
		       	hseek cFF97+pripr->(cIdFakt97+cBrFakt+rbr)
		       	if found()
		        	replace kolicina with kolicina+nkolicina
		       	else
		        	APPEND BLANK
				replace idfirma with cFF97
				replace idtipdok with cIdFakt97
				replace brdok with cBrFakt
				replace rbr with pripr->rbr
		        	replace kolicina with nkolicina
		       	endif
		endif
		if lRJKon97_2
		       	hseek cFF97_2+pripr->(cIdFakt97_2+cBrFakt+rbr)
		       	if found()
		        	replace kolicina with kolicina+nkolicina
		       	else
		        	APPEND BLANK
				replace idfirma with cFF97_2
				replace idtipdok with cIdFakt97_2
				replace brdok with cBrFakt
				replace rbr with pripr->rbr
		        	replace kolicina with nkolicina
		       	endif
		endif
       elseif (pripr->idvd=="16" .and. IsVindija())
       	APPEND BLANK
       	replace kolicina with nkolicina
       else
       	hseek cFaktFirma+pripr->(cIdFakt+cBrFakt+rbr)
       	if found()
        	replace kolicina with kolicina+nkolicina
       	else
        	APPEND BLANK
        	replace kolicina with nkolicina
       	endif
       endif

       if ffirst
	   if pripr->idvd=="97"
		if lRJKon97
          		select XPRIPR
		       	hseek cFF97+pripr->(cIdFakt97+cBrFakt+rbr)
           		select konto; hseek PRIPR->idkonto
           		cTxta:=padr(pripr->idkonto,30)
           		cTxtb:=padr(konto->naz,30)
           		cTxtc:=padr("",30)
           		ctxt:=Chr(16)+" " +Chr(17)+;
           		      Chr(16)+" "+Chr(17)+;
           		      Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
           		      Chr(16)+cTxtc+Chr(17)
          		select XPRIPR
          		replace txt with ctxt
		endif
 		if lRJKon97_2
          		select XPRIPR
		       	hseek cFF97_2+pripr->(cIdFakt97_2+cBrFakt+rbr)
           		select konto; hseek PRIPR->idkonto2
           		cTxta:=padr(pripr->idkonto2,30)
           		cTxtb:=padr(konto->naz,30)
           		cTxtc:=padr("",30)
           		ctxt:=Chr(16)+" " +Chr(17)+;
           		      Chr(16)+" "+Chr(17)+;
           		      Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
           		      Chr(16)+cTxtc+Chr(17)
          		select XPRIPR
          		replace txt with ctxt
		endif
         	fFirst:=.f.
	   else
           	select PARTN; hseek PRIPR->idpartner
           	if pripr->idvd $ "11#12#13#95#PR#RN"
           	   select konto; hseek PRIPR->idkonto
           	   cTxta:=padr(pripr->idkonto,30)
           	   cTxtb:=padr(konto->naz,30)
           	   cTxtc:=padr("",30)
           	else
           	  cTxta:=padr(naz,30)
           	  cTxtb:=padr(naz2,30)
           	  cTxtc:=padr(mjesto,30)
           	endif
           	inkey(0)
           	ctxt:=Chr(16)+" " +Chr(17)+;
           	      Chr(16)+" "+Chr(17)+;
           	      Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
           	      Chr(16)+cTxtc+Chr(17)
           	fFirst:=.f.

          	select XPRIPR
          	replace txt with ctxt
          endif
       endif

       for i:=1 to 2

	       if pripr->idvd=="97"
		       if i==1
				if !lRJKon97
					loop
				endif
		        	hseek cFF97+pripr->(cIdFakt97+cBrFakt+rbr)
		       else
				if !lRJKon97_2
					loop
				endif
		    	   	hseek cFF97_2+pripr->(cIdFakt97_2+cBrFakt+rbr)
		       endif
	       else
		       replace idfirma  with IF(cFaktFirma!=cIdFirma.or.lRJKonto,cFaktFirma,pripr->idfirma)
		       replace rbr      with pripr->Rbr
		       replace idtipdok with cIdFakt   // izlazna faktura
		       replace brdok    with cBrFakt
	       endif


	       replace datdok   with pripr->datdok
	       replace idroba   with pripr->idroba
	       replace cijena   with pripr->vpc      // bilo je fcj sto je pravo bezveze
	       replace rabat    with 0               // kakav crni rabat
	       replace dindem   with "KM "

	       if pripr->idvd == "10" .and. cOldVar10<>"-"
	          replace cijena with pripr->(&cOldVar10)
	       elseif pripr->idvd == "16" .and. cOldVar16<>"-"
	          replace cijena with pripr->(&cOldVar16)
	       elseif pripr->idvd $ "11#12#13"
	          replace cijena with pripr->mpcsapp   // ove dokumente najvise interesuje mpc!
	       elseif pripr->idvd $ "PR#RN"
	          replace cijena with pripr->vpc
	       elseif pripr->idvd $ "95"
	          replace cijena with pripr->VPC
	       elseif pripr->idvd $ "16"
	          replace cijena with pripr->vpc       // i ovdje je bila nc pa sam stavio vpc
	       endif

	       IF lPoNarudzbi .and. FIELDPOS("IDNAR")<>0
		  REPLACE idnar WITH PRIPR->idnar, brojnar WITH PRIPR->brojnar
	       ENDIF

	       if pripr->idvd<>"97"
	       		exit
	       endif       
       next

       select PRIPR
       skip
     enddo
     Beep(1)
   exit
enddo
Boxc()

close all
Azur()
closeret2
return
*}




/*! \fn Azur()
 *  \brief Azuriranje FAKT-dokumenta
 */

static function Azur()
*{
O_FAKT_PRIPR
O_FAKT
O_FAKT_DOKS
O_VALUTE

if !( FAKT->(flock()) ) .or. !( FAKT_DOKS->(flock()) )
    Beep(4)
    BoxC()
    Msg("Azuriranje NE moze vrsiti vise korisnika istovremeno !",4)
    close all
endif

select fakt
seek fakt_pripr->(idfirma+idtipdok+brdok)
if found()
  Beep(4)
  Msg("Dokument vec postoji pod istim brojem...",4)
  return
endif
append from fakt_pripr

select fakt_pripr
go top
do while !eof()
  select fakt_doks
  append blank
  select fakt_pripr

  cIDFirma:=idfirma
  cBrDok:=BrDok; cIdTipDok:=IdTipDok
  aMemo:=ParsMemo(txt)
  if len(aMemo)>=5
    cTxt:=trim(amemo[3])+" "+trim(amemo[4])+","+trim(amemo[5])
  else
    cTxt:=""
  endif
  cTxt:=padr(cTxt,30)

  nDug:=nRab:=0
  nDugD:=nRabD:=0
  cDinDem:=dindem
  cRezerv:=" "
  if cidtipdok=="20" .and. Serbr="*"
     cRezerv:="*"
  endif
  select fakt_doks
  replace idfirma with cidfirma, brdok with cbrdok,;
          rezerv with cRezerv, datdok with fakt->datdok, idtipdok with cidtipdok,;
          partner with cTxt, dindem with cdindem
  if fieldpos("sifra")<>0
    replace sifra with sifrakorisn
  endif

  select fakt_pripr
  if gBaznaV=="P"
    cIBaznaV:=ValPomocna()
  else
    cIBaznaV:=ValDomaca()
  endif
  cIBaznaV:=left(cIBaznaV,3)
  do while !eof() .and. cIdFirma==IdFirma .and. cIdTipdok==IdTipDok .and. cBrDok==BrDok
    if cdindem==cIBaznaV
        nDug+=Cijena*kolicina*(1-Rabat/100)*(1+Porez/100)
        nRab+=Cijena*kolicina*Rabat/100
    else
        nDugD+=Cijena*kolicina*Kurs(datdok,gBaznaV)*(1-Rabat/100)*(1+Porez/100)
        nRabD+=Cijena*kolicina*Kurs(datdok,gBaznaV)*Rabat/100
    endif
    skip
  enddo

  select fakt_doks
  if cDinDem==cIBaznaV
   replace iznos with nDug
   replace rabat with nRab
  else
   replace iznos with nDugD
   replace rabat with nRabD
  endif
  replace DINDEM with cDinDEM
  select fakt_pripr

enddo

select fakt_pripr; zap

close all
return




/*! \fn kalk_prenos_modem(fSif)
 *  \brief
 */
 
function kalk_prenos_modem(fSif)
*{
local nRec, gModemVeza:="S"

if gFakt<>"0 " .and. Pitanje(,"Izvrsiti prenos u FAKT modemom ?","D")=="D"
 
if fSif==NIL;  fSif:=.f.; endif

if fSif
	O_KALK_PRIPR
endif

O_FAKT_PRIPR
select fakt_pripr
copy structure extended to struct

// dodacu jos par polja u struct
my_use( "struct", "NEW" )
dbappend()
replace field_name with "VPC" , field_type with "N", ;
        field_len with 12, field_dec with 3
dbappend()
replace field_name with "VPC2" , field_type with "N", ;
        field_len with 12, field_dec with 3
dbappend()
replace field_name with "MPC" , field_type with "N", ;
        field_len with 12, field_dec with 3
dbappend()
replace field_name with "MPC2" , field_type with "N", ;
        field_len with 12, field_dec with 3
dbappend()
replace field_name with "MPC3" , field_type with "N", ;
        field_len with 12, field_dec with 3
dbappend()
replace field_name with "ROBNAZ" , field_type with "C", ;
        field_len with 250, field_dec with 0
dbappend()
replace field_name with "IDTARIFA" , field_type with "C", ;
        field_len with 6, field_dec with 0
dbappend()
replace field_name with "JMJ" , field_type with "C", ;
        field_len with 6, field_dec with 0

use


select (F__FAKT)
create (PRIVPATH+"_fakt") from struct
use

O__FAKT
zap


select (F_ROBA)
if !used(); use (SIFPATH+"roba"); endif
set order to tag "ID"

select kalk_pripr; go top
do while !eof()
  select _fakt; scatter()
  select kalk_pripr; scatter()
  select roba
  hseek kalk_pripr->idRoba
  _idTipDok:="01"
  _brDok:=kalk_pripr->idVd+"-"+TRIM(kalk_pripr->brDok)
  _MPC:=roba->mpc;  _MPC2:=roba->mpc2
  if roba->(fieldpos("MPC3"))<>0
    _MPC3:=roba->mpc3
  endif
  if roba->(fieldpos("VPC2"))<>0
    _VPC2:=roba->vpc2
  endif
  _VPC:=roba->vpc
  _Robnaz:=roba->naz
  _jmj:=roba->jmj
  _idtarifa:=roba->idtarifa
  select _fakt
  dbappend();  gather()
  select kalk_pripr; skip
enddo

select _fakt; use

select kalk_pripr; go top
if fsif
  cDestMod:=right(dtos(date()),4)  // 1998 1105  - 11 mjesec, 05 dan
else
  cDestMod:=right(dtos(kalk_pripr->datdok),4)  // 1998 1105  - 11 mjesec, 05 dan
endif
cDestMod:="PRENOS\"+gmodemveza+"F"+cDestMod  // PRENOS\SF1205

dirmak2(KUMPATH+"PRENOS") // napravi direktorij prenos !!!

my_use("_fakt", "nFAKT") 

fIzadji:=.f.
// donja for-next pelja otvara baze i , ako postoje, gleda da li je
// u njih pohranjen isti dokument
for i:=1 to 25

   bErr:=ERRORBLOCK({|o| MyErrH(o)})
   begin sequence
     my_use ( KUMPATH+cDestMod+chr(64+i), "oFAKT" )
     // OD A-C
     if nFAKT->(idfirma+idtipdok+brdok)==oFAKT->(idfirma+idtipdok+brdok)
       fIzadji:=.t.
     endif
     use
   recover
     fizadji:=.t.
     // ako ne prodje use onda je prazno
   end sequence
   bErr:=ERRORBLOCK(bErr)
   if fizadji; exit; endif
next
cDestMod:=cDestMod+chr(64+i)
select nFAKT; use
cDestMod:=KUMPATH+cDestMod+".DBF"


filecopy(PRIVPATH+"_FAKT.DBF",cDestMod)
filecopy(strtran(PRIVPATH+"_FAKT.DBF",".DBF",".FPT"), strtran(cDestMod,".DBF",".FPT"))

cDestMod:=strtran(cDestMod,".DBF",".TXT")
filecopy(PRIVPATH+"outf.txt",cDestMod)

cDestMod:=strtran(cDestMod,".TXT",".DBF")
MsgBeep("Datoteka "+cDestMod+"je izgenerisana")


endif
return nil
*}



