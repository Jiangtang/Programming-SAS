data temp(keep=tempf) ; 
     do i = 100 to 103.4 by .1 ; 
        tempf=i ;  
   output ; 
     end ; 
run ; 
 
data local ; 
set temp; 
tempc=(tempf - 32 )/1.8; 
tempcr=round((tempf - 32)/1.8,.0001) ; 
tempcr2=round((tempf - 32)/1.8,.01) ; 
if tempc < 38.0 then severity = 0;
else if 38.0 <= tempc < 38.5 then severity = 1; 
else if 38.5 <= tempc < 39.5 then severity = 2; 
else if tempc >= 39.5 then severity = 3;  
 
if tempcr < 38.0 then severtyr = 0; 
else if 38.0 <= tempcr < 38.5 then severtyr = 1; 
else if 38.5 <= tempcr < 39.5 then severtyr = 2; 
else if tempcr >= 39.5 then severtyr = 3;  
 
if tempcr2 < 38.0 then severtyr2 = 0; 
else if 38.0 <= tempcr2 < 38.5 then severtyr2 = 1; 
else if 38.5 <= tempcr2 < 39.5 then severtyr2 = 2; 
else if tempcr2 >= 39.5 then severtyr2 = 3;  

put tempc=32.30;
run; 

data test;
a=38.5;
b=38.4449999999;
c=38.4999999999;
bb1=round(b,0.01);
bb2=round(b,0.001);
cc1=round(c,0.01);
cc2=round(c,0.001);
put  _all_;
run;
proc print;
run;

