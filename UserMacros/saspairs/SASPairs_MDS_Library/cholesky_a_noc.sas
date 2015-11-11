data spmdslib.cholesky_a_noc;
/* -------------------------------------------------
   Va = Cholesky, Vc = 0, Vu
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=LD, VC=0, VU=LD
  begin matrices
    va
    fa L
    vc
    vu
    fu L
  end matrices
  begin mx
    co fa fu
    fi va vc vu
  end mx
  begin iml
    if pair_number = 1 then do;
      va = fa * t(fa);
      vu = fu * t(fu);
      p1 = va + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va;
  end iml
END MODEL
;;;;
run;
