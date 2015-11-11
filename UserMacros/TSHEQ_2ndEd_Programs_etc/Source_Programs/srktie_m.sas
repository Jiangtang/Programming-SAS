%MACRO srktie_m(W,N,ALPHA,EPS1,EPS2,PATH);
data data0;
infile "&PATH"; W=&W;
array D{&N};
do I=1 to &N; input D{I} @; end;
DMIN=min(of D1-D&N); DMAX= max(of D1-D&N);
WR=max(abs(DMIN),abs(DMAX));
R=WR/W;
RC=left(R);
call symput("RM",RC);

data data1; set data0;
array D{&N};
array M{-&RM:&RM};
do K=-R to R;
DK=K*W; M{K}=0;
   do I=1 to &N;  if abs(D{I}-DK) < 10**(-10) then M{K}=M{K}+1; end;
end;

   SMP0=0;
   do K=1 to R; SMP0=SMP0+M{K}*M{-K}; end;

   SMP0_1=0;
   do K=1 to R; SMP0_1=SMP0_1+M{K}*(M{-K}+M{0}); end;

   SMP0_2=0;
   do K=-R to R; SMP0_2=SMP0_2+M{K}*M{-K}**2; end;

   SMP1=0;
   do K=1 to R; do L=-K+1 to K-1;
   SMP1=SMP1+M{K}*M{L}; end; end;

   SMQ=0;
   do K=1 to R; SMQ=SMQ+M{K}**2; end;

   SM=0;
   do K=1 to R; SM=SM+M{K}; end;

   SMPQ=0; SMP0PL=0;
   do K=-R+1 to R;
      SM_K=0; do L=-K+1 to R; SM_K=SM_K+M{L}; end;
      SMPQ=SMPQ+M{K}*SM_K**2;
      SMP0PL=SMP0PL+M{K}*M{-K}*SM_K;
      end;

   SMP2=0;
   do K=1 to R; do L=-K+1 to R;
   SMP2=SMP2+M{K}*M{L}; end; end;

ALPHA=&ALPHA; N=&N; EPS1=&EPS1; EPS2=&EPS2;


U_PL  = (2*SMP1+SMQ-SM)/(N*(N-1));
U_0    = (2*SMP0+M{0}*(M{0}-1))/(N*(N-1));
QH_PL  =(SMPQ - 2*SMP1 - SMQ + 2*SM -2*SMP2)/(N*(N-1)*(N-2));
QH_0   =(SMP0_2 - 2*SMP0 -3*M{0}**2+2*M{0})/(N*(N-1)*(N-2));
QH_0PL =(SMP0PL - SMP0 - SM*M{0})/(N*(N-1)*(N-2));



SSQ_PL = (4*(N-2)/(N-1))*(QH_PL-U_PL**2) + (2/(N-1))*U_PL*(1-U_PL);
SSQ_0  = (4*(N-2)/(N-1))*(QH_0-U_0**2) + (2/(N-1))*U_0*(1-U_0);
SS_0PL = (4*(N-2)/(N-1))*(QH_0PL-U_0*U_PL) + (2/(N-1))*U_0*U_PL;

TAUHSQAS= SSQ_PL/(1-U_0)**2 + U_PL**2*SSQ_0/(1-U_0)**3
          + 2*U_PL*SS_0PL/(1-U_0)**3;

UAS_PL=U_PL/(1-U_0);
EQCTR=(1-EPS1+EPS2)/2;
TAUHAS=sqrt(TAUHSQAS);

CRIT=sqrt(cinv(ALPHA,1,N*(EPS1+EPS2)**2/4/TAUHSQAS));
  if sqrt(N)*abs((UAS_PL -EQCTR)/TAUHAS) >= CRIT then REJ= 0;
  if sqrt(N)*abs((UAS_PL -EQCTR)/TAUHAS) < CRIT then REJ= 1;
  if TAUHAS=. or CRIT=. then REJ=0;

proc print noobs; var N ALPHA EPS1 EPS2 U_PL U_0 UAS_PL TAUHAS CRIT REJ;
run;
%mend srktie_m;


%srktie_m(.1,24,.05,.2602,.2602, '<mydirectory>\Examples\expl5_5_srktie.raw')
