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


#include "fakt.ch"

function fakt_admin_menu()
local _opc := {}
local _opcexe := {}
local _izbor := 1

AADD( _opc, "1. regeneracija fakt memo polja                     ")
AADD( _opcexe, {|| fa_memo_regen() } )
AADD( _opc, "2. regeneracija polja fakt->rbr")
AADD( _opcexe, {|| fa_rbr_regen() } )
AADD( _opc, "3. konverzija fakt_fakt/fakt_doks polja" )
AADD( _opcexe, {|| fakt_konvert_doks_fakt() } )
AADD( _opc, "4. regeneracija doks iznos ukupno")
AADD( _opcexe, {|| do_uk_regen() } )
AADD( _opc, "5. kontrola duplih partnera")
AADD( _opcexe, {|| chk_dpartn() } )
AADD( _opc, "6. podesavanje brojaca dokumenta ")
AADD( _opcexe, {|| fakt_set_param_broj_dokumenta() } )
AADD( _opc, "E. fakt export (r_exp) ")
AADD( _opcexe, {|| fkt_export() } )
AADD( _opc, "U. pretvaranje otpremnica - unlock ")
AADD( _opcexe, {|| fakt_otpremnice_pretvaranje_unlock() } )
AADD( _opc, "------------ T E S T O V I ------------------")
AADD( _opcexe, {|| fakt_otpremnice_pretvaranje_unlock() } )

f18_menu("fain", .f., _izbor, _opc, _opcexe )

return



static function fakt_otpremnice_pretvaranje_unlock()
local _param := "fakt_otpremnice_lock_user"

// ukini lock funkcije pretvaranja...
if !EMPTY( ALLTRIM( fetch_metric( _param, NIL, "" ) ) )
    set_metric( _param, NIL, "" )
    MsgBeep( "Napravio unlock opcije pretvaranja otpremnica !!!" )
else
    MsgBeep( "Opcija se slobodno moze koristiti !!!" )
endif

return .t.



// regeneracija rednih brojeva u tabeli fakt
static function fa_rbr_regen()
local nCounter
local cOldRbr
local cNewRbr
local nTotRecord
local _rec

if !SigmaSif("RBRREG")
    return
endif

if Pitanje(,"Izvrsiti regeneraciju rednih brojeva (D/N)","N") == "N"
    return
endif

O_FAKT

select fakt
set order to tag 0

Box(, 3,60)
@ m_x+1, m_y+2 SAY "Vrsim regeneraciju rednih brojeva fakt..."

nCounter := 0
nTotRecord := RecCount()

@ m_x+2, m_y+2 SAY "ukupni broj zapisa: " + ALLTRIM(STR(nTotRecord)) 

do while !EOF()

    cOldRbr := field->rbr
    cNewRbr := PADL(ALLTRIM(cOldRbr), 3)

    _rec := dbf_get_rec()
    _rec["rbr"] := cNewRbr

    update_rec_server_and_dbf( "fakt_fakt", 1, _rec, "FULL")

    ++nCounter

    @ m_x+3, m_y+2 SAY "obradjeno zapisa: " + ALLTRIM(STR(nCounter))
    
    skip
enddo

BoxC()

return


// --------------------------------------------------
// regeneracija polja ukupno u tabeli doks
// --------------------------------------------------
static function do_uk_regen()
local cD_firma
local cD_tdok
local cD_brdok
local nCounter
local nCnt
local i
local aTest := {}
local nTotal
local nRabat
local nStavka
local nStRabat
local nStPorez
local _rec

O_FAKT
O_FAKT_DOKS

if !SigmaSif("REGEN")
    return 
endif

if Pitanje(,"Izvrsiti regeneraciju (D/N)?","N") == "N"
    return
endif

select fakt_doks
set order to tag "1"
go top

nCounter := 0

Box(,3, 60)

@ 1 + m_x, 2 + m_y SAY "popunjavanje polja u toku..."

do while !EOF()
    
    cD_firma := field->idfirma
    cD_tdok := field->idtipdok
    cD_brdok := field->brdok

    // trenutno nam treba samo za dokumente "20"
    if cD_tdok <> "20" .and. cD_tdok <> "10"
        skip
        loop
    endif

    select fakt
    set order to tag "1"
    go top
    seek ( cD_firma + cD_tdok + cD_brdok )

    nTotal := 0
    nRabat := 0
    nStavka := 0
    nStPorez := 0
    nStRabat := 0

    do while !EOF() .and. field->idfirma + field->idtipdok + ;
        field->brdok == cD_firma + cD_tdok + cD_brdok
    
        // ukini polje poreza
        if field->porez <> 0
            replace field->porez with 0
        endif

            if field->dindem == LEFT(ValBazna(), 3)
                
            nStavka := Round( field->kolicina * ;
                field->cijena * PrerCij() * ;
                (1 - field->Rabat/100), ZAOKRUZENJE )
            
            // rabat
                nStRabat := ROUND( field->kolicina * ;
                field->cijena * PrerCij() * ;
                (field->rabat / 100), ZAOKRUZENJE)
                
            // porez
                nStPorez := ROUND( nStavka * (field->porez / 100), ;
                ZAOKRUZENJE )

            nTotal += nStavka + nStPorez
            nRabat += nStRabat
            else
                
            nStavka := round( field->kolicina * ;
                field->cijena * ;
                (PrerCij() / UBaznuValutu(datdok)) * ;
                (1-field->Rabat/100), ZAOKRUZENJE)
                
            // rabat
                nStRabat := ROUND( field->kolicina * ;
                field->cijena * ;
                ( PrerCij() / UBaznuValutu(datdok)) * ;
                (field->Rabat/100), ZAOKRUZENJE)
                // porez
                nStPorez := ROUND(nStavka * ;
                (field->porez/100), ZAOKRUZENJE)
                
            nTotal += nStavka + nStPorez
                nRabat += nStRabat

            endif
            skip
    enddo
  
    select fakt_doks

    // ubaci u tabelu doks ako je iznos razlicit
    if ROUND(field->iznos, ZAOKRUZENJE) <> ROUND(nTotal, ZAOKRUZENJE)
        // dodaj u kontrolnu matricu
        AADD( aTest, { field->idfirma + "-" + ;
                field->idtipdok + "-" + ;
                ALLTRIM(field->brdok), ;
                field->iznos, ;
                nTotal } )

        _rec := dbf_get_rec()
        _rec["iznos"] := nTotal
        _rec["rabat"] := nRabat
        update_rec_server_and_dbf( "fakt_doks", 1, _rec, "FULL")
    endif

    ++nCounter

    @ 3+m_x, 2+m_y SAY "odradjeno zapisa " + ALLTRIM(STR(nCounter)) 

    skip

enddo

BoxC()

if LEN( aTest ) > 0
    // daj mi info o zamjenjenim iznosima
    START PRINT CRET
    
    ? "Iznosi zamjenjeni na sljedecim dokumentima:"
    ? "--------------------------------------------------------"
    
    nCnt := 1

    for i := 1 to LEN( aTest )
        ? PADL( ALLTRIM( STR(nCnt) ), 5) + ".", ;
            aTest[i, 1], ;
            ROUND( aTest[i, 2], ZAOKRUZENJE), ;
            "=>", ;
            ROUND( aTest[i, 3], ZAOKRUZENJE)
        ++ nCnt
    next

    FF
    END PRINT
endif

return



// --------------------------------------------------
// generisanje podataka za polja dat_isp, dat_otpr
// konverzija polja idrnal -> memo (objekat_id)
// --------------------------------------------------
static function fakt_konvert_doks_fakt()
local _r_br, _id_rad_nal
local _memo, _update_doks, _update_fakt
local _count, _id_firma, _tip_dok, _br_dok
local _rec_fakt, _rec_doks
local _x := 1
local _regen_dat := "N"
local _regen_objekat_id := "N"
local _regen_dok_veze := "N"

if !SigmaSif("REGEN")
    return 
endif

Box(, 7, 60 )

    @ m_x + _x, m_y + 2 SAY "Regeneracija fakt podataka *****" 
    ++ _x

     read_dn_parametar("Regeneracija datuma otpreme", m_x + _x, m_y + 2, @_regen_dat)
     ++ _x

     read_dn_parametar("fakt.idrnal -> fakt.txt (objekat id)", m_x + _x, m_y + 2, @_regen_objekat_id)
     ++ _x

     read_dn_parametar("fakt_doks.dok_veza -> fakt.txt (fakt_dok_veze)", m_x + _x, m_y + 2, @_regen_dok_veze)
     read

BoxC()

// zadnja sansa za izlazak iz opcije
if LastKey() == K_ESC .or. Pitanje(, "Izvrsiti regeneraciju/konverziju podataka (D/N) ?","N" ) == "N"
    return
endif

O_FAKT
O_FAKT_DOKS

select fakt_doks
set order to tag "1"
go top

_count := 0

if !f18_lock_tables( { "fakt_fakt", "fakt_doks" } )

    // neko je zauzeo...

    select ( F_FAKT )
    use

    select ( F_FAKT_DOKS )
    use

    return

endif
   
//--------
sql_table_update( nil, "BEGIN" )

Box(, 3, 60 )

@ m_x + 1, m_y + 2 SAY "konverzija u toku..."

do while !EOF()

    _update_doks := .f.
    _update_fakt := .f.

    _id_firma := field->idfirma
    _tip_dok := field->idtipdok
    _br_dok := field->brdok

    select fakt
    set order to tag "1"
    go top
    seek ( _id_firma + _tip_dok + _br_dok + "  1" )

    if !FOUND()
        select fakt_doks
        skip
        loop
    endif

    _rec_fakt := dbf_get_rec()
    _memo := ParsMemo( field->txt )

    select fakt_doks
    _rec_doks := dbf_get_rec()

    if _regen_dat == "D"
        _update_doks := .t.
        _rec_doks["dat_otpr"] := IIF( LEN( _memo ) >= 7, CTOD( _memo[7] ), CTOD("") )
        _rec_doks["dat_isp"] := IIF( LEN( _memo ) >= 7, CTOD( _memo[7] ), CTOD("") )
        _rec_doks["dat_val"] := IIF( LEN( _memo ) >= 9, CTOD( _memo[9] ), CTOD("") )

    endif

    if _regen_objekat_id == "D"
            _update_fakt := .t.
            _memo[20] := PADR( fakt->idrnal, 10 )
            // pripremi mi sada txt polje
            _rec_fakt["txt"] := fakt_memo_field_to_txt( _memo )
    endif

    if _regen_dok_veze == "D"
            _update_fakt := .t.
            _memo[19] := PADR( fakt_doks->dok_veza, 150)
            // pripremi mi sada txt polje
            _rec_fakt["txt"] := fakt_memo_field_to_txt( _memo )
    endif


    // napravi update zapisa fakt_doks
    if _update_doks
        update_rec_server_and_dbf( "fakt_doks", _rec_doks, 1, "CONT" )
    endif

    // napravi update zapisa fakt_fakt
    if _update_fakt
        select fakt
        update_rec_server_and_dbf( "fakt_fakt", _rec_fakt, 1, "CONT" )
        select fakt_doks
    endif

    ++ _count

    @ m_x + 3, m_y + 2 SAY "odradjeno zapisa " + ALLTRIM( STR( _count ) ) 

    skip

enddo

f18_free_tables( { "fakt_fakt", "fakt_doks" } )

sql_table_update( nil, "END" )

BoxC()

return


// ---------------------------------------
// regeneracija polja FAKT-TXT
// ---------------------------------------
static function fa_memo_regen()
local cRbr
local cPartn
local dDatPl

if !SigmaSif("MEMREG")
    return 
endif

if Pitanje(,"Izvrsiti regeneraciju (D/N)?","N") == "N"
    return
endif

O_FAKT
O_FAKT_DOKS
O_PARTN

select fakt
set order to tag "1"
go top

// interesuju nas samo prvi zapisi pod rbr = '  1'
cRbr := PADL("1", 3)
nCounter:=0

Box(,3, 60)
@ 1+m_x, 2+m_y SAY "regeneracija memo polja u toku..."

do while !EOF()
    
    // provjeri prvo polje rbr
    if ( field->rbr <> cRbr )
        skip
        loop
    endif
    
    // provjeri i LEN txt polja, ako je > 10 onda je ok
    if LEN(field->txt) > 10
        skip
        loop
    endif
    
    cPartn := fakt->idpartner
    dDatDok := fakt->datdok
    
    // pozicioniraj se na partnera
    select partn
    hseek cPartn

    // prebaci se na doks radi datuma placanja
    select fakt_doks
    set order to tag "1"
    hseek fakt->idfirma + fakt->idtipdok + fakt->brdok
    dDatPl := fakt_doks->datpl
    
    select fakt
    
    // odradi regeneraciju polja
    _rec := dbf_get_rec()

    // roba // ovo je za roba U
    _txt := Chr(16) + Chr(17)
        // dodatni tekst fakture // nemamo ga
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + ALLTRIM(partn->naz) + Chr(17)
    _txt += Chr(16) + ALLTRIM(partn->adresa) + ", Tel:" + ALLTRIM(partn->telefon) + Chr(17) 
    _txt += Chr(16) + ALLTRIM(partn->ptt) + " " + ALLTRIM(partn->mjesto) + Chr(17)
        // broj otpremnice - nemamo ga
    _txt += Chr(16) + Chr(17) 
        // datum otpremnice
    _txt += Chr(16) + DToC(dDatDok) + Chr(17)
        // broj narudzbenice - nemamo ga
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + DToC(dDatPl) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    _txt += Chr(16) + Chr(17)
    
    _rec["txt"] := _txt

    update_rec_server_and_dbf( "fakt_fakt", 1, _rec, "FULL" )
    
    ++nCounter

    @ 3+m_x, 2+m_y SAY "odradjeno zapisa " + ALLTRIM(STR(nCounter)) 

    skip

enddo

BoxC()

return


// ------------------------------------------------------------
// regeneracija / popunjavanje polja idpartner u tabeli fakt
// ------------------------------------------------------------
static function fa_part_regen()
local nCount
local cIdFirma
local cIdTipDok
local cBrDok
local cPartn
local cMsg
local lFaktOverwrite := .f.

if !SigmaSif("PARREG")
    return
endif

cMsg := "Prije pokretanja ove opcije#!!! OBAVEZNO !!! napraviti backup podataka"

msgbeep(cMsg)

if Pitanje(,"Izvrsiti popunjavanje partnera u dokumentima (D/N)","N") == "N"
    return
endif


if Pitanje(,"Prepisati vrijednosti u tabeli FAKT (D/N)", "N") == "D"
    lFaktOverwrite := .t.
endif

O_FAKT_DOKS
O_FAKT

select fakt
set order to tag "1"
go top

Box(,3,60)

@ m_x+1, m_y+2 SAY "Vrsim popunjavanje partnera..."

nCount := 0

do while !EOF()
    
    cIdFirma := field->idfirma
    cIdTipDok := field->idtipdok
    cBrDok := field->brdok
    cPartn := field->idpartner

    if lFaktOverwrite == .t. .or. EMPTY( cPartn )
        
        // pokusaj naci u DOKS
        select fakt_doks
        set order to tag "1"
        seek cIdFirma + cIdTipDok + cBrDok

        if FOUND()
            if !EMPTY( field->idpartner )
                
                cPartn := field->idpartner
            
                @ m_x+2, m_y+2 SAY "*** uzeo iz DOKS -> " + cPartn
    
            endif
        endif
            
        select fakt
            
    endif

    do while !EOF() .and. field->idfirma == cIdFirma ;
            .and. field->idtipdok == cIdTipDok ;
            .and. field->brdok == cBrDok
    
        
        if (lFaktOverwrite == .t. .or. EMPTY( field->idpartner )) .and. !EMPTY( cPartn )
        
            ++ nCount
        
            _rec := dbf_get_rec()
            _rec["idpartner"] := cPartn
            update_rec_server_and_dbf( "fakt_fakt", 1, _rec, "FULL" )   

            @ m_x+3, m_y+2 SAY "dok-> " + cIdFirma + "-" + ;
                cIdTipDok + "-" + ALLTRIM(cBrDok)
    
        endif
        
        skip
    enddo
    
enddo

BoxC()

if nCount > 0
    msgbeep("Odradjeno " + ALLTRIM(STR(nCount)) + " zapisa !")
endif

return


// -----------------------------------------------------
// provjera duplih partnera u sifrarniku partnera
// -----------------------------------------------------
function chk_dpartn()
local cId
local cPNaz
local aPartn := {}

O_FAKT_DOKS
O_PARTN
select partn
go top

Box(,1,50)

do while !EOF()
        
    cId := field->id
    cPNaz := field->naz
    nCnt := 0
    
    @ m_x + 1, m_y + 2 SAY "partner: " + cId + " " + ;
        PADR( cPNaz, 15 ) + " ..."

    do while !EOF() .and. field->id == cId
        ++ nCnt
        skip
    enddo
    
    if nCnt > 1
        
        select fakt_doks
        go top
        
        do while !EOF()
            
            if field->idpartner == cId
                
                AADD( aPartn, { cId, PADR( cPNaz, 25), ;
                    fakt_doks->idfirma + ;
                    "-" + fakt_doks->idtipdok + ;
                    "-" + fakt_doks->brdok } )
            endif
            
            skip
        
        enddo

        select partn
    else
        select partn
        skip
    endif

enddo

BoxC()

if LEN( aPartn ) > 0

    START PRINT CRET
    P_COND

    ?
    ? "-------------------------------------------------"
    ? " partner (id/naz)                   dokument "
    ? "-------------------------------------------------"
    ?

    for i:=1 to LEN( aPartn )
        
        // id partnera
        ? aPartn[i, 1]
        // naziv partnera
        @ prow(), pcol()+1 SAY aPartn[i, 2]
        // dokument na kojem se pojavljuje
        @ prow(), pcol()+1 SAY aPartn[i, 3]
    next

    END PRINT
endif

return




// -------------------------------------------------
// ispravka podataka dokumenta
// -------------------------------------------------
function fakt_edit_data( id_firma, tip_dok, br_dok )
local _t_area := SELECT()
local _ret := .f.
local _x := 1
local _cnt
local __idpartn
local __br_otpr
local __br_nar
local __dat_otpr
local __dat_pl
local __txt
local __id_vrsta_p
local __p_tmp
local _t_txt

__idpartn := field->idpartner
__id_vrsta_p := field->idvrstep

select ( F_FAKT )
if !Used()
    O_FAKT
endif

select ( F_PARTN )
if !Used()
    O_PARTN
endif

select fakt
set order to tag "1"
go top
seek id_firma + tip_dok + br_dok

if !FOUND()
    select ( _t_area )
    return _ret
endif

_t_txt := parsmemo( field->txt )

__br_otpr := _t_txt[6]
__br_nar := _t_txt[8]
__dat_otpr := CTOD( _t_txt[7] )
__dat_pl := CTOD( _t_txt[9] )

Box(, 12, 65 )
    
    @ m_x + _x, m_y + 2 SAY "*** korekcija podataka dokumenta"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Partner:" GET __idpartn ;
        VALID p_firma( @__idpartn )

    ++ _x
    @ m_x + _x, m_y + 2 SAY "Datum otpremnice:" GET __dat_otpr 

    ++ _x
    @ m_x + _x, m_y + 2 SAY " Broj otpremnice:" GET __br_otpr PICT "@S40" 
    
    ++ _x
    @ m_x + _x, m_y + 2 SAY "  Datum placanja:" GET __dat_pl
    
    ++ _x
    @ m_x + _x, m_y + 2 SAY "        Narudzba:" GET __br_nar PICT "@S40"

    ++ _x
    @ m_x + _x, m_y + 2 SAY "  Vrsta placanja:" GET __id_vrsta_p VALID EMPTY( __id_vrsta_p ) .or. P_VRSTEP( @__id_vrsta_p )
    
    
    read

BoxC()

if LastKey() == K_ESC
    select ( _t_area )
    return _ret
endif

if Pitanje(, "Izvrsiti zamjenu podataka ? (D/N)", "D" ) == "N"
    select ( _t_area )
    return _ret
endif

if !f18_lock_tables( { "fakt_fakt", "fakt_doks" } )
    MsgBeep("Problem sa lokovanjem tabela !!!")
    select ( _t_area )
    return _ret
endif

sql_table_update( nil, "BEGIN" )

// mjenjamo podatke
_ret := .t.

// pronadji nam partnera
select partn
seek __idpartn

__p_tmp := ALLTRIM( field->naz ) + ;
    "," + ALLTRIM( field->ptt ) + ;
    " " + ALLTRIM( field->mjesto )

// vrati se na doks
select fakt_doks
seek id_firma + tip_dok + br_dok

if !FOUND()
    msgbeep("Nisam nista promjenio !!!")
    return .f.
endif

// napravi zamjenu u doks tabeli 
_rec := dbf_get_rec()
_rec["idpartner"] := __idpartn
_rec["partner"] := __p_tmp
_rec["idvrstep"] := __id_vrsta_p

update_rec_server_and_dbf( "fakt_doks", _rec, 1, "CONT" )

// prodji kroz fakt stavke
select fakt
go top
seek id_firma + tip_dok + br_dok

_cnt := 1

do while !EOF() .and. field->idfirma == id_firma ;
        .and. field->idtipdok == tip_dok ;
        .and. field->brdok == br_dok

    _rec := dbf_get_rec()
    _rec["idpartner"] := __idpartn
    _rec["idvrstep"] := __id_vrsta_p

    if _cnt == 1
        
        // roba tip U
        __txt := Chr(16) + _t_txt[1] + Chr(17)
            // dodatni tekst fakture
        __txt += Chr(16) + _t_txt[2] + Chr(17)
        // naziv partnera
        __txt += Chr(16) + ALLTRIM( partn->naz ) + Chr(17)
        // partner 2 podaci
        __txt += Chr(16) + ALLTRIM(partn->adresa) + ", Tel:" + ALLTRIM(partn->telefon) + Chr(17) 
        // partner 3 podaci
        __txt += Chr(16) + ALLTRIM(partn->ptt) + " " + ALLTRIM(partn->mjesto) + Chr(17)
            // broj otpremnice
        __txt += Chr(16) + __br_otpr + Chr(17) 
            // datum otpremnice
        __txt += Chr(16) + DToC(__dat_otpr) + Chr(17)
            // broj narudzbenice
        __txt += Chr(16) + __br_nar + Chr(17)
        // datum placanja
        __txt += Chr(16) + DToC(__dat_pl) + Chr(17)
        
        if LEN( _t_txt ) > 9
            for _i := 10 to LEN( _t_txt )
                __txt += Chr(16) + _t_txt[ _i ] + Chr(17)
            next
        endif

        _rec["txt"] := __txt

    endif

    update_rec_server_and_dbf( "fakt_fakt", _rec, 1, "CONT" )

    ++ _cnt

    skip

enddo

sql_table_update( nil, "END" ) 
f18_free_tables( { "fakt_fakt", "fakt_doks" } )

select ( _t_area )
return _ret



