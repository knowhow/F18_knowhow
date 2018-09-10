#!/bin/bash

EXE=cloc #/d/devel/cloc-1.76.exe 

MODULE=F18_SQL
echo ==== $MODULE =============
$EXE F18_1.7_arhiva/ \
   --report-file=$MODULE.cloc

MODULE=F18_common
echo ==== $MODULE =============
$EXE include/ common/ narudzbenica/ string/ reports/ \
   --report-file=$MODULE.cloc

MODULE=F18_scripts
echo ==== $MODULE =============
$EXE scripts/ \
   --report-file=$MODULE.cloc

MODULE=F18_fin
echo ==== $MODULE =============
$EXE  fin/ \
   --report-file=$MODULE.cloc

MODULE=F18_kalk
echo ==== $MODULE =============
$EXE  kalk/ \
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

MODULE=F18_mat
echo ==== $MODULE =============
$EXE  mat/ \
   --report-file=$MODULE.cloc


MODULE=F18_rnal
echo ==== $MODULE =============
$EXE  rnal/ \
   --report-file=$MODULE.cloc

MODULE=F18_kadev
echo ==== $MODULE =============
$EXE  kadev/ \
   --report-file=$MODULE.cloc



$EXE --sum-report \
    F18_SQL.cloc \
    F18_scripts.cloc \
    F18_common.cloc  \
    F18_fin.cloc \
    F18_kalk.cloc \
    F18_fakt.cloc \
    F18_ld.cloc \
    F18_pos.cloc \
    F18_os.cloc \
    F18_epdv.cloc \
    F18_virm.cloc \
    F18_mat.cloc \
    F18_kadev.cloc \
    F18_rnal.cloc \
    --report-file=F18_all.cloc

#{F18_RNAL}rnal/*.prg
#{F18_KADEV}kadev/*.prg
