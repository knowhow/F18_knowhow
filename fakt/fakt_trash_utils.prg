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


#include "fakt.ch"

// -------------------------------------
// opcija pregleda smeca
// -------------------------------------

function Pripr9View()

private aUslFirma := gFirma
private aUslDok := SPACE(50)
private dDat1 := CToD("")
private dDat2 := DATE()

Box(,10, 60)
	@ 1+m_x, 2+m_y SAY "Uslovi pregleda smeca:" COLOR "I"
	@ 3+m_x, 2+m_y SAY "Firma (prazno-sve)" GET aUslFirma PICT "@S40"
	@ 4+m_x, 2+m_y SAY "Vrste dokumenta (prazno-sve)" GET aUslDok PICT "@S20"
	@ 5+m_x, 2+m_y SAY "Datum od" GET dDat1 
	@ 5+m_x, 20+m_y SAY "do" GET dDat2 
	read
BoxC()

if LastKey()==K_ESC
	return
endif

// postavi filter
P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)

private gVarijanta:="2"

private PicV:="99999999.9"
ImeKol:={ ;
    { "F."        , {|| IdFirma                  }, "IdFirma"     } ,;
    { "VD"        , {|| IdTipDok                 }, "IdTipDok"    } ,;
    { "BrDok"     , {|| BrDok                    }, "BrDok"       } ,;
    { "Dat.dok"   , {|| DatDok                   }, "DatDok"      } ,;
    { "Partner"   , {|| PADR(_get_partner(idpartner),50)  }, "idpartner" } ;
        }

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)
@ m_x+17,m_y+2 SAY "<c-T>  Brisi stavku                              "
@ m_x+18,m_y+2 SAY "<c-F9> Brisi sve     "
@ m_x+19,m_y+2 SAY "<P> Povrat dokumenta u pripremu "
@ m_x+20,m_y+2 SAY "               "

ObjDbedit("PRIPR9",20,77,{|| fa_pripr9_key_handler()},"<P>-povrat dokumenta u pripremu","Pregled smeca...", , , , ,4)
BoxC()

return


function fa_pripr9_key_handler()
do case
	case Ch==K_CTRL_T 
		// brisanje dokumenta iz pripr9
		bris_smece(idfirma, idtipdok, brdok)
      	return DE_REFRESH
	case Ch==K_CTRL_F9 
		// brisanje kompletnog pripr9
		bris_svo_smece()
		return DE_REFRESH
	case chr(Ch) $ "pP" // povrat dokumenta u pripremu
		PovPr9()
		P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)
		return DE_REFRESH
endcase
return DE_CONT

return


static function PovPr9()
local nArr
nArr:=SELECT()

povrat_smece( idfirma, idtipdok, brdok )

select (nArr)

return DE_CONT



static function P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)
O_FAKT_PRIPR9
set order to tag "1"

// obavezno postavi filter po rbr
cFilter:="rbr = '  1'"

if !Empty(aUslFirma)
	cFilter += " .and. idfirma='" + aUslFirma + "'"
endif

if !Empty(aUslDok)
	aUslDok := Parsiraj(aUslDok, "idtipdok")
	cFilter += " .and. " + aUslDok
endif

if !Empty(dDat1)
	cFilter += " .and. datdok >= " + Cm2Str(dDat1)
endif

if !Empty(dDat2)
	cFilter += " .and. datdok <= " + Cm2Str(dDat2)
endif

set filter to &cFilter

go top

return


static function _get_partner(cIdPartner)
local nTArea
local cPartner
nTArea := SELECT()
select partn
go top
seek cIdPartner

if Found()
	cPartner := field->naz
else
	cPartner := "????????"
endif

select (nTArea)
return cPartner



// -------------------------------------------------
// brisi dokument iz smeca
// -------------------------------------------------
function bris_smece(cIdF, cIdTipDok, cBrDok)

if Pitanje(,"Sigurno zelite izbrisati dokument?","N")=="N"
	return
endif

select fakt_pripr9
seek cIdF+cIdTipDok+cBrDok

do while !eof() .and. cIdF==IdFirma .and. cIdTipDok==Idtipdok .and. cBrDok==BrDok
	skip 1
	nRec:=RecNo()
	skip -1
   	dbdelete2()
   	go nRec
enddo

nTArea := SELECT()

if Logirati(goModul:oDataBase:cName,"DOK","SMECE")
	cOpis := "dokument: " + cIdF + "-" + cIdTipDok + "-" + cBrDok
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "SMECE", ;
		nil, nil, nil, nil, ;
		"","", cOpis, DATE(), DATE(), "", ;
		"Brisanje dokumenta iz tabele smeca")
endif

select (nTArea)

return

// -------------------------------------------
// brisi sve iz smeca
// -------------------------------------------
function bris_svo_smece()

if Pitanje( , "Sigurno zelite izbrisati sve zapise?","N")=="N"
	return
endif

select fakt_pripr9
go top
zapp()

nTArea := SELECT()

if Logirati(goModul:oDataBase:cName,"DOK","SMECE")
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "SMECE", ;
		nil, nil, nil, nil, ;
		"","", "", DATE(), DATE(), "", ;
		"Brisanje kompletne tabele smeca")
endif

select (nTArea)

return

// -------------------------------------------------------
// opcija azuriranja dokumenta u smece
// -------------------------------------------------------
function azuriraj_smece( lSilent )

if lSilent == nil
	lSilent := .f.
endif

if lSilent == .f. .and. Pitanje("p1", "Zelite li dokument prebaciti u smece (D/N) ?", "D" ) == "N"
	return
endif

O_FAKT_PRIPR9
O_FAKT_PRIPR

lFound := .f.
nCount := 0

do while !EOF()

	++ nCount 
	lFound := .f.
	nRecNo := RECNO()

	cIdfirma := idfirma
	cIdTipDok := idtipdok
	cBrDok := brdok

	do while !EOF() .and. idfirma == cIdFirma ;
			.and. idtipdok == cIdtipdok ;
			.and. brdok == cBrDok
		skip
	enddo

	select fakt_pripr9
	seek cIdFirma+cIdtipdok+cBrDok

	if found()
		// ima vec u smecu !
		lFound := .t.
		
		if lSilent == .f.
			msgbeep("U smecu vec postoji isti dokument !")
			closeret
		endif

	endif

	select fakt_pripr
	
	if lFound == .t.
		
		go (nRecNO)
		// zamjeni brdok sa 00001-1
		do while !EOF() .and. idfirma == cIdFirma ;
				.and. idtipdok == cIdTipDok ;
				.and. brdok == cBrDok

			replace brdok with PADR(brdok, 5)+"-"+ALLTRIM(STR(nCount)) 
			skip
		enddo

		go (nRecNo)

	endif

enddo

select fakt_pripr
go top

do while !EOF()

	_rec := dbf_get_rec()

	select fakt_pripr9
	append blank
	dbf_update_rec( _rec )

	select fakt_pripr
	skip

enddo

select fakt_pripr
zapp()

nTArea := SELECT()
if Logirati(goModul:oDataBase:cName,"DOK","SMECE")
	cOpis := "dokument: "+ cIdFirma + "-" + cIdTipDok + "-" + cBrDok
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "SMECE", ;
		nil, nil, nil, nil, ;
		"","", cOpis, DATE(), DATE(), "", ;
		"Prebacivanje dokumenta iz pripreme u smece")
endif

select (nTArea)

if lSilent == .f.
	closeret
endif

return


// ---------------------------------------------------
// povrat dokumenta iz smeca
// ---------------------------------------------------
function povrat_smece( cIdFirma, cIdtipdok, cBrDok )
local nRec

lSilent := .t.

O_FAKT_PRIPR9
O_FAKT_PRIPR

select fakt_pripr9
set order to tag 1

// ako nema parametara funkcije
if (PCount() == 0)
	lSilent := .f.
endif

if !lSilent
   cIdFirma := gFirma
   cIdtipdok := SPACE(LEN(field->idtipdok))
   cBrDok := SPACE(LEN(field->brdok))
endif

if !lSilent
   Box("",1,40)
     @ m_x + 1, m_y + 2 SAY "Dokument:"
     @ m_x + 1, col() + 1 GET cIdFirma
     @ m_x + 1, col() + 1 SAY "-" GET cIdtipdok
     @ m_x + 1, col() + 1 SAY "-" GET cBrdok
     read
     ESC_BCR
   BoxC()
endif

if Pitanje("","Iz smeca "+cIdFirma+"-"+cIdtipdok+"-"+ALLTRIM(cBrDok)+" povuci u pripremu (D/N) ?","D")=="N"
	
	if !lSilent
		CLOSERET
	else
		return
	endif

endif

select fakt_pripr9

hseek cIdFirma+cIdtipdok+cBrDok

MsgO("PRIPREMA")
do while !eof() .and. cIdFirma==IdFirma .and. cIdtipdok==Idtipdok .and. cBrDok==BrDok
   select fakt_pripr9
   Scatter()
   select fakt_pripr
   append blank
   _ERROR:=""
   Gather2()
   select fakt_pripr9
   skip
enddo

select fakt_pripr9
seek cIdFirma+cIdTipDok+cBrDok
do while !eof() .and. cIdFirma==IdFirma .and. cIdtipdok==Idtipdok .and. cBrDok==BrDok
   skip 1
   nRec:=recno()
   skip -1
   dbdelete2()
   go nRec
enddo

use

MsgC()

nTArea := SELECT()
if Logirati(goModul:oDataBase:cName,"DOK","SMECE")
	cOpis := "dokument: " + cIdFirma + "-" + cIdTipDok + "-" + cBrDok
	EventLog(nUser, goModul:oDataBase:cName, "DOK", "SMECE", ;
		nil, nil, nil, nil, ;
		"","", cOpis, DATE(), DATE(), "", ;
		"Prebacivanje dokumenta smeca u pripremu")
endif

select (nTArea)

if !lSilent
	closeret
endif

O_FAKT_PRIPR9
select fakt_pripr9

return


