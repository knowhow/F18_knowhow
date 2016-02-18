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



FUNCTION gen_kuf()

   LOCAL dDatOd
   LOCAL dDatDo
   LOCAL cSezona := Space( 4 )

   dDatOd := Date()
   dDatDo := Date()

   Box(, 6, 40 )
   @ m_x + 1, m_y + 2 SAY "Generacija KUF"

   @ m_x + 3, m_y + 2 SAY "Datum do " GET dDatOd
   @ m_x + 4, m_y + 2 SAY "      do " GET dDatDo

   @ m_x + 6, m_y + 2 SAY "sezona" GET cSezona
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF


   // ima li nesto u kif pripremi ?
   SELECT F_P_KUF
   IF !Used()
      O_P_KUF
   ENDIF

   IF RECCOUNT2() <> 0
      MsgBeep( "KUF Priprema nije prazna !" )
      IF Pitanje(, "Isprazniti KUF pripremu ?", "N" ) == "D"
         SELECT p_kuf
         ZAP
      ENDIF
   ENDIF


   Box(, 5, 60 )

   kalk_kuf( dDatOd, dDatDo, cSezona )
   fin_kuf( dDatOd, dDatDo, cSezona )

   epdv_renumeracija_rbr( "P_KUF", .F. )
   BoxC()

   RETURN



FUNCTION gen_kif()

   LOCAL dDatOd
   LOCAL dDatDo
   LOCAL cSezona

   dDatOd := Date()
   dDatDo := Date()
   cSezona := Space( 4 )

   Box(, 3, 40 )
   @ m_x + 1, m_y + 2 SAY "Datum do " GET dDatOd
   @ m_x + 2, m_y + 2 SAY "      do " GET dDatDo
   @ m_x + 3, m_y + 2 SAY "sezona" GET cSezona

   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN
   ENDIF

   SELECT F_P_KIF
   IF !Used()
      O_P_KIF
   ENDIF

   IF RECCOUNT2() <> 0
      MsgBeep( "KIF Priprema nije prazna !" )
      IF Pitanje(, "Isprazniti KIF pripremu ?", "N" ) == "D"
         SELECT p_kif
         ZAP
      ENDIF
   ENDIF

   Box(, 5, 60 )
   fakt_kif( dDatOd, dDatDo, cSezona )

   kalk_kif( dDatOd, dDatDo, cSezona )

   tops_kif( dDatOd, dDatDo, cSezona )

   fin_kif( dDatOd, dDatDo, cSezona )

   epdv_renumeracija_rbr( "P_KIF", .F. )
   BoxC()

   RETURN
