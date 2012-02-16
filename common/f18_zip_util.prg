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
local _error
_error := __zip( output_file_name, files )
return _error


// ---------------------------------------------------
// unzipovanje fajlova
// ---------------------------------------------------
function unzip_files( zip_file_name, extract_destination, files )
local _error
_error := __zip( zip_file_name, extract_destination, files )
return _error



// ------------------------------------------------------
// ------------------------------------------------------
static function __zip( zf_name, files )
local _h_zip
local _file
local _error := 0
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
                    _error := HB_ZipStoreFile( _h_zip, _file, _file, nil )
                    IF ( _error <> 0 )
                        RETURN __zip_error( _error )
                    ENDIF
                ENDIF
            ENDIF
        NEXT

        _error := HB_ZIPCLOSE( _h_zip, "" )
    
    BoxC()

ENDIF

IF ( _error <> 0 )
    RETURN __zip_error( _error )
ENDIF

RETURN _error


// -----------------------------------
// obrada gresaka 
// -----------------------------------
static function __zip_error( err )
IF ( err <> 0 )
    MsgBeep( "Imamo gresku ?!???" + ALLTRIM( STR( _error ) ) )
ENDIF
RETURN


// ------------------------------------------------------
// ------------------------------------------------------
static function __unzip( zf_name, zf_destination, files )
local _h_zip
local _file
local _error := 0
local _cnt := 0
local _extract := .t.
local _scan
local _file_in_zip

// paterni fajlova za ekstrakt
IF ( files == nil )
    files := {}
ENDIF

// otvori zip fajl
_h_zip := HB_UNZIPOPEN( zf_name )

IF !EMPTY( _h_zip )

    Box(, 2, 65 )

        @ m_x + 1, m_y + 2 SAY "Dekompresujem fajl: " + ALLTRIM( zf_name )

        _error := HB_UNZIPFILEFIRST( _h_zip )

        DO WHILE _error == 0
            
            // da li imamo kakve paterne ?
            IF LEN( files ) > 0
                // daj info o zip fajlu...
                HB_UnzipFileInfo( _h_zip, @_file_in_zip )
                _scan := ASCAN( files, { | pattern | HB_WILDMATCH( pattern, _file_in_zip, .t. ) } )
                IF _scan == 0
                    _extract := .f.         
                ENDIF

            ENDIF

            IF _extract
                ++ _cnt
                @ m_x + 2, m_y + 2 SAY PADL( ALLTRIM(STR( _cnt )), 3 ) + ") ..." + PADL( ALLTRIM( _file ), 58 )
                _error := HB_UnzipExtractCurrentFile( _h_zip, NIL, NIL )
                IF ( _error <> 0 )
                    RETURN __zip_error( _error )
                ENDIF
            ENDIF

            _error := HB_UnzipFileNext( _h_zip )
            IF ( _error <> 0 )
                RETURN __zip_error( _error )
            ENDIF

        ENDDO

        _error := HB_UNZIPCLOSE( _h_zip, "" )

    BoxC()

ENDIF

IF ( _error <> 0 )
    RETURN __zip_error( _error )
ENDIF

RETURN _error




