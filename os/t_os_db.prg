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


#include "os.ch"
#include "hbclass.ch"
 
// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbOs INHERIT TDB 
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

 ::super:new()
 ::cName:="OS"
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



// -----------------------------------------------
// -----------------------------------------------
method kreiraj(nArea)

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

if (nArea==-1 .or. nArea==(F_INVENT))
	if !file(f18_ime_dbf("invent"))
	        aDbf:={}
	        AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	        AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
	        AADD(aDBf,{ 'KOLICINA'            , 'N' ,   6 ,  1 })
	        AADD(aDBf,{ 'IZNOS'               , 'N' ,  14 ,  2 })
	        DBCREATE2(PRIVPATH+'INVENT.DBF',aDbf)
			
	endif
	CREATE_INDEX("ID","Id",PRIVPATH+"INVENT") // Inventura
endif

return



// -------------------------------------------------
// -------------------------------------------------
method obaza(i)

local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_PARAMS 
	lIdiDalje:=.t.
endif

if i==F_OS .or. i==F_PROMJ .or. i==F_INVENT .or. i==F_REVAL .or. i==F_AMORT
	lIdiDalje:=.t.
endif

if i==F_KONTO .or. i==F_PARTN .or. i==F_RJ .or. i==F_K1 .or. i==F_VALUTE
	lIdiDalje:=.t.
endif

if lIdiDalje
	cDbfName:=DBFName(i,.t.)
	select(i)
	usex(cDbfName)
else
	use
	return
endif

return


// --------------------------------------------
// --------------------------------------------
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

if !SigmaSif("KZ      ")
	return
endif

Box(,8,50)
	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78"  PICT "9"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78A" PICT "@!"
  	@ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)  " GET cSif  VALID  cSif$"DN"  PICT "@!"
  	@ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)  " GET cKum  VALID  cKum$"DN"  PICT "@!"
  	@ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  	read
  	if LastKey()==K_ESC
		BoxC()
		return
	endif
  	if Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    		BoxC()
		return
  	endif
BoxC()

aPriv:= { F_INVENT }
aKum:= { F_OS, F_PROMJ, F_RJ, F_K1 }
aSif:={ F_PARTN, F_KONTO, F_AMORT, F_REVAL }

if cSif=="N"
	aSif:={}
endif

if cKum=="N"
	aKum:={}
endif

if cPriv=="N"
	aPriv:={}
endif

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return



// -------------------------------------------------------------------
// -------------------------------------------------------------------
method skloniSezonu(cSezona,finverse,fda,fnulirati, fRS)
save screen to cScr

if (fda==nil)
	fDA:=.f.
endif
if (finverse==nil)
	finverse:=.f.
endif
if (fNulirati==nil)
	fnulirati:=.f.
endif
if (fRS==nil)
  // mrezna radna stanica , sezona je otvorena
  fRS:=.f.
endif

if fRS // radna stanica
  if file(PRIVPATH+cSezona+"\INVENT.DBF")
      // nema se sta raditi ......., pripr.dbf u sezoni postoji !
      return
  endif
  aFilesK:={}
  aFilesS:={}
  aFilesP:={}
endif

cls

if fRS
   // mrezna radna stanica
   ? "Formiranje DBF-ova u privatnom direktoriju, RS ...."
endif

?

if fInverse
	? "Prenos iz  sezonskih direktorija u radne podatke"
else
 	? "Prenos radnih podataka u sezonske direktorije"
endif

?

fnul:=.f.
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"INVENT.DBF",cSezona,finverse,fda,fnul)
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


Skloni(KUMPATH,"OS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"K1.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"PROMJ.DBF",cSezona,finverse,fda,fnul)

Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"AMORT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"REVAL.DBF",cSezona,finverse,fda,fnul)

?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr

return





