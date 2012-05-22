#include "fmk.ch"


// -----------------------------------------------------
// konvertuje nase karaktere u US format
// -----------------------------------------------------
function to_us_encoding( cp852_str )
local _us_str
local _cnt
local _arr := _get_us_codes_array()

_us_str := hb_strtoutf8( cp852_str )

for _cnt := 1 to LEN( _arr )
	_us_str := STRTRAN( _us_str, _arr[ _cnt, 1 ], _arr[ _cnt, 2 ] )
next

return _us_str


// -------------------------------------------------
// vraca matricu sa US kodovima
// -------------------------------------------------
static function _get_us_codes_array()
local _arr := {}

AADD( _arr, { "Ž", "Z" } )
AADD( _arr, { "ž", "z" } )
AADD( _arr, { "Č", "C" } )
AADD( _arr, { "č", "c" } )
AADD( _arr, { "Ć", "C" } )
AADD( _arr, { "ć", "c" } )
AADD( _arr, { "Đ", "Dj" } )
AADD( _arr, { "đ", "dj" } )
AADD( _arr, { "Š", "S" } )
AADD( _arr, { "š", "s" } )

return _arr


// -----------------------------------------------------
// konvertuje nase karaktere u windows-1250 format
// -----------------------------------------------------
function to_win1250_encoding( cp852_str )
local _win_str
local _cnt
local _arr := _get_win_1250_codes_array()

_win_str := hb_strtoutf8( cp852_str )

for _cnt := 1 to LEN( _arr )
	_win_str := STRTRAN( _win_str, _arr[ _cnt, 1 ], _arr[ _cnt, 2 ] )
next

return _win_str


// -------------------------------------------------
// vraca matricu sa windows 1250 kodovima
// -------------------------------------------------
static function _get_win_1250_codes_array()
local _arr := {}

AADD( _arr, { "Č", CHR(138) } )
AADD( _arr, { "č", CHR(154) } )
AADD( _arr, { "Ć", CHR(230) } )
AADD( _arr, { "ć", CHR(198) } )
AADD( _arr, { "Ž", CHR(200) } )
AADD( _arr, { "ž", CHR(232) } ) 
AADD( _arr, { "Đ", CHR(158) } )
AADD( _arr, { "đ", CHR(142) } )
AADD( _arr, { "Š", CHR(240) } )
AADD( _arr, { "š", CHR(208) } )

return _arr





// --------------------------------------------------------------------
// pretvara specijalne string karaktere u xml encoding kraktere
// npr: Č -> &#262; itd...
// to_xml_encoding( "Čekić" ) 
//  => "&#262;eki&#269;"
// --------------------------------------------------------------------
function to_xml_encoding( cp852_str )
local _ent_arr := _get_ent_codes_array()
local _cnt
local _utf8_str 

_utf8_str := hb_strtoutf8( cp852_str )

for _cnt := 1 to LEN( _ent_arr )
	_utf8_str := STRTRAN( _utf8_str, _ent_arr[ _cnt, 1 ], _ent_arr[ _cnt, 2 ] )
next

return _utf8_str


// ------------------------------------------------
// napuni i vrati matricu sa parovima 
// utf8 karakter, xml entity code
// ------------------------------------------------
static function _get_ent_codes_array() 
local _arr := {}

// rezervisani znakovi

AADD( _arr, { "&", "&amp;" } ) 
AADD( _arr, { "!", "&#33;" } ) 
AADD( _arr, { '"', "&quot;" } ) 
AADD( _arr, { "'", "&#39;" } ) 
AADD( _arr, { ",", "&#44;" } ) 
AADD( _arr, { "<", "&lt;" } ) 
AADD( _arr, { ">", "&gt;" } ) 

// bh karakteri
AADD( _arr, { "č", "&#269;" } ) 
AADD( _arr, { "ć", "&#263;" } ) 
AADD( _arr, { "ž", "&#382;" } ) 
AADD( _arr, { "š", "&#353;" } ) 
AADD( _arr, { "đ", "&#273;" } ) 
AADD( _arr, { "Č", "&#268;" } ) 
AADD( _arr, { "Ć", "&#262;" } ) 
AADD( _arr, { "Ž", "&#381;" } ) 
AADD( _arr, { "Š", "&#352;" } ) 
AADD( _arr, { "Đ", "&#272;" } ) 

return _arr


