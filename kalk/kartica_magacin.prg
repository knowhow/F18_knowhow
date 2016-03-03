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



/*! KM2()
 *  Magacinska kartica kao pomoc pri unosu 14-ke
 */

FUNCTION KM2()

   LOCAL nR1, nR2, nR3
   PRIVATE GetList := {}

   SELECT  roba
   nR1 := RecNo()
   SELECT kalk_pripr
   nR2 := RecNo()
   SELECT tarifa
   nR3 := RecNo()
   my_close_all_dbf()
   Kartica_magacin( _IdFirma, _idroba, _IdKonto2 )
   o_kalk_edit()
   SELECT roba
   GO nR1
   SELECT kalk_pripr
   GO nR2
   SELECT tarifa
   GO nR3
   SELECT kalk_pripr

   RETURN NIL


/*! \fn MarkBrDok(fNovi)
 *  \brief Odredjuje sljedeci broj dokumenta uzimajuci u obzir marker definisan u polju koncij->m1
 */

FUNCTION MarkBrDok( fNovi )

   LOCAL nArr := Select()

   _brdok := cNBrDok
   IF fNovi .AND. KONCIJ->( FieldPos( "M1" ) ) <> 0
      SELECT KONCIJ
      HSEEK _idkonto2
      IF !Empty( m1 )
         SELECT kalk; SET ORDER TO TAG "1"; SEEK _idfirma + _idvd + "X"
         SKIP -1
         _brdok := Space( 8 )
         DO WHILE !Bof() .AND. idvd == _idvd
            IF Upper( Right( brdok, 3 ) ) == Upper( KONCIJ->m1 )
               _brdok := brdok
               EXIT
            ENDIF
            SKIP -1
         ENDDO
         _Brdok := UBrojDok( Val( Left( _brdok, 5 ) ) + 1, 5, KONCIJ->m1 )
      ENDIF
      SELECT ( nArr )
   ENDIF
   @  m_x + 2, m_y + 46  SAY _BrDok COLOR F18_COLOR_INVERT 

   RETURN .T.
