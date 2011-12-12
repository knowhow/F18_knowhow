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


#include "mat.ch"

function mat_knjizenje_naloga()


PRIVATE PicDEM:="9999999.99"
PRIVATE PicBHD:="999999999.99"
PRIVATE PicKol:="999999.999"

public gPotpis:="N"
PicUN:="999999999.99"
private fK1:=fk2:=fk3:=fk4:="N"
************************************************
O_PARAMS
Private cSection:="1",cHistory:=" ",aHistory:={}
Params1()
RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)
RPar("po",@gPotpis)
select params; use

if gNW$"DR"
  KnjNal()
else
 private opc[4],Izbor:=1
 Opc[1]:="1. knjizenje mat_naloga    "
 Opc[2]:="2. stampa mat_naloga"
 Opc[3]:="3. azuriranje podataka"
 Opc[4]:="4. kurs "+KursLis
 h[1]:=h[2]:=h[3]:=h[4]:=""

 do while .t.
 Izbor:=menu("knjiz",opc,Izbor,.f.)

   do case
     case izbor == 0
         exit
     case izbor == 1
         KnjNal()
     case izbor == 2
         mat_st_nalog()
     case izbor == 3
         Azur()
     case izbor == 4
       if KursLis=="1"  // prva vrijednost
         KursLis:="2"
       else
         KursLis:="1"
       endif
       opc[4]:="4. kurs "+KursLis
   endcase

 enddo
endif

closeret


*******************************
*******************************
Function KnjNal()

O_Edit()

ImeKol:={ ;
          {"F.",         {|| IdFirma }, "idfirma" } ,;
          {"VN",         {|| IdVN    }, "idvn" } ,;
          {"Br.",        {|| BrNal   }, "brnal" } ,;
          {"R.br",       {|| RBr     } } ,;
          {IF(gSeks=="D","Predmet","Konto"),      {|| IdKonto } ,"idkonto"} ,;
          {"Partner",    {|| idpartner}, "idpartner" }  ,;
          {"Artikal",    {|| IdRoba}, "idroba" }  ,;
          {"U/I",        {|| U_I     }, "U_I" } ,;
          {"Kolicina",      {|| transform(Kolicina,"999999.99")} } ;
       }

IF gNW=="R"
 AADD(ImeKol,{"Datum",               {|| DatDok                       }, "datdok" })
ELSE
 AADD(ImeKol,{"Cijena ",             {|| transform(Cijena,"99999.999") }           })
 AADD(ImeKol,{"Iznos "+ValPomocna(), {|| transform(Iznos,"9999999.9") }           })
 AADD(ImeKol,{"Iznos "+ValDomaca(),  {|| transform(Iznos2,"9999999.9")}           })
 AADD(ImeKol,{"Datum",               {|| DatDok                       }, "datdok" })
ENDIF

       //   {"Datum",      {|| DatDok  } } ,;
       //   {"D/P",           {|| D_P     }, "D_P" } ,;
       //   {"Tip Dok",       {|| IdTipDok}, "IdTipDok" } ,;
       //   {"Br.Dok",        {|| BrDok   }, "BrDok" } ,;
       //   {"Zaduz.",        {|| IdZaduz } } ,;
       //   {"Partner",       {|| IdPartner} } ,;

Kol:={}; for i:=1 to LEN(ImeKol); AADD(Kol,i); next

Box(,20,77)
@ m_x+18,m_y+2 SAY " <c-N>  Nove Stavke       ³ <ENT> Ispravi stavku   ³ <c-T> Brisi Stavku "
@ m_x+19,m_y+2 SAY " <c-A>  Ispravka mat_naloga   ³ <c-P> Stampa mat_naloga    ³ <a-A> Azuriranje   "
@ m_x+20,m_y+2 SAY " <c-F9> Brisi mat_pripremu    ³ <F5>  Kontrola zbira   ³                    "
ObjDbedit("PNal",20,77,{|| EdPRIPR()},"","Priprema..", , , , ,3)
BoxC()

closeret


function O_Edit()

O_mat_psuban
O_mat_panal
O_mat_psint
O_mat_pnalog

O_MAT_SUBAN
O_KARKON
O_MAT_PRIPR
O_KONTO
O_PARTN
O_TNAL
O_TDOK
O_ROBA
O_SIFV
O_SIFK
O_VALUTE
O_MAT_NALOG
O_TARIFA

select mat_pripr
#ifndef C50
set order to tag "1"
#else
set order to 1
#endif
go top
return

******************************************************
* ulaz _IdFirma, ...., nRedBr (str(_RBr))
******************************************************
function EditPRIPR(fNovi)
   private nKurs:=0
   if fnovi .and. nRbr==1; _idfirma:=gFirma; endif

   if gNW$"DR"
    @  m_x+1,m_y+2   SAY "Firma: "; ?? gFirma,"-",gNFirma
   else
    @  m_x+1,m_y+2   SAY "Firma:"    get _IdFirma valid {|| P_Firma(@_IdFirma,1,20),_idfirma:=left(_idfirma,2),.t.}
   endif

   @  m_x+3,m_y+2   SAY "NALOG:   Vrsta:"  get _IdVN    valid P_VN(@_IdVN,3,23)
   read; ESC_RETURN 0

   if fnovi .and. (_idfirma<>idfirma .or. _idvn<>idvn)
     select mat_nalog; seek _idfirma+_idvn+"X"; skip -1
     if idvn<>_idvn
       _brnal:="0000"
     else
       _brnal:=brnal
     endif
     _brnal:=NovaSifra(_brnal)
     select  mat_pripr
   endif


   @  m_x+3,m_y+52  SAY "Broj:"   get _BrNal   valid Dupli(_BrNal,_IdVN,_IdFirma) .and. !empty(_BrNal)

   @  m_x+5,m_y+2  SAY "Redni broj stavke mat_naloga:" get nRbr picture "9999"

   if  gKupZad=="D"
    @ m_x+7,m_y+2    SAY "Dobavljac/Kupac" get _IdPartner valid empty(_IdPartner) .or. P_Firma(@_IdPartner,24)
    @ m_x+7,m_y+40   SAY "Zaduzuje " GET _IdZaduz pict "@!" valid empty(_IdZaduz) .or. P_Firma(@_IdZaduz,24)
   endif

   @  m_x+9,m_y+2  SAY "DOKUMENT:"
   if gNW=="N"
    @  m_x+9,m_y+12 SAY "Tip :" get _IdTipDok valid P_TipDok(@_IdTipDok)
    @  m_x+9,m_y+24 SAY "Broj:"   get _BrDok
   else
    @  m_x+9,m_y+13 SAY "Broj:"   get _BrDok
   endif

   if fk1=="D"; @  m_x+9,col()+2 SAY "K1" GET _k1 pict "@!" ; endif
   if fk2=="D"; @  m_x+9,col()+2 SAY "K2" GET _k2 pict "@!" ; endif
   if fk3=="D"; @  m_x+9,col()+2 SAY "K3" GET _k3 pict "@!" ; endif
   if fk4=="D"; @  m_x+9,col()+2 SAY "K4" GET _k4 pict "@!" ; endif

   @  m_x+11,m_y+2  SAY "Datum dok.:"   get  _DatDok valid {|| _datkurs:=_DatDok,.t.}
   if gNW=="N"
    @  m_x+11,m_y+24 SAY "Datum kursa:" GET _DatKurs ;
       VALID {|| nKurs:=Kurs(_DatKurs),qqout(" "+ValDomaca()+"/"+ValPomocna(),transform(nKurs,PicUn)),.t.}
   endif

   if gkonto<>"D"
    @  m_x+13,m_y+2  SAY IF(gSeks=="D","Predmet ","Konto   ") get _IdKonto ;
      valid {|| nKurs:=Kurs(_DatKurs), P_Konto(@_IdKonto),setpos(m_x+13,m_y+25),qqout(left(konto->naz,45)),.t.}
   endif

   @  m_x+14,m_y+2  SAY "Artikal " get _IdRoba pict "@!" ;
          valid  V_Roba(fnovi)

   @  m_x+16,m_y+2  SAY "Ulaz/Izlaz (1/2):" get _U_I Valid  V_UI()

   @ m_x+16,m_y+32 GET _Kolicina PICTURE PicKol valid V_Kol(fnovi)

   IF gNW!="R"
     @ m_x+16,m_y+50 SAY "CIJENA   :" GET _Cijena PICTURE PicUn+"9" ;
         when {|| IF(_cijena<>0,.t.,Cijena())} ;
         valid {|| _Iznos:=iif(_Cijena<>0,round(_Cijena*_Kolicina,2),_Iznos), .t.}
     @ m_x+17,m_y+50 SAY "IZNOS "+ValPomocna()+":" GET _Iznos PICTURE PicUn ;
         when {|| iif(gkonto=="D",.f.,.t.)}  valid  {|| _Iznos2:=_Iznos/nKurs, .t.}
     @ m_x+18,m_y+50 SAY "IZNOS "+ValDomaca()+":" GET _Iznos2 PICTURE PicUn ;
         when {|| _iznos2:=iif(gkonto=="D",_iznos,_iznos2),.t.}
   
   ENDIF
   
   READ
   
   ESC_RETURN 0

   OsvCijSif()

   _Rbr:=STR(nRbr,4)

return 1



function Cijena()
local nArr:=SELECT(),cPom1:=" ",cPom2:=" "

// da vidimo osobine unesenog konta, ako postoje
SELECT KARKON
SEEK _idkonto
if found()
  cPom1:=tip_nc
  cPom2:=tip_pc
endif
SELECT (nArr)
// ako se radi o ulazu
if _u_i=="1"
  // ako nije po kontu definisan tip cijene, gledamo u parametre
  if cPom1==" "
    if gCijena=="1"
      _Cijena:=roba->nc
    elseif gCijena=="2"
      _Cijena:=roba->vpc
    elseif gCijena=="3"
      _cijena:=roba->mpc
    elseif gCijena=="P"
      _cijena:=SredCij()
    endif
  else // u suprotnom gledamo u karakteristiku konta "tip_nc" <=> cPom1
    if cPom1=="1"
      _Cijena:=roba->nc
    elseif cPom1=="2"
      _Cijena:=roba->vpc
    elseif cPom1=="3"
      _cijena:=roba->mpc
    elseif cPom1=="P"
      _cijena:=SredCij()
    endif
  endif
else   // tj. ako se radi o izlazu
  // ako nije po kontu definisan tip cijene, gledamo u parametre
  if cPom2==" "
    if gCijena=="1"
      _Cijena:=roba->nc
    elseif gCijena=="2"
      _Cijena:=roba->vpc
    elseif gCijena=="3"
      _cijena:=roba->mpc
    elseif gCijena=="P"
      _cijena:=SredCij()
    endif
  else // u suprotnom gledamo u karakteristiku konta "tip_pc" <=> cPom2
    if cPom2=="1"
      _Cijena:=roba->nc
    elseif cPom2=="2"
      _Cijena:=roba->vpc
    elseif cPom2=="3"
      _cijena:=roba->mpc
    elseif cPom2=="P"
      _cijena:=SredCij()
    endif
  endif
endif

return .t.


function SredCij()
 LOCAL nArr:=SELECT(),nFin:=0,nMat:=0
 SELECT mat_suban
 #ifndef C50
 SET ORDER TO TAG "3"
 #else
 SET ORDER TO 3
 #endif
  SEEK _idfirma+_idkonto+_idroba
  DO WHILE !EOF().and.(_idfirma+_idkonto+_idroba==idfirma+idkonto+idroba).and.dtos(datdok)<=dtos(_datdok)
    IF u_i=="1"  // ulaz
      nFin+=iznos
      nMat+=kolicina
    ELSE  // izlaz
      nFin-=iznos
      nMat-=kolicina
    ENDIF
    SKIP 1
  ENDDO
 SELECT(nArr)
RETURN (nFin/nMat)



function V_Roba(fnovi)

P_Roba(@_IdRoba,14,25)
if fnovi .and. _idvn $ gNalPr  // predlozi izlaz iz prod
      _u_i:="2"
endif
if gKonto=="D"
  _Idkonto:=roba->idkonto
  nKurs:=Kurs(_DatKurs)
   @  m_x+13,m_y+2  SAY "Konto:   "; ?? _IdKonto
endif
@  m_x+15,m_y+25  SAY "Jed.mjere:"
@  m_x+15,m_y+36  SAY ROBA->jmj COLOR INVERT
return .t.


function V_UI()

if !(_U_I $ "12");  return .f.; endif

_D_P:=_U_I

if _U_I=="1"
      @ m_x+16,m_y+25 SAY "ULAZ   "
else
      @ m_x+16,m_y+25 SAY "IZLAZ  "
endif
return .t.



function V_Kol(fnovi)
if fNovi; _Cijena:=0; endif
if fnovi .and. _idvn $ gNalPr .and. _u_i=="2"
      _cijena:=roba->mpc
endif
return .t.


function EdPRIPR()
local nTr2

if (Ch==K_CTRL_T .or. Ch==K_ENTER)  .and. empty(BrNal)
  return DE_CONT
endif

select mat_pripr
do case
  case Ch==K_CTRL_T
     if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
      delete
      mat_brisi_pbaze()
      return DE_REFRESH
     endif
     return DE_CONT

   case Ch==K_F5 // kontrola zbira za jedan mat_nalog
      PushWa()
      Box("kzb",8,60,.f.,"Kontrola zbira mat_naloga")
      set cursor on
      cFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

      @ m_x+1,m_y+1 SAY "       Firma:" GET cFirma
      //VALID P_Firma(@cFirma,1,20) .and. len(trim(cFirma))<=2
      @ m_x+2,m_y+1 SAY "Vrsta mat_naloga:" GET cIdVn valid P_VN(@cIdVN,2,20)
      @ m_x+3,m_y+1 SAY " Broj mat_naloga:" GET cBrNal
      READ; if lastkey()==K_ESC; BoxC(); PopWA(); return DE_CONT; endif
      cFirma:=left(cFirma,2)
      #ifndef C50
      set order to tag "2"
      #else
      set order to 2
      #endif
      seek cFirma+cIdVn+cBrNal
      dug:=Pot:=0
      if !(IdFirma+IdVn+BrNal==cFirma+cIdVn+cBrNal)
        Msg("Ovaj mat_nalog nije unesen ...",10)
        BoxC()
        PopWa()
        return DE_CONT
      endif
      do while !eof() .and. (IdFirma+IdVn+BrNal==cFirma+cIdVn+cBrNal)
        if D_P=="1"; dug+=Iznos; else; pot+=Iznos; endif
        skip
      enddo
      @ m_x+5,m_y+2 SAY "Zbir mat_naloga:"
      @ m_x+6,m_y+2 SAY "     Duguje:"
      @ m_x+6,COL()+2 SAY Dug PICTURE gPicDEM()
      @ m_x+7,m_y+2 SAY "  Potrazuje:"
      @ m_x+7,COL()+2 SAY Pot  PICTURE gPicDEM()
      @ m_x+8,m_y+2 SAY "      Saldo:"
      @ m_x+8,COL()+2 SAY Dug-Pot  PICTURE gPicDEM()
      Inkey(0)
     BoxC()
     PopWA()
     return DE_CONT

   case Ch==K_ENTER
    Box("ist",20,75,.f.)
    Scatter()
    nRbr:=VAL(_Rbr)
    if EditPRIPR(.f.)==0
     BoxC()
     return DE_CONT
    else
     Gather()
     mat_brisi_pbaze()
     BoxC()
     return DE_REFRESH
    endif

   case Ch==K_CTRL_A
        PushWA()
        select mat_pripr
        go top
        Box("anal",20,75,.f.,"Ispravka mat_naloga")
        nDug:=0; nPot:=0
        do while !eof()
           skip; nTR2:=RECNO(); skip-1
           Scatter()
           nRbr:=VAL(_Rbr)
           @ m_x+1,m_y+1 CLEAR to m_x+18,m_y+74
           if EditPRIPR(.f.)==0
             exit
           else
             mat_brisi_pbaze()
           endif
           if D_P='1'; nDug+=_Iznos; else; nPot+=_Iznos; endif
           @ m_x+20,m_y+1 SAY "ZBIR mat_nalogA:"
           @ m_x+20,m_y+14 SAY nDug PICTURE PicDEM
           @ m_x+20,m_y+35 SAY nPot PICTURE PicDEM
           @ m_x+20,m_y+56 SAY nDug-nPot PICTURE PicDEM

           select mat_pripr
           Gather()
           go nTR2
         enddo
         PopWA()
         BoxC()
         return DE_REFRESH

     case Ch==K_CTRL_N  // nove stavke
        nDug:=nPot:=nPrvi:=0

        do while .not. eof() // kompletan mat_nalog sumiram
           if D_P='1'; nDug+=Iznos; else; nPot+=Iznos; endif
           skip
        enddo
        go bottom
        Box("knjn",20,77,.f.,"Knjizenje mat_naloga - nove stavke")
        do while .t.
           Scatter()
           nRbr:=VAL(_Rbr)+1
           @ m_x+1,m_y+1 CLEAR to m_x+18,m_y+78
           if EditPRIPR(.t.)==0
             exit
           else
             mat_brisi_pbaze()
           endif
           if D_P='1'; nDug+=_Iznos; else; nPot+=_Iznos; endif
           @ m_x+20,m_y+1 SAY "ZBIR mat_nalogA:"
           @ m_x+20,m_y+14 SAY nDug PICTURE PicDEM
           @ m_x+20,m_y+35 SAY nPot PICTURE PicDEM
           @ m_x+20,m_y+56 SAY nDug-nPot PICTURE PicDEM

           select mat_pripr
           APPEND BLANK
           Gather()
        enddo

        BoxC()
        return DE_REFRESH

   case Ch=K_CTRL_F9
        if Pitanje(,"Zelite li izbrisati mat_pripremu !!????","N")=="D"
             zap
             mat_brisi_pbaze()
        endif
        return DE_REFRESH

   case Ch==K_CTRL_P
     close all
     mat_st_nalog()
     O_Edit()
     return DE_REFRESH

   case Ch==K_ALT_A
     close all
     Azur()
     O_Edit()
     return DE_REFRESH
endcase



function dupli(cBrNal,cVN,cIdFirma)
PushWa()
select mat_nalog
seek cIdFirma+cVN+cBrNal
if found()
   MsgO(" Dupli mat_nalog ! ")
   Beep(3)
   MsgC()
   PopWa()
   return .f.
endif
PopWa()
return .t.



function Azur()

if Pitanje(,"Sigurno zelite izvrsiti azuriranje (D/N)?","N")=="N"
   return
endif

O_PARTN
O_MAT_PRIPR
O_MAT_SUBAN
O_mat_psuban
O_MAT_ANAL
O_mat_panal
O_MAT_SINT
O_mat_psint
O_MAT_NALOG
O_mat_pnalog
O_ROBA

fAzur:=.t.
select mat_psuban; if reccount2()==0; fAzur:=.f.; endif
select mat_panal; if reccount2()==0; fAzur:=.f.; endif
select mat_psint; if reccount2()==0; fAzur:=.f.; endif
if !fAzur
  Beep(3)
  Msg("Niste izvrsili stampanje mat_naloga ...",10)
  return
endif

// kontrola ispravnosti sifara artikala

select mat_psuban
GO TOP
DO WHILE !EOF()
  select ROBA; hseek mat_psuban->idroba
  if !found()
    Beep(1)
    Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra artikla!")
    select mat_psuban; zapp()
    select mat_panal; zapp()
    select mat_psint; zapp()
    closeret
  endif
  select PARTN; hseek mat_psuban->idpartner
  if !found().and.!EMPTY(mat_psuban->idpartner)
    Beep(1)
    Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra partnera!")
    select mat_psuban; zapp()
    select mat_panal; zapp()
    select mat_psint; zapp()
    closeret
  endif
  select mat_psuban
  SKIP 1
ENDDO
go top

if !( mat_suban->(flock()) .and. mat_anal->(flock()) .and. mat_sint->(flock()) .and. mat_nalog->(flock()) )
  Beep(1)
  Msg("Neko vec koristi datoteke !",6)
  closeret
endif

Box(,7,30,.f.)
select mat_anal
APPEND FROM mat_panal
@ m_x+1,m_y+2 SAY "ANALITIKA"
select mat_panal; zapp()

select mat_sint
APPEND FROM mat_psint
@ m_x+3,m_y+2 SAY "SINTETIKA  "
select mat_psint; zapp()

select mat_nalog
APPEND FROM mat_pnalog
@ m_x+5,m_y+2 SAY "NALOZI     "
select mat_pnalog; zapp()

select mat_suban
APPEND FROM mat_psuban

select mat_psuban; go top
DO WHILE !EOF()

   nUlazK:=nIzlK:=nDug:=nPot:=0
   IF U_I="1"
     nUlazK:=Kolicina
   ELSE
     nIzlK:=Kolicina
   ENDIF
   IF D_P="1"
      nDug:=Iznos
   ELSE
      nPot:=Iznos
   ENDIF

   select mat_pripr
   seek mat_psuban->(idfirma+idvn+brnal)
   if found(); dbdelete2(); endif

   select mat_psuban
   SKIP
ENDDO

select mat_psuban;zapp()

select mat_pripr; __dbpack()
@ m_x+7,m_y+2 SAY "SUBANALITIKA "

Inkey(2)

BoxC()
closeret

function mat_st_nalog()
local Izb

PRIVATE PicDEM:="@Z 9999999.99"
PRIVATE PicBHD:="@Z 999999999.99"
PRIVATE PicKol:="@Z 999999.999"

mat_st_anal_nalog()
//StSintNal()
MsgO("Formiranje mat_analitickih i mat_sintetickih stavki...")
SintStav()
MsgC()
if (gKonto=="D" .and. Pitanje(,"Stampa mat_analitike","D")=="D")  .or. ;
   (gKonto=="N" .and. Pitanje(,"Stampa mat_analitike","N")=="D")
 mat_st_sint_nalog(.t.)
endif
return

function mat_st_anal_nalog(fnovi)
local i

if pcount()==0
  fnovi:=.t.
endif

O_TNAL
O_ROBA

if fnovi
 O_MAT_PRIPR
 O_mat_psuban
 select mat_psuban; zapp()
 SELECT mat_pripr
 #ifndef C50
 set order to tag "2"
 #else
 set order to 2
 #endif
 go top
 if empty(BrNal); Msg("PRIPR je prazna!",15); return; endif
else
 O_MAT_SUBAN2
endif


if gkonto=="N"  .and. g2Valute=="D"
 M:="---- ------- ---------- ------------------ --- -------- ------- ---------- ----------"+IF(gNW=="R",""," ---------- ---------- ------------ ------------")
else
 M:="---- ------- ------ ---------- ---------------------------------------- -- --------"+IF(gNW=="R",""," ----------")+" ---------- ----------"+IF(gNW=="R",""," ------------ ------------")
endif
DO WHILE !EOF()
   cIdFirma:=IdFirma; cIdVN:=IdVN; cBrNal:=BrNal

   Box("",1,50)
     set cursor on
     set confirm off
     @ m_x+1,m_y+2 SAY "Nalog broj:" GET cIdFirma
     @ m_x+1,col()+1 SAY "-" GET cIdVn
     @ m_x+1,col()+1 SAY "-" GET cBrNal
     read; ESC_BCR
     set confirm on
   BoxC()

   HSEEK cIdFirma+cIdVN+cBrNal             // HSEEK
   IF EOF(); CLOSERET; ENDIF
//   SEEK cIdFirma+cIdVN+cBrNal
//   NFOUND CRET

   *----------- mat_nalog -------------------*
   START PRINT CRET
   nStr:=0
   nUkDug:=nUkPot:=0
   nUkDug2:=nUkPot2:=0
   b2:={|| cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal}
   Zagl11()
   DO WHILE !eof() .and. eval(b2)   // mat_nalog
      nDug:=nPot:=0
      nDug2:=nPot2:=0
      cBrDok:=BrDok
      DO WHILE !eof() .and.eval(b2) .and. BrDok==cBrDok  // brdok
         IF prow()>58; FF; Zagl11(); ENDIF
         @ prow()+1,0 SAY Rbr
         @ prow(),pcol()+1 SAY IdKonto
         if gkonto=="D" .or. g2Valute=="N"
          @ prow(),pcol()+1 SAY IdPartner
         endif
         nCP:=pcol()+1
         @ prow(),pcol()+1 SAY IdRoba
         nCR:=pcol()+1
         select ROBA; hseek mat_pripr->idroba
         if gkonto=="D" .or. g2Valute=="N"
          aRez:=SjeciStr(naz,40)
         else
          aRez:=SjeciStr(naz,18)
         endif
         select mat_pripr
         @ prow(),pcol()+1 SAY aRez[1]
         nCK14:=pcol()+1
         @ prow(),nCk14    SAY IdTipDok
         if gkonto=="N" .and. g2Valute=="D"
          @ prow(),pcol()+1 SAY BrDok
         endif
         @ prow(),pcol()+1 SAY DatDok
         if (gkonto=="D" .or. g2Valute=="N") .and. gNW!="R"
           if round(kolicina,4)<>0
            @ prow(),pcol()+1 SAY iznos/kolicina picture RIGHT(gpicdem+"9",LEN(gPicDem))
           else
            @ prow(),pcol()+1  SAY 0 picture RIGHT(gpicdem+"9",LEN(gPicDem))
           endif
         endif
         nCK:=pcol()+1
         if U_I=="1"
           @ prow(),pcol()+1 SAY Kolicina PICTURE "@Z "+gPicKol
           @ prow(),pcol()+1 SAY 0        PICTURE "@Z "+gPicKol
         else
           @ prow(),pcol()+1 SAY 0        PICTURE "@Z "+gPicKol
           @ prow(),pcol()+1 SAY Kolicina PICTURE "@Z "+gPicKol
         endif

         nCI:=pcol()+1
         IF gNW!="R"
           IF D_P="1"
              @ prow(),pcol()+1 SAY Iznos PICTURE "@Z "+gPicDEM()
              @ prow(),pcol()+1 SAY 0 PICTURE "@Z "+gPicDEM()
              nDug+=Iznos
           ELSE
              @ prow(),pcol()+1 SAY 0 PICTURE "@Z "+gPicDEM()
              @ prow(),pcol()+1 SAY Iznos PICTURE "@Z "+gPicDEM()
              nPot+=Iznos
           ENDIF
         ENDIF

         if gkonto=="N" .and. g2Valute=="D" .and. gNW!="R"
           IF D_P="1"
              @ prow(),pcol()+1 SAY Iznos2  PICTURE "@Z "+gPicDIN
              @ prow(),pcol()+1 SAY 0  PICTURE "@Z "+gPicDIN
              nDug2+=Iznos2
           ELSE
              @ prow(),pcol()+1 SAY 0     PICTURE "@Z "+gPicDIN
              @ prow(),pcol()+1 SAY Iznos2 PICTURE "@Z "+gPicDIN
              nPot2+=Iznos2
           ENDIF
         endif

        if gkonto=="N" .and.  g2Valute=="D"
          for i:=2 to len(aRez)
            @ prow()+1,nCR say aRez[i]
          next
          @ prow()+1,nCP SAY IdPartner
          @ prow(),nCR SAY IdZaduz
          @ prow(),nCK14 SAY k1+"-"+k2+"-"+k3+"-"+k4
          if Kolicina<>0 .AND. gNW!="R"
            @ prow(),nCK SAY "Cijena:"
            @ prow(),pcol()+1 SAY  Iznos/Kolicina picture "*****.***"
            @ prow(),pcol()+1 SAY ValPomocna()
          endif
        endif

        if fnovi
         select mat_pripr; Scatter()

         SELECT mat_psuban
         APPEND BLANK
         Gather()  // stavi sve vrijednosti iz mat_pripr u mat_psuban
         select mat_pripr
        endif // fnovi

        SKIP
      ENDDO // brdok

      IF prow()>59; FF; Zagl11();  endif
      ? M
      IF gNW!="R"
        ? "UKUPNO ZA DOKUMENT:"
        @ prow(),pcol()+1 SAY cBrDok
        @ prow(),nCI-1 SAY ""
        @ prow(),pcol()+1 SAY nDug PICTURE "@Z "+gPicDEM()
        @ prow(),pcol()+1 SAY nPot PICTURE "@Z "+gPicDEM()

        if gkonto=="N" .and. g2Valute=="D"
         @ prow(),pcol()+1 SAY nDug2 PICTURE "@Z "+gPicDIN
         @ prow(),pcol()+1 SAY nPot2 PICTURE "@Z "+gPicDIN
        endif
        ? M
      ENDIF

      nUkDug+=nDug; nUkPot+=nPot
      nUkDug2+=nDug2; nUkPot2+=nPot2
      //?
   ENDDO // mat_nalog

   IF prow()>59; FF; Zagl11();  endif
   IF gNW!="R"
     ? M
     ? "ZBIR mat_nalogA:"
     @ prow(),nCI-1 SAY ""
     @ prow(),pcol()+1 SAY nUkDug PICTURE "@Z "+gPicDEM()
     @ prow(),pcol()+1 SAY nUkPot PICTURE "@Z "+gPicDEM()
     if gkonto=="N" .and. g2Valute=="D"
      @ prow(),pcol()+1 SAY nUkDug2 PICTURE "@Z "+gPicDIN
      @ prow(),pcol()+1 SAY nUkPot2 PICTURE "@Z "+gPicDIN
     endif
     ? M
   ENDIF
   cIdFirma:=IdFirma
   cIdVN:=IdVN
   cBrNal:=BrNal


     if gPotpis=="D"
      IF prow()>58; FF; Zagl11();  endif
      ?
      ?; P_12CPI
      @ prow()+1,55 SAY "Obrada AOP "; ?? replicate("_",20)
      @ prow()+1,55 SAY "Kontirao   "; ?? replicate("_",20)
    endif

   FF
   END PRINT

ENDDO  // eof()

closeret



static function Zagl11()
local nArr
P_10CPI
?? gnFirma
if gkonto=="N"
 P_COND
else
 P_COND2
endif
?
? "MAT.P: mat_nalog ZA KNJIZENJE BROJ :"
@ prow(),PCOL()+2 SAY cIdFirma+" - "+cIdVn+" - "+cBrNal
nArr:=select()
select TNAL; HSEEK cIdVN; @ prow(),pcol()+4 SAY naz
select(nArr)
@ prow(),120 SAY "Str "+str(++nStr,3)
? M
if gkonto=="N" .and. g2Valute=="D"
 ? "*R. *"+KonSeks("KONTO  ")+"*  ROBA    *  NAZIV ROBE      *  D O K U M E N T   *      KOLICINA       *"+IF(gNW=="R","","  I Z N O S   "+ValPomocna()+"   *   I Z N O S   "+ValDomaca()+"     *")
 ? "             ----------  ---------------  --------------------- --------------------- "+IF(gNW=="R","","--------------------- -------------------------")
 ? "*BR.*       * PARTNER  *  ZADUZUJE        *TIP* BROJ  * DATUM  *  ULAZ    *  IZLAZ   *"+IF(gNW=="R","","   DUG    *   POT    *    DUG     *    POT    *")
else
  ? "*R. *"+KonSeks("KONTO  ")+"*Partn.*  SIFRA   *            NAZIV                       * DOKUMENT   *"+IF(gNW=="R","","  Cijena *")+"      KOLICINA       *"+IF(gNW=="R","","   I Z N O S   "+ValPomocna()+"     *")
  ? "            *      *                                                   --------------"+IF(gNW=="R","","         *")+"--------------------- "+IF(gNW=="R","","-------------------------")
  ? "*BR.*       *      *          *                                        *TIP* DATUM  *"+IF(gNW=="R","","         *")+"  ULAZ    *  IZLAZ   *"+IF(gNW=="R","","    DUG     *    POT    *")
endif
? M



return


function mat_sintStav()

O_mat_psuban
O_mat_panal
O_mat_psint
O_mat_pnalog

select mat_panal; zap
select mat_psint; zap
select mat_pnalog; zap

select mat_psuban
#ifndef C50
set order to tag "2"
#else
set order to 2
#endif
go top
if empty(BrNal); closeret; endif

DO WHILE !eof()   // svi nalozi

   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal


   nDug11:=nPot11:=nDug22:=nPot22:=0

   DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal    // jedan mat_nalog

      cIdKonto:=IdKonto
      nDug1:=0;nPot1:=0
      nDug2:=0;nPot2:=0

      IF D_P=="1" ; nDug1:=Iznos; ELSE; nPot1:=Iznos; ENDIF
      IF D_P=="1"; nDug2:=Iznos2; ELSE; nPot2:=Iznos2; ENDIF

      SELECT mat_panal     // mat_analitika
      seek cidfirma+cidvn+cbrnal+cidkonto
      fNasao:=.f.
      DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
             .and. IdKonto==cIdKonto
        if month(mat_psuban->datdok)==month(datnal)
          fNasao:=.t.
          exit
        endif
        skip
      enddo
      if !fNasao
        append blank
      endif

      REPLACE IdFirma WITH cIdFirma,IdKonto WITH cIdKonto,IdVN WITH cIdVN,;
              BrNal with cBrNal,;
              DatNal WITH max(mat_psuban->datdok,datnal),;
              Dug    WITH Dug+nDug1, Pot WITH Pot+nPot1,;
              Dug2 WITH   Dug2+nDug2, Pot2 WITH Pot2+nPot2
      SELECT mat_psint
      seek cidfirma+cidvn+cbrnal+left(cidkonto,3)
      fNasao:=.f.
      DO WHILE !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal ;
                .and. left(cidkonto,3)==idkonto
        if  month(mat_psuban->datdok)==month(datnal)
          fNasao:=.t.
          exit
        endif
        skip
      enddo  // konto
      if !fNasao
          append blank
      endif

      REPLACE IdFirma WITH cIdFirma,IdKonto WITH left(cIdKonto,3),IdVN WITH cIdVN,;
           BrNal WITH cBrNal,;
           DatNal WITH max(DatNal,mat_psuban->datdok),;
           Dug  WITH   Dug+nDug1,  Pot   WITH Pot+nPot1,;
           Dug2 WITH   Dug2+nDug2, Pot2  WITH Pot2+nPot2


      SELECT mat_psuban
      nDug11+=nDug1; nPot11+=nPot1
      nDug22+=nDug2; nPot22+=nPot2
      skip

   ENDDO  // mat_nalog

   SELECT mat_pnalog    // datoteka mat_naloga
   APPEND BLANK
   REPLACE IdFirma WITH cIdFirma,IdVN WITH cIdVN,BrNal WITH cBrNal,;
           DatNal WITH date(),;
           Dug WITH nDug11, Pot WITH nPot11,;
           Dug2 WITH nDug22,Pot2 WITH nPot22
   SELECT mat_psuban


enddo // eof


select mat_panal
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan mat_nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

select mat_psint
go top
do while !eof()
   nRbr:=0
   cIdFirma:=IdFirma;cIDVn=IdVN;cBrNal:=BrNal
   do while !eof() .and. cIdFirma==IdFirma .AND. cIdVN==IdVN .AND. cBrNal==BrNal     // jedan mat_nalog
     replace rbr with str(++nRbr,3)
     skip
   enddo
enddo

closeret


FUNCTION mat_brisi_pbaze()
  PushWA()
  SELECT (F_mat_psuban); ZAP
  SELECT (F_mat_panal); ZAP
  SELECT (F_mat_psint); ZAP
  SELECT (F_mat_pnalog); ZAP
  PopWA()
RETURN (NIL)




PROCEDURE OsvCijSif()
local nArr:=SELECT(),cPom1:=" ",cPom2:=" "

SELECT ROBA
SEEK _idroba
IF !FOUND()
  SELECT (nArr)
  MsgBeep("Nema sifre artikla!")
  RETURN
ENDIF

// da vidimo osobine unesenog konta, ako postoje
SELECT KARKON
SEEK _idkonto
if found()
  cPom1:=tip_nc
  cPom2:=tip_pc
endif
SELECT ROBA
Scatter("q")
// ako se radi o ulazu
if _u_i=="1"
  // ako nije po kontu definisan tip cijene, gledamo u parametre
  if cPom1==" "
    if gCijena=="1"
      IF qnc<>_cijena .and. Pitanje("","Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qnc  := _Cijena
      ENDIF
    elseif gCijena=="2"
      IF qvpc<>_cijena .and. Pitanje("","Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qvpc  := _Cijena
      ENDIF
    elseif gCijena=="3"
      IF qmpc<>_cijena .and. Pitanje("","Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qmpc  := _Cijena
      ENDIF
    elseif gCijena=="P"
    endif
  else // u suprotnom gledamo u karakteristiku konta "tip_nc" <=> cPom1
    if cPom1=="1"
      IF qnc<>_cijena .and. Pitanje("","Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qnc  := _Cijena
      ENDIF
    elseif cPom1=="2"
      IF qvpc<>_cijena .and. Pitanje("","Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qvpc  := _Cijena
      ENDIF
    elseif cPom1=="3"
      IF qmpc<>_cijena .and. Pitanje("","Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qmpc  := _Cijena
      ENDIF
    elseif cPom1=="P"
    endif
  endif
else   // tj. ako se radi o izlazu
  // ako nije po kontu definisan tip cijene, gledamo u parametre
  if cPom2==" "
    if gCijena=="1"
      IF qnc<>_cijena .and. Pitanje("","Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qnc  := _Cijena
      ENDIF
    elseif gCijena=="2"
      IF qvpc<>_cijena .and. Pitanje("","Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qvpc  := _Cijena
      ENDIF
    elseif gCijena=="3"
      IF qmpc<>_cijena .and. Pitanje("","Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qmpc  := _Cijena
      ENDIF
    elseif gCijena=="P"
    endif
  else // u suprotnom gledamo u karakteristiku konta "tip_pc" <=> cPom2
    if cPom2=="1"
      IF qnc<>_cijena .and. Pitanje("","Zelite li ovu nabavnu cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qnc  := _Cijena
      ENDIF
    elseif cPom2=="2"
      IF qvpc<>_cijena .and. Pitanje("","Zelite li ovu (VP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qvpc  := _Cijena
      ENDIF
    elseif cPom2=="3"
      IF qmpc<>_cijena .and. Pitanje("","Zelite li ovu (MP) cijenu postaviti kao tekucu ? (D/N)","D")=="D"
        qmpc  := _Cijena
      ENDIF
    elseif cPom2=="P"
    endif
  endif
endif
Gather("q")
SELECT (nArr)
RETURN


