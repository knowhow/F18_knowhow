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


function PrometVPl()
O_KASE
O_PROMVP

cIdPos:=gIdPos
dDatOd:=dDatDo:=gDatum

set cursor on
Box(,3,60)
  set cursor on
  @ m_x+1,m_y+2 SAY "Prod.mjesto    :  "  GET  cIdPos  valid empty(cIdPos).or.P_Kase(@cIdPos) pict "@!"
  @ m_x+2,m_y+2 SAY "Datumski period:" GET dDatOd
  @ m_x+2,col()+2 SAY "-" GET dDatDo
  read
BoxC()

SELECT PROMVP; go top

nIznPKM:=nIznPEURO:=nIznKred:=nIznVirm:=nIznU:=nIznU2:=nIznTrosk:=0

DO WHILE !EOF()
  if PM==cIdPos .and. Datum>=dDatOd .and. Datum<=dDatDo
     nIznPKM+=PROMVP->PologKM
     nIznPEURO+=PROMVP->PologEU
     nIznKred+=PROMVP->Krediti
     nIznVirm+=PROMVP->Virmani
     nIznTrosk+=PROMVP->Trosk
     nIznU2+=PROMVP->Ukupno2
     skip
  else
    skip
  endif
ENDDO

cLm:=SPACE(5)

// -- stampaj izvjestaj
START PRINT CRET

ZagFirma()

IF gVrstaRS == "S"
  P_INI  ; P_10CPI
EndIF

? "PREGLED PROMETA PO VRSTI PLACANJA NA DAN "+DTOC(gDatum)
? "-------------------------------------------------"
?
if empty(cIdPos)
? "Prodajno mjesto: SVI"
else
? "Prodajno mjesto: " + cIdPos
endif
? "PERIOD         : "+DTOC(dDatOd)+" - "+DTOC(dDatDo)
? "-------------------------------------------"
?
? cLm+"Polog KM    : "+STR(nIznPKM)
? cLm+"Polog EURO  : "+STR(nIznPEURO)
? cLm+"Krediti     : "+STR(nIznKred)
? cLm+"Virmani     : "+STR(nIznVirm)
? cLm+"Troskovi    : "+STR(nIznTrosk)
? cLm+"------------------------------------"
? cLm+"UKUPNO      : "+STR(nIznU2)
? cLm+"------------------------------------"

END PRINT
CLOSERET
*}

