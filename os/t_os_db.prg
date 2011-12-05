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

CreFMKSvi()

if (nArea==-1 .or. nArea==(F_OS))
	if !file(f18_ime_dbf("os"))
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
	   AADD(aDBf,{ 'IDRJ'                , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'Datum'               , 'D' ,   8 ,  0 })
	   AADD(aDBf,{ 'DatOtp'              , 'D' ,   8 ,  0 })
	   AADD(aDBf,{ 'OpisOtp'             , 'C' ,  30 ,  0 })
	   AADD(aDBf,{ 'IdKonto'             , 'C' ,   7 ,  0 })
	   AADD(aDBf,{ 'kolicina'            , 'N' ,   6 ,  1 })
	   AADD(aDBf,{ 'jmj'                 , 'C' ,   3 ,  0 })
	   AADD(aDBf,{ 'IdAm'                , 'C' ,   8 ,  0 })
	   AADD(aDBf,{ 'IdRev'               , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'NabVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'OtpVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmD'                 , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmP'                 , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevD'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevP'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'K1'                  , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
	   AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
	   AADD(aDBf,{ 'Opis'                , 'C' ,  25 ,  0 })
	   AADD(aDBf,{ 'BrSoba'              , 'C' ,   6 ,  0 })
	   AADD(aDBf,{ 'IdPartner'           , 'C' ,   6 ,  0 })

	   DBCREATE2("OS", aDbf)
	   reset_semaphore_version( "os_os" )
	   my_use("OS")

	endif

	CREATE_INDEX("1","id+idam+dtos(datum)",KUMPATH+"OS")
	CREATE_INDEX("2","idrj+id+dtos(datum)",KUMPATH+"OS")
	CREATE_INDEX("3","idrj+idkonto+id",KUMPATH+"OS")
	CREATE_INDEX("4","idkonto+idrj+id",KUMPATH+"OS")
	CREATE_INDEX("5","idam+idrj+id",KUMPATH+"OS")
endif


// k1 - grupacije
if (nArea==-1 .or. nArea==(F_K1))
	if !file(f18_ime_dbf("k1"))
	   aDBf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
	   DBCREATE2( "K1", aDbf )
	   reset_semaphore_version( "os_k1" )
       my_use("K1")
	endif
	CREATE_INDEX("ID","id",KUMPATH+"K1")
	CREATE_INDEX("NAZ","NAZ",KUMPATH+"K1")
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

if (nArea==-1 .or. nArea==(F_PROMJ))
	if !file(f18_ime_dbf("promj"))
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
	   AADD(aDBf,{ 'Opis'                , 'C' ,  30 ,  0 })
	   AADD(aDBf,{ 'Datum'               , 'D' ,   8 ,  0 })
	   AADD(aDBf,{ 'Tip'                 , 'C' ,   2 ,  0 })
	   AADD(aDBf,{ 'NabVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'OtpVr'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmD'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'AmP'                , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevD'               , 'N' ,  18 ,  2 })
	   AADD(aDBf,{ 'RevP'               , 'N' ,  18 ,  2 })
	   DBCREATE2( "PROMJ", aDbf )
	   reset_semaphore_version("os_promj")
	   my_use("PROMJ")
	endif
	CREATE_INDEX("1","id+tip+dtos(datum)",KUMPATH+"PROMJ")
endif

if (nArea==-1 .or. nArea==(F_AMORT))
	if !file(f18_ime_dbf("amort"))
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
	   AADD(aDBf,{ 'Iznos'               , 'N' ,   7 ,  3 })
	   DBCREATE2("AMORT", aDbf)
	   reset_semaphore_version("os_amort")
	   my_use("AMORT")
	endif
	CREATE_INDEX("ID","id",SIFPATH+"AMORT")
endif

if (nArea==-1 .or. nArea==(F_REVAL))
	if !file(f18_ime_dbf("reval"))
	   aDbf:={}
	   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
	   AADD(aDBf,{ 'NAZ'                 , 'C' ,  10 ,  0 })
	   AADD(aDBf,{ 'I1'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I2'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I3'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I4'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I5'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I6'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I7'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I8'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I9'                  , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I10'                 , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I11'                 , 'N' ,   7 ,  3 })
	   AADD(aDBf,{ 'I12'                 , 'N' ,   7 ,  3 })
	   DBCREATE2("REVAL", aDbf)
	   reset_semaphore_version("os_reval")
	   my_use("REVAL")
	endif
	CREATE_INDEX("ID","id",SIFPATH+"REVAL")
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





