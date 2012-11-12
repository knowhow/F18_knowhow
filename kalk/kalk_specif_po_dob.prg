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


// -----------------------------------------------
// specifikacija maloprodaje po dobavljacima
// -----------------------------------------------
function kalk_spec_mp_po_dob()
local _vars

// forma uslova izvjestaja
if !frm_vars( @_vars )
    return
endif

// kreiraj pomocnu tabelu
_cre_tmp()

// generisi report
gen_rpt( _vars )

if _vars["narudzba"] == "D"
    print_frm_asort_nar( _vars )
else
    // printaj report
    print_report( _vars )
endif

return


// ----------------------------------------
// kreiraj pomocnu tabelu
// ----------------------------------------
static function _cre_tmp()
local _dbf := {}
	
AADD( _dbf, { "IDKONTO", "C", 7, 0 })
AADD( _dbf, { "IDPARTNER", "C", 6, 0 })
AADD( _dbf, { "IDROBA", "C", 10, 0 })
AADD( _dbf, { "BARKOD", "C", 13, 0 })
AADD( _dbf, { "NAZIV", "C", 40, 0 })
AADD( _dbf, { "TARIFA", "C", 6, 0 })
AADD( _dbf, { "JMJ", "C", 3, 0 })
AADD( _dbf, { "ULAZ", "N", 15, 5 })
AADD( _dbf, { "IZLAZ", "N", 15, 5 })
AADD( _dbf, { "STANJE", "N", 15, 5 })
AADD( _dbf, { "PC", "N", 15, 5 })

t_exp_create( _dbf )

O_R_EXP
index on idroba tag "roba"
	
return



// ----------------------------------------
// forma uslova izvjestaja
// ----------------------------------------
static function frm_vars( vars )
local _dat_od, _dat_do, _p_konto, _artikli, _dob, _prik_nule
local _narudzba
local _x := 1

_dat_od := fetch_metric( "kalk_spec_mp_dob_dat_od", my_user(), CTOD("") )
_dat_do := fetch_metric( "kalk_spec_mp_dob_dat_do", my_user(), DATE() )
_p_konto := fetch_metric( "kalk_spec_mp_dob_p_konto", my_user(), PADR( "1330", 7 ) )
_artikli := PADR( fetch_metric( "kalk_spec_mp_dob_artikli", my_user(), "" ), 200 )
_dob := fetch_metric( "kalk_spec_mp_dob_dobavljac", my_user(), PADR( "", 6 ) )
_prik_nule := fetch_metric( "kalk_spec_mp_dob_nule", my_user(), "N" )
_narudzba := fetch_metric( "kalk_spec_mp_dob_narudzba", my_user(), "N" )

// forma uslova #
Box(, 10, 70 )
    
    @ m_x + _x, m_y + 2 SAY "Datum od:" GET _dat_od
    @ m_x + _x, col() + 1 SAY "do:" GET _dat_do

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Prodavnicki konto:" GET _p_konto VALID P_Konto( @_p_konto )
    
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Dobavljac:" GET _dob VALID P_Firma( @_dob )

    ++ _x
    ++ _x
    @ m_x + _x, m_y + 2 SAY "Artikli (prazno-svi):" GET _artikli PICT "@S35"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Prikaz stavki kojima je ulaz = 0 (D/N) ?" GET _prik_nule VALID _prik_nule $ "DN" PICT "@!"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Stampati formu narudzbe (D/N) ?" GET _narudzba VALID _narudzba $ "DN" PICT "@!"

    read

BoxC()

// ESC - vozdra forma i opcija
if LastKey() == K_ESC
    return .f.
endif

// snimi parametre i hash matricu
set_metric( "kalk_spec_mp_dob_dat_od", my_user(), _dat_od )
set_metric( "kalk_spec_mp_dob_dat_do", my_user(), _dat_do )
set_metric( "kalk_spec_mp_dob_p_konto", my_user(), _p_konto )
set_metric( "kalk_spec_mp_dob_artikli", my_user(), _artikli )
set_metric( "kalk_spec_mp_dob_dobavljac", my_user(), _dob )
set_metric( "kalk_spec_mp_dob_nule", my_user(), _prik_nule )
set_metric( "kalk_spec_mp_dob_narudzba", my_user(), _narudzba )

vars := hb_hash()
vars["datum_od"] := _dat_od
vars["datum_do"] := _dat_do
vars["p_konto"] := _p_konto
vars["artikli"] := _artikli
vars["dobavljac"] := _dob
vars["nule"] := _prik_nule
vars["narudzba"] := _narudzba

return .t.


// ----------------------------------------
// generisi report
// ----------------------------------------
static function gen_rpt( vars )

// izdvoji mi ulaze za izvjestaj i napuni u pomocnu tabelu
if _izdvoji_ulaze( vars ) == 0
    return .f.
endif

// samo ako se radi izvjestaj
// ako je narudzba, ovo je nepotrebno
if vars["narudzba"] == "N"
    // sada nastiklaj i prodaju na osnovu upita i pomocne tabele
    _izdvoji_prodaju( vars )
endif

return .t.


// ------------------------------------------------------
// izdvoji ulaze u pomocnu tabelu
// ------------------------------------------------------
static function _izdvoji_ulaze( vars )
local _qry := ""
local _date := ""
local _dat_od, _dat_do, _dob, _artikli, _p_konto, _id_firma
local _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _cnt := 0

_p_konto := vars["p_konto"]
_dat_od := vars["datum_od"]
_dat_do := vars["datum_do"]
_artikli := vars["artikli"]
_dob := vars["dobavljac"]
_id_firma := gFirma

// datumski uslov
if _dat_od <> CTOD( "" )   
    _date += "kalk.datdok >= " + _sql_quote( _dat_od )
endif

if _dat_do <> CTOD( "" )
    
    if !EMPTY( _date )
        _date += " AND "
    endif
    
    _date += "kalk.datdok <= " + _sql_quote( _dat_do )

endif

// sredi upit
if !EMPTY( _date )
    _date := " AND (" + _date + ")"
endif

// sql upit za ulaze:
//
_qry := "SELECT " + ;
   "kalk.pkonto pkonto, " + ;
   "kalk.idroba idroba, " + ;
   "roba.barkod barkod, " + ; 
   "roba.naz robanaz, " + ;
   "roba.idtarifa idtarifa, " + ;
   "roba.jmj jmj, " + ;
   "SUM( " + ; 
       "CASE " + ; 
          "WHEN kalk.pu_i = '1' THEN kalk.kolicina " + ;
          "WHEN kalk.pu_i = 'I' THEN kalk.gkolicin2 " + ;
          "ELSE 0 " + ;
       "END " + ; 
   ") as ulaz " + ;
"FROM fmk.kalk_kalk kalk " + ;
"LEFT JOIN fmk.roba roba ON kalk.idroba = roba.id " + ;
"WHERE " + ; 
   "kalk.idfirma = " + _sql_quote( _id_firma ) + ;  
   " AND kalk.pkonto = " + _sql_quote( _p_konto ) + ; 
   " AND kalk.idpartner = " + _sql_quote( _dob ) + ; 
   _date + ;  
   " AND roba.tip NOT IN ( " + _sql_quote("T") + ", " + _sql_quote("U") + " ) " + ;
"GROUP BY kalk.pkonto, kalk.idroba, roba.barkod, roba.naz, roba.idtarifa, roba.jmj " + ;
"ORDER BY kalk.idroba" 

MsgO( "Prikupljanje podataka ulaza u maloprodaji... sacekajte !" )

_table := _sql_query( _server, _qry )
_table:Refresh()

// provrti se kroz matricu i azuriraj rezultat u pomocni dbf
for _i := 1 to _table:LastRec()

    ++ _cnt

    oRow := _table:GetRow( _i )

    select r_export
    append blank
    
    _rec := dbf_get_rec()

    // uzmi iz varijabli
    _rec["idpartner"] := _dob

    // uzmi iz matrice
    _rec["idkonto"] := oRow:Fieldget( oRow:Fieldpos("pkonto"))
    _rec["idroba"] := PADR( oRow:Fieldget( oRow:Fieldpos("idroba")), 10 )
    _rec["barkod"] := PADR( oRow:Fieldget( oRow:Fieldpos("barkod")), 13 )
    _rec["naziv"] := oRow:Fieldget( oRow:Fieldpos("robanaz")) 
    _rec["tarifa"] := oRow:Fieldget( oRow:Fieldpos("idtarifa")) 
    _rec["jmj"] := oRow:Fieldget( oRow:Fieldpos("jmj")) 
    _rec["ulaz"] := oRow:Fieldget( oRow:Fieldpos("ulaz")) 
    _rec["stanje"] := ( _rec["ulaz"] - _rec["izlaz"] )

    dbf_update_rec( _rec )
    
next

MsgC()

return _cnt



// ------------------------------------------------------
// izdvoji prodaju artikala
// ------------------------------------------------------
static function _izdvoji_prodaju( vars )
local _qry := ""
local _date := ""
local _dat_od, _dat_do, _dob, _artikli, _p_konto, _id_firma
local _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _cnt := 0
local _id_roba 

_p_konto := vars["p_konto"]
_dat_od := vars["datum_od"]
_dat_do := vars["datum_do"]
_artikli := vars["artikli"]
_dob := vars["dobavljac"]
_id_firma := gFirma

// datumski uslov
if _dat_od <> CTOD( "" )   
    _date += "kalk.datdok >= " + _sql_quote( _dat_od ) + " "
endif

if _dat_do <> CTOD( "" )
    
    if !EMPTY( _date )
        _date += " AND "
    endif
    
    _date += " kalk.datdok <= " + _sql_quote( _dat_do ) + " "

endif

// sredi upit
if !EMPTY( _date )
    _date := " AND (" + _date + ")"
endif

// sql upit za izlaze:
//
_qry := "SELECT " + ;
   "kalk.pkonto pkonto, " + ;
   "kalk.idroba idroba, " + ;
   "SUM( " + ; 
       "CASE " + ; 
          "WHEN kalk.pu_i = '5' AND kalk.idvd IN ( " + _sql_quote("12") + "," + _sql_quote("13") + " ) THEN -kalk.kolicina " + ;
          "WHEN kalk.pu_i = '5' AND kalk.idvd NOT IN ( " + _sql_quote("12") + "," + _sql_quote("13") + " ) THEN kalk.kolicina " + ;
          "WHEN kalk.idvd = '80' AND kalk.kolicina < 0  THEN -kalk.kolicina " + ;
          "ELSE 0 " + ;
       "END " + ; 
   ") as izlaz " + ;
"FROM fmk.kalk_kalk kalk " + ;
"LEFT JOIN fmk.roba roba ON kalk.idroba = roba.id " + ;
"WHERE " + ; 
   "kalk.idfirma = " + _sql_quote( _id_firma ) + ;  
   " AND kalk.pkonto = " + _sql_quote( _p_konto ) + ; 
   _date + ;
   " AND roba.tip NOT IN ( " + _sql_quote("T") + ", " + _sql_quote("U") + " ) " + ;
"GROUP BY kalk.pkonto, kalk.idroba " + ;
"ORDER BY kalk.idroba" 

MsgO( "Prikupljanje podataka o izlazima robe... sacekajte !" )

_table := _sql_query( _server, _qry )
_table:Refresh()

log_write( _qry, 7 )

// provrti se kroz matricu i azuriraj rezultat u pomocni dbf
for _i := 1 to _table:LastRec()

    ++ _cnt

    oRow := _table:GetRow( _i )

    _id_roba := oRow:Fieldget( oRow:Fieldpos("idroba"))

    select r_export
    set order to tag "roba"
    go top
    seek PADR( _id_roba, 10 )

    if FOUND()

        ++ _cnt 

        _rec := dbf_get_rec()
        _rec["izlaz"] := oRow:Fieldget( oRow:Fieldpos("izlaz"))
        _rec["stanje"] := ( _rec["ulaz"] - _rec["izlaz"]  )
        dbf_update_rec( _rec )
    
    endif
    
next

MsgC()

return _cnt



// ---------------------------------------------------------
// printanje obrasca narudzbe na osnovu podataka
// ---------------------------------------------------------
static function print_frm_asort_nar( vars )
local _my_xml := my_home() + "data.xml"
local _template := "kalk_asort_nar.odt"
local _count := 0

open_xml( _my_xml )
xml_head()

select r_export
set order to tag "roba"
go top

O_PARTN
select partn
hseek r_export->idpartner

select r_export

xml_subnode( "nar", .f. )

// podaci matične firme
xml_node( "firma", to_xml_encoding( gNFirma) )
xml_node( "f_adr", to_xml_encoding( fetch_metric( "org_adresa", nil, "" ) ) )
xml_node( "f_mj", to_xml_encoding( gMjStr ) )
xml_node( "f_tel", to_xml_encoding( fetch_metric( "fakt_zagl_telefon", nil, "" ) ) )
  
// podaci partnera
xml_node( "part_id", to_xml_encoding( hb_utf8tostr( field->idpartner ) ) )
xml_node( "part_naz", to_xml_encoding( hb_utf8tostr( partn->naz ) ) )
xml_node( "part_adr", to_xml_encoding( hb_utf8tostr( partn->adresa ) ) )
xml_node( "part_mj", to_xml_encoding( hb_utf8tostr( partn->mjesto ) ) )
xml_node( "part_ptt", to_xml_encoding( hb_utf8tostr( partn->ptt ) ) )
xml_node( "part_tel", to_xml_encoding( hb_utf8tostr( partn->telefon ) ) )
xml_node( "datum", DTOC( DATE() ) )

do while !EOF()
    
    ++ _count

    xml_subnode( "item", .f. )

    xml_node( "rbr", ALLTRIM(STR( _count ) ) )
    xml_node( "idroba", to_xml_encoding( hb_utf8tostr( field->idroba ) ) )
    xml_node( "barkod", to_xml_encoding( hb_utf8tostr( field->barkod ) ) )
    xml_node( "naziv", to_xml_encoding( hb_utf8tostr( field->naziv ) )  )
    xml_node( "jmj", to_xml_encoding( hb_utf8tostr( field->jmj ) ) )

    xml_subnode( "item", .t. )

    skip

enddo

xml_subnode( "nar", .t. )
close_xml()

if _count > 0
    // pozovi print odt forme
    if f18_odt_generate( _template, _my_xml )
	    // printaj odt
        f18_odt_print()
    endif
endif

return



// ----------------------------------------
// printaj report
// ----------------------------------------
static function print_report( vars )
local _cnt := 0
local _head, _line
local _t_ulaz := 0
local _t_izlaz := 0
local _n_pos := 50
local _nule := vars["nule"]

if RECCOUNT() == 0
    MsgBeep( "Ne postoje trazeni podaci !" )
    return
endif

_head := _get_head()
_line := _get_line()

START PRINT CRET
?

? "SPECIFIKACIJA ASORTIMANA PO DOBAVLJACIMA NA DAN", DTOC( DATE() )
? "Za period od", DTOC( vars["datum_od"]), "do", DTOC(vars["datum_do"])
? "Prodavnicki konto:", vars["p_konto"]

O_KONTO
seek vars["p_konto"]
?? ALLTRIM( konto->naz )

? "Dobavljac:", vars["dobavljac"]

O_PARTN
seek vars["dobavljac"]
?? ALLTRIM( partn->naz )

P_COND

? _line
? _head
? _line

select r_export
set order to tag "roba"
go top

do while !EOF()

    if _nule == "N" .and. ROUND( field->ulaz, 2 ) == 0
        skip
        loop
    endif

    ? PADL( ALLTRIM( STR( ++_cnt ) ), 5 ) + "."

    @ prow(), pcol() + 1 SAY field->idroba
    @ prow(), pcol() + 1 SAY field->barkod
    @ prow(), pcol() + 1 SAY PADR( hb_utf8tostr( field->naziv ), 40 )
    @ prow(), pcol() + 1 SAY field->tarifa
    @ prow(), _n_pos := pcol() + 1 SAY STR( field->ulaz, 12, 2 )
    @ prow(), pcol() + 1 SAY STR( field->izlaz, 12, 2 )
    @ prow(), pcol() + 1 SAY STR( field->stanje, 12, 2 )

    _t_ulaz += field->ulaz
    _t_izlaz += field->izlaz

    skip

enddo

? _line

// ispis totala
? "UKUPNO:"

@ prow(), _n_pos SAY STR( _t_ulaz, 12, 2 )
@ prow(), pcol() + 1 SAY STR( _t_izlaz, 12, 2 )
@ prow(), pcol() + 1 SAY STR( _t_ulaz - _t_izlaz, 12, 2 )

? _line

FF
END PRINT

return


// ----------------------------------------
// vraca header izvjestaja
// ----------------------------------------
static function _get_head()
local _head := ""

_head += PADR( "R.br", 6 )
_head += SPACE(1)
_head += PADR( "Artikal", 10 )
_head += SPACE(1)
_head += PADR( "Barkod", 13 )
_head += SPACE(1)
_head += PADR( "Naziv", 40 )
_head += SPACE(1)
_head += PADR( "Tarifa", 7 )
_head += SPACE(1)
_head += PADR( "Ulazi", 12 )
_head += SPACE(1)
_head += PADR( "Izlazi", 12 )
_head += SPACE(1)
_head += PADR( "Razlika", 12 )

return _head



// ----------------------------------------
// vraca liniju izvjestaja
// ----------------------------------------
static function _get_line()
local _line := ""

_line += REPLICATE("-", 6)
_line += SPACE(1)
_line += REPLICATE("-", 10)
_line += SPACE(1)
_line += REPLICATE("-", 13)
_line += SPACE(1)
_line += REPLICATE("-", 40)
_line += SPACE(1)
_line += REPLICATE("-", 7)
_line += SPACE(1)
_line += REPLICATE("-", 12)
_line += SPACE(1)
_line += REPLICATE("-", 12)
_line += SPACE(1)
_line += REPLICATE("-", 12)

return _line



