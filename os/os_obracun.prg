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

#include "os.ch"

static __sanacije


// ----------------------------------
// obracun meni
// ----------------------------------
function os_obracuni()
local _izbor := 1
local _opc := {}
local _opcexe := {}

__sanacije := .f.

cTip := IF( gDrugaVal == "D", ValDomaca() , "" )
cBBV := cTip
nBBK := 1

AADD(_opc, "1. amortizacija       ")
AADD(_opcexe, {|| os_obracun_amortizacije() })
AADD(_opc, "2. revalorizacija")
AADD(_opcexe, {|| os_obracun_revalorizacije() })

f18_menu( "obracun", .f., _izbor, _opc, _opcexe )

return


// ----------------------------------
// obracun amortizacije
// ----------------------------------
function os_obracun_amortizacije()
local cAGrupe:="N"
local nRec
local dDatObr
local nMjesOd
local nMjesDo
local cLine := ""
local _rec
local _san := fetch_metric( "os_obracun_sanacija", NIL, "N" )
local _datum_otpisa
local _iznos_sanacije := hb_hash()
local _t_nab := _t_otp := _t_amp := 0
private nGStopa := 100

O_AMORT

o_os_sii()
o_os_sii_promj()

dDatObr:=gDatObr
cFiltK1:=SPACE(40)
cVarPrik := "N"

Box( "#OBRACUN AMORTIZACIJE", 10, 60 )

    do while .t.

        @ m_x + 1, m_y + 2 SAY "Datum obracuna:" GET dDatObr
        @ m_x + 2, m_y + 2 SAY "Varijanta ubrzane amortizacije po grupama ?" GET cAGrupe pict "@!"
        @ m_x + 4, m_y + 2 SAY "Pomnoziti obracun sa koeficijentom (%)" GET nGStopa pict "999.99"
        @ m_x + 5, m_y + 2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
    
        @ m_x + 6, m_y + 2 SAY "Varijanta prikaza"
        @ m_x + 7, m_y + 2 SAY "pred.amort + tek.amort (D/N)?" GET cVarPrik pict "@!" VALID cVarPrik $ "DN"
    
        @ m_x + 9, m_y + 2 SAY "Obracunavati sanacije na sredstvima (D/N) ?" GET _san VALID _san $ "DN" PICT "@!"
        read
        
        ESC_BCR
        aUsl1:=Parsiraj(cFiltK1,"K1")
        if aUsl1<>NIL
            exit
        endif
    enddo
BoxC()

set_metric( "os_obracun_sanacija", NIL, _san )

if _san == "D"
    __sanacije := .t.
endif

select_os_sii()
set order to tag "5"  
if !EMPTY( cFiltK1 )
    set filter to &aUsl1
endif

go top

os_rpt_default_valute()

START PRINT CRET

P_COND2

// stampaj header
_p_header( @cLine, dDatObr, nGStopa, cFiltK1, cVarPrik )

private nOstalo := 0
private nUkupno := 0

do while !eof()
    
    cIdam := field->idam

    select amort
    hseek cIdAm
    
    select_os_sii()
    
    ? cLine
    
    ? "Amortizaciona stopa:", cIdAm, amort->naz, "  Stopa:", amort->iznos, "%"
    
    if nGStopa <> 100
        ?? " ","efektivno ", transform(round(amort->iznos*nGStopa/100,3),"999.999%")
    endif
    
    ? cLine

    private nRGr:=0
    nRGr := RECNO()
    nOstalo := 0

    _t_nab := _t_otp := _t_amp := 0
    
    do while !EOF() .and. field->idam == cIdAm
        
        set_global_memvars_from_dbf()

        // setuj datum otpisa ako postoji
        _datum_otpisa := _datotp
        
        select amort
        hseek _idam

        select_os_sii()
        
        if !EMPTY( _datotp ) .and. YEAR( _datotp ) < YEAR( dDatObr )    
            // otpisano sredstvo, ne amortizuj
            SKIP
            LOOP
        endif

        // izracunaj iznos sanacije ... ako postoji ?
        _iznos_sanacije := os_sii_iznos_sanacije( field->id, ;
                                _datum, ;
                                IIF( !EMPTY(_datotp), ;
                                    MIN( dDatOBr, _datotp ), ;
                                    dDatObr - dana_u_mjesecu( dDatObr ) ;
                                    ) ;
                                )

        // izracunaj amortizaciju do predh.mjeseca...
        nPredAm := izracunaj_os_amortizaciju( _datum, ;
                    IIF( !EMPTY(_datotp), MIN( dDatOBr, _datotp ), dDatObr - dana_u_mjesecu( dDatObr ) ), ;
                      nGStopa, ;
                      _iznos_sanacije ;
                    )     
 
        // izracunaj iznos sanacije ... ako postoji ?
        _iznos_sanacije := os_sii_iznos_sanacije( field->id, ;
                                _datum, ;
                                IIF( !EMPTY( _datotp ), MIN( dDatOBr, _datotp ), dDatObr ) ;
                                )
        
        izracunaj_os_amortizaciju( _datum, ;
                     IIF( !EMPTY( _datotp ), MIN( dDatOBr, _datotp ), dDatObr ), ;
                     nGStopa, ;
                     _iznos_sanacije ;
                     )     
        
        // napuni _amp
        if cAGrupe == "N"
        
            ? _id, _datum, naz
            
            @ prow(), pcol() + 1 SAY _nabvr * nBBK PICT gpici
            @ prow(), pcol() + 1 SAY _otpvr * nBBK PICT gpici
            
            // ako treba prikazivati rasclanjeno...
            if cVarPrik == "D"
                @ prow(), pcol() + 1 SAY nPredAm * nBBK PICT gpici
                @ prow(), pcol() + 1 SAY ( _amp - nPredAm ) * nBBK PICT gpici
            endif
            
            @ prow(),pcol()+1 SAY _amp * nBBK PICT gpici
            @ prow(),pcol()+1 SAY _datotp PICT gpici
            
            nUkupno += ROUND( _amp, 2 )

        endif

        _t_nab += _nabvr
        _t_otp += _otpvr
        _t_amp += _amp
    
        private cId := _id
        
        _rec := get_dbf_global_memvars()

        set device to screen

        update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )

        set device to printer
    
        // amortizacija promjena
        select_promj()
        hseek cId
        
        do while !EOF() .and. field->id == cId .and. field->datum <= dDatObr
                
            set_global_memvars_from_dbf()
            
            if __sanacije .and. LEFT( field->opis, 2 ) == "#S"
                // ovo preskacemo za obracun...
                nPredAm := 0
                _amp := 0
    
                // suma sumarum sanacije... jer moze biti i drugih sredstava i promjena
                _t_amp += _amp
                _t_nab += _nabvr
                _t_otp += _otpvr

            else
                // izracunaj za predh.mjesec...
                nPredAm := izracunaj_os_amortizaciju( _datum, dDatObr - dana_u_mjesecu( dDatObr ), nGStopa )
                izracunaj_os_amortizaciju( _datum, dDatObr, nGStopa )
            endif
 
            if cAGrupe == "N"
                    
                ? space(10), _datum, opis
                    
                @ prow(), pcol() + 1 SAY _nabvr * nBBK PICT gpici
                @ prow(), pcol() + 1 SAY _otpvr * nBBK PICT gpici

                if cVarPrik == "D"
                    @ prow(), pcol() + 1 SAY nPredAm * nBBK PICT gpici
                    @ prow(), pcol() + 1 SAY ( _amp - nPredam ) * nBBK PICT gpici
                endif
                
                @ prow(), pcol() + 1 SAY _amp * nBBK PICT gpici
                @ prow(), pcol() + 1 SAY _datum_otpisa PICT gpici
                    
                nUkupno += ROUND( _amp, 2 )
                
            endif

            _rec := get_dbf_global_memvars()
   
            set device to screen

            update_rec_server_and_dbf( get_promj_table_name( ALIAS() ), _rec, 1, "FULL" )

            set device to printer

            skip

        enddo  

        select_os_sii()
        skip

        // prikaz ukupnog obracuna sanacije...
        if cAGrupe == "N" .and. _iznos_sanacije["nabvr"] <> 0
            ? SPACE( 35 ) + REPLICATE( "-", 60 )
            ? PADL( "Ukupni obracun sanacija:", 50 )
            @ prow(), pcol() + 1 SAY _t_nab PICT gpici
            @ prow(), pcol() + 1 SAY _t_otp PICT gpici
            @ prow(), pcol() + 1 SAY _t_amp PICT gpici
            ? 
        endif

    enddo

    // drugi prolaz
    if cAGrupe == "D"
 
        select_os_sii()
        go nRGr

        do while !eof() .and. field->idam == cIdAm
                
            set_global_memvars_from_dbf()

            // setuj datum otpisa                
            _datum_otpisa := _datotp

            if !Empty(_datotp) .and. YEAR(_datotp) < YEAR(dDatobr)    
                // otpisano sredstvo, ne amortizuj
                skip
                loop
            endif

            if _nabvr > 0
                if _nabvr - _otpvr - _amp > 0  
                    // ostao je neamortizovani dio
                    private nAm2:=MIN(_nabvr - _otpvr - _amp, nOstalo)
                    nOstalo:=nOstalo-nAm2
                    _amp:=_amp+nAm2
                endif
            else
                
                _nabvr:=-_nabvr
                _otpvr:=-_otpvr
                _amp := -_amp
                    
                if _nabvr-_otpvr-_amp > 0  
                    // ostao je neamortizovani dio
                    private nAm2:=MIN((_nabvr-_otpvr-_amp), nOstalo)
                    nOstalo:=nOstalo-nAm2
                    _amp:=_amp+nAm2
                endif
                    
                _nabvr:=-_nabvr
                _otpvr:=-_otpvr
                _amp := -_amp
            endif
        
            ? _id, _datum, naz
                
            @ prow(),pcol()+1 SAY _nabvr*nBBK pict gpici
            @ prow(),pcol()+1 SAY _otpvr*nBBK pict gpici
                
            if cVarPrik == "D"
            
                @ prow(),pcol()+1 SAY 0 pict gpici
                @ prow(),pcol()+1 SAY 0 pict gpici
            
            endif
            
            @ prow(),pcol()+1 SAY _amp*nBBK pict gpici
            @ prow(),pcol()+1 SAY _datotp pict gpici
                
            nUkupno+=round(_amp,2)
            
            private cId := _id
            
            // sinhronizuj podatke sql/server
            _rec := get_dbf_global_memvars()
            
            set device to screen
            
            update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )

            set device to printer  

            // amortizacija promjena
            select_promj()
            hseek cId
                
            do while !eof() .and. field->id == cId .and. field->datum <= dDatObr
                
                set_global_memvars_from_dbf()
                
                if _nabvr>0
                    if _nabvr-_otpvr-_amp>0  
                        // ostao je neamortizovani dio
                        private nAm2:=MIN(_nabvr-_otpvr-_amp, nOstalo)
                        nOstalo:=nOstalo-nAm2
                        _amp:=_amp+nAm2
                    endif
                else
                    _nabvr:=-_nabvr
                    _otpvr:=-_otpvr
                    _amp := -_amp
                    if _nabvr-_otpvr-_amp>0  
                        // ostao je neamortizovani dio
                        private nAm2:=MIN(_nabvr-_otpvr-_amp, nOstalo)
                        nOstalo:=nOstalo-nAm2
                        _amp:=_amp+nAm2
                    endif
                    _nabvr:=-_nabvr
                    _otpvr:=-_otpvr
                    _amp := -_amp
                endif
            
                ? space(10), _datum, _opis
                @ prow(),pcol()+1 SAY _nabvr*nBBK pict gpici
                @ prow(),pcol()+1 SAY _otpvr*nBBK pict gpici
                
                if cVarPrik == "D"
                    @ prow(),pcol()+1 SAY 0 pict gpici
                    @ prow(),pcol()+1 SAY 0 pict gpici
                endif
                
                @ prow(),pcol()+1 SAY _amp*nBBK pict gpici
                    
                nUkupno+=round(_amp,2)
            
                // sinhronizuj podatke sql/server
                _rec := get_dbf_global_memvars()

                set device to screen

                update_rec_server_and_dbf( get_promj_table_name( ALIAS() ), _rec, 1, "FULL" )

                set device to printer
    
                skip

            enddo 
        
            select_os_sii()
            skip

        enddo
    
        ? cLine
        ? "Za grupu ", cIdAm, "ostalo je nerasporedjeno", TRANSFORM( nOstalo*nBBK, gPici )
        ? cLine
    
    endif 
    // grupa

enddo 

? cLine
?
? "Ukupan iznos amortizacije:"

@ prow(),pcol()+1 SAY nUkupno*nBBK pict "99,999,999,999,999"

FF
END PRINT

my_close_all_dbf()
return



// ------------------------------------------------------------------
// prikaz headera
// ------------------------------------------------------------------
static function _p_header( cLine, dDatObr, nGStopa, cFiltK1, cVar)
local cTxt := ""

// linija
cLine := ""
cLine += REPLICATE("-", 10)
cLine += " "
cLine += REPLICATE("-", 8)
cLine += " "
cLine += REPLICATE("-", 29)
cLine += " "
cLine += REPLICATE("-", 12)
cLine += " "
cLine += REPLICATE("-", 11)

if cVar == "D"

    cLine += " "
    cLine += REPLICATE("-", 11)
    cLine += " "
    cLine += REPLICATE("-", 11)

endif

cLine += " "
cLine += REPLICATE("-", 11)
cLine += " "
cLine += REPLICATE("-", 8)

// tekst
cTxt += PADC("INV.BR", 10)
cTxt += " "
cTxt += PADC("DatNab", 8)
cTxt += " "
cTxt += PADC("Sredstvo", 29)
cTxt += " "
cTxt += PADC("Nab.vr", 12)
cTxt += " "
cTxt += PADC("Otp.vr", 11)

if cVar == "D"

    cTxt += " "
    cTxt += PADC("Pred.amort", 11)
    cTxt += " "
    cTxt += PADC("Tek.amort", 11)

endif

cTxt += " "
cTxt += PADC("Amortiz.", 11)
cTxt += " "
cTxt += PADC("Dat.Otp", 8)

?

P_10CPI

? "OS: Pregled obracuna amortizacije", PrikazVal(), SPACE(9), "Datum obracuna:", dDatObr

if (nGStopa <> 100)
    ?
    ? "Obracun se mnozi sa koeficijentom (%) ",transform(nGStopa,"999.99")
    ?
endif

if !EMPTY(cFiltK1)
    ? "Filter grupacija K1 pravljen po uslovu: '" + TRIM(cFiltK1) + "'"
endif

P_COND

?
? cLine
? cTxt
? cLine
?

return



// ----------------------------
// koliko dana ima u mjesecu
// ----------------------------
function dana_u_mjesecu(dDate)
local nDana

do case
    case MONTH(dDate) == 1
        nDana := 31
    case MONTH(dDate) == 2
        nDana := 28
    case MONTH(dDate) == 3
        nDana := 31
    case MONTH(dDate) == 4
        nDana := 30
    case MONTH(dDate) == 5
        nDana := 31
    case MONTH(dDate) == 6
        nDana := 30
    case MONTH(dDate) == 7
        nDana := 31
    case MONTH(dDate) == 8
        nDana := 31
    case MONTH(dDate) == 9
        nDana := 30
    case MONTH(dDate) == 10
        nDana := 31
    case MONTH(dDate) == 11
        nDana := 30
    case MONTH(dDate) == 12
        nDana := 31
endcase

return nDana



// -----------------------------------------------------
// iznos sanacije...
// -----------------------------------------------------
function os_sii_iznos_sanacije( id, datum_od, datum_do )
local _nab := 0
local _otp := 0
local _qry, _data, oRow
local _hash := hb_hash()

_hash["otpvr"] := 0
_hash["nabvr"] := 0
 
if gOsSII == "S" .or. __sanacije == .f.
    return _hash
endif

_qry := "SELECT "
_qry += " id, "
_qry += " opis, "
_qry += " datum, "
_qry += " nabvr, "
_qry += " otpvr "
_qry += "FROM fmk.os_promj "
_qry += "WHERE id = " + _sql_quote( id )
_qry += "  AND opis LIKE '#S%' "
_qry += "  AND " + _sql_date_parse( "datum", datum_od, datum_do )
_qry += "ORDER BY datum "

_data := _sql_query( my_server(), _qry )

if VALTYPE( _data ) == "L" .or. _data:LastRec() == 0
    return _hash
endif

_data:Refresh()
_data:GoTo(1)

do while !_data:EOF()
    oRow := _data:GetRow()
    _nab += oRow:FieldGet( oRow:FieldPos( "nabvr" ) )
    _otp += oRow:FieldGet( oRow:FieldPos( "otpvr" ) )
    _data:SKIP()
enddo

_hash["otpvr"] := _otp
_hash["nabvr"] := _nab

return _hash




// --------------------------------------------
// izracun amortizacije
// d1 - od mjeseca
// d2 - do mjeseca
// nOstalo se uvecava za onaj dio koji se na
// nekom sredstvu ne moze amortizovati
// --------------------------------------------
function izracunaj_os_amortizaciju( d1, d2, nGAmort, sanacije )
local nMjesOd
local nMjesDo
local nIzn
local fStorno
local _san_nab
local _san_otp

// ako je metoda obracuna 1 - odmah
if gMetodObr == "1"
    izr_am_od_dana( d1, d2, nGAmort, sanacije )
    return
endif

if sanacije == NIL
    _san_nab := 0
    _san_otp := 0
else
    _san_nab := sanacije["nabvr"]
    _san_otp := sanacije["otpvr"]
endif

// ako je metoda obracuna od 1 u narednom mjesecu
fStorno := .f.

if ( gVarDio == "D" ) .and. !EMPTY( gDatDio )
    d1 := MAX( d1, gDatDio )
endif

if YEAR(d1) < YEAR(d2)
    nMjesOd := 1
else
    nMjesOd := MONTH(d1) + 1
endif

if DAY(d2) >= 28 .or. gVObracun == "2"
    nMjesDo := MONTH(d2) + 1
else
    nMjesDo := MONTH(d2)
endif

if _nabvr < 0 
    // stornirani dio
    fStorno := .t.
    _nabvr :=- _nabvr
    _otpvr :=- _otpvr
endif

nIzn := ROUND( ( _nabvr - _san_nab ) * ROUND( amort->iznos * IIF( nGamort <> 100, nGamort / 100, 1 ), 3 ) / 100 * ;
        ( nMjesDo - nMjesOD ) / 12, 2 )

_amd := 0

if ( _nabvr - _otpvr - nIzn ) < 0
    _amp := _nabvr - _otpvr
    nOstalo += nIzn - ( _nabvr - _otpvr )
else
    _amp := nIzn
endif

if _amp < 0
    _amp := 0
endif

if fStorno
    _nabvr := -_nabvr
    _optvr := -_otpvr
    _amp := -_amp
endif

return _amp



// --------------------------------------------
// izracun amortizacije 2006 >
// d1 - od mjeseca
// d2 - do mjeseca
// --------------------------------------------
function izr_am_od_dana( d1, d2, nGAmort, sanacije )
local nMjesOd
local nMjesDo
local nIzn
local fStorno
local _san_nab := 0
local _san_otp := 0

if sanacije == NIL
    _san_nab := 0
    _san_otp := 0
else
    _san_nab := sanacije["nabvr"]
    _san_otp := sanacije["otpvr"]
endif

fStorno:=.f.

if ( gVarDio == "D" ) .and. !EMPTY( gDatDio )
    d1 := MAX( d1, gDatDio )
endif

nTekMjesec := MONTH(d1)
nTekDan := DAY(d1)
nTekBrDana := dana_u_mjesecu(d1)

if YEAR(d1) < YEAR(d2)
    nMjesOd := 1
else
    nMjesOd := MONTH(d1) + 1
endif

if DAY(d2) >= 28 .or. gVObracun == "2"
    nMjesDo := MONTH(d2) + 1
else
    nMjesDo := MONTH(d2)
endif

if _nabvr < 0 
    // stornirani dio
        fStorno:=.t.
        _nabvr := -_nabvr
        _otpvr := -_otpvr
endif

nIzn := 0

if YEAR(d1) == YEAR(d2)
    // tekuci mjesec
    // samo za tekucu sezonu
    nIzn += ROUND( ( _nabvr - _san_nab ) * ROUND( amort->iznos * iif(nGamort<>100, nGamort/100, 1), 3) / 100 * (((nTekBrDana - nTekDan) / nTekBrDana ) / 12), 2)
endif

// ostali mjeseci
nIzn += ROUND( ( _nabvr - _san_nab ) * ROUND( amort->iznos * iif(nGamort<>100, nGamort/100, 1), 3) / 100 * (nMjesDo - nMjesOd) / 12, 2)

_amd := 0

if (_nabvr - _otpvr - nIzn) < 0
    _amp := _nabvr-_otpvr
    nOstalo += nIzn - ( _nabvr - _otpvr )
else
    _amp := nIzn
endif

if _amp < 0
    _amp := 0
endif

if fStorno
    _nabvr := -_nabvr
    _optvr := -_otpvr
    _amp := -_amp
endif

return _amp




function os_obracun_revalorizacije()

local  cAGrupe:="D",nRec,dDatObr,nMjesOd,nMjesDo
local nKoef

O_REVAL
o_os_sii()
o_os_sii_promj()

dDatObr:=gDatObr
cFiltK1:=SPACE(40)

Box("#OBRACUN REVALORIZACIJE",3,60)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Datum obracuna:" GET dDatObr
  @ m_x+2,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

select_os_sii()
set order to tag "5"

if !EMPTY(cFiltK1)
  set filter to &aUsl1
endif
go top


m:="---------- -------- ---- ---------------------------- ------------- ----------- ----------- ----------- ----------- -------"

os_rpt_default_valute()

start print cret

P_COND
? "OS: Pregled obracuna revalorizacije",PrikazVal(),space(9),"Datum obracuna:",dDatObr

if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif

? m
? " INV.BR     DatNab  S.Rev     Sredstvo                  Nab.vr      Otp.vr+Am   Reval.DUG    Rev.POT    Rev.Am    Stopa"
? m

nURevDug:=0
nURevPot:=0
nURevAm:=0
do while !eof()
  Scatter()
  if !empty(_datotp)  .and. year(_datotp)<year(dDatobr)    // otpisano sredstvo, ne amortizuj
        skip
        loop
  endif
  select reval; hseek _idrev; select_os_sii()
  nRevAm:=0
  nKoef:=izracunaj_os_reval(_datum,iif(!empty(_datotp),min(dDatOBr,_datotp),dDatObr),@nRevAm)     // napuni _revp,_revd
   ? _id,_datum,_idrev,_naz
   @ prow(),pcol()+1 SAY _nabvr*nBBK     pict gpici
   @ prow(),pcol()+1 SAY _otpvr*nBBK+_amp*nBBK     pict gpici
   @ prow(),pcol()+1 SAY _revd*nBBK       pict gpici
   @ prow(),pcol()+1 SAY _revp*nBBK-nRevAm*nBBK  pict gpici
   @ prow(),pcol()+1 SAY nRevAm*nBBK       pict gpici
   @ prow(),pcol()+1 SAY nkoef       pict "9999.999"
   nURevDug+=_revd
   nURevPot+=_revp
   nURevAm+=nRevAm
  Gather()
  private cId:=_id
  select_promj(); hseek cid
  do while !eof() .and. id==cid .and. datum<=dDatObr
    Scatter()
    nRevAm:=0
    nKoef:=izracunaj_os_reval(_datum,iif(!empty(_datotp),min(dDatOBr,_datotp),dDatObr),@nRevAm)
    ? space(10),_datum,_idrev,_opis
    @ prow(),pcol()+1 SAY _nabvr*nBBK      pict gpici
    @ prow(),pcol()+1 SAY _otpvr*nBBK+_amp*nBBK pict gpici
    @ prow(),pcol()+1 SAY _revd*nBBK       pict gpici
    @ prow(),pcol()+1 SAY _revp*nBBK-nRevAm*nBBK  pict gpici
    @ prow(),pcol()+1 SAY nRevAm*nBBK       pict gpici
    @ prow(),pcol()+1 SAY nkoef       pict "9999.999"
    nURevDug+=_revd
    nURevPot+=_revp
    nURevAm+=nRevAm
    Gather()
    skip
  enddo

  select_os_sii()
  skip
enddo
? m
?
?
? "Revalorizacija duguje           :", nURevDug*nBBK
?
? "Revalorizacija otp.vr potrazuje :", nURevPot*nBBK-nURevAm*nBBK
? "Revalorizacija amortizacije     :", nURevAm*nBBK
? "Ukupno revalorizacija potrazuje :", nURevPot*nBBK

? "------------------------------------------------------"
? "UKUPNO EFEKAT REVALORIZACIJE :", nURevDug*nBBK-nURevPot*nBBK
? "------------------------------------------------------"
?
FF
end print
closeret
return




*************************
* d1 - od mjeseca, d2 do
*************************
function izracunaj_os_reval(d1,d2,nRevAm)

// nRevAm - iznos revalorizacije amortizacije
local nTrecRev
local nMjesOD,nMjesDo,nIzn,nIzn2,nk1,nk2,nkoef

  if year(d1) < year(d2)
    PushWa()
    select reval
    nTrecRev:=recno()
    seek str(year(d1),4)
    if found()
      nMjesOd:=month(d1)+1
      c1:="I"+alltrim(str(nMjesOd-1))
      nk1:=reval->&c1
      nMjesod:=-100
    else
      nMjesOd:=1
    endif
    go nTrecRev // vrati se na tekucu poziciju
    PopWa()
  else
    //nMjesOd:=iif(day(d1)>1,month(d1)+1,month(d1))
    nMjesOd:=month(d1)+1
  endif
  if day(d2)>=28 .or. gVObracun=="2"
    nMjesDo:=month(d2)+1
  else
    nMjesDo:=month(d2)
  endif
  private c1,c2:=""
  c1:="I"+alltrim(str(nMjesOd-1))
  c2:="I"+alltrim(str(nMjesDo-1))
  if nMjesOd<>-100  // ako je -100 onda je vec formiran nK1
   if (nMjesod-1)<1
     nk1:=0
   else
     nk1:=reval->&c1
   endif
  endif

  if (nMjesdo-1)<1
     nk2:=0
  else
     nk2:=reval->&c2
  endif
  nkoef:=(nk2+1)/(nk1+1) - 1
  nIzn :=round( _nabvr * nkoef   ,2)
  nIzn2:=round( (_otpvr+_amp) * nkoef  ,2)
  nRevAm:=round(_amp*nkoef,2)
  _RevD:=nIzn
  _RevP:=nIzn2
  if d2<d1 // mjesdo < mjesod
   _REvd:=0
   _revp:=0
   nkoef:=0
  endif
return nkoef


