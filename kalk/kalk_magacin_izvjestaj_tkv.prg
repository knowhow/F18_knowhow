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

static __LEN_OPIS := 70


// -----------------------------------------
// izvjestaj TKV
// -----------------------------------------
function kalk_tkv()
local _vars
local _calc_rec := 0

// skeleton ::

// uslovi izvjestaja...
if !get_vars( @_vars )
    return
endif

// generisanje izvjestaja
_calc_rec := kalk_gen_fin_stanje_magacina( _vars )

if _calc_rec > 0
    // stampaj TKV izvjestaj
    stampaj_tkv( _vars )
endif

return


// -----------------------------------------
// uslovi izvjestaja
// -----------------------------------------
static function get_vars( vars )
local _ret := .f.
local _x := 1
local _konta := fetch_metric( "kalk_tkv_konto", my_user(), SPACE(200) )
local _d_od := fetch_metric( "kalk_tkv_datum_od", my_user(), DATE()-30 )
local _d_do := fetch_metric( "kalk_tkv_datum_do", my_user(), DATE() )
local _vr_dok := fetch_metric( "kalk_tkv_vrste_dok", my_user(), SPACE(200) )
local _usluge := fetch_metric( "kalk_tkv_gledati_usluge", my_user(), "N" )
local _tip := fetch_metric( "kalk_tkv_tip_obrasca", my_user(), "P" )
local _vise_konta := "D"

Box(, 12, 70)

    @ m_x + _x, m_y + 2 SAY "*** magacin - izvjestaj TKV"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Datum od" GET _d_od
    @ m_x + _x, col() + 1 SAY "do" GET _d_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "     Konto (prazno-svi):" GET _konta PICT "@S35"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Vrste dok. (prazno-svi):" GET _vr_dok PICT "@S35"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Gledati [N] nabavne cijene [P] prodajne cijene ?" GET _tip PICT "@!" ;
            VALID _tip $ "PN"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Gledati usluge (D/N) ?" GET _usluge PICT "@!" VALID _usluge $ "DN"

    read

BoxC()

if LastKey() == K_ESC
    return _ret
endif

_ret := .t.

// snimi hash matricu...
vars := hb_hash()
vars["datum_od"] := _d_od
vars["datum_do"] := _d_do
vars["konto"] := _konta
vars["vrste_dok"] := _vr_dok
vars["gledati_usluge"] := _usluge
vars["tip_obrasca"] := _tip
// ako postoji tacka u kontu onda gledaj
if RIGHT( ALLTRIM( _konta ), 1 ) == "."
    _vise_konta := "N"
endif
vars["vise_konta"] := _vise_konta

// snimi sql/db parametre
set_metric( "kalk_tkv_konto", my_user(), _konta )
set_metric( "kalk_tkv_datum_od", my_user(), _d_od )
set_metric( "kalk_tkv_datum_do", my_user(), _d_do )
set_metric( "kalk_tkv_vrste_dok", my_user(), _vr_dok )
set_metric( "kalk_tkv_gledati_usluge", my_user(), _usluge )
set_metric( "kalk_tkv_tip_obrasca", my_user(), _tip )

return _ret



// ------------------------------------------
// stampa izvjestaja TKV
// ------------------------------------------
static function stampaj_tkv( vars )
local _red_br := 0
local _line, _opis_knjizenja
local _n_opis, _n_iznosi
local _t_dug, _t_pot, _t_rabat
local _a_opis := {}
local _i
local _tip_obrasca := vars["tip_obrasca"]

// daj mi liniju za report...
_line := _get_line()

START PRINT CRET

?
P_COND

// ispisi zaglavlje izvjestaja
tkv_zaglavlje( vars )

// stampaj header izvjestaja
? _line
tkv_header()
? _line

_t_dug := 0
_t_pot := 0
_t_rabat := 0

select r_export
go top

do while !EOF()

    // preskoci ako su stavke = 0
    if ( ROUND( field->vp_saldo, 2 ) == 0 .and. ROUND( field->nv_saldo, 2 ) == 0 )
        skip
        loop
    endif

    // 1. red izvjestaja...

    // redni broj...
    ? PADL( ALLTRIM( STR( ++_red_br ) ), 6 ) + "."

    // datum dokumenta
    @ prow(), pcol() + 1 SAY field->datum

    // generisi string za opis knjizenja...
    _opis_knjizenja := ALLTRIM( field->vr_dok )
    _opis_knjizenja += " "
    _opis_knjizenja += "broj: "
    _opis_knjizenja += ALLTRIM( field->idvd ) + "-" + ALLTRIM( field->brdok )
    _opis_knjizenja += ", "
    _opis_knjizenja += "veza: " + ALLTRIM( field->br_fakt )
    _opis_knjizenja += ", "
    _opis_knjizenja += ALLTRIM( field->part_naz )
    _opis_knjizenja += ", "
    _opis_knjizenja += ALLTRIM( field->part_adr )
    _opis_knjizenja += ", "
    _opis_knjizenja += ALLTRIM( field->part_mj )

    _a_opis := SjeciStr( _opis_knjizenja, __LEN_OPIS )

    // opis knjizenja
    @ prow(), _n_opis := pcol() + 1 SAY _a_opis[ 1 ]

    if _tip_obrasca == "N"

        // zaduzenje bez PDV
        @ prow(), _n_iznosi := pcol() + 1 SAY STR( field->nv_dug, 12, 2 )

        // razduzenje bez PDV
        @ prow(), pcol() + 1 SAY STR( field->vp_pot, 12, 2 )

    elseif _tip_obrasca == "P"

        // zaduzenje bez PDV
        @ prow(), _n_iznosi := pcol() + 1 SAY STR( field->vp_dug, 12, 2 )

        // razduzenje bez PDV
        @ prow(), pcol() + 1 SAY STR( field->vp_pot, 12, 2 )

    endif

    // odobreni rabat
    @ prow(), pcol() + 1 SAY STR( field->vp_rabat, 12, 2 )

    if _tip_obrasca == "N"
        _t_dug += field->nv_dug
    elseif _tip_obrasca == "P"
        _t_dug += field->vp_dug
    endif

    _t_pot += field->vp_pot

    _t_rabat += field->vp_rabat

    // 2, 3... red izvjestaja...
    // radi opisnog polja...

    for _i := 2 to LEN( _a_opis )
        ?
        @ prow(), _n_opis SAY _a_opis[ _i ]
    next

    skip

enddo

? _line

// stampaj ukupno
? "UKUPNO:"
@ prow(), _n_iznosi SAY STR( _t_dug, 12, 2 )
@ prow(), pcol() + 1 SAY STR( _t_pot, 12, 2 )
@ prow(), pcol() + 1 SAY STR( _t_rabat, 12, 2 )

? "SALDO TRGOVACKE KNJIGE:"
@ prow(), _n_iznosi SAY STR( _t_dug - _t_pot , 12, 2 )

? _line

FF
END PRINT

return



// ----------------------------------------
// vraca liniju za report
// ----------------------------------------
static function _get_line()
local _line

_line := ""
_line += REPLICATE( "-", 7 )
_line += SPACE(1)
_line += REPLICATE( "-", 8 )
_line += SPACE(1)
_line += REPLICATE( "-", __LEN_OPIS )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )

return _line


// -----------------------------------------
// zaglavlje izvjestaja
// -----------------------------------------
static function tkv_zaglavlje( vars )

? gFirma, "-", ALLTRIM( gNFirma )
?
? SPACE(10), "TRGOVACKA KNJIGA NA VELIKO (TKV) za period od:", vars["datum_od"], "do:", vars["datum_do"]
?
? "Uslov za skladista: "

if !EMPTY( ALLTRIM( vars["konto"] ) )
    ?? ALLTRIM( vars["konto"] )
else
    ?? " sva skladista"
endif

? "na dan", DATE()

?

return


// -----------------------------------------
// header izvjestaja
// -----------------------------------------
static function tkv_header()
local _row_1, _row_2

_row_1 := ""
_row_2 := ""

_row_1 += PADR( "R.Br", 7 )
_row_2 += PADR( "", 7 )

_row_1 += SPACE(1)
_row_2 += SPACE(1)

_row_1 += PADC( "Datum", 8 )
_row_2 += PADC( "dokum.", 8 )

_row_1 += SPACE(1)
_row_2 += SPACE(1)

_row_1 += PADR( "", __LEN_OPIS )
_row_2 += PADR( "Opis knjizenja", __LEN_OPIS )

_row_1 += SPACE(1)
_row_2 += SPACE(1)

_row_1 += PADC( "Zaduzenje", 12 )
_row_2 += PADC( "bez PDV-a", 12 )

_row_1 += SPACE(1)
_row_2 += SPACE(1)

_row_1 += PADC( "Razduzenje", 12 )
_row_2 += PADC( "bez PDV-a", 12 )

_row_1 += SPACE(1)
_row_2 += SPACE(1)

_row_1 += PADC( "Odobreni", 12 )
_row_2 += PADC( "rabat", 12 )

? _row_1
? _row_2

return
