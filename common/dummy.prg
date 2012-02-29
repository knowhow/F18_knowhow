/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


function f18_get_metric()
MsgBeep(PROCNAME(1) + "/" + ToStr(PROCLINE(1)) + " ovo se mora mjenjati f18_get_metric")
QUIT
return

function f18_set_metric()
MsgBeep(PROCNAME(1) + "/" + ToStr(PROCLINE(1)) + " ovo se mora mjenjati f18_set_metric")
QUIT
return

function send2comport(cStr)

? "dummy send2commport"

return

function sql_azur()
return .t.

function GathSQL()
return .t.


function rloptlevel()
return 0

function isRudnik()
return .f.

function isPlanika()
return .f.

function isPlNs()
return .f.

function isKonsig()
return .f.

function isStampa()
return .f.

function isJerry()
return .f.

// ovo nešto treba za harbour 
//function TFileRead()
//return

function PosTest()
? "Pos test (pos/main/2g/app.prg)"
return


function replsql_dummy()
return


/*! \fn UpisiURF(cTekst,cFajl,lNoviRed,lNoviFajl)
 *  \brief Upisi u report fajl
 *  \param cTekst    - tekst
 *  \param cFajl     - ime fajla
 *  \param lNoviRed  - da li prelaziti u novi red
 *  \param lNoviFajl - da li snimati u novi fajl
 */
 
function UpisiURF(cTekst,cFajl,lNoviRed,lNoviFajl)
*{
StrFile(IF(lNoviRed,CHR(13)+CHR(10),"") + cTekst, cFajl, !lNoviFajl)
return
*}

/*! \fn DiffMFV(cZn,cDiff)
 *  \brief differences: memo vs field variable
 *  \param cZn 
 *  \param cdiff
 */
 
function DiffMFV(cZN,cDiff)
*{
local lVrati:=.f.
local i
local aStruct

if cZn==NIL
	cZn:="_"
endif

aStruct:=DBSTRUCT()

FOR i:=1 TO LEN(aStruct)
	cImeP := aStruct[i,1]
    	IF !(cImeP=="BRISANO")
     		cVar := cZn+cImeP
      		IF "U" $ TYPE(cVar)
			    MsgBeep("Greska:neuskladjene strukture baza!#"+;
			      	"Pozovite servis bring.out !#"+;
				    "Funkcija: GATHER(), Alias: "+ALIAS()+", Polje: "+cImeP)
      		ELSE
			IF field->&cImeP <> &cVar
	  			lVrati:=.t.
          			cDiff += hb_eol() + "     "
          			cDiff += cImeP+": bilo="+TRANS(field->&cImeP,"")+", sada="+TRANS(&cVar,"")
			ENDIF
      		ENDIF
    	ENDIF
NEXT
return lVrati

/*! \fn O_Log()
 *  \brief Ucitavanje SQL log fajla
 */
 
function O_Log()
*{
local cPom
local cLogF

cPom:=ToUnix(KUMPATH+SLASH+"SQL")
DirMak2(cPom)

cLogF:=cPom+SLASH+replicate("0",8)

OKreSQLPar(cPom)

public gSQLSite:=field->_SITE_
public gSQLUser:=1
use

//postavi site
Gw("SET SITE "+Str(gSQLSite))
Gw("SET TODATABASE OFF")
Gw("SET MODUL "+gModul)

AImportLog()

return


function addoidfields()
return

function OL_YIELD()
return


function f18_gather()
MsgBeep("f18_gather zamijeniti")
quit
return

function f18_scatter_global_vars()
MsgBeep("f18_scatter_global_vars zamijeniti")
quit
return


