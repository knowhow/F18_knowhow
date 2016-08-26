/*
 * This file is part of the bring.out knowhow ERP, a free and open source
 * Enterprise Resource Planning software suite,
 * Copyright (c) 1994-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_knowhow.md located at the
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */

#include "f18.ch"

FUNCTION fin_kamate_print()

   LOCAL _mala_kamata := 15
   LOCAL _var_obr := "Z"
   LOCAL _kum_kam := "D"
   LOCAL _pdv_obr := "D"


   IF pitanje(, "Rekalkulisati osnovni dug ?", "N" ) == "D"
      fin_kamate_rekalkulisi_osnovni_dug()
   ENDIF


   fin_kamate_kreiraj_pomocnu_tabelu()

   Box(, 6, 70 )

   @ m_x + 1, m_y + 2 SAY "Ne ispisuj kam.listove za iznos kamata ispod" GET _mala_kamata ;
      PICT "999999.99"

   @ m_x + 2, m_y + 2 SAY "Varijanta (Z-zatezna kamata,P-prosti kamatni racun)" GET _var_obr ;
      VALID _var_obr $ "ZP" PICT "@!"

   @ m_x + 4, m_y + 2 SAY "Prikazivati kolonu 'kumulativ kamate' (D/N) ?" GET _kum_kam ;
      VALID _kum_kam $ "DN" PICT "@!"

   @ m_x + 5, m_y + 2 SAY "Dodaj PDV na obracun kamate (D/N) ?" GET _pdv_obr ;
      VALID _pdv_obr $ "DN" PICT "@!"

   READ

   BoxC()

   fin_kam_prikaz_kumulativ( _kum_kam )
   fin_kam_obracun_pdv( _pdv_obr )

   IF !start_print()
      RETURN .F.
   ENDIF

   ?

   O_KAM_PRIPR
   SELECT kam_pripr
   GO TOP

   DO WHILE !Eof()

      _id_partner := field->idpartner

      PRIVATE nOsnDug := 0
      PRIVATE nKamate := 0
      PRIVATE nSOsnSD := 0
      PRIVATE nPdv := 0
      PRIVATE nPdvTotal := 0
      PRIVATE nKamTotal := 0

      IF fin_kamate_obracun_sa_kamatni_list( _id_partner, .F., _var_obr ) > _mala_kamata

         my_flock()

         SELECT pom
         APPEND BLANK

         REPLACE field->idpartner WITH _id_partner
         REPLACE field->osndug WITH nOsnDug
         REPLACE field->kamate WITH nKamate
         REPLACE field->pdv WITH nPdvTotal

         my_unlock()

         SELECT kam_pripr
         fin_kamate_obracun_sa_kamatni_list( _id_partner, .T., _var_obr )

      ENDIF

      SELECT kam_pripr
      SEEK _id_partner + Chr( 250 )

   ENDDO

   end_print()

   O_KAM_PRIPR
   SELECT kam_pripr
   GO TOP

   RETURN .T.
