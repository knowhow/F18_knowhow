#include "fin.ch"


// -------------------------------------------
// kreiraj index FIN rules....
// -------------------------------------------
function cre_rule_cdx()

CREATE_INDEX( "FINKNJ1", "MODUL_NAME+RULE_OBJ+STR(RULE_NO,5)", SIFPATH + "FMKRULES" )

CREATE_INDEX( "ELBA1", "MODUL_NAME+RULE_OBJ+RULE_C3", SIFPATH + "FMKRULES" )
return




// --------------------------------------------
// rule - kolone specificne
// --------------------------------------------
function g_rule_cols()
local aKols := {}

//rule_c1 = 1
//rule_c2 = 5
//rule_c3 = 10
//rule_c4 = 10
//rule_c5 = 50
//rule_c6 = 50
//rule_c7 = 100

AADD(aKols, { "tip nal", {|| PADR(rule_c3, 10) }, "rule_c3", {|| .t.}, {|| .t. } })
AADD(aKols, { "partner", {|| PADR(rule_c5, 20) }, "rule_c5", {|| .t.}, {|| .t. } })
AADD(aKols, { "konto", {|| PADR(rule_c6, 20) }, "rule_c6", {|| .t.}, {|| .t. } })
AADD(aKols, { "d_p", {|| rule_c1 }, "rule_c1", {|| .t.}, {|| .t. } })

return aKols


// -------------------------------------
// rule - block tabele rule
// -------------------------------------
function g_rule_block()
local bBlock := {|| ed_rule_bl() }
return bBlock

// ------------------------------------
// edit rule key handler
// ------------------------------------
static function ed_rule_bl()
return DE_CONT



// ---------------------------------------
//
// .....RULES.....
//
// ---------------------------------------


static function err_validate( nLevel )
local lRet := .f.

if nLevel <= 3

	lRet := .t.
	
elseif nLevel == 4
	
	if Pitanje(, "Zanemariti ovo pravilo (D/N) ?", "N" ) == "D"
	
		lRet := .t.
	
	endif

endif

return lRet




// -------------------------------------
// ispitivanje pravila o kontima
// -------------------------------------
function _rule_kto_()
local nErrLevel := 0

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_kto1_()

endif

return err_validate( nErrLevel )



// -------------------------------------------
// dozvoljen konto na nalogu
// -------------------------------------------
function _rule_kto1_()
local nReturn := 0
local nTArea := SELECT()

local cObj := "KNJIZ_KONTO"
local cMod := goModul:oDataBase:cName

local nErrLevel
local cKtoList
local cNalog

O_FMKRULES
select fmkrules
set order to tag "FINKNJ1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj )
	
	// B4 ili B* ili *
	cNalog := ALLTRIM( fmkrules->rule_c3 )
	// 132 ili 132;1333;2311;....
	cKtoList := ALLTRIM( fmkrules->rule_c6 )
	// nivo pravila
	nErrLevel := fmkrules->rule_level
	
	// ima li konta ???
	if nErrLevel <> 0 .and. ;
		_nalog_cond( _idvn, cNalog ) .and. ;
		_konto_cond( _idkonto, cKtoList )
		
		nReturn := nErrLevel
		
		sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		
		exit
	
	endif

	
	skip
	
enddo

select (nTArea)
return nReturn



// ---------------------------------------------------
// da li vrsta naloga zadovoljava....
// ---------------------------------------------------
static function _nalog_cond( cFinNalog, cRuleNalog )
local lRet := .f.

if cRuleNalog == "*"
	
	// odnosi se na sve naloge svi nalozi
	
	lRet := .t.

elseif LEFT( cRuleNalog, 1 ) <> "*" .and. "*" $ cRuleNalog

	// odnosi se na pravilo "B*" recimo
	
	if LEFT( cRuleNalog, 1 ) == LEFT( cFinNalog, 1 )
		lRet := .t.
	endif

elseif cRuleNalog == cFinNalog

	// odnosi se na uslov "B4"
	
	lRet := .t.
	
endif

return lRet




// -------------------------------------
// ispitivanje pravila o partneru
// -------------------------------------
function _rule_partn_()
local nErrLevel := 0

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_pt1_()

endif

return err_validate( nErrLevel )



// -------------------------------------------
// koji partner na kontu ???
// -------------------------------------------
function _rule_pt1_()
local nReturn := 0
local nTArea := SELECT()

local cObj := "KNJIZ_PARTNER_KONTO"
local cMod := goModul:oDataBase:cName

local nErrLevel
local cKtoList
local cNalog
local cPartn

O_FMKRULES
select fmkrules
set order to tag "FINKNJ1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj )
	
	// B4 ili B* ili *
	cNalog := ALLTRIM( fmkrules->rule_c3 )
	
	// 132 ili 132;1333;2311;....
	cKtoList := ALLTRIM( fmkrules->rule_c6 )

	// SC_SV1 - sifra partnera
	cPartn := ALLTRIM( fmkrules->rule_c5 )

	// nivo pravila
	nErrLevel := fmkrules->rule_level

	// ima li konta ???
	if nErrLevel <> 0 .and. ;
		_nalog_cond( _idvn, cNalog ) .and. ;
		_konto_cond( _idkonto, cKtoList ) .and. ;
		_partn_cond( _idpartner, cPartn ) == .f.
	
		nReturn := nErrLevel
		
		sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		
		exit
	
	endif

	
	skip
	
enddo

select (nTArea)
return nReturn



// -------------------------------------
// ispitivanje dugovne/potrazne strane
// -------------------------------------
function _rule_d_p_()
local nErrLevel := 0

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_dp1_()

endif

return err_validate( nErrLevel )



// -------------------------------------------
// duguje / potrazuje / partner / konto ????
// -------------------------------------------
function _rule_dp1_()
local nReturn := 0
local nTArea := SELECT()

local cObj := "KNJIZ_DP_PARTNER_KONTO"
local cMod := goModul:oDataBase:cName

local nErrLevel
local cKtoList
local cDugPot
local cPartn
local cNalog

O_FMKRULES
select fmkrules
set order to tag "FINKNJ1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj )
	
	// B4 ili B* ili *
	cNalog := ALLTRIM( fmkrules->rule_c3 )
	
	// 132 ili 132;1333;2311;....
	cKtoList := ALLTRIM( fmkrules->rule_c6 )

	// SC_SV1 - sifra partnera
	cPartn := ALLTRIM( fmkrules->rule_c5 )

	// duguje ili potrazuje (1 ili 2)
	cDugPot := ALLTRIM( fmkrules->rule_c1 )

	// nivo pravila
	nErrLevel := fmkrules->rule_level

	// ima li konta ???
	if nErrLevel <> 0 .and. ;
		_nalog_cond( _idvn, cNalog ) .and. ;
		_konto_cond( _idkonto, cKtoList ) .and. ;
		( _partn_cond( _idpartner, cPartn) == .f. .or. ;
		_dp_cond( _d_p , cDugPot ) == .f. )
			
		nReturn := nErrLevel
		
		sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		
		exit
	
		
	endif
	
	skip
	
enddo

select (nTArea)
return nReturn



// ---------------------------------------------------
// da li kupac zadovoljava kriterij ????
// ---------------------------------------------------
static function _partn_cond( cNalPartn, cRulePartn, lEmpty )
local lRet := .f.

if lEmpty == nil
	lEmpty := .f.
endif

cNalPartn := ALLTRIM( cNalPartn ) 

if lEmpty == .t. .and. EMPTY( cRulePartn )

	lRet := .t.

elseif cRulePartn == "*"

	// svi partneri
	lRet := .t.

elseif cRulePartn == "#KUPAC#"
	
	// provjeri da li je partner kupac?
	
	lRet := is_kupac( cNalPartn )

elseif cRulePartn == "#DOBAVLJAC#"

	// provjeri da li je partner dobavljac?
	
	lRet := is_dobavljac( cNalPartn )

elseif cRulePartn == "#BANKA#"

	// provjeri da li je partner banka?

	lRet := is_banka( cNalPartn )

elseif cRulePartn == "#RADNIK#"

	// provjeri da li je partner radnik?

	lRet := is_radnik( cNalPartn )

elseif cRulePartn == cNalPartn

	// odnosi se na uslov "01CZ02", konkretnu sifru
	
	lRet := .t.
	
endif

return lRet



// ---------------------------------------------------
// da li konto kriterij zadovoljava ????
// ---------------------------------------------------
static function _konto_cond( cNalKonto, cRuleKtoList, lEmpty )
local lRet := .f.

cNalKonto := ALLTRIM( cNalKonto )

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t. .and. EMPTY( cRuleKtoList )
	
	lRet := .t.

elseif cRuleKtoList == "*"

	// sva konta
	lRet := .t.

elseif cNalKonto $ cRuleKtoList
	
	lRet := .t.
	
endif

return lRet



// ---------------------------------------------------
// da li DP kriterij zadovoljava ????
// ---------------------------------------------------
static function _dp_cond( cNalDP, cRuleDP, lEmpty )
local lRet := .f.

cNalDP := ALLTRIM( cNalDP )

if lEmpty == nil
	lEmpty := .f.
endif

if lEmpty == .t. .and. EMPTY( cRuleDP )
	
	lRet := .t.

elseif cNalDP == cRuleDP
	
	lRet := .t.
	
endif

return lRet


// -------------------------------------
// ispitivanje broja veze naloga
// -------------------------------------
function _rule_veza_()
local nErrLevel := 0

// ako se koriste pravila ? uopste
if is_fmkrules()
	
	nErrLevel := _rule_bv1_()

endif

return err_validate( nErrLevel )



// -------------------------------------------
// broj veze pravilo 1 ????
// -------------------------------------------
function _rule_bv1_()
local nReturn := 0
local nTArea := SELECT()

local cObj := "KNJIZ_BROJ_VEZE"
local cMod := goModul:oDataBase:cName

local nErrLevel
local cKtoList
local cNalog
local cPartn
local cDugPot

O_FMKRULES
select fmkrules
set order to tag "FINKNJ1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj )

do while !EOF() .and. field->modul_name == g_rulemod( cMod ) ;
		.and. field->rule_obj == g_ruleobj( cObj )
	
	// B4 ili B* ili *
	cNalog := ALLTRIM( fmkrules->rule_c3 )
	
	// 132 ili 132;1333;2311;....
	cKtoList := ALLTRIM( fmkrules->rule_c6 )

	// partner
	cPartn := ALLTRIM( fmkrules->rule_c5 )

	// duguje / potrazuje
	cDugPot := ALLTRIM( fmkrules->rule_c1 )
	
	// nivo pravila
	nErrLevel := fmkrules->rule_level

	// ima li konto/nalog/opis ???
	if nErrLevel <> 0 .and. ;
		_nalog_cond( _idvn, cNalog ) .and. ;
		_konto_cond( _idkonto, cKtoList, .t. ) .and. ;
		_partn_cond( _idpartner, cPartn, .t. ) .and. ;
		_dp_cond( _d_p, cDugPot, .t. ) .and. ;
		EMPTY( _brdok )
		
		nReturn := nErrLevel
		
		sh_rule_err( fmkrules->rule_ermsg, nErrLevel )
		
		exit
	
		
	endif
	
	skip
	
enddo

select (nTArea)
return nReturn



// ----------------------------------------
// ELBA import rules
// ----------------------------------------

// vraca konto po uslovu rule_c3
function r_get_konto( cCond, cPartner )
local nTArea := SELECT()

local cObj := "ELBA_IMPORT"
local cMod := goModul:oDataBase:cName
local cKonto := "XX"

O_FMKRULES
select fmkrules
set order to tag "ELBA1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c3( cCond )

if cPartner == nil
	cPartner := ""
endif

do while !EOF() .and. field->modul_name == g_rulemod(cMod) ;
		.and. field->rule_obj == g_ruleobj(cObj) ;
		.and. field->rule_c3 == g_rule_c3( cCond )
		
	if EMPTY(cPartner)

		if EMPTY(field->rule_c5)
			cKonto := PADR( field->rule_c6, 7 )
			exit
		endif
			
	else
		
		if ALLTRIM(cPartner) == ALLTRIM( field->rule_c5 )
			cKonto := PADR( field->rule_c6, 7 )
			exit
		endif
			
	endif
	
	skip
enddo

select (nTArea)

return cKonto



// vraca partnera po uslovu konta
function r_get_kpartn( cKonto )
local nTArea := SELECT()

local cObj := "ELBA_IMPORT"
local cMod := goModul:oDataBase:cName
local cCond := "KTO_PARTN"
local cPartn := ""

O_FMKRULES
select fmkrules
set order to tag "ELBA1"
go top

seek g_rulemod( cMod ) + g_ruleobj( cObj ) + g_rule_c3( cCond )

do while !EOF() .and. field->modul_name == g_rulemod(cMod) .and. ;
		field->rule_obj == g_ruleobj(cObj) .and. ;
		field->rule_c3 == g_rule_c3(cCond)
	
	if ALLTRIM(cKonto) == ALLTRIM( field->rule_c6 )
		
		cPartn := PADR( field->rule_c5, 6 )
		
		exit
	
	endif
	
	skip

enddo

select (nTArea)

return cPartn



