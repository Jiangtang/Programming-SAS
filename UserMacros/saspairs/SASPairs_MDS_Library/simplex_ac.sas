data spmdslib.simplex_ac;
/* -----------------------------------------------------------------
   VA & Vc = Simplex, Vu
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=simplex, VC=simplex, VU=LD
  begin matrices
    va
    simplex_a U &np &np
    sa
    vc
    simplex_c U &np &np
    sc
    vu
    fu L
  end matrices
  begin mx
    co sa fu
    fi simplex_a simplex_c va vc vu
    fr autoreg(simplex_a 1) autoreg(simplex_c 1)
  end mx
  begin iml
    if pair_number = 1 then do;
      temp = I(&np) - simplex_a;
      tempinv = inv(temp);
      va = tempinv * sa * t(tempinv);
      temp = I(&np) - simplex_c;
      tempinv = inv(temp);
      vc = tempinv * sc * t(tempinv);
      vu = fu * t(fu);
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;
