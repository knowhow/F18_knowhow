/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"

function IzSifre(fSilent)
local nPos
local cSif := trim(_txt3a)
local cPom
local fTel

if fSilent == nil
	fSilent:=.f.
endif

fTel:=.f.
if right(cSif,1)="." .and. len(csif)<=7
	nPos:=RAT(".",cSif)
   	cSif:=left(cSif,nPos-1)
   	if !fsilent
     		P_Firma(padr(cSif,6))
   	endif
   	if lSpecifZips
     		_Txt3a:=TRIM(partn->id)+"- "+TRIM(LEFT(partn->naz,25))+" "+trim(partn->naz2)
   	else
     		IF IzFMKINI("PoljeZaNazivPartneraUDokumentu","Prosiriti","N",KUMPATH)=="D"
       			_Txt3a:=padr(partn->naz,60)
     		ELSE
       			_Txt3a:=padr(partn->naz,30)
     		ENDIF
   	endif

   	_txt3b:=trim(partn->adresa)
   	cPom:=""
   	
	if !empty(partn->telefon) .and. IzFmkIni('FAKT','NaslovPartnTelefon','D')=="D"
      		cPom:=_txt3b + ", Tel:" + trim(partn->telefon)
   	else
      		fTel:=.t.
   	endif
   	
	if !empty(cPom) .and. len(cPom)<=30
     		_txt3b:=cPom
      		ftel:=.t.
   	endif
   	if !empty(partn->ptt)
     		if IzFmkIni('FAKT','NaslovPartnPTT','D')=="D"
        		_txt3c:=trim(partn->ptt)+" "+trim(partn->mjesto)
     		endif
   	else
     		_txt3c:=trim(partn->mjesto)
   	endif

   	if !ftel
       		if IzFmkIni('FAKT','NaslovPartnTelefon','D')=="D"
          		_txt3c:=_txt3c+", Tel:"+trim(partn->telefon)
       		endif
   	endif

   	_txt3b:=padr(_txt3b,30)
   	_txt3c:=padr(_txt3c,30)
   	_IdPartner:=partn->id
endif

if gShSld == "D"
	private gFinKPath := STRTRAN( KUMPATH, "FAKT", "FIN" )
	// ako je prikaz salda na fakturi = D prikazi box sa podacima fin
	g_box_stanje( _idpartner, gFinKtoDug, gFinKtoPot )
endif

return  .t.


function V_Rj ()
IF gDetPromRj == "D" .and. gFirma <> _IdFirma
    Beep (3)
    Msg ("Mijenjate radnu jedinicu!!!#")
  EndIF
return .t.


function V_Podbr()
local fRet:=.f.,nTRec,nPrec,nPkolicina:=1,nPRabat:=0
private GetList:={}
if (left(_podbr,1) $ " .0123456789") .and. (right(_podbr,1) $ " .0123456789")
  fRet:=.t.
endif

if val(_podbr)>0; _podbr:= str(val(_podbr),2); endif
if alltrim(_podbr)=="."
  _podbr:=" ."
  cPRoba:=""  // proizvod sifra
  nPKolicina:=_kolicina
  _idroba:=space(len(_idroba))
  Box(,5,50)
    @ m_x+1,m_y+2 SAY "Proizvod:" GET _idroba valid {|| empty(_idroba) .or. P_roba(@_idroba)} pict "@!"
    read
    if !empty(_idroba)
       @ m_x+3,m_y+2 SAY "kolicina        :" GET nPkolicina pict pickol
       @ m_x+4,m_y+2 SAY "rabat %         :" GET nPRabat    pict "999.999"
       @ m_x+5,m_y+2 SAY "Varijanta cijene:" GET cTipVPC
       read
    endif
  BoxC()
  // idemo na sastavnicu
  if !empty(_idroba)
   _txt1:=padr(roba->naz,40)
   nTRec:=recno()
   go top
   nTRbr:=nRbr
   do while !eof()
     skip; nPRec:=recno(); skip -1
     if nTrbr==val(rbr) .and. alltrim(podbr)<>"."
       // pobrisi stare zapise
       delete
     endif
     go nPrec
   enddo
   // nafiluj iz sastavnice
   select sast
   cPRoba:=_idroba
   cptxt1:=_txt1
   seek cPRoba
   nPbr:=0
   do while !eof() .and. cPRoba==id
     select roba
     hseek sast->id2  // pozicioniraj se na materijal
     select fakt_pripr
     append ncnl
     _rbr:=str(nTrbr,3)
     _podbr:=str(++npbr,2)
     _idroba:=sast->id2
     _kolicina:=sast->kolicina*npkolicina
     _rabat:=nPRabat
     SetujCijenu()

     if roba->tip=="U"
       _txt1:=trim(LEFT(roba->naz, 40))
     else
       _txt1:=""
     endif
     if _podbr==" ." .or.  roba->tip="U"
         _txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
           Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
           Chr(16)+trim(_txt3c)+Chr(17) +;
           Chr(16)+_BrOtp+Chr(17) +;
           Chr(16)+dtoc(_DatOtp)+Chr(17) +;
           Chr(16)+_BrNar+Chr(17) +;
           Chr(16)+dtoc(_DatPl)+Chr(17)
     endif
     Gather()
     select sast
     skip
   enddo
   select fakt_pripr
   go nTRec
   _podbr:=" ."
   _cijena:=0
   _idroba:=cPRoba
   _kolicina:=npkolicina
   _txt1:=cptxt1
  endif
  _txt1:=padr(_txt1,40)
  _porez:=_rabat:=0
  if empty(cPRoba)
   _idroba:=""
   _Cijena:=0
  endif
  _SerBr:=""
endif
return fRet



// -----------------------------------------
// setovanje cijene
// -----------------------------------------
function SetujCijenu()
local lRJ:=.f.

select (F_RJ)
IF USED()
	lRJ:=.t.
  	hseek _idfirma
ENDIF
select  roba

if _idtipdok=="13" .and. ( gVar13=="2" .or. glCij13Mpc ) .or. _idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D"
  IF g13dcij=="6"
    _cijena:=MPC6
  ELSEIF g13dcij=="5"
    _cijena:=MPC5
  ELSEIF g13dcij=="4"
    _cijena:=MPC4
  ELSEIF g13dcij=="3"
    _cijena:=MPC3
  ELSEIF g13dcij=="2"
    _cijena:=MPC2
  ELSE
    _cijena:=MPC
  ENDIF
elseif lRJ .and. rj->tip="M"  // baratamo samo sa mp.cijenama
   _cijena:=fakt_mpc_iz_sifrarnika()

elseif _idtipdok$"11#15#27"
  if gMP=="1"
    _Cijena:=MPC
  elseif gMP=="2"
      _Cijena:=round(VPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100),;
                   VAL(IzFMKIni("FAKT","ZaokruzenjeMPCuDiskontu","2",KUMPATH)))
  elseif gMP=="3"
    _Cijena:=MPC2
  elseif gMP=="4"
    _Cijena:=MPC3
  elseif gMP=="5"
    _Cijena:=MPC4
  elseif gMP=="6"
    _Cijena:=MPC5
  elseif gMP=="7"
    _Cijena:=MPC6
  endif
else
  if cTipVPC=="1"
    _Cijena:=vpc
  elseif fieldpos("vpc2")<>0
   if gVarC=="1"
     _Cijena:=vpc2
   elseif gVarc=="2"
     _Cijena:=vpc
     if vpc<>0; _Rabat:= (vpc-vpc2) / vpc * 100; endif
   elseif gVarc=="3"
     _Cijena:=nc
   endif
  else
    _Cijena:=0
  endif
endif

select fakt_pripr
return



function V_Kolicina()
local cRjTip
local nUl:=nIzl:=0
local nRezerv:=nRevers:=0

if _kolicina == 0
	return .f.
endif

if JeStorno10()
	_kolicina := - ABS(_kolicina)
endif

if _podbr<>" ."
	select RJ
	hseek _idfirma
	
	if rj->(FIELDPOS("tip"))<>0
		cRjTip := rj->tip
	else
		cRjTip := ""
	endif

  	IF gVarNum=="1" .and. gVar13=="2" .and. _idtipdok=="13"
    		hseek RJIzKonta(_idpartner+" ")
  	ENDIF

	NSRNPIdRoba(_IDROBA)
  	select ROBA
	if !(roba->tip="U")  // usluge ne diraj
  		if _idtipdok=="13" .and. (gVar13=="2".or.glCij13Mpc).and.gVarNum=="1"
      			if gVar13=="2" .and. _idtipdok=="13"
        			_cijena := fakt_mpc_iz_sifrarnika()
      			else
        			if g13dcij=="6"
          				_cijena:=MPC6
        			elseif g13dcij=="5"
          				_cijena:=MPC5
        			elseif g13dcij=="4"
          				_cijena:=MPC4
        			elseif g13dcij=="3"
          				_cijena:=MPC3
        			elseif g13dcij=="2"
          				_cijena:=MPC2
        			else
          				_cijena:=MPC
        			endif
      			endif
    		elseif _idtipdok=="13".and.(gVar13=="2".or.glCij13Mpc).and.gVarNum=="2" .or. _idtipdok=="19".and.IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D"
      			if g13dcij=="6"
        			_cijena:=MPC6
      			elseif g13dcij=="5"
        			_cijena:=MPC5
      			elseif g13dcij=="4"
       				_cijena:=MPC4
      			elseif g13dcij=="3"
        			_cijena:=MPC3
      			elseif g13dcij=="2"
        			_cijena:=MPC2
      			else
        			_cijena:=MPC
      			endif
    		elseif cRjtip="M"
       			_cijena:=fakt_mpc_iz_sifrarnika()
    		elseif _idtipdok$"11#15#27"
      			if gMP=="1"
        			_Cijena:=MPC
      			elseif gMP=="2"
        			_Cijena:=round(VPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100),VAL(IzFMKIni("FAKT","ZaokruzenjeMPCuDiskontu","1",KUMPATH)))
      			elseif gMP=="3"
        			_Cijena:=MPC2
      			elseif gMP=="4"
        			_Cijena:=MPC3
      			elseif gMP=="5"
        			_Cijena:=MPC4
      			elseif gMP=="6"
        			_Cijena:=MPC5
      			elseif gMP=="7"
        			_Cijena:=MPC6
      			endif
    		elseif _idtipdok=="25" .and. _cijena<>0
      			// za knjiznu obavijest: 
			// ne dirati cijenu ako je vec odredjena
    		elseif cRjTip="V".and._idTipDok $ "10#20" 
			//ako se radi o racunima i predracunima
			_cijena:=fakt_vpc_iz_sifrarnika()
		else
      			if cTipVPC=="1"
        			_Cijena:=vpc
      			elseif fieldpos("vpc2")<>0
       				if gVarC=="1"
         				_Cijena:=vpc2
       				elseif gVarc=="2"
         				_Cijena:=vpc
         				if vpc<>0
						_Rabat:= (vpc-vpc2) / vpc * 100
					endif
       				elseif gVarc=="3"
         				_Cijena:=nc
       				endif
      			else
        			_Cijena:=0
      			endif
    		endif
	endif
endif

if lPoNarudzbi = .t.
	select fakt_pripr
  	return .t.
endif

select fakt
set order to tag "3"

lBezMinusa := ( IzFMKIni("FAKT","NemaIzlazaBezUlaza","N",KUMPATH) == "D" )

if !(roba->tip="U") .and. !empty(_IdRoba) .and.  left(_idtipdok,1) $ "12"  ;
	.and. (gPratiK=="D".or.lBezMinusa = .t.) .and. ;
   	!(left(_idtipdok,1) == "1" .and. left(_serbr,1)="*")  
	// ovo je onda faktura
        // na osnovu otpremnice

    MsgO("Izracunavam trenutno stanje ...")
 	
	seek _idroba
 	
	nUl:=0
	nIzl:=0
	nRezerv:=0
	nRevers:=0
 	
	do while !eof()  .and. roba->id==IdRoba
   		
		// ovdje provjeravam samo za tekucu firmu
   		if fakt->IdFirma <> _IdFirma
     			skip
			loop
   		endif
   		
		if idtipdok="0"  
			// ulaz
     			nUl  += kolicina
   		elseif idtipdok="1"   
			// izlaz faktura
     			if !(left(serbr,1)=="*" .and. idtipdok=="10")  
				// za fakture na osnovu otpremnice 
				// ne racunaj izlaz
       				nIzl += kolicina
     			endif
   		elseif idtipdok$"20#27"
     			if serbr="*"
       				nRezerv += kolicina
     			endif
   		elseif idtipdok=="21"
     			nRevers += kolicina
   		endif
   		skip
 	enddo

    MsgC()

	if ( ( nUl - nIzl - nRevers - nRezerv - _kolicina ) < 0 )
 		
		fakt_box_stanje({{_IdFirma, nUl,nIzl,nRevers,nRezerv}},_idroba)
 		
		if _idtipdok = "1" .and. lBezMinusa = .t.
   			select fakt_pripr
   			return .f.
		endif

	endif
endif 

select fakt_pripr

IF _idtipdok=="26" .and. glDistrib .and. !UGenNar()
	RETURN .f.
ENDIF

if IsRabati() .and. (_idtipdok $ gcRabDok)
	_rabat := 0
	// _rabat := RabVrijednost(gcRabDef, cTipRab, _idroba, gcRabIDef)
	if lSkonto
		_skonto := 0
		// _skonto :=  SKVrijednost(gcRabDef, cTipRab, _idroba)
	endif
endif

return .t.


// -----------------------------------------------
// WHEN roba
// -----------------------------------------------
function W_Roba()
private Getlist:={}

if _podbr==" ."
     	@ m_x + 15, m_y + 2  SAY "Roba     " ;
     		GET _txt1 ;
		PICT "@!"
     	read
     	return .f.
else
     	return .t.
endif


// ----------------------------------------------
// VALID roba
// ----------------------------------------------
function V_Roba( lPrikTar )
local cPom
local nArr
private cVarIDROBA

if fID_J
	cVarIDROBA:="_IDROBA_J"
else
  	cVarIDROBA:="_IDROBA"
endif


if lPrikTar == nil
	lPrikTar := .t.
endif

if right(trim(&cVarIdRoba),2)="++"
	cPom:=padr(left(&cVarIdRoba,len(trim(&cVarIdRoba))-2),len(&cVarIdRoba))
  	select roba
	seek cPom
  	if found()
      		//BrowseKart(cPom)    
		// prelistaj kalkulacije
      		//&cVarIdRoba:=cPom
  	endif
endif

if right(trim(&cVarIdRoba),2)="--"
	cPom:=padr(left(&cVarIdRoba,len(trim(&cVarIdRoba))-2),len(&cVarIdRoba))
  	select roba
	seek cPom
  	if found()
      		FaktStanje(roba->id)    // prelistaj kalkulacije
      		&cVarIdRoba:=cPom
  	endif
endif

// sredi sifru dobavljaca...
fix_sifradob( @_idroba, 5, "0" ) 

P_Roba( @_Idroba , nil, nil, gArtCDX )

select roba
select fakt_pripr

select tarifa
seek roba->idtarifa

if lPrikTar
	@ m_X+16,m_y+28 SAY "TBr: "
	?? roba->idtarifa, "PDV", str(tarifa->opp,7,2)+"%"
  	if _IdTipdok=="13"
		if IsPDV()
     			@ m_X+18,m_y+47 SAY "MPC.s.PDV sif:"
		else
     			@ m_X+18,m_y+47 SAY "MPC u sif:"
		endif
		?? str(roba->mpc,8,2)
  	endif
endif

// uzmi rabat za ovu robu.... iz polja roba->n1
if gRabIzRobe == "D"
	_rabat := roba->n1
endif

select fakt_pripr
return .t.


// -------------------------------
// VALID porez 
// -------------------------------
function V_Porez()
local nPor
if _porez<>0
	if roba->tip="U"
    		nPor:=tarifa->ppp
  	else
    		nPor:=tarifa->opp
  	endif
  	if nPor<>_Porez
    		Beep(2)
    		Msg("Roba pripada tarifnom stavu "+roba->idtarifa+;
      		"#kod koga je porez "+str(nPor,5,2)  ;
       		)
  	endif
endif
return .t.




/*! \fn W_BrOtp(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function W_BrOtp(fnovi)
if fnovi
	_datotp:=_datdok;_datpl:=_datdok
endif
return .t.



/*! \fn V_Rabat()
 *  \brief
 */
 
function V_Rabat()
if trabat $ " U"
  if _Cijena*_Kolicina<>0
   _rabat:=_rabat*100/(_Cijena*_Kolicina)
  else
   _rabat:=0
  endif
elseif trabat="A"
  if _Cijena<>0
   _rabat:=_rabat*100/_Cijena
  else
   _rabat:=0
  endif
elseif trabat="C" // zadata je nova cijena
  if _Cijena<>0
   _rabat:= (_cijena-_rabat)/_cijena*100
  else
   _rabat:=0
  endif
elseif trabat="I" // zadat je zeljeni iznos (kolicina*cijena)
  if _kolicina*_Cijena<>0
   _rabat:= (_kolicina*_cijena-_rabat)/(_kolicina*_cijena)*100
  else
   _rabat:=0
  endif
endif

if _Rabat>99
  Beep(2)
  Msg("Rabat ne moze biti ovoliki !!",6)
  _rabat:=0
endif
if _idtipdok$"11#15#27"
   _porez:=0
else
 if roba->tip=="V"
  _porez:=0
 endif
endif

// setuj novu cijenu u sifrarnik i rabat ako postoji
set_cijena( _idtipdok, _idroba, _cijena, _rabat )

ShowGets()
return .t.




// -------------------------------------------------
// uzorak teksta na kraju fakture
// -------------------------------------------------
function UzorTxt()
local cId := "  "

// INO kupci
if IsPdv() .and. _IdTipDok $ "10#20" .and. IsIno(_IdPartner)
	InoKlauzula()
 	if EMPTY(alltrim(_txt2))
		cId:="IN"
 	endif
endif

// KOMISION
if IsPdv() .and. _IdTipDok == "12" .and. IsProfil(_IdPartner, "KMS")
 	// komisiona otprema klauzula
 	KmsKlauzula()
 	if EMPTY(alltrim(_txt2))
		cId:="KS"
 	endif
endif

if (nRbr==1 .and. val(_podbr)<1)
	Box(,9,75)
 		@ m_x+1,m_Y+1  SAY "Uzorak teksta (<c-W> za kraj unosa teksta):"  GET cId pict "@!"
 		read
 
 		if lastkey()<>K_ESC .and. !empty(cId)
   			P_Ftxt(@cId)
   			SELECT ftxt
   			SEEK cId
   			select fakt_pripr
   			_txt2 := trim(ftxt->naz)

   			if gSecurity == "D"
				_txt2 += "Dokument izradio: " + GetFullUserName( GetUserID() ) 
   			endif
  
  			select fakt_pripr
  			IF glDistrib .and. _IdTipdok=="26"
    				IF cId $ IzFMKIni("FAKT","TXTIzjaveZaObracunPoreza",";",KUMPATH)
      					_k2 := "OPOR"
    				ELSE
      					_k2 := ""
    				ENDIF
  			ENDIF
 		endif
 		setcolor(Invert)
 		private fUMemu:=.t.
 		_txt2:=MemoEdit(_txt2,m_x+3,m_y+1,m_x+9,m_y+76)
 		fUMemu:=NIL
 		
        setcolor(Normal)
 	BoxC()
endif
return



// -------------------------------------------------
// uzorak teksta na kraju fakture
// verzija sa listom...
// -------------------------------------------------
function UzorTxt2( cList )
local cId := "  "
local cU_txt
local aList := {}
local i
local nCount := 1

if cList == nil
	cList := ""
endif

cList := ALLTRIM( cList )

if !EMPTY( cList )
	// samo kod praznog teksta generisi iz liste
	if EMPTY(_txt2) 
	  if Pitanje(,"Dokument sadrzi txt listu, koristiti je ?","D") == "N"
		// ponisti listu
		cList := ""
	  endif
	  // napravi matricu sa tekstovima
	  aList := TokToNiz( cList, ";" )
	endif
endif

// INO kupci
if IsPdv() .and. _IdTipDok $ "10#20" .and. IsIno(_IdPartner)
	InoKlauzula()
 	if EMPTY(alltrim(_txt2))
		cId := "IN"
		AADD( aList, cId )
 	endif
endif

// KOMISION
if IsPdv() .and. _IdTipDok == "12" .and. IsProfil(_IdPartner, "KMS")
 	// komisiona otprema klauzula
 	KmsKlauzula()
 	if EMPTY(alltrim(_txt2))
		cId := "KS"
		AADD( aList, cId )
 	endif
endif

// dodaj sve iz liste u _TXT2
// cID = "MX" - miksani sadrzaj

if !EMPTY( cList )
  for i:=1 to LEN( aList )
	cU_txt := aList[i]
	_add_to_txt( cU_txt, nCount, .t. )
  	cId := "MX"
	++ nCount 
  next
endif
 
// prva stavka fakture 

if (nRbr==1 .and. val(_podbr)<1)

  Box(,11,75)
     do while .t.

	@ m_x + 1, m_y + 1 SAY "Odaberi uzorak teksta iz sifrarnika:" ;
	 	GET cId pict "@!"
 	
	@ m_x + 11, m_y + 1 SAY "<c+W> dodaj tekst na fakturu, unesi novi  <ESC> izadji i snimi"
	
	read
 
 	if lastkey() <> K_ESC .and. !EMPTY( cId ) 
	  	if cId <> "MX"
   			P_Ftxt(@cId)
			_add_to_txt( cId, nCount, .t. )
			++ nCount
			cId := "  "
		endif
   	endif	
 	setcolor(Invert)
 	private fUMemu:=.t.
 	_txt2:=MemoEdit(_txt2,m_x+3,m_y+1,m_x+9,m_y+76)
 	fUMemu:=NIL
 	setcolor(Normal)
     
        if LastKey() == K_ESC
	   exit
	endif
     
     enddo
  BoxC()

endif

return


// ---------------------------------------------------------
// dodaj tekst u _txt2
// ---------------------------------------------------------
function _add_to_txt( cId_txt, nCount, lAppend )
local cTmp 

if lAppend == nil
	lAppend := .f.
endif
if nCount == nil
	nCount := 1
endif

// prazan tekst - ne radi nista
if EMPTY( cId_Txt )
	return
endif

select ftxt
seek cId_txt
select fakt_pripr

if lAppend == .f.
	_txt2 := trim(ftxt->naz)
else
	cTmp := ""
	
	if nCount > 1
		cTmp += CHR(13) + CHR(10)
	endif
	
	cTmp += trim(ftxt->naz)

	_txt2 := _txt2 + cTmp
endif

if nCount = 1 .and. gSecurity == "D"
	_txt2 += " Dokument izradio: " + GetFullUserName( GetUserID() ) 
endif
  
select fakt_pripr
if nCount = 1 .and. glDistrib .and. _IdTipdok=="26"
	_k2 :=""
	if cId_txt $ IzFMKIni("FAKT","TXTIzjaveZaObracunPoreza",";",KUMPATH)
		_k2 := "OPOR"
	endif
endif

return



// ----------------------------
// ino klauzula
// ----------------------------
function InoKlauzula()

PushWa() 
	SELECT FTXT
	seek "IN"
	if !found()
		APPEND BLANK
		replace id with "IN", ;
		        naz with "Porezno oslobadjanje na osnovu (nulta stopa) na osnovu clana 27. stav 1. tacka 1. ZPDV - izvoz dobara iz BIH"
	endif
PopWa()
return

// ----------------------------
// komision klauzula
// ----------------------------
function KmsKlauzula()

PushWa() 
	SELECT FTXT
	seek "KS"
	if !found()
		APPEND BLANK
		replace id with "KS", ;
		        naz with "Dostava nije oporeziva, na osnovu Pravilnika o primjeni Zakona o PDV-u"+;
			Chr(13)+Chr(10)+"clan 6. tacka 3."
	endif
PopWa()


/*! \fn GetUsl(fNovi)
 *  \brief get usluga
 *  \param fNovi
 */
 
function GetUsl(fNovi)
*{
private GetList:={}


if !(roba->tip="U")
 devpos(m_x+15,m_y+25)
 ?? space(40)
 devpos(m_x+15,m_y+25)

 ?? trim(LEFT(roba->naz,40)),"("+roba->jmj+")"
endif

if roba->tip $ "UT" .and. fnovi
  _kolicina:=1
endif

if roba->tip=="U"
  _txt1 := PADR( IF( fNovi , LEFT(ROBA->naz,40) , _txt1 ) , 320 )
  IF fNovi
    _cijena := ROBA->vpc
    if !_idtipdok$"11#15#27"
      _porez  := TARIFA->ppp
    endif
  ENDIF
  @ row(),m_y+25 GET _txt1 pict "@S40"
  read
  _txt1:=trim(_txt1)
else
  _txt1:=""
endif

return .t.




/*! \fn Nijedupla(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function NijeDupla(fNovi)
*{
local nEntBK,ibk,uEntBK
local nPrevRec 

    // ako se radi o stornu fakture -> preuzimamo rabat i porez iz fakture
    if JeStorno10()
      RabPor10()
    endif

    if gOcitBarkod .and. nRbr>1

        nEntBK:=val(IzFmkIni("Barkod","ENTER"+_IdTipdok,"0",SIFPATH))
        // otiltaj entere ako je barkod ocitan !!
        cEntBK:=""
        for ibk:=1 to nEntBK
          cEntBK+=Chr(K_ENTER)
        next
        if nEntBK>0
          KEYBOARD cEntBK
        endif

        return .t.
    endif

    select fakt_pripr
    nPrevRec:=RECNO()
    LOCATE FOR idfirma+idtipdok+brdok+idroba==_idfirma+_idtipdok+_brdok+_idroba .and. (recno()<>nPrevrec .or. fnovi)
    IF FOUND ()
      if !(roba->tip $ "UT")
       Beep (2)
       Msg ("Roba se vec nalazi na dokumentu, stavka "+ALLTRIM (PRIPR->Rbr), 30)
      endif
    ENDIF
    GO nPrevRec
RETURN (.t.)
*}




/*! \fn Prepak(cIdRoba,cPako,nPak,nKom,nKol,lKolUPak)
 *  \brief Preracunavanje paketa i komada ...
 *  \param cIdRoba  - sifra artikla
 *  \param nPak     - broj paketa/kartona
 *  \param nKom     - broj komada u ostatku (dijelu paketa/kartona)
 *  \param nKol     - ukupan broj komada
 *  \param nKOLuPAK - .t. -> preracunaj pakete (nPak,nKom) .f. -> preracunaj komade (nKol)
 */
 
function Prepak(cIdRoba,cPako,nPak,nKom,nKol,lKolUPak)
*{
LOCAL lVrati:=.f., nArr:=SELECT(), aNaz:={}, cKar:="AMB ", nKO:=1, n_Pos:=0
  IF lKOLuPAK==NIL; lKOLuPAK:=.t.; ENDIF
  SELECT SIFV; SET ORDER TO TAG "ID"
  HSEEK "ROBA    "+cKar+PADR(cIdRoba,15)
  DO WHILE !EOF() .and.;
           id+oznaka+idsif=="ROBA    "+cKar+PADR(cIdRoba,15)
    IF !EMPTY(naz)
      AADD( aNaz , naz )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    nOpc  := 1  // za sad ne uvodim meni
    n_Pos := AT( "_" , aNaz[nOpc] )
    cPako := "(" + ALLTRIM( LEFT( aNaz[nOpc] , n_Pos-1 ) ) + ")"
    nKO   := VAL( ALLTRIM( SUBSTR( aNaz[nOpc] , n_Pos+1 ) ) )
    IF nKO<>0
      IF lKOLuPAK
        nPak := INT(nKol/nKO)
        nKom := nKol-nPak*nKO
      ELSE
        nKol := nPak*nKO+nKom
      ENDIF
    ENDIF
    lVrati:=.t.
  ELSEIF lKOLuPAK
    nPak := 0
    nKom := nKol
  ENDIF
  SELECT (nArr)
RETURN lVrati
*}



/*! \fn UGenNar()
 *  \brief U Generalnoj Narudzbi
 */
 
function UGenNar()
*{
LOCAL lVrati:=.t., nArr:=SELECT(), nIsporuceno, nNaruceno, dNajstariji:=CTOD("")
  SELECT (F_UGOV)
  IF !USED()
    O_UGOV
  ENDIF
  SET ORDER TO TAG "1"
  HSEEK "D"+"G"+_idpartner
  IF FOUND()
    SELECT (F_RUGOV)
    IF !USED()
      O_RUGOV
    ENDIF
    SET ORDER TO TAG "ID"
    SELECT UGOV
    nNaruceno:=0
    // izracunajmo ukupnu narucenu kolicinu i utvrdimo datum najstarije
    /// narudzbe
    DO WHILE !EOF() .and. aktivan+vrsta+idpartner=="D"+"G"+_idpartner
      SELECT RUGOV
      HSEEK UGOV->id+_idroba
      IF FOUND()
        IF EMPTY(dNajstariji)
          dNajstariji := UGOV->datod
        ELSE
          dNajstariji := MIN( UGOV->datod , dNajstariji )
        ENDIF
        nNaruceno += kolicina
      ENDIF
      SELECT UGOV
      SKIP 1
    ENDDO
    // izracunati dosadasnju isporuku (nIsporuceno)
    nIsporuceno:=0
    SELECT FAKT
    SET ORDER TO TAG "6"
    // sabiram sve isporuke od datuma vazenja najstarijeg ugovora do danas
    SEEK _idfirma+_idpartner+_idroba+"10"+DTOS(dNajstariji)
    DO WHILE !EOF() .and. idfirma+idpartner+idroba+idtipdok==;
                          _idfirma+_idpartner+_idroba+"10"
      nIsporuceno += kolicina
      SKIP 1
    ENDDO
    IF _kolicina+nIsporuceno > nNaruceno
      lVrati:=.f.
      MsgBeep("Kolicina: "+ALLTRIM(TRANS(_kolicina,PicKol))+". Naruceno: "+ALLTRIM(TRANS(nNaruceno,PicKol))+". Dosad isporuceno: "+ALLTRIM(TRANS(nIsporuceno,PicKol))+". #"+;
              "Za ovoliku isporuku artikla morate imati novu generalnu narudzbenicu!")
    ENDIF
  ENDIF
  SELECT (nArr)
RETURN lVrati
*}


// ako 
function v_pretvori(cPretvori, cDinDem, dDatDok, nCijena)

if !(cPretvori $ "DN")
	MsgBeep("preracunati cijenu u valutu dokumenta "+cDinDem+" ##(D)a ili (N)e ?")
	return .f.
endif

if cPretvori == "D"
	nCijena := nCijena * OmjerVal( ValBazna(), cDinDem, dDatDok)
	cPretvori := "N"
endif

ShowGets()
return .t.


// ------------------------------------------------
// setuje cijenu i rabat u sifrarniku robe
// ------------------------------------------------
function set_cijena( cIdTipDok, cIdRoba, nCijena, nRabat )
local nTArea := SELECT()
local lFill := .f.
local _vars

select roba
go top
seek cIdRoba

if FOUND()	

	// provjeri da li je cijena ista ?
    _vars := dbf_get_rec()
	
    if cIdTipDok $ "#10#01#12#20#" .and. nCijena <> 0
		if field->vpc <> nCijena .and. ;
			Pitanje(, "Postaviti novu VPC u sifranik ?", "N") == "D"
			_vars["vpc"] := nCijena
			lFill := .t.
		endif
	elseif cIdTipDok $ "#11#13#" .and. nCijena <> 0
		if field->mpc <> nCijena .and. ;
			Pitanje(,"Postaviti novu MPC u sifrarnik ?", "N") == "D"
			_vars["mpc"] := nCijena
			lFill := .t.
		endif
	endif
	
	if gRabIzRobe == "D" .and. lFill == .t. .and. nRabat <> 0 .and. ;
		nRabat <> field->n1
		_vars["n1"] := nRabat
	endif

    if lFill == .t.
		update_rec_server_and_dbf(nil, _vars)
	endif

endif

select (nTArea)
return



/*! \fn IniVars()
 *  \brief Ini varijable
 */
 
function IniVars()
*{
set cursor on

// varijable koje se inicijalizuju iz baze
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""        // txt1  -  naziv robe,usluge
_BrOtp:=space(8)
_DatOtp:=ctod("")
_BrNar:=space(8)
_DatPl:=ctod("")
_VezOtpr := ""

aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  _txt1:=aMemo[1]
endif
if len(aMemo)>=2
  _txt2:=aMemo[2]
endif
if len(aMemo)>=5
  _txt3a:=aMemo[3]; _txt3b:=aMemo[4]; _txt3c:=aMemo[5]
endif
if len(aMemo)>=9
 _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
endif
IF len (aMemo)>=10
  _VezOtpr := aMemo [10]
EndIF
*}



/*! \fn SetVars()
 *  \brief Setuj varijable
 */
 
function SetVars()
*{
if _podbr==" ." .or.  roba->tip="U" .or. (val(_Rbr)<=1 .and. val(_podbr)<1)
    _txt2:=OdsjPLK(_txt2)           // odsjeci na kraju prazne linije
    if ! "Faktura formirana na osnovu" $ _txt2
       _txt2 += CHR(13)+Chr(10)+_VezOtpr
    endif
    _txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
          Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
          Chr(16)+trim(_txt3c)+Chr(17) +;
          Chr(16)+_BrOtp+Chr(17) +;
          Chr(16)+dtoc(_DatOtp)+Chr(17) +;
          Chr(16)+_BrNar+Chr(17) +;
          Chr(16)+dtoc(_DatPl)+Chr(17) +;
          IIF (Empty (_VezOtpr), "", Chr(16)+_VezOtpr+Chr(17))
else
    _txt:=""
endif
return
*}



/*! \fn Tb_V_RBr()
 *  \brief
 */
 
function Tb_V_RBr()
*{
replace Rbr with str(nRbr,3)
return .t.
*}


/*! \fn Tb_W_IdRoba()
 *  \brief
 */
 
function Tb_W_IdRoba()
*{
_idroba:=padr(_idroba,15)
return W_Roba()
*}


/*! \fn TbRobaNaz()
 *  \brief
 */
 
function TbRobaNaz()
*{
NSRNPIdRoba()
// select roba; hseek fakt_pripr->idroba; select fakt_pripr
return left(Roba->naz,25)
*}


/*! \fn ObracunajPP(cSetPor,dDatDok)
 *  \brief Obracunaj porez na promet 
 *  \param cSetPor
 *  \param dDatDok
 */
 
function ObracunajPP(cSetPor,dDatDok)
*{

select (F_FAKT_PRIPR)
if !used()
	O_FAKT_PRIPR
endif
select (F_ROBA)
if !used()
	O_ROBA
endif
select (F_TARIFA)
if !used()
	O_TARIFA
endif

select fakt_pripr
go top
if dDatDok=NIL
  dDatDok:=fakt_pripr->DatDok
endif
if cSetPor=NIL
  cSetPor:="D"
endif

do while !eof()
 if cSetPor=="D"
  NSRNPIdRoba()
  // select roba; hseek fakt_pripr->idroba
  select tarifa; hseek roba->idtarifa
  if found()
    select fakt_pripr
    replace porez with tarifa->opp
  endif
 endif
 if datDok<>dDatdok
    replace DatDok with dDatDok
 endif
 select fakt_pripr
 skip
enddo

go top
RETURN
*}



/*! \fn UCKalk()
 *  \brief Uzmi cijenu iz Kalk-a
 */
 
function UCKalk()
*{
LOCAL nArr:=SELECT(), aUlazi:={}, GetList:={}, cIdPartner:=_idpartner
  LOCAL cSezona:="RADP", cPKalk:=""
  PUBLIC gDirKalk:=""
  O_PARAMS
  private cSection:="T",cHistory:=" "; aHistory:={}
  RPar("dk",@gDirKalk)
  if empty(gDirKalk)
    gDirKalk:=trim(strtran(goModul:oDataBase:cDirKum,"FAKT","KALK"))+"\"
    WPar("dk",gDirKalk)
  endif
  select 99; use
  Box("#ROBA:"+_IDROBA,4,50)
    @ m_x+2, m_y+2 SAY "Sifra dobavljaca             :" GET cIdPartner
    @ m_x+3, m_y+2 SAY "Sezona ('RADP'-tekuca godina):" GET cSezona
    READ
  BoxC()
  SETLASTKEY(0)
  select (F_KALK)
  IF cSezona=="RADP"
    cPKalk:=gDirKalk+"KALK"
  ELSE
    cPKalk:=gDirKalk+cSezona+"\KALK"
  ENDIF
  IF FILE(cPKalk+".DBF")
    USE (cPKalk)
  ELSE
    MsgBeep("Baza '"+cPKalk+".DBF' ne postoji !")
    SELECT (nArr); RETURN
  ENDIF
  set order to tag "7"   // "7","idroba"
  seek _idroba
  IF !FOUND()
    USE; SELECT (nArr); RETURN
  ENDIF
  DO WHILE !EOF() .and. _idroba==idroba
    IF idpartner==cIdPartner .and. idvd=="10" .and. kolicina>0
      AADD( aUlazi , idfirma+"-"+idvd+"-"+brdok+"³"+;
                     DTOC(datdok)+"³"+;
                     STR(kolicina,11,3)+"³"+;
                     STR(fcj,11,3)                     )
    ENDIF
    SKIP 1
  ENDDO
  USE
  SELECT (nArr)
  IF !( LEN(aUlazi)>0 ); RETURN; ENDIF
  h:=ARRAY(LEN(aUlazi)); AFILL(h,"")
  Box("#POSTOJECI ULAZI (KALK): ÍÍÍÍÍÍÍ <Enter>-izbor ",MIN(LEN(aUlazi),16)+3,51)
   @ m_x+1, m_y+2 SAY "    DOKUMENT   ³ DATUM  ³ KOLICINA  ³  CIJENA    "
   @ m_x+2, m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ"
   nPom := 1
   @ row()-1, col()-6 SAY ""
   nPom := Menu("KCME",aUlazi,nPom,.f.,,,{m_x+2,m_y+1})
   IF nPom>0
     _cijena  := VAL(ALLTRIM(RIGHT(aUlazi[nPom],11)))
     Menu("KCME",aUlazi,0,.f.)
   ENDIF
  BoxC()
RETURN
*}


/*! \fn ChSveStavke(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function ChSveStavke(fNovi)
*{
LOCAL nRec:=recno()
  set order to
  go top
  do while !eof()
    IF IDFIRMA+IDTIPDOK+BRDOK == _IDFIRMA+_IDTIPDOK+_BRDOK .or.;
       !fNovi .and. cOldKeyDok == IDFIRMA+IDTIPDOK+BRDOK
      RLOCK()
      _field->idfirma   := _IdFirma
      _field->datdok    := _DatDok
      _field->IdTipDok  := _IdTipDok
      _field->brdok     := _BrDok
      _field->dindem    := _dindem
      _field->zaokr     := _zaokr
      _field->idpartner := _idpartner
      IF lVrsteP
       _field->idvrstep:=_idvrstep
      ENDIF
      IF glDistrib
       _field->iddist   := _iddist
       _field->idrelac  := _idrelac
       _field->idvozila := _idvozila
       _field->idpm     := _idpm
       _field->marsruta := _marsruta
       _field->ambp     := _ambp
       _field->ambk     := _ambk
      ENDIF
      if glRadNal
      	_field->idRNal:=_idRNal
      endif
      IF !(_idtipdok="0") .and. lPoNarudzbi
       _field->idnar    := _idpartner
      ENDIF
      DBUNLOCK()
    ENDIF
    skip
  enddo
  set order to tag "1"
  go nRec
RETURN
*}



/*! \fn TarifaR(cRegion, cIdRoba, aPorezi)
 *  \brief Tarifa na osnovu region + roba
 *  \param cRegion
 *  \param cIdRoba
 *  \param aPorezi
 *  \note preradjena funkcija jer Fakt nema cIdKonto
 */
 
function TarifaR(cRegion, cIdRoba, aPorezi)
*{
local cTarifa
private cPolje

PushWa()

if empty(cRegion)
 cPolje:="IdTarifa"
else
   if cRegion=="1" .or. cRegion==" "
      cPolje:="IdTarifa"
   elseif cRegion=="2"
      cPolje:="IdTarifa2"
   elseif cRegion=="3"
      cPolje:="IdTarifa3"
   else
      cPolje:="IdTarifa"
   endif
endif

SELECT (F_ROBA)
if !used()
 O_ROBA
endif
seek cIdRoba
cTarifa:=&cPolje

SELECT (F_TARIFA)
if !used()
  O_TARIFA
endif
seek cTarifa

SetAPorezi(@aPorezi)

PopWa()
return tarifa->id
*}


// ----------------------------------------
//  PrCijSif()
//  Promjena cijene u sifrarniku
// ----------------------------------------
 
function PrCijSif()

NSRNPIdRoba()
select fakt_pripr

return .t.

// ---------------------------------------------
// NSRNPIIdRoba(cSR,fSint)
//  Nasteli sif->roba na fakt_pripr->idroba
//  cSR
//  fSint  - ako je fSint:=.t. sinteticki prikaz
// -----------------------------------------------
 
function NSRNPIdRoba(cSR, fSint)

if fSint == NIL
  fSint := .f.
endif

IF cSR == NIL
   cSR := fakt_pripr->IdRoba
ENDIF

SELECT ROBA

if (fSint)
  HSEEK PADR(LEFT(cSR, gnDS), LEN(cSR))
  IF !FOUND() .or. ROBA->tip != "S"
    HSEEK cSR
  ENDIF
else
  HSEEK cSR
endif

// TODO: http://redmine.bring.out.ba/issues/25746
// sta select(alias) vraca ?
if SELECT("PRIPR") != 0
  select fakt_pripr
else
  SELECT (F_PRIPR)
endif

return

// ------------------------------------------------------------
// RJIzKonta(cKonto)
// Vraca radnu jedinicu iz sif->konto na osnovu zadatog konta
//  param cKonto   - konto
// return cVrati
// ------------------------------------------------------------
 
function RJIzKonta(cKonto)
local cVrati:="  ", nArr:=SELECT(), nRec

SELECT (F_RJ)

nRec:=RECNO()
   
GO TOP
do while !EOF()
     if cKonto==RJ->konto
       cVrati:=RJ->id
       exit
     endif
     SKIP 1
enddo
  
GO (nRec)
SELECT (nArr)

return cVrati


/*! \fn KontoIzRJ(cRJ)
 *  \brief Vraca konto na osnovu radne jedinice
 *  \param cRJ  - radna jedinica
 *  \return cVrati
 */
 
function KontoIzRJ(cRJ)
local cVrati:=SPACE(7)
 PushWA()
   SELECT (F_RJ)
     HSEEK cRJ
     if FOUND()
       cVrati:=RJ->konto
     endif
 PopWA()
return cVrati



/*! \fn fakt_naredni_dokument(fNovi)
 *  \brief Postavlja u pripremi broj dokumenta - puni pripremu
 *  \brief fakt_naredni_dokument(fNovi)->cBroj  - Generise naredni broj dokumenta
 *  \param fNovi
 *  \return _brdok
 */
 
function fakt_naredni_dokument(fNovi)
*{
local nPrev:=SELECT()

if !EMPTY (fakt_pripr->BrDok) .or. eof()  // nema dokumenata
   // ovaj vec ima odredjen broj
   return fakt_pripr->BrDok
endif


if gMreznoNum == "D"
  select fakt_pripr
  nTrecPripr:=recno()
  go top
  _idtipdok:=fakt_pripr->idtipdok
  _idfirma:=fakt_pripr->idfirma
  _datdok:=fakt_pripr->datdok
  _dindem:=fakt_pripr->dindem
  _rezerv:=""
  _idpartner:=""
  _partner:=""
  _iznos:=0
  _rabat:=0
  _m1 := " "
  _idvrstep:=""
  if fakt_doks->(FIELDPOS("DATPL")>0)
    _datpl := CTOD("")
  endif
  if fakt_doks->(FIELDPOS("IDPM")>0)
    _idpm  := SPACE(15)
  endif
  go nTrecPripr
endif


// novi dokument, koji nema svog broja, u pripremi
select fakt_doks

if gMreznoNum == "D"
   if !FAKT_DOKS->(FLOCK())
      nOkr := 80     // daj mu 10 sekundi max
      do while nOkr > 0
         InkeySc (.125)
         nOkr --
         if fakt_doks->(FLOCK())
            exit
         endif
      enddo
      if nOkr == 0 .AND. ! fakt_doks->(FLOCK())
         Beep (4)
         Msg ("Nemoguce odrediti broj dokumenta - ne mogu pristupiti bazi!")
         return SPACE (LEN (_BrDok))
      endif
   endif
endif

cBroj1:=OdrediNBroj(_idfirma,_idtipdok)   //_brdok

if _idtipdok $ "12#13"

    if _idtipdok == "12"
        cTmpTip := "12"
        cTmpTip2 := "22"
    endif
    
    if _idtipdok == "13"
        cTmpTip := "13"
        cTmpTip2 := "23"
    endif
    
    cBroj2 := OdrediNBroj( _idfirma, cTmpTip2 )
    if VAL( LEFT( cBroj1, gNumDio )) >= VAL( LEFT(cBroj2, gNumDio))
        _Brdok := cBroj1
    else
            _BrDok := cBroj2
    endif
else
    _BrDok := cBroj1
endif

if gMreznoNum == "D"

  // pravi se fizicki append u bazi dokumenata da bi se sacuvalo mjesto
  // za ovaj dokument
  //
  select fakt_doks

  // dbappend()   // append blank skine LOCK sa baze
  appblank2 (.F., .F.)   // ne cisti, ne otkljucavaj
  _M1 := "Z"
  if fieldpos("SIFRA")<>0
    _sifra := sifrakorisn
  endif
  Gather2 ()
  DBUNLOCK()

  // popuni broj dokumenta u svakoj stavki pripreme
  select fakt_pripr
  nTekRec := RECNO ()
  nPrevOrd := INDEXORD()
  set order to
  go top

  LOCATE for IdFirma == _IdFirma .AND. IdTipDok == _IdTipDok ;
             .AND. EMPTY (BrDok)
  do while FOUND ()
    REPLACE BrDok WITH _BrDok
    CONTINUE
  END

  GO nTekRec
  DBSETORDER(nPrevOrd)
endif

return _BrDok




function JokSBr()
if "U" $ TYPE("BK_SB")
	BK_SB := .f.
endif
return IF(gNW=="R","  KJ/KG ", IIF(glDistrib,"", IIF(BK_SB, "  BARKOD   ", "Ser.broj")))

/*! \fn Koef(cDinDem)
 *  \brief Konverzija valute
 *  \param cDinDem
 */
 
function Koef(cdindem)
local nNaz, nRet, nArr, dDat

if cDinDem == LEFT(ValSekund(),3)
	return 1 / UbaznuValutu(datdok)
else
 	return 1
endif

/*! \fn SljBrDok13(cBrD,nBrM,cKon)
 *  \brief
 *  \param cBrD
 *  \param nBrM
 *  \param cKon
 */
 
function SljBrDok13(cBrD,nBrM,cKon)
local nPom
local cPom:=""
local cPom2

cPom2:=PADL(ALLTRIM(STR(VAL(ALLTRIM(SUBSTR(cKon,4))))),2,"0")
nPom:=AT("/",cBrD)

if VAL(SUBSTR(cBrD, nPom+1, 2)) != nBrM
    cPom:="01"
else
    cPom:=NovaSifra(SUBSTR(cBrD,nPom-2,2))
endif

return cPom2 + cPom + "/" + PADL(ALLTRIM(STR(nBrM)), 2, "0")


/*! \fn IsprUzorTxt(fSilent,bFunc)
 *  \brief Ispravka teksta ispod fakture
 *  \param fSilent
 *  \param bFunc
 */
 
function IsprUzorTxt(fSilent,bFunc)
local cListaTxt := ""

if fSilent==nil
    fSilent:=.f.
endif

lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )

if !fSilent
  Scatter()
endif

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
  _BrOtp:=space(50)
else
  _BrOtp:=space(8)
endif
_DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")

_VezOtpr := ""
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""        // txt1  -  naziv robe,usluge
nRbr:=RbrUNum(RBr)

if lDoks2
  d2k1 := SPACE(15)
  d2k2 := SPACE(15)
  d2k3 := SPACE(15)
  d2k4 := SPACE(20)
  d2k5 := SPACE(20)
  d2n1 := SPACE(12)
  d2n2 := SPACE(12)
endif

aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  _txt1:=aMemo[1]
endif
if len(aMemo)>=2
  _txt2:=aMemo[2]
endif
if len(aMemo)>=5
  _txt3a:=aMemo[3]; _txt3b:=aMemo[4]; _txt3c:=aMemo[5]
endif

if len(aMemo)>=9
 _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
endif
if len (aMemo)>=10 .and. !EMPTY(aMemo[10])
  _VezOtpr := aMemo [10]
endif

if lDoks2
  if len (aMemo)>=11
    d2k1 := aMemo[11]
  endif
  if len (aMemo)>=12
    d2k2 := aMemo[12]
  endif
  if len (aMemo)>=13
    d2k3 := aMemo[13]
  endif
  if len (aMemo)>=14
    d2k4 := aMemo[14]
  endif
  if len (aMemo)>=15
    d2k5 := aMemo[15]
  endif
  if len (aMemo)>=16
    d2n1 := aMemo[16]
  endif
  if len (aMemo)>=17
    d2n2 := aMemo[17]
  endif
endif

if !fSilent
    cListaTxt := g_txt_tipdok( _idtipdok )
    UzorTxt2( cListaTxt )
endif

if bFunc<>nil; EVAL(bFunc); endif

_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
      Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
      Chr(16)+trim(_txt3c)+Chr(17) +;
      Chr(16)+_BrOtp+Chr(17) +;
      Chr(16)+dtoc(_DatOtp)+Chr(17) +;
      Chr(16)+_BrNar+Chr(17) +;
      Chr(16)+dtoc(_DatPl)+Chr(17) +;
      Iif (Empty (_VezOtpr),Chr(16)+ ""+Chr(17), Chr(16)+_VezOtpr+Chr(17))+;
      IF( lDoks2 , Chr(16)+d2k1+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k2+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k3+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k4+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k5+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2n1+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2n2+Chr(17) , "" )
if !fSilent
  Gather()
endif
return


/*! \fn edit_fakt_doks2()
 *  \brief Editovanje DOKS2.DBF pri unosu fakture
 */
 
function edit_fakt_doks2()

local cPom:="", nArr:=SELECT(), GetList:={}

cPom := IzFMKINI("FAKT","Doks2Edit","N", KUMPATH) 
if cPom == "N"
    return
endif
 
cPom := IzFMKINI("FAKT","Doks2opis","dodatnih podataka",KUMPATH)

if Pitanje(,"Zelite li unos/ispravku "+cPom+"? (D/N)","N")=="N"
    SELECT(nArr)
    return
endif

// ucitajmo dodatne podatke iz FMK.INI u aDodPar
// ---------------------------------------------
aDodPar := {}

 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK1" , "K1" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK2" , "K2" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK3" , "K3" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK4" , "K4" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK5" , "K5" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZN1" , "N1" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZN2" , "N2" , KUMPATH )  )

 nd2n1 := VAL(d2n1)
 nd2n2 := VAL(d2n2)

 Box(,9,75)
   @ m_x+0, m_y+2 SAY "Unos/ispravka "+cPom COLOR "GR+/B"
   @ m_x+2, m_y+2 SAY PADL(aDodPar[1],30) GET d2k1
   @ m_x+3, m_y+2 SAY PADL(aDodPar[2],30) GET d2k2
   @ m_x+4, m_y+2 SAY PADL(aDodPar[3],30) GET d2k3
   @ m_x+5, m_y+2 SAY PADL(aDodPar[4],30) GET d2k4
   @ m_x+6, m_y+2 SAY PADL(aDodPar[5],30) GET d2k5
   @ m_x+7, m_y+2 SAY PADL(aDodPar[6],30) GET nd2n1 PICT "999999999.99"
   @ m_x+8, m_y+2 SAY PADL(aDodPar[7],30) GET nd2n2 PICT "999999999.99"
   READ
 BoxC()

 if LASTKEY()<>K_ESC
   d2n1 := IF( nd2n1<>0 , ALLTRIM(STR(nd2n1)) , "" )
   d2n2 := IF( nd2n2<>0 , ALLTRIM(STR(nd2n2)) , "" )
 endif

 SELECT (nArr)
return


// -------------------------------------------------
// provjeri cijenu sa cijenom iz sifrarnika
// -------------------------------------------------
function c_cijena( nCijena, cTipDok, lNovidok )
local lRet := .t.
local nRCijena := nil

// provjeru radi samo kod novog dokumenta
if !lNoviDok
    return lRet
endif

if cTipDok $ "11#15#27"
  
  if gMP == "1"
    nRCijena := roba->mpc
  elseif gMP == "3"
    nRCijena := roba->mpc2
  elseif gMP == "4"
    nRCijena := roba->mpc3
  elseif gMP == "5"
    nRCijena := roba->mpc4
  elseif gMP == "6"
    nRCijena := roba->mpc5
  elseif gMP == "7"
    nRCijena := roba->mpc6
  endif

elseif cTipDok $ "10#"
  // veleprodaja...
  nRCijena := roba->vpc
endif

if gPratiC == "D" .and. nRCijena <> nil .and. nCijena <> nRCijena
    msgbeep("Unesena cijena razlicita od cijene u sifrarniku !" + ; 
        "#Trenutna: " + ALLTRIM(STR(nCijena,12,2)) + ;
        ", sifrarnik: " + ALLTRIM(STR(nRCijena,12,2)) )
    if Pitanje(,"Koristiti ipak ovu cijenu ?", "D") == "N"
        lRet := .f.
    endif
endif

return lRet


/*! \fn SKCKalk(lSet)
 *  \brief Set Key za Cijenu iz Kalk
 *  \param lSet
 */
 
function SKCKalk(lSet)
// knjizna obavijest obavezno, a mo§e se podesiti i za ostale dokumente
if _idtipdok=="25" .or.;
     IzFMKIni("FAKT","TipDok"+_idtipdok+"_OmoguciUzimanjeFCJizKALK", "N", KUMPATH)=="D"
    if lSet
      SET KEY K_ALT_K to UCKalk()
      @ row()+1, 27 SAY REPLICATE("-", 26)
      @ row()+1, 27 SAY BROWSE_COL_SEP+" <a-K> uzmi FCJ iz KALK "+BROWSE_COL_SEP
      @ row()+1, 27 SAY REPLICATE("-", 26)
    else
      SET KEY K_ALT_K TO
      @ row()+1, 27 SAY "                          "
      @ row()+1, 27 SAY "                          "
      @ row()+1, 27 SAY "                          "
    endif
  endif
return .t.


function ImportTxt()
CLOSE ALL
cKom :="fmk.exe --batch --exe:ImportTxt --db:"+STRTRAN(TRIM(gNFirma), " ", "_") 
RUN &cKom

o_fakt_edit()
return


function GetKarC3N2(mx)
local nKor:=0
local nDod:=0
local x:=0
local y:=0

if (fakt_pripr->(fieldpos("C1"))<>0 .and. gKarC1=="D")
    @ mx+(++nKor),m_y+2 SAY "C1" GET _C1 pict "@!"
    nDod++
endif

if (fakt_pripr->(fieldpos("C2"))<>0 .and. gKarC2=="D")
    SljPozGet(@x,@y,@nKor,mx,nDod)
    @ x,y SAY "C2" GET _C2 pict "@!"
    nDod++
endif

if (fakt_pripr->(fieldpos("C3"))<>0 .and. gKarC3=="D")
    SljPozGet(@x,@y,@nKor,mx,nDod)
    @ x,y SAY "C3" GET _C3 pict "@!"
    nDod++
endif

if (fakt_pripr->(fieldpos("N1"))<>0 .and. gKarN1=="D")
    SljPozGet(@x,@y,@nKor,mx,nDod)
    @ x,y SAY "N1" GET _N1 pict "999999.999"
    nDod++
endif

if (fakt_pripr->(fieldpos("N2"))<>0 .and. gKarN2=="D")
    SljPozGet(@x, @y, @nKor, mx, nDod)
    @ x,y SAY "N2" GET _N2 pict "999999.999"
    nDod++
endif

if (fakt_pripr->(fieldpos("opis"))<>0)
    SljPozGet(@x,@y,@nKor,mx,nDod)
    @x,y SAY "Opis" GET _opis pict "@S40"
    nDod++
endif

if nDod>0
    ++nKor
endif

return nKor


function SljPozGet(x,y,nKor,mx,nDod)
if nDod > 0
    if nDod % 3 == 0
        x:=mx+(++nKor)
        y:=m_y+2
    else
        x:=mx+nKor
        y:=col()+2
    endif
else
    x:=mx+(++nKor)
    y:=m_y+2
endif
return


// ----------------------------------------------------------------------
// ispisuje informaciju o tekucem dokumentu na vrhu prozora 
// ----------------------------------------------------------------------
function TekDokument()
local nRec
local aMemo
local cTxt

cTxt := padr( "-", 60 )

if RecCount2() <> 0
    nRec := recno()
    go top
    aMemo := ParsMemo(txt)
    if len(aMemo)>=5
            cTxt := trim(amemo[3]) + " " + trim(amemo[4]) + "," + trim(amemo[5])
    else
            cTxt:=""
    endif
    cTxt:=padr(cTxt,30)
    cTxt := " " + alltrim(cTxt) + ", Broj: "+idfirma+"-"+idtipdok+"-"+brdok+", od "+dtoc(datdok)+" "
    go nRec
endif

@ m_x+0, m_y+2 SAY cTxt
return


// Rbr()
// Redni broj
 
function Rbr()
local cRet

if EOF()
    cRet:=""
elseif VAL(fakt_pripr->podbr)==0
    cRet:=fakt_pripr->rbr+")"
else
    cRet:=fakt_pripr->rbr+"."+alltrim(fakt_pripr->podbr)
endif

return padr(cRet,6)

/*! \fn CijeneOK(cStr)
 *  \brief
 *  \param cStr
 */
 
function CijeneOK(cStr)
local fMyFlag := .F., lRetFlag := .T., nTekRec
  select fakt_pripr
  nTekRec := RECNO ()
  if fakt_pripr->IdTipDok $ "10#11#15#20#25#27"
     // PROVJERI IMA LI NEODREDJENIH CIJENA ako se radi o fakturi
     Scatter()
     SET ORDER to tag "1"
     Seek2 (_IdFirma + _IdTipDok + _BrDok)
     do while ! EOF() .AND. IdFirma == _IdFirma .AND. ;
           IdTipDok == _IdTipDok .AND. BrDok == _BrDok
        if Cijena == 0 .and. EMPTY (PodBr)
           Beep (3)
           Msg ("Utvrdjena greska na stavci broj " + ;
                ALLTRIM (rbr) + "!#" + ;
                "CIJENA NIJE ODREDJENA!!!", 30)
           fMyFlag := .T.
        endif
        SKIP
     END
     if fMyFlag
        Msg (cStr+" nije dozvoljeno!#Vracate se na pripremu!", 30)
        lRetFlag := .F.
     endif
  endif
  GO nTekRec
return (lRetFlag)
*}


/*! \fn EdOtpr(Ch)
 *  \brief Ispravka otpremnica
 *  \param Ch
 */

function EdOtpr(Ch)
local cDn:="N",nRet:=DE_CONT
do case
    case Ch==ASC(" ") .or. Ch==K_ENTER
        Beep(1)
        if m1=" "    // iz DOKS
                replace m1 with "*"
                nSuma+=Iznos
        else
                replace m1 with " "
                nSuma-=Iznos
        endif
        @ m_x+1,m_Y+55 SAY nSuma pict picdem
        nRet:=DE_REFRESH
endcase

return nRet


/*! \fn renumeracija_fakt_pripr(cVezOtpr,dNajnoviji)
 *  \brief
 *  \param cVezOtpr
 *  \param dNajnoviji - datum posljednje radjene otpremnice
 */
 
function renumeracija_fakt_pripr(cVezOtpr,dNajnoviji)
//poziva se samo pri generaciji otpremnica u fakturu
local dDatDok
local lSetujDatum:=.f.
private nRokPl:=0
private cSetPor:="N"

select fakt_pripr
set order to tag "1"
go top
if RecCount2 () == 0
    return
endif

nRbr:=999
go bottom
do while !bof()
    replace rbr with str(--nRbr,3)
    skip -1
enddo

nRbr:=0
do while !eof()
    skip
    nTrec:=recno()
    skip -1
    if Empty(podbr)
        replace rbr with str(++nRbr,3)
    else
            if nRbr==0
            nRbr:=1
        endif
            replace rbr with str(nRbr,3)
    endif
    go nTrec
enddo

go top

Scatter()
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""
_dest := SPACE(150)
_m_dveza := SPACE(500)

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
    _BrOtp:=space(50)
else
    _BrOtp:=space(8)
endif
_DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")
if cVezOtpr==nil
    cVezOtpr:= ""
endif
aMemo:=ParsMemo(_txt)
if len(aMemo)>0
    _txt1:=aMemo[1]
endif
if len(aMemo)>=2
    _txt2:=aMemo[2]
endif
if len(aMemo)>=5
    _txt3a:=aMemo[3]
    _txt3b:=aMemo[4]
    _txt3c:=aMemo[5]
endif
if len(aMemo)>=9
    _BrOtp:=aMemo[6]
    _DatOtp:=ctod(aMemo[7])
    _BrNar:=amemo[8]
    _DatPl:=ctod(aMemo[9])
endif
if len(aMemo)>=10 .and. !EMPTY(aMemo[10])
    cVezOtpr := aMemo[10]
endif

// destinacija
if LEN( aMemo) >= 18
    _dest := PADR( aMemo[18], 150 )
endif

if LEN( aMemo ) >= 19
    _m_dveza := PADR( aMemo[19], 500 )
endif

nRbr:=1

Box("#PARAMETRI DOKUMENTA:",10,75)

  if gDodPar=="1"
    if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
      @  m_x+1,m_y+2 SAY "Otpremnica broj:" GET _brotp PICT "@S8"
    else
      @  m_x+1,m_y+2 SAY "Otpremnica broj:" GET _brotp
    endif
   @  m_x+2,m_y+2 SAY "          datum:" GET _Datotp
   @  m_x+3,m_y+2 SAY "Ugovor/narudzba:" GET _brNar
   @  m_x+4,m_y+2 SAY "    Destinacija:" GET _dest PICT "@S45"
   @  m_x+5,m_y+2 SAY "Vezni dokumenti:" GET _m_dveza PICT "@S45"
  endif

  if gDodPar=="1" .or. gDatVal=="D"
   nRokPl:=gRokPl
   @  m_x+6,m_y+2 SAY "Datum fakture  :" GET _DatDok
   if dNajnoviji<>NIL
    @  m_x+6,m_y+35 SAY "Datum posljednje otpremnice:" GET dNajnoviji WHEN .f. COLOR "GR+/B"
   endif
   @ m_x+7,m_y+2 SAY "Rok plac.(dana):" GET nRokPl PICT "999" WHEN FRokPl("0",.t.) VALID FRokPl("1",.t.)
   @ m_x+8,m_y+2 SAY "Datum placanja :" GET _DatPl VALID FRokPl("2",.t.)
   read
  endif

  read

BoxC()

dDatDok := _Datdok

UzorTxt()

if !Empty (cVezOtpr)
  _txt2 += Chr(13)+Chr(10)+cVezOtpr
endif

_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
      Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
      Chr(16)+trim(_txt3c)+Chr(17) +;
      Chr(16)+_BrOtp+Chr(17) +;
      Chr(16)+dtoc(_DatOtp)+Chr(17) +;
      Chr(16)+_BrNar+Chr(17) +;
      Chr(16)+dtoc(_DatPl)+Chr(17)+;
      IIF(Empty (cVezOtpr), "", Chr(16)+cVezOtpr+Chr(17))+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+Chr(17)+;
      Chr(16)+TRIM(_dest)+Chr(17)+;
      Chr(16)+TRIM(_m_dveza)+Chr(17)

if datDok<>dDatDok
    lSetujDatum:=.t.
endif

Gather()

return



// ---------------------------------
// prikaz partnera u prvoj stavki
// ---------------------------------
function Part1Stavka()
local cRet:=""

if alltrim(rbr) == "1"
  cRet += trim(IdPartner) + ": " 
endif

return cRet

// ------------------------------------------
// Roba() - prikazi robu 
// ------------------------------------------
function Roba()
local cRet := ""


cRet += trim(StIdROBA())+" "
do case
   case EOF()
    cRet := ""
   case  alltrim(podbr)=="."
    aMemo:=ParsMemo(txt)
    cRet += aMemo[1]
   otherwise
    select F_ROBA
    if !used()
        O_ROBA
    endif
    select roba
    seek fakt_pripr->IdRoba
    select fakt_pripr
    cRet += LEFT(ROBA->naz,40)
endcase

return padr( cRet, 30)


// -------------------------------------------------
//  JedinaStavka()
//  U dokumentu postoji samo jedna stavka
//
// -------------------------------------------------
function JedinaStavka()
nTekRec   := RECNO()
nBrStavki := 0
cIdFirma  := IdFirma
cIdTipDok := IdTipDok
cBrDok    := BrDok

GO TOP

HSEEK cIdFirma+cIdTipDok+cBrDok
do while ! eof () .and. (IdFirma==cIdFirma) .and. (IdTipDok==cIdTipDok) ;
      .AND. (BrDok==cBrDok)
    nBrStavki++
    SKIP
enddo

GO nTekRec

return IIF(nBrStavki == 1, .t., .f.)

