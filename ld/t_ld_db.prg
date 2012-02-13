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


#include "ld.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbLd INHERIT TDB 
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

 ::cName:="LD"
 ::lAdmin:=.f.

 ::kreiraj()

return self

// ---------------------------------------------------------
// ---------------------------------------------------------
method skloniSezonu(cSezona,finverse,fda,fnulirati, fRS)

local cScr

if fDa==nil
	fDa:=.f.
endif

if fInverse==nil
	fInverse:=.f.
endif

if fNulirati==nil
	fNulirati:=.f.
endif

if fRs==nil
	// mrezna radna stanica , sezona je otvorena
  	fRs:=.f.
endif

if fRs // radna stanica
	if File(PRIVPATH+cSezona+SLASH+"_RADKR.DBF")
      	// nema se sta raditi ......., pripr.dbf u sezoni postoji !
      		return
	endif
  	aFilesK:={}
  	aFilesS:={}
  	aFilesP:={}
endif

save screen to cScr

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
// privatni
fNul:=.f.

Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_RADKR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_OPSLD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_KRED.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_PRIPNO.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_LD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"GPARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"LDT22.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"OPSLD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"REKNI.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if fNulirati
	fNul:=.t.
else
	fNul:=.f.
endif  

Skloni(PRIVPATH,"LDSM.DBF",cSezona,finverse,fda,fnul)

if fRs
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak.."
 	restore screen from cScr
 	return
endif

fNul:=.f.

Skloni(KUMPATH,"RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RADKR.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"LD.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KPARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"NORSIHT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RADSIHT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"REKLD.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"TPRSIHT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"PK_RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"PK_DATA.DBF",cSezona,finverse,fda,fnul)

fNul:=.f.

Skloni(SIFPATH,"PAROBR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KRED.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"POR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"DOPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"STRSPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KBENEF.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VPOSLA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TIPPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TIPPR2.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

//sifrarnici
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



// -------------------------------------------------
// -------------------------------------------------
method install(cKorisn,cSifra,p3,p4,p5,p6,p7)
	install_start(goModul,.f.)
return


// -------------------------------------------------
// -------------------------------------------------
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

// REKLD
aDbf:={}
AADD( aDbf, {"GODINA"     ,  "C" ,  4, 0})
AADD( aDbf, {"MJESEC"     ,  "C" ,  2, 0})
AADD( aDbf, {"ID"         ,  "C" , 40, 0})
AADD( aDbf, {"OPIS"       ,  "C" , 40, 0})
AADD( aDbf, {"IZNOS1"     ,  "N" , 18, 4})
AADD( aDbf, {"IZNOS2"     ,  "N" , 18, 4})
AADD( aDbf, {"IDPARTNER"  ,  "C" ,  6, 0})

if !FILE( f18_ime_dbf( "REKLD" ) )
    DBCreate2( "REKLD", aDbf )
endif

CREATE_INDEX("1","godina+mjesec+id", "REKLD" )
CREATE_INDEX("2","godina+mjesec+id+idpartner", "REKLD" )

AADD( aDbf, {"IDRNAL"  ,  "C" , 10, 0})

if !FILE(f18_ime_dbf( "REKLDP" ))
    DBCreate2( "REKLDP", aDbf )
endif

CREATE_INDEX("1","godina+mjesec+id+idRNal", "REKLDP" )


aDbf := {} 
AADD( aDbf, {"ID"     ,  "C" ,  1, 0})
AADD( aDbf, {"IDOPS"  ,  "C" ,  4, 0})
AADD( aDbf, {"IZNOS"  ,  "N" , 18, 4})
AADD( aDbf, {"IZNOS2" ,  "N" , 18, 4})
AADD( aDbf, {"LJUDI"  ,  "N" ,  4, 0})

if !FILE( f18_ime_dbf("OPSLD") )
    DBCreate2( "OPSLD", aDbf )
endif

CREATE_INDEX("1","id+idops", "OPSLD" )

return


// -------------------------------------------
// -------------------------------------------
method obaza(i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F__LD .or. i==F__RADN .or. i==F__RADKR .or. i==F_LDSM .or. i==F_OPSLD 
	lIdiDalje:=.t.
endif

if i==F_PK_RADN .or. i==F_PK_DATA
	lIdiDalje := .t.
endif

if i==F_LD .or. i=F_RADN .or. i==F_RADKR .or. i==F_RJ .or. i==F_RADSIHT .or. i==F_NORSIHT .or. i==F_TPRSIHT 
	lIdiDalje:=.t.
endif

if i==F_POR .or. i==F_DOPR .or. i==F_PAROBR .or. i==F_TIPPR .or. i==F_TIPPR2 .or. i==F_KRED .or. i==F_STRSPR .or. i==F_KBENEF .or. i==F_VPOSLA .or. i==F_BANKE
	lIdiDalje := .t.
endif

if i==F_OBRACUNI .or. i==F_RADSAT
	lIdiDalje := .t.
endif

if (gSecurity=="D" .and. (i==175 .or. i==176 .or. i==177 .or. i==178 .or. I==179))
	lIdiDalje := .t.
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
	
	select (i)
	usex (cDbfName)
else
	use
	return
endif


return


// -------------------------------------------
// -------------------------------------------
method ostalef()
return

// -------------------------------------------
// -------------------------------------------
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

private aKonvZN:={}

if !gAppSrv	
	if !SigmaSif("KZ      ")
		return
	endif

	Box(,8,50)
	@ m_x+2, m_y+2 SAY "Trenutni standard (7/8)        " GET cIz   VALID   cIz$"78B"  PICT "@!"
  	@ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)" GET cU    VALID    cU$"78AB" PICT "@!"
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
		@ 10, 2 SAY "Trenutni standard (7/8)        " GET cIz VALID cIz$"78B" PICT "@!"
		?
		@ 11, 2 SAY "Konvertovati u standard (7/8/A)" GET cU VALID cU$"78AB" PICT "@!"
		read
	endif
	cSif:="D"
	cKum:="D"
	cPriv:="D"
endif

aPriv:= {}
aKum:= { F_LD, F_RADKR, F_RADN, F_RJ, F_PK_RADN, F_PK_DATA }
aSif:={F_PAROBR, F_TIPPR, F_TIPPR, F_STRSPR, F_KBENEF, F_VPOSLA, F_OPS, F_POR, F_DOPR, F_RJ, F_KRED, F_LDSM }

if cSif=="N"
	aSif:={}
endif

if cKum=="N"
	aKum:={}
endif

if cPriv=="N"
	aPriv:={}
endif

private aSifRev:={}
//
if cU=="B" .or. cIz=="B" 
	KZNBaza(aPriv, aKum, aSif, cIz, cU, "B")
else
	KZNBaza(aPriv, aKum, aSif, cIz, cU)
endif

// Odstampaj rezultate zamjene sifara
START PRINT CRET
? "Stanje zamjene sifara: Obracun plata"
?
? "--------------------------------------------------------"
? "RADNICI: "
? "Stara sifra  -  Nova sifra  -  Ime i prezime radnika"
? "--------------------------------------------------------"
O_RADN
for i:=1 to LEN(aKonvZN)
	select radn
	set order to tag "1"
	seek aKonvZN[i, 2]
	
	? aKonvZN[i, 1] + "       -   " + aKonvZN[i, 2] + "     -  " + ALLTRIM(radn->ime) + " " + ALLTRIM(radn->naz) 
next

?

FF
END PRINT

return


