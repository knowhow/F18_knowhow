#include "f18.ch"

function harbour_base()
local aRez

TEST_LINE(hb_ValToStr( 4 )                     , "         4"    )
TEST_LINE(hb_ValToStr( 4.0 / 2 )               , "         2.00" )
TEST_LINE(hb_ValToStr( "String" )              , "String"        )
TEST_LINE(hb_ValToStr( hb_SToD( "20010101" ) ) , "01.01.01"      )
TEST_LINE(hb_ValToStr( NIL )                   , "NIL"           )
TEST_LINE(hb_ValToStr( .f. )                   , ".F."           )

TEST_LINE(hb_ValToStr( .t. )                   , ".T."           )

aRez := {}
SjeciStr( "jedan dva tri cetiri pet sest sedam osam devet ", 20,  @aRez)
TEST_LINE(pp(aRez), "(array): 1 / jedan dva tri        ; 2 / cetiri pet sest      ; 3 / sedam osam devet     ; ")

return
