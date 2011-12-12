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

function mat_kzb()


local   picBHD:='999999999999.99'
local   picDEM:='999999999.99'

O_MAT_NALOG
O_MAT_SUBAN
O_MAT_ANAL
O_MAT_SINT

Box("KZB",10,77,.f.)
set cursor off
@ m_x+1,m_y+2 say "* NAZIV      * DUGUJE "+ValPomocna()+"* POTRA@."+ValPomocna()+"* DUGUJE "+ValDomaca()+"   * POTRA@UJE "+ValDomaca()+"*"



select mat_nalog

go top
nDug:=nPot:=nDug2:=nPot2:=0
DO WHILE !EOF() .and. INKEY()!=27
   nDug+=Dug;   nPot+=Pot
   nDug2+=Dug2;   nPot2+=Pot2
   SKIP
ENDDO
ESC_BCR
@ m_x+3,m_y+2 SAY "      NALOZI"
@ row(),col()+1 SAY nDug PICTURE picDEM
@ row(),col()+1 SAY nPot PICTURE picDEM
@ row(),col()+1 SAY nDug2 PICTURE picBHD
@ row(),col()+1 SAY nPot2 PICTURE picBHD

select mat_sint
nDug:=nPot:=nDug2:=nPot2:=0
go top
DO WHILE !EOF() .and. INKEY()!=27
   nDug+=Dug; nPot+=Pot
   nDug2+=Dug2; nPot2+=Pot2
   SKIP
ENDDO
ESC_BCR
@ m_x+5,m_y+2 SAY "   mat_sintETIKA"
@ row(),col()+1 SAY nDug PICTURE picDEM
@ row(),col()+1 SAY nPot PICTURE picDEM
@ row(),col()+1 SAY nDug2 PICTURE picBHD
@ row(),col()+1 SAY nPot2 PICTURE picBHD


select mat_anal
nDug:=nPot:=nDug2:=nPot2:=0
go top
DO WHILE !EOF() .and. INKEY()!=27
   nDug+=Dug; nPot+=Pot
   nDug2+=Dug2; nPot2+=Pot2
   SKIP
ENDDO
ESC_BCR
@ m_x+7,m_y+2 SAY "   mat_analITIKA"
@ row(),col()+1 SAY nDug PICTURE picDEM
@ row(),col()+1 SAY nPot PICTURE picDEM
@ row(),col()+1 SAY nDug2 PICTURE picBHD
@ row(),col()+1 SAY nPot2 PICTURE picBHD

select mat_suban
nDug:=nPot:=nDug2:=nPot2:=0
go top
DO WHILE !EOF() .and. INKEY()!=27
  if D_P=="1"
   nDug+=Iznos; nDug2+=Iznos2
  else
   nPot+=Iznos; nPot2+=Iznos2
  endif
  SKIP
ENDDO
ESC_BCR
@ m_x+9,m_y+2 SAY "SUBANALITIKA"
@ row(),col()+1 SAY nDug PICTURE picDEM
@ row(),col()+1 SAY nPot PICTURE picDEM
@ row(),col()+1 SAY nDug2 PICTURE picBHD
@ row(),col()+1 SAY nPot2 PICTURE picBHD

Inkey(0)
BoxC()
closeret
