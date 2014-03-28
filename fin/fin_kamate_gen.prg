/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * ERP software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fin.ch"


// ------------------------------------------
// prenos podataka iz fin u kam
// ------------------------------------------
function prenos_fin_kam()
local _id_konto := PADR( "2110", 7 )
local _dat_obr := DATE()
local _limit_dana := 0
local _zatvorene := "D"
local _dodaj_dana := 30
local _partneri := SPACE( 100 )
local _usl, _rec
local _filter := ""

O_KAM_PRIPR
O_KONTO
O_PARTN

Box("#PRENOS RACUNA ZA OBRACUN FIN->KAM", 8, 65)

	@ m_x+1,m_y+2 SAY "Konto:         " GET _id_konto valid P_Konto(@_id_konto)
  	@ m_x+2,m_y+2 SAY "Datum obracuna:" GET _dat_obr
  	@ m_x+3,m_y+2 SAY "Uzeti u obzir samo racune cije je"
	@ m_x+4,m_y+2 SAY "valutiranje starije od (br.dana)" GET _limit_dana pict "9999999"
  	@ m_x+5,m_y+2 SAY "Uzeti u obzir stavke koje su zatvorene? (D/N)" GET _zatvorene pict "@!" valid _zatvorene $ "DN"
  	@ m_x+6,m_y+2 SAY "Ukoliko nije naveden datum valutiranja"
  	@ m_x+7,m_y+2 SAY "na datum dokumenta dodaj (br.dana)    " GET _dodaj_dana pict "99"
  	@ m_x+8,m_y+2 SAY "Partneri" GET _partneri pict "@!S50"
	
	do while .t.

  		READ
		ESC_BCR
  		
        _usl := Parsiraj( _partneri, "IdPartner", "C" )

  		if _usl <> NIL
			exit
		endif

	enddo

BoxC()

O_SUBAN

if !EMPTY( _usl )
    _filter := _usl
 	set filter to &_filter
else
 	set filter to
endif

set order to tag "3"
seek gFirma + _id_konto

do while !EOF() .and. field->idkonto == _id_konto .and. field->idfirma == gFirma

	_id_partner := field->idpartner
    // osnovni dug
   	_osn_dug := 0
  
   	do while !EOF() .and. field->idkonto == _id_konto .and. field->idpartner == _id_partner .and. field->idfirma == gFirma
		
        _br_dok := field->brdok
      		
        _duguje := 0
        _potrazuje := 0
		_dat_pocetka := CTOD("")

      	_tmp := "XYZYXYYXXX"
      		
        do while !EOF() .and. field->idkonto == _id_konto .and. field->idpartner == _id_partner ;
                        .and. field->brdok == _br_dok  .and. field->idfirma == gFirma
        
            if field->brdok == _tmp .or. field->datdok > _dat_obr
                skip
				loop
          	endif
          		
            if field->otvst = "9" .and. _zatvorene == "N" 
			    // samo otvorene stavke
             	if field->d_p=="1"
              		_osn_dug += field->iznosbhd
             	else
              		_osn_dug -= field->iznosbhd
             	endif
             	skip
				loop
          	endif
			
            if field->d_p=="1"
                
                if EMPTY( _dat_pocetka )		
                    if EMPTY( field->datval )
                 	    _dat_pocetka := field->datdok + _dodaj_dana
              		else
					    // datum valutiranja
                		_dat_pocetka := field->datval  
              		endif
             	endif
             			
                _duguje += field->iznosbhd
             	_osn_dug += field->iznosbhd
          	
            else
             			
                if !EMPTY( _dat_pocetka ) 
				    // vec je nastalo dugovanje!!
                	_dat_pocetka := field->datdok
             	endif
             			
                _potrazuje += field->iznosbhd
             	_osn_dug -= field->iznosbhd
          	
            endif
			
			if !EMPTY( _dat_pocetka )
                select kam_pripr
             	if ( field->idpartner + field->idkonto + field->brdok == _id_partner + _id_konto + _br_dok )
                    // vec postoji prosli dio racuna
				    // njega zatvori sa
                	// predhodnim danom
                    if field->datod >= _dat_pocetka 
                        // slijedeca promjena na isti datum
                  	    replace field->osnovica with ;
                           			field->osnovica + suban->(iif(d_p=="1", iznosbhd,-iznosbhd))
						select suban
						skip
						loop
                    else
                  		replace field->datdo with _dat_pocetka - 1
                	endif
                endif

             	if ( field->idpartner + field->idkonto + field->brdok <> _id_partner + _id_konto + _br_dok ) ;
                    .and. ( _dat_obr - _limit_dana < _dat_pocetka )
                    // onda ne pohranjuj
                	_tmp := _br_dok
             	else
                    
                    append blank
                    replace idpartner with _id_partner
					replace idkonto with _id_konto
					replace osnovica with _duguje - _potrazuje
					replace brdok with _br_dok
					replace datod with _dat_pocetka
					replace datdo with _dat_obr
             	endif
          	endif
			
            select suban
          	skip
      	
        enddo
    	
    enddo
	select kam_pripr
   	_t_rec := recno()
   	seek _id_partner
   		
	do while !EOF() .and. _id_partner == field->idpartner
        replace field->osndug with _osn_dug  
        // nafiluj osnovni dug
      	skip
   	enddo
   	go _t_rec
   	select suban
enddo 

select kam_pripr
set order to tag "1"
go top

_tmp := "XYZXYZSC"
do while !eof()
	skip
	_t_rec := recno()
	skip -1
    if field->datod <= field->datdo .and. _tmp == field->brdok .and. field->osndug = 0
        // ako se radi o zadnjoj uplati vec postojeceg racuna
		// ne brisi !
      	skip
		loop
    endif
    	
    if field->datod >= field->datdo .or. field->osndug <= 0
      	delete()
    else
      	_tmp := field->brdok
    endif
    go _t_rec

enddo

go top
my_dbf_pack( .F. )

close all

return

