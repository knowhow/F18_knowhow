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


function ODbKalk()

O_SIFK
O_SIFV
O_TARIFA
O_ROBA
O_KONCIJ
O_KONTO
O_PARTN
O_KALK_DOKS
O_KALK
return


function Gen9999()
  if !(gRadnoPodr=="9999")  
    // sezonsko kumulativno podrucje za zbirne izvjeçtaje
    MsgBeep("Ova operacija se radi u 9999 podrucju")
    return
  endif
  
  nG0:=nG1:=YEAR(DATE())
  Box("#Generacija zbirne baze dokumenata",5,75)
   @ m_x+2, m_y+2 SAY "Od sezone:" GET nG0 VALID nG0>0.and.nG1>=nG0 PICT "9999"
   @ m_x+3, m_y+2 SAY "do sezone:" GET nG1 VALID nG1>0.and.nG1>=nG0 PICT "9999"
   READ; ESC_BCR
  BoxC()

  // spaja se sve izuzev dokumenata 16 i 80 na dan 01.01.XX gdje XX oznacava
  // sve sezone izuzev pocetne
  // -----------------------------------------------------------------------

close all
return




/*! \fn KalkNaF(cidroba,nKols)
 *  \brief Stanje zadanog artikla u FAKT
 */

function KalkNaF(cidroba,nKols)
*{
select (F_FAKT)
if !used(); O_FAKT; endif

select fakt; set order to tag "3" // idroba
nKols:=0
seek cidroba
do while !eof() .and. cidroba==idroba
     if idtipdok="0"  // ulaz
        nKols+=kolicina
     elseif idtipdok="1"   // izlaz faktura
       if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremince ne ra~unaj izlaz
          nKols-=kolicina
       endif
     endif
     skip
enddo
select kalk_pripr
return
*}


// ako nije razduzeno kako bi trebalo po metodi NC

/*! \fn MsgNCRazd()
 *  \brief
 *  \todo ukinuti?
 */

function MsgNCRazd()
*{
//ne moze raditi
//if round(nab-> kalk->kolicina) .and. round(nab->nc-kalk->nc,3)<>0;  Msg("U dokumentu "+kalk->(idfirma+"-"+idvd+"-"+brdok)+" nije dobra NC po metodi razduzenja !"); endif
return
*}


/*! \fn P_Kalk(cIdFirma,cIdVD,cBrDok)
 *  \brief Ispituje postojanje zadanog dokumenta medju azuriranim
 */

function P_Kalk(cIdFirma,cIdVD,cBrDok)
*{
local nRez:=.f.
local nArr:=SELECT()
//PushWa()
SELECT KALK
set filter to
set order to tag "1"
seek cIdFirma+cIdVD+cBrDok
if found()
  Beep(1)
  Msg("Dokument vec postoji !")
  nRez:=.t.
else
endif
//PopWa()
SELECT (nArr)
return nRez
*}


/*! \fn VVT()
 *  \brief Prikaz PPP i proracun marze za visokotarifnu robu
 */

function VVT()
*{
@ m_x+13,m_y+2 SAY "PPP:"
@ m_x+13,col()+2 SAY tarifa->opp pict "99.99%"
if roba->tip="X"
 @ m_x+13,col()+2 SAY roba->mpc/(1+tarifa->opp/100)*tarifa->opp/100 pict picdem
 _marza:=roba->mpc/(1+tarifa->opp/100)-_nc
else
 @ m_x+13,col()+2 SAY _vpc/(1+tarifa->opp/100)*tarifa->opp/100 pict picdem
 _marza:=_vpc/(1+tarifa->opp/100)-_nc
endif
_tmarza:="A"
return .t.
*}




/*! \fn DuplRoba()
 *  \brief Obrada slucaja pojavljivanja duplog unosa robe u dokumentu
 */

function DuplRoba()
*{
local nRREC,fdupli:=.f.,dkolicina:=0,dfcj:=0
private GetList:={}
 // pojava robe vise puta unutar kalkulacije!!!
 if ( (roba->tip $ "UTY") .or. empty(gMetodaNC) .or. gmagacin=="1" .or. (IsJerry() .and. _idvd="4") )
    return .t.
 endif
 select kalk_pripr; set order to tag "3"
 nRRec:=recno()
 seek _idfirma+_idvd+_brdok+_idroba
 fdupli:=.f.
 dkolicina:=_kolicina
 dfcj:=_fcj
 do while !eof() .and. _idfirma+_idvd+_brdok+_idroba== idfirma+idvd+brdok+idroba
   if val(rbr)<>nRbr .and. (nRRec<>recno() .or. fnovi)
     Beep(2)
     // skocio je na donji zapis
     if Pitanje(,"Artikal "+_idroba+" se pojavio vise puta unutar - spojiti ?","N")=="D"
        fdupli:=.t.
        dfcj:=(dfcj*dkolicina+fcj*kolicina)/(dkolicina+kolicina)
        dkolicina+=kolicina
        delete
     else
        _ERROR:="1"
     endif
   endif
   skip
 enddo
 go nRRec
 if fdupli
   _kolicina:=dkolicina
   _fcj:=dfcj
 endif
 select kalk_pripr
 set order to tag "1"
return .t.
*}



/*! \fn DatPosljK()
 *  \brief Ispituje da li je datum zadnje promjene na zadanom magacinu i za zadani artikal noviji od one koja se unosi
 */

function DatPosljK()
*{
select kalk
set order to tag "3"
seek _idfirma+_mkonto+_idroba+chr(254)
skip -1
if _idfirma+_idkonto+_idroba==idfirma+mkonto+idroba .and. _datdok<datdok
   Beep(2)
   Msg("Zadnji dokument za ovaj artikal radjen je: "+dtoc(datdok))
   _ERROR:="1"
endif
select kalk_pripr
return
*}


/*! \fn DatPosljP()
 *  \brief Ispituje da li je datum zadnje promjene na zadanoj prodavnici i za zadani artikal noviji od one koja se unosi
 */

function DatPosljP()
*{
select kalk
set order to tag "4"

if _idroba="T"
 go bottom
 if _datdok<datdok
   Msg("Zadji dokument je radjen: "+dtoc(datdok))
   _ERROR:="1"
 endif
else
 seek _idfirma+_idkonto+_idroba+chr(254)
 skip -1
 if _idfirma+_idkonto+_idroba==idfirma+pkonto+idroba .and. _datdok<datdok
   Beep(2)
   Msg("Zadnji dokument za ovaj artikal radjen je: "+dtoc(datdok))
   _ERROR:="1"
 endif
endif
select kalk_pripr
return
*}



/*! \fn SljBroj(cidfirma,cIdvD,nMjesta)
 *  \brief Sljedeci slobodan broj dokumenta za zadanu firmu i vrstu dokumenta
 */

function SljBroj(cidfirma,cIdvD,nMjesta)
private cReturn:="0"
select kalk
seek cidfirma+cidvd+"ä"
skip -1
if idvd<>cidvd
     cReturn:=space(8)
else
     cReturn:=brdok
endif

if ALLTRIM(cReturn) >= "99999"
    cReturn := PADR( novasifra( ALLTRIM(cReturn) ), 5 )
else
    cReturn := UBrojDok( VAL( LEFT(cReturn, 5) ) + 1, ;
        5, RIGHT(cReturn) )
endif

return cReturn



// ------------------------------------------------
// ------------------------------------------------
function SljBrKalk(cTipKalk, cIdFirma, cSufiks)
*{
local cBrKalk:=space(8)
if cSufiks==nil
    cSufiks:=SPACE(3)
endif
if gBrojac=="D"
    if glBrojacPoKontima
        select kalk_doks
        set order to tag "1S"
        seek cIdFirma+cTipKalk+cSufiks+"X"
    else
        select kalk
        set order to tag "1"
        seek cIdFirma+cTipKalk+"X"
    endif
    skip -1
    
    if cTipKalk<>field->idVD .or. glBrojacPoKontima .and. right(field->brDok,3)<>cSufiks
        cBrKalk:=SPACE(gLenBrKalk)+cSufiks
    else
        cBrKalk:=field->brDok
    endif
    
    if cTipKalk=="16" .and. glEvidOtpis
        cBrKalk:=STRTRAN(cBrKalk,"-X","  ")
    endif
    
    if ALLTRIM( cBrKalk ) >= "99999"
        cBrKalk := PADR( novasifra( ALLTRIM(cBrKalk) ), 5 ) + ;
            right( cBrKalk, 3 )
    else
        cBrKalk:=UBrojDok(val(left(cBrKalk,5)) + 1, ;
            5, right(cBrKalk,3) )
    endif
endif
return cBrKalk




// --------------------------------------------------------
// uvecava broj kalkulacije sa stepenom uvecanja nUvecaj
// --------------------------------------------------------
function GetNextKalkDoc(cIdFirma, cIdTipDok, nUvecaj)
local xx
local i
local lIdiDalje

if nUvecaj == nil
    nUvecaj := 1
endif

lIdiDalje := .f.

O_KALK_DOKS
select kalk_doks
set order to tag "1"

seek cIdFirma + cIdTipDok + "XXX"
// vrati se na zadnji zapis
skip -1

do while .t.
    for i := 2 to LEN(ALLTRIM(field->brDok)) 
        if !IsNumeric(SubStr(ALLTRIM(field->brDok),i,1))
            lIdiDalje := .f.
            skip -1
            loop
        else
            lIdiDalje := .t.
        endif
    next

    if lIdiDalje := .t.
        cResult := field->brDok
        exit
    endif
    
enddo

xx := 1

for xx := 1 to nUvecaj
    cResult := PADR( novasifra( ALLTRIM(cResult) ), 5 ) + ;
        RIGHT( cResult, 3 )
next

return cResult



/*! \fn MMarza2()
 *  \brief Daje iznos maloprodajne marze
 */

function MMarza2()
*{
  if TMarza2=="%".or.EMPTY(tmarza2)
     nMarza2:=kolicina*Marza2/100*VPC
  elseif TMarza2=="A"
     nMarza2:=Marza2*kolicina
  elseif TMarza2=="U"
     nMarza2:=Marza2
  endif
return nMarza2
*}



/*! \fn KnjizSt()
 *  \brief Proracun knjiznog stanja za zadanu robu i prodavnicu 
 */

function KnjizSt()
*{
local nUlaz:=nIzlaz:=0
local nMPVU:=nMPVI:=nNVU:=nNVI:=0
local cIdRoba:=_Idroba
local cidfirma:=_idfirma
local cidkonto:=_idkonto
local nRabat:=0
select roba; hseek cidroba; select kalk
PushWa()
set order to tag "4"
hseek cidfirma+cidkonto+cidroba
do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

  if _Datdok<datdok  // preskoci
      skip; loop
  endif
  if roba->tip $ "UT"
      skip; loop
  endif

  if pu_i=="1"
    nUlaz+=kolicina-GKolicina-GKolicin2
    nMPVU+=mpcsapp*kolicina
    nNVU+=nc*kolicina

  elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    nIzlaz+=kolicina
    nMPVI+=mpcsapp*kolicina
    nNVI+=nc*kolicina


  elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    nUlaz-=kolicina
    nMPVU-=mpcsapp*kolicina
    nnvu-=nc*kolicina

  elseif pu_i=="3"    // nivelacija
    nMPVU+=mpcsapp*kolicina

  elseif pu_i=="I"
    nIzlaz+=gkolicin2
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2
  endif

  skip
enddo

_gkolicina:=nUlaz-nIzlaz
_fcj:=nmpvu-nmpvi // stanje mpvsapp
if round(nulaz-nizlaz,4)<>0
  _mpcsapp:=round((nMPVU-nMPVI)/(nulaz-nizlaz),3)
  _nc:=round((nnvu-nnvi)/(nulaz-nizlaz),3)
else
  _mpcsapp:=0
endif

PopWa()
select kalk_pripr
return



// -------------------------------------------------------------
// Prenumerisanje stavki zadanog dokumenta u kalk_pripremi
// -------------------------------------------------------------
function renumeracija_kalk_pripr( cDok, cIdvd, silent )
local _rbr

if silent == NIL
    silent := .t.
endif

if !silent
    if Pitanje(, "Renumerisati pripremu ?", "N" ) == "N"
        return
    endif
endif

select (F_KALK_PRIPR)
if !used()
    O_KALK_PRIPR
endif

select kalk_pripr
set order to
go top

_rbr := 0

do while !eof()
    replace field->rbr with RedniBroj( ++ _rbr )
    skip
enddo

select kalk_pripr
set order to tag "1"
go top

return



function IspitajPrekid()
INKEY()
return IF(LASTKEY()==27,PrekSaEsc(),.t.)



// Kalkulacija stanja za karticu artikla u prodavnici
function KaKaProd(nUlaz,nIzlaz,nMPV,nNV)
if pu_i=="1"
    nUlaz+=kolicina-GKolicina-GKolicin2
    nMPV+=mpcsapp*kolicina
    nNV+=nc*kolicina
elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    nIzlaz+=kolicina
    nMPV-=mpcsapp*kolicina
    nNV-=nc*kolicina
elseif pu_i=="I"
    nIzlaz+=gkolicin2
    nMPV-=mpcsapp*gkolicin2
    nNV-=nc*gkolicin2
elseif pu_i=="5" .and. (idvd $ "12#13#22")    
    // povrat
    nUlaz-=kolicina
    nMPV-=mpcsapp*kolicina
    nNV-=nc*kolicina
elseif pu_i=="3"    
    // nivelacija
    nMPV+=mpcsapp*kolicina
endif
return



/*! \fn NCuMP(_idfirma,_idroba,_idkonto,nKolicina,dDatDok)
 *  \brief Proracun stanja i nabavne vrijednosti za zadani artikal i prodavnicu
 */

function NCuMP(_idfirma,_idroba,_idkonto,nKolicina,dDatDok)
 LOCAL nArr:=SELECT()
  nKolS:=0
  nKolZN:=0
  nc1:=nc2:=0
  dDatNab:=ctod("")
  _kolicina := nKolicina
  _datdok   := dDatDok
  SELECT KALK
  PushWA()
  MsgO("Racunam stanje u prodavnici")
    KalkNabP(_idfirma,PADR(_idroba,LEN(idroba)),_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab)
  MsgC()
  SELECT KALK
  PopWA()
  SELECT (nArr)
return nc2




/*! \fn KalkTrUvoz()
 *  \brief Proracun carine i ostalih troskova koji se javljaju pri uvozu
 *  \todo samo otvorena f-ja
 */

function KalkTrUvoz()
*{
 LOCAL nT1:=0 , nT2:=0 , nT3:=0 , nT4:=0 , nT5:=0, CP:="999999999.999999999"
  Box("#Unos troskova",7,75)
    @ m_x+2, m_y+2 SAY c10T1 GET nT1 PICT CP
    @ m_x+3, m_y+2 SAY c10T2 GET nT2 PICT CP
    @ m_x+4, m_y+2 SAY c10T3 GET nT3 PICT CP
    @ m_x+5, m_y+2 SAY c10T4 GET nT4 PICT CP
    @ m_x+6, m_y+2 SAY c10T5 GET nT5 PICT CP
    READ
  BoxC()
  MsgBeep("Opcija jos nije u funkciji jer je dorada u toku!")
CLOSERET
*}


/*! \fn ObracunPorezaUvoz()
 *  \brief Proracun poreza pri uvozu
 */

function ObracunPorezaUvoz()
*{
local nTP, qqT1, qqT2, aUT1, aUT2

O_KALK_PRIPR

if !(kalk_pripr->idvd $ "10#81")
    MsgBeep("Ova opcija vrijedi samo za dokumente tipa 10 i 81 !")
    CLOSERET
endif

nTP:=5
qqT1:=PADR(IzFmkIni("RasporedTroskova","UslovPoTarifamaT1","",KUMPATH),40)
qqT2:=PADR(IzFmkIni("RasporedTroskova","UslovPoTarifamaT2","",KUMPATH),40)

Box("#Obracun poreza pri uvozu",7,75)
do while .t.
    @ m_x+2, m_y+2 SAY "Porez je u trosku br.(1-5)" GET nTP PICT "9" VALID nTP>0 .and. nTP<6
    @ m_x+3, m_y+2 SAY "Uslov za sifre tarifa grupe 1 (20%)" GET qqT1 PICT "@!S30"
    @ m_x+4, m_y+2 SAY "Uslov za sifre tarifa grupe 2 (10%)" GET qqT2 PICT "@!S30"
    read
    aUT1:=Parsiraj(qqT1,"idTarifa")
    aUT2:=Parsiraj(qqT2,"idTarifa")
    if aUT1<>nil .and. aUT2<>nil
        exit
    endif
enddo
BoxC()

if lastkey()<>K_ESC
    // proracun poreza
    select kalk_pripr
    go top
    do while !eof()
        Scatter()
        private cPom:=ImePoljaTroska(nTP)
        
        if gKalo=="1"
            skol:=_kolicina-_gkolicina-_gkolicin2
        else
            skol:=_kolicina
        endif
        
        if &aUT1
            _t&cPom:="U"
            _&cPom:=skol*_nc*0.2
        elseif &aUT2
            _t&cPom:="U"
            _&cPom:=skol*_nc*0.1
        endif
        
        NabCj()
        
        Gather()
        skip 1
    enddo
endif

CLOSERET
return
*}


function ImePoljaTroska(n)
*{
local aTros
aTros:={"Prevoz","BankTr","SpedTr","CarDaz","ZavTr"}
return aTros[n]
*}


/*! \fn KTroskovi()
 *  \brief Proracun iznosa troskova pri unosu u kalk_pripremi
 */

function KTroskovi()
*{
local Skol:=0,nPPP:=0

if gKalo=="1"
  Skol:=Kolicina-GKolicina-GKolicin2
else
  Skol:=Kolicina
endif
if roba->tip $ "VKX"
  nPPP:=1/(1+tarifa->opp/100)
  //if roba->tip="X"; nPPP:=nPPP*roba->mpc/vpc; endif
else
  nPPP:=1
endif

if TPrevoz=="%"
  nPrevoz:=Prevoz/100*FCj2
elseif TPrevoz=="A"
  nPrevoz:=Prevoz
elseif TPrevoz=="U"
  if skol<>0
   nPrevoz:=Prevoz/SKol
  else
   nPrevoz:=0
  endif
else
  nPrevoz:=0
endif
if TCarDaz=="%"
  nCarDaz:=CarDaz/100*FCj2
elseif TCarDaz=="A"
  nCarDaz:=CarDaz
elseif TCarDaz=="U"
  if skol<>0
   nCarDaz:=CarDaz/SKol
  else
   nCarDaz:=0
  endif
else
  nCarDaz:=0
endif
if TZavTr=="%"
  nZavTr:=ZavTr/100*FCj2
elseif TZavTr=="A"
  nZavTr:=ZavTr
elseif TZavTr=="U"
  if skol<>0
   nZavTr:=ZavTr/SKol
  else
   nZavTr:=0
  endif
else
  nZavTr:=0
endif
if TBankTr=="%"
  nBankTr:=BankTr/100*FCj2
elseif TBankTr=="A"
  nBankTr:=BankTr
elseif TBankTr=="U"
  if skol<>0
   nBankTr:=BankTr/SKol
  else
   nBankTr:=0
  endif
else
  nBankTr:=0
endif
if TSpedTr=="%"
  nSpedTr:=SpedTr/100*FCj2
elseif TSpedTr=="A"
  nSpedTr:=SpedTr
elseif TSpedTr=="U"
  if skol<>0
   nSpedTr:=SpedTr/SKol
  else
   nSpedTr:=0
  endif
else
  nSpedTr:=0
endif

if IdVD $ "14#94#15"   // izlaz po vp
  if roba->tip=="V"
    nMarza:=VPC*nPPP-VPC*Rabatv/100-NC
  elseif roba->tip=="X"
    nMarza:=VPC*(1-Rabatv/100)-NC- mpcsapp*nPPP*tarifa->opp/100
  else
    nMarza:=VPC*nPPP*(1-Rabatv/100)-NC
  endif
elseif idvd=="24"  // usluge
  nMarza:=marza
elseif idvd $ "11#12#13"
  nMarza:=VPC*nPPP-FCJ
else
 if roba->tip=="X"
   nMarza:=VPC-NC-mpcsapp*nPPP*tarifa->opp/100
 else
   nMarza:=VPC*nPPP-NC
 endif
endif

if (idvd $ "11#12#13")
    if (roba->tip=="K")
        nMarza2:=MPC-VPC*nPPP-nPrevoz
    elseif (roba->tip=="X")
        msgbeep("nije odradjeno")
    else
        nMarza2:=MPC-VPC-nPrevoz
    endif
elseif ( (idvd $ "41#42#43#81") .or. (IsJerry() .and. idvd="4") )
    if (roba->tip=="V")
        nMarza2:=(MPC-roba->VPC)+roba->vpc*nPPP-NC
    elseif (roba->tip=="X")
        msgbeep("nije odradjeno")
    else
        nMarza2:=MPC-NC
    endif
else
    nMarza2:=MPC-VPC
endif
return
*}






/*! \fn ima_u_kalk_kumulativ(cKljuc,cTag)
 *  \brief Ispituje postojanje zadanog kljuca u zadanom indeksu kumulativa KALK
 */

function ima_u_kalk_kumulativ(cKljuc,cTag)
*{
 local lVrati:=.f.
 local lUsed:=.t.
 local nArr:=SELECT()
  SELECT (F_KALK)
  IF !USED()
    lUsed:=.f.
    O_KALK
  ELSE
    PushWA()
  ENDIF
  IF !EMPTY(INDEXKEY(VAL(cTag)+1))
    SET ORDER TO TAG (cTag)
    seek cKljuc
    lVrati:=found()
  ENDIF
  IF !lUsed
    USE
  ELSE
    PopWA()
  ENDIF
  select (nArr)
return lVrati
*}



/* \fn UkupnoKolP(nTotalUlaz, nTotalIzlaz)
 * \brief Obracun kolicine za prodavnicu 
 * \note funkciju staviti unutar petlje koja prolazi kroz kalk
 * \code
 *    nUlazKP:=0
 *    nIzlazKP:=0
 *    do while .t. 
 *      SELECT KALK
 *      UkupnoKolP(@nUlazKP,@nIzlazKP)
 *      SKIP
 *    enddo
 *    ? nUlazKP, nIzlazKP
 * \endcode
 */
 
function UkupnoKolP(nTotalUlaz, nTotalIzlaz)
*{
local cIdRoba
local lUsedRoba

cIdRoba:=field->idRoba

nSelect:=SELECT()

lUsedRoba:=.t.
SELECT(F_ROBA)
if !USED()
    lUsedRoba:=.f.
    O_ROBA
else
    SELECT(F_ROBA)
endif
SEEK cIdRoba

SELECT (nSelect)

if field->pu_i=="1"
    SumirajKolicinu(kolicina, 0, @nTotalUlaz,0)
elseif field->pu_i=="5"
        if field->idvd $ "12#13"
            SumirajKolicinu(-kolicina, 0, @nTotalUlaz,0)
        else
            SumirajKolicinu(0, kolicina, 0, @nTotalIzlaz)
        endif
elseif field->pu_i=="3"    
    // nivelacija
elseif field->pu_i=="I"
        SumirajKolicinu(0, gkolicin2, 0, @nTotalIzlaz)
endif


return
*}

/*! \fn UkupnoKolM(nTotalUlaz, nTotalIzlaz)
 *  \sa UkupnoKolP
 */
 
function UkupnoKolM(nTotalUlaz, nTotalIzlaz)
*{
local cIdRoba
local lUsedRoba

cIdRoba:=field->idRoba

nSelect:=SELECT()

lUsedRoba:=.t.
SELECT(F_ROBA)
if !USED()
    lUsedRoba:=.f.
    O_ROBA
else
    SELECT(F_ROBA)
endif
SEEK cIdRoba

SELECT (nSelect)
if field->mu_i=="1"
    if !(field->idVd $ "12#22#94")
        SumirajKolicinu(field->kolicina-field->gKolicina-field->gKolicin2, 0, @nTotalUlaz, 0)

    else
        SumirajKolicinu(0, -field->kolicina, 0, @nTotalIzlaz)
    endif
     
elseif field->mu_i=="5"
    SumirajKolicinu(0, field->kolicina, 0, @nTotalIzlaz)
    
elseif field->mu_i=="3"    

elseif field->mu_i=="8"
    // sta je mu_i==8 ??
    SumirajKolicinu(-field->kolicina, -field->kolicina, @nTotUlaz, @nTotalIzlaz)
endif

return
*}


function RptSeekRT()
*{
local nArea

nArea:=SELECT()
select ROBA
HSEEK (nArea)->IdRoba
SELECT tarifa
HSEEK (nArea)->IdTarifa
SELECT (nArea)

return
*}


/*! \fn UzmiIzP(cSta)
 *  \brief Uzmi iz parametara
 *  \param cSta - "KOL", "NV", "MPV", MPVBP"...
 */
function UzmiIzP(cSta)  
*{
LOCAL nVrati:=0, nArr:=0
  IF cSta=="KOL"
    if pu_i=="1"
      nVrati := kolicina-GKolicina-GKolicin2
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -kolicina
    elseif pu_i=="I"
      nVrati := -gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -kolicina
    elseif pu_i=="3"    // nivelacija
    endif
  ELSEIF cSta=="NV"
    if pu_i=="1"
      nVrati := +nc*kolicina
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -nc*kolicina
    elseif pu_i=="I"
      nVrati := -nc*gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -nc*kolicina
    elseif pu_i=="3"    // nivelacija
    endif
  ELSEIF cSta=="MPV"
    if pu_i=="1"
      nVrati := +mpcsapp*kolicina
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -mpcsapp*kolicina
    elseif pu_i=="I"
      nVrati := -mpcsapp*gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -mpcsapp*kolicina
    elseif pu_i=="3"    // nivelacija
      nVrati := +mpcsapp*kolicina
    endif
  ELSEIF cSta=="MPVBP"
    if pu_i=="1"
      nVrati := +mpc*kolicina
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -mpc*kolicina
    elseif pu_i=="I"
      nArr:=SELECT()
      SELECT TARIFA; HSEEK (nArr)->IDTARIFA; VTPorezi()
      SELECT (nArr)
      nVrati := -mpcsapp/((1+_OPP)*(1+_PPP))*gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -mpc*kolicina
    elseif pu_i=="3"    // nivelacija
      nVrati := +mpc*kolicina
    endif
  ENDIF
RETURN nVrati
*}


function Generisi11ku_iz10ke(cBrDok)
*{
local nArr
nArr:=SELECT()
O_TARIFA
O_KONCIJ
O_ROBA
O_KALK_PRIPR9
cOtpremnica:=SPACE(10)
cIdKonto:="1320   "
nBrojac:=0
Box(,2,50)
    @ 1+m_x, 2+m_y SAY "Prod.konto zaduzuje: " GET cIdKonto VALID !Empty(cIdKonto)
    @ 2+m_x, 2+m_y SAY "Po otpremnici: " GET cOtpremnica
    read
BoxC()

select kalk_pripr
go top
do while !EOF()
    aPorezi:={}
    fMarza:=" "
    ++nBrojac
    cKonto:=kalk_pripr->idKonto
    cRoba:=kalk_pripr->idRoba
    cTarifa:=kalk_pripr->idtarifa
    select roba
    seek cRoba
    select tarifa
    seek cTarifa
    SetAPorezi(@aPorezi)
    VTPorezi()
    select kalk_pripr
    Scatter()
    select kalk_pripr9
    append blank
    _idvd:="11"
    _brDok:=cBrDok
    _idKonto:=cIdKonto
    _idKonto2:=cKonto
    _brFaktP:=cOtpremnica
    _tPrevoz:="R"
    _tMarza:="A"
    _marza:=_vpc/(1+_PORVT)-_fcj
    _tMarza2:="A"
    _mpcsapp:=UzmiMpcSif()
    VMPC(.f., fMarza)
    VMPCSaPP(.f.,fMarza)
    _MU_I:="5"
    _PU_I:="1"
    _mKonto:=cKonto
    _pKonto:=cIdKonto
    Gather()
    select kalk_pripr
    skip

enddo

select (nArr)

MsgBeep("Formirao dokument " + ALLTRIM(gFirma) + "-11-" + ALLTRIM(cBrDok))
return
*}


function Get11FromSmece(cBrDok)
*{
local nArr
nArr:=SELECT()

O_KALK_PRIPR9
select kalk_pripr9
go top
do while !EOF()
    if (field->idvd=="11" .and. field->brdok==cBrDok)
        Scatter()
        select kalk_pripr
        append blank
        Gather()
        select kalk_pripr9
        delete
        skip
    else
        skip
    endif
enddo

select (nArr)
MsgBeep("Asistentom obraditi dokument !")
return
*}


function Generisati11_ku()
*{
// daj mi vrstu dokumenta kalk_pripreme
nTRecNo:=RECNO()
go top
cIdVD:=kalk_pripr->idvd
go (nTRecNo)
// ako se ne radi o 10-ci nista
if (cIdVD <> "10")
    return .f.
endif
if IzFmkIni("KALK","AutoGen11","N",KUMPATH)=="D" .and. Pitanje(,"Formirati 11-ku (D/N)?","D")=="D"
    return .t.
else
    return .f.
endif
return
*}


// set pdv cijene
function set_pdv_cijene()
*{

if !SigmaSif("SETPDVC")
   MsgBeep("Ne cackaj!")
   return
endif


//ppp tarifa
cIdTarifa:=SPACE(6)

cZaTarifu:=SPACE(6)
nZaokruzenje:=2
cPdvTarifa:=PADR("PDV17", 6)
cSetCijena:="1"

O_ROBA
O_ROBASEZ
O_TARIFA


SET CURSOR ON
Box(,5,60)
    cUvijekUzmi := "N"
    @ 1+m_x, 2+m_y SAY "Set cijene za tarifu  (prazno sve tarife)?" GET cZaTarifu PICT "@!" VALID  EMPTY(cZaTarifu) .or. P_Tarifa(@cZaTarifu)
    @ 2+m_x, 2+m_y SAY "Zaokruzenje cijene na koliko decimala "  get nZaokruzenje PICT "9"
    @ 3+m_x, 3+m_y SAY "PDV tarifa " GET cPdvTarifa VALID P_Tarifa(@cPdvTarifa)
    @ 4+m_x, 3+m_y SAY "Set cijena MPC (1), MPC2 (2) " GET cSetCijena VALID cSetCijena $ "12"
    READ
    
BoxC()

if Lastkey() == K_ESC
    closeret
endif


select roba

set order to tag "ID"
go top

Box(,3,60)

aPorezi := {}

do while !eof()
    
    cIdRoba := roba->id
    
    SELECT robasez
    set order to tag "ID"
    hseek cIdRoba
    
    if !Found()
        select roba
        skip
        loop
    endif

    cIdTarifa:=robasez->idtarifa
    nMpcSaP1 := robasez->mpc
    nMpcSaP2 := robasez->mpc2

    if robasez->(FIELDPOS("zaniv2")) <> 0
        nAkcizaPorez := robasez->zaniv2
    else
        nAkcizaPorez := 0
    endif
    
    if !empty(cZaTarifu) .and. (cIdTarifa <> cZaTarifu)
        select roba
        skip
        loop    
    endif
    
    @ m_x+1,m_y+2 SAY "Roba / Tarifa : " + cIdRoba + "/" + cIdTarifa

    // ako je konto prazan, onda gledaj samo sifrarnik
    Tarifa( "", cIdRoba, @aPorezi, cIdTarifa)
    
    
    // nc = 99999 jer je ne trebamo
    nMpcBP1 := MpcBezPor( nMpcSaP1, aPorezi, , 99999)
    nMpcBP2 := MpcBezPor( nMpcSaP2, aPorezi, , 99999)

    nMpcBP1 -= nAkcizaPorez
    nMpcBP2 -= nAkcizaPorez
    
    SELECT tarifa
    SEEK cPdvTarifa
    nPdvTarifa := tarifa->opp
    
    nPdvC1 := nMpcBP1 * ( 1 + nPdvTarifa/100 )
    nPdvC1 := ROUND( nPdvC1, nZaokruzenje)
        
    nPdvC2 := nMpcBP2 * ( 1 + nPdvTarifa/100 )
    nPdvC2 := ROUND( nPdvC2, nZaokruzenje)

    SELECT ROBA

    if cSetCijena == "1"
        replace mpc with nPdvC1
    endif

        if cSetCijena == "2"
        replace mpc2 with nPdvC2
    endif
    
    skip
    
enddo       

BoxC()

MsgBeep("Formirao PDV cijene u sifrarniku Roba tekuca godina")

closeret
*}


// set pdv cijene
function SetPomnoziCijene()
*{

local cIdTarifa:=SPACE(6)
local cZaTarifu:=SPACE(6)
local nZaokruzenje:=2
cSetCijena:="1"


if !SigmaSif("SETCPOFA")
   MsgBeep("Ne cackaj!")
   return
endif


O_ROBA
O_TARIFA

nFaktor := 1.17
SET CURSOR ON
Box(,5,60)
    cUvijekUzmi := "N"
    @ 1+m_x, 2+m_y SAY "Set cijene za tarifu  (prazno sve tarife)?" GET cZaTarifu PICT "@!" VALID  EMPTY(cZaTarifu) .or. P_Tarifa(@cZaTarifu)
    @ 2+m_x, 2+m_y SAY "Zaokruzenje cijene na koliko decimala "  get nZaokruzenje PICT "9"
    @ 4+m_x, 3+m_y SAY "Set cijena MPC (1), MPC2 (2) " GET cSetCijena VALID cSetCijena $ "12"
    @ 5+m_x, 3+m_y SAY "Faktor sa kojim se cijena mnozi ?" GET nFaktor PICT  "999999.99999"
    READ
    
BoxC()

if Lastkey() == K_ESC
    closeret
endif


select roba

set order to tag "ID"
go top

Box(,3,60)

aPorezi := {}

do while !eof()
    
    cIdRoba := roba->id
    cIdTarifa := roba->idtarifa
    
    @ m_x+1,m_y+2 SAY "Roba / Tarifa : " + cIdRoba + "/" + cIdTarifa

    // ako je konto prazan, onda gledaj samo sifrarnik
    //Tarifa( "", cIdRoba, @aPorezi, cIdTarifa)
    
    

    SELECT ROBA

    if cSetCijena == "1"
            nNovaCj := ROUND( mpc * nFaktor, nZaokruzenje)
        replace mpc with nNovaCj
    endif

        if cSetCijena == "2"
            nNovaCj := ROUND( mpc2 * nFaktor, nZaokruzenje)
        replace mpc2 with nNovaCj
    endif
    
    skip
    
enddo       

BoxC()

MsgBeep("Formirao nove cijene, pomnozio sa faktorom !")

closeret
*}



// kopiraj stavke u pript tabelu iz KALK
function cp_dok_pript(cIdFirma, cIdVd, cBrDok)
*{
// kreiraj pript
crepriptdbf()
O_PRIPT
O_KALK
select kalk
set order to tag "1"
hseek cIdFirma+cIdVd+cBrDok
if Found()
    MsgO("Kopiram dokument u pript...")
    do while !EOF() .and. (kalk->(idfirma+idvd+brdok) == cIdFirma+cIdVd+cBrDok) 
        Scatter()
        select pript
        append blank
        Gather()
        select kalk
        skip
    enddo
    MsgC()
else
    MsgBeep("Dokument " + cIdFirma + "-" + cIdVd + "-" + ALLTRIM(cBrDok) + " ne postoji !!!")
    return 0
endif

return 1



// --------------------------------------------------
// vraca oznaku PU_I za pojedini dokument prodavnice
// --------------------------------------------------
function get_pu_i(cIdVd)
local cRet := " "

do case 
    case cIdVd $ "11#15#80#81"
        cRet := "1"
    case cIdVd $ "12#41#42#43"
        cRet := "5"
    case cIdVd == "19"
        cRet := "3"
    case cIdVd == "IP"
        cRet := "I"
        
endcase

return cRet


// --------------------------------------------------
// vraca oznaku MU_I za pojedini dokument magacina
// --------------------------------------------------
function get_mu_i(cIdVd)
local cRet := " "

do case 
    case cIdVd $ "10#12#16#94"
        cRet := "1"
    case cIdVd $ "11#14#82#95#96#97"
        cRet := "5"
    case cIdVd == "15"
        cRet := "8"
    case cIdVd == "18"
        cRet := "3"
    case cIdVd == "IM"
        cRet := "I"
        
endcase

return cRet


// ------------------------------------------------------------
// da li je dokument u procesu
// provjerava na osnovu polja PU_I ili MU_I
// ------------------------------------------------------------
function dok_u_procesu(cFirma, cIdVd, cBrDok)
local nTArea := SELECT()
local lRet := .f.

select kalk

if cIdVD $ "#80#81#41#42#43#12#19#IP" 
    set order to tag "PU_I2"
else
    set order to tag "MU_I2"
endif

go top
seek "P" + cFirma + cIdVd + cBRDok

if FOUND()
    lRet := .t.
endif

select kalk
set order to tag "1"

select (nTArea)
return lRet

// ----------------------------------------------------------
// skeniranje koje se poziva automatski za sve prodavnice
// ----------------------------------------------------------
function pl_scan_automatic()
local nTArea := SELECT()

if !isplanika()
    return
endif

if o_p_update() == 0
    return
endif
select p_update
go top

if p_update->(RecCount()) == 0
    return
endif

go top

MsgBeep("!EOF()")

do while !EOF()
    
    if field->p_updated == "N"
    
        scan_dok_u_procesu("P", field->idkonto)
        
        select p_update
        
        scatter()
        _p_updated := "D"
        gather()
        
    endif
        
    select p_update
    skip
enddo

c_p_update()

select (nTArea)
return


// -------------------------------------------------
// skeniraj dokumente u procesu za cKonto
// -------------------------------------------------
function pl_scan_dok_u_procesu(cKonto)
local nTArea := SELECT()

if !IsPlanika()
    return
endif

// da li treba odraditi update za specifican konto
if !EMPTY(cKonto) .and. scan_p_update("TOPS", cKonto)
    // skeniraj dokumente u procesu
        scan_dok_u_procesu("P", cKonto)
        // dodaj da je skenirano za konto....
    add_p_update("TOPS", cKonto, "D")
endif

// da li treba uraditi update za sva konta
if EMPTY(cKonto)
    scan_dok_u_procesu("P")
endif

select (nTArea)
return

// ----------------------------------------------
// skeniranje i setovanje novih stanja
// za dokumente u procesu
// 
// cMagProd - marker "M"agacin, "P"rodavnica
// cPMKonto - prodavnicki/magacinski konto 
// ----------------------------------------------
function scan_dok_u_procesu(cMagProd, cPMKonto)
local cPMU_I := "MU_I"
local cFldMPKonto := "MKONTO"
local nDokNaStanju := 0
local nNRec
local nCount := 0
local cSeekDok := ""
local nScanArr := 0
local aDokNaStanju := {}
local cSeekUsl := ""

O_KONCIJ
O_KALK
o_kalk_doks

if cPMKonto == nil
    cPMKonto := ""
endif

if cMagProd == nil
    cMagProd := "P"
endif

select kalk

if cMagProd == "P"
    cPMU_I := "PU_I"
endif

cFldMPKonto := cMagProd + "KONTO"

set order to tag &cPMU_I
go top

cSeekUsl := "P"

if !EMPTY(cPMKonto)
    cSeekUsl += cPMKonto
endif

seek cSeekUsl

Box(, 2, 70)

do while !EOF() .and. field->&cPMU_I == "P" ;
        .and. IF(!EMPTY(cPMKonto), field->&cFldMPKonto == cPMKonto, .t.)
    
    cKIdFirma := kalk->idfirma
    cKIdVd := kalk->idvd
    cKBrDok := kalk->brdok
    cKKonto := kalk->idkonto

    @ m_x+1, m_y+2 SAY "Dokument: " + cKIdFirma + "-" + cKIdVd + "-" + cKBrDok + SPACE(5) + "konto: " + cKKonto

    // provjeri da li je tops dokument na stanju
    nDokNaStanju := tops_dok_na_stanju(cKIdFirma, cKIdVd, cKBrDok, cKKonto)
        
    select kalk

    if nDokNaStanju == -1
        MsgBeep(cKKonto + " nema podesene parametre u konciju!!!")
        skip
        loop
    endif

    if nDokNaStanju == 2
        
        if EMPTY(cPMKonto)
          MsgBeep("Dokument " + kalk->idfirma + "-" + ;
                  kalk->idvd + "-" + ALLTRIM(kalk->brdok) + ;
              " nije prenesen u TOPS !")
        endif
        
    endif
    
    do while !EOF() .and. kalk->(&cPMU_I + idfirma + idvd + brdok) == "P" + cKIdFirma + cKIdVd + cKBrDok
        
        skip
        nNRec := RECNO()
        skip -1
        
        if nDokNaStanju == 1
            
            // funkcije koje setuju stanje...
            Scatter()
            _pu_i := get_pu_i(cKIdVd)
            _mu_i := get_mu_i(cKIdVd)
            Gather()

            ++ nCount

            cSeekDok := kalk->idfirma
            cSeekDok += "-"
            cSeekDok += kalk->idvd
            cSeekDok += "-"
            cSeekDok += ALLTRIM(kalk->brdok)

            nScanArr := ASCAN(aDokNaStanju, {|xVal| xVal[1] == cSeekDok })
            if nScanArr == 0
                AADD(aDokNaStanju, { cSeekDok, kalk->datdok })
            endif
            
        endif
        
        if EMPTY(cPMKonto)
            // upisi da je skenirano u p_update
                add_p_update("TOPS", kalk->pkonto, "D")
        endif

        select kalk
        
        go (nNREC)
    enddo
enddo

BoxC()

// prikazi report...
// rpt_dok_na_stanju(aDokNaStanju)

return


// -----------------------------------------------------
// izvjestaj o dokumentima stavljenim na stanje
// -----------------------------------------------------
static function rpt_dok_na_stanju(aDoks)
local i

if LEN(aDoks) == 0
    MsgBeep("Nema novih dokumenata na stanju !")
    return
endif

START PRINT CRET

? "Lista dokumenata stavljenih na stanje:"
? "--------------------------------------"
?

for i:=1 TO LEN(aDoks)
    ? aDoks[i, 1], aDoks[i, 2]
next

?

FF
END PRINT

return


// --------------------------------------------------------------
// da li je vezni tops dokument na stanju
// 
// funkcija vraca nNaStanju
//    0 = nije na stanju
//    1 = na stanju je
//   -1 = nije nesto podeseno u konciju
//    2 = nije prenesen u TOPS
// --------------------------------------------------------------
static function tops_dok_na_stanju(cFirma, cIdVd, cBrDok, cKonto)
local nTArea := SELECT()
local nNaStanju := 1
local cTKPath := ""
local cTSPath := ""
local cTPM := ""

select koncij
set order to tag "ID"
hseek cKonto

if FOUND()
    cTKPath := ALLTRIM(field->kumtops)
    cTSPath := ALLTRIM(field->siftops)
    cTPm := field->idprodmjes
else
    select (nTArea)
    return -1
endif

AddBS(@cTKPath)
AddBS(@cTSPath)

// otvori kalk_doksRC i kalk_doks
if FILE(cTKPath + "DOKSRC.DBF")
    select (248)
    use (cTKPath + "DOKSRC") alias TDOKSRC
    set order to tag "2"
else
    select (nTArea)
    return -1
endif
if FILE(cTKPath + "DOKS.DBF")
    select (249)
    use (cTKPath + "DOKS") alias TDOKS
    set order to tag "2"
else
    select (nTArea)
    return -1
endif

select tdoksrc
go top
seek PADR("KALK", 10) + cFirma + cIdvd + cBrDok

// pronadji dokument TOPS - vezni
if FOUND()
    
    cTBrDok := tdoksrc->brdok
    cTIdPos := tdoksrc->idfirma
    cTIdVd := tdoksrc->idvd
    dTDatum := tdoksrc->datdok

    select tdoks
    set order to tag "1"
    go top
    seek cTIdPos + cTIdVd + DTOS(dTDatum) + cTBrDok

    if FOUND()
        if ALLTRIM(tdoks->sto) == "N"
            nNaStanju := 0
        endif
    endif
    
else
    nNaStanju := 2
endif

select (248)
use

select (249)
use

select (nTArea)
return nNaStanju


// ------------------------------------------
// konvertovanje sifre dobavljaca
// ------------------------------------------
function c_sifradob()
local nCount := 0
local cSDob
local nNo := 5
local cPredzn := "0"

if Pitanje(,"Izvrsiti konverziju ?", "N") == "N"
    return
endif

if !SigmaSif("SIFDOB")
    msgbeep("Ne cackaj !!!")
    return
endif

Box(,3,50)
    @ m_x + 1, m_y + 2 SAY "velicina sifre" GET nNo PICT "9"
    @ m_x + 2, m_y + 2 SAY "prefiks" GET cPredzn 
    read
BoxC()

O_ROBA
set order to tag "ID"
go top

do while !EOF()
    
    // sifra dobavljaca
    cSDob := ALLTRIM( field->sifradob )
 
    if !EMPTY( cSDob )
        cNDob := PADL( cSDob, nNo, cPredzn )
        // ubaci novu sifru sa nulama
        replace sifradob with PADR( cNDob, 8 )
        ++ nCount 
    endif
    
    skip

enddo

if nCount > 0
    msgbeep("Konvertovano: " + ALLTRIM(STR(nCount)) + " zapisa !")
endif

return


// ---------------------------------------
// brisi dokumente
// ---------------------------------------
function del_docs()
local dD_f
local dD_t
local dDate

if ddoc_vars( @dD_f, @dD_t ) = 0
    return
endif

if !SigmaSif("KALKDEL")
    msgbeep("Ne cackaj !")
    return
endif

o_kalk_doks
O_KALK

msgo("brisem kalk_doks...")
select kalk_doks
set order to tag "1"
go top

do while !EOF()

    dDate := field->datdok

    if ( dDate >= dD_f .and. dDate <= dD_t )
        delete
    endif

    skip
enddo
msgc()

msgo("brisem KALK...")
select kalk
set order to tag "1"
go top

do while !EOF()
    
    dDate := field->datdok

    if ( dDate >= dD_f .and. dDate <= dD_t )
        delete
    endif

    skip
enddo
msgc()

msgbeep("Podaci zadatog perioda izbrisani !")

return


// -----------------------------------------------------
// uslovi opcije brisanje dokumenata
// -----------------------------------------------------
static function ddoc_vars( dDate_f, dDate_t )
private getlist:={}

dDate_f := DATE()
dDate_t := DATE()

Box(,1, 60)
    @ m_x + 1, m_y + 2 SAY "u periodu od:" GET dDate_f
    @ m_x + 1, col() + 1 SAY "do:" GET dDate_t 
    read
BoxC()

if LastKey() == K_ESC
    return 0
endif

return 1


// ------------------------------------------
// spajanje tabele kalk iz sezona
// ------------------------------------------
function kalk_join()
local cSezone := SPACE(150)
local aSezone := {}
local cT_sez := goModul:oDataBase:cSezona
local cR_sez := goModul:oDataBase:cRadimUSezona
local cT_path
local i
local nCnt := 0
local lSilent := .t.
local lWriteKParam := .t.

Box(, 5, 60)
    @ m_x + 1, m_y + 2 SAY "Dodaj podatke iz sezona:" ;
        GET cSezone ;
        PICT "@S25"

    read
BoxC()

if LastKey() == K_ESC
    return
endif

if EMPTY( cSezone )
    return
endif

if !SigmaSif("KALKJ")
    msgbeep("Ne cackaj!")
    return
endif

// predji u tekucu sezonu i setuj path
goModul:oDataBase:logAgain( "RADP", lSilent, lWriteKParam )

cT_path := KUMPATH

// vrati se u sezonu u kojoj si bio
goModul:oDataBase:logAgain( cR_sez, lSilent, lWriteKParam )


// generisi matricu sezona
aSezone := TokToNiz( ALLTRIM(cSezone), ";" )

for i:=1 to LEN( aSezone )
    
    if ALLTRIM( aSezone[i] ) <> cR_sez
    
        o_p_tbl( cT_path, ALLTRIM( aSezone[i] ), cT_sez )
    
        msgo("prebacujem sezonu " + ALLTRIM( aSezone[i]))

        O_KALK
        o_kalk_doks

        select kalk_s
        go top
        do while !EOF()
            scatter()
            select kalk
            append blank
            Gather()
            select kalk_s
            skip
        enddo
    
        select kalk_doks_s
        go top
        do while !EOF()
            scatter()
            select kalk_doks
            append blank
            Gather()
            select kalk_doks_s
            skip
            ++ nCnt
        enddo

        msgc()

        c_p_tbl()

    endif

next

msgbeep("Ubaceno " + ALLTRIM(STR(nCnt)) + " dokumenata.")

return


// ------------------------------------------
// export podataka kalk tabele
// ------------------------------------------
function kalk_export()
local cSezone := SPACE(150)
local aSezone := {}
local i
local lSilent := .t.
local lWriteKParam := .t.
local lInSez
local cP_path := PRIVPATH
local cT_sez := goModul:oDataBase:cSezona
local cG_sez := cT_sez
local cU_dok := SPACE(100)
local dD_from := CTOD("")
local dD_to := CTOD("")

Box(, 5, 60)

    @ m_x + 1, m_y + 2 SAY "export sezone:" ;
        GET cSezone ;
        PICT "@S40"

    @ m_x + 3, m_y + 2 SAY "dokumenti (prazno-svi):" ;
        GET cU_dok ;
        PICT "@S30"

    @ m_x + 4, m_y + 2 SAY "datum od:" GET dD_from
    @ m_x + 4, col() + 1 SAY "do:" GET dD_to
    
    read
BoxC()

if LastKey() == K_ESC
    return
endif

// kreiraj pomocnu tabelu
cre_tmp( cP_path )

// generisi matricu sezona
aSezone := TokToNiz( ALLTRIM(cSezone), ";" )

// prodji kroz sezone i napuni podatke
for i:=1 to LEN( aSezone )
    
    if ALLTRIM( aSezone[i] ) <> cT_sez

        // predji u sezonu
        goModul:oDataBase:logAgain( ALLTRIM(aSezone[i]), ;
            lSilent, lWriteKParam )
        // vrati mi vrijednost o sezoni
        cG_sez := ALLTRIM( aSezone[i] )

        o_tmp( cP_Path )
    endif

    msgo("exportujem sezonu " + ALLTRIM(aSezone[i]))

    O_KALK
    select kalk
    go top

    do while !EOF() 

        if !EMPTY( cU_dok )
            if kalk->idvd $ cU_dok
                // idi dalje...
            else
                skip
                loop
            endif
        endif
        
        select r_export
        append blank

        replace field->idfirma with kalk->idfirma
        replace field->idroba with kalk->idroba
        replace field->rbr with kalk->rbr
        replace field->idkonto with kalk->idkonto
        replace field->idkonto2 with kalk->idkonto2
        replace field->idvd with kalk->idvd
        replace field->brdok with kalk->brdok
        replace field->datdok with kalk->datdok
        replace field->brfaktp with kalk->brfaktp
        replace field->datfaktp with kalk->datfaktp
        replace field->idpartner with kalk->idpartner
        replace field->kolicina with kalk->kolicina
        replace field->nc with kalk->nc
        replace field->fcj with kalk->fcj
        replace field->vpc with kalk->vpc
        replace field->rabatv with kalk->rabatv
        replace field->mpc with kalk->mpc
        replace field->mpcsapp with kalk->mpcsapp
        replace field->mkonto with kalk->mkonto
        replace field->pkonto with kalk->pkonto

        select kalk
        skip
    enddo

    msgc()

next

// na kraju se vrati u tekuce radno podrucje
if cG_sez <> cT_sez
    goModul:oDataBase:logAgain( cT_sez, lSilent, lWriteKParam )
    o_tmp( cP_path )
endif

msgbeep( "Tabela R_EXPORT.DBF napunjena KALK podacima!")

return



// -------------------------------------------
// kreiraj pomocnu tabelu
// -------------------------------------------
static function cre_tmp( cPath )
local aFields := {}

AADD( aFields, {"idfirma", "C", 2, 0} )
AADD( aFields, {"idroba", "C", 10, 0} )
AADD( aFields, {"rbr", "C", 4, 0} )
AADD( aFields, {"idkonto", "C", 7, 0} )
AADD( aFields, {"idkonto2", "C", 7, 0} )
AADD( aFields, {"idvd", "C", 2, 0} )
AADD( aFields, {"brdok", "C", 10, 0} )
AADD( aFields, {"datdok", "D", 8, 0} )
AADD( aFields, {"brfaktp", "C", 10, 0} )
AADD( aFields, {"datfaktp", "D", 8, 0} )
AADD( aFields, {"idpartner", "C", 6, 0} )
AADD( aFields, {"kolicina", "N", 15, 5} )
AADD( aFields, {"nc", "N", 15, 5} )
AADD( aFields, {"fcj", "N", 15, 5} )
AADD( aFields, {"vpc", "N", 15, 5} )
AADD( aFields, {"rabatv", "N", 15, 5} )
AADD( aFields, {"mpc", "N", 15, 5} )
AADD( aFields, {"mpcsapp", "N", 15, 5} )
AADD( aFields, {"mkonto", "C", 7, 0} )
AADD( aFields, {"pkonto", "C", 7, 0} )

t_exp_create( aFields )

o_tmp( cPath )

return


// --------------------------------------------
// otvori pomocnu tabelu
// --------------------------------------------
static function o_tmp( cPath )

select (248)
use ( cPath + "r_export" ) alias "r_export"

return


// --------------------------------------------
// otvori pomocnu tabelu
// --------------------------------------------
static function o_p_tbl( cPath, cSezona, cT_sezona )

if cSezona = "RADP" .or. cSezona == cT_sezona
    cSezona := ""
endif

if !EMPTY(cSezona)
    cSezona := cSezona + SLASH
endif

select (248)
use ( cPath + cSezona + "KALK" ) alias "kalk_s"
select (249)
use ( cPath + cSezona + "DOKS" ) alias "doks_s"

return

// ----------------------------------------------
// zatvori pomocne sezonske tabele
// ----------------------------------------------
static function c_p_tbl()
select (248)
use
select (249)
use
return



