#include "f18.ch"

MEMVAR ImeKol, Kol

// k1 - karakteristike

FUNCTION P_K1( cId, dx, dy )

   LOCAL _area, _i
   PRIVATE ImeKol := {}
   PRIVATE Kol := {}

   _area := Select()

   O_K1

   AAdd( ImeKol, { "ID", {|| id }, "id" } )
   add_mcode( @ImeKol )
   AAdd( ImeKol, { "Naziv", {|| naz }, "naz" } )

   FOR _i := 1 TO Len( ImeKol )
      AAdd( Kol, _i )
   NEXT

   SELECT ( _area )

   RETURN PostojiSifra( F_K1, I_ID, 10, 60, "Lista - K1", @cId, dx, dy )



/* fn P_VrsteP(cId,dx,dy)
 */

FUNCTION P_VrsteP( cId, dx, dy )

   PRIVATE ImeKol, Kol := {}

   O_VRSTEP

   ImeKol := { { "ID ",             {|| id },  "id", {|| .T. }, {|| sifra_postoji( wId ) }      }, ;
      { PadC( "Naziv", 20 ), {|| PadR( ToStrU( naz ), 20 ) },  "naz" };
      }

   FOR i := 1 TO Len( ImeKol )
      AAdd( Kol, i )
   NEXT

   RETURN p_sifra( F_VRSTEP, 1, 10, 55, "Šifarnik vrsta plaćanja", @cid, dx, dy )