data spmdslib.acu_noucorr;
/* -------------------------------------------------
   ACU Model: No Unique Environment Correlations
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
begin model   VA=UN, VC=UN, VU=DI, no unique environment correlations
  begin matrices
    va
    vc
    vu 
  end matrices
  begin mx
    co va vu
    fi 0 offdiag(vu)
  end mx
  begin iml
    if pair_number=1 then do;
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
end model
;;;;
run;
