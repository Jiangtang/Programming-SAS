start predicted_stats (pair_number, relative1, relative2, gamma_a, gamma_c,     
       gamma_d, p1, p2, r12, p1cv, p2cv, vccv, mean_vector, bad_f_value)        
       GLOBAL ( &global_arg1 );                                                 
   if pair_number=1 then do;                                                    
      ResidCov = SU + ResidCov;                                                 
      IMBInv = INV(I(nrow(B)) - B);                                             
      VP = IMBInv * ResidCov * t(IMBInv);                                       
      P1 = VP;                                                                  
      P2 = P1;                                                                  
   end;                                                                         
   if pair_number=1 then R12 = IMBInv * ReltvCov11 * t(IMBInv);                 
   else if pair_number=2 then R12 = IMBInv * ReltvCov22 * t(IMBInv);            
finish;                                                                         
