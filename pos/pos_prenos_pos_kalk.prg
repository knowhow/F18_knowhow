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


#include "pos.ch"



// -----------------------------------------------------------
// vrati mi vrstu dokumenta za import podataka
// -----------------------------------------------------------
static function _get_vd( tip_dokumenta )
local _ret := "16"

do case
    case tip_dokumenta $ "11#80#81"
        _ret := "16"
    case tip_dokumenta $ "19"
        _ret := "NI"
    case tip_dokumenta $ "IP"
        _ret := "IN"
endcase

return _ret



// ---------------------------------------------------------
// preuzimanje podataka iz modula kalk
// ---------------------------------------------------------
function pos_preuzmi_iz_kalk( tip_dok, br_dok, rs_dbf )
local _imp_table := ""
local _destination := ""
local _br_dok
local _val_otpremnica 
local _val_zaduzenje
local _val_inventura
local _val_nivelacija
local _id_pos, _prodajno_mjesto

_id_pos := gIdPos
_prodajno_mjesto := SPACE(2)
_val_otpremnica := "95"
_val_zaduzenje := "11#12#13#80#81"
_val_inventura := "IP"
_val_nivelacija := "19"

_destination := ALLTRIM( gKalkDest )

SET CURSOR ON
O_PRIPRZ

_br_dok := SPACE( LEN( field->brdok ) )

if priprz->( RecCount2() ) == 0 .and. Pitanje( , "Preuzeti dokumente iz KALK-a", "N" ) == "N"
    return .f.
endif

// odaberi fajl za import
if !get_import_file( _br_dok, @_destination, @_imp_table )
    return .f.
endif

// _imp_table u nasem slucaju sadrzi i putanju i naziv fajla
//
// otvori katops datoteku

select ( F_TMP_KATOPS )
my_use_temp( "KATOPS", _imp_table )

// daj mi vrstu dokumenta koju cu importovati
_id_tip_dok := _get_vd( katops->idvd )
// setuj varijablu tipa dokumenta
tip_dok := _id_tip_dok
   
select pos_doks
set order to tag "1"
    
// nadji sljedeci broj TOPS dokumenta
_br_dok := pos_novi_broj_dokumenta( _id_pos, tip_dok )
br_dok := _br_dok
  
select katops
go top
        
MsgO( "kalk -> priprema, update roba ")

do while !EOF()
    if ( katops->idpos == _id_pos )
        if ( import_row( _id_tip_dok, _br_dok, "" ) == 0 )
            exit
        endif
    endif
    select katops
    skip
enddo

select katops
use
    
MsgC()

// pobrisi fajl importa nakon što smo ga importovali
_brisi_fajlove_importa( _imp_table )

return .t.


// ----------------------------------------------
// brisi fajlove importa
// ----------------------------------------------
static function _brisi_fajlove_importa( import_file )
        
// samo pobrisi fajl prenosa
FileDelete( import_file )
// i txt fajl
FileDelete(strtran( import_file, ".dbf", ".txt"))

return

 
// -----------------------------------------------
// katops -> priprz
// ----------------------------------------------   
static function import_row( id_vd, br_dok, id_odj )
local _t_area := SELECT()

// tabela PRIPRZ = "priprema zaduzenja"
select priprz
append blank

replace idroba with katops->idroba
replace cijena with katops->mpc

replace kolicina with katops->kolicina

// nivelacija...
if id_vd == "NI"
    replace ncijena with katops->mpc2
endif

// inventura...
if id_vd == "IN"
    // kod inventure su ove stvari obrnute
    replace kolicina with katops->kol2 
    replace kol2 with katops->kolicina
endif

replace idtarifa with katops->idtarifa
replace jmj with katops->jmj
replace robanaz with katops->naziv
replace k1 with katops->k1
replace k2 with katops->k2
replace k7 with katops->k7
replace k8 with katops->k8
replace k9 with katops->k9
replace n1 with katops->n1
replace n2 with katops->n2
replace barkod with katops->barkod
replace PREBACEN with OBR_NIJE
replace IDRADNIK with gIdRadnik
replace IdPos with KATOPS->IdPos
replace IdOdj WITH id_odj
replace IdVd WITH id_vd
replace Smjena WITH gSmjena 
replace BrDok with br_dok
replace DATUM with gDatum

select ( _t_area )

return 1


// -----------------------------------------------
// odaberi - setuj ime kalk dbf-a
// -----------------------------------------------
static function get_import_file( br_dok, destinacija, import_fajl )
local _filter
local _prodajno_mjesto, _id_pos, _prefix
local _imp_files := {}
local _opc := {}
local _h, _i
local _izbor
local _prenesi 

if gMultiPM == "D"

    _filter := 2
    _prodajno_mjesto := GetPm( gIdPos )

    if !EMPTY( _prodajno_mjesto )
        _id_pos := _prodajno_mjesto
        _prefix := ( TRIM( _prodajno_mjesto ) ) + SLASH
    else
        _prefix := ""
    endif

    destinacija := ALLTRIM( gKalkDest ) + _prefix
    
    // pobrisi fajlove starije od 7 dana
    BrisiSFajlove( destinacija )

    _imp_files := DIRECTORY( destinacija + "kt*.dbf" )

    ASORT( _imp_files,,,{|x,y| DTOS(x[3]) + x[4] > DTOS(y[3]) + y[4] })   
    // datum + vrijeme
    // KT0512.DBF = elem[1]
        
    AEVAL( _imp_files, {|elem| AADD( _opc, PADR( elem[1], 15 ) + UChkPostoji() + " " + DTOC( elem[3] ) + " " + elem[4] ) }, 1 )
    
    // datum + vrijeme
    ASORT( _opc,,,{|x,y| RIGHT(x,17) > RIGHT(y,17)})  
    
    _h := ARRAY( LEN( _opc ) )
    for _i := 1 to LEN(_h)
        _h[_i]:=""
    next

    // elem 3 - datum
    // elem 4 - time

    if LEN( _opc ) == 0
        MsgBeep("U direktoriju za prenos nema podataka")
        close all
        return .f.
    endif

else    
    MsgBeep ("Pripremi disketu za prenos ....#te pritisni neku tipku za nastavak!!!")
endif

if gMultiPM == "D"
    
    // CITANJE
    _izbor := 1
    _prenesi := .f.
    do while .t.
        _izbor := Menu("k2p", _opc, _izbor, .f.)
        if _izbor == 0
            exit
        else
            import_fajl := TRIM( destinacija ) + TRIM( LEFT( _opc[ _izbor ], 15 ) )
            //SAVE SCREEN TO _screen
            //Vidifajl(strtran(cKalkDBF,".DBF",".TXT"))  // vidi TK1109.TXT
            //RESTORE SCREEN FROM _screen
            if Pitanje(,"Zelite li izvrsiti prenos ?","D")=="D"
                _prenesi:=.t.
                _izbor := 0
            endif
        endif
    enddo
    
    if !_prenesi
        return .f.
    endif
    
else    
    
    // nije modemska veza
    // ako nije modemska veza
    import_fajl := TRIM( destinacija ) + "katops.dbf"
    _a_tmp1 := IscitajCRC( TRIM( destinacija ) + "crckt.crc" )
    _a_tmp2 := IntegDbf( imp_fajl )

    if !( _a_tmp1[1] == _a_tmp2[1] .and. _a_tmp1[2] == _a_tmp2[2] )
        MsgBeep("CRC se ne slaze")
        if Pitanje(, "Ipak zelite prenos (D/N)?", "N") == "N"
            return .f.
        endif
    endif

endif

return .t.


// -----------------------------------------
// vrati prodajno mjesto
// -----------------------------------------
static function GetPm( id_pos )
local _pm

_pm := ALLTRIM( id_pos )

return _pm




/*! \fn AutoRek2Kalk(cDate1, cDate2)
 *  \brief APPSRV prenos rek2kalk 
 *  \param cDate1 - datum od
 *  \param cDate2 - datum do
 */
function AutoRek2Kalk(cDate1, cDate2)
*{
local dD1
local dD2
local nD1
local nD2

// inicijalizuj port za stampu i sekvence stampaca (EPSON)
// radi globalnih varijabli
private gPPort:="8"
set_epson_print_codes()

nD1 := LEN(cDate1)
nD2 := LEN(cDate2)

if ((nD1 < 10) .or. (nD2 < 10))
    ? "FORMAT DATUMA NEISPRAVAN...."
    ? "ISPRAVAN FORMAT, PRIMJER: 01.01.2005"
    Sleep(5)
    return
endif

if (!Empty(cDate1) .and. !Empty(cDate2))
    dD1 := CToD(cDate1)
    dD2 := CToD(cDate2)
    ? "Vrsim prenos reklamacija za datum od: " + DToC(dD1) + " do " + DToC(dD2)
    pos_prenos_pos_kalk(dD1, dD2)
    ? "Izvrsen prenos ..."
    Sleep(1)
endif

return
*}



/*! \fn AutoReal2Kalk(cDate1, cDate2)
 *  \brief APPSRV prenos real2kalk 
 *  \param cDate1 - datum od
 *  \param cDate2 - datum do
 */
function AutoReal2Kalk(cDate1, cDate2)
*{
local dD1
local dD2
local nD1
local nD2

// inicijalizuj port za stampu i sekvence stampaca (EPSON)
// radi globalnih varijabli
private gPPort:="8"
set_epson_print_codes()

nD1 := LEN(cDate1)
nD2 := LEN(cDate2)

if ((nD1 < 10) .or. (nD2 < 10))
    ? "FORMAT DATUMA NEISPRAVAN...."
    ? "ISPRAVAN FORMAT, PRIMJER: 01.01.2005"
    Sleep(5)
    return
endif

if (!Empty(cDate1) .and. !Empty(cDate2))
    dD1 := CToD(cDate1)
    dD2 := CToD(cDate2)
    ? "Vrsim prenos realizacija za datum od: " + DToC(dD1) + " do " + DToC(dD2)
    // pozovi f-ju Real2Kalk() sa argumentima
    pos_prenos_pos_kalk(dD1, dD2)
    ? "Izvrsen prenos ..."
    Sleep(1)
endif

return


// -------------------------------------------------------------------
// otvori tabele za prenos podataka
// -------------------------------------------------------------------
static function _o_real_table()
O_ROBA
O_KASE
O_POS
O_POS_DOKS
return



// -------------------------------------------------------------------
// prenos popisa robe za kalk
// -------------------------------------------------------------------
function pos_prenos_inv_2_kalk( id_pos, id_vd, dat_dok, br_dok )
local _r_br, _rec
local _kol
local _iznos
local _t_area := SELECT()
local _count

// ako nije inventura onda nemoj nista raditi...
if id_vd <> VD_INV
    return
endif

// napravi pom tabelu
_cre_pom_table()

// otvori opet tabele jer je indeks gore zatvorio
_o_real_table()

select pos_doks
set order to tag "1"  
// IdVd+DTOS (Datum)+Smjena
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if !FOUND()
    MsgBeep( "Dokument: " + id_pos + "-" + id_vd + "-" + PADL( br_dok, 6 ) + " ne postoji !" )
    return
endif

_r_br := 0
_kol := 0
_iznos := 0

select pos
set order to tag "1"
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if !FOUND()
    MsgBeep( "POS tabela nema stavki !" )
    select ( _t_area )
    return
endif

MsgO( "Eksport dokumenta u toku ..." )

do while !EOF() .and. field->idpos == id_pos .and. field->idvd == id_vd .and. ;
                    field->datum == dat_dok .and. field->brdok == br_dok 
   
    _id_roba := field->idroba

    select roba
    hseek _id_roba
 
    select pom
    append blank

    _rec := dbf_get_rec()

    _rec["idpos"] := pos->idpos
    _rec["idvd"] := pos->idvd
    _rec["datum"] := pos->datum
    _rec["brdok"] := pos->brdok
    _rec["kolicina"] := pos->kolicina
    _rec["idroba"] := pos->idroba
    _rec["idtarifa"] := pos->idtarifa
    _rec["kol2"] := pos->kol2
    _rec["mpc"] := pos->cijena
    _rec["stmpc"] := pos->ncijena
    _rec["barkod"] := roba->barkod
    _rec["robanaz"] := roba->naz
    _rec["jmj"] := roba->jmj
    
    dbf_update_rec( _rec )
 
    ++ _r_br

    select pos
    skip

enddo

MsgC()

if _r_br == 0
    MsgBeep( "Ne postoji niti jedna stavka u eksport tabeli !" )
    select ( _t_area )
    return
endif

select pom
use

if gMultiPM == "D"

	_file := _cre_topska_multi( id_pos, dat_dok, dat_dok, id_vd, "tk_p" )

    MsgBeep( "Kreiran fajl " + _file + "#broj stavki: " + ALLTRIM(STR( _r_br )) )	

endif

select ( _t_area )

return




// --------------------------------------------------------------------
// prenos podataka za modul kalk
// --------------------------------------------------------------------
function pos_prenos_pos_kalk( dDateOd, dDateDo, cIdVd, id_pm )
local _usl_roba := SPACE(150)
local _usl_mark := "U"
local aPom := {}
local i
local _r_br
local cIdPos := gIdPos
local _dat_od, _dat_do, _file
local _tmp
local _auto_prenos := .f.

if id_pm <> NIL
    _auto_prenos := .t.
endif

// ako je nil onda se radi o realizaciji
if ( cIdVd == NIL )
    cIdVd := "42"
endif

if (( dDateOd == NIL ) .and. ( dDateDo == NIL ))
    _dat_od := DATE()
    _dat_do := DATE()
else
    _dat_od := dDateOd
    _dat_do := dDateDo
endif

_o_real_table()

SET CURSOR ON

if !_auto_prenos
    
    Box(, 4, 70, .f., " PRENOS REALIZACIJE POS->KALK   " )
        
	@ m_x+1,m_y+2 SAY "Prodajno mjesto " GET cIdPos pict "@!" Valid !EMPTY(cIdPos) .or. P_Kase(@cIdPos,5,20)
    @ m_x+2,m_y+2 SAY "Prenos za period" GET _dat_od
    @ m_x+2,col()+2 SAY "-" GET _dat_do
    @ m_x+3,m_y+2 SAY "Uslov po artiklima:" GET _usl_roba PICT "@S40"
    @ m_x+4,m_y+2 SAY "Artikle (U)kljuci / (I)skljuci iz prenosa:" GET _usl_mark PICT "@!" VALID _usl_mark $ "UI"
    
	READ
   	ESC_BCR

    BoxC()

else
    cIdPos := id_pm
endif

gIdPos := cIdPos

// napravi pom tabelu
_cre_pom_table()
// otvori opet tabele jer je indeks gore zatvorio
_o_real_table()

select pos_doks
set order to tag "2"  
// IdVd+DTOS (Datum)+Smjena
go top
seek cIdVd + DTOS( _dat_od )

EOF CRET

_r_br := 0
_kol := 0
_iznos := 0

if !EMPTY( _usl_roba ) .and. RIGHT( ALLTRIM( _usl_roba ) ) <> ";"
     _usl_roba := ALLTRIM( _usl_roba ) + ";"
endif  

do while !eof() .and. pos_doks->IdVd == cIdVd .and. pos_doks->Datum <= _dat_do
    
    if !EMPTY(cIdPos) .and. pos_doks->IdPos <> cIdPos
        SKIP
        LOOP
    endif
    
    select pos
    seek pos_doks->( IdPos + IdVd + DTOS( datum ) + BrDok )
    
    do while !EOF() .and. pos->( IdPos + IdVd + DTOS( datum ) + Brdok) == pos_doks->( IdPos + IdVd + DTOS( datum ) + BrDok )
                
        // uslov po robi
        if !EMPTY( _usl_roba )
            // parsiraj uslov...
            _tmp := Parsiraj( _usl_roba, "idroba" )
            // ako je tacno !
            if &_tmp
                
                if _usl_mark == "I"
                    // ako iskljucujes, onda preskoci
                    skip
                    loop
                endif
            
            else
                // ako treba da je ukljucena roba
                if _usl_mark == "U"
                    skip
                    loop
                endif
            endif
        endif
        
        // uzmi i barkod
        select roba
        set order to tag "ID"
        hseek pos->idroba
        
        select pom
        set order to tag "1"
        go top
        seek pos->idpos + pos->idroba + STR( pos->cijena, 13, 4 ) + STR( pos->ncijena, 13, 4 )

		_kol += pos->kolicina
		_iznos += ( pos->kolicina * pos->cijena )
            
		// seekuj i cijenu i popust (koji je pohranjen u ncijena)
        if !FOUND() .or. IdTarifa <> POS->IdTarifa .or. MPC <> POS->Cijena
            
			append blank
                
            replace IdPos WITH POS->IdPos
            replace IdRoba WITH POS->IdRoba
            replace Kolicina WITH POS->Kolicina
            replace IdTarifa WITH POS->IdTarifa
            replace mpc With POS->Cijena
            replace IdCijena WITH POS->IdCijena
            replace Datum WITH _dat_do
            replace DatPos with pos->datum
            replace brdok with pos->brdok
            replace idvd with POS->IdVd
            replace StMPC WITH pos->ncijena
            replace barkod with roba->barkod
            replace robanaz with roba->naz

            if !EMPTY(pos_doks->idgost)
                replace idpartner with pos_doks->idgost
            endif
                        
            ++ _r_br
      	else

            _rec := dbf_get_rec()
            _rec["kolicina"] := _rec["kolicina"] + pos->kolicina
            dbf_update_rec( _rec )

        endif
                
        select pos
        skip

    enddo

    select pos_doks
    skip

enddo

// zatvori pom
select pom
use

close all

if !_auto_prenos

    // printaj report o prenosu
    _print_report( _dat_od, _dat_do, _kol, _iznos, _r_br )

    if gMultiPM == "D"
	    _file := _cre_topska_multi( cIdPos, _dat_od, _dat_do, cIdVd )
    else
	    _file := _cre_topska()
    endif

    MsgBeep( "Kreiran fajl " + _file + "#broj stavki: " + ALLTRIM(STR( _r_br )) )

endif

return


// -------------------------------------------------------------------------------------
// printanje reporta nakon prenosa
// -------------------------------------------------------------------------------------
static function _print_report( datum_od, datum_do, kolicina, iznos, broj_stavki )

START PRINT CRET

?
? "PRENOS PODATAKA TOPS->KALK za ", DTOC( DATE() )
?
? "Datumski period od", DTOC( datum_od ), "do", DTOC( datum_do )
? "Broj stavki:", ALLTRIM( STR( broj_stavki ) )
? 
? "Ukupna kolicina:", ALLTRIM( STR( kolicina, 12, 2 ) )
? "  U kupan iznos:", ALLTRIM( STR( iznos, 12, 2 ) )

FF
END PRINT

return


// -------------------------------------------------------------
// napravi pom tabelu
// -------------------------------------------------------------
static function _cre_pom_table()
local aDbf:={}

AADD(aDBF,{"IdPos",    "C",   2, 0})
AADD(aDBF,{"IDROBA",   "C",  10, 0})
AADD(aDBF,{"ROBANAZ",  "C", 250, 0})
AADD(aDBF,{"kolicina", "N",  13, 4})
AADD(aDBF,{"kol2",     "N",  13, 4})
AADD(aDBF,{"MPC",      "N",  13, 4})
AADD(aDBF,{"STMPC",    "N",  13, 4})
AADD(aDBF,{"IDTARIFA", "C",   6, 0})
AADD(aDBF,{"IDCIJENA", "C",   1, 0})
AADD(aDBF,{"IDPARTNER","C",  10, 0})
AADD(aDBF,{"DATUM",    "D",   8, 0})
AADD(aDBF,{"DATPOS",   "D",   8, 0})
AADD(aDBF,{"IdVd",     "C",   2, 0})
AADD(aDBF,{"BRDOK",    "C",  10, 0})
AADD(aDBF,{"M1",       "C",   1, 0})
AADD(aDBF,{"BARKOD",   "C",  13, 0})
AADD(aDBF,{"JMJ",      "C",   3, 0})

select pos_doks

NaprPom( aDbf )

select ( F_POM )
if used()
	USE
endif

my_use_temp( "POM", my_home() + "pom", .f., .t. )

index on ( idpos + idroba + STR( mpc, 13, 4 ) + STR( stmpc, 13, 4) ) tag "1"

SET ORDER TO TAG "1"

return




// --------------------------------------------------------------------------
// kreira izlazni fajl za multi prodajna mjesta režim
// --------------------------------------------------------------------------
static function _cre_topska_multi( id_pos, datum_od, datum_do, v_dok, prefix )
local _prefix := "tk"
local _export_location
local _table_name
local _table_path
local _dest_file := ""
local _bytes := 0

if prefix != NIL
    _prefix := prefix
endif

if RIGHT( ALLTRIM( gKalkDest ) , 1 ) <> SLASH
    gKalkDest := ALLTRIM( gKalkDest ) + SLASH
endif

// napravi direktorij prenosa ako ga nema !
_dir_create( ALLTRIM( gKalkDest ) )

// prodajno mjesto je ?
_id_pm := GetPm( id_pos )

_export_location := ALLTRIM( gKalkDest) + _id_pm + SLASH 

// napravi i ovaj direktorij ako ne postoji
_dir_create( ALLTRIM( _export_location ) )

// nakon kreiranja direktorija prebaci se u lokalni folder
DirChange( my_home() )

// "tk1203"
_table_name := get_topskalk_export_file( "1", _export_location, datum_do, prefix ) 
    
_dest_file := _export_location + _table_name + ".dbf"

// kopiraj pom u fajl koji treba    
if FileCopy( my_home() + "pom.dbf", _dest_file ) > 0
    FileCopy( my_home() + OUTF_FILE, STRTRAN( _dest_file, ".dbf", ".txt" ) )
else
    MsgBeep( "Problem sa kopiranjem fajla na lokaciju #" + _export_location )
endif
 
//if !FILE( _dest_file )
//    MsgBeep("Eksport fajl ne postoji na lokaciji !!!")
//endif

return _dest_file



// -----------------------------------------------------------
// kreira topska za jednu instancu
// -----------------------------------------------------------
static function _cre_topska()
local _dbf
local _destination

_destination := ALLTRIM( gKalkDest ) + "topska.dbf"
    
_dbf := IntegDbf( _destination )
NapraviCRC( ALLTRIM( gKalkDEST ) + "crctk.crc" , _dbf[1] , _dbf[2] )
        

return _destination
   
   

