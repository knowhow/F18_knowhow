/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


// ---------------------------------------------------------
// unos radnih sati kod obracuna plate
// ---------------------------------------------------------
function FillRadSati( cIdRadnik, nRadniSati )

// uzmi prethodne sate...
cSatiPredhodni := GetStatusRSati( cIdRadnik )   

if Pitanje(, Lokal( "Unos placenih sati (D/N)?"), "D" ) == "N"
    return VAL( cSatiPredhodni )
endif

nPlacenoRSati := 0
cOdgovor := "D"

Box(, 9, 48 )
    @ m_x + 1, m_y + 2 SAY Lokal("Radnik:   ") + ALLTRIM(cIdRadnik)
    @ m_x + 2, m_y + 2 SAY Lokal("Ostalo iz predhodnih obracuna: ") + ALLTRIM(cSatiPredhodni) + " sati"
    @ m_x + 3, m_y + 2 SAY "-----------------------------------------------"
    @ m_x + 4, m_y + 2 SAY Lokal("Uplaceno sati: ") GET nPlacenoRSati PICT "99999999" 
    read
    @ m_x + 5, m_y + 2 SAY "-----------------------------------------------"
    @ m_x + 6, m_y + 2 SAY Lokal("Radni sati ovaj mjesec  : ") + ALLTRIM(STR(nRadniSati))
    @ m_x + 7, m_y + 2 SAY Lokal("Placeni sati ovaj mjesec: ") + ALLTRIM(STR(nPlacenoRSati))
    @ m_x + 8, m_y + 2 SAY Lokal("Ostalo ") + ALLTRIM(STR(nRadniSati-nPlacenoRSati+VAL(cSatiPredhodni))) + Lokal(" sati za sljedeci mjesec !")
    @ m_x + 9, m_y + 2 SAY Lokal("Sacuvati promjene (D/N)? ") GET cOdgovor VALID cOdgovor$"DN" PICT "@!"
    read
    
    if cOdgovor=="D"    
        UbaciURadneSate( cIdRadnik, nRadniSati-nPlacenoRSati )
    else
        MsgBeep(Lokal("Promjene nisu sacuvane !!!"))
    endif
BoxC()

return VAL(cSatiPredhodni)


// ------------------------------------------------
// vraca status uplacenih sati za tekuci mjesec
// ------------------------------------------------
function GetUplaceniRSati(cIdRadn)
local nArr
local nSati := 0
nArr := SELECT()

select radsat
hseek cIdRadn

if FOUND() .and. field->idradn == cIdRadn
    nSati := field->up_sati
endif

select (nArr)

return STR(nSati)



// ------------------------------------------------
// vraca status radnih sati za obracun
// ------------------------------------------------
function GetStatusRSati(cIdRadn)
local nArr
local nSati := 0
nArr:=SELECT()

select radsat
hseek cIdRadn

if FOUND() .and. field->idradn == cIdRadn
    nSati:=field->sati
endif

select (nArr)

return STR(nSati)


// ----------------------------------------------------
// ubaci podatke u tabelu radnih sati
// ----------------------------------------------------
function UbaciURadneSate( id_radnik, iznos_sati )
local _t_area := SELECT()
local _rec

select radsat
set order to tag "IDRADN"
go top
seek id_radnik

if FOUND()
    _rec := dbf_get_rec()
    _rec["sati"] := _rec["sati"] + iznos_sati
else
    append blank
    _rec := dbf_get_rec()
    _rec["idradn"] := id_radnik
    _rec["sati"] := iznos_sati
endif

update_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )

select ( _t_area )

return


// ---------------------------------
// upisi u iznos radne sate
// ---------------------------------
function delRadSati( id_radnik, iznos_sati )
local _t_arr := SELECT()
local _rec

select radsat
set order to tag "IDRADN"
go top
seek id_radnik

if Found()    
    _rec := dbf_get_rec()
    _rec["sati"] := iznos_sati
    update_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )  
endif

select ( _t_arr )

return

// -------------------------------------------------
// ispravka pregled radnih sati
// -------------------------------------------------
function edRadniSati()
private ImeKol := {}
private Kol := {}

PushWa()

O_RADN
O_RADSAT
select radsat
set order to tag "IDRADN"
go top

private Imekol := {}

AADD(ImeKol, {"radn",         {|| IdRadn   } } )
AADD(ImeKol, {"ime i prezime", {|| g_naziv(IdRadn) } } )
AADD(ImeKol, {"sati",          {|| sati   } } )
AADD(ImeKol, {"status",        {|| status   } } )

Kol:={}

for i:=1 to LEN(ImeKol)
    AADD(Kol,i)
next

Box(, MAXROWS() - 16, MAXCOLS() - 5 )
    ObjDbedit("RadSat", MAXROWS() - 16, MAXCOLS() - 5,{|| key_handler()},"Pregled radnih sati za radnike","", , , , )
Boxc()

PopwA()

return



// ---------------------------------------
// key handler za radne sate
// ---------------------------------------
static function key_handler()
local _rec

do case
    case CH == K_F2
        
        Box(,1,40)
            nSati := field->sati
            @ m_x+1,m_y+2 SAY "novi sati:" GET nSati
            read
        BoxC()

        if LastKey() == K_ESC
            return DE_CONT
        else
            _rec := dbf_get_rec()
            _rec["sati"] := nSati
            update_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )
            return DE_REFRESH
        endif

    case CH == K_CTRL_T
        if Pitanje(,"izbrisati stavku ?","N") == "D"
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "ld_radsat", _rec, 1, "FULL" )
            return DE_REFRESH
        endif
    
    case CH == K_CTRL_P
        stRadniSati()
        return DE_CONT
endcase

return DE_CONT


// -----------------------------------------------
// printanje sadrzaja radnih sati
// -----------------------------------------------
static function stRadniSati()
local nCnt
local cTxt := ""
local cLine := ""
local aSati

select radsat
set order to tag "1"
go top

START PRINT CRET

?
P_COND

cTxt += PADR("r.br",5)
cTxt += SPACE(1)
cTxt += PADR("id", 6)
cTxt += SPACE(1)
cTxt += PADR("naziv radnika", 25)
cTxt += SPACE(1)
cTxt += PADR("radni sati", 10)
cTxt += SPACE(1)
cTxt += PADR("status", 6)

cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 6)
cLine += SPACE(1)
cLine += REPLICATE("-", 25)
cLine += SPACE(1)
cLine += REPLICATE("-", 10)
cLine += SPACE(1)
cLine += REPLICATE("-", 6)

? "Pregled radnih sati:"

? cLine
? cTxt
? cLine

aSati := {}

nCnt := 0
do while !EOF() 

    if field->sati = 0
        skip
        loop
    endif

    AADD( aSati, { idradn, PADR( g_naziv( idradn ), 25 ), sati, status } )
    
    skip
enddo

// sada istampaj
// napravi sort po ime+prezime
ASORT( aSati,,,{|x,y| x[2] < y[2] } )

for i:=1 to LEN( aSati )
    
    ? PADL( ALLTRIM( STR( ++ nCnt )), 4 ) + "."
    @ prow(), pcol()+1 SAY aSati[i, 1]
    @ prow(), pcol()+1 SAY aSati[i, 2]
    @ prow(), pcol()+1 SAY aSati[i, 3]
    @ prow(), pcol()+1 SAY aSati[i, 4]

next

? cLine

FF
END PRINT

return




