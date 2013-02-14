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

#include "pos.ch"
#include "getexit.ch"

static __max_kolicina := NIL
static __kalk_konto := NIL


// ----------------------------------------------------------
// maksimalna kolicina na unosu racuna
// ----------------------------------------------------------
function max_kolicina_kod_unosa( read_par )

if read_par != NIL
    __max_kolicina := fetch_metric( "pos_maksimalna_kolicina_na_unosu", nil, 0 )
endif

return __max_kolicina


// ----------------------------------------------------------
// kalk konto za stanje artikla
// ----------------------------------------------------------
function kalk_konto_za_stanje_pos( read_par )

if read_par != NIL
	__kalk_konto := fetch_metric( "pos_stanje_sa_kalk_konta", NIL, "" )
endif

return __kalk_konto



function UnesiNarudzbu()
parameters cBrojRn, cSto

local _max_cols := MAXCOLS()
local _max_rows := MAXROWS()
local _read_barkod
local _stanje_robe := 0
local _stanje_art_id, _stanje_art_jmj

private ImeKol := {}
private Kol := {}
private nRowPos
private oBrowse
private aAutoKeys:={}
private nPopust := 0
private nIznNar := 0
private bPrevZv
private bPrevKroz
private aUnosMsg:={}
private bPrevUp
private bPrevDn
private GetList:={}

o_edit_rn()

select _pos

aRabat := {}

if ( cBrojRn == nil )
    cBrojRn := ""
endif

if ( cSto == nil )
    cSto := ""
endif


AADD( ImeKol, { PADR( "Artikal", 10 ), { || idroba } } )
AADD( ImeKol, { PADC( "Naziv", 50 ), { || PADR( robanaz, 50 ) } } )
AADD( ImeKol, { "JMJ", { || jmj } } )
AADD( ImeKol, { "Kolicina", { || STR( kolicina, 8, 3 ) } } )
AADD( ImeKol, { "Cijena", { || STR( cijena, 8, 2 ) } } )
AADD( ImeKol, { "Ukupno", { || STR( kolicina * cijena, 10, 2 ) } } )
AADD( ImeKol, { "Tarifa", { || idtarifa } } )

for i := 1 to LEN( ImeKol )
    AADD( Kol, i )
next

AADD( aUnosMsg, "<*> - Ispravka stavke")
//AADD( aUnosMsg, "Storno - neg.kolicina")
AADD( aUnosMsg, "<F8> storno")
AADD( aUnosMsg, "<F9> fiskalne funkcije")

Box(, _max_rows - 3, _max_cols - 3 , , aUnosMsg )

@ m_x, m_y + 23 SAY PADC ("RACUN BR: " + ALLTRIM( cBrojRn ), 40 ) COLOR Invert

oBrowse := FormBrowse( m_x + 7, m_y + 1, m_x + _max_rows - 12, m_y + _max_cols - 2, ImeKol, Kol,{ "Í", "Ä", "³"}, 0)

oBrowse:autolite := .f.
aAutoKeys := HangKeys()
bPrevDn := SETKEY( K_PGDN, {|| DummyProc() })
bPrevUp := SETKEY( K_PGUP, {|| DummyProc() })

SETKEY( K_F6, {|| f7_pf_traka() })

// storno racuna
SETKEY( K_F7, {|| pos_storno_fisc_no(), _refresh_total() })
SETKEY( K_F8, {|| pos_storno_rn(), _refresh_total() })
SETKEY( K_F9, {|| fisc_rpt( .t., .t.  ) })

// <*> - ispravka tekuce narudzbe
//       (ukljucujuci brisanje i ispravku vrijednosti)
// </> - pregled racuna - kod HOPSa

SetSpecNar()

@ m_x + 3, m_y + ( _max_cols - 30 ) SAY "UKUPNO:"
@ m_x + 4, m_y + ( _max_cols - 30 ) SAY "POPUST:"
@ m_x + 5, m_y + ( _max_cols - 30 ) SAY " TOTAL:"

// ispis velikim brojevima iznosa racuna
// na dnu forme...
ispisi_iznos_veliki_brojevi( 0, m_x + ( _max_rows - 12 ), _max_cols - 2 )

select _pos
set order to tag "1"

nIznNar := 0
nPopust := 0

_calc_current_total( @nIznNar, @nPopust )

select _pos_pripr
set order to
go top

// uzmi varijable _pos_pripr
scatter() 
 
gDatum := DATE()
_idpos := gIdPos
_idvd  := VD_RN
_brdok := cBrojRn
_datum := gDatum
_sto   := cSto
_smjena := gSmjena
_idradnik := gIdRadnik
_idcijena := gIdCijena
_prebacen := OBR_NIJE
_mu_i := R_I

if gStolovi == "D"
    _sto_br := VAL(cSto)
endif


do while .t.

    SET CONFIRM ON
    _show_total( nIznNar, nPopust, m_x + 2 )

    // brisi staru cijenu
    @ m_x + 3, m_y + 15 SAY SPACE(10)   
    
    // ispisi i iznos velikim brojevima na dnu...
    ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( _max_rows - 12 ), _max_cols - 2 )

	do while !oBrowse:stable 
    	oBrowse:Stabilize()
	enddo

    do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 ) 
    enddo

    _idroba := SPACE( LEN( _idroba ) )
    _kolicina := 0

    @ m_x + 2, m_y + 25 SAY SPACE (40)
    set cursor on

    // duzina naziva robe na unosu...
    if gDuzSifre > 0
        cDSFINI := ALLTRIM( STR( gDuzSifre ) )
    else
        cDSFINI := "10"
    endif
   
    @ m_x + 2, m_y + 5 SAY " Artikal:" GET _idroba ;
   		PICT PICT_POS_ARTIKAL ;
        WHEN {|| _idroba := PADR( _idroba, VAL(cDSFINI) ), .t. } ;
        VALID valid_pos_racun_artikal( @_kolicina ) 
 
    @ m_x + 3, m_y + 5 SAY "  Cijena:" GET _Cijena PICT "99999.999"  ;
        WHEN ( roba->tip == "T" .or. gPopZcj == "D" )

    @ m_x + 4, m_y + 5 SAY "Kolicina:" GET _Kolicina ;
      	PICT "999999.999" ;
        WHEN when_pos_kolicina( @_kolicina ) ;
     	VALID valid_pos_kolicina( @_kolicina, _cijena )

   
    nRowPos := 5
    
	read
    
    @ m_x + 4, m_y + 25 SAY space (11)

    // zakljuci racun
    if LastKey() == K_ESC
        exit
    endif
   
    // dodaj stavku racuna
    select _pos_pripr
    append blank
 
    _robanaz := roba->naz
    _jmj := roba->jmj
    _idtarifa := roba->idtarifa
    _idodj := SPACE(2)

    if !( roba->tip == "T" )
        _cijena := pos_get_mpc()
        // roba->mpc
    endif
            
    // _pos_pripr
    Gather()

	// gledati iz KALK ili iz POS ?
	if !EMPTY( ALLTRIM( __kalk_konto ) )
    	_stanje_robe := kalk_kol_stanje_artikla_prodavnica( PADR( __kalk_konto, 7 ), field->idroba, DATE() )
	else
   		_stanje_robe := pos_stanje_artikla( field->idpos, field->idroba )
	endif

    _stanje_art_id := field->idroba
    _stanje_art_jmj := field->jmj

    // utvrdi stanje racuna
    nIznNar += cijena * kolicina
    nPopust += ncijena * kolicina
    oBrowse:goBottom()
    oBrowse:refreshAll()
    oBrowse:dehilite()
            
    // prikazi stanje artikla u dnu ekrana
    _tmp := "STANJE ARTIKLA " + ALLTRIM( _stanje_art_id ) + ": " + ALLTRIM( STR( _stanje_robe, 12, 2 ) ) + " " + _stanje_art_jmj
    ispisi_donji_dio_forme_unosa( _tmp, 1 )

enddo

CancelKeys( aAutoKeys )
SETKEY( K_PGDN, bPrevDn )
SETKEY( K_PGUP, bPrevUp )

SETKEY( K_F6, NIL)
SETKEY( K_F7, NIL)
SETKEY( K_F8, NIL)
SETKEY( K_F9, NIL)

UnSetSpecNar()

BoxC()

return (.t.)



// ----------------------------------------------
// obrada popusta
// ----------------------------------------------
function Popust( nx, ny )
local nC1 := 0
local nC2 := 0

FrmGetRabat( aRabat, _cijena )
ShowRabatOnForm( nx, ny )

return


// ----------------------------------------------
// validacija artikla na racunu
// ----------------------------------------------
static function valid_pos_racun_artikal(kolicina)
local _ok, _read_barkod

_ok := pos_postoji_roba( @_idroba, 2, 27, @_read_barkod ) .and. NarProvDuple( _idroba )

if gOcitBarCod  
   hb_keyput(K_ENTER)
endif


return _ok
 

// ---------------------------------------------
// ---------------------------------------------
static function when_pos_kolicina(kolicina)

Popust( m_x + 4, m_y + 28 )

if gOcitBarCod
    if param_tezinski_barkod() == "D" .and. kolicina <> 0
        // _kolicina vec setovana
    else
        // ako je sifra ocitana po barcodu, onda ponudi kolicinu 1
        kolicina := 1
    endif
endif

return .t.

// ----------------------------------------------------------------
// ----------------------------------------------------------------
static function valid_pos_kolicina( kolicina, cijena )
return KolicinaOK( kolicina ) .and. pos_check_qtty( @kolicina ) .and. cijena_ok( cijena ) 

 
// ----------------------------------------------
//  
// ----------------------------------------------
static function _refresh_total()
local _iznos := 0
local _popust := 0

// izracunaj trenutni total...
_calc_current_total( @_iznos, @_popust )

nIznNar := _iznos
nPopust := _popust

// ispisi i iznos velikim brojevima na dnu...
ispisi_iznos_veliki_brojevi( ( _iznos - _popust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )
    
// ispisi i na gornjem totalu...
_show_total( _iznos, _popust, m_x + 2 )

select _pos_pripr
go top

return .t.


// --------------------------------------------------------------
// izracunava trenutni total u pripremi
// --------------------------------------------------------------
static function _calc_current_total( iznos, popust )
local _t_area := SELECT()
local _iznos := 0
local _popust := 0

select _pos_pripr
go top

do while !EOF()
    _iznos += _pos_pripr->( kolicina * cijena )
    _popust += _pos_pripr->( kolicina * ncijena )
    skip
enddo

iznos := _iznos
popust := _popust

select ( _t_area )
return


// ----------------------------------------------------
// provjera kolicine na unosu racuna
// ----------------------------------------------------
function pos_check_qtty( qtty )
local _max_qtty

_max_qtty := max_kolicina_kod_unosa() 

if _max_qtty == 0
    _max_qtty := 99999
endif

if _max_qtty == 0
    return .t.
endif

if qtty > _max_qtty
    if Pitanje(, "Da li je ovo ispravna kolicina: " + ALLTRIM(STR( qtty )), "N" ) == "D"
        return .t.
    else
        // resetuj na 0
        qtty := 0
        return .f.
    endif
else
    return .t.
endif



/*! \fn HangKeys()
 *  \brief Nabacuje SETKEYa kako je tastatura programirana   
 */
 
function HangKeys()
local aKeysProcs:={}
local bPrevSet

SELECT K2C
GO TOP

do while !eof()
    bPrevSet:=SETKEY(KeyCode,{|| AutoKeys ()})
        AADD (aKeysProcs, { KeyCode, bPrevSet} )
        SKIP
enddo
return (aKeysProcs)



/*! \fn CancelKeys(aPrevSets)
 *  \brief Ukida SETKEYs koji se postave i HANGKEYs
 *  \param aPrevSets
 */
 
function CancelKeys(aPrevSets)
local i:=1

nPrev := SELECT()

SELECT K2C
GoTop2()
do while !eof()
    SETKEY( KeyCode, aPrevSets [i++] )
    SKIP
enddo
SELECT (nPrev)
return



function SetSpecNar()
bPrevZv := SETKEY( ASC("*"), {|| IspraviNarudzbu() })
return .t.


function UnSetSpecNar()
SETKEY(ASC ("*"), bPrevZv)
return .f.


// --------------------------------------------
// provjera cijene
// --------------------------------------------
static function cijena_ok( cijena )
local _ret := .t.

if cijena == 0
    MsgBeep( "Nepravilan unos cijene, cijena mora biti <> 0 !!!" )
    _ret := .f.
endif

return _ret


// --------------------------------------------------------
// provjerava trenutnu kolicinu artikla u kasi...
// --------------------------------------------------------
static function KolicinaOK( kolicina )
local _ok := .f.
local _msg
local _stanje_robe 

if LASTKEY() == K_UP
	_ok := .t.
    return _ok
endif

if ( kolicina == 0 )
    MsgBeep( "Nepravilan unos kolicine robe! Ponovite unos!", 15 )
    return _ok
endif

if gPratiStanje == "N" .or. roba->tip $ "TU"
	_ok := .t.
    return _ok
endif

// izvuci stanje robe
_stanje_robe := pos_stanje_artikla( _idpos, _idroba )

_ok := .t.

if ( kolicina > _stanje_robe )
    
    _msg := "Artikal: " + _idroba + " Trenutno na stanju: " + STR( _stanje_robe, 12, 2 )

    if gPratiStanje = "!"
        _msg += "#Unos artikla onemogucen !!!"
		_ok := .f.
    endif

    MsgBeep( _msg )

endif

return _ok



static function NarProvDuple()
local nPrevRec
local lFlag:=.t.

if gDupliArt == "D" .and. gDupliUpoz == "N"
    // mogu dupli i nema upozorenja
    return .t.
endif

select _pos_pripr
nPrevRec := RECNO()

if _idroba = PADR( "PLDUG", 7 ) .and. reccount2() <> 0
    return .f.
endif

set order to tag "1"
seek PADR( "PLDUG", 7 )

if FOUND()
    MsgBeep('PLDUG mora biti jedina stavka !')
    SET ORDER TO
    GO (nPrevRec)
    return .f.
else
    set order to tag "1"
    HSEEK _IdRoba
endif

if FOUND()
    if _IdRoba='PLDUG'
            MsgBeep('Pri placanju duga ne mozete navoditi robu')
    endif
    if gDupliArt == "N"
            MsgBeep ( "Na narudzbi se vec nalazi ista roba!#" +"U slucaju potrebe ispravite stavku narudzbe!", 20)
            lFlag:=.f.
    elseif gDupliUpoz == "D"
            MsgBeep ( "Na narudzbi se vec nalazi ista roba!")
    endif
endif
SET ORDER TO
GO (nPrevRec)
return (lFlag)



function IspraviNarudzbu()
// Koristi privatnu varijablu oBrowse iz UNESINARUDZBU
local cGetId
local nGetKol
local aConds
local aProcs

UnSetSpecNar()

OpcTipke( { "<Enter>-Ispravi stavku", "<B>-Brisi stavku", "<Esc>-Zavrsi" } )

oBrowse:autolite := .t.
oBrowse:configure()

// spasi ono sto je bilo u GET-u
cGetId := _idroba
nGetKol := _Kolicina

aConds := { { |Ch| UPPER(CHR(Ch)) == "B" }, { |Ch| Ch == K_ENTER } }
aProcs := { { || BrisStavNar(oBrowse) }, { || EditStavNar (oBrowse) } }

ShowBrowse( oBrowse, aConds, aProcs )

oBrowse:autolite := .f.
oBrowse:dehilite()
oBrowse:stabilize()

// vrati stari meni
Prozor0()

// OpcTipke (aUnosMsg)
// vrati sto je bilo u GET-u
_idroba := cGetId
_kolicina := nGetKol

SetSpecNar()

return


// ---------------------------------------------------------------------
// ispisuje total na vrhu prozora unosa racuna
// ---------------------------------------------------------------------
static function _show_total( iznos, popust, row )
// osvjezi cijene
@ m_x + row + 0, m_y + ( MAXCOLS() - 12 ) SAY iznos PICT "99999.99" COLOR Invert
@ m_x + row + 1, m_y + ( MAXCOLS() - 12 ) SAY popust PICT "99999.99" COLOR Invert
@ m_x + row + 2, m_y + ( MAXCOLS() - 12 ) SAY iznos - popust PICT "99999.99" COLOR Invert
return


 
function BrisStavNar( oBrowse )
//      Brise stavku narudzbe
//      Koristi privatni parametar OBROWSE iz SHOWBROWSE
select _pos_pripr

if RecCount2() == 0
    MsgBeep ("Priprema racuna je prazna !!!#Brisanje nije moguce!", 20)
    return (DE_REFRESH)
endif

Beep (2)

// ponovo izracunaj ukupno
nIznNar -= _pos_pripr->( kolicina * cijena )
nPopust -= _pos_pripr->( kolicina * ncijena )

_show_total( nIznNar, nPopust, m_x + 2 )
ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

DELETE    
__dbPack()

oBrowse:refreshAll()

do while !oBrowse:stable 
    oBrowse:Stabilize()
enddo

return (DE_REFRESH)




function EditStavNar()
//      Vrsi editovanje stavke narudzbe, i to samo artikla ili samo kolicine
//      Koristi privatni parametar OBROWSE iz SHOWBROWSE
private GetList:={}

select _pos_pripr
if RecCount2() == 0
    MsgBeep ("Narudzba nema nijednu stavku!#Ispravka nije moguca!", 20)
    return (DE_CONT)
endif

Scatter()

set cursor on

Box (, 3, 75)
    
    @ m_x+1,m_y+4 SAY "    Artikal:" GET _idroba PICTURE PICT_POS_ARTIKAL VALID pos_postoji_roba(@_idroba, 1, 27) .AND. (_IdRoba==_pos_pripr->IdRoba .OR. NarProvDuple ())
    @ m_x+2,m_y+3 SAY "     Cijena:" GET _Cijena  picture "99999.999" when roba->tip=="T"
    @ m_x+3,m_y+3 SAY "   kolicina:" GET _Kolicina VALID KolicinaOK (_Kolicina)

    READ

    select _pos_pripr
    @ m_x+3,m_Y+25  SAY SPACE(11)

    if LASTKEY() <> K_ESC
        if (_pos_pripr->IdRoba<>_IdRoba) .or. roba->tip=="T"
            SELECT ODJ
            HSEEK ROBA->IdOdj
            // LOCATE FOR IdTipMT == ROBA->IdTreb
            if FOUND()
                select _pos_pripr
                _RobaNaz:=ROBA->Naz
                _JMJ:=ROBA->JMJ
                if !(roba->tip=="T")
                    _Cijena:=&("ROBA->Cijena"+gIdCijena)
                endif
                _IdTarifa:=ROBA->IdTarifa
                if gVodiOdj=="D"
                    _IdOdj:=ROBA->IdOdj
                else
                    _IdOdj:=SPACE(2)
                endif
            
                nIznNar+=(_cijena*_kolicina)-cijena*kolicina
                nPopust+=(_ncijena*_kolicina)  - ncijena*kolicina
                Gather () 
            else
                MsgBeep ("Za robu "+ALLTRIM (_IdRoba)+" nije odredjeno odjeljenje!#"+"Narucivanje nije moguce!!!", 15)
                select _pos_pripr
                return (DE_CONT)
            endif
        endif
        
        if (_pos_pripr->Kolicina <> _Kolicina)        
            // azuriraj narudzbu
            nIznNar += (_cijena*_kolicina) - cijena * kolicina
            nPopust += (_ncijena*_kolicina) - ncijena * kolicina
            REPLACE Kolicina WITH _Kolicina
        endif
    
    endif

BoxC()

// ispisi totale...
_show_total( nIznNar, nPopust, m_x + 2 )
ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( MAXROWS() - 12 ), MAXCOLS() - 2 )

oBrowse:refreshCurrent()

do while !oBrowse:stable 
    oBrowse:Stabilize()
enddo

return (DE_CONT)



/*! \fn GetReader2(oGet,GetList,oMenu,aMsg)
 *  \param oGet
 *  \param GetList
 *  \param oMenu
 *  \param aMsg
 */
 
function GetReader2( oGet, GetList, oMenu, aMsg )
local nKey
local nRow
local nCol

if (GetPreValSC(oGet, aMsg))
        oGet:setFocus()
    do while ( oGet:exitState == GE_NOEXIT )
            if ( gOcitBarcod .and. gEntBarCod == "D")
                oGet:exitState:=GE_ENTER
                exit
            endif
            if ( oGet:typeOut )
                oGet:exitState := GE_ENTER
            endif

            do while ( oGet:exitState == GE_NOEXIT )
                nKey := INKEY( 0 )
                GetApplyKey( oGet, nKey, GetList, oMenu, aMsg )
                nRow := ROW()
                nCol := COL()
                DevPos( nRow, nCol )
            enddo

            if ( !GetPstValSC( oGet, aMsg ) )
                oGet:exitState := GE_NOEXIT
            endif
        enddo
        // De-activate the GET
        oGet:killFocus()
endif

return

