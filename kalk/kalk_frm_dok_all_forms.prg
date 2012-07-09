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

function VRoba( lSay )

P_Roba( @_IdRoba )

if lSay == NIL
	lSay := .t.
endif

if lSay
	Reci( 11, 23, TRIM( LEFT( roba->naz, 40 )) + " (" + ALLTRIM( roba->jmj ) + ")", 40 )
endif

if fNovi .or. IsJerry() .or. IsPlanika()
	// nadji odgovarajucu tarifu regiona
	cTarifa := Tarifa( _idkonto, _idroba, @aPorezi )
else
	// za postojece dokumente uzmi u obzir unesenu tarifu
	SELECT TARIFA
	seek _idtarifa
	SetAPorezi( @aPorezi )
endif

if fNovi .or. ( gVodiSamoTarife == "D" ) .or. IsJerry() .or. IsPlanika()
	_idtarifa := cTarifa
endif

return .t.





/*! \fn WMpc(fRealizacija,fMarza)
 *  \brief When blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 */

function WMpc(fRealizacija, fMarza)

if fRealizacija==nil
	fRealizacija:=.f.
endif

if fRealizacija
	fMarza:=" "
endif

if _mpcsapp <> 0
	_marza2 := 0
	_mpc := MpcBezPor( _mpcsapp, aPorezi, , _nc )
endif

if fRealizacija
	if (_idvd=="47" .and. !(IsJerry().and._idvd="4"))
		_nc:=_mpc
	endif
endif

return .t.





/*! \fn VMpc(fRealizacija,fMarza)
 *  \brief Valid blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 */

function VMpc(fRealizacija, fMarza)

if fRealizacija==NIL
	fRealizacija:=.f.
endif

if fRealizacija
	fMarza:=" "
endif

if fMarza==NIL 
	fMarza:=" "
endif

Marza2(fMarza)

if _mpcsapp == 0
	_MPCSaPP := round( MpcSaPor( _mpc, aPorezi ), 2 )
endif

return .t.





/*! \fn VMpcSaPP(fRealizacija,fMarza)
 *  \brief Valid blok za unos MpcSaPP
 *  \param fRealizacija -
 *  \param fMarza -
 */

function VMpcSaPP(fRealizacija, fMarza)
*{
local nRabat

if fRealizacija==NIL
	fRealizacija:=.f.
endif

if fRealizacija
	nRabat:=_rabatv
else
	nRabat:=0
endif

if fMarza==NIL 
	fMarza:=" "
endif

if _mpcsapp<>0 .and. empty(fMarza)
	
	_mpc:=MpcBezPor(_mpcsapp, aPorezi, nRabat, _nc)
	
	_marza2:=0
	if fRealizacija
		Marza2R()
	else  
		Marza2()
	endif
	ShowGets()

	if fRealizacija
		DuplRoba()
	endif
endif

fMarza:=" "
return .t.
*}




/*! \fn SayPorezi(nRow)
 *  \brief Ispisuje poreze
 *  \param nRow - relativna kooordinata reda u kojem se ispisuju porezi
 */

function SayPorezi(nRow)
*{
if IsPDV()
	@ m_x+nRow,m_y+2  SAY "PDV (%):"
	@ row(),col()+2 SAY aPorezi[POR_PPP] PICTURE "99.99"
	if glUgost
	  @ m_x+nRow,col()+8  SAY "PP (%):"
	   @ row(),col()+2  SAY aPorezi[POR_PP] PICTURE "99.99"
	endif
else
	@ m_x+nRow,m_y+2  SAY "PPP (%):"
	@ row(),col()+2 SAY  aPorezi[POR_PPP] PICTURE "99.99"
	@ m_x+nRow,col()+8  SAY "PPU (%):"
	@ row(),col()+2  SAY PrPPUMP() PICTURE "99.99"
	@ m_x+nRow,col()+8  SAY "PP (%):"
	@ row(),col()+2  SAY aPorezi[POR_PP] PICTURE "99.99"
endif
return
*}




/*! \fn FillIzgStavke(pIzgStavke)
 *  \brief Puni polja izgenerisane stavke
 *  \param pIzgStavke - .f. ne puni, .t. puni
 */

function FillIzgStavke(pIzgStavke)
*{
if pIzgSt .and. _kolicina>0 .and. lastkey()<>K_ESC // izgenerisane stavke postoje
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
    replace nc with kalk_pripr->fcj,;
          vpc with _vpc,;
          tprevoz with _tprevoz,;
          prevoz with _prevoz,;
          mpc    with _mpc,;
          mpcsapp with _mpcsapp,;
          tmarza  with _tmarza,;
          marza  with _vpc/(1+_PORVT)-kalk_pripr->fcj,;      // konkretna vp marza
          tmarza2  with _tmarza2,;
          marza2  with _marza2,;
          mkonto with _mkonto,;
          mu_i with  _mu_i,;
          pkonto with _pkonto,;
          pu_i with  _pu_i ,;
          error with "0"
  endif
  skip
 enddo
 go nRRec
endif

return
*}



/*! \fn VRoba_lv(fNovi, aPorezi)
 *  \brief Setuje tarifu i poreze na osnovu sifrarnika robe i tarifa
 *  \note koristi lokalne varijable
 */

function VRoba_lv( fNovi, aPorezi )

P_Roba(@_IdRoba)

if fNovi .or. IsJerry()
    // nadji odgovarajucu tarifu regiona
    cTarifa:=Tarifa(_IdKonto,_IdRoba, @aPorezi)
else
    // za postojece dokumente uzmi u obzir unesenu tarifu
    SELECT TARIFA
    seek _IdTarifa
    SetAPorezi(@aPorezi)
endif

if fNovi .or. (gVodiSamoTarife=="D") .or. IsJerry()
   _IdTarifa:=cTarifa
endif

return .t.



// -----------------------------------------------------------
// WHEN validator na polju MPC
// -----------------------------------------------------------
function W_Mpc_( cIdVd, lNaprijed, aPorezi )
local _st_popust

// formiraj cijenu naprijed
if lNaprijed
    // postavi _Mpc bez poreza
    MarzaMP( cIdVd, .t. , aPorezi )  
endif

if cIdVd $ "41#42#47"
    nMpcSaPDV := _MpcSaPP
    _st_popust := _rabatv
else
    nMpcSaPDV := _MpcSapp
    _st_popust := 0
endif

// postoji MPC, idi unazad
if !lNaprijed .and. _MpcSapp <> 0
    _Marza2 := 0
    _Mpc := MpcBezPor( nMpcSaPDV, aPorezi, , _nc ) - _st_popust
endif

return .t.



/*! \fn WMpc_lv(fRealizacija, fMarza, aPorezi)
 *  \brief When blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 *  \note koriste se lokalne varijable
 */

function WMpc_lv(fRealizacija, fMarza, aPorezi)
*{

// legacy

if fRealizacija==nil
  fRealizacija:=.f.
endif

if fRealizacija
   fMarza:=" "
endif

if _MpcSapp<>0
  _marza2:=0
  _Mpc:=MpcBezPor(_MpcSaPP, aPorezi, , _nc)
endif

if fRealizacija
  if (_idvd=="47" .and. !( IsJerry() .and. _idvd="4"))
     _nc:=_mpc
  endif
endif

return .t.
*}




/*! \fn VMpc_lv(fRealizacija, fMarza, aPorezi)
 *  \brief Valid blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 *  \note koriste se lokalne varijable
 */

function VMpc_lv(fRealizacija, fMarza, aPorezi)
*{
if fRealizacija==nil
  fRealizacija:=.f.
endif
if fRealizacija
  fMarza:=" "
endif
if fMarza==nil 
  fMarza:=" "
endif

Marza2(fMarza)
if (_mpcsapp == 0)
 _MPCSaPP:=round( MpcSaPor(_mpc, aPorezi), 2 )
endif
return .t.
*}



function V_Mpc_( cIdVd, lNaprijed, aPorezi)
local nPopust

if cIdVd $ "41#42#47"
     nPopust := _RabatV
else
     nPopust := 0
endif

MarzaMp(cIdVd, lNaprijed, aPorezi)

if ( _Mpcsapp == 0 )
    _mpcsapp := ROUND( MpcSaPor( _mpc, aPorezi ), 2 ) + nPopust
endif

return .t.





/*! \fn VMpcSaPP_lv(fRealizacija, fMarza, aPorezi)
 *  \brief Valid blok za unos MpcSaPP
 *  \param fRealizacija -
 *  \param fMarza -
 *  \note koriste se lokalne varijable
 */

function VMpcSaPP_lv( fRealizacija, fMarza, aPorezi, lShowGets )
local nPom

if lShowGets == nil
	lShowGets := .t.
endif

if fRealizacija==NIL
    fRealizacija:=.f.
endif

if fRealizacija
    nPom := _mpcsapp
else
    nPom := _mpcsapp
endif

if fMarza==nil 
    fMarza := " "
endif

if _mpcsapp <> 0 .and. EMPTY( fMarza )
  _mpc := MpcBezPor (nPom, aPorezi, , _nc) - _rabatv
  _marza2 := 0
  if fRealizacija
    Marza2R()
  else  
    Marza2()
  endif
  if lShowGets
  	ShowGets()
  endif
  if fRealizacija
     DuplRoba()
  endif
endif

fMarza:=" "
return .t.


// ---------------------------------------------------------------
// racuna mpc sa porezom 
// ---------------------------------------------------------------
function V_MpcSaPP_( cIdVd, lNaprijed, aPorezi, lShowGets)
local nPom

if lShowGets == nil
	lShowGets := .t.
endif

if cIdvd $ "41#42"
    nPom := _mpcsapp
else
    nPom := _mpcsapp
endif

if _Mpcsapp <> 0 .and. !lNaprijed

    // mpc ce biti umanjena mpc sa pp - porez - rabat (ako postoji)  
    _mpc := MpcBezPor( nPom, aPorezi, , _nc ) - _rabatv

    _marza2 := 0
  
    MarzaMP(cIdVd, lNaprijed, aPorezi)
  
    if lShowGets
    	ShowGets()
    endif
  
    if cIdVd $ "41#42"
        DuplRoba()
    endif

endif

return .t.





/*! \fn SayPorezi_lv(nRow, aPorezi)
 *  \brief Ispisuje poreze
 *  \param nRow - relativna kooordinata reda u kojem se ispisuju porezi
 *  \aPorezi - koristi lokalne varijable
 */

function SayPorezi_lv(nRow, aPorezi)
*{
if IsPDV()
	@ m_x+nRow,m_y+2  SAY "PDV (%):"
	@ row(),col()+2 SAY  aPorezi[POR_PPP] PICTURE "99.99"
	
	if glUgost
	  @ m_x+nRow,col()+8  SAY "PP (%):"
	  @ row(),col()+2  SAY aPorezi[POR_PP] PICTURE "99.99"
	endif
else
	@ m_x+nRow,m_y+2  SAY "PPP (%):"
	@ row(),col()+2 SAY  aPorezi[POR_PPP] PICTURE "99.99"
	@ m_x+nRow,col()+8  SAY "PPU (%):"
	@ row(),col()+2  SAY PrPPUMP() PICTURE "99.99"
	@ m_x+nRow,col()+8  SAY "PP (%):"
	@ row(),col()+2  SAY aPorezi[POR_PP] PICTURE "99.99"
endif
return
*}


