%macro gofsimpt(ALPHA,N,K,EPS,PATH);


data gofsimpt;
   array X{&K}; array PI0{&K}; array PIH{&K};
   infile "&PATH";
   N=&N;

   do J=1 to &K; input X{J} @; end;
   do J=1 to &K; input PI0{J} @; end;
   do J=1 to &K; PIH{J}=X{J}/N; end;


   DSQPIH_0=0; VNSQ_1=0;
   do J= 1 to &K;
      DSQPIH_0=DSQPIH_0+(PIH{J}-PI0{J})**2;
      VNSQ_1=VNSQ_1+(PIH{J}-PI0{J})**2*PIH{J};
   end;
   VNSQ_2=0;
   do J1=1 to &K; do J2=1 to &K;
      VNSQ_2=VNSQ_2+(PIH{J1}-PI0{J1})*(PIH{J2}-PI0{J2})*
             PIH{J1}*PIH{J2};
   end; end;

   VNSQ= (4/N)*(VNSQ_1-VNSQ_2);  VN_N=sqrt(VNSQ);
   EPSAKSQ= &EPS**2;
   CRIT=EPSAKSQ-probit(1-&ALPHA)*VN_N;
   REJ=0;
   if DSQPIH_0 ^=. and DSQPIH_0 < CRIT then REJ=1;
   ALPHA=&ALPHA; EPS=&EPS;
   keep  ALPHA EPS  N X1-X&K PI01-PI0&K
PIH1-PIH&K DSQPIH_0  VN_N CRIT REJ;
run;


proc print noobs;
var  ALPHA EPS  N X1-X&K PI01-PI0&K DSQPIH_0  VN_N CRIT REJ;
run;

%mend gofsimpt;

%gofsimpt(.05,100,6,.15,'<mydirectory>\Examples\expl_9_1.inp');
