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


function P_Fakt()
local cIdFirma:=gFirma,cIdTipDok:="10",cBrDok:=space(8),cBrFakt
local cDir:=space(25), cFaktFirma:="", lRJKonto:=.f.
local lRJKon97:=.f.
local lRJKon97_2:=.f.
local cFF97:=""
local cFF97_2:=""
local cIdFakt97:="01"
local cIdFakt97_2:="19"

cOldVar10 := IzFMKIni("PrenosKALK10_FAKT","NazivPoljaCijeneKojaSePrenosiIzKALK","-",KUMPATH)   // nekad bilo FCJ
cOldVar16 := IzFMKIni("PrenosKALK16_FAKT","NazivPoljaCijeneKojaSePrenosiIzKALK","-",KUMPATH)   // nekad bilo NC

O_FAKT
O_FAKT_PRIPR
O_PARTN
O_KONTO
O_KALK_PRIPR
O_RJ

set order to tag "ID"
select kalk_pripr

Box(, 3, 60 )

do while .t.
    
    cIdFirma := kalk_pripr->idfirma

    SELECT RJ
    GO TOP

    IF kalk_pripr->idvd $ "97"
        exit
    ELSE
        cFaktFirma := cIdFirma
    ENDIF

    select kalk_pripr

    // cFaktFirma je uvedena za slucaj komisiona koji se treba voditi u
    // FAKT-u pod drugom radnom jedinicom (definicija u parametrima - gKomFakt)
    // gKomKonto je konto komisiona definisan takodje u parametrima

    IF kalk_pripr->idvd=="16" .and. kalk_pripr->idkonto==gKomKonto
        cFaktFirma := gKomFakt
    ENDIF

    cIdTipDok := kalk_pripr->idvd
    cBrDok := kalk_pripr->brdok

    read

    select fakt
    private gNumDio := 5
    private cIdFakt := ""

    if kalk_pripr->idvd $ "97"

        cBrFakt := cIdTipDok + "-" + right( alltrim(cBrDok), 5 )

        if lRJKon97

            seek cFF97+cIdFakt97+cBrFakt

            @ m_x+2,m_y+2 SAY "Broj dokumenta u modulu FAKT: "+cFF97+" - "+cIdFakt97+" - " + cBrFakt

            if found()
                Beep(4)
                Box(,1,50)
                    @ m_x+1,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
                    inkey(0)
                BoxC()
                exit
            endif

        endif

        if lRJKon97_2
            seek cFF97_2+cIdFakt97_2+cBrFakt
            @ m_x+3,m_y+2 SAY "Broj dokumenta u modulu FAKT: "+cFF97_2+" - "+cIdFakt97_2+" - " + cBrFakt
            if found()
                Beep(4)
                Box(,1,50)
                    @ m_x+1,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
                    inkey(0)
                BoxC()
                exit
            endif
        endif

    elseif kalk_pripr->idvd $ "10#16#PR#RN"

        cIdFakt := "01"    
        cBrFakt := fakt_novi_broj_dokumenta( cFaktFirma, cIdFakt )

        seek cFaktFirma + cIdFakt + cBrFakt

    else

        if kalk_pripr->idvd $ "11#12#13"
            cIdFakt:="13"
        elseif kalk_pripr->idvd $ "95#96"
            cIdFakt:="19"
        endif

        cBrFakt := fakt_novi_broj_dokumenta( cFaktFirma, cIdFakt )

        seek cFaktFirma + cIdFakt + cBrFakt
    
    endif

    if kalk_pripr->idvd <> "97"

        @ m_x+2,m_y+2 SAY "Broj dokumenta u modulu FAKT: " + cFaktFirma + " - " + cIdFakt + " - " + cBrFakt

        if found()
            Beep(4)
            Box(,1,50)
                @ m_x + 1, m_y + 2 SAY "U FAKT vec postoji ovaj dokument !!"
                inkey(0)
            BoxC()
            exit
        endif

    endif

    select kalk_pripr

    fFirst := .t.
    
    do while !eof() .and. cIdFirma+cIdTipDok+cBrDok==IdFirma+IdVD+BrDok

        private nKolicina:=kalk_pripr->(kolicina-gkolicina-gkolicin2)

        if kalk_pripr->idvd $ "12#13"  
            // ove transakcije su storno otpreme
            nKolicina:=-nKolicina
        endif

        if kalk_pripr->idvd $ "PR#RN"
            if val(kalk_pripr->rbr)>899
                skip
                loop
            endif
        endif

        select fakt_pripr

        if kalk_pripr->idvd == "97"
            if lRJKon97
                hseek cFF97+kalk_pripr->(cIdFakt97+cBrFakt+rbr)
                if found()
                    RREPLACE kolicina with kolicina+nkolicina
                else
                    APPEND BLANK
                    replace idfirma with cFF97
                    replace idtipdok with cIdFakt97
                    replace brdok with cBrFakt
                    replace rbr with kalk_pripr->rbr
                    replace kolicina with nkolicina
                endif
            endif
            if lRJKon97_2
                hseek cFF97_2+kalk_pripr->(cIdFakt97_2+cBrFakt+rbr)
                if found()
                    RREPLACE kolicina with kolicina+nkolicina
                else
                    APPEND BLANK
                    replace idfirma with cFF97_2
                    replace idtipdok with cIdFakt97_2
                    replace brdok with cBrFakt
                    replace rbr with kalk_pripr->rbr
                    replace kolicina with nkolicina
                endif
            endif

        elseif (kalk_pripr->idvd == "16" .and. IsVindija() )
            APPEND BLANK
            replace kolicina with nKolicina

        else

            hseek cFaktFirma + kalk_pripr->(cIdFakt+cBrFakt+rbr)

            if found()
                RREPLACE kolicina with kolicina+nkolicina
            else
                APPEND BLANK
                replace kolicina with nkolicina
            endif

        endif

        if fFirst

            if kalk_pripr->idvd == "97"
                if lRJKon97
                    select fakt_pripr
                    hseek cFF97+pripr->(cIdFakt97+cBrFakt+rbr)
                    select konto
                    hseek kalk_pripr->idkonto
                    cTxta:=padr(kalk_pripr->idkonto,30)
                    cTxtb:=padr(konto->naz,30)
                    cTxtc:=padr("",30)
                    ctxt:=Chr(16)+" " +Chr(17)+;
                      Chr(16)+" "+Chr(17)+;
                      Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
                      Chr(16)+cTxtc+Chr(17)
                    select fakt_pripr
                    RREPLACE txt with ctxt
                endif
                if lRJKon97_2
                    select fakt_pripr
                    hseek cFF97_2+pripr->(cIdFakt97_2+cBrFakt+rbr)
                    select konto
                    hseek kalk_pripr->idkonto2
                    cTxta:=padr(kalk_pripr->idkonto2,30)
                    cTxtb:=padr(konto->naz,30)
                    cTxtc:=padr("",30)
                    cTxt:=Chr(16)+" " +Chr(17)+;
                      Chr(16)+" "+Chr(17)+;
                      Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
                      Chr(16)+cTxtc+Chr(17)
                    select fakt_pripr
                    RREPLACE txt with ctxt
                endif
                fFirst := .f.

            else

                select PARTN
                hseek kalk_pripr->idpartner
             
                if kalk_pripr->idvd $ "11#12#13#95#PR#RN"
                    select konto
                    hseek kalk_pripr->idkonto
                    cTxta:=padr(kalk_pripr->idkonto,30)
                    cTxtb:=padr(konto->naz,30)
                    cTxtc:=padr("",30)
                else
                    cTxta:=padr(naz,30)
                    cTxtb:=padr(naz2,30)
                    cTxtc:=padr(mjesto,30)
                endif

                inkey(0)

                cTxt:=Chr(16)+" " +Chr(17)+;
                    Chr(16)+" "+Chr(17)+;
                    Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
                    Chr(16)+cTxtc+Chr(17)
                
                fFirst:=.f.

                select fakt_pripr
                RREPLACE txt with cTxt

            endif
        endif

        for i := 1 to 2

            if kalk_pripr->idvd == "97"
                if i==1
                    if !lRJKon97
                        loop
                    endif
                    hseek cFF97+kalk_pripr->(cIdFakt97+cBrFakt+rbr)
                else
                    if !lRJKon97_2
                        loop
                    endif
                    hseek cFF97_2+kalk_pripr->(cIdFakt97_2+cBrFakt+rbr)
                endif
            else
                RREPLACE idfirma with IF(cFaktFirma!=cIdFirma.or.lRJKonto,cFaktFirma, kalk_pripr->idfirma ), rbr with kalk_pripr->Rbr, idtipdok with cIdFakt, brdok with cBrFakt
            endif

            my_rlock()

            replace idpartner with kalk_pripr->idpartner
            replace datdok with kalk_pripr->datdok
            replace idroba with kalk_pripr->idroba
            replace cijena with kalk_pripr->vpc      // bilo je fcj sto je pravo bezveze
            replace rabat with 0               // kakav crni rabat
            replace dindem with "KM "

            if kalk_pripr->idvd == "10" .and. cOldVar10<>"-"
                replace cijena with kalk_pripr->(&cOldVar10)
            elseif kalk_pripr->idvd == "16" .and. cOldVar16<>"-"
                replace cijena with kalk_pripr->(&cOldVar16)
            elseif kalk_pripr->idvd $ "11#12#13"
                replace cijena with kalk_pripr->mpcsapp   // ove dokumente najvise interesuje mpc!
            elseif kalk_pripr->idvd $ "PR#RN"
                replace cijena with kalk_pripr->vpc
            elseif kalk_pripr->idvd $ "95"
                replace cijena with kalk_pripr->VPC
            elseif kalk_pripr->idvd $ "16"
                replace cijena with kalk_pripr->vpc       // i ovdje je bila nc pa sam stavio vpc
            endif

            my_unlock()

            if kalk_pripr->idvd<>"97"
                exit
            endif       
        next

        select kalk_pripr
        skip
    enddo

    Beep(1)

    exit
enddo
Boxc()

my_close_all_dbf()

// fakt trazi ove varijabl
glRadNal := .f.
glDistrib := .f.

azur_fakt( .t. )

my_close_all_dbf()

return



