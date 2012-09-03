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


#include "rnal.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbRnal INHERIT TDB 
	method New
    method skloniSezonu	
	method setgaDBFs	
	method install	
	method ostalef	
	method obaza	
	method kreiraj	
	method konvZn
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()
 ::cName:="RNAL"
 ::lAdmin:=.f.

 ::kreiraj()

return self



// --------------------------------------------
// --------------------------------------------
method skloniSezonu(cSezona, finverse, fda, lNulirati, fRS)
local cScr

save screen to cScr

if fda==nil
	fDA:=.f.
endif
if finverse==nil
  	finverse:=.f.
endif
if lNulirati==nil
  	lNulirati:=.f.
endif
if fRS==nil
  	// mrezna radna stanica , sezona je otvorena
  	fRS:=.f.
endif

if fRS // radna stanica
  	if file(ToUnix(PRIVPATH+cSezona+"\P_RNAL.DBF"))
      		return
  	endif
  	aFilesK:={}
  	aFilesS:={}
  	aFilesP:={}
endif

if KLevel<>"0"
	MsgBeep("Nemate pravo na koristenje ove opcije")
endif

cls

if fRS
	// mrezna radna stanica
	? "Formiranje DBF-ova u privatnom direktoriju, RS ...."
endif

?

if finverse
 	? "Prenos iz  sezonskih direktorija u radne podatke"
else
	? "Prenos radnih podataka u sezonske direktorije"
endif
?

// privatni
fNul:=.f.
Skloni(PRIVPATH,"_DOCS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_IT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_IT2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_DOC_OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if fRS
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak.."

 	restore screen from cScr
 	return
endif

if lNulirati
	fnul:=.t.
else
	fnul:=.f.
endif  

// kumulativ
Skloni(KUMPATH,"DOCS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_IT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_IT2.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_LOG.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOC_LIT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

fnul := .f.

// prenesi ali ne prazni, ovo su parametri...
Skloni(KUMPATH,"KPARAMS.DBF",cSezona,finverse,fda,fnul)

// sifrarnik
Skloni(SIFPATH,"AOPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"AOPS_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ARTICLES.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ELEMENTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_AOPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GROUPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GR_ATT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"E_GR_VAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"CUSTOMS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OBJECTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"RAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"CONTACTS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?

Beep(4)

? "pritisni nesto za nastavak.."

restore screen from cScr
return


// --------------------------------------------
// --------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return


// ----------------------------------------
// ----------------------------------------
method install()
  install_start(goModul,.f.)
return


// ----------------------------------------
// ----------------------------------------
method kreiraj(nArea)

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea == nil)
	nArea:=-1
endif

Beep(1)

if (nArea <> -1)
	CreSystemDb( nArea )
endif

return


method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_DOCS .or. i==F__DOCS
	lIdiDalje:=.t.
endif

if i==F_DOC_IT .or. i==F__DOC_IT
	lIdiDalje:=.t.
endif

if i==F_DOC_IT2 .or. i==F__DOC_IT2
	lIdiDalje:=.t.
endif

if i==F_DOC_OPS .or. i==F__DOC_OPS
	lIdiDalje:=.t.
endif

if i==F_DOC_LOG .or. i==F_DOC_LIT
	lIdiDalje:=.t.
endif

if i==F_ARTICLES .or. i==F_ELEMENTS .or. i==F_E_AOPS .or. i==F_E_ATT
	lIdiDalje:=.t.
endif

if i==F_E_GROUPS .or. i==F_E_GR_ATT .or. i==F_E_GR_VAL
	lIdiDalje:=.t.
endif

if i==F_CUSTOMS .or. i==F_CONTACTS .or. i==F_OBJECTS
	lIdiDalje:=.t.
endif

if i==F_AOPS .or. i==F_AOPS_ATT
	lIdiDalje:=.t.
endif


if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	if gAppSrv 
		? "OPEN: " + cDbfName + ".DBF"
		if !File(cDbfName + ".DBF")
			? "Fajl " + cDbfName + ".dbf ne postoji!!!"
			use
			return
		endif
	endif
	select(i)
	usex(cDbfName)
else
	use
	return
endif

return


method ostalef()
close all
return



method konvZn()
local cIz:="7"
local cU:="8"
local aPriv:={}
local aKum:={}
local aSif:={}
local GetList:={}
local cSif:="D"
local cKum:="D"
local cPriv:="D"

if !gAppSrv
	IF !SigmaSif("KZ      ")
   		RETURN
 	ENDIF
	Box(,8,50)
  	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	READ
  	IF LASTKEY()==K_ESC
		BoxC()
		RETURN
	ENDIF
  	IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		RETURN
  	ENDIF
 	BoxC()
else
	?
	cKonvertTo:=IzFmkIni("FMK","KonvertTo","78",EXEPATH)
	
	if cKonvertTo=="78"
		cIz:="7"
		cU:="8"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	elseif cKonvertTo=="87"
		cIz:="8"
		cU:="7"
		? "Trenutni standard: " + cIz
		? "Konvertovati u: " + cU 
	else // pitaj
		?
		@ 10, 2 SAY "Trenutni standard (7/8)        " GET cIz VALID cIz$"78" PICT "9"
		?
		@ 11, 2 SAY "Konvertovati u standard (7/8/A)" GET cU VALID cU$"78A" PICT "@!"
		read
	endif
	cSif:="D"
	cKum:="D"
	cPriv:="D"
endif
 
aKum  := { F_DOCS, F_DOC_IT, F_DOC_OPS, F_DOC_LOG, F_DOC_LIT }
aPriv := { F__DOCS, F__DOC_IT, F__DOC_OPS }
aSif  := { F_AOPS, F_AOPS_ATT, F_E_GROUPS, F_E_GR_ATT, F_E_GR_VAL, F_ARTICLES, F_ELEMENTS, F_E_AOPS, F_E_ATT, F_OBJECTS, F_CUSTOMS, F_CONTACTS }

if cSif == "N"
	aSif := {}
endif
if cKum == "N"
	aKum := {}
endif
if cPriv == "N"
	aPriv := {}
endif

KZNbaza(aPriv,aKum,aSif,cIz,cU)
return


method scan
return



