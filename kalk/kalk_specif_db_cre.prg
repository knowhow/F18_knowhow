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



 
function CreTblPObjekti()
local cTbl
local aDbf

CLOSE ALL
cTbl:="pobjekti"
aDbf:={ {"id","C",2,0}   ,;
        {"IdObj","C", 7,0}, ;
        {"zalt","N", 18,5}, ;
        {"zaltu","N", 18,5}, ;
        {"zalu","N", 18,5}, ;
        {"zalg","N", 18,5}, ;
        {"prodt","N", 18,5}, ;
        {"prodtu","N", 18,5}, ;
        {"prodg","N", 18,5}, ;
        {"produ","N", 18,5} ;
       }
// uvijek kreiraj
DBCREATE2(cTbl, aDbf)
CREATE_INDEX("ID","id", cTbl)

CLOSE ALL

O_POBJEKTI
O_OBJEKTI

SELECT pobjekti
Scatter()

SELECT objekti
Scatter()

MsgO("objekti -> pobjekti")
// napuni PObjekti sa id iz Objekti 
go top 
do while !EOF()
	Scatter()
	SELECT pobjekti
	APPEND BLANK
	Gather()

	SELECT objekti
	skip
enddo
MsgC()

CLOSE ALL
return


function CreTblRek1(cVarijanta)

aDbf:={ {"idroba"  ,"C", 10,0},;
        {"objekat" ,"C", 7 ,0},;
        {"G1"      ,"C", 4 ,0},;
        {"idtarifa","C", 6 ,0},;
        {"mpc",    "N", 10 ,2},;
        {"k1","N",9+gDecKol,gDecKol}, ;
        {"k2","N",9+gDecKol,gDecKol}, ;
        {"k4pp","N",9+gDecKol,gDecKol} ;
     }

if (cVarijanta=="2")
	// nisu samo kolicine interesantne
	AADD( adbf,{"novampc","N", 10 ,2})
	AADD( adbf,{"k0","N",9+gdeckol,gDecKol} )
	AADD( adbf,{"k3","N",9+gdeckol,gDecKol} )
	AADD( adbf,{"k4","N",9+gdeckol,gDecKol} )
	AADD( adbf,{"k5","N",9+gdeckol,gDecKol} )
	AADD( adbf,{"k6","N",9+gdeckol,gDecKol} )
	AADD( adbf,{"k7","N",9+gdeckol,gDecKol} )
	AADD( adbf,{"k8","N",9+gdeckol,gDecKol} )

	AADD( adbf, {"f0","N",18,3}  )
	AADD( adbf,  {"f1","N",18,3} )
	AADD( adbf,  {"f2","N",18,3} )
	AADD( adbf,  {"f3","N",18,3} )
	AADD( adbf,  {"f4","N",18,3} )
	AADD( adbf,  {"f5","N",18,3} )
	AADD( adbf,  {"f6","N",18,3} )
	AADD( adbf,  {"f7","N",18,3} )
	AADD( adbf,  {"f8","N",18,3} )
endif

// novampc - ako nadjes 19-ku na dDatDo onda je nova cijena
// F0 - pocetno stanje zaliha
// f1 - tekuca prodaja, f2 trenutna zaliha, f3 - kumulativna prodaja
// f4 - prijem u toku mjeseca
// f6 - izlaz iz prodavnice po ostalim osnovama
// f5 - reklamacije u toku mjeseca, f7 - reklamacije u toku godine
// f8 -

FERASE(PRIVPATH+"REKAP1.CDX")
DBCREATE2(PRIVPATH+"REKAP1",aDbf)

select (F_REKAP1)
usex (PRIVPATH+"REKAP1")
delete tag "1"
delete tag "2"
delete tag "BRISAN"
index  on  objekat+idroba  tag "1"
index  on  g1+idtarifa+idroba+objekat  tag "2"
index ON BRISANO TAG "BRISAN"
set order to tag "1"
 
CLOSE ALL

return



function CreTblRek2()

local aDbf

aDbf:={ {"objekat" ,"C", 7 ,0},;
        {"G1"      ,"C", 4 ,0},;
        {"idtarifa","C", 6 ,0},;
        {"MJESEC",  "N", 2 ,0},;
        {"GODINA","N", 4 ,0},;
        {"ZALIHAK","N",16,2}, ;
        {"ZALIHAF","N",16,2}, ;
        {"NABAVK","N",16,2}, ;
        {"NABAVF","N",16,2}, ;
        {"PNABAVK","N",16,2}, ;
        {"PNABAVF","N",16,2}, ;
        {"STANJEK","N",16,2}, ;
        {"STANJEF","N",16,2}, ;
        {"STANJRK","N",16,2}, ;
        {"STANJRF","N",16,2}, ;
        {"PRODAJAK","N",16,2}, ;
        {"PRODAJAF","N",16,2}, ;
        {"PROSZALK","N",16,2}, ;
        {"PROSZALF","N",16,2}, ;
        {"ORUCF","N",16,2}, ;
        {"OMPRUCF","N",16,2}, ;
        {"POVECANJE","N",16,2}, ;
        {"SNIZENJE","N",16,2} ;
     }

DBCREATE2(PRIVPATH+"REKAP2.DBF", aDbf)
FERASE(PRIVPATH+"REKAP2.CDX")

SELECT(F_REKAP2)
USEX (PRIVPATH+"REKAP2")

delete tag "1"
delete tag "2"
delete tag "3"
delete tag "BRISAN"
index on str(godina)+str(mjesec)+objekat tag "1"
index on str(godina)+str(mjesec)+g1+objekat tag "2"
index on g1+str(godina)+str(mjesec) tag "3"
index ON BRISANO TAG "BRISAN"   
set order to tag "2"


aDbf:={ {"G1"      ,"C", 4 ,0},;
        {"idtarifa","C", 6 ,0},;
        {"ZALIHAK","N",16,2}, ;
        {"ZALIHAF","N",16,2}, ;
        {"NABAVK","N",16,2}, ;
        {"NABAVF","N",16,2}, ;
        {"PNABAVK","N",16,2}, ;
        {"PNABAVF","N",16,2}, ;
        {"STANJEK","N",16,2}, ;
        {"STANJEF","N",16,2}, ;
        {"STANJRF","N",16,2}, ;
        {"STANJRK","N",16,2}, ;
        {"PRODAJAK","N",16,2}, ;
        {"PRODAJAF","N",16,2}, ;
        {"PROSZALK","N",16,2}, ;
        {"PROSZALF","N",16,2}, ;
        {"PRODKUMK","N",16,2}, ;
        {"PRODKUMF","N",16,2}, ;
        {"ORUCF","N",16,2}, ;
        {"OMPRUCF","N",16,2}, ;
        {"POVECANJE","N",16,2}, ;
        {"SNIZENJE","N",16,2}, ;
        {"KOBRDAN","N",16,9}, ;
        {"GKOBR","N",18,9} ;
     }
DBCREATE2(PRIVPATH+"REKA22.DBF",aDbf)
ferase(PRIVPATH+"REKA22.CDX")

SELECT(F_REKA22)
usex (PRIVPATH+"REKA22")
delete tag "1"
delete tag "BRISAN"
index on g1 tag "1"
index ON BRISANO TAG "BRISAN"
set order to tag "1"

CLOSE ALL

return



/*! \fn CrePPProd()
 *  \brief Kreiraj tabelu kalk_ppprod
 *  \sa tbl_kalk_ppprod
 *
 */

function CrePPProd()
local cTblName
local aTblCols

cTblName:=ToUnix(PRIVPATH+"PPPROD.DBF")
aTblCols:={}
AADD(aTblCols,{"idKonto","C",7,0})
AADD(aTblCols,{"pari1","N",10,0})
AADD(aTblCols,{"pari2","N",10,0})
AADD(aTblCols,{"pari","N",10,0})
AADD(aTblCols,{"bruto1","N",12,2})
AADD(aTblCols,{"bruto2","N",12,2})
AADD(aTblCols,{"bruto","N",14,2})
AADD(aTblCols,{"neto1","N",12,2})
AADD(aTblCols,{"neto2","N",12,2})
AADD(aTblCols,{"neto","N",14,2})
AADD(aTblCols,{"polog01","N",12,2})
AADD(aTblCols,{"polog02","N",12,2})
AADD(aTblCols,{"polog03","N",12,2})
AADD(aTblCols,{"polog04","N",12,2})
AADD(aTblCols,{"polog05","N",12,2})
AADD(aTblCols,{"polog06","N",12,2})
AADD(aTblCols,{"polog07","N",12,2})
AADD(aTblCols,{"polog08","N",12,2})
AADD(aTblCols,{"polog09","N",12,2})
AADD(aTblCols,{"polog10","N",12,2})
AADD(aTblCols,{"polog11","N",12,2})
AADD(aTblCols,{"polog12","N",12,2})

DBCREATE2(cTblName, aTblCols)
CREATE_INDEX("konto","idKonto", cTblName, .t.)

return






