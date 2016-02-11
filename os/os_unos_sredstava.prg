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

#include "f18.ch"


static function _o_tables()
O_K1
O_RJ
O_KONTO
O_AMORT
O_REVAL
o_os_sii()
o_os_sii_promj()
return


function unos_osnovnih_sredstava()
local _rec
local _id_am
private cId := SPACE(10)
private cIdRj := SPACE(4)

Box("#UNOS PROMJENA NAD STALNIM SREDSTVIMA", maxrows()-5, maxcols()-5 )
    
    do while .t.

        BoxCLS()

        _o_tables()

        SET CURSOR ON

        cPicSif := IIF( gPicSif="V", "@!", "" )

        IF gIBJ == "D"

            @ m_x + 1, m_y + 2 SAY "Sredstvo:       " GET cId VALID P_OS( @cId, 1, 35) PICT cPicSif

            READ

            _t_area := SELECT()

            select_os_sii()
            go top
            seek cId    
            cIdRj := field->idrj
            _id_am := field->idam

            select ( _t_area )
    
            @ m_x + 2, m_y + 2 SAY "Radna jedinica: " GET cIdRj VALID {|| P_RJ( @cIdRj, 2, 35 ), cIdRj := PADR( cIdRj, 4 ), .t. }

            READ

            ESC_BCR

        ELSE

            DO WHILE .t.

                @ m_x + 1, m_y + 2 SAY "Sredstvo:       " GET cId PICT cPicSif
                @ m_x + 2, m_y + 2 SAY "Radna jedinica: " GET cIdRj
                READ

                ESC_BCR

                select_os_sii()
                SEEK cId
                _id_am := field->idam
                
                DO WHILE !EOF() .and. cId == field->id .and. cIdRJ != field->idrj
                    SKIP 1
                ENDDO

                IF cID != field->id .or. cIdRJ != field->idrj
                    Msg( "Izabrano sredstvo ne postoji!", 5 ) 
                ELSE
                    SELECT RJ
                    SEEK cIdRj
                    
                    if gOsSii == "O"
                        @ m_x+1, m_y+35 SAY os->naz
                    else
                        @ m_x+1, m_y+35 SAY sii->naz
                    endif

                    @ m_x+2, m_y+35 SAY RJ->naz

                    EXIT

                ENDIF

            ENDDO

        ENDIF

        select amort
        HSEEK _id_am

        select_os_sii()

        IF ( cIdrj <> field->idrj )

            IF Pitanje(,"Jeste li sigurni da zelite promijeniti radnu jedinicu ovom sredstvu? (D/N)"," ")=="D"
                _rec := dbf_get_rec()
                _rec["idrj"] := cIdRj
                update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )
            ELSE
                cIdRj := field->idrj
                SELECT RJ
                SEEK cIdRj
                select_os_sii()
                @ m_x+2,m_y+2 SAY "Radna jedinica: " GET cIdRj
                @ m_x+2,m_y+35 SAY RJ->naz
                CLEAR GETS
            ENDIF
        ENDIF

        @ m_x+3, m_y+2 SAY "Datum nabavke: "
        ?? field->datum

        if !empty(field->datotp)
            @ m_x+3, m_y+38 SAY "Datum otpisa: "
            ?? field->datotp
        endif

        @ m_x+4, m_y + 2 SAY "Nabavna vr.:"
        ?? transform( field->nabvr, gPicI )
        @ m_x+4, col() + 2 SAY "Ispravka vr.:"
        ?? transform( field->otpvr, gPicI )
        aVr := { field->nabvr, field->otpvr, 0 }

        // recno(), datum, DatOtp, NabVr, OtpVr, KumAmVr
        aSred := { { 0, field->datum, field->datotp, field->nabvr, field->otpvr, 0 } }

        private dDatNab := field->datum
        private dDatOtp := field->datotp
        private cOpisOtp := field->opisotp

        select_promj()

        ImeKol:={}

        AADD(ImeKol, { "DATUM",            {|| datum }                          })
        AADD(ImeKol, { "OPIS",             {|| opis }                          })
        AADD(ImeKol, { PADR("Nabvr",11),   {|| transform( nabvr, gpici )}     })
        AADD(ImeKol, { PADR("OtpVr",11),   {|| transform( otpvr, gpici )}     })
        AADD(ImeKol, { PADR("Kumul.SadVr",11), {|| transform( PSadVr(), gpici )}     })

        Kol:={}

        for i:=1 to len(ImeKol)
            AADD(Kol,i)
        next

        set cursor on

        @ m_x+20,m_y+2 SAY "<ENT> Ispravka, <c-T> Brisi, <c-N> Nove prom, <c-O> Otpis, <c-I> Novi ID"

        ShowSadVr()

        DO WHILE .t.
            BrowseKey( m_x+8, m_y+1, m_x + maxrows() - 5, m_y + maxcols()-5, ImeKol, {|Ch| unos_os_key_handler(Ch)},"id==cid", cId, 2, NIL, NIL, {|| PSadVr()<0})
            IF (aVr[1]-aVr[2] >= 0)
                IF aVr[3]<0
                    MsgBeep("Greska: sadasnja vrijednost sa uracunatom amortizacijom manja od nule! #Ispravite gresku!")
                ELSE
                    EXIT
                ENDIF
            ELSE
                MsgBeep("Greska: sadasnja vrijednost manja od nule ! Ispravite gresku !")
            ENDIF
            EXIT  

        ENDDO

    my_close_all_dbf()
    enddo

BoxC()

my_close_all_dbf()

return


function unos_os_key_handler(Ch)
local cDn := "N"
local nRet := DE_CONT
local nRec0 := RECNO()
local _rec
local _t_rec
local _novi
local _prom_dat, _prom_opis, _prom_nv, _prom_ov

do case

    case ( Ch == K_ENTER .and. !(EOF() .or. BOF())) .or. Ch == K_CTRL_N

        if Ch == K_CTRL_N
            go bottom
            skip 1
        endif

        _rec := dbf_get_rec()

        _prom_dat := _rec["datum"]
        _prom_opis := _rec["opis"]
        _prom_nv := _rec["nabvr"]
        _prom_ov := _rec["otpvr"]

        Box(,5,50)
            @ m_x + 1, m_y + 2 SAY "Datum:" GET _prom_dat valid os_validate_date( @_prom_dat )
            @ m_x + 2, m_y + 2 SAY "Opis:"  GET _prom_opis
            @ m_x + 4, m_y + 2 SAY "nab vr" GET _prom_nv PICT "9999999.99"
            @ m_x + 5, m_y + 2 SAY "OTP vr" GET _prom_ov PICT "9999999.99"
            read
        BoxC()

        if LASTKEY() == K_ESC
            GO (nRec0)
            nRet := DE_CONT
        else

            if CH == K_CTRL_N
                append blank
            endif

            _rec["id"] := cId
            _rec["opis"] := _prom_opis
            _rec["datum"] := _prom_dat
            _rec["nabvr"] := _prom_nv
            _rec["otpvr"] := _prom_ov

            update_rec_server_and_dbf( get_promj_table_name( ALIAS() ), _rec, 1, "FULL" )
    
            ShowSadVr()

            nRet:=DE_REFRESH

        endif

    case Ch == K_CTRL_T
        
        IF pitanje(,"Sigurno zelite izbrisati promjenu ?","N")=="D"
            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( get_promj_table_name( ALIAS() ), _rec, 1, "FULL" )
            ShowSadVr()
        ENDIF

        return DE_REFRESH

    case Ch == K_CTRL_O
        
        select_os_sii()
        nKolotp := field->kolicina
        
        Box(,5,50)

            @ m_x+1,m_y+2 SAY "Otpis sredstva"
            @ m_x+3,m_y+2 SAY "Datum: " GET dDatOtp VALID dDatOtp>dDatNab .or. empty(dDatOtp)
            @ m_x+4,m_y+2 SAY "Opis : " GET cOpisOtp

            IF field->kolicina > 1
                @ m_x+5,m_y+2 SAY "Kolicina koja se otpisuje:" GET nKolotp PICT "999999.99" VALID ( nKolotp <= field->kolicina .and. nKolotp >= 1 )
            ENDIF

            READ

        BoxC()

        IF LASTKEY() == K_ESC
            select_promj()
            RETURN DE_CONT
        ENDIF

        fRastavljeno := .f.

        if nKolotp < field->kolicina
            
            select_os_sii()

            _rec := dbf_get_rec()

            nNabVrJ := _rec["nabvr"] / _rec["kolicina"]
            nOtpVrJ := _rec["otpvr"] / _rec["kolicina"]

            // postojeci inv broj
            _rec["kolicina"] := _rec["kolicina"] - nKolOtp
            _rec["nabvr"] := nNabVrj * _rec["kolicina"]
            _rec["otpvr"] := nOtpVrj * _rec["kolicina"]
            
            update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )

            // dodaj novi zapis...
            _rec := dbf_get_rec()
           
            APPEND BLANK
 
            _rec["kolicina"] := nKolOtp
            _rec["nabvr"] := nNabvrj * nKolotp
            _rec["otpvr"] := nOtpvrj * nKolotp
            _rec["id"] := LEFT( _rec["id"], 9 ) + "O"
            _rec["datotp"] := dDatotp
            _rec["opisotp"] := cOpisOtp
            
            update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )

            fRastavljeno := .t.

        else

            select_os_sii()

            _rec := dbf_get_rec()
            _rec["datotp"] := dDatOtp
            _rec["opisotp"] := cOpisOtp

            update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )

        endif

        select_promj()

        @ m_x+5, m_y+38 SAY "Datum otpisa: "
        
        if gOsSii == "O"
            ?? os->datotp
        else
            ?? sii->datotp
        endif

        if fRastavljeno
            Msg("Postojeci inv broj je rastavljen na dva-otpisani i neotpisani")
            RETURN DE_ABORT
        else
            RETURN DE_REFRESH
        endif

    case Ch == K_CTRL_I

        Box(,4,50)
            _novi := SPACE(10)
            @ m_x+1, m_y+2 SAY "Promjena inventurnog broja:"
            @ m_x+3, m_y+2 SAY "Novi inventurni broj:" GET _novi valid !EMPTY( _novi )
            read
        BoxC()

        ESC_RETURN DE_CONT

        select_os_sii()

        seek _novi

        if FOUND()
            Beep(1)
            Msg("Vec postoji sredstvo sa istim inventurnim brojem !")
        else

            select_promj()
            seek cId

            _t_rec := 0

            do while !eof() .and. cId == field->id
                skip
                _t_rec := recno()
                skip -1
                _rec := dbf_get_rec()
                _rec["id"] := _novi
                update_rec_server_and_dbf( get_promj_table_name( ALIAS() ), _rec, 1, "FULL" )
                go ( _t_rec )
            enddo
            seek _novi

            select_os_sii()
            seek cId
            _rec := dbf_get_rec()
            _rec["id"] := _novi
            update_rec_server_and_dbf( get_os_table_name( ALIAS() ), _rec, 1, "FULL" )
            cId := _novi
        endif

        select_promj()
        RETURN DE_REFRESH

    otherwise
        RETURN DE_CONT

endcase

return nRet


// ------------------------------------------------------------------------
// 1) izracunaj i prikazi sadasnju vrijednost
// 2) izracunaj i kumulativ amortizacije u aSred
// ------------------------------------------------------------------------
function ShowSadVr()
local _arr := SELECT()
local _t_rec := 0
local _i := 0

// polja os/sii
aVr[1] := field->nabvr
aVr[2] := field->otpvr
 
select_promj()

_t_rec := RECNO()

SEEK cId
 
FOR _i := LEN( aSred ) TO 1 STEP -1
    IF aSred[ _i, 1 ] > 0 .and. aSred[ _i, 1 ] < 999999
        ADEL(aSred, _i)
        ASIZE(aSred, LEN(aSred) - 1 )
    ENDIF
NEXT
  
DO WHILE !EOF() .and. field->id == cID
    aVr[1] += field->nabvr
    aVr[2] += field->otpvr
    AADD( aSred, { RECNO(), field->datum, IF( gOsSii == "O", os->datotp, sii->datotp ), field->nabvr, field->otpvr, 0} )
    SKIP 1
ENDDO
  
ASORT(aSred,,,{|x,y| x[2]<y[2]})

_i := 1

FOR _i := 1 TO LEN( aSred )
    _nabvr := aSred[ _i, 4 ]
    _otpvr := aSred[ _i, 5 ]
    _amd := 0
    _amp := 0
    nOstalo := 0
    _datum := aSred[ _i, 2 ] 
    _datotp := aSred[ _i, 3 ]
    izracunaj_os_amortizaciju( _datum, iif(!empty(_datotp), min(gDatObr,_datotp), gDatObr ),100)     
    // napuni _amp
    aSred[ _i, 6 ] = _amp
NEXT
  
SKIP -1
IF field->id == cId
    aVr[3] := PSadVr()
ENDIF
  
@ m_x+6, m_y+1 SAY " UKUPNO:   Nab.vr.="         COLOR "W+/B"
@ row(),col()  SAY TRANS( aVr[1],"9999999.99")        COLOR "GR+/B"
@ row(),col()  SAY ",    Otp.vr.="         COLOR "W+/B"
@ row(),col()  SAY TRANS( aVr[2],"9999999.99")        COLOR "GR+/B"
@ row(),col()  SAY ",    Sad.vr.="         COLOR "W+/B"
@ row(),col()  SAY TRANS( aVr[1] - aVr[2],"9999999.99") COLOR IF( aVr[1] - aVr[2] < 0,"GR+/R","GR+/B")
@ m_x+7, m_y+1 SAY "           Sadasnja vrijednost sa uracunatom amortizacijom=" COLOR "W+/B"
@ row(),col()  SAY TRANS( aVr[3],"9999999.99")        COLOR IF( aVr[3]<0,"GR+/R","GR+/B")

GO (_t_rec)
SELECT (_arr)

return



function PSadVr()
local _n := 0
local _i := 0

for _i:=1 to LEN(aSred)
    _n += ( aSred[_i,4]-aSred[_i,5]-aSred[_i,6] )
    if _i==LEN(aSred)
        aVr[3]:=_n
    endif
    if aSred[_i,1]==RECNO()
        exit
    endif
next
return _n




function os_validate_date( os_date )
local _ret := .t.

if os_date <= dDatNab
    Beep(1)
    Msg("Datum promjene mora biti veci od datuma nabavke !")
    _ret := .f.
endif

if !empty( dDatOtp ) .and. os_date >= dDatOtp
    Beep(1)
    Msg("Datum promjene mora biti manji od datuma otpisa !")
    _ret := .f.
endif

return _ret



