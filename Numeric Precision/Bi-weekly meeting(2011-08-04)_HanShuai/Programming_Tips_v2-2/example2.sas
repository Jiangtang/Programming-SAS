data serologi; 
   subject=1; bleed=1; test1=40; test2=80; output; 
   subject=1; bleed=2; test1=160; test2=320; output; 
run; 
 
* get GMT for individual subject/antigen/bleed     *; 
 
data serology; 
   set serologi; 
   result =10**mean(log10(test1),log10(test2)); 
run; 
 
data baseline(drop=bleed rename=(result=baseline))  
     postbase(drop=bleed); 
   set serology(keep=subject bleed result); 
   if bleed=1 then output baseline ; 
   else if bleed=2 then output postbase ; 
run; 
 
data final; 
  merge postbase baseline; 
      by subject; 
   fold = result/baseline;
t=fold-4; 
   frfold=(fold>=4);
   fourfold = (round(fold,0.01)>=4); 
   put fold=32.30;
run; 
