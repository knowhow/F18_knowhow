#include "fmk.ch"



// k1 - karakteristike
function P_K1( cId, dx, dy )
local _area, _i
private ImeKol := {}
private Kol := {}

_area := SELECT()

O_K1

AADD(ImeKol, { "ID", {|| id}, "id" })
add_mcode(@ImeKol)
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })

for _i := 1 to LEN( ImeKol )
	AADD( Kol, _i )
next

select ( _area )
return PostojiSifra( F_K1, I_ID, 10, 60, "Lista - K1", @cId, dx, dy )



/*! \fn P_VrsteP(cId,dx,dy)
 *  \brief Otvara sifranik vrsta placanja 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_VrsteP(cId,dx,dy)
PRIVATE ImeKol, Kol:={}

O_VRSTEP

ImeKol:={ { "ID ",             {|| id }                       ,  "id"  , {|| .t.}, {|| sifra_postoji(wId)}      },;
          { PADC("Naziv", 20), {|| Padr( ToStrU( naz ), 20 ) },  "naz" };
        }

FOR i:=1 TO LEN(ImeKol)
  AADD(Kol,i)
NEXT

return p_sifra(F_VRSTEP, 1, 10, 55, "Šifarnik vrsta plaćanja",@cid, dx, dy)



