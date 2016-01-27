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


static _pict := "@Z 999999999.99"


// --------------------------------------------
// stampa liste naloga
// --------------------------------------------
function mat_dnevnik_naloga()
local _line
local _dug
local _pot
local _dug2
local _pot2
local _rbr
local _row_pos

O_MAT_NALOG
SELECT mat_nalog
set order to tag "1"
GO TOP

START PRINT CRET

_line := _get_line()
_rbr := 0
_row_pos := 0

_dug := 0
_pot := 0
_dug2 := 0
_pot2 := 0

DO WHILE !EOF()
   
    IF prow()==0
        _zaglavlje( _line )
    ENDIF

    DO WHILE !EOF() .AND. prow()<66
        @ prow() + 1, 0 SAY ++_rbr PICTURE "9999"
        @ prow(), pcol()+2 SAY field->IdFirma
        @ prow(), pcol()+2 SAY field->IdVN
        @ prow(), pcol()+2 SAY field->BrNal
        @ prow(), pcol()+1 SAY field->DatNal
        _row_pos := pcol()
        @ prow(), pcol()+1 SAY field->Dug  picture _pict
        @ prow(), pcol()+1 SAY field->Pot  picture _pict
        @ prow(), pcol()+1 SAY field->Dug2 picture _pict
        @ prow(), pcol()+1 SAY field->Pot2 picture _pict
      
        _dug += field->Dug
        _pot += field->Pot
        _dug2 += field->Dug2
        _pot2 += field->Pot2
        
        SKIP
    ENDDO
    IF prow() > 65
        FF
    ENDIF
ENDDO

? _line
? "UKUPNO:"
@ prow(), _row_pos + 1 SAY _dug        picture _pict
@ prow(), pcol() + 1 SAY _pot  picture _pict
@ prow(), pcol() + 1 SAY _dug2 picture _pict
@ prow(), pcol() + 1 SAY _pot2 picture _pict
? _line

FF
ENDPRINT

my_close_all_dbf()
return


// -------------------------------------------
// zaglavlje izvjestaja
// -------------------------------------------
static function _zaglavlje( line )
local _r_line_1
local _r_line_2
        
P_COND
        
?? "DNEVNIK NALOGA NA DAN:"
@ prow(), pcol() + 2 SAY DATE()
        
? line

_r_line_1 := PADR( "*RED", 4 )
_r_line_2 := PADR( "*BRD", 4 )

_r_line_1 += PADR( "*FIR", 4 )
_r_line_2 += PADR( "*MA", 4 )

_r_line_1 += PADR( "* V", 4 )
_r_line_2 += PADR( "* N", 4 )

_r_line_1 += PADR( "* BR", 6 )
_r_line_2 += PADR( "* NAL", 6 )

_r_line_1 += PADR( "* DAT", 9 )
_r_line_2 += PADR( "* NAL", 9 )

_r_line_1 += PADR( "*   DUGUJE", 13 )
_r_line_2 += PADR( "*   " + ValDomaca(), 13 )

_r_line_1 += PADR( "* POTRAZUJE", 13 )
_r_line_2 += PADR( "*   " + ValDomaca(), 13 )

_r_line_1 += PADR( "*   DUGUJE", 13 )
_r_line_2 += PADR( "*   " + ValPomocna(), 13 )

_r_line_1 += PADR( "* POTRAZUJE", 13 )
_r_line_2 += PADR( "*   " + ValPomocna(), 13 )

? _r_line_1
? _r_line_2
       
? line
 
return


// vraca liniju za report
static function _get_line()
local _line := ""

_line := REPLICATE( "-", 4 )
_line += SPACE(1)
_line += REPLICATE( "-", 3 )
_line += SPACE(1)
_line += REPLICATE( "-", 3 )
_line += SPACE(1)
_line += REPLICATE( "-", 5 )
_line += SPACE(1)
_line += REPLICATE( "-", 8 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )
_line += SPACE(1)
_line += REPLICATE( "-", 12 )

return _line



