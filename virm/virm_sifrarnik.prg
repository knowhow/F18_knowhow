/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "f18.ch"


function P_VrPrim(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={}
Kol:={}

AADD(Imekol, { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| vpsifra(wid)} } )
AADD(Imekol, { "Opis"   , {|| NAZ              }, "NAZ"      } )
AADD(Imekol, { "Pomocni tekst"   , {|| POM_TXT          }, "POM_TXT"  } )
AADD(Imekol, { "Konto "    , {|| idkonto          }, "idkonto"  } )
AADD(Imekol, { "Partner "    , {|| idpartner         }, "idpartner"  } )
AADD(Imekol, { "Valuta ( ,1,2)"  , {|| PADC(NACIN_PL,14)}, "NACIN_PL" } )
AADD(Imekol, { "Racun"      , {|| RACUN           }, "RACUN"   } )
AADD(Imekol, { "Unos dobavlj (D/N)"   , {|| PADC(DOBAV,13)   }, "DOBAV"    } )

For i:=1 to len(ImeKol); AADD(Kol,i) ; next

vrati:=PostojiSifra(F_VRPRIM,1,10,77,"Lista: Vrste primalaca:",@cId,dx,dy)
return vrati

function P_VrPrim2(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={ { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| vpsifra(wid)} },;
          { "Opis"            , {|| NAZ              }, "NAZ"      },;
          { "Pomocni tekst"   , {|| POM_TXT          }, "POM_TXT"  },;
          { "Konto "    , {|| idkonto          }, "idkonto"  },;
          { "Partner "    , {|| idpartner         }, "idpartner"  },;
          { "Valuta ( ,1,2)"  , {|| PADC(NACIN_PL,14)}, "NACIN_PL" },;
          { "Racun"      , {|| Racun          }, "Racun"   },;
          { "Unos dobavlj (D/N)"   , {|| PADC(DOBAV,13)   }, "DOBAV"    };
        }
Kol:={1,2,3,4,5,6,7,8}
vrati:=PostojiSifra(F_VRPRIM2,1,10,77,"LISTA VRSTA PRIMALACA ZA UPLATNICE:",@cId,dx,dy)
return vrati

function P_LDVIRM(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={ { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| P_VRPRIM(@wId), wnaz := ALLTRIM( PADR( vrprim->naz, 40 ) ) + "...", .t. } },;
          { "Opis"   , {|| NAZ}, "NAZ"      },;
          { "FORMULA"   , {|| formula          }, "formula"  };
        }
Kol:={1,2,3}
vrati:=PostojiSifra(F_LDVIRM,1,10,77,"LISTA LD->VIRM:",@cId,dx,dy)
return vrati

function P_KALVIR(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol:={}
ImeKol:={ { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| P_VRPRIM(@wId), wnaz:=vrprim->naz,.t. } },;
          { "Opis"   , {|| NAZ}, "NAZ"      },;
          { "FORMULA"   , {|| formula          }, "formula"  };
        }
if KALVIR->(fieldpos("pnabr"))<>0
  AADD (ImeKol,{ "Poz.na br.", {|| pnabr }, "pnabr" })
endif
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
vrati:=PostojiSifra(F_KALVIR,1,10,77,"LISTA KALK->VIRM:",@cId,dx,dy)
return vrati



function P_JPrih(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={}
Kol:={}
AADD(Imekol,{ "Vrsta",   {|| Id} ,      "Id" })
AADD(Imekol,{ "N0",      {|| IdN0} ,    "IdN0" })
AADD(Imekol,{ "Kan",     {|| IdKan} ,   "IdKan" })
AADD(Imekol,{ "Ops",     {|| IdOps} ,   "IdOps" })
AADD(Imekol,{ "Naziv",   {|| Naz} ,     "Naz" })
AADD(Imekol,{ "Racun",   {|| Racun} ,   "Racun" })
AADD(Imekol,{ "BudzOrg", {|| BudzOrg} , "BudzOrg" })
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

vrati:=PostojiSifra(F_JPRIH,1,10,77,"Lista Javnih prihoda",@cId,dx,dy)
return vrati


