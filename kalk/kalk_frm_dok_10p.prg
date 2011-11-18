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

// konverzija valute
static __k_val


// -----------------------------------------------
// unos dokumenta tip "10" - prva stranica
// -----------------------------------------------
function Get1_10PDV()

__k_val := "N"

if nRbr == 1 .and. fNovi
	_DatFaktP:=_datdok
endif

if nRbr == 1  .or. !fNovi .or. gMagacin=="1"
	
	@  m_x+6,m_y+2   SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid {|| empty(_IdPartner) .or. P_Firma(@_IdPartner,6,22), _ino_dob( _idpartner ) }
 	
	@  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj:" get _BrFaktP
 	
	@  m_x+7,col()+2 SAY "Datum:" get _DatFaktP
 	
	if is_uobrada()
		@ m_x+8,m_y+2 SAY "Odobrenje broj:" GET _odobr_no PICT "@S10"
	endif
	
	_DatKurs:=_DatFaktP
 	@ m_x+10,m_y+2   SAY "Magacinski Konto zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 	if gNW<>"X"
  		@ m_x+10,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 	endif
 	if !empty(cRNT1)
   		@ m_x+10,m_y+42  SAY "Rad.nalog:"   GET _IdZaduz2  pict "@!"
 	endif
 	read
	ESC_RETURN K_ESC
else
	
	@ m_x+6,m_y+2 SAY "DOBAVLJAC: "
	?? _IdPartner
 	@ m_x+7,m_y+2 SAY "Faktura dobavljaca - Broj: "
	?? _BrFaktP
 	@ m_x+7,col()+2 SAY "Datum: "
	?? _DatFaktP
	
	if is_uobrada()
		@ m_x + 8, m_y+2 SAY "Odobrenje:"
		?? PADR(_odobr_no, 10)
	endif
	
	@ m_x+10,m_y+2 SAY "Magacinski Konto zaduzuje "
	?? _IdKonto
 	if gNW<>"X"
   		@ m_x+10,m_y+42 SAY "Zaduzuje: "
		?? _IdZaduz
 	endif
	
	_ino_dob( _idpartner )
	
endif

@ m_x+11,m_y+66 SAY "Tarif.brĿ"

if lKoristitiBK
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba ;
		PICT "@!S10" ;
		WHEN {|| _idroba:=padr(_idroba,VAL(gDuzSifIni)),.t. } ;
		VALID {|| ;
			_idroba := iif(len(trim(_idroba))<10,left(_idroba,10),_idroba), ;
			P_Roba(@_IdRoba), ;
			Reci(12,MAXROWS()-1,trim(LEFT(roba->naz, 40)) + " (" + ROBA->jmj + ")",40), ;
			_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa), ;
		.t. }
else
	@ m_x+12, m_y+2  SAY "Artikal  " GET _IdRoba ;
		PICT "@!" ;
		VALID {|| ;
			_idroba := iif(len(trim(_idroba))<10, left(_idroba,10), _idroba), ;
			fix_sifradob(@_idroba,5,"0"), ;
			P_Roba(@_IdRoba, nil, nil, gArtCDX ), ;
			Reci(12,MAXROWS()-1,trim(LEFT(roba->naz, 40))+" ("+ROBA->jmj+")",40), ;
			_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa), ;
		.t. }
endif

@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba, 10)
endif

select koncij
seek trim(_idkonto)
select kalk_pripr

_MKonto:=_Idkonto
_MU_I:="1"
DatPosljK()

select TARIFA
hseek _IdTarifa 
select kalk_pripr  

@ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0


if is_uobrada()
	@ m_x+13,col()+1 SAY "JCI br:" GET _jci_no PICT "@S10" 
endif

if IsDomZdr()
	@ m_x+14+IF(lPoNarudzbi,1,0),m_y+2 SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
endif

if fNovi
	select ROBA
	HSEEK _IdRoba
 	_VPC := KoncijVPC()
	if Carina<>0
    		_TCarDaz:="%"
    		_CarDaz:=carina
 	endif
endif

select kalk_pripr

if _tmarza<>"%"  
	// procente ne diraj
	_Marza:=0
endif

if gVarEv=="1"
	@ m_x+15+IF(lPoNarudzbi,1,0),m_y+2   SAY "F.CJ.(DEM/JM):"

	if gDokKVal == "D"
		@ m_x + 15, m_y + 40 SAY "pr.->" GET __k_val VALID _val_konv(__k_val) PICT "@!"
	endif
	
 	@ m_x+15+IF(lPoNarudzbi,1,0),m_y+50  GET _FCJ PICTURE gPicNC valid {|| _fcj > 0 .and. _set_konv( @_fcj, @__k_val ) } when V_kol10()
	@ m_x+17+IF(lPoNarudzbi,1,0),m_y+2   SAY "KASA-SKONTO(%):"
 	@ m_x+17+IF(lPoNarudzbi,1,0),m_y+40 GET _Rabat PICTURE PicDEM when DuplRoba()
	if gNW<>"X"   .or. gVodiKalo=="D"
   		@ m_x+18, m_y+2   SAY "Normalni . kalo:"
   		@ m_x+18, m_y+40  GET _GKolicina PICTURE PicKol
		@ m_x+19, m_y+2   SAY "Preko  kalo:    "
   		@ m_x+19, m_y+40  GET _GKolicin2 PICTURE PicKol
	endif
endif

read
ESC_RETURN K_ESC

_FCJ2:=_FCJ*(1-_Rabat/100)

return lastkey()


// --------------------------------------------------
// da li je dobavljac ino, setuje valutiranje
// --------------------------------------------------
static function _ino_dob( cPartn )

if gDokKVal == "D" .and. fNovi .and. isinodob( cPartn ) 
	__k_val := "D"
endif

return .t.



// ---------------------------------------
// validacija unosa preracuna
// ---------------------------------------
static function _val_konv( cDn )
local lRet := .t.

if cDN $ "DN"
	return lRet
else
	msgbeep("Preracun: " + valpomocna() + "=>" + valdomaca() + "#Unjeti 'D' ili 'N' !")
	lRet := .f.
	return lRet
endif

return .t.


// --------------------------------------
// konverzija fakturne cijene
// --------------------------------------
static function _set_konv( nFcj, cPretv )

if cPretv == "D"
	a_val_convert()	
	cPretv := "N"
	showgets()
endif

return .t.



// --------------------------------------------------
// unos dokumenta "10" - druga stranica
// --------------------------------------------------
function Get2_10PDV()
local cSPom:=" (%,A,U,R) "
private getlist:={}

if empty(_TPrevoz); _TPrevoz:="%"; endif
if empty(_TCarDaz); _TCarDaz:="%"; endif
if empty(_TBankTr); _TBankTr:="%"; endif
if empty(_TSpedTr); _TSpedtr:="%"; endif
if empty(_TZavTr);  _TZavTr:="%" ; endif
if empty(_TMarza);  _TMarza:="%" ; endif

// automatski setuj troskove....
_auto_set_trosk( fNovi )

@ m_x+2,m_y+2     SAY c10T1+cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
@ m_x+2,m_y+40    GET _Prevoz PICTURE  PicDEM

@ m_x+3,m_y+2     SAY c10T2+cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" pict "@!"
@ m_x+3,m_y+40    GET _BankTr PICTURE PicDEM

@ m_x+4,m_y+2     SAY c10T3+cSPom GET _TSpedTr valid _TSpedTr $ "%AUR" pict "@!"
@ m_x+4,m_y+40    GET _SpedTr PICTURE PicDEM

@ m_x+5,m_y+2     SAY c10T4+cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
@ m_x+5,m_y+40    GET _CarDaz PICTURE PicDEM

@ m_x+6,m_y+2     SAY c10T5+cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
@ m_x+6,m_y+40    GET _ZavTr PICTURE PicDEM ;
                    VALID {|| NabCj(),.t.}

@ m_x+8,m_y+2     SAY "NABAVNA CJENA:"
@ m_x+8,m_y+50    GET _NC     PICTURE gPicNC

if !IsMagSNab() 
	private fMarza:=" "
  	@ m_x+10,m_y+2    SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
  	@ m_x+10,m_y+40 GET _Marza PICTURE PicDEM
  	@ m_x+10,col()+1 GET fMarza pict "@!" valid {|| Marza(fMarza),fMarza:=" ",.t.}
    	if koncij->naz=="P2"
     		@ m_x+12,m_y+2    SAY "PLANSKA CIJENA  (PLC)       :"
    	else
		@ m_x+12,m_y+2    SAY "PROD.CJENA BEZ PDV   :"
    	endif
    	@ m_x+12,m_y+50 get _VPC    picture PicDEM ;
                      VALID {|| MarzaVP(_Idvd, (fMarza == "F") ), .t. }

  	if (gMpcPomoc == "D")
    		_mpcsapp:=roba->mpc
   		// VPC se izracunava pomocu MPC cijene !!
       		@ m_x+16,m_y+2 SAY "PROD.CJENA SA PDV:"
       		@ m_x+16,m_y+50 GET _MPCSaPP  picture PicDEM ;
             		valid {|| _mpcsapp:=iif(_mpcsapp=0,round(_vpc*(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),2),_mpcsapp),_mpc:=_mpcsapp/(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),;
                       iif(_mpc<>0,_vpc:=round(_mpc,2),_vpc), ShowGets(),.t.}

  	endif

  	read

  	if (gMpcPomoc == "D")
		if (roba->mpc==0 .or. roba->mpc<>round(_mpcsapp,2)) .and. Pitanje(,"Staviti MPC u sifrarnik")=="D"
         		select roba
			replace mpc with _mpcsapp
         		select kalk_pripr
     		endif
  	endif

  	SetujVPC(_VPC )  
else
	read
  	_Marza:=0
	_TMarza:="A"
	_VPC:=_NC
endif

_MKonto:=_Idkonto
_MU_I:="1"
nStrana:=3
return lastkey()
*}


// ------------------------------------------------------
// automatsko setovanje troskova kalkulacije
// na osnovu sifrarnika robe
//
// lNewItem - radi se o novoj stavci
// ------------------------------------------------------
static function _auto_set_trosk( lNewItem )

local lForce := .f.

// ako nema polja TROSK1 u robi idi dalje....
// nemas sta raditi

if roba->(fieldpos("TROSK1")) == 0
	return
endif

// ako su automatski troskovi = "N", izadji
if gRobaTrosk == "N"
	return 
endif

if gRobaTrosk == "0"
	
	if Pitanje( ,"Preuzeti troskove iz sifrarnika robe ?", "D" ) == "N"
		return
	endif
	
	// setuj forirano uzimanje troska.....
	lForce := .t.
	
endif

if ( _Prevoz == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_Prevoz := roba->trosk1
	
	if !Empty(gRobaTr1Tip)
		_TPrevoz := gRobaTr1Tip
	endif
	
endif

if ( _BankTr == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_BankTr := roba->trosk2
	
	if !Empty(gRobaTr2Tip)
		_TBankTr := gRobaTr2Tip
	endif
	
endif

if ( _SpedTr == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_SpedTr := roba->trosk3

	if !Empty(gRobaTr3Tip)
		_TSpedTr := gRobaTr3Tip
	endif
	
endif

if ( _CarDaz == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_CarDaz := roba->trosk4

	if !EMPTY(gRobaTr4Tip)
		_TCarDaz := gRobaTr4Tip
	endif
	
endif

if ( _ZavTr == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_ZavTr := roba->trosk5

	if !EMPTY(gRobaTr5Tip)
		_TZavTr := gRobaTr5Tip
	endif
	
endif

return


// ---------------------------------------------------------
// unos dokumenta "10" - skracena varijanta bez troskova
// ---------------------------------------------------------
function Get1_10sPDV()
local nNCpom:=0

__k_val := "N"

if nRbr==1  .or. !fNovi
 _DatFaktP:=_datdok
 @  m_x+6,m_y+2   SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid {|| empty(_IdPartner) .or. P_Firma(@_IdPartner,6,22), _ino_dob(_idpartner) }
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP
 _DatKurs:=_DatFaktP
 
 if is_uobrada()
 	@ m_x+8, m_y+2 SAY "Odobrenje:" GET _odobr_no PICT "@S10"
 endif
 
 @ m_x+10,m_y+2   SAY "Magacinski Konto zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
  @ m_x+10,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read; ESC_RETURN K_ESC
else
 @  m_x+6,m_y+2   SAY "DOBAVLJAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP

 @ m_x+10,m_y+2   SAY "Magacinski Konto zaduzuje ";?? _IdKonto
 if gNW<>"X"
  @ m_x+10,m_y+42  SAY "Zaduzuje: "; ?? _IdZaduz
 endif
 _ino_dob( _idpartner )
endif

IF !glEkonomat
  @ m_x+11,m_y+66 SAY "Tarif.brĿ"
ENDIF
@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!" ;
                  valid  {|| P_Roba(@_IdRoba),Reci(12,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
IF !glEkonomat
  @ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)
ENDIF

read; ESC_RETURN K_ESC

select koncij; seek trim(_IdKonto)
select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
select kalk_pripr  // napuni tarifu
_MKonto:=_Idkonto; _MU_I:="1"

DatPosljK()
DuplRoba()

@ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
if fNovi
 select ROBA
 HSEEK _IdRoba
 _VPC := KoncijVPC()
endif

select kalk_pripr
if _tmarza<>"%"  // procente ne diraj
 _Marza:=0
endif

if is_uobrada()
	@ m_x+13,col()+1 SAY "JCI br:" GET _jci_no PICT "@S10" 
endif

IF gVarEv=="1"

 IF !glEkonomat
   
   nYpos := m_y + 2
   
   if gDokKVal == "D"
   
   	@ m_x + 15, nYpos SAY "pr" GET __k_val VALID _val_konv(__k_val) PICT "@!"
   	
	nYpos := col() + 2 
   
   endif
   
   @ m_x+15, nYpos SAY "F.CJ.(DEM/JM):"
   @ m_x+15, col() + 2 GET _FCJ PICTURE gPicNC ;
   	VALID {|| _fcj > 0, _set_konv( @_fcj, @__k_val ) } ;
	WHEN V_kol10()

   @ m_x+15, m_y + 40   SAY "Rabat(%):"
   @ m_x+15, col()+2 GET _Rabat PICTURE PicDEM valid {|| _FCJ2:=_FCJ*(1-_Rabat/100),NabCj(),nNCpom:=_NC,.t.}
 
 ENDIF

@ m_x+17,m_y+2     SAY "NABAVNA CJENA:"
@ m_x+17,col()+2    GET _NC     PICTURE gPicNC VALID NabCj2(_NC,nNCpom)



if empty(_TPrevoz); _TPrevoz:="%"; endif
if empty(_TCarDaz); _TCarDaz:="%"; endif
if empty(_TBankTr); _TBankTr:="%"; endif
if empty(_TSpedTr); _TSpedtr:="%"; endif
if empty(_TZavTr);  _TZavTr:="%" ; endif
if empty(_TMarza);  _TMarza:="%" ; endif

if !IsMagSNab()
   private fMarza:=" "
   @ m_x+17,m_y+36   SAY "Magacin. Marza   :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
   @ m_x+17,col()+1  GET _Marza PICTURE PicDEM
   @ m_x+17,col()+1 GET fMarza pict "@!" valid {|| Marza(fMarza),fMarza:=" ",.t.}
   @ m_x+19,m_y+2    SAY "PROD.CJENA BEZ PDV:"
   @ m_x+19,col()+2  get _VPC    picture PicDEM;
                    VALID {|| Marza(fMarza),.t.}
   if (gMpcPomoc=="D")
    	_mpcsapp:=roba->mpc
   	// VPC se izracunava pomocu MPC cijene !!
   	@ m_x+20,m_y+2 SAY "PROD.CJENA SA PDV:"
   	@ m_x+20,col()+2 GET _MPCSaPP  picture PicDEM ;
             		valid {|| _mpcsapp:=iif(_mpcsapp=0, round( _vpc * (1+TARIFA->opp/100),2), _mpcsapp), _mpc:=_mpcsapp/(1+TARIFA->opp/100), iif(_mpc<>0,_vpc:=round(_mpc,2),_vpc), ShowGets(),.t.}

   endif
   read

   SetujVPC(_VPC )    
   if (gMpcPomoc=="D")
     	if (roba->mpc==0 .or. roba->mpc<>round(_mpcsapp,2)) .and. Pitanje(,"Staviti MPC u sifrarnik")=="D"
       		select roba
		replace mpc with _mpcsapp
       		select kalk_pripr
     	endif


   endif
 
 else
   read
   _Marza:=0
   _TMarza:="A"
   _VPC:=_NC
 endif

ELSE  
  read
ENDIF

_MKonto:=_Idkonto
_MU_I:="1"
nStrana:=3
return lastkey()
*}


