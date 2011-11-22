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

 
*string tbl_fakt_serBr
/*! \var tbl_fakt_serBr
 *  \brief predvidjeno za evidenciju serijskog broja artikla
 *
 * \note koliko mi je poznato NIKO ovu mogucnost ne koristi
 *  
 *  Za dokument inventure cemo ga koristiti na SPECIFICAN nacin:
 *  "serBr"    -> pohranicemo vijednost Knjizne kolicine
 *
 *  \code
 *  nKKolicina:=VAL(field->serBr)
 *  ..
 *  REPLACE serBr WITH STR(nKKolicina,15,4)
 *  \endcode
 *
 *  "kolicina" -> pohranicemo vrijednost Popisane kolicine
 *  Razlog: promjena strukture fakt-a bi jos uvecala (a time i usporila bazu)
 *  Vrijednost knjizne kolicine nije nesto po cemu trebamo ptretrazivati pa
 *  stoga nema nikakve potrebe za otvaranjem novog polja
 *
 * \todo takodje se koristi kod reklamacije za ... ali ne znam za sta
 * \sa tbl_fakt
 */
 
function TFrmInvNew()
*{
local oObj

#ifdef CLIP

#else
	oObj:=TFrmInv():new()
#endif

oObj:self:=oObj
oObj:lTerminate:=.f.
return oObj
*}

/*! \fn FaUnosInv()
 *  \brief Poziva se unos dokumenta inventure
 */
 
function FaUnosInv()
*{
local oMainFrm
oMainFrm:=TFrmInvNew()
oMainFrm:open()
oMainFrm:close()
return
*}



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
	method genDokManjak
	method genDokVisak

END CLASS

/*! \fn TFrmInv::open()
 */

*void TFrmInv::open()
method open()
private ImeKol
private Kol

o_fakt_edit()
SELECT pripr
SET ORDER TO TAG "1"

if ::lTerminate
	return
endif

::setColumns()

Box(,21,77)
TekDokument()
::sayKomande()
ObjDbedit("FInv", 21, 77, {|| ::onKeyBoard() }, "", "Priprema inventure", , , , ,4)

return
*}


*void TFrmInv::onKeyboard()
*{
method onKeyboard()
local nRet
local oFrmItem

::nCh:=Ch

if ::lTerminate
	return DE_ABORT
endif

SELECT pripr
if (::nCh==K_ENTER  .and. EMPTY(field->brDok) .and. EMPTY(field->rbr))
  return DE_CONT
endif

do case
	case ::nCh==K_CTRL_T
     		if ::deleteItem()==1
     			return DE_REFRESH
		else
			return DE_CONT
		endif

   	case ::nCh==K_ENTER
		oFrmItem:=TFrmInvItNew(self)
		nRet:=oFrmItem:open()
		oFrmItem:close()
		if nRet==1
			return DE_REFRESH
		else
			return DE_CONT   
		endif

	case ::nCh==K_CTRL_A
		::walk()
		return DE_REFRESH

	case ::nCh==K_CTRL_N
		::noveStavke()
		return DE_REFRESH

	case ::nCh==K_CTRL_P
        	::print()
        	return DE_REFRESH
	
	case ::nCh==K_ALT_P
        	::printOPop()
        	return DE_REFRESH

	case ::nCh==K_ALT_A
		CLOSE ALL
		azur_fakt()
		o_fakt_edit()
		return DE_REFRESH

   	case ::nCh==K_CTRL_F9
		::deleteAll()
        	return DE_REFRESH

   	case ::nCh==K_F10
       		::popup()
		if ::lTerminate
			return DE_ABORT
		endif
       		return DE_REFRESH

	case ::nCh==K_ALT_F10
		//FaAsistent()
      	//	return DE_REFRESH
	
	case ::nCh==K_ESC
		return DE_ABORT
endcase

	
return DE_CONT
*}

/*! \fn TFrmInv::walk()
 *  \brief Prodji kroz sve stavke dokumenta
 */
 
method walk()
local oFrmItem

oFrmItem:=TFrmInvItNew(self)

do while .t.

	oFrmItem:lNovaStavka:=.f.
	oFrmItem:open()
	oFrmItem:close()
	if LASTKEY()==K_ESC
		exit
	endif
	if oFrmItem:nextItem()==0
		//nema vise stavki
		exit
	endif
enddo

oFrmItem:=nil

return
*}

/*! \fn TFrmInv::noveStavke()
 *  \brief Unos novih stavki
 */
 
method noveStavke()
local oFrmItem

oFrmItem:=TFrmInvItNew(self)

do while .t.
	oFrmItem:lNovaStavka:=.t.
	oFrmItem:open()
	oFrmItem:close()
	if LASTKEY()==K_ESC
		oFrmItem:deleteItem()
		exit
	endif
enddo
oFrmItem:=nil

return
*}


/*! \fn TFrmInv::sayKomande()
 *  \brief Stampa Liste komandi na dnu ekrana
 *
 */

*void TFrmInv::sayKomande()
*{
method sayKomande()

@ m_x+18, m_y+2 SAY " <c-N> Nove Stavke       ³<ENT> Ispravi stavku      ³<c-T> Brisi Stavku "
@ m_x+19, m_y+2 SAY " <c-A> Ispravka Dokumenta³<c-P> Stampa dokumenta    ³<a-P> Stampa obr. popisa"
@ m_x+20, m_y+2 SAY " <a-A> Azuriranje dok.   ³<c-F9> Brisi pripremu     ³"
@ m_x+21, m_y+2 SAY " <F10>  Ostale opcije    ³<a-F10> Asistent  "

return
*}


/*! \fn TFrmInv::setColuns()
 *  \brief Postavi vrijednost aImeKol, aKol matrica
 *  \note takodje se na kraju postavljaju priv var: ImeKol:=aImeKol, Kol:=aKol
 */
 
*void TFrmInv::setColuns()
*{
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
*}

/*! \fn TFrmInv::print()
 *  \brief Stampa obrasca uporednog prikaza knjiznih i popisanih kolicina
 *
 *  \code
 *  Izvjestaj sadrzi sljedece kolone
 *  Rbr; Artikal (id, naz); Knj.kol; Pop.kol; Razlika kol; <<nastavak dole>> 
 *  Vpc; Vpv Visak; Vpv Manjak  
 *
 *  (izvjestaj je ostranicen)
 *  \endcode
 *
 *  \sa DokNovaStrana
 */
*void TFrmInv::print()
*{
method print()

RptInv()

return
*}

/*! \fn TFrmInv::printOPop()
 *  \brief Stampa obrasca Popisa
 *
 *  \code
 *  Izvjestaj sadrzi sljedece kolone
 *  Rbr; Artikal (id, naz); Pop.kol; Vpc  
 *  
 *  Kolona Pop.kol: sadrzi prostor "____________" za unos kolicine
 *
 *  Na kraju sadrzi potpis clanova komisije
 *
 *  (izvjestaj je ostranicen)
 *  \endcode
 *  
 *  \sa PrnClanoviKomisije, DokNovaStrana
 */
*void TFrmInv::printOPop()
*{
method printOPop()

RptInvObrPopisa()

return
*}

*void TFrmInv::close()
*{
method close
BoxC()
CLOSERET
return
*}

/*! \fn TFrmInv::itemsCount()
 *  \brief Prodji kroz sve stavke dokumenta
 */

*{ TFrmInv::itemsCount()
*{
method itemsCount()
local nCnt

PushWa()
SELECT pripr
nCnt:=0
do while !EOF()
	nCnt++
	skip
enddo
PopWa()
return nCnt
*}


*void TFrmInv::deleteAll()
*{
method deleteAll()

if Pitanje(,"Zelite li zaista izbrisati cijeli dokument?","N")=="D"
	ZAP
endif
return
*}

*void TFrmInv::deleteItem()
*{
method deleteItem()
DELETE
return 1
*}

/*! \fn *void TFrmInv::popup()
 *  \brief PopupMeni forme Inventure
 *
 */
 
*void TFrmInv::popup()
*{
method popup
private opc
private opcexe
private Izbor

opc:={}
opcexe:={}
Izbor:=1
AADD(opc,"1. generacija dokumenta inventure      ")
AADD(opcexe, {|| ::genDok() })

AADD(opc,"2. generisi otpremu za kolicinu manjka")
AADD(opcexe, {|| ::genDokManjak() })
AADD(opc,"3. generisi dopremu za kolicinu viska")
AADD(opcexe, {|| ::genDokVisak() })

Menu_SC("ppin")

return nil
*}

/*! \fn TFrmInv::genDok()
 */

*void TFrmInv::genDok()
*{
method genDok()
local cIdRj

cIdRj:=gFirma
Box(,2,40)
	@ m_x+1,m_y+2 SAY "RJ:" GET cIdRj
	READ
BoxC()

if Pitanje(,"Generisati dokument inventure za RJ "+cIdRj,"N")=="D"
	CLOSE ALL
	GDokInv(cIdRj)
	o_fakt_edit()
endif

return
*}

/*! \fn TFrmInv::genDokManjak()
 */

*void TFrmInv::genDokManjak()
*{
method genDokManjak()
local cIdRj
local cBrDok

cIdRj:=gFirma
cBrDok:=SPACE(LEN(field->brDok))
do while .t.
	Box(,4,60)
	@ m_x+1, m_y+2 SAY "Broj (azuriranog) dokumenta za koji generisete"
	@ m_x+2, m_y+2 SAY "otpremu po osnovu manjka"

	@ m_x+4, m_y+2 SAY "RJ:" GET cIdRJ
	@ m_x+4, COL()+2 SAY "- IM -" GET cBrDok

	READ
	BoxC()
	if LASTKEY()==K_ESC
		return
	endif

	if !IsDocExists(cIdRj, "IM", cBrDok)
		MsgBeep("Dokument ne postoji ?!")
	else
		exit
	endif
enddo

MsgBeep("Not imp: GDokInvManjak")

// generisem dokumenat 19 - izlaz po ostalim osnovama
GDokInvManjak(cIdRj, cBrDok)

// obrada "obicnih" dokumenata
fakt_unos_dokumenta()

::lTerminate:=.t.

return
*}


/*! \fn TFrmInv::genDokVisak()
 */

*void TFrmInv::genDokVisak()
*{
method genDokVisak 
local cIdRj
local cBrDok

cIdRj:=gFirma
cBrDok:=SPACE(LEN(field->brDok))

do while .t.
	Box(,4,60)
	@ m_x+1, m_y+2 SAY "Broj (azuriranog) dokumenta za koji generisete"
	@ m_x+2, m_y+2 SAY "prijem po osnovu viska"

	@ m_x+4, m_y+2 SAY "RJ:" GET cIdRJ
	@ m_x+4, COL()+2 SAY "- IM -" GET cBrDok

	READ
	BoxC()
	if LASTKEY()==K_ESC
		return
	endif

	if !IsDocExists(cIdRj, "IM", cBrDok)
		MsgBeep("Dokument "+cIdRj+"-IM-"+cBrDok+"ne postoji ?!")
	else
		exit
	endif
enddo

MsgBeep("Not imp: GDokInvVisak")
// generisem dokumenat 01 - prijem
GDokInvVisak(cIdRj, cBrDok)

// obrada "obicnih" dokumenata
fakt_unos_dokumenta()

::lTerminate:=.t.
return
*}

