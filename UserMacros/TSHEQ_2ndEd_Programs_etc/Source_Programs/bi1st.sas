%macro bi1st(ALPHA,N,P1,P2);
data; ALPHA= &ALPHA; N= &N; P1= &P1; P2= &P2;
keep N P1 P2 ALPHA C1 GAM1 C2 GAM2 POWNONRD POW;
    K=int(N/2); if 2*K <N or P2 ^=1-P1 then go to S00;
    P1K= probbnml(P1,N,K)-probbnml(P1,N,K-1);
    if P1K >= ALPHA then go to S7;
S00:P0=(P1+P2)/2; K1=max(int(N*P1),1); K2=max(int(N*P0)-2,K1-1);
S0: FBINP1C1=probbnml(P1,N,K1-1); ALPHA1=0;
    FBINP2C1=probbnml(P2,N,K1-1); ALPHA2=0;
    do while (max(ALPHA1,ALPHA2) <= ALPHA);
    ALPHA1=probbnml(P1,N,K2) - FBINP1C1;
    ALPHA2=probbnml(P2,N,K2) - FBINP2C1; K2=K2+1;
    end;   K2=K2-2; if K2 < K1 then go to S2;
    K1 = K1+1; INCL=0; INCR=1;
S1: ALPHA1=probbnml(P1,N,K2) - probbnml(P1,N,K1-1);
    ALPHA2=probbnml(P2,N,K2) - probbnml(P2,N,K1-1);
    DELALPH1=ALPHA - ALPHA1 ;
    DELALPH2=ALPHA - ALPHA2 ;
    B11=probbnml(P1,N,K1-1) - probbnml(P1,N,max(K1-2,0))*sign(1+sign(K1-2));
    B12=probbnml(P1,N,K2+1) - probbnml(P1,N,K2);
    B21=probbnml(P2,N,K1-1) - probbnml(P2,N,max(K1-2,0))*sign(1+sign(K1-2));
    B22=probbnml(P2,N,K2+1) - probbnml(P2,N,K2);

    GAM1 = (B22*DELALPH1 - B12*DELALPH2)/(B11*B22 - B12*B21);
    GAM2 = (B11*DELALPH2 - B21*DELALPH1)/(B11*B22 - B12*B21);
    if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and INCL=0 and INCR=1 then go to S3;
    if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and INCL=1 and INCR=0 then go to S4;
    if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and INCL=1 and INCR=1 then go to S5;
    else go to S6;
S2: INCL=1; INCR=1; go to S1;
S3: K1=K1-1; K2=K2-1; INCL=1; INCR=0; go to S1;
S4: K2=K2+1; INCL=1; INCR=1; go to S1;
S5: K1=K1+1; go to S0;

S6: C1 = K1-1 ; C2=K2+1;
    FBINP0C1 = probbnml(P0,N,C1)  ;
    B01 = FBINP0C1 -probbnml(P0,N,max(C1-1,0))*sign(1+sign(C1-1));
    FBINP0K2 = probbnml(P0,N,K2) ; B02 = probbnml(P0,N,C2) -FBINP0K2;
    POWNONRD = FBINP0K2 - FBINP0C1;
    POW = GAM1*B01 + POWNONRD + GAM2*B02;
    if C1=C2 then POW=POW/2;
    go to S9;
S7: C1=K; C2=K; GAM1=ALPHA/P1K; GAM2=GAM1;
    POWNONRD=0;
    P0K=probbnml(.5,N,K)-probbnml(.5,N,K-1);
    POW=GAM1*P0K;
S9: run;


proc print noobs;
var ALPHA N P1 P2 C1 C2 GAM1 GAM2 POWNONRD POW;
format GAM1 GAM2 POWNONRD POW E15.; run;
%mend bi1st;

%bi1st(.05,273,.65,.75)
