data spmdslib.acu_noa;
/* -------------------------------------------------
   ACU Model: VA = 0
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
begin model   VA=0, VC=UN, VU=LD
  begin matrices
    va
    vc
    vu
    fu L 
  end matrices;
  begin mx
    fi va vu
    co fu
  end mx;
  begin iml
    if pair_number=1 then do;
      vu = fu * t(fu);
      p1 = vc + vu;
      p2 = p1;
    end;
    r12 = gamma_c * vc;
  end iml
end model
;;;;
run;
