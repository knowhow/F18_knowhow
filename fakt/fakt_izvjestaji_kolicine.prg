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


#include "fakt.ch"


// ---------------------------------
// otvara potrebne tabele
// ---------------------------------
static function _o_tables()
O_FAKT
O_PARTN
O_VALUTE
O_RJ
O_SIFK
O_SIFV
O_ROBA
O_OPS
return



// -----------------------------------------------------------------------
// setuje u parametrima robu koja ce se pojavljivati na izvjestajima
// -----------------------------------------------------------------------
static function set_articles()
local _x := 1
local _count := 20
local _tmp, _i
local _ok := .t.
local _art_1, _art_2, _art_3, _art_4, _art_5, _art_6, _art_7, _art_8, _art_9, _art_10
local _art_11, _art_12, _art_13, _art_14, _art_15, _art_16, _art_17, _art_18, _art_19, _art_20
local _var, _valid_block

// procitaj paramtre iz sql/db
for _i := 1 to _count
    _var := "_art_" + ALLTRIM(STR(_i))
    &_var := PADR( fetch_metric( "fakt_pregled_prodaje_rpt_artikal_" + PADL( ALLTRIM(STR(_i)), 2, "0"), NIL, SPACE(10) ), 10 )
next

Box(, _count + 2, 65 )
    
    @ m_x + _x, m_y + 2 SAY "Izvjestaj se pravi za sljedece artikle:"

    ++ _x
    ++ _x
    
    _i := 1

    for _i := 1 to _count
   
        _var := "_art_" + ALLTRIM(STR(_i))
        _valid_block := "EMPTY(_art_" + ALLTRIM(STR(_i))+ ") .or. P_Roba(@_art_" + ALLTRIM(STR(_i)) + ")"
        @ m_x + _x, m_y + 2 SAY "Artikal " +  PADL( ALLTRIM(STR(_i)), 2 ) + ":" GET &_var VALID &_valid_block

        ++ _x   

    next

    read

BoxC()

// snimi parametre
if LastKey() != K_ESC

    // snimi parametre
    _i := 1

    for _i := 1 to _count

        _var := "_art_" + ALLTRIM( STR( _i ) )
        set_metric( "fakt_pregled_prodaje_rpt_artikal_" + PADL( ALLTRIM(STR(_i)), 2, "0"), NIL, ALLTRIM( &_var ) )

    next

endif

return _ok




// --------------------------------------------
// vraca matricu sa robom i definicijom polja
// praznu
// --------------------------------------------
static function _g_ini_roba( )
local _arr := {}
local _i
local _param_count := 20
local _item
local _count := 0

for _i := 1 to _param_count
  
    // item uzimam iz sql/db
    _item := fetch_metric( "fakt_pregled_prodaje_rpt_artikal_" + PADL( ALLTRIM( STR( _i ) ), 2, "0" ), NIL, "" )
    
    if !EMPTY( _item )

        ++ _count

        AADD( _arr, { _item, "ROBA" + ALLTRIM( STR( _count ) ), 0 } ) 
    
    endif

next

return _arr



// --------------------------------------------------
// vraca matricu sa definicijom polja exp.tabele
// aRoba = [ field_naz, sifra_robe, opis_robe   ] 
// --------------------------------------------------
static function _g_exp_fields( article_arr )
local aFields := {}
local _i

AADD(aFields, {"rbr", "C", 10, 0 })
AADD(aFields, {"distrib", "C", 60, 0 })
AADD(aFields, {"pm_idbroj", "C", 13, 0 })
AADD(aFields, {"pm_naz", "C", 100, 0 })
AADD(aFields, {"pm_tip", "C", 20, 0 })
AADD(aFields, {"pm_mjesto", "C", 20, 0 })
AADD(aFields, {"pm_ptt", "C", 10, 0 })
AADD(aFields, {"pm_adresa", "C", 60, 0 })
AADD(aFields, {"pm_kt_br", "C", 20, 0 })

for _i := 1 to LEN( article_arr )
    AADD( aFields, { article_arr[ _i, 2 ], "N", 15, 5 })
next

AADD( aFields, {"ukupno", "N", 15, 5 })

return aFields


// -------------------------------------------
// filuje export tabelu sa podacima
// -------------------------------------------
static function fill_exp_tbl( cRbr, cDistrib, cPmId, cPmNaz, ;
        cPmTip, cPmMj, cPmPtt, cPmAdr, cPmKtBr, aRoba )
local _t_area
local _i
local _total := 0

_t_area := SELECT()

O_R_EXP
append blank
replace field->rbr with cRbr
replace field->distrib with cDistrib
replace field->pm_idbroj with cPmId
replace field->pm_naz with cPmNaz
replace field->pm_tip with cPmTip
replace field->pm_mjesto with cPmMj
replace field->pm_ptt with cPmPtt
replace field->pm_adresa with cPmAdr
replace field->pm_kt_br with cPmKtBr

// dodaj za robu...
for _i := 1 to LEN( aRoba )
    replace field->&( aRoba[ _i, 2] ) with aRoba[ _i, 3 ]
    _total += aRoba[ _i, 3 ]
next

replace field->ukupno with _total

select (_t_area)

return



// ---------------------------------------
// specifikacija prodaje
// ---------------------------------------
function spec_kol_partn()
local _x := 1
local _define := "N"
local aRoba 
local cPartner
local cRoba
local cIdFirma
local dDatod
local dDatDo
local cFilter
local cDistrib

_o_tables()

cIdfirma := gFirma
dDatOd := CTOD("")
dDatDo := DATE()
cDistrib := PADR("10", 6)

Box("#SPECIFIKACIJA PRODAJE PO PARTNERIMA",12,77)

    cIdFirma := PADR( cIdFirma, 2 )
        
    @ m_x + _x, m_y + 2 SAY "RJ            " GET cIdFirma ;
        VALID {|| EMPTY(cIdFirma) .or. ;
        cIdFirma == gFirma .or. P_RJ( @cIdFirma ), cIdFirma := LEFT( cIdFirma, 2), .t. }
        
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Od datuma " GET dDatOd
    @ m_x + _x, col() + 1 SAY "do" GET dDatDo
    
    ++ _x
    
    @ m_x + _x, m_y + 2 SAY "Distributer   " GET cDistrib VALID P_Firma(@cDistrib)

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Definisi artikle za izvjestaj (D/N) ?" GET _define VALID _define $ "DN" PICT "@!"

    READ
        
    ESC_BCR
    
BoxC()

// definisi artikle koji ce se naci na izvjestaju...
if _define == "D"
    set_articles()    
endif

// inicijalizuj matricu "aRoba"
aRoba := _g_ini_roba()

if LEN( aRoba ) = 0
    msgbeep("Potrebno definisati artikle za izvjestaj !!!")
    return
endif

aExpFields := _g_exp_fields( aRoba )
t_exp_create(aExpFields)
cLaunch := exp_report()

_o_tables()

select partn
seek cDistrib
cDistNaz := field->naz

select fakt
set order to tag "6"
//idfirma + idpartner + idroba + idtipdok + dtos(datum)

// postavi filter
cFilter := "idtipdok == '10' "

if (!empty(dDatOd) .or. !empty(dDatDo))
    cFilter+=".and.  datdok>=" + Cm2Str(dDatOd) + " .and. datdok<="+Cm2Str(dDatDo)
endif

if (!empty(cIdFirma))
    cFilter+=" .and. IdFirma=" + Cm2Str(cIdFirma)
endif

// postavi filter
set filter to &cFilter 

select fakt
go top

nCount := 0

Box( , 2, 50)

@ m_x + 1, m_y + 2 SAY "generisem podatke za xls...."

do while !EOF() .and. field->idfirma == cIdFirma
    
    // resetuj aroba matricu
    _reset_aroba( @aRoba )

    cPartner := field->idpartner
    
    lUbaci := .f.
    
    // idi za jednog partnera
    do while !EOF() .and. field->idfirma == cIdFirma ;
            .and. field->idpartner == cPartner 
            
        cRoba := field->idroba
        nKol := field->kolicina
        
        nScan := ASCAN( aRoba, {|xvar| xvar[1] == ALLTRIM(cRoba)  })

        // ubaci u matricu...
        if nScan <> 0

            lUbaci := .t.
            
            aRoba[ nScan, 3 ] := aRoba[ nScan, 3 ] + nKol   
            
            @ m_x + 2, m_y + 2 SAY "  scan: " + cRoba

        endif
        
        skip
    
    enddo

    if lUbaci == .t.
        
        select partn
        seek cPartner
        select fakt

        fill_exp_tbl( ;
            ALLTRIM(STR(++nCount)), ;
            cDistNaz, ;
            IzSifK( "PARTN", "REGB", cPartner, .f.), ;
            partn->naz, ;
            IzSifK( "PARTN", "TIP", cPartner, .f. ), ;
            partn->mjesto, ;
            partn->ptt, ;
            partn->adresa, ;
            _k_br(cPartner), ;
            aRoba )

    endif

enddo

BoxC()

tbl_export( cLaunch )

return

// ----------------------------------------
// vraca broj kuce partnera
// djemala bijedica "22" <-----
// ----------------------------------------
static function _k_br( partner_id )
local _tmp := "bb"
local _ret := ""

_ret := IzSifK("PARTN", "KBR", partner_id, .f. )

if EMPTY( _ret )
    _ret := _tmp
endif

return _ret



// -----------------------------------------------
// resetuj vrijednosti u aRoba matrici
// -----------------------------------------------
static function _reset_aroba( arr )
local _i

for _i := 1 to LEN( arr )
    arr[ _i, 3 ] := 0
next

return


