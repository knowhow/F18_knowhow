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

 

// Omogucava izradu naljepnica u dvije varijante:
// 1 - prikaz naljepnica sa tekucom cijenom
// 2 - prikaz naljepnica sa novom cijenom, kao i prekrizenom starom cijenom


function RLabele()
local cVarijanta
local cKolicina
local _tkm_no
local _xml_file := my_home() + "data.xml"
local _template := "rlab1.odt"

cVarijanta := "1"
cKolicina := "N"

// kreiraj tabelu rLabele
CreTblRLabele()

if GetVars( @cVarijanta, @cKolicina, @_tkm_no ) == 0 
	close all
	return
endif

if cVarijanta == "2"
    _template := "rlab2.odt"
endif

// izvrsi funkciju koja filuje tabelu rLabele 
// podacima a vraca varijantu ( 1-5 )
if ( gModul == "KALK" )
	KaFillRLabele( cKolicina )
else
	FaFillRLabele()
endif

// generisi xml fajl sa podacima labele
_gen_xml( _xml_file, _tkm_no )

CLOSE ALL

if f18_odt_generate( _template, _xml_file )
	// printaj odt
    f18_odt_print()
endif


//if ( cVarijanta > "0" .and. cVarijanta < "3" )
//	PrintRLabele( cVarijanta )
//endif

return


// ------------------------------------------------------
// uslovi generisanja labela
// ------------------------------------------------------
static function GetVars( cVarijanta, cKolicina, tkm_no )
local lOpened
local cIdVd

cIdVd := "XX"
cVarijanta := "1"
cKolicina := "N"
lOpened := .t.
tkm_no := SPACE(20)

if ( gModul == "KALK" )

	SELECT ( F_KALK_PRIPR )
	if !used()
		O_KALK_PRIPR
		lOpened := .f.
	endif

	PushWa()
	SELECT kalk_pripr
	GO TOP

	cIdVd := kalk_pripr->idVd
	
	PopWa()
	
	if ( cIdVd == "19" )
		cVarijanta := "2"
	endif
endif

Box(, 7, 65 )
	
	@ m_x + 1, m_y + 2 SAY "Broj labela zavisi od kolicine artikla (D/N):" ;
		GET cKolicina VALID cKolicina $ "DN" PICT "@!"

	@ m_x + 3, m_y + 2 SAY "1 - standardna naljepnica"
	@ m_x + 4, m_y + 2 SAY "2 - sa prikazom stare cijene (prekrizeno)"
	
	@ m_x + 6, m_y + 3 SAY "Odaberi zeljenu varijantu " ;
		GET cVarijanta VALID cVarijanta $ "12"
    
    @ m_x + 7, m_y + 2 SAY "Broj TKM:" GET tkm_no 	

	read

BoxC()

if (gModul=="KALK")
	if (!lOpened)
		USE
	endif
endif

if (LASTKEY()==K_ESC)
	return 0
endif

return 1




// -------------------------------------------------------------
// Kreira tabelu rLabele u privatnom direktoriju
// -------------------------------------------------------------
static function CreTblRLabele()
local aDbf
local _tbl
local _dbf
local _cdx

SELECT ( F_RLABELE )

_tbl := "rlabele"
_dbf := my_home() + _tbl + ".dbf"
_cdx := my_home() + _tbl + ".cdx"

if ( FILE( _dbf ) .and. FERASE( _dbf ) == -1 )
    MsgBeep( "Ne mogu izbrisati " + _dbf + " !" )
endif

if ( FILE( _cdx ) .and. FERASE( _cdx ) == -1 )
	MsgBeep( "Ne mogu izbrisati " + _cdx + " !")
endif

aDBf := {}
AADD(aDBf,{ 'idRoba'		, 'C', 10, 0 })
AADD(aDBf,{ 'naz'		    , 'C', 40, 0 })
AADD(aDBf,{ 'idTarifa'		, 'C',  6, 0 })
AADD(aDBf,{ 'barkod'		, 'C', 20, 0 })
AADD(aDBf,{ 'evBr'		    , 'C', 10, 0 })
AADD(aDBf,{ 'cijena'		, 'N', 10, 2 })
AADD(aDBf,{ 'sCijena'		, 'N', 10, 2 })
AADD(aDBf,{ 'skrNaziv'		, 'C', 20, 0 })
AADD(aDBf,{ 'brojLabela'	, 'N',  6, 0 })
AADD(aDBf,{ 'jmj'		    , 'C',  3, 0 })
AADD(aDBf,{ 'katBr'		    , 'C', 20, 0 })
AADD(aDBf,{ 'catribut'		, 'C', 30, 0 })
AADD(aDBf,{ 'catribut2'		, 'C', 30, 0 })
AADD(aDBf,{ 'natribut'		, 'N', 10, 2 })
AADD(aDBf,{ 'natribut2'		, 'N', 10, 2 })
AADD(aDBf,{ 'vpc'		    , 'N',  8, 2 })
AADD(aDBf,{ 'mpc'		    , 'N',  8, 2 })
AADD(aDBf,{ 'porez'		    , 'N',  8, 2 })
AADD(aDBf,{ 'porez2'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez3'		, 'N',  8, 2 })

DbCreate( _dbf, aDbf )
my_use_temp( "RLABELE", ALLTRIM( _dbf ), .f., .t. )
index on ("idroba") tag "1" 
set order to tag "1"

return nil




// -------------------------------------------------------------------------
// Puni tabelu rLabele podacima na osnovu dokumenta iz pripreme modula KALK
// 
// cKolicina - D ili N, broj labela zavisi od kolicine robe
// -------------------------------------------------------------------------
static function KaFillRLabele( cKolicina )
local cDok
local nBr_labela := 0
local _predisp := .f.

O_KALK_PRIPR
O_ROBA

select kalk_pripr
go top

if mp_predispozicija( field->idfirma, field->idvd, field->brdok )
    _predisp := .t.
endif

select kalk_pripr
go top

cDok := ( field->idFirma + field->idVd + field->brDok )

do while ( !eof() .and. cDok == ( field->idFirma + field->idVd + ;
	field->brDok ) )

    // ako je rijec o predispozicijama onda generisi za onaj
    // konto kojem ide roba
    // a to je konto kojem je idkonto2 = "XXX"

    if _predisp 
	    if field->idkonto2 <> "XXX"
            skip
            loop
        endif
    endif
	
	nBr_labela := field->kolicina

	// ako ne zavisi od kolicine artikla 
	// uvijek je jedna labela

	if cKolicina == "N"
		nBr_labela := 1
	endif

	// pronadji ovu robu
	select roba
	seek kalk_pripr->idRoba
	
	// pregledaj postoji li vec u rlabele.dbf !
	select rLabele
	seek kalk_pripr->idroba
	
	if ( cKolicina == "D" .or. ( cKolicina == "N" .and. !FOUND() ) )
		
	    for i := 1 to nBr_labela
		
		    select rlabele
		    append blank
		
		    Scatter()
		
		    _idroba := kalk_pripr->idroba
		    _naz := LEFT( roba->naz, 40 )
		    _idtarifa := kalk_pripr->idtarifa
		    _evbr := kalk_pripr->brdok
            _jmj := roba->jmj

      	    if !EMPTY( roba->barkod )
			    _barkod := roba->barkod
		    endif
		
		    if ( kalk_pripr->idVd == "19" )
			    _cijena := kalk_pripr->mpcsapp + kalk_pripr->fcj
			    _scijena := kalk_pripr->fcj
		    else
			    _cijena := kalk_pripr->mpcsapp
			    _scijena := _cijena
		    endif
		
		    Gather()
	   
	    next
	
	endif
	
	select kalk_pripr
	skip 1
enddo

return nil


// ---------------------------------------------------------------
// Prodji kroz pripremu FAKT-a i napuni tabelu rLabele
// ---------------------------------------------------------------
static function FaFillRLabele()
return nil



// -------------------------------------------------------------------
// Stampaj RLabele (delphirb)
//   cVarijanta - varijanta izgleda labele robe: 
//       "1" - standardna; 
//       "2" - za dokument nivelacije - prikazuju snizenje, 
//             gdje se vidi i precrtana stara cijena
// -------------------------------------------------------------------
static function PrintRLabele( cVarijanta )
local _rtm_naziv := ALLTRIM( "rLab" + cVarijanta )

f18_rtm_print( _rtm_naziv, "rlabele", "1" )

return nil


// ----------------------------------------------------------
// generisi xml na osnovu tabele rlabele
// ----------------------------------------------------------
static function _gen_xml( xml_file, tkm_no )
local _t_area := SELECT()

open_xml( xml_file )
xml_head()

xml_subnode( "lab", .f. )

select rlabele
set order to tag "1"
go top

xml_node( "pred", to_xml_encoding( ALLTRIM(gNFirma) ) )
xml_node( "tkm", to_xml_encoding( ALLTRIM( tkm_no ) ) )
xml_node( "dok", to_xml_encoding( ALLTRIM( rlabele->evbr ) ) )

do while !EOF()
    
    xml_subnode( "data", .f. )

    // filuj podatke iz tabele
    xml_node( "id", to_xml_encoding( ALLTRIM( rlabele->idroba ))  )
    xml_node( "naz", PADR( to_xml_encoding( ALLTRIM( rlabele->naz )), 28  ) )
    xml_node( "jmj", to_xml_encoding( ALLTRIM( rlabele->jmj ))  )
    xml_node( "bk", to_xml_encoding( ALLTRIM( rlabele->barkod ))  )
    xml_node( "c1", ALLTRIM( STR( rlabele->cijena, 12, 2 ) )  )
    xml_node( "c2", ALLTRIM( STR( rlabele->scijena, 12, 2 ) )  )

    xml_subnode( "data", .t. )

    skip 
enddo

xml_subnode( "lab", .t. )

close_xml()

select ( _t_area )
return



