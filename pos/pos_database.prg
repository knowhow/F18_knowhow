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


// -------------------------------------------------
// otvaranje pos tabela
// -------------------------------------------------
function o_pos_tables( kum )

my_close_all_dbf()

if kum == NIL
	kum := .t.
endif

if kum 
	O_POS
	O_POS_DOKS
	O_DOKSPF
endif

O_ODJ

O_OSOB
SET ORDER TO TAG "NAZ"

O_VRSTEP
O_PARTN
O_DIO
O_K2C
O_MJTRUR
O_KASE
O_SAST
O_ROBA
O_TARIFA
O_SIFK
O_SIFV
O_PRIPRZ
O_PRIPRG
O__POS
O__POS_PRIPR

if kum
    select pos_doks
else
    select _pos
endif

return



function o_pos_sifre()

O_KASE
O_UREDJ
O_ODJ
O_ROBA
O_TARIFA
O_VRSTEP
O_VALUTE
O_PARTN
O_OSOB
O_STRAD
O_SIFK
O_SIFV

return



// -----------------------------------------------------------------------
// vraca iznos racuna
// -----------------------------------------------------------------------
function pos_iznos_racuna( cIdPos, cIdVD, dDatum, cBrDok )
local _iznos := 0
local _popust := 0
local _total := 0

if PCOUNT() == 0

    cIdPos := pos_doks->IdPos
    cIdVD := pos_doks->IdVD
    dDatum := pos_doks->Datum
    cBrDok := pos_doks->BrDok

endif

select pos
Seek2( cIdPos + cIdVd + DTOS(dDatum) + cBrDok )

do while !EOF() .and. POS->( IdPos + IdVd + DTOS( datum ) + BrDok ) == ( cIdPos + cIdVd + DTOS( dDatum ) + cBrDok )
    _iznos += POS->( kolicina * cijena )
    _popust += POS->( kolicina * ncijena )
    SKIP
enddo

_total := ( _iznos - _popust )

select pos_doks

return _total


// ----------------------------------------
// pos, stanje robe
// ----------------------------------------
function pos_vrati_broj_racuna_iz_fiskalnog( fisc_rn, broj_racuna, datum_racuna )
local _qry, _qry_ret, _table
local _server := pg_server()
local _i, oRow
local _id_pos := gIdPos
local _rn_broj := ""
local _ok := .f.

_qry := " SELECT pd.datum, pd.brdok, pd.fisc_rn, " + ;
        " SUM( pp.kolicina * pp.cijena ) as iznos, " + ;
        " SUM( pp.kolicina * pp.ncijena ) as popust " + ;
        " FROM fmk.pos_pos pp " + ;
        " LEFT JOIN fmk.pos_doks pd " + ;
            " ON pd.idpos = pp.idpos AND pd.idvd = pp.idvd AND pd.brdok = pp.brdok AND pd.datum = pp.datum " + ; 
        " WHERE pd.idpos = " + _sql_quote( _id_pos ) + ;
        " AND pd.idvd = '42' AND pd.fisc_rn = " + ALLTRIM( STR( fisc_rn ) ) + ;
        " GROUP BY pd.datum, pd.brdok, pd.fisc_rn " + ;
        " ORDER BY pd.datum, pd.brdok, pd.fisc_rn "

_table := _sql_query( _server, _qry )
_table:Refresh()
_table:GoTo(1)

if _table:LastRec() > 1

    _arr := {}

    do while !_table:EOF()
        oRow := _table:GetRow()
        AADD( _arr, { oRow:FieldGet(1), oRow:FieldGet(2), oRow:FieldGet(3), oRow:FieldGet(4), oRow:FieldGet(5) } )
        _table:Skip()
    enddo
    
    // imamo vise racuna
    _browse_rn_choice( _arr, @broj_racuna, @datum_racuna )

    _ok := .t.

else

    // jedan ili nijedan...

    if _table:lastRec() == 0
        return _ok
    endif

    _ok := .t.
    oRow := _table:GetRow()
    broj_racuna := oRow:FieldGet( oRow:FieldPos( "brdok" ) )
    datum_racuna := oRow:FieldGet( oRow:FieldPos( "datum" ) )

endif

return _ok




static function _browse_rn_choice( arr, broj_racuna, datum_racuna )
local _ret := 0
local _i, _n
local _tmp
local _izbor := 1
local _opc := {}
local _opcexe := {}
local _m_x := m_x
local _m_y := m_y

for _i := 1 to LEN( arr )

    _tmp := ""
    _tmp += DTOC( arr[ _i, 1 ] )
    _tmp += " racun: "
    _tmp += PADR( PADL( ALLTRIM( gIdPos ), 2 ) + "-" + ALLTRIM( arr[ _i, 2 ]  ), 10 )
    _tmp += PADL( ALLTRIM( STR( arr[ _i, 4 ] - arr[ _i, 5 ], 12, 2 ) ), 10 )

    AADD( _opc, _tmp )
    AADD( _opcexe, {|| "" })
    
next

do while .t. .and. LastKey() != K_ESC
    _izbor := Menu( "choice", _opc, _izbor, .f. )
	if _izbor == 0
        exit
    else
        broj_racuna := arr[ _izbor, 2 ]
        datum_racuna := arr[ _izbor, 1 ]
        _izbor := 0
    endif
enddo

m_x := _m_x
m_y := _m_y

return _ret



// ----------------------------------------
// pos, stanje robe
// ----------------------------------------
function pos_stanje_artikla( id_pos, id_roba )
local _qry, _qry_ret, _table
local _server := pg_server()
local _data := {}
local _i, oRow
local _stanje := 0

_qry := "SELECT SUM( CASE WHEN idvd IN ('16') THEN kolicina WHEN idvd IN ('42') THEN -kolicina WHEN idvd IN ('IN') THEN -(kolicina - kol2) ELSE 0 END ) AS stanje FROM fmk.pos_pos " + ;
        " WHERE idpos = " + _sql_quote( id_pos ) + ;
        " AND idroba = " + _sql_quote( id_roba )

_table := _sql_query( _server, _qry )
_table:Refresh()

oRow := _table:GetRow( 1 )

_stanje := oRow:FieldGet( oRow:FieldPos("stanje"))

if VALTYPE( _stanje ) == "L"
    _stanje := 0
endif

return _stanje



function pos_iznos_dokumenta( lUI )
local cRet := SPACE(13)
local l_u_i
local nIznos := 0
local cIdPos, cIdVd, cBrDok
local dDatum

select pos_doks

cIdPos := pos_doks->idPos
cIdVd := pos_doks->idVd
cBrDok := pos_doks->brDok
dDatum := pos_doks->datum

if ( ( lUI == NIL ) .or. lUI )
    // ovo su ulazi ...
    if pos_doks->IdVd $ VD_ZAD + "#" + VD_PCS + "#" + VD_REK
        select pos
        set order to tag "1"
        go top
        seek cIdPos + cIdVd + DTOS( dDatum ) + cBrDok
        do while !EOF() .and. pos->( IdPos + IdVd + DTOS(datum) + BrDok )==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
            nIznos += pos->kolicina * pos->cijena
            SKIP
        enddo
        if pos_doks->idvd == VD_REK
            nIznos := -nIznos
        endif
    endif
endif

if ( ( lUI == NIL ) .or. !lUI )
    // ovo su, pak, izlazi ...
    if pos_doks->idvd $ VD_RN + "#" + VD_OTP + "#" + VD_RZS + "#" + VD_PRR + "#" + "IN" + "#" + VD_NIV
        select pos
        set order to tag "1"
        go top
        seek cIdPos + cIdVd + DTOS(dDatum) + cBrDok
        do while !EOF() .and. pos->(IdPos+IdVd+DTOS(datum)+BrDok)==cIdPos+cIdVd+DTOS(dDatum)+cBrDok
            do case
                case pos_doks->idvd == "IN"
                    // samo ako je razlicit iznos od 0
                    // ako je 0 onda ne treba mnoziti sa cijenom
                    if pos->kol2 <> 0           
                        nIznos += pos->kol2 * pos->cijena
                    endif
                case pos_doks->IdVd == VD_NIV
                    nIznos += pos->kolicina * ( pos->ncijena - pos->cijena )
                otherwise
                    nIznos += pos->kolicina * pos->cijena
            endcase
            skip
        enddo
    endif
endif

select pos_doks
cRet := STR( nIznos, 13, 2 )

return (cRet)



// ---------------------------------------------------------
// azuriranje zaduzenja...
// ---------------------------------------------------------
function AzurPriprZ(cBrDok, cIdVd)
local _rec, _app, _t_rec
local _cnt := 0
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
local _ok := .t.

SELECT PRIPRZ
GO TOP

set_global_memvars_from_dbf()

// zakljucaj semafore pos-a
if !f18_lock_tables({"pos_pos", "pos_doks", "roba"})
    return
endif

sql_table_update( nil, "BEGIN")

select pos_doks
append blank

_brdok := cBrDok 

// zakljucene stavke
if gBrojSto == "D"
    if cIdVd <> VD_RN
        _zakljucen := "Z"
    endif
endif

if cIdVd == "PD"
    _IdVd := "16"
else
    _IdVd := cIdVd
endif

_app := get_dbf_global_memvars()

update_rec_server_and_dbf( "pos_doks", _app, 1, "CONT" )

SELECT PRIPRZ

// dodaj u datoteku POS
do while !EOF()   
    
    SELECT PRIPRZ

    azur_sif_roba_row()

    SELECT PRIPRZ 

    set_global_memvars_from_dbf()

    SELECT POS
    APPEND BLANK

    _BrDok := cBrDok

    if cIdVd=="PD"
        _IdVd:="16"
    else
        _IdVd:=cIdVd
    endif
    
    if cIdVD=="PD"
        // !prva stavka storno
        _IdVd:="16"
        _IdDio:=_IdVrsteP
        _kolicina:=-_Kolicina
    endif

    _rbr := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

    _app := get_dbf_global_memvars()

    update_rec_server_and_dbf( "pos_pos", _app, 1, "CONT" )

    if cIdVD == "PD"  
        
        // druga stavka
        //append blank
        
        // !druga stavka storno storna = "+"
        _rec := hb_hash()
        _rec["idvd"] := "16"
        _rec["idodj"] := _rec["idvrstep"]  
        _rec["iddio"] := ""
        _rec["idvrstep"] := ""
        _rec["kolicina"] := - _rec["kolicina"]
        _rec["rbr"] := PADL( ALLTRIM( STR( ++ _cnt ) ), 5 )

        update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )
    
    endif

    SELECT PRIPRZ
	SKIP 1
    _t_rec := RECNO()
	SKIP -1

    my_delete()

	GO ( _t_rec )

enddo

f18_free_tables({"pos_pos", "pos_doks", "roba"})
sql_table_update( nil, "END")

SELECT PRIPRZ
my_dbf_pack()

// ova opcija ce setovati plu kodove u sifrarniku ako nisu vec setovani
if fiscal_opt_active() 

    nTArea := SELECT()

    _dev_id := odaberi_fiskalni_uredjaj( NIL, .T., .F. )
    
    if _dev_id > 0
        _dev_params := get_fiscal_device_params( _dev_id, my_user() )
        if _dev_params["plu_type"] == "P"     
            // generisi plu kodove za nove sifre
            gen_all_plu( .t. )
        endif
    endif

    select ( nTArea )

endif

return



// ------------------------------------------------------------------
// pos, uzimanje novog broja za tops dokument
// ------------------------------------------------------------------
function pos_novi_broj_dokumenta( id_pos, tip_dokumenta, dat_dok )
local _broj := 0
local _broj_doks := 0
local _param
local _tmp, _rest
local _ret := ""
local _t_area := SELECT()

if dat_dok == NIL
    dat_dok := gDatum
endif

// param: pos/10/10
_param := "pos" + "/" + id_pos + "/" + tip_dokumenta 
_broj := fetch_metric( _param, nil, _broj )

// konsultuj i doks uporedo
O_POS_DOKS
set order to tag "1"
go top
seek id_pos + tip_dokumenta + DTOS( dat_dok ) + "Ž"
skip -1

if field->idpos == id_pos .and. field->idvd == tip_dokumenta .and. DTOS( field->datum ) == DTOS( dat_dok )
    _broj_doks := VAL( field->brdok )
else
    _broj_doks := 0
endif

// uzmi sta je vece, doks broj ili globalni brojac
_broj := MAX( _broj, _broj_doks )

// uvecaj broj
++ _broj

// ovo ce napraviti string prave duzine...
_ret := PADL( ALLTRIM( STR( _broj ) ), 6  )

// upisi ga u globalni parametar
set_metric( _param, nil, _broj )

select ( _t_area )
return _ret


// ------------------------------------------------------------
// setovanje parametra brojaca na admin meniju
// ------------------------------------------------------------
function pos_set_param_broj_dokumenta()
local _param
local _broj := 0
local _broj_old
local _id_pos := gIdPos
local _tip_dok := "42"

Box(, 2, 60 )

    @ m_x + 1, m_y + 2 SAY "Dokument:" GET _id_pos
    @ m_x + 1, col() + 1 SAY "-" GET _tip_dok

    read

    if LastKey() == K_ESC
        BoxC()
        return
    endif

    // param: pos/10/10
    _param := "pos" + "/" + _id_pos + "/" + _tip_dok
    _broj := fetch_metric( _param, nil, _broj )
    _broj_old := _broj

    @ m_x + 2, m_y + 2 SAY "Zadnji broj dokumenta:" GET _broj PICT "999999"

    read

BoxC()

if LastKey() != K_ESC
    // snimi broj u globalni brojac
    if _broj <> _broj_old
        set_metric( _param, nil, _broj )
    endif
endif

return



// ------------------------------------------------------------
// resetuje brojač dokumenta ako smo pobrisali dokument
// ------------------------------------------------------------
function pos_reset_broj_dokumenta( id_pos, tip_dok, broj_dok )
local _param
local _broj := 0

// param: fakt/10/10
_param := "pos" + "/" + id_pos + "/" + tip_dok
_broj := fetch_metric( _param, nil, _broj )

if VAL( ALLTRIM( broj_dok ) ) == _broj
    -- _broj
    // smanji globalni brojac za 1
    set_metric( _param, nil, _broj )
endif

return



function Del_Skip()
local nNextRec
nNextRec:=0
SKIP
nNextRec:=RECNO()
SKIP -1
my_delete()
GO nNextRec
return



function GoTop2()
GO TOP
if DELETED()
    SKIP
endif
return



/*! \fn SR_ImaRobu(cPom,cIdRoba)
 *  \brief Funkcija koja daje .t. ako se cIdRoba nalazi na posmatranom racunu
 *  \param cPom
 *  \param cIdRoba
 */
 
function SR_ImaRobu( cPom, cIdRoba )
local lVrati:=.f.
local nArr:=SELECT()

SELECT POS
Seek2(cPom+cIdRoba)

if POS->(IdPos+IdVd+dtos(datum)+BrDok+idroba)==cPom+cIdRoba
    lVrati:=.t.
endif

SELECT (nArr)
return (lVrati)



/*! \fn Priprz2Pos()
 *  \brief prebaci iz priprz -> pos,doks
 *  \note azuriranje dokumenata zaduzenja, nivelacija
 *
 */

function Priprz2Pos()
local lNivel
local _rec
local _cnt := 0
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
local _ok := .t.
local _t_rec
local _cnt_no 
local _id_tip_dok
local _dok_count

lNivel:=.f.

SELECT (cRsDbf)
SET ORDER TO TAG "ID"

_dok_count := priprz->(RECCOUNT())

log_write( "F18_DOK_OPER: azuriranje stavki iz priprz u pos/doks, br.zapisa: " + ALLTRIM( STR( _dok_count ) ) , 2 )

Box(, 3, 60 )

// lockuj semafore
if !f18_free_tables({"pos_pos", "pos_doks"})
    MsgC()
    return .f.
endif

sql_table_update( nil, "BEGIN" )

SELECT PRIPRZ
GO TOP

select pos_doks
APPEND BLANK

_rec := dbf_get_rec()
_rec["idpos"] := priprz->idpos
_rec["idvd"] := priprz->idvd
_rec["datum"] := priprz->datum
_rec["brdok"] := priprz->brdok
_rec["vrijeme"] := priprz->vrijeme
_rec["idvrstep"] := priprz->idvrstep 
_rec["idgost"] := priprz->idgost
_rec["idradnik"] := priprz->idradnik
_rec["m1"] := priprz->m1
_rec["prebacen"] := priprz->prebacen
_rec["smjena"] := priprz->smjena

// tip dokumenta
_id_tip_dok := _rec["idvd"]

@ m_x + 1, m_y + 2 SAY "    AZURIRANJE DOKUMENTA U TOKU ..."
@ m_x + 2, m_y + 2 SAY "Formiran dokument: " + ALLTRIM( _rec["idvd"]) + "-" + _rec["brdok"] + " / zap: " + ;
        ALLTRIM( STR( _dok_count ) )

update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )

// upis inventure/nivelacije
SELECT PRIPRZ  

do while !EOF()

    _t_rec := RECNO()

    // dodaj stavku u pos
    SELECT POS  
    APPEND BLANK

    _rec := dbf_get_rec()
    _rec["idpos"] := priprz->idpos
    _rec["idvd"] := priprz->idvd
    _rec["datum"] := priprz->datum
    _rec["brdok"] := priprz->brdok
    _rec["m1"] := priprz->m1
    _rec["prebacen"] := priprz->prebacen
    _rec["iddio"] := priprz->iddio 
    _rec["idodj"] := priprz->idodj
    _rec["idcijena"] := priprz->idcijena
    _rec["idradnik"] := priprz->idradnik
    _rec["idroba"] := priprz->idroba
    _rec["idtarifa"] := priprz->idtarifa
    _rec["kolicina"] := priprz->kolicina
    _rec["kol2"] := priprz->kol2
    _rec["mu_i"] := priprz->mu_i
    _rec["ncijena"] := priprz->ncijena
    _rec["cijena"] := priprz->cijena
    _rec["smjena"] := priprz->smjena
    _rec["c_1"] := priprz->c_1
    _rec["c_2"] := priprz->c_2
    _rec["c_3"] := priprz->c_3
    _rec["rbr"] := PADL( ALLTRIM(STR( ++ _cnt ) ) , 5 ) 

    @ m_x + 3, m_y + 2 SAY "Stavka " + ALLTRIM( STR( _cnt ) ) + " roba: " + _rec["idroba"]

    update_rec_server_and_dbf( "pos_pos", _rec, 1, "CONT" )
    
    SELECT PRIPRZ

    // ako je inventura ne treba nista dirati u sifrarniku...
    if _id_tip_dok <> "IN"
        // azur sifrarnik robe na osnovu priprz
        azur_sif_roba_row()
    endif

    SELECT PRIPRZ
    GO ( _t_rec )
    SKIP

enddo

BoxC()

f18_free_tables({"pos_pos", "pos_doks"})
sql_table_update( nil, "END" )

MsgO("brisem pripremu....")

// ostalo je jos da izbrisemo stavke iz pomocne baze
SELECT PRIPRZ

my_dbf_zap()

MsgC()

return



// ------------------------------------------
// azuriraj sifrarnik robe
// priprz -> roba
// ------------------------------------------
static function azur_sif_roba_row()
local _rec
local _field_mpc
local _update := .f.

select roba
set order to tag "ID"
go top

if gSetMPCijena == "1"
    _field_mpc := "mpc"
else
    _field_mpc := "mpc" + ALLTRIM( gSetMPCijena )
endif

// pozicioniran sam na robi
seek priprz->idroba  

lNovi := .f.

if !FOUND()

    // novi artikal
    // roba (ili sirov)
    append blank

    _rec := dbf_get_rec()
    _rec["id"] := priprz->idroba
    _update := .t.

else

    _rec := dbf_get_rec()

endif

_rec["naz"] := priprz->robanaz
_rec["jmj"] := priprz->jmj

if !IsPDV() 
    // u ne-pdv rezimu je bilo bitno da preknjizenje na pdv ne pokvari
    // star cijene
    if katops->idtarifa <> "PDV17"
        _rec[ _field_mpc ] := ROUND( priprz->cijena, 3 )        
    endif
else

    if cIdVd == "NI"
      // nivelacija - u sifrarnik stavi novu cijenu
      _rec[ _field_mpc ] := ROUND( priprz->ncijena, 3 )
    else
      _rec[ _field_mpc ] := ROUND( priprz->cijena, 3 )
    endif
    
endif

_rec["idtarifa"] := priprz->idtarifa
_rec["k1"] := priprz->k1
_rec["k2"] := priprz->k2
_rec["k7"] := priprz->k7
_rec["k8"] := priprz->k8
_rec["k9"] := priprz->k9
_rec["n1"] := priprz->n1
_rec["n2"] := priprz->n2
_rec["barkod"] := priprz->barkod

update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

return


// ---------------------------------------------------------------
// koriguje broj racuna
// ---------------------------------------------------------------
static function _fix_rn_no( racun )
local _a_rn := {}

if !EMPTY( racun ) .and. ( "-" $ racun )

    _a_rn := TokToNiz( racun, "-" )

    if !EMPTY( _a_rn[2] )
        racun := PADR( ALLTRIM(_a_rn[2]), 6 )
    endif 

endif

return .t.



// ---------------------------------------------------------------
// storniranje racuna po fiskalnom isjecku
// ---------------------------------------------------------------
function pos_storno_fisc_no()
local nTArea := SELECT()
local _rec
local _datum, _broj_rn
local _fisc_broj := 0
private GetList := {}
private aVezani:={}

Box(, 1, 55 )
    @ m_x + 1, m_y + 2 SAY "broj fiskalnog isjecka:" GET _fisc_broj ;
                VALID pos_vrati_broj_racuna_iz_fiskalnog( _fisc_broj, @_broj_rn, @_datum ) ;
                PICT "9999999999"
    read
BoxC()

if LastKey() == K_ESC
    select ( nTArea )
    return
endif

// filuj stavke storno racuna
__fill_storno( _datum, _broj_rn, STR( _fisc_broj, 10 ) )

select (nTArea)

// ovo refreshira pripremu
oBrowse:goBottom()
oBrowse:refreshAll()
oBrowse:dehilite()

do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 )
enddo

return


// -------------------------------------
// storniranje racuna
// -------------------------------------
function pos_storno_rn( lSilent, cSt_rn, dSt_date, cSt_fisc )
local nTArea := SELECT()
local _rec
local _datum := gDatum
local _danasnji := "D"
private GetList := {}
private aVezani:={}

if lSilent == nil
    lSilent := .f.
endif

if cSt_rn == nil
    cSt_rn := SPACE(6)
endif

if dSt_date == nil
    dSt_date := DATE()
endif

if cSt_fisc == nil
    cSt_fisc := SPACE(10)
endif

select ( F_POS )
if !USED()
    O_POS
endif

select ( F_POS_DOKS )
if !USED()
    O_POS_DOKS
endif

Box(, 4, 55 )
    
    @ m_x + 1, m_y + 2 SAY "Racun je danasnji ?" GET _danasnji VALID _danasnji $ "DN" PICT "@!"
    
    read

    if _danasnji == "N"
        _datum := NIL
    endif

    @ m_x + 2, m_y + 2 SAY "stornirati pos racun broj:" GET cSt_rn VALID {|| PRacuni( @_datum, @cSt_rn, .t. ), _fix_rn_no( @cSt_rn ), dSt_date := _datum,  .t. }
    @ m_x + 3, m_y + 2 SAY "od datuma:" GET dSt_date
    
    read
    
    cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

    if EMPTY( cSt_fisc )
        select pos_doks
        seek gIdPos + "42" + DTOS( dSt_date ) + cSt_rn
        cSt_fisc := PADR( ALLTRIM( STR( pos_doks->fisc_rn )), 10 )
    endif

    @ m_x + 4, m_y + 2 SAY "broj fiskalnog isjecka:" GET cSt_fisc
    
    read

BoxC()

if LastKey() == K_ESC
    select ( nTArea )
    return
endif

if EMPTY( cSt_rn )
    select ( nTArea )
    return
endif

select ( nTArea )

// filuj stavke storno racuna
__fill_storno( dSt_date, cSt_rn, cSt_fisc )

select ( F_POS )
use
select ( F_POS_DOKS )
use

select ( nTArea )

if lSilent == .f.

    // ovo refreshira pripremu
    oBrowse:goBottom()
    oBrowse:refreshAll()
    oBrowse:dehilite()

    do while !oBrowse:Stabilize() .and. ( ( Ch := INKEY() ) == 0 )
    enddo

endif

return


// --------------------------------------------------
// filuje pripremu sa storno stavkama
// --------------------------------------------------
static function __fill_storno( rn_datum, storno_rn, broj_fiscal )
local _t_area := SELECT()
local _t_roba, _rec

// napuni pripremu sa stavkama racuna za storno
select ( F_POS )
if !USED()
    O_POS
endif
select pos
seek gIdPos + "42" + DTOS( rn_datum ) + storno_rn

do while !EOF() .and. field->idpos == gIdPos ;
    .and. field->brdok == storno_rn ;
    .and. field->idvd == "42"

    _t_roba := field->idroba

    select roba
    seek _t_roba
    
    select pos

    _rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" ) 
    
    select _pos_pripr
    append blank
    
    _rec["brdok"] :=  "PRIPRE"
    _rec["kolicina"] := ( _rec["kolicina"] * -1 )
    _rec["robanaz"] := roba->naz
    _rec["datum"] := gDatum
    // placanje uvijek resetovati kod storna na gotovinu
    _rec["idvrstep"] := "01"

    if EMPTY( broj_fiscal )
        _rec["c_1"] := ALLTRIM( storno_rn )
    else
        _rec["c_1"] := ALLTRIM( broj_fiscal )
    endif

    dbf_update_rec( _rec )
    
    select pos
    skip

enddo

select pos
use

select ( _t_area )

return



// ---------------------------------------------------------------------
// pos brisanje dokumenta
// ---------------------------------------------------------------------
function pos_brisi_dokument( id_pos, id_vd, dat_dok, br_dok )
local _ok := .t.
local _t_area := SELECT()
local _ret := .f.
local _rec

select pos
set filter to
set order to tag "1"
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if !FOUND()

    // potrazi i u doks
    select pos_doks
    set filter to
    set order to tag "1"
    go top
    seek id_pos + id_vd + DTOS( dat_dok ) + br_dok
    
    // nema ga stvarno !!!
    if !FOUND()    
        select ( _t_area )
        return _ret
    endif

endif 

log_write( "F18_DOK_OPER: pos, brisanje racuna broj: " + br_dok + " od " + DTOC(dat_dok), 2 )
	           	
if !f18_lock_tables({"pos_pos", "pos_doks"})
    select ( _t_area )
    return _ret
endif     

sql_table_update( nil, "BEGIN" )

_ret := .t.          				

MsgO("Brisanje dokumenta iz glavne tabele u toku ...")

select pos
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if FOUND()
    _rec := dbf_get_rec()
    delete_rec_server_and_dbf( "pos_pos", _rec, 2, "CONT" )
endif

select pos_doks
go top
seek id_pos + id_vd + DTOS( dat_dok ) + br_dok

if FOUND() 
    _rec := dbf_get_rec()		
	delete_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
endif

f18_free_tables({"pos_pos", "pos_doks"})
sql_table_update( nil, "END" )

MsgC()

select (_t_area)

return _ret



// -------------------------------------
// povrat racuna u pripremu
// -------------------------------------
function pos_povrat_rn( cSt_rn, dSt_date )
local nTArea := SELECT()
local _rec
private GetList := {}

if EMPTY( cSt_rn )
    select ( nTArea )
    return
endif

cSt_rn := PADL( ALLTRIM(cSt_rn), 6 )

// napuni pripremu sa stavkama racuna za storno
select pos
seek gIdPos + "42" + DTOS(dSt_date) + cSt_rn

msgo("Povrat dokumenta u pripremu ... ")

do while !EOF() .and. field->idpos == gIdPos ;
    .and. field->brdok == cSt_rn ;
    .and. field->idvd == "42"

    cT_roba := field->idroba
    select roba
    seek cT_roba
    
    select pos

    _rec := dbf_get_rec()
    hb_hdel( _rec, "rbr" ) 
    
    select _pos_pripr
    append blank
    
    _rec["robanaz"] := roba->naz

    dbf_update_rec( _rec )

    select pos

    skip

enddo

msgC()

// pos brisi dokument iz baze...
pos_brisi_dokument( gIdPos, VD_RN, dSt_date, cSt_rn )

select ( nTArea )
    
return


// ---------------------------------------------
// import sifrarnika iz fmk
// ---------------------------------------------
function pos_import_fmk_roba()
local _location := fetch_metric( "pos_import_fmk_roba_path", my_user(), PADR( "", 300 ) )
local _cnt := 0
local _rec

O_ROBA

_location := PADR( ALLTRIM( _location ), 300 ) 

Box(, 1, 60)
    @ m_x + 1, m_y + 2 SAY "lokacija:" GET _location PICT "@S50"
    read
BoxC()

if LastKey() == K_ESC
    return
endif

// snimi parametar
set_metric( "pos_import_fmk_roba_path", my_user(), _location )

select ( F_TMP_1 )
if used()
    use
endif

my_use_temp( "TOPS_ROBA", ALLTRIM( _location ), .f., .t. )
index on ("id") tag "ID" 

// ----------
// predji na tops_roba

select tops_roba
set order to tag "ID"
go top

f18_lock_tables({"roba"})
sql_table_update( nil, "BEGIN" )

Box(,1,60)

do while !EOF() 

    _id_roba := field->id

    select roba
    go top
    seek _id_roba

    if !FOUND()
        append blank
    endif
    
    _rec := dbf_get_rec()

    _rec["id"] := tops_roba->id

    _rec["naz"] := tops_roba->naz
    _rec["jmj"] := tops_roba->jmj
    _rec["idtarifa"] := tops_roba->idtarifa
    _rec["barkod"] := tops_roba->barkod
    _rec["tip"] := tops_roba->tip
    _rec["mpc"] := tops_roba->cijena1
    _rec["mpc2"] := tops_roba->cijena2

    if tops_roba->( FieldPOS("fisc_plu") ) <> 0
        _rec["fisc_plu"] := tops_roba->fisc_plu
    endif

    ++ _cnt
    @ m_x + 1, m_y + 2 SAY "import roba: " + _rec["id"] + ":" + PADR( _rec["naz"], 20 ) + "..."
    update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

    select tops_roba
    skip

enddo

BoxC()

f18_free_tables({"roba"})
sql_table_update( nil, "END" )

select ( F_TMP_1 )
use

if _cnt > 0
    msgbeep( "Update " + ALLTRIM( STR( _cnt ) ) + " zapisa !" )
endif

close all
return


