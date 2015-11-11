%macro gofind_t(ALPHA,R,S,EPS,PATH);

data goind_t;
   array X{&R,&S}; array PIH{&R,&S};
   array PIHROW{&R}; array PIHCOL{&S};
   array GRADH{&R,&S}; array COVH{&R,&S,&R,&S};

   ALPHA=&ALPHA; EPS=&EPS; R=&R; S=&S;

infile "&PATH";
   do I=1 to R;
     do J=1 to S; input X{I,J} @@; end;
   end;

   N=0;
   do I=1 to R; do J=1 to S;
   N=N+X{I,J};
   end; end;
   do I=1 to R; do J=1 to S;
   PIH{I,J}=X{I,J}/N;
   end; end;

   do I=1 to R;
      PIHROW{I}=0;
      do J=1 to S;
      PIHROW{I}=PIHROW{I}+PIH{I,J};
      end;
   end;
   do J=1 to S;
      PIHCOL{J}=0;
      do I=1 to R;
      PIHCOL{J}=PIHCOL{J}+PIH{I,J};
      end;
   end;

   DSQ_OBS=0;
   do I= 1 to R; do J= 1 to S;
       DSQ_OBS=DSQ_OBS+(PIH{I,J}-PIHROW{I}*PIHCOL{J})**2;  end;
   end;

   do I1=1 to R; do J1=1 to S; do I2=1 to R; do J2=1 to S;
   COVH{I1,J1,I2,J2}=-PIH{I1,J1}*PIH{I2,J2}; end; end; end; end;
       do I=1 to R; do J=1 to S;
       COVH{I,J,I,J}=PIH{I,J}*(1-PIH{I,J}); end; end;

   do I=1 to R; do J=1 to S;
      SUMJ=0; do JJ=1 to S;
              SUMJ=SUMJ+(PIH{I,JJ}-PIHROW{I}*PIHCOL{JJ})*PIHCOL{JJ};
              end;
      SUMI=0; do II=1 to R;
              SUMI=SUMI+(PIH{II,J}-PIHROW{II}*PIHCOL{J})*PIHROW{II};
              end;
   GRADH{I,J}=2*( (PIH{I,J}-PIHROW{I}*PIHCOL{J}) - SUMJ - SUMI);
   end; end;

   VNSQ=0;
   do I1=1 to R; do J1=1 to S; do I2=1 to R; do J2=1 to S;
   VNSQ=VNSQ+ GRADH{I1,J1}*COVH{I1,J1,I2,J2}*GRADH{I2,J2};
   end; end; end; end;
   VN=sqrt(VNSQ);

   CRIT=EPS**2-probit(1-ALPHA)*VN/sqrt(N);
   REJ=0;
   if DSQ_OBS ^=. and DSQ_OBS < CRIT then REJ=1;
   %let RS = %eval(&R*&S);


keep N ALPHA EPS R S  X1-X&RS DSQ_OBS  VN CRIT REJ;
run;




proc print noobs;  var N ALPHA EPS R S  X1-X&RS DSQ_OBS  VN CRIT REJ;
run;

quit;

%mend gofind_t;

%gofind_t(.05, 2, 4, .15, '<mydirectory>\Examples\gofind_t.inp');
