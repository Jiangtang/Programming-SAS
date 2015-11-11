libname mvq  '<mydirectory>\Source_Programs\MVQ';

proc iml;

start ppost_singleobs(N,DEL0,N10,N01);

use mvq.c;
read all var _num_ into C;
use mvq.g;
read all var _num_ into G;

ppost = J(N+1,N+1);

A= DEL0; B= (1+DEL0)/2;

X1= N10; X2= N01 ;
K1= .5; K2 = .5; K3 = .5; NSUB = 10;

PROBPOST_ = probbeta(DEL0,X2+K2,N-X2+K1+K3);

PROBPOST=0; JJ=1; do while (JJ <= NSUB);
AA=A+(JJ-1)*(B-A)/NSUB; BB=A+JJ*(B-A)/NSUB;
M=(AA+BB)/2; L=(BB-AA)/2;

      do J= 1 to 48;
      ITGDR=0; ITGDL=0;
      pmiR=  M + C[J]*L;
      Q1= pmiR-DEL0;
      IQ1=probbeta(Q1/(1-pmiR),X1+K1,N-X1-X2+K3);
      IQ2= 1;
      IQ2_1= IQ2-IQ1;
      dens=pdf('beta', pmir,X2+K2,N-X2+K1+K3);
        if min(IQ2_1,dens) > 0 then do;
        ITGDRLOG  =log(dens)+log(IQ2_1) ;
        ITGDR= exp(ITGDRLOG);
        end;
        pmiL=  M - C[J]*L;
      Q1= pmiL-DEL0;
      IQ1=probbeta(Q1/(1-pmiL),X1+K1,N-X1-X2+K3);
      IQ2= 1;
      IQ2_1= IQ2-IQ1;
      dens=pdf('beta', pmiL,X2+K2,N-X2+K1+K3);
        if min(IQ2_1,dens) > 0 then do;
        ITGDLLOG  =log(dens)+log(IQ2_1) ;
        ITGDL= exp(ITGDLLOG);
        end;
        PROBPOST= PROBPOST + G[J]*(ITGDR+ITGDL);
      end;
JJ=JJ+1; end;
PROBPOST=PROBPOST*L+PROBPOST_;

ppost = PROBPOST;

return(ppost);
finish ppost_singleobs;


N= 72; DEL0 = 0.05;  N10 = 4; N01 = 5;

ppost= ppost_singleobs(N,DEL0,N10,N01);

print N  DEL0 N10 N01 ;
print ppost;
quit;
