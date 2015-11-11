%macro mcnempow(ALPHA,N,DEL0,P10,P01);

data mcnempow;
ALPHA=&ALPHA; N=&N; DEL0=&DEL0; P10=&P10;  P01=&P01;
array KL{&N}; array KU{&N};
U_AL=probit(ALPHA); ERROR= 'NONE';
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
    DO U=KL{V} to KU{V};
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
    DO U=KL{V} to KU{V};
    T=sqrt(N)*abs((2*U-V)/N)/sqrt(V/N-((2*U-V)/N)**2);
    NC=N*DEL0**2/(V/N-((2*U-V)/N)**2);
    if NC >100 then goto B2N;
    CRIT=sqrt( cinv(ALPHA,1,NC) ); goto C2N;
    B2N:CRIT=sqrt(NC)+U_AL;
    C2N:if T >= CRIT  then goto W;
    end;

          POW=0; ETA=P10+P01; PI=P10/ETA;
          do V=1 to N;
          if KU{V} >= V then goto D;
          if (KL{V} <= KU{V}) then goto C;
          REJ_V=0; goto V;
          C: REJ_V= probbnml(PI,V,KU{V}) - probbnml(PI,V,KL{V}-1);
          goto V;
          D: REJ_V=1;
          V:PROBV=probbnml(ETA,N,V)-probbnml(ETA,N,V-1);
          POW=POW+REJ_V*PROBV;
          end;



keep
ALPHA N DEL0 P10 P01 POW ERROR; goto S;
W: ERROR = '!!!!'; goto S;
S: run;

proc print noobs;
var ALPHA N DEL0 P10 P01 POW ERROR;
format POW  E15.; run;
%mend mcnempow;

%mcnempow(.024902, 50,.20,.30,.30)
