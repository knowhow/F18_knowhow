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


#include "rnal.ch"


static _direkt_mod


// ----------------------------------------------------------------------
// Kreiranje pomocne tabele za parametre 
// pretrage kod unosa naloga
// 
// _FND_PAR.DBF
//  
// -------------------------------------------
// fnd_..no | fnd_..type | fnd_att | fnd_val |
// -------------------------------------------
//        1 |   MC       |         | FC4K    |
//        2 |   ATT      |    1    |    1    |
//        3 |   ATT      |    5    |   11    | 
// -------------------------------------------
// ----------------------------------------------------------------------
function _cre_fnd_par()
local cFndDbf := "_FND_PAR"
local aDbf := {}

if !FILE(PRIVPATH + cFndDbf + ".DBF")
	
	AADD(aDbf, { "fnd_par_no", "N", 4, 0})
	AADD(aDbf, { "fnd_par_type", "C", 10, 0})
	AADD(aDbf, { "fnd_att", "C", 10, 0})
	AADD(aDbf, { "fnd_val", "C", 10, 0})

	DBcreate2(PRIVPATH + cFndDbf + ".DBF", aDbf)

endif

CREATE_INDEX("1", "STR(fnd_par_no, 4)", PRIVPATH + cFndDbf, .t.)

return


// ------------------------------------------------
// otvara TBrowse objekat _fnd_par
// 
// ------------------------------------------------
function _fnd_par_get()
local nArea
local nTArea
local GetList:={}
local nBoxX := 12
local nBoxY := 77
local cHeader := ""
local cFooter := ""
local cBoxOpt := ""
private ImeKol
private Kol

nTArea := SELECT()

cHeader := "Uslovi za pretragu artikala"

O__FND_PAR
select _fnd_par 

if gFnd_reset == 1
	// ponisti posljednju pretragu
	_clear_fnd()
endif

go top

Box(, nBoxX, nBoxY)

cBoxOpt += "<c-N> nova stavka"
cBoxOpt += " "
cBoxOpt += "<c-T> brisi"
cBoxOpt += " "
cBoxOpt += "<c-F9> brisi sve"
cBoxOpt += " "
cBoxOpt += "<a-F> trazi"
cBoxOpt += " "
cBoxOpt += "<ESC> izadji"

@ m_x + nBoxX, m_y + 2 SAY cBoxOpt

set_a_kol(@ImeKol, @Kol)

// setuj varijable direktnog moda....
private bGoreRed:=NIL
private bDoleRed:=NIL
private bDodajRed:=NIL
private fTBNoviRed:=.f. 
private TBCanClose:=.t. 
private TBAppend:="N"  
private bZaglavlje:=NIL
private TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
private nTBLine:=1      
private nTBLastLine:=1  
private TBPomjerise:="" 
private TBScatter:="N"  

private gTBDir := "D"

ObjDbedit("fnd_par", nBoxX, nBoxY, {|| key_handler()}, cHeader, cFooter,,,,,1)

BoxC()

select (nTArea)

if LastKey() == K_ESC
	return 0
endif

return 1
  
// -------------------------------------------
// ponistavanje posljednje pretrage
// -------------------------------------------
static function _clear_fnd( lAlways )
go top

if lAlways == nil
	lAlways := .t.
endif

do while !EOF()
	
	if lAlways == .t. 
		replace field->fnd_val with ""
	endif
	
	skip
	
enddo

return .t.


// ------------------------------------------
// key handler nad tabelom
// ------------------------------------------
static function key_handler()
local nTRec := RECNO()
local nRet := DE_CONT

if ( Ch == K_CTRL_T .or. Ch == K_CTRL_F9) .and. RecCount2() == 0
	return DE_CONT
endif


do case

	case (Ch == K_ESC) 
		
		gTBDir:="N"
        	NeTBDirektni()

	case (Ch == K_CTRL_T)
	
		if Pitanje(, "Zelite izbrisati ovu stavku ?","D")=="D"
      			
			delete
      			nRet := DE_REFRESH
			
      		endif
		
	case (Ch == K_CTRL_F9)

		if Pitanje(, "Izbrisati sve stavke iz tabele ?", "N") == "D"
			
			go top
			do while !EOF()
				delete
				skip
			enddo
			
			nRet := DE_REFRESH
		endif
		
	case (Ch == K_CTRL_N)
		
		//dodaj novi parametar u _fnd_par
		if _add_fnd_par( _new_fnd_par() ) == 0
			go top
		endif
	
		TB:left()
		TB:left()
		TB:down()

		while !TB:stabilize()
		end
	
		nRet := DE_REFRESH
	
	case ( Ch == K_ALT_F )
		
		// zapocni pretragu prema unesenim vrijednostima
		gTBDir:="N"
        	NeTBDirektni()

		nRet := DE_ABORT

endcase


return nRet


// -------------------------------------------------------
// setovanje kolona tabele za unos operacija
// -------------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol:={}

// tip atributa...
AADD(aImeKol, ;
	{ PADC( "Tip", 6),;
	{|| PADR(g_fnd_par_type( fnd_par_type ), 6)} })

// atribut
AADD(aImeKol, ;
	{PADC("Atribut", 20),;
	{|| IF(ALLTRIM(fnd_par_type) == "ATT", ALLTRIM(g_egr_by_att(VAL(fnd_att), .t. )) + "/" + PADR(g_gr_at_desc(VAL(fnd_att), nil, .t.), 15), IF( ALLTRIM(fnd_par_type) == "AOP" , PADR( ALLTRIM(g_aop_desc(VAL(fnd_att), .t.)), 20), PADR("----->", 20) ) ) },;
	"fnd_att",;
	{|| ALLTRIM(fnd_par_type) $ "ATT#AOP" .or. not_att_msg() },;
	{|| IF(ALLTRIM(fnd_par_type) == "ATT", s_e_gr_att( @wfnd_att, nil, @wfnd_att , .t. ), IF( ALLTRIM(fnd_par_type) == "AOP", s_aops(@wfnd_att, @wfnd_att, .t.) , .t.  )), to_str(@wfnd_att), go_right() },;
	"V" })


// vrijednost atributa
AADD(aImeKol, ;
	{PADC("Vrijednost", 35), ;
	{|| IF( ALLTRIM(fnd_par_type) == "ATT" , PADR(g_e_gr_vl_desc(val(fnd_val), .t.), 35), IF( ALLTRIM(fnd_par_type) == "AOP", PADR(g_aop_att_desc(val(fnd_val), .t.), 35), PADR(fnd_val, 35)))  },;
	"fnd_val",;
	{|| .t. },;
	{|| IF(ALLTRIM(fnd_par_type) == "ATT" , EMPTY(wfnd_val) .or. s_e_gr_val(@wfnd_val, VAL(fnd_att), @wfnd_val, .t.) , IF( ALLTRIM(fnd_par_type) == "AOP", EMPTY(wfnd_val) .or. s_aops_att(@wfnd_val, VAL(fnd_att), @wfnd_val, .t.) , .t.)), to_str(@wfnd_val) },;
	"V"  })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// -------------------------------------------
// pomjeri se u browsu na desno
// -------------------------------------------
static function go_right()
TB:right()
while !TB:stabilize()
end
return .t.



// -----------------------------------------
// konvertuje nPar -> STR(nPar) i vraæa .t.
// -----------------------------------------
static function to_str(nPar)
if VALTYPE(nPar) == "N"
	nPar := STR(nPar,10)
endif
return .t.


// -----------------------------------------
// poruka sekcija nema atributa
// -----------------------------------------
static function not_att_msg()
MSGBEEP("Ova sekcija nema atributa !!!#Unosi se samo vrijednost.")
return .f.


// -----------------------------------------------
// dodaje novi parametar u listu...
// -----------------------------------------------
static function _new_fnd_par()
local nSelection := 0
local nX := m_x
local nY := m_y
private izbor := 1
private opc := {}
private opcexe := {}

AADD(opc, "1. atribut elementa             ")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})
AADD(opc, "2. dodatna operacija artikla")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})
AADD(opc, "3. match code artikla")
AADD(opcexe, {||  nSelection := izbor, izbor := 0})

Menu_SC("fnd_par_add")

m_x := nX
m_y := nY

if LastKey() == K_ESC
	nSelection := -1
endif

return nSelection


// ---------------------------------------------------------
// dodaje u tabelu _fnd_par novi parametar
// ---------------------------------------------------------
static function _add_fnd_par( nSelection )
local cFndParType := ""
local nTRec := RECNO()
local nFndParNo := 0

if nSelection < 0
	return 0
endif

do case 
	case nSelection == 1
		cFndParType := "ATT"
	case nSelection == 2
		cFndParType := "AOP"
	case nSelection == 3
		cFndParType := "MC"
endcase 

select _fnd_par
set order to tag "1"
go bottom

nFndParNo := field->fnd_par_no
nFndParNo += 1

append blank

Scatter()
_fnd_par_no := nFndParNo
_fnd_par_type := PADR(cFndParType, 10)
Gather()

go top

return 1


// --------------------------------------------
// vraca naziv parametra prema kodu
// --------------------------------------------
static function g_fnd_par_type( par_type )

par_type := ALLTRIM( par_type )

if par_type == "ATT"
	return "atrib."
endif
if par_type == "AOP"
	return "d.oper"
endif
if par_type == "MC"
	return "m.code"
endif
if EMPTY( par_type )
	return "????"
endif

return



