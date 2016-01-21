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



// -------------------------------------------------------------
// realizacija prodavnice  41-fakture maloprodaje
//                         42-gotovina
// -------------------------------------------------------------

function Get1_41()
pIzgSt:=.f.   
// izgenerisane stavke jos ne postoje
private aPorezi:={}

IF fNovi
    _DatFaktP:=_datdok
ENDIF

if _idvd == "41"

    @  m_x+6,  m_y+2 SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,5,30)
    @  m_x+7,  m_y+2 SAY "Faktura Broj:" get _BrFaktP
    @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP

elseif _idvd=="43"

    @  m_x+6,  m_y+2 SAY "DOBAVLJAC KOMIS.ROBE:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,5,30)

else

    _idpartner:=""
    _brfaktP:=""

endif


@ m_x+8,m_y+2   SAY "Prodavnicki Konto razduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,21,5) pict "@!"

if gNW<>"X"
    @ m_x+8,m_y+50  SAY "Razduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,21,5)
endif

_idkonto2:=""
_idzaduz2:=""

read


select kalk_pripr

ESC_RETURN K_ESC

@ m_x+10,m_y+66 SAY "Tarif.br->"

if lKoristitiBK
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba()
else
    @ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid VRoba()
endif

@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)
@ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

read
ESC_RETURN K_ESC

if lKoristitiBK
    _idRoba:=Left(_idRoba,10)
endif

select TARIFA
hseek _IdTarifa 
select koncij

seek trim(_idkonto)
select kalk_pripr  // napuni tarifu

_PKonto:=_Idkonto

// provjerava kada je radjen zadnji dokument za ovaj artikal
DatPosljK()
DatPosljP()

_GKolicina:=0
_GKolicin2:=0

if fNovi

    select koncij
    seek trim(_idkonto)
    select ROBA
    HSEEK _IdRoba
    _MPCSaPP:=UzmiMPCSif()

    if gMagacin=="2"
        _FCJ:=NC
        _VPC:=0
    else
        _FCJ:=NC
        _VPC:=0
    endif

    select kalk_pripr
    _Marza2 := 0
    _TMarza2 := "A"

endif


if IsPdv()
    if ( gCijene == "2" .and. ( _MpcSAPP == 0 .or. fNovi) )
        FaktMPC( @_MPCSAPP, _idfirma + _idkonto + _idroba )
    endif
else

    // ppp varijanta
    // ovo dole do daljnjeg ostavljamo
    if ((_idvd<>'47' ) .and. !fnovi .and. gcijene=="2" .and. roba->tip!="T" .and. _MpcSapp=0)
        // uzmi mpc sa kartice
        FaktMPC( @_MPCSAPP,_idfirma+_idkonto+_idroba )
    endif

endif

if roba->(fieldpos("PLC")) <> 0  
    // stavi plansku cijenu
    _vpc := roba->plc
endif

VtPorezi()

if ( ( _idvd<>"47" ) .and. roba->tip != "T" )

    //////// kalkulacija nabavne cijene
    //////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

    nKolS:=0
    nKolZN:=0
    nc1:=0
    nc2:=0
    dDatNab:=ctod("")
    lGenStavke:=.f.

    // ako je X onda su stavke vec izgenerisane
    if _TBankTr<>"X"  
        if !empty( gMetodaNC ) 
            nc1:=0
            nc2:=0
            MsgO("Racunam stanje u prodavnici")
            KalkNabP( _idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2)
            MsgC()
            if dDatNab > _DatDok
                Beep(1)
                Msg("Datum nabavke je "+dtoc(dDatNab),4)
            endif
            if gMetodaNC $ "13"
                _fcj := nc1
            elseif gMetodaNC=="2"
                _fcj := nc2
            endif
        endif
    endif

    @ m_x + 12, m_y + 30 SAY "Ukupno na stanju "
    @ m_x + 12, col() + 2 SAY nkols pict pickol

    @ m_x + 14, m_y + 2 SAY "NC  :" GET _fcj PICT picdem VALID {|| V_KolPro(), _tprevoz := "A", _prevoz := 0, _nc := _fcj, .t. }

    @ m_x + 15, m_y + 40 SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
    @ m_x + 15, col() + 1 GET _Marza2 PICTURE  PicDEM

endif

if IsPdv()
    @ m_x + 17, m_y + 2 SAY "PRODAJNA CJENA  (PC):"
else
    @ m_x + 17, m_y + 2 SAY "MALOPROD. CJENA (MPC):"
endif

@ m_x + 17, m_y + 50 GET _mpc PICT PicDEM WHEN W_MPC_( IdVd, .f., @aPorezi ) VALID V_Mpc_( _IdVd, .f., @aPorezi )

private cRCRP := gRCRP

@ m_x + 18, m_y + 2 SAY "POPUST (C-CIJENA,P-%)" GET cRCRP VALID cRCRP $ "CP" PICT "@!"
@ m_x + 18, m_y + 50 GET _Rabatv PICT picdem VALID RabProcToC()

SayPorezi( 19 )

if IsPDV()
    @ m_x + 20, m_y + 2 SAY "MPC SA PDV    :"
else
    @ m_x + 20, m_y + 2 SAY "MPC SA POREZOM:"
endif

@ m_x + 20, m_y + 50 GET _mpcsapp PICT PicDEM VALID V_MpcSaPP_( _IdVd, .f., @aPorezi, .t. )
         
read

ESC_RETURN K_ESC

// izlaz iz prodavnice
_PKonto := _Idkonto
_PU_I := "5"     
nStrana := 2

FillIzgStavke(pIzgSt)

return lastkey()



// ------------------------------------------
// racuna rabat za stavku...
// ------------------------------------------
static function RabProcToC()

if cRCRP == "P"
    _rabatv := _mpc * ( _rabatv / 100 )
    cRCRP := "C"
    ShowGets()
endif

return .t.


