%macro bi2dipow(ALPHA0,M,N,DEL1,DEL2,P1,P2);

data bi2dipow;
ALPHA0=&ALPHA0; M=&M; N=&N; DEL1=&DEL1; DEL2=&DEL2; P1=&P1; P2=&P2;
array INDR{0:&M,0:&N};
array KL{0:&M}; array KU{0:&M};
array EMPT{0:&M};

ERROR='None';

U_AL=probit(ALPHA0);

X=0;
    EMPT{X}=0;
    INDR{X,0}=0;
    do Y=1 to N-1;
    T=abs(X/M-Y/N-(DEL2-DEL1)/2)/sqrt((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    NC=((DEL1+DEL2)/2)**2/((1/M)*(X/M)*(1-X/M)+(1/N)*(Y/N)*(1-Y/N));
    if NC >100 then goto A;
    CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto B;
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
    CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto D;
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
    CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto F;
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
end;  goto P;

WAR: ERROR = '!!!!';  goto SR;

     P: REJ_=0;
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
POWEX=REJ_;

keep ALPHA0 M  N DEL1 DEL2 P1 P2 POWEX ERROR;
SR: run;

proc print noobs;
var ALPHA0 M N DEL1 DEL2  P1 P2 POWEX ERROR;
format POWEX   F12.10;
run;
%mend bi2dipow;

%bi2dipow(.0228, 50, 50,.20,.20,.50,.50)
