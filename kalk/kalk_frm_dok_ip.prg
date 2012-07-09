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


function IP()

O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA

Box(,4,50)

    cIdFirma := gFirma
    cIdkonto := padr("1320",7)
    dDatDok := date()
    cNulirati := "N"

    @ m_x+1,m_Y+2 SAY "Prodavnica:" GET  cidkonto valid P_Konto(@cidkonto)
    @ m_x+2,m_Y+2 SAY "Datum     :  " GET  dDatDok
    @ m_x+3,m_Y+2 SAY "Nulirati lager (D/N)" GET cNulirati VALID cNulirati $ "DN" PICT "@!"

    read
    ESC_BCR

BoxC()

O_KONCIJ
O_KALK_PRIPR
O_KALK

private cBrDok := SljBroj( cidfirma, "IP", 8 )

nRbr := 0

set order to tag "4"

MsgO("Generacija dokumenta IP - "+cbrdok)

select koncij
seek trim(cidkonto)
select kalk

hseek cidfirma+cidkonto

do while !eof() .and. cidfirma+cidkonto==idfirma+pkonto

    cIdRoba:=Idroba
    nUlaz:=nIzlaz:=0
    nMPVU:=nMPVI:=nNVU:=nNVI:=0
    nRabat:=0
    
    select roba
    hseek cidroba
    
    select kalk
    
    do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

        if ddatdok<datdok  // preskoci
            skip
            loop
        endif
    
        if roba->tip $ "UT"
            skip
            loop
        endif

        if pu_i=="1"
            nUlaz+=kolicina-GKolicina-GKolicin2
            nMPVU+=mpcsapp*kolicina
            nNVU+=nc*kolicina

        elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
            nIzlaz+=kolicina
            nMPVI+=mpcsapp*kolicina
            nNVI+=nc*kolicina

        elseif pu_i=="5"  .and. (idvd $ "12#13#22")    
            // povrat
            nUlaz-=kolicina
            nMPVU-=mpcsapp*kolicina
            nNvu-=nc*kolicina

        elseif pu_i=="3"    // nivelacija
            nMPVU+=mpcsapp*kolicina

        elseif pu_i=="I"
            nIzlaz+=gkolicin2
            nMPVI+=mpcsapp*gkolicin2
            nNVI+=nc*gkolicin2
        endif
        skip
    enddo

    if (round(nulaz-nizlaz,4)<>0) .or. (round(nmpvu-nmpvi,4)<>0)
        select roba
        hseek cidroba
        select kalk_pripr
        scatter()
        append ncnl
        _idfirma:=cidfirma; _idkonto:=cidkonto; _pkonto:=cidkonto; _pu_i:="I"
        _idroba:=cidroba; _idtarifa:=roba->idtarifa
        _idvd:="IP"; _brdok:=cbrdok

        _rbr:=RedniBroj(++nrbr)
        _kolicina:=_gkolicina:=nUlaz-nIzlaz
        if cNulirati == "D"
            _kolicina := 0
        endif
        _datdok:=_DatFaktP:=ddatdok
        _ERROR:=""
        _fcj:=nmpvu-nmpvi // stanje mpvsapp
        if round(nulaz-nizlaz,4)<>0
            _mpcsapp:=round((nMPVU-nMPVI)/(nulaz-nizlaz),3)
            _nc:=round((nnvu-nnvi)/(nulaz-nizlaz),3)
        else
            _mpcsapp:=0
        endif
        Gather2()
        select kalk
    endif

enddo

MsgC()

close all
return


// ---------------------------------------------------------------------------
// inventurno stanje artikla 
// ---------------------------------------------------------------------------
function kalk_ip_roba( id_konto, id_roba, dat_dok, kolicina, nc, fc, mpcsapp )
local _t_area := SELECT()
local _ulaz, _izlaz, _mpvu, _mpvi, _rabat, _nvu, _nvi

_ulaz := 0
_izlaz := 0
_mpvu := 0
_mpvi := 0
_rabat := 0
_nvu := 0
_nvi := 0

kolicina := 0
nc := 0
fc := 0
mpcsapp := 0

select roba
hseek id_roba

if roba->tip $ "UI"
    select ( _t_area )
    return
endif

select kalk
set order to tag "4"
hseek gFirma + id_konto + id_roba 

do while !EOF() .and. field->idfirma == gFirma .and. field->pkonto == id_konto .and. field->idroba == id_roba

    if dat_dok < field->datdok  
        // preskoci
        skip
        loop
    endif
    
    if field->pu_i == "1"
        _ulaz += field->kolicina - field->gkolicina - field->gkolicin2
        _mpvu += field->mpcsapp * field->kolicina
        _nvu += field->nc * field->kolicina

    elseif field->pu_i == "5" .and. !( field->idvd $ "12#13#22" )
        _izlaz += field->kolicina
        _mpvi += field->mpcsapp * field->kolicina
        _nvi += field->nc * field->kolicina

    elseif field->pu_i == "5" .and. ( field->idvd $ "12#13#22" )      
        // povrat
        _ulaz -= field->kolicina
        _mpvu -= field->mpcsapp * field->kolicina
        _nvu -= field->nc * field->kolicina

    elseif field->pu_i == "3"   
        // nivelacija
        _mpvu += field->mpcsapp * field->kolicina

    elseif field->pu_i == "I"
        _izlaz += field->gkolicin2
        _mpvi += field->mpcsapp * field->gkolicin2
        _nvi += field->nc * field->gkolicin2
    endif
    
    skip

enddo
 

if ROUND( _ulaz - _izlaz, 4 ) <> 0
    kolicina := _ulaz - _izlaz
    fcj := _mpvu - _mpvi 
    mpcsapp := ROUND( ( _mpvu - _mpvi ) / ( _ulaz - _izlaz ), 3 )
    nc := ROUND( ( _nvu - _nvi ) / ( _ulaz - _izlaz ), 3 )
endif
 
return




// generacija inventure - razlike postojece inventure
function gen_ip_razlika()

O_KONTO

Box(,4,50)
	cIdFirma:=gFirma
	cIdkonto:=padr("1320",7)
	dDatDok:=date()
	cOldBrDok:=SPACE(8)
	cIdVd := "IP"
	@ m_x+1,m_Y+2 SAY "Prodavnica:" GET cIdKonto valid P_Konto(@cIdKonto)
	@ m_x+2,m_Y+2 SAY "Datum do  :" GET dDatDok
	@ m_x+3,m_y+2 SAY "Dokument " + cIdFirma + "-" + cIdVd GET cOldBrDok
	read
	ESC_BCR
BoxC()

if Pitanje(,"Generisati inventuru (D/N)","D") == "N"
	return
endif

// prvo izvuci postojecu inventuru u PRIPT
if cp_dok_pript(cIdFirma, cIdVd, cOldBrDok) == 0
	return
endif

O_TARIFA
O_SIFK
O_SIFV
O_ROBA
O_KONCIJ
O_kalk_pripr
O_PRIPT
O_KALK

private cBrDok:=SljBroj(cIdFirma, "IP", 8)

nRbr := 0
set order to tag "4"

MsgO("Generacija dokumenta IP - " + cBrDok)

select koncij
seek trim(cIdKonto)
select kalk
hseek cIdFirma + cIdKonto
do while !eof() .and. cIdFirma + cIdKonto == idfirma + pkonto
	cIdRoba:=Idroba
	
	select pript
	set order to tag "2"
	hseek cIdFirma+"IP"+cOldBrDok+cIdRoba
	
	// ako nadjes dokument u pript prekoci ga u INVENTURI!!!	
	if Found()
		select kalk
		skip
		loop
	endif
	
	nUlaz:=nIzlaz:=0
	nMPVU:=nMPVI:=nNVU:=nNVI:=0
	nRabat:=0
	select roba
	hseek cidroba
	select kalk
	do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba
		if ddatdok<datdok  // preskoci
      			skip
      			loop
  		endif
  		if roba->tip $ "UT"
      			skip
      			loop
  		endif
		
		if pu_i=="1"
    			nUlaz+=kolicina-GKolicina-GKolicin2
    			nMPVU+=mpcsapp*kolicina
    			nNVU+=nc*kolicina
  		elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    			nIzlaz+=kolicina
    			nMPVI+=mpcsapp*kolicina
    			nNVI+=nc*kolicina
  		elseif pu_i=="5"  .and. (idvd $ "12#13#22")    
    			// povrat
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

	if (round(nulaz-nizlaz,4)<>0) .or. (round(nmpvu-nmpvi,4)<>0)
		select roba
		hseek cidroba
 		select kalk_pripr
 		scatter()
 		append ncnl
 		_idfirma:=cidfirma
		_idkonto:=cidkonto
		_pkonto:=cidkonto
		_pu_i:="I"
 		_idroba:=cidroba
		_idtarifa:=roba->idtarifa
 		_idvd:="IP"
		_brdok:=cbrdok
		_rbr:=RedniBroj(++nrbr)
		// kolicinu odmah setuj na 0
		_kolicina:=0
		// popisana kolicina je trenutno stanje
		_gkolicina:=nUlaz-nIzlaz
		_datdok:=_DatFaktP:=ddatdok
		_ERROR:=""
		_fcj:=nmpvu-nmpvi // stanje mpvsapp
 		if round(nulaz-nizlaz,4)<>0
  			_mpcsapp:=round((nMPVU-nMPVI)/(nulaz-nizlaz),3)
  			_nc:=round((nnvu-nnvi)/(nulaz-nizlaz),3)
 		else
  			_mpcsapp:=0
 		endif
 		Gather2()
 		select kalk
	endif
enddo
MsgC()

closeret
return




// ---------------------------------------
// forma za unos dokument
// ---------------------------------------
function Get1_IP()
local nFaktVPC
local _x := 8
local _pos_x, _pos_y
local _left := 25
private aPorezi := {}

_datfaktp := _datdok
_datkurs := _datfaktp

@ m_x + _x, m_y + 2 SAY "Konto koji zaduzuje" GET _IdKonto ;
    VALID P_Konto( @_IdKonto, _x, 35 ) pict "@!"
 
if gNW <> "X"
   @ m_x + _x, m_y + 35 SAY "Zaduzuje: " GET _idzaduz PICT "@!" ;
        VALID EMPTY( _idzaduz ) .or. P_Firma( @_idzaduz, _x, 35 )
endif
 
read
ESC_RETURN K_ESC

++ _x
++ _x

_pos_x := m_x + _x

if lKoristitiBK
    @ m_x + _x, m_y + 2 SAY "Artikal  " GET _idroba PICT "@!S10" ;
        WHEN {|| _idroba := PADR( _idroba, VAL( gDuzSifIni ) ), .t. } ;
        VALID {|| vroba( .f. ), ispisi_naziv_sifre( F_ROBA, _idroba, _pos_x, 25, 40 ), .t.  }
else
    @ m_x + _x, m_y + 2 SAY "Artikal  " GET _idroba PICT "@!" ;
        VALID {|| vroba( .f. ), ispisi_naziv_sifre( F_ROBA, _idroba, _pos_x, 25, 40 ), .t.  }
endif

@ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _idtarifa ;
    WHEN gPromTar == "N" VALID P_Tarifa( @_idtarifa )

read

ESC_RETURN K_ESC

if lKoristitiBK
    _idroba := LEFT( _idroba, 10 )
endif

// proracunava knjizno stanje robe na prodavnici
// kada je dokument prenesen iz tops-a onda ovo ne bi trebalo da radi 
if !EMPTY( gMetodaNC ) .and. _nc = 0 .and. _mpcsapp = 0
    knjizst()
endif

select tarifa
hseek _idtarifa  

select kalk_pripr  

// provjeri duplu robu...
DuplRoba()

++ _x
++ _x
 
@ m_x + _x, m_y + 2 SAY PADL( "KNJIZNA KOLICINA:", _left ) GET _gkolicina PICT PicKol  ;
    WHEN {|| iif( gMetodaNC == " ", .t., .f. ) }

@ m_x + _x, col() + 2 SAY "POPISANA KOLICINA:" GET _kolicina VALID VKol() PICT PicKol

if IsPDV()
    _tmp := "P.CIJENA (SA PDV):"
else
    _tmp := " CIJENA (MPCSAPP):"
endif

++ _x
++ _x
@ m_x + _x, m_y + 2 SAY PADL( "NABAVNA CIJENA:", _left ) GET _nc PICT picdem

++ _x
++ _x
@ m_x + _x, m_y + 2 SAY PADL( _tmp, _left ) GET _mpcsapp PICT picdem 

read

ESC_RETURN K_ESC

// _fcj - knjizna prodajna vrijednost
// _fcj3 - knjizna nabavna vrijednost

_gkolicin2 := _gkolicina - _kolicina   

// ovo je kolicina izlaza koja nije proknjizena
_mkonto := ""
_pkonto := _idkonto

_mu_i := ""     
_pu_i := "I"
// inventura

nStrana := 3

return lastkey()




static function VKol()
local lMoze := .t.

if ( glZabraniVisakIP )
	if ( _kolicina > _gkolicina )
		MsgBeep("Ne dozvoljavam evidentiranje viska na ovaj nacin!")
		lMoze := .f.
	endif
endif

return lMoze


