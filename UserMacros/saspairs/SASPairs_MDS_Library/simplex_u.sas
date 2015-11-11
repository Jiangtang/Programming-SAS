data spmdslib.simplex_u;
/* -----------------------------------------------------------------
   Va = free, Vc = free, Vu = Simplex
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=UN, VC=UN, VU=Simplex
  begin matrices
    va
    vc
    vu
    simplex_u U &np &np
    su
  end matrices
  begin mx
    fi vu simplex_u
    fr autoreg(simplex_u 1)
    co su
  end mx
  begin iml
    if pair_number = 1 then do;
      temp = I(&np) - simplex_u;
      tempinv = inv(temp);
      vu = tempinv * su * t(tempinv);
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;


