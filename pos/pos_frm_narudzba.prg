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



function UnesiNarudzbu()
parameters cBrojRn, cSto

local _max_cols := MAXCOLS()
local _max_rows := MAXROWS()
local _tb := fetch_metric( "barkod_tezinski_barkod", nil, "N" )

private ImeKol := {}
private Kol := {}
private nRowPos
private oBrowse
private aAutoKeys:={}
private nIznNar:=0
private bPrevZv
private bPrevKroz
private aUnosMsg:={}
private bPrevUp
private bPrevDn

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
AADD( ImeKol, { "Tarifa", { || idtarifa } } )
AADD( ImeKol, { "Kolicina", { || STR( kolicina, 8, 2 ) } } )
AADD( ImeKol, { "Cijena", { || STR( cijena, 8, 2 ) } } )
AADD( ImeKol, { "Ukupno", { || STR( kolicina * cijena, 10, 2 ) } } )

for i := 1 to LEN( ImeKol )
    AADD( Kol, i )
next

AADD( aUnosMsg, "<*> - Ispravka stavke")
AADD( aUnosMsg, "Storno - neg.kolicina")

Box(, _max_rows - 3, _max_cols - 3 , , aUnosMsg )

@ m_x, m_y + 23 SAY PADC ("RACUN BR: " + ALLTRIM( cBrojRn ), 40 ) COLOR Invert

oBrowse := FormBrowse( m_x + 7, m_y + 1, m_x + _max_rows - 12, m_y + _max_cols - 2, ImeKol, Kol,{ "Í", "Ä", "³"}, 0)

oBrowse:autolite := .f.
aAutoKeys := HangKeys()
bPrevDn := SETKEY( K_PGDN, {|| DummyProc() })
bPrevUp := SETKEY( K_PGUP, {|| DummyProc() })

if IsPDV()
    SETKEY( K_F7, {|| f7_pf_traka() })
endif

// storno racuna
SETKEY( K_F8, {|| pos_storno_rn() })

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
set order to tag "3"

//"3", "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba", PRIVPATH+"_POS"
seek VD_RN + gIdRadnik
        
do while !eof() .and. _pos->(IdVd+IdRadnik) == (VD_RN + gIdRadnik)

	if !(_pos->m1 == "Z")

		// mora biti Z, jer se odmah zakljucuje
        Scatter()
        select _pos_pripr
        append blank 
		Gather()
       	SELECT _POS
       	Del_Skip()
  	else
      	delete
        skip
 	endif
enddo
    
set order to tag "1"

nIznNar := 0
nPopust := 0

select _pos_pripr
go top

do while !EOF()
    
    if ( idradnik + idpos + idvd + smjena ) <> ( gIdRadnik + gidpos + VD_RN + gSmjena )
        delete  
    else
      	nIznNar += _pos_pripr->( kolicina * cijena )
       	nPopust += _pos_pripr->( kolicina * ncijena )
    endif
    
    skip

enddo

set order to
go top

scatter() 
 
_IdPos:=gIdPos
_IdVd:=VD_RN
_BrDok:=cBrojRn
gDatum := DATE()
_Datum := gDatum
_Sto:=cSto
_Smjena:=gSmjena
_IdRadnik:=gIdRadnik
_IdCijena:=gIdCijena
_Prebacen:=OBR_NIJE
_MU_I:= R_I

if gStolovi == "D"
    _sto_br := VAL(cSto)
endif

do while .t.

    _show_total( nIznNar, nPopust, m_x + 2 )

    // brisi staru cijenu
    @ m_x + 3, m_y + 15 SAY SPACE(10)   
    
    // ispisi i iznos velikim brojevima na dnu...
    ispisi_iznos_veliki_brojevi( ( nIznNar - nPopust ), m_x + ( _max_rows - 12 ), _max_cols - 2 )

    do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 ) 
    enddo

    _idroba := SPACE( LEN( _idroba ) )
    _Kolicina := 0

    @ m_x + 2, m_y + 25 SAY SPACE (40)
    set cursor on

    if gDuzSifre <> nil .and. gDuzSifre > 0
        cDSFINI := ALLTRIM( STR( gDuzSifre ) )
    else
        cDSFINI := IzFMKINI('SifRoba','DuzSifra','10')
    endif
    
    @ m_x + 2, m_y + 5 SAY " Artikal:" GET _idroba ;
   		PICT "@!S10" ;
        WHEN {|| _idroba := PADR( _idroba, VAL(cDSFINI) ), .t. } ;
        VALID PostRoba( @_idroba, 2, 27 ) .and. NarProvDuple( _idroba )
 
    @ m_x + 3, m_y + 5 SAY "  Cijena:" GET _Cijena ;
      	PICT "99999.999" ;
        WHEN ( roba->tip == "T" .or. gPopZcj == "D" )

    @ m_x + 4, m_y + 5 SAY "Kolicina:" GET _Kolicina ;
      	PICT "999999.999" ;
        WHEN {|| Popust( m_x + 4, m_y + 28 ), ;
       		_kolicina := IIF( gOcitBarcod, IIF( _tb == "D" .and. _kolicina <> 0, _kolicina, 1 ), _kolicina ), ;
            _kolicina := IIF( _idroba = PADR( "PLDUG", 7 ), 1, _kolicina ), ;
            IIF( _idroba = PADR("PLDUG", 7 ), .f., .t. ) } ;
      	VALID KolicinaOK( _kolicina ) .and. pos_check_qtty( _kolicina ) 
    
    nRowPos := 5
    
    // ako je sifra ocitana po barcodu, onda ponudi kolicinu 1
	read
    
    cParticip:="N"
    
    @ m_x + 4, m_y + 25 SAY space (11)

    if LASTKEY() == K_ESC
        EXIT
    else
        
        SELECT ODJ
        HSEEK SPACE(2)
        
        if gVodiOdj == "N" .or. FOUND()
            
            select _pos_pripr
            append blank
 
            _RobaNaz:=ROBA->Naz
            _Jmj:=ROBA->Jmj
            _IdTarifa:=ROBA->IdTarifa

            if !(roba->tip=="T")
                    _Cijena:=ROBA->mpc
            endif
            
            if gVodiOdj=="D"
                _IdOdj:=ROBA->IdOdj
            else
                _IdOdj:=SPACE(2)
            endif
            
            if gModul=="HOPS"
                    
                if gVodiTreb=="D".and.ROBA->Tip<>"I"
                        
                    // I -inventar
                        _GT:=OBR_NIJE
                        
                    if gRadniRac=="D"
                        _M1:="S"
                    else
                        _M1:=" "
                    endif
                    else
                        // za inventar se ne pravi trebovanje, ni u kom slucaju
                        _GT := OBR_JEST
                    endif
                
                    SELECT ROBAIZ
                HSEEK (_IdRoba)
                    
                if FOUND()
                        _IdDio:=ROBAIZ->IdDio
                    else
                        _IdDio:=gIdDio
                    endif
                    
                select _pos_pripr
                
            endif

            // _PRIPR
            Gather()

            // utvrdi stanje racuna
            nIznNar += cijena * kolicina
            nPopust += ncijena * kolicina
            oBrowse:goBottom()
            oBrowse:refreshAll()
            oBrowse:dehilite()
            
        else   
            
            // nije nadjeno odjeljenje ??
            select _pos_pripr
            MsgBeep("Za robu " + ALLTRIM(_IdRoba) + " nije odredjeno odjeljenje!#" + "Izdavanje nije moguce!" )

        endif

    endif

enddo

CancelKeys( aAutoKeys )
SETKEY( K_PGDN, bPrevDn )
SETKEY( K_PGUP, bPrevUp )

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




function pos_check_qtty( qtty )
local _max_qtty

_max_qtty := fetch_metric( "pos_maksimalna_kolicina_na_unosu", nil, 0 )

if _max_qtty == 0
    return .t.
endif

if qtty > _max_qtty
    if Pitanje(, "Da li je ovo ispravna kolicina: " + ALLTRIM(STR( qtty )), "N" ) == "D"
        return .t.
    else
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

if gModul == "HOPS"
    // provjeriti parametar kako se vode racuni trgovacki ili hotelski
    if (gRadniRac=="D")
            bPrevKroz := SETKEY (ASC ("/"), { || PreglRadni (cBrojRn) })
    endif
endif

return .t.




function UnSetSpecNar()

SETKEY(ASC ("*"), bPrevZv)

if gModul=="HOPS"
    if gRadniRac=="D"
            SETKEY (ASC ("/"), bPrevKroz)
    endif
endif

return .f.


// --------------------------------------------------------
// provjerava trenutnu kolicinu artikla u kasi...
// --------------------------------------------------------
static function KolicinaOK(nKol)
local nSelect := SELECT()
local nStanje
local lFlag := .t.
local _msg

if LASTKEY() == K_UP
    return .t.
endif

if ( nKol == 0 )
    MsgBeep( "Nepravilan unos kolicine robe! Ponovite unos!", 15 )
    return .f.
endif

if gPratiStanje == "N" .or. roba->tip $ "TU"
    return .t.
endif

select pos
set order to tag "5"  
//"5", "IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
            
seek _IdPos+_idroba
nStanje := 0

do while !eof() .and. POS->(IdPos+IdRoba)==(_IdPos+_IdRoba)
    // uzmi samo stavke do tekuceg datuma
    if (pos->datum > gDatum )
        skip
        loop
    endif
            
    if pos->idvd $ "16#00"
        nStanje += POS->Kolicina
    elseif Pos->idvd $ "IN"
        nStanje += POS->Kol2 - POS->Kolicina
    elseif POS->idvd $ "42#01#96"
        nStanje -= POS->Kolicina
    endif
                
    skip

enddo
            
select pos
set order to tag "1"
            
select (nSelect)
            
if ( nKol > nStanje )
    
    _msg := "Artikal: " + _idroba + " Trenutno na stanju: " + STR( nStanje, 12, 2 )

    if gPratiStanje = "!"
        _msg += "#Unos artikla onemogucen !!!"
        lFlag := .f.
    endif

    MsgBeep( _msg )

endif

return lFlag



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
    MsgBeep ("Narudzba nema nijednu stavku!#Brisanje nije moguce!", 20)
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
    
    @ m_x+1,m_y+4 SAY "   Artikal:" GET _idroba PICTURE "@K" VALID PostRoba(@_idroba, 1, 27) .AND. (_IdRoba==_pos_pripr->IdRoba .OR. NarProvDuple ())
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
        
        if (_pos_pripr->Kolicina<>_Kolicina)        
            // azuriraj narudzbu
            nIznNar+=(_cijena*_kolicina) - cijena*kolicina
            nPopust+=(_ncijena*_kolicina) - ncijena*kolicina
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

