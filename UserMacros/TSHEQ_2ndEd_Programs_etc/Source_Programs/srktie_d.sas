%MACRO srktie_d(N,ALPHA,EPS1,EPS2,PATH);
data data0;
infile "&PATH";
array D{&N};

ALPHA=&ALPHA; N=&N; EPS1=&EPS1; EPS2=&EPS2;

do I=1 to &N; input D{I} @; end;

  U_PL=0;
  do I=1 to N-1; do J=I+1 to N;
   U_PL= U_PL+ int(.5*(sign(D{I}+D{J})+1));
   end;end;
  U_PL=U_PL*2/N/(N-1);

  U_0=0;
  do I=1 to N-1; do J=I+1 to N;
   U_0= U_0+ 1-(sign(abs(D{I}+D{J})));
   end;end;
  U_0=U_0*2/N/(N-1);


  QH_PL=0;
  do I=1 to N-2; do J=I+1 to N-1; do K=J+1 to N;
  QH_PL= QH_PL + int(.5*(sign(min(D{I}+D{J},D{I}+D{K}))+1))
  + int(.5*(sign(min(D{J}+D{I},D{J}+D{K}))+1))
  + int(.5*(sign(min(D{K}+D{I},D{K}+D{J}))+1));
  end; end; end;
  QH_PL=QH_PL*2/N/(N-1)/(N-2);

  QH_0=0;
  do I=1 to N-2; do J=I+1 to N-1; do K=J+1 to N;
  QH_0= QH_0 + 1 -sign(max(abs(D{I}+D{J}),abs(D{I}+D{K})))
  +  1 -sign(max(abs(D{I}+D{J}),abs(D{J}+D{K})))
  +  1 -sign(max(abs(D{I}+D{K}),abs(D{J}+D{K}))) ;
  end; end; end;
  QH_0=QH_0*2/N/(N-1)/(N-2);


  QH_0PL=0;
  do I=1 to N-2; do J=I+1 to N-1; do K=J+1 to N;
  QH_0PL= QH_0PL + int(.5*(sign(D{I}+D{J})+1))*(1 -sign(abs(D{I}+D{K})))
  + int(.5*(sign(D{I}+D{J})+1))*(1 -sign(abs(D{J}+D{K})))
  + int(.5*(sign(D{I}+D{K})+1))*(1 -sign(abs(D{J}+D{K})))
  + int(.5*(sign(D{I}+D{K})+1))*(1 -sign(abs(D{I}+D{J})))
  + int(.5*(sign(D{J}+D{K})+1))*(1 -sign(abs(D{I}+D{J})))
  + int(.5*(sign(D{J}+D{K})+1))*(1 -sign(abs(D{I}+D{K})));
  end; end; end;
  QH_0PL=QH_0PL/N/(N-1)/(N-2);



SSQ_PL = (4*(N-2)/(N-1))*(QH_PL-U_PL**2) + (2/(N-1))*U_PL*(1-U_PL);
SSQ_0  = (4*(N-2)/(N-1))*(QH_0-U_0**2) + (2/(N-1))*U_0*(1-U_0);
SS_0PL = (4*(N-2)/(N-1))*(QH_0PL-U_0*U_PL) + (2/(N-1))*U_0*U_PL;

TAUHSQAS= SSQ_PL/(1-U_0)**2 + U_PL**2*SSQ_0/(1-U_0)**3
          + 2*U_PL*SS_0PL/(1-U_0)**3;

UAS_PL=U_PL/(1-U_0);
EQCTR=(1-EPS1+EPS2)/2;
TAUHAS=sqrt(TAUHSQAS);

CRIT=sqrt(cinv(ALPHA,1,N*(EPS1+EPS2)**2/4/TAUHSQAS));
  if sqrt(N)*abs((UAS_PL -EQCTR)/TAUHAS) >= CRIT then REJ= 0;
  if sqrt(N)*abs((UAS_PL -EQCTR)/TAUHAS) < CRIT then REJ= 1;
  if TAUHAS=. or CRIT=. then REJ=0;

proc print noobs; var N ALPHA EPS1 EPS2
U_PL U_0 UAS_PL TAUHAS CRIT REJ;
run;
%mend srktie_d;

%srktie_d(24,.05,.2602,.2602, '<mydirectory>\Examples\expl5_5_srktie.raw')
