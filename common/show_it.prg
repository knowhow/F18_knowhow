#include "fmk.ch"
// ------------------------------------------------
// prikazuje cItem u istom redu gdje je get
// cItem - string za prikazati
// nPadR - n vrijednost pad-a
// ------------------------------------------------
function show_it(cItem, nPadR)

if nPadR <> nil
	cItem := PADR( cItem, nPadR )
endif

@ row(), col() + 3 SAY cItem

return .t.


