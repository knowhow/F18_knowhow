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

// ---------------------------------------------------------------------
// automatsko formiranje nivelacije na osnovu ulaznog dokumenta
// ---------------------------------------------------------------------
function Niv_11()
local _sufix

O_TARIFA
O_KONCIJ
O_KALK_PRIPR2
O_KALK_PRIPR
O_KALK_DOKS
O_KALK
O_SIFK
O_SIFV
O_ROBA

select kalk_pripr
go top

private cIdFirma := field->idfirma
private cIdVD := field->idvd
private cBrDok := field->brdok

if !( cIdvd $ "11#81" ) .and. !empty( gMetodaNC )
	close all
	return
endif

private cBrNiv := "0"

select kalk
seek cIdFirma + "19" + CHR(254)
skip -1
if idvd<>"19"
     cBrNiv:=space(8)
else
     cBrNiv:=brdok
endif
                
_sufix := SufBrKalk( kalk_pripr->idkonto )
select kalk_pripr

cBrNiv := SljBrKalk( "19", gFirma, _sufix )
// cBrNiv := UBrojDok(val(left(cBrNiv,5))+1,5,right(cBrNiv,3))

select kalk_pripr
go top
private nRBr := 0
cPromjCj := "D"
fNivelacija := .f.
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  	scatter()
  	select koncij
	seek trim(_idkonto)
  	select roba
	hseek _idroba
  	select tarifa
	hseek roba->idtarifa
  	select roba

  	private nMPC:=0
  	nMPC:=UzmiMPCSif()
  	if gCijene="2"
   		/////// utvrdjivanje fakticke mpc
   		faktMPC(@nMPC,_idfirma+_pkonto+_idroba)
   		select kalk_pripr
  	endif

  	if _mpcsapp<>nMPC // izvrsiti nivelaciju

   if !fNivelacija   // prva stavka za nivelaciju
     cPromCj:=Pitanje(,"Postoje promjene cijena. Staviti nove cijene u sifrarnik ?","D")
   endif
   fNivelacija:=.t.

   private nKolZn:=nKols:=nc1:=nc2:=0,dDatNab:=ctod("")
   KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab)
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);_ERROR:="1";endif

   select kalk_pripr2
   //append blank

   _idpartner:=""
   _VPC:=0
   _GKolicina:=_GKolicin2:=0
   _Marza2:=0; _TMarza2:="A"
    private cOsn:="2",nStCj:=nNCJ:=0

    nStCj:=nMPC

    nNCJ:=kalk_pripr->MPCSaPP

    _MPCSaPP:=nNCj-nStCj
    _MPC:=0
    _fcj:=nStCj

    if _mpc<>0
      _MPCSaPP:=(1+TARIFA->Opp/100)*_MPC*(1+TARIFA->PPP/100)
    else
      _mpc:=_mpcsapp/(1+TARIFA->Opp/100)/(1+TARIFA->PPP/100)
    endif

    if cPromCj=="D"
     select koncij; seek trim(_idkonto)
     select roba
     StaviMPCSif(_fcj+_mpcsapp)
    endif
    select kalk_pripr2

    _PKonto:=_Idkonto;_PU_I:="3"     // nivelacija
    _MKonto:="";      _MU_I:=""

    _kolicina:=nKolS
    _brdok:=cBrniv
    _idvd:="19"

    _TBankTr:="X"    // izgenerisani dokument
    _ERROR:=""
    if round(_kolicina,3)<>0
     append ncnl
     _rbr:=str(++nRbr,3)
     gather2()
    endif
  endif

  select kalk_pripr;  skip

enddo
closeret
return
*}


