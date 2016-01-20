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

#include "f18.ch"



function ld_brisanje_obr()
local _opc:={}
local _opcexe:={}
local _izbor:=1

AADD(_opc, "1. brisanje obracuna za jednog radnika       ")
AADD(_opcexe, {|| BrisiRadnika() })
AADD(_opc, "2. brisanje obracuna za jedan mjesec   ")
AADD(_opcexe, {|| BrisiMjesec()})
AADD(_opc, "3. totalno brisanje radnika iz evidencije")
AADD(_opcexe, {|| TotBrisRadn()})

f18_menu("bris", .f., _izbor, _opc, _opcexe )

return


function BrisiRadnika()
local nTrec
local cIdRadn
local cMjesec
local cIdRj
local fnovi
local _rec

nUser := 001
O_RADN
O_LD

if Logirati(goModul:oDataBase:cName, "DOK", "BRISIRADNIKA")
    lLogBrRadn:=.t.
else
    lLogBrRadn:=.f.
endif

do while .t.

    cIdRadn:=SPACE(_LR_)
    cIdRj:=gRj
    cMjesec:=gMjesec
    cGodina:=gGodina
    cObracun := gObracun

    Box(,4,60)
        @ m_x+1,m_y+2 SAY "Radna jedinica: "
        QQOUTC(cIdRJ,"N/W")
        @ m_x+2,m_y+2 SAY "Mjesec: "
        QQOUTC(str(cMjesec,2),"N/W")
        @ m_x+2,col()+2 SAY "Obracun: "
        QQOUTC(cObracun,"N/W")
        @ m_x+3,m_y+2 SAY "Godina: "
        QQOUTC(STR(cGodina,4),"N/W")
        
        @ m_x+4, m_y+2 SAY "Radnik" GET cIdRadn valid {|| cIdRadn $ "XXXXXX" .or. P_Radn(@cIdRadn), SetPos(m_x+2,m_y+20), QQOUT(TRIM(radn->naz)+" ("+TRIM(radn->imerod)+") "+radn->ime), .t.}
        
        read
        ESC_BCR
    BoxC()
    
    if cIdRadn <> "XXXXXX"

        O_LD
        select ld
        seek STR(cGodina, 4) + cIdRj + STR(cMjesec, 2) + BrojObracuna() + cIdRadn

        if Found()

            if Pitanje(,"Sigurno zelite izbrisati ovaj zapis D/N","N")=="D"

                _rec := dbf_get_rec()
                delete_rec_server_and_dbf( "ld_ld", _rec, 1, "FULL" )

                MsgBeep("Izbrisan obracun za radnika: " + cIdRadn + "  !!!")

                if lLogBrRadn
                    EventLog(nUser,goModul:oDataBase:cName,"DOK","BRISIRADNIKA",nil,nil,nil,nil,cIdRj,STR(cMjesec,2),"Rad:"+cIdRadn+" God:"+STR(cGodina,4),Date(),Date(),"","Brisanje obracuna za jednog radnika")
                endif

            endif
        else
            Msg("Podatak ne postoji...",4)
        endif

    else
        select ld
        set order to 0
        if FLock()

            go top

            Postotak(1, RecCount(), "Ukloni 0 zapise")

            f18_lock_tables({"ld_ld"})
            sql_table_update( nil, "BEGIN" )

            do while !eof()

                    nPom:=0
                    _rec := dbf_get_rec()

                    for i:=1 to cLDPolja
                        cPom := PadL(ALLTRIM(STR(i)),2,"0")
                        nPom += (ABS(_i&cPom) + ABS(_s&cPom))
                        // ako su sve nule
                    next
    
                    if (Round(nPom, 5)=0)
                        delete_rec_server_and_dbf( "ld_ld", _rec, 1, "CONT" )
                    endif
    
                    Postotak(2, RecNo())

                    skip
    
            enddo

            Postotak(0)

            f18_free_tables({"ld_ld"})
            sql_table_update( nil, "END" )

        else
                MsgBeep("Neko vec koristi datoteku LD !!!")
        endif
    endif
    
    select ld
    use
enddo

my_close_all_dbf()
return



function BrisiMjesec()
local cMjesec
local cIdRj
local fnovi
local _rec

nUser := 001

O_RADN

if Logirati(goModul:oDataBase:cName,"DOK","BRISIMJESEC")
    lLogBrMjesec:=.t.
else
    lLogBrMjesec:=.f.
endif

do while .t.

    O_LD
    
    cIdRadn:=SPACE(_LR_)
    cIdRj:=gRj
    cMjesec:=gMjesec
    cGodina:=gGodina
    cObracun:=gObracun
    
    Box(,4,60)
        @ m_x+1,m_y+2 SAY "Radna jedinica: " GET cIdRJ
        @ m_x+2,m_y+2 SAY "Mjesec: "  GET cMjesec pict "99"
        @ m_x+2,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
        @ m_x+3,m_y+2 SAY "Godina: "  GET cGodina pict "9999"
        read
        ClvBox()
        ESC_BCR
    BoxC()
    
    if Pitanje(,"Sigurno zelite izbrisati sve podatke za RJ za ovaj mjesec !?","N")=="N"
        my_close_all_dbf()
        return
    endif
    
    MsgO("Sacekajte, brisem podatke....")

    select ld
    
    seek STR(cGodina,4) + cIdRj + STR(cMjesec, 2) + BrojObracuna()

    if FOUND()
   
        _rec := dbf_get_rec()
        delete_rec_server_and_dbf( "ld_ld", _rec, 2, "FULL" )

    endif

    MsgBeep("Obracun za " + STR(cMjesec,2) + " mjesec izbrisani !!!")
    
    MsgC()
    exit

enddo

my_close_all_dbf()
return



