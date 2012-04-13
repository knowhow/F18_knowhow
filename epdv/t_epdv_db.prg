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


#include "epdv.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbEpdv INHERIT TDB 
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

 ::cName:="EPDV"
 ::lAdmin:=.f.

 ::kreiraj()

return self


// -----------------------------------------------------------------
// -----------------------------------------------------------------
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
  if file(ToUnix(PRIVPATH+cSezona+"\P_KUF.DBF"))
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
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
fnul:=.f.
Skloni(PRIVPATH,"P_KUF.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"P_KIF.DBF",cSezona,finverse,fda,fnul)
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
Skloni(KUMPATH,"KIF.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KUF.DBF",cSezona,finverse,fda,fnul)
Skloni (KUMPATH,"PDV.DBF",cSezona,finverse,fda,fnul)

fnul:=.f.
Skloni(KUMPATH,"SG_KIF.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"SG_KUF.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return


// -----------------------------------------------------------------
// -----------------------------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return


// -----------------------------------------------------------------
// -----------------------------------------------------------------
method install()
	install_start(goModul,.f.)
return


// -----------------------------------------------------------------
// -----------------------------------------------------------------
method kreiraj(nArea)
local cImeDbf

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

Beep(1)

if (nArea<>-1)
	CreSystemDb(nArea)
endif

return



/*! \fn *void TDBePdv::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *  S obzirom da se koristi prvenstveno za instalacijske funkcije
 *  otvara tabele u exclusive rezimu
 */

*void TDBePdv::obaza(int i)
*{
method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.


if i==F_KUF .or. i==F_KIF .or. i==F_PDV 
	lIdiDalje:=.t.
endif

if i==F_P_KUF .or. i==F_P_KIF 
	lIdidalje:=.t.
endif

if i==F_SG_KUF .or. i==F_SG_KIF 
	lIdidalje:=.t.
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


// ---------------------------------------------
// ---------------------------------------------
method ostalef()
close all
return


// ---------------------------------------------
// ---------------------------------------------
method konvZn()

LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"
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
 
aKum  := { F_KIF, F_KUF, F_PDV }
aPriv := { }
aSif  := { }

 IF cSif  == "N"; aSif  := {}; ENDIF
 IF cKum  == "N"; aKum  := {}; ENDIF
 IF cPriv == "N"; aPriv := {}; ENDIF

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return


