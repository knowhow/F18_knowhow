#!/bin/bash

MODULES="main fin kalk fakt os ld virm epdv rnal kadev test common"
MODULES="$MODULES base admin brojaci partner konto roba parametri narudzbenica string semaphores dbf_create sql sql_data_access fiskalizacija pdv ui_1990  print"

export F18_GT_QTC=1
export F18_DEBUG=1
export F18_FIN=1
export F18_KALK=1
export F18_FAKT=1
export F18_FIN_OSTAVKE=1
export F18_POS=1
export F18_EPDV=1
export F18_CORE_ONLY=1
export F18_OS=1
export F18_LD=1
export F18_VIRM=1

export HB_QT_MAJOR_VER=5

