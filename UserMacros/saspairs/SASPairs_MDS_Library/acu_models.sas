data spmdslib.acu_models;
/* --------------------------------------------------------
   fits default VA, VC, VD, and VU models
   -------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
begin model data=spmdslib.acu;
begin model data=spmdslib.acu_noa;
begin model data=spmdslib.acu_noc;
begin model data=spmdslib.acu_noacorr;
begin model data=spmdslib.acu_noccorr;
begin model data=spmdslib.acu_noucorr;
;;;;
run;
