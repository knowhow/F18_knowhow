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


function OKreSQLPAr(cPom)
local nOid1, nOid2

if goModul:oDatabase:cRadimUSezona<>"RADP"
	return 0
endif

if !file(ToUnix(cPom+"\SQLPAR.DBF"))
 //sql parametri
 aDbf := {}
 AADD (aDbf, {"_OID_POC",   "N", 12, 0})
 AADD (aDbf, {"_OID_KRAJ",  "N", 12, 0})
 AADD (aDbf, {"_OID_TEK",   "N", 12, 0})
 AADD (aDbf, {"_SITE_",    "N",  2, 0})
 AADD (aDbf, {"K1",   "C", 20, 0})
 AADD (aDbf, {"K2",   "C", 20, 0})
 AADD (aDbf, {"K3",   "C", 20, 0})
 Dbcreate2 (cPom+"\SQLPAR.DBF",aDBF)

 O_SQLPAR
 append blank

 do while .t.
 nOid1:=nOid2:=0
 nSite:=1
 Box(,3,40)
   @ m_x+1,m_y+2 SAY "Inicijalni _OID_" GET nOid1 PICTURE "999999999999"
   @ m_x+2,m_y+2 SAY "Krajnji    _OID_" GET nOid2 PICTURE "999999999999" valid nOid2>nOid1
   @ m_x+3,m_y+2 SAY "Site            " GET nSite PICTURE "99"
   read
 BoxC()

 if pitanje(,"Jeste li sigurni ?","N")=="D"
   replace _oid_poc with nOid1, _oid_kraj with nOid2, _oid_tek with nOid1, _SITE_ with nSite
   exit
 else
   loop
 endif
 enddo

 MsgBeep("SQL parametri inicijalizirani#Pokrenuti ponovo program")
 goModul:quit()

else
 O_SQLPAR
endif

*}

function GetSqlSite()
*{
if gSQL=="D"
	return gSQLSite
else
	return 0
endif
*}
