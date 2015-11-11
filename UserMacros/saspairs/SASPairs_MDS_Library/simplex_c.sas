data spmdslib.simplex_c;
/* -----------------------------------------------------------------
   Va = free, Vc = Simplex, Vu
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=UN, VC=simplex, VU=LD
  begin matrices
    va
    vc
    simplex_c U &np &np
    sc
    vu
    fu L
  end matrices
  begin mx
    co va fu
    fi simplex_c vc vu
    fr autoreg(simplex_c 1)
  end mx
  begin iml
    if pair_number = 1 then do;
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

