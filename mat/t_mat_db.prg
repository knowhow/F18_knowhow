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



/*
method setgaDBFs()
PUBLIC gaDBFs:={}

AADD(gaDBFs, { F_PARAMS, "PARAMS", P_PRIVPATH  } )
AADD(gaDBFs, { F_mat_pripr, "mat_pripr", P_PRIVPATH  } )
AADD(gaDBFs, { F_INVENT, "INVENT", P_PRIVPATH  } )
AADD(gaDBFs, { F_Pmat_suban, "Pmat_suban", P_PRIVPATH  } )
AADD(gaDBFs, { F_Pmat_sint, "Pmat_sint", P_PRIVPATH  } )
AADD(gaDBFs, { F_Pmat_anal, "Pmat_anal", P_PRIVPATH  } )
AADD(gaDBFs, { F_Pmat_nalog, "Pmat_nalog", P_PRIVPATH  } )

AADD(gaDBFs, { F_mat_suban, "mat_suban", P_KUMPATH  } )
AADD(gaDBFs, { F_mat_anal, "mat_anal", P_KUMPATH  } )
AADD(gaDBFs, { F_mat_sint, "mat_sint", P_KUMPATH  } )
AADD(gaDBFs, { F_mat_nalog, "mat_nalog", P_KUMPATH  } )

AADD(gaDBFs, { F_KONTO, "KONTO", P_SIFPATH } )
AADD(gaDBFs, { F_PARTN, "PARTN", P_SIFPATH } )
AADD(gaDBFs, { F_VALUTE, "VALUTE", P_SIFPATH } )
AADD(gaDBFs, { F_TARIFA, "TARIFA", P_SIFPATH } )
AADD(gaDBFs, { F_TNAL, "TNAL", P_SIFPATH } )
AADD(gaDBFs, { F_TDOK, "TDOK", P_SIFPATH } )
AADD(gaDBFs, { F_ROBA, "ROBA", P_SIFPATH } )
AADD(gaDBFs, { F_KARKON, "KARKON", P_SIFPATH } )

return
*/

 
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

CreFmkSvi()
CreRoba()
CreFmkPi()

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'DATNAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DUG'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DUG2'                , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT2'                , 'N' ,  15 ,  2 })

if !file(f18_ime_dbf( "mat_nalog" )
        DBCREATE2( "mat_nalog", aDbf )
		reset_semaphore_version("mat_nalog")
		my_use("mat_nalog")
endif

if !file( f18_ime_dbf( "mat_pnalog" ))
        DBCREATE2( "mat_pnalog", aDbf)
endif

CREATE_INDEX("1","IdFirma+IdVn+BrNal", "mat_nalog") // Nalozi
CREATE_INDEX("1","IdFirma", "mat_pnalog") // Nalozi

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'IDTIPDOK'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'U_I'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'KOLICINA'            , 'N' ,  10 ,  3 })
AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IZNOS'               , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'IDPartner'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDZaduz'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IZNOS2'              , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DatKurs'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K4'                  , 'C' ,   2 ,  0 })

if !file( f18_ime_dbf( "mat_suban" ))
        DBCREATE2("mat_suban", aDbf)
		reset_semaphore_version("mat_suban")
		my_use("mat_nalog")
endif

if !file( f18_ime_dbf( "mat_psuban" ))
        DBCREATE2( 'mat_psuban', aDbf )
endif

CREATE_INDEX("1","IdFirma+IdRoba+dtos(DatDok)"        , KUMPATH+"mat_suban")
CREATE_INDEX("2","IdFirma+IdPartner+IdRoba"           , KUMPATH+"mat_suban")
CREATE_INDEX("3","IdFirma+IdKonto+IdRoba+dtos(DatDok)", KUMPATH+"mat_suban")
CREATE_INDEX("4","idFirma+IdVN+BrNal+rbr"             , KUMPATH+"mat_suban")
CREATE_INDEX("5","IdFirma+IdKonto+IdPartner+IdRoba+dtos(DatDok)", ;
	KUMPATH+"mat_suban")
CREATE_INDEX("1","idFirma+idvn+brnal"        , PRIVPATH+"mat_psuban")
CREATE_INDEX("2","idFirma+IdVN+Brnal+IdKonto", PRIVPATH+"mat_psuban")

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'DATNAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'DUG'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DUG2'                , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT2'                , 'N' ,  15 ,  2 })

if !file(f18_ime_dbf( 'mat_anal' ))
        DBCREATE2('mat_anal', aDbf)
		reset_semaphore_version("mat_anal")
		my_use("mat_anal")
endif

if !file( f18_ime_dbf( 'mat_panal' ))
        DBCREATE2( 'mat_panal', aDbf)
endif

CREATE_INDEX("1","IdFirma+IdKonto+dtos(DatNal)",KUMPATH+"mat_anal")  //mat_analiti
CREATE_INDEX("2","idFirma+IdVN+BrNal+IdKonto",KUMPATH+"mat_anal")
CREATE_INDEX("1","IdFirma+idvn+brnal+idkonto",PRIVPATH+"mat_panal")

aDbf:={}
AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'DATNAL'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'RBR'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'DUG'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT'                 , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'DUG2'                , 'N' ,  15 ,  2 })
AADD(aDBf,{ 'POT2'                , 'N' ,  15 ,  2 })

if !file( f18_ime_dbf( 'mat_sint' ))
        DBCREATE2( 'mat_sint', aDbf )
		reset_semaphore_version("mat_sint")
		my_use("mat_sint")
endif

if !file( f18_ime_dbf( 'mat_psint' ))
        DBCREATE2( 'mat_psint', aDbf )
endif

CREATE_INDEX("1","IdFirma+IdKonto+dtos(DatNal)",KUMPATH+"mat_sint")  // mat_sinteti
CREATE_INDEX("2","idFirma+IdVN+BrNal+IdKonto",KUMPATH+"mat_sint")
CREATE_INDEX("1","IdFirma",PRIVPATH+"mat_psint")

if !file( f18_ime_dbf( 'mat_pripr' ) )
        aDbf:={}
        AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
        AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
        AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'BRNAL'               , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'IDTIPDOK'            , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
        AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
        AADD(aDBf,{ 'U_I'                 , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'KOLICINA'            , 'N' ,  10 ,  3 })
        AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'IZNOS'               , 'N' ,  15 ,  2 })
        AADD(aDBf,{ 'CIJENA'              , 'N' ,  15 ,  3 })
        AADD(aDBf,{ 'IDPartner'           , 'C' ,   6 ,  0 })
        AADD(aDBf,{ 'IDZaduz'             , 'C' ,   6 ,  0 })
        AADD(aDBf,{ 'IZNOS2'              , 'N' ,  15 ,  2 })
        AADD(aDBf,{ 'DATKURS'             , 'D' ,   8 ,  0 })
        AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'K4'                  , 'C' ,   2 ,  0 })
        DBCREATE2( 'mat_pripr', aDbf )
endif
CREATE_INDEX("1","idFirma+IdVN+BrNal+rbr",PRIVPATH+"mat_pripr")
CREATE_INDEX("2","idFirma+IdVN+BrNal+BrDok+Rbr",PRIVPATH+"mat_pripr")
CREATE_INDEX("3","idFirma+IdVN+IdKonto",PRIVPATH+"mat_pripr")


if !file( f18_ime_dbf( 'INVENT' ))
        aDbf:={}
//        AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'IDROBA'              , 'C' ,  10 ,  0 })
        AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
        AADD(aDBf,{ 'BROJXX'              , 'N' ,   8 ,  2 })
        AADD(aDBf,{ 'KOLICINA'            , 'N' ,  10 ,  2 })
        AADD(aDBf,{ 'CIJENA'              , 'N' ,  12 ,  2 })
        AADD(aDBf,{ 'IZNOS'               , 'N' ,  14 ,  2 })
        AADD(aDBf,{ 'IZNOS2'              , 'N' ,  14 ,  2 })
        DBCREATE2( 'INVENT', aDbf)
endif
CREATE_INDEX("1","IdRoba", "INVENT") // Inventura


if !file(f18_ime_dbf( 'KARKON' ))
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,  7  ,  0 })
        AADD(aDBf,{ 'TIP_NC'              , 'C' ,  1 ,   0 })
        AADD(aDBf,{ 'TIP_PC'              , 'C' ,  1 ,   0 })
        DBCREATE2( 'KARKON', aDbf )
		reset_semaphore_version("karkon")
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


