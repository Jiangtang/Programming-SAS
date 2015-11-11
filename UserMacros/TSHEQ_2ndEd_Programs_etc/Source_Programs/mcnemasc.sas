%macro mcnemasc(ALPHA,N,DEL0,SW,TOL,MAXH);

data mcnemasc;
ALPHA=&ALPHA; N=&N; DEL0=&DEL0; SW=&SW;  TOL=&TOL; MAXH=&MAXH;
array KL{&N}; array KU{&N}; array KLPR{&N};
ITMIN=ceil(DEL0/SW); ITMAX=1/SW;
ERROR= 'NONE';

U_AL=probit(ALPHA);
    do V=1 to N-1; U=-1;
    T=10; CRIT=0;
    do while (U<=V-1 and T >= CRIT);
    U=U+1;
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto B;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto E;
    B:CRIT=sqrt(NC)+U_AL;
    E:end;
    KL{V}=U; KU{V}=V-KL{V};
    do U=KL{V} to KU{V};
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto B2;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto C2;
    B2:CRIT=sqrt(NC)+U_AL;
    C2:if T >= CRIT  then goto W;
    end;
end;
    V=N; U=0;
    T=10; CRIT=0;
    do while (U<=V-2 and T >= CRIT);
    U=U+1;
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto BN;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto EN;
    BN:CRIT=sqrt(NC)+U_AL;
    EN:end;
    KL{V}=U; KU{V}=V-KL{V};
    do U=KL{V} to KU{V};
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto B2N;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto C2N;
    B2N:CRIT=sqrt(NC)+U_AL;
    C2N:if T >= CRIT  then goto W;
    end;


SIZE=0;
       do IT=ITMIN to ITMAX;
       ETA=IT*SW;
       REJ_=0;
          do V=1 to N;
          if KU{V} >= V then goto D;
          if (KL{V} <= KU{V}) then goto C;
          REJ_V=0; goto V;
          C:PI=(ETA+DEL0)/(2*ETA);
          if PI >=1 then goto E2;
          REJ_V= probbnml(PI,V,KU{V}) - probbnml(PI,V,KL{V}-1);
          goto V;
          D: REJ_V=1; goto V;
          E2: REJ_V=0; goto V;
          V:PROBV=probbnml(ETA,N,V)-probbnml(ETA,N,V-1);
          REJ_=REJ_+REJ_V*PROBV;
          end;
        SIZE=max(SIZE,REJ_);
          end;

if SIZE <= ALPHA then goto K;

ALPHA1=0; SIZE1=0;
ALPHA2=ALPHA; NH=0;
ST: ALPHA0=(ALPHA1+ALPHA2)/2; NH=NH+1;
    U_AL0=probit(ALPHA0);
    do V=1 to N; KLPR{V}=KL{V}; end;
    IND=0;
    do V=1 to N-1; U=-1;
    T=10; CRIT=0;
    do while (U<=V-1 and T >= CRIT);
    U=U+1;
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto BB;
    CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto EE;
    BB:CRIT=sqrt(NC)+U_AL0;
    EE:end;
    KL{V}=U;  IND=IND+sign(abs(KL{V}-KLPR{V}));
    KU{V}=V-KL{V};
    end;


    V=N; U=0;
    T=10; CRIT=0;
    do while (U<=V-2 and T >= CRIT);
    U=U+1;
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto BB_N;
    CRIT=sqrt( cinv(ALPHA0,1,NC) ); goto EE_N;
    BB_N:CRIT=sqrt(NC)+U_AL0;
    EE_N:end;
    KL{V}=U; IND=IND+sign(abs(KL{V}-KLPR{V}));
    KU{V}=V-KL{V};


    if IND=0 and INDCS=1 then goto CS1;
    if IND=0 and INDCS=2 then goto CS2;

    do V=1 to N;
        do U=KL{V} to KU{V};
        T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
        NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
        if NC >100 then goto BB2;
        CRIT=sqrt( cinv(ALPHA,1,NC) ); goto CC2;
        BB2:CRIT=sqrt(NC)+U_AL;
        CC2:if T >= CRIT  then goto W;
        end;
      end;


    SIZE=0;
       do IT=ITMIN to ITMAX;
       ETA=IT*SW;
       REJ_=0;
          do V=1 to N;
          if KU{V} >= V then goto DD;
          if (KL{V} <= KU{V}) then goto CC;
          REJ_V=0; goto VV;
          CC:PI=(ETA+DEL0)/(2*ETA);
          if PI >=1 then goto EE2;
          REJ_V= probbnml(PI,V,KU{V}) - probbnml(PI,V,KL{V}-1);
          goto VV;
          DD: REJ_V=1; goto VV;
          EE2: REJ_V=0; goto VV;
          VV:PROBV=probbnml(ETA,N,V)-probbnml(ETA,N,V-1);
          REJ_=REJ_+REJ_V*PROBV;
          end;
        SIZE=max(SIZE,REJ_);
        end;

            if SIZE >= ALPHA-TOL and SIZE <= ALPHA then goto K;
            if SIZE > ALPHA and NH< MAXH then goto CS1;
            if SIZE < ALPHA-TOL and NH< MAXH then goto CS2;
            if NH>=MAXH then goto A;

     CS1: ALPHA2=ALPHA0; INDCS=1; goto ST;
     CS2: ALPHA1=ALPHA0; SIZE1=SIZE;
          INDCS=2; goto ST;

W: ERROR = '!!!!'; goto S;

A: ALPHA0=ALPHA1; SIZE0=SIZE1;

K: keep ALPHA ALPHA0 N DEL0 SIZE0  SW NH ERROR;
S:run;

proc print noobs;
var ALPHA N DEL0 SW ALPHA0 SIZE0  NH ERROR;
format ALPHA0 SIZE0  E15.; run;
%mend mcnemasc;

%mcnemasc(.10, 50,.10,.0005,.0005,15)
