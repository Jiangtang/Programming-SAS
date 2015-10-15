/*
proc template;     
 source base.Summary / file="C:\Users\jhu\Documents\GitHub\Programming-SAS\ODS\stat\procMeans.tpl";
run;

proc means data=sashelp.class n NMISS  min max range sum SUMWGT mean MODE uss css var  stddev stderr cv  SKEW KURT  CLM LCLM UCLM
 alpha=0.1 P50 q1 q3  QRANGE prt t;
    var weight height;
run;

*/

proc template;                                                                
   define table Base.Summary;                                                 
      notes "Summary table for MEANS and SUMMARY";                            
      dynamic clmpct one_var_name one_var_label one_var _double_space_;       
      column class nobs id type ways (varname) (label) (min) (max) (range) (n)
         (nmiss) (sumwgt) (sum) (mean) (uss) (css) (var) (stddev) (cv) (stderr
         ) (t) (probt) (lclm) (uclm) (skew) (kurt) (median) (mode) (q1) (q3) (
         qrange) (p1) (p5) (p10) (p20) (p25) (p30) (p40) (p50) (p60) (p70) (  
         p75) (p80) (p90) (p95) (p99);                                        
      header h;                                                               
                                                                              
      define h;                                                               
         text "Analysis Variable : " one_var_name " " one_var_label;          
         space = 1;                                                           
         just = C;                                                            
         print = one_var;                                                     
         spill_margin;                                                        
      end;                                                                    
                                                                              
      define class;                                                           
         vjust = T;                                                           
         id;                                                                  
         generic;                                                             
         blank_internal_dups;                                                 
      end;                                                                    
                                                                              
      define nobs;                                                            
         header = "N Obs";                                                    
         vjust = T;                                                           
         id;                                                                  
         blank_internal_dups;                                                 
      end;                                                                    
                                                                              
      define id;                                                              
         vjust = T;                                                           
         id;                                                                  
         generic;                                                             
         blank_internal_dups;                                                 
      end;                                                                    
                                                                              
      define type;                                                            
         header = "Type";                                                     
         vjust = T;                                                           
         id;                                                                  
         blank_internal_dups;                                                 
      end;                                                                    
                                                                              
      define ways;                                                            
         header = "Ways";                                                     
         vjust = T;                                                           
         id;                                                                  
         blank_internal_dups;                                                 
      end;                                                                    
                                                                              
      define varname;                                                         
         header = "Variable";                                                 
         id;                                                                  
         generic;                                                             
      end;                                                                    
                                                                              
      define label;                                                           
         header = "Label";                                                    
         id;                                                                  
         generic;                                                             
      end;                                                                    
                                                                              
      define min;                                                             
         define header hmin;                                                  
            text "Minimum";                                                   
            text2 "Min";                                                      
         end;                                                                 
         header = hmin;                                                       
         generic;                                                             
      end;                                                                    
                                                                              
      define max;                                                             
         define header hmax;                                                  
            text "Maximum";                                                   
            text2 "Max";                                                      
         end;                                                                 
         header = hmax;                                                       
         generic;                                                             
      end;

      define range;
        define header hrange;  
             text  "Range: @ max - min" ;
             text2 "RANGE";
             split = '@'; 
         end; 
         header = hrange; 
         generic;                                                             
      end;  
                                                                 
                                                                              
      define n;                                                               
         header = "N";                                                        
         generic;                                                             
      end;                                                                    
                                                                              
      define nmiss;                                                           
         header = "N Miss";                                                   
         generic;                                                             
      end;                                                                    
                                                                              
      define sumwgt;                                                          
         header = "Sum Wgts";                                                 
         generic;                                                             
      end;                                                                    
                                                                              
      define sum;
        define header hsum;  
             text  "Sum:@ (*ESC*){unicode sigma_u}x" ;
             text2 "SUM";
             split = '@'; 
         end; 
         header = hsum; 
         generic;                                                             
      end;                                                                    
                                                                              
      define mean; 
         define header hmean; 
             text  "Mean:@ (*ESC*){unicode sigma_u}x/n";
             text2 "MEAN";
             split = '@'; 
         end;
         header = hmean; 
         generic;                                                             
      end;                                                                    
                                                                              
      define uss;                                                         
         define header huss;                                                  
            text "USS: Uncorrected Sum of Squares:@ (*ESC*){unicode sigma_u}x^2";                                            
            text2 "USS";  
            split = '@'; 
         end;                                                                 
         header = huss;                                                       
         generic;                                                             
      end;                                                                    
                                                                              
      define css;                                                             
         define header hcss;                                                  
            text "CSS: Corrected Sum of Squares:@ (*ESC*){unicode sigma_u}(x-u)^2";                                              
            text2 "CSS"; 
            split = '@';  
         end;                                                                 
         header = hcss;                                                       
         generic;                                                             
      end;                                                                    
                                                                              
      define var;
         define header hvar; 
             text  "Variance: @ css/(n-1)";  
             text2 "VAR";
             split = '@';              
         end;
         header = hvar;
         generic; 
      end;  

      define stddev;
         define header hstddev; 
             text  "Std Deviation: @squrt(var)";  
             text2 "STDDEV";
             split = '@';              
         end;
         header = hstddev;
         generic; 
      end;

      define cv;
         define header hcv; 
             text  "Coeff of Variation: @stddev/mean * 100";  
             text2 "CV";
             split = '@';              
         end;
         header = hcv;
         generic; 
      end; 

      define stderr;
         define header hstderr; 
             text  "Std Error (of mean):@stddev /sqrt(n)";  
             text2 "STDERR";
             split = '@';              
         end;
         header = hstderr;
         parent = Common.ParameterEstimates.StdErr;  
         generic; 
      end;

      define t;
         define header ht; 
             text  "t: Student's t statistic:@(u - mu0) / STDERR while MU0 = 0 ";  
             text2 "T";
             split = '@';              
         end;
         header = ht;
         parent = Common.ParameterEstimates.tValue;  
         generic; 
      end; 

      define probt;
         define header hprobt; 
             text  "P:@ P{X > |t|} = tail * (1 - probt(t,df))@Note: you can also calculate tCritic = tinv(1 - alpha/tail,df)";  
             text2 "PROBT";
             split = '@';              
         end;
         header = hprobt;
         parent = Common.ParameterEstimates.Probt;   
         generic; 
      end;                                                             
                                                                  
                                                                              
      define lclm;                                                            
         define header hlclm;                                                 
            text "Lower " clmpct BEST8. %nrstr("%%/CL for Mean");             
            split = "/";                                                      
         end;                                                                 
         header = hlclm;                                                      
         generic;                                                             
      end;                                                                    
                                                                              
      define uclm;                                                            
         define header huclm;                                                 
            text "Upper " clmpct BEST8. %nrstr("%%/CL for Mean");             
            split = "/";                                                      
         end;                                                                 
         header = huclm;                                                      
         generic;                                                             
      end;                                                                    
                                                                              
      define skew;                                                            
         header = "Skewness";                                                 
         generic;                                                             
      end;                                                                    
                                                                              
      define kurt;                                                            
         header = "Kurtosis";                                                 
         generic;                                                             
      end;                                                                    
                                                                              
      define median;                                                          
         header = "Median";                                                   
         generic;                                                             
      end;                                                                    
                                                                              
      define mode;                                                            
         header = "Mode";                                                     
         generic;                                                             
      end; 

      define q1;
         define header hq1; 
             text  "Q1 | P25:@Lower Quartile";  
             text2 "Q1";
             split = '@';              
         end;
         header = hq1;
         generic; 
      end;

      define q3;
         define header hq3; 
             text  "Q3 | P75:@Upper Quartile";  
             text2 "Q3";
             split = '@';              
         end;
         header = hq3;
         generic; 
      end; 

      define qrange;
         define header hqrange; 
             text  "Quartile Range:@Q3 - Q1";  
             text2 "QRANGE";
             split = '@';              
         end;
         header = hqrange;
         generic; 
      end;                                                                               
                                                                 
                                                                              
      define p1;                                                              
         header = "1st Pctl";                                                 
         generic;                                                             
      end;                                                                    
                                                                              
      define p5;                                                              
         header = "5th Pctl";                                                 
         generic;                                                             
      end;                                                                    
                                                                              
      define p10;                                                             
         header = "10th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p20;                                                             
         header = "20th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p25;                                                             
         header = "25th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p30;                                                             
         header = "30th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p40;                                                             
         header = "40th Pctl";                                                
         generic;                                                             
      end;

      define p50;
         define header hp50; 
             text  "MEDIAN | P50:@ 50th Pctl";  
             text2 "P50";
             split = '@';              
         end;
         header = hp50;
         generic; 
      end;   
                                                                              
                                                                  
                                                                              
      define p60;                                                             
         header = "60th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p70;                                                             
         header = "70th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p75;                                                             
         header = "75th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p80;                                                             
         header = "80th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p90;                                                             
         header = "90th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p95;                                                             
         header = "95th Pctl";                                                
         generic;                                                             
      end;                                                                    
                                                                              
      define p99;                                                             
         header = "99th Pctl";                                                
         generic;                                                             
      end;                                                                    
      required_space = 5;                                                     
      control = _control_;                                                    
      double_space = _double_space_;                                          
      underline;                                                              
      overline;                                                               
      byline;                                                                 
      use_format_defaults;                                                    
      split_stack;                                                            
      use_name;                                                               
      order_data;                                                             
      classlevels;                                                            
   end;                                                                       
run;
