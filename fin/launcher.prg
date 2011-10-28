#include "fin.ch"

EXTERNAL DESCEND
EXTERNAL RIGHT


/*! \fn function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)
 *  \brief Main fja za FIN.EXE
 */
function Main(cKorisn, cSifra, p3, p4, p5, p6, p7)

MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)

return

function TFileRead()
return


/*! \fn MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)
 *  \brief Glavna funkcija Fin aplikacijskog modula
 */
 
function MainFin(cKorisn, cSifra, p3, p4, p5, p6, p7)

local oPos
local cModul

PUBLIC gKonvertPath:="D"

cModul:="FIN"
PUBLIC goModul


oFin := TFinMod():new(NIL, cModul, D_FI_VERZIJA, D_FI_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)
goModul:=oFin

oFin:run()

return

