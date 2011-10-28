#include "fin.ch"


/*! \file fmk/fin/rpt/1g/ostalo.prg
 *  \brief Ostali izvjestaji
 */

/*! \fn Ostalo()
 *  \brief Menij ostalih izvjestaja
 */
 
function Ostalo()

private Izbor:=1
private opc:={}
private opcexe:={}
//private picBHD:=FormPicL(gPicBHD,16)
//private picDEM:=FormPicL(gPicDEM,12)

cSecur:=SecurR(KLevel,"Ostalo")
if ImaSlovo("X",cSecur)
  MsgBeep("Opcija nedostupna !")
  return
endif

AADD(opc,"1. pregled promjena na racunu               ")
AADD(opcexe,{|| PrPromRn()})

if IzFMKIni("FIN","Bilansi_Jerry","N",KUMPATH)=="D"
	lBilansi:=.t.
  	AADD(opc,"2. bilans stanja")
	AADD(opcexe,{|| if (lBilansi,BilansS(),nil)})
  	AADD(opc,"3. bilans uspjeha")
	AADD(opcexe,{|| if (lBilansi,BilansU(),nil)})
else
  	lBilansi:=.f.
  	AADD(opc,"2. ---------------------")
	AADD(opcexe,{|| nil})
  	AADD(opc,"3. ---------------------")
	AADD(opcexe,{|| nil})
endif

if (IsRamaGlas())
	AADD(opc,"4. specifikacije za pogonsko knjigovodstvo")
	AADD(opcexe,{|| IzvjPogonK() })
endif

Menu_SC("ost")
return .f.


