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


// -----------------------------------------
// otvaranje tabele roba - sifrarnik
// -----------------------------------------
function P_Roba(cId, dx, dy, cSeek )
local cRet
local bRoba
local nTArea
local lArtGroup := .f.
local _naz_len := 40
private ImeKol
private Kol

// pretraga po dobavljacu
if cSeek == nil
    cSeek := ""
endif

PushWa()
ImeKol:={}

nTArea := SELECT()

O_ROBA

AADD( ImeKol, { PADC( "ID", 10 ),  ;
        {|| id }, ;
        "id" , {|| .t.}, {|| vpsifra(wId) } } )

AADD( ImeKol, { PADC( "PLU kod", 8 ), ;
        {|| PADR(fisc_plu, 10)}, ;
        "fisc_plu", {|| gen_plu(@wfisc_plu), .f.}, ;
        {|| .t. } })

// kataloski broj
if roba->(fieldpos("KATBR"))<>0
    AADD( ImeKol, { PADC( "KATBR", 14 ), {|| PADR( katBr, 14 ) }, "katbr"   })
endif

// sifra dobavljaca
if roba->(fieldpos( "SIFRADOB" )) <> 0
    AADD( ImeKol, { PADC( "S.dobav.", 13 ), {|| PADR( sifraDob, 13 ) }, "sifradob"   })
endif

// naziv
if glProvNazRobe
    AADD( ImeKol, { PADC( "Naziv", _naz_len ), {|| LEFT( naz, _naz_len ) }, "naz", {|| .t.}, {|| VpNaziv(wNaz)}} )
else
    AADD( ImeKol, { PADC( "Naziv", _naz_len ), {|| LEFT( naz, _naz_len ) }, "naz", {|| .t.}, {|| .t.}})
endif

// jedinica mjere
AADD(ImeKol, {padc("JMJ",3), {|| jmj},       "jmj"    })

// DEBLJINA i TIP
if roba->(fieldpos("DEBLJINA")) <> 0
    AADD(ImeKol, {padc("Debljina",10 ), {|| transform(debljina, "999999.99")}, "debljina", nil, nil, "999999.99" })

    AADD(ImeKol, {padc("Roba tip",10 ), {|| roba_tip}, "roba_tip", {|| .t.}, {|| .t. }})
endif

// STRINGS
if roba->(fieldpos("STRINGS")) <> 0
    AADD(ImeKol, {padc("Strings", 10 ), {|| strings}, "strings", {|| .t.}, {|| .t. }})
endif

// VPC
//if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWVPC"))
    AADD(ImeKol, {padc("VPC",10 ), {|| transform(VPC,"999999.999")}, "vpc" , nil, nil, nil, gPicCDEM  })
//endif

// VPC2
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWVPC2"))
        if IzFMkIni('SifRoba',"VPC2",'D', SIFPATH)=="D"
            AADD(ImeKol, {padc("VPC2",10 ), {|| transform(VPC2,"999999.999")}, "vpc2", NIL, NIL,NIL, gPicCDEM   })
        endif
endif

if roba->(fieldpos("PLC"))<>0  .and. IzFMkIni("SifRoba","PlanC","N", SIFPATH)=="D"
    AADD(ImeKol, {padc("Plan.C",10 ), {|| transform(PLC,"999999.999")}, "PLC", NIL, NIL,NIL, gPicCDEM    })
endif

AADD(ImeKol, { PADC("MPC1",10 ), {|| transform(MPC,"999999.999")}, "mpc", NIL, NIL,NIL, gPicCDEM  })

for i := 2 to 10

    cPom := "mpc" + ALLTRIM(STR(i))
    cPom2 := '{|| transform(' + cPom + ',"999999.999")}'

    if roba->( FieldPos( cPom ) )  <>  0
        
        cPrikazi := fetch_metric( "roba_prikaz_" + cPom, nil, "D" )  

        if cPrikazi == "D"
            AADD( ImeKol, { PADC( UPPER(cPom), 10 ), &(cPom2), cPom , nil, nil, nil, gPicCDEM } )
        endif

    endif

next

if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWNC"))
    AADD(ImeKol, {padc("NC",10 ), {|| transform(NC,gPicCDEM)}, "NC", NIL, NIL, NIL, gPicCDEM  })
endif

AADD(ImeKol, {"Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa), roba_opis_edit()  }   })
AADD(ImeKol, {"Tip",{|| " "+Tip+" "}, "Tip", {|| .t.}, {|| wTip $ " TUCKVPSXY" } ,NIL,NIL,NIL,NIL, 27 } )

// BARKOD
if glAutoFillBK
    AADD (ImeKol,{ padc("BARKOD",14 ), {|| BARKOD}, "BarKod" , {|| WhenBK()} , {|| DodajBK(@wBarkod) }  })
else
    AADD (ImeKol,{ padc("BARKOD",14 ), {|| BARKOD}, "BarKod" , {|| .t. } , {|| DodajBK(@wBarkod), vpsifra( wbarkod, "BARKOD" ) }  })
endif

if roba->(fieldpos("mink"))<>0
    AADD (ImeKol,{ padc("MINK",10 ), {|| transform(MINK,"999999.99")}, "MINK"   })
endif

if roba->(fieldpos("K1"))<>0
    AADD (ImeKol,{ padc("K1",4 ), {|| k1 }, "k1"   })
    AADD (ImeKol,{ padc("K2",4 ), {|| k2 }, "k2", ;
        {|| .t.}, {|| .t.}, nil, nil, nil, nil, 35   })
    AADD (ImeKol,{ padc("N1",12), {|| N1 }, "N1"   })
    AADD (ImeKol,{ padc("N2",12 ), {|| N2 }, "N2", ;
        {|| .t.}, {|| .t.}, nil, nil, nil, nil, 35   })
endif

if roba->(fieldpos("K7"))<>0
    AADD (ImeKol,{ padc("K7",2 ), {|| k7 }, "k7"   })
    AADD (ImeKol,{ padc("K8",2 ), {|| k8 }, "k8"  })
    AADD (ImeKol,{ padc("K9",3 ), {|| k9 }, "k9" })
endif

// AUTOMATSKI TROSKOVI ROBE, samo za KALK
if goModul:oDataBase:cName == "KALK" .and. roba->(fieldpos("TROSK1")) <> 0
    AADD (ImeKol,{ PADR(c10T1,8) ,{|| trosk1 }, "trosk1", {|| .t.}, {|| .t.} })
    AADD (ImeKol,{ PADR(c10T2,8), {|| trosk2 }, "trosk2", ;
        {|| .t. }, {|| .t. }, nil, nil, nil, nil, 30 })
    AADD (ImeKol,{ PADR(c10T3,8), {|| trosk3 }, "trosk3", {|| .t.}, {|| .t.} })
    AADD (ImeKol,{ PADR(c10T4,8), {|| trosk4 }, "trosk4", ;
        {|| .t. }, {|| .t. }, nil, nil, nil, nil, 30 })
    AADD (ImeKol,{ PADR(c10T5,8), {|| trosk5 }, "trosk5"   })
endif

if roba->(fieldpos("ZANIVEL"))<>0
    AADD (ImeKol,{ padc("Nova cijena", 20 ), {|| transform(zanivel,"999999.999")}, "zanivel", NIL, NIL,NIL, gPicCDEM  })
endif
if roba->(fieldpos("ZANIV2"))<>0
    AADD (ImeKol,{ padc("Nova cijena/2", 20 ), {|| transform(zaniv2,"999999.999")}, "zaniv2", NIL, NIL,NIL, gPicCDEM  })
endif

if roba->(fieldpos("IDKONTO"))<>0
    AADD (ImeKol,{ "Id konto",{|| idkonto}, "idkonto", {|| .t. }, {|| EMPTY( widkonto ) .or. P_Konto( @widkonto ) }   })
endif

if roba->(fieldpos("IDTARIFA2"))<>0
    AADD (ImeKol,{ "Tarifa R2",{|| IdTarifa2}, "IdTarifa2", {|| .t. }, {|| set_tar_rs(@wIdTarifa2, wIdTarifa) .or. P_Tarifa(@wIdTarifa2) }   })
    AADD (ImeKol,{ "Tarifa R3",{|| IdTarifa3}, "IdTarifa3", {|| .t. }, {|| set_tar_rs(@wIdTarifa3, wIdTarifa) .or. P_Tarifa(@wIdTarifa3) }   })
endif

Kol := {}

FOR i:=1 TO LEN(ImeKol)
    AADD(Kol,i)
NEXT

select sifk
set order to tag "ID"
seek "ROBA"

do while !eof() .and. ID="ROBA"
    AADD (ImeKol, {  IzSifKNaz("ROBA",SIFK->Oznaka) })
    AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('ROBA','" + sifk->oznaka + "')) }" ) )
    AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
    if sifk->edkolona > 0
        for ii:=4 to 9
                AADD( ImeKol[Len(ImeKol)], NIL  )
        next
        AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
    else
        for ii:=4 to 10
                AADD( ImeKol[Len(ImeKol)], NIL  )
        next
    endif

    // postavi picture za brojeve
    if sifk->Tip="N"
        if f_decimal > 0
                ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina-sifk->f_decimal-1 )+"."+replicate("9",sifk->f_decimal)
        else
                ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
        endif
    endif
    AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )
    skip
enddo

select (nTArea)

bRoba:=gRobaBlock

if !EMPTY(cSeek)
    cPomTag := cSeek
else
    cPomTag := "ID" 
endif

cRet := PostojiSifra(F_ROBA, (cPomTag), 15, MAXCOLS() - 5 , "Lista artikala - robe", @cId, dx, dy, bRoba,,,,,{"ID"})

PopWa()

return cRet




// ---------------------------------------------------
// definisanje opisa artikla u sifrarniku
// ---------------------------------------------------
function roba_opis_edit( view )
local _op := "N"
private getList := {}

if view == NIL
    view := .f.
endif

if !view

    @ m_x + 7, m_y + 43 SAY "Definisati opis artikla (D/N) ?" GET _op PICT "@!" VALID _op $ "DN"

    read

    if _op == "N"
        return .t.
    endif

endif

Box(, 14, 55 )

    @ m_x + 1, m_y + 2 SAY "OPIS ARTIKLA # " + if( !view, "<c-W> za kraj unosa...", "" )

    // otvori memo edit
    wopis := MemoEdit( field->opis, m_x + 3, m_y + 1, m_x + 14, m_y + 55 )

BoxC()

return .t.




// ------------------------------------
// formiranje MPC na osnovu VPC
// ------------------------------------
function MpcIzVpc()

if pitanje(,"Formirati MPC na osnovu VPC ? (D/N)","N")=="N"
    return DE_CONT
endif

private GetList:={}
private nZaokNa:=1
private cMPC:=" "
private cVPC:=" "

Scatter()
select tarifa
hseek _idtarifa
select roba

Box(,4,70)
@ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
@ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
READ
IF EMPTY(cVPC)
    cVPC:=""
ENDIF
IF EMPTY(cMPC)
    cMPC:=""
ENDIF
BoxC()

Box(,6,70)
@ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(LEFT(roba->naz, 40))
@ m_X+2, m_y+2 SAY "TARIFA"
@ m_X+2, col()+2 SAY _idtarifa
@ m_X+3, m_y+2 SAY "VPC"+cVPC
@ m_X+3, col()+1 SAY _VPC&cVPC pict gPicDem
@ m_X+4, m_y+2 SAY "Postojeca MPC"+cMPC
@ m_X+4, col()+1 SAY roba->MPC&cMPC pict gPicDem
@ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict "9"
@ m_X+6, m_y+2 SAY "MPC"+cMPC GET _MPC&cMPC WHEN {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict gPicDem
read
BoxC()
if lastkey()<>K_ESC
    Gather()
        IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je MPC"+cMPC+"=0 ? (D/N)","N")=="D"
            nRecAM:=RECNO()
            Postotak(1,RECCOUNT2(),"Formiranje cijena")
            nStigaoDo:=0
            GO TOP
            DO WHILE !EOF()
                    IF ROBA->MPC&cMPC == 0
                        Scatter()
                        select tarifa
                hseek _idtarifa
                select roba
                        _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa)
                        Gather()
                    ENDIF
                    Postotak(2,++nStigaoDo)
                    SKIP 1
            ENDDO
            Postotak(0)
            GO (nRecAM)
        ENDIF
        return DE_REFRESH
endif
return DE_CONT


// -------------------------------------------------------
// setovanje tarife 2 i 3 u sifrarniku na osnovu idtarifa
// -------------------------------------------------------
function set_tar_rs(cId1, cId2)
if EMPTY(cId1)
    cId1 := cId2
endif
return .t.


function WhenBK()

if EMPTY( wBarKod )
    wBarKod := PADR( wId, LEN( wBarKod ) )
    AEVAL( GetList, {|o| o:display()} )
endif

return .t.



// roba ima zasticenu cijenu
// sto znaci da krajnji kupac uvijek placa fixan iznos pdv-a 
// bez obzira po koliko se roba prodaje
function RobaZastCijena( cIdTarifa )
lZasticena := .f.
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("PDVZ",6))
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("PDV17Z",6))
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("CIGA05",6))

return lZasticena



// ------------------------------------
// setuje u sifk parametre GR1, GR2
// ------------------------------------
function set_sifk_roba_group()

local _seek
local _naziv
local _id
local _rec

SELECT ( F_SIFK )

if !used()
    O_SIFK
endif

SET ORDER TO TAG "ID"
GO TOP
// id + SORT + naz

_id := PADR( "ROBA", SIFK_LEN_DBF ) 
_naziv := PADR( "Grupa 1", LEN(field->naz) )
_seek :=  _id + "01" + _naziv

SEEK _seek   

// dodaj grupa 1 ako ne postoji

if !FOUND()
    
    APPEND BLANK
    _rec := dbf_get_rec()
    _rec["id"] := _id
    _rec["naz"] := _naziv
    _rec["oznaka"] := "GR1"
    _rec["sort"] := "01"
    _rec["tip"] := "C"
    _rec["duzina"] := 20
    _rec["veza"] := "1"

    if !update_rec_server_and_dbf( "sifk", _rec, 1, "FULL" )  
        delete_with_rlock()
    endif

endif

// dodaj grupa 2 ako ne postoji
GO TOP

_id := PADR( "ROBA", SIFK_LEN_DBF ) 
_naziv := PADR( "Grupa 2", LEN(field->naz) )
_seek :=  _id + "02" + _naziv

SEEK _seek   

if !FOUND()
    
    APPEND BLANK
    _rec := dbf_get_rec()
    _rec["id"] := _id
    _rec["naz"] := _naziv
    _rec["oznaka"] := "GR2"
    _rec["sort"] := "02"
    _rec["tip"] := "C"
    _rec["duzina"] := 20
    _rec["veza"] := "1"

    if !update_rec_server_and_dbf( "sifk", _rec, 1, "FULL") 
        delete_with_rlock()
    endif

endif

return .t.


//---------------------------------------------------
//---------------------------------------------------
function OFmkRoba()
O_SIFK
O_SIFV
O_KONTO
O_KONCIJ
O_TRFP
O_TARIFA
O_ROBA
O_SAST
return



// ----------------------------------------------------
// provjera cijena u sifrarniku artikala
// ----------------------------------------------------
function sifre_artikli_provjera_mp_cijena()
local _check := {}
local _i, _n, _x, _mpc
local _line
local _decimal := 2

select ( F_ROBA )
if !Used()
    O_ROBA
endif

MsgO( "Provjera sifrarnika artikala u toku ..." )
go top
do while !EOF()

    // prodji kroz MPC setove    
    for _n := 1 to 9
           
        // MPC, MPC2, MPC3...

        _tmp := "mpc"

        if _n > 1
            _tmp += ALLTRIM(STR( _n ))
        endif

        _mpc := field->&_tmp

        if ABS( _mpc ) - ABS( VAL( STR( _mpc, 12, _decimal ) ) ) <> 0

            _n_scan := ASCAN( _check, { | val | val[1] == field->id  })

            if _n_scan == 0
                // dodaj u matricu...
                AADD( _check, { field->id, field->barkod, field->naz, ;
                            IF( _n == 1, _mpc, 0 ), ;
                            IF( _n == 2, _mpc, 0 ), ;
                            IF( _n == 3, _mpc, 0 ), ;
                            IF( _n == 4, _mpc, 0 ), ;
                            IF( _n == 5, _mpc, 0 ), ;
                            IF( _n == 6, _mpc, 0 ), ;
                            IF( _n == 7, _mpc, 0 ), ;
                            IF( _n == 8, _mpc, 0 ), ;
                            IF( _n == 9, _mpc, 0 ) } )
            else
                // dodaj u postojecu matricu
                _check[ _n_scan, 2 + _n ] := _mpc
            endif

        endif

    next

    skip

enddo

MsgC()

// nema gresaka
if LEN( _check ) == 0
    close all
    return
endif

START PRINT CRET

?

P_COND2

_count := 0
_line := _get_check_line()

? _line

? "Lista artikala sa nepravilnom MPC"

? _line

? PADR( "R.br.", 6 ), PADR( "Artikal ID", 10 ), PADR( "Barkod", 13 ), ;
    PADR( "Naziv artikla", 30 ), ;
    PADC( "MPC1", 15 ), ;
    PADC( "MPC2", 15 ), ;
    PADC( "MPC3", 15 ), ;
    PADC( "MPC4", 15 ), ;
    PADC( "MPC5", 15 ), ;
    PADC( "MPC6", 15 ), ;
    PADC( "MPC7", 15 ), ;
    PADC( "MPC8", 15 ), ;
    PADC( "MPC9", 15 )
 
? _line

for _i := 1 to LEN( _check )

    ? PADL( ALLTRIM(STR( ++ _count )) + ".", 6 )
    // id
    @ prow(), pcol() + 1 SAY _check[ _i, 1 ]
    // barkod
    @ prow(), pcol() + 1 SAY _check[ _i, 2 ]
    // naziv
    @ prow(), pcol() + 1 SAY PADR( _check[ _i, 3 ], 30 )

    // setovi cijena...
    for _x := 1 to 9

        // mpc, mpc2, mpc3...
        _cijena := _check[ _i, 3 + _x ]

        if ROUND( _cijena, 4 ) == 0
            _tmp := PADR( "", 15 )
        else
            _tmp := STR( _cijena, 15, 4 )
        endif

        @ prow(), pcol() + 1 SAY _tmp

    next
next

? _line

FF

close all

END PRINT

return


static function _get_check_line()
local _line := ""

_line += REPLICATE( "-", 6 )
_line += SPACE(1)
_line += REPLICATE( "-", 10 )
_line += SPACE(1)
_line += REPLICATE( "-", 13 )
_line += SPACE(1)
_line += REPLICATE( "-", 30 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )
_line += SPACE(1)
_line += REPLICATE( "-", 15 )

return _line





// --------------------------------------------------
// prikaz izvjestaja duplih barkodova
// --------------------------------------------------
function rpt_dupli_barkod()
local _data

MsgO( "Formiram sql upit ..." )
_data := __dupli_bk_sql()
MsgC()

__dupli_bk_rpt( _data )

return


// -----------------------------------------------
// sql upit
// -----------------------------------------------
static function __dupli_bk_sql()
local _qry, _table
local _server := pg_server()

_qry := "SELECT id, naz, barkod " + ;
        "FROM fmk.roba r1 " + ;
        "WHERE barkod <> '' AND barkod IN ( " + ;
            "SELECT barkod " + ;
            "FROM fmk.roba r2 " + ;
            "GROUP BY barkod " + ;
            "HAVING COUNT(*) > 1 " + ;
        ") " + ;
        "ORDER BY barkod"

_table := _sql_query( _server, _qry )

if _table == NIL
    return NIL
endif

_table:Refresh()

return _table



// -----------------------------------------------
// prikaz duplih barkodova iz sifrarnika
// -----------------------------------------------
static function __dupli_bk_rpt( data )
local _i

if VALTYPE( data ) == "L" .or. LEN( data ) == 0
    MsgBeep( "Nema podataka za prikaz !!!" )
    return
endif

START PRINT CRET

?

? "Dupli barkodovi unutar sifrarnika artikala:"
? "----------------------------------------------------------------------------------"
? "ID             NAZIV                                    BARKOD"
? "----------------------------------------------------------------------------------"

do while !data:EOF()

    _row := data:GetRow()

    ? _row:FieldGet( _row:FieldPos("id") ), ;
        PADR( hb_utf8tostr( _row:FieldGet( _row:FieldPos("naz") ) ), 40 ), ;
        _row:FieldGet( _row:FieldPos("barkod") )

    data:Skip()

enddo

FF
END PRINT

return



// --------------------------------------------------------
// setovanje mpc cijene iz vpc
// --------------------------------------------------------
function roba_setuj_mpc_iz_vpc()
local _params := hb_hash()
local _rec
local _mpc_set
local _tarifa
local _count := 0

if !_get_params( @_params ) 
    return
endif

if !f18_lock_tables( { "roba" } )
    return
endif
sql_table_update( NIL, "BEGIN" )

O_TARIFA
O_ROBA
go top

// koji cu set mpc gledati...
if _params["mpc_set"] == 1
    _mpc_set := "mpc"
else
    _mpc_set := "mpc" + ALLTRIM( STR( _params["mpc_set"] ) )
endif

Box(, 2, 70 )

do while !EOF()

    _rec := dbf_get_rec()

    if !EMPTY( _params["filter_id"] )
        _filt_id := Parsiraj( _params["filter_id"], "id" )
        if !( &_filt_id )
            skip
            loop
        endif
    endif

    // vpc je 0, preskoci...
    if ROUND( _rec["vpc"], 3 ) == 0
        skip
        loop
    endif
    
    // konverzija samo tamo gdje je mpc = 0
    if ROUND( _rec[ _mpc_set ], 3 ) <> 0 .and. _params["mpc_nula"] == "D"
        skip
        loop
    endif

    _tarifa := _rec["idtarifa"]

    if EMPTY( _tarifa )
        skip
        loop
    endif

    select tarifa
    hseek _tarifa

    if !FOUND()
        select roba
        skip 
        loop
    endif

    select roba    

    if tarifa->opp > 0

        // napravi kalkulaciju...
        _rec[ _mpc_set ] := ROUND( _rec["vpc"] * ( 1 + ( tarifa->opp / 100 ) ), 2 )

        // zaokruzi na 5 pf
        if _params["zaok_5pf"] == "D"
	        _rec[ _mpc_set ] := _rec[ _mpc_set ] - zaokr_5pf( _rec[ _mpc_set ] )
        endif

        @ m_x + 1, m_y + 2 SAY PADR( "Artikal: " + _rec["id"] + "-" + PADR( _rec["naz"], 20 ) + "...", 50 )
        @ m_x + 2, m_y + 2 SAY PADR( " VPC: " + ALLTRIM( STR( _rec["vpc"], 12, 3 ) ) + ;
                                " -> " + UPPER( _mpc_set ) + ": " + ALLTRIM( STR( _rec[ _mpc_set ], 12, 3 ) ), 50 )

        update_rec_server_and_dbf( "roba", _rec, 1, "CONT" )

        ++ _count 

        endif
    
    skip

enddo

BoxC()

f18_free_tables( { "roba" } )
sql_table_update( NIL, "END" )

return



static function _get_params( params )
local _ok := .f.
local _x := 1
local _mpc_no := 1
local _zaok_5pf := "D"
local _mpc_nula := "D"
local _filter_id := SPACE(200)

Box(, 10, 65 )

    @ m_x + _x, m_y + 2 SAY "VPC -> MPC..."

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Setovati MPC (1/2/.../9)" GET _mpc_no VALID _mpc_no >= 1 .and. _mpc_no < 10 PICT "9"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Zaokruženje 0.5pf (D/N) ?" GET _zaok_5pf VALID _zaok_5pf $ "DN" PICT "@!"

    ++ _x

    @ m_x + _x, m_y + 2 SAY "Setovati samo gdje je MPC = 0 (D/N) ?" GET _mpc_nula VALID _mpc_nula $ "DN" PICT "@!"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Filter po polju ID:" GET _filter_id PICT "@S40"

    read

BoxC()

if LastKey() == K_ESC
    return _ok
endif

params := hb_hash()
params["mpc_set"] := _mpc_no
params["zaok_5pf"] := _zaok_5pf
params["mpc_nula"] := _mpc_nula
params["filter_id"] := ALLTRIM( _filter_id )

_ok := .t.

return _ok

