libname mvq  '<mydirectory>\Source_Programs\MVQ';

proc iml;

start posterior(N,DEL0,K1,K2,K3,NSUB);

use mvq.c;
read all var _num_ into C;
use mvq.g;
read all var _num_ into G;

ppost = J(N+1,N+1);

A= DEL0; B= (1+DEL0)/2;

do X1=0 to N; do X2= 0 to N-X1;

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

Npl_ = X1+1; N0_ = N-X1-X2+1;
ppost[N0_,Npl_] = PROBPOST;

end;end;
return(ppost);
finish posterior;


start NPLCRIT(N,ALPHA,PPOST);

NPL_N0 = J(N+1,1);

do N0_ = 1 to N+1;
   NPL_ = 1;
   do while (PPOST[N0_,NPL_] <= 1-ALPHA); NPL_ = NPL_+1; end;
NPL_N0[N0_] = NPL_-1;
end;
return(NPL_N0);
finish NPLCRIT;



start FINDSIZE(N,ALPHA, DEL0,SW,NPL_N0);

SIZE=0; SIZE_ = 0; eta_ = DEL0;

PBN0 = J(N+1,1);

eta= DEL0 + SW;
do while (eta <= 1 -SW);
p0 = 1-eta;
pi_0 = 1/2-DEL0/(2*eta);

   PBN0[1]=probbnml(p0,N,0);
   do N0_=2 to N+1;
   PBN0[N0_] =probbnml(p0,N,N0_-1) - probbnml(p0,N,N0_-2) ;
   end;


  PROBRJ=0;

   do N0_= 1 to N;
        if NPL_n0[N0_] <= N+1-N0_ then
                do ;
                if NPL_n0[N0_] =0 then PBNplGEK_n0=1;
                else PBNplGEK_n0=1-probbnml(pi_0,N+1-N0_,NPL_n0[N0_]-1);
                PBN0EQn0=PBn0[N0_];

                        if min(PBNplGEK_n0,PBN0EQn0) > 0 then do;
                        LPBNpl=log(PBNplGEK_n0); LPBn0=log(PBN0EQn0);
                        probrj=probrj+exp(LPBNpl+LPBn0);
                        end;
                end;
   end;
   SIZE=max(SIZE_,PROBRJ);
   if SIZE > SIZE_ then do ;
        SIZE_ = SIZE; ETA_ = ETA; end;
   eta= eta + SW;
end;

RESULTS_SIZE = J(2,1); RESULTS_SIZE[1] = SIZE;  RESULTS_SIZE[2] = ETA_;

return(RESULTS_SIZE);
finish FINDSIZE;



start POW_NULLALT(N,ETA,NPL_N0);

PBN0 = J(N+1,1);
k = nrow(ETA);   POW = J(1,k);

do j = 1 to k;


   eta_ = ETA[j];  PI=1/2; p0 = 1-eta_;

   PBN0[1]=probbnml(p0,N,0);
   do N0_=2 to N+1;
   PBN0[N0_] =probbnml(p0,N,N0_-1) - probbnml(p0,N,N0_-2) ;
   end;


  PROBRJ=0;

   do N0_= 1 to N;
        if NPL_n0[N0_] <= N+1-N0_ then
                do ;
                if NPL_n0[N0_] =0 then PBNplGEK_n0=1;
                else PBNplGEK_n0=1-probbnml(pi,N+1-N0_,NPL_n0[N0_]-1);
                PBN0EQn0=PBn0[N0_];

                        if min(PBNplGEK_n0,PBN0EQn0) > 0 then do;
                        LPBNpl=log(PBNplGEK_n0); LPBn0=log(PBN0EQn0);
                        PROBRJ=PROBRJ+exp(LPBNpl+LPBn0);
                        end;
                end;
   end;

 POW[j] = PROBRJ;
end;

return(POW);
finish POW_NULLALT;




N= 50; DEL0 = 0.10;  K1= .5; K2= .5; K3=.5; NSUB = 10; SW = .0005;

ppost= posterior(N,DEL0,K1,K2,K3,NSUB);



ALPHA = .05; MAXH = 10;

   NPL_N0= NPLCRIT(N,ALPHA,PPOST);
   RES_SIZE = FINDSIZE(N,ALPHA, DEL0,SW,NPL_N0);
   SIZE_UNC = RES_SIZE[1];

if SIZE_UNC <= ALPHA then do;
                  print N DEL0 ALPHA K1 K2 K3 NSUB SW;
                  STOP;
                  end;

ALPHA0 = ALPHA; SIZE = SIZE_UNC; ETA_UNC = RES_SIZE[2];

do until (SIZE < ALPHA);
   ALPHA0 = ALPHA0 - .01;
   NPL_N0= NPLCRIT(N,ALPHA0,PPOST);
   RES_SIZE = FINDSIZE(N,ALPHA0, DEL0,SW,NPL_N0);
   SIZE = RES_SIZE[1];
end;

ALPHA1 = ALPHA0; SIZE1 = SIZE;
ALPHA2 = ALPHA0 + .01;
IT = 0;
   do while(IT <= MAXH);
   ALPHA0=(ALPHA1+ALPHA2)/2; IT=IT+1;
   NPL_N0= NPLCRIT(N,ALPHA0,PPOST);
   RES_SIZE = FINDSIZE(N,ALPHA0, DEL0,SW,NPL_N0);
   SIZE = RES_SIZE[1];
        if SIZE < ALPHA then do;
                ALPHA1 = ALPHA0; SIZE1 = SIZE;
                end;
        else ALPHA2 = ALPHA0;
   end;


ALPHA0=ALPHA1; SIZE0=SIZE1;

print N DEL0 ALPHA K1 K2 K3 NSUB SW;
print ALPHA0 SIZE0 SIZE_UNC;


NPL_N0= NPLCRIT(N,ALPHA0,PPOST);
ETA = J(7,1);
ETA[1]= .0002; ETA[2]= .002; ETA[3]= .02; ETA[4]= .2;
ETA[5]= .3; ETA[6]= .5; ETA[7]= .8;

POW = POW_NULLALT(N,ETA,NPL_N0);
print POW;

quit;
