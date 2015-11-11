%macro mcnasc_ni(ALPHA,N,DEL0,SW,TOL,MAXH);

data mcnasc_ni;
ALPHA=&ALPHA; N=&N; DEL0=&DEL0; SW=&SW;  TOL=&TOL; MAXH=&MAXH;
array K{&N};  array KPR{&N};

U_ALC=probit(1-ALPHA);
    do V=1 to N; U=V;
        T= 10;
        do while (U >= 1 and T > U_ALC);
        U=U-1;
        T=sqrt(N)*((2*U-V)/N + DEL0)/sqrt(V/N-((2*U-V)/N)**2);
        end;
    K(V)=U+1;
    end;

       SIZE=0;  eta_ = DEL0;

        eta= DEL0 + sw;
        do while (eta <= 1 -sw);
        pi_0 = 1/2-DEL0/(2*eta);

       REJ_=0;
          do V=1 to N;
          if K(V) = 0 then goto D;
          REJ_V= 1-probbnml(PI_0,V,K(V)-1) ;
          goto V;
          D: REJ_V=1; goto V;
          V: PROBV=probbnml(ETA,N,V)-probbnml(ETA,N,V-1);
          REJ_=REJ_+REJ_V*PROBV;
          end;
        if SIZE >= REJ_ then goto ETA;
        SIZE=REJ_; ETA_ = ETA;
        ETA: eta= eta + sw;
        end;

SIZE_unc = SIZE; ETA_unc = ETA_;

if SIZE <= ALPHA then goto K;

ALPHA1=0; SIZE1=0;
ALPHA2=ALPHA; NH=0;

ST: ALPHA0=(ALPHA1+ALPHA2)/2; NH=NH+1;
    U_AL0_C = probit(1-ALPHA0);
    do V=1 to N; KPR(V)=K(V); end;
    IND=0;

   do V=1 to N; U=V;
        T= 10;
        do while (U >= 1 and T > U_AL0_C);
        U=U-1;
        T=sqrt(N)*((2*U-V)/N + DEL0)/sqrt(V/N-((2*U-V)/N)**2);
        end;
    K(V)=U+1;
    IND=IND+sign(abs(K(V)-KPR(V)));
    end;


    if IND=0 and INDCS=1 then goto CS1;
    if IND=0 and INDCS=2 then goto CS2;


        SIZE=0;  eta_ = DEL0;
        eta= DEL0 + sw;

        do while (eta <= 1 -sw);
        pi_0 = 1/2-DEL0/(2*eta);


       REJ_=0;
          do V=1 to N;
          if K(V) = 0 then goto DD;
          REJ_V= 1-probbnml(PI_0,V,K(V)-1) ;
          goto VV;
          DD: REJ_V=1; goto VV;
          VV:PROBV=probbnml(ETA,N,V)-probbnml(ETA,N,V-1);
          REJ_=REJ_+REJ_V*PROBV;
          end;
        if SIZE >= REJ_ then goto ETA1;
        SIZE= REJ_; ETA_ = ETA;
        ETA1: eta= eta + sw;
        end;


            if SIZE >= ALPHA-TOL and SIZE <= ALPHA then goto K;
            if SIZE > ALPHA and NH < MAXH then goto CS1;
            if SIZE < ALPHA-TOL and NH < MAXH then goto CS2;
            if NH>=MAXH then goto A;

     CS1: ALPHA2=ALPHA0; INDCS=1; goto ST;
     CS2: ALPHA1=ALPHA0; SIZE1=SIZE; INDCS=2; goto ST;


A: ALPHA0=ALPHA1; SIZE0=SIZE1;

K: keep ALPHA ALPHA0 N DEL0 SIZE_unc ETA_unc SIZE0  SW NH;
run;

proc print noobs;
var ALPHA N DEL0 SW ALPHA0 SIZE0 SIZE_unc ;
format ALPHA0 SIZE0  E15.;
run;
%mend ;

%mcnasc_ni(.05, 50,.05,.0005,.0001, 10)
