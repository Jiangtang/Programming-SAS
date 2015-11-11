%macro bi2diffac(ALPHA,M,N,DEL1,DEL2,SW,TOLRD,TOL,MAXH);

data bi2diffac0;
ALPHA=&ALPHA; M=&M; N=&N; DEL1=&DEL1; DEL2=&DEL2;SW=&SW; TOLRD=&TOLRD;
TOL=&TOL; MAXH=&MAXH;
ITMAXL=ceil((1-DEL2)/SW -1); ITMAXR=ceil((1-DEL1)/SW -1);
ITMXL2PL=ITMAXL+2; ITMXR2PL=ITMAXR+2;
call symput("ITMXL2PL",ITMXL2PL); call symput("ITMXR2PL",ITMXR2PL);


data bi2diffac; set  bi2diffac0;

array INDR{0:&M,0:&N};  array EMPT{0:&M};
array KL{0:&M}; array KU{0:&M};  array KLPR{0:&M}; array KUPR{0:&M};
array P1RDL{2}; array P1RDR{2};

ERROR='None';


P1RDL{1}=DEL2+TOLRD; P1RDL{2}=1-TOLRD;
P1RDR{1}=TOLRD; P1RDR{2}=1-DEL1-TOLRD;

U_AL=probit(ALPHA);
X=0;
    EMPT{X}=0;
    INDR{X,0}=0;
    do Y=1 to N-1;
    T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    if NC >100 then goto A;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto B;
    A:CRIT=sqrt(NC)+U_AL;
    B:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
    EMPT{X}=EMPT{X}+INDR{X,Y};
    end;
    INDR{X,N}=0;
do X=1 to M-1;
    EMPT{X}=0;
    do Y=0 to N;
    T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    if NC >100 then goto C;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto D;
    C:CRIT=sqrt(NC)+U_AL;
    D:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
    EMPT{X}=EMPT{X}+INDR{X,Y};
    end;
end;
X=M;
    EMPT{X}=0;
    INDR{X,0}=0;
    do Y=1 to N-1;
    T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    if NC >100 then goto E;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto F;
    E:CRIT=sqrt(NC)+U_AL;
    F:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
    EMPT{X}=EMPT{X}+INDR{X,Y};
    end;
    INDR{X,N}=0;
do X=0 to M;
    if EMPT{X}=0 then goto NULL;
    KL{X}=0;
    Y=0;
    do while (INDR{X,Y}=0);
    Y=Y+1;
    end;
    KL{X}=Y; KU{X}=KL{X}-1;
    do Y=KL{X} to N;
    if INDR{X,Y}=0 then goto S;
    end;
  S:KU{X}=Y-1;
    do Y=KU{X}+1 to N;
    if INDR{X,Y}=1 then goto WAR;
    end;
    goto CON;
NULL: KL{X}=N; KU{X}=0;
CON: continue;
end;

       SIZE=0;
       P1=DEL2;
       do while (P1 <= 1-SW);
       P1=P1+SW;
          P2=-DEL2+P1;
          REJ_=0;
          do X=0 to M;
             if  (KL{X} <= KU{X}) then goto LU;
                 REJ_X=0; goto LV;
             LU: if KL{X} > 0 then goto LU1;
                 REJ_X= probbnml(P2,N,KU{X}); goto LV;
             LU1:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
             LV: PROBLEX= probbnml(P1,M,X);
                 if X>0 then goto LV1;
                 PROBLTX=0; goto LW;
             LV1:PROBLTX=probbnml(P1,M,X-1);
             LW: PROBX=PROBLEX-PROBLTX;
           REJ_=REJ_+REJ_X*PROBX;
           end;
           SIZE=max(SIZE,REJ_);
       end;

       do J=1 to 2;
       P1=P1RDL{J};
          P2=-DEL2+P1;
          REJ_=0;
           do X=0 to M;
              if  (KL{X} <= KU{X}) then goto LG;
                  REJ_X=0; goto LH;
              LG: if KL{X} > 0 then goto LG1;
                  REJ_X= probbnml(P2,N,KU{X}); goto LH;
              LG1:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
              LH: PROBLEX= probbnml(P1,M,X);
                  if X>0 then goto LH1;
                  PROBLTX=0; goto LI;
              LH1:PROBLTX=probbnml(P1,M,X-1);
              LI: PROBX=PROBLEX-PROBLTX;
            REJ_=REJ_+REJ_X*PROBX;
            end;
            SIZE=max(SIZE,REJ_);
       end;


       P1=1-DEL1;
       do while (P1 >= SW);
       P1=P1-SW;
          P2=DEL1+P1;
          REJ_=0;
            do X=0 to M;
               if  (KL{X} <= KU{X}) then goto RU;
                   REJ_X=0; goto RV;
               RU: if KL{X} > 0 then goto RU1;
                   REJ_X= probbnml(P2,N,KU{X}); goto RV;
               RU1:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
               RV: PROBLEX= probbnml(P1,M,X);
                   if X>0 then goto RV1;
                   PROBLTX=0; goto RW;
               RV1:PROBLTX=probbnml(P1,M,X-1);
               RW: PROBX=PROBLEX-PROBLTX;
             REJ_=REJ_+REJ_X*PROBX;
             end;
             SIZE=max(SIZE,REJ_);
        end;

        do J=1 to 2;
        P1=P1RDR{J};
          P2=DEL1+P1;
          REJ_=0;
             do X=0 to M;
               if  (KL{X} <= KU{X}) then goto RG;
                   REJ_X=0; goto RH;
               RG: if KL{X} > 0 then goto RG1;
                   REJ_X= probbnml(P2,N,KU{X}); goto RH;
               RG1:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
               RH: PROBLEX= probbnml(P1,M,X);
                   if X>0 then goto RH1;
                   PROBLTX=0; goto RI;
               RH1:PROBLTX=probbnml(P1,M,X-1);
               RI: PROBX=PROBLEX-PROBLTX;
             REJ_=REJ_+REJ_X*PROBX;
             end;
             SIZE=max(SIZE,REJ_);
       end;

if SIZE > ALPHA then goto ANTI;
if SIZE <=ALPHA then goto K;


ANTI: ALPHA1=0; SIZE1=0;  ALPHA2=ALPHA; NH=0;

ST: ALPHA0=(ALPHA1+ALPHA2)/2; NH=NH+1;

    do X=0 to M; KLPR{X}=KL{X}; KUPR{X}=KU{X}; end;
    U_AL0=probit(ALPHA0);  INDDIS=0;
    X=0;
    EMPT{X}=0;
        INDR{X,0}=0;
        do Y=1 to N-1;
        T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        if NC >100 then goto A2;
        CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto B2;
        A2:CRIT=sqrt(NC)+U_AL0;
        B2:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
        EMPT{X}=EMPT{X}+INDR{X,Y};
        end;
        INDR{X,N}=0;
        do X=1 to M-1;
        EMPT{X}=0;
        do Y=0 to N;
        T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        if NC >100 then goto C2;
        CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto D2;
        C2:CRIT=sqrt(NC)+U_AL0;
        D2:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
        EMPT{X}=EMPT{X}+INDR{X,Y};
        end;
        end;
        X=M;
        EMPT{X}=0;
        INDR{X,0}=0;
        do Y=1 to N-1;
        T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        if NC >100 then goto E2;
        CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto F2;
        E2:CRIT=sqrt(NC)+U_AL0;
        F2:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
        EMPT{X}=EMPT{X}+INDR{X,Y};
        end;
        INDR{X,N}=0;
        do X=0 to M;
        if EMPT{X}=0 then goto NULL2;
        KL{X}=0;
        Y=0;
        do while (INDR{X,Y}=0);
        Y=Y+1;
        end;
        KL{X}=Y; INDDIS=INDDIS+sign(abs(KL{X}-KLPR{X}));
        KU{X}=KL{X}-1;
        do Y=KL{X} to N;
        if INDR{X,Y}=0 then goto S2;
        end;
        S2:KU{X}=Y-1;  INDDIS=INDDIS+sign(abs(KU{X}-KUPR{X}));
        do Y=KU{X}+1 to N;
        if INDR{X,Y}=1 then goto WAR;
        end;
        goto CON2;
 NULL2: KL{X}=N; KU{X}=0; INDDIS=INDDIS+sign(abs(KU{X}-KUPR{X}));
 CON2:  continue;
        end;



    if INDDIS=0 and NH =MAXH then goto ABR;
    if INDDIS=0 and INDCS=1 then goto CS1;
    if INDDIS=0 and INDCS=2 then goto CS2;


       SIZE=0; P1=DEL2;
       do while (P1 <= 1-SW);
       P1=P1+SW;
          P2=-DEL2+P1;
          REJ_=0;
          do X=0 to M;
             if  (KL{X} <= KU{X}) then goto LU2;
                 REJ_X=0; goto LV2;
             LU2: if KL{X} > 0 then goto LU12;
                 REJ_X= probbnml(P2,N,KU{X}); goto LV2;
             LU12:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
             LV2: PROBLEX= probbnml(P1,M,X);
                 if X>0 then goto LV12;
                 PROBLTX=0; goto LW2;
             LV12:PROBLTX=probbnml(P1,M,X-1);
             LW2: PROBX=PROBLEX-PROBLTX;
           REJ_=REJ_+REJ_X*PROBX;
           end;
           SIZE=max(SIZE,REJ_);
       end;

       do J=1 to 2;
       P1=P1RDL{J};
          P2=-DEL2+P1;
          REJ_=0;
           do X=0 to M;
              if  (KL{X} <= KU{X}) then goto LG2;
                  REJ_X=0; goto LH2;
              LG2: if KL{X} > 0 then goto LG12;
                  REJ_X= probbnml(P2,N,KU{X}); goto LH2;
              LG12:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
              LH2: PROBLEX= probbnml(P1,M,X);
                  if X>0 then goto LH12;
                  PROBLTX=0; goto LI2;
              LH12:PROBLTX=probbnml(P1,M,X-1);
              LI2: PROBX=PROBLEX-PROBLTX;
            REJ_=REJ_+REJ_X*PROBX;
            end;
            SIZE=max(SIZE,REJ_);
       end;


       P1=1-DEL1;
       do while (P1 >= SW);
       P1=P1-SW;
          P2=DEL1+P1;
          REJ_=0;
            do X=0 to M;
               if  (KL{X} <= KU{X}) then goto RU2;
                   REJ_X=0; goto RV2;
               RU2: if KL{X} > 0 then goto RU12;
                   REJ_X= probbnml(P2,N,KU{X}); goto RV2;
               RU12:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
               RV2: PROBLEX= probbnml(P1,M,X);
                   if X>0 then goto RV12;
                   PROBLTX=0; goto RW2;
               RV12:PROBLTX=probbnml(P1,M,X-1);
               RW2: PROBX=PROBLEX-PROBLTX;
             REJ_=REJ_+REJ_X*PROBX;
             end;
             SIZE=max(SIZE,REJ_);
        end;

        do J=1 to 2;
        P1=P1RDR{J};
          P2=DEL1+P1;
          REJ_=0;
             do X=0 to M;
               if  (KL{X} <= KU{X}) then goto RG2;
                   REJ_X=0; goto RH2;
               RG2: if KL{X} > 0 then goto RG12;
                   REJ_X= probbnml(P2,N,KU{X}); goto RH2;
               RG12:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
               RH2: PROBLEX= probbnml(P1,M,X);
                   if X>0 then goto RH12;
                   PROBLTX=0; goto RI2;
               RH12:PROBLTX=probbnml(P1,M,X-1);
               RI2: PROBX=PROBLEX-PROBLTX;
             REJ_=REJ_+REJ_X*PROBX;
             end;
             SIZE=max(SIZE,REJ_);
       end;



            if SIZE >= ALPHA-TOL and SIZE <= ALPHA then goto CS0;
            if SIZE > ALPHA and NH< MAXH then goto CS1;
            if SIZE < ALPHA-TOL and NH< MAXH then goto CS2;
            if NH=MAXH then goto ABR;

     CS0: SIZE0=SIZE; goto K;
     CS1: ALPHA2=ALPHA0; INDCS=1; goto ST;
     CS2: ALPHA1=ALPHA0; SIZE1=SIZE; INDCS=2; goto ST;




WAR: ERROR = '!!!!';  goto SR;

ABR: ALPHA0=ALPHA1; SIZE0=SIZE1;




K: U_AL0=probit(ALPHA0);
    X=0;
    EMPT{X}=0;
        INDR{X,0}=0;
        do Y=1 to N-1;
        T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        if NC >100 then goto A0;
        CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto B0;
        A0:CRIT=sqrt(NC)+U_AL0;
        B0:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
        EMPT{X}=EMPT{X}+INDR{X,Y};
        end;
        INDR{X,N}=0;
        do X=1 to M-1;
        EMPT{X}=0;
        do Y=0 to N;
        T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        if NC >100 then goto C0;
        CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto D0;
        C0:CRIT=sqrt(NC)+U_AL0;
        D0:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
        EMPT{X}=EMPT{X}+INDR{X,Y};
        end;
        end;
        X=M;
        EMPT{X}=0;
        INDR{X,0}=0;
        do Y=1 to N-1;
        T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
        if NC >100 then goto E0;
        CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto F0;
        E0:CRIT=sqrt(NC)+U_AL0;
        F0:INDR{X,Y}=int(.5*(1+sign(CRIT-T)));
        EMPT{X}=EMPT{X}+INDR{X,Y};
        end;
        INDR{X,N}=0;
        do X=0 to M;
        if EMPT{X}=0 then goto NULL0;
        KL{X}=0;
        Y=0;
        do while (INDR{X,Y}=0);
        Y=Y+1;
        end;
        KL{X}=Y; KU{X}=KL{X}-1;
        do Y=KL{X} to N;
        if INDR{X,Y}=0 then goto S0;
        end;
        S0:KU{X}=Y-1;
        do Y=KU{X}+1 to N;
        if INDR{X,Y}=1 then goto WAR;
        end;
        goto CON0;
 NULL0: KL{X}=N; KU{X}=0; INDDIS=INDDIS+sign(abs(KU{X}-KUPR{X}));
 CON0:  continue;
        end;




array P1L{&ITMXL2PL}; array P1R{&ITMXR2PL};


   P1L{1}= DEL2+TOLRD; do J=2 to ITMAXL+1; P1L{J}=DEL2+SW*(J-1); end;
   P1L{ITMXL2PL}=1-TOLRD;
   P1R{1}=TOLRD; do J=2 to ITMAXR+1; P1R{J}=SW*(J-1); end;
   P1R{ITMXR2PL}=1-DEL1-TOLRD;


       SIZE_=0;
       do J=1 to ITMXL2PL;
       P1=P1L{J};
          P2=-DEL2+P1;
          do while (P2 > TOLRD);
          REJ_=0;
          do X=0 to M;
             if  (KL{X} <= KU{X}) then goto LU_;
                 REJ_X=0; goto LV_;
             LU_: if KL{X} > 0 then goto LU1_;
                  REJ_X= probbnml(P2,N,KU{X}); goto LV_;
             LU1_:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
             LV_: PROBLEX= probbnml(P1,M,X);
                  if X>0 then goto LV1_;
                  PROBLTX=0; goto LW_;
             LV1_:PROBLTX=probbnml(P1,M,X-1);
             LW_: PROBX=PROBLEX-PROBLTX;
           REJ_=REJ_+REJ_X*PROBX;
           end;
           SIZE_=max(SIZE_,REJ_);
           P2=P2-SW;
          end;
           P2=TOLRD;
           REJ_=0;
           do X=0 to M;
              if  (KL{X} <= KU{X}) then goto LG_;
                  REJ_X=0; goto LH_;
              LG_: if KL{X} > 0 then goto LG1_;
                  REJ_X= probbnml(P2,N,KU{X}); goto LH_;
              LG1_:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
              LH_: PROBLEX= probbnml(P1,M,X);
                  if X>0 then goto LH1_;
                  PROBLTX=0; goto LI_;
              LH1_:PROBLTX=probbnml(P1,M,X-1);
              LI_: PROBX=PROBLEX-PROBLTX;
            REJ_=REJ_+REJ_X*PROBX;
            end;
            SIZE_=max(SIZE_,REJ_);

       end;


       do J=1 to ITMXR2PL;
       P1=P1R{J};
            P2=DEL1+P1;
            do while (P2 < 1-TOLRD);
            REJ_=0;
            do X=0 to M;
               if  (KL{X} <= KU{X}) then goto RU_;
                   REJ_X=0; goto RV_;
               RU_: if KL{X} > 0 then goto RU1_;
                   REJ_X= probbnml(P2,N,KU{X}); goto RV_;
               RU1_:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
               RV_: PROBLEX= probbnml(P1,M,X);
                   if X>0 then goto RV1_;
                   PROBLTX=0; goto RW_;
               RV1_:PROBLTX=probbnml(P1,M,X-1);
               RW_: PROBX=PROBLEX-PROBLTX;
             REJ_=REJ_+REJ_X*PROBX;
             end;
             SIZE_=max(SIZE_,REJ_);
             P2=P2+SW;
             end;
             P2=1-TOLRD;
             REJ_=0;
             do X=0 to M;
               if  (KL{X} <= KU{X}) then goto RG_;
                   REJ_X=0; goto RH_;
               RG_: if KL{X} > 0 then goto RG1_;
                   REJ_X= probbnml(P2,N,KU{X}); goto RH_;
               RG1_:REJ_X= probbnml(P2,N,KU{X}) - probbnml(P2,N,KL{X}-1);
               RH_: PROBLEX= probbnml(P1,M,X);
                   if X>0 then goto RH1_;
                   PROBLTX=0; goto RI_;
               RH1_:PROBLTX=probbnml(P1,M,X-1);
               RI_: PROBX=PROBLEX-PROBLTX;
             REJ_=REJ_+REJ_X*PROBX;
             end;
             SIZE_=max(SIZE_,REJ_);
    end;


if SIZE_ > SIZE0+TOLRD then goto WAR;

keep ALPHA ALPHA0 M  N DEL1 DEL2 SW TOLRD TOL MAXH NH SIZE0  ERROR;

SR: run;

proc print noobs;
var  ALPHA M N DEL1 DEL2 SW TOLRD TOL MAXH  NH ALPHA0 SIZE0 ERROR;
format ALPHA0 SIZE0  F12.10;
run;
%mend bi2diffac;

%bi2diffac(.05, 50, 50 ,.40,.40,.001,.000001,.0001,10)
