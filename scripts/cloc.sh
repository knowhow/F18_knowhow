#!/bin/bash

EXE=cloc #/d/devel/cloc-1.76.exe 

MODULE=F18_SQL
echo ==== $MODULE =============
$EXE sql_scripts/ \
   --report-file=$MODULE.cloc


MODULE=F18_core
echo ==== $MODULE =============
$EXE core/ core_ui2/ core_sql/ core_dbf/ core_pdf/ \
   core_reporting/ core_string/ \
   --report-file=$MODULE.cloc

MODULE=F18_core_semafori
echo ==== $MODULE =============
$EXE  core_semafori/ \
   --report-file=$MODULE.cloc

MODULE=F18_common
echo ==== $MODULE =============
$EXE F18.prg \
   common/ common_legacy/ \
   --report-file=$MODULE.cloc

MODULE=F18_scripts
echo ==== $MODULE =============
$EXE scripts/ \
   --report-file=$MODULE.cloc

MODULE=F18_fiskalizacija
echo ==== $MODULE =============
$EXE fiskalizacija/ \
   --report-file=$MODULE.cloc

MODULE=F18_fin
echo ==== $MODULE =============
$EXE  fin/ \
   --report-file=$MODULE.cloc

MODULE=F18_kalk
echo ==== $MODULE =============
$EXE  kalk/ kalk_legacy/ \
   --report-file=$MODULE.cloc

MODULE=F18_fakt
echo ==== $MODULE =============
$EXE  fakt/ \
   --report-file=$MODULE.cloc

MODULE=F18_ld
echo ==== $MODULE =============
$EXE  ld/ \
   --report-file=$MODULE.cloc

MODULE=F18_pos
echo ==== $MODULE =============
$EXE  pos/ \
   --report-file=$MODULE.cloc

MODULE=F18_os
echo ==== $MODULE =============
$EXE  os/ \
   --report-file=$MODULE.cloc

MODULE=F18_epdv
echo ==== $MODULE =============
$EXE  epdv/ \
   --report-file=$MODULE.cloc

MODULE=F18_virm
echo ==== $MODULE =============
$EXE  virm/ \
   --report-file=$MODULE.cloc

$EXE --sum-report \
    F18_SQL.cloc \
    F18_core.cloc \
    F18_core_semafori.cloc \
    F18_scripts.cloc \
    F18_common.cloc  \
    F18_fiskalizacija.cloc \
    F18_fin.cloc \
    F18_kalk.cloc \
    F18_fakt.cloc \
    F18_ld.cloc \
    F18_pos.cloc \
    F18_os.cloc \
    F18_epdv.cloc \
    F18_virm.cloc \
    --report-file=F18_all.cloc

#{F18_RNAL}rnal/*.prg
#{F18_MAT}mat/*.prg
#{F18_KADEV}kadev/*.prg
