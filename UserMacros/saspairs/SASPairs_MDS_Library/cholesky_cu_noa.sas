data spmdslib.cholesky_cu_noa;
/* -------------------------------------------------
   Va = 0, Vc = Cholesky, Vu = Cholesky
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
NOTE WELL: This is the same model as cholesky_c_noa because of the
           parameterizatin of VU. It is included here as a convenience.
BEGIN MODEL   VA=0, VC=LD, VU=LD
  begin matrices
    va
    vc
    fc L
    vu
    fu L
  end matrices
  begin mx
    co fu
    fi va vc vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vc = fc * t(fc);
      vu = fu * t(fu);
      p1 = vc + vu;
      p2 = p1;
    end;
    r12 = gamma_c * vc;
  end iml
END MODEL
;;;;
run;
