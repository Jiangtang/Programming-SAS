data spmdslib.cholesky_u_noc;
/* -------------------------------------------------
   Va, Vc = 0, Vu = Cholesky
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
NOTE WELL: This is the same model as acu_noc because of the parameterization
           of matrix VU. It is included here as a convenience.
BEGIN MODEL   VA=UN, VC=0, VU=LD
  begin matrices
    va
    vc
    vu
    fu L
  end matrices
  begin mx
    co va fu
    fi vc vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vu = fu * t(fu);
      p1 = va + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va;
  end iml
END MODEL
;;;;
run;
