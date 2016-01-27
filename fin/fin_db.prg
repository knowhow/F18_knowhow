/*
 * This file is part of the bring.out FMK, a free and open source
 * accounting software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"


/*! \fn Dupli(cIdFirma,cIdVn,cBrNal)
 *  \brief Provjera duplog naloga
 *  \param cIdFirma
 *  \param cIdVn
 *  \param cBrNal
 */

FUNCTION Dupli( cIdFirma, cIdVn, cBrNal )

   PushWA()

   SELECT NALOG
   SET ORDER TO TAG "1"

   SEEK cIdFirma + cIdVN + cBrNal

   IF Found()
      MsgO( " Dupli nalog ! " )
      Beep( 3 )
      MsgC()
      PopWa()
      RETURN .F.
   ENDIF

   PopWa()

   RETURN .T.
