#include "f18.ch"

function harbour_base()

TEST_LINE( hb_ValToStr( 4 )                     , "         4"    )
TEST_LINE( hb_ValToStr( 4.0 / 2 )               , "         2.00" )
TEST_LINE( hb_ValToStr( "String" )              , "String"        )
TEST_LINE( hb_ValToStr( hb_SToD( "20010101" ) ) , "2001.01.01"    )
TEST_LINE( hb_ValToStr( NIL )                   , "NIL"           )
TEST_LINE( hb_ValToStr( .f. )                   , ".F."           )

TEST_LINE( hb_ValToStr( .t. )                   , ".T."           )

return
