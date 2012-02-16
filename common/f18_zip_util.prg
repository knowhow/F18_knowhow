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


// ---------------------------------------------------
// zipovanje fajlova
// ---------------------------------------------------
function zip_files( output_file_name, files )

__zip( output_file_name, files )

return



// ------------------------------------------------------
// ------------------------------------------------------
static function __zip( zf_name, files )
local _h_zip
local _file
local _cnt := 0

// otvori fajl
_h_zip := HB_ZIPOPEN( zf_name )

IF !EMPTY( _h_zip )

    Box(, 2, 65 )

        @ m_x + 1, m_y + 2 SAY "Kompresujem fajl: " + ALLTRIM( zf_name )

        FOR EACH _file IN files
            // ako postoji fajl
            IF !EMPTY( _file ) .AND. FILE( _file )
                IF ! ( _file == zf_name )
                    ++ _cnt
                    @ m_x + 2, m_y + 2 SAY PADL( ALLTRIM(STR( _cnt )), 3 ) + ") ..." + PADL( ALLTRIM( _file ), 58 )
                    HB_ZipStoreFile( _h_zip, _file, _file, nil )
                ENDIF
            ENDIF
        NEXT

        HB_ZIPCLOSE( _h_zip, "" )
    
    BoxC()

ENDIF

return .t.




