data spmdslib.cholesky_u_noa;
/* -------------------------------------------------
   Va = 0, Vc, Vu = Cholesky
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
NOTE WELL: This is the same model as acu_noa because of the
           parameterization of matrix VU. It is included here as a
           convenience.
BEGIN MODEL   VA=0, VC=UN, VU=LD
  begin matrices
    va
    vc
    vu
    fu L
  end matrices
  begin mx
    co fu
    fi va vu
  end mx
  begin iml
    if pair_number = 1 then do;
      vu = fu * t(fu);
      p1 = vc + vu;
      p2 = p1;
    end;
    r12 = gamma_c * vc;
  end iml
END MODEL
;;;;
run;
