%macro mawi(ALPHA,M,N,EPS1_,EPS2_,PATH);
data;  ALPHA= &ALPHA; M= &M; N= &N;
EPS1_= &EPS1_;  EPS2_= &EPS2_;
EQCTR= .5+(EPS2_-EPS1_)/2; EQLENG= EPS1_+EPS2_;
array X{&M};  array Y{&N};
infile "&PATH";
  do I=1 to M; input X{I} @; end;
  do J=1 to N; input Y{J} @; end;
  WXY=0; PIHXXY=0; PIHXYY=0;
  do I=1 to M; do J=1 to N;
   WXY=WXY+ int(.5*(sign(X{I}-Y{J})+1)); end;end;
  do I=1 to M; do J1=1 to N-1; do J2=J1+1 to N;
  PIHXYY= PIHXYY + int(.5*(sign(X{I}-max(Y{J1},Y{J2}))+1));
  end; end; end;
  do I1=1 to M-1; do I2=I1+1 to M; do J=1 to N;
  PIHXXY= PIHXXY + int(.5*(sign(min(X{I1},X{I2})-Y{J})+1));
  end; end; end;
  WXY= WXY/(M*N); PIHXXY=PIHXXY*2/(M*(M-1)*N);
                  PIHXYY=PIHXYY*2/(N*(N-1)*M);
  SIGMAH=sqrt((WXY-(M+N-1)*WXY**2+(M-1)*PIHXXY+(N-1)*PIHXYY)/(m*n));
  CRIT=sqrt(cinv(ALPHA,1,(EQLENG/2/SIGMAH)**2));
  if abs((WXY -EQCTR)/SIGMAH) >= CRIT then REJ= 0;
  if abs((WXY -EQCTR)/SIGMAH) < CRIT then REJ= 1;
  if SIGMAH=. or CRIT=. then REJ=0;
  keep ALPHA M N EPS1_ EPS2_ WXY SIGMAH CRIT REJ;
run;

  proc print noobs; run;
%mend mawi;


%mawi(.05,12,12,.1382,.2602, '<mydirectory>\Source_Programs\Examples\ex6_1_mw.raw')
