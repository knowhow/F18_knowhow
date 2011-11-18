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


#include "fakt.ch"
#include "hbclass.ch"

CLASS TDbFakt INHERIT TDB 
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

 ::cName:="FAKT"
 ::lAdmin:=.f.

 ::kreiraj()

return self



/*! \fn *void TDBFakt::skloniSezonu(string cSezona, bool finverse,bool fda,bool fnulirati,bool fRS)
 *  \brief formiraj sezonsku bazu podataka
 *  \param cSezona - 
 *  \param fInverse - .t. iz sezone u radno, .f. iz radnog u sezonu
 *  \param fda - ne znam
 *  \param fnulirati - nulirati tabele
 *  \param fRS - ne znam
 */

*void TDBFakt::skloniSezonu(string cSezona, bool fInverse,bool fDa,bool fNulirati,bool fRS)
*{

method skloniSezonu(cSezona,fInverse,fDa,fNulirati,fRS)

save screen to cScr

if fDa==nil
	fDA:=.f.
endif

if fInverse==nil
	fInverse:=.f.
endif

if fNulirati==nil
	fNulirati:=.f.
endif

if fRS==nil
	// mrezna radna stanica , sezona je otvorena
  	fRS:=.f.
endif

if fRS // radna stanica
	if File(PRIVPATH+cSezona+"\FAKT_PRIPR.DBF")
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
	? "Prenos iz sezonskih direktorija u radne podatke"
else
 	? "Prenos radnih podataka u sezonske direktorije"
endif

?

fNul:=.f.

MsgBeep("Sklanjam privatne direktorije!!!")

Skloni(PRIVPATH,"FAKT_PRIPR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FAKT_PRIPR.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FAKT_PRIPR9.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FAKT_PRIPR9.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_FAKT.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_FAKT.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"BARKOD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FDEVICE.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"ZAGL.TXT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"NAR.TXT",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"FMK.INI",cSezona,finverse,fda,fnul)

if IsStampa()
	Skloni(KUMPATH,"POMGN",cSezona,finverse,fda,fnul)
	Skloni(KUMPATH,"PPOMGN",cSezona,finverse,fda,fnul)
endif

if fRS
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak..."
	restore screen from cScr
 	return
endif


// kumulativ datoteke

MsgBeep("Sklanjam kumulativne direktorije!!!")

Skloni(KUMPATH,"FAKT.FPT",cSezona,fInverse,fDa,fNul)

if fNulirati
	fNul:=.t.
else
	fNul:=.f.
endif  

Skloni(KUMPATH,"FAKT.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOKS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"DOKS2.DBF",cSezona,finverse,fda,fnul)

if fNulirati
	fNul:=.f.
else
	fNul:=.t.
endif  

Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"UGOV.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RUGOV.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"GEN_UG.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"GEN_UG_P.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"KALPOS.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"FMK.INI",cSezona,finverse,fda,fnul)


// Sif PATH
MsgBeep("Sklanjam direktorij sifrarnika!!!")

Skloni(SIFPATH,"TARIFA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"ROBA.FPT",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"PARTN.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FTXT.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VALUTE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SAST.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KONTO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FADO.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FADE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"BANKE.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VRSTEP.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VOZILA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"RELAC.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"DEST.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"FMK.INI",cSezona,finverse,fda,fnul)

?
?
?
Beep(4)
? "pritisni nesto za nastavak..."

restore screen from cScr
return
*}

/*! \fn *void TDBFakt::setgaDBFs()
 *  \brief Setuje matricu gaDBFs 
 */
*void TDBFakt::setgaDBFs()
*{
method setgaDBFs()
// prebaceno u f18_utils.prg
return
*}


/*! \fn *void TDBFakt::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
 *  \brief osnovni meni za instalacijske procedure
 */

*void TDBFakt::install(string cKorisn,string cSifra,variant p3,variant p4,variant p5,variant p6,variant p7)
method install()
	install_start(goModul, .f.)
return

/*! \fn *void TDBFakt::Kreiraj(int nArea)
 *  \brief Kreiranje baze podataka Fakt-a
 */
 
*void TDBFakt::Kreiraj(int nArea)
*{
method Kreiraj(nArea)
local lPoNarudzbi := .f.
local glDistrib := .f.

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

CreFMKSvi()
CreRoba()
if IsRabati()
	CreRabDB()
endif
CreFMKPI()

if (nArea==nil)
	nArea:=-1
endif

Beep(1)

if (nArea<>-1)
	CreSystemDb(nArea)
endif

if (nArea==-1 .or. nArea==(F_UPL))
	
	//UPL.DBF
	aDBf:={}
   	AADD(aDBf,{'DATUPL'     ,'D', 8,0})
   	AADD(aDBf,{'IDPARTNER'  ,'C', 6,0})
   	AADD(aDBf,{'OPIS'       ,'C',30,0})
   	AADD(aDBf,{'IZNOS'      ,'N',12,2})
   	if !FILE(f18_ime_dbf("UPL"))
		DBcreate2(KUMPATH+"UPL.DBF",aDbf)
	endif

	CREATE_INDEX("1","IDPARTNER+DTOS(DATUPL)",KUMPATH+"UPL")
	CREATE_INDEX("2","IDPARTNER",KUMPATH+"UPL")
endif


if (nArea==-1 .or. nArea==(F_FTXT))
        
	//FTXT.DBF
	aDbf:={}
        AADD(aDBf,{'ID'  ,'C',  2 ,0})
        AADD(aDBf,{'NAZ' ,'C',340 ,0})
	if !FILE(f18_ime_dbf("FTXT"))
        	DBcreate2(SIFPATH+'FTXT.DBF',aDbf)
	endif
	
	CREATE_INDEX("ID","ID",SIFPATH+"FTXT")
endif


aDbf:={}
AADD(aDBf,{ 'IDFIRMA'   , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IdTIPDok'  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRDOK'     , 'C' ,   8 ,  0 })
AADD(aDBf,{ 'DATDOK'    , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'IDPARTNER' , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'DINDEM'    , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'zaokr'     , 'N' ,   1 ,  0 })
AADD(aDBf,{ 'Rbr'       , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'PodBr'     , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDROBA'    , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'SerBr'     , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'KOLICINA'  , 'N' ,  14 ,  5 })
AADD(aDBf,{ 'Cijena'    , 'N' ,  14 ,  5 })
AADD(aDBf,{ 'Rabat'     , 'N' ,   8 ,  5 })
AADD(aDBf,{ 'Porez'     , 'N' ,   9 ,  5 })
AADD(aDBf,{ 'K1'        , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'K2'        , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'M1'        , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'TXT'       , 'M' ,  10 ,  0 })
AADD(aDBf,{ 'IDVRSTEP'  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDPM'      , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'DOK_VEZA'  , 'C' , 150 ,  0 })
AADD(aDBf,{ 'FISC_RN'   , 'N' ,  10 ,  0 })

if IsRabati()
	AADD(aDBf,{ 'TIPRABAT'  , 'C' ,  10 ,  0 })
	AADD(aDBf,{ 'SKONTO'    , 'N' ,  10 ,  5 })
endif

if (nArea==-1 .or. nArea==(F_FAKT))
	//FAKT.DBF
	
	if !FILE(f18_ime_dbf("FAKT"))
        	DBcreate2(KUMPATH+'FAKT.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",KUMPATH+"FAKT")
	CREATE_INDEX("2","IdFirma+dtos(datDok)+idtipdok+brdok+rbr",KUMPATH+"FAKT")
	CREATE_INDEX("3","idroba+dtos(datDok)",KUMPATH+"FAKT")
	if lPoNarudzbi = .t.
 		// sifru gradi IDNAR + idroba !!!!!!!!!!
  		CREATE_INDEX("3N","idnar+idroba+dtos(datDok)",KUMPATH+"FAKT")
	endif
	if izfmkini("SifRoba","ID_J")=="D"
 		// sifru gradi IDROBA_J + idroba !!!!!!!!!!
 		CREATE_INDEX("3J","idroba_j+idroba+dtos(datDok)",KUMPATH+"FAKT")
	endif
	// ako se koristi varijanta DITRIBUCIJA ukljuci i ove indexe
	if glDistrib = .t.
		CREATE_INDEX("4","idfirma+idtipdok+dtos(datdok)+idrelac+marsruta+brdok+rbr",KUMPATH+"FAKT")
  		CREATE_INDEX("5","idfirma+idtipdok+dtos(datdok)+idrelac+iddist+idvozila+idroba",KUMPATH+"FAKT")
	endif

  	CREATE_INDEX("6","idfirma+idpartner+idroba+idtipdok+dtos(datdok)",KUMPATH+"FAKT")
  	CREATE_INDEX("7","idfirma+idpartner+idroba+dtos(datdok)",KUMPATH+"FAKT")

endif


if (nArea==-1 .or. nArea==(F_FAKT_PRIPR))
	//PRIPR.DBF

	if IsRabati()
		AADD(aDBf,{ 'TIPRABAT'    , 'C' ,  10 ,  0 })
	endif
	
	if !FILE(f18_ime_dbf("fakt_pripr"))
        	DBcreate2(PRIVPATH+"FAKT_PRIPR.DBF",aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",PRIVPATH+"FAKT_PRIPR")
	CREATE_INDEX("2","IdFirma+dtos(datdok)",PRIVPATH+"FAKT_PRIPR")
	CREATE_INDEX("3","IdFirma+idroba+rbr",PRIVPATH+"FAKT_PRIPR")
	if IsRabati()
		CREATE_INDEX("4","IdFirma+idtipdok+rbr",PRIVPATH+"FAKT_PRIPR")
	endif
endif

// opcija smece
if (nArea==-1 .or. nArea==(F_FAKT_PRIPR))
	//PRIPR9.DBF

	//if IsRabati()
	//	AADD(aDBf,{ 'TIPRABAT'    , 'C' ,  10 ,  0 })
	//endif
	
	if !FILE(f18_ime_dbf("fakt_pripr9"))
        	DBcreate2(PRIVPATH+'FAKT_PRIPR9.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",PRIVPATH+"FAKT_PRIPR9")
	CREATE_INDEX("2","IdFirma+dtos(datdok)",PRIVPATH+"FAKT_PRIPR9")
	CREATE_INDEX("3","IdFirma+idroba+rbr",PRIVPATH+"FAKT_PRIPR9")
	if IsRabati()
		CREATE_INDEX("4","IdFirma+idtipdok+rbr",PRIVPATH+"FAKT_PRIPR9")
	endif
endif

if (nArea==-1 .or. nArea==(F__FAKT))
	//_FAKT.DBF
	
	if !FILE(f18_ime_dbf("_FAKT"))
        	DBcreate2(PRIVPATH+'_FAKT.DBF',aDbf)
	endif

	CREATE_INDEX("1","IdFirma+idtipdok+brdok+rbr+podbr",PRIVPATH+"_FAKT")
endif

#ifndef C50
	dbt2fpt(KUMPATH+'FAKT')
	dbt2fpt(PRIVPATH+'FAKT_PRIPR')
	dbt2fpt(PRIVPATH+'_FAKT')
#endif

if (nArea==-1 .or. nArea==(F_DOKS))
	//DOKS.DBF
	
	aDbf:={}
	AADD(aDBf,{ 'IDFIRMA'             , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'IdTIPDok'            , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'BRDOK'               , 'C' ,   8 ,  0 })
	AADD(aDBf,{ 'PARTNER'             , 'C' ,  30 ,  0 })
	AADD(aDBf,{ 'DATDOK'              , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'DINDEM'              , 'C' ,   3 ,  0 })
	AADD(aDBf,{ 'Iznos'               , 'N' ,  12 ,  3 })
	AADD(aDBf,{ 'Rabat'               , 'N' ,  12 ,  3 })
	AADD(aDBf,{ 'Rezerv'              , 'C' ,   1 ,  0 })
	AADD(aDBf,{ 'M1'                  , 'C' ,   1 ,  0 })
	AADD(aDBf,{ 'IDPARTNER'           , 'C' ,   6 ,  0 })
	AADD(aDBf,{ 'IDVRSTEP'            , 'C' ,   2 ,  0 })
	AADD(aDBf,{ 'DATPL'               , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'IDPM'                , 'C' ,  15 ,  0 })
	AADD(aDBf,{ 'DOK_VEZA'            , 'C' , 150 ,  0 })
	AADD(aDBf,{ 'OPER_ID'             , 'N' ,   3 ,  0 })
	AADD(aDBf,{ 'FISC_RN'             , 'N' ,  10 ,  0 })
	AADD(aDBf,{ 'DAT_ISP'             , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'DAT_VAL'             , 'D' ,   8 ,  0 })
	AADD(aDBf,{ 'DAT_OTPR'            , 'D' ,   8 ,  0 })
	
	//if IsRabati()
	//	AADD(aDBf,{ 'IDRABAT'             , 'C' ,  10 ,  0 })
	//	AADD(aDBf,{ 'TIPRABAT'            , 'C' ,  10 ,  0 })
	//endif
	
	if !FILE(f18_ime_dbf("fakt_doks"))
        	DBcreate2(KUMPATH+'FAKT_DOKS.DBF',aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok",KUMPATH+"FAKT_DOKS")
	CREATE_INDEX("2","IdFirma+idtipdok+partner",KUMPATH+"FAKT_DOKS")
	CREATE_INDEX("3","partner",KUMPATH+"FAKT_DOKS")
	CREATE_INDEX("4","idtipdok",KUMPATH+"FAKT_DOKS")
	CREATE_INDEX("5","datdok",KUMPATH+"FAKT_DOKS")
	CREATE_INDEX("6","IdFirma+idpartner+idtipdok",KUMPATH+"FAKT_DOKS")
endif


if (nArea==-1 .or. nArea==(F_DOKS2))
	//BLOK: DOKS2
	
	aDbf:={}
	AADD(aDBf,{ "IDFIRMA"      , "C" ,   2 ,  0 })
	AADD(aDBf,{ "IDTIPDOK"     , "C" ,   2 ,  0 })
	AADD(aDBf,{ "BRDOK"        , "C" ,   8 ,  0 })
	AADD(aDBf,{ "K1"           , "C" ,  15 ,  0 })
	AADD(aDBf,{ "K2"           , "C" ,  15 ,  0 })
	AADD(aDBf,{ "K3"           , "C" ,  15 ,  0 })
	AADD(aDBf,{ "K4"           , "C" ,  20 ,  0 })
	AADD(aDBf,{ "K5"           , "C" ,  20 ,  0 })
	AADD(aDBf,{ "N1"           , "N" ,  15 ,  2 })
	AADD(aDBf,{ "N2"           , "N" ,  15 ,  2 })
	
	if !FILE(f18_ime_dbf("fakt_doks2"))
        	DBcreate2(KUMPATH+"FAKT_DOKS2.DBF",aDbf)
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok",KUMPATH+"FAKT_DOKS2")
endif


if (nArea==-1 .or. nArea==(F_VRSTEP))
	//VRSTEP.DBF
	
	aDbf:={}
	AADD(aDbf,{"ID" ,"C", 2,0})
	AADD(aDbf,{"NAZ","C",20,0})
	
	if !FILE(f18_ime_dbf("vrstep"))
		DBcreate2(SIFPATH+"VRSTEP.DBF",aDbf)
	endif
	
	CREATE_INDEX("ID","Id",SIFPATH+"VRSTEP.DBF")
endif

/* 
if glDistrib
	if (nArea==-1 .or. nArea==(F_RELAC)) 
		//RELAC.DBF
		
		aDBf:={}
     		AADD(aDBf,{ "ID"                  , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "NAZ"                 , "C" ,  10 ,  0 })
     		AADD(aDBf,{ "IDPARTNER"           , "C" ,   6 ,  0 })
     		AADD(aDBf,{ "IDPM"                , "C" ,  15 ,  0 })
     
  		if !FILE(SIFPATH+"RELAC.DBF")
     			DBcreate2(SIFPATH+"RELAC.DBF",aDbf)
  		endif
  		
		CREATE_INDEX("ID","id+naz"         ,SIFPATH+"RELAC")
  		CREATE_INDEX("1" ,"idpartner+idpm" ,SIFPATH+"RELAC")
	endif
        
	if (nArea==-1 .or. nArea==(F_VOZILA)) 
  		//VOZILA.DBF	
     		
		aDBf:={}
     		AADD(aDBf,{ "ID"                  , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "NAZ"                 , "C" ,  25 ,  0 })
     		AADD(aDBf,{ "TABLICE"             , "C" ,  15 ,  0 })
		
		if !FILE(SIFPATH+"VOZILA.DBF")
     			DBcreate2(SIFPATH+"VOZILA.DBF",aDbf)
  		endif
  		
		CREATE_INDEX("ID","id",SIFPATH+"VOZILA")
	endif
	
	if (nArea==-1 .or. nArea==(F_KALPOS))  
  	 	//KALPOS.DBF
		
		aDBf:={}
     		AADD(aDBf,{ "DATUM"              , "D" ,   8 ,  0 })
     		AADD(aDBf,{ "IDRELAC"            , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "IDDIST"             , "C" ,   6 ,  0 })
     		AADD(aDBf,{ "IDVOZILA"           , "C" ,   4 ,  0 })
     		AADD(aDBf,{ "REALIZ"             , "C" ,   1 ,  0 })
    		
		if !file(KUMPATH+"KALPOS.DBF")
     			DBcreate2(KUMPATH+"KALPOS.DBF",aDbf)
  		endif
  		
		CREATE_INDEX("1","DTOS(datum)",KUMPATH+"KALPOS")
  		CREATE_INDEX("2","IDRELAC+DTOS(datum)",KUMPATH+"KALPOS")
	endif
endif
*/

// kreiranje tabela ugovora
db_cre_ugov()

//if gFc_use == "D"
	// kreiranje tabele sa listom uredjaja
	c_fdevice()
//endif

return



/*! \fn *void TDBFakt::obaza(int i)
 *  \brief otvara odgovarajucu tabelu
 *  
 *      
 */

*void TDBFakt::obaza(int i)
*{

method obaza (i)
local lIdIDalje
local cDbfName

lIdiDalje:=.f.

if i==F_KORISN .or. i==F_PARAMS .or.  i==F_GPARAMS .or. i==F_GPARAMSP .or. i==F_MPARAMS .or. i==F_FAKT_PRIPR 
	lIdiDalje:=.t.
endif

if i==F_FAKT  .or. i==F_FAKT_DOKS .or. i==F_FAKT_DOKS2 .or. i==F_FAKT_RJ .or. i==F_UPL
	lIdiDalje:=.t.
endif

if i==F_ROBA .or. i==F__ROBA .or. i==F_TARIFA .or. i==F_PARTN .or. i==F_FTXT .or. i==F_VALUTE .or.  i==F_SAST  .or. i==F_KONTO  .or. i==F_VRSTEP .or. i==F_BANKE .or. i==F_OPS   
	lIdiDalje:=.t.
endif

if i==F_UGOV .or. i==F_RUGOV .or. i==F_DEST  .or. i==F_SECUR .or. i==F_ADRES
	lIdiDalje:=.t.
endif

if i==F_GEN_UG .or. i==F_G_UG_P
	lIdiDalje:=.t.
endif

if i==F_FDEVICE
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
	
	select(i)
	usex(cDbfName)
else
	use
	return
endif


return
*}

/*! \fn *void TDBFakt::ostalef()
 *  \brief Ostalef funkcije (bivsi install modul)
 *  \note  sifra: SIGMAXXX
*/

*void TDBFakt::ostalef()
*{
method ostalef()


return
*}

/*! \fn *void TDBFakt::konvZn()
 *  \brief koverzija 7->8 baze podataka KALK
 */
 
*void TDBFakt::konvZn()
*{
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

aPriv := { F_PRIPR, F__ROBA }
aKum  := { F_FAKT, F_DOKS, F_RJ, F_UGOV, F_RUGOV, F_UPL, F_DEST, F_DOKS2 }
aSif  := { F_ROBA, F_TARIFA, F_PARTN, F_FTXT, F_VALUTE, F_SAST, F_KONTO,;
           F_VRSTEP, F_OPS }

IF cSif  == "N"; aSif  := {}; ENDIF
IF cKum  == "N"; aKum  := {}; ENDIF
IF cPriv == "N"; aPriv := {}; ENDIF

KZNbaza(aPriv,aKum,aSif,cIz,cU)

return
*}



