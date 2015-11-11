%macro tt1st(ALPHA,TOL,ITMAX,N,THETA1, THETA2);
data ; ALPHA= &ALPHA; TOL= &TOL; ITMAX= &ITMAX;
N= &N; THETA1= &THETA1; THETA2= &THETA2;
NY=N-1; DEL1= THETA1*sqrt(N); DEL2= THETA2*sqrt(N);

    ERR1= -ALPHA;  C1= (DEL1+DEL2)/2;
    do while (ERR1 <0);  C1= C1-.05;
    AREAC1_2= probt(C1,NY,DEL2) ;
    if AREAC1_2=. then goto S8;
    H= ALPHA + AREAC1_2 ; C2= tinv(H,NY,DEL2);
    ERR1= probt(C2,NY,DEL1)-probt(C1,NY,DEL1)  -ALPHA;
    end;  C1L= C1 ;  C1R= C1 +.05;    IT= 0;

    do while (abs(ERR1) >=TOL  and IT <=ITMAX);  IT= IT+1;
    C1= (C1L+C1R)/2;  H= ALPHA + probt(C1,NY,DEL2) ;
    C2= tinv(H,NY,DEL2);
    ERR1= probt(C2,NY,DEL1)-probt(C1,NY,DEL1)  -ALPHA;
         if ERR1 <=0 then go to S1;  else go to S2;
    S1:  C1R= C1; go to S3;
    S2:  C1L= C1;
    S3:  end;
goto S9;
S8: C2=tinv(ALPHA,NY,DEL2);
    C1=tinv(1-ALPHA,NY,DEL1);
    AREAC1_1=probt(C1,NY,DEL1); AREAC2_1= probt(C2,NY,DEL1);
    if AREAC2_1=. then AREAC2_1=1;
    ERR1= AREAC2_1-AREAC1_1-ALPHA;
    AREAC1_2=probt(C1,NY,DEL2); AREAC2_2= probt(C2,NY,DEL2);
    if AREAC1_2=. then AREAC1_2=0;
    ERR2= AREAC2_2-AREAC1_2-ALPHA;
S9: POW0= probt(C2,NY)-probt(C1,NY); output;
run;

proc print noobs;
     var ALPHA N THETA1 THETA2 IT  C1 C2 ERR1 ERR2 POW0;
     format C1 C2 11.8  POW0 9.8  ERR1 ERR2 E10.;
run;
%mend tt1st;

%tt1st(.05,1.E-10,50,36,-0.4716,.3853)
