data spmdslib.acu_noccorr;
/* -------------------------------------------------
   ACU Model: No Common Environment Correlations
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
begin model   VA=UN, VC=DI, VU=LD, no common environment correlations
  begin matrices
    va
    vc
    vu
    fu L 
  end matrices
  begin mx
    fi vu
    co va fu
    fi 0 offdiag(vc)
  end mx
  begin iml
    if pair_number=1 then do;
      vu = fu * t(fu);
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
end model
;;;;
run;
