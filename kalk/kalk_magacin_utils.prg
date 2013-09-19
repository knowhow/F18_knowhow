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



function KalkNabP( cIdFirma, cIdroba, cIdkonto, nKolicina, nKolZN, nNC, nSNC, dDatNab )
local npom,fproso
local nIzlNV
local nIzlKol
local nUlNV
local nUlKol
local nSkiniKol
local nZadnjaUNC

nKolicina := 0

if lAutoObr == .t.
	// uzmi stanje iz cache tabele
	if knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina, ;
		@nUlNv, @nIzlNv, @nNc ) == 1
		select kalk_pripr
		return
	endif
endif

select kalk
set order to tag "4"  //idFirma+pkonto+idroba+pu_i+IdVD
seek cIdFirma+cIdKonto+cIdRoba+chr(254)
skip -1

if cIdfirma + cIdkonto + cIdroba == idfirma + pkonto + idroba .and. _datdok < datdok
    Beep(2)
    Msg("Postoji dokument "+idfirma+"-"+idvd+"-"+brdok+" na datum: "+dtoc(datdok),4)
    _ERROR:="1"
endif

nLen:=1

nKolicina:=0

// ukupna izlazna nabavna vrijednost
nIzlNV:=0  

// ukupna izlazna kolicina
nIzlKol:=0  
nUlNV:=0

// ulazna kolicina
nUlKol:=0  
nZadnjaUNC := 0

//  ovo je prvi prolaz
hseek cIdFirma+cIdKonto+cIdRoba

do while !eof() .and. cIdFirma+cIdKonto+cIdroba==idFirma+pkonto+idroba .and. _datdok >= datdok

  if pu_i=="1" .or. pu_i=="5"
    if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0)
      nKolicina += abs(kolicina)       // rad metode prve i zadnje nc moramo
      nUlKol    += abs(kolicina)       // sve sto udje u magacin strpati pod
      nUlNV     += (abs(kolicina)*nc)  // ulaznom kolicinom

      if idvd $ "10#16#96"
      	nZadnjaUNC := nc
      endif

    else
      nKolicina -= abs(kolicina)
      nIzlKol   += abs(kolicina)
      nIzlNV    += (abs(kolicina)*nc)
    endif
  elseif pu_i=="I"
     nKolicina-=gkolicin2
     nIzlKol+=gkolicin2
     nIzlNV+=nc*gkolicin2
  endif
  skip

enddo //  ovo je prvi prolaz

// prva nabavka  se prva skida sa stanja
if gMetodaNc=="3"
  hseek cIdFirma+cIdKonto+cIdRoba
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  do while !eof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+pkonto+idroba .and. _datdok >= datdok

    if pu_i=="1" .or. pu_i=="5"
      if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0)
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
       endif
    elseif pu_i=="I" .and.  gkolicin2<0   // IP - storno izlaz

           if nSkiniKol>abs(gKolicin2)
             nNabVr   +=abs(gkolicin2*nc)
             nSkinikol-=abs(gkolicin2)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif

    endif
    skip
  enddo //  ovo je drugi prolaz , metoda "3"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi prve
  else
    nNC:=0
  endif
endif

// metoda zadnje nabavne cijene: zadnja nabavka se prva skida sa stanja

if gMetodaNc == "1"

  seek cIdFirma+cIdKonto+cIdRoba+chr(254)
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  skip -1
  do while !bof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+pkonto+idroba

    if _datdok<=datdok // preskaci novije datume
      skip -1
      loop
    endif

    if pu_i=="1" .or. pu_i=="5"
      if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0) // ulaz
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
      endif
    elseif (pu_i=="I"  .and. gkolicin2<0)
           if nSkiniKol>abs(gkolicin2)
             nNabVr   +=abs(gkolicin2*nc)
             nSkinikol-=abs(gkolicin2)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
    endif
    skip -1
  enddo //  ovo je drugi prolaz , metoda "1"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi zadnje
  else
    nNC:=0
  endif
endif

if round(nKolicina, 5)==0
 nSNC:=0
else
 nSNC:=(nUlNV-nIzlNV)/nKolicina
endif

// ako se koristi kontrola NC
if gNC_ctrl > 0 .and. nSNC <> 0 .and. nZadnjaUNC <> 0
	
	nTmp := ROUND( nSNC, 4 ) - ROUND( nZadnjaUNC, 4 )
	nOdst := ( nTmp / ROUND( nZadnjaUNC, 4 )) * 100

	if ABS(nOdst) > gNC_ctrl
		
		Beep(4)
 		clear typeahead

		msgbeep("Odstupanje u odnosu na zadnji ulaz je#" + ;
			ALLTRIM(STR(ABS(nOdst))) + " %" + "#" + ;
			"artikal: " + ALLTRIM(_idroba) + " " + ;
			PADR( roba->naz, 15 ) + " nc:" + ;
			ALLTRIM(STR( nSNC, 12, 2 )) )
		
		//a_nc_ctrl( @aNC_ctrl, idroba, nKolicina, ;
		//	nSNC, nZadnjaUNC )
		
		if Pitanje(,"Napraviti korekciju NC (D/N)?", "N") == "D"
			
			nTmp_n_stanje := ( nKolicina - _kolicina )
			nTmp_n_nv := ( nTmp_n_stanje * nZadnjaUNC )
			nTmp_s_nv := ( nKolicina * nSNC )
			
			nSNC := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina ) 

		endif

	endif
endif

nKolicina:=round(nKolicina,4)
select kalk_pripr
return




function MarzaVP(cIdVd, lNaprijed)
local SKol:=0


if (_nc==0)
  _nc:=9999
endif

if gKalo=="1" .and. cIdvd=="10"
 Skol:=_Kolicina-_GKolicina-_GKolicin2
else
 Skol:=_Kolicina
endif

if  _Marza==0 .or. _VPC<>0 .and. !lNaprijed
  // unazad formiraj marzu
  nMarza:=_VPC - _NC
  if _TMarza=="%"
     _Marza:=100*(_VPC/_NC-1)
  elseif _TMarza=="A"
    _Marza:=nMarza
  elseif _TMarza=="U"
    _Marza:=nMarza*SKol
  endif

elseif round(_VPC,4)==0  .or. lNaprijed
  // formiraj marzu "unaprijed" od nc do vpc
  if _TMarza=="%"
     nMarza:=_Marza/100*_NC
  elseif _TMarza=="A"
     nMarza:=_Marza
  elseif _TMarza=="U"
     nMarza:=_Marza/SKol
  endif
  _VPC:=round((nMarza+_NC), 2)
  
else
  if cIdvd $ "14#94"
     nMarza:=_VPC * (1-_Rabatv/100) - _NC
  else
   nMarza:=_VPC - _NC
  endif
endif
AEVAL(GetList,{|o| o:display()})
return
*}


/*! \fn Marza(fmarza)
 *  \brief Proracun veleprodajne marze
 */

function Marza(fmarza)
*{
local SKol:=0,nPPP

if fmarza==NIL
  fMarza:=" "
endif

if _nc==0
  _nc:=9999
endif

if roba->tip $ "VKX"
  nPPP:=1/(1+tarifa->opp/100)
  if roba->tip="X"; nPPP:=nPPP*_mpcsapp/_vpc; endif
else
  nPPP:=1
endif


if gKalo=="1" .and. _idvd=="10"
 Skol:=_Kolicina-_GKolicina-_GKolicin2
else
 Skol:=_Kolicina
endif

if  _Marza==0 .or. _VPC<>0 .and. empty(fMarza)
  nMarza:=_VPC*nPPP-_NC
  if roba->tip="X"
    nMarza -= roba->mpc-_VPC
    // nmarza:= _vpc*npp-_nc - (roba->mpc-_vpc)
    // nmarza/_nc := (_vpc*nppp/nc-1 - (roba->mpc-_Vpc)/nc)
    // nmarza/_nc := ( (_vpc*nppp - roba->mpc -_vpc)/_nc-1)
  endif
  if _TMarza=="%"
     if roba->tip="X"
      _Marza:=100*( (_VPC*nPPP - roba->mpc - _vpc)/_NC-1)
     else
      _Marza:=100*(_VPC*nPPP/_NC-1)
     endif
  elseif _TMarza=="A"
    _Marza:=nMarza
  elseif _TMarza=="U"
    _Marza:=nMarza*SKol
  endif

elseif round(_VPC,4)==0  .or. !empty(fMarza)
  if _TMarza=="%"
     nMarza:=_Marza/100*_NC
  elseif _TMarza=="A"
     nMarza:=_Marza
  elseif _TMarza=="U"
     nMarza:=_Marza/SKol
  endif
  _VPC:=round((nMarza+_NC)/nPPP,2)
else
  if _idvd $ "14#94"
   if roba->tip=="V"
     nMarza:=_VPC*nPPP-_VPC*_Rabatv/100-_NC
   else
     nMarza:=_VPC*nPPP*(1-_Rabatv/100)-_NC
   endif
  else
   nMarza:=_VPC*nPPP-_NC
  endif
endif
AEVAL(GetList,{|o| o:display()})
return
*}



/*! \fn FaktVPC(nVPC,cseek,dDatum)
 *  \brief Fakticka veleprodajna cijena
 */

function FaktVPC(nVPC,cseek,dDatum)
*{
local nOrder

if koncij->naz=="V2" .and. roba->(fieldpos("vpc2"))<>0
	nVPC:=roba->vpc2
elseif koncij->naz=="P2"
	nVPC:=roba->plc
elseif roba->(fieldpos("vpc"))<>0
	nVPC:=roba->vpc
else
	nVPC:=0
endif

select kalk
PushWa()
set filter to
//nOrder:=indexord()
set order to tag "3" //idFirma+mkonto+idroba+dtos(datdok)
seek cseek+"X"
skip -1


do while !bof() .and. idfirma+mkonto+idroba==cseek

if dDatum<>NIL .and. dDatum<datdok
	skip -1
	loop
endif

//if mu_i=="1" //.or. mu_i=="5"
if idvd $ "RN#10#16#12#13"
	if koncij->naz<>"P2"
        	nVPC:=vpc
      	endif
      	exit
elseif idvd=="18"
	nVPC:=mpcsapp+vpc
      	exit
endif
skip -1
enddo
PopWa()
//dbsetorder(nOrder)
return
*}



/*! \fn PratiKMag(cIdFirma,cIdKonto,cIdRoba)
 *  \brief Prati karticu magacina
 */
 
function PratiKMag(cIdFirma,cIdKonto,cIdRoba)
*{
local nPom
select kalk ; set order to tag "3"
hseek cIdFirma+cIdKonto+cIdRoba
//"KALKi3","idFirma+mkonto+idroba+dtos(datdok)+PODBR+MU_I+IdVD",KUMPATH+"KALK")

nVPV:=0
nKolicina:=0
do while !eof() .and.  cIdFirma+cIdKonto+cIdRoba==idfirma+idkonto+idroba

   dDatDok:=datdok
   do while !eof() .and.  cIdFirma+cIdKonto+cIdRoba==idfirma+idkonto+idroba ;
                   .and. datdok==dDatDok


       nVPC:=vpc   // veleprodajna cijena
       if mu_i=="1"
          nPom:=kolicina-gkolicina-gkolicin2
          nKolicina+= nPom
          nVPV+=nPom*vpc
       elseif mu_i=="3"
          nPom:=kolicina
          nVPV+=nPom*vpc
          // kod ove kalk mpcsapp predstavlja staru vpc
          nVPC:=vpc+mpcsapp
       elseif mu_i=="5"
          nPom:=kolicina
          nVPV-=nPom*VPC
       endif

       if round(nKolicina,4)<>0
          if round(nVPV/nKolicina,2) <> round(nVPC,2)

          endif
       endif

   enddo

enddo
return
*}



/*! \fn ObSetVPC(nNovaVrijednost)
 *  \brief Obavezno setuj VPC
 */

function ObSetVPC(nNovaVrijednost)
local nArr := SELECT()
local _rec
private cPom:="VPC"
  
if koncij->naz=="P2"
	cPom:="PLC"
elseif koncij->naz=="V2"
    cPom:="VPC2"
else
    cPom:="VPC"
endif
  
select roba
_rec := dbf_get_rec()

_rec[ LOWER( cPom ) ] := nNovaVrijednost

update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

select (nArr)
return .t.




/*! \fn UzmiVPCSif(cMKonto,lKoncij)
 *  \brief Za zadani magacinski konto daje odgovarajucu VPC iz sifrarnika robe
 */

function UzmiVPCSif(cMKonto,lKoncij)
*{
 LOCAL nCV:=0, nArr:=SELECT()
 IF lKoncij=NIL; lKoncij:=.f.; ENDIF
  SELECT KONCIJ
   nRec:=RECNO()
    SEEK TRIM(cMKonto)
    nCV:=KoncijVPC()
   IF !lKoncij
     GO (nRec)
   ENDIF
  SELECT (nArr)
return nCV
*}



/*! \fn NabCj()
 *  \brief Proracun nabavne cijene za ulaznu kalkulaciju 10
 */

function NabCj()
*{
local Skol

if gKalo=="1"
 Skol:=_Kolicina-_GKolicina-_GKolicin2
else
 Skol:=_Kolicina
endif


if _TPrevoz=="%"
  nPrevoz:=_Prevoz/100*_FCj2
elseif _TPrevoz=="A"
  nPrevoz:=_Prevoz
elseif _TPrevoz=="U"
  nPrevoz:=_Prevoz/SKol
elseif _TPrevoz=="R"
  nPrevoz:=0
else
  nPrevoz:=0
endif
if _TCarDaz=="%"
  nCarDaz:=_CarDaz/100*_FCj2
elseif _TCarDaZ=="A"
 nCarDaz:=_CarDaz
elseif _TCArDaz=="U"
 nCarDaz:=_CarDaz/SKol
elseif _TCArDaz=="R"
 nCarDaz:=0
else
 nCardaz:=0
endif
if _TZavTr=="%"
  nZavTr:=_ZavTr/100*_FCj2
elseif _TZavTr=="A"
  nZavTr:=_ZavTr
elseif _TZavTr=="U"
  nZavTr:=_ZavTr/SKol
elseif _TZavTr=="R"
  nZavTr:=0
else
  nZavTr:=0
endif
if _TBankTr=="%"
   nBankTr:=_BankTr/100*_FCj2
elseif _TBankTr=="A"
   nBankTr:=_BankTr
elseif _TBankTr=="U"
   nBankTr:=_BankTr/SKol
else
   nBankTr:=0
endif
if _TSpedTr=="%"
   nSpedTr:=_SpedTr/100*_FCj2
elseif _TSpedTr=="A"
   nSpedTr:=_SpedTr
elseif _TSpedTr=="U"
   nSpedTr:=_SpedTr/SKol
else
   nSpedTr:=0
endif

_NC:=_FCj2+nPrevoz+nCarDaz+nBanktr+nSpedTr+nZavTr

return
*}



/*! \fn NabCj2(n1,n2)  
 *  \param n1 - ukucana NC
 *  \param n2 - izracunata NC
 *  \brief Ova se f-ja koristi samo za 10-ku bez troskova (gVarijanta="1")
 */

function NabCj2(n1,n2)  

IF ROUND(_FCJ, 6)  == 0
   Alert("Fakturna cijene ne moze biti 0")
   _FCJ := 1
   return .f.
endif

 IF glEkonomat

   _fcj   := _fcj2 := _nc
   _rabat := 0

 ELSEIF ABS(n1-n2)>0.00001   // tj. ako je ukucana drugacija NC
 
   _rabat:=100-100*_NC/_FCJ
   _FCJ2:=_NC
   ShowGets()
 ENDIF

return .t.



/*! \fn SetujVPC(nNovaVrijednost,fUvijek)
 *  \param fUvijek -.f. samo ako je vrijednost u sifrarniku 0, .t. uvijek setuj
 *  \brief Utvrdi varijablu VPC. U sifrarnik staviti novu vrijednost
 */

function SetujVPC(nNovaVrijednost, lUvijek)
local nVal
local _vars

if lUvijek == nil
	lUvijek := .f.
endif

private cPom:="VPC" 

if koncij->naz=="P2"
   cPom:="plc"
   nVal:=roba->plc
elseif koncij->naz=="V2"
   cPom:="vpc2"
   nVal:=roba->VPC2
else
   cPom:="vpc"
   nVal:=roba->VPC
endif

if nVal==0  .or. ABS(round(nVal-nNovaVrijednost, 2)) > 0 .or. lUvijek
 
   if gAutoCjen == "D" .and. Pitanje( , "Staviti Cijenu (" + cPom + ")" + " u sifrarnik ?", "D") == "D"
     select roba
     
     _vars := dbf_get_rec()
     _vars[cPom] := nNovaVrijednost

     update_rec_server_and_dbf("roba", _vars, 1, "FULL" )

     select kalk_pripr
   endif
 endif

return .t.



/*! \fn KoncijVPC()
 *  \brief Daje odgovarajucu VPC iz sifrarnika robe
 */

function KoncijVPC()
*{
// podrazumjeva da je nastimana tabela koncij
// ------------------------------------------
if koncij->naz=="P2"
	return roba->plc
elseif koncij->naz=="V2"
	return roba->VPC2
elseif koncij->naz=="V3"
	return roba->VPC3
else
	return roba->VPC
endif

return (nil)
*}



/*! \fn MMarza()
 *  \brief Preracunava iznos veleprodajne marze
 */

function MMarza()
*{
local SKol:=0
Skol:=Kolicina-GKolicina-GKolicin2
  if TMarza=="%".or.empty(tmarza)
     nMarza:=Skol*Marza/100*NC
  elseif TMarza=="A"
     nMarza:=Marza*Skol
  elseif TMarza=="U"
     nMarza:=Marza
  endif
return nMarza
*}



/*! \fn PrerRab()
 *  \brief Rabat veleprodaje - 14
 */

function PrerRab()
*{
local nPrRab
if cTRabat=="%"
   nPrRab:=_rabatv
elseif cTRabat=="A"
  if _VPC<>0
   nPrRab:=_RABATV/_VPC*100
  else
   nPrRab:=0
  endif
elseif cTRabat=="U"
 if _vpc*_kolicina<>0
   nprRab:=_rabatV/(_vpc*_kolicina)*100
 else
   nPrRab:=0
 endif
else
  return .f.
endif
_rabatv:=nPrRab
cTrabat:="%"
showgets()
return .t.
*}


// Validacija u prilikom knjizenja (knjiz.prg) - VALID funkcija u get-u

// Koristi sljedece privatne varijable:
// nKols   
// gMetodaNC
// _TBankTr - "X"  - ne provjeravaj - vrati .t.
// ---------------------------------------------
// Daje poruke:
// Nabavna cijena manja od 0 ??
// Ukupno na stanju samo XX robe !!

function V_KolMag()

if (_nc < 0) .and. !(_idvd $ "11#12#13#22") .or.  _fcj<0 .and. _idvd $ "11#12#13#22"

 Msg("Nabavna cijena manja od 0 ??")
 _ERROR:="1"

endif

// usluge
if roba->tip $ "UTY"; return .t. ; endif

if empty(gMetodaNC) .or. _TBankTR=="X"
	return .t.
endif  // bez ograde

if nKolS < _Kolicina
 Beep(4)
 clear typeahead
 Msg("Ukupno na stanju je samo" + str(nKolS, 10, 4) + " robe !!", 6)
 _ERROR:="1"
endif

return .t.



/*! \fn V_RabatV()
 *  \brief Ispisuje vrijednost rabata u VP
 */
 
// Trenutna pozicija u tabeli KONCIJ (na osnovu koncij->naz ispituje cijene)
// Trenutan pozicija u tabeli ROBA (roba->tip)

function V_RabatV()
local nPom, nMPCVT
local nRVPC:=0
private getlist:={}, cPom:="VPC"

if koncij->naz=="P2"
   cPom:="PLC"
elseif koncij->naz=="V2"
   cPom:="VPC2"
else
   cPom:="VPC"
endif

if roba->tip $ "UTY"
    return .t.
endif

nRVPC := KoncijVPC()
if round(nRVPC-_vpc,4)<>0  .and. gMagacin=="2"
	if nRVPC==0
    	Beep(1)
      	Box(,3,60)
      	@ m_x+1,m_Y+2 SAY "Roba u sifrarniku ima "+cPom+" = 0 !??"
      	@ m_x+3,m_y+2 SAY "Unesi "+cPom+" u sifrarnik:" GET _vpc pict picdem

      	read

      	select roba
		_rec := dbf_get_rec()

		_rec[LOWER(cPom)] := _vpc
		update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

      	select kalk_pripr
      	BoxC()

   	endif
endif
 
// roba tarife
if roba->tip=="V" 
   nMarza:=_VPC/(1+_PORVT)-_VPC*_RabatV/100-_NC
elseif roba->tip="X"
   nMarza:=_VPC*(1-_RabatV/100)-_NC- _MPCSAPP/(1+_PORVT)*_porvt
else
   nMarza:=_VPC/(1+_PORVT)*(1-_RabatV/100)-_NC
endif
 
if IsPDV()
 	@ m_x+15,m_y+41  SAY "PC b.pdv.-RAB:"
else
 	@ m_x+15,m_y+41  SAY "VPC b.p.-RAB:"
endif
 
if roba->tip=="V"
   @ m_x+15,col()+1 SAY _Vpc/(1+_PORVT)-_VPC*_RabatV/100 pict picdem
elseif roba->tip=="X"
   @ m_x+15,col()+1 SAY _Vpc*(1-_RabatV/100) - _MPCSAPP/(1+_PORVT)*_PORVT pict picdem
else
   @ m_x+15,col()+1 SAY _Vpc/(1+_PORVT)*(1-_RabatV/100) pict picdem
endif
 
ShowGets()

return .t.




// KalkNab(cIdFirma,cIdRoba,cIdKonto,nKolicina,nKolZN,nNC,nSNC,dDatNab)
// param nNC - zadnja nabavna cijena
// param nSNC - srednja nabavna cijena
// param nKolZN - kolicina koja je na stanju od zadnje nabavke
// param dDatNab - datum nabavke
//  Racuna nabavnu cijenu i stanje robe u magacinu


function KalkNab(cIdFirma, cIdRoba, cIdKonto, nKolicina, nKolZN, nNC, nSNc, dDatNab)

local nPom
local fProso
local nIzlNV
local nIzlKol
local nUlNV
local nUlKol
local nSkiniKol
local nKolNeto
local nZadnjaUNC

// posljednje pozitivno stanje
local nKol_poz := 0
local nUVr_poz, nIVr_poz
local nUKol_poz, nIKol_poz

nKolicina := 0

if lAutoObr == .t.
	// uzmi stanje iz cache tabele
	if knab_cache( cIdKonto, cIdroba, @nUlKol, @nIzlKol, @nKolicina, ;
		@nUlNv, @nIzlNv, @nSNC ) == 1
		select kalk_pripr
		return
	endif
endif

select kalk

set order to TAG "3"
seek cIdFirma + cIdKonto + cIdRoba+"X"

skip -1
if ((cIdFirma+cIdKonto+cIdRoba) == (idfirma+mkonto+idroba)) .and. _datdok<datdok
	Beep(2)
  	Msg("Postoji dokument " + idfirma + "-" + idvd + "-" + brdok + " na datum: " + dtoc(datdok), 4)
  	_ERROR:="1"
endif

nLen:=1

nKolicina := 0
nIzlNV := 0   
// ukupna izlazna nabavna vrijednost
nUlNV := 0
nIzlKol := 0  
// ukupna izlazna kolicina
nUlKol := 0  
// ulazna kolicina
nZadnjaUNC := 0


//  ovo je prvi prolaz
//  u njemu se proracunava totali za jednu karticu
hseek cIdFirma+cIdKonto+cIdRoba
do while !eof() .and. ((cIdFirma+cIdKonto+cIdRoba)==(idFirma+mkonto+idroba)) .and. _datdok>=datdok

  if mu_i=="1" .or. mu_i=="5"

    if IdVd=="10"
      // kod 10-ki je originalno predvidjeno gubitak kolicine (kalo i rastur)
      // mislim da ovo niko i ne koristi, ali eto neka stoji
      nKolNeto := ABS(kolicina-gKolicina-gKolicin2)
    else
      nKolNeto := ABS(kolicina)
    endif

    if (mu_i=="1" .and.  kolicina>0) .or. (mu_i=="5" .and. kolicina<0)

         // ulazi plus, storno izlaza
         nKolicina += nKolNeto
         nUlKol    += nKolNeto
         nUlNV     += (nKolNeto * nc)

	 // zapamti uvijek zadnju ulaznu NC
	 if idvd $ "10#16#96"
	 	nZadnjaUNC := nc
	 endif

    else

         nKolicina -= nKolNeto

         nIzlKol   += nKolNeto
         nIzlNV    += (nKolNeto * nc)

    endif

    // ako je stanje pozitivno zapamti ga
    if round(nKolicina, 8) > 0
        nKol_poz := nKolicina

        nUKol_poz := nUlKol
        nIKol_poz := nIzlKol

        nUVr_poz := nUlNv
        nIVr_poz := nIzlNv
    endif


  endif
  skip

enddo 
//  ovo je bio prvi prolaz


// koliko znam i ovo niko ne koristi svi koriste srednju nabavnu
//gMetodaNC=="3"  // prva nabavka  se prva skida sa stanja
if gMetodaNc=="3"
  hseek cIdFirma+cIdKonto+cIdRoba
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  do while !eof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba .and. _datdok>=datdok

    if mu_i=="1" .or. mu_i=="5"
      if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0) // ulaz
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
      endif
    endif
    skip
  enddo //  ovo je drugi prolaz , metoda "3"

  if _kolicina <> 0
    nNC:=(nNabVr-nIzlNV) /_kolicina   
  else
    nNC:=0
  endif
endif

// koliko znam i ovo niko ne koristi svi koriste srednju nabavnu
// gMetodaNC=="1"  // zadnja nabavka se prva skida sa stanja
if gMetodaNc=="1"
  seek cIdFirma+cIdKonto+cIdRoba+chr(254)
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  skip -1
  do while !bof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba

    if _datdok<=datdok // preskaci novije datume
      skip -1; loop
    endif

    if mu_i=="1" .or. mu_i=="5"
      if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0) // ulaz
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
      endif
    endif
    skip -1
  enddo //  ovo je drugi prolaz , metoda "1"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi zadnje
  else
    nNC:=0
  endif
endif

// utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
if round(nKol_poz, 8) == 0
	nSNc:=0
else
 	// srednja nabavna cijena
 	nSNc:=(nUVr_poz - nIVr_poz) / nKol_poz
endif

// ako se koristi kontrola NC
if gNC_ctrl > 0 .and. nSNC <> 0 .and. nZadnjaUNC <> 0
	
	nTmp := ROUND( nSNC, 4 ) - ROUND( nZadnjaUNC, 4 )
	nOdst := ( nTmp / ROUND( nZadnjaUNC, 4 )) * 100

	if ABS(nOdst) > gNC_ctrl
		
		Beep(4)
 		clear typeahead

		msgbeep("Odstupanje u odnosu na zadnji ulaz je#" + ;
			ALLTRIM(STR(ABS(nOdst))) + " %" + "#" + ;
			"artikal: " + ALLTRIM(_idroba) + " " + ;
			PADR( roba->naz, 15 ) + " nc:" + ;
			ALLTRIM(STR( nSNC, 12, 2 )) )
	
		//a_nc_ctrl( @aNC_ctrl, idroba, nKolicina, ;
		//	nSNC, nZadnjaUNC )

		if Pitanje(,"Napraviti korekciju NC (D/N)?", "N") == "D"
			
			nTmp_n_stanje := ( nKolicina - _kolicina )
			nTmp_n_nv := ( nTmp_n_stanje * nZadnjaUNC )
			nTmp_s_nv := ( nKolicina * nSNC )
			
			nSNC := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina ) 

		endif
	endif
endif

// daj posljednje stanje kakvo i jeste 
nKolicina := round(nKolicina, 4)

select kalk_pripr

return


// ---------------------------------------------------------
// dodaj u matricu robu koja je problematicna
// ---------------------------------------------------------
function a_nc_ctrl( aCtrl, cIdRoba, nKol, nSnc, nZadnjaNC )
local nScan := 0
local nOdst := 0

if nSNC <> 0 .and. nZadnjaNC <> 0
	nTmp := ROUND( nSNC, 4 ) - ROUND( nZadnjaNC, 4 )
	nOdst := ( nTmp / ROUND( nZadnjaNC, 4 )) * 100
endif

nScan := ASCAN( aCtrl, {|xVal| xVal[1] == cIdRoba } )

if nScan = 0
	// dodaj novi zapis
	AADD( aCtrl, { cIdRoba, nKol, nSNC, nZadnjaNC, nOdst } )
else
	// ispravi tekuce zapise
	aCtrl[ nScan, 2 ] := nKol
	aCtrl[ nScan, 3 ] := nSNC
	aCtrl[ nScan, 4 ] := nZadnjaNC
	aCtrl[ nScan, 5 ] := nOdst

endif

return

// ------------------------------------------------
// popup kod nabavne cijene
// ------------------------------------------------
function p_nc_popup( cIdRoba )
local nScan

nScan := ASCAN( aNC_ctrl, {|xVal| xVal[1] == cIdRoba } )

if nScan <> 0
	
	// daj mi odstupanje !
	nOdstupanje := ROUND( aNC_ctrl[ nScan, 5 ], 2 )
	msgbeep( "Odstupanje u odnosu na zadnji ulaz je#" + ;
		ALLTRIM(STR(nOdstupanje)) + " %" )

endif

return


// ------------------------------------------------
// stampanje stanja iz kontrolne tabele
// ------------------------------------------------
function p_nc_ctrl( aCtrl )
local nTArea := SELECT()
local i
local cLine := ""
local cTxt := ""
local nCnt := 0

if LEN( aCtrl ) = 0
	return
endif

START PRINT CRET

?
? "Kontrola odstupanja nabavne cijene"
? "- kontrolna tacka = " + ALLTRIM(STR(gNC_ctrl)) + "%"
? 

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)
cLine += SPACE(1)
cLine += REPLICATE("-", 12)

cTxt += PADR("r.br", 5)
cTxt += SPACE(1)
cTxt += PADR("artikal", 10)
cTxt += SPACE(1)
cTxt += PADR("kolicina", 12)
cTxt += SPACE(1)
cTxt += PADR("zadnja NC", 12)
cTxt += SPACE(1)
cTxt += PADR("nova NC", 12)
cTxt += SPACE(1)
cTxt += PADR("odstupanje", 12)

? cLine
? cTxt
? cLine

for i:=1 to LEN( aCtrl )

	// rbr
	? PADL( ALLTRIM( STR( ++nCnt ) ), 4 ) + "."
	// idroba
	@ prow(), pcol() + 1 SAY aCtrl[i, 1 ]
	// kolicina
	@ prow(), pcol() + 1 SAY aCtrl[i, 2 ]
	// zadnja nc
	@ prow(), pcol() + 1 SAY aCtrl[i, 4 ]
	// nova nc
	@ prow(), pcol() + 1 SAY aCtrl[i, 3 ]
	// odstupanje
	@ prow(), pcol() + 1 SAY aCtrl[i, 5 ] PICT "9999%"

next

FF
END PRINT

select (nTArea)
return




function IsMagPNab()

if (IsPDV() .and. gPDVMagNab == "D") 
	return .t.
else
	return .f.
endif
return
*}

// -------------------------------------
// magacin samo po nabavnim cijenama
// -------------------------------------
function IsMagSNab()
local lN1 := .f.

PushWa()

// da li je uopste otvoren koncij
SELECT F_KONCIJ
if used()
	if koncij->naz == "N1"
		lN1 := .t.
	endif
endif
PopWa()

if (gMagacin == "1") .or. lN1
	return .t.
else
	return .f.
endif

// znaci magacin robe - PDV je po nab cjenama
function IsPDVMagNab()

if (IsPDV() .and. gPDVMagNab == "D")
   return .t.
else
   return .f.
endif

