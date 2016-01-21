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

// stampa liste dokumenata koji se nalaze u pripremi
function StPripr()
*{
m:="-------------- -------- ----------"
O_KALK_PRIPR

START PRINT CRET

?? m
? "   Dokument     Datum  Broj stavki"
? m
do while !eof()
  cIdFirma:=IdFirma; cIdVd:=idvd; cBrDok:=BrDok
  dDatDok:=datdok
  nStavki:=0
  do while !eof() .and. cIdFirma==idfirma .and. cIdVd==idvd .and. cbrdok==brdok
    ++nStavki
    skip
  enddo
  ? cIdFirma+"-"+cIdVd+"-"+cBrDok, dDatDok, STR(nStavki,4), space(2), "__"
enddo
? m
END PRINT
closeret
return
*}

