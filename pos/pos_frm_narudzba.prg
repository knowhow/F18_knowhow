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

SELECT _POS

aRabat:={}

if ( cBrojRn == nil )
    cBrojRn:=""
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
AADD( aUnosMsg, "Storno/povrat - negativna kolicina")

if gModul=="HOPS"
    if gRadniRac=="D"
            AADD( aUnosMsg, "</> - Pregled racuna")
    endif
endif

Box(, MAXROWS() - 4, MAXCOLS() - 3 , , aUnosMsg )

@ m_x, m_y + 23 SAY PADC ("RACUN BR: " + ALLTRIM(cBrojRn), 40) COLOR Invert

oBrowse := FormBrowse( m_x + 7, m_y + 1, m_x + MAXROWS() - 8, m_y + MAXCOLS() - 2, ImeKol, Kol,{ "Í", "Ä", "³"}, 0)

oBrowse:autolite:=.f.
aAutoKeys:=HangKeys ()
bPrevDn:=SETKEY(K_PGDN, {|| DummyProc()})
bPrevUp:=SETKEY(K_PGUP, {|| DummyProc()})

if IsPDV()
    SETKEY(K_F7, {|| f7_pf_traka()})
endif

// storno racuna
SETKEY( K_F8, {|| pos_storno_rn() })

// <*> - ispravka tekuce narudzbe
//       (ukljucujuci brisanje i ispravku vrijednosti)
// </> - pregled racuna - kod HOPSa

SetSpecNar()

@ m_x+3,m_y+50 SAY "Ukupno:"
@ m_x+4,m_y+50 SAY "Popust:"
@ m_x+5,m_y+50 SAY "UKUPNO:"

   
SELECT _POS
set order to tag "3"
//"3", "IdVd+IdRadnik+GT+IdDio+IdOdj+IdRoba", PRIVPATH+"_POS"
SEEK VD_RN + gIdRadnik
        
do while !eof() .and. _pos->(IdVd+IdRadnik) == (VD_RN + gIdRadnik)
            
	if !(_pos->m1 == "Z")
                
		// mora biti Z, jer se odmah zakljucuje
        Scatter()
        select _pos_pripr
        append blank 
		// pripr
                
		Gather()
       	SELECT _POS
       	Del_Skip()

  	else
            
      	delete
        skip

 	endif

enddo
    
set order to tag "1"

nIznNar:=0
nPopust:=0

select _pos_pripr
GO TOP

do while !eof()
    
    if (idradnik+idpos+idvd+smjena)<>(gIdRadnik+gidpos+VD_RN+gSmjena)
       	// _PRIPR
        delete  
    else
      	nIznNar+=_pos_pripr->(Kolicina*Cijena)
       	nPopust+=_pos_pripr->(Kolicina*NCijena)
    endif
    
    SKIP

enddo

SET ORDER TO
GO TOP

// iz _PRIPR
Scatter() 
 
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

    @ m_x+3,m_y+70 SAY nIznNar pict "99999.99" COLOR Invert
    @ m_x+4,m_y+70 SAY nPopust pict "99999.99" COLOR Invert
    @ m_x+5,m_y+70 SAY nIznNar-nPopust pict "99999.99" COLOR Invert
    // brisi staru cijenu
    @ m_x+3,m_y+15 SAY SPACE (10)   

    do while !oBrowse:Stabilize() .and. ((Ch:=INKEY())==0)
    enddo

    _idroba:=SPACE(LEN(_idroba))
    _Kolicina:=0
    // resetuj i velicinu

    @ m_x+2,m_y+25 SAY SPACE (40)
    set cursor on

    if gDuzSifre <> nil .and. gDuzSifre > 0
        cDSFINI := ALLTRIM(STR(gDuzSifre))
    else
        cDSFINI := IzFMKINI('SifRoba','DuzSifra','10')
    endif
    
    @ m_x+2,m_y+5 SAY " Artikal:" GET _idroba ;
            PICT "@!S10" ;
            WHEN {|| _idroba := padr(_idroba,VAL(cDSFINI)),.t.} ;
            VALID PostRoba(@_idroba, 2, 27) .and. NarProvDuple (_idroba)
 
    @ m_x+3,m_y+5 SAY "  Cijena:" GET _Cijena ;
            PICT "99999.999" ;
            WHEN ( roba->tip == "T" .or. gPopZcj == "D" )

    @ m_x+4, m_y+5 SAY "Kolicina:" GET _Kolicina ;
            PICT "999999.999" ;
            WHEN {|| Popust(m_x+4,m_y+28), ;
                _kolicina := iif(gOcitBarcod, 1, _kolicina), ;
                _kolicina := iif(_idroba='PLDUG  ', 1, _kolicina), ;
                iif( _idroba = 'PLDUG  ', .f., .t.) } ;
            VALID KolicinaOK(_Kolicina) .and. CheckQtty(_Kolicina) 
            //SEND READER := {|g| GetReader2(g)}
    
    nRowPos := 5
    
    // ako je sifra ocitana po barcodu, onda ponudi kolicinu 1
    read
    
    cParticip:="N"
    // apoteke !!!
    
    @ m_x+4,m_y+25 SAY space (11)

    if LASTKEY() == K_ESC
        
        EXIT
        
    else
        
        SELECT ODJ
        HSEEK SPACE(2)
        
        if gVodiOdj=="N" .or. FOUND()
            
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
            nIznNar+=Cijena*Kolicina
            nPopust+=NCijena*Kolicina
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

CancelKeys(aAutoKeys)
SETKEY(K_PGDN,bPrevDn)
SETKEY(K_PGUP,bPrevUp)
UnSetSpecNar()

BoxC()

return (.t.)



/*! \fn Popust(nx,ny)
 *  \brief
 *  \param nx
 *  \param ny
 *  \return
 */
function Popust(nx,ny)
*{

local nC1:=0
local nC2:=0

FrmGetRabat(aRabat, _cijena)
ShowRabatOnForm(nx, ny)

return
*}



function CheckQtty(nAmount)
*{

nTotAmount:=VAL(IzFmkIni("POS","MaxKolicina","100",KUMPATH))

if nTotAmount==0
    return .t.
endif

if nAmount > nTotAmount 
    if Pitanje(,"Da li je ovo ispravna kolicina: " + ALLTRIM(STR(nAmount)),"N")=="D"
        return .t.
    else
        return .f.
    endif
else
    return .t.
endif
*}


/*! \fn HangKeys()
 *  \brief Nabacuje SETKEYa kako je tastatura programirana   
 */
 
function HangKeys()
*{

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
*}


/*! \fn CancelKeys(aPrevSets)
 *  \brief Ukida SETKEYs koji se postave i HANGKEYs
 *  \param aPrevSets
 */
 
function CancelKeys(aPrevSets)
*{

local i:=1

nPrev:=SELECT()

SELECT K2C
GoTop2()
do while !eof()
    SETKEY( KeyCode, aPrevSets [i++] )
    SKIP
enddo
SELECT (nPrev)
return
*}

/*! \fn SetSpecNar()
 *  \brief Definisi ponasanje tipke "*" koja nas uvodi u rezim ispravki
 */
 
function SetSpecNar()
*{

bPrevZv:=SETKEY(ASC("*"), {|| IspraviNarudzbu()})

if gModul=="HOPS"
    // provjeriti parametar kako se vode racuni trgovacki ili hotelski
    if (gRadniRac=="D")
            bPrevKroz := SETKEY (ASC ("/"), { || PreglRadni (cBrojRn) })
    endif
endif

return .t.
*}


/*! \fn UnSetSpecNar()
 *  \brief VratiSpecifikaciju kakva je bila prije ove procedure
 */
 
function UnSetSpecNar()
*{

SETKEY(ASC ("*"), bPrevZv)

if gModul=="HOPS"
    if gRadniRac=="D"
            SETKEY (ASC ("/"), bPrevKroz)
    endif
endif

return .f.

*}


/*! \fn KolicinaOK(nKol)
 */
static function KolicinaOK(nKol)
*{

local nSelect:=SELECT()
local nStanje
local lFlag:=.t.

if LASTKEY()==K_UP
    return .t.
endif

if IsPlNS() 
    if gFissta=="D" .and. gFisStorno=="N"
        // sasa: ovo ne treba ovdje
        //if (nKol < 0)
        //  MsgBeep("Storno nije dozvoljen. Ponovite unos!")
        //  return .f.
        //endif
    endif
endif

if (nKol==0)
    MsgBeep("Nepravilan unos kolicine robe! Ponovite unos!", 15)
    return .f.

endif

if gPratiStanje=="N".or.roba->Tip $ "TU"
    return (.t.)
else
    // gprati stanje D, !
    if gModul=="TOPS"  // ovo cemo samo za TOPS!!
            select pos
            set order to tag "5"  
        //"5", "IdPos+idroba+DTOS(Datum)", KUMPATH+"POS")
            seek _IdPos+_idroba
            nStanje:=0
            do while !eof() .and. POS->(IdPos+IdRoba)==(_IdPos+_IdRoba)
                // uzmi samo stavke do tekuceg datuma
            if (pos->datum > gDatum )
                skip
                loop
            endif
            
            // provjeri da li je dokument na stanju...
            if IsPlanika() .and. pos->idvd == VD_ZAD
                if !roba_na_stanju(pos->idpos, pos->idvd, ;
                        pos->brdok, pos->datum)
                    skip
                    loop
                endif
            endif
            
            if POS->idvd $ "16#00"
                    nStanje += POS->Kolicina
                elseif Pos->idvd $ "IN"
                    nStanje += POS->Kol2 - POS->Kolicina
                elseif POS->idvd $ "42#01#96"
                    nStanje -= POS->Kolicina
                endif
                SKIP
            enddo
            select pos
        set order to tag "1"
            select (nSelect)
            if nKol>nStanje
                MsgBeep("Trenutno na stanju artikla :"+_IdRoba+" "+str(nStanje,12,2))
                if gPratiStanje="!"
                    lFlag:=.f.
                endif
            endif
    endif
endif


return (lFlag)
*}


/*! \fn NarProvDuple()
 *  \brief 
 */
static function NarProvDuple()
*{

local nPrevRec
local lFlag:=.t.

if gDupliArt=="D".and.gDupliUpoz=="N"
    // mogu dupli i nema upozorenja
    return .t.
endif

select _pos_pripr
nPrevRec:=RECNO()

if _idroba='PLDUG  ' .and. reccount2()<>0
    return .f.
endif

set order to tag "1"
seek 'PLDUG  '
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
*}


/*! \fn IspraviNarudzbu()
 *  \brief Ispravka racuna, narudzbe
 */  
 
function IspraviNarudzbu()
*{

//
// Koristi privatnu varijablu oBrowse iz UNESINARUDZBU

local cGetId
local nGetKol
local aConds
local aProcs

UnSetSpecNar()

OpcTipke({"<Enter>-Ispravi stavku","<B>-Brisi stavku","<Esc>-Zavrsi"})

oBrowse:autolite:=.t.
oBrowse:configure()

// spasi ono sto je bilo u GET-u
cGetId:=_idroba
nGetKol:=_Kolicina

aConds:={{|Ch| Ch == ASC ("b") .OR. Ch == ASC ("B")},{|Ch| Ch == K_ENTER}}
aProcs:={{|| BrisStavNar (oBrowse)},{|| EditStavNar (oBrowse)}}

ShowBrowse(oBrowse,aConds,aProcs)

oBrowse:autolite:=.f.
oBrowse:dehilite()
oBrowse:stabilize()

// vrati stari meni
Prozor0()

// OpcTipke (aUnosMsg)
// vrati sto je bilo u GET-u
_idroba:=cGetId
_Kolicina:=nGetKol

SetSpecNar()
return
*}


/*! \fn BrisStavNar(oBrowse)
 *  \param oBrowse
 */
 
function BrisStavNar(oBrowse)
*{
//      Brise stavku narudzbe
//      Koristi privatni parametar OBROWSE iz SHOWBROWSE
select _pos_pripr

if RecCount2()==0
    MsgBeep ("Narudzba nema nijednu stavku!#Brisanje nije moguce!", 20)
    return (DE_REFRESH)
endif

Beep (2)

// ponovo izracunaj ukupno
nIznNar-=_pos_pripr->(Kolicina*Cijena)
nPopust-=_pos_pripr->(Kolicina*NCijena)

// osvjezi cijene
@ m_x+3,m_y+70 SAY nIznNar pict "99999.99" COLOR Invert
@ m_x+4,m_y+70 SAY nPopust pict "99999.99" COLOR Invert
@ m_x+5,m_y+70 SAY nIznNar-nPopust pict "99999.99" COLOR Invert

DELETE    // _PRIPR

oBrowse:refreshAll()

do while !oBrowse:stable 
    oBrowse:Stabilize()
enddo

return (DE_REFRESH)
*}


/*! \fn EditStavNar()
 *  \brief
 */
 
function EditStavNar()
*{

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

cParticip:="D"
if _nCijena==0
    cParticip:="N"
endif
// apoteke !!!
select odj
hseek roba->idodj 
select _pos_pripr
if RIGHT(odj->naz,5)=="#1#0#" .or. RIGHT(odj->naz,6)=="#1#50#"
    set cursor on
        @ m_x+3,m_y+25 SAY "particip:" GET cParticip pict "@!" valid cParticip $ "DN"
        read
        if cParticip=="D"
            _Ncijena:=1
        else
            _NCijena:=0
        endif
else
        @ m_x+3,m_Y+25  SAY SPACE(11)
endif

if LASTKEY()<>K_ESC
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
                Gather () //_PRIPR
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
    if (gPopVar=="A" .and. _pos_pripr->ncijena<> _NCijena)
            // samo za apoteke
            replace ncijena with _ncijena
    endif
endif
BoxC()
@ m_x+3,m_y+70 SAY nIznNar pict "99999.99" COLOR Invert
@ m_x+4,m_y+70 SAY nPopust pict "99999.99" COLOR Invert
@ m_x+5,m_y+70 SAY nIznNar-nPopust pict "99999.99" COLOR Invert
oBrowse:refreshCurrent()
do while !oBrowse:stable 
    oBrowse:Stabilize()
enddo

return (DE_CONT)
*}


/*! \fn GetReader2(oGet,GetList,oMenu,aMsg)
 *  \param oGet
 *  \param GetList
 *  \param oMenu
 *  \param aMsg
 */
 
function GetReader2(oGet, GetList, oMenu, aMsg)
*{

local nKey
local nRow
local nCol

if (GetPreValSC(oGet, aMsg))
        oGet:setFocus()
    do while ( oGet:exitState == GE_NOEXIT )
            if (gOcitBarcod .and. gEntBarCod=="D")
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
*}

