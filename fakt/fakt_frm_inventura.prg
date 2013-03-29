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
#include "hbclass.ch"
#include "f18_separator.ch"


function TFrmInvNew()
local oObj
oObj:=TFrmInv():new()
oObj:self:=oObj
oObj:lTerminate:=.f.
return oObj



function FaUnosInv()
local oMainFrm
oMainFrm:=TFrmInvNew()
oMainFrm:open()
oMainFrm:close()
return


CREATE CLASS TFrmInv 
	EXPORTED:
	var self
	
	//is partner field loaded
	var lPartnerLoaded
	var lTerminate

	var nActionType
	var nCh
	var oApp
	var aImeKol
	var aKol
	var nStatus

	method open
	method close
	method print
	method printOPop
	method deleteItem
	method deleteAll
	method itemsCount
	method setColumns
	method onKeyboard

	method walk
	method noveStavke
	method popup
	method sayKomande
	
	method genDok

    method open_tables

END CLASS


method open_tables()
O_FAKT_DOKS
O_FAKT
O_SIFK
O_SIFV
O_PARTN
O_ROBA
O_TARIFA
O_FAKT_PRIPR
return .t.


method open()
private imekol
private kol

o_fakt_edit()

select fakt_pripr
set order to tag "1"

if ::lTerminate
    return
endif

::setColumns()

Box(,21,77)
    TekDokument()
    ::sayKomande()
    ObjDbedit( "FInv", 21, 77, {|| ::onKeyBoard() }, "", "Priprema inventure", , , , ,4)

return



method onKeyboard()
local nRet
local oFrmItem

::nCh := Ch

if ::lTerminate
    return DE_ABORT
endif

select fakt_pripr

if ( ::nCh == K_ENTER  .and. EMPTY( field->brdok ) .and. EMPTY( field->rbr ) )
    return DE_CONT
endif

do case

    case ::nCh == K_CTRL_T
     	if ::deleteItem() == 1
     		return DE_REFRESH
		else
			return DE_CONT
		endif

   	case ::nCh == K_ENTER
	    oFrmItem := TFrmInvItNew( self )
		nRet := oFrmItem:open()
		oFrmItem:close()

		if nRet == 1
			return DE_REFRESH
		else
			return DE_CONT   
		endif

	case ::nCh == K_CTRL_A
		::walk()
		return DE_REFRESH

	case ::nCh == K_CTRL_N
		::noveStavke()
		return DE_REFRESH

	case ::nCh == K_CTRL_P
        ::print()
        return DE_REFRESH
	
	case ::nCh == K_ALT_P
        ::printOPop()
        return DE_REFRESH

	case ::nCh == K_ALT_A
		close all
		azur_fakt()
		o_fakt_edit()
		return DE_REFRESH

   	case ::nCh == K_CTRL_F9
		::deleteAll()
        return DE_REFRESH

   	case ::nCh == K_F10
       	::popup()
		if ::lTerminate
			return DE_ABORT
		endif
       	return DE_REFRESH

	case ::nCh == K_ALT_F10
	
	case ::nCh == K_ESC
	    return DE_ABORT
endcase
	
return DE_CONT



method walk()
local oFrmItem

oFrmItem := TFrmInvItNew( self )

do while .t.

	oFrmItem:lNovaStavka := .f.
	oFrmItem:open()
	oFrmItem:close()

	if LASTKEY() == K_ESC
		exit
	endif

	if oFrmItem:nextItem() == 0
		exit
	endif

enddo

oFrmItem := nil

return


 
method noveStavke()
local oFrmItem

oFrmItem := TFrmInvItNew( self )

do while .t.
	oFrmItem:lNovaStavka := .t.
	oFrmItem:open()
	oFrmItem:close()
	if LASTKEY() == K_ESC
		oFrmItem:deleteItem()
		exit
	endif
enddo
oFrmItem := NIL

return



method sayKomande()

@ m_x + 18, m_y+2 SAY " <c-N> Nove Stavke       " + BROWSE_COL_SEP + "<ENT> Ispravi stavku      " + BROWSE_COL_SEP + "<c-T> Brisi Stavku "
@ m_x + 19, m_y+2 SAY " <c-A> Ispravka Dokumenta" + BROWSE_COL_SEP + "<c-P> Stampa dokumenta    " + BROWSE_COL_SEP + "<a-P> Stampa obr. popisa"
@ m_x + 20, m_y+2 SAY " <a-A> Azuriranje dok.   " + BROWSE_COL_SEP + "<c-F9> Brisi pripremu     " + BROWSE_COL_SEP + ""
@ m_x + 21, m_y+2 SAY " <F10>  Ostale opcije    " + BROWSE_COL_SEP + "<a-F10> Asistent  "

return


method setColumns()
local i

::aImeKol:={}
AADD(::aImeKol, {"Red.br",        {|| STR(RbrUNum(field->rBr),4) } })
AADD(::aImeKol, {"Roba",          {|| Roba()} })
AADD(::aImeKol, {"Knjiz. kol",    {|| field->serBr} })
AADD(::aImeKol, {"Popis. kol",    {|| field->kolicina} })
AADD(::aImeKol, {"Cijena",        {|| field->cijena} , "cijena" })
AADD(::aImeKol, {"Rabat",         {|| field->rabat} ,"rabat"})
AADD(::aImeKol, {"Porez",         {|| field->porez} ,"porez"})
AADD(::aImeKol, {"RJ",            {|| field->idFirma}, "idFirma" })
AADD(::aImeKol, {"Partn",         {|| field->idPartner}, "idPartner" })
AADD(::aImeKol, {"IdTipDok",      {|| field->idTipDok}, "idtipdok" })
AADD(::aImeKol, {"Brdok",         {|| field->brDok}, "brdok" })
AADD(::aImeKol, {"DatDok",        {|| field->datDok}, "datDok" })
       
if fakt_pripr->(fieldpos("k1"))<>0 .and. gDK1=="D"
  	AADD(::aImeKol,{ "K1",{|| field->k1}, "k1" })
  	AADD(::aImeKol,{ "K2",{|| field->k2}, "k2" })
endif


::aKol:={}
for i:=1 to LEN(::aImeKol)
	AADD(::aKol,i)
next

ImeKol:=::aImeKol
Kol:=::aKol
return



method print()

PushWA()
RptInv()
::open_tables()
PopWA()

return



method printOPop()
PushWA()
RptInvObrPopisa()
::open_tables()
PopWA()
return

method close
BoxC()
CLOSERET
return

method itemsCount()
local nCnt

PushWa()
SELECT fakt_pripr
nCnt:=0
do while !EOF()
	nCnt++
	skip
enddo
PopWa()
return nCnt


method deleteAll()
if Pitanje(,"Zelite li zaista izbrisati cijeli dokument?","N")=="D"
	ZAP
endif
return

method deleteItem()
DELETE
return 1

method popup
private opc
private opcexe
private Izbor

opc:={}
opcexe:={}
Izbor:=1
AADD(opc,"1. generacija dokumenta inventure      ")
AADD(opcexe, {|| ::genDok() })

Menu_SC("ppin")

return nil

method genDok()
local cIdRj

cIdRj:=gFirma
Box(, 2, 40)
	@ m_x+1,m_y+2 SAY "RJ:" GET cIdRj
	READ
BoxC()

if Pitanje( , "Generisati dokument inventure za RJ " + cIdRj , "N") == "D"
	CLOSE ALL
	GDokInv(cIdRj)
	o_fakt_edit()
endif

return


