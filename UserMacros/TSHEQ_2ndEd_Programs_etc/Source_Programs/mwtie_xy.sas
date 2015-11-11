"
%macro mwtie_xy(ALPHA,M,N,EPS1_,EPS2_,PATH);
data;  ALPHA= &ALPHA; M= &M; N= &N;
EPS1_= &EPS1_;  EPS2_= &EPS2_;
EQCTR= .5+(EPS2_-EPS1_)/2; EQLENG= EPS1_+EPS2_;
array X{300};  array Y{300};
infile "&PATH";
  do I=1 to M; input X{I} @; end;
  do J=1 to N; input Y{J} @; end;
  WXY=0; PIH0=0;  PIHXYY0=0;PIHXYY1=0; PIHXYY2=0;
  PIHXXY0=0; PIHXXY1=0; PIHXXY2=0;
  do I=1 to M; do J=1 to N;
  PIH0=PIH0+ 1 - sign(abs(X{I}-Y{J}));
  WXY=WXY+ int(.5*(sign(X{I}-Y{J})+1)); end;end;
  do I=1 to M; do J1=1 to N-1; do J2=J1+1 to N;
  PIHXYY0= PIHXYY0 + 1 -sign(max(abs(X{I}-Y{J1}),abs(X{I}-Y{J2})));
  PIHXYY1= PIHXYY1 + int(.5*(sign(X{I}-max(Y{J1},Y{J2}))+1));
  PIHXYY2= PIHXYY2 + int(.5*(sign(X{I}-Y{J1})+1))*(1 -sign(abs(X{I}-Y{J2})));
  PIHXYY2= PIHXYY2 + int(.5*(sign(X{I}-Y{J2})+1))*(1 -sign(abs(X{I}-Y{J1})));
  end; end; end;
  do I1=1 to M-1; do I2=I1+1 to M; do J=1 to N;
  PIHXXY0= PIHXXY0 + 1 -sign(max(abs(X{I1}-Y{J}),abs(X{I2}-Y{J})));
  PIHXXY1= PIHXXY1 + int(.5*(sign(min(X{I1},X{I2})-Y{J})+1));
  PIHXXY2= PIHXXY2 + int(.5*(sign(X{I1}-Y{J})+1))*(1 -sign(abs(X{I2}-Y{J})));
  PIHXXY2= PIHXXY2 + int(.5*(sign(X{I2}-Y{J})+1))*(1 -sign(abs(X{I1}-Y{J})));
  end; end; end;
  WXY= WXY/(M*N); PIH0=PIH0/(M*N); WXY_TIE=WXY/(1-PIH0);
  PIHXXY0=PIHXXY0*2/(M*(M-1)*N);
  PIHXYY0=PIHXYY0*2/(N*(N-1)*M);
  PIHXXY1=PIHXXY1*2/(M*(M-1)*N);
  PIHXYY1=PIHXYY1*2/(N*(N-1)*M);
  PIHXXY2=PIHXXY2/(M*(M-1)*N);
  PIHXYY2=PIHXYY2/(N*(N-1)*M);

  VARHPIH0=(PIH0-(M+N-1)*PIH0**2+(M-1)*PIHXXY0+(N-1)*PIHXYY0)/(M*N);
  VARHGAMH=(WXY-(M+N-1)*WXY**2+(M-1)*PIHXXY1+(N-1)*PIHXYY1)/(M*N);
  COVH=((M-1)*PIHXXY2+(N-1)*PIHXYY2-(M+N-1)*WXY*PIH0)/(M*N);
  SIGMAH=sqrt((1-PIH0)**(-2)*VARHGAMH+WXY**2*(1-PIH0)**(-4)*VARHPIH0+
          2*WXY*(1-PIH0)**(-3)*COVH);
  CRIT=sqrt(cinv(ALPHA,1,(EQLENG/2/SIGMAH)**2));
  if abs((WXY_TIE -EQCTR)/SIGMAH) >= CRIT then REJ= 0;
  if abs((WXY_TIE -EQCTR)/SIGMAH) < CRIT then REJ= 1;
  if SIGMAH=. or CRIT=. then REJ=0;
  keep ALPHA M N EPS1_ EPS2_ WXY_TIE SIGMAH CRIT REJ;
run;

proc print noobs; run;
%mend mwtie_xy;


%mwtie_xy(.05,204,258,.10,.10, '<mydirectory>\Examples\expl_6_2.raw')
