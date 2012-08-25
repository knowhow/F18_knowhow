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


#include "kalk.ch"
#include "hbclass.ch"


// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbKalk INHERIT TDB 
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

 ::cName:="KALK"
 ::lAdmin:=.f.

 ::kreiraj()

return self




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
  if file(PRIVPATH+cSezona+"\KALK_PRIPR.DBF")
      // nema se sta raditi ......., kalk_pripr.dbf u sezoni postoji !
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
if finverse
 ? "Prenos iz  sezonskih direktorija u radne podatke"
else
 ? "Prenos radnih podataka u sezonske direktorije"
endif
?

fnul:=.f.
Skloni(PRIVPATH,"kalk_pripr.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_KALK.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"finmat.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"kalk_pripr2.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"kalk_pripr9.DBF",cSezona,finverse,fda,fnul)
if is_doksrc()
	Skloni(PRIVPATH,"P_DOKSRC.DBF",cSezona,finverse,fda,fnul)
endif
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

if fnulirati; fnul:=.t.; else; fnul:=.f.; endif  // kumulativ datoteke
Skloni(KUMPATH,"KALK.DBF",cSezona,finverse,fda,fnul)
if FILE("KALKS.DBF")
  Skloni(KUMPATH,"KALKS.DBF",cSezona,finverse,fda,fnul)
endif
Skloni(KUMPATH,"kalk_doks.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"kalk_doks2.DBF",cSezona,finverse,fda,fnul)
if is_doksrc()
	Skloni(KUMPATH,"DOKSRC.DBF",cSezona,finverse,fda,fnul)
endif


fnul:=.f.
// proizvoljni izvjestaji
Skloni(KUMPATH,"KONIZ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KOLIZ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"IZVJE.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"ZAGLI.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"OBJEKTI.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"K1.DBF",cSezona,finverse,fda,fnul)

fnul:=.f.
Skloni(SIFPATH,"TARIFA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TNAL.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TDOK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TRFP.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONCIJ.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SAST.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)
if IsPlanika()
	Skloni(KUMPATH,"PRODNC.DBF",cSezona,finverse,fda,fnul)
	Skloni(SIFPATH,"RVRSTA.DBF",cSezona,finverse,fda,fnul)
endif

Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)



?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return



// ----------------------------------------------------
// ----------------------------------------------------
method setgaDBFs()
// prebaceno u f18_utils.prg
return


// -------------------------------------------------------
// -------------------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return


// -------------------------------------------------------
// -------------------------------------------------------
method kreiraj(nArea)
local lPoNarudzbi := .f.
local glBrojacPoKontima := .f.
local gVodiSamoTarife := "N"

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

CreFMKPI()

if IsPlanika() 

    aDbf:={}
    AADD(aDBf,{ 'PKONTO'             , 'C' ,   7 ,  0 })
    AADD(aDBf,{ 'IDROBA'             , 'C' ,  10 ,  0 })
    AADD(aDBf,{ 'IDTARIFA'           , 'C' ,   6 ,  0 })
    AADD(aDBf,{ 'IDVD'               , 'C' ,   2 ,  0 })
    AADD(aDBf,{ 'BRDOK'              , 'C' ,   8 ,  0 })
    AADD(aDBf,{ 'DATDOK'             , 'D' ,   8 ,  0 })
    AADD(aDBf,{ 'NC'                 , 'N' ,  20 ,  8 })
    // kolicina kod posljednje nabavke
    AADD(aDBf,{ 'KOLICINA'           , 'N' ,  12 ,  2 })
	if !FILE(f18_ime_dbf("prodnc"))
    		DBcreate2('PRODNC.DBF',aDbf)
	endif
	CREATE_INDEX("PRODROBA","PKONTO+IDROBA","PRODNC")

    //RVrsta.Dbf
    aDbf:={}
    AADD(aDBf,{ 'ID'              , 'C' ,  1 ,  0 })
    AADD(aDBf,{ 'NAZ'             , 'C' , 30 ,  0 })
	if !FILE(f18_ime_dbf("rvrsta"))
    		DBcreate2('RVRSTA.DBF',aDbf)
	endif
	CREATE_INDEX("ID","ID","RVRSTA")
	CREATE_INDEX("NAZ", "NAZ", "RVRSTA")

endif

return


// ----------------------------------------------------------------
// ----------------------------------------------------------------
method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_PRIPR .or. i==F_finmat .or. i==F_pripr2 .or. i==F_pripr9
	lIdiDalje:=.t.
endif

if i==F__KALK .or. i==F__ROBA .or. i==F__PARTN 
	lIdiDalje:=.t.
endif

if i==F_KALK .or. i=F_doks .or. i==F_ROBA .or. i==F_TARIFA .or. i==F_PARTN  .or. i==F_TNAL   .or. i==F_TDOK  .or. i==F_KONTO  
	lIdiDalje:=.t.
endif

if i==F_TRFP .or. i==F_VALUTE .or. i==F_KONCIJ .or. i==F_SAST  .or. i==F_BARKOD
	lIdiDalje:=.t.
endif

if i==F_PARAMS .or. i==F_GPARAMS .or. i==F_GPARAMSP .or. i==F_KORISN .or. i==F_MPARAMS .or. i==F_KPARAMS .or. i==F_ADRES
	lIdiDalje:=.t.
endif

if i==F_KONIZ .or. i==F_KOLIZ .or. i==F_IZVJE .or. i==F_ZAGLI
	lIdiDalje:=.t.
endif

if i==F_OBJEKTI .or. i==F_K1
	lIdiDalje:=.t.
endif

if is_doksrc()
	if i==F_P_DOKSRC .or. i==F_DOKSRC
		lIdiDalje := .t.
	endif
endif

if IsPlanika()
	if i==F_PRODNC .or. i==F_RVRSTA
		lIdiDalje:=.t.
	endif
endif


if (gSecurity=="D" .and. (i==F_EVENTS .or. i==F_EVENTLOG .or. i==F_USERS .or. i==F_GROUPS .or. i==F_RULES))
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


// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
method ostalef()

if pitanje(,"Formirati Bosanski sort","N")=="D"
   CREATE_INDEX("NAZ_B","BTOEU(Naz)","ROBA")
endif

if pitanje(,"Formirati KALKS ?","N")=="D"

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICINA'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'GKOLICIN2'           , 'N' ,  12 ,  3 })
AADD(aDBf,{ 'NC'                  , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'TMARZA'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA'               , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  12 ,  4 })
AADD(aDBf,{ 'RABATV'              , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'TMARZA2'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MARZA2'              , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'MPC'                 , 'N' ,  15 ,  8 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'MPCSAPP'             , 'N' ,  12 ,  4 })
AADD(aDBf,{ 'MKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'PKONTO'              , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'MU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PU_I'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'ERROR'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'PODBR'               , 'C' ,   2 ,  0 })

if !file(f18_ime_dbf("kalks"))
 ferase('KALKS.CDX')
 dbcreate2('KALKS.DBF',aDbf)
endif

CREATE_INDEX("1","idFirma+IdVD+BrDok+RBr","KALKS")
CREATE_INDEX("2","idFirma+idvd+brdok+IDTarifa","KALKS")
// 3 - vodjenje magacina
CREATE_INDEX("3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD","KALKS")
// 4 - vodjenje prodavnice
CREATE_INDEX("4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD","KALKS")
CREATE_INDEX("5","idFirma+dtos(datdok)+podbr+idvd+brdok","KALKS")
CREATE_INDEX("6","idFirma+IdTarifa+idroba","KALKS")
CREATE_INDEX("7","idroba","KALKS")
CREATE_INDEX("8","mkonto","KALKS")
CREATE_INDEX("9","pkonto","KALKS")
CREATE_INDEX("D","datdok","KALKS")

endif

return



// --------------------------------------------------------------------
// --------------------------------------------------------------------
method konvZn() 
LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

if !gAppSrv
	if !SigmaSif("KZ      ")
		return
	endif
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

aPriv := { F_pripr, F_finmat, F_pripr2, F_pripr9, F__KALK, F__ROBA,;
            F__PARTN, F_PORMP }
aKum  := { F_KALK, F_doks, F_KONIZ, F_IZVJE, F_ZAGLI, F_KOLIZ }
aSif  := { F_ROBA, F_TARIFA, F_PARTN, F_TNAL, F_TDOK, F_KONTO, F_TRFP,;
            F_VALUTE, F_KONCIJ, F_SAST }

IF cSif  == "N"
	aSif  := {}
ENDIF
IF cKum  == "N"
	aKum  := {}
ENDIF
IF cPriv == "N"
	aPriv := {}
ENDIF

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return



