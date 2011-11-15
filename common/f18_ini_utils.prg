#include "fmk.ch"

// --------------------------------------------------------------
// citaj vrijednost ini fajla
// --------------------------------------------------------------
function f18_ini_read( cSrch_sect, cSrch_key, cIni_file )
local aIni
local aSect
local cSect
local cKey
local cValue := ""

if cIni_file == nil
	cIni_file := my_home() + ".f18_config.ini"
endif

aIni := hb_iniread( cIni_file )

if EMPTY( aIni )
	return ""
endif

for each cSect in aIni:Keys
 
	if cSect <> cSrch_sect
		// nisam pronasao sekciju...
		loop
	endif 
	
	aSect := aIni[ cSect ]

	for each cKey in aSect:Keys

		if cKey <> cSrch_key
			// nisam pronasao kljuc...
			loop
		endif

		cValue := aSect[ cKey ]	
	next

next

return cValue


// ------------------------------------------------------------------------
// upisi vrijednost u ini fajl
// ------------------------------------------------------------------------
function f18_ini_write( cWrite_sect, cWrite_key, cWrite_value, cIni_File )
local aIni
local cSect
local aSect
local cKey
local lFoundKey := .f.
local lFoundSect := .f.

if cIni_file == nil
	cIni_file := my_home() + ".f18_config.ini"
endif

if f18_ini_read( cWrite_sect, cWrite_key, cIni_file ) == cWrite_value
	// postoji vec identican parametar 
	// nema se sta upisivati
	return
endif

aIni := hb_iniread( cIni_file )

if EMPTY( aIni )
	return ""
endif

// pronadji sekciju
for each cSect in aIni:Keys
 
	if cSect <> cWrite_sect
		// nisam pronasao sekciju...
		loop
	endif 
	
	// ovo je sekcija...
	aSect := aIni[ cSect ]
	lFoundSect := .t.
	exit

next

if lFoundSect = .f.
	// dodaj sekciju
	AADD( aIni:Keys,  cWrite_sect := hb_hash() )
	aSect := aIni[ cWrite_sect ]
endif

// pronaji key
for each cKey in aSect:Keys

	if cKey <> cWrite_key
		// nisam pronasao kljuc...
		loop
	endif

	aSect[ cKey ] := cWrite_value
	lFoundKey := .t.

next

if lFoundKey = .f.
	
	// dodaj novi key
	AADD( aSect:Keys,  cWrite_key  )
	aSect[ cWrite_key ] := cWrite_value

endif

if !hb_IniWrite( cIni_file, aIni, "#Ini konfiguracioni fajl", "#kraj ini fajla" )
	log_write( "Ne mogu snimiti ini fajl "  + cIni_file )
endif

return



