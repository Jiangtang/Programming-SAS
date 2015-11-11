data spmdslib.general_factor_u_noc;
/* -------------------------------------------------
   Va = free, Vc = 0, Vu = general factor + specifics
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=UN, VC=0, VU=GF+Sp
  begin matrices
    va
    vc
    vu
    fu U &np 1
    su
  end matrices
  begin mx
    co va fu su
    fi vc vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vu = fu * t(fu) + su;
      p1 = va + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va;
  end iml
END MODEL
;;;;
run;
