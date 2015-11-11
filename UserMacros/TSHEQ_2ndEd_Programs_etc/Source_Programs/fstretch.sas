%macro fstretch(ALPHA,TOL,ITMAX,NY1,NY2,RHO1,RHO2);
data ; ALPHA= &ALPHA; TOL= &TOL; ITMAX= &ITMAX;
NY1= &NY1; NY2=&NY2; RHO1= &RHO1; RHO2=&RHO2;
    ERR= -ALPHA;  C1= sqrt(RHO1*RHO2);
    do while (ERR <0);
    C1= C1- .05;   H= ALPHA + probf(C1/RHO2,NY1,NY2) ;
    C2= finv(H,NY1,NY2)*RHO2;
    ERR= probf(C2/RHO1,NY1,NY2)-probf(C1/RHO1,NY1,NY2)  -ALPHA;
    end;  C1L= C1 ;  C1R= C1 +.05;    IT= 0;

    do while (abs(ERR) >=TOL  and IT <=ITMAX);  IT= IT+1;
    C1= (C1L+C1R)/2;  H= ALPHA + probf(C1/RHO2,NY1,NY2) ;
    C2= finv(H,NY1,NY2)*RHO2;
    ERR= probf(C2/RHO1,NY1,NY2)-probf(C1/RHO1,NY1,NY2)  -ALPHA;
    if ERR <=0 then go to S1; else go to S2;
    S1:  C1R= C1; go to S3;
    S2:  C1L= C1;
    S3:  end;
POW0= probf(C2,NY1,NY2)-probf(C1,NY1,NY2);
run;

proc print noobs;
     VAR ALPHA NY1 NY2 RHO1 RHO2 IT C1 C2 ERR POW0;
     FORMAT C1 C2 12.9   POW0 10.9   ERR E10.;
run;
%mend fstretch;

%fstretch(.05,1.E-10,50, 24,24, 0.50, 2.00)
