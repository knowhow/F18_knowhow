#include "fmk.ch"




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


