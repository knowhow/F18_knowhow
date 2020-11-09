#include "f18.ch"

FUNCTION fin_eIsporukeNabavkeMenu()

    LOCAL aOpc := {}
    LOCAL aOpcexe := {}
    LOCAL nIzbor := 1

    AAdd( aOpc, "1. parametri enabavke             " )
    AAdd( aOpcexe, {|| parametri_eNabavke() } )

    AAdd( aOpc, "2. provjera knjiženja enabavke    " )
    AAdd( aOpcexe, {|| check_eNabavke() } )

    AAdd( aOpc, "3. generacija enabavke            " )
    AAdd( aOpcexe, {|| gen_eNabavke() } )

   // AAdd( aOpc, "4. eksport enabavke               " )
   // AAdd( aOpcexe, {|| export_eNabavke() } )

    AAdd( aOpc, "5. parametri eisporuke            " )
    AAdd( aOpcexe, {|| parametri_eIsporuke() } )

    AAdd( aOpc, "6. generacija eisporuke            " )
    AAdd( aOpcexe, {|| gen_eIsporuke() } )
 
    f18_menu( "fin_eispn", .F., nIzbor, aOpc, aOpcexe )
 
    RETURN .T.
