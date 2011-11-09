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


#include "rnal.ch"


// --------------------------------------------------
// automatski napravi lami staklo od obicnog
// nEl_nr - redni broj elementa
// nFolNr - broj folija lami stakla
// --------------------------------------------------
function a_lami_gen( nEl_nr, nFolNr, nArt_id )
local i
local nTRec := RECNO()
local nLastNo
local cTmp
local cSchema
local lLast := .t.

do while !EOF() .and. field->art_id == nArt_id
	lLast := .f.
	skip
enddo

skip -1

// ne radi se o zadnjem zapisu....
if lLast == .f.

	nLastNo := field->el_no

	// skontaj koliko treba praznih mjesta....
	nNewNo := nLastNo + ( nFolNr * 2 )

	do while !BOF() .and. field->art_id == nArt_id
	
		// ako si na odabranom record-u, izadji... on nam treba
		if RECNO() == nTRec
			exit
		endif
		
		replace field->el_no with nNewNo
	
		nNewNo -= 1

		skip -1

	enddo

endif

// sada insert novih elemenata....
nTRec := RECNO()
cTmp := "FL-G"
cSchema := ""

// skontaj koja je shema
for i := 1 to nFolNr

	if i <> 1
		cSchema += "-"
	endif
	
	cSchema += cTmp

next

// generisi auto elemente...
auto_el_gen( nArt_id, nil, cSchema, nEl_nr )


return DE_REFRESH 



// -------------------------------------------------------------
// vraæanje lami stakla u prvobitni polozaj, obièno staklo
// -------------------------------------------------------------
function undo_lami_gen()


return



