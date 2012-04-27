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



function Get1_95()
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje


set key K_ALT_K to KM2()
if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1 .or. !fnovi .or. gMagacin=="1"
 @  m_x+5,m_y+2   SAY "Dokument Broj:" get _BrFaktP
 @  m_x+5,col()+1 SAY "Datum:" get _DatFaktP   ;
    valid {|| _DatKurs:=_DatFaktP,.t.}
 
 if is_uobrada()
    @ m_x+5, col()+1 SAY "Odobrenje:" GET _odobr_no PICT "@S10"
 endif
 
 _IdZaduz:=""
 @ m_x+8,m_y+2 SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
            valid empty(_IdKonto2) .or. P_Konto(@_IdKonto2,21,5)
 if gNW<>"X"
   @ m_x+8,m_y+40 SAY "Razduzuje:" GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2,21,5)
 else
   if !empty(cRNT1) .and. _idvd $ "97#96#95"
     if (IsRamaGlas())
       @ m_x+8,m_y+40 SAY "Rad.nalog:" GET _IdZaduz2 pict "@!" valid RadNalOK()
     else
       @ m_x+8,m_y+40 SAY "Rad.nalog:" GET _IdZaduz2   pict "@!"
     endif
   endif
 endif
 if _idvd $ "97#96#95"    // ako je otprema, gdje to ide
   
   @ m_x+9,m_y+2   SAY "Konto zaduzuje            " GET _IdKonto valid  empty(_IdKonto) .or. P_Konto(@_IdKonto,21,5) pict "@!"
   
   if (_idvd=="95" .and. IsVindija())
       
       @ m_x+9,m_y+40 SAY "Sifra veze otpisa:" GET _IdPartner  valid empty(_idPartner) .or.P_Firma(@_IdPartner,21,5) pict "@!"
   
   elseif gMagacin=="1"
       @ m_x+9,m_y+40 SAY "Partner zaduzuje:" GET _IdPartner  valid empty(_idPartner) .or.P_Firma(@_IdPartner,21,5) pict "@!"
   
   else
      if _idvd == "96"
          @ m_x+9,m_y+40 SAY "Partner zaduzuje:" GET _IdPartner  valid empty(_idPartner) .or.P_Firma(@_IdPartner,21,5) pict "@!"
      endif
   endif
 
 else
  _idkonto:=""
 endif

else
 @  m_x+6,m_y+2   SAY "Dokument Broj: "; ?? _BrFaktP
 @  m_x+6,col()+2 SAY "Datum: "; ?? _DatFaktP
 _IdZaduz:=""
 _DatKurs:=_DatFaktP
 @ m_x+8,m_y+2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
 @ m_x+9,m_y+2 SAY "Konto zaduzuje "; ?? _IdKonto
 if gNW<>"X"
   @ m_x+9,m_y+40 SAY "Razduzuje: "; ?? _IdZaduz2
 endif
endif

 if !glEkonomat
   @ m_x+10,m_y+66 SAY "Tarif.brÄ¿"
 endif
 if lKoristitiBK
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz,40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 if !glEkonomat
   @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)
 endif
 
 if IsDomZdr()
    @ m_x + 12, m_y + 2 SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 endif

 if is_uobrada()
    @ m_x+12,m_y+2 SAY "JCI br: " GET _jci_no PICT "@S10"
    @ m_x+12,col()+2 SAY "EX3 br: " GET _ex_no PICT "@S10"
 endif

 read; ESC_RETURN K_ESC
 if lKoristitiBK
    _idRoba:=Left(_idRoba, 10)
 endif

 _MKonto:=_Idkonto2
 DatPosljK()
 DuplRoba()

 select koncij
 seek trim(_idkonto2)
 select TARIFA
 hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select kalk_pripr  // napuni tarifu

 @ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina <> 0

 
IF gVarEv=="1"

 _GKolicina:=0
 if fNovi
   
   select ROBA; HSEEK _IdRoba
   if koncij->naz=="P2"
     _VPC:=PLC
   else
     _VPC:=KoncijVPC()
   endif
   
   _NC:=NC
 endif

 if gCijene="2" .and. fNovi
   /////// utvrdjivanje fakticke VPC
    faktVPC(@_VPC, _idfirma + _idkonto2 + _idroba)
    select kalk_pripr
 endif


 //////// kalkulacija nabavne cijene
 //////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
 nKolS:=0
 nKolZN:=0
 nc1:=nc2:=0
 dDatNab:=ctod("")

 lGenStavke:=.f.
 
 if _TBankTr<>"X" 
 
   if !empty(gMetodaNC)  .and. !(roba->tip $ "UT")

     IF glEkonomat

       aNabavke:={}
       IF !fNovi
         AADD( aNabavke , {0,_nc,_kolicina} )
       ENDIF
       KalkNab2(_idfirma, _idroba, _idkonto2, aNabavke)
       IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF

     ELSE

       MsgO("Racunam stanje na skladistu")
        KalkNab(_idfirma, _idroba, _idkonto2, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab, @_RokTr)
       MsgC()

       @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nKols pict pickol
       @ m_x+13,m_y+30   SAY "Srednja nc "; @ m_x+13, col()+2 SAY nc2 pict pickol

     ENDIF

   endif

   if !glEkonomat

     if dDatNab>_DatDok; Beep(1); Msg("Datum nabavke je "+dtoc(dDatNab),4); endif

     if !(roba->tip $ "UT")

       if gMetodaNC $ "13"
            // prva ili zadnja
            _nc := nc1 
       elseif gMetodaNC == "2"
            // srednja
            _nc := nc2
       endif

       if gMetodaNc == "2"
         if _kolicina > 0
          select roba
          _rec := dbf_get_rec()
          _rec["nc"] := _nc
          update_rec_server_and_dbf( ALIAS(), _rec )
          select kalk_pripr // nafiluj sifrarnik robe sa nc sirovina, robe
         endif
       endif

     endif
   endif

 endif

 select kalk_pripr
 if !glEkonomat
   @ m_x+14,m_y+2  SAY "NAB.CJ   "  GET _NC  picture gPicNC  valid V_KolMag()
   private _vpcsappp:=0
   if !IsMagPNab()
     if _vpc=0
        _vpc := KoncijVPC()        // MS 19.12.00
     endif
     if IsPDV()
        @ m_x+15,m_y+2   SAY "PROD.CIJ " get _VPC    picture PicDEM
     else
        @ m_x+15,m_y+2   SAY "VPC      " get _VPC    picture PicDEM
     endif
     _PNAP:=0
     
     if gMagacin=="1" .and. !IsPDV() 
     // ovu cijenu samo prikazati ako se vodi po nabavnim cijenama
       _VPCSAPPP:=0
     endif
     
     if IsPDV() .and. gPDVMagNab == "N"
     
        _mpcsapp:=roba->mpc
    // VPC se izracunava pomocu MPC cijene !!
    @ m_x+17,m_y+2 SAY "PROD.CJENA SA PDV:"
    @ m_x+17,col()+2 GET _MPCSaPP  picture PicDEM ;
                valid {|| _mpcsapp:=iif(_mpcsapp=0,round( _vpc * (1+TARIFA->opp/100),2),_mpcsapp),_mpc:=_mpcsapp/(1+TARIFA->opp/100),iif(_mpc<>0,_vpc:=round(_mpc,2),_vpc), ShowGets(),.t.}
        read
   else
    read
   endif    
   
   else // magacin po vpc
     read
     _Marza:=0; _TMarza:="A"; _VPC:=_NC
   endif //magacin po nc
 endif
ELSE    // ako je gVarEv=="2" tj. bez cijena
  read
ENDIF

IF glEkonomat
  _Marza:=0; _TMarza:="A"
  if !IsPDV()
    _mpcsapp:=0
  endif
  _MKonto:=_Idkonto2;_MU_I:="5"     // izlaz iz magacina
  _PKonto:=""; _PU_I:=""
  IF lGenStavke
    pIzgSt:=.t.
    // viçe od jedne stavke
    FOR i:=1 TO LEN(aNabavke)-1
      // generiçi sve izuzev posljednje
      APPEND BLANK
      _error    := IF(_error<>"1","0",_error)
      _rbr      := RedniBroj(nRBr)
      _nc       := aNabavke[i,2]
      _kolicina := aNabavke[i,3]
      _vpc      := _nc
      Gather()
      ++nRBr
    NEXT
    // posljednja je teku†a
    _nc       := aNabavke[i,2]
    _kolicina := aNabavke[i,3]
    _vpc      := _nc
  ELSE
    // jedna ili nijedna
    IF LEN(aNabavke)>0
      // jedna
      _nc       := aNabavke[1,2]
      _kolicina := aNabavke[1,3]
      _vpc      := _nc
    ELSE
      // nije izabrana koliŸina -> kao da je prekinut unos tipkom Esc
      RETURN (K_ESC)
    ENDIF
  ENDIF
ENDIF

if !IsPDV()
    _mpcsapp:=0
endif

nStrana:=2
_marza:=_vpc-_nc
_MKonto:=_Idkonto2;_MU_I:="5"     // izlaz iz magacina
_PKonto:=""; _PU_I:=""

if pIzgSt  .and. _kolicina>0 .and.  lastkey()<>K_ESC // izgenerisane stavke postoje
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
    if IsMagPNab()
      nmarza:=0
      replace vpc with kalk_pripr->nc,;
          vpcsap with  kalk_pripr->nc,;
          rabatv with  0 ,;
          marza with  0
    else
     nMarza:=_VPC*(1-_RabatV/100)-_NC
     replace vpc with _vpc,;
          vpcsap with _VPC*(1-_RABATV/100)+iif(nMarza<0,0,nMarza)*TARIFA->VPP/100,;
          rabatv with _rabatv,;
          marza  with _vpc-kalk_pripr->nc   // mora se uzeti nc iz ove stavke
    endif
    replace  mkonto with _mkonto,;
             tmarza  with _tmarza,;
             mpc     with  _MPC,;
             mu_i with  _mu_i,;
             pkonto with _pkonto,;
             pu_i with  _pu_i ,;
             error with "0"
  endif
  skip
 enddo
 go nRRec
endif

set key K_ALT_K to
return lastkey()



/*! \fn StKalk95()
 *  \brief Stampa kalkulacija tipa 16,95,96,97
 */

function StKalk95()

local nCol1:=nCol2:=0
local nPom:=0, nLijevo:=8

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
B_ON; I_ON
?? space(nLijevo), "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,"  Datum:",DatDok
B_OFF; I_OFF

P_COND
@ prow()+1,125 SAY "Str:"+str(++nStr,3)

select PARTN; HSEEK cIdPartner

if cidvd=="16"  // doprema robe
 select konto; hseek cidkonto
 P_10CPI; B_ON
 ?
 ? space(nLijevo),"PRIJEM U MAGACIN"
 ?
 ? space(nLijevo),"KONTO zaduzuje:",cIdKonto,"-",naz
 B_OFF
elseif cidvd$"96#97"
 P_10CPI; B_ON
 ?
 if cIdVd=="96"
   ? space(nLijevo),"OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
 else
   ? space(nLijevo),"PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
 endif
 ?
 if cidvd$"96#97"  // otprema iz magacina
  select konto; hseek cidkonto2
  ?  space(nLijevo),"KONTO razduzuje :",cIdKonto2,"-",naz

  select konto; hseek cidkonto
  B_OFF
  ?  space(nLijevo),"KONTO zaduzuje  :",cIdKonto,"-",naz
 endif
 B_OFF
elseif cidvd=="95"
 P_10CPI; B_ON
 ?
 ? space(nLijevo),"OTPIS MAGACIN"
 if (!EMPTY(cIdPartner) .and. IsVindija())
    B_OFF
    ?? " -", RTRIM(cIdPartner), "("+PADR(partn->naz, 20)+")"
    B_ON
 endif
 ?
  select konto; hseek cidkonto2
 ? space(nLijevo),"KONTO razduzuje:",cIdKonto2,"-",naz
 B_OFF
endif

///?  "PARTNER:",cIdPartner,"-",naz,SPACE(5),

? space(nLijevo),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

 if !empty(kalk_pripr->idzaduz2)
    B_ON
    ?? "      RAD.NALOG:",kalk_pripr->idzaduz2
    B_OFF
 endif

P_COND

select kalk_pripr
select koncij; seek trim(kalk_pripr->mkonto);select kalk_pripr

m:="--- ------------------------- ---------- ----------- ----------"
if !IsMagPNab()
 m+=" ---------- ---------- --------- ---------- ----------"
else  // nabavne cijene
 nLijevo+=2
 P_10CPI
endif
?
?
? space(nLijevo),m
? space(nLijevo),"*R * ARTIKAL                 * Kolicina *  NABAV.  *    NV    *"
if !IsMagPNab()
  if koncij->naz=="P1"
    ?? "   MARZA   *  MARZA  *   Iznos  *  Prod.C *  Prod.Vr *"
  elseif koncij->naz=="P2"
    ?? "   MARZA   *  MARZA  *   Iznos  *  Plan.C *  Plan.Vr *"
  else
    ?? "    RUC    *   RUC   *   Iznos  *   VPC   *   VPV    *"
  endif
endif
? space(nLijevo),"*BR*                         *          *  CJENA   *          *"
if !IsMagPNab()
  if koncij->naz=="P1"
   ?? "     %     *         *    marze *         *          *"
  else
   ?? "     %     *         *     RUC  *         *          *"
  endif
endif
? space(nLijevo),m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
if (!empty(idkonto2) .and. !empty(Idkonto)) .and. idvd $ "16"
  cidkont:=idkonto
  cIdkont2:=idkonto2
  nProlaza:=2
else
  cidkont:=idkonto
  nProlaza:=1
endif

select kalk_pripr
nC1:=30
nRec:=recno()
unTot:=unTot1:=unTot2:=unTot3:=unTot4:=unTot5:=unTot6:=unTot7:=unTot8:=unTot9:=unTotA:=unTotb:=0

for i:=1 to nprolaza
nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
go nRec
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    if cIdVd $ "97" .and. tbanktr=="X"
      skip 1; loop
    endif

    if empty(cidkonto2)
     if idpartner+brfaktp+idkonto+idkonto2<>cidd
      set device to screen
      Beep(2)
      Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
      set device to printer
     endif
    else
      if (i==1 .and. left(idkonto2,3)<>"XXX") .or. ;
         (i==2 .and. left(idkonto2,3)=="XXX")
         // nastavi
      else
         skip; loop
      endif
    endif

    select ROBA; HSEEK kalk_pripr->IdRoba
    select TARIFA; HSEEK kalk_pripr->IdTarifa
    select kalk_pripr
    KTroskovi()

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

    SKol:=Kolicina

    nTot4+=  (nU4:=ROUND(NC*Kolicina    , gZaokr))  // nv
    nTot5+=  (nU5:=ROUND(nMarza*Kolicina, gZaokr)) // ruc
    nTot8+=  (nU8:=ROUND(VPC*Kolicina   , gZaokr))

    @ prow()+1,1+nLijevo SAY  Rbr PICTURE "999"
    @ prow(),5+nLijevo SAY  ""; ?? trim(LEFT(ROBA->naz,40))+"("+ROBA->jmj+")"
    if roba->(fieldpos("KATBR"))<>0
       ?? " KATBR:", roba->katbr
    endif
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,5+nLijevo SAY IdRoba
    @ prow(),31+nLijevo SAY Kolicina  PICTURE PicKol
    nC1:=pcol()+1
    @ prow(),pcol()+1   SAY NC                          PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nU4  pict picdem
    if !IsMagPNab()
     @ prow(),pcol()+1 SAY IF(NC==0,0,nMarza/NC*100)    PICTURE PicProc
     @ prow(),pcol()+1 SAY nmarza pict picdem
     @ prow(),pcol()+1 SAY nu5   pict picdem
     @ prow(),pcol()+1 SAY VPC                  PICTURE PiccDEM
     @ prow(),pcol()+1 SAY nu8  pict picdem
    endif
    skip

enddo

 if nprolaza==2
   ? space(nLijevo),m
   ? space(nLijevo),"Konto "
   if i==1
     ?? cidkont
   else
     ?? cidkont2
   endif
   @ prow(),nc1      SAY 0  pict "@Z "+picdem
   @ prow(),pcol()+1 SAY nTot4  pict picdem

   if !IsMagPNab()
    @ prow(),pcol()+1 SAY 0  pict "@Z "+picdem
    @ prow(),pcol()+1 SAY 0  pict "@Z "+picdem
    @ prow(),pcol()+1 SAY ntot5  pict picdem
    @ prow(),pcol()+1 SAY 0  pict "@Z "+picdem
    @ prow(),pcol()+1 SAY ntot8  pict picdem
   endif
   ? space(nLijevo),m
 endif
 unTot4+=nTot4
 unTot5+=nTot5
 unTot8+=nTot8
next

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? space(nLijevo),m
@ prow()+1,1+nLijevo        SAY "Ukupno:"
@ prow(),nc1      SAY 0  pict "@Z "+picdem
@ prow(),pcol()+1 SAY unTot4  pict picdem
if !IsMagPNab()
 @ prow(),pcol()+1 SAY 0  pict "@Z "+picdem
 @ prow(),pcol()+1 SAY 0  pict "@Z "+picdem
 @ prow(),pcol()+1 SAY untot5  pict picdem
 @ prow(),pcol()+1 SAY 0  pict "@Z "+picdem
 @ prow(),pcol()+1 SAY untot8  pict picdem
endif
? space(nLijevo),m

if cidvd $ "95#96" .and. !empty(cidkonto)
 ?
 P_COND
 ? space(nLijevo+10),"Napomena: ovaj dokument ima SAMO efekat razduzenja ",cidkonto2
 ? space(nLijevo+10),"Ako zelite izvrsiti zaduzenje na ",cidkonto, "obradite odgovarajuci dokument tipa 16"
endif
return


function RadNalOK()
local nArr
local lOK
local nLenBrDok
if (!IsRamaGlas())
    return .t.
endif
nArr:=SELECT()
lOK:=.t.
nLenBrDok:=LEN(_idZaduz2)
select rnal
hseek PADR(_idZaduz2,10)
if !found()
    MsgBeep("Unijeli ste nepostojeci broj radnog naloga. Otvaram sifrarnik radnih##naloga da biste mogli izabrati neki od postojecih!")
    P_Rnal(@_idZaduz2,8,60)
    _idZaduz2:=PADR(_idZaduz2,nLenBrDok)
    ShowGets()
endif
SELECT (nArr)
return lOK

