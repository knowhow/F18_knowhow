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


#include "mat.ch"


function mat_dnevnik_naloga()

O_MAT_NALOG
SELECT mat_nalog
set order to tag "1"
GO TOP

START PRINT CRET

m:="---- --- --- ----- -------- ------------ ------------ ---------------- -----------------"

nRBr:=A:=0

nDug:=nPot:=nDug2:=nPot2:=0

PRIVATE picBHD:='@Z 9999999999999.99'
PRIVATE picDEM:='@Z 999999999.99';

DO WHILE !EOF()
   IF prow()==0
      P_COND
      ?? "DNEVNIK mat_nalogA NA DAN:"
      @ prow(),pcol()+2 SAY DATE()
      ? m
      ? "*RED*FIR* V * BR  * DAT    *   DUGUJE   * POTRAZUJE  *     DUGUJE     *   POTRAZUJE    *"
      ? "*BRD*MA * N * NAL * NAL    *    "+ValDomaca()+"    *    "+ValDomaca()+"    *      "+ValPomocna()+"      *      "+ValPomocna()+"      *"
      ? m
   ENDIF

   DO WHILE !EOF() .AND. prow()<66
      @ prow()+1,0 SAY ++nRBr PICTURE "9999"
      @ prow(),pcol()+2 SAY IdFirma
      @ prow(),pcol()+2 SAY IdVN
      @ prow(),pcol()+2 SAY BrNal
      @ prow(),pcol()+1 SAY DatNal
      @ prow(),28       SAY Dug  picture picDEM
      @ prow(),pcol()+1 SAY Pot  picture picDEM
      @ prow(),pcol()+1 SAY Dug2 picture picBHD
      @ prow(),pcol()+1 SAY Pot2 picture picBHD
      nDug+=Dug
      nPot+=Pot
      nDug2+=Dug2
      nPot2+=Pot2
      SKIP
   ENDDO
   IF prow()>65; FF; ENDIF
ENDDO
? m
? "UKUPNO:"
@ prow(),28 SAY nDug        picture picDEM
@ prow(),pcol()+1 SAY nPot  picture picDEM
@ prow(),pcol()+1 SAY nDug2 picture picBHD
@ prow(),pcol()+1 SAY nPot2 picture picBHD
? m

FF
END PRINT

closeret
