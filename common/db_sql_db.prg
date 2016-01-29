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


FUNCTION OKreSQLPAr( cPom )

   LOCAL nOid1, nOid2

   IF goModul:oDatabase:cRadimUSezona <> "RADP"
      RETURN 0
   ENDIF

   IF !File( ToUnix( cPom + "\SQLPAR.DBF" ) )
      // sql parametri
      aDbf := {}
      AAdd ( aDbf, { "_OID_POC",   "N", 12, 0 } )
      AAdd ( aDbf, { "_OID_KRAJ",  "N", 12, 0 } )
      AAdd ( aDbf, { "_OID_TEK",   "N", 12, 0 } )
      AAdd ( aDbf, { "_SITE_",    "N",  2, 0 } )
      AAdd ( aDbf, { "K1",   "C", 20, 0 } )
      AAdd ( aDbf, { "K2",   "C", 20, 0 } )
      AAdd ( aDbf, { "K3",   "C", 20, 0 } )
      Dbcreate2 ( cPom + "\SQLPAR.DBF", aDBF )

      O_SQLPAR
      APPEND BLANK

      DO WHILE .T.
         nOid1 := nOid2 := 0
         nSite := 1
         Box(, 3, 40 )
         @ m_x + 1, m_y + 2 SAY "Inicijalni _OID_" GET nOid1 PICTURE "999999999999"
         @ m_x + 2, m_y + 2 SAY "Krajnji    _OID_" GET nOid2 PICTURE "999999999999" VALID nOid2 > nOid1
         @ m_x + 3, m_y + 2 SAY "Site            " GET nSite PICTURE "99"
         READ
         BoxC()

         IF pitanje(, "Jeste li sigurni ?", "N" ) == "D"
            REPLACE _oid_poc WITH nOid1, _oid_kraj WITH nOid2, _oid_tek WITH nOid1, _SITE_ WITH nSite
            EXIT
         ELSE
            LOOP
         ENDIF
      ENDDO

      MsgBeep( "SQL parametri inicijalizirani#Pokrenuti ponovo program" )
      goModul:quit()

   ELSE
      O_SQLPAR
   ENDIF

   // }

FUNCTION GetSqlSite()

   // {
   IF gSQL == "D"
      RETURN gSQLSite
   ELSE
      RETURN 0
   ENDIF
   // }
