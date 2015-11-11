data spmdslib.psychometric_noalatent;
/* -----------------------------------------------------------------
   Psychometric Model: All variables are a manifestation of a
    single latent phenotype
   ----------------------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
BEGIN MODEL   Psychometric Model: VA(Latent) = 0
  begin matrices
    va
    sa
    vc
    sc
    vu
    su
    asq v 1
    csq v 1
    usq v 1
    fpat v &np
  end matrices
  begin mx
    fi asq
    fi va vc vu
    co sa su
    fi 1 usq
  end mx
  begin iml
    if pair_number = 1 then do;
      temp = fpat * t(fpat);
      va = asq * temp + sa;
      vc = csq * temp + sc;
      vu = usq * temp + su;
      p1 = va + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va + gamma_c * vc;
  end iml
END MODEL
;;;;
run;
