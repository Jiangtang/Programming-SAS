data spmdslib.general_factor_cu;
/* -------------------------------------------------
   Va = free, Vc & Vu = general factor + specifics
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=UN, VC=GF+Sp, VU=GF+Sp
  begin matrices
    va
    vc
    fc U 1
    sc
    vu
    fu U 1
    su
  end matrices
  begin mx
    co va fu su
    fi vc vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vc = fc * t(fc) + sc;
      vu = fu * t(fu) + su;
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;
