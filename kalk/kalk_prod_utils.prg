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


function MarzaMP(cIdVd, lNaprijed, aPorezi)
local nPrevMP

// za svaki slucaj setujemo ovo ako slucajno u dokumentu nije ispranvo
if (IsPDVMagNab() .or. IsMagSNab()) .and. cIdVD $ "11#12#13"
	// inace je _fcj kod ovih dokumenata  = nabavnoj cijeni
	// _nc u ovim dokumentima moze biti uvecana za troskove prevoza
	_VPC := _FCJ
endif

if (IsPDVMagNab() .or. IsMagSNab()) .and. cIdVD $ "80"
	_vpc := _nc
	_fcj := _nc
endif


// ako je prevoz u MP rasporedjen uzmi ga u obzir
if  (cIdVd $ "11#12#13") .and. (_TPrevoz=="A")
	nPrevMP:=_Prevoz
else
	nPrevMP:=0
endif


if  (_Marza2==0) .and. !lNaprijed

	nMarza2:= _MPC - _VPC - nPrevMP
	
	if _TMarza2=="%"
		if round( _VPC,5 ) <>0
			_Marza2:=100*( _MPC / (_VPC+nPrevMP) - 1)
		else
			_Marza2:=0
		endif
		
	elseif _TMarza2=="A"
		_Marza2:=nMarza2
		
	elseif _TMarza2=="U"
		_Marza2:=nMarza2*(_Kolicina)
	endif

elseif (_MPC==0) .or. lNaprijed

	if _TMarza2=="%"
		nMarza2 := _Marza2/100 * (_VPC + nPrevMP)
	elseif _TMarza2=="A"
		nMarza2 := _Marza2
	elseif _TMarza2 == "U"
		nMarza2 := _Marza2/(_Kolicina)
	endif
	
	_MPC:=round(nMarza2 + _VPC, 2)

        _MpcSaPP := round( MpcSaPor( _mpc, aPorezi), 2)

else
	nMarza2:= _MPC - _VPC - nPrevMP
endif

AEVAL(GetList,{|o| o:display()})
return



/*! \fn Marza2(fMarza)
 *  \brief Postavi _Marza2, _mpc, _mpcsapp
 */

function Marza2(fMarza)

local nPrevMP, nPPP

if IsPdv()

// za svaki slucaj setujemo ovo ako slucajno u dokumentu nije ispranvo
if IsPDVMagNab() .or. IsMagSNab() .and. _IdVD $ "11#12#13"
	// inace je _fcj kod ovih dokumenata  = nabavnoj cijeni
	// _nc u ovim dokumentima moze biti uvecana za troskove prevoza
	_VPC := _FCJ
endif


if fMarza==nil
	fMarza:=" "
endif

// za svaki slucaj setujemo ovo ako slucajno u dokumentu nije ispranvo
if IsPDVMagNab() .or. IsMagSNab()
	_VPC := _FCJ
endif


// ako je prevoz u MP rasporedjen uzmi ga u obzir
if _TPrevoz=="A"
	nPrevMP:=_Prevoz
else
	nPrevMP:=0
endif

if _FCj==0
	_FCj:=_mpc
endif

if  _Marza2==0 .and. empty(fmarza)
	nMarza2:=_MPC - _VPC - nPrevMP
	
	if _TMarza2=="%"
		if round(_vpc,5)<>0
			_Marza2:=100*( _MPC / (_VPC+nPrevMP) - 1)
		else
			_Marza2:=0
		endif
		
	elseif _TMarza2=="A"
		_Marza2:=nMarza2
		
	elseif _TMarza2=="U"
		_Marza2:=nMarza2*(_Kolicina)
	endif

elseif _MPC==0 .or. !empty(fMarza)

	if _TMarza2=="%"
		nMarza2:=_Marza2 / 100 * (_VPC + nPrevMP)
	elseif _TMarza2=="A"
		nMarza2:=_Marza2
	elseif _TMarza2=="U"
		nMarza2:=_Marza2 / (_Kolicina)
	endif
	_MPC:=round(nMarza2+_VPC, 2)
	
	if !empty(fMarza)
	     _MpcSaPP := round( MpcSaPor(_mpc, aPorezi), 2)
	endif

else
	nMarza2:=_MPC-_VPC-nPrevMP
endif

AEVAL(GetList,{|o| o:display()})
return

else

// PPP obracun
return Marza2O(fMarza)

endif


function Marza2O(fMarza)
*{
local nPrevMP, nPPP

if fMarza==nil
	fMarza:=" "
endif

if roba->tip=="K"  // samo za tip k
	nPPP:=1/(1+tarifa->opp/100)
else
	nPPP:=1
endif

// ako je prevoz u MP rasporedjen uzmi ga u obzir
if _TPrevoz=="A"
	nPrevMP:=_Prevoz
else
	nPrevMP:=0
endif

if _fcj==0
	_fcj:=_mpc
endif

if  _Marza2==0 .and. empty(fmarza)
	nMarza2:=_MPC-_VPC*nPPP-nPrevMP
	if _TMarza2=="%"
		if round(_vpc,5)<>0
			_Marza2:=100*(_MPC/(_VPC*nPPP+nPrevMP)-1)
		else
			_Marza2:=0
		endif
	elseif _TMarza2=="A"
		_Marza2:=nMarza2
	elseif _TMarza2=="U"
		_Marza2:=nMarza2*(_Kolicina)
	endif

elseif _MPC==0 .or. !empty(fMarza)
	if _TMarza2=="%"
		nMarza2:=_Marza2/100*(_VPC*nPPP+nPrevMP)
	elseif _TMarza2=="A"
		nMarza2:=_Marza2
	elseif _TMarza2=="U"
		nMarza2:=_Marza2/(_Kolicina)
	endif
	_MPC:=round(nMarza2+_VPC,2)
	if !empty(fMarza)
		if roba->tip=="V"
			_mpcsapp:=round(_mpc*(1+TARIFA->PPP/100),2)
		elseif roba->tip="X"
			// ne diraj _mpcsapp
		else
			_mpcsapp:=round(MpcSaPor(_mpc,aPorezi),2)
		endif
	endif

else
	nMarza2:=_MPC-_VPC*nPPP-nPrevMP
endif

AEVAL(GetList,{|o| o:display()})
return
*}




/*! \fn Marza2R()
 *  \brief Marza2 pri realizaciji prodavnice je MPC-NC
 */

function Marza2R()
*{
local nPPP

nPPP:=1/(1+tarifa->opp/100)

if _nc==0
   _nc:=_mpc
endif

if  _Marza2==0
  nMarza2:=_MPC-_NC
  if roba->tip=="V"
    nMarza2:=(_MPC-roba->VPC)+roba->vpc*nPPP-_NC
  endif

  if _TMarza2=="%"
    _Marza2:=100*(_MPC/_NC-1)
  elseif _TMarza2=="A"
    _Marza2:=nMarza2
  elseif _TMarza2=="U"
    _Marza2:=nMarza2*(_Kolicina)
  endif
elseif _MPC==0
  if _TMarza2=="%"
     nMarza2:=_Marza2/100*_NC
  elseif _TMarza2=="A"
     nMarza2:=_Marza2
  elseif _TMarza2=="U"
     nMarza2:=_Marza2/(_Kolicina)
  endif
  _MPC:=nMarza2+_NC
else
 nMarza2:=_MPC-_NC
endif
AEVAL(GetList,{|o| o:display()})
return
*}


/*! \fn Marza2R()
 *  \brief Marza pri realizaciji prodavnice 
 */

function MarzaMpR()
*{
local nPPP

nPPP:=1/(1+tarifa->opp/100)

if _nc==0
   _nc:=_mpc
endif

nMpcSaPop := _MPC - RabatV

if  (_Marza2==0)
  nMarza2:= nMpcSaPop - _NC

  if _TMarza2=="%"
    _Marza2:=100*(nMpcSaPop/_NC-1)
  elseif _TMarza2=="A"
    _Marza2:=nMarza2
  elseif _TMarza2=="U"
    _Marza2:=nMarza2*(_Kolicina)
  endif
elseif (_MPC==0)
  if _TMarza2=="%"
     nMarza2:=_Marza2/100*_NC
  elseif _TMarza2=="A"
     nMarza2:=_Marza2
  elseif _TMarza2=="U"
     nMarza2:=_Marza2/(_Kolicina)
  endif
  
  _MPC := nMarza2+ _NC + _RabatV
  
else
 nMarza2:= nMpcSaPop -_NC
endif
AEVAL(GetList,{|o| o:display()})
return
*}



/*! \fn FaktMPC(nMPC,cseek,dDatum)
 *  \brief Fakticka maloprodajna cijena
 */

function FaktMPC(nMPC,cseek,dDatum)
*{
local nOrder
  nMPC:=UzmiMPCSif()
  select kalk
  PushWa()
  set filter to
  //nOrder:=indexord()
  set order to tag "4" //idFirma+pkonto+idroba+dtos(datdok)
  seek cseek+"X"
  skip -1
  do while !bof() .and. idfirma+pkonto+idroba==cseek
    if dDatum<>NIL .and. dDatum<datdok
       skip -1; loop
    endif
    if idvd $ "11#80#81"
      nMPC:=mpcsapp
      exit
    elseif idvd=="19"
      nMPC:=fcj+mpcsapp
      exit
    endif
    skip -1
  enddo
  PopWa()
  //dbsetorder(nOrder)
return





function UzmiMPCSif()
local nCV := 0
  
if koncij->naz == "M2"
	nCV := roba->mpc2
elseif koncij->naz == "M3"
    nCV := roba->mpc3
elseif koncij->naz == "M4" .and. roba->(fieldpos("mpc4"))<>0
    nCV := roba->mpc4
elseif koncij->naz == "M5" .and. roba->(fieldpos("mpc5"))<>0
    nCV := roba->mpc5
elseif koncij->naz == "M6" .and. roba->(fieldpos("mpc6"))<>0
    nCV := roba->mpc6
elseif roba->(fieldpos("mpc")) <> 0
    nCV := roba->mpc
endif

return nCV




// ------------------------------------
// StaviMPCSif(nCijena, lUpit)
// ------------------------------------
function StaviMPCSif( nCijena, lUpit )
local lAzuriraj
local lRet := .f.
local lIsteCijene
local _rec

IF lUpit == nil
 	lUpit := .f.
ENDIF
 
private cMpc := ""

do case 
  case koncij->naz=="M2"
      cMpc := "mpc2"
  case koncij->naz=="M3"
      cMpc := "mpc3"
  case koncij->naz=="M4"
      cMpc := "mpc4"
  case koncij->naz=="M5"
      cMpc := "mpc5"
  case koncij->naz=="M6"
      cMpc := "mpc6"
  otherwise
      cMpc := "mpc"
endcase


if roba->(fieldpos(cMpc)) == 0
	return .f.
endif


lIsteCijene := (ROUND(roba->(&cMpc), 4) == ROUND(nCijena, 4))
	
if lIsteCijene
	// iste cijene nemam sta mijenjati
	return .f.
endif

if lUpit
	if gAutoCjen == "D" .and. Pitanje(,"Staviti " + cMpc + " u sifrarnik ?", "D") == "D"
		lAzuriraj := .t.
	else
		lAzuriraj := .f.
	endif
else
	lAzuriraj := .t.
	if gAutoCjen == "N"
		lAzuriraj := .f.
	endif
endif

if lAzuriraj
	PushWa()
	SELECT ROBA
    _rec := dbf_get_rec()
    _rec[ cMpc ] := nCijena

	my_use_semaphore_off()
	sql_table_update( nil, "BEGIN" )

	update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )

	sql_table_update( nil, "END" )
	my_use_semaphore_on()

	PopWa()
	lRet := .t.
endif

return lRet



/*! \fn V_KolPro()
 *  \brief
 */

function V_KolPro()
*{
local ppKolicina

if empty(gMetodaNC) .or. _TBankTr=="X" // .or. lPoNarudzbi
	return .t.
endif  // bez ograde

if roba->tip $ "UTY"; return .t. ; endif

ppKolicina:=_Kolicina
if _idvd=="11"
  ppKolicina:=abs(_Kolicina)
endif

if nKolS<ppKolicina
     Beep(2);clear typeahead
     Msg("U prodavnici je samo"+str(nKolS,10,3)+" robe !!",6)
     _ERROR:="1"
endif
return .t.
*}




/*! \fn StanjeProd(cKljuc,ddatdok)
 *  \brief
 */

function StanjeProd(cKljuc,ddatdok)
*{
 LOCAL nUlaz:=0, nIzlaz:=0
 SELECT KALK
 set order to tag "4"
 GO TOP
 SEEK cKljuc
 DO WHILE !EOF() .and. cKljuc==idfirma+pkonto+idroba
   if ddatdok<datdok  // preskoci
       skip; loop
   endif
   if roba->tip $ "UT"
       skip; loop
   endif

   if pu_i=="1"
     nUlaz+=kolicina-GKolicina-GKolicin2

   elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
     nIzlaz+=kolicina

   elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
     nUlaz-=kolicina

   elseif pu_i=="I"
     nIzlaz+=gkolicin2
   endif

   SKIP 1
 ENDDO
return (nUlaz-nIzlaz)
*}

