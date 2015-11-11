data spmdslib.general_factor_c;
/* -------------------------------------------------
   Va = free, Vc = general factor + specifics, Vu
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=UN, VC=GF+Sp, VU=LD
  begin matrices
    va
    vc
    fc U 1
    sc
    vu
    fu L
  end matrices
  begin mx
    co va fu
    fi vu vc
  end mx
  begin iml
    if pair_number = 1 then do;
      vc = fc * t(fc) + sc;
      vu = fu * t(fu);
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;


