data spmdslib.general_factor_a;
/* -------------------------------------------------
   Va = general factor + specifics, Vc, Vu
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=GF+Sp, VC=UN, VU=LD
  begin matrices
    va
    fa U 1
    sa
    vc
    vu
    fu L
  end matrices
  begin mx
    co fa fu
    fi va vu
  end mx
  begin iml
    if pair_number = 1 then do;
      va = fa * t(fa) + sa;
      vu = fu * t(fu);
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;
