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
   _cijena:=UzmiMPCsif()

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
	cRjTip:=rj->tip
  	IF gVarNum=="1" .and. gVar13=="2" .and. _idtipdok=="13"
    		hseek RJIzKonta(_idpartner+" ")
  	ENDIF

	NSRNPIdRoba(_IDROBA)
  	select ROBA
	if !(roba->tip="U")  // usluge ne diraj
  		if _idtipdok=="13" .and. (gVar13=="2".or.glCij13Mpc).and.gVarNum=="1"
      			if gVar13=="2" .and. _idtipdok=="13"
        			_cijena := UzmiMPCSif()
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
       			_cijena:=UzmiMPCSif()
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
			_cijena:=UzmiVPCSif()
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

if lPoNarudzbi
	select fakt_pripr
  	return .t.
endif

select fakt
set order to 3

lBezMinusa := ( IzFMKIni("FAKT","NemaIzlazaBezUlaza","N",KUMPATH) == "D" )

if !(roba->tip="U") .and. !empty(_IdRoba) .and.  left(_idtipdok,1) $ "12"  ;
	.and. (gPratiK=="D".or.lBezMinusa) .and. ;
   	!(left(_idtipdok,1) == "1" .and. left(_serbr,1)="*")  
	// ovo je onda faktura
        // na osnovu otpremnice

	if gTBDir="N"
  		MsgO("Izracunavam trenutno stanje ...")
	endif
 	
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

	if gTBDir="N"
  		MsgC()
	else
  		@ m_x+17, m_y+1   SAY "Artikal: "
		?? _idRoba 
		?? "("+roba->jmj+")"
  		@ m_x+18, m_y+1   SAY "Stanje :"
  		@ m_x+18, col()+1 SAY nUl-nIzl-nRevers-nRezerv  picture pickol
  		@ m_x+19, m_y+1   SAY "Tarifa : " 
		?? roba->idtarifa
	endif

	if ( ( nUl - nIzl - nRevers - nRezerv - _kolicina ) < 0 )
 		
		fakt_box_stanje({{_IdFirma, nUl,nIzl,nRevers,nRezerv}},_idroba)
 		
		if _idtipdok = "1" .and. lBezMinusa
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
	_rabat := RabVrijednost(gcRabDef, cTipRab, _idroba, gcRabIDef)
	if lSkonto
		_skonto := SKVrijednost(gcRabDef, cTipRab, _idroba)
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
      		BrowseKart(cPom)    
		// prelistaj kalkulacije
      		&cVarIdRoba:=cPom
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
	if gTBDir=="N"
    		if IsPDV()
			@ m_X+16,m_y+28 SAY "TBr: "
			?? roba->idtarifa, "PDV", str(tarifa->opp,7,2)+"%"
		else
			@ m_X+16,m_y+28 SAY "TBr: "
			?? roba->idtarifa, "PPP", str(tarifa->opp,7,2)+"%", "PPU", str(tarifa->ppp,7,2)
  		endif
	endif
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
 		UsTipke()
 		private fUMemu:=.t.
 		_txt2:=MemoEdit(_txt2,m_x+3,m_y+1,m_x+9,m_y+76)
 		fUMemu:=NIL
 		//BosTipke()
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
 	UsTipke()
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
static function _add_to_txt( cId_txt, nCount, lAppend )
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
static function InoKlauzula()

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
static function KmsKlauzula()

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

if gTBDir="N"

if !(roba->tip="U")
 devpos(m_x+15,m_y+25)
 ?? space(40)
 devpos(m_x+15,m_y+25)

 ?? trim(LEFT(roba->naz,40)),"("+roba->jmj+")"
endif
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
  UsTipke()
  if gTBDir=="D"
    @ row(),col()-15 GET _txt1 pict "@S40"
  else
    @ row(),m_y+25 GET _txt1 pict "@S40"
  endif
  read
  BosTipke()
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

select roba
go top
seek cIdRoba

if FOUND()	

	// provjeri da li je cijena ista ?

	if cIdTipDok $ "#10#01#12#20#" .and. nCijena <> 0
		if field->vpc <> nCijena .and. ;
			Pitanje(, "Postaviti novu VPC u sifranik ?", "N") == "D"
			replace field->vpc with nCijena
			lFill := .t.
		endif
	elseif cIdTipDok $ "#11#13#" .and. nCijena <> 0
		if field->mpc <> nCijena .and. ;
			Pitanje(,"Postaviti novu MPC u sifrarnik ?", "N") == "D"
			replace field->mpc with nCijena
			lFill := .t.
		endif
	endif
	
	if gRabIzRobe == "D" .and. lFill == .t. .and. nRabat <> 0 .and. ;
		nRabat <> field->n1
		replace field->n1 with nRabat
	endif

endif

select (nTArea)
return



