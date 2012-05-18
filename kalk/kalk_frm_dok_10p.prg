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

// konverzija valute
static __k_val



// -----------------------------------------------
// unos dokumenta tip "10" - prva stranica
// -----------------------------------------------
function Get1_10PDV()
local _x := 5
local _kord_x := 0
local _unos_left := 40

gVarijanta := "2"
__k_val := "N"

if nRbr == 1 .and. fNovi
	_DatFaktP := _datdok
endif

if nRbr == 1  .or. !fNovi .or. gMagacin == "1"

    _kord_x := m_x + _x	

	@ m_x + _x, m_y + 2 SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid {|| empty(_IdPartner) .or. P_Firma( @_IdPartner ), ispisi_naziv_sifre( F_PARTN, _idpartner, _kord_x - 1, 22, 20 ), _ino_dob( _idpartner ) }
 	
	@ m_x + _x, 50 SAY "Broj fakture:" get _BrFaktP
 	
	@ m_x + _x, col() + 1 SAY "Datum:" get _DatFaktP
 	
	_DatKurs := _DatFaktP
 	
    ++ _x
    _kord_x := m_x + _x

    @ m_x + _x, m_y + 2 SAY "Magacinski Konto zaduzuje" GET _IdKonto valid {|| P_Konto( @_IdKonto), ispisi_naziv_sifre( F_KONTO, _idkonto, _kord_x, 40, 30 ) } pict "@!"
 	
    if gNW <> "X"
  		@ m_x + _x, m_y + 42  SAY "Zaduzuje: " GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma( @_IdZaduz )
 	endif

 	if !empty(cRNT1)
   		@ m_x + _x, m_y + 42  SAY "Rad.nalog:" GET _IdZaduz2  pict "@!"
 	endif

 	read

	ESC_RETURN K_ESC

else
	
	@ m_x + _x, m_y + 2 SAY "DOBAVLJAC: "
	?? _IdPartner
 	@ m_x + _x, col() + 1 SAY "Faktura dobavljaca - Broj: "
	?? _BrFaktP
 	@ m_x + _x, col() + 1 SAY "Datum: "
	?? _DatFaktP
	
    ++ _x
	@ m_x + _x, m_y + 2 SAY "Magacinski Konto zaduzuje "
    ?? _IdKonto

 	if gNW<>"X"
   		@ m_x + _x, m_y + 42 SAY "Zaduzuje: "
		?? _IdZaduz
 	endif
	
	_ino_dob( _idpartner )
	
endif

++ _x
++ _x
_kord_x := m_x + _x

if lKoristitiBK
	@ m_x + _x, m_y + 2 SAY "Artikal  " GET _IdRoba ;
		PICT "@!S10" ;
		WHEN {|| _idroba:=padr(_idroba,VAL(gDuzSifIni)),.t. } ;
		VALID {|| ;
			_idroba := iif(len(trim(_idroba))<10,left(_idroba,10),_idroba), ;
			P_Roba(@_IdRoba), ;
			ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ), ;
			_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa), ;
		.t. }
else
	@ m_x + _x, m_y + 2  SAY "Artikal  " GET _IdRoba ;
		PICT "@!" ;
		VALID {|| ;
			_idroba := iif(len(trim(_idroba))<10, left(_idroba,10), _idroba), ;
			fix_sifradob(@_idroba,5,"0"), ;
			P_Roba(@_IdRoba, nil, nil, gArtCDX ), ;
			ispisi_naziv_sifre( F_ROBA, _idroba, _kord_x, 25, 40 ), ;
			_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa), ;
		.t. }

endif

@ m_x + _x, m_y + ( MAXCOLS() - 20  ) SAY "Tarifa:" GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read

ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba := LEFT( _idRoba, 10 )
endif

select koncij
seek trim(_idkonto)
select kalk_pripr

_MKonto := _Idkonto
_MU_I := "1"
DatPosljK()

select TARIFA
hseek _IdTarifa 
select kalk_pripr  

++ _x

@ m_x + _x + IF( lPoNarudzbi, 1, 0 ), m_y + 2 SAY "Kolicina " GET _Kolicina PICT PicKol VALID _Kolicina <> 0

if fNovi
	select ROBA
	HSEEK _IdRoba
 	_VPC := KoncijVPC()
    _TCarDaz := "%"
    _CarDaz := 0
endif

select kalk_pripr

if _tmarza <> "%"  
	// procente ne diraj
	_Marza := 0
endif

if gVarEv == "1"

    ++ _x

    // FCJ
	@ m_x + _x + IF( lPoNarudzbi, 1, 0 ), m_y + 2 SAY "Fakturna cijena:"

	if gDokKVal == "D"
		@ m_x + _x, col() + 1 SAY "pr.->" GET __k_val VALID _val_konv(__k_val) PICT "@!"
	endif
	
 	@ m_x + _x + IF(lPoNarudzbi,1,0), m_y + _unos_left GET _fcj PICT gPicNC VALID {|| _fcj > 0 .and. _set_konv( @_fcj, @__k_val ) } when V_kol10()

    // KASA - SKONTO
    ++ _x
	@ m_x + _x + IF(lPoNarudzbi,1,0), m_y + 2 SAY "Rabat (%):"
 	@ m_x + _x + IF(lPoNarudzbi,1,0), m_y + _unos_left GET _Rabat PICT PicDEM when DuplRoba()

	if gNW<>"X" .or. gVodiKalo=="D"
        ++ _x
   		@ m_x + _x, m_y + 2 SAY "Normalni . kalo:"
   		@ m_x + _x, m_y + _unos_left GET _GKolicina PICTURE PicKol
        ++ _x
		@ m_x + _x, m_y + 2 SAY "Preko  kalo:    "
   		@ m_x + _x, m_y + _unos_left GET _GKolicin2 PICTURE PicKol
	endif

endif

read

ESC_RETURN K_ESC

_FCJ2 := _FCJ * (1 - _Rabat / 100 )

// obracun kalkulacije tip-a 10
obracun_kalkulacija_tip_10_pdv( _x )

return lastkey()


// --------------------------------------------------
// da li je dobavljac ino, setuje valutiranje
// --------------------------------------------------
static function _ino_dob( cPartn )

if gDokKVal == "D" .and. fNovi .and. isinodob( cPartn ) 
	__k_val := "D"
endif

return .t.



// ---------------------------------------
// validacija unosa preracuna
// ---------------------------------------
static function _val_konv( cDn )
local lRet := .t.

if cDN $ "DN"
	return lRet
else
	msgbeep("Preracun: " + valpomocna() + "=>" + valdomaca() + "#Unjeti 'D' ili 'N' !")
	lRet := .f.
	return lRet
endif

return .t.


// --------------------------------------
// konverzija fakturne cijene
// --------------------------------------
static function _set_konv( nFcj, cPretv )

if cPretv == "D"
	a_val_convert()	
	cPretv := "N"
	showgets()
endif

return .t.



// --------------------------------------------------
// unos dokumenta "10" - druga stranica
// --------------------------------------------------
static function obracun_kalkulacija_tip_10_pdv( x_kord )
local cSPom := " (%,A,U,R) "
local _x := x_kord + 4
local _unos_left := 40
local _kord_x
local _sa_troskovima := .t.
private getlist:={}

if empty( _TPrevoz )
    _TPrevoz := "%"
endif
if empty( _TCarDaz )
    _TCarDaz := "%"
endif
if empty( _TBankTr )
    _TBankTr := "%"
endif
if empty( _TSpedTr )
    _TSpedtr := "%"
endif
if empty( _TZavTr )
    _TZavTr := "%"
endif
if empty( _TMarza )
    _TMarza := "%"
endif

if _sa_troskovima 

    // automatski setuj troskove....
    _auto_set_trosk( fNovi )

    // TROSKOVNIK

    @ m_x + _x, m_y + 2 SAY "Raspored troskova kalkulacije ->"

    @ m_x + _x, m_y + _unos_left + 10 SAY c10T1+cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
    @ m_x + _x, col() + 2 GET _Prevoz PICT  PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left + 10 SAY c10T2+cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" pict "@!"
    @ m_x + _x, col() + 2 GET _BankTr PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left + 10 SAY c10T3+cSPom GET _TSpedTr valid _TSpedTr $ "%AUR" pict "@!"
    @ m_x + _x, col() + 2 GET _SpedTr PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left + 10 SAY c10T4+cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
    @ m_x + _x, col() + 2 GET _CarDaz PICT PicDEM

    ++ _x
    @ m_x + _x, m_y + _unos_left + 10 SAY c10T5+cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
    @ m_x + _x, col() + 2 GET _ZavTr PICT PicDEM VALID {|| NabCj(),.t.}

    ++ _x
    ++ _x

endif

// NC
@ m_x + _x, m_y + 2 SAY "NABAVNA CJENA:"
@ m_x + _x, m_y + _unos_left GET _nc PICT gPicNC

if !IsMagSNab() 

	private fMarza:=" "

    // MARZA
    ++ _x
  	@ m_x + _x, m_y + 2    SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
  	@ m_x + _x, col() + 2 GET _Marza PICT PicDEM
  	@ m_x + _x, col() + 1 GET fMarza pict "@!" VALID {|| Marza( fMarza ), fMarza := " ", .t. }

    // PRODAJNA CIJENA / PLANSKA CIJENA
    ++ _x
    if koncij->naz == "P2"
        @ m_x + _x, m_y + 2    SAY "PLANSKA CIJENA  (PLC)       :"
    else
		@ m_x + _x, m_y + 2    SAY "PROD.CJENA BEZ PDV   :"
    endif
    
    @ m_x + _x, m_y + _unos_left GET _vpc PICT PicDEM VALID {|| MarzaVP( _Idvd, ( fMarza == "F" ) ), .t. }


  	if ( gMpcPomoc == "D" )

        _mpcsapp := roba->mpc

        ++ _x

   		// VPC se izracunava pomocu MPC cijene !!
       	@ m_x + _x, m_y + 2 SAY "PROD.CJENA SA PDV:"
       	@ m_x + _x, m_y + _unos_left GET _mpcsapp PICT PicDEM ;
             		valid {|| _mpcsapp:=iif(_mpcsapp=0,round(_vpc*(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),2),_mpcsapp),_mpc:=_mpcsapp/(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),;
                       iif(_mpc<>0,_vpc:=round(_mpc,2),_vpc), ShowGets(),.t.}

    endif

  	read

  	if (gMpcPomoc == "D")
		
        if (roba->mpc==0 .or. roba->mpc<>round(_mpcsapp,2)) .and. Pitanje(,"Staviti MPC u sifrarnik")=="D"

         		select roba
			    _rec := dbf_get_rec()
                _rec["mpc"] := _mpcsapp
                my_use_semaphore_off()
                sql_table_update( nil, "BEGIN" )

                update_rec_server_and_dbf( ALIAS(), _rec, 1, "CONT" )
                sql_table_update( nil, "END" )
                my_use_semaphore_on()

         		select kalk_pripr

     	endif

  	endif

  	SetujVPC( _vpc )  

else

	read

  	_Marza := 0
	_TMarza := "A"
	_VPC := _NC

endif

_MKonto := _Idkonto
_MU_I := "1"

nStrana := 3

return lastkey()



// ------------------------------------------------------
// automatsko setovanje troskova kalkulacije
// na osnovu sifrarnika robe
//
// lNewItem - radi se o novoj stavci
// ------------------------------------------------------
static function _auto_set_trosk( lNewItem )

local lForce := .f.

// ako nema polja TROSK1 u robi idi dalje....
// nemas sta raditi

if roba->(fieldpos("TROSK1")) == 0
	return
endif

// ako su automatski troskovi = "N", izadji
if gRobaTrosk == "N"
	return 
endif

if gRobaTrosk == "0"
	
	if Pitanje( ,"Preuzeti troskove iz sifrarnika robe ?", "D" ) == "N"
		return
	endif
	
	// setuj forirano uzimanje troska.....
	lForce := .t.
	
endif

if ( _Prevoz == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_Prevoz := roba->trosk1
	
	if !Empty(gRobaTr1Tip)
		_TPrevoz := gRobaTr1Tip
	endif
	
endif

if ( _BankTr == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_BankTr := roba->trosk2
	
	if !Empty(gRobaTr2Tip)
		_TBankTr := gRobaTr2Tip
	endif
	
endif

if ( _SpedTr == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_SpedTr := roba->trosk3

	if !Empty(gRobaTr3Tip)
		_TSpedTr := gRobaTr3Tip
	endif
	
endif

if ( _CarDaz == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_CarDaz := roba->trosk4

	if !EMPTY(gRobaTr4Tip)
		_TCarDaz := gRobaTr4Tip
	endif
	
endif

if ( _ZavTr == 0 .or. lForce == .t. .or. lNewItem == .t. ) 
	
	_ZavTr := roba->trosk5

	if !EMPTY(gRobaTr5Tip)
		_TZavTr := gRobaTr5Tip
	endif
	
endif

return



