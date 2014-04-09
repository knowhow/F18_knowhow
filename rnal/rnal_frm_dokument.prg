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

#include "rnal.ch"
#include "f18_separator.ch"

static l_new
static _doc
static _doc_it
static __item_no
static __art_id
static l_auto_tab
static __dok_x
static __dok_y

// ---------------------------------------------
// edit dokument
// lNewDoc - novi dokument .t. or .f.
// ---------------------------------------------
function ed_document( lNewDoc )

if lNewDoc == nil
    lNewDoc := .f.
endif

l_new := lNewDoc
// otvori radne i pripremne tabele...
o_tables(.t.)
// otvori unos dokumenta
_document()

return



// ---------------------------------------------
// otvara unos novog dokumenta
// ---------------------------------------------
static function _document()
local cHeader
local cFooter
local i
local nX
local nY
local nRet := 1
local cCol1 := "W/B"
local cCol2 := "W+/G"
private ImeKol
private Kol

// x: 22
// y: 77

__dok_x := MAXROWS() - 5
__dok_y := MAXCOLS() - 5

Box(, __dok_x, __dok_y )

l_auto_tab := .f.

select _doc_it
go top
select _doc_ops
go top
select _docs
go top

_doc := _docs->doc_no

// ispisi header i footer
header_footer()

// bilo: 50
m_y += ( __dok_x * 2 )
// bilo: 6
m_x += 6

do while .t.

    if ALIAS() == "_DOCS"
        
        // bilo: 6
        nX := 6
        // bilo: 78
        nY := __dok_y + 1
        
        // bilo: 6
        m_x -= 6
        // bilo: 50
        m_y -= ( __dok_x * 2 )
    
        // prikazi naslov tabele
        _say_tbl_desc( m_x + 1, ;
                m_y + 1, ;
                cCol2, ;
                "*** osnovni podaci", ;
                20 )
        
        docs_kol(@ImeKol, @Kol)
        
    elseif ALIAS() == "_DOC_IT"

        // bilo: 15
        nX := ( __dok_x - 10 )
        // bilo: 49
        nY := ( ( __dok_x * 2 ) - 1 )
        
        // bilo: 6
        m_x += 6
        
        _say_tbl_desc( m_x + 1 , ;
                m_y + 1, ;
                cCol2, ;
                "*** stavke naloga" , ;
                20 )
        
        docit_kol(@ImeKol, @Kol)

    elseif ALIAS() == "_DOC_OPS"

        // bilo: 15
        nX := ( __dok_x - 10 )
        // bilo: 28
        nY := ( __dok_y - ( ( __dok_x * 2 ) - 1 ) )
        // bilo: 50
        m_y += ( __dok_x * 2 )
        
        _say_tbl_desc( m_x + 1,  m_y + 1,  cCol2,   "*** dod.oper.",  20 )
    
        docop_kol( @ImeKol, @Kol )
        
    endif
    
    ObjDBedit( "docum", nX, nY, {|Ch| key_handler(Ch)},"","",,,,,1)

    if LastKey() == K_ESC
    
        if _docs->doc_status == 3
            MsgBeep("Dokument ostavljen za doradu !!!")
        endif
        
        exit
    
    endif

enddo

BoxC()

return nRet


// ---------------------------------------
// prikaz osnovni podaci
// nX - x koord.
// nY - y koord.
// cTxt - tekst
// cColSheme - kolor shema...
// nLeft - poravnanje ulijevo nnn
// ---------------------------------------
function _say_tbl_desc(nX, nY, cColSheme, cTxt, nLeft)

if nLeft == nil
    nLeft := 20
endif

if cColSheme == nil
    @ nX, nY SAY PADR( cTxt, nLeft )
else
    @ nX, nY SAY PADR( cTxt, nLeft ) COLOR cColSheme
endif

return



// -----------------------------------------------------------------------
// vraca broj dokumenta u pripremi
// -----------------------------------------------------------------------
static function get_document_no()
return "dok.broj:" + PADL( ALLTRIM( STR ( _doc ) ), 10 )

// ----------------------------------------------------------------------
// prikazuje broj dokumenta u pripremi
// ----------------------------------------------------------------------
static function show_document_no()
@ 2, 3 SAY get_document_no()
return



// -----------------------------------------------
// prikazi header i footer 
// -----------------------------------------------
static function header_footer()
local i
local nTArea := SELECT()
local cHeader
local cFooter
local cLineClr := "GR+/B"

cFooter := "<TAB> brow.tab "
cFooter += "<c-N> nova "
cFooter += "<c-T> brisi "
cFooter += "<F2> ispravka "
cFooter += "<c-P> stampa "
cFooter += "<a-A> azur."

cHeader := get_document_no()
cHeader += SPACE(5)

if l_new
    cHeader += "UNOS NOVOG DOKUMENTA"
else
    cHeader += "DORADA DOKUMENTA"
endif

cHeader += SPACE(5)
cHeader += "operater: "
cHeader += PADR( ALLTRIM( f18_user() ), 30 )

@ m_x, m_y + 2 SAY cHeader

@ m_x + 6, m_y + 1 SAY REPLICATE( BROWSE_PODVUCI_2, __dok_y + 1 ) COLOR cLineClr

@ m_x + __dok_x - 1, m_y + 1 SAY REPLICATE( BROWSE_PODVUCI, __dok_y + 1 ) COLOR cLineClr

@ m_x + __dok_x, m_y + 1 SAY cFooter

for i := 7 to ( __dok_x - 2 )
    @ m_x + i, m_y + ( __dok_x * 2 ) SAY BROWSE_COL_SEP COLOR cLineClr
next

select (nTArea)

return



// ---------------------------------------------
// setuje matricu kolona tabele _DOCS
// ---------------------------------------------
static function docs_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {PADC("Narucioc", 20), {|| PADR(g_cust_desc( cust_id ), 18) + ".."}, "cust_id" })
AADD(aImeKol, {PADC("Datum", 8), {|| doc_date}, "doc_date", {|| .t.}, {|| .t.} })
AADD(aImeKol, {PADC("Dat.isp", 8), {|| doc_dvr_da}, "doc_dvr_da" })
AADD(aImeKol, {"Vr.isp", {|| PADR(doc_dvr_ti, 5)}, "doc_dvr_ti"  })
AADD(aImeKol, {"Mj.isp", {|| PADR(doc_ship_p,10)}, "doc_ship_p" })
AADD(aImeKol, {"Kontakt", {|| PADR(g_cont_desc( cont_id ), 8) + ".." }, "cont_id" })
AADD(aImeKol, {"Kont.opis", {|| PADR(cont_add_d, 18) + ".."}, "cont_add_d" })
AADD(aImeKol, {"Vrsta p.", {|| doc_pay_id}, "doc_pay_id" })
AADD(aImeKol, {"Prioritet", {|| doc_priori}, "doc_priori" })
AADD(aImeKol, {"Tip", {|| doc_type}, "doc_type" })

for i:=1 to LEN(aImeKol)
    AADD(aKol, i)
next

return


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_IT
// ---------------------------------------------
static function docit_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"R.br", {|| doc_it_no }, "doc_it_no" })
AADD(aImeKol, {"Artikal", {|| PADR(g_art_desc( art_id, nil, .f. ), 18) + ".." }, "art_id" })
AADD(aImeKol, {"sirina", {|| TRANSFORM(doc_it_wid, PIC_DIM()) }, "doc_it_wid" })
AADD(aImeKol, {"visina", {|| TRANSFORM(doc_it_hei, PIC_DIM()) }, "doc_it_hei" })
AADD(aImeKol, {"kol.", {|| TRANSFORM(doc_it_qtt, PIC_QTTY()) }, "doc_it_qtt" })


for i:=1 to LEN(aImeKol)
    AADD(aKol,i)
next

return


// ---------------------------------------------
// setuje matricu kolona tabele _DOC_OP
// ---------------------------------------------
static function docop_kol( aImeKol, aKol )
local i
aImeKol := {}
aKol:={}

AADD(aImeKol, {"dod.oper", {|| PADR(g_aop_desc( aop_id ),10) }, "aop_id"})
AADD(aImeKol, {"atr.dod.oper", {|| PADR( g_aop_att_desc( aop_att_id ), 10 ) }, "aop_att_id" })
AADD(aImeKol, {"dod.opis", {|| PADR(doc_op_des, 13) + ".."}, "doc_op_des" })

for i:=1 to LEN(aImeKol)
    AADD(aKol,i)
next

return


// --------------------------------------------
// --------------------------------------------
static function _show_op_item( x, y )
@ x + ( __dok_x - 10 ), y + 2 SAY "stavka: " + PADR( ALLTRIM( STR( field->doc_it_no ) ), 10 )
return .t.


// ---------------------------------------------
// obrada dogadjaja na tipke tastature
// ---------------------------------------------
static function key_handler()
local nRet := DE_CONT
local nX := m_x
local nY := m_y
local GetList := {}
local nRec := RecNo()
local nDocNoNew := 0
local cDesc := ""
local nArea, oCsvImport
local _art_id, _imported

if ALIAS() == "_DOC_OPS"
    // ispis broja stavke na koju se odnosi operacija
    _show_op_item( nX, nY )
endif

do case 

    // automatski tab
    case l_auto_tab == .t.
            
        KEYBOARD CHR(K_TAB)
        l_auto_tab := .f.
        return DE_REFRESH
            
    // browse tabele
    case Ch == K_TAB

        if ALIAS() == "_DOCS"
        
            _say_tbl_desc( m_x + 1, m_y + 1, ;
                    nil, "*** osnovni podaci", 20 )
            
            select _doc_it
            nRet := DE_ABORT
            
        elseif ALIAS() == "_DOC_IT"
            
            _say_tbl_desc( m_x + 1, m_y + 1, ;
                    nil, "*** stavke naloga", 20 )
            
            __art_id := field->art_id
            __item_no := field->doc_it_no
            
            select _doc_ops
            nRet := DE_ABORT

        elseif ALIAS() == "_DOC_OPS"

            _say_tbl_desc( m_x + 1, m_y + 1, ;
                    nil, "*** dod.oper.", 20 )
            
            select _docs
            nRet := DE_ABORT
            
        endif

    // nove stavke
    case Ch == K_CTRL_N
    
        nRet := DE_CONT

        if ALIAS() == "_DOCS"
        
            if e_doc_main_data( .t. ) == 1
                select _docs
                nRet := DE_REFRESH
                l_auto_tab := .t.
            endif
            
            select _docs
            
        elseif ALIAS() == "_DOC_IT"

            select _docs
            if RECCOUNT2() == 0
                MsgBeep("Nema definisanog naloga !!!")
                select _doc_it
                return DE_CONT
            endif
        
            _doc := field->doc_no
            select _doc_it
            set order to tag "1"
            
            if e_doc_item( _doc, .t. ) <> 0
            
                select _doc_it
                set order to tag "1"
                nRet := DE_REFRESH

            endif
            
            select _doc_it
            set order to tag "1"
    
        elseif ALIAS() == "_DOC_OPS"

            select _docs
            if RECCOUNT2() == 0
                MsgBeep("Nema definisanog naloga !!!")
                select _doc_ops
                return DE_CONT
            endif
            
            select _doc_ops
            
            if e_doc_ops( _doc, .t., __art_id ) <> 0
            
                select _doc_ops
                nRet := DE_REFRESH

            endif
            
            select _doc_ops
            
        endif
                
    case Ch == K_F2 .or. Ch == K_ENTER
    
        nRet := DE_CONT
        
        if RECCOUNT2() == 0
            return nRet
        endif
        
        if ALIAS() == "_DOCS"
        
            if _docs->doc_status == 3
            
                MsgBeep("Ispravka osnovnih podataka onemogucena kod dorade#Opcija promjena sluzi u tu svrhu !!!")
                return DE_CONT
                
            endif
            
            if e_doc_main_data( .f. ) == 1
            
                select _docs
                nRet := DE_REFRESH

            endif

            select _docs
        
        elseif ALIAS() == "_DOC_IT"

            if e_doc_item( _doc, .f. ) <> 0
            
                select _doc_it
                nRet := DE_REFRESH

            endif

            select _doc_it
    
        elseif ALIAS() == "_DOC_OPS"

            if e_doc_ops( _doc, .f., __art_id ) <> 0
            
                select _doc_ops
                nRet := DE_REFRESH

            endif

            select _doc_ops
    
        endif
   
    case Ch == K_CTRL_F9

		// brisanje sve iz stavki ili operacija

		nRet := DE_CONT

   		if ALIAS() == "_DOCS"
			return nRet
		endif

		if ALIAS() == "_DOC_IT" .and. RECCOUNT() > 0
			if docit_delete_all() == 1
				nRet := DE_REFRESH
			endif
		elseif ALIAS() == "_DOC_OPS" .and. RECCOUNT() > 0
			if docop_delete_all() == 1
				nRet := DE_REFRESH
			endif
		endif

 
    case Ch == K_CTRL_T

        nRet := DE_CONT
        
        if ALIAS() == "_DOCS"
        
            if docs_delete() == 1
                
                l_auto_tab := .t.
                KEYBOARD CHR(K_TAB)
                nRet := DE_REFRESH
                
            endif
            
        elseif ALIAS() == "_DOC_IT"

            if docit_delete() == 1
                
                nRet := DE_REFRESH
                
            endif

        elseif ALIAS() == "_DOC_OPS"

            if docop_delete() == 1
            
                nRet := DE_REFRESH
            
            endif
            
        endif

    case UPPER(CHR(Ch)) == "E"
        // export dokumenta
        m_export( _docs->doc_no, nil, .t., .t. )
        return DE_CONT

    case UPPER( CHR( Ch )  ) == "R"

        // promjena rednog broja stavke
        if ALIAS() <> "_DOC_IT"
            return DE_CONT
        endif

        if _change_item_no( field->doc_no, field->doc_it_no )
            return DE_REFRESH
        endif

    case UPPER( CHR( Ch ) ) == "C"

        // import CSV
        if ALIAS() <> "_DOC_IT"
            return DE_CONT
        endif

        oCsvImport := RnalCsvImport():new( _doc )
        if oCsvImport:import()
			select _doc_it
        	go top
			m_x := nX
			m_y := nY
            return DE_REFRESH
		else
			select _doc_it
			go top
        endif


    case UPPER( CHR( Ch ) ) == "S"

        // setovanje artikla za sve stavke
        if ALIAS() <> "_DOC_IT"
            return DE_CONT
        endif

		if Pitanje(, "Postaviti novi artikal za sve stavke (D/N) ?", "D") == "D" .and. set_items_article()
			m_x := nX
			m_y := nY
			return DE_REFRESH
		endif 


    case UPPER( CHR( Ch ) ) == "O"

        // promjena rednog broja stavke
        if ALIAS() <> "_DOCS"
            return DE_CONT
        endif

        // reset broja dokumenta na "0"
        if _reset_to_zero()
            select _docs
            go top
            _doc := field->doc_no
            show_document_no()
            return DE_REFRESH
        endif

    case Ch == K_ALT_C

        nRet := DE_CONT

        if ALIAS() == "_DOC_IT"
            // kopiranje stavki naloga
            if cp_items() <> 0
                nRet := DE_REFRESH
            endif
        else
            msgbeep("Za ovu operaciju pozicionirajte se na#unos stavki naloga !!!")
        endif

        select _doc_it

        m_x := nX
        m_y := nY

        return nRet

    case Ch == K_ALT_A
        
        nRet := DE_CONT

        if ALIAS() == "_DOCS" .and. RECCOUNT2() <> 0 .and. ;
            Pitanje(,"Izvrsiti azuriranje dokumenta (D/N) ?", "D") == "D"
            
            // ima li stavki u nalogu
            if _doc_integ() == 0
                msgbeep("!!! Azuriranje naloga onemoguceno !!!")
                m_x := nX
                m_y := nY
                return DE_CONT
            endif
            
            // busy....
            if field->doc_status == 3
                _g_doc_desc( @cDesc )
            endif

            nDocNoNew := _docs->doc_no
    
            if rnal_set_broj_dokumenta( @nDocNoNew )
                // filuj sve tabele sa novim brojem
                fill__doc_no( nDocNoNew )
            endif

            // insertuj nalog u kumulativ
            if doc_insert( cDesc ) == 1
                select _docs
                l_auto_tab := .t.
                KEYBOARD CHR( K_TAB )
                _doc := 0
                nRet := DE_REFRESH
            else
                select _docs
                l_auto_tab := .t.
                KEYBOARD CHR( K_TAB )            
            endif
        
        elseif ALIAS() <> "_DOCS"
            Msgbeep( "Pozicionirajte se na tabelu osnovnih podataka" )
        endif
        
        return nRet

    case Ch == K_CTRL_P

        // stampa naloga
        nTArea := SELECT()
        select _docs
        
        // ima li stavki u nalogu
        if _doc_integ( .t. ) == 0
            m_x := nX
            m_y := nY
            select ( nTArea )
            return DE_CONT
        endif
            
        select _docs
        
        nDocNoNew := _docs->doc_no

        if rnal_set_broj_dokumenta( @nDocNoNew )
            // filuj sve tabele sa novim brojem
            fill__doc_no( nDocNoNew )
        endif

        select _docs
        go top
        _doc := field->doc_no
        show_document_no()
 
        st_nalpr( .t. , _docs->doc_no )
        
        select (nTArea)
        go top

        nRet := DE_CONT

    case Ch == K_CTRL_O

        // obracunski list......
        nTArea := SELECT()
        select _docs
        
        // ima li stavki u nalogu
        if _doc_integ( .t. ) == 0
            m_x := nX
            m_y := nY
            select ( nTArea )
            return DE_CONT
        endif
            
        select _docs
        
        nDocNoNew := _docs->doc_no

        if rnal_set_broj_dokumenta( @nDocNoNew )
            // filuj sve tabele sa novim brojem
            fill__doc_no( nDocNoNew )
        endif

        select _docs
        go top
        _doc := field->doc_no
        show_document_no()
        
        st_obr_list( .t. , _docs->doc_no )
        
        select (nTArea)
        go top

        nRet := DE_CONT

    case Ch == K_CTRL_R
        
        if ALIAS() == "_DOC_IT" .and. RECCOUNT2() <> 0 
            box_it2( field->doc_no, field->doc_it_no )
        endif

        nRet := DE_CONT
    
    case Ch == K_CTRL_L
       
        nTArea := SELECT() 
        st_label( .t., _docs->doc_no )
        select (nTArea)
        nRet := DE_CONT

endcase

m_x := nX
m_y := nY

return nRet


// ---------------------------------------------------
// vraca broj naloga na 0
// ---------------------------------------------------
static function _reset_to_zero()
local _t_area := SELECT()
local _rec, _t_rec

if Pitanje(, "Resetovati broj dokumenta na 0 (D/N) ?", "N" ) == "N"
    return .f.
endif

// 1) _doc_it
select _doc_it
set order to tag "1"
go top
do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    _rec := dbf_get_rec()
    _rec["doc_no"] := 0
    dbf_update_rec( _rec )
    go ( _t_rec )
enddo
go top

// 2) _doc_it2
select _doc_it2
set order to tag "1"
go top
do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    _rec := dbf_get_rec()
    _rec["doc_no"] := 0
    dbf_update_rec( _rec )
    go ( _t_rec )
enddo
go top

// 3) _doc_ops
select _doc_ops
set order to tag "1" 
go top
do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    _rec := dbf_get_rec()
    _rec["doc_no"] := 0
    dbf_update_rec( _rec )
    go ( _t_rec )
enddo
go top

// 4) _docs
select _docs
set order to tag "1" 
go top
_rec := dbf_get_rec()
_rec["doc_no"] := 0
dbf_update_rec( _rec )

select ( _t_area )
return .t.




// ---------------------------------------------------
// provjera problematicnih stavki naloga
// ---------------------------------------------------
static function _check_orphaned_items()
local _ok := .t.
local _orph := {}
local _t_area := SELECT()
local _t_rec := RECNO()
local _it_no, _doc_no

// 1) provjera operacija
select _doc_ops
set order to tag "1"
go top

if RECCOUNT() > 0

 _doc_no := field->doc_no

 do while !EOF()
    _it_no := field->doc_it_no
    select _doc_it
    set order to tag "1"
    go top
    seek doc_str( _doc_no ) + docit_str( _it_no )
    if !FOUND()
        _scan := ASCAN( _orph, { |val| val[2] == _it_no } )
        if _scan == 0
            AADD( _orph, { _doc_no, _it_no, "operacija" } )
        endif
    endif   
    select _doc_ops 
    skip
 enddo
 select _doc_ops
 go top

endif

// 2) provjera repromaterijala...
select _doc_it2
set order to tag "1"
go top
_doc_no := field->doc_no

do while !EOF()
    _it_no := field->doc_it_no
    select _doc_it
    set order to tag "1"
    go top
    seek doc_str( _doc_no ) + docit_str( _it_no )
    if !FOUND()
        _scan := ASCAN( _orph, { |val| val[2] == _it_no } )
        if _scan == 0
            AADD( _orph, { _doc_no, _it_no, "repromaterijal" } )
        endif
    endif   
    select _doc_it2 
    skip
enddo
select _doc_it2
go top

select _doc_it
set order to tag "1"
go top

select ( _t_area )
go ( _t_rec )

if LEN( _orph ) > 0
    _show_orphaned_items( _orph )
    _ok := .f.
endif

select ( _t_area )

return _ok


// ---------------------------------------------------------
// ---------------------------------------------------------
static function _show_orphaned_items( orph )
local _m_x := m_x
local _m_y := m_y
local _i
local _tmp
private izbor := 1
private opc := {}
private opcexe := {}
private GetList := {}

AADD( opc, PADC( "*** Nepovezane stavke naloga  ( <ESC> - izlaz )", 70 ) )
AADD( opcexe, {|| NIL } )
AADD( opc, "-" )
AADD( opcexe, {|| NIL } )

for _i := 1 to LEN( orph )
    _tmp := PADL( ALLTRIM( STR( _i ) ) + ")", 4 )
    _tmp += " nepovezana stavka " 
    _tmp += ALLTRIM( orph[ _i, 3 ] ) + " trazi broj: " + PADR( ALLTRIM( STR( orph[ _i, 2 ] ) ) , 10 ) 
    AADD( opc, _tmp )
    AADD( opcexe, {|| NIL } )
next

menu_sc( "orph" )

if LastKEY() == K_ESC
    ch := 0
    izbor := 0
endif

m_x := _m_x
m_y := _m_y

return



// ----------------------------------------
// promjeni redni broj !
// ----------------------------------------
static function _change_item_no( docno, docitno )
local _ok := .f.
local _new_it_no := 0
local _rec, _t_rec
local _m_x, _m_y
local _op_count := 0
local _it2_count := 0

_m_x := m_x
_m_y := m_y

Box(, 2, 60 )
    @ m_x + 1, m_y + 2 SAY "*** promjena rednog broja stavke"
    @ m_x + 2, m_y + 2 SAY "Broj " + ALLTRIM( STR( docitno ) ) + " postavi na:" GET _new_it_no ;
            PICT "9999" VALID _change_item_no_valid( _new_it_no, docitno, docno )
    READ
BoxC()

m_x := _m_x
m_y := _m_y

if LastKey() == K_ESC
    return _ok
endif

// 1) promjeni redni broj u stavkama
select _doc_it
_rec := dbf_get_rec()
_rec["doc_it_no"] := _new_it_no
dbf_update_rec( _rec )

// 2) promjeni operacije ako ih ima...
select _doc_ops
set order to tag "1"
go top

do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    if field->doc_it_no == docitno
        ++ _op_count
        _rec := dbf_get_rec()
        _rec["doc_it_no"] := _new_it_no
        dbf_update_rec( _rec )
    endif
    go ( _t_rec )
enddo

set order to tag "1"
go top

// 3) promjeni repromaterijal 
select _doc_it2
set order to tag "1"
go top

do while !EOF()
    skip 1
    _t_rec := RECNO()
    skip -1
    if field->doc_it_no == docitno
        ++ _it2_count
        _rec := dbf_get_rec()
        _rec["doc_it_no"] := _new_it_no
        dbf_update_rec( _rec )
    endif
    go ( _t_rec )
enddo

set order to tag "1"
go top

// 4) vrati se na postojecu tabelu stavki...
select _doc_it

log_write( "F18_DOK_OPER, promjena rednog broja naloga sa " + ALLTRIM( STR( docitno ) ) + ;
            " na " + ALLTRIM( STR( _new_it_no ) ) + ;
            " / broj operacija: " + ALLTRIM( STR( _op_count ) )  + ;
            " / broj stavki repromaterijala: " + ALLTRIM( STR( _it2_count ) ), 3 )

_ok := .t.

return _ok


// --------------------------------------------------
// --------------------------------------------------
static function _change_item_no_valid( it_no, it_old, doc_no )
local _ok := .f.
local _t_rec := RECNO()

if it_no < 1
    MsgBeep( "Redni broj mora biti > 0 !!!" )
    return _ok
endif

if it_no == it_old
    MsgBeep( "Odabran je isti redni broj !!!" )
    return _ok
endif

if it_no >= 1

    select _doc_it
    go top
    seek docno_str( doc_no ) + docit_str( it_no )

    if FOUND()
        MsgBeep( "Redni broj " + ALLTRIM( STR( it_no ) ) + " vec postoji !!!" )
        go ( _t_rec )
        return _ok
    endif

endif

go ( _t_rec )
_ok := .t.

return _ok



// ----------------------------------------
// vraca box sa opisom
// ----------------------------------------
function _g_doc_desc( cDesc )
local GetList := {}

Box( , 5, 70)
    cDesc := SPACE(150)
    @ m_x + 1, m_y + 2 SAY "Unesi opis promjene na nalogu:"
    @ m_x + 3, m_y + 2 SAY "Opis:" GET cDesc VALID !EMPTY(cDesc) PICT "@S60"
    read
BoxC()

ESC_RETURN 0

return 1



// -------------------------------------------
// docs - integritet
// -------------------------------------------
static function _doc_integ( lPrint )
local nTAREA := SELECT()
local nRet := 1
local cTmp := ""
local nItems := 0
local nCustId := 0
local nContId := 0

if lPrint == nil
    lPrint := .f.
endif

select _docs

nCustId := field->cust_id
nContId := field->cont_id

select _doc_it
nItems := RECCOUNT2()

// vrati se gdje si bio...
select ( nTAREA )

if lPrint == .f. .and. ( nItems == 0 .or. nCustId == 0 .or. nContId == 0 )
    nRet := 0
elseif lPrint == .t. .and. ( nItems == 0 )
    nRet := 0
endif

if nItems == 0
    MsgBeep("Nalog mora da sadrzi najmanje 1 stavku !!!")
endif

if lPrint == .f.
    if nCustId == 0
        MsgBeep("Polje narucioca mora biti popunjeno !!!")
    endif
    if nContId == 0
        MsgBeep("Polje kontakta mora biti popunjeno !!!")
    endif
endif

// provjera nepovezanih stavki naloga...
if !_check_orphaned_items() 
    nRet := 0
endif

return nRet



// --------------------------------------------
// opcija brisanja dokumenta
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docs_delete( lSilent )
local nDoc_no
local nDoc_status 
local _vals, _id_fields, _where_bl
local _it_count := 0
local _it2_count := 0
local _op_count := 0

if lSilent == nil
    lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati nalog iz pripreme (D/N) ?!???", "N") == "N"
    return 0
endif

nDoc_no := field->doc_no
nDoc_status := field->doc_status

// 1) brisi dokument
my_rlock()
delete
my_unlock()
my_dbf_pack()

// 2) brisi stavke
select _doc_it
my_flock()
go top
do while !EOF()
    ++ _it_count
    delete
    skip
enddo
my_unlock()
my_dbf_pack()

// 3) brisi pomocne stavke
select _doc_it2
go top
my_flock()
do while !EOF()
    ++ _it2_count
    delete
    skip
enddo
my_unlock()
my_dbf_pack()

// 4) brisi operacije
select _doc_ops
go top
my_flock()
do while !EOF()
    ++ _op_count
    delete
    skip
enddo
my_unlock()
my_dbf_pack()

if nDoc_status == 3
    // ukloni marker sa azuriranog dokumenta (busy)
    set_doc_marker( nDoc_no, 0 )
endif

select _docs
go top

log_write( "F18_DOK_OPER, brisanje naloga iz pripreme broj: " + ;
            ALLTRIM( STR( nDoc_no ) ) + ;
            " / status: " + ALLTRIM( STR( nDoc_status ) ) + ;
            " / broj stavki: " + ALLTRIM( STR( _it_count ) ) + ;
            " / broj dodatnih stavki: " + ALLTRIM( STR( _it2_count ) ) + ;
            " / broj operacija: " + ALLTRIM( STR( _op_count ) ) , 3 )

MsgBeep( "INFO: brisanje naloga broj: " + ALLTRIM( STR( nDoc_no ) ) + ", status: " + ALLTRIM( STR( nDoc_status ) ) + ;
        "#" + ;
        "stavke: " + ALLTRIM( STR( _it_count ) ) + ;
        "#" + ;
        "reprom: " + ALLTRIM( STR( _it2_count ) ) + ;
        "#" + ;
        "operacija: " + ALLTRIM( STR( _op_count ) ) )

return 1



// -------------------------------------------
// brisanje svih zapisa stavki naloga
// -------------------------------------------
static function docit_delete_all( lSilent )
local _ret := 0
local _doc_no

if lSilent == NIL
	lSilent := .f.
endif

if !lSilent .and. Pitanje(, "Izbrisati sve stavke naloga (D/N) ?", "D" ) == "N"
    return _ret
endif

SELECT _docs
_doc_no := field->doc_no

SELECT _doc_it
my_dbf_zap()
my_dbf_pack()

SELECT _doc_ops
my_dbf_zap()
my_dbf_pack()

SELECT _doc_it2
my_dbf_zap()
my_dbf_pack()

SELECT _doc_it
GO TOP
_ret := 1

log_write( "F18_DOK_OPER, brisanje svih stavki naloga iz pripreme broj: " + ALLTRIM( STR( _doc_no ) ), 3 )

MsgBeep( "INFO / brisanje: pobrisane sve stavke naloga " )

return _ret




// --------------------------------------------
// opcija brisanja stavke naloga
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docit_delete( lSilent )
local nDoc_it_no
local nDoc_no
local _art_id, _qtty
local _it2_count := 0
local _op_count := 0

if lSilent == NIL
    lSilent := .f.
endif

if !lSilent .and. Pitanje(, "Izbrisati stavku (D/N) ?", "D" ) == "N"
    return 0
endif

nDoc_no := field->doc_no
nDoc_it_no := field->doc_it_no
_art_id := field->art_id
_qtty := field->doc_it_qtt

// 1) brisi stavku
my_rlock()
delete
my_unlock()
my_dbf_pack()


// 2) brisi operacije
select _doc_ops
set order to tag "1"
go top
seek doc_str( nDoc_no ) + docit_str( nDoc_it_no )

my_flock()
do while !EOF() .and. field->doc_no == nDoc_no ;
        .and. field->doc_it_no == nDoc_it_no

    ++ _op_count
    delete
    skip
enddo
my_unlock()
my_dbf_pack()

// 3) brisi repromaterijal
if !lSilent .and. Pitanje(, "Brisati vezne stavke repromaterijala (D/N) ?", "D" ) == "D"
    select _doc_it2
    set order to tag "1"
    go top
    my_flock()
    seek doc_str( nDoc_no ) + docit_str( nDoc_it_no )
    do while !EOF() .and. field->doc_no == nDoc_no .and. field->doc_it_no == nDoc_it_no
        ++ _it2_count
        delete
        skip
    enddo 
    my_unlock()
endif

// 5) vrati se na pravo podrucje
select _doc_it

log_write( "F18_DOK_OPER, brisanje stavke naloga iz pripreme broj: " + ALLTRIM( STR( nDoc_no ) ) + ;
        " / stavka broj: " + ALLTRIM( STR( nDoc_it_no ) ) + ;
        " / kolicina: " + ALLTRIM( STR( _qtty, 12, 2 ) ) + " / artikal id: " + ALLTRIM( STR( _art_id ) ) + ;
        " / broj operacija: " + ALLTRIM( STR( _op_count ) ) + ;
        " / broj stavki repromaterijala: " + ALLTRIM( STR( _it2_count ) ), 3 )

MsgBeep( "INFO / brisanje: stavka broj: " + ALLTRIM( STR( nDoc_it_no ) ) + ;
            "#" + ;
            "artikal id: " + ALLTRIM( STR( _art_id ) ) + " / kolicina: " + ALLTRIM( STR( _qtty, 12, 2 ) ) + ;
            "#" + ;
            "broj operacija: " + ALLTRIM( STR( _op_count ) ) + ;
            "#" + ;
            "broj reprom: " + ALLTRIM( STR( _it2_count ) ) )

return 1


// --------------------------------------------
// opcija brisanja operacije
// lSilent - tihi nacin rada bez upita
// --------------------------------------------
static function docop_delete( lSilent )
local _doc_no, _doc_it_no, _doc_op_no

if lSilent == NIL
    lSilent := .f.
endif

if !lSilent .and. Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
    return 0
endif

_doc_no := field->doc_no
_doc_it_no := field->doc_it_no
_doc_op_no := field->doc_op_no

my_delete_with_pack()


log_write( "F18_DOK_OPER, brisanje operacije naloga broj: " + ALLTRIM( STR( _doc_no ) ) + ;
            " / stavka broj: " + ALLTRIM( STR( _doc_it_no ) ) + ;
            " / broj operacije: " + ALLTRIM( STR( _doc_op_no ) ), 3 )

return 1



// -------------------------------------------
// brisanje svih zapisa stavki naloga
// -------------------------------------------
static function docop_delete_all( lSilent )
local _ret := 0
local _doc_no

if lSilent == NIL
	lSilent := .f.
endif

if !lSilent .and. Pitanje(, "Izbrisati sve operacije naloga (D/N) ?", "D" ) == "N"
    return _ret
endif

SELECT _docs
_doc_no := field->doc_no

SELECT _doc_ops
my_dbf_zap()
my_dbf_pack()

GO TOP

_ret := 1

log_write( "F18_DOK_OPER, brisanje svih operacija naloga iz pripreme broj: " + ALLTRIM( STR( _doc_no ) ), 3 )

MsgBeep( "INFO / brisanje: pobrisane sve operacije naloga " )

return _ret




// ------------------------------------------------
// validacija vrijednosti, mora se unjeti
// ------------------------------------------------
function must_enter( xVal )
local lRet := .t.

if VALTYPE(xVal) == "C"
    if EMPTY(xVal)
        lRet := .f.
    endif
elseif VALTYPE(xVal) == "N"
    if xVal == 0
        lRet := .f.
    endif
elseif VALTYPE(xVal) == "D"
    if CTOD("") == xVal
        lRet := .f.
    endif
endif

msg_must_enter( lRet )

return lRet

// -----------------------------------------
// poruka za must_enter validaciju
// -----------------------------------------
static function msg_must_enter( lVal )
if lVal == .f.
    MsgBeep("Unos polja obavezan !!!")
endif
return




