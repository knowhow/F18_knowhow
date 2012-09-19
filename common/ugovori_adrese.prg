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


// --------------------------------------------------
// labeliranje adresa iz ugovora
// --------------------------------------------------
function kreiraj_adrese_iz_ugovora()
local _id_roba, _partner, _ptt, _mjesto
local _n_sort, _dat_do, _g_dat

PushWA()

_id_roba := DFTidroba
_partner := SPACE(80)
_ptt := SPACE(80)
_mjesto := SPACE(80)
_n_sort := "4"
_dat_do := DATE()
_g_dat := "D"

Box(,11,77)
    do while .t.
        @ m_x+0, m_y+5 SAY "POSTAVLJENJE USLOVA ZA PRAVLJENJE LABELA"
        @ m_x+2, m_y+2 SAY "Artikal  :" GET _id_roba VALID P_Roba( @_id_roba ) PICT "@!"
        @ m_x+3, m_y+2 SAY "Partner  :" GET _partner PICT "@S50!"
        @ m_x+4, m_y+2 SAY "Mjesto   :" GET _mjesto PICT "@S50!"
        @ m_x+5, m_y+2 SAY "PTT      :" GET _ptt PICT "@S50!"
        @ m_x+6, m_y+2 SAY "Gledati tekuci datum (D/N):" GET _g_dat ;
 	        VALID _g_dat $ "DN" PICT "@!"
        @ m_x+7, m_y+2 SAY "Nacin sortiranja (1-kolicina+mjesto+naziv ,"
        @ m_x+8, m_y+2 SAY "                  2-mjesto+naziv+kolicina ,"
        @ m_x+9, m_y+2 SAY "                  3-PTT+mjesto+naziv+kolicina),"
        @ m_x+10, m_y+2 SAY "                  4-kolicina+PTT+mjesto+naziv)," 
        @ m_x+11, m_y+2 SAY "                  5-idpartner)," ;
 	        GET _n_sort VALID _n_sort $ "12345" PICT "9"
        READ

        IF LASTKEY()==K_ESC
            BoxC()
            RETURN
        ENDIF
 
        aUPart := Parsiraj( _partner, "IDPARTNER" )
        aUPTT  := Parsiraj( _ptt, "PTT"       )
        aUMjes := Parsiraj( _mjesto, "MJESTO" )

        if aUPart <> NIL .and. aUMjes <> NIL .and. aUPTT <> NIL
            EXIT
        endif

    ENDDO

BoxC()

// kreiraj labelu dbf
_create_labelu_dbf()

if is_dest()
	select dest
	set filter to
endif

select ugov
set filter to

select rugov
set filter to

set filter to idroba == _id_roba
go top

MsgO( "Kreiram pomocnu tabelu labelu.dbf ..." )

do while !EOF()

	select ugov
	set order to tag "ID"
	go top
	seek rugov->id

	// stampati samo ugovore kod kojih je LAB_PRN <> "N"
	if ugov->(FIELDPOS("LAB_PRN")) <> 0
		if field->lab_prn == "N" .or. !(&aUPart) 
			select rugov
			skip 1
			loop
		endif
	else
		if field->aktivan != "D" .or. !(&aUPart)
    			select rugov
			skip 1
			loop
  		endif
	endif

	// pogledaj i datum ugovora, ako je istekao 
	// ne stampaj labelu
	if _g_dat == "D" .and. ( _dat_do > ugov->datdo )
		select rugov
		skip 1
		loop
	endif

  	select partn
	seek ugov->idpartner
  	
	if !( &aUMjes ) .or. !( &aUPTT )
    	select rugov
		skip 1
		loop
  	endif

  	select labelu
  	append blank
	
  	replace idpartner with ugov->idpartner
	replace kolicina with rugov->kolicina
	replace idroba with rugov->idroba

  	if is_dest() .and. !EMPTY( rugov->dest )
     		
		select dest
		set order to tag "ID"
		go top
		seek ugov->idpartner + rugov->dest

     	select labelu
		replace destin with dest->id
		replace naz with dest->naziv
		replace naz2 with dest->naziv2
		replace ptt with dest->ptt
		replace mjesto with dest->mjesto
		replace telefon with dest->telefon
		replace fax with dest->fax
     	replace adresa with dest->adresa
		
	else  
		
		// nije naznacena destinacija
     	select labelu
		replace naz with partn->naz
		replace naz2 with partn->naz2
		replace ptt with partn->ptt
		replace mjesto with partn->mjesto
		replace telefon with partn->telefon
		replace fax with partn->fax
		replace adresa with partn->adresa
		
  	endif

  	select rugov
  	skip

enddo

MsgC()

select labelu
SET ORDER TO TAG ( _n_sort )
GO TOP

aKol := {}

if lSpecifZips
	AADD( aKol, { "Sifra izdanja", {|| IDROBA       }, .f., "C", 13, 0, 1, 1} )
else
 	AADD( aKol, { "Artikal"      , {|| IDROBA       }, .f., "C", 10, 0, 1, 1} )
endif

AADD( aKol, { "Partner"      , {|| IdPartner    }, .f., "C",  6, 0, 1, 2} )
AADD( aKol, { "Dest."        , {|| Destin       }, .f., "C",  6, 0, 1, 3} )
AADD( aKol, { "Kolicina"     , {|| Kolicina     }, .t., "N", 12, 2, 1, 4} )
AADD( aKol, { "Naziv"        , {|| Naz          }, .f., "C", 60, 0, 1, 5} )
AADD( aKol, { "Naziv2"       , {|| Naz2         }, .f., "C", 60, 0, 1, 6} )
AADD( aKol, { "PTT"          , {|| PTT          }, .f., "C",  5, 0, 1, 7} )
AADD( aKol, { "Mjesto"       , {|| MJESTO       }, .f., "C", 16, 0, 1, 8} )
AADD( aKol, { "Adresa"       , {|| ADRESA       }, .f., "C", 40, 0, 1, 9} )
AADD( aKol, { "Telefon"      , {|| TELEFON      }, .f., "C", 12, 0, 1,10} )
AADD( aKol, { "Fax"          , {|| FAX          }, .f., "C", 12, 0, 1,11} )

StartPrint()

StampaTabele(aKol,{|| BlokSLU()},,gTabela,,;
              ,"PREGLED BAZE PRIPREMLJENIH LABELA",,,,,)

close all
EndPrint()

// stampaj labelu...
// pozovi funkciju stampanja rtm fajla kroz labeliranje.exe
f18_rtm_print( "labelu", "labelu", _n_sort, NIL, "labeliranje" )

O_UGOV
O_RUGOV
O_DEST
O_ROBA
O_SIFK
O_SIFV

PopWA()

return



static function _create_labelu_dbf()
local aDbf := {}
local _table := "labelu"

AADD (aDbf, {"IDROBA", "C",  10, 0})
AADD (aDbf, {"IdPartner", "C",  6, 0})
AADD (aDbf, {"Destin"  , "C", 6, 0})
AADD (aDbf, {"Kolicina", "N",  12, 2})
AADD (aDbf, {"Naz" , "C", 60, 0})
AADD (aDbf, {"Naz2", "C", 60, 0})
AADD (aDBf, {"PTT" , 'C' ,   5 ,  0 })
AADD (aDBf, {"MJESTO" , 'C' ,  16 ,  0 })
AADD (aDBf, {"ADRESA" , 'C' ,  40 ,  0 })
AADD (aDBf, {"TELEFON", 'C' ,  12 ,  0 })
AADD (aDBf, {"FAX"    , 'C' ,  12 ,  0 })

Dbcreate( my_home() + _table + ".dbf", aDbf )

select (F_LABELU)
my_use_temp( "labelu", my_home() + _table + ".dbf", .f., .f. )

index on STR( kolicina, 12, 2 ) + mjesto + naz tag "1"
index on mjesto+naz+str(kolicina,12,2) tag "2"
index on ptt+mjesto+naz+str(kolicina,12,2) tag "3"
index on str(kolicina,12,2)+ptt+mjesto+naz tag "4"
index on idpartner tag "5"

return


static function BlokSLU()
return



