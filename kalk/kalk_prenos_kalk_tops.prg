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


#include "f18.ch"

// -------------------------------------------
// otvori tabele potrebne za generaciju 
// -------------------------------------------
static function _o_gen_tables( from_kum )

if from_kum == NIL
    from_kum := .f.
endif

select F_ROBA
if !used()    
    O_ROBA
endif

select F_KONCIJ
if !used()
    O_KONCIJ
endif

if from_kum == .t.
    select F_KALK
    if !used()
        O_SKALK
    endif
else
    select F_KALK_PRIPR
    if !used()
        O_KALK_PRIPR
    endif
endif

return



// -------------------------------------------
// kreiraj tabelu za prenos u TOPS
// -------------------------------------------
static function _cre_katops_dbf( dbf_table, from_kum )
local _dbf

if from_kum == NIL
    from_kum := .f.
endif

_o_gen_tables( from_kum )

select kalk_pripr
go top

_dbf := {}
AADD( _dbf,{"IDFIRMA","C",2,0})
AADD( _dbf,{"BRDOK","C",8,0})
AADD( _dbf,{"IDVD","C",2,0})
AADD( _dbf,{"DATDOK","D",8,0})
AADD( _dbf,{"IDKONTO","C",7,0})
AADD( _dbf,{"IDKONTO2","C",7,0})
AADD( _dbf,{"IDPARTNER","C",6,0})
AADD( _dbf,{"IDPOS","C",2,0})
AADD( _dbf,{"IDROBA","C",10,0})
AADD( _dbf,{"kolicina","N",13,4})
AADD( _dbf,{"kol2","N",13,4})
AADD( _dbf,{"MPC","N",13,4})
AADD( _dbf,{"MPC2","N",13,4})
AADD( _dbf,{"NAZIV","C",250,0})
AADD( _dbf,{"IDTARIFA","C",6,0})
AADD( _dbf,{"JMJ","C",3,0})
AADD( _dbf,{"K1","C",4,0})
AADD( _dbf,{"K2","C",4,0})
AADD( _dbf,{"K7","C",1,0})
AADD( _dbf,{"K8","C",2,0})
AADD( _dbf,{"K9","C",3,0})
AADD( _dbf,{"N1","N",12,2})
AADD( _dbf,{"N2","N",12,2})
AADD( _dbf,{"BARKOD","C",13,0})

// kreiraj tabelu
dbcreate( dbf_table, _dbf )
    
select ( F_TMP_KATOPS )
my_use_temp( "KATOPS", dbf_table )

return


// -------------------------------------------------------
// prenos prerequisites
// -------------------------------------------------------
static function _prenos_prereq()
local _ret := .f.

if ALLTRIM( gTops ) <> "0"
	// provjeri i gTopsDest 
	if EMPTY( ALLTRIM( gTopsDest ) )
		MsgBeep( "Nije podesen direktorij za prenos podataka !" )
	else
		_ret := .t.
	endif
endif

if _ret
	if Pitanje(, "Generisati datoteku prenosa za modul TOPS (D/N) ?", "N" ) == "N"
		_ret := .f.
	endif
endif

return _ret


// ----------------------------------------------------------
// generacija tops dokumenata na osnovu kalk dokumenata
// ----------------------------------------------------------
function kalk_generisi_tops_dokumente( id_firma, id_tip_dok, br_dok )
local _katops_table := "katops.dbf"
local _rbr, _dat_dok
local _pos_locations
local _from_kum := .t.
local _total := 0

my_close_all_dbf()

if PCOUNT() == 0
    // generisanje iz pripreme
    _from_kum := .f.
endif

// provjeri uslove za prenos
if !_prenos_prereq()

	_o_gen_tables( _from_kum )
    select kalk_pripr
    return

endif

// otvori tabele
_o_gen_tables( _from_kum )

// kreiraj tabelu katops
// ona ce se kreirati u privatnom direktoriju...
_cre_katops_dbf( my_home() + _katops_table, _from_kum )

select kalk_pripr
set order to tag "1"
go top

if _from_kum == .f.
    id_firma := field->idfirma
    id_tip_dok := field->idvd
    br_dok := field->brdok
endif

seek id_firma + id_tip_dok + br_dok
    
_rbr := 0
_dat_dok := DATE()
    
// matrica pos mjesta koje kaci kalkulacija
_pos_locations := {}   
    
do while !eof() .and. field->idfirma == id_firma .and. field->idvd == id_tip_dok .and. field->brdok == br_dok
        
    select roba
    HSEEK kalk_pripr->idroba
        
    select koncij
    seek TRIM( kalk_pripr->pkonto )
    
    // provjeri postoji li koncij zapis !
    if EMPTY( koncij->idprodmjes )
        Msgbeep( "Nije definisano prodajno mjesto u tabeli konta - tipovi cijena !" )
        select kalk_pripr
        return 
    endif
 
    select katops
    append blank
        
    if ASCAN( _pos_locations, {|x| x == koncij->idprodmjes } ) == 0
        AADD( _pos_locations, koncij->idprodmjes )
    endif
        
    _dat_dok := kalk_pripr->datdok

    replace field->idfirma with gFirma
    replace field->idvd with kalk_pripr->idvd
    replace field->idpos with koncij->idprodmjes
    replace field->datdok with kalk_pripr->datdok
    replace field->idkonto with kalk_pripr->idkonto
    replace field->idkonto2 with kalk_pripr->idkonto2
    replace field->idpartner with kalk_pripr->idpartner
    replace field->idroba with kalk_pripr->idroba

    replace field->kolicina with kalk_pripr->kolicina

    // kod inventure
    if field->idvd == "IP"
        replace field->kol2 with kalk_pripr->gkolicina
    endif

    replace field->mpc with kalk_pripr->mpcsapp
    replace field->naziv with roba->naz
    replace field->idtarifa with kalk_pripr->idtarifa
    replace field->jmj with roba->jmj
    replace field->brdok with kalk_pripr->brdok
    replace field->k1 with roba->k1
    replace field->k2 with roba->k2
    replace field->k7 with roba->k7
    replace field->k8 with roba->k8
    replace field->k9 with roba->k9
    replace field->n1 with roba->n1
    replace field->n2 with roba->n2
    replace field->barkod with roba->barkod
    
    // cijene...
    if kalk_pripr->pu_i == "3"  
        // radi se o nivelaciji
        // mpc - stara cijena
        replace field->mpc with kalk_pripr->fcj 
        // mpc2 - nova cijena
        replace field->mpc2 with kalk_pripr->(fcj + mpcsapp)      
    endif

    if kalk_pripr->pu_i == "5"
        replace field->kolicina with -kolicina
    endif

    if EMPTY( koncij->idprodmjes )
        replace field->idpos with gTops
    endif

    // saberi total...
    _total += ( field->kolicina * field->mpc )

    ++ _rbr

    select kalk_pripr
    skip

enddo

// zatvori sta treba zatvoriti
select katops
use

if _rbr > 0
    
    // napravi i prebaci izlazne fajlove gdje trebaju
    _exp_file := _kreiraj_fajl_prenosa( _dat_dok, _pos_locations, _rbr )

	my_close_all_dbf()
    // ispisi report
    _print_report( id_firma, id_tip_dok, br_dok, _rbr, _total, _exp_file )

endif

my_close_all_dbf()
return


// ---------------------------------------------
// printaj rezultat prenosa podataka
// ---------------------------------------------
static function _print_report( firma, tip_dok, br_dok, broj_stavki, total_prenosa, export_fajl )
	
START PRINT CRET
	
?
? SPACE(2) + "Prenos KALK -> TOPS na dan: ", Date()
? SPACE(2) + "---------------------------------------"
?
? SPACE(2) + "Formiran dokument: " + export_fajl
?
? SPACE(2) + "Dokument: " + firma + "-" + tip_dok + "-" + br_dok
?
? SPACE(2) + "Broj prenesenih stavki: " + ALLTRIM(STR( broj_stavki ))
? SPACE(2) + "Saldo: " + ALLTRIM(STR( total_prenosa, 10, 2 ) )
?
?

if tip_dok == "80" .and. total_prenosa == 0
	? SPACE(2) + "Predispozicija"
endif

?

ENDPRINT

return



// -------------------------------------------------------
// kreiranje fajla prenosa
// -------------------------------------------------------
static function _kreiraj_fajl_prenosa( datum, pos_locations, broj_stavki )
local _i, _n
local _dest_file, _dest_patt
local _integ := {}
local _table_name := "katops.dbf"
local _table_path := my_home()
local _export_location, _export
local _ret := ""

if RIGHT( ALLTRIM( gTopsDest ) , 1 ) <> SLASH
    gTopsDest := ALLTRIM( gTopsDest ) + SLASH
endif

// napravi direktorij prenosa ako ga nema !
_dir_create( ALLTRIM( gTopsDest ) )

// export lokacija generalna
_export_location := ALLTRIM( gTopsDest )

if gMultiPM == "D"
            
    // prodji kroz sve lokacije i postavi datoteke eksporta
    for _n := 1 to LEN( pos_locations )  
   
        // export ce biti u poddirektoriju kojem treba da bude...
        // recimo /prenos/1/
        _export := _export_location + ALLTRIM( pos_locations[ _n ] ) + SLASH 

        // kreiraj mi ovaj direktorij ako ne postoji 
        _dir_create( _export )

        // nakon dir create prebaci se na my_local_folder
        DirChange( my_home() )

        // pronadji mi naziv fajla koji je dozvoljen 
        _dest_patt := get_topskalk_export_file( "2", _export, datum )
       
        // kopiraj katops.dbf
        _dest_file := _export + STRTRAN( _table_name, "katops.", _dest_patt + "." )
        _ret := _dest_file
        
        if FileCopy( _table_path + _table_name, _dest_file ) > 0
            // kopiraj txt fajl
            _dest_file := STRTRAN( _dest_file, ".dbf", ".txt" )
            FileCopy( my_home() + OUTF_FILE, _dest_file )
        else
            MsgBeep( "Problem sa kopiranjem fajla na destinaciju #" + _export )
        endif
    
    next 

else
    
    _integ := IntegDbf( _table_name )
    NapraviCRC( ALLTRIM(gTopsDEST) + "crckt.crc" , _integ[1] , _integ[2] )

endif

return _ret


// ---------------------------------------------------------------
// vraca naziv fajla za export
// ---------------------------------------------------------------
function get_topskalk_export_file( topskalk, export_path, datum, prefix )
local _file := ""
local _prefix := "kt"
local _i, _tmp
local _tmp_date := RIGHT( DTOS( datum ), 4 )

if topskalk == "1"
	_prefix := "tk"
else
	_prefix := "kt"
endif

if prefix != NIL
    _prefix := prefix
endif

// naziv fajla treba da bude 
// kt110401, kt110402 itd...

for _i := 1 to 99
    // nastavak na fajl
    _tmp := PADL( ALLTRIM(STR(_i)), 2, "0" )
    _file := _prefix + _tmp_date + _tmp

    if !FILE( export_path + _file + ".dbf" )
        // ovaj fajl moze da se koristi
        exit
    endif
next
 
return _file



// ------------------------------------------------------------------
// generisanje topska na osnovu azuriranog kalk dokumenta
// ------------------------------------------------------------------
function mnu_prenos_kalk_u_tops()
local cIDFirma := gFirma
local cIDTipDokumenta := "80"
local cBrojDokumenta := SPACE(8)

Box(,5,40)
	set cursor on
	@ m_x+1,m_y+2 SAY "Generacija KALK -> TOPS: "
	@ m_x+2,m_y+2 SAY "-------------------------------"
	@ m_x+4,m_y+2 SAY "Dokument: " GET cIDFirma
	@ m_x+4,m_y+16 SAY " - " GET cIDTipDokumenta VALID !Empty(cIDTipDokumenta)
	@ m_x+4,m_y+23 SAY " - " GET cBrojDokumenta VALID !Empty(cBrojDokumenta)
	read
	ESC_BCR
BoxC()

if kalk_dokument_postoji( cIDFirma, cIDTipDokumenta, cBrojDokumenta )
	if (gTops <> "0 " .and. Pitanje(,"Izgenerisati datoteku prenosa?","N") == "D")
        // generisi datoteku prenosa
		kalk_generisi_tops_dokumente( cIDFirma, cIDTipDokumenta, cBrojDokumenta )
	endif	
endif

return


// ---------------------------------------------------------------
// provjera da li trazeni dokument postoji ?
// ---------------------------------------------------------------
static function kalk_dokument_postoji( idfirma, tipdokumenta, brojdokumenta )
O_KALK_DOKS
select kalk_doks
HSEEK idfirma + tipdokumenta + brojdokumenta

if !Found()  
	MsgBeep("Dokument " + TRIM(idfirma) + "-" + TRIM(tipdokumenta) + "-" + TRIM(brojdokumenta) + " ne postoji !!!")
	return .f.
else
	return .t.
endif

return .f.


 
