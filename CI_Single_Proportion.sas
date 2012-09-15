*******************************************************************************************************************;
*Program    Name    : CI_Single_Proportion.sas                                                                    *;
*Programmer Name	: Jiangtang Hu                                                                                *;
*                     Jiangtanghu@gmail.com                                                                       *;
*                     Jiangtanghu.com/blog                                                                        *;
*                                                                                                                 *;
*Purpose            : Compute two-sided confidence intervals for single proportion with 11 methods:               *;
*                     1.  Simple asymptotic, Without CC | Wald                                                    *;
*                     2.  Simple asymptotic, With CC                                                              *;
*                     3.  Score method, Without CC | Wilson                                                       *;
*                     4.  Score method, With CC                                                                   *;
*                     5.  Binomial-based, 'Exact' | Clopper-Pearson                                               *;
*                     6.  Binomial-based, Mid-p                                                                   *;
*                     7.  Likelihood-based                                                                        *;
*                     8.  Jeffreys                                                                                *;
*                     9.  Agresti-Coull,z^2/2 successes                                                           *;
*                     10. Agresti-Coull,2 successes and 2 fail                                                    *;
*                     11. Logit                                                                                   *;
*                                                                                                                 *;
*Input              : r     - the number of interested responses                                                  *;
*                     n     - total observations, 0 =< r <= n                                                     *;
*                     alpha - 0.05 by default                                                                     *;
*Output             : confidence intervals using 11 methods                                                       *;
*Usage              : %CI_Single_Proportion(r=81,n=263)                                                           *;
*                                                                                                                 *;
*References         : Newcombe R.G., Two-sided confidence intervals for the single proportion:                    *;
*                     comparison of seven methods, Statistics in Medicine, (1998) 17, 857-872                     *;
*                                                                                                                 *;
*                    http://www2.jura.uni-hamburg.de/instkrim/kriminologie/Mitarbeiter/Enzmann/Software/prop.CI.r *;
*                                                                                                                 *;
*License            : public domain, ABSOLUTELY NO WARRANTY                                                       *;
*Platform           : tested in SAS/Base 9.1.3 SP4 and SAS/Base 9.2                                               *;
*Version            : V1.0                                                                                        *;
*Date		        : 14Jul2011                                                                                   *;
*******************************************************************************************************************;


%macro CI_Single_Proportion(r=,n=,alpha=0.05);

data param;
    do i=1 to 11;
          r=&r;
          n=&n;
          alpha=&alpha;
          p=r/n;
          z = probit (1-alpha/2);
    output;
    end; 
run;

/*method 1-5,8-11;*/
data CI5;
    length method $50.;
    set param(where=(i not in (6 7)));

    if i=1 then do;
          Method = "1. Simple asymptotic, Without CC | Wald";
          p_CI_low = p-z*((sqrt(&n*p*(1-p)))/n);
          p_CI_up  = p+z*((sqrt(&n*p*(1-p)))/n);  
    end;

    if i=2 then do;
          Method = "2. Simple asymptotic, With CC";
          p_CI_low = p-(z*((sqrt(&n*p*(1-p)))/n)+1/(2*&n));
          p_CI_up  = p+(z*((sqrt(&n*p*(1-p)))/n)+1/(2*&n)); 
          
          if r=0 then p_CI_low=0;
          if r=n then p_CI_up =1;
    end;
    
    if i=3 then do;
          Method = "3. Score method, Without CC | Wilson";
          p_CI_low = ( 2*n*p+z**2 - (z*sqrt(z**2+4*n*p*(1-p)))) / (2*(n+z**2));
          p_CI_up  = ( 2*n*p+z**2 + (z*sqrt(z**2+4*n*p*(1-p)))) / (2*(n+z**2));         
    end;
    
    if i=4 then do;
          Method = "4. Score method, With CC";
          p_CI_low = ( 2*n*p+z**2 -1 - z*sqrt(z**2-2-1/n+4*p*(n*(1-p)+1))) / (2*(n+z**2));
          p_CI_up  = ( 2*n*p+z**2 +1 + z*sqrt(z**2+2-1/n+4*p*(n*(1-p)-1))) / (2*(n+z**2));  
          
          if r=0 then p_CI_low=0;
          if r=n then p_CI_up =1;  
    end;
    
    if i=5 then do;
          Method = "5. Binomial-based, 'Exact' | Clopper-Pearson";
          p_CI_low =1-betainv(1-alpha/2,n-r+1,r);
          p_CI_up  =  betainv(1-alpha/2,r+1,n-r);  
          
          if r=0 then p_CI_low=0;
          if r=n then p_CI_up =1;
    end;
    
    if i=8 then do;
          Method = "8. Jeffreys";   
          p_CI_low = betainv(alpha/2, r+0.5,n-r+0.5);
          p_CI_up  = betainv(1-alpha/2,r+0.5,n-r+0.5);
    end;
    
    if i=9 then do;
          Method = "9. Agresti-Coull,z^2/2 successes";        
          p_CI_low = ((r+((z**2)/2))/(n+z**2))-z*(sqrt(((r+((z**2)/2))/(n+(z**2)))*(1-((r+((z**2)/2))/(n+(z**2))))/(n+z**2)));
          p_CI_up  = ((r+((z**2)/2))/(n+z**2))+z*(sqrt(((r+((z**2)/2))/(n+(z**2)))*(1-((r+((z**2)/2))/(n+(z**2))))/(n+z**2)));
          
          if p_CI_low<0 then p_CI_low=0;
          if p_CI_up>1  then p_CI_up =1;
    end;
    
    if i=10 then do;
          Method = "10. Agresti-Coull,2 successes and 2 failures";
          p_CI_low =((r+2)/(n+4))-z*(sqrt(((r+2)/(n+4))*(1-((r+2)/(n+4)))/(n+4)));
          p_CI_up  =((r+2)/(n+4))+z*(sqrt(((r+2)/(n+4))*(1-((r+2)/(n+4)))/(n+4)));
          
          if p_CI_low<0 then p_CI_low=0;
          if p_CI_up>1  then p_CI_up =1;
    end;
    
    if i=11 then do;
          Method = "11. Logit";             
          p_CI_low=exp(log(p/(1-p)) - z*sqrt(n/(r*(n-r))))/(1+exp(log(p/(1-p)) - z*sqrt(n/(r*(n-r)))));
          p_CI_up =exp(log(p/(1-p)) + z*sqrt(n/(r*(n-r))))/(1+exp(log(p/(1-p)) + z*sqrt(n/(r*(n-r)))));
    end;
run;

/*method 6;*/
data param6;
    set param(where=(i=6));
    max_idx=alpha/2;
	min_idx=1-alpha/2;

	do j=0.000001 to 0.999999 by 0.00001;
		if (r>0 and r<n) then a2=0.5*probbnml(j,n,r-1) + 0.5*probbnml(j,n,r);
		output;
	end;
run;

proc sql;
	create table max as
		select max(j) as p_CI_up
		from param6		
		where a2 > max_idx and r>0 and r<n
		;

	create table min as
		select min(j) as p_CI_low
		from param6		
		where a2 <= min_idx and r>0 and r<n
		;

	create table param6_2 as
		select *
		from param
        where i=6
		;
quit;

data CI6;
	merge param6_2 min max;
    Method = "6. Binomial-based, Mid-p";
	
	if r=0 then do;
		p_CI_low=0;
		p_CI_up = 1-alpha**(1/n);
	end;

	if r=n then do;
		p_CI_low=alpha**(1/n);
		p_CI_up = 1;
	end;
run;

/*method 7;*/
data param7;
    set param(where=(i=7));

	k=-cinv(1-alpha,1)/2;

	do j=0.000001 to 0.999999 by 0.00001;
		lik=pdf('Binomial',r,j,n);		 
		output;
	end;
run;

proc sql;	
	create table max as
		select i,max(lik) as max
		from param7
	;
quit;

data test1;
	merge param7 max;
    by i;
	logLR = log(lik/max);
run;

proc sql;
	create table max2 as
		select min(j) as p_CI_low,max(j) as p_CI_up
		from test1		
		where logLR>k
		;

	create table param7_2 as
		select distinct *
		from param
        where i=7
		;
quit;

data CI7;
	merge param7_2 max2;
    Method = "7. Likelihood-based";
	
	if r=0 then p_CI_low=0;
	if r=n then p_CI_up =1;
run;

/*put together,1-11;*/
data CI_SP;
    set CI5 CI6 CI7;
    p_CI=compress(catx("","[",put(round(p_CI_low,0.0001),6.4),",",put(round(p_CI_up,0.0001),6.4),"]"));
run;

proc sort; by i;run;
           
proc print data=CI_SP;
    var r n p method p_ci;
run;
      
%mend CI_Single_Proportion;

/*test;
%CI_Single_Proportion(r=81,n=263);
%CI_Single_Proportion(r=15,n=148);
%CI_Single_Proportion(r=0, n=20 );
%CI_Single_Proportion(r=1, n=29 );
%CI_Single_Proportion(r=29,n=29 );
*/
