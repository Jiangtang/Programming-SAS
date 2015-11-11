%macro gofhwex(ALPHA,N,S,DEl1,DEL2);

data dim;
N= &N; S= &S;
NB=int(S/2)-max(0,S-N)+1;
call symput("DIM",NB);

data;  set dim;

ALPHA= &ALPHA; DEL1= &DEL1; DEL2= &DEL2;
THET1= (1-DEL1)*4; THET2= (1+DEL2)*4;
keep N S DEL1 DEL2 ALPHA C1 GAM1 C2 GAM2 ;

array B{&DIM};  array PRBL{&DIM};  array PRBR{&DIM};

do K=1 to NB; B(K)=S-2*int(S/2)+2*(K-1); end;

BHW= S*(1-S/(2*N));

if (NB=1) then goto S7;

K=1; do while (B(K) <= BHW); K=K+1; end;
K1=min(K+1, NB);

   K = 1;
        CL=lgamma(N+1)-lgamma((S-B(K))/2+1) -lgamma(B(K)+1) -
           lgamma(N-B(K)/2- S/2+1);
        ARGEXP1_U = CL+(B(K)/2)*log(THET1);
        ARGEXP2_U = CL+(B(K)/2)*log(THET2);

        do K=2 to NB;
        CL=lgamma(N+1)-lgamma((S-B(K))/2+1) -lgamma(B(K)+1) -
           lgamma(N-B(K)/2- S/2+1);
        ARGEXP1_U = max(ARGEXP1_U,  CL+(B(K)/2)*log(THET1));
        ARGEXP2_U = max(ARGEXP2_U,  CL+(B(K)/2)*log(THET2));
        end;

        SHIFTL1 = min(0 , 700 - ARGEXP1_U);
        SHIFTL2 = min(0 , 700 - ARGEXP2_U);

     do K=1 to NB;
        CL=lgamma(N+1)-lgamma((S-B(K))/2+1) -lgamma(B(K)+1) -
           lgamma(N-B(K)/2- S/2+1);


        PRBL(K)= exp(CL+(B(K)/2)*log(THET1) + SHIFTL1 );
        PRBR(K)= exp(CL+(B(K)/2)*log(THET2) + SHIFTL2 );

        end;

do K=2 to NB;
PRBL(K)= PRBL(K)+PRBL(K-1);
PRBR(K)= PRBR(K)+PRBR(K-1);
end;

do K=1 to NB;
PRBL(K)=PRBL(K)/PRBL(NB);
PRBR(K)=PRBR(K)/PRBR(NB);
end;


    S0:K2=K1-1;
       PRBLC1=PRBL(max(K1-1,1))*sign(K1-1); ALPHA1=0;
       PRBRC1=PRBR(max(K1-1,1))*sign(K1-1); ALPHA2=0;
       do while (max(ALPHA1,ALPHA2) <= ALPHA and K2 <=NB);
       ALPHA1=PRBL(min(K2,NB)) - PRBLC1;
       ALPHA2=PRBR(min(K2,NB)) - PRBRC1;
       K2=K2+1;end;
       K2=K2-2;  if K2 < K1 then go to S2;
       K1=K1+1; INCL=0; INCR=1;

   S1: ALPHA1=PRBL(min(K2,NB))-PRBL(MAX(1,K1-1));
       ALPHA2=PRBR(min(K2,NB))-PRBR(MAX(1,K1-1));
       DELALPH1=ALPHA - ALPHA1 ;
       DELALPH2=ALPHA - ALPHA2 ;
       EXRANDL1=PRBL(K1-1)-PRBL(max(K1-2,1))*sign(K1-2);
       EXRANDL2=PRBL(min(K2+1,NB))-PRBL(min(K2,NB));
       EXRANDR1=PRBR(K1-1)-PRBR(max(K1-2,1))*sign(K1-2);
       EXRANDR2=PRBR(min(K2+1,NB))-PRBR(min(K2,NB));
       DET =EXRANDL1*EXRANDR2 - EXRANDL2*EXRANDR1;

       if abs(DET) >=  10**(-78) then goto G0;
            GAM1 = -1; GAM2 = -1; goto G1;

       G0:  GAM1 = (EXRANDR2*DELALPH1 - EXRANDL2*DELALPH2)/DET;
            GAM2 = (EXRANDL1*DELALPH2 - EXRANDR1*DELALPH1)/DET;
       G1:  if (min(GAM1,GAM2)<0 or max(GAM1,GAM2)>=1) and
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
   S6: C1 = B(K1-1) ; C2=B(K2+1); go to S9;
   S7: C1=B(1); C2=B(1); GAM1=ALPHA; GAM2=ALPHA;
   S9: run;

proc print noobs;
format GAM1 GAM2 E15.; run;
%mend gofhwex;

%gofhwex(.05,393, 511, 1-1/1.96, 0.96)
