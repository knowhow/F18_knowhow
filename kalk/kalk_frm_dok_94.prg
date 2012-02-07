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


// prijem robe 16
// storno 14-ke fakture !!!!!!!!!! - 94
// storno otpreme  - 97

function Get1_94()
local nRVPC
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

set key K_ALT_K to KM94()

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

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
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz, 40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF lPoNarudzbi
  @ m_x+12,m_y+2 SAY "Po narudzbi br." GET _brojnar
  @ m_x+12,col()+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,12,50)
ENDIF

 @ m_x+12, m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
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

 @ m_x+13, m_y+2    SAY "NAB.CJ   "  GET _NC  picture gPicNC  when V_kol10()

 private _vpcsappp:=0


 if !IsMagPNab()

   if koncij->naz=="P2"
      @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "PLAN. C. " GET _VPC    picture picdem
   else
      if IsPDV()
        @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "PROD.CIJ " get _VPC    picture PicDEM
      else
        @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "VPC      " get _VPC    picture PicDEM
      endif
   endif

 if _IdVD $ "94"   // storno fakture

 @ m_x+15+IF(lPoNarudzbi,1,0),m_y+2    SAY "RABAT (%)" get _RABATV    picture picdem ;
      valid V_RabatV()

 _PNAP:=0
 if IsPDV()
    _MPC := tarifa->opp
    @ m_x+16,m_y+2    SAY "PDV (%)  " + TRANSFORM(_MPC,"99.99")
 else
    @ m_x+16, m_y+2    SAY "PPP (%)  " get _MPC pict "99.99" ;
    when {|| iif(roba->tip=="V",_mpc:=0,NIL),iif(roba->tip=="V",ppp14(.f.),.t.)} ;
    valid ppp14(.t.)
 endif
 if !IsPDV()
    @ m_x+17, m_y+2    SAY "PRUC (%) "; qqout(transform(TARIFA->VPP,"99.99"))
 endif

 if gVarVP=="1"
  _VPCsaPP:=0
  if IsPDV()
    @ m_x+19, m_y+2  SAY "PC SA PDV  "
  else
    @ m_x+19, m_y+2  SAY "VPC + PPP  "
  endif
  @ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
       when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
       valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}

 else  // preracunate stope
  _VPCsaPP:=0
  if IsPDV()
    @ m_x+19,m_y+2  SAY "PC SA PDV  "
  else
    @ m_x+19, m_y+2  SAY "VPC + PPP  "
  endif

  @ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
       when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
       valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}
 endif


 if !IsPDV() .and. gMagacin=="1"  // ovu cijenu samo prikazati ako se vodi po nabavnim cijenama
  _VPCSAPPP:=0
  @ m_x+20, m_y+2 SAY "VPC + PPP + PRUC:"
  @ m_x+20, m_Y+50 GET _vpcSaPPP picture picdem  ;
       VALID {||  VPCSAPPP()}
 endif

 endif // _idvd $ "94"

 read // vodi se po vpc

 else // vodi se po nc
  read
  _VPC:=_nc; marza:=0
 endif

 if !IsMagPNab()
   SetujVPC(_vpc)
 endif

ENDIF    // kraj IF gVarEv=="1"

 _mpcsapp:=0
nStrana:=2

_marza:=_vpc-_nc
_MKonto:=_Idkonto;_MU_I:="1"
_PKonto:=""; _PU_I:=""
set key K_ALT_K to
return lastkey()
*}



/*! \fn KM94()
 *  \brief Magacinska kartica kao pomoc pri unosu 94-ke
 */

// koristi se stkalk14   za stampu kalkulacije
// stkalk 95 za stampu 16-ke
function KM94()
*{
local nR1,nR2,nR3
private GetList:={}
select  roba
nR1:=recno()
select kalk_pripr
nR2:=recno()
select tarifa
nR3:=recno()
close all
Karticam(_IdFirma,_idroba,_IdKonto)
o_kalk_edit()
select roba
go nR1
select kalk_pripr
go nR2
select tarifa
go nR3
select kalk_pripr
return
*}

