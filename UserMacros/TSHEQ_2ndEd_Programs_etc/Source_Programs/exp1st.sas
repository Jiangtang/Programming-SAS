%macro exp1st(ALPHA,TOL,ITMAX,N,EPS);
data ; ALPHA= &ALPHA; TOL= &TOL ;ITMAX= &ITMAX;
N= &N; EPS= &EPS;    NY= 2*N;
    ERR1= -ALPHA;  C1= 1.0;
    do while (ERR1 <0);
    C1= C1- .05;   H= ALPHA + probchi(NY*C1/(1+EPS),NY) ;
    C2= cinv(H,NY)*(1+EPS)/NY;
    ERR1= probchi(NY*(1+EPS)*C2,NY)-probchi(NY*(1+EPS)*C1,NY)  -ALPHA;
    end;  C1L= C1 ;  C1R= C1 +.05;    IT= 0;

    do while (abs(ERR1) >=TOL  and IT <=ITMAX);  IT= IT+1;
         C1= (C1L+C1R)/2;  H= ALPHA + probchi(NY*C1/(1+EPS),NY) ;
         C2= cinv(H,NY)*(1+EPS)/NY;
         ERR1= probchi(NY*(1+EPS)*C2,NY)-probchi(NY*(1+EPS)*C1,NY)  -ALPHA;
         if ERR1 <=0 then go to S1;  else go to S2;
    S1:  C1R= C1; go to S3;
    S2:  C1L= C1;
    S3:  end;
POW0= probchi(NY*C2,NY)-probchi(NY*C1,NY);  C1=N*C1; C2=N*C2;
run;

proc print noobs;
     var  ALPHA TOL ITMAX N EPS IT C1 C2 ERR1 POW0;
     FORMAT C1 C2 12.9 POW0 10.9 ERR1 E10.;
run;
%mend exp1st;
%exp1st(.05,1.E-10,100,80,0.30)
