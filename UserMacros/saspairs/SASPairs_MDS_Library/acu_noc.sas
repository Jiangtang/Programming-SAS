data spmdslib.acu_noc;
/* -------------------------------------------------
   ACU Model: No Vc
   ------------------------------------------------- */
  length card $80;
  input card $char80.;
datalines4;
begin model   VA=UN, VC=0, VU=LD
  begin matrices
    va
    vc
    vu
    fu L 
  end matrices;
  begin mx
    fi vc vu
    co va fu
  end mx;
  begin iml
    if pair_number=1 then do;
      vu = fu * t(fu);
      p1 = va + vu;
      p2 = p1;
    end;
    r12 = gamma_a * va;
  end iml
end model
;;;;
run;
