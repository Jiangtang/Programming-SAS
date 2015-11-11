%MACRO mwtie_fr(K,ALPHA,M,N,EPS1_,EPS2_,PATH);
data data0;  ALPHA= &ALPHA; M= &M; N= &N;
EPS1_= &EPS1_;  EPS2_= &EPS2_; K= &K; KPL1=K+1;
EQCTR= .5+(EPS2_-EPS1_)/2; EQLENG= EPS1_+EPS2_;
call symput("KPL1",KPL1);

data data1; set data0;
array X{&M};  array Y{&N};
array W{&K};
array NX{&K};  array NY{&K};
array NXC{&KPL1};  array NYC{&KPL1};

do KK=1 to K;
W{KK}=KK;
NX{KK}=0; NY{KK}=0;
end;
infile "&PATH";

do I=1 to M; input X{I} @ ;
     do KK=1 to K;
     if X{I}=W{KK} then NX{KK} =NX{KK}+1;
     end;
  end;

  do J=1 to N; input Y{J} @;
     do KK=1 to K;
     if Y{J}=W{KK} then NY{KK} =NY{KK}+1;
     end;
  end;

  NXC{1}=0; NYC{1}=0;
  do KK=2 to K+1;
  NXC{KK}=NXC{KK-1}+NX{KK-1};
  NYC{KK}=NYC{KK-1}+NY{KK-1};
  end;

  WXY=0; PIH0=0;  PIHXYY0=0;PIHXYY1=0; PIHXYY2=0;PIHXXY0=0; PIHXXY1=0; PIHXXY2=0;


  do KK=1 to K;
  PIH0=PIH0+ NX{KK}*NY{KK}; WXY=WXY+NX{KK}*NYC{KK};
  PIHXYY0= PIHXYY0 + NX{KK}*NY{KK}*(NY{KK}-1);
  PIHXYY1= PIHXYY1 + NX{KK}*NYC{KK}*(NYC{KK}-1);
  PIHXYY2= PIHXYY2 + NX{KK}*NY{KK}*NYC{KK};
  PIHXXY0= PIHXXY0 + NX{KK}*(NX{KK}-1)*NY{KK};
  PIHXXY1= PIHXXY1 + NY{KK}*(M-NXC{KK+1})*(M-NXC{KK+1}-1);
  PIHXXY2= PIHXXY2 + NY{KK}*NX{KK}*(M-NXC{KK+1});
  end;

  WXY= WXY/(M*N); PIH0=PIH0/(M*N); WXY_TIE=WXY/(1-PIH0);
  PIHXXY0=PIHXXY0/(M*(M-1)*N);
  PIHXYY0=PIHXYY0/(N*(N-1)*M);
  PIHXXY1=PIHXXY1/(M*(M-1)*N);
  PIHXYY1=PIHXYY1/(N*(N-1)*M);
  PIHXXY2=PIHXXY2/(M*(M-1)*N);
  PIHXYY2=PIHXYY2/(N*(N-1)*M);

  VARHPIHO=(PIH0-(M+N-1)*PIH0**2+(M-1)*PIHXXY0+(N-1)*PIHXYY0)/(M*N);
  VARHGAMH=(WXY-(M+N-1)*WXY**2+(M-1)*PIHXXY1+(N-1)*PIHXYY1)/(M*N);
  COVH=((M-1)*PIHXXY2+(N-1)*PIHXYY2-(M+N-1)*WXY*PIH0)/(M*N);
  SIGMAH=sqrt((1-PIH0)**(-2)*VARHGAMH+WXY**2*(1-PIH0)**(-4)*VARHPIHO+
          2*WXY*(1-PIH0)**(-3)*COVH);
  CRIT=sqrt(cinv(ALPHA,1,(EQLENG/2/SIGMAH)**2));
  if abs((WXY_TIE -EQCTR)/SIGMAH) >= CRIT then REJ= 0;
  if abs((WXY_TIE -EQCTR)/SIGMAH) < CRIT then REJ= 1;
  if SIGMAH=. or CRIT=. then REJ=0;
keep K ALPHA M N EPS1_ EPS2_ WXY_TIE SIGMAH CRIT REJ;
run;

proc print noobs;
var K ALPHA M N EPS1_ EPS2_ WXY_TIE SIGMAH CRIT REJ;
run;
%mend mwtie_fr;


%mwtie_fr(3,.05,204,258,.10,.10, '<mydirectory>\Examples\expl_6_2.raw')
