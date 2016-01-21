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

static aPorezi:={}


// direktni ulaz u prodavnicu
function Get1_81( atrib )
local _x := 5
local _kord_x := 0
local _unos_left := 40
local _use_opis := .f.
local _use_rok := .f.
local _opis := SPACE(300)
local _rok := CTOD("")
local _krabat := NIL

if hb_hhaskey( atrib, "opis" )
    _use_opis := .t.
endif

if hb_hhaskey( atrib, "rok" )
    _use_rok := .t.
endif

if _use_opis
    if !fNovi 
        _opis := PADR( atrib["opis"], 300 )
    endif
endif
 
if _use_rok
    if !fNovi 
        _rok := CTOD( ALLTRIM( atrib["rok"] ) )
    endif
endif
 
__k_val := "N"

if nRbr == 1 .and. fnovi
    _datfaktp := _datdok
endif

if nRbr == 1 .or. !fnovi

    ++ _x

    _kord_x := m_x + _x

    @ m_x + _x, m_y + 2 SAY "DOBAVLJAC:" GET _IdPartner PICT "@!" VALID {|| EMPTY(_IdPartner) .or. P_Firma(@_IdPartner), ispisi_naziv_sifre( F_PARTN, _idpartner, _kord_x - 1, 22, 20) }
    @ m_x + _x, 50 SAY "Broj fakture:" GET _brfaktp
    @ m_x + _x, col() + 1 SAY "Datum:" get _datfaktp

    ++ _x
    
    _kord_x := m_x + _x

    @ m_x + _x, m_y + 2 SAY "Konto zaduzuje:" GET _idkonto VALID {|| P_Konto( @_IdKonto ), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x, 40, 30 ) } PICT "@!"

    if gNW <> "X"
        @ m_x + _x, m_y + 42 SAY "Zaduzuje: " GET _idzaduz PICT "@!" VALID EMPTY(_idzaduz) .or. P_Firma( @_idzaduz )
    endif

    read

    ESC_RETURN K_ESC

else

    ++ _x

    @ m_x + _x, m_y + 2 SAY "DOBAVLJAC: "
    ?? _idpartner
    @  m_x + _x, col() + 1 SAY "Faktura broj: "
    ?? _brfaktp
    @  m_x + _x, col() + 1 SAY "Datum: "
    ?? _datfaktp

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Konto zaduzuje: "
    ?? _idkonto

    if gNW<>"X"
        @  m_x + _x, m_y + 42 SAY "Zaduzuje: "
        ?? _idzaduz
    endif
    read
    ESC_RETURN K_ESC

endif

++ _x
++ _x
_kord_x := m_x + _x

if lKoristitiBK
    @ m_x + _x, m_y + 2 SAY "Artikal  " GET _idroba ;
        PICT "@!S10" ;
        WHEN {|| _idroba := PADR( _idroba, VAL( gDuzSifIni )), .t. } ;
        VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ), zadnji_ulazi_info( _idpartner, _idroba, "P" ) }
else
    @ m_x + _x, m_y + 2 SAY "Artikal  " GET _idroba ;
        PICT "@!"  ;
        VALID {|| VRoba_lv( fNovi, @aPorezi ), ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ), zadnji_ulazi_info( _idpartner, _idroba, "P" ) } 
endif

@ m_x + _x, m_y + ( MAXCOLS() - 20 ) SAY "Tarifa:" GET _idtarifa ;
    WHEN gPromTar == "N" ;
    VALID P_Tarifa( @_IdTarifa )

read
ESC_RETURN K_ESC

if lKoristitiBK
    _idroba := LEFT( _idroba, 10 )
endif

select tarifa
seek roba->idtarifa

select koncij
seek TRIM( _idkonto )
select kalk_pripr  

_pkonto := _idkonto
DatPosljP()

++ _x

if _use_rok
    @ m_x + _x, m_y + 2 SAY "Datum isteka roka:" GET _rok
endif

if _use_opis
    @ m_x + _x, m_y + 30 SAY "Opis:" GET _opis PICT "@S40"
endif

++ _x

@ m_x + _x, m_y + 2 SAY "Kolicina " GET _kolicina PICT PicKol VALID _kolicina <> 0

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

// FCJ

++ _x

@ m_x + _x, m_y + 2 SAY "Fakturna cijena:"

if gDokKVal == "D"
    // konverzija valute...
    @ m_x + _x, col() + 1 SAY "pr.->" GET __k_val VALID _val_konv( __k_val ) PICT "@!"
endif

@ m_x + _x, m_y + _unos_left GET _fcj ;
        PICT PicDEM ;
        VALID {|| SETKEY( K_ALT_T, { || NIL } ), _fcj > 0 } ;
        WHEN VKol()
@ m_x + _x, col() + 1 SAY "*** <ALT+T> unos ukupne FV"

// KASA-SKONTO ili RABAT

++ _x
@ m_x + _x, m_y + 2   SAY "Rabat (%):"
@ m_x + _x, m_y + _unos_left GET _rabat PICT PicDEM ;
        WHEN { || SETKEY( K_ALT_T, { || _kaskadni_rabat( @_krabat ) } ), DuplRoba() } ;
        VALID { || SETKEY( K_ALT_T, { || NIL } ), .t. }
@ m_x + _x, col() + 1 SAY "*** <ALT+T> unos kaskadnog rabata"

if gNW <> "X"
    ++ _x 
    @ m_x + _x, m_y + 2 SAY "Transport. kalo:"
    @ m_x + _x, m_y + _unos_left GET _gkolicina PICT PicKol
    ++ _x
    @ m_x + _x, m_y + 2 SAY "    Ostalo kalo:"
    @ m_x + _x, m_y + _unos_left GET _gkolicin2 PICT PicKol
endif

read

ESC_RETURN K_ESC

_fcj2 := _fcj * ( 1 - _rabat / 100 )

// setuj atribute...
if _use_opis
    atrib["opis"] := _opis
endif

if _use_rok
    atrib["rok"] := DTOC( _rok )
endif

obracun_kalkulacija_tip_81_pdv( _x )

return lastkey()



// ---------------------------------------------
// unos kaskadnog rabata
// ---------------------------------------------
static function _kaskadni_rabat( krabat )
local _r_1 := 0
local _r_2 := 0
local _r_3 := 0
local _r_4 := 0
local _ok := .t.
private GetList := {}

Box(, 8, 50 )
    @ m_x + 1, m_y + 2 SAY "Unos kaskadnog rabata:"
    @ m_x + 3, m_y + 2 SAY "Rabat 1 (%):" GET _r_1 PICT PicDem
    @ m_x + 4, m_y + 2 SAY "Rabat 2 (%):" GET _r_2 PICT PicDem
    @ m_x + 5, m_y + 2 SAY "Rabat 3 (%):" GET _r_3 PICT PicDem
    @ m_x + 6, m_y + 2 SAY "Rabat 4 (%):" GET _r_4 PICT PicDem
    READ
BoxC()

if LastKey() == K_ESC
    return _ok
endif

_rabat := ( 100 - 100 * ( 1 - _r_1 / 100 ) * ;
          IF( _r_2 > 0, ( 1 - _r_2 / 100 ), 1 ) * ;
          IF( _r_3 > 0, ( 1 - _r_3 / 100 ), 1 ) * ;
          IF( _r_4 > 0, ( 1 - _r_4 / 100 ), 1 ) ;
          )

return _ok



// ---------------------------------------------
// unos ukupne fakturne vrijednosti
// ---------------------------------------------
static function _fv_ukupno()
local _uk_fv := 0
local _ok := .t.
private GetList := {}

Box(, 1, 50 )
    @ m_x + 1, m_y + 2 SAY "Ukupna FV:" GET _uk_fv PICT PicDem
    READ
BoxC()

if LastKey() == K_ESC .or. ROUND( _uk_fv, 2 ) == 0
    return _ok
endif

_fcj := ( _uk_fv / _kolicina )

return _ok


// --------------------------------------------
// --------------------------------------------
static function VKol()

SETKEY( K_ALT_T, { || _fv_ukupno() } )

if _kolicina < 0  
    
    // storno

    //////// kalkulacija nabavne cijene
    //////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
    nKolS := 0
    nKolZN := 0
    nc1 := nc2 := 0
    dDatNab := CTOD("")

    if !empty(gMetodaNC)
        MsgO("Racunam stanje na u prodavnici")
        KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab)
        MsgC()
        @ m_x + 12, m_y + 30 SAY "Ukupno na stanju "
        @ m_x + 12, col() + 2 SAY nKols pict pickol
    endif

    if dDatNab > _DatDok
        Beep(1)
        Msg("Datum nabavke je "+dtoc(dDatNab),4)
    endif

    if nkols < abs(_kolicina)
        _ERROR:="1"
        Beep(2)
        Msg("Na stanju je samo kolicina:"+str(nkols,12,3))
    endif
    select kalk_pripr
endif

return .t.


// --------------------------------------------------------
// 81 - dokument, obracun kalkulacije
// --------------------------------------------------------
static function obracun_kalkulacija_tip_81_pdv( x_kord )
local cSPom:=" (%,A,U,R) "
local _x := x_kord + 2
local _unos_left := 40
local _kord_x
local _sa_troskovima := .t.
private getlist:={}
private fMarza:=" "

if empty(_TPrevoz)
    _TPrevoz:="%"
endif
if empty(_TCarDaz); _TCarDaz:="%"; endif
if empty(_TBankTr); _TBankTr:="%"; endif
if empty(_TSpedTr); _TSpedtr:="%"; endif
if empty(_TZavTr);  _TZavTr:="%" ; endif
if empty(_TMarza);  _TMarza:="%" ; endif

if _sa_troskovima == .t.

    // TROSKOVNIK
    @ m_x + _x, m_y + 2 SAY "Raspored troskova kalkulacije ->"
    @ m_x + _x, m_y + _unos_left SAY c10T1 + cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICT "@!"
    @ m_x + _x, col() + 2 GET _Prevoz PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left SAY c10T2 + cSPom GET _TBankTr VALID _TBankTr $ "%AUR" pict "@!"
    @ m_x + _x, col() + 2 GET _BankTr PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left SAY c10T3 + cSPom GET _TSpedTr valid _TSpedTr $ "%AUR" pict "@!"
    @ m_x + _x,col() + 2 GET _SpedTr PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left SAY c10T4 + cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICT "@!"
    @ m_x + _x, col() + 2 GET _CarDaz PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left SAY c10T5 + cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICT "@!"
    @ m_x + _x, col() + 2 GET _ZavTr PICT PicDEM ;
                    VALID {|| NabCj(), .t. }

    ++ _x
    ++ _x

endif

// NC

@ m_x + _x, m_y + 2 SAY "NABAVNA CIJENA:"
@ m_x + _x, m_y + _unos_left GET _nc PICT PicDEM

// MARZA
++ _x
@ m_x + _x, m_y + 2 SAY "MARZA:" GET _TMarza2 VALID _Tmarza2 $ "%AU" PICT "@!"
@ m_x + _x, m_y + _unos_left GET _marza2 PICT PicDEM VALID {|| _vpc := _nc, .t. }    
@ m_x + _x, col() + 1 GET fMarza PICT "@!"

// PRODAJNA CIJENA
++ _x

if IsPDV()
    @ m_x + _x, m_y + 2 SAY "PC BEZ PDV:"
else
    @ m_x + _x, m_y + 2 SAY "MALOPROD. CIJENA (MPC):"
endif

@ m_x + _x, m_y + _unos_left GET _mpc PICT PicDEM ;
     WHEN W_MPC_( "81", (fMarza == "F"), @aPorezi ) ;
     VALID V_Mpc_( "81", (fMarza=="F"), @aPorezi )

++ _x

if IsPDV()

    @ m_x + _x, m_y + 2 SAY "PDV (%):"
    @ m_x + _x, col() + 2 SAY TARIFA->OPP PICTURE "99.99"

    if glUgost
        @ m_x + _x, col() + 2 SAY "PP (%):"
        @ m_x + _x, col() + 2 SAY TARIFA->ZPP PICTURE "99.99"
    endif

else

    @ m_x + _x, m_y + 2 SAY "PPP (%):"
    @ m_x + _x, col() + 2 SAY  TARIFA->OPP PICTURE "99.99" 
    @ m_x + _x, col() + 2 SAY "PPU (%):"
    @ m_x + _x, col() + 2 SAY TARIFA->PPP PICTURE "99.99" 
    @ m_x + _x, col() + 2 SAY "PP (%):"
    @ m_x + _x, col() + 2 SAY TARIFA->ZPP PICTURE "99.99" 

endif

++ _x

if IsPDV()
    @ m_x + _x, m_y + 2 SAY "PC SA PDV:"
else
    @ m_x + _x, m_y + 2 SAY "MPC SA POREZOM:"
endif

@ m_x + _x, m_y + _unos_left GET _mpcsapp PICT PicDEM ;
    WHEN {|| fMarza := " ", _Marza2 := 0, .t. } ;
    VALID V_MpcSaPP_( "81", .f., @aPorezi, .t. )

read

ESC_RETURN K_ESC

select koncij
seek TRIM( _idkonto )

StaviMPCSif( _mpcsapp, .t. )

select kalk_pripr

_pkonto := _idkonto
_mkonto := ""
_pu_i := "1"
_mu_i := ""

nStrana := 3
return lastkey()


