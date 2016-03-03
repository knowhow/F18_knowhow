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


function PosPrijava(Fx,Fy)
local nChar
local cKorSif
local nSifLen
local nPom
local cLevel
local cBrojac
local nPrevKorRec

close all

nSifLen:=6

do while .t.

    SETPOS (Fx+4, Fy+15)

    cKorSif := UPPER( GetLozinka( nSifLen ) )

	if ( ALLTRIM( cKorSif ) == "ADMIN" )
		gIdRadnik := "XXXX"
		gKorIme   := "bring.out servis / ADMIN mode"
		gSTRAD  := "A"
		cLevel := L_SYSTEM
		EXIT
	endif

    // obradi specijalne sifre
    HSpecSifre( cKorSif )

    if ( goModul:lTerminate )
  	    return
    endif

    SET CURSOR OFF
    SETCOLOR ( F18_COLOR_NORMAL )

    if SetUser(cKorSif, nSifLen, @cLevel) == 0
  	    loop
    else
  	    exit
    endif

ENDDO

pos_status_traka()

CLOSE ALL

return (cLevel)



// obrada specijalnih sifara...
function HSpecSifre( sifra )

if TRIM( UPPER( sifra )) $ "X"
    goModul:lTerminate := .t.
elseif TRIM( UPPER( sifra )) = "M"
    goModul:quit()
endif

return
