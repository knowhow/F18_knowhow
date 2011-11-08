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


#include "kalk.ch"


function KMag()
local nR1,nR2,nR3,cidfirma:=space(2),cidroba:=space(10),ckonto:=space(7)
private GetList:={}
select  roba
nR1:=recno()
select kalk_pripr
nR2:=recno()
select tarifa
nR3:=recno()
if empty(kalk_pripr->mkonto)
   box(,2,50)
     cidfirma:=gfirma
     @ m_x+1,m_y+2 SAY "KARTICA MAGACIN"
     @ m_x+2,m_y+2 SAY "Kartica konto-artikal" GET ckonto
     @ m_x+2,col()+2 SAY "-" GET cidroba
     read
   BoxC()
else
   cidfirma:=kalk_pripr->idfirma
   ckonto:=kalk_pripr->mkonto
   cidroba:=kalk_pripr->idroba
endif

close all
Karticam(cIdFirma,cidroba,ckonto)
OEdit()
select roba
go nR1
select kalk_pripr
go nR2
select tarifa
go nR3
select kalk_pripr
return


