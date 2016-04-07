/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

// ------------------------------
// no_lock - ne zakljucavaj
// ------------------------------
FUNCTION dbf_update_rec( vars, no_lock )

   LOCAL _key
   LOCAL _field_b
   LOCAL _msg
   LOCAL _a_dbf_rec

   IF no_lock == NIL
      no_lock := .F.
   ENDIF

   IF !Used()
      _msg := "dbf_update_rec - nema otvoren dbf"
      log_write( _msg, 1 )
      Alert( _msg )
      //QUIT_1
      RETURN .F.
   ENDIF

   IF no_lock .OR. my_rlock()

      _a_dbf_rec := get_a_dbf_rec( Alias(), .F. )

      FOR EACH _key in vars:Keys

         // blacklistovano polje
         IF field_in_blacklist( _key, _a_dbf_rec[ "blacklisted" ] )
            LOOP
         ENDIF

         // replace polja
         IF FieldPos( _key ) == 0
            _msg := RECI_GDJE_SAM + "dbf field " + _key + " ne postoji u " + Alias()
            // Alert(_msg)
            log_write( _msg, 1 )
         ELSE
            _field_b := FieldBlock( _key )
            // napuni field sa vrijednosti
            Eval( _field_b, vars[ _key ] )
         ENDIF

      NEXT

      IF !no_lock
         my_unlock()
      ENDIF
   ELSE
      MsgBeep( "Ne mogu rlock-ovati:" + Alias() )
      RETURN .F.
   ENDIF

   RETURN .T.
