/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "kalk.ch"


function Get1_14PDV()

pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

set key K_ALT_K to KM2()

if nRbr==1 .and. fnovi
    _DatFaktP:=_datdok
endif

if nRbr==1 .or. !fnovi
    @ m_x+6,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,18)
    @ m_x+7,m_y+2   SAY "Faktura Broj:" get _BrFaktP
    @ m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
            valid {|| .t.}
    _IdZaduz:=""
    _Idkonto:="1200"
    private cNBrDok:=_brdok
    @ m_x+9,m_y+2 SAY "Magacinski konto razduzuje"  GET _IdKonto2 VALID valid_mag_konto_14(@_idkonto2, @_brdok)
    
    if gNW<>"X"
        @ m_x+9,m_y+40 SAY "Razduzuje:" GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2, 21, 5)
    endif
else
    @ m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
    @ m_x+7,m_y+2   SAY "Faktura Broj: "; ?? _BrFaktP
    @ m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
    
    _IdZaduz:=""
    _Idkonto:="1200"
    @ m_x+9,m_y+2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
    if gNW<>"X"
        @ m_x+9,m_y+40 SAY "Razduzuje: "; ?? _IdZaduz2
    endif
endif

@ m_x+10,m_y+66 SAY "Tarif.brĿ"

if lKoristitiBK
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz, 40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
else
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba), Reci(11,23,trim(LEFT(roba->naz, 40))+" ("+ROBA->jmj+")",40), _IdTarifa:=iif(fnovi,ROBA->idtarifa, _IdTarifa),.t.}
endif

@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF !lPoNarudzbi
    @ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
ENDIF

IF IsDomZdr()
    @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
ENDIF

read
ESC_RETURN K_ESC

_MKonto:=_Idkonto2
 
if lKoristitiBK
    _idRoba:=Left(_idRoba, 10)
endif

select TARIFA
hseek _IdTarifa

select ROBA
HSEEK _IdRoba
select koncij
seek trim(_idkonto2)
select kalk_pripr  // napuni tarifu

if koncij->naz="P"
    _FCJ:=roba->PlC
endif

DatPosljK()
DuplRoba()

if fNovi
    select roba
    _VPC:=KoncijVPC()
    _NC:=NC
    select kalk_pripr
endif

if gCijene="2" .and. fNovi

    /////// utvrdjivanje fakticke VPC
    if gPDVMagNab == "N"
        faktVPC(@_VPC,_idfirma+_idkonto2+_idroba)
    endif
    select kalk_pripr
endif

VtPorezi()

_GKolicina:=0

//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

nKolS:=0
nKolZN:=0
nc1:=0
nc2:=0
dDatNab:=ctod("")
lGenStavke:=.f.

if _TBankTr<>"X"   // ako je X onda su stavke vec izgenerisane
    if !empty(gMetodaNC) 
            MsgO("Racunam stanje na skladistu")
                KalkNab(_idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab)
            MsgC()
            @ m_x+ 12, m_y+30   SAY "Ukupno na stanju "
        @ m_x+ 12, col()+2 SAY nKols pict pickol
    endif
    if dDatNab>_DatDok
            Beep(1)
            Msg("Datum nabavke je "+dtoc(dDatNab), 4)
    endif
        // Vindija trazi da se uvijek nudi srednja nabavna cijena
        // kada malo razmislim najbolje da se ona uvijek nudi
    //if _kolicina >= 0
            if gMetodaNC $ "13"
            _nc := nc1
        elseif gMetodaNC=="2"
            _nc := nc2
        endif
    //endif
endif
select kalk_pripr


@ m_x + 13, m_y+2    SAY "NAB.CJ   "  GET _NC  picture PicDEM      valid V_KolMag()

private _vpcsappp:=0

@ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "PC BEZ PDV" get _VPC  valid {|| iif(gVarVP=="2" .and. (_vpc-_nc)>0,cisMarza:=(_vpc-_nc)/(1+tarifa->vpp),_vpc-_nc),.t.}  picture PicDEM

private cTRabat:="%"
@ m_x+15+IF(lPoNarudzbi,1,0),m_y+2    SAY "RABAT    " GET  _RABATV pict picdem
@ m_x+15+IF(lPoNarudzbi,1,0),col()+2  GET cTRabat  pict "@!" ;
     valid {|| PrerRab(), V_RabatV(), ctrabat $ "%AU" }

_PNAP:=0

if IsPdv()
    _MPC := tarifa->opp
endif

if gPDVMagNab == "D"
    @ m_x+16,m_y+2 SAY "PDV (%)  " + TRANSFORM(_MPC, "99.99")
else
    @ m_x+16,m_y+2 SAY "PDV (%)  " GET _MPC pict "99.99" when {|| iif(roba->tip $ "VKX",_mpc:=0,NIL),iif(roba->tip $ "VKX",pPDV14(.f.),.t.)} valid pPDV14(.t.)
endif

if gVarVP=="1"
    _VPCsaPP:=0
    @ m_x+19+IF(lPoNarudzbi,1,0),m_y+2  SAY "PC SA PDV "
    @ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
        when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
        valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}

else  // preracunate stope

    _VPCsaPP:=0
    @ m_x+19+IF(lPoNarudzbi,1,0),m_y+2  SAY "PC SA PDV "
    @ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
        when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
        valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}
endif

read

nStrana:=2

if roba->tip == "X"
    _marza:=_vpc-_mpcsapp/(1+_PORVT)*_PORVT-_nc
else
    _mpcsapp:=0
    _marza:=_vpc/(1+_PORVT)-_nc
endif


// izlaz iz magacina
_MKonto := _Idkonto2
_MU_I:="5"     
_PKonto:=""; _PU_I:=""

if _idvd == "KO"
    _MU_I:="4" // ne utice na stanje
endif

if pIzgSt .and. _kolicina>0 .and. lastkey()<>K_ESC // izgenerisane stavke postoje
    private nRRec:=recno()
    go top
    do while !eof()  // nafiluj izgenerisane stavke
        if kolicina==0
                skip
                private nRRec2:=recno()
                skip -1
                dbdelete2()
                go nRRec2
                loop
        endif
        if brdok==_brdok .and. idvd==_idvd .and. val(Rbr)==nRbr

                nMarza:=_VPC/(1+_PORVT)*(1-_RabatV/100)-_NC  // ??????????
                replace vpc with _vpc,;
                rabatv with _rabatv,;
                mkonto with _mkonto,;
                tmarza  with _tmarza,;
                mpc     with  _MPC,;
                marza  with _vpc/(1+_PORVT)-kalk_pripr->nc,;   // mora se uzeti nc iz ove stavke
                vpcsap with _VPC/(1+_PORVT)*(1-_RABATV/100)+iif(nMarza<0,0,nMarza)*TARIFA->VPP/100,;
                mu_i with  _mu_i,;
                pkonto with "",;
                pu_i with  "",;
                error with "0"
        endif
        skip
    enddo
    go nRRec
endif

set key K_ALT_K to
return lastkey()




/*! \fn pPDV14(fret)
 *  \brief Prikaz PDV pri unosu 14-ke
 */

function pPDV14(fRet)
*{
devpos(m_x+16+IF(lPoNarudzbi,1,0),m_y+41)
if roba->tip $ "VKX"
    // nista ppp
else
    qqout("   PDV:",transform(_PNAP:=_VPC*(1-_RabatV/100)*_MPC/100,picdem) )
endif

_VPCSaP:=iif(_VPC<>0, _VPC*(1-_RABATV/100) + iif(nMarza<0,0,nMarza) * TARIFA->VPP/100,0)
return fret
*}


