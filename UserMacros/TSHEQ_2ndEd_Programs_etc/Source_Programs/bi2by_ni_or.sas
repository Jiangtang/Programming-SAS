libname mvq  '<mydirectory>\Source_Programs\MVQ';

proc iml;

start posterior(N1,N2,EPS,NSUB);

use mvq.c;
read all var _num_ into C;
use mvq.g;
read all var _num_ into G;

RHO0 = 1-EPS;



ppost = J(N1+1,N2+1);

A= 0; B= 1;

do X=0 to N1; do Y= 0 to N2;

PROBPOST=0; JJ=1; do while (JJ <= NSUB);
AA=A+(JJ-1)*(B-A)/NSUB; BB=A+JJ*(B-A)/NSUB;
M=(AA+BB)/2; L=(BB-AA)/2;

      do J= 1 to 48;
      ITGDR=0; ITGDL=0;

      PI2_R= M+C[J]*L;
      PI2_R_TR= rho0*pi2_r/((1-pi2_r)+rho0*pi2_r);
      PP_PI2_R= 1- probbeta(PI2_R_TR,X+.5,N1-X+.5);
      DENS = pdf('beta', PI2_R,Y+.5,N2-Y+.5);
        if min(pp_pi2_r,dens) > 0 then do;
        ITGDRLOG  =log(dens)+log(pp_pi2_r) ;
        ITGDR= exp(ITGDRLOG);
        end;
      PI2_L=  M - C[J]*L;
      PI2_L_TR= rho0*pi2_l/((1-pi2_l)+rho0*pi2_l);
      PP_PI2_L= 1- probbeta(PI2_L_TR,X+.5,N1-X+.5);
      DENS = pdf('beta', pi2_l,y+.5,n2-y+.5);
        if min(pp_pi2_l,dens) > 0 then do;
        ITGDLLOG  =log(dens)+log(pp_pi2_l) ;
        ITGDL= exp(ITGDLLOG);
        end;
        PROBPOST= PROBPOST + G[J]*(ITGDR+ITGDL);
      end;
JJ=JJ+1; end;
PROBPOST=PROBPOST*L;

X_ = X+1; Y_ = Y+1;
ppost[X_,Y_] = PROBPOST;

end;end;
return(ppost);
finish posterior;


start XCRIT(N1,N2,ALPHA,PPOST);

KX_Y = J(N2+1,1);

do Y_ = 1 to N2+1;
   X_ = 1;
   do while (PPOST[X_,Y_] <= 1-ALPHA & X_ <= N1); X_ = X_+1; end;
KX_Y[Y_] = X_-1;
if KX_Y[Y_] = N1 & PPOST[N1+1,Y_] <= 1-ALPHA  then do;  KX_Y[Y_] = N1+1; end;
end;
return(KX_Y);
finish XCRIT;



start FINDSIZE(N1,N2,ALPHA, EPS,SW,KX_Y);

RHO0 = 1-EPS;  PBY = J(N2+1,1);

size=0; SIZE_ = 0; PI2_ = 0;

pi2=0;
do while (pi2 <= 1 -sw);
pi2=pi2+sw;

   PBY[1]=probbnml(pi2,N2,0);
   do Y_=2 to N2+1;
   Y = Y_-1;
   PBY[Y_]=probbnml(pi2,N2,Y) - probbnml(pi2,N2,Y-1) ;
   end;


   pi1=pi2*rho0/((1-pi2)+pi2*rho0);

   probrj=0;

   do Y_=1 to N2+1;
   Y = Y_-1;

   if KX_Y[Y_]=0 then  do;  PBXGEK_Y=1; end;
   if KX_Y[Y_]=N1+1 then do; PBXGEK_Y=0; end;
   if KX_Y[Y_] >= 1 & KX_Y[Y_] <= N1  then do;
          PBXGEK_Y=1-probbnml(pi1,n1,KX_Y[Y_]-1);
          end;

   PBYEQY=PBY[Y_];
   if min(PBXGEK_Y,PBYEQY) <= 0 then do; INCR = 0; end;
   if min(PBXGEK_Y,PBYEQY) > 0 then do;
        LPBX=log(PBXGEK_Y); LPBY=log(PBYEQY);
        INCR = exp(LPBX+LPBY); end;
   PROBRJ=PROBRJ+INCR;
   end;
   SIZE=max(SIZE_,PROBRJ);
if SIZE > SIZE_ then do ;
        SIZE_ = SIZE; PI2_ = pi2; end;
end;


RESULTS_SIZE = J(2,1); RESULTS_SIZE[1] = SIZE;  RESULTS_SIZE[2] = PI2_;

return(RESULTS_SIZE);
finish FINDSIZE;



N1= 10; N2=10; EPS = 1/3;  NSUB = 10; SW = .0005;

ppost= posterior(N1,N2,EPS,NSUB);


ALPHA = .05; MAXH = 12;

   KX_Y= XCRIT(N1,N2,ALPHA,PPOST);
   RES_SIZE = FINDSIZE(N1,N2,ALPHA, EPS,SW,KX_Y);
   SIZE_UNC = RES_SIZE[1];

if SIZE_UNC <= ALPHA then do;
                  print N1 N2 EPS ALPHA  NSUB SW SIZE_UNC;
                  STOP;
                  end;

ALPHA0 = ALPHA; SIZE = SIZE_UNC; P2_UNC = RES_SIZE[2];


do until (SIZE < ALPHA);
   ALPHA0 = ALPHA0 - .01;
   KX_Y= XCRIT(N1,N2,ALPHA0,PPOST);
   RES_SIZE = FINDSIZE(N1,N2,ALPHA0, EPS,SW,KX_Y);
   SIZE = RES_SIZE[1];
end;

ALPHA1 = ALPHA0; SIZE1 = SIZE;
ALPHA2 = ALPHA0 + .01;
IT = 0;
   do while(IT <= MAXH);
   ALPHA0=(ALPHA1+ALPHA2)/2; IT=IT+1;
   KX_Y= XCRIT(N1,N2,ALPHA0,PPOST);
   RES_SIZE = FINDSIZE(N1,N2,ALPHA0, EPS,SW,KX_Y);
   SIZE = RES_SIZE[1];
        if SIZE < ALPHA then do;
                ALPHA1 = ALPHA0; SIZE1 = SIZE;
                end;
        else ALPHA2 = ALPHA0;
   end;


ALPHA0=ALPHA1; SIZE0=SIZE1;

print N1 N2 EPS ALPHA NSUB SW ;
print ALPHA0 SIZE0 SIZE_UNC;




quit;
