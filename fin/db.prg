#include "fin.ch"




/*! \fn Dupli(cIdFirma,cIdVn,cBrNal)
 *  \brief Provjera duplog naloga
 *  \param cIdFirma
 *  \param cIdVn
 *  \param cBrNal
 */
 
function Dupli(cIdFirma,cIdVn,cBrNal)

PushWa()

select NALOG
set order to tag "1"

seek cIdFirma+cIdVN+cBrNal

if found()
   MsgO(" Dupli nalog ! ")
   Beep(3)
   MsgC()
   PopWa()
   return .f.
endif

PopWa()
return .t.




