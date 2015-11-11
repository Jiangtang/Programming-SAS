%macro bi2st(ALPHA,M,N,S,RHO1,RHO2);
data; ALPHA= &ALPHA; M=&M; N= &N; S=&S;
      RHO1= &RHO1; RHO2= &RHO2;
keep M N S RHO1 RHO2 ALPHA C1 GAM1 C2 GAM2 ;
    NN=M+N; K=int(S*M/NN);
    if 2*K <S or RHO1 ^= 1/RHO2 then go to S00;
    HRHO1K=probhypr(NN,M,S,K,RHO1)-probhypr(NN,M,S,max(0,K-1),RHO1);
    if HRHO1K >= ALPHA then go to S7;
    S00:K1=min(K+2,S,M);
    S0:K2=K1-1;
       HRHO1C1=probhypr(NN,M,S,K1-1,RHO1); ALPHA1=0;
       HRHO2C1=probhypr(NN,M,S,K1-1,RHO2); ALPHA2=0;
       do while (max(ALPHA1,ALPHA2) <= ALPHA and K2 <= min(S,M) +2);
       ALPHA1=probhypr(NN,M,S,min(S,M,K2),RHO1) - HRHO1C1;
       ALPHA2=probhypr(NN,M,S,min(S,M,K2),RHO2) - HRHO2C1;
       K2=K2+1;end;   K2=K2-2;  if K2 < K1 then go to S2;
       K1=K1+1; INCL=0; INCR=1;
   S1: ALPHA1=probhypr(NN,M,S,min(S,M,K2),RHO1) - probhypr(NN,M,S,max(0,S-N,K1-1),RHO1);
       ALPHA2=probhypr(NN,M,S,min(S,M,K2),RHO2) - probhypr(NN,M,S,max(0,S-N,K1-1),RHO2);
       DELALPH1=ALPHA - ALPHA1 ;
       DELALPH2=ALPHA - ALPHA2 ;
       EXHYP11=probhypr(NN,M,S,K1-1,RHO1) -
          probhypr(NN,M,S,max(0,S-N,K1-2),RHO1)*sign(1+sign((K1-2)-max(0,S-N)));
       EXHYP12=probhypr(NN,M,S,min(S,M,K2+1),RHO1) -
          probhypr(NN,M,S,min(S,M,K2),RHO1);
       EXHYP21=probhypr(NN,M,S,K1-1,RHO2) -
          probhypr(NN,M,S,max(0,S-N,K1-2),RHO2)*sign(1+sign((K1-2)-max(0,S-N)));
       EXHYP22=probhypr(NN,M,S,min(S,M,K2+1),RHO2) -
          probhypr(NN,M,S,min(S,M,K2),RHO2);
       DET =EXHYP11*EXHYP22 - EXHYP12*EXHYP21;
       GAM1 = (EXHYP22*DELALPH1 - EXHYP12*DELALPH2)/DET;
       GAM2 = (EXHYP11*DELALPH2 - EXHYP21*DELALPH1)/DET;
       if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and
                                                INCL=0 and INCR=1 then go to S3;
       if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and
                                                INCL=1 and INCR=0 then go to S4;
       if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and
                                                INCL=1 and INCR=1 then go to S5;
       else go to S6;
   S2: INCL=1; INCR=1; go to S1;
   S3: K1=K1-1; K2=K2-1; INCL=1; INCR=0; go to S1;
   S4: K2=K2+1; INCL=1; INCR=1; go to S1;
   S5: K1=K1-1; go to S0;
   S6: C1 = K1-1 ; C2=K2+1; go to S9;
   S7: C1=K; C2=K; GAM1=ALPHA/HRHO1K; GAM2=GAM1;
   S9: run;

proc print noobs;
format GAM1 GAM2 E15.; run;
%mend bi2st;

%bi2st(.95,25,25,5,.6667,3/2)
