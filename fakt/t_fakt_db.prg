/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"
#include "hbclass.ch"

CLASS TDbFakt INHERIT TDB 
	method New
	method install	
	method kreiraj	
ENDCLASS


// --------------------------------------------
// --------------------------------------------
method New()

 ::super:new()

 ::cName:="FAKT"
 ::lAdmin:=.f.

 ::kreiraj()

return self




method install()
	install_start(goModul, .f.)
return



method Kreiraj(nArea)
local lPoNarudzbi := .f.
local glDistrib := .f.

cDirRad := my_home()
cDirSif := my_home()
cDirPriv := my_home()

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
		DBcreate2( "UPL", aDbf )
		reset_semaphore_version("fakt_upl")
		my_use("upl")
		close all
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
        	DBcreate2("FTXT",aDbf)
			reset_semaphore_version("fakt_ftxt")
			my_use("ftxt")
			close all
	endif
	
	CREATE_INDEX("ID","ID",SIFPATH+"FTXT")
endif


if (nArea==-1 .or. nArea==(F_FAKT_DOKS2))

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
        	DBcreate2("FAKT_DOKS2",aDbf)
			reset_semaphore_version("fakt_doks2")
			my_use("fakt_doks2")
			close all
	endif
	
	CREATE_INDEX("1","IdFirma+idtipdok+brdok", "FAKT_DOKS2")

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

return


