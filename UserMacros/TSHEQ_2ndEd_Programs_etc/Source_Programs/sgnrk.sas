%macro sgnrk(ALPHA,N,QPL1,QPL2,PATH);
data;  ALPHA=&ALPHA; N= &N;
QPL1=&QPL1; QPL2=&QPL2;
QPLCT=(QPL1+QPL2)/2; EPS=(QPL2-QPL1)/2;
array D{250};
infile "&PATH" ;
do I=1 to N; input D{I} @; end;
  U=0;
  do I=1 to N-1; do J=I+1 to N;
   U= U + int(.5*(sign(D{I}+D{J})+1));
   end;end;
  ZETA=0;
  do I=1 to N-2; do J=I+1 to N-1; do K=J+1 to N;
  ZETA= ZETA + int(.5*(sign(min(D{I}+D{J},D{I}+D{K}))+1))
  + int(.5*(sign(min(D{J}+D{I},D{J}+D{K}))+1))
  + int(.5*(sign(min(D{K}+D{I},D{K}+D{J}))+1));
  end; end; end;
  U=U*2/N/(N-1);
  ZETA=ZETA*2/N/(N-1)/(N-2) - U**2;
  SIGMAH=sqrt( (4*(N-2)*ZETA +2*U*(1-U))/N/(N-1) );
  CRIT=sqrt(cinv(.05,1,(EPS/SIGMAH)**2));
  if abs((U-QPLCT)/SIGMAH) >= CRIT then REJ= 0;
  if abs((U-QPLCT)/SIGMAH) <  CRIT then REJ= 1;
  if SIGMAH=. or CRIT=. then REJ=0;
  keep ALPHA N QPL1 QPL2  U SIGMAH CRIT REJ;
  run;

  proc print noobs; var ALPHA N QPL1 QPL2 U SIGMAH CRIT REJ; run;
%mend sgnrk;

%sgnrk(.05,20,.2398,.7602, '<mydirectory>\Examples\ex5_4_sgnrk.raw')
