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


#include "kalk.ch"

function FaktKalk()
private Opc:={}
private opcexe:={}

AADD(Opc,"1. magacin fakt->kalk         ")
AADD(opcexe,{|| prenos_fakt_kalk_magacin() })
AADD(Opc,"2. prodavnica fakt->kalk")
AADD(opcexe,{||  prenos_fakt_kalk_prodavnica()  })
AADD(Opc,"3. proizvodnja fakt->kalk")
AADD(opcexe,{||  FaKaProizvodnja() })        
AADD(Opc,"4. konsignacija fakt->kalk")
AADD(opcexe, {|| FaktKonsig() }) 
private Izbor:=1
Menu_SC("faka")
CLOSERET
return



/*! \fn ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor)
 *  \brief Provjera postojanja sifara
 *  \param clDok - "while" uslov za obuhvatanje slogova tekuce baze
 *  \param cImePoljaID - ime polja tekuce baze u kojem su sifre za ispitivanje
 *  \param nOblSif - oblast baze sifrarnika
 *  \param clFor - "for" uslov za obuhvatanje slogova tekuce baze
 */

function ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor,lTest)
local lVrati := .t.
local nArr := SELECT()
local nRec := RECNO()
local lStartPrint := .f.
local cPom3 := ""
LOCAL nR := 0

if lTest == nil
	lTest := .f.
endif

IF clFor == NIL
	clFor:=".t."
ENDIF

private cPom := clDok
private cPom2 := cImePoljaID
private cPom4 := clFor

do while &cPom
    if &cPom4
        SELECT (nOblSif)
        cPom3 := (nArr)->(&cPom2)
        SEEK cPom3
        if !FOUND()  .and.  !(  fakt->(alltrim(podbr)==".")  .and. empty(fakt->idroba))
            // ovo je kada se ide 1.  1.1 1.2
            ++nR
            lVrati:=.f.
            if lTest == .f.
                if !lStartPrint
                    lStartPrint:=.t.
                    StartPrint()
                    ? "NEPOSTOJECE SIFRE:"
                    ? "------------------"
                ENDIF
                ? STR(nR)+") SIFRA '"+cPom3+"'"
            else

      	        nTArea := SELECT()

	            select roba
	            go top
	            seek fakt->idroba

	            if !FOUND()
	                append blank
                    _rec := dbf_get_rec()
	                _rec["id"] := fakt->idroba
	                _rec["naz"] :=  "!!! KONTROLOM UTVRDJENO"
                    update_rec_server_and_dbf( "roba", _rec, 1, "FULL" )
	            endif
	            select (nTArea)

            endif
        ENDIF
    ENDIF
    SELECT (nArr)
    SKIP 1
ENDDO

GO (nRec)
IF lStartPrint
    ?
    EndPrint()
ENDIF

return lVrati






