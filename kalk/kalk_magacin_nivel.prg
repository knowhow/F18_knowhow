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


#include "f18.ch"



function Niv_10()
local nRVPC:=0

O_KONCIJ
O_KALK_PRIPR
O_KALK_PRIPR2
O_KALK
O_TARIFA
O_SIFK
O_SIFV
O_ROBA

select kalk_pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok

if !(cidvd $ "14#96#95#10#94#16") .and. !empty(gMetodaNC)
  closeret
endif

if kalk_pripr->idvd $ "14#94#96#95"
 select koncij; seek trim(kalk_pripr->idkonto2)
else
 select koncij; seek trim(kalk_pripr->idkonto)
endif
if koncij->naz $ "N1#P1#P2"
   closeret
endif

private cBrNiv:="0"
select kalk
seek cidfirma+"18�"
skip -1
if idvd<>"18"
     cBrNiv:=space(8)
else
     cBrNiv:=brdok
endif
cBrNiv:=UBrojDok(val(left(cBrNiv,5))+1,5,right(cBrNiv,3))


select kalk_pripr
go top
private nRBr:=0
fNivelacija:=.f.
cPromCj:="N"
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok

  if kalk_pripr->idvd $ "14#94#96#95"   // ako je vise konta u igri - kao 16-ka
    select koncij; seek trim(kalk_pripr->idkonto2)
  else
    select koncij; seek trim(kalk_pripr->idkonto)
  endif
  select kalk_pripr
  if koncij->naz $ "N1#P1#P2"
      skip; loop
  endif



  scatter()
  select roba; hseek _idroba
  select tarifa; hseek roba->idtarifa
  frazlika:=.f.
  nRVPC:=KoncijVPC()
  if gCijene="2"  .and. gNiv14="1"
                        // nivel.se vrsi na ukupnu kolicinu
   /////// utvrdjivanje fakticke VPC
   faktVPC(@nRVPC,_idfirma+_mkonto+_idroba)
   select kalk_pripr
  endif
  if round(_vpc,3)<>round(nRVPC,3)  // izvrsiti nivelaciju

   if !fNivelacija  .and. ; // prva stavka za nivelaciju
      !(cidvd=="14" .and. gNiv14=="2")   //minex
      cPromCj:=Pitanje(,"Postoje promjene cijena. Staviti nove cijene u sifrarnik ?","D")
   endif
   fNivelacija:=.t.

   private nKolZn:=nKols:=nc1:=nc2:=0,dDatNab:=ctod("")
   if gKolicFakt=="D"
    KalkNaF(_idroba,@nKolS) // uzmi iz FAKTA
   else
    KalkNab(_idfirma,_idroba,_mkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab)
   endif
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);_ERROR:="1";endif


   select kalk_pripr2
   //append blank


   _idpartner:=""
   _rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_nc:=_marza:=_marza2:=_mpc:=0
   _gkolicina:=_gkolicin2:=_mpc:=0
   _VPC:=kalk_pripr->vpc-nRVPC
   _MPCSAPP:=nRVPC
   _kolicina:=nKolS
   _brdok:=cBrniv
   _idkonto:=_mkonto
   _idkonto2:=""
   _MU_I:="3"     // ninvelacija
   _PKonto:="";      _PU_I:=""
   _idvd:="18"

   _TBankTr:="X"    // izgenerisani dokument
   _ERROR:=""
   if cIdVD $ "94" // storno fakture,storno otpreme - niveli{i na stornirano
     _kolicina:=kalk_pripr->kolicina
     _vpc:=nRVPC - kalk_pripr->vpc
     _mpcsapp:=kalk_pripr->vpc
     _MKonto:=_Idkonto
   endif
   if   (cidvd=="14" .and. gNiv14=="2")  // minex,
     _kolicina:=kalk_pripr->kolicina
     _MKonto:=_Idkonto
     if _kolicina<0 // radi se storno fakture
       _kolicina:=-_kolicina
       _vpc:=-_vpc
       _mpcsapp:=kalk_pripr->vpc
     endif

   endif
   if round(_kolicina,4)<>0
     _rbr:=str(++nRbr,3)
     append ncnl
     gather2()
   endif
   if cPromCj=="D"
    if cIdVD $ "10#16#14#96" ;  // samo ako je ulaz,izlaz u magacin promjeni stanje VPC u sif.robe
     .and. !(cidvd=="14" .and. gNiv14=="2")   // minex
     select roba         // promjeni stanje robe !!!!
     ObSetVPC(kalk_pripr->vpc)

    endif
   endif
  endif
  select kalk_pripr
  skip
enddo

closeret
return
*}

