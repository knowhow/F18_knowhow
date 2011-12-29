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
//if lViseObr
Skloni(SIFPATH,"TIPPR2.DBF",cSezona,finverse,fda,fnul)
//endif
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
local lVOBrisiCDX := .f.
local lViseObr := .f.

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


// REKLD
aDbf:={}
AADD( aDbf, {"GODINA"     ,  "C" ,  4, 0})
AADD( aDbf, {"MJESEC"     ,  "C" ,  2, 0})
AADD( aDbf, {"ID"         ,  "C" , 40, 0})
AADD( aDbf, {"OPIS"       ,  "C" , 40, 0})
AADD( aDbf, {"IZNOS1"     ,  "N" , 18, 4})
AADD( aDbf, {"IZNOS2"     ,  "N" , 18, 4})
AADD( aDbf, {"IDPARTNER"  ,  "C" ,  6, 0})

if (nArea==-1 .or. nArea==(F_REKLD))
	//REKLD.DBF

	if !FILE(f18_ime_dbf("REKLD"))
  		DBCreate2( "REKLD.DBF", aDbf )
	endif

  	CREATE_INDEX("1","godina+mjesec+id",KUMPATH+"REKLD")
  	CREATE_INDEX("2","godina+mjesec+id+idpartner",KUMPATH+"REKLD")
endif

if (nArea==-1 .or. nArea==(F_REKLDP))
	//REKLDP.DBF
	
	AADD( aDbf, {"IDRNAL"  ,  "C" , 10, 0})

	if !FILE(f18_ime_dbf("REKLDP"))
  		DBCreate2( "REKLDP.DBF", aDbf)
	endif

  	CREATE_INDEX("1","godina+mjesec+id+idRNal",KUMPATH+"REKLDP")
endif


// OPSLD
if (nArea==-1 .or. nArea==(F_OPSLD))

	if !FILE(f18_ime_dbf("OPSLD"))
	
  		aDbf:={ {"ID"    , "C" ,  1, 0},;
            		{"IDOPS" , "C" ,  4, 0},;
            		{"IZNOS" , "N" , 18, 4},;
            		{"IZNOS2", "N" , 18, 4},;
            		{"LJUDI" , "N" ,  4, 0} ;
          		}
  		DBCREATE2( "OPSLD.DBF", aDbf )
		
	endif

  	CREATE_INDEX("1","id+idops",PRIVPATH+"OPSLD")
endif


aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'Aktivan'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Fiksan'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'UFS'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'UNeto'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Koef1'               , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'Formula'             , 'C' , 200 ,  0 })
AADD(aDBf,{ 'OPIS'                , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'TPR_TIP'             , 'C' ,   1 ,  0 })

if !file(f18_ime_dbf("TIPPR"))
   	DBCREATE2( 'TIPPR', aDbf)
	reset_semaphore_version("tippr")
	my_use("TIPPR")
endif

CREATE_INDEX("ID","id",SIFPATH+"TIPPR")

if !file(f18_ime_dbf("TIPPR2"))
   	DBCREATE2( 'TIPPR2', aDbf )
	reset_semaphore_version("tippr2")
	my_use("TIPPR2")
endif

CREATE_INDEX("ID","id",SIFPATH+"TIPPR2")

// RJ
if !file(f18_ime_dbf("ld_rj"))
	aDBf:={}
   	AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
   	add_f_mcode(@aDbf)
   	AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
   	AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  0 })
   	AADD(aDBf,{ 'OPOR'                , 'C' ,   1 ,  0 })
   	DBCREATE2( "LD_RJ", aDbf )
	reset_semaphore_version("ld_rj")
	my_use("ld_rj")
endif
CREATE_INDEX("ID","id",KUMPATH+"LD_RJ")

// KRED
aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'ZIRO'                , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ZIROD'               , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'TELEFON'             , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'MJESTO'              , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ADRESA'              , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'PTT'                 , 'C' ,   5 ,  0 })
AADD(aDBf,{ 'FIL'                 , 'C' ,  30 ,  0 })
if !file(f18_ime_dbf("KRED"))
   	DBCREATE2( 'KRED', aDbf )
	reset_semaphore_version("kred")
	my_use("KRED")
endif

if !file(f18_ime_dbf("_KRED"))
   DBCREATE2( '_KRED',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"KRED")
CREATE_INDEX("NAZ","naz",SIFPATH+"KRED")


// POR
if !file(f18_ime_dbf("POR"))

   	aDBf:={}
  	
	AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
    add_f_mcode(@aDbf)
   	AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   	AADD(aDBf,{ 'IZNOS'               , 'N' ,   5 ,  2 })
   	AADD(aDBf,{ 'DLIMIT'              , 'N' ,  12 ,  2 })
   	AADD(aDBf,{ 'POOPST'              , 'C' ,   1 ,  0 })
   	AADD(aDBf,{ 'POR_TIP'             , 'C' ,   1 ,  0 })
	// stepenasti porez
	AADD(aDBf,{ 'ALGORITAM'           , 'C' ,   1 ,  0 })
	AADD(aDBf,{ 'S_STO_1'             , 'N' ,   5 ,  2 })
	AADD(aDBf,{ 'S_IZN_1'             , 'N' ,  12 ,  2 })
   	AADD(aDBf,{ 'S_STO_2'             , 'N' ,   5 ,  2 })
	AADD(aDBf,{ 'S_IZN_2'             , 'N' ,  12 ,  2 })
   	AADD(aDBf,{ 'S_STO_3'             , 'N' ,   5 ,  2 })
	AADD(aDBf,{ 'S_IZN_3'             , 'N' ,  12 ,  2 })
   	AADD(aDBf,{ 'S_STO_4'             , 'N' ,   5 ,  2 })
	AADD(aDBf,{ 'S_IZN_4'             , 'N' ,  12 ,  2 })
   	AADD(aDBf,{ 'S_STO_5'             , 'N' ,   5 ,  2 })
	AADD(aDBf,{ 'S_IZN_5'             , 'N' ,  12 ,  2 })
   
	DBCREATE2( 'POR', aDbf )
	reset_semaphore_version("por")
	my_use("POR")

endif

CREATE_INDEX("ID","id",SIFPATH+"POR")


// DOPR
if !file(f18_ime_dbf("DOPR"))
   
	aDBf:={}
   	AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
    add_f_mcode(@aDbf)
   	AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   	AADD(aDBf,{ 'IZNOS'               , 'N' ,   5 ,  2 })
   	AADD(aDBf,{ 'IdKBenef'            , 'C' ,   1 ,  0 })
   	AADD(aDBf,{ 'DLIMIT'              , 'N' ,  12 ,  2 })
   	AADD(aDBf,{ 'POOPST'              , 'C' ,   1 ,  0 })
   	AADD(aDBf,{ 'DOP_TIP'             , 'C' ,   1 ,  0 })
   	AADD(aDBf,{ 'TIPRADA'             , 'C' ,   1 ,  0 })
	
   	DBCREATE2( 'DOPR', aDbf )
	reset_semaphore_version("dopr")
	my_use("dopr")

endif

CREATE_INDEX("ID","id",SIFPATH+"DOPR")

if !file(f18_ime_dbf("LDSM"))
   AADD(aDBf, { "Obr","C",1,0 } )      // obracun
   DBCREATE2(PRIVPATH+"LDSM.DBF",aDbf)
endif

CREATE_INDEX("1","Obr+str(godina)+str(mjesec)+idradn+idrj",PRIVPATH+"LDSM")
CREATE_INDEX("RADN","idradn",PRIVPATH+"LDSM")

if !file(f18_ime_dbf("_LD"))
   DBCREATE2(PRIVPATH+"_LD.DBF",aDbf)
endif

if !file(f18_ime_dbf("STRSPR"))
    aDbf:={ {"id","C",3,0} ,;
            {"naz","C",20,0} ,;
            {"naz2","C",6,0} ;
                }
    DBCREATE2( "STRSPR", aDbf )
	reset_semaphore_version( "strspr" )
	my_use("STRSPR")

endif


CREATE_INDEX("ID","id",SIFPATH+"strspr")

if !file(f18_ime_dbf("KBENEF"))
   aDbf:={ {"id","C",1,0} ,;
           {"naz","C",8,0} ,;
           {"iznos","N",5,2} ;
         }
  	DBCREATE2( "KBENEF", aDbf )
	reset_semaphore_version( "kbenef" )
	my_use("KBENEF")
	
endif

CREATE_INDEX("ID","id",SIFPATH+"KBENEF")


if !file(f18_ime_dbf("VPOSLA"))  // vrste posla
   aDbf:={  {"id","C",2,0}   ,;
            {"naz","C",20,0} ,;
            {"idkbenef","C",1,0} ;
         }
	DBCREATE2( "VPOSLA", aDbf )
	reset_semaphore_version( "vposla" )
	my_use( "VPOSLA" )

endif

CREATE_INDEX("ID","id",SIFPATH+"VPOSLA")


//RADSIHT
aDbf:={}
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Dan'                 , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'DanDio'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDRADN'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
AADD(aDBf,{ 'OPIS'                , 'C' ,  50 ,  0 })
AADD(aDBf,{ 'IDTipPR'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'IdNorSiht'           , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'Izvrseno'            , 'N' ,  14 ,  3 })
AADD(aDBf,{ 'Bodova'              , 'N' ,  14 ,  2 })

if !file(f18_ime_dbf("RADSIHT"))
	DBCREATE2( "RADSIHT", aDBF )
	reset_semaphore_version( "ld_radsiht" )
	my_use("RADSIHT")
endif

CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idrj+str(dan)+dandio+idtippr",KUMPATH+"RADSIHT")
CREATE_INDEX("2","idkonto+str(godina)+str(mjesec)+idradn",KUMPATH+"RADSIHT")
CREATE_INDEX("3","idnorsiht+str(godina)+str(mjesec)+idradn",KUMPATH+"RADSIHT")
CREATE_INDEX("4","idradn+str(godina)+str(mjesec)+idkonto",KUMPATH+"RADSIHT")


//NORSIHT - norme u sihtarici - koristi se vjerovatno samo kod rada u normi
aDbf:={}
AADD(aDBf,{ 'ID'                , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'JMJ'               , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'Iznos'             , 'N' ,   8 ,  2 })
AADD(aDBf,{ 'N1'                , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })

if !file(f18_ime_dbf("NORSIHT"))

	DBCREATE2( "NORSIHT", aDBF)
	reset_semaphore_version("ld_norsiht")
	my_use("NORSIHT")

endif

CREATE_INDEX("ID","id",KUMPATH+"NORSIHT")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"NORSIHT")

//TPRSIHT   - tipovi primanja koji odradjuju sihtaricu
aDbf:={}
AADD(aDBf,{ 'ID'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
// K1="F" - po formuli
//    " " - direktno se unose bodovi
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K3'                , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'FF'                , 'C' ,  30 ,  0 })

if !file(f18_ime_dbf("TPRSIHT"))
	DBCREATE2( "TPRSIHT", aDBF )
	reset_semaphore_version("ld_tprsiht")
	my_use("TPRSIHT")
endif

CREATE_INDEX("ID","id",KUMPATH+"TPRSIHT")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"TPRSIHT")

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


