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


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 


/*! \file fmk/kalk/prod/dok/1g/frm_80.prg
 *  \brief Maska za unos dokumenta tipa 80
 */


/*! \fn Get1_80()
 *  \brief Prva strana maske za unos dokumenta tipa 80
 */

// prijem prodavnica, predispozicija

function Get1_80()
*{
private aPorezi:={}
if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1  .or. !fnovi
 @  m_x+7,m_y+2   SAY "Dokument - Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP

 @ m_x+9,m_y+2   SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
   @ m_x+9,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 @ m_x+10,m_y+2   SAY "Prenos na konto    " GET _IdKonto2   valid empty(_idkonto2) .or. P_Konto(@_IdKonto2,24) pict "@!"
 if gNW<>"X"
   @ m_x+10,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz2  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz2,24)
 endif

 read
 ESC_RETURN K_ESC
 _DatKurs:=_DatFaktP
else
 @  m_x+7,m_y+2   SAY "Dokument - Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 @  m_x+9 ,m_y+2  SAY "Konto koji zaduzuje "; ?? _IdKonto
 @  m_x+10,m_y+2  SAY "Prenos na konto     "; ?? _IdKonto2
 if gNW<>"X"
   @  m_x+9,m_y+35  SAY "Zaduzuje: "; ?? _IdZaduz
   @  m_x+10,m_y+35 SAY "Zaduzuje: "; ?? _IdZaduz2
 endif
 read
 ESC_RETURN K_ESC
endif

// planika, skeniraj dok.u procesu....
pl_scan_dok_u_procesu(_idkonto)

select kalk_pripr

@ m_x+11,m_y+66 SAY "Tarif.br->"

if lKoristitiBK
	@ m_x+12,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba_lv(fNovi, @aPorezi)
else
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!"  valid  VRoba_lv(fNovi, @aPorezi)
endif
@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

VTPorezi()

  @ m_x+13, m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

IF IsDomZdr()
   @ m_x+13, m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
ENDIF

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif

select TARIFA
//hseek _IdTarifa  // postavi TARIFA na pravu poziciju

select koncij
seek trim(_idkonto)
select kalk_pripr  // napuni tarifu

_PKonto:=_Idkonto
DatPosljP()
DuplRoba()

private fMarza:=" "

if fNovi
 select koncij
 seek trim(_idkonto)
 select ROBA
 HSEEK _IdRoba

 _MPCSapp:=UzmiMPCSif()

 _TMarza2:="%"
 _TCarDaz:="%"
 _CarDaz:=0
endif

select kalk_pripr

@ m_x+14, m_y+2     SAY "NABAVNA CJENA:"

@ m_x+14, m_y+50    GET _NC ;
       when VKol() ;
       PICTURE PicDEM 

@ m_x+16, m_y+2 SAY "Marza:" GET _TMarza2  ;
         VALID _Tmarza2 $ "%AU" ;
	 PICTURE "@!"
	 
@ m_x+16, col()+2  GET _Marza2  ;
       PICTURE  PicDEM ;
       valid {|| _vpc:=_nc, .t.}
       
@ m_x+16, col()+1 GET fMarza pict "@!"

@ m_x+17, m_y+2  SAY "MALOPROD. CJENA (MPC):"
@ m_x+17, m_y+50 GET _MPC ;
        picture PicDEM;
	WHEN W_MPC_("80", (fMarza == "F"), @aPorezi) ;
     	VALID V_Mpc_ ("80", (fMarza=="F"), @aPorezi)

SayPorezi_lv(19, aPorezi)

if IsPDV()
	@ m_x+20, m_y+2 SAY "PC SA PDV     :"
else
	@ m_x+20, m_y+2 SAY "MPC SA POREZOM:"
endif

@ m_x+20, m_y+50 GET _MPCSaPP  picture PicDEM ;
    	   VALID V_MpcSaPP_( "80", .f., @aPorezi, .t.)

read
ESC_RETURN K_ESC


select koncij
seek trim(_idkonto)

StaviMPCSif(_MpcSapp, .t.)

select kalk_pripr

_PKonto:=_Idkonto
_PU_I:="1"
_MKonto:=""
_MU_I:=""

nStrana:=3
return lastkey()
*}



// PROTUSTAVKA 80-ka, druga strana
// _odlval nalazi se u knjiz, filuje staru vrijenost
// _odlvalb nalazi se u knjiz, filuje staru vrijenost nabavke
function Get1_80b()
local cSvedi:="M"
private aPorezi:={}

fnovi:=.t.
private PicDEM:="9999999.99999999" 
PicKol:="999999.999"
Beep(1)
@ m_x+2,m_Y+2 SAY "PROTUSTAVKA   ( S-svedi M-mpc sifr i ' '-ne diraj):"
@ m_x+2,col()+2 GET cSvedi valid csvedi $ " SM" pict "@!"
read

@ m_x+11,m_y+66 SAY "Tarif.br->"
@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!" ;
                  valid  VRoba_lv(fNovi, @aPorezi)
@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read
ESC_RETURN K_ESC
select koncij
seek trim(_idkonto)
select kalk_pripr 

_PKonto:=_Idkonto
DatPosljP()
DuplRoba()

private fMarza:=" "

@ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

select koncij
seek trim(_idkonto)
select ROBA
HSEEK _IdRoba

if _mpcsapp == 0  // ako nije popunjeno
 _MPCSapp:=UzmiMPCSif()
endif

_TMarza2:="%"
_TCarDaz:="%"
_CarDaz:=0

select kalk_pripr

@ m_x+14,m_y+2     SAY "NABAVNA CJENA:"
@ m_x+14,m_y+50    GET _NC     PICTURE PicDEM when VKol()

@ m_x+16,m_y+2 SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+16,col()+2  GET _Marza2 PICTURE  PicDEM valid {|| _vpc:=_nc, .t.}
@ m_x+16,col()+1 GET fMarza pict "@!"

if IsPDV()
	@ m_x+17,m_y+2  SAY "PROD.CJENA BEZ PDV   :"
else
	@ m_x+17,m_y+2  SAY "MALOPROD. CJENA (MPC):"
endif

@ m_x+17,m_y+50 GET _MPC picture PicDEM WHEN WMpc_lv(nil, nil, aPorezi) VALID VMpc_lv(nil, nil, aPorezi)
	       
SayPorezi_lv(19, aPorezi)

if IsPDV()
	@ m_x+20,m_y+2 SAY "P.CJENA SA PDV:"
else
	@ m_x+20,m_y+2 SAY "MPC SA POREZOM:"
endif

@ m_x+20,m_y+50 GET _MPCSaPP  picture PicDEM ;
     valid {|| Svedi(cSvedi), VMpcSapp_lv(nil, nil, aPorezi) }

read
ESC_RETURN K_ESC

select koncij
seek trim(_idkonto)

StaviMPCSif(_mpcsapp,.t.)

select kalk_pripr

_PKonto:=_Idkonto

if IsPlanika()
	_PU_I := "P"
else
	_PU_I := "1"
endif

_MKonto:=""
_MU_I:=""

nStrana:=3
return lastkey()




/*! \fn Svedi(cSvedi)
 *  \brief Svodi vrijednost protustavke na vrijednost stavke
 */

function Svedi(cSvedi)
*{
if cSvedi=="M"

    select koncij
    seek trim(_idkonto)
    select ROBA
    HSEEK _IdRoba
    _MPCSapp:=UzmiMPCSif()
    
elseif csvedi=="S"
   if _mpcsapp<>0
    _kolicina:=-round(_oldval/_mpcsapp,4)
   else
    _kolicina:=99999999
   endif
   if _kolicina<>0
    _nc:=abs(_oldvaln/_kolicina)
   else
    _nc:=0
   endif
endif
return .t.
*}




/*! \fn VKol()
 *  \brief Validacija unesene kolicine u dokumentu tipa 80
 */

static function VKol()
*{
if _kolicina<0  // storno
//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
 if !empty(gMetodaNC)
  MsgO("Racunam stanje u prodavnici")
  KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
  MsgC()
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
 endif
 if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 if _nc==0; _nc:=nc2; endif
 //if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
 if nkols < abs(_kolicina)
   _ERROR:="1"
   Beep(2)
   Msg("Na stanju je samo kolicina:"+str(nkols,12,3))
 endif
select kalk_pripr
endif
return .t.
*}

