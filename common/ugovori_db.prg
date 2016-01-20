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
#include "cre_all.ch"


// -------------------------------
// kreiranje tabela ugovora
// -------------------------------
function db_cre_ugov( ver )

cre_tbl( "UGOV", ver )
cre_tbl( "RUGOV", ver )
cre_tbl( "GEN_UG", ver )
cre_tbl( "GEN_UG_P", ver )
cre_tbl( "DEST", ver )

return



// ------------------------------------------
// interna funkcija za kreiranje tabela
// ------------------------------------------
static function cre_tbl( table_name, ver )
local aDbf
local _alias, _table_name 

// struktura
do case
	case table_name == "UGOV"
		aDbf := a_ugov()		
	case table_name == "RUGOV"
		aDbf := a_rugov()
	case table_name == "GEN_UG"
		aDbf := a_genug()
	case table_name == "GEN_UG_P"
		aDbf := a_gug_p()
	case table_name == "DEST"
		aDbf := a_dest()
endcase

_alias := table_name
_table_name := LOWER( table_name )

if !( table_name == "DEST" ) 
    _table_name := "fakt_" + LOWER( table_name )
endif

IF_NOT_FILE_DBF_CREATE
IF_C_RESET_SEMAPHORE

// indexi
do case
	case table_name == "UGOV"
		CREATE_INDEX("ID"      ,"Id+idpartner" , "UGOV" )
		CREATE_INDEX("NAZ"     ,"idpartner+Id" , "UGOV" )
		CREATE_INDEX("NAZ2"    ,"naz"          , "UGOV" )
		CREATE_INDEX("PARTNER" ,"IDPARTNER"    , "UGOV" ) 
		CREATE_INDEX("AKTIVAN" ,"AKTIVAN"      ,  "UGOV" )
	case table_name == "RUGOV"
		CREATE_INDEX("ID","id+idroba+dest", "RUGOV")
		CREATE_INDEX("IDROBA","IdRoba", "RUGOV")
	case table_name == "GEN_UG"
		CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)", "GEN_UG")
		CREATE_INDEX("DAT_GEN","DTOS(DAT_GEN)", "GEN_UG")
	case table_name == "GEN_UG_P"
		CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)+ID_UGOV+IDPARTNER", "GEN_UG_P")
	case table_name == "DEST"
		CREATE_INDEX("ID", "IDPARTNER + ID", "DEST")
		CREATE_INDEX("IDDEST", "ID", "DEST")
endcase 

return


// ---------------------------------------------
// vraca matricu sa tabelom DEST
// ---------------------------------------------
static function a_dest()
local aDbf:={}

AADD(aDBF, { "ID"        , "C" ,  6,  0 })
AADD(aDBF, { "IDPartner" , "C" ,  6,  0 })
AADD(aDBF, { "Naziv"     , "C" , 60,  0 })
AADD(aDBF, { "Naziv2"    , "C" , 60,  0 })
AADD(aDBF, { "Mjesto"    , "C" , 20,  0 })
AADD(aDBF, { "Adresa"    , "C" , 40,  0 })
AADD(aDBF, { "Ptt"       , "C" , 10,  0 })
AADD(aDBF, { "Telefon"   , "C" , 20,  0 })
AADD(aDBf, { "Mobitel"   , "C" , 20,  0 })
AADD(aDBf, { "Fax"       , "C" , 20,  0 })

return aDbf


// -----------------------------------------
// vraca matricu sa strukturom tabele UGOV
// -----------------------------------------
static function a_ugov()
local aDbf:={}

AADD(aDBF, { "ID"        , "C" , 10,  0 })
AADD(aDBF, { "DatOd"     , "D" ,  8,  0 })
AADD(aDBF, { "IDPartner" , "C" ,  6,  0 })
AADD(aDBF, { "DatDo"     , "D" ,  8,  0 })
AADD(aDBF, { "Naz"       , "C" , 20,  0 })
AADD(aDBF, { "Vrsta"     , "C" ,  1,  0 })
AADD(aDBF, { "IdTipdok"  , "C" ,  2,  0 })
AADD(aDBF, { "Aktivan"   , "C" ,  1,  0 })
AADD(aDBF, { "LAB_PRN"   , "C" ,  1,  0 })
AADD(aDBf, { 'DINDEM'    , 'C' ,  3,  0 })
AADD(aDBf, { 'IDTXT'     , 'C' ,  2,  0 })
AADD(aDBf, { 'ZAOKR'     , 'N' ,  1,  0 })
AADD(aDBf, { 'IDDODTXT'  , 'C' ,  2,  0 })

AADD(aDBf, { 'A1'        , 'N' , 12,  2 })
AADD(aDBf, { 'A2'        , 'N' , 12,  2 })

AADD(aDBf, { 'B1'        , 'N' , 12,  2 })
AADD(aDBf, { 'B2'        , 'N' , 12,  2 })

AADD(aDBf, { 'TXT2'      , 'C' ,  2,  0 })
AADD(aDBf, { 'TXT3'      , 'C' ,  2,  0 })
AADD(aDBf, { 'TXT4'      , 'C' ,  2,  0 })

// nivo fakturisanja
AADD(aDBf, { 'F_NIVO'    , 'C' ,  1,  0 })
// proizvoljni nivo
AADD(aDBf, { 'F_P_D_NIVO', 'N' ,  5,  0 })
// datum zadnjeg obracuna    
AADD(aDBf, { 'DAT_L_FAKT', 'D' ,  8,  0 })
// destinacija    
AADD(aDBf, { 'DEF_DEST',   'C' ,  6,  0 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele RUGOV
// ----------------------------------------
static function a_rugov()
aDbf:={}

AADD(aDBF, { "ID"       , "C" ,  10,  0 })
AADD(aDBF, { "IDROBA"   , "C" ,  10,  0 })
AADD(aDBF, { "Kolicina" , "N" ,  15,  4 })
AADD(aDBF, { "Cijena"   , "N" ,  15,  3 })
AADD(aDBf, { 'Rabat'    , 'N' ,   6,  3 })
AADD(aDBf, { 'Porez'    , 'N' ,   5,  2 })
AADD(aDBf, { 'K1'       , 'C' ,   1,  0 })
AADD(aDBf, { 'K2'       , 'C' ,   2,  0 })
AADD(aDBf, { 'DEST'     , 'C' ,   6,  0 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele GEN_UG
// ----------------------------------------
static function a_genug()
aDbf:={}

/// datum obracuna je kljucni datum - 
// on nam govori na koji se mjesec generacija 
// odnosi
AADD(aDBF, { "DAT_OBR"  , "D" ,   8,  0 })

// datum generacije govori kada je 
// obracun napravljen
AADD(aDBF, { "DAT_GEN"  , "D" ,   8,  0 })

// datum valute za izgenerisane dokumente
AADD(aDBF, { "DAT_VAL"  , "D" ,   8,  0 })

// datum posljednje uplate
AADD(aDBF, { "DAT_U_FIN", "D" ,   8,  0 })
// konto kupac
AADD(aDBF, { "KTO_KUP"  , "C" ,   7,  0 })
// konto dobavljac
AADD(aDBF, { "KTO_DOB"  , "C" ,   7,  0 })
// opis
AADD(aDBF, { "OPIS"     , "C" , 100,  0 })
// broj fakture od
AADD(aDBf, { 'BRDOK_OD' , 'C' ,   8,  0 })
// broj fakture do
AADD(aDBf, { 'BRDOK_DO' , 'C' ,   8,  0 })
// broj faktura
AADD(aDBf, { 'FAKT_BR'  , 'N' ,   5,  0 })
// saldo fakturisanja
AADD(aDBf, { 'SALDO'    , 'N' ,  15,  5 })
// saldo pdv-a
AADD(aDBf, { 'SALDO_PDV', 'N' ,  15,  5 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele GEN_UG_P
// ----------------------------------------
static function a_gug_p()
aDbf:={}

// datum obracuna
AADD(aDBF, { "DAT_OBR"  , "D" ,   8,  0 })

// partner
AADD(aDBF, { "IDPARTNER", "C" ,   6,  0 })
// id ugovora
AADD(aDBF, { "ID_UGOV"    , "C" ,  10,  0 })
// saldo kupca
AADD(aDBF, { "SALDO_KUP", "N" ,  15,  5 })
// saldo dobavljaci
AADD(aDBF, { "SALDO_DOB", "N" ,  15,  5 })
// datum posljednje uplate kupca
AADD(aDBf, { 'D_P_UPL_KUP', 'D' ,   8,  0 })
// datum posljednje promjene kupca
AADD(aDBf, { 'D_P_PROM_KUP', 'D' ,   8,  0 })
// datum posljednje promjene dobavljac
AADD(aDBf, { 'D_P_PROM_DOB', 'D' ,   8,  0 })
// fakturisanje iznos
AADD(aDBF, { "F_IZNOS"     , "N" ,  15,  5 })
// fakturisanje iznos pdv-a
AADD(aDBF, { "F_IZNOS_PDV" , "N" ,  15,  5 })

return aDbf


// --------------------------------
// otvori tabele neophodne za UGOV
// --------------------------------
function o_ugov()

O_FTXT
O_SIFK
O_SIFV
O_FAKT
O_FAKT_DOKS
O_ROBA
O_TARIFA
O_PARTN
O_DEST
O_UGOV
O_RUGOV
O_GEN_UG
O_G_UG_P
O_KONTO

return


// --------------------------------------
// dodaj stavku u gen_ug_p
// --------------------------------------
function a_to_gen_p(dDatObr, cIdUgov, cUPartner,  ;
                    nSaldoKup, nSaldoDob, dPUplKup,;
		    dPPromKup, dPPromDob, nFaktIzn, nFaktPdv)

local _rec

select gen_ug_p
set order to tag "dat_obr"
seek DTOS(dDatObr) + cIdUgov + cUPartner

if !FOUND()
	append blank
endif

_rec := dbf_get_rec()

_rec["dat_obr"] := dDatObr
_rec["id_ugov"] := cIdUgov
_rec["idpartner"] := cUPartner
_rec["saldo_kup"] := nSaldoKup
_rec["saldo_dob"] := nSaldoDob
_rec["d_p_upl_ku"] := dPUplKup
_rec["d_p_prom_k"] := dPPromKup
_rec["d_p_prom_d"] := dPPromDob
_rec["f_iznos"] := nFaktIzn
_rec["f_iznos_pd"] := nFaktPDV

update_rec_server_and_dbf( "fakt_gen_ug_p", _rec, 1, "FULL" )

return 


// -------------------------------------
// da li se koristi destinacija
// -------------------------------------
function is_dest()
local lRet := .f.
local nTArea := SELECT()

if rugov->(fieldpos("dest")) <> 0 .and. ;
	FILE( f18_ime_dbf("dest") )
	
	lRet := .t.
	
endif

select (nTArea)
return lRet



