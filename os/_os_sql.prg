/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

MEMVAR gOssii

FUNCTION datotp_prazan()

   IF field->datotp < SToD( "10010101" ) // 1000-01-01
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION get_datotp()

   IF field->datotp < SToD( "10010101" )
      RETURN CToD( "" )
   ENDIF

   RETURN field->datotp


FUNCTION o_amort( cId )

   LOCAL cTable := "os_amort"
   LOCAL cAlias := "AMORT"

   SELECT ( F_AMORT )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


FUNCTION select_o_amort( cId )

   SELECT ( F_AMORT )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_amort( cId )


FUNCTION o_reval( cId )

   LOCAL cTable := "os_reval"
   LOCAL cAlias := "REVAL"

   SELECT ( F_REVAL )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


FUNCTION select_o_reval( cId )

   SELECT ( F_REVAL )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_reval( cId )



FUNCTION o_os( cId )

   LOCAL cTable := "os_os", cAlias := "OS"

   SELECT ( F_OS )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


FUNCTION select_o_os( cId )

   SELECT ( F_OS )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_os( cId )


FUNCTION o_sii( cId )

   LOCAL cTable := "sii_sii", cAlias := "sii"

   SELECT ( F_SII )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


FUNCTION select_o_sii( cId )

   SELECT ( F_SII )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_sii( cId )


FUNCTION o_os_promj( cId )

   LOCAL cTable := "os_promj", cAlias := "PROMJ"

   SELECT ( F_PROMJ )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


FUNCTION select_o_os_promj( cId )

   SELECT ( F_PROMJ )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_os_promj( cId )


FUNCTION o_sii_promj( cId )

   LOCAL cTable := "sii_promj", cAlias := "SII_PROMJ"

   SELECT ( F_SII_PROMJ )
   IF !use_sql_sif( cTable, .T., cAlias, cId )
      RETURN .F.
   ENDIF

   IF cId != NIL
      SEEK cId
   ENDIF

   RETURN !Eof()


FUNCTION select_o_sii_promj( cId )

   SELECT ( F_SII_PROMJ )
   IF Used()
      IF RecCount() > 1 .AND. cId == NIL
         RETURN .T.
      ELSE
         USE // samo zatvoriti postojecu tabelu, pa ponovo otvoriti sa cId
      ENDIF
   ENDIF

   RETURN o_os_sii_promj( cId )




FUNCTION select_os_sii( cId )

   IF gOsSii == "O"
      select_o_os( cId )
   ELSE
      select_o_sii( cId )
   ENDIF

   RETURN .T.


FUNCTION select_promj( cId )

   IF gOsSii == "O"
      select_o_os_promj( cId )
   ELSE
      select_o_sii_promj( cId )
   ENDIF

   RETURN .T.


FUNCTION o_os_sii()

   IF gOsSii == "O"
      RETURN o_os()
   ELSE
      RETURN o_sii()
   ENDIF

   RETURN .T.


FUNCTION o_os_sii_promj()

   IF gOsSii == "O"
      RETURN o_os_promj()
   ELSE
      RETURN o_sii_promj()
   ENDIF

   RETURN .T.
