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


#include "virm.ch"
#include "hbclass.ch"

// ----------------------------------------------------------
// ----------------------------------------------------------
CLASS TDbVirm INHERIT TDB 
	method New
	method setgaDBFs	
	method install	
	method obaza	
	method kreiraj	
	method konvZn
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::cName:="VIRM"
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


// -------------------------------------------------
// -------------------------------------------------
method kreiraj(nArea)
local _table_name
local _alias

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

if (nArea==nil)
	nArea:=-1
endif

if (nArea<>-1)
	CreSystemDb(nArea)
endif

aDbf:={}
AADD(aDBf,{ 'RBR'        , 'N' ,   3 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DAT_UPL'    , 'D' ,   8 ,   0 })
AADD(aDBf,{ 'SVRHA_PL'   , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NA_TERET'   , 'C' ,   6 ,   0 }) // ko  placa - sifra
AADD(aDBf,{ 'U_KORIST'   , 'C' ,   6 ,   0 }) // kome se placa - sifra
AADD(aDBf,{ 'KO_TXT'     , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KO_ZR'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_TXT'   , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KOME_ZR'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KO_SJ'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_SJ'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'SVRHA_DOZ'  , 'C' ,  92 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  10 ,   0 })
AADD(aDBf,{ 'Hitno'      , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'Vupl'       , 'C' ,   1 ,   0 })
AADD(aDBF,{ 'IdOps'      , 'C' ,   3 ,   0 })
AADD(aDBF,{ 'POd'        , 'D' ,   8 ,   0 })
AADD(aDBF,{ 'PDo'        , 'D' ,   8 ,   0 })
AADD(aDBF,{ 'BPO'        , 'C' ,  13 ,   0 })
AADD(aDBF,{ 'BudzOrg'    , 'C' ,   7 ,   0 })
AADD(aDBF,{ 'IdJPrih'    , 'C' ,   6 ,   0 })
AADD(aDBf,{ 'IZNOS'      , 'N' ,  20 ,   2 })
AADD(aDBf,{ 'IZNOSSTR'   , 'C' ,  20 ,   0 })
AADD(aDBf,{ '_ST_'   ,     'C' ,   1 ,   0 })

_tbl_name := "virm_pripr"
_alias := "VIRM_PRIPR"

if (nArea==-1 .or. nArea == (F_VIPRIPR))
	IF !FILE(f18_ime_dbf( _alias ))
		DBCREATE2(_alias, aDbf)
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)",_alias)
	CREATE_INDEX("2","DTOS(dat_upl)+STR(rbr,3)",_alias)
endif


aDbf:={}
AADD(aDBf,{ 'RBR'        , 'N' ,   3 ,   0 })
AADD(aDBf,{ 'MJESTO'     , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DAT_UPL'    , 'C' ,  15 ,   0 })
AADD(aDBf,{ 'SVRHA_PL'   , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NA_TERET'   , 'C' ,   6 ,   0 }) // ko  placa - sifra
AADD(aDBf,{ 'U_KORIST'   , 'C' ,   6 ,   0 }) // kome se placa - sifra
AADD(aDBf,{ 'KO_TXT'     , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KO_ZR'      , 'C' ,  31 ,   0 })
AADD(aDBf,{ 'KOME_TXT'   , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'KOME_ZR'    , 'C' ,  31 ,   0 })
AADD(aDBf,{ 'KO_SJ'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'KOME_SJ'    , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'SVRHA_DOZ'  , 'C' ,  92 ,   0 })
AADD(aDBf,{ 'PNABR'      , 'C' ,  19 ,   0 })
AADD(aDBf,{ 'Hitno'      , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'Vupl'       , 'C' ,   1 ,   0 })
AADD(aDBF,{ 'IdOps'      , 'C' ,   5 ,   0 })
AADD(aDBF,{ 'POd'        , 'C' ,  15 ,   0 })
AADD(aDBF,{ 'PDo'        , 'C' ,  15 ,   0 })
AADD(aDBF,{ 'BPO'        , 'C' ,  25 ,   0 })
AADD(aDBF,{ 'BudzOrg'    , 'C' ,  13 ,   0 })
AADD(aDBF,{ 'IdJPrih'    , 'C' ,  11 ,   0 })
AADD(aDBf,{ 'IZNOS'      , 'N' ,  20 ,   2 })
AADD(aDBf,{ 'IZNOSSTR'   , 'C' ,  20 ,   0 })
AADD(aDBf,{ '_ST_'   ,     'C' ,   1 ,   0 })

_table_name := "izlaz"
_alias := "IZLAZ"

if (nArea==-1 .or. nArea==(F_IZLAZ))
	IF !FILE( f18_ime_dbf(_alias) )
		DBCREATE2( _alias, aDbf )
	ENDIF
	CREATE_INDEX("1","STR(rbr,3)", _alias )
endif


aDbf:={}
AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
AADD(aDBf,{ 'NAZ'        , 'C' ,  55 ,   0 })
AADD(aDBf,{ 'POM_TXT'    , 'C' ,  65 ,   0 })
AADD(aDBf,{ 'IDKONTO'    , 'C' ,   7 ,   0 })
AADD(aDBf,{ 'IDPartner'  , 'C' ,   6 ,   0 })
AADD(aDBf,{ 'NACIN_PL'   , 'C' ,   1 ,   0 })
AADD(aDBf,{ 'RACUN'      , 'C' ,  16 ,   0 })
AADD(aDBf,{ 'DOBAV'      , 'C' ,   1 ,   0 })

_table_name := "vrprim"
_alias := "VRPRIM"

if (nArea==-1 .or. nArea==(F_VRPRIM))
	IF !FILE(f18_ime_dbf( _alias ) )
		DBCREATE2( _alias, aDbf)
        reset_semaphore_version( _table_name )
        my_use( _alias )
	ENDIF
	CREATE_INDEX("ID","id", _alias )
	CREATE_INDEX("NAZ","naz", _alias )
	CREATE_INDEX("IDKONTO","idkonto+idpartner", _alias )
endif

_table_name := "vrprim2"
_alias := "VRPRIM2"

if (nArea==-1 .or. nArea==(F_VRPRIM2))
	IF !FILE( f18_ime_dbf( _alias ) )
		DBCREATE2( _alias, aDbf )
	ENDIF
	CREATE_INDEX("ID","id", _alias )
	CREATE_INDEX("NAZ","naz", _alias )
	CREATE_INDEX("IDKONTO","idkonto+idpartner", _alias )
endif

_table_name := "ldvirm"
_alias := "LDVIRM"

if (nArea==-1 .or. nArea==(F_LDVIRM))
	IF !FILE( f18_ime_dbf( _alias ) )
		aDbf:={}
		AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
		AADD(aDBf,{ 'NAZ'        , 'C' ,  50 ,   0 })
		AADD(aDBf,{ 'FORMULA'    , 'C' ,  70 ,   0 })
		DBCREATE2( _alias , aDbf )
        reset_semaphore_version( _table_name )
        my_use( _alias )
	ENDIF
	CREATE_INDEX("ID","id", _alias)
endif

_table_name := "kalvir"
_alias := "KALVIR"

if (nArea==-1 .or. nArea==(F_KALVIR))
	IF !FILE( f18_ime_dbf( _alias ) )
		aDbf:={}
		AADD(aDBf,{ 'ID'         , 'C' ,   4 ,   0 })
		AADD(aDBf,{ 'NAZ'        , 'C' ,  20 ,   0 })
		AADD(aDBf,{ 'FORMULA'    , 'C' ,  70 ,   0 })
		AADD(aDBf,{ 'PNABR'      , 'C' ,  10 ,   0 })
		DBCREATE2( _alias, aDbf )
        reset_semaphore_version( _table_name )
        my_use( _alias )
	ENDIF
	CREATE_INDEX("ID","id", _alias )
endif

_table_name := "jprih"
_alias := "JPRIH"

if (nArea==-1 .or. nArea==(F_JPRIH))
	if !file( f18_ime_dbf( _alias ) )
		aDbf:={}
		AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
		AADD(aDBf,{ 'IdN0'                , 'C' ,   1 ,  0 })
		AADD(aDBf,{ 'IdKan'               , 'C' ,   2 ,  0 })
		AADD(aDBf,{ 'IdOps'               , 'C' ,   3 ,  0 })
		AADD(aDBf,{ 'Naz'                 , 'C' ,  40 ,  0 })
		AADD(aDBf,{ 'Racun'               , 'C' ,  16 ,  0 })
		AADD(aDBf,{ 'BudzOrg'             , 'C' ,  7 ,  0 })
		DBCREATE2( _alias, aDbf )
        reset_semaphore_version( _table_name )
        my_use( _alias )
	endif

	CREATE_INDEX("Id","id+IdOps+IdKan+IdN0+Racun", _alias )
	CREATE_INDEX("Naz","Naz+IdOps", _alias )
endif

return

// ----------------------------------------
// ----------------------------------------
method obaza(i)

local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_PARAMS .or. i==F_VIPRIPR .or. i==F_VIPRIP2 .or. i==F_IZLAZ  
	lIdiDalje:=.t.
endif

if i==F_LDVIRM .or. i==F_KALVIR .or. i==F_VRPRIM  .or. i==F_VRPRIM2 
	lIdiDalje:=.t.
endif

if i==F_JPRIH .or. i==F_PARTN .or. i==F_VALUTE .or. i==F_BANKE .or. i==F_OPS
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


// ------------------------------------------
// ------------------------------------------
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

aPriv:= { }
aKum:= { F_VRPRIM, F_K_VRPRIM, F_VRPRIM2 }
aSif:={ F_JPRIH, F_STAMP, F_STAMP2, F_PARTN, F_VALUTE, F_BANKE, F_OPS }

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
