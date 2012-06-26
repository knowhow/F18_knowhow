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


#include "kalk.ch"

 

function vise_kalk_dok_u_pripremi(cIdd)

if field->idPartner + field->brFaktP + field->idKonto + field->idKonto2 <> cIdd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
endif

return

// -----------------------------------------------------
// prikaz dodatnih informacija za dokument
// -----------------------------------------------------
function show_more_info( cPartner, dDatum, cFaktura, cMU_I )
local cRet := ""
local cMIPart := ""
local cTip := ""

if !EMPTY( cPartner )
	
	// naziv partnera sa dokumenta ...
	cMIPart := ALLTRIM( Ocitaj( F_PARTN, cPartner, "NAZ" ) )

	if cMU_I == "1"
		cTip := "dob.:"
	else
		cTip := "kup.:"
	endif

	cRet := DTOC( dDatum )
	cRet += ", "
	cRet += "br.dok: "
	cRet += ALLTRIM( cFaktura )
	cRet += ", "
	cRet += cTip 
	cRet += " " 
	cRet += cPartner 
	cRet += " ("
	cRet += cMIPart
	cRet += ")"
	
endif

return cRet


// --------------------------------------------------------------
// prikazi pomoc pri unosu sa ispisom 
// --------------------------------------------------------------
function zadnji_ulazi_info( partner, id_roba, mag_prod )
local _data := {}
local _count := 3

if fetch_metric( "pregled_rabata_kod_ulaza", my_user(), "N" ) == "N"
    return .t.
endif

if mag_prod == NIL
    mag_prod := "P"
endif

_data := _kalk_get_ulazi( partner, id_roba, mag_prod )

if LEN( _data ) > 0 
    _prikazi_info( _data, mag_prod, _count )
endif

return .t.



// --------------------------------------------------------------
// prikazi pomoc pri unosu sa ispisom 
// --------------------------------------------------------------
function zadnji_izlazi_info( partner, id_roba )
local _data := {}
local _count := 3

if fetch_metric( "pregled_rabata_kod_izlaza", my_user(), "N" ) == "N"
    return .t.
endif

_data := _fakt_get_izlazi( partner, id_roba )

if LEN( _data ) > 0 
    _prikazi_info( _data, "F", _count )
endif

return .t.



// ----------------------------------------------------------
// vraca ulaze sa servera...
// ----------------------------------------------------------
static function _fakt_get_izlazi( partner, roba )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow

_qry := "SELECT idfirma, idtipdok, brdok, datdok, cijena, rabat FROM fmk.fakt_fakt " + ;
        " WHERE idpartner = " + _sql_quote( partner ) + ;
        " AND idroba = " + _sql_quote( roba ) + ;
        " AND ( idtipdok = " + _sql_quote( "10" ) + " OR idtipdok = " + _sql_quote( "11" ) + " ) " + ;
        " ORDER BY datdok"

_table := _sql_query( _server, _qry )
_table:Refresh()

for _i := 1 to _table:LastRec()

    oRow := _table:GetRow( _i )

    AADD( _data, { oRow:Fieldget( oRow:Fieldpos("idfirma") ), ;
                    oRow:Fieldget( oRow:Fieldpos("idtipdok") ) + "-" + ALLTRIM( oRow:Fieldget( oRow:Fieldpos("brdok") ) ), ;
                    oRow:Fieldget( oRow:Fieldpos("datdok") ), ;
                    oRow:Fieldget( oRow:Fieldpos("cijena") ), ;
                    oRow:Fieldget( oRow:Fieldpos("rabat") ) } )


next

return _data




// ----------------------------------------------------------
// vraca ulaze sa servera...
// ----------------------------------------------------------
static function _kalk_get_ulazi( partner, roba, mag_prod )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _u_i := "pu_i"

if mag_prod == "M"
    _u_i := "mu_i"
endif

_qry := "SELECT idkonto, idvd, brdok, datdok, nc, rabat FROM fmk.kalk_kalk WHERE idfirma = " + ;
        _sql_quote( gfirma ) + ;
        " AND idpartner = " + _sql_quote( partner ) + ;
        " AND idroba = " + _sql_quote( roba ) + ;
        " AND " + _u_i + " = " + _sql_quote( "1" ) + ;
        " ORDER BY datdok"

_table := _sql_query( _server, _qry )
_table:Refresh()

for _i := 1 to _table:LastRec()

    oRow := _table:GetRow( _i )

    AADD( _data, { oRow:Fieldget( oRow:Fieldpos("idkonto") ), ;
                    oRow:Fieldget( oRow:Fieldpos("idvd") ) + "-" + ALLTRIM( oRow:Fieldget( oRow:Fieldpos("brdok") ) ), ;
                    oRow:Fieldget( oRow:Fieldpos("datdok") ), ;
                    oRow:Fieldget( oRow:Fieldpos("nc") ), ;
                    oRow:Fieldget( oRow:Fieldpos("rabat") ) } )


next

return _data



// --------------------------------------------------------------
// prikazi info na unosu
// --------------------------------------------------------------
static function _prikazi_info( ulazi, mag_prod, ul_count )
local GetList := {}
local _line := ""
local _head := ""
local _ok := " "
local _n := 4
local _i, _len

_len := LEN( ulazi )

_head := PADR( IF( mag_prod == "F", "FIRMA", "KONTO" ), 7 )
_head += " "
_head += PADR( "DOKUMENT", 10 )
_head += " "
_head += PADR( "DATUM", 8 )
_head += " "
_head += PADL( IF (mag_prod == "F", "CIJENA", "NC" ), 12 )
_head += " "
_head += PADL( "RABAT", 13 )

do while .t.

    Box(, 5 + ul_count, 60 )

        @ m_x + 1, m_y + 2 SAY PADR( "*** Pregled rabata", 59 ) COLOR "I"
        @ m_x + 2, m_y + 2 SAY _head
        @ m_x + 3, m_y + 2 SAY REPLICATE( "-", 59 )

        for _i := _len to ( _len - ul_count ) step -1
            
            if _i > 0

                _line := PADR( ulazi[ _i, 1 ], 7 )
                _line += " "
                _line += PADR( ulazi[ _i, 2 ], 10 )
                _line += " "
                _line += DTOC( ulazi[ _i, 3 ])
                _line += " "
                _line += STR( ulazi[ _i, 4 ], 12, 2 ) 
                _line += " "
                _line += STR( ulazi[ _i, 5 ], 12, 2 ) + "%"

                @ m_x + _n, m_y + 2 SAY _line
                ++ _n

            endif

        next
        
        @ m_x + _n, m_y + 2 SAY REPLICATE( "-", 59 )
        ++ _n
        @ m_x + _n, m_y + 2 SAY "Pritisni 'ENTER' za nastavak ..." GET _ok

        read

    BoxC()

    if LastKey() == K_ENTER
        exit
    endif

enddo

return




/*! \fn PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)
 *  \brief Funkcija vraca dobavljaca cIdRobe na osnovu polja roba->dob
 *  \param cIdRoba
 *  \param nRazmak - razmak prije ispisa dobavljaca
 *  \param lNeIspisujDob - ako je .t. ne ispisuje "Dobavljac:"
 *  \return cVrati - string "dobavljac: xxxxxxx"
 */

function PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)

if lNeIspisujDob==NIL
	lNeIspisujDob:=.t.
else
	lNeIspisujDob:=.f.
endif

cIdDob:=Ocitaj(F_ROBA, cIdRoba, "SifraDob")

if lNeIspisujDob
	cVrati:=SPACE(nRazmak) + "Dobavljac: " + TRIM(cIdDob)
else
	cVrati:=SPACE(nRazmak) + TRIM(cIdDob)
endif

if !Empty(cIdDob)
	return cVrati
else
	cVrati:=""
	return cVrati
endif



function PrikTipSredstva(cKalkTip)
if !EMPTY(cKalkTip)
	? "Uslov po tip-u: "
	if cKalkTip=="D"
		?? cKalkTip, ", donirana sredstva"
	elseif cKalkTip=="K"
		?? cKalkTip, ", kupljena sredstva"
	else
		?? cKalkTip, ", --ostala sredstva"
	endif
endif

return


// ---------------------------------------
// vraca naziv objekta na osnovu konta
// ---------------------------------------
function g_obj_naz(cKto)
local cVal := ""
local nTArr

nTArr := SELECT()

O_OBJEKTI
select objekti
set order to tag "idobj"
go top
seek cKto

if FOUND()
	cVal := objekti->naz
endif

select (nTArr)

return cVal


