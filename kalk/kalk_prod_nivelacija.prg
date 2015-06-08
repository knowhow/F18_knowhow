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
local _h_dok
local _rec

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

if !( cIdvd $ "11#81" ) .and. !EMPTY( gMetodaNC )
	close all
	return
endif

private cBrNiv := "0"

select kalk
seek cIdFirma + "19" + CHR(254)
skip -1

if idvd<>"19"
     cBrNiv := space(8)
else
     cBrNiv := brdok
endif
           
  
select kalk_pripr

_h_dok["idfirma"] := gFirma
_h_dok["idvd"]   := "19"
_h_dok["brdok"]  := ""
_h_dok["datdok"] := DATE()
cBrNiv := kalk_novi_broj_dokumenta(_h_dok, kalk_pripr->idkonto) 

select kalk_pripr
go top
private nRBr := 0
cPromjCj := "D"
fNivelacija := .f.

do while !EOF() .and. cIdFirma == idfirma .and. cIdvd == idvd .and. cBrdok == brdok

    _rec := dbf_get_rec()

    scatter()

  	select koncij
	seek TRIM( _rec["idkonto"] )

  	select roba
	hseek _rec["idroba"]

  	select tarifa
	hseek roba->idtarifa

  	select roba

  	private nMPC := 0
  	nMPC := UzmiMPCSif()
  
    if gCijene = "2"
   		faktMPC( @nMPC, _rec["idfirma"] + _rec["pkonto"] + _rec["idroba"] )
   		select kalk_pripr
  	endif

  	if _rec["mpcsapp"] <> nMPC 
        // izvrsiti nivelaciju

        if !fNivelacija   
            // prva stavka za nivelaciju
            cPromCj := Pitanje(,"Postoje promjene cijena. Staviti nove cijene u sifrarnik ?","D")
        endif
        fNivelacija:=.t.

        private nKolZn := nKols := nc1 := nc2 := 0
        private dDatNab := CTOD("")

        KalkNabP( _rec["idfirma"], _rec["idroba"], _rec["idkonto"], @nKolS, @nKolZN, @nc1, @nc2, @dDatNab )
        
        if dDatNab > _rec["datdok"]
            Beep(1)
            Msg( "Datum nabavke je " + DTOC( dDatNab ), 4 )
            _rec["error"] := "1"
        endif

        select kalk_pripr2
        //append blank

        _rec["idpartner"] := ""
        _rec["vpc"]:=0
        _rec["gkolicina"] := 0
        _rec["gkolicin2"] := 0
        _rec["marza2"] := 0
        _rec["tmarza2"] := "A"
            
        private cOsn := "2", nStCj := nNCJ := 0

        nStCj := nMPC

        nNCJ := kalk_pripr->MPCSaPP

        _rec["mpcsapp"] := nNCj - nStCj
        _rec["mpc"] := 0
        _rec["fcj"] := nStCj

        if _rec["mpc"] <> 0
            _rec["mpcsapp"] := (1 + tarifa->opp/100) * _rec["mpc"] * ( 1 + tarifa->ppp/100 )
        else
            _rec["mpc"] := _rec["mpcsapp"] / ( 1 + tarifa->opp/100) / ( 1 + tarifa->ppp/100 )
        endif

        if cPromCj == "D"
            select koncij
            seek TRIM( _rec["idkonto"] ) 
            select roba
            StaviMPCSif( _rec["fcj"] + _rec["mpcsapp"] ) 
        endif

        select kalk_pripr2

        _rec["pkonto"] := _rec["idkonto"]
        _rec["pu_i"] := "3"     
        _rec["mkonto"] := ""
        _rec["mu_i"] := ""

        _rec["kolicina"] := nKolS
        _rec["brdok"] := cBrniv
        _rec["idvd"] := "19"

        _rec["tbanktr"] := "X"    
        _rec["error"] := ""
    
        if ROUND( _rec["kolicina"], 3 ) <> 0
            append ncnl
            _rec["rbr"] := STR( ++ nRbr, 3 )
            dbf_update_rec( _rec ) 
        endif
  
    endif

    select kalk_pripr
    skip

enddo

close all
return




