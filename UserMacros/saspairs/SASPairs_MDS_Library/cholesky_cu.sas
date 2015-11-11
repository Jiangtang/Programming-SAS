data spmdslib.cholesky_cu;
/* -------------------------------------------------
   Va, Vc = Cholesky, Vu = Cholesky
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
NOTE WELL: This is the same model as cholesky_c because of the
           parameterizatin of VU. It is included here as a convenience.
BEGIN MODEL   VA=UN, VC=LD, VU=LD
  begin matrices
    va
    vc
    fc L
    vu
    fu L
  end matrices
  begin mx
    co va fu
    fi vc vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vc = fc * t(fc);
      vu = fu * t(fu);
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;
