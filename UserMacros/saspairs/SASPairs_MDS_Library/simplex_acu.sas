data spmdslib.simplex_acu;
/* -----------------------------------------------------------------
   Va & Vc & Vu = Simplex
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=simplex, VC=simplex, VU=simplex
  begin matrices
    va
    simplex_a U &np &np
    sa
    vc
    simplex_c U &np &np
    sc
    vu
    simplex_u U &np &np
    su
  end matrices
  begin mx
    fi va vc vu simplex_a simplex_c simplex_u
    fr autoreg(simplex_a 1) autoreg(simplex_c 1) autoreg(simplex_u 1)
    co sa su
  end mx
  begin iml
    if pair_number = 1 then do;
      temp = I(&np) - simplex_a;
      tempinv = inv(temp);
      va = tempinv * sa * t(tempinv);
      temp = I(&np) - simplex_c;
      tempinv = inv(temp);
      vc = tempinv * sc * t(tempinv);
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


