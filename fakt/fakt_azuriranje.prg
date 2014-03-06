/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fakt.ch"

// --------------------------------------------------
// centralna funkcija za azuriranje fakture
// --------------------------------------------------
function azur_fakt( lSilent )
local _a_fakt_doks := {}
local _id_firma
local _br_dok
local _id_tip_dok
local _ok
local _tbl_fakt  := "fakt_fakt"
local _tbl_doks  := "fakt_doks"
local _tbl_doks2 := "fakt_doks2"
local _msg
local oAtrib

if ( lSilent == nil)
    lSilent := .f.
endif

o_fakt_edit()

if ( !lSilent .and. Pitanje( "FAKT_AZUR", "Sigurno zelite izvrsiti azuriranje (D/N) ?", "N" ) == "N" )
    return _a_fakt_doks
endif

select fakt_pripr
use

O_FAKT_PRIPR
go top

// ubaci mi matricu sve dokumente iz pripreme
_a_fakt_doks := fakt_dokumenti_u_pripremi()

if LEN( _a_fakt_doks ) == 0
    MsgBeep( "Postojeci dokumenti u pripremi vec postoje azurirani u bazi !" )
    return _a_fakt_doks
endif

// ako je samo jedan dokument provjeri njegove redne brojeve
if LEN( _a_fakt_doks ) == 1
    select fakt_pripr
    go top
    // provjeri redne brojeve dokumenta
    if !provjeri_redni_broj()
        MsgBeep( "Redni brojevi u dokumentu nisu ispravni !!!" )
        return _a_fakt_doks
    endif
endif

// fiksiranje tabele atributa
F18_DOK_ATRIB():new("fakt"):fix_atrib( F_FAKT_PRIPR, _a_fakt_doks )

_ok := .t.

MsgO( "Azuriranje dokumenata u toku ..." )

// prodji kroz matricu sa dokumentima i azuriraj ih
for _i := 1 to LEN( _a_fakt_doks )

    _id_firma   := _a_fakt_doks[ _i, 1 ]
    _id_tip_dok := _a_fakt_doks[ _i, 2 ]
    _br_dok     := _a_fakt_doks[ _i, 3 ]
    
    // provjeri da li postoji vec identican broj azuriran u bazi ?
    if fakt_doks_exist( _id_firma, _id_tip_dok, _br_dok )
        MsgBeep( "Dokument " + _id_firma + "-" + _id_tip_dok + "-" + ALLTRIM(_br_dok) + " vec postoji azuriran u bazi !" )
        _ok := .f.
    endif
    
    if _ok .and. fakt_azur_sql( _id_firma, _id_tip_dok, _br_dok  )
    
        if _ok .and. !fakt_azur_dbf( _id_firma, _id_tip_dok, _br_dok )
            _msg := "ERROR DBF: Neuspjesno FAKT/DBF azuriranje: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok
            log_write(_msg, 1)
            MsgBeep(_msg)
            _ok := .f.
        else
            log_write( "F18_DOK_OPER: azuriranje fakt dokumenta: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok, 2 )
        endif

    else
        _msg := "ERROR SQL: Neuspjesno SQL azuriranje: " + _id_firma + "-" + _id_tip_dok + "-" + _br_dok
        log_write(_msg, 1)
        MsgBeep(_msg)
        _ok := .f.
    endif

next

MsgC()

if !_ok
   return _a_fakt_doks
endif

select fakt_pripr

MsgO("brisem pripremu....")

// provjeri sta treba pobrisati iz pripreme
if LEN( _a_fakt_doks ) > 1
    fakt_izbrisi_azurirane( _a_fakt_doks )
else
    // izbrisi pripremu
    select fakt_pripr
    ZAPP( .t. )
endif

// pobrisi mi fakt_atribute takodjer
F18_DOK_ATRIB():new("fakt"):zapp_local_table()

MsgC()
    
close all

return _a_fakt_doks


// -----------------------------------------------------------------
// seek dokumenta u pripremi
// -----------------------------------------------------------------
static function _seek_pripr_dok( idfirma, idtipdok, brdok )
local _ret := .f.

O_FAKT_PRIPR

select fakt_pripr
set order to tag "1"
go top
seek idfirma + idtipdok + brdok

if FOUND()
    _ret := .t.
endif

return _ret



// --------------------------------------------------------------
// azuriranje u sql tabele
// --------------------------------------------------------------
static function fakt_azur_sql( id_firma, id_tip_dok, br_dok )
local _ok
local _tbl_fakt, _tbl_doks, _tbl_doks2
local _i, _n
local _tmp_id, _tmp_doc
local _ids := {}
local _ids_tmp := {}
local _ids_doc := {}
local _fakt_doks_data
local _fakt_doks2_data
local _fakt_totals
local _record
local _msg
local _ids_fakt  := {}
local _ids_doks  := {}
local _ids_doks2 := {}
local oAtrib

close all

_tbl_fakt  := "fakt_fakt"
_tbl_doks  := "fakt_doks"
_tbl_doks2 := "fakt_doks2"

Box(, 5, 60 )

_ok := .t.

O_FAKT_PRIPR

// vidi ima li tog dokumenta u pripremi !
// svakako mi se nastimaj na taj record
if !_seek_pripr_dok( id_firma, id_tip_dok, br_dok )
    Alert( "ne kontam u fakt_pripr nema: " + id_firma + "-" + id_tip_dok + "-" + br_dok )
    return .f.
endif

// lokuj prvo tabele
if !f18_lock_tables( { "fakt_fakt", "fakt_doks", "fakt_doks2" } )
    return .f.
endif

o_fakt_edit()
// opet se vrati na ovaj slog koji mi treba
_seek_pripr_dok( id_firma, id_tip_dok, br_dok )

// -----------------------------------------------------------------------------------------------------
sql_table_update(nil, "BEGIN")

// uzmi potrebni record
_record := dbf_get_rec()

// algoritam 2 - dokument nivo
_tmp_id := _record["idfirma"] + _record["idtipdok"] + _record["brdok"]
AADD( _ids_fakt, "#2" + _tmp_id )

@ m_x + 1, m_y + 2 SAY "fakt_fakt -> server: " + _tmp_id 

do while !EOF() .and. field->idfirma == id_firma .and. field->idtipdok == id_tip_dok .and. field->brdok == br_dok
    _record := dbf_get_rec()
    if !sql_table_update("fakt_fakt", "ins", _record )
        _ok := .f.
        exit
    endif
    skip
enddo

if _ok == .t.
    @ m_x + 2, m_y + 2 SAY "fakt_doks -> server: " + _tmp_id 
    AADD( _ids_doks, _tmp_id )
    SELECT fakt_pripr
    _record := get_fakt_doks_data( id_firma, id_tip_dok, br_dok )
    if !sql_table_update( "fakt_doks", "ins", _record )
        _ok := .f.
    endif
endif

if _ok == .t.
    @ m_x + 3, m_y + 2 SAY "fakt_doks2 -> server: " + _tmp_id 
    AADD( _ids_doks2, _tmp_id )
    _record := get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )
    SELECT fakt_pripr
    if !sql_table_update("fakt_doks2", "ins", _record )
        _ok := .f.
    endif
endif

if _ok == .t.
    @ m_x + 4, m_y + 2 SAY "fakt_atributi -> server "
    oAtrib := F18_DOK_ATRIB():new("fakt")
    oAtrib:dok_hash["idfirma"] := id_firma
    oAtrib:dok_hash["idtipdok"] := id_tip_dok
    oAtrib:dok_hash["brdok"] := br_dok
    _ok := oAtrib:atrib_dbf_to_server()
endif

if !_ok
    _msg := "FAKT sql azuriranje, trasakcija " + _tmp_id + " neuspjesna ?!"
    log_write( _msg, 2 )
    MsgBeep(_msg )
    // transakcija neuspjesna
    // server nije azuriran 
    sql_table_update(nil, "ROLLBACK" )

    // ako je transakcja neuspjesna, svejedno trebas osloboditi tabele
    f18_free_tables({"fakt_fakt", "fakt_doks", "fakt_doks2"})

else

    @ m_x+4, m_y+2 SAY "push ids to semaphore: " + _tmp_id

    push_ids_to_semaphore( _tbl_fakt   , _ids_fakt   )
    push_ids_to_semaphore( _tbl_doks   , _ids_doks   )
    push_ids_to_semaphore( _tbl_doks2  , _ids_doks2  )

    f18_free_tables({"fakt_fakt", "fakt_doks", "fakt_doks2"})
    sql_table_update(nil, "END")

endif

BoxC()

return _ok




// -------------------------------------------------------------------
// azuriranje u dbf tabele
// -------------------------------------------------------------------
static function fakt_azur_dbf( id_firma, id_tip_dok, br_dok, lSilent )
local _a_memo
local _rec
local _fakt_totals
local _fakt_doks_data
local _fakt_doks2_data

close all
o_fakt_edit()

Box( "#Proces azuriranja dbf-a u toku", 3, 60 )

    @ m_x + 1, m_y + 2 SAY "fakt_pripr -> fakt_fakt"

    // seekuj mi dokument u pripremi
    _seek_pripr_dok( id_firma, id_tip_dok, br_dok )
    
    do while !EOF() .and. field->idfirma == id_firma .and. field->idtipdok == id_tip_dok .and. field->brdok == br_dok

        select fakt_pripr
        _rec := dbf_get_rec()
        
        select fakt
        APPEND BLANK
        dbf_update_rec( _rec, .t. )

        select fakt_pripr
        skip

    enddo

    @ m_x + 2, m_y + 2 SAY "fakt_doks " + id_firma + id_tip_dok + br_dok 
  
    select fakt_doks
    set order to tag "1"
    go top
    seek id_firma + id_tip_dok + br_dok

    if !FOUND()

        _rec := get_fakt_doks_data( id_firma, id_tip_dok, br_dok )
        
        // pobrisi sljedece clanove...
        hb_hdel( _rec, "brisano" ) 
        hb_hdel( _rec, "sifra" ) 

        select fakt_doks
        APPEND BLANK

        dbf_update_rec( _rec, .t. )

    else

        _msg := "ERR: " + RECI_GDJE_SAM0 + " postoji zapis u fakt_doks : " + id_firma + id_tip_dok + br_dok 
        Alert(_msg)
        log_write( _msg, 5 )

    endif


    @ m_x + 3, m_y + 2 SAY "fakt_doks2 " + id_firma + id_tip_dok + br_dok

    select fakt_doks2
    set order to tag "1"
    go top
    seek id_firma + id_tip_dok + br_dok

    if !FOUND()

        _rec := get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )

        select fakt_doks2
        APPEND BLANK

        dbf_update_rec( _rec, .t. )

    else
        _msg := "ERR: " + RECI_GDJE_SAM0 + " postoji zapis u fakt_doks2 : " + id_firma + id_tip_dok + br_dok 
        Alert(_msg)
        log_write( _msg, 5 )
    endif

BoxC()

// opet seekuj pripremu 
_seek_pripr_dok( id_firma, id_tip_dok, br_dok )

return .t.




// -----------------------------------------------
// -----------------------------------------------
static function _fakt_partner_naziv( id_partner )
local _return := ""
local _t_area := SELECT()
    
select ( F_PARTN )
if !Used()
    O_PARTN
endif

select partn
go top
hseek id_partner

// priprema podatke za upis u polje "doks->partner"
_return := ALLTRIM( partn->naz )
_return += " "
_return += ALLTRIM( partn->adresa )
_return += ","
_return += ALLTRIM( partn->ptt )
_return += " "
_return += ALLTRIM( partn->mjesto )

_return := PADR( _return, FAKT_DOKS_PARTNER_LENGTH )

select ( _t_area )    
return _return


// -------------------------------------------------------------
// vraca hash matricu za fakt_doks2
// -------------------------------------------------------------
function get_fakt_doks2_data( id_firma, id_tip_dok, br_dok )
local _fakt_data := hb_hash()
local _memo 

O_FAKT_PRIPR
select fakt_pripr
go top
seek id_firma + id_tip_dok + br_dok

_fakt_data["idfirma"]  := field->idfirma
_fakt_data["brdok"]    := field->brdok
_fakt_data["idtipdok"] := field->idtipdok

_memo := ParsMemo( field->txt )
    
_fakt_data["k1"] := if( LEN( _memo ) >= 11, _memo[11], "" )
_fakt_data["k2"] := if( LEN( _memo ) >= 12, _memo[12], "" )
_fakt_data["k3"] := if( LEN( _memo ) >= 13, _memo[13], "" )
_fakt_data["k4"] := if( LEN( _memo ) >= 14, _memo[14], "" )
_fakt_data["k5"] := if( LEN( _memo ) >= 15, _memo[15], "" )
_fakt_data["n1"] := if( LEN( _memo ) >= 16, VAL( ALLTRIM( _memo[16] ) ), 0 )
_fakt_data["n2"] := if( LEN( _memo ) >= 17, VAL( ALLTRIM( _memo[17] ) ), 0 )

return _fakt_data


// -------------------------------------------------------------
// -------------------------------------------------------------
function get_fakt_doks_data( id_firma, id_tip_dok, br_dok )
local _fakt_totals
local _fakt_data 
local _memo 

// definiši matricu za fakt_doks zapis
_fakt_data := hb_hash()
_fakt_data["idfirma"]  := id_firma
_fakt_data["idtipdok"] := id_tip_dok
_fakt_data["brdok"]    := br_dok

O_FAKT_PRIPR
// sljedeća polja ću uzeti iz pripreme
select fakt_pripr
HSEEK id_firma + id_tip_dok + br_dok

_memo := ParsMemo( field->txt )

_fakt_data["datdok"]  := field->datdok
_fakt_data["dindem"]  := field->dindem
_fakt_data["rezerv"] := " "
_fakt_data["m1"] := field->m1
_fakt_data["idpartner"] := field->idpartner
_fakt_data["partner"] := _fakt_partner_naziv( field->idpartner )
_fakt_data["oper_id"] := getUserId()
_fakt_data["sifra"] := SPACE(6)
_fakt_data["brisano"] := SPACE(1)
_fakt_data["idvrstep"] := field->idvrstep
_fakt_data["datpl"] := field->datdok
_fakt_data["idpm"] := field->idpm

//_fakt_data["dok_veza"] := ""

_fakt_data["dat_isp"]  := iif( LEN( _memo ) >= 7, CToD( _memo[7] ), CToD("") )
_fakt_data["dat_otpr"] := iif( LEN( _memo ) >= 7, CToD( _memo[7] ), CToD("") )
_fakt_data["dat_val"]  := iif( LEN( _memo ) >= 9, CToD( _memo[9] ), CToD("") )

//ovo nema nikakvog smisla. fisc_rn uvijek postoji u F18
//takođe mi mije jasno zašto se ne uzmu oba polja onakva kakva jesu ?
// ovdje uopšte mi nije jasna ova zbrka koja se pravi sa fisc_rn i fisc_st poljima
// non stop se nešto gleda bez ikakve potrebe
// u fisc_rn treba biti broj fiskalnog račun.

// ako se radi o reklamoranom (storno računu) onda sadržan treba biti
// fisc_rn - originalni račun koji se reklamira, fisc_st - broj reklamiranog računa

_fakt_data["fisc_rn"] := field->fisc_rn
_fakt_data["fisc_st"] := 0
_fakt_data["fisc_date"] := CTOD("")
_fakt_data["fisc_time"] := PADR( "", 10 )

// izracunaj totale za fakturu
_fakt_totals := calculate_fakt_total( id_firma, id_tip_dok, br_dok )
    
// ubaci u fakt_doks totale
_fakt_data["iznos"] := _fakt_totals["iznos"] 
_fakt_data["rabat"] := _fakt_totals["rabat"]

return _fakt_data



// ----------------------------------------------------------
// kalkulise ukupno za fakturu
// ----------------------------------------------------------
function calculate_fakt_total( id_firma, id_tipdok, br_dok)
local _fakt_total := hb_hash()
local _cij_sa_por := 0
local _rabat := 0
local _uk_sa_rab := 0
local _uk_rabat := 0 
local _dod_por := 0
local _din_dem

select fakt_pripr
go top
seek id_firma + id_tipdok + br_dok
    
_din_dem := field->dindem

do while !EOF() .and. field->idfirma == id_firma .and. field->idtipdok == id_tipdok .and. field->brdok == br_dok
        
    if _din_dem == LEFT( ValBazna(), 3 )
        
        _cij_sa_por := ROUND( field->kolicina * field->cijena * PrerCij() * ( 1 - field->rabat / 100), ZAOKRUZENJE )
        
        _rabat := ROUND( field->kolicina * field->cijena * PrerCij() * field->rabat / 100 , ZAOKRUZENJE )
        
        _dod_por := ROUND( _cij_sa_por * field->porez / 100, ZAOKRUZENJE )
        
    else
        
        _cij_sa_por := ROUND( field->kolicina * field->cijena * ;
                        PrerCij() * ( 1 - field->Rabat / 100), ZAOKRUZENJE ) 
        
        _rabat := ROUND( field->kolicina * field->cijena * ;
                        PrerCij() * field->rabat / 100 , ZAOKRUZENJE )
        
        _dod_por := ROUND( _cij_sa_por * field->porez / 100, ZAOKRUZENJE )
        
    endif
        
    _uk_sa_rab += _cij_sa_por + _dod_por
    _uk_rabat += _rabat

    skip

enddo

_fakt_total["iznos"] := _uk_sa_rab
_fakt_total["rabat"] := _uk_rabat
 
return _fakt_total



// -----------------------------------------------------------
// pravi fakt, protudokumente
// -----------------------------------------------------------
static function fakt_protu_dokumenti( cPrj )
local lVecPostoji := .f.
local cKontrol2Broj
local lProtu := .f.

if ( gProtu13 == "D" .and. ;
    fakt_pripr->idtipdok == "13" .and. ;
    Pitanje("AZUR PROD", "Napraviti protu-dokument zaduzenja prodavnice","D")=="D")
    
    if (gVar13 == "2" .and. gVarNum == "1")
        cPRj := RJIzKonta(fakt_pripr->idpartner + " ")
    else
        O_RJ
        Box(,2,50)
            cPRj:=IzFMKIni("FAKT","ProtuDokument13kiIdeNaRJ","P1",KUMPATH)
            @ m_x+1,m_y+2 SAY "RJ - objekat:" GET cPRj valid P_RJ(@cPRJ) pict "@!"
            read
        BoxC()
        select rj
        use
    endif
        
    lVecPostoji := .f.
    // prvo da provjerimo ima li isti broj dokumenta u DOKS
    cKontrol2Broj := fakt_pripr->(cPRJ+"01"+TRIM(brdok)+"/13")
    select fakt_doks
    seek cKontrol2Broj
        
    if Found()
        lVecPostoji:=.t.
    else
        // ako nema u DOKS, 
        // provjerimo ima li isti broj dokumenta u FAKT
        select fakt
        seek cKontrol2Broj
        if Found()
            lVecPostoji:=.t.
        endif
    endif
        
    if lVecPostoji
        Msg("Vec postoji dokument pod brojem "+fakt_pripr->(cPRJ+"-01-"+TRIM(brdok)+"/13"),4)
        close all
        return .f.
    endif

    lProtu := .t.

endif

return lProtu

// -----------------------------------
// vise dokumenata u pripremi
// ----------------------------------
function fakt_dokumenti_u_pripremi()
local _fakt_doks := {}
local _id_firma
local _id_tip_dok
local _br_dok

select fakt_pripr
go top

do while !EOF()
    
    _id_firma := field->idfirma
    _id_tip_dok := field->idtipdok
    _br_dok := field->brdok
    
    do while !EOF() .and. ( field->idfirma + field->idtipdok + field->brdok ) == ;
            ( _id_firma + _id_tip_dok + _br_dok )
        // preskoci sve stavke
        skip
    enddo
    
    // provjeri da li postoji vec identican broj azuriran u bazi ?
    if !fakt_doks_exist( _id_firma, _id_tip_dok, _br_dok )
        AADD( _fakt_doks, { _id_firma, _id_tip_dok, _br_dok } )
    endif

    select fakt_pripr

enddo

return _fakt_doks


// -------------------------------------
// -------------------------------------
function o_fakt_edit( _open_pfakt )

close all

if _open_pfakt == NIL
  _open_pfakt := .f.
endif

select ( F_FAKT_OBJEKTI )
if !used()
    O_FAKT_OBJEKTI
endif

if glDistrib = .t.
    select F_RELAC
    if !used()
        O_RELAC
        O_VOZILA
        O_KALPOS
    endif
endif

select F_VRSTEP
if !used()
    O_VRSTEP
endif

select F_OPS
if !used()
    O_OPS
endif

select F_KONTO
if !used()
    O_KONTO
endif

select F_SAST
if !used()
    O_SAST
endif

select F_PARTN
if !used()
    O_PARTN
endif

select F_ROBA
if !used()
    O_ROBA
endif

if _open_pfakt

    // otvori fakt_fakt pod fakt_pripr aliasom
    select F_FAKT
    if !used()
        O_PFAKT
    endif

else

    select F_FAKT_PRIPR
    if !used()
        O_FAKT_PRIPR
    endif

    select F_FAKT
    if !used()
        O_FAKT
    endif

endif

select F_FTXT
if !used()
    O_FTXT
endif

select F_TARIFA
if !used()
    O_TARIFA
endif

select F_VALUTE
if !used()
    O_VALUTE
endif

select F_FAKT_DOKS2
if !used()
    O_FAKT_DOKS2
endif

select F_FAKT_DOKS
if !used()
    O_FAKT_DOKS
endif

select F_RJ
if !used()
    O_RJ
endif

select F_SIFK
if !used()
    O_SIFK
endif

select F_SIFV
if !used()
    O_SIFV
endif

select fakt_pripr
set order to tag "1"
go top

return nil



/*! \fn SrediRbrFakt()
 *  \brief Sredi redni broj
 */
function SrediRbrFakt()
local _t_rec, _rec
local _firma, _broj, _tdok
local _cnt

O_FAKT_PRIPR
set order to tag "1"
go top

do while !eof()
	
	_firma := field->idfirma
	_tdok  := field->idtipdok
	_broj  := field->brdok
	_cnt   := 0

	do while !EOF() .and. field->idfirma == _firma .and. field->idtipdok == _tdok .and. field->brdok == _broj
					
		skip 1
		
		_t_rec := RECNO()

		skip -1

        _rec := dbf_get_rec()
		_rec["rbr"] := PADL( ALLTRIM(STR( ++ _cnt )), 3, 0 )
	    dbf_update_rec( _rec )

		go ( _t_rec )
	
	enddo

enddo

return 0






// ---------------------------------------------------------------------------
// izbrisi azurirane dokumente iz pripreme na osnovu matrice a_data
// ---------------------------------------------------------------------------
static function fakt_izbrisi_azurirane( a_data )
local nRecNo

select fakt_pripr
go top
do while !eof()
    skip 1
    nRecNo := RecNo()
    skip -1
    if ( ASCAN( a_data, field->idfirma + field->idtipdok + field->brdok ) = 0 )
        delete
    endif
    go (nRecNo)
enddo
            
__dbpack()
            
return



// provjeri duple stavke u pripremi za vise dokumenata
function prov_duple_stavke() 
local cSeekDok
local lDocExist:=.f.

select fakt_pripr
go top

// provjeri duple dokumente
do while !EOF()
    cSeekDok := fakt_pripr->(idfirma + idtipdok + brdok)
    if dupli_dokument(cSeekDok)
        lDocExist := .t.
        exit
    endif
    select fakt_pripr
    skip
enddo

// postoje dokumenti dupli
if lDocExist
    MsgBeep("U pripremi su se pojavili dupli dokumenti!")
    if Pitanje("BRIS-DUP", "Pobrisati duple dokumente (D/N)?", "D")=="N"
        MsgBeep("Dupli dokumenti ostavljeni u tabeli pripreme!#Prekidam operaciju azuriranja!")
        return 1
    else
        Box(,1,60)
            cKumPripr := "P"
            @ m_x+1, m_y+2 SAY "Zelite brisati stavke iz kumulativa ili pripreme (K/P)" GET cKumPripr VALID !Empty(cKumPripr) .or. cKumPripr $ "KP" PICT "@!"
            read
        BoxC()
        
        if cKumPripr == "P"
            // brisi pripremu
            return prip_brisi_duple()
        else
            // brisi kumulativ
            return kum_brisi_duple()
        endif
    endif
endif

return 0



// brisi stavke iz pripreme koje se vec nalaze u kumulativu
function prip_brisi_duple()
local cSeek
select fakt_pripr
go top

do while !EOF()
    cSeek := fakt_pripr->(idfirma + idtipdok + brdok)
    
    if dupli_dokument(cSeek)
        // pobrisi stavku
        select fakt_pripr
        delete
    endif
    
    select fakt_pripr
    skip
enddo

return 0


// ---------------------------------------------------------------------
// brisi stavke iz kumulativa koje se vec nalaze u pripremi
// ---------------------------------------------------------------------
function kum_brisi_duple()
local _seek
local _ctrl_seek
local _rec

select fakt_pripr
go top

_ctrl_seek := "XXX"

do while !EOF()
    
    _seek := fakt_pripr->(idfirma + idtipdok + brdok)
    
    if _seek == _ctrl_seek
        skip
        loop
    endif
    
    if dupli_dokument( _seek )
        
        select fakt_doks
        
        MsgO("Brisem stavke iz kumulativa ... sacekajte trenutak!")
        
		// brisi doks
        set order to tag "1"
        go top
        seek _seek
        
		if Found()

			_rec := dbf_get_rec()
			delete_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )			

        	// brisi iz fakt
        	select fakt
        	set order to tag "1"
        	go top
        	seek _seek
        	
			if Found()
				_rec := dbf_get_rec()
				delete_rec_server_and_dbf( "fakt_fakt", _rec, 2, "CONT" )
            endif
     	endif

        MsgC()

    endif
    
    _ctrl_seek := _seek
    
    select fakt_pripr
    skip

enddo

return 0



// ------------------------------------------
// ------------------------------------------
function dupli_dokument(cSeek)
select fakt_doks
set order to tag "1"
go top
seek cSeek
if Found()
    if gMreznoNum == "D"
        if m1 == "Z"
            return .f.
        endif
    endif
    return .t.
endif
select fakt
set order to tag "1"
go top
seek cSeek
if Found()
    return .t.
endif
return .f.



// ------------------------------------------------
// ------------------------------------------------
function fakt_brisanje_pripreme()
local _id_firma, _tip_dok, _br_dok
local oAtrib

if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","BRISANJE" ))
    MsgBeep(cZabrana)
    return DE_CONT
endif

if Pitanje("FAKT_BRISI_PRIPR", "Zelite li izbrisati pripremu !!????","N")=="D"
 
    select fakt_pripr
    go top
    
    _id_firma := IdFirma
    _tip_dok := IdTipDok
    _br_dok := BrDok
    
    oAtrib := F18_DOK_ATRIB():new("fakt")
    oAtrib:dok_hash["idfirma"] := _id_firma
    oAtrib:dok_hash["idtipdok"] := _tip_dok
    oAtrib:dok_hash["brdok"] := _br_dok
 
    if gcF9usmece == "D"

        // pobrisi i atribute...
        oAtrib:delete_atrib()

        // azuriraj dokument u smece 
        azuriraj_smece( .t. )    

        log_write( "F18_DOK_OPER: fakt, prenosa dokumenta iz pripreme u smece: " + _id_firma + "-" + _tip_dok + "-" + _br_dok, 2 )

        select fakt_pripr

    else
        
        // ponisti pripremu...
        zapp()
        // ponisti i atribut        // ponisti i atributee
        oAtrib:zapp_local_table() 
        
        log_write( "F18_DOK_OPER: fakt, brisanje dokumenta iz pripreme: " + _id_firma + "-" + _tip_dok + "-" + _br_dok, 2 )

        // potreba za resetom brojaca ?
        fakt_reset_broj_dokumenta( _id_firma, _tip_dok, _br_dok )

   endif

endif

return


/*! \fn KomIznosFakt()
 *  \brief Kompletiranje iznosa fakture pomocu usluga
 */
 
function KomIznosFakt()
local nIznos:=0
local cIdRoba

O_SIFK
O_SIFV
O_FAKT_S_PRIPR
O_TARIFA
O_ROBA

cIdRoba:=SPACE(LEN(id))

Box("#KOMPLETIRANJE IZNOSA FAKTURE POMOCU USLUGA",5,75)
    @ m_x+2, m_y+2 SAY "Sifra usluge:" GET cIdRoba VALID P_Roba(@cIdRoba) PICT "@!"
    @ m_x+3, m_y+2 SAY "Zeljeni iznos fakture:" GET nIznos PICT picdem
    read
    ESC_BCR
BoxC()

select roba
hseek cIdRoba
select tarifa
hseek roba->idtarifa
select fakt_pripr

nDug2:=0
nRab2:=0
nPor2:=0

//KonZbira(.f.)

go bottom

Scatter()

append blank

_idroba:=cIdRoba
_kolicina:=IF(nDug2-nRab2+nPor2>nIznos,-1,1)
_rbr := STR( RbrUnum(_Rbr) + 1, 3, 0)
_cijena:=ABS(nDug2-nRab2+nPor2-nIznos)
_rabat:=0 
_porez:=0

if !(_idtipdok $ "11#15#27")
    _porez:=if( ROBA->tip=="U",tarifa->ppp,tarifa->opp)
    _cijena:=_cijena/(1+_porez/100)
endif

_txt:=Chr(16)+ROBA->naz+Chr(17)

Gather()

MsgBeep("Formirana je dodatna stavka. Vratite se tipkom <Esc> u pripremu"+"#i prekontrolisite fakturu!")

CLOSERET


// ---------------------------------------------------
// generisi storno dokument u pripremi
// ---------------------------------------------------
function storno_dok( id_firma, id_tip_dok, br_dok )
local _novi_br_dok
local _rec 
local _count
local _fiscal_no
local _fiscal_use := fiscal_opt_active()

if Pitanje("FORM_STORNO", "Formirati storno dokument ?","D") == "N"
    return
endif

O_FAKT_PRIPR
select fakt_pripr

if fakt_pripr->(RECCOUNT2()) <> 0
    msgbeep("Priprema nije prazna !!!")
    return
endif

O_FAKT
O_FAKT_DOKS
O_ROBA
O_PARTN

_novi_br_dok := ALLTRIM( br_dok ) + "/S"

if LEN( ALLTRIM( _novi_br_dok ) ) > 8
    
    // otkini prva dva karaktera
    // da moze stati "/S"
    _novi_br_dok := RIGHT( ALLTRIM( br_dok ), 6 ) + "/S"

endif

_count := 0

select fakt_doks
set order to tag "1"
go top
seek id_firma + id_tip_dok + br_dok

_fiscal_no := 0

if _fiscal_use
    _fiscal_no := field->fisc_rn
endif

select fakt
set order to tag "1"
go top
seek id_firma + id_tip_dok + br_dok

do while !EOF() .and. field->idfirma == id_firma  .and. field->idtipdok == id_tip_dok .and. field->brdok == br_dok
    
    _rec := dbf_get_rec()

    select fakt_pripr
    append blank

    _rec["kolicina"] := ( _rec["kolicina"] * -1 )
    _rec["brdok"] := _novi_br_dok
    _rec["datdok"] := DATE()

    // obavezno resetuj vrstu placanja na gotovina...
    _rec["idvrstep"] := ""
 
    if _fiscal_use
        _rec["fisc_rn"] := _fiscal_no
    endif

    dbf_update_rec( _rec )

    select fakt
    skip

    ++ _count

enddo

if _count > 0
    msgbeep("Formiran je dokument " + id_firma + "-" + ;
        id_tip_dok + "-" + ALLTRIM( _novi_br_dok ) + ;
        " u pripremi !")
endif

return


