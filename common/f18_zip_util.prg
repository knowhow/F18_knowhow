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
function zip_files( output_path, output_file_name, files, relative_path )
local _error

IF ( relative_path == NIL )
    relative_path := .f.
ENDIF

IF ( files == NIL ) .or. LEN( files ) == 0
    return MsgBeep( "Nema fajlova za arhiviranje ?!???" )
ENDIF

_error := __zip( output_path, output_file_name, files, relative_path )

return _error


// ---------------------------------------------------
// unzipovanje fajlova
// ---------------------------------------------------
function unzip_files( zip_path, zip_file_name, extract_destination, files )
local _error
_error := __unzip( zip_path, zip_file_name, extract_destination, files )
return _error



// ------------------------------------------------------
// ------------------------------------------------------
static function __zip( zf_path, zf_name, files, relative_path )
local _h_zip
local _file
local _error := 0
local _cnt := 0
local _zip_file := zf_path + zf_name
local __file_path, __file_ext, __file_name
local _a_file, _a_dir

// otvori fajl
_h_zip := HB_ZIPOPEN( _zip_file )

IF !EMPTY( _h_zip )

    Box(, 2, 65 )

        @ m_x + 1, m_y + 2 SAY "Kompresujem fajl: ..." + PADL( ALLTRIM( _zip_file ), 40 )

        FOR EACH _file IN files
            IF !EMPTY( _file )  

                // odvoji mi lokaciju fajlova i nazive
                HB_FNameSplit( _file, @__file_path, @__file_name, @__file_ext )

                _a_dir := HB_DirScan( __file_path, __file_name + __file_ext )                
                    
                FOR EACH _a_file IN _a_dir
                    IF ! ( __file_path + _a_file[1] == _zip_file )

                        ++ _cnt

                        @ m_x + 2, m_y + 2 SAY PADL( ALLTRIM(STR( _cnt )), 3 ) + ") ..." + PADL( ALLTRIM( __file_path + _a_file[1] ), 58 )

                        IF relative_path 
                            _error := HB_ZipStoreFile( _h_zip, __file_path + _a_file[1], __file_path + _a_file[1], nil )
                        ELSE
                            _error := HB_ZipStoreFile( _h_zip, _a_file[1], _a_file[1], nil )
                        ENDIF

                        IF ( _error <> 0 )
                            RETURN __zip_error( _error )
                        ENDIF

                    ENDIF
                NEXT
                
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
    MsgBeep( "Imamo gresku ?!???" + ALLTRIM( STR( err ) ) )
ENDIF
RETURN


// ------------------------------------------------------
// ------------------------------------------------------
static function __unzip( zf_path, zf_name, zf_destination, files )
local _h_zip
local _file
local _error := 0
local _cnt := 0
local _extract := .t.
local _scan
local _file_in_zip
local _zip_file := zf_path + zf_name
local __file, __date, __time, __size

// paterni fajlova za ekstrakt
IF ( files == NIL )
    files := {}
ENDIF

IF ( zf_destination == NIL ) 
    zf_destination := ""
ENDIF

// otvori zip fajl
_h_zip := HB_UNZIPOPEN( _zip_file )

IF !EMPTY( _h_zip )

    Box(, 2, 65 )

        @ m_x + 1, m_y + 2 SAY "Dekompresujem fajl: ..." + PADL( ALLTRIM( _zip_file ), 30 )

        IF !EMPTY( zf_destination )
            // skoci u direktorij za raspakivanje ...
            DirChange( zf_destination )
        ENDIF

        _error := HB_UNZIPFILEFIRST( _h_zip )

        DO WHILE _error == 0
 
            HB_UnzipFileInfo( _h_zip, @__file, @__date, @__time, , , , @__size )

            IF ( __file == NIL ) .OR. EMPTY( __file )
                _error := HB_UnzipFileNext( _h_zip )
            ENDIF

            // da li imamo kakve paterne ?
            IF LEN( files ) > 0
                // daj info o zip fajlu...
                _scan := ASCAN( files, { | pattern | HB_WILDMATCH( pattern, __file, .t. ) } )
                IF _scan == 0
                    _extract := .f.         
                ENDIF

            ENDIF

            IF _extract

                ++ _cnt

                @ m_x + 2, m_y + 2 SAY PADL( ALLTRIM(STR( _cnt )), 3 ) + ") ... " + PADR( ALLTRIM( __file ), 40 )

                _error := HB_UnzipExtractCurrentFile( _h_zip, NIL, NIL )

                IF ( _error <> 0 )
                    RETURN __zip_error( _error )
                ENDIF

            ENDIF

            // ovdje ne treba obrada error-a
            // zato sto je kraj arhive greska = -100
            _error := HB_UnzipFileNext( _h_zip )

        ENDDO

        _error := HB_UNZIPCLOSE( _h_zip, "" )

    BoxC()

ENDIF

IF ( _error <> 0 )
    RETURN __zip_error( _error )
ENDIF

RETURN _error




