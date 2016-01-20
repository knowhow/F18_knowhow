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
#include "cre_all.ch"

FUNCTION is_pdv_obveznik( cIdPartner )

   RETURN IsPdvObveznik( cIdPartner )


FUNCTION IsPdvObveznik( cIdPartner )

   LOCAL cPdvBroj

   cPdvBroj := ALLTRIM( firma_pdv_broj( cIdPartner ) )

   IF LEN( cPdvBroj ) == 12
      RETURN .T.
   ENDIF

   RETURN .F.


FUNCTION IsIno( cIdPartner, lShow )

   // isti je algoritam za utvrdjivanje
   // ino partnera bio dobavljac ili kupac

   RETURN IsInoDob( cIdPartner, lShow )


/*
    Ino dobavljač:
    - PDV broj je prazan
    - Id broj sadrži manje od 13 cifri: npr. ENG105
*/

FUNCTION IsInoDob( cIdPartner, lShow )

   LOCAL cIdBroj
   LOCAL cPdvBroj

   cPdvBroj := ALLTRIM( firma_pdv_broj( cIdPartner ) )
   cIdBroj :=  ALLTRIM( firma_id_broj( cIdPartner ) )

   IF !Empty( cIdBroj )

      IF EMPTY( cPdvBroj ) .AND. Len( cIdBroj ) < 13 .AND. Len( cIdBroj ) > 0
         RETURN .T.
      ELSE
         RETURN .F.
      ENDIF

   ELSE
      RETURN .F.
   ENDIF



/*
   Opis: da li id broj ima 13 cifara
*/
FUNCTION is_idbroj_13cifara( id_broj )

   IF LEN( ALLTRIM( id_broj ) ) == 13
      RETURN .T.
   ENDIF

   RETURN .F.

/*
    primjer: PdvParIIIF ( cIdPartner, 1.17, 1, 0)
    ako je partner pdv obvezinik return 1.17
    ako je no pdv return 1
    ako je ino return 0
*/

FUNCTION PdvParIIIF( cIdPartner, nPdvObv, nNoPdv, nIno, nUndefined )

   IF !is_postoji_partner( cIdPartner )
      RETURN nUndefined
   ENDIF

   IF IsPdvObveznik( cIdPartner )
      RETURN nPdvObv
   ENDIF

   IF IsIno( cIdPartner )
      RETURN nIno
   ELSE
      RETURN nNoPdv
   ENDIF



/*
   u ovo polje se stavlja clan zakona o pdv-u ako postoji
   osnova za oslobadjanje
*/

FUNCTION PdvOslobadjanje( cIdPartner )

   LOCAL cIdBroj

   RETURN cIdBroj := IzSifKPartn( "PDVO", cIdPartner, .F. )


/*
 da li je partner oslobodjen po clanu
*/

FUNCTION IsOslClan( cIdPartner )

   LOCAL lRet := .F.
   LOCAL cClan

   cClan := PdvOslobadjanje( cIdPartner )

   IF cClan <> NIL .AND. !Empty( cClan )
      lRet := .T.
   ENDIF

   RETURN lRet