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


function KMag()
local nR1
local nR2
local nR3
local cIdFirma := space(2)
local cIdroba := space(10)
local cKonto := space(7)
private GetList:={}

select  roba
nR1:=recno()

select kalk_pripr
nR2:=recno()

select tarifa
nR3:=recno()

if EMPTY( kalk_pripr->mkonto )
   	Box(,2,50)
    	cIdFirma := gfirma
     	@ m_x+1,m_y+2 SAY "KARTICA MAGACIN"
     	@ m_x+2,m_y+2 SAY "Kartica konto-artikal" GET cKonto
     	@ m_x+2,col()+2 SAY "-" GET cIdRoba
     	read
   	BoxC()
else
	cIdFirma := kalk_pripr->idfirma
   	cKonto := kalk_pripr->mkonto
   	cIdRoba := kalk_pripr->idroba
endif

my_close_all_dbf()

kartica_magacin( cIdFirma, cIdRoba, cKonto )

o_kalk_edit()

select roba
go nR1

select kalk_pripr
go nR2

select tarifa
go nR3

select kalk_pripr

return


