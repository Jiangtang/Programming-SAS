%macro gofhwex_1s(ALPHA,N,S,DEl0);

data dim;
N= &N; S= &S;
NB=int(S/2)-max(0,S-N)+1;
call symput("DIM",NB);

data;  set dim;

ALPHA= &ALPHA; DEL0= &DEL0;
THET= (1-DEL0)*4;
keep N S DEL0 ALPHA C GAM;

array B{&DIM};  array PRB{&DIM};  array PRB_GT{0:&DIM};

do K=1 to NB; B(K)=S-2*int(S/2)+2*(K-1); end;

BHW= S*(1-S/(2*N));

if (NB=1) then goto S7;

K=1; do while (B(K) <= BHW); K=K+1; end;
K1=min(K+1, NB);

   K = 1;
        CL=lgamma(N+1)-lgamma((S-B(K))/2+1) -lgamma(B(K)+1) -
           lgamma(N-B(K)/2- S/2+1);
        ARGEXP_U = CL+(B(K)/2)*log(THET);

        do K=2 to NB;
        CL=lgamma(N+1)-lgamma((S-B(K))/2+1) -lgamma(B(K)+1) -
           lgamma(N-B(K)/2- S/2+1);
        ARGEXP_U = max(ARGEXP1_U,  CL+(B(K)/2)*log(THET));
        end;

        SHIFTL = min(0 , 700 - ARGEXP_U);

     do K=1 to NB;
        CL=lgamma(N+1)-lgamma((S-B(K))/2+1) -lgamma(B(K)+1) -
           lgamma(N-B(K)/2- S/2+1);


        PRB(K)= exp(CL+(B(K)/2)*log(THET) + SHIFTL );

        end;



      PRB_GT(NB)=0;
        do K=1 to NB;
        KK=NB-K;
        PRB_GT(KK)= PRB(KK+1) + PRB_GT(KK+1);
        end;

        do K=1 to NB;
        PRB_GT(K)=PRB_GT(K)/PRB_GT(0);
        end;
        PRB_GT(0) = 1;


        K=NB+1;

         S0:K=K-1;
            SIZE= PRB_GT(K);
            IF(SIZE <= ALPHA) then go to S0;
            else go to S1;
         S1:KC= K+1; C=B(KC);
            GAM= (ALPHA-PRB_GT(KC))/(PRB_GT(K)-PRB_GT(KC));
            go to S9;
         S7: KC=1; C=B(1); GAM=ALPHA;
         S9: output;

proc print noobs;
format GAM GAM E15.; run;
%mend gofhwex_1s;

%gofhwex_1s(.05 , 133 , 65 , 1-1/1.96)
