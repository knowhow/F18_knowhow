#include "fmk.ch"




// pretvara specijalne string karaktere u xml encoding kraktere
// npr: Č -> &#262; itd...

function to_xml_encoding( cp852_str )
local ret_val := ""
local ent_arr := _get_ent_codes_array()
local i
local UTF8_str 

UTF8_str := hb_strtoutf8( cp852_str )

for i:=1 to LEN( ent_arr )
	UTF8_str := STRTRAN( UTF8_str, ent_arr[ i, 1 ], ent_arr[ i, 2 ] )
next

ret_val := UTF8_str

return ret_val


static function _get_ent_codes_array() 
local _arr := {}

// bh karakteri
AADD( _arr, { "č", "&#263;" } ) 
AADD( _arr, { "ć", "&#269;" } ) 
AADD( _arr, { "ž", "&#382;" } ) 
AADD( _arr, { "š", "&#353;" } ) 
AADD( _arr, { "đ", "&#273;" } ) 
AADD( _arr, { "Č", "&#262;" } ) 
AADD( _arr, { "Ć", "&#268;" } ) 
AADD( _arr, { "Ž", "&#381;" } ) 
AADD( _arr, { "Š", "&#352;" } ) 
AADD( _arr, { "Đ", "&#272;" } ) 

// rezervisani znakovi

AADD( _arr, { "&", "&amp;" } ) 
AADD( _arr, { "!", "&#33;" } ) 
AADD( _arr, { '"', "&quot;" } ) 
AADD( _arr, { "'", "&#39;" } ) 
AADD( _arr, { ",", "&#44;" } ) 
AADD( _arr, { "<", "&lt;" } ) 
AADD( _arr, { ">", "&gt;" } ) 

return _arr


