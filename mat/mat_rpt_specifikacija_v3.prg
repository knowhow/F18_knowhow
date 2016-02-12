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


static PicDEM := "999999999.99"
static PicBHD := "999999999.99"
static PicKol := "99999999.999"


// -------------------------------------------------
// otvara potrebne tabele za report
// -------------------------------------------------
static function _o_rpt_tables()
O_ROBA
O_SIFK
O_SIFV
O_MAT_SUBAN
O_PARTN
return



// ------------------------------------------------
// uslovi izvjestaja
// ------------------------------------------------
static function _get_vars( params )
local _fmt
local _firma
local _konta
local _artikli
local _dat_od
local _dat_do
local _group
local _group_sifra
local _sel_groups
local _group_lista
local _cnt := 1
local _ret := .t.

// inicijalizujem def.parametre
_fmt := "2"
_firma := gFirma
_konta := SPACE(200)
_artikli := SPACE(200)
_dat_od := CTOD( "" )
_dat_do := CTOD( "" )
_group := "N"
_sel_groups := SPACE(200)
_vrijednost := "N"
_group_sifra := "N"
_group_lista := "N"

// uzmi parametre iz sql/db
_firma := fetch_metric( "mat_rpt_specifikacija_firma", my_user(), _firma )
_konta := fetch_metric( "mat_rpt_specifikacija_konta", my_user(), _konta )
_artikli := fetch_metric( "mat_rpt_specifikacija_artikli", my_user(), _artikli )
_dat_od := fetch_metric( "mat_rpt_specifikacija_datum_od", my_user(), _dat_od )
_dat_do := fetch_metric( "mat_rpt_specifikacija_datum_do", my_user(), _dat_do )
_group := fetch_metric( "mat_rpt_specifikacija_grupe", my_user(), _group )
_group_sifra := fetch_metric( "mat_rpt_specifikacija_grupe_iz_sifre", my_user(), _group_sifra )
_group_lista := fetch_metric( "mat_rpt_specifikacija_sadrzaj_grupe", my_user(), _group_lista )
_sel_groups := fetch_metric( "mat_rpt_specifikacija_selektovane_grupe", my_user(), _sel_groups )
_vrijednost := fetch_metric( "mat_rpt_specifikacija_samo_vrijednost", my_user(), _vrijednost )


Box( "Spe2", 13, 65, .f. )

    ++ _cnt

    @ m_x + _cnt, m_y + 2 SAY "Iznos u " + ValDomaca() + "/" + ValPomocna() + "(1/2) ?" GET _fmt ;
                VALID _fmt $ "12"
    read
    
    if _fmt == "1"
        _fmt := "2"
    else
        _fmt := "3"
    endif

    ++ _cnt
    ++ _cnt

    if gNW $ "DR"
        @ m_x + _cnt, m_y + 2 SAY "Firma "
        ?? gFirma, "-", gNFirma
    else
        @ m_x + _cnt, m_y + 2 SAY "Firma: " GET _firma ;
            VALID {|| P_Firma( @_firma ), _firma := left( _firma, 2 ), .t. }
    endif

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Konta : " GET _konta PICT "@S50"
    
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Artikli : " GET _artikli PICT "@S50"
    
    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Datum dokumenta - od:" GET _dat_od
    @ m_x + _cnt, col() + 1 SAY "do:" GET _dat_do VALID _dat_do >= _dat_od

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Prikaz po grupacijama (D/N)?" GET _group ;
        VALID _group $ "DN" PICT "@!"

    @ m_x + _cnt, col() + 1 SAY "Grupu uzmi iz sifre (D/N)?" GET _group_sifra ;
        VALID _group_sifra $ "DN" PICT "@!"

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Grupe:" GET _sel_groups PICT "@S50"

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Prikazati sadrzaj grupe (D/N)?" GET _group_lista ;
        VALID _group_lista $ "DN" PICT "@!"

    ++ _cnt
    @ m_x + _cnt, m_y + 2 SAY "Prikaz samo vrijednosti" GET _vrijednost PICT "@!" VALID _vrijednost $ "DN"

    read

BoxC()

if LastKey() == K_ESC
    _ret := .f.
    return _ret
endif

// hash parametre napuni sa varijablama
params["format"] := _fmt
params["firma"] := _firma
params["konta"] := _konta
params["artikli"] := _artikli
params["dat_od"] := _dat_od
params["dat_do"] := _dat_do
params["po_grupi"] := _group
params["grupa_na_osnovu_sifre"] := _group_sifra
params["grupe"] := _sel_groups
params["samo_vrijednost"] := _vrijednost
params["listaj_sadrzaj_grupe"] := _group_lista

// snimi parametre u sql/db
set_metric( "mat_rpt_specifikacija_firma", my_user(), _firma )
set_metric( "mat_rpt_specifikacija_konta", my_user(), _konta )
set_metric( "mat_rpt_specifikacija_artikli", my_user(), _artikli )
set_metric( "mat_rpt_specifikacija_datum_od", my_user(), _dat_od )
set_metric( "mat_rpt_specifikacija_datum_do", my_user(), _dat_do )
set_metric( "mat_rpt_specifikacija_grupe", my_user(), _group )
set_metric( "mat_rpt_specifikacija_grupe_iz_sifre", my_user(), _group_sifra )
set_metric( "mat_rpt_specifikacija_selektovane_grupe", my_user(), _sel_groups )
set_metric( "mat_rpt_specifikacija_samo_vrijednost", my_user(), _vrijednost )
set_metric( "mat_rpt_specifikacija_sadrzaj_grupe", my_user(), _group_lista )

return _ret



// -------------------------------------------------
// linija za ogranicavanje na izvjestaju
// -------------------------------------------------
static function _get_line( r_format, params )
local _line := ""

_line += REPLICATE( "-", 4 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 40 )
_line += SPACE(1)
_line += REPLICATE( "-", 3 )

if params["samo_vrijednost"] == "N"

    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )

endif

if r_format == "1"    
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
endif

_line += SPACE(1)
_line += REPLICATE( "-", LEN( PICDEM ) )
_line += SPACE(1)
_line += REPLICATE( "-", LEN( PICDEM ) )
_line += SPACE(1)
_line += REPLICATE( "-", LEN( PICDEM ) )

if r_format == "1"
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
    _line += SPACE(1)
    _line += REPLICATE( "-", LEN( PICDEM ) )
endif 

return _line



// ----------------------------------------------------
// sinteticka specifikacija
// ----------------------------------------------------
function mat_sint_specifikacija()
local _params := hb_hash()
local _usl_1
local _usl_2
local _dat_od
local _dat_do
local _firma
local _fmt
local _line
local _filter := ""
local _a_tmp
local _samo_vrijednost

// otvori potrebne tabele
_o_rpt_tables()

// daj mi uslove izvjestaja
if !_get_vars( @_params )
    my_close_all_dbf()
    return
endif

// kreiraj pomocnu tabelu izvjestaja
_cre_tmp_tbl()

// otvori tabele izvjestaja
_o_rpt_tables()
	
_usl_1 := Parsiraj( _params["konta"], "IdKonto", "C" )
_usl_2 := Parsiraj( _params["artikli"], "IdRoba", "C" )
_dat_od := _params["dat_od"]
_dat_do := _params["dat_do"]
_firma := LEFT( _params["firma"], 2 )
_fmt := _params["format"]
_samo_vrijednost := _params["samo_vrijednost"]

select mat_suban   
// "IdFirma+IdRoba+dtos(DatDok)"
set order to tag "1"

// napravi filter...
_filter := "idfirma == " + dbf_quote( _firma )

if _usl_1 != ".t."
    _filter += " .and. " + _usl_1
endif

if _usl_2 != ".t."
    _filter += " .and. " + _usl_2
endif

if !empty( _dat_od ) .or. !empty( _dat_do )
    _filter += " .and. DTOS(datdok) <= " + dbf_quote( DTOS( _dat_do ) )
    _filter += " .and. DTOS(datdok) >= " + dbf_quote( DTOS( _dat_od ) )
endif

set filter to &_filter

go top

EOF CRET

msgO( "Punim pomocnu tabelu izvjestaja..." )

// napuni pomocnu tabelu podacima
_fill_rpt_data( _params )

msgC()

// daj mi liniju za izvjestaj
_line := _get_line( _fmt, _params )

START PRINT CRET

if _params["po_grupi"] == "D"
    _show_report_grupe( _params, _line )
else
    _show_report( _params, _line )
endif

FF
ENDPRINT

my_close_all_dbf()

return


// ------------------------------------------------------
// filuje pomocnu tabelu izvjestaja
// ------------------------------------------------------
static function _fill_rpt_data( param )
local _dug_1, _pot_1, _dug_2, _pot_2
local _ulaz_k_1, _izlaz_k_1, _ulaz_k_2, _izlaz_k_2
local _saldo_k_1, _saldo_k_2, _saldo_i_1, _saldo_i_2
local _id_roba

select mat_suban

do while !EOF()
   
    _id_roba := field->idroba

    // resetuj brojace...
    _dug_1 := 0
    _pot_1 := 0
    _dug_2 := 0
    _pot_2 := 0
    _ulaz_k_1 := 0
    _izlaz_k_1 := 0
    _ulaz_k_2 := 0
    _izlaz_k_2 := 0
    _saldo_k_1 := 0
    _saldo_k_2 := 0
    _saldo_i_1 := 0
    _saldo_i_2 := 0

    do while !EOF() .and. _id_roba = field->idroba

        // saberi ulaze/izlaze
        if field->u_i = "1"
            _ulaz_k_1 += field->kolicina
        else
            _izlaz_k_1 += field->kolicina
        endif
        
        // saberi iznose d/p
        if field->d_p = "1"
            _dug_1 += field->iznos
            _dug_2 += field->iznos2
        else
            _pot_1 += field->iznos
            _pot_2 += field->iznos2
        endif
        
        skip
    
    enddo

    select roba
    HSEEK _id_roba

    // da li se grupa odredjuje putem sifre ili iz sifk ?
    if param["grupa_na_osnovu_sifre"] == "D"
        _roba_gr := PADR( _id_roba, 2 )
    else
        // ovdje cemo smjestiti grupaciju...
        _roba_gr := IzSifKRoba("GR1", _id_roba, .f. )
    endif

    select mat_suban

    _saldo_k_1 := _ulaz_k_1 - _izlaz_k_1
    _saldo_i_1 := _dug_1 - _pot_1
    _saldo_k_2 := _ulaz_k_2 - _izlaz_k_2
    _saldo_i_2 := _dug_2 - _pot_2
    
     _fill_tmp_tbl( _id_roba, _roba_gr, roba->naz, roba->jmj, ;
			roba->nc, roba->vpc, roba->mpc, ;
            "", "", "", "", ;
			_ulaz_k_1, _ulaz_k_2, _izlaz_k_1, _izlaz_k_2, ;
            _saldo_k_1, _saldo_k_2, ;
            _dug_1, _dug_2, _pot_1, _pot_2, ;
            _saldo_i_1, _saldo_i_2 )

    select mat_suban

enddo


return




// ---------------------------------------------
// ispisi izvjestaj
// ---------------------------------------------
static function _show_report( params, line )
local _mark_pos
local _rbr
local _uk_dug_1, _uk_dug_2, _uk_pot_1, _uk_pot_2
local _id_roba, _roba_naz, _roba_jmj
local _fmt := params["format"]

?
_mark_pos := 0

// stampaj zaglavlje
_zaglavlje( params, line )

select r_export
set order to tag "1"
go top

_rbr := 0
_uk_dug_1 := 0
_uk_pot_1 := 0
_uk_dug_2 := 0
_uk_pot_2 := 0

do while !EOF()
   
    // provjera novog reda... 
    if prow() > 63
        FF
    endif

    @ prow() + 1, 0 SAY ++_rbr PICT '9999'
    @ prow(), pcol() + 1 SAY field->id_roba
    @ prow(), pcol() + 1 SAY PADR( field->roba_naz, 40 )
    @ prow(), pcol() + 1 SAY field->roba_jmj

    if _fmt == "1"
        @ prow(), pcol() + 1 SAY field->roba_nc PICT PICDEM
        @ prow(), pcol() + 1 SAY field->roba_vpc PICT PICDEM
        @ prow(), pcol() + 1 SAY field->roba_mpc PICT PICDEM
    endif

    @ prow(), pcol() + 1 SAY field->ulaz_1 PICT PICKOL
    @ prow(), pcol() + 1 SAY field->izlaz_1 PICT PICKOL
    @ prow(), pcol() + 1 SAY field->saldo_k_1 PICT PICKOL
    
    _mark_pos := pcol()
     
    if _fmt $ "12"
        @ prow(),pcol()+1 SAY field->dug_1 PICT PicDEM
        @ prow(),pcol()+1 SAY field->pot_1 PICT PicDEM
        @ prow(),pcol()+1 SAY field->saldo_i_1 PICT PicDEM
    endif
     
    if _fmt $ "13"
        @ prow(),pcol()+1 SAY field->dug_2 PICT PicBHD
        @ prow(),pcol()+1 SAY field->pot_2 PICT PicBHD
        @ prow(),pcol()+1 SAY field->saldo_i_2 PICT PicBHD
    endif

    _uk_dug_1 += field->dug_1
    _uk_pot_1 += field->pot_1
    _uk_dug_2 += field->dug_2
    _uk_pot_2 += field->pot_2

    select r_export
    skip

enddo

?  line
?  "UKUPNO :"

@  prow(), _mark_pos SAY ""

if _fmt $ "12"  
    @ prow(), pcol() + 1 SAY _uk_dug_1 PICT PicDEM
    @ prow(), pcol() + 1 SAY _uk_pot_1 PICT PicDEM
    @ prow(), pcol() + 1 SAY ( _uk_dug_1 - _uk_pot_1 ) PICT PicDEM
endif

if _fmt $ "13"
    @ prow(), pcol() + 1 SAY _uk_dug_2 PICT PicBHD
    @ prow(), pcol() + 1 SAY _uk_pot_2 PICT PicBHD
    @ prow(), pcol() + 1 SAY ( _uk_dug_2 - _uk_pot_2 ) PICT PicBHD
endif

? line

return



// ---------------------------------------------
// ispisi izvjestaj po grupama
// ---------------------------------------------
static function _show_report_grupe( params, line )
local _mark_pos
local _rbr
local _uk_dug_1, _uk_dug_2, _uk_pot_1, _uk_pot_2
local _fmt := params["format"]
local _grupa
local _u_ulaz, _u_izlaz, _u_sld_k, _u_dug_1, _u_dug_2, _u_pot_1, _u_pot_2
local _u_sld_i_1, _u_sld_i_2


?
_mark_pos := 0

// stampaj zaglavlje
_zaglavlje( params, line )

select r_export
set order to tag "2"
go top

_rbr := 0

_uk_dug_1 := 0
_uk_pot_1 := 0
_uk_dug_2 := 0
_uk_pot_2 := 0

do while !EOF()
   
    // provjera novog reda... 
    if prow() > 63
        FF
    endif

    _grupa := field->grupa
     
    // provjeri da li postoji uslov za grupacije...
    if !EMPTY( params["grupe"] )
        if ! ( ALLTRIM( _grupa ) $ params["grupe"] )
            select r_export
            skip
            loop
        endif
    endif

    _u_ulaz := 0
    _u_izlaz := 0
    _u_sld_k := 0
    _u_dug_1 := 0 
    _u_dug_2 := 0 
    _u_pot_1 := 0
    _u_pot_2 := 0
    _u_sld_i_1 := 0
    _u_sld_i_2 := 0
    _gr_count := 0

    // ako je listanje sadrzaja grupe
    if params["listaj_sadrzaj_grupe"] == "D"
        // postavi zaglavlje za grupu...
        @ prow() + 1, 0 SAY "Sadrzaj grupe " + _grupa
        ? line
    endif

    do while !EOF() .and. field->grupa == _grupa

        if !EMPTY( params["grupe"] )
            if ! ( ALLTRIM( _grupa ) $ params["grupe"] )
                select r_export
                skip
                loop
            endif
        endif

        if params["listaj_sadrzaj_grupe"] == "D"
            // ispisi za svaku grupu...
            
            @ prow() + 1, 0 SAY ++_gr_count PICT '9999'
            @ prow(), pcol() + 1 SAY PADR( ALLTRIM( field->id_roba ) + " - " + ALLTRIM( field->roba_naz ) + " (" + field->roba_jmj + ")" , 50 )
  
            if params["samo_vrijednost"] == "N"
  
                @ prow(), pcol() + 1 SAY field->ulaz_1 PICT picKol
                @ prow(), pcol() + 1 SAY field->izlaz_1 PICT picKol
                @ prow(), pcol() + 1 SAY field->saldo_k_1 PICT picKol

            endif

            if _fmt $ "12"
                @ prow(),pcol()+1 SAY field->dug_1 PICT PicDEM
                @ prow(),pcol()+1 SAY field->pot_1 PICT PicDEM
                @ prow(),pcol()+1 SAY field->saldo_i_1 PICT PicDEM
            endif
     
            if _fmt $ "13"
                @ prow(),pcol()+1 SAY field->dug_2 PICT PicBHD
                @ prow(),pcol()+1 SAY field->pot_2 PICT PicBHD
                @ prow(),pcol()+1 SAY field->saldo_i_2 PICT PicBHD
            endif

        endif

        // saberi totale...
        _u_ulaz += field->ulaz_1
        _u_izlaz += field->izlaz_1
        _u_sld_k += field->saldo_k_1

        _u_dug_1 += field->dug_1
        _u_dug_2 += field->dug_2
        _u_pot_1 += field->pot_1
        _u_pot_2 += field->pot_2

        _u_sld_i_1 += field->saldo_i_1
        _u_sld_i_2 += field->saldo_i_2

        skip

    enddo
   
    // liniju postavi ako postoji sadrzaj grupe...
    if params["listaj_sadrzaj_grupe"] == "D"
        ? line
    endif
 
    @ prow() + 1, 0 SAY ++_rbr PICT '9999'
    @ prow(), pcol() + 1 SAY PADR( "Ukupno grupa: " + _grupa, 55 )
  
    if params["samo_vrijednost"] == "N"
  
        @ prow(), pcol() + 1 SAY _u_ulaz PICT picKol
        @ prow(), pcol() + 1 SAY _u_izlaz PICT picKol
        @ prow(), pcol() + 1 SAY _u_sld_k PICT picKol

    endif

    _mark_pos := pcol()
     
    if _fmt $ "12"
        @ prow(),pcol()+1 SAY _u_dug_1 PICT PicDEM
        @ prow(),pcol()+1 SAY _u_pot_1 PICT PicDEM
        @ prow(),pcol()+1 SAY _u_sld_i_1 PICT PicDEM
    endif
     
    if _fmt $ "13"
        @ prow(),pcol()+1 SAY _u_dug_2 PICT PicBHD
        @ prow(),pcol()+1 SAY _u_pot_2 PICT PicBHD
        @ prow(),pcol()+1 SAY _u_sld_i_2 PICT PicBHD
    endif

    // liniju postavi ako postoji sadrzaj grupe...
    if params["listaj_sadrzaj_grupe"] == "D"
        ? line
    endif

    _uk_dug_1 += _u_dug_1
    _uk_pot_1 += _u_pot_1
    _uk_dug_2 += _u_dug_2
    _uk_pot_2 += _u_pot_2

    select r_export
    skip

enddo

?  line
?  "UKUPNO (sve grupe) :"

@  prow(), _mark_pos SAY ""

if _fmt $ "12"  
    @ prow(), pcol() + 1 SAY _uk_dug_1 PICT PicDEM
    @ prow(), pcol() + 1 SAY _uk_pot_1 PICT PicDEM
    @ prow(), pcol() + 1 SAY ( _uk_dug_1 - _uk_pot_1 ) PICT PicDEM
endif

if _fmt $ "13"
    @ prow(), pcol() + 1 SAY _uk_dug_2 PICT PicBHD
    @ prow(), pcol() + 1 SAY _uk_pot_2 PICT PicBHD
    @ prow(), pcol() + 1 SAY ( _uk_dug_2 - _uk_pot_2 ) PICT PicBHD
endif

? line

return



// ------------------------------------------------
// filovanje pomocne tabele 
// ------------------------------------------------
static function _fill_tmp_tbl( id_roba, grupa, roba_naz, roba_jmj, ;
			roba_nc, roba_vpc, roba_mpc, ;
            id_konto, konto_naz, id_partner, partn_naz, ;
			ulaz_1, ulaz_2, izlaz_1, izlaz_2, ;
            saldo_k_1, saldo_k_2, ;
            dug_1, dug_2, pot_1, pot_2, ;
            saldo_i_1, saldo_i_2 )

local _arr := SELECT()

select (F_R_EXP)
if !used()
    O_R_EXP
endif

append blank
replace field->id_roba with id_roba
replace field->grupa with grupa
replace field->roba_naz with roba_naz
replace field->roba_jmj with roba_jmj
replace field->roba_nc with roba_nc
replace field->roba_vpc with roba_vpc
replace field->roba_mpc with roba_mpc
replace field->id_konto with id_konto
replace field->konto_naz with konto_naz
replace field->id_partner with id_partner
replace field->partn_naz with partn_naz
replace field->ulaz_1 with ulaz_1
replace field->ulaz_2 with ulaz_2
replace field->izlaz_1 with izlaz_1
replace field->izlaz_2 with izlaz_2
replace field->saldo_k_1 with saldo_k_1
replace field->saldo_k_2 with saldo_k_2
replace field->dug_1 with dug_1
replace field->dug_2 with dug_2
replace field->pot_1 with pot_1
replace field->pot_2 with pot_2
replace field->saldo_i_1 with saldo_i_1
replace field->saldo_i_2 with saldo_i_2

select (_arr)

return


// -------------------------------------------------------
// vraca matricu pomocne tabele za izvjestaj
// -------------------------------------------------------
static function _cre_tmp_tbl()
local _dbf := {}

AADD( _dbf, { "id_roba",  "C",  10, 0 } )
AADD( _dbf, { "grupa",    "C",  20, 0 } )
AADD( _dbf, { "roba_naz", "C", 100, 0 } )
AADD( _dbf, { "roba_jmj", "C",   3, 0 } )
AADD( _dbf, { "roba_nc",  "N", 12, 3 } )
AADD( _dbf, { "roba_vpc", "N", 12, 3 } )
AADD( _dbf, { "roba_mpc", "N", 12, 3 } )
AADD( _dbf, { "id_konto", "C", 7, 0 } )
AADD( _dbf, { "konto_naz","C", 50, 0 } )
AADD( _dbf, { "id_partner", "C", 6, 0 } )
AADD( _dbf, { "partn_naz", "C", 100, 0 } )
AADD( _dbf, { "ulaz_1", "N", 15, 3 } )
AADD( _dbf, { "ulaz_2", "N", 15, 3 } )
AADD( _dbf, { "izlaz_1", "N", 15, 3 } )
AADD( _dbf, { "izlaz_2", "N", 15, 3 } )
AADD( _dbf, { "dug_1", "N", 15, 3 } )
AADD( _dbf, { "dug_2", "N", 15, 3 } )
AADD( _dbf, { "pot_1", "N", 15, 3 } )
AADD( _dbf, { "pot_2", "N", 15, 3 } )
AADD( _dbf, { "saldo_k_1", "N", 15, 3 } )
AADD( _dbf, { "saldo_k_2", "N", 15, 3 } )
AADD( _dbf, { "saldo_i_1", "N", 15, 3 } )
AADD( _dbf, { "saldo_i_2", "N", 15, 3 } )

// kreiraj tabelu
t_exp_create( _dbf )

O_R_EXP
// indeksiraj...
index on id_roba tag "1" 
index on grupa tag "2" 

return




// ------------------------------------------------------------
// zaglavlje izvestaja...
// ------------------------------------------------------------
static function _zaglavlje( param, line )
local _r_line_1 := ""
local _r_line_2 := ""
local _r_line_3 := ""

P_COND2
?

@ prow(), 0 SAY "MAT.P: SPECIFIKACIJA ROBE (U "

if param["format"] == "1"
    ?? ValPomocna() + "/" + ValDomaca() + ") "
elseif param["format"] == "2"
    ?? ValPomocna() + ") "
else
    ?? ValDomaca() + ") "
endif
    
if !empty( param["dat_od"] ) .or. !empty( param["dat_do"] )
    ?? "ZA PERIOD OD", param["dat_od"], "-", param["dat_do"]
endif
   
?? "      NA DAN:"
@ prow(), pcol() + 1 SAY DATE()

@ prow() + 1, 0 SAY "FIRMA:"
@ prow(), pcol() + 1 SAY param["firma"]

select partn
HSEEK param["firma"]

@ prow(), pcol() + 1 SAY field->naz
@ prow(), pcol() + 1 SAY field->naz2
   
? "Kriterij za " + KonSeks("konta") + ":", trim( param["konta"] )
   
? line

// definisi nazive kolona
_r_line_1 += "*R. "
_r_line_2 += "*Br."
_r_line_3 += "*   "

if param["po_grupi"] == "N"

    _r_line_1 += "*  SIFRA   "
    _r_line_2 += "*          "
    _r_line_3 += "*          "

    _r_line_1 += "*       N A Z I V                        "
    _r_line_2 += "*                                        "
    _r_line_3 += "*                                        "

else

    _r_line_1 += "*  GRUPACIJA                                        "
    _r_line_2 += "*                                                   "
    _r_line_3 += "*                                                   "

endif

_r_line_1 += "*J. "
_r_line_2 += "*MJ."
_r_line_3 += "*   "

if param["samo_vrijednost"] == "N"

    _r_line_1 += "*" + PADC( "K O L I C I N A", LEN( PICKOL ) * 3 + 2 )
    _r_line_2 += REPLICATE( "-", LEN( PICKOL ) * 3 + 2 )
    _r_line_3 += "*" + PADC( "ULAZ", LEN( PICKOL ) )
    _r_line_3 += "*" + PADC( "IZLAZ", LEN( PICKOL ) )
    _r_line_3 += "*" + PADC( "STANJE", LEN( PICKOL ) )

endif

_r_line_1 += "*" + PADC( "V R I J E D N O S T", LEN( PICDEM ) * 3 + 2 ) + "*"
_r_line_2 += REPLICATE( "-", LEN( PICDEM ) * 3 + 2 )
_r_line_3 += "*" + PADC( "DUGUJE", LEN( PICDEM ) )
_r_line_3 += "*" + PADC( "POTRAZUJE", LEN( PICDEM ) ) 
_r_line_3 += "*" + PADC( "SALDO", LEN( PICDEM ) ) + "*"

? _r_line_1
? _r_line_2
? _r_line_3
    
?  line

return



