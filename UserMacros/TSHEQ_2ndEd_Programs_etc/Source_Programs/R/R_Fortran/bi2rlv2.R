setwd("d:/zi/biostat/wellek/Rtest/DLLFortran")
dyn.load("d:/zi/biostat/wellek/Rtest/DLLFortran/bi2rlv2.dll")
is.loaded("bi2rlv2_")

.Fortran("bi2rlv2")
