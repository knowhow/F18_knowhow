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


#include "rnal.ch"


// variables
static __temp
static __doc_no

// -------------------------------------
// stampa naloga, filovanje prn tabela
// -------------------------------------
function st_nalpr( lTemporary, nDoc_no )
local cFlag := "N"
local lFlag

__temp := lTemporary
__doc_no := nDoc_no

// kreiraj print tabele
t_rpt_create()
// otvori tabele
t_rpt_open()

o_tables( __temp )

// osnovni podaci naloga
_fill_main()
// stavke naloga
_fill_items()
// dodatne stavke naloga
_fill_it2()
// operacije
_fill_aops()

lFlag := _is_p_rekap()

if lFlag == .t.
    cFlag := "D"
endif

// upisi za rekapitulaciju u t_pars
add_tpars("N20", cFlag )

if Pitanje(, "Stampati odt verziju ?", "N" ) == "D"
    rnal_nalog_za_proizvodnju_odt()
else
    // printaj nalog
    nalpr_print( .t. )
endif

close all

o_tables( __temp )

return DE_REFRESH


// -------------------------------------
// stampa obracunskog lista
// filovanje prn tabela
// -------------------------------------
function st_obr_list( lTemporary, nDoc_no, aOlDocs )
local lGN := .t.
local i 
local ii
local cDocs := ""
local cFlag := "N"

if gGnUse == "N"
    lGn := .f.
endif

if aOlDocs == nil .or. LEN( aOlDocs ) == 0
    // dodaj onda ovaj nalog koji treba da se stampa
    aOlDocs := {}
    AADD(aOlDocs, { nDoc_no, "" })
endif

// setuj opis i dokumente 
for ii:=1 to LEN(aOlDocs)
    if !EMPTY(cDocs)
        cDocs += ","
    endif
    cDocs += ALLTRIM( STR(aOlDocs[ii, 1] ))
next

__temp := lTemporary

// kreiraj print tabele
t_rpt_create()
// otvori tabele
t_rpt_open()

o_tables( __temp )

// prosetaj kroz stavke za stampu !
for i:=1 to LEN( aOlDocs ) 

    if aOlDocs[i, 1] < 0
        // ovakve stavke preskoci, jer su to brisane stavke !
        loop
    endif

    __doc_no := aOlDocs[ i, 1 ] 

    select docs
    go top
    seek docno_str( __doc_no )

    // osnovni podaci naloga
    _fill_main( cDocs )
    
    // stavke naloga
    _fill_items( lGN, 2 )
    
    // dodatne stavke naloga
    _fill_it2()
    
    // operacije
    _fill_aops()

next

nCount := t_docit->(RecCount2())

if nCount > 0 .and. pitanje(,"Odabrati stavke za stampu ? (D/N)","N") == "D"
    sel_items()
endif

// da li se stampa rekapitulacija repromaterijala
lFlag := _is_p_rekap()

if lFlag == .t.
    cFlag := "D"
endif

// upisi za rekapitulaciju u t_pars
add_tpars("N20", cFlag )

// printaj obracunski list
obrl_print( .t. )

close all

o_tables( __temp )

return DE_REFRESH



// -------------------------------------
// samo napuni pripremne tabale
// -------------------------------------
function st_pripr( lTemporary, nDoc_no, aOlDocs )
local lGN := .t.
local i 
local ii
local cDocs := ""
local cFlag := "N"

if aOlDocs == nil .or. LEN( aOlDocs ) == 0
    // dodaj onda ovaj nalog koji treba da se stampa
    aOlDocs := {}
    AADD(aOlDocs, { nDoc_no, "" })
endif

// setuj opis i dokumente 
for ii:=1 to LEN(aOlDocs)
    if !EMPTY(cDocs)
        cDocs += ","
    endif
    cDocs += ALLTRIM( STR(aOlDocs[ii, 1] ))
next

__temp := lTemporary

// kreiraj print tabele
t_rpt_create()
// otvori tabele
t_rpt_open()

o_tables( __temp )

// prosetaj kroz stavke za stampu !
for i:=1 to LEN( aOlDocs ) 

    if aOlDocs[i, 1] < 0
        // ovakve stavke preskoci...
        // jer su to brisane stavke !
        loop
    endif

    __doc_no := aOlDocs[ i, 1 ] 

    select docs
    go top
    seek docno_str( __doc_no )

    // osnovni podaci naloga
    _fill_main( cDocs )
    
    // stavke naloga
    _fill_items( lGN, 2 )
    
    // dodatne stavke naloga
    _fill_it2()
    
    // operacije
    _fill_aops()

next

close all

o_tables( __temp )

return DE_REFRESH



// -------------------------------------
// stampa labela na osnovu naloga
// -------------------------------------
function st_label( lTemporary, nDoc_no )
local lGn := .t.

__temp := lTemporary
__doc_no := nDoc_no

// kreiraj print tabele
t_rpt_create()
// otvori tabele
t_rpt_open()

o_tables( __temp )

// osnovni podaci naloga
_fill_main()
// stavke naloga
_fill_items( lGn, 2 )
// operacije
_fill_aops()

// printaj labele
lab_print( lTemporary )

close all

o_tables( __temp )

return DE_REFRESH



// -------------------------------------------------------
// filuj tabele za stampu
// lZPoGn - zaokruzenje po GN .t. or .f.
// nVar - varijanta 1, 2, 3... 1-nalog, 2-obrl. itd..
// -------------------------------------------------------
static function _fill_items( lZpoGN, nVar )
local nTable := F_DOC_IT
local nTOps := F_DOC_OPS
local nArt_id
local cArt_desc
local cArt_full_desc
local nDoc_it_no
local cDoc_gr_no := "0"
local nQtty
local nTotal
local nTot_m
local nHeigh
local nHe2
local nWidth
local nWi2
local nZWidth := 0
local nZH2 := 0
local nZW2 := 0
local nZHeigh := 0
local nNeto := 0
local nBruto := 0
local lGroups := .f.
local nGr1 
local nGr2
local cPosition
local cIt_lab_pos
local xx
local nScan

if nVar == NIL
    nVar := 1
endif

if lZpoGN == NIL
    lZPoGN := .f.
endif

// iskljucen parametar zaokruzenja
if gGnUse == "N"
    lZPoGn := .f.
endif

// samo kod naloga se vrsi dijeljenje po grupama...
if nVar == 1 .and. Pitanje(,"Razdijeliti nalog po grupama ?", "D" ) == "D"
    lGroups := .t.
endif

if ( __temp == .t. )
    nTable := F__DOC_IT
    nTOps := F__DOC_OPS
endif

select (nTable)
set order to tag "1"
go top
seek docno_str(__doc_no)

nArtTmp := -1
cGrTmp := "-1"

// filuj stavke
do while !EOF() .and. field->doc_no == __doc_no
    
    nArt_id := field->art_id
    nDoc_it_no := field->doc_it_no
    nDoc_no := field->doc_no
    
    cDoc_it_pos := ALLTRIM(field->doc_it_pos)
    cIt_lab_pos := field->it_lab_pos
    cPosition := ""

    if !EMPTY( cDoc_it_pos )
        cPosition := "pozicija: " + cDoc_it_pos + ", "
    endif

    // tip artikla
    cDoc_it_type := field->doc_it_typ
    
    // nadji proizvod
    select articles
    hseek artid_str( nArt_id )

    if lGroups == .t.
        
        // odredi grupu artikla
        // - izo i kaljeno, izo i bruseno ili ....
        cDoc_gr_no := set_art_docgr( nArt_id, nDoc_no, nDoc_it_no )
        
    else
        
        cDoc_gr_no := "0"
        
    endif
    
    cOper_desc := ""
    lPrepust := .f.

    nHeigh := 0
    nWidth := 0

    // u varijanti obracunskog lista uzmi i operacije za ovu stavku
    if nVar = 2

        aOper := {}
        cTmp := ""
        
        select ( nTOps )
        seek docno_str( nDoc_no ) + docit_str( nDoc_it_no )
        do while !EOF() .and. field->doc_no = nDoc_no ;
            .and. field->doc_it_no = nDoc_it_no
        
            // ako je prepust, uzmi dimenzije
            cTmp_val := ALLTRIM( field->aop_value )

            if ( "<A_PREP>" $ cTmp_val ) .and. lPrepust == .f.
                
                lPrepust := .t.
                prep_read( cTmp_val, @nWidth, @nHeigh )
            
            endif

            cTmp := g_aop_desc( field->aop_id )
            
            nScan := ASCAN( aOper, {|xVar| xVar[1] = cTmp } )
            
            if nScan = 0
                AADD( aOper, { cTmp } ) 
            endif

            skip
        enddo

        for xx := 1 to LEN( aOper )
            
            if !EMPTY( cOper_desc)
                cOper_desc += ", "
            endif
            
            cOper_desc += ALLTRIM( aOper[xx, 1] )
        next

        if !EMPTY( cOper_desc )
            cOper_desc := ", " + cOper_desc
        endif

    endif

    cArt_full_desc := ALLTRIM(articles->art_full_d)
    cArt_desc := ALLTRIM(articles->art_desc)
    
    cArt_sh := cArt_desc
    cArt_sh += cOper_desc

    // temporary
    cArt_desc := "(" + cArt_desc + ")"
    cArt_desc += " " + cArt_full_desc
    
    if nVar = 2
        cArt_desc += cOper_desc
    endif

    // ako je artikal isti ne treba mu opis...
    if ( nArt_Id == nArtTmp ) .and. ( cGrTmp == cDoc_gr_no )
        if lZpoGN == .f.
            cArt_desc := ""
        endif
    endif

    select ( nTable )
    
    nQtty := field->doc_it_qtt
    
    // dimenzije stakla
    if nHeigh < field->doc_it_hei
        nHeigh := field->doc_it_hei
    endif

    if nWidth < field->doc_it_wid
        nWidth := field->doc_it_wid
    endif

    // dimenzije ako je oblik SHAPE
    nHe2 := field->doc_it_h2
    nWi2 := field->doc_it_w2

    // kod obracunskog lista
    if nVar = 2
        // prepust...
    endif

    // nadmorska visina
    // samo ako je razlicita vrijednost od default-ne
    if (field->doc_it_alt <> gDefNVM) .or. ;
        ( field->doc_acity <> ALLTRIM(gDefCity) )
        nDocit_altt := field->doc_it_alt
        cDocit_city := field->doc_acity
    else
        nDocit_altt := 0
        cDocit_city := ""
    endif
    
    // ukupno mm -> m2
    nTotal := ROUND( c_ukvadrat(nQtty, nHeigh, nWidth), 2)
    
    // ukupno duzinski
    nTot_m := ROUND( c_duzinski(nQtty, nHeigh, nWidth), 2)

    cDoc_it_schema := field->doc_it_sch
    // na napomene dodaj i poziciju ako postoji...
    cDoc_it_desc := cPosition + ALLTRIM( field->doc_it_des )
         
    aZpoGN := {}
    // setuje se matrica sa elementima artikla
    _art_set_descr( nArt_id, .f., nil, @aZpoGN, .t. )
    
    if lZpoGN == .t.

        lBezZaokr := .f.

        if lBezZaokr == .f.
            // da li je kaljeno ? kod kaljenog nema zaokruzenja
            lBezZaokr := is_kaljeno( aZpoGN, nDoc_no, nDoc_it_no )
        endif

        if lBezZaokr == .f.
            // da li je emajlirano ? isto nema zaokruzenja
            lBezZaokr := is_emajl(aZpoGN, nDoc_no, nDoc_it_no )
        endif

        if lBezZaokr == .f.
            // da li je vatroglas ? isto nema zaokruzenja
            lBezZaokr := is_vglass( aZpoGN )
        endif

        if lBezZaokr == .f.
            // da li je plexiglas ? isto nema zaokruzenja
            lBezZaokr := is_plex( aZpoGN )
        endif
    
        nZHeigh := obrl_zaok( nHeigh, aZpoGN, lBezZaokr )
        nZH2 := obrl_zaok( nHe2, aZpoGN, lBezZaokr )
        
        nZWidth := obrl_zaok( nWidth, aZpoGN, lBezZaokr )
        nZW2 := obrl_zaok( nWi2, aZpoGN, lBezZaokr )
        
        // ako se zaokruzuje onda total ide po zaokr.vrijednostima
        nTotal := ROUND( c_ukvadrat( nQtty, nZHeigh, nZWidth, nZH2, nZW2 ), 2)
           
    endif
         
        
    // izracunaj neto
    nNeto := ROUND( obrl_neto( nTotal, aZpoGN ), 2)
    nBruto := 0
    
    // prva grupa
    nGr1 := VAL( SUBSTR(cDoc_gr_no, 1, 1) )

    // dodaj u stavke
    a_t_docit( __doc_no, nGr1, nDoc_it_no, nArt_id, cArt_desc , cArt_sh, ;
          cDoc_it_schema, cDoc_it_desc, cDoc_it_Type, ;
          nQtty, nHeigh, nWidth, ;
          nHe2, nWi2, ;
          nDocit_altt, cDocit_city, nTotal, nTot_m, ;
          nZHeigh, nZWidth, ;
          nZH2, nZW2, ;
          nNeto, nBruto, cDoc_it_pos, cIt_lab_pos )
    
    
    if LEN( cDoc_gr_no ) > 1
    
        // razdvoji nalog na 2 dijela   
        // ako ima vise grupa
    
        for xx := 1 to ( LEN(cDoc_gr_no) )
    
        // ako je vec kao grupa 1 onda preskoci...
        if VAL(SUBSTR(cDoc_gr_no, xx, 1)) == nGr1
            loop
        endif

        a_t_docit( __doc_no, VAL(SUBSTR(cDoc_Gr_no, xx, 1)), nDoc_it_no, nArt_id, cArt_desc , cArt_sh, ;
          cDoc_it_schema, cDoc_it_desc, cDoc_it_type, ;
          nQtty, nHeigh, nWidth, ;
          nHe2, nWi2, ;
          nDocit_altt, cDocit_city, nTotal, nTot_m, ;
          nZHeigh, nZWidth, ;
          nZH2, nZW2, ;
          nNeto, nBruto, cDoc_it_pos, cIt_lab_pos )

        next

    endif
    
    nArtTmp := nArt_Id
    cGrTmp := cDoc_gr_no
    
    select ( nTable )
    skip
enddo
    
return


// ---------------------------------------------------
// da li printati rekapitulaciju repromaterijala
// ---------------------------------------------------
function _is_p_rekap()
local lRet := .f.
local nTArea := SELECT()

select t_docit2

if RECCOUNT2() > 0
    if Pitanje(,"Stampati rekapitulaciju materijala ?", "D") == "D"
        lRet := .t.
    endif
endif

select ( nTArea )
return lRet


// ----------------------------------
// filuj tabele za stampu DOC_IT2
// ----------------------------------
static function _fill_it2()
local nTable := F_DOC_IT2
local cArt_id
local cArt_desc
local nDoc_it_no
local nQtty

if ( __temp == .t. )
    nTable := F__DOC_IT2
endif

select (nTable)

set order to tag "1"
go top
seek docno_str(__doc_no)

// filuj stavke
do while !EOF() .and. field->doc_no == __doc_no
    
    cArt_id := field->art_id
    nDoc_it_no := field->doc_it_no
    nDoc_no := field->doc_no
    nIt_no := field->it_no
    
    // nadji artikal
    select roba
    hseek cArt_id

    cArt_desc := ALLTRIM( roba->naz )
    
    select ( nTable )
    
    nQtty := field->doc_it_qtt
    nPrice := field->doc_it_pri

    cDesc := ALLTRIM( field->descr )
    cSh_desc := ALLTRIM( field->sh_desc )

    cDescription := ""

    if !EMPTY( cSh_desc )
        cDescription += cSh_desc
    endif

    if !EMPTY( cDesc )
        cDescription += ", " + cDesc
    endif
    
    // dodaj u stavke
    a_t_docit2( __doc_no, nDoc_it_no, nIt_no, cArt_id, cArt_desc , ;
          nQtty, nPrice, cDescription )
    
    select ( nTable )
    skip

enddo


return



// --------------------------------------------------
// filovanje operacija 
// --------------------------------------------------
static function _fill_aops()
local nTable := F_DOC_OPS
local nTable2 := F_DOC_IT
local nDoc_op_no
local nDoc_it_no
local nDoc_el_no
local cDoc_el_desc
local nArt_id
local aElem
local nElem_no
local nAop_id
local cAop_desc
local nAop_att_id
local cAop_att_desc
local cDoc_op_desc
local cAop_Value


if ( __temp == .t. )
    nTable := F__DOC_OPS
    nTable2 := F__DOC_IT
endif

select (nTable2)
set order to tag "2"
go top

// filuj operacije
select (nTable)
set order to tag "1"
go top
seek docno_str(__doc_no)

cRecord := ""
cTmpRecord := "XX"
nArticle := -99
nTmpArticle := -99


do while !EOF() .and. field->doc_no == __doc_no

    nElem_no := 0
    nDoc_it_no := field->doc_it_no
    nDoc_op_no := field->doc_op_no
    nDoc_el_no := field->doc_it_el_

    // uzmi sve operacije za jednu stavku
    // ispitaj da li trebas da da je dodajes za stampu

    nRec := RECNO()

    cRecord := ""
    
    do while !EOF() .and. field->doc_no == __doc_no ;
            .and. field->doc_it_no == nDoc_it_no
    
        nAop_id := field->aop_id
        nAop_att_id := field->aop_att_id

        cRecord += g_aop_desc( nAop_id) 
        cRecord += ","
        cRecord += g_aop_att_desc( nAop_att_id )
        
        if !EMPTY( field->aop_value )
            cRecord += ","
            cRecord += ALLTRIM( field->aop_value )
        endif

        if !EMPTY( ALLTRIM(field->doc_op_des) )
            cRecord += ","
            cRecord += ALLTRIM( field->doc_op_des )
        endif

        cRecord += "#"

        skip
    enddo

    // doc_it
    // uzmi artikal...
    select (nTable2)
    set order to tag "1"
    go top
    seek docno_str( __doc_no ) + docit_str( nDoc_it_no )

    nArticle := field->art_id
    
    // vrati se na operacije
    select (nTable)
    
    // ako su identicne operacije samo idi dalje....
    if cRecord == cTmpRecord .and. nArticle == nTmpArticle
        loop
    endif

    // vrati se na zapis gdje si bio
    go (nRec)

        do while !EOF() .and. field->doc_no == __doc_no ;
            .and. field->doc_it_no == nDoc_it_no

     
     nElem_no := 0
     nDoc_it_no := field->doc_it_no
     nDoc_op_no := field->doc_op_no
     nDoc_el_no := field->doc_it_el_
     
     select (nTable2)
     set order to tag "1"
     go top
     seek docno_str( __doc_no ) + docit_str( nDoc_it_no )
    
     nArt_id := field->art_id

     aElem := {}
    
     _g_art_elements( @aElem, nArt_id )
    
     // vrati broj elementa artikla (1, 2, 3 ...)
     _g_elem_no( aElem, nDoc_el_no, @nElem_no )
    
     cDoc_el_desc := get_elem_desc( aElem, nDoc_el_no, 150 )
    
     select (nTable)
    
     nAop_id := field->aop_id
     nAop_att_id := field->aop_att_id

     cAop_desc := g_aop_desc( nAop_id )
     cAop_att_desc := g_aop_att_desc( nAop_att_id )

     cDoc_op_desc := ALLTRIM( field->doc_op_des )
    
     cAop_value := g_aop_value( field->aop_value )
     cAop_vraw := ALLTRIM(field->aop_value)

     a_t_docop( __doc_no, nDoc_op_no, nDoc_it_no, ;
           nElem_no, cDoc_el_desc, ;
                   nAop_id, cAop_desc, ;
           nAop_att_id, cAop_att_desc, ;
           cDoc_op_desc, cAop_value, cAop_vraw )


     select (nTable)
     
     skip
    
       enddo

       cTmpRecord := cRecord
       nTmpArticle := nArticle
    
enddo

return


// --------------------------------------
// napuni podatke narucioca i ostalo
// --------------------------------------
static function _fill_main( cDescr )
local nTable := F_DOCS

if cDescr == nil
    cDescr := ""
endif

if ( __temp == .t. )
    nTable := F__DOCS
endif

select (nTable)
set order to tag "1"
go top
seek docno_str( __doc_no )

_fill_customer( field->cust_id )
_fill_contacts( field->cont_id )
_fill_objects( field->obj_id)

select (nTable)

// broj naloga
add_tpars("N01", docno_str( __doc_no ) )
// datum naloga
add_tpars("N02", DToC( field->doc_date ) )
// datum isporuke
add_tpars("N03", DToC( field->doc_dvr_da ) )
// vrijeme isporuke
add_tpars("N04", PADR( field->doc_dvr_ti, 5))
// hitnost - prioritet
add_tpars("N05", s_priority( field->doc_priori ))
// nalog vrsta placanja
add_tpars("N06", s_pay_id( field->doc_pay_id ))
// mjesto isporuke
add_tpars("N07", ALLTRIM(field->doc_ship_p) )
// dokument dodatni podaci
add_tpars("N08", ALLTRIM(field->doc_desc) )
// dokument, kontakt dodatni podaci...
add_tpars("N09", ALLTRIM(field->cont_add_d) )
// operater koji je napravio nalog
add_tpars("N13", ALLTRIM( getfullusername(field->operater_i)) )

// dokumenti koji su sadrzani 
if !EMPTY(cDescr)
    add_tpars("N14", cDescr )
endif

// ako je kes, dodaj i podatke o placeno D i napomene
if field->doc_pay_id == 2
    
    // placeno d/n...
    add_tpars("N10", ALLTRIM( field->doc_paid ) )
    // placanje dodatne napomene...
    add_tpars("N11", ALLTRIM( field->doc_pay_de ) )

endif

if fieldpos("DOC_TIME") <> 0
    // vrijeme dokumenta
    add_tpars("N12", ALLTRIM(field->doc_time) )
endif

return



// ----------------------------------------
// dodaj podatke o naruciocu
// ----------------------------------------
static function _fill_customer( nCust_id )
local nTArea := SELECT()
local cCust_desc := ""
local cCust_addr := ""
local cCust_tel := ""

select customs
set order to tag "1"
go top
seek custid_str(nCust_id)

if FOUND()
    cCust_desc := ALLTRIM( customs->cust_desc )
    cCust_addr := ALLTRIM( customs->cust_addr )
    cCust_tel := ALLTRIM( customs->cust_tel )
endif

add_tpars("P01", custid_str(nCust_id))
add_tpars("P02", cCust_desc )
add_tpars("P03", cCust_addr )
add_tpars("P04", cCust_tel )

select (nTArea)
return


// ----------------------------------------
// dodaj podatke o kontaktu
// ----------------------------------------
static function _fill_contacts( nCont_id )
local nTArea := SELECT()
local cCont_desc := ""
local cCont_tel := ""
local cCont_add_desc := ""

select contacts
set order to tag "1"
go top
seek contid_str(nCont_id)

if FOUND()
    cCont_desc := ALLTRIM( contacts->cont_desc )
    cCont_tel := ALLTRIM( contacts->cont_tel )
    cCont_add_desc := ALLTRIM( contacts->cont_add_d )
endif

add_tpars("P10", contid_str(nCont_id))
add_tpars("P11", cCont_desc )
add_tpars("P12", cCont_tel )
add_tpars("P13", cCont_add_desc )

select (nTArea)
return


// ----------------------------------------
// dodaj podatke o objektu
// ----------------------------------------
static function _fill_objects( nObj_id )
local nTArea := SELECT()
local cObj_desc := ""

select objects
set order to tag "1"
go top
seek objid_str(nObj_id)

if FOUND()
    cObj_desc := ALLTRIM( objects->obj_desc )
endif

add_tpars("P20", objid_str(nObj_id))
add_tpars("P21", cObj_desc )

select (nTArea)
return



// ---------------------------------------------
// vraca opis grupe za stampu dokumenta
// ---------------------------------------------
function get_art_docgr( nGr )
local cGr := "sve grupe"

do case
    case nGr == 1
        cGr := "rezano"
    case nGr == 2
        cGr := "kaljeno"
    case nGr == 3
        cGr := "bruseno"
    case nGr == 4
        cGr := "IZO"
    case nGr == 5
        cGr := "LAMI-RG"
    case nGr == 6
        cGr := "emajlirano"
    case nGr == 7
        cGr := "buseno"
    case nGr == -99
        cGr := "!!! ARTICLE-ERROR !!!"
endcase

return cGr


// -----------------------------------------------
// setuj grupu artikla za stampu naloga
// -----------------------------------------------
function set_art_docgr( nArt_id, nDoc_no, nDocit_no )
local cGroup := ""
local aArt := {}
local lIsIZO := .f.
local lIsBruseno := .f.
local lIsBuseno := .f.
local lIsKaljeno := .f.
local lIsLamiG := .f.
local lIsLami := .f.

// daj matricu aArt sa definicijom artikla....
_art_set_descr( nArt_id, nil, nil, @aArt, .t. )

if aArt == nil .or. LEN(aArt) == 0
    cGroup := "0"
    return cGroup
endif

// da li je artikal IZO...
lIsIZO := is_izo( aArt )
// lami-rg staklo
lIsLami := is_lami( aArt )
// lami gotovo staklo - ne laminira RG
lIsLAMIG := is_lamig( aArt )

lIsBruseno := is_bruseno( aArt, nDoc_no, nDocIt_no )
lIsBuseno := is_buseno( aArt, nDoc_no, nDocIt_no )
lIsKaljeno := is_kaljeno( aArt, nDoc_no, nDocIt_no )
lIsEmajl := is_emajl( aArt, nDoc_no, nDocIt_no )

// grupe su sljedece
// 1 - rezano
// 2 - kaljeno
// 3 - bruseno
// 4 - IZO
// 5 - lami-rg
// 6 - emajlirano
// 7 - buseno

if lIsEmajl == .t.
    cGroup += "6"
endif

if lIsKaljeno == .t. .and. lIsEmajl == .f.
    cGroup += "2"
endif

if lIsBruseno == .t. .and. ( lIsKaljeno == .f. .and. lIsEmajl == .f. )
    cGroup += "3"
endif       

if lIsIZO == .t. 
    cGroup += "4"
endif       

if lIsLAMI == .t.
    cGroup += "5"
endif   

if lIsBuseno == .t. 
    cGroup += "7"
endif       


if ( lIsKaljeno == .f. ) .and. ;
    (lIsBruseno == .f.) .and. ;
    (lIsBuseno == .f.) .and. ;
    (lIsIZO == .f.) .and. ;
    (lIsEmajl == .f.) .and. ;
    (lIsLami == .f. ) 

    // ako sve ovo nije, onda je rezano
    cGroup += "1"

endif

return cGroup


// ---------------------------------------
// da li je staklo IZO
// ---------------------------------------
function is_izo( aArticle )
local lRet := .f.
local nElNo
local nGlass
local nFrame

local cGlCode := ALLTRIM( gGlassJoker )
local cFrCode := ALLTRIM( gFrameJoker )


nElNo := aArticle[ LEN(aArticle), 1 ]

if nElNo > 1

    nGlass := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cGlCode })
    nFrame := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cFrCode })
    
    if nGlass <> 0 .and. nFrame <> 0
        lRet := .t.
    endif
    
endif

return lRet


// ---------------------------------------------
// da li je staklo LAMI - gotovo LAMI staklo
// ---------------------------------------------
function is_lamig( aArticle )
local lRet := .f.
local nLAMI

local cGlCode := ALLTRIM( gGlassJoker )
local cLamiCode := ALLTRIM( gGlLamiJoker )

nLAMI := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cGlCode .and. ;
        ALLTRIM(xVar[5]) == cLamiCode } )

if nLAMI <> 0
    lRet := .t.
endif

return lRet


// ---------------------------------------------
// da li je staklo LAMI - lami-rg staklo
// ramaglas radi laminiranje stakla !
// ---------------------------------------------
function is_lami( aArticle )
local lRet := .f.
local nLAMI
// folija je joker kod pravljenih stakala u elementu folija
local cFrCode := "FL"

// kod ovog tipa je bitno samo da se nadje Folija u komponenti stakla
nLAMI := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cFrCode } )

if nLAMI <> 0
    lRet := .t.
endif

return lRet


// ---------------------------------------
// da li je staklo PLEX
// ---------------------------------------
function is_plex( aArticle )
local lRet := .f.
local nRet

local cGlCode := ALLTRIM( gGlassJoker )
local cSGlCode := "PLEX"

nRet := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cGlCode .and. ;
        ALLTRIM(xVar[5]) = cSGlCode } )

if nRet <> 0
    lRet := .t.
endif

return lRet


// ---------------------------------------
// da li je staklo vatroglass
// ---------------------------------------
function is_vglass( aArticle )
local lRet := .f.
local nRet

local cGlCode := ALLTRIM( gGlassJoker )
local cSGlCode := "V"

nRet := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[2]) == cGlCode .and. ;
        ALLTRIM(xVar[5]) = cSGlCode } )

if nRet <> 0
    lRet := .t.
endif

return lRet



// ------------------------------------------------------------
// da li je staklo kaljeno ???
// ------------------------------------------------------------
function is_kaljeno( aArticle, nDoc_no, nDocit_no, nDoc_el_no )
local lRet := .f.
local cSrcJok := ALLTRIM( gAopKaljenje )

if nDoc_el_no == nil
    nDoc_el_no := 0
endif

// provjeri obradu iz matrice
lRet := ck_obr( aArticle, cSrcJok )

if lRet == .f.
    // provjeri i tabelu DOC_OPS
    lRet := ck_obr_aops( nDoc_no, nDocit_no, nDoc_el_no, cSrcJok )
endif

return lRet 


// -----------------------------------------------------------
// da li je staklo emajlirano ???
// -----------------------------------------------------------
function is_emajl( aArticle, nDoc_no, nDocit_no, nDoc_el_no )
local lRet := .f.
local cSrcJok := "<A_E>"

if nDoc_el_no == nil
    nDoc_el_no := 0
endif

// provjeri obradu iz matrice
lRet := ck_obr( aArticle, cSrcJok )

if lRet == .f.
    // provjeri i tabelu DOC_OPS
    lRet := ck_obr_aops( nDoc_no, nDocit_no, nDoc_el_no, cSrcJok )
endif

return lRet 



// -------------------------------------------------------------
// da li je staklo kaljeno ???
// -------------------------------------------------------------
function is_bruseno( aArticle, nDoc_no, nDocit_no, nDoc_el_no )
local lRet := .f.
local cSrcJok := ALLTRIM( gAopBrusenje )

if nDoc_el_no == nil
    nDoc_el_no := 0
endif

// provjeri obradu iz matrice
lRet := ck_obr( aArticle, cSrcJok )

if lRet == .f.
    // provjeri i tabelu DOC_OPS
    lRet := ck_obr_aops( nDoc_no, nDocit_no, nDoc_el_no, cSrcJok )
endif

return lRet 



// -------------------------------------------------------------
// da li je staklo buseno ???
// -------------------------------------------------------------
function is_buseno( aArticle, nDoc_no, nDocit_no, nDoc_el_no )
local lRet := .f.
local cSrcJok := "<A_BU>"

if nDoc_el_no == nil
    nDoc_el_no := 0
endif

// provjeri obradu iz matrice
lRet := ck_obr( aArticle, cSrcJok )

if lRet == .f.
    // provjeri i tabelu DOC_OPS
    lRet := ck_obr_aops( nDoc_no, nDocit_no, nDoc_el_no, cSrcJok )
endif

return lRet 



// ----------------------------------------------------
// provjeri obradu na osnovu matrice artikla
// ----------------------------------------------------
static function ck_obr( aArticle, cSrcObrada )
local lRet := .f.
local nObrada 
nObrada := ASCAN(aArticle, {|xVar| ALLTRIM(xVar[4]) == cSrcObrada } )
if nObrada <> 0
    lRet := .t.
endif
return lRet


// ----------------------------------------------------------------------
// provjeri obradu u tabeli DOC_OPS
//   nDocIt_no - redni broj stavke naloga
//   cSrcObrada - djoker obrade <AOP_K> .... 
//                koju obradu trazimo
// ----------------------------------------------------------------------
static function ck_obr_aops( nDoc_no, nDocit_no, nDoc_el_no, cSrcObrada )
local lRet := .f.
local nTArea := SELECT()
local nTable := F_DOC_OPS
if __temp == .t.
    nTable := F__DOC_OPS
endif

// provjeri na osnovu DOC_AOP
    
select (nTable)
set order to tag "1"
go top
    
seek docno_str(nDoc_no) + docit_str(nDocit_no)
    
do while !EOF() .and. field->doc_no == nDoc_no .and. ;
        field->doc_it_no == nDocit_no

    // provjeri po elementu
    if nDoc_el_no > 0
        if field->doc_it_el_ <> nDoc_el_no
            skip
            loop
        endif
    endif

    nAop_id := field->aop_id

    // idi u operacije pa vidi djoker
    select aops
    go top
    seek aopid_str( nAop_id )
        
    if FOUND() .and. field->aop_id == nAop_id .and. ;
        ALLTRIM( field->aop_joker ) == cSrcObrada
            
        lRet := .t.
        exit
            
    endif
        
    select (nTable)
    skip
enddo
    
select (nTArea)
return lRet



// ----------------------------------------------
// printanje naloga, po zadatom broju 
// ----------------------------------------------
function prn_nal()
local GetList := {}
local nDoc_no := 0 

Box(,1, 30)
    @ m_x+1, m_y+2 SAY "Broj naloga:" GET nDoc_no PICT "999999999" 
    read
BoxC()

if LastKey() == K_ESC .or. nDoc_no = 0
    return
endif

// sada stampaj nalog nDoc_no
o_tables( )

select docs
set order to tag "1"
seek docno_str( nDoc_no )

if field->doc_no <> nDoc_no
    msgbeep("Trazeni nalog ne postoji !!!")
    return
endif

// stampaj nalog
st_nalpr(.f., nDoc_no)


return


// --------------------------------------------
// rekalkulisanje vrijednosti T_DOCIT stavke
// --------------------------------------------
function recalc_pr()
local aZpoGn := {}
local nTArea := SELECT()

// ukupno mm -> m2
replace field->doc_it_tot with ROUND( c_ukvadrat(field->doc_it_qtt, ;
    field->doc_it_hei, field->doc_it_wid), 2)

replace field->doc_it_tm with ROUND( c_duzinski(field->doc_it_qtt, ;
    field->doc_it_hei, field->doc_it_wid), 2)


aZpoGN := {}
        
// zaokruzi vrijednosti....
_art_set_descr( field->art_id, nil, nil, @aZpoGN, .t. )
    
select (nTArea)

lBezZaokr := .f.

if lBezZaokr == .f.
    // da li je kaljeno ? kod kaljenog nema zaokruzenja
    lBezZaokr := is_kaljeno( aZpoGN, field->doc_no, field->doc_it_no )
endif

if lBezZaokr == .f.
    // da li je emajlirano ? isto nema zaokruzenja
    lBezZaokr := is_emajl(aZpoGN, field->doc_no, field->doc_it_no )
endif

if lBezZaokr == .f.
    // da li je vatroglas ? isto nema zaokruzenja
    lBezZaokr := is_vglass( aZpoGN )
endif

if lBezZaokr == .f.
    // da li je plexiglas ? isto nema zaokruzenja
    lBezZaokr := is_plex( aZpoGN )
endif
    
replace field->doc_it_zhe with ;
    obrl_zaok( field->doc_it_hei, aZpoGN, lBezZaokr )
replace field->doc_it_zh2 with ;
    obrl_zaok( field->doc_it_h2, aZpoGN, lBezZaokr )
replace field->doc_it_zwi with ;
    obrl_zaok( field->doc_it_wid, aZpoGN, lBezZaokr )
replace field->doc_it_zw2 with ;
    obrl_zaok( field->doc_it_w2, aZpoGN, lBezZaokr )
        
// ako se zaokruzuje onda total ide po zaokr.vrijednostima
replace field->doc_it_tot with ROUND( c_ukvadrat( field->doc_it_qtt, ;
    field->doc_it_zhe, ;
    field->doc_it_zwi, ;
    field->doc_it_zh2, ;
    field->doc_it_zw2 ), 2)
replace field->doc_it_tm with ROUND( c_duzinski( field->doc_it_qtt, ;
    field->doc_it_zhe, ;
    field->doc_it_zwi, ;
    field->doc_it_zh2, ;
    field->doc_it_zw2 ), 2)
    
// izracunaj neto
replace field->doc_it_net with ROUND( obrl_neto( field->doc_it_tot, aZpoGN ), 2)
        
return


