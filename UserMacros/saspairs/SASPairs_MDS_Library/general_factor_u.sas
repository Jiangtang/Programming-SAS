data spmdslib.general_factor_u;
/* -------------------------------------------------
   Va, Vc = free, Vu = general factor + specifics
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=UN, VC=UN, VU=GF+Sp
  begin matrices
    va
    vc
    vu
    fu U &np 1
    su
  end matrices
  begin mx
    co va fu su
    fi vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vu = fu * t(fu) + su;
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;
