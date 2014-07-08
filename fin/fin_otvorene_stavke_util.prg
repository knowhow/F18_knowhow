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

#include "fin.ch"


/*! \fn OStUndo()
 *  \brief Otvorene stavke - UNDO operacija
 */
FUNCTION OStUndo()

   IF !SigmaSif( "SCUNDO" )
      MsgBeep( "Nemate ovlastenja za koristenje ove operacije!" )
      RETURN
   ENDIF

   MsgBeep( "Prije ove operacije obavezno arhivirati podatke!" )

   dDatOd := CToD( "" )
   dDatDo := Date()
   cPartn := Space( 6 )
   cKonto := "2120"
   cVNal := PadR( "61;", 40 )
   cDp := "1"

   O_SUBAN
   SELECT suban

   cKonto := PadR( cKonto, Len( suban->idkonto ) )
   cPartn := PadR( cPartn, Len( suban->idPartner ) )

   // setuj parametre
   IF GetVars( @dDatOd, @dDatDo, @cPartn, @cKonto, @cDp, @cVNal ) == 0
      MsgBeep( "Operacija prekinuta !!!" )
      RETURN
   ENDIF

   // pokreni undo opciju
   OStRunUndo( dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal )

   IF Pitanje(, "Pokrenuti opciju automatskog zatvaranja stavki?", "D" ) == "D"
      fin_automatsko_zatvaranje_otvorenih_stavki( .T., cKonto, cPartn )
   ENDIF

   RETURN



/*! \fn GetVars(dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal)
 *  \brief Setuj parametre
 */
STATIC FUNCTION GetVars( dDatOd, dDatDo, cPartn, cKonto, cDp, cVNal )

   O_PARTN
   O_KONTO

   Box(, 5, 60 )
   @ m_x + 1, m_y + 2 SAY "Datum od" GET dDatOd
   @ m_x + 1, m_y + 21 SAY "do" GET dDatDo
   @ m_x + 2, m_y + 2 SAY "Konto   " GET cKonto VALID P_KontoFin( @cKonto ) PICT "@!"
   @ m_x + 3, m_y + 2 SAY "Partner (prazno-svi)" GET cPartn VALID Empty( cPartn ) .OR. P_Firma( @cPartn ) PICT "@!"
   @ m_x + 4, m_y + 2 SAY "Konto duguje / potrazuje" GET cDp WHEN {|| cDp := iif( cKonto = '54', '2', '1' ), .T. } VALID cDp $ "12 "
   @ m_x + 5, m_y + 2 SAY "Vrste naloga" GET cVNal
   READ
   BoxC()

   IF LastKey() == K_ESC
      RETURN 0
   ENDIF

   RETURN 1



/*! \fn OStRunUndo()
 *  \brief glavna funkcija obrade dokumenta
 */
STATIC FUNCTION OStRunUndo( dDOd, dDDo, cIdPartn, cIdKonto, cDugPot, cVNal )

   LOCAL _rec

   SELECT suban
   SET ORDER TO TAG "1"
   GO TOP

   IF !Empty( cIdPartn )
      SEEK gFirma + cIdKonto + cIdPartn
   ELSE
      SEEK gFirma + cIdKonto
   ENDIF

   cBrNal := ""
   cTipNal := ""
   cKupac := ""

   Box(, 3, 70 )

   DO WHILE !Eof() .AND. field->idkonto = cIdKonto .AND. field->datdok <= dDatDo .AND. if( !Empty( cIdPartn ), field->idpartner = cIdPartn, .T. )

      // uzmi broj prvog naloga
      cBrNal := field->brnal
      cTipNal := field->idvn
      cKupac := field->idpartner

      SELECT partn
      hseek cKupac

      SELECT suban
	
      @ 1 + m_x, 2 + m_y SAY "Partner: " + partn->naz
	
      // ako tip naloga nije u zadatim tipovima naloga
      IF At( cTipNal, cVNal ) == 0
         SKIP
         LOOP
      ENDIF
	
      nIznBhd := 0
      nIznDem := 0
	
      @ 2 + m_x, 2 + m_y SAY "Nalog: " + gFirma + "-" + cTipNal + "-" + AllTrim( cBrNal )
	
      DO WHILE !Eof() .AND. field->idkonto = cIdKonto .AND. field->idpartner = cKupac .AND. field->datdok <= dDatDo .AND. field->brnal = cBrNal .AND. field->idvn = cTipNal
		
         DO CASE
         CASE cDugPot == "1"
            // varijanta duguje
            IF ( field->d_p == "1" )
               SKIP
            ENDIF
				
         CASE cDugPot == "2"
            // varijanta potrazuje
            // uplate
            IF ( field->d_p == "2" )
               SKIP
            ENDIF
         ENDCASE
		
         nIznBhd += field->iznosbhd
         nIznDem += field->iznosdem
		
         @ 3 + m_x, 2 + m_y SAY Space( 50 )
         @ 3 + m_x, 2 + m_y SAY "Suma += " + AllTrim( Str( nIznBhd ) )
		
         SKIP
		
         f18_lock_tables( { "fin_suban" } )
         sql_table_update( nil, "BEGIN" )
		
         // ako je sljedeci nalog razlicit, updateuj postojeci sa sumom
         IF ( field->brnal <> cBrNal .OR. field->idvn <> cTipNal )

            SKIP -1

            _rec := dbf_get_rec()

            _rec[ "iznosbhd" ] := nIznBhd
            _rec[ "iznosdem" ] := nIznDem
            _rec[ "brdok" ] := ""
            _rec[ "otvst" ] := ""

            update_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

            SKIP

         ELSE

            // izbrisi prethodnu stavku
            SKIP -1

            _rec := dbf_get_rec()
            delete_rec_server_and_dbf( "fin_suban", _rec, 1, "CONT" )

            SKIP

         ENDIF
			
         f18_free_tables( { "fin_suban" } )
         sql_table_update( nil, "END" )

      ENDDO

   ENDDO

   BoxC()

   MsgBeep( "Opcija zavrsena!#Pogledajte rezultate..." )

   RETURN



/*! \fn OStAfterAzur(cIdPart, cIdKonto, cDp)
 *  \brief Pokrece asistenta otvorenih stavki poslije azuriranja naloga
 */
FUNCTION OStAfterAzur( aPartList, cIdPart, cIdKonto, cDp )
   RETURN
