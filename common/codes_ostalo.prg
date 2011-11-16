#include "fmk.ch"



// k1 - karakteristike
function P_K1()
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_K1

AADD(ImeKol, { "ID", {|| id}, "id" })
add_mcode(@ImeKol)
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
PostojiSifra(F_K1, I_ID, 10, 60, "Lista - K1")
return



