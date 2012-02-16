/* 
 * This file is part of the bring.out knowhow ERP, a free and open source 
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out d.o.o Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including knowhow ERP specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "fmk.ch"


function zip_files( file_name, files )

__zip( file_name, file_name, files )

return


function unzip_files()

return




static function __zip( zf_path, zf_name, files )
local hZip
local _zip_file_name, _file

// ovo je izlazni fajl
_zip_file_name := HB_FNameMerge( zf_path, zf_name )

hZip := HB_ZIPOPEN( _zip_file_name )

IF !EMPTY( hZip )

    ? "Arhiviram fajl:", _zip_file_name

    FOR EACH _file IN files
        IF !EMPTY( _file )
            IF ! (_file == _zip_file_name )
                ? "Dodajem fajl:", _file
                HB_ZipStoreFile( hZip, _file, _file, nil )
            ENDIF
        ENDIF
    NEXT

    HB_ZIPCLOSE( hZip, "" )

ENDIF

return .t.




