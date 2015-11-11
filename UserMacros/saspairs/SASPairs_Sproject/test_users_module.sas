/* =======================================================================                      
   *** DO NOT CHANGE ANY OF THE FOLLOWING CODE UNDER PENALITY OF DEATH ***                      
   ======================================================================= */                   
proc iml;                                                                                       
%include "&put_x_file";                                                                         
start function_covmats (x)                                                                      
			GLOBAL (n_rel, n_cov, n_covariates, rel_pheno, cov_mats, gamma, df, fdet, fval, f,           
					index_x, nrows, ncols, parm_value, whereinx);                                              
/* ------------------------------------------------------------------------------               
	RELATIVE PAIRS MAXIMIM LIKELIHOOD FUNCTION MODULE: fit to covariance matrices                  
   ------------------------------------------------------------------------------ */            
                                                                                                
	/* put the iterated parameters into the vector of full parameter values */                     
	do i=1 to nrow(whereinx);                                                                      
		if whereinx[i] ^= 0 then parm_value[i] = x[whereinx[i]];                                      
	end;                                                                                           
                                                                                                
	/* put the parameters into the user defined matrices */                                        
	call put_x_into_matrices (parm_value, index_x, nrows, ncols);                                  
                                                                                                
	/* loop to calculate the function value */                                                     
	stop = 0;                                                                                      
	do i = 1 to n_rel;                                                                             
		pairnum=i; /* for safety in case the user changes pair_number */                              
		bad_f_value = 0;                                                                              
		call predicted_stats (pairnum, rel_pheno[i,1], rel_pheno[i,2], gamma[i,1],                    
							  gamma[i,2], gamma[i,3], p1, p2, r12, p1cv, p2cv, vccv,,                                
							  bad_f_value);                                                                          
		if bad_f_value = 1 then do;                                                                   
			f=.;                                                                                         
			return (f);                                                                                  
		end;                                                                                          
		if n_covariates = 0 then                                                                      
			pre = (p1 || r12) // (t(r12) || p2);                                                         
		else                                                                                          
			pre = (p1 || r12 || p1cv) // (t(r12) || p2 || p2cv) //                                       
				  (t(p1cv) || t(p2cv) || vccv) ;                                                            
		detpre = det(pre);                                                                            
		if detpre <= 0 then do;                                                                       
			f=.;                                                                                         
			return (f);                                                                                  
		end;                                                                                          
		start = stop + 1;                                                                             
		stop = start + n_cov - 1;                                                                     
		obs = cov_mats[start:stop,];                                                                  
		fval[i] = df[i] * (log(detpre) - fdet[i] + trace(obs * inv(pre)) - n_cov);                    
	end;                                                                                           
	f = sum(fval);                                                                                 
	if upcase("&negative_chi2") = "NO" & f < 0 then f = .;                                         
	return (f);                                                                                    
finish;                                                                                         
                                                                                                
start predicted_stats (pair_number, relative1, relative2, gamma_a, gamma_c,                     
     gamma_d, p1, p2, r12, p1cv, p2cv, vccv, mean_vector, bad_f_value)                          
     GLOBAL ( &global_arg1 );                                                                   
/* =======================================================================                      
                        *** END OF DEATH PENALTY ***                                            
   ======================================================================= */                   
   if pair_number=1 then do;                                                                    
      ResidCov = SU + ResidCov;                                                                 
      IMBInv = INV(I(nrow(B)) - B);                                                             
      VP = IMBInv * ResidCov * t(IMBInv);                                                       
      P1 = VP;                                                                                  
      P2 = P1;                                                                                  
   end;                                                                                         
   if pair_number=1 then R12 = IMBInv * ReltvCov11 * t(IMBInv);                                 
   else if pair_number=2 then R12 = IMBInv * ReltvCov22 * t(IMBInv);                            
/* =======================================================================                      
   *** DO NOT CHANGE ANY OF THE FOLLOWING CODE UNDER PENALITY OF DEATH ***                      
   ======================================================================= */                   
finish;                                                                                         
                                                                                                
	/* load the stored matrices */                                                                 
	load n_rel n_var n_cov n_covariates rel_pheno gamma;                                           
	load nrows ncols index_x whereinx parm_value x0;                                               
	load &load_matrices;                                                                           
                                                                                                
	/* 	first call to the function */                                                              
	fval = j(n_rel, 1, 0);                                                                         
	f_scale = 1;                                                                                   
	xsave = x0;                                                                                    
	f = &function (x0);                                                                            
                                                                                                
/* =======================================================================                      
                        *** END OF DEATH PENALTY ***                                            
   ======================================================================= */                   
