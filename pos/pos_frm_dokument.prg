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



static function _o_pos_prepis_tbl()

select (F_PARTN)
if !used()
    O_PARTN
endif

select (F_VRSTEP)
if !used()
    O_VRSTEP
endif

select (F_DIO)
if !used()
    O_DIO
endif

select (F_ODJ)
if !used()
    O_ODJ
endif

select (F_KASE)
if !used()
    O_KASE
endif

select (F_OSOB)
if !used()
    O_OSOB
    set order to tag "NAZ"
endif

select (F_TARIFA)
if !used()
    O_TARIFA 
endif

select (F_VALUTE)
if !used()
    O_VALUTE
endif

select (F_SIFK)
if !used()
    O_SIFK
endif

select (F_SIFV)
if !used()
    O_SIFV
endif

select (F_ROBA)
if !used()
    O_ROBA
endif

select (F_POS_DOKS)
if !used()
    O_POS_DOKS   
endif

select (F_POS)
if !used()
    O_POS
endif

return


// -------------------------------------------
// Stampa azuriranog dokumenta
// -------------------------------------------
function pos_prepis_dokumenta()
local aOpc
private cFilter:=".t."
private ImeKol := {}
private Kol := {}

_o_pos_prepis_tbl()

if !EMPTY(gRNALKum)
    o_doksrc( KUMPATH )
endif

AADD(ImeKol, {"Vrsta", {|| IdVd}})
AADD(ImeKol, {"Broj ",{||PADR(IF(!Empty(IdPos),trim(IdPos)+"-","")+alltrim(BrDok),9)}} )
AADD(ImeKol, {"Fisk.rn", {|| fisc_rn}})

if IzFMKIni("TOPS","StAzurDok_PrikazKolonePartnera","N",EXEPATH)=="D"
    select pos_doks
    SET RELATION TO idgost INTO partn
    AADD(ImeKol,{PADR("Partner",25),{||PADR(TRIM(idgost)+"-"+TRIM(partn->naz),25)}})
endif

AADD(ImeKol,{"VP",{||IdVrsteP}})
AADD(ImeKol,{"Datum",{||datum}})

if gStolovi == "D"
    AADD(ImeKol,{"Sto",{||sto_br}})
else
    AADD(ImeKol,{"Smj",{||smjena}})
endif

AADD(ImeKol,{PADC("Iznos",10),{|| pos_iznos_dokumenta(NIL)}})

if IsPlanika()
  // reklamacije (R)ealizovane, (P)riprema
  AADD(ImeKol,{"Rekl",{||if(idvd == VD_REK, sto, "   ")}})
  AADD(ImeKol,{"Na stanju",{||if(idvd == VD_ZAD, if(EMPTY(sto), "da ", "NE "), "   ")}})
endif

AADD(ImeKol,{"Radnik",{||IdRadnik}})

if gStolovi == "D"
    AADD(ImeKol,{"Zaklj",{||zak_br}})
endif

for i:=1 to LEN(ImeKol)
    AADD(Kol,i)
next

select pos_doks
set cursor on

cVrste:="  "
dDatOd:=DATE()-1
dDatDo:=DATE()

Box(,3,60)
    @ m_x+1,m_y+2 SAY "Datumski period:" GET dDatOd
    @ m_x+1,col()+2 SAY "-" GET dDatDo
    @ m_x+3,m_y+2 SAY "Vrste (prazno svi)" GET cVrste pict "@!"
    read
BoxC()

if !empty(dDatOd).or.!empty(dDatDo)
    cFilter+=".and. Datum>="+cm2str(dDatOD)+".and. Datum<="+cm2str(dDatDo)
endif
if !empty(cVrste)
    cFilter+=".and. IdVd="+cm2str(cVrste)
endif
if !(cFilter==".t.")
    set filter to &cFilter
endif

//set scopebottom to "W"
go top

aOpc := { "<ENTER> Odabir", "<E> eksport" }

if klevel <= "1"
    AADD( aOpc, "<F2> - promjena vrste placanja" )
endif

ObjDBedit( "pos_doks" , MAXROWS() - 10, MAXCOLS() - 3, {|| PrepDokProc (dDatOd, dDatDo) },"  STAMPA AZURIRANOG DOKUMENTA  ", "", nil, aOpc )

close all

return



function PrepDokProc( dDat0, dDat1 )
local cLevel
local cOdg
local nRecNo
local ctIdPos
local dtDatum
local _rec, _id_pos, _id_vd, _dat_dok, _br_dok
local _t_area := SELECT()
local _tbl_filter := DbFilter()
local _rec_no, _ok
local _tbl_pos := "pos_pos"
local _tbl_doks := "pos_doks"
static cIdPos
static cIdVd
static cBrDok
static dDatum
static cIdRadnik

// M->Ch je iz OBJDB
if M->Ch == 0
    return (DE_CONT)
endif

if LASTKEY() == K_ESC
    return (DE_ABORT)
endif

_rec_no := RECNO()

do case

    case Ch == K_F2 .and. kLevel <= "1"

        if pitanje(,"Zelite li promijeniti vrstu placanja?","N")=="D"

            cVrPl:=idvrstep

            if !VarEdit({{"Nova vrsta placanja","cVrPl","Empty (cVrPl).or.P_VrsteP(@cVrPl)","@!",}},10,5,14,74,'PROMJENA VRSTE PLACANJA, DOKUMENT:'+idvd+"/"+idpos+"-"+brdok+" OD "+DTOC(datum),"B1")
                return DE_CONT
            endif

            _rec := dbf_get_rec()
            _rec["idvrstep"] := cVrPl

            my_use_semaphore_off()

            if !pos_semaphores_lock()
                return DE_CONT
            endif

            sql_table_update( nil, "BEGIN" )
            update_rec_server_and_dbf( "pos_doks", _rec, 1, "CONT" )
            sql_table_update( nil, "END" )

            pos_semaphores_unlock()

            my_use_semaphore_on()

            return DE_REFRESH

        endif

        return DE_CONT

    case Ch == K_CTRL_F9

        _id_pos := field->idpos
        _id_vd := field->idvd
        _br_dok := field->brdok
        _dat_dok := field->datum
        
        if pitanje(,"Zelite li zaista izbrisati dokument","N") == "D"
           
            pos_brisi_dokument( _id_pos, _id_vd, _dat_dok, _br_dok )    

            _o_pos_prepis_tbl()
            select ( _t_area )
            set filter to &_tbl_filter
            go top

            return DE_REFRESH
            
        endif

        return DE_CONT

    case Ch == K_ENTER
        
        do case

            // stampanje racuna
            case pos_doks->IdVd==VD_RN
                
                cOdg := "D"
                
                if glRetroakt
                    cOdg := Pitanje(,"Stampati tekuci racun? (D-da,N-ne,S-sve racune u izabranom periodu)","D","DNS")
                endif
                
                if cOdg == "S"

                    ctIdPos := gIdPos
                    seek ctIdPos+VD_RN

                    START PRINT CRET

                    do while !eof() .and. IdPos+IdVd==ctIdPos+VD_RN
                        if (datum <= dDat1)
                            aVezani:={{IdPos, BrDok, IdVd, datum}}
                            StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .f., glRetroakt)
                        endif
                        select pos_doks
                        skip 1
                    enddo

                    END PRINT

                elseif cOdg=="D"

                    aVezani:={{IdPos, BrDok, IdVd, datum}}
                    StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .t.)

                endif

            case pos_doks->IdVd == "16"
                PrepisZad("ZADUZENJE ")
            case pos_doks->IdVd == VD_OTP
                PrepisZad("OTPIS ")
            case pos_doks->IdVd == VD_REK
                PrepisZad("REKLAMACIJA")
            case pos_doks->IdVd == VD_RZS
                PrepisRazd()
            case pos_doks->IdVd == "IN"
                PrepisInvNiv(.t.)
            case pos_doks->IdVd == VD_NIV
                PrepisInvNiv(.f.)
                RETURN (DE_REFRESH)
            case pos_doks->IdVd == VD_PRR
                PrepisKumPr()
            case pos_doks->IdVd == VD_PCS
                PrepisPCS()
            case pos_doks->IdVd == VD_ROP // reklamacija ostali podaci
                StDokROP(.t.)
        endcase
        
    case Ch == ASC("F") .or. Ch == ASC("f")

        // stampa poreske fakture
        aVezani:={{IdPos, BrDok, IdVd, datum}}
        StampaPrep(IdPos, dtos(datum)+BrDok, aVezani, .t., nil, .t.)

        select pos_doks

        f7_pf_traka(.t.)

        select pos_doks

        return (DE_REFRESH)

    case gStolovi == "D" .and. ( Ch == ASC("Z") .or. Ch == ASC("z") )
        
        if pos_doks->idvd == "42"

            PushWa()
            print_zak_br(pos_doks->zak_br)
            o_pregled()
            PopWa()
            select pos_doks
            return (DE_REFRESH)     

        endif

        return (DE_CONT)
    
    
    case Ch == K_CTRL_P

        pos_stampa_dokumenta()
            
    case Ch == ASC("E") .or. Ch == ASC("e")
        
        if Pitanje(, "Eksportovati dokument (D/N) ?", "N" ) == "D"
            // export dokumenta
            pos_prenos_inv_2_kalk( field->idpos, field->idvd, field->datum, field->brdok )
        endif

        return (DE_CONT)

    case Ch == ASC("P") .or. Ch == ASC("p")
             
        _id_pos := field->idpos
        _id_vd := field->idvd
        _br_dok := field->brdok
        _dat_dok := field->datum

        if Pitanje(, "Dokument " + _id_pos + "-" + _id_vd + "-" + _br_dok + " povuci u pripremu (D/N) ?", "N" ) == "N"
            return ( DE_CONT )
        endif

        if field->idvd == VD_INV

            // povrat dokumenta u pripremu
            pos_2_priprz()
            
            // pobrisi dokument sa servera i dbf-a
            pos_brisi_dokument( _id_pos, _id_vd, _dat_dok, _br_dok )
            
            _o_pos_prepis_tbl()
            select pos_doks
            set filter to &_tbl_filter
            go top

            MsgBeep( "Dokument je vracen u pripremu inventure..." )

            return ( DE_REFRESH )

        endif

        return (DE_CONT)


endcase
    
// vrati se tamo gdje si bio
_o_pos_prepis_tbl()
select pos_doks
set filter to &( _tbl_filter )
go ( _rec_no ) 

return (DE_CONT)


// ----------------------------------------------------------
// pregled racuna iz pregleda racuna, opcija "P"
// ----------------------------------------------------------
function PreglSRacun()
local oBrowse
local cPrevCol
local _rec
private ImeKol
private Kol

cPrevCol := SETCOLOR(INVERT)

SELECT F__PRIPR

if !used()
    O__POS_PRIPR
endif

select _pos_pripr

Zapp()

Scatter()

SELECT POS
seek pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

do while !eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok) == pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

    _rec := dbf_get_rec()

    select roba
    HSEEK _rec["idroba"]

    _rec["robanaz"] := roba->naz
    _rec["jmj"] := roba->jmj

    // pobrisi mi polje "rbr" koje pos koristi
    hb_hdel( _rec, "rbr" )

    select _pos_pripr
    append Blank 
 
    dbf_update_rec( _rec )

    SELECT POS
    SKIP

enddo

select _pos_pripr
GO TOP

ImeKol := { { "Sifra", {|| idroba} }, ;
            { "Naziv", {|| LEFT(RobaNaz,30) } }, ;
            { "Kolicina", {|| STR(Kolicina,7,2)}}, ;
            { "Cijena", {|| STR(Cijena,7,2)}}, ;
            { "Iznos", {|| STR(Kolicina*Cijena,11,2)}} }

Kol := {1,2,3,4,5}

Box(, 15, 73 )

@ m_x+1,m_y+19 SAY PADC ("Pregled "+IIF(gRadniRac=="D","stalnog ","")+"racuna "+TRIM(pos_doks->IdPos)+"-"+ LTRIM (pos_doks->BrDok),30) COLOR INVERT

    oBrowse:=FormBrowse(m_x+2,m_y+1,m_x+15,m_y+73,ImeKol,Kol,{"Í","Ä","³"},0)
    ShowBrowse(oBrowse,{},{})

    select _pos_pripr
    Zapp()
BoxC()
    
SETCOLOR (cPrevCol)
select pos_doks

return



