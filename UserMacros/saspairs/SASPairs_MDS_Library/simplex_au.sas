data spmdslib.simplex_au;
/* -----------------------------------------------------------------
   Va = Simplex, Vc, Vu = Simplex
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=simplex, VC=UN, VU=simplex
  begin matrices
    va
    simplex_a U &np &np
    sa
    vc
    vu
    simplex_u U &np &np
    su
  end matrices
  begin mx
    fi va vu simplex_a  simplex_u
    fr autoreg(simplex_a 1) autoreg(simplex_u 1)
    co sa su
  end mx
  begin iml
    if pair_number = 1 then do;
      temp = I(&np) - simplex_a;
      tempinv = inv(temp);
      va = tempinv * sa * t(tempinv);
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


