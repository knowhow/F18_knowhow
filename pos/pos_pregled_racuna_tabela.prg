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



function pos_pregled_racuna_tabela()
local fScope := .t.
local cFil0
local cTekIdPos := gIdPos
private aVezani := {}
private dMinDatProm := ctod("")

// datum kada je napravljena promjena na racunima
// unutar PRacuni, odnosno P_SRproc setuje se ovaj datum

O_SIFK
O_SIFV
O_KASE
O_ROBA
O__POS_PRIPR
O_POS_DOKS
O_POS

dDatOd := DATE()
dDatDo := DATE()

qIdRoba := SPACE( LEN( POS->idroba ) )

SET CURSOR ON

Box(,2,60)
    @ m_x + 1, m_y + 2 SAY "Datumski period:" GET dDatOd
    @ m_x + 1, col() + 2 SAY "-" GET dDatDo
	@ m_x + 2, m_y + 2 SAY "Prodajno mjesto:" GET gIdPos VALID P_Kase(@gIdPos)
    read
BoxC()

if LastKey() == K_ESC
    close all
    return
endif

cFil0 := ""

if !EMPTY(dDatOd).and.!EMPTY(dDatDo)
	cFil0 := "datum >= " + _filter_quote( dDatOD ) + " .and. datum <= " + _filter_quote( dDatDo ) + " .and. "
endif

pos_lista_racuna(,,,fScope, cFil0, qIdRoba )  

CLOSE ALL

gIdPos := cTekIdPos

return




