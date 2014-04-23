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


/* ---------------------------------------- CLASS FinNalozi ------------------------------------------------------- */


CLASS FinNalozi
   
   METHOD New()
   METHOD addNalog( oFinNalog )                // dodaj FinNalog
   METHOD getNalog( cIdFirma, cIdVn, cBrNal )  // nađi FinNalog na osnovu broja

   DATA aNalozi // ARRAY OF FinNalog

ENDCLASS


METHOD FinNalozi:New()

   ::aNalozi := {}

   RETURN Self


METHOD FinNalozi:addNalog( oFinNalog )

    AADD( ::aNalozi, oFinNalog )
    RETURN .T.


METHOD FinNalozi:getNalog( cIdFirma, cIdVn, cBrNal )

    LOCAL nPos

    nPos := ASCAN( ::aNalozi, { | oNalog |  oNalog:cIdFirma == cIdFirma .AND. oNalog:cIdVN == cIdVN .AND. oNalog:cBrNal == cBrNal  } )

    IF nPos > 0
        RETURN ::aNalozi[ nPos ]
    ENDIF

    RETURN NIL



/* ---------------------------------------- CLASS FinNalog ------------------------------------------------------- */

CLASS FinNalog

   Method New( cIdFirma, cIdVn, cBrNal )
   METHOD addStavka( dDatDok ) // dodaj stavku u FIN nalog, interesuje nas sao datum dokumenta
   METHOD setDatumNaloga()
   DATA cIdFirma
   DATA cIdVN
   DATA cBrNal
   DATA dDatumNaloga


   DATA dMinDatDok  // najmanji datum dokumenta unutar naloga
   DATA dMaxDatDok  // najveći datum dokumenta

END CLASS


METHOD FinNalog:New( cIdFirma, cIdVN, cBrNal )

   ::dMinDatDok := NIL
   ::dMaxDatDok := NIL

   ::cIdFirma := cIdFirma
   ::cIdVN := cIdVN
   ::cBrNal := cBrNal

   
   RETURN Self


/*
   dodajemo stavku finansijskog naloga
   interesuje nas samo datum dokumenta
*/
METHOD FinNalog:addStavka( dDatDok )

    IF ::dMinDatDok == NIL
         ::dMinDatDok := dDatDok
    ENDIF

    IF ::dMaxDatDok == NIL
        ::dMaxDatDok := dDatDok
    ENDIF
  
    IF dDatDok < ::dMinDatDok 
         ::dMinDatDok := dDatDok
    ENDIF

    IF dDatDok > ::dMaxDatDok
         ::dMaxDatDok := dDatDok
    ENDIF

    ::setDatumNaloga()
    RETURN .T.


METHOD FinNalog:setDatumNaloga()

   LOCAL nYear, nMonth

   // hbct: Zadnji dan u mjesecu: 17.02.2014 => 28.02.2014
   ::dDatumNaloga := EoM( ::dMaxDatDok )

   RETURN .T.


METHOD FinNalog:validDatum()

   // godina za sve stavke mora biti ista
   IF YEAR( ::dMinDatDok ) != YEAR( ::dMaxDatDok )
        RETURN .F.
   ENDIF

   // sve stavke naloga moraju pripadati jednom mjesecu
   IF MONTH( ::dMinDatDok ) != YEAR( ::dMaxDatDok )
        RETURN .F.
   ENDIF
        
   RETURN .T.
