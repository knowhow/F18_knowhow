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

// ------------------------------------------------------------
// prijem prodavnica, predispozicija
// ------------------------------------------------------------
function Get1_80( atrib )
local _x := 5
local _kord_x := 0
local _unos_left := 40
private aPorezi := {}
private fMarza := " "

if nRbr == 1 .and. fnovi
    _DatFaktP := _datdok
endif

if nRbr == 1 .or. !fnovi
    
    _kord_x := m_x + _x

    @ m_x + _x, m_y + 2 SAY "Temeljnica:" GET _BrFaktP
    @ m_x + _x, col() + 1 SAY "Datum:" GET _DatFaktP

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Konto zaduzuje/razduzuje:" GET _IdKonto VALID {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x - 1, 40, 20 ) } PICT "@!"

    if gNW <> "X"
        @ m_x + _x, m_y + 50  SAY "Partner zaduzuje:" GET _IdZaduz PICT "@!" VALID EMPTY(_idZaduz) .or. P_Firma( @_IdZaduz )
    endif

    ++ _x
    _kord_x := m_x + _x

    @ m_x + _x, m_y + 2 SAY "Prenos na konto:" GET _IdKonto2 VALID {|| EMPTY( _idkonto2 ) .or. P_Konto( @_IdKonto2 ), ispisi_naziv_sifre( F_KONTO, _idkonto2, _kord_x, 30, 20 )  } PICT "@!"

    if gNW<>"X"
        @ m_x + _x, m_y + 50 SAY "Partner zaduzuje:" GET _IdZaduz2 PICT "@!" VALID EMPTY(_idZaduz) .or. P_Firma( @_IdZaduz2 )
    endif

    read

    ESC_RETURN K_ESC


else

    @ m_x + _x, m_y + 2 SAY "Temeljnica: "
    ?? _BrFaktP
    @ m_x + _x, col() + 2 SAY "Datum: "
    ?? _DatFaktP
    
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Konto zaduzuje/razduzuje: "
    ?? _IdKonto
    if gNW <> "X"
        @ m_x + _x, col() + 2  SAY "Partner zaduzuje: "
        ?? _IdZaduz
    endif
    
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Prenos na konto: "
    ?? _IdKonto2
    if gNW <> "X"
        @ m_x + _x, col() + 2 SAY "Partner zaduzuje: "
        ?? _IdZaduz2
    endif
    
    read
    ESC_RETURN K_ESC

endif

select kalk_pripr

++ _x
++ _x

_kord_x := m_x + _x

if lKoristitiBK
    @ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba PICT "@!S10" ;
        WHEN {|| _IdRoba := PADR( _idroba, VAL( gDuzSifIni ) ), .t. } ;
        VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ) }
else
    @ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba PICT "@!" ;
        VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ) }
endif

@ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _IdTarifa ;
    WHEN gPromTar == "N" VALID P_Tarifa( @_IdTarifa )

VTPorezi()

++ _x
@ m_x + _x, m_y + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

read
ESC_RETURN K_ESC

if lKoristitiBK
    _idRoba := LEFT( _idRoba, 10 )
endif

select roba
hseek _idroba

select tarifa
seek roba->idtarifa

select koncij
seek trim( _idkonto )

select kalk_pripr  

_pkonto := _idkonto

DatPosljP()
DuplRoba()

if fNovi

    select koncij
    seek TRIM( _idkonto )

    select roba
    HSEEK _idroba

    _mpcsapp := UzmiMPCSif()

    _TMarza2 := "%"
    _TCarDaz := "%"
    _CarDaz := 0

endif

select kalk_pripr

// NC

++ _x
++ _x

_kord_x := m_x + _x

@ m_x + _x, m_y + 2 SAY "NABAVNA CJENA:"
@ m_x + _x, m_y + _unos_left GET _nc WHEN VKol( _kord_x - 2 ) PICT PicDEM 

++ _x
@ m_x + _x, m_y + 2 SAY "MARZA:" GET _TMarza2 VALID _Tmarza2 $ "%AU" PICT "@!"
@ m_x + _x, m_y + _unos_left GET _Marza2 PICT PicDEM VALID {|| _vpc := _nc, .t. }       
@ m_x + _x, col() + 1 GET fMarza PICT "@!"

++ _x
@ m_x + _x, m_y + 2 SAY "MALOPROD. CIJENA (MPC):"
@ m_x + _x, m_y + _unos_left GET _mpc ;
    PICT PicDEM;
    WHEN W_MPC_( "80", ( fMarza == "F" ), @aPorezi ) ;
    VALID V_Mpc_( "80", ( fMarza == "F" ), @aPorezi )

++ _x
SayPorezi_lv( _x, aPorezi )

++ _x
if IsPDV()
    @ m_x + _x, m_y + 2 SAY "PC SA PDV:"
else
    @ m_x + _x, m_y + 2 SAY "MPC SA POREZOM:"
endif

@ m_x + _x, m_y + _unos_left GET _MPCSaPP PICT PicDEM VALID V_MpcSaPP_( "80", .f., @aPorezi, .t. )

read
ESC_RETURN K_ESC


select koncij
seek trim(_idkonto)

StaviMPCSif( _MpcSapp, .t. )

select kalk_pripr

_PKonto:=_Idkonto
_PU_I:="1"
_MKonto:=""
_MU_I:=""

nStrana := 3

return lastkey()




// PROTUSTAVKA 80-ka, druga strana
// _odlval nalazi se u knjiz, filuje staru vrijenost
// _odlvalb nalazi se u knjiz, filuje staru vrijenost nabavke
function Get1_80b()
local cSvedi := fetch_metric( "kalk_dok_80_predispozicija_set_cijena", my_user(), " " )
local _x := 2
local _kord_x := 0
local _unos_left := 40
private aPorezi := {}
private PicDEM := "9999999.99999999" 

fnovi := .t.

PicKol := "999999.999"

Beep(1)

@ m_x + _x, m_y + 2 SAY "PROTUSTAVKA   ( S - svedi M - mpc sifr i ' ' - ne diraj ):"
@ m_x + _x, col() + 2 GET cSvedi VALID cSvedi $ " SM" PICT "@!"

read

// zapamti zadnji unos
set_metric( "kalk_dok_80_predispozicija_set_cijena", my_user(), cSvedi )

_x := 12
_kord_x := m_x + _x 

@ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba PICT "@!" ;
    VALID {|| VRoba_lv(fNovi, @aPorezi), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 21, 20 ) }

@ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" ;
    GET _IdTarifa WHEN gPromTar == "N" VALID P_Tarifa(@_IdTarifa)

read

ESC_RETURN K_ESC

select koncij
seek trim( _idkonto )

select kalk_pripr 

_pkonto := _idkonto

DatPosljP()

private fMarza := " "

++ _x
@ m_x + _x, m_y + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

select koncij
seek TRIM( _idkonto )

select ROBA
hseek _idroba

// ako nije popunjeno
_mpcsapp := UzmiMPCSif()
_TMarza2 := "%"
_TCarDaz := "%"
_CarDaz := 0

select kalk_pripr

// NC
++ _x

_kord_x := m_x + _x

@ m_x + _x, m_y + 2 SAY "NABAVNA CIJENA:"
@ m_x + _x, m_y + _unos_left GET _NC PICT PicDEM when VKol( _kord_x )

// MARZA
++ _x
@ m_x + _x, m_y + 2 SAY "MARZA:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICT "@!"
@ m_x + _x, m_y + _unos_left  GET _Marza2 PICT PicDEM valid {|| _vpc:=_nc, .t.}
@ m_x + _x, col() + 1 GET fMarza pict "@!"

++ _x
if IsPDV()
    @ m_x + _x, m_y + 2  SAY "PROD.CIJENA BEZ PDV:"
else
    @ m_x + _x, m_y + 2  SAY "MALOPROD. CJENA (MPC):"
endif

@ m_x + _x, m_y + _unos_left GET _mpc PICT PicDEM ;
    WHEN WMpc_lv(nil, nil, aPorezi) ;
    VALID VMpc_lv(nil, nil, aPorezi)
           
++ _x

SayPorezi_lv( _x, aPorezi)

++ _x

if IsPDV()
    @ m_x + _x, m_y+2 SAY "P.CIJENA SA PDV:"
else
    @ m_x + _x, m_y+2 SAY "MPC SA POREZOM:"
endif

@ m_x + _x, m_y + _unos_left GET _mpcsapp PICT PicDEM ;
     valid {|| Svedi( cSvedi ), VMpcSapp_lv( nil, nil, aPorezi ) }

read

ESC_RETURN K_ESC

select koncij
seek TRIM( _idkonto )

StaviMPCSif( _mpcsapp, .t. )

select kalk_pripr

_PKonto := _Idkonto
_PU_I := "1"
_MKonto := ""
_MU_I := ""

nStrana := 3

return lastkey()





function Svedi(cSvedi)

if cSvedi == "M"

    select koncij
    seek TRIM( _idkonto )
    select roba
    hseek _idroba
    _mpcsapp := UzmiMPCSif()
    
elseif cSvedi == "S"

    if _mpcsapp <> 0
        _kolicina := -round(_oldval/_mpcsapp,4)
    else
        _kolicina := 99999999
    endif

    if _kolicina <> 0
        _nc := abs( _oldvaln/_kolicina )
    else
        _nc := 0
   endif
endif

return .t.





/*! \fn VKol()
 *  \brief Validacija unesene kolicine u dokumentu tipa 80
 */

static function VKol( x_kord )

if _kolicina < 0  

    // storno
    //////// kalkulacija nabavne cijene
    //////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

    nKolS := 0
    nKolZN := 0

    nc1 := nc2 := 0

    dDatNab:=ctod("")

    if !EMPTY( gMetodaNC )
        MsgO("Racunam stanje u prodavnici")
        KalkNabP( _idfirma, _idroba, _idkonto, @nKolS, @nKolZN, @nc1, @nc2, @dDatNab) 
        MsgC()
        @ x_kord, m_y + 30 SAY "Ukupno na stanju "
        @ x_kord, col() + 2 SAY nKols PICT pickol
    endif

    if dDatNab > _DatDok
        Beep(1)
        Msg("Datum nabavke je "+dtoc(dDatNab),4)
    endif

    if _nc == 0
        _nc:=nc2
    endif

    if nKols < ABS( _kolicina )
        _ERROR := "1"
        Beep(2)
        Msg("Na stanju je samo kolicina:"+str(nkols,12,3))
    endif

    select kalk_pripr

endif

return .t.


