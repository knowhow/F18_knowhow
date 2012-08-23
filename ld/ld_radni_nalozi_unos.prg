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

#include "ld.ch"

function UnosSatiPoRNal(nGodina,nMjesec,cIdRadn)
private cRNal[8]
private nSati[8]

UcitajSateRNal(nGodina,nMjesec,cIdRadn)

@ m_x+10, m_y+2 SAY "Radni nalog" GET cRNal[1] VALID ValRNal(cRNal[1],1)
@ m_x+10, col()+2 SAY "sati" GET nSati[1] WHEN !EMPTY(cRNal[1]) PICT "999.99"
@ m_x+11, m_y+2 SAY "Radni nalog" GET cRNal[2] VALID ValRNal(cRNal[2],2)
@ m_x+11, col()+2 SAY "sati" GET nSati[2] WHEN !EMPTY(cRNal[2]) PICT "999.99"
@ m_x+12, m_y+2 SAY "Radni nalog" GET cRNal[3] VALID ValRNal(cRNal[3],3)
@ m_x+12, col()+2 SAY "sati" GET nSati[3] WHEN !EMPTY(cRNal[3]) PICT "999.99"
@ m_x+13, m_y+2 SAY "Radni nalog" GET cRNal[4] VALID ValRNal(cRNal[4],4)
@ m_x+13, col()+2 SAY "sati" GET nSati[4] WHEN !EMPTY(cRNal[4]) PICT "999.99"
@ m_x+14, m_y+2 SAY "Radni nalog" GET cRNal[5] VALID ValRNal(cRNal[5],5)
@ m_x+14, col()+2 SAY "sati" GET nSati[5] WHEN !EMPTY(cRNal[5]) PICT "999.99"
@ m_x+15, m_y+2 SAY "Radni nalog" GET cRNal[6] VALID ValRNal(cRNal[6],6)
@ m_x+15, col()+2 SAY "sati" GET nSati[6] WHEN !EMPTY(cRNal[6]) PICT "999.99"
@ m_x+16, m_y+2 SAY "Radni nalog" GET cRNal[7] VALID ValRNal(cRNal[7],7)
@ m_x+16, col()+2 SAY "sati" GET nSati[7] WHEN !EMPTY(cRNal[7]) PICT "999.99"
@ m_x+17, m_y+2 SAY "Radni nalog" GET cRNal[8] VALID ValRNal(cRNal[8],8)
@ m_x+17, col()+2 SAY "sati" GET nSati[8] WHEN !EMPTY(cRNal[8]) PICT "999.99"
read

if (LASTKEY() != K_ESC)
	SnimiSateRNal(nGodina,nMjesec,cIdRadn)
endif

@ m_x+10, m_y+2 CLEAR TO m_x+17,75

return


function SnimiSateRNal(nGodina,nMjesec,cIdRadn)
local nArr:=SELECT()
local nRec
local i
local _rec

select radsiht
seek str(nGodina,4)+str(nMjesec,2)+cIdRadn

do while !eof() .and. str(field->godina,4)+str(field->mjesec,2)+field->idRadn==str(nGodina,4)+str(nMjesec,2)+cIdRadn
	skip 1
	nRec:=RECNO()
	skip -1
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( ALIAS(), _rec )
	go (nRec)
enddo

for i:=1 to 8
	if !EMPTY(cRNal[i])
		append blank
        _rec := dbf_get_rec()
        _rec["godina"] := nGodina
        _rec["mjesec"] := nMjesec
        _rec["idradn"] := cIdRadn
        _rec["idrnal"] := cRnal[i]
        _rec["sati"] := nSati[i]
        update_rec_server_and_dbf( ALIAS(), _rec, 1, "FULL" )
	endif
next

select (nArr)

return

