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


// -------------------------------------------
// otvori potrebne tabele
// -------------------------------------------
static function o_kzb_tables()
O_MAT_NALOG
O_MAT_SUBAN
O_MAT_ANAL
O_MAT_SINT
return



// -----------------------------------------------
// kontrola zbira datoteka
// -----------------------------------------------
function mat_kzb()
local _pict := "999999999.99"
local _header

_header := PADR( "* NAZIV", 13 )      
_header += PADR( "* DUGUJE " + ValDomaca(), 13 )
_header += PADR( "* POTRAZ." + ValDomaca(), 13 )
_header += PADR( "* DUGUJE " + ValPomocna(), 13 ) 
_header += PADR( "* POTRAZ." + ValPomocna(), 13 )

o_kzb_tables()

Box("KZB",10,77,.f.)

    set cursor off

    @ m_x + 1, m_y + 2 SAY _header

    select mat_nalog

    go top
    
    nDug:=nPot:=nDug2:=nPot2:=0
    
    DO WHILE !EOF() .and. INKEY()!=27
        nDug+=Dug
        nPot+=Pot
        nDug2+=Dug2
        nPot2+=Pot2
        SKIP
    ENDDO

    ESC_BCR

    @ m_x+3,m_y+2 SAY PADL( "NALOZI", 13 )
    @ row(),col()+1 SAY nDug PICT _pict
    @ row(),col()+1 SAY nPot PICT _pict
    @ row(),col()+1 SAY nDug2 PICT _pict
    @ row(),col()+1 SAY nPot2 PICT _pict

    select mat_sint
    nDug:=nPot:=nDug2:=nPot2:=0
    go top
    DO WHILE !EOF() .and. INKEY()!=27
        nDug+=Dug; nPot+=Pot
        nDug2+=Dug2; nPot2+=Pot2
        SKIP
    ENDDO
    ESC_BCR
    @ m_x+5,m_y+2 SAY PADL( "SINTETIKA", 13 )
    @ row(),col()+1 SAY nDug PICTURE _pict
    @ row(),col()+1 SAY nPot PICTURE _pict
    @ row(),col()+1 SAY nDug2 PICTURE _pict
    @ row(),col()+1 SAY nPot2 PICTURE _pict


    select mat_anal
    nDug:=nPot:=nDug2:=nPot2:=0
    go top
    DO WHILE !EOF() .and. INKEY()!=27
        nDug+=Dug; nPot+=Pot
        nDug2+=Dug2; nPot2+=Pot2
        SKIP
    ENDDO
    ESC_BCR
    @ m_x+7,m_y+2 SAY PADL( "ANALITIKA", 13 )
    @ row(),col()+1 SAY nDug PICTURE _pict
    @ row(),col()+1 SAY nPot PICTURE _pict
    @ row(),col()+1 SAY nDug2 PICTURE _pict
    @ row(),col()+1 SAY nPot2 PICTURE _pict

    select mat_suban
    nDug:=nPot:=nDug2:=nPot2:=0
    go top
    DO WHILE !EOF() .and. INKEY()!=27
        if D_P=="1"
            nDug+=Iznos; nDug2+=Iznos2
        else
            nPot+=Iznos; nPot2+=Iznos2
        endif
        SKIP
    ENDDO
    ESC_BCR
    @ m_x+9,m_y+2 SAY PADL( "SUBANALITIKA", 13 )
    @ row(),col()+1 SAY nDug PICTURE _pict
    @ row(),col()+1 SAY nPot PICTURE _pict
    @ row(),col()+1 SAY nDug2 PICTURE _pict
    @ row(),col()+1 SAY nPot2 PICTURE _pict

    Inkey(0)
BoxC()

my_close_all_dbf()
return


