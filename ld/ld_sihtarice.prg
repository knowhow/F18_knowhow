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


// -----------------------------------------------
// definisanje sihtarice
// -----------------------------------------------
function def_siht( lNew )
local nBoxX := 10
local nBoxY := 65
local nX := 1
local cIdRadn := SPACE(6)
local nGodina := gGodina
local nMjesec := gMjesec
local cGroup := SPACE(7)
local cOpis := SPACE(50)

select (F_RADSIHT)
if !used()
    O_RADSIHT
endif

select radsiht
set order to tag "2"

Box(, nBoxX, nBoxY )
    
   do while .t.

    @ m_x + nX, m_y + 2 SAY "*** Unos / obrada sihtarica po grupama"
    
    ++ nX
    ++ nX

    @ m_x + nX, m_y + 2 SAY "godina" GET nGodina PICT "9999"
    @ m_x + nX, col() + 2 SAY "mjesec" GET nMjesec PICT "99"

    ++ nX
    
    @ m_x + nX, m_y + 2 SAY "grupa:" GET cGroup ;
        VALID { || p_konto( @cGroup ), ;
            _show_get_item_value( g_gr_naz( cGroup ), 40 ) }

    ++ nX

    @ m_x + nX, m_y + 2 SAY "opis:" GET cOpis PICT "@S40"

    ++ nX
    
    @ m_x + nX, m_y + 2 SAY "radnik:" GET cIdRadn ;
        VALID { || p_radn( @cIdRadn ), ;
            _show_get_item_value( _rad_ime( cIdRadn), 30 )}

    read

    if LastKey() == K_ESC
        exit
    endif

    // pronadji ovaj zapis u RADSIHT
    select radsiht
    go top
    seek cGroup + STR(nGodina) + STR(nMjesec) + cIdRadn

    if !FOUND()

        append blank
        set_global_memvars_from_dbf()

        _godina := nGodina
        _mjesec := nMjesec
        _idkonto := cGroup
        _opis := cOpis
        _idradn := cIdRadn
        _dandio := "G"
        _izvrseno := 0
        _bodova := 0

    else

        set_global_memvars_from_dbf()

    endif

    ++ nX
    ++ nX

    @ m_x + nX, m_y + 2 SAY "broj odradjenih sati:" GET _izvrseno ;
        PICT "99999.99"

    ++ nX
    
    @ m_x + nX, m_y + 2 SAY "od toga nocni rad:" GET _bodova ;
        PICT "99999.99"

    read

    if LastKey() == K_ESC
        exit
    endif
    
    _vals := get_dbf_global_memvars() 

    update_rec_server_and_dbf( "ld_radsiht", _vals, 1, "FULL" ) 

    // resetuj varijable
    cIdRadn := SPACE(6)

    nX := 1

   enddo
    
BoxC()

return


// ---------------------------------------------------
// uslovi izvjestaja
// ---------------------------------------------------
static function g_vars( nGod, nMj, cRadn, cGroup )
local nRet := 1
private GetList := {}

Box(, 2, 60)
    @ m_x + 1, m_y + 2 SAY "Godina" GET nGod PICT "9999"
    @ m_x + 1, col() + 2 SAY "Godina" GET nMj PICT "99"
    @ m_x + 2, m_y + 2 SAY "Grupa" GET cGroup ;
        VALID EMPTY(cGroup) .or. p_konto(@cGroup)
    @ m_x + 2, col() + 2 SAY "Radnik" GET cRadn ;
        VALID EMPTY(cRadn) .or. p_radn(@cRadn)
    read
BoxC()

if LastKey() == K_ESC
    nRet := 0
endif

return nRet



// --------------------------------------------
// daj mi obradjene sihtarice
// 
// lInfo - za prikaz na kartici .t.
// vraca ukupne sate radnika
// --------------------------------------------
function get_siht( lInfo, nGodina, nMjesec, cIdRadn, cGroup )
local nTArea := SELECT()
local cFilter := ""
local nLineLen := 100
local nVar := 1

select F_RADN
if !used()
    O_RADN
endif

if pcount() <= 1
    
    // nema parametara unesenih
    nMjesec := gMjesec
    nGodina := gGodina
    cGroup := SPACE(7)
    cIdRadn := SPACE(6)

    if g_vars( @nGodina, @nMjesec, @cIdRadn, @cGroup ) == 0
        return
    endif

endif

if pcount() == 0
    lInfo := .f.
endif

if !EMPTY( cIdRadn )
    nLineLen := 80
endif

if lInfo == .t.
    nVar := 0
endif

sort_siht( nGodina, nMjesec, cIdRadn, cGroup, nVar )

if nVar > 0
    set order to tag "2"
else
    set order to tag "2i"
endif

go top

if lInfo == .f.
    START PRINT CRET
    ?
endif

? "Lista satnica po sihtarici: ", STR(nMjesec) + "/" + STR(nGodina) 
? REPLICATE( "-", nLineLen )
? PADR("rbr", 4), ;
    PADR("objekat", 30), ;
    if(EMPTY(cIdRadn), PADR("radnik", 20), ""), ;
    PADR("sati", 15), PADR("nocni",15), PADR("redovni",15)

? REPLICATE( "-", nLineLen )

nT_sati := 0
nT_nsati := 0
nT_razl := 0

nTCol := 30

nCnt := 0

do while !EOF()

    ? PADL( ALLTRIM(STR(++nCnt)) + ".", 4 )
    @ prow(), pcol()+1 SAY PADR( g_gr_naz( field->idkonto ), 30 )
    
    if EMPTY( cIdRadn )
        @ prow(), pcol()+1 SAY PADR( _rad_ime( field->idradn ), 20 )
    endif

    @ prow(), nTCol := pcol()+1 SAY STR( field->izvrseno, 12, 2 )
    @ prow(), pcol()+1 SAY STR( field->bodova, 12, 2 )
    @ prow(), pcol()+1 SAY STR( field->izvrseno - field->bodova, 12, 2 )

    nT_sati += field->izvrseno
    nT_nsati += field->bodova
    nT_razl += field->izvrseno - field->bodova

    skip
enddo

? REPLICATE("-", nLineLen )
? "UKUPNO SATI:"
@ prow(), nTCOL SAY STR(nT_sati, 12, 2)
@ prow(), pcol()+1 SAY STR(nT_nsati, 12, 2)
@ prow(), pcol()+1 SAY STR(nT_razl, 12, 2)
? REPLICATE("-", nLineLen )

if lInfo == .f.
    FF
    END PRINT
endif

select F_RADN
if !used()
    O_RADN
endif

select F_RADSIHT
if !used()
    O_RADSIHT
endif

go top
set filter to

select (nTArea)
return nT_sati



// --------------------------------------------
// lista sihtarice
// 
// --------------------------------------------
function get_siht2()
local nTArea := SELECT()
local cFilter := ""
local nLineLen := 70
local nMjesec
local nGodina
local cGroup
local cIdRadn
local nCol := 12
local aSiht
local i

// nema parametara unesenih
nMjesec := gMjesec
nGodina := gGodina
cGroup := SPACE(7)
cIdRadn := SPACE(6)

select F_RADN
if !used()
    O_RADN
endif

if g_vars( @nGodina, @nMjesec, @cIdRadn, @cGroup ) == 0
    return
endif

sort_siht( nGodina, nMjesec, cIdRadn, cGroup )
set order to tag "4"
// "4","idradn+str(godina)+str(mjesec)+idkonto"
go top

START PRINT CRET
?

? "Lista satnica po sihtarici: ", STR(nMjesec) + "/" + STR(nGodina) 
? REPLICATE( "-", nLineLen )
? PADR("rbr", 5), PADR("radnik", 20), PADR("sati", 15), PADR("nocni", 15), ;
    PADR("redovni", 15)
? REPLICATE( "-", nLineLen )

nT_sati := 0
nT_nsati := 0

nT_tsati := 0
nT_tnsati := 0

nT_razl := 0
nT_trazl := 0

nCnt := 0

aSiht := {}

// zavrti se po radnicima...
do while !EOF()

  cId_radn := field->idradn
  nT_sati := 0
  nT_nsati := 0
  nT_razl := 0

  do while !EOF() .and. field->idradn == cId_radn

    nT_sati += field->izvrseno
    nT_nsati += field->bodova
    nT_razl += field->izvrseno - field->bodova

    nT_tsati += field->izvrseno
    nT_tnsati += field->bodova
    nT_trazl += field->izvrseno - field->bodova

    skip
  
  enddo

  AADD( aSiht, { PADR(_rad_ime(cId_radn), 20), STR(nT_sati,12,2), ;
    STR(nT_nsati, 12, 2), STR(nT_razl, 12, 2) } )

enddo

if LEN( aSiht ) > 0

  // napravi sortiranje
  ASORT( aSiht,,,{|x,y| x[1] < y[1] } )

  // sada ispisi
  for i:=1 to len( aSiht )

    // ispisi ukupno
    ? PADL( ALLTRIM( STR( ++nCnt, 4 )) + ".", 5 )
    @ prow(), pcol()+1 SAY aSiht[i, 1]
    @ prow(), nCol := pcol()+1 SAY aSiht[i, 2]
    @ prow(), pcol()+1 SAY aSiht[i, 3]
    @ prow(), pcol()+1 SAY aSiht[i, 4]

  next

  ? REPLICATE("-", nLineLen )
  ? "UKUPNO SATI: "
  @ prow(), nCol SAY STR( nT_tsati, 12, 2 )
  @ prow(), pcol()+1 SAY STR( nT_tnsati, 12, 2 )
  @ prow(), pcol()+1 SAY STR( nT_trazl, 12, 2 )
  ? REPLICATE("-", nLineLen )

endif

FF
END PRINT

select F_RADN
if !used()
    O_RADN
endif

select F_RADSIHT
if !used()
    O_RADSIHT
endif

go top
set filter to

select (nTArea)
return


// ------------------------------------------------------------
// sortiranje sihtarice
// ------------------------------------------------------------
function sort_siht( nGodina, nMjesec, cIdRadn, cGroup, nVar )
local cFilter

if nVar == nil
    nVar := 0
endif

cFilter := "godina =" + STR( nGodina )  
cFilter += " .and. mjesec = " + STR( nMjesec )
cFilter += " .and. dandio == 'G' "

if !EMPTY( cIdRadn )
    cFilter += " .and. idradn == " + cm2str( cIdRadn )
endif

if !EMPTY( cGroup )
    cFilter += " .and. idkonto == " + cm2str( cGroup )
endif

select (F_RADSIHT)
if !used()
    O_RADSIHT
endif

select radsiht
set filter to &cFilter
set order to tag "2"
go top

if nVar == 1
    set order to tag "2i"
    go top
endif

return


// ------------------------------------------
// brisanje sihtarice
// ------------------------------------------
function del_siht()
local nMjesec := gMjesec
local nGodina := gGodina
local cGroup := SPACE(7)
local cIdRadn := SPACE(6)
local nTArea := SELECT()
local cFilter := ""
local _rec, _t_rec

if g_vars( @nGodina, @nMjesec, @cIdRadn, @cGroup ) == 0
    return
endif

sort_siht( nGodina, nMjesec, cIdRadn, cGroup )

if Pitanje(,"Pobrisati zapise sa ovim kriterijem (D/N)","N") == "N"
    return
endif

set order to tag "2"
go top

nCnt := 0
do while !EOF()

    ++ nCnt

    SKIP 1
    _t_rec := RECNO() 
    SKIP -1

    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( "ld_radsiht", _rec )

    GO ( _t_rec )

enddo

go top
set filter to

msgbeep("pobrisao " + ALLTRIM(STR(nCnt)) + " zapisa..." )

return



// ------------------------------------------------
// prikazuje cItem u istom redu gdje je get
// cItem - string za prikazati
// nPadR - n vrijednost pad-a
// ------------------------------------------------
function _show_get_item_value(cItem, nPadR)

if nPadR <> nil
    cItem := PADR( cItem, nPadR )
endif
@ row(), col() + 3 SAY cItem

return .t.


// ------------------------------------------------
// vraca ime i prezime radnika
// ------------------------------------------------
function _rad_ime( cId, lImeOca )
local xRet := ""
local nTArea := SELECT()

if lImeOca == nil
    lImeOca := .f.
endif

select (F_RADN)
if !used()
    O_RADN
endif

seek cId

xRet := ALLTRIM( field->ime )
xRet += " "
if lImeOca == .t.
    xRet += "(" + ALLTRIM( field->imerod ) + ") "
endif
xRet += ALLTRIM( field->naz )

select (nTArea)
return xRet




