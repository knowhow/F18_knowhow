/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

// ----------------------------------
// puni tabelu za export
// ----------------------------------
function fill_ost_tbl(cIntervals, cIdPart, cP_naz, ;
			nTUVal, nTVVal, nTotal, ;
			nUVal1, nUVal2, nUVal3, nUVal4, nUValP, ;
			nVVal1, nVVal2, nVVal3, nVVal4, nVValP )
			
local nArr
nArr:=SELECT()

O_R_EXP
append blank
replace field->idpart with cIdPart
replace field->p_naz with cP_naz
replace field->t_vval with nTVVal
replace field->t_uval with nTUVal
replace field->total with nTotal

if cIntervals == "D"
	// u valuti
	replace field->uval_1 with nUVal1
	replace field->uval_2 with nUVal2
	replace field->uval_3 with nUVal3
	replace field->uval_4 with nUVal4
	replace field->uvalp with nUValP
	// van valute
	replace field->vval_1 with nVVal1
	replace field->vval_2 with nVVal2
	replace field->vval_3 with nVVal3
	replace field->vval_4 with nVVal4
	replace field->vvalp with nVValP
endif

select (nArr)

return



// ------------------------------------------
// vraca matricu sa ostav poljima
// cIntervals - da li postoje intervali "DN"
// 
// ------------------------------------------
function get_ost_fields( cIntervals, nPartLen )

if cIntervals == nil
	cIntervals := "N"
endif

if nPartLen == nil
	nPartLen := 6
endif

aFields := {}

AADD(aFields, {"idpart", "C", nPartLen, 0})
AADD(aFields, {"p_naz", "C", 40, 0})

if cIntervals == "D"
	
	AADD(aFields, {"UVal_1", "N", 15, 2})
  	AADD(aFields, {"UVal_2", "N", 15, 2})
  	AADD(aFields, {"UVal_3", "N", 15, 2})
  	AADD(aFields, {"UVal_4", "N", 15, 2})
  	AADD(aFields, {"UValP", "N", 15, 2})
endif

AADD(aFields, {"T_UVal", "N", 15, 2})

if cIntervals == "D" 
	AADD(aFields, {"VVal_1", "N", 15, 2})
  	AADD(aFields, {"VVal_2", "N", 15, 2})
  	AADD(aFields, {"VVal_3", "N", 15, 2})
  	AADD(aFields, {"VVal_4", "N", 15, 2})
  	AADD(aFields, {"VValP", "N", 15, 2})
endif

AADD(aFields, {"T_VVal", "N", 15, 2})
AADD(aFields, {"Total", "N", 15, 2})

return aFields



// -------------------------------
// vraca naz2 iz partnera
// -------------------------------
function PN2()
return ( if( cN2Fin=="D" , " " + TRIM(PARTN->naz2) , "" ) )



// ---------------------------------------------
// Rasclanjuje radne jedinice
// ---------------------------------------------
function RasclanRJ()
if cRasclaniti=="D"
	return cRasclan==suban->(idrj)
  	//sasa, 12.02.04
  	//return cRasclan==suban->(idrj+funk+fond)
else
  	return .t.
endif



// ------------------------------------------
// prikaz vrijednosti na izvjestaju
// ------------------------------------------
function Pljuc(xVal)
? "�"
?? xVal
?? "�"
RETURN

// -------------------------------------------
// prikaz vrijednosti na izvjestaju 
// -------------------------------------------
function PPljuc(xVal)
?? xVal
?? "�"
RETURN


// -------------------------------
// ispis rocnosti
// -------------------------------
function IspisRoc2(i)
LOCAL cVrati
  IF i==1
    cVrati := " DO "+STR( nDoDana1 , 3 )
  ELSEIF i==2
    cVrati := " DO "+STR( nDoDana2 , 3 )
  ELSEIF i==3
    cVrati := " DO "+STR( nDoDana3 , 3 )
  ELSEIF i==4
    cVrati := " DO "+STR( nDoDana4 , 3 )
  ELSE
    cVrati := " PR."+STR( nDoDana4 , 3 )
  ENDIF
RETURN cVrati+" DANA"


// -------------------------------------
// ispis rocnosti
// -------------------------------------
function RRocnost()
LOCAL nDana := ABS(IF( EMPTY(datval) , datdok , datval ) - dNaDan), nVrati
  IF nDana<=nDoDana1
    nVrati:=1
  ELSEIF nDana<=nDoDana2
    nVrati:=2
  ELSEIF nDana<=nDoDana3
    nVrati:=3
  ELSEIF nDana<=nDoDana4
    nVrati:=4
  ELSE
    nVrati:=5
  ENDIF
RETURN nVrati


/*! \fn IspisRocnosti()
 *  \brief Ispis rocnosti
 */
 
function IspisRocnosti()

LOCAL cRocnost:=Rocnost(), cVrati
  IF cRocnost=="999"
    cVrati:=" PREKO "+STR(nDoDana4,3)+" DANA"
  ELSE
    cVrati:=" DO "+cRocnost+" DANA"
  ENDIF
RETURN cVrati


// --------------------------------
// rocnost
// --------------------------------
function Rocnost()
LOCAL nDana := ABS(IF( EMPTY(datval) , datdok , datval ) - dNaDan), cVrati
IF nDana<=nDoDana1
	cVrati := STR( nDoDana1 , 3 )
ELSEIF nDana<=nDoDana2
    	cVrati := STR( nDoDana2 , 3 )
ELSEIF nDana<=nDoDana3
    	cVrati := STR( nDoDana3 , 3 )
ELSEIF nDana<=nDoDana4
    	cVrati := STR( nDoDana4 , 3 )
ELSE
    	cVrati := "999"
ENDIF

RETURN cVrati



