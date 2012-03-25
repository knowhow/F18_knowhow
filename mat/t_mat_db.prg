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


#include "mat.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbMat INHERIT TDB 
	method New
    method skloniSezonu	
	method setgaDBFs	
	method install	
	method obaza	
	method kreiraj	
	method konvZn
ENDCLASS



// --------------------------------------------
// --------------------------------------------
method New()

 ::cName:="MAT"
 ::lAdmin:=.f.

 ::kreiraj()

return self


// -----------------------------------------------
// -----------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return



// -----------------------------------------------
// -----------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return

 
// ------------------------------------------------------------- 
// ------------------------------------------------------------- 
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
  if file(ToUnix(PRIVPATH+cSezona+"\mat_pripr.DBF"))
      // nema se sta raditi ......., mat_pripr.dbf u sezoni postoji !
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
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"mat_pripr.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"INVENT.DBF",cSezona,finverse,fda,fnul)
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
Skloni(KUMPATH,"mat_suban.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"mat_anal.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"mat_sint.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"mat_nalog.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)

// sifrarnici
fnul:=.f.
Skloni(SIFPATH,"KONTO.DBF", cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF", cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TARIFA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TNAL.DBF",  cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TDOK.DBF",  cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBF",  cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBT",  cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KARKON.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?

Beep(4)

? "pritisni nesto za nastavak.."

restore screen from cScr
return



 
// ------------------------------------------------------------- 
// ------------------------------------------------------------- 
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

CreFmkPi()

if !file(f18_ime_dbf( 'KARKON' ))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,  7  ,  0 })
        AADD(aDBf,{ 'TIP_NC'              , 'C' ,  1 ,   0 })
        AADD(aDBf,{ 'TIP_PC'              , 'C' ,  1 ,   0 })
        DBCREATE2( 'KARKON', aDbf )
		reset_semaphore_version("mat_karkon")
		my_use("karkon")
endif

CREATE_INDEX("ID","ID", "KARKON")

return



// ------------------------------------------------------------- 
// ------------------------------------------------------------- 
method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.


if i==F_mat_suban .or. i==F_mat_anal .or. i==F_mat_sint .or. i==F_mat_nalog 
	lIdiDalje:=.t.
endif

if i==F_PARAMS .or. i==F_mat_pripr .or. i==F_INVENT
	lIdidalje:=.t.
endif

if i==F_Pmat_suban .or. i==F_Pmat_anal .or. i==F_Pmat_sint .or. i==F_Pmat_nalog
	lIdidalje:=.t.
endif

if i==F_KONTO .or. i==F_PARTN .or. i==F_ROBA .or. i==F_TDOK .or. i==F_TNAL
	lIdidalje:=.t.
endif

if i==F_VALUTE .or. i==F_TARIFA .or. i==F_KARKON 
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


// ------------------------------------------------------------- 
// ------------------------------------------------------------- 
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
 
aKum  := { F_mat_suban, F_mat_nalog, F_mat_sint, F_mat_anal }
aPriv := { F_mat_pripr, F_INVENT }
aSif  := { F_ROBA, F_PARTN, F_KONTO }

 IF cSif  == "N"; aSif  := {}; ENDIF
 IF cKum  == "N"; aKum  := {}; ENDIF
 IF cPriv == "N"; aPriv := {}; ENDIF

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return


