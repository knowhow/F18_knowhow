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


#include "ld.ch"


function DlgZakljucenje()

O_OBRACUNI
O_LD_RJ

select obracuni

cRadnaJedinica:="  "
nMjObr:=gMjesec
nGodObr:=gGodina
cOdgovor:="N"
cStatus:="U"

Box(,9,40)
	@ m_x+1,m_y+2 SAY "Radna jedinica:" GET cRadnaJedinica valid P_LD_Rj(@cRadnaJedinica) PICT "@!"
      	@ m_x+2,m_y+2 SAY "Mjesec        :" GET nMjObr PICT "99"
      	@ m_x+3,m_y+2 SAY "Godina        :" GET nGodObr PICT "9999"
       	@ m_x+4,m_y+2 SAY "--------------------------------------"
       	@ m_x+5,m_y+2 SAY "Opcije: "
	@ m_x+6,m_y+2 SAY "  - otvori (U)"
	@ m_x+7,m_y+2 SAY "  - zakljuci (Z)" GET cStatus VALID cStatus$"UZ" PICT "@!"
	@ m_x+8,m_y+2 SAY "--------------------------------------"
	@ m_x+9,m_y+2 SAY "Snimiti promjene (D/N)?" GET cOdgovor VALID cOdgovor$"DN" PICT"@!"
	read

	if (cOdgovor=="D")
		if (cStatus=="Z")
			if (!f18_privgranted( "ld_unos_podataka" ))
				MsgBeep("Vi nemate pravo na zakljucenje obracuna!")
			else
				ZakljuciObr(cRadnaJedinica,nGodObr,nMjObr,"Z")
			endif
		elseif (cStatus=="U") 
			if (ProsliObrOtvoren(cRadnaJedinica,nGodObr,nMjObr))
				MsgBeep("Morate prvo zakljuciti obracun za prethodni mjesec!")
			else
				OtvoriObr(cRadnaJedinica,nGodObr,nMjObr,"U")
			endif
		endif
	endif
BoxC()

return




/*! \fn OtvoriObr(cRj,nGodina,nMjesec,cStatus)
 *  \brief Otvara obracun ili ga ponovo otvara zavisno od statusa
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status: "U" otvori novi, "P" ponovo otvori
 */
 
function OtvoriObr(cRj,nGodina,nMjesec,cStatus)

select obracuni
hseek cRj + ALLTRIM( STR( nGodina ) ) + FmtMjesec( nMjesec )

if !Found()
	AddStatusObr( cRj, nGodina, nMjesec, "U" )
	MsgBeep("Obracun otvoren !!!")
	IspisiStatusObracuna(cRj,nGodina,nMjesec)
	return
endif

if JelZakljucen(cRj,nGodina,nMjesec)
	if (!f18_privgranted("ld_unos_podataka"))
		MsgBeep("Vi nemate pravo na ponovno otvaranje zakljucenog obracuna!")
		return
	endif
	if Pitanje(,"Obracun zakljucen, otvoriti ponovo","N")=="D"
		hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)
		ChStatusObr(cRJ,nGodina,nMjesec,"P")
		MsgBeep("Obracun ponovo otvoren !!!")
		IspisiStatusObracuna(cRJ,nGodina,nMjesec)
		return
	else
		MsgBeep("Obracun nije otvoren !!!")
		return
	endif
endif

return



/*! \fn ZakljuciObr(cRj,nGodina,nMjesec,cStatus)
 *  \brief Zakljucuje obracun ili ga ponovo zakljucuje zavisno od statusa
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status: "Z" zakljuci, "X" ponovo zakljuci
 */

function ZakljuciObr(cRJ,nGodina,nMjesec,cStatus)

select obracuni
hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)

if !Found()
	MsgBeep("Potrebno prvo otvoriti obracun !!!")
	return
endif

if field->status=="U"
	ChStatusObr(cRj,nGodina,nMjesec,"Z")
	MsgBeep("Obracun zakljucen !!!")
	IspisiStatusObracuna(cRj,nGodina,nMjesec)
	return
endif

if JelOtvoren(cRj,nGodina,nMjesec)
	ChStatusObr(cRJ,nGodina,nMjesec,"X")
	MsgBeep("Obracun ponovo zakljucen !!!")
	IspisiStatusObracuna(cRj,nGodina,nMjesec)
	return
endif

return



/*! \fn JelZakljucen(cRJ,nGodina,nMjesec)
 *  \brief Provjerava da li je obracun vec zakljucen
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
function JelZakljucen(cRJ,nGodina,nMjesec)

select obracuni
hseek (cRJ+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec))
if (Found() .and. field->status=="X" .or. Found() .and. field->status=="Z")
	return .t.
else
	return .f.
endif
return


/*! \fn JelOtvoren(cRJ,nGodina,nMjesec)
 *  \brief Provjerava da li je obracun vec otvoren
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
function JelOtvoren(cRJ,nGodina,nMjesec)

select obracuni
hseek cRJ+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)
if (Found() .and. field->status=="P" .or. Found() .and. field->status=="U")
	return .t.
else
	return .f.
endif
return


/*! \fn AddStatusObr(cRJ,nGodina,nMjesec,cStatus)
 *  \brief Upisuje novi zapis u tabelu OBRACUNI ako ga nije nasao za cRJ+nGodina+nMjesec+cStatus
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status koji se provjerava
 */
function AddStatusObr(cRJ,nGodina,nMjesec,cStatus)
local _rec

select obracuni
append blank

_rec := dbf_get_rec()
_rec["rj"] := cRJ
_rec["godina"] := nGodina
_rec["mjesec"] := nMjesec
_rec["status"] := cStatus

update_rec_server_and_dbf( "ld_obracuni", _rec, 1, "FULL" )

return



/*! \fn ChStatusObr(cRJ,nGodina,nMjesec,cStatus)
 *  \brief Mjenja zapis u tabelu OBRACUNI za cRJ+nGodina+nMjesec+cStatus
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status koji se provjerava
 */
function ChStatusObr(cRJ,nGodina,nMjesec,cStatus)
local _rec
select obracuni
_rec := dbf_get_rec()
_rec["rj"] := cRJ
_rec["godina"] := nGodina
_rec["mjesec"] := nMjesec
_rec["status"] := cStatus

update_rec_server_and_dbf( "ld_obracuni", _rec, 1, "FULL" )

return


/*! \fn FmtMjesec(nMjesec)
 *  \brief Format prikaza mjeseca
 *  \param nMjesec - mjesec
 */
function FmtMjesec(nMjesec)
*{
if nMjesec<10
	cMj:=" "+ALLTRIM(STR(nMjesec))
else
	cMj:=ALLTRIM(STR(nMjesec))
endif
return cMj


/*! \fn GetObrStatus(cRJ,nGodina,nMjesec)
 *  \brief Provjerava status obracuna, ako uopste ne postoji vraca "N" inace vraca pravi status
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
function GetObrStatus(cRj,nGodina,nMjesec)
local nArr

nArr:=SELECT()

if gZastitaObracuna <> "D"
	return ""
endif

O_OBRACUNI
select obracuni
set order to tag "RJ"
hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)

if !Found()
	cStatus:="N"
else
	cStatus:=field->status
endif

select (nArr)

return cStatus


/*! \fn ProsliObrOtvoren(cRj,nGodObr,nMjObr)
 *  \brief Provjerava da li je obracun za mjesec unazad otvoren
 *  \param cRJ - radna jedinica
 *  \param nGodObr - godina
 *  \param nMjObr - mjesec
 */
function ProsliObrOtvoren(cRJ,nGodObr,nMjObr)
local lOtvoren
if (nMjObr==1)
	lOtvoren:=JelOtvoren(cRJ,nGodObr-1,12)
else
	lOtvoren:=JelOtvoren(cRJ,nGodObr,nMjObr-1)
endif
return (lOtvoren)




