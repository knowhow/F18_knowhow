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


function Get1_11()
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

private aPorezi:={}

if nRbr==1  .or. !fnovi
 _GKolicina:=_GKolicin2:=0
 if _IdVD $ "11#12#13#22"
   _IdPartner:=""
   @  m_x+6,m_y+2   SAY "Otpremnica - Broj:" get _BrFaktP
   @  m_x+6,col()+2 SAY "Datum:" get _DatFaktP
 endif
 _DatKurs:=_DatFaktP

 @ m_x+8,m_y+2   SAY "Prodavnicki Konto zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto, 21, 5) pict "@!"
 if gNW<>"X"
   @ m_x+8,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif

 @ m_x+9,m_y+2   SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
            valid empty(_IdKonto2) .or. P_Konto(@_IdKonto2, 21, 5 )
 if gNW<>"X"
   @ m_x+9,m_y+42 SAY "Razduzuje:" GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2,24)
 endif
 read; ESC_RETURN K_ESC
else
 if _IdVD $ "11#12#13#22"
   @  m_x+6,m_y+2   SAY "Otpremnica - Broj: "; ?? _BrFaktP
   @  m_x+6,col()+2 SAY "Datum: "; ?? _DatFaktP
 endif
 @ m_x+8,m_y+2   SAY "Prodavnicki Konto zaduzuje "; ?? _IdKonto
 if gNW<>"X"
   @ m_x+8,m_y+42  SAY "Zaduzuje: "; ?? _IdZaduz
 endif
 @ m_x+9,m_y+2   SAY "Magacinski konto razduzuje "; ?? _IdKonto2
 if gNW<>"X"
   @ m_x+9,m_y+42  SAY "Razduzuje: "; ?? _IdZaduz2
 endif
endif

 @ m_x+10,m_y+66 SAY "Tarifa ->"
 if lKoristitiBK
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba()
else
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid VRoba()
endif
         
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

 IF !lPoNarudzbi
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 ENDIF
 
 IF IsDomZdr()
   @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 ENDIF
 
 read
 ESC_RETURN K_ESC
 
 if lKoristitiBK
    _idRoba:=Left(_idRoba,10)
 endif

 select koncij
 seek trim(_idkonto)
 select kalk_pripr  // napuni tarifu

 _MKonto:=_Idkonto2
 _PKonto:=_Idkonto
 DatPosljK()
 DatPosljP()
 DuplRoba()


_GKolicina:=_GKolicin2:=0
if fNovi
 select roba
 _MPCSaPP:=UzmiMPCSif()


if (IsPDVMagNab() .or. IsMagSNab())
   _FCJ:=NC
   _VPC:=NC
else
   _FCJ:=NC
   _VPC:=UzmiVPCSif(_mkonto)

   select koncij
   seek trim(_pkonto)
   select roba
   if gcijene=="2"
      FaktMPC(@_MPCSAPP,_idfirma+_Pkonto+_idroba)
   endif

endif


 select kalk_pripr
 _Marza2:=0
 _TMarza2:="A"
endif

if gcijene=="2" .OR. ROUND(_VPC,3)=0 // uvijek nadji
  select koncij; seek trim(_mkonto); select kalk_pripr  // magacin
  FaktVPC(@_VPC,_idfirma+_mkonto+_idroba)
  select koncij; seek trim(_pkonto); select kalk_pripr  // magacin
endif

VTPorezi()

//////// kalkulacija nabavne cijene u magacinu
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0
nKolZN:=0
nc1:=0
nc2:=0
lGenStavke:=.f.
if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
if !empty(gMetodaNC) .or. lPoNarudzbi
 nc1:=nc2:=0
 dDatNab:=ctod("")
 if lPoNarudzbi
   aNabavke:={}
   IF !fNovi
     AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
   ENDIF
   IF !fNovi
     IF _kolicina<0
       KalkNab3p(_idfirma,_idroba,_idkonto,aNabavke,@nKolS)
     ELSE
       KalkNab3m(_idfirma,_idroba,_idkonto2,aNabavke,@nKolS)
     ENDIF
   ELSEIF Pitanje(,"1-zaduzenje prodavnice , 2-povrat iz prodavnice (1/2) ?",IF(_idvd=="12","2","1"),"12")=="2"
     KalkNab3p(_idfirma,_idroba,_idkonto,aNabavke,@nKolS)
   ELSE
     KalkNab3m(_idfirma,_idroba,_idkonto2,aNabavke,@nKolS)
   ENDIF
   IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF
   IF LEN(aNabavke)>0
     // - tekuca -
     i:=LEN(aNabavke)
     _fcj := _nc := aNabavke[i,2]
     _kolicina := aNabavke[i,3]
     _idnar    := aNabavke[i,4]
     _brojnar  := aNabavke[i,5]
     // ----------
   ENDIF
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
   @ row(),col()+2 SAY IspisPoNar(,,.t.)
 else
   if _kolicina>0
    MsgO("Racunam stanje na skladistu")
      KalkNab(_idfirma,_idroba,_idkonto2,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
    MsgC()
   else
    MsgO("Racunam stanje prodavnice")
      KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,dDatNab,@_RokTr)
    MsgC()
   endif
 endif
 if !lPoNarudzbi
  if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
  if gMetodaNC $ "13"; _fcj:=nc1; elseif gMetodaNC=="2"; _fcj:=nc2; endif
 endif
endif
endif

 if _kolicina>0
  @ m_x+12,m_y+30   SAY "Na stanju magacin "; @ m_x+12,col()+2 SAY nkols pict pickol
 else
  @ m_x+12,m_y+30   SAY "Na stanju prodavn "; @ m_x+12,col()+2 SAY nkols pict pickol
 endif

select koncij
seek trim(_idkonto2)
select kalk_pripr

if IsPDvMagNab() .or. IsMagSNab()
        //_VPC:=_NC
    _vpc:=_fcj
    @ m_x+14,m_y+2    SAY "NABAVNA CIJENA (NC)       :"  
    if _kolicina>0
            @ m_x+14,m_y+50   get _FCj    picture gPicNC ;
                        VALID {|| V_KolMag(), _vpc:=_Fcj, .t.}
    else // storno zaduzenja prodavnice
            @ m_x+14,m_y+50   get _FCJ    picture PicDEM;
                     VALID {|| V_KolPro(),;
                               _vpc:=_fcj, .t.}
    endif
else
        // ima vpc
    if _kolicina>0
        @ m_x+14,m_y+2    SAY "NC  :"  GET _fcj picture gPicNC valid V_KolMag()
    else // storno zaduzenja
        @ m_x+14,m_y+2    SAY "NC  :"  GET _fcj picture gPicNC valid V_KolPro()
    endif
    @ m_x+14,col()+2  SAY "VPC :"  GET _vpc picture picdem ;
             when {|| iif(gCijene=="2",.f.,.t.)}
endif

// prodavnica
select koncij
seek trim(_idkonto)
select kalk_pripr

if fNovi
    _TPrevoz:="R"
endif

if nRBr==1 .or. !fNovi // prva stavka
    @ m_x+15, m_y+2 SAY "MP trosak (A,R):" GET _TPrevoz VALID _tPrevoz $ "AR"
    @ m_x+15,col()+2 GET _prevoz PICT PICDEM
else
    @ m_x+15,m_y+2 SAY "MP trosak:"; ?? "("+_tPrevoz+") "; ?? _prevoz
endif

private fMarza:=" "
@ m_x+16,m_y+2 SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+16,col()+1  GET _Marza2 PICTURE  PicDEM ;
    valid {|| _nc:=_fcj+iif(_TPrevoz=="A",_Prevoz,0),;
              _Tmarza:="A",;
              _marza:=_vpc/(1+_PORVT)-_fcj, .t.}
@ m_x+16,col()+1 GET fMarza pict "@!"   VALID {|| Marza2(fMarza),fMarza:=" ",.t.}

if IsPDV()
    @ m_x+18,m_y+2  SAY "PRODAJNA CJENA       :"
else
    @ m_x+18,m_y+2  SAY "MALOPROD. CJENA (MPC):"
endif

@ m_x+18,m_y+50 GET _MPC picture PicDEM valid VMpc(.f.,fMarza) when WMpc(.f.,fMarza)

SayPorezi(19)

if IsPDV()
    @ m_x+20,m_y+2 SAY "PROD.C. SA PDV:"
else
    @ m_x+20,m_y+2 SAY "MPC SA POREZOM:"
endif
@ m_x+20,m_y+50 GET _MPCSaPP  picture PicDEM VALID VMPCSaPP(.f.,fMarza)

read
ESC_RETURN K_ESC

select koncij
seek trim(_idkonto)
StaviMPCSif(_mpcsapp,.t.)       // .t. znaci sa upitom
select kalk_pripr

// izlaz iz magacina
_MKonto:=_Idkonto2
_MU_I:="5"     

// ulaz u prodavnicu
_PKonto:=_Idkonto
_PU_I:="1"     

nStrana:=2

FillIzgStavke(pIzgSt)
return lastkey()
*}
 
