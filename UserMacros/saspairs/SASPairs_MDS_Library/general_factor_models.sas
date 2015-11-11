data spmdslib.general_factor_models;
  length card $80;
  input card $char80.;
datalines4;
Begin model  data = spmdslib.acu
BEGIN MODEL  data = spmdslib.general_factor_a
BEGIN MODEL  data = spmdslib.general_factor_c
BEGIN MODEL  data = spmdslib.general_factor_u
BEGIN MODEL  data = spmdslib.general_factor_ac
BEGIN MODEL  data = spmdslib.general_factor_au
BEGIN MODEL  data = spmdslib.general_factor_acu
;;;;
run;
