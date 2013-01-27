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

#define D_MAX_FILES     150


// -----------------------------------------------------------
// otvaranje fajlova potrebnih kod importa podataka
// -----------------------------------------------------------
static function _o_imp_tables()

select ( F_ROBA )
if !used()
	O_ROBA
endif

select ( F_TARIFA )
if !used()
	O_TARIFA
endif

select ( F_KALK_PRIPR )
if !used()
	O_KALK_PRIPR
endif

select ( F_KALK_DOKS )
if !used()
	O_KALK_DOKS
endif

select ( F_KALK )
if !used()
	O_KALK
endif

select ( F_KONCIJ )
if !used()
	O_KONCIJ
endif

return


// --------------------------------------------------------
// upit za konto
// --------------------------------------------------------
static function _box_konto()
local _konto := PADR( "1320", 7 )
local _t_area := SELECT()
	
select konto

Box(, 3, 60 )
	@ m_x+2, m_y+2 SAY "Magacinski konto:" GET _konto VALID P_Konto( @_konto )
  	read
BoxC()

select ( _t_area )
return _konto


// ----------------------------------------------------------------
// nacin zamjene barkod-ova prilikom importa
// ----------------------------------------------------------------
static function _bk_replace()
local _ret := 0
local _x := 1

Box(, 7, 60 )

	@ m_x + _x, m_y + 2 SAY "Zamjena barkod-ova"
	
	++ _x
	++ _x

	@ m_x + _x, m_y + 2 SAY "0 - bez zamjene"

	++ _x

	@ m_x + _x, m_y + 2 SAY "1 - ubaci samo nove"
	
	++ _x

	@ m_x + _x, m_y + 2 SAY "2 - zamjeni sve"

	++ _x
	++ _x

	@ m_x + _x, m_y + 2 SAY SPACE(15) + "=> odabir" GET _ret PICT "9"
	
	read
	
BoxC()

return _ret



// ------------------------------------------------------------
// preuzimanje podataka iz POS-a
// ------------------------------------------------------------
function kalk_preuzmi_tops_dokumente()
local _auto_razduzenje := "N"
local _br_kalk, _idvd_pos
local _id_konto2 := ""
local _bk_replace
local _br_dok, _id_konto, _r_br
local _bk_tmp
local _app_rec
local _imp_file := ""
local _roba_data := {}
local _count := 0
local _h_brdok

// opcija za automatko svodjeje prodavnice na 0
// ---------------------------------------------
// prenese se tops promet u dokument 11
// pa se prenese tops promet u dokument 42
_auto_razduzenje := fetch_metric( "kalk_tops_prenos_auto_razduzenje", my_user(), _auto_razduzenje )

// otvori tabele bitne za import podataka
_o_imp_tables()

// daj mi fajl za import
if !get_import_file( @_imp_file )
	close all
	return
endif

// otvori temp tabelu
select ( F_TMP_TOPSKA )
my_use_temp( "TOPSKA", _imp_file )

go bottom

// daj mi broj kalkulacije
_br_kalk := LEFT( STRTRAN( DTOC( field->datum ), ".", "" ), 4 ) + "/" + ALLTRIM( field->idpos )
_idvd_pos := field->idvd

// provjeri da li postoji podesenje za ovaj fajl importa
select koncij
locate for idprodmjes == topska->idpos

if !FOUND()
	MsgBeep("U sifrarniku KONTA-TIPOVI CIJENA nije postavljeno#nigdje prodajno mjesto :" + field->idprodmjes + "#Prenos nije izvrsen.")
  	close all
	return
endif

select kalk

if ( _idvd_pos == "42" .and. _auto_razduzenje == "D" )

        _h_brdok := hb_hash()
        _h_brdok["idfirma"] := gFirma
        _h_brdok["idvd"] := "11"
        _h_brdok["brdok"] := ""
        _h_brdok["datdok"] := DATE()
  	_br_kalk := kalk_novi_broj_dokumenta(_h_brdok) 

else

	seek gfirma + _idvd_pos + _br_kalk

  	if FOUND()
		Msg("Vec postoji dokument pod brojem " + gFirma + "-" + _idvd_pos + "-" + _br_kalk + "#Prenos nece biti izvrsen" )
		close all
		return
	endif

endif

select topska
go top

// nacin zamjene barkod-ova
// 0 - ne mjenjaj
// 1 - ubaci samo nove
// 2 - zamjeni sve

_bk_replace := _bk_replace()

// konto magacina za razduzenje
if ( _idvd_pos == "42" .and. _auto_razduzenje == "D" ) .or. ( _idvd_pos == "12" )
	_id_konto2 := _box_konto()
endif

// konacno idemo na import

_r_br := "0"

MsgO( "Prenos stavki POS -> KALK priprema ... sacekajte !" )

do while !EOF()
	
	_br_dok := _br_kalk
    _id_konto := koncij->id

    _n_rbr := RbrUNum( _r_br ) + 1
    _r_br := RedniBroj( _n_rbr )
    
    // provjeri da li roba postoji u sifraniku
    // ako ne postoji, dodaj...
    // dodaj u kontrolnu matricu ove informacije

    kalk_import_roba( @_roba_data, ALLTRIM( koncij->naz ) )
    	
	if ( _idvd_pos == "42" .or. _idvd_pos == "12" )

		if _auto_razduzenje == "D"
            // formiraj stavku 11	
		    import_row_11( _br_dok, _id_konto, _id_konto2, _r_br )
        else
		    // formiraj stavku 42
		    import_row_42( _br_dok, _id_konto, _id_konto2, _r_br )
        endif

	elseif ( _idvd_pos == "IN" )

        // inventura
        import_row_ip( _br_dok, _id_konto, _id_konto2, _r_br )

    endif
  	
	// zamjena barkod-a ako postoji
	if _bk_replace > 0

		select roba
	   	set order to tag "ID"
	    seek topska->idroba
	    	
		if Found()

			_bk_tmp := roba->barkod

			if _bk_replace == 2 .or. ( _bk_replace == 1 .and. !EMPTY( topska->barkod ) .and. topska->barkod <> _bk_tmp )
				
				_app_rec := dbf_get_rec()
				_app_rec["barkod"] := topska->barkod

				update_rec_server_and_dbf( "roba", _app_rec, 1, "FULL" )
		
			endif

	    endif

	endif
	
    ++ _count

	select topska
  	skip

enddo

MsgC()

close all

// prikazi report...
_show_report_roba( _roba_data )

if ( gMultiPM == "D" .and. _count > 0 .and. _auto_razduzenje == "N" )
	// pobrisi fajlove...
	FileDelete( _imp_file )
	FileDelete( STRTRAN( _imp_file , ".dbf", ".txt" ) )
endif

return


static function _show_report_roba( data )
local _i
local _razlika := 0

START PRINT CRET
?
P_COND2

? "Razlike u cijenama:"
? "-------------------"
? PADR("R.br", 5), PADR( "ID", 10), PADR( "naziv", 40 ), PADR("POS cijena", 12 ), PADR( "KALK cijena", 12 )
? REPLICATE( "-", 80 )

for _i := 1 to LEN( data )

    ? PADR( ALLTRIM( STR( _i, 4 )) + ".", 5 ), ;
        data[_i, 1], ;
        PADR( data[ _i, 2 ], 40 ), ;
        STR( data[ _i, 3 ], 12, 2 ), ;
        STR( data[ _i, 4 ], 12, 2 )

    _razlika += data[ _i, 3 ] - data[ _i, 4 ]

next

? REPLICATE( "-", 80 )
? "Ukupno razlika:", ALLTRIM(STR( _razlika, 12, 2 ))

FF
END PRINT

return

// --------------------------------------------
// import robe u sifrarnik robe
// --------------------------------------------
static function kalk_import_roba( a_roba, tip_cijene, update_roba )
local _t_area := SELECT()
local _rec, _mpc_naz

// ako nema ovog polja, nista ne radi !
if topska->(FIELDPOS("robanaz")) == 0
    return
endif

if update_roba == NIL
    update_roba := .f.
endif

select roba
hseek topska->idroba

if !FOUND()

    append blank
    _rec := dbf_get_rec()

    _rec["id"] := topska->idroba
    _rec["naz"] := topska->robanaz
    _rec["idtarifa"] := topska->idtarifa
    _rec["barkod"] := topska->barkod

    if topska->(FIELDPOS("jmj")) <> 0
        _rec["jmj"] := topska->jmj
    endif
    
    if ALLTRIM( tip_cijene ) == "M1" .or. EMPTY( tip_cijene )
        _rec["mpc"] := topska->mpc
    else
        // M3 -> mpc3
        _mpc_naz := STRTRAN( tip_cijene, "M", "mpc" )
        _rec[ _mpc_naz ] := topska->mpc
    endif

    update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )

    // dodaj u kontrolnu matricu
    AADD( a_roba, { topska->idroba, topska->robanaz, topska->mpc, 0 } )

else
    
    _rec := dbf_get_rec()

    if ALLTRIM( tip_cijene ) == "M1" .or. EMPTY( tip_cijene )
        _mpc_naz := "mpc"
    else
        // M3 -> mpc3
        _mpc_naz := STRTRAN( tip_cijene, "M", "mpc" )
    endif
        
    if ROUND( _rec[ _mpc_naz ], 2 ) <> ROUND( topska->mpc, 2 )

        AADD( a_roba, { topska->idroba, topska->robanaz, topska->mpc, _rec[ _mpc_naz ] } )
        
        _rec[ _mpc_naz ] := topska->mpc

        if update_roba
            update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )
        endif

    endif

endif

select ( _t_area )
return 


// ---------------------------------------------------------
// formiraj stavku inventure prodavnice
// ---------------------------------------------------------
static function import_row_ip( broj_dok, id_konto, id_konto2, r_br )
local _tip_dok := "IP"		
local _t_area := SELECT()
local _kolicina := 0
local _nc := 0
local _fc := 0
local _mpcsapp := 0
local _marzap := 50

if ( topska->kol2 == 0 )
	return
endif

// sracunaj za ovu stavku stanje inventurno u kalk-u
kalk_ip_roba( id_konto, topska->idroba, topska->datum, @_kolicina, @_nc, @_fc, @_mpcsapp )

if _kolicina == 0

    // nema ga na stanju... 
    // morat cemo preci na rucni rad racunice

    _mpcsapp := topska->mpc
    _nc := ROUND( _mpcsapp * ( _marzap / 100 ), 2 )

endif

// uvijek uzmi iz topska ovu cijenu pri prenosu
_mpcsapp := topska->mpc

select kalk_pripr
locate for field->idroba == topska->idroba

if !FOUND()
    
    append blank
			
    replace field->idfirma with gFirma
    replace field->idvd with _tip_dok
    replace field->brdok with broj_dok         
    replace field->datdok with topska->datum  
    replace field->datfaktp with topska->datum  
    replace field->kolicina with topska->kol2
    replace field->gkolicina with _kolicina
    replace field->gkolicin2 with ( gkolicina - kolicina )
    replace field->idkonto with id_konto        
    replace field->idkonto2 with id_konto
    replace field->pkonto with id_konto       
    replace field->idroba with topska->idroba  
    replace field->rbr with r_br           
    replace field->idtarifa with topska->idtarifa
    replace field->mpcsapp with _mpcsapp
    replace field->nc with _nc
    replace field->fcj with _fc
    replace field->pu_i with "I"
    replace field->error with "0"

else

    // samo appenduj kolicinu
    replace field->kolicina with field->kolicina + topska->kol2
    replace field->gkolicin2 with ( gkolicina - kolicina )
 
endif

select ( _t_area )
return




// ---------------------------------------------------------
// formiraj stavku razduzenja magacina
// ---------------------------------------------------------
static function import_row_11( broj_dok, id_konto, id_konto2, r_br )
local _tip_dok := "11"		
local _t_area := SELECT()

if ( topska->kolicina == 0 )
	return
endif

select kalk_pripr
append blank
			
replace field->idfirma with gFirma
replace field->idvd with _tip_dok
replace field->brdok with broj_dok         
replace field->datdok with topska->datum  
replace field->datfaktp with topska->datum   
replace field->kolicina with topska->kolicina
replace field->idkonto with id_konto        
replace field->idkonto2 with id_konto2       
replace field->idroba with topska->idroba  
replace field->rbr with r_br           
replace field->tmarza2 with "%"            
replace field->idtarifa with topska->idtarifa
replace field->mpcsapp with topska->( mpc - stmpc )
replace field->prevoz with "R"

select ( _t_area )
return


// ---------------------------------------------------------
// formiraj stavku razduzenja prodavnice
// ---------------------------------------------------------
static function import_row_42( broj_dok, id_konto, id_konto2, r_br )
local _t_area := SELECT()

if ( topska->kolicina == 0 )
	return
endif

select kalk_pripr
append blank
			
replace field->idfirma with gFirma
replace field->idvd with topska->idvd
replace field->brdok with broj_dok         
replace field->datdok with topska->datum  
replace field->datfaktp with topska->datum   
replace field->kolicina with topska->kolicina
replace field->idkonto with id_konto        
replace field->idroba with topska->idroba  
replace field->rbr with r_br           
replace field->tmarza2 with "%"            
replace field->idtarifa with topska->idtarifa
replace field->mpcsapp with topska->mpc
replace field->rabatv with topska->stmpc
	
select ( _t_area )
return




// ----------------------------------------------------------
// daj mi sva prodajna mjesta iz koncija
// ----------------------------------------------------------
static function _prodajna_mjesta_iz_koncij()
local _a_pm := {}
local _scan

select koncij
go top

do while !EOF()
	// ako nije prazno
	// ako je maloprodaja
	if !EMPTY( field->idprodmjes ) .and. LEFT( field->naz, 1 ) == "M"
		_scan := ASCAN( _a_pm, {|x| ALLTRIM(x) == ALLTRIM( field->idprodmjes ) })
		if _scan == 0
			AADD( _a_pm, ALLTRIM( field->idprodmjes ) )
		endif
	endif
	skip
enddo

return _a_pm


// ----------------------------------------------------------
// selekcija fajla za import podataka
// ----------------------------------------------------------
static function get_import_file( import_file )
local _opc := {}
local _pos_kum_path
local _prod_mjesta
local _ret := .t.
local _i, _imp_files, _opt, _h, _n
local _imp_patt := "t*.dbf"
local _prenesi, _izbor, _a_tmp1, _a_tmp2

if gMultiPM == "D"

	// daj mi sva prodajna mjesta iz tabele koncij
	_prod_mjesta := _prodajna_mjesta_iz_koncij()
	
	if LEN( _prod_mjesta ) == 0
		// imamo problem, nema prodajnih mjesta
		MsgBeep( "U tabeli koncij nisu definisana prodajna mjesta !!!" )
		_ret := .f.
		return _ret
	endif
    
	for _i := 1 to LEN( _prod_mjesta )

			// putanja koju cu koristiti	
			_pos_kum_path := ALLTRIM( gTopsDest ) + ALLTRIM( _prod_mjesta[ _i ] ) + SLASH
			
			// brisi sve fajlove starije od 28 dana
			BrisiSFajlove( _pos_kum_path )
			
			// daj mi fajlove u matricu po pattern-u
   			_imp_files := DIRECTORY( _pos_kum_path + _imp_patt )

			ASORT( _imp_files,,, {|x,y| DTOS(x[3]) + x[4] > DTOS(y[3]) + y[4] })
			
			// dodaj u matricu za odabir
			AEVAL( _imp_files, { |elem| AADD( _opc, PADR( ALLTRIM( _prod_mjesta[ _i ] ) + ;
										SLASH + TRIM(elem[1]), 20) + " " + ;
										UChkPostoji() + " " + DTOC(elem[3]) + " " + elem[4] ;
 								) }, 1, D_MAX_FILES )  


	next

	// R/X + datum + vrijeme
 	ASORT( _opc ,,,{|x,y| RIGHT(x, 19) > RIGHT(y, 19) })  
 	
	_h := ARRAY( LEN( _opc ) )
 	
	for _n := 1 to LEN( _h )
   		_h[ _n ] := ""
 	next

	// ima li stavki za preuzimanje ? 	
	if LEN( _opc ) == 0

   		MsgBeep( "U direktoriju za prenos nema podataka" )
		_ret := .f.
		return _ret

 	endif

else
	MsgBeep( "Pripremi disketu za prenos ....#te pritisni nesto za nastavak" )
endif

if gMultiPM == "D"

	_izbor := 1
  	_prenesi := .f.

	do while .t.

   		_izbor := Menu( "izdat", _opc, _izbor, .f. )

		if _izbor == 0
     		exit
   		else
			
            import_file := ALLTRIM( gTopsDest ) + ALLTRIM( LEFT( _opc[ _izbor ], 20 ) )
     			
			if Pitanje(, "Zelite li izvrsiti prenos ?", "D" ) == "D"
         		_prenesi := .t.
         		_izbor := 0
     		else
         		loop
     		endif
   		endif
  	enddo
	
  	if !_prenesi
		_ret := .f.
        return _ret
  	endif

else

	// CRC gledamo ako nije modemska veza
 	import_file := ALLTRIM( gTopsDest ) + "topska.dbf"

 	_a_tmp1 := IscitajCRC( ALLTRIM( gTopsDest ) + "crctk.crc" )
 	_a_tmp2 := IntegDBF( import_file )

	IF !( _a_tmp1[1] == _a_tmp2[1] .and. _a_tmp1[2] == _a_tmp2[2] ) 
   		Msg("CRCTK.CRC se ne slaze. Greska na disketi !",4)
		_ret := .f.
		return _ret
 	ENDIF

endif

return _ret




