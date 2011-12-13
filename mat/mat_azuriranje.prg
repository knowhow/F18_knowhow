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



function azur_mat()

if Pitanje(,"Sigurno zelite izvrsiti azuriranje (D/N)?","N")=="N"
   return
endif

O_PARTN
O_MAT_PRIPR
O_MAT_SUBAN
O_MAT_PSUBAN
O_MAT_ANAL
O_MAT_PANAL
O_MAT_SINT
O_MAT_PSINT
O_MAT_NALOG
O_MAT_PNALOG
O_ROBA

fAzur:=.t.
select mat_psuban; if reccount2()==0; fAzur:=.f.; endif
select mat_panal; if reccount2()==0; fAzur:=.f.; endif
select mat_psint; if reccount2()==0; fAzur:=.f.; endif
if !fAzur
  Beep(3)
  Msg("Niste izvrsili stampanje mat_naloga ...",10)
  return
endif

// kontrola ispravnosti sifara artikala

select mat_psuban
GO TOP
DO WHILE !EOF()
  select ROBA; hseek mat_psuban->idroba
  if !found()
    Beep(1)
    Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra artikla!")
    select mat_psuban; zapp()
    select mat_panal; zapp()
    select mat_psint; zapp()
    closeret
  endif
  select PARTN; hseek mat_psuban->idpartner
  if !found().and.!EMPTY(mat_psuban->idpartner)
    Beep(1)
    Msg("Stavka br."+mat_psuban->rbr+": Nepostojeca sifra partnera!")
    select mat_psuban; zapp()
    select mat_panal; zapp()
    select mat_psint; zapp()
    closeret
  endif
  select mat_psuban
  SKIP 1
ENDDO
go top

if !( mat_suban->(flock()) .and. mat_anal->(flock()) .and. mat_sint->(flock()) .and. mat_nalog->(flock()) )
  Beep(1)
  Msg("Neko vec koristi datoteke !",6)
  closeret
endif

Box(,7,30,.f.)
select mat_anal
APPEND FROM mat_panal
@ m_x+1,m_y+2 SAY "ANALITIKA"
select mat_panal; zapp()

select mat_sint
APPEND FROM mat_psint
@ m_x+3,m_y+2 SAY "SINTETIKA  "
select mat_psint; zapp()

select mat_nalog
APPEND FROM mat_pnalog
@ m_x+5,m_y+2 SAY "NALOZI     "
select mat_pnalog; zapp()

select mat_suban
APPEND FROM mat_psuban

select mat_psuban; go top
DO WHILE !EOF()

   nUlazK:=nIzlK:=nDug:=nPot:=0
   IF U_I="1"
     nUlazK:=Kolicina
   ELSE
     nIzlK:=Kolicina
   ENDIF
   IF D_P="1"
      nDug:=Iznos
   ELSE
      nPot:=Iznos
   ENDIF

   select mat_pripr
   seek mat_psuban->(idfirma+idvn+brnal)
   if found(); dbdelete2(); endif

   select mat_psuban
   SKIP
ENDDO

select mat_psuban;zapp()

select mat_pripr; __dbpack()
@ m_x+7,m_y+2 SAY "SUBANALITIKA "

Inkey(2)

BoxC()
closeret


