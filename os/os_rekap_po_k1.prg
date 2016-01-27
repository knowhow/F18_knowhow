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


function os_rekapitulacija_po_k1()

O_K1
O_RJ

o_os_sii()

cIdrj := space(4)
cON := "N"
cKolP := "N"
cPocinju := "N"
cDNOS := "D"

Box(,4,77)
    @ m_x+1,m_y+2 SAY "Radna jedinica (prazno svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
    @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
    @ m_x+2,m_y+2 SAY "Prikaz svih neotpisanih/otpisanih/samo novonabavljenih (N/O/B) sredstava:" get cON pict "@!" valid con $ "ONB"
    @ m_x+4,m_y+2 SAY "Prikaz sredstava D/N:" get cDNOs pict "@!" valid cDNOs $ "DN"
    read
    ESC_BCR
BoxC()

if cPocinju == "D" .or. empty( cIdrj )
    cIdRj := trim( cIdrj )
endif

m:="----- ---------- ------------------------- -------------"

select_os_sii()
set order to tag "2" 
//idrj+id+dtos(datum)

cFilt1 := "idrj=cidrj"
cSort1 := "k1+idrj"

Box(,1,30)
index on &cSort1 to "TMPSP2" for &cFilt1 eval(TekRec()) every 10
BoxC()

START PRINT CRET

nCol1 := 48

ZglK1()

go top

do while !eof()

    select_os_sii()
    nKol:=0
    cK1 := field->k1
    do while !eof() .and. cK1 = field->k1

        select_os_sii()
        nKolRJ:=0
        nRbr:=0
        cTRj:=field->idrj
        do while !eof() .and. cK1 == field->k1 .and. cTRj == field->idrj
            select_os_sii()
            if (cON="B" .and. year(gdatobr) <> year(field->datum))  
                // nije novonabavljeno
                skip
                loop
                // prikazi samo novonabavlj.
            endif

            if (!empty(field->datotp) .and. year( field->datotp )= year( gdatobr )) .and. cON $ "NB"
                // otpisano sredstvo , a zelim prikaz neotpisanih
                skip
                loop
            endif

            if (empty( field->datotp ) .or. year( field->datotp ) < year( gdatobr )) .and. cON=="O"
                // neotpisano, a zelim prikaz otpisanih
                skip 
                loop
            endif

            nKolRJ += field->kolicina
            if cDNOS=="D"
                ? str(++nrbr,4) + ".", field->id, field->naz
                nCol1 := pcol()+1
                @ prow(),pcol()+1 SAY field->kolicina pict gpickol
            endif

            skip
            select_os_sii()

        enddo
    
        if prow()>62
            FF  
            ZglK1()
        endif
    
        ? m
        ? "UKUPNO ZA RJ", cTRJ,"-", cK1
        @ prow(),nCol1 SAY nKolRJ   pict gpickol
        ? m
        nKol += nKolRJ
    enddo

    if prow()>62
        FF
        ZglK1()
    endif
 
    ? strtran(m,"-","=")
    select k1
    hseek cK1

    select_os_sii()

    ? "UKUPNO ZA GRUPU", cK1, k1->naz
    @ prow(),nCol1 SAY nKol pict gpickol
    ? strtran(m,"-","=")

enddo

END PRINT

my_close_all_dbf()
return


static function TekRec()
@ m_x+1,m_y+2 SAY recno()
return NIL



static function ZglK1()
local _mod_name := "OS"

if gOsSii == "S"
    _mod_name := "SII"
endif

?

P_12CPI

?? UPPER(gTS) + ":", gNFirma
?
? _mod_name + ": Rekapitulacija po grupama - k1 "

if cON=="N"
   ?? "sredstava u upotrebi"
else
   ?? "sredstava otpisanih u toku godine"
endif

?? "     Datum:", gDatObr

select rj
seek cIdRj
select_os_sii()

? "Radna jedinica:", cIdrj, rj->naz

if cPocinju == "D"
    ?? "(SVEUKUPNO)"
endif

? m
? "Rbr                                           Kolicina"
? m

return



