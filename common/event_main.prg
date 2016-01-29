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


FUNCTION EventLog( nUser, cModul, cKomponenta, cFunkcija, nN1, nN2, nCount1, nCount2, cC1, cC2, cC3, dDatum1, dDatum2, cSql, cOpis )
   RETURN



/*! \fn Logirati(cModul,cKomponenta,cFunkcija)
 *  \brief Provjerava da li funkciju treba logirati
 *  \param cModul modul
 *  \param cKomponenta komponenta unutar modula
 *  \param cFunkcija konkretna funkcija
 *  \return .t. or .f.
 */

FUNCTION Logirati( cModul, cKomponenta, cFunkcija )

   LOCAL lLogirati := .F.

   RETURN lLogirati
