#include "f18.ch"

#define INI_FNAME ".f18_config.ini"

// --------------------------------------------------------------
// citaj vrijednost ini fajla
// .t. ako je sve ok
// --------------------------------------------------------------
function f18_ini_read( sect, ini, global )
local tmp_ini_section
local tmp_key
local ini_file
local ini_read

if (global == NIL) .or. (global == .f.)
	ini_file := my_home() + INI_FNAME
else
	ini_file := my_home_root() + INI_FNAME
endif

if !FILE( ini_file )
	log_write( "Ne postoji ini fajl " + ini_file )
else
    ini_read := hb_iniread( ini_file )
endif


if EMPTY( ini_read )
	log_write( "Fajl je prazan: " + ini_file )

else
    if HB_HHASKEY(ini_read, sect)

    tmp_ini_section := ini_read[sect]
    for each tmp_key in ini:Keys
            // napuni ini sa onim sto si procitao
            if HB_HHASKEY(tmp_ini_section, tmp_key)
                ini[tmp_key] := tmp_ini_section[tmp_key]
            endif
    next
        
    endif
endif
 
return .t.

function f18_ini_write( sect, ini, global )
local tmp_key
local ini_file
local ini_read

if (global == NIL) .or. (global == .f.)
	ini_file := my_home() + INI_FNAME
else
	ini_file := my_home_root() + INI_FNAME
endif

ini_read := hb_iniread( ini_file )

if EMPTY(ini_read)
   ini_read := hb_hash()
endif

if !HB_HHASKEY(ini_read, sect)
   ini_read[sect] := hb_hash()
endif

// napuni ini_read sa vrijednostima iz ini matrice
for each tmp_key in ini:Keys
       ini_read[sect][tmp_key] := ini[tmp_key]
next


if !hb_IniWrite( ini_file, ini_read, "#F18 config", "#end of config" )
	log_write( "Ne mogu snimiti ini fajl "  + ini_file )
    return .f.
endif

return .t.
