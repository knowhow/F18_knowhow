/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


// -----------------------------------------
// provjera podataka za migraciju f18
// -----------------------------------------
function f18_test_data()
local _a_sif := {}
local _a_data := {}
local _a_ctrl := {} 
local _chk_sif := .f.
local _c_sif := "N"
local _c_fin := "D"
local _c_kalk := "D"
local _c_fakt := "D"
local _c_ld := "D"
local _c_pdv := "D"
local _c_pos := "D"

Box(, 10, 50 )

    @ m_x + 1, m_y + 2 SAY "Provjeri sifrarnik ?" GET _c_sif VALID _c_sif $ "DN" PICT "@!"
    @ m_x + 2, m_y + 2 SAY "      Provjeri fin ?" GET _c_fin VALID _c_fin $ "DN" PICT "@!"
    @ m_x + 3, m_y + 2 SAY "     Provjeri fakt ?" GET _c_fakt VALID _c_fakt $ "DN" PICT "@!"
    @ m_x + 4, m_y + 2 SAY "     Provjeri kalk ?" GET _c_kalk VALID _c_kalk $ "DN" PICT "@!"
    @ m_x + 5, m_y + 2 SAY "       Provjeri ld ?" GET _c_ld VALID _c_ld $ "DN" PICT "@!"
    @ m_x + 6, m_y + 2 SAY "     Provjeri epdv ?" GET _c_pdv VALID _c_pdv $ "DN" PICT "@!"
    @ m_x + 7, m_y + 2 SAY "      Provjeri pos ?" GET _c_pos VALID _c_pos $ "DN" PICT "@!"

    read

BoxC()

if LastKey() == K_ESC
    return
endif

// provjeri sifrarnik
if _c_sif == "D"
    f18_sif_data( @_a_sif, @_a_ctrl )
endif

// provjeri fin
if _c_fin == "D"
    f18_fin_data( @_a_data, @_a_ctrl )
endif

// provjeri kalk
if _c_kalk == "D"
    f18_kalk_data( @_a_data, @_a_ctrl )
endif

// provjeri fakt
if _c_fakt == "D"
    f18_fakt_data( @_a_data, @_a_ctrl )
endif

// provjeri ld
if _c_ld == "D"
    f18_ld_data( @_a_data, @_a_ctrl )
endif

// provjeri epdv
if _c_pdv == "D"
    f18_epdv_data( @_a_data, @_a_ctrl )
endif

// provjeri pos
if _c_pos == "D"
    f18_pos_data( @_a_data, @_a_ctrl )
endif

// prikazi rezultat testa
f18_pr_rezultat( _a_ctrl, _a_data, _a_sif )

return


// -----------------------------------------
// provjera suban, anal, sint
// -----------------------------------------
static function f18_fin_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0
local _scan 

O_SUBAN

Box(, 2, 60 )

select suban
set order to tag "4"
go top

do while !EOF()
 
    if EMPTY( field->idfirma )
        skip
        loop    
    endif
   
    _dok := field->idfirma + "-" + field->idvn + "-" + ALLTRIM( field->brnal )
    
    @ m_x + 1, m_y + 2 SAY "fin dokument: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->iznosbhd )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "fin data", _n_c_stavke, _n_c_iznos } )
endif

return



// -----------------------------------------
// provjera fakt
// -----------------------------------------
static function f18_fakt_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0

O_FAKT

Box(, 2, 60 )

select fakt
set order to tag "1"
go top

do while !EOF()
 
    if EMPTY( field->idfirma )
        skip
        loop    
    endif

    _dok := field->idfirma + "-" + field->idtipdok + "-" + ALLTRIM( field->brdok )
    
    @ m_x + 1, m_y + 2 SAY "fakt dokument: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->kolicina + field->cijena + field->rabat )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "fakt data", _n_c_stavke, _n_c_iznos } )
endif

return


// -----------------------------------------
// provjera pos
// -----------------------------------------
static function f18_pos_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0
local _dok

O_POS

Box(, 2, 60 )

select pos
set order to tag "1"
go top

do while !EOF()
 
    if EMPTY( field->idpos )
        skip
        loop    
    endif

    _dok := field->idpos + "-" + field->idvd + "-" + ALLTRIM( field->brdok ) + ", " + DTOC( field->datum )
    
    @ m_x + 1, m_y + 2 SAY "pos dokument: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->kolicina + field->cijena + field->ncijena )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "pos data", _n_c_stavke, _n_c_iznos } )
endif

return




// -----------------------------------------
// provjera ld
// -----------------------------------------
static function f18_ld_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0

O_LD

Box(, 2, 60 )

select ld
set order to tag "1"
go top

do while !EOF()
    
    if EMPTY( field->idrj )
        skip
        loop    
    endif

    _dok := field->idrj + ", " + STR( field->godina, 4 ) + ", " + STR( field->mjesec, 2 ) + ", " + field->idradn
    
    @ m_x + 1, m_y + 2 SAY "ld stavka: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->uneto + field->i01 )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "ld data", _n_c_stavke, _n_c_iznos } )
endif

return


// -----------------------------------------
// provjera epdv
// -----------------------------------------
static function f18_epdv_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0

O_KIF
O_KUF

Box(, 2, 60 )

select kuf
set order to tag "1"
go top

do while !EOF()
    
    if EMPTY( STR( field->br_dok, 10 ) )
        skip
        loop    
    endif

    _dok := STR( field->br_dok, 10 )
    
    @ m_x + 1, m_y + 2 SAY "kuf dokument: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->i_b_pdv + field->i_pdv )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "kuf data", _n_c_stavke, _n_c_iznos } )
endif

_n_c_stavke := 0
_n_c_iznos := 0

Box(, 2, 60 )

select kif
set order to tag "1"
go top

do while !EOF()
    
    if EMPTY( STR( field->br_dok, 10 ) )
        skip
        loop    
    endif

    _dok := STR( field->br_dok, 10 )
    
    @ m_x + 1, m_y + 2 SAY "kif dokument: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->i_b_pdv + field->i_pdv )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "kif data", _n_c_stavke, _n_c_iznos } )
endif

return







// -----------------------------------------
// provjera kalk
// -----------------------------------------
static function f18_kalk_data( data, checksum )
local _n_c_iznos := 0
local _n_c_stavke := 0

O_KALK

Box(, 2, 60 )

select kalk
set order to tag "1"
go top

do while !EOF()
    
    if EMPTY( field->idfirma )
        skip
        loop    
    endif

    _dok := field->idfirma + "-" + field->idvd + "-" + ALLTRIM( field->brdok )
    
    @ m_x + 1, m_y + 2 SAY "kalk dokument: " + _dok

    // kontrolni broj
    ++ _n_c_stavke
    _n_c_iznos += ( field->kolicina + field->nc + field->vpc )

    skip

enddo

BoxC()

if _n_c_stavke > 0
    AADD( checksum, { "kalk data", _n_c_stavke, _n_c_iznos } )
endif

return






// ------------------------------------------
// prikazi rezultat
// ------------------------------------------
static function f18_pr_rezultat( a_ctrl, a_data, a_sif )
local i, d, s

START PRINT CRET
?
P_COND

? "F18 rezultati testa:", DTOC( DATE() )
? "================================"
?
? "1) Kontrolni podaci:"
? "-------------- --------------- ---------------"
? "objekat        broj zapisa     kontrolni broj"
? "-------------- --------------- ---------------"
// prvo mi ispisi kontrolne zapise
for i := 1 to LEN( a_ctrl )
    ? PADR( a_ctrl[ i, 1 ], 14 )
    @ prow(), pcol() + 1 SAY STR( a_ctrl[ i, 2 ], 15, 0 )
    @ prow(), pcol() + 1 SAY STR( a_ctrl[ i, 3 ], 15, 2 )
next

?

FF
END PRINT

return


// -----------------------------------------
// provjera sifrarnika
// -----------------------------------------
function f18_sif_data( data, checksum )

O_ROBA
O_RADN
O_PARTN
O_KONTO
O_TRFP
O_OPS
O_VALUTE
O_KONCIJ

select roba
set order to tag "ID"
go top

f18_sif_check( @data, @checksum )

select partn
set order to tag "ID"
go top

f18_sif_check( @data, @checksum )

select konto
set order to tag "ID"
go top

f18_sif_check( @data, @checksum )

select ops
set order to tag "ID"
go top

f18_sif_check( @data, @checksum )

select radn
set order to tag "ID"
go top

f18_sif_check( @data, @checksum )


return


// ------------------------------------------
// provjera sifrarnika 
// ------------------------------------------
static function f18_sif_check( data, checksum )
local _chk := "x-x"
local _scan
local _stavke := 0

do while !EOF()
    
    if EMPTY( field->id )
        skip
        loop
    endif

    ++ _stavke

    skip

enddo

if _stavke > 0
    AADD( checksum, { "sif. " + ALIAS(), _stavke, 0 } )
endif

return


 
 

