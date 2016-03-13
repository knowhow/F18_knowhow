/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */




#include "f18.ch"


function PrepisRazd()
LOCAL nSir := 80, nRobaSir := 30, cLm := SPACE (5), cPicKol := "999999.999"
  START PRINT CRET
  IF gVrstaRS == "S"
    P_INI
    P_10CPI
  Else
    nSir := 40
    nRobaSir := 18
    cLM := ""
    cPicKol := "9999.999"
  EndIF

  ? PADC ("RAZDUZENJE SIROVINA " +;
          IIF (Empty (DOKS->IdPos), "", ALLTRIM (DOKS->IdPos)+"-")+;
          ALLTRIM (DOKS->BrDok), nSir)

  SELECT POS
  HSEEK pos_doks->(IdPos+IdVd+dtos(datum)+BrDok)

  ? PADC (FormDat1 (DOKS->Datum) +;
          IIF (!Empty (DOKS->Smjena), " Smjena: "+DOKS->Smjena, ""), nSir)
  ?
  ? cLM
  IF gVrstaRS == "S"
    ?? "Sifra    Naziv                          JMJ Cijena  Kolicina   ODJ"
    m := cLM+"-------- ------------------------------ --- ------- ---------- ---"
    IF gPostDO == "D"
      m += " ---"
    EndIF
  Else
    ?? "Sifra    Naziv              JMJ Kolicina"
    m := cLM+"-------- ------------------ --- --------"
  EndIF
  IF gPostDO == "D"
    ?? " DIO"
  EndIF
  ? m

/****
Sifra    Naziv                          JMJ Cijena  Kolicina   ODJ DIO
-------- ------------------------------ --- ------- ---------- --- ---
01234567 012345678901234567890123456789     9999.99 999999.999
                                            999,999,999,999.99
Sifra    Naziv              JMJ Kolicina
         ODJ DIO
-------- ------------------ --- --------
01234567 012345678901234567 012 9999.999
         01  01
                            9,999,999.99
****/

  nFin := 0
  SELECT POS
  While ! Eof() .and. POS->(IdPos+IdVd+dtos(datum)+BrDok)==DOKS->(IdPos+IdVd+dtos(datum)+BrDok)
    IF gVrstaRS == "S" .and. Prow() > 63-dodatni_redovi_po_stranici()
      FF
    EndIF
    ? cLM
    ?? IdRoba, ""
    select roba
    HSEEK POS->IdRoba
    ?? PADR (roba->Naz, nRobaSir), roba->Jmj, ""
    SELECT POS
    IF gVrstaRS == "S"
     ?? TRANS (POS->Cijena, "9999.99"), ""
    EndIF
    ?? TRANS (POS->Kolicina, cPicKol)
    IF gVrstaRS <> "S"
      ? cLM+SPACE (LEN (POS->IdRoba))
    EndIF
    ?? " "+POS->IdOdj, " "+POS->IdDio
    nFin += POS->(Kolicina * Cijena)
    SKIP
  ENDDO
  IF gVrstaRS == "S" .and. Prow() > 63-dodatni_redovi_po_stranici() - 7
    FF
  EndIF
  ? m
  ? cLM
  ?? PADL ("IZNOS DOKUMENTA ("+TRIM (gDomValuta)+")", ;
           IIF (gVrstaRS=="S", 13,10)+nRobaSir), ;
     TRANS (nFin, IIF (gVrstaRS=="S", "999,999,999,999.99", "9,999,999.99"))
  ? m
  IF gVrstaRS == "S"
    FF
  Else
    PaperFeed()
  EndIF
  ENDPRINT
  select pos_doks
RETURN
*}

