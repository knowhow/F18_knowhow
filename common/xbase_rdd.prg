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

#include "fmk.ch"

/*
   Funkcije koje koriste xBASE RDD-ovi (replacable database driver)
   DBCDX, SQLMIX
*/

static aWaStack:={}
// --------------------------------
// --------------------------------
FUNCTION PushWA()

   LOCAL cFilter

   IF Used()
      IF rddName() != "SQLMIX"
         cFilter := dbFilter()
      ELSE
         cFilter := ""
      ENDIF
      StackPush( aWAStack, { Select(), ordName(), cFilter, RecNo() } )
   ELSE
      StackPush( aWAStack, { NIL, NIL, NIL, NIL } )
   ENDIF

   RETURN NIL


// ---------------------------
// ---------------------------
FUNCTION PopWA()

   LOCAL aWa
   LOCAL i

   aWa := StackPop( aWaStack )

   IF aWa[ 1 ] <> NIL

      // select
      SELECT( aWa[ 1 ] )

      ordSetFocus( aWa[ 2 ] )

      // filter
      IF !Empty( aWa[ 3 ] )
         SET FILTER to &( aWa[ 3 ] )
      ELSE
         IF !Empty( dbFilter() )
            SET FILTER TO
         ENDIF
      ENDIF

      IF Used()
         GO aWa[ 4 ]
      ENDIF

   ENDIF

   RETURN NIL


FUNCTION index_tag_num( name )

   IF rddName() != "SQLMIX"
      RETURN ordNumber( name )
   ELSE
      FOR i := 1 TO ordCount()
         IF ordKey( i ) == name
            RETURN i
         ENDIF
      NEXT
      RETURN 0
   ENDIF

   // dbf lock / unlock

FUNCTION my_flock()

   IF rddName() != "SQLMIX"
      RETURN FLock()
   ELSE
      RETURN .T.
   ENDIF

FUNCTION my_rlock()

   IF rddName() != "SQLMIX"
      RETURN RLock()
   ELSE
      RETURN .T.
   ENDIF

FUNCTION my_unlock()

   IF rddName() != "SQLMIX"
      RETURN dbUnlock()
   ELSE
      RETURN .T.
   ENDIF
