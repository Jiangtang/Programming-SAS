data spmdslib.simplex_a_noc;
/* -----------------------------------------------------------------
   VA = Simplex, Vc = 0, Vu
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   VA=simplex, VC=0, VU=LD
  begin matrices
    va
    sa
    simplex_a U &np &np
    vc
    vu
    fu L
  end matrices
  begin mx
    co sa fu
    fi simplex_a va vc vu
    fr autoreg(simplex_a 1)
  end mx
  begin iml
    if pair_number = 1 then do;
      temp = I(&np) - simplex_a;
      tempinv = inv(temp);
      va = tempinv * sa * t(tempinv);
      vu = fu * t(fu);
      p1 = va + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va;
  end iml
END MODEL
;;;;
run;

