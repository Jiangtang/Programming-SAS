data spmdslib.adcu_dscalar_noccorr;
/* -------------------------------------------------
   ADCU Model
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
begin model   VA=UN, VD=scalar*VA, VC=DI, VU=LD
  begin matrices
    va
    vd
    vc
    vu
    fu L
	scalar v 1 1 
  end matrices
  begin mx
    fi vd vu
    co va fu
	fi 0 offdiag(vc)
	st .1 scalar
  end mx
  begin iml
    if pair_number=1 then do;
	  vd = scalar*va;
      vu = fu * t(fu);
      p1 = va + vd + vc + vu;
      p2 = p1;
    end;
    r12 = gamma_a*va + gamma_d*vd + gamma_c*vc;
  end iml
end model
;;;;
run;
