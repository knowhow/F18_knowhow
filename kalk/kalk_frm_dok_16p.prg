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


function Get1_16PDV()
local nRVPC
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

set key K_ALT_K to KM94()

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if empty(_TMarza);  _TMarza:="%" ; endif

if nRbr==1 .or. !fnovi .or. gMagacin=="1"
 if _idvd $ "94#97"
  @  m_x+6,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,18)
 endif
 @  m_x+7,m_y+2   SAY "Faktura/Otpremnica Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
    valid {|| _DatKurs:=_DatFaktP,.t.}
 

  @ m_x+9,m_y+2 SAY "Magacinski konto zaduzuje"  GET _IdKonto ;
              valid empty(_IdKonto) .or. P_Konto(@_IdKonto,21,5)
  if gNW<>"X"
    @ m_x+9,m_y+40 SAY "Zaduzuje:" GET _IdZaduz   pict "@!"  valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,21,5)
  else
    if !empty(cRNT1)
      @ m_x+9,m_y+40 SAY "Rad.nalog:"   GET _IdZaduz2  pict "@!"
    endif
  endif


  if _idvd=="16"
   @ m_x+10,m_y+2   SAY "Prenos na konto          " GET _IdKonto2   valid empty(_idkonto2) .or. P_Konto(@_IdKonto2,21,5) pict "@!"
   if gNW<>"X"
     @ m_x+10,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz2  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz2,21,5)
   endif
  endif

else
 @  m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 _DatKurs:=_DatFaktP
 @ m_x+9,m_y+2 SAY "Magacinski konto zaduzuje "; ?? _IdKonto
 if gNW<>"X"
  @ m_x+9,m_y+40 SAY "Zaduzuje: "; ?? _IdZaduz
 endif

endif

 @ m_x+10,m_y+66 SAY "Tarif.brĿ"
 if lKoristitiBK
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF lPoNarudzbi
  @ m_x+12,m_y+2 SAY "Po narudzbi br." GET _brojnar
  @ m_x+12,col()+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,12,50)
ENDIF

 // IF !lPoNarudzbi
   @ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 // ENDIF
 
 IF IsDomZdr()
   @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 ENDIF
 
 read; ESC_RETURN K_ESC
 if lKoristitiBK
    _idRoba:=Left(_idRoba, 10)
 endif

 select koncij; seek trim(_idkonto)  // postavi TARIFA na pravu poziciju
 select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select kalk_pripr  // napuni tarifu
 _MKonto:=_Idkonto; _MU_I:="1"

IF gVarEv=="1"          ///////////////////////////// sa cijenama
    DatPosljK()
    DuplRoba()
    _GKolicina:=0
    if fNovi
        select ROBA; HSEEK _IdRoba
        if koncij->naz=="P2"
                _nc:=plc
                _vpc:=plc
        else
            _VPC:=KoncijVPC()
            _NC:=NC
        endif
    endif
    VTPorezi()
    select kalk_pripr

    @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2    SAY "NAB.CJ   "  GET _NC  picture gPicNC  when V_kol10()

    private _vpcsappp:=0

    if !IsMagPNab()
   
        private fMarza:=" "
        @ m_x+16,m_y+36   SAY "Magacin. Marza   :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
        @ m_x+16,col()+1  GET _Marza PICTURE PicDEM
        @ m_x+16,col()+1 GET fMarza pict "@!" valid {|| Marza(fMarza),fMarza:=" ",.t.}
        @ m_x+19,m_y+2    SAY "PROD.CJENA BEZ PDV:"
        @ m_x+19,col()+2  get _VPC    picture PicDEM;
                    VALID {|| Marza(fMarza),.t.}
        if !IsMagPNab()
                _mpcsapp:=roba->mpc
            // VPC se izracunava pomocu MPC cijene !!
            @ m_x+20,m_y+2 SAY "PROD.CJENA SA PDV:"
            @ m_x+20,col()+2 GET _MPCSaPP  picture PicDEM ;
                        valid {|| _mpcsapp:=iif(_mpcsapp=0,round( _vpc * (1+TARIFA->opp/100),2),_mpcsapp),_mpc:=_mpcsapp/(1+TARIFA->opp/100),iif(_mpc<>0,_vpc:=round(_mpc,2),_vpc), ShowGets(),.t.}
        endif
        read
        
        if !IsMagPNab()
                if (roba->mpc==0 .or. roba->mpc<>round(_mpcsapp,2)) .and. Pitanje(,"Staviti MPC u sifrarnik")=="D"
                    select roba
                replace mpc with _mpcsapp
                    select kalk_pripr
                endif

                SetujVPC(_VPC )  

        endif

    else // vodi se po nc
        read
        _VPC:=_nc; marza:=0
    endif

    if !IsMagPNab()
        SetujVpc(_vpc)
    endif
    
ENDIF

nStrana:=2

_marza:=_vpc-_nc
_MKonto:=_Idkonto
_MU_I:="1"
_PKonto:=""
_PU_I:=""

set key K_ALT_K to

return lastkey()
*}




/*! \fn Get1_16bPDV()
 *  \brief
 */

// _odlval nalazi se u knjiz, filuje staru vrijednost
// _odlvalb nalazi se u knjiz, filuje staru vrijednost nabavke
function Get1_16bPDV()
*{
local cSvedi:=" "

fnovi:=.t.
private PicDEM:="9999999.99999999",PicKol:="999999.999"
Beep(1)
@ m_x+2,m_Y+2 SAY "PROTUSTAVKA   (svedi na staru vrijednost - kucaj S):"
@ m_x+2,col()+2 GET cSvedi valid csvedi $ " S" pict "@!"
read

@ m_x+11,m_y+66 SAY "Tarif.brĿ"
@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!" ;
                  valid  {|| P_Roba(@_IdRoba),Reci(12,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=ROBA->idtarifa,.t.}
@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read; ESC_RETURN K_ESC
select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
select koncij; seek trim(_idkonto)
select kalk_pripr  // napuni tarifu

_PKonto:=_Idkonto
DatPosljP()
DuplRoba()

private fMarza:=" "

@ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

select koncij; seek trim(_idkonto)
select ROBA; HSEEK _IdRoba
_VPC:=KoncijVPC()
_TMarza2:="%"
_TCarDaz:="%"
_CarDaz:=0

select kalk_pripr

VTPorezi()
select kalk_pripr

IF gVarEv=="1"

 @ m_x+14,m_y+2    SAY "NAB.CJ   "  GET _NC  picture  gPicNC  when V_kol10()

 private _vpcsappp:=0

 if !IsMagPNab()

    @ m_x+15,m_y+2   SAY "PROD. CIJ " get _VPC    picture PicDEM

 else // vodi se po nc
    _VPC:=_nc; marza:=0
 endif

 cBeze:=" "
 @ m_x+17,m_y+2 GET cBeze valid  SvediM(cSvedi)

ENDIF

read

IF gVarEv=="1"

 if !IsMagPNab()
   SetujVPC(_vpc)
 endif

ENDIF

nStrana:=2
_marza:=_vpc-_nc
_MKonto:=_Idkonto;_MU_I:="1"
_PKonto:=""; _PU_I:=""
_ERROR:="0"
nStrana:=3
return lastkey()
*}




