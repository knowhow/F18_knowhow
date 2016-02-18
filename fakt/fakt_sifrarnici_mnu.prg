f18head


FUNCTION fakt_sifrarnik()

   PRIVATE opc := {}
   PRIVATE opcexe := {}
   PRIVATE Izbor := 1

   AAdd( opc, "1. opći šifarnici              " )
   AAdd( opcexe, {|| SifFMKSvi() } )


   AAdd( opc, "2. robno-materijalno poslovanje " )
   AAdd( opcexe, {|| SifFMKRoba() } )


   AAdd( opc, "3. fakt->txt" )
   AAdd( opcexe, {|| OSifFtxt(), P_FTxt() } )


   AAdd( opc, "U. ugovori" )
   AAdd( opcexe, {|| o_ugov(), SifUgovori() } )

   Menu_SC( "fsif" )

   RETURN .T.
