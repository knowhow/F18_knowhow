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


#include "fmk.ch"


static __MAX_QT := 99999.999
static __MIN_QT := 0.001
static __MAX_PRICE := 999999.99
static __MIN_PRICE := 0.01
static __MAX_PERC := 99.99
static __MIN_PERC := -99.99



// ----------------------------------------
// fajl za fiskalni stampac
// ----------------------------------------
function fiscal_out_filename( file_name, rn_broj, trig )
local _ret, _rn
local _f_name := ALLTRIM( file_name )

if trig == nil
	trig := ""
endif

trig := ALLTRIM( trig )

do case

    // po broju racuna ( TREMOL ) 
	case "$rn" $ _f_name

        if EMPTY( rn_broj )
            _ret := STRTRAN( _f_name, "$rn", "0000" )
        else
		    // broj racuna.xml
		    _rn := PADL( ALLTRIM( rn_broj ), 8, "0" )
            // ukini znak "/" ako postoji
            _rn := STRTRAN( _rn, "/", "" )
		    _ret := STRTRAN( _f_name, "$rn", _rn )
        endif

		_ret := UPPER( _ret )

    // po trigeru ( HCP, TRING )	
	case "TR$" $ _f_name

		// odredjuje PLU ili CLI ili RCP na osnovu trigera
		_ret := STRTRAN( _f_name, "TR$", trig )
		_ret := UPPER( _ret )
	
		if ".XML" $ UPPER( trig )
			_ret := trig
		endif

    // ostale verijante
	otherwise 
		_ret := _f_name

endcase

return _ret


// ---------------------------------------------------
// ispravi naziv artikla
// ---------------------------------------------------
function fiscal_art_naz_fix( naz, drv )
local _ret := ""

do case 
    case drv == "FPRINT"
        _ret := STRTRAN( naz, ";", "" )
    otherwise
        _ret := naz
endcase

return _ret



// -------------------------------------------------
// generise novi plu kod za sifru
// -------------------------------------------------
function gen_plu( nVal )
local nTArea := SELECT()
local nTRec := RECNO()
local nPlu := 0

if ((Ch==K_CTRL_N) .or. (Ch==K_F4))

	if LastKey() == K_ESC
		return .f.
	endif

	set order to tag "plu"
	go top
	seek STR(99999999999, 10)
	skip -1

	nPlu := field->fisc_plu
	nVal := nPlu + 1

	select (nTArea)
	set order to tag "ID"
	go (nTRec)

	AEVAL(GetList,{|o| o:display()})

endif

return .t.


// -------------------------------------------------------
// generisi PLU kodove za postojece stavke sifraranika
// -------------------------------------------------------
function gen_all_plu( lSilent )
local nPLU := 0
local lReset := .f.
local nP_PLU := 0
local nCnt 
local _rec

if lSilent == nil
	lSilent := .f.
endif

if lSilent == .f. .and. !SigmaSIF("GENPLU")
	msgbeep("NE DIRAJ !!!")
	return .f.
endif

if lSilent == .f. .and. Pitanje(,"Resetovati postojece PLU", "N") == "D"
	lReset := .t.
endif

if lSilent == .t.
	lReset := .f.
endif

f18_lock_tables({"roba"})
sql_table_update( nil, "BEGIN" )

O_ROBA
select ROBA
go top

// prvo mi nadji zadnji PLU kod
select roba
set order to tag "PLU"
go top
seek str(9999999999,10)
skip -1
nP_PLU := field->fisc_plu
nCnt := 0

select roba
set order to tag "ID"
go top

Box(, 1, 50)
do while !EOF()
	
	if lReset == .f.
		// preskoci ako vec postoji PLU i 
		// neces RESET
		if field->fisc_plu <> 0
			skip
			loop
		endif
	endif
	
	++ nCnt
	++ nP_PLU
    
    _rec := dbf_get_rec()
    _rec["fisc_plu"] := nP_PLU
    update_rec_server_and_dbf( "roba", _rec, 1, "CONT")

	@ m_x + 1, m_y + 2 SAY PADR( "idroba: " + field->id + ;
		" -> PLU: " + ALLTRIM( STR( nP_PLU ) ), 30 )
	
	skip

enddo

BoxC()

f18_free_tables({"roba"})
sql_table_update( nil, "END" )

if nPLU > 0
	if lSilent == .f.
		msgbeep("Generisao " + ALLTRIM(STR(nCnt)) + " PLU kodova.")
	endif
	return .t.
else
	return .f.
endif

return




// --------------------------------------------------
// vraca iz parametara zadnji PLU broj
// --------------------------------------------------
function last_plu( device_id )
local _plu := 0
local _param_name := _get_auto_plu_param_name( device_id )
_plu := fetch_metric( _param_name, nil, _plu )
return _plu




// --------------------------------------------------
// generisanje novog plug kod-a inkrementalno
// --------------------------------------------------
function auto_plu( reset_plu, silent_mode, dev_params )
local _plu := 0
local _t_area := SELECT()
local _param_name := _get_auto_plu_param_name( dev_params["id"] )

if reset_plu == nil
	reset_plu := .f.
endif

if silent_mode == nil
	silent_mode := .f.
endif

if reset_plu = .t.
	// uzmi inicijalni plu iz parametara
	_plu := dev_params["plu_init"]
else
    _plu := fetch_metric( _param_name, nil, _plu )
    // prvi put pokrecemo opciju, uzmi init vrijednost !
	if _plu == 0
        _plu := dev_params["plu_init"]
    endif
    // uvecaj za 1
	++ _plu 
endif

if reset_plu = .t. .and. !silent_mode
	if !SigmaSif("RESET")
		msgbeep("Unesena pogresna sifra !")
		select (_t_area)
		return _plu
	endif
endif

// upisi u sql/db
set_metric( _param_name, nil, _plu )

if reset_plu = .t. .and. !silent_mode
	MsgBeep( "Setovan pocetni PLU na: " + ALLTRIM( STR( _plu ) ) )
endif

select ( _t_area )

return _plu


// -----------------------------------------------------------------
// vraca naziv parametra za sql/db
// parametar moze biti:
// 
// "auto_plu_dev_1" - auto plu device 1
// "auto_plu_dev_2" - auto plu device 2
// -----------------------------------------------------------------
static function _get_auto_plu_param_name( device_id )
local _tmp := "auto_plu"
local _ret
_ret := _tmp + "_dev_" + ALLTRIM( STR( device_id ) )
return _ret



// ------------------------------------------
// vraca tarifu za fiskalni stampac
// po uredjajima...
// ------------------------------------------
function fiscal_txt_get_tarifa( tarifa_id, pdv, drv )
local _tar := "2"
local _tmp 

// PDV17 -> PDV1 ili PDV7NP -> PDV7 ili PDV0IZ -> PDV0
_tmp := LEFT( UPPER( ALLTRIM( tarifa_id ) ), 4 )

do case

	case ( _tmp == "PDV1" .or. _tmp == "PDV7" ) .and. pdv == "D"

		// PDV je tarifna skupina "E"

        if drv == "TRING"
		    _tar := "E"
        elseif drv == "FPRINT"
            _tar := "2"
        elseif drv == "HCP"
            _tar := "1"
        elseif drv == "TREMOL"
            _tar := "2"
        endif

	case _tmp == "PDV0" .and. pdv == "D"

		// bez PDV-a je tarifna skupina "K"

        if drv == "TRING"
		    _tar := "K"
        elseif drv == "FPRINT"
            _tar := "4"
        elseif drv == "HCP"
            _tar := "3"
        elseif drv == "TREMOL"
            _tar := "1"
        endif

	case pdv == "N"

		// ne-pdv obveznik, skupina "A"
        if drv == "TRING"
		    _tar := "A"
        elseif drv == "FPRINT"
            _tar := "1"
        elseif drv == "HCP"
            _tar := "0"
        elseif drv == "TREMOL"
            _tar := "3"
        endif

    otherwise

        MsgBeep( "Greska sa tarifom !!!" )

endcase

return _tar


// -----------------------------------------------------
// vraca oznaku vrste placanja za pojedine uredjaje
// -----------------------------------------------------
function fiscal_txt_get_vr_plac( id_plac, drv )
local _ret := ""

do case

    case id_plac == "0"

        if drv == "TRING"
            _ret := "Gotovina"
        elseif drv $ "#HCP#FPRINT#"
            _ret := id_plac
        elseif drv == "TREMOL"
            _ret := "Gotovina"
        endif

    case id_plac == "1"

        if drv == "TRING"
            _ret := "Cek"
        elseif drv $ "#HCP#FPRINT#"
            _ret := id_plac
        elseif drv == "TREMOL"
            _ret := "Cek"
        endif

    case id_plac == "2"

        if drv == "TRING"
            _ret := "Virman"
        elseif drv $ "#HCP#FPRINT#"
            _ret := id_plac
        elseif drv == "TREMOL"
            _ret := "Kartica"
        endif

    case id_plac == "3"

        if drv == "TRING"
            _ret := "Kartica"
        elseif drv $ "#HCP#FPRINT#"
            _ret := id_plac
        elseif drv == "TREMOL"
            _ret := "Virman"
        endif

endcase

return _ret



// ---------------------------------------------------------
// vrsi provjeru vrijednosti cijena, kolicina itd...
// ---------------------------------------------------------
function fiscal_items_check( items, storno, level, drv )
local _i, _cijena, _plu_cijena, _kolicina, _naziv
local _fix := 0
local _ret := 0

if drv == NIL
    drv := "FPRINT"
endif

// aData[4] - naziv
// aData[5] - cijena
// aData[6] - kolicina

// setuj mi min, max values za pojedine uredjaje
set_min_max_values( drv )

if storno == nil
	storno := .f.
endif

for _i := 1 to LEN( items )

	_cijena := items[ _i, 5 ]	
	_plu_cijena := items[ _i, 10 ]
	_kolicina := items[ _i, 6 ]	
	_naziv := items[ _i, 4 ]

	if ( !_chk_qtty( _kolicina ) .or. !_chk_price( _cijena ) ) ;
		.or. !_chk_price( _plu_cijena )
		
		if level > 1
			
			// popravi kolicine, cijene
			_fix_qtty( @_kolicina, @_cijena, @_plu_cijena, @_naziv )
			
			// promjeni u matrici podatke takodjer
			items[ _i, 5 ] := _cijena
			items[ _i, 10 ] := _plu_cijena
			items[ _i, 6 ] := _kolicina
			items[ _i, 4 ] := _naziv
		
		endif

		++ _fix

	endif

next

if _fix > 0 .and. level > 1

	msgbeep("Pojedini artikli na racunu su prepakovani na 100 kom !")

elseif _fix > 0 .and. level == 1
	
	_ret := -99
	msgbeep("Pojedinim artiklima je kolicina/cijena van dozvoljenog ranga#Prekidam operaciju !!!!")

	if storno
		// ako je rijec o storno dokumentu, prikazi poruku
		// ali ipak nastavi dalje...
		_ret := 0
	endif

endif

return _ret



// ---------------------------------------------------------
// setuje minimalne i maksimalne vrijednosti 
// za pojedini uredjaj
// ---------------------------------------------------------
static function set_min_max_values( drv )

do case
 
    case drv $ "FPRINT#TRING"

        __MAX_QT := 99999.999
        __MIN_QT := 0.001
        __MAX_PRICE := 999999.99
        __MIN_PRICE := 0.01
        __MAX_PERC := 99.99
        __MIN_PERC := -99.99

    case drv $ "HCP#TREMOL"

        __MAX_QT := 99999.999
        __MIN_QT := 1.000
        __MAX_PRICE := 999999.99
        __MIN_PRICE := 0.01
        __MAX_PERC := 99.99
        __MIN_PERC := -99.99

endcase

return




// -------------------------------------------------
// provjerava da li zadovoljava kolicina
// -------------------------------------------------
function _chk_qtty( rn_qtty )
local _ret := .t.

// ispitivanje vrijednosti
if rn_qtty > __MAX_QT .or. rn_qtty < __MIN_QT
	_ret := .f.
    return _ret
endif

// ispitivanje decimala
// fiskalni uredjaj dozvoljava unos na 3 decimale
if ABS( rn_qtty ) - ABS( VAL( STR( rn_qtty, 12, 3 ) ) ) <> 0
    _ret := .f.
    return _ret
endif

return _ret


// -------------------------------------------------
// provjerava da li zadovoljava cijena
// -------------------------------------------------
function _chk_price( nPrice )
local lRet := .t.

if nPrice > __MAX_PRICE .or. nPrice < __MIN_PRICE
	lRet := .f.
endif

return lRet


// -------------------------------------------------
// koriguj cijenu i kolicinu
// -------------------------------------------------
function _fix_qtty( nQtty, nPrice, nPPrice, cName )

nQtty := nQtty / 100
nPrice := nPrice * 100
nPPrice := nPPrice * 100
cName := LEFT( ALLTRIM( cName ), 5 ) + " x100"

return


