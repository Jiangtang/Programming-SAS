proc iml;

start teststat(N1,N2,EPS);
testeps = J(N1+1,N2+1);
testeps[1,1] = 0;
testeps[N1+1,N2+1] = 10;

Y=0;
    do X=1 to N1-1;
    T=((X/N1-Y/N2)+EPS)/sqrt((1/N1)*(X/N1)*(1-X/N1)+
                             (1/N2)*(Y/N2)*(1-Y/N2));
    testeps[X+1,Y+1] = T;
    end;
    testeps[N1+1,Y+1] = 10;
do Y=1 to N2-1;
    do X=0 to N1;
    T=((X/N1-Y/N2)+EPS)/sqrt((1/N1)*(X/N1)*(1-X/N1)+
                             (1/N2)*(Y/N2)*(1-Y/N2));
    testeps[X+1,Y+1] = T;
    end;
end;
Y=N2;
    testeps[1,Y+1] = -10;
    do X=1 to N1-1;
    T=((X/N1-Y/N2)+EPS)/sqrt((1/N1)*(X/N1)*(1-X/N1)+
                             (1/N2)*(Y/N2)*(1-Y/N2));
    testeps[X+1,Y+1] = T;
    end;

return(testeps);
finish teststat;


start XCRIT(N1,N2,ALPHA,TEPS);
U_ALC = probit(1-ALPHA);

KX_Y = J(N2+1,1);

do Y_ = 1 to N2+1;
   X_ = 1;
   do while (TEPS[X_,Y_] < U_ALC & X_ <= N1); X_ = X_+1; end;
KX_Y[Y_] = X_-1;
if KX_Y[Y_] = N1 & TEPS[N1+1,Y_] > U_ALC  then do;  KX_Y[Y_] = N1+1; end;
end;
return(KX_Y);
finish XCRIT;



start FINDSIZE(N1,N2,ALPHA, EPS,SW,KX_Y);

PBY = J(N2+1,1);

size=0; SIZE_ = 0; PI2_ = 0;

pi2=eps;
do while (pi2 <= 1-sw);
pi2=pi2+sw;

   PBY[1]=probbnml(pi2,N2,0);
   do Y_=2 to N2+1;
   Y = Y_-1;
   PBY[Y_]=probbnml(pi2,N2,Y) - probbnml(pi2,N2,Y-1) ;
   end;


   pi1=pi2-eps;

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



N1= 25; N2=25; EPS = .10;  SW = .0001;

TEPS= teststat(N1,N2,EPS);


ALPHA = .05; MAXH = 10;

   KX_Y= XCRIT(N1,N2,ALPHA,TEPS);
   RES_SIZE = FINDSIZE(N1,N2,ALPHA, EPS,SW,KX_Y);
   SIZE_UNC = RES_SIZE[1];


if SIZE_UNC <= ALPHA then do;
                  print N1 N2 EPS ALPHA  NSUB SW SIZE_UNC;
                  STOP;
                  end;

ALPHA0 = ALPHA; SIZE = SIZE_UNC; P2_UNC = RES_SIZE[2];



do until (SIZE < ALPHA);
 ALPHA0 = ALPHA0 - .01;
 * ALPHA0 = ALPHA0 - .001;
   KX_Y= XCRIT(N1,N2,ALPHA0,TEPS);
   RES_SIZE = FINDSIZE(N1,N2,ALPHA0, EPS,SW,KX_Y);
   SIZE = RES_SIZE[1];
end;

ALPHA1 = ALPHA0; SIZE1 = SIZE;
ALPHA2 = ALPHA0 + .01;
* ALPHA2 = ALPHA0 + .001;


IT = 0;
   do while(IT <= MAXH);
   ALPHA0=(ALPHA1+ALPHA2)/2; IT=IT+1;
   KX_Y= XCRIT(N1,N2,ALPHA0,TEPS);
   RES_SIZE = FINDSIZE(N1,N2,ALPHA0, EPS,SW,KX_Y);
   SIZE = RES_SIZE[1];
        if SIZE < ALPHA then do;
                ALPHA1 = ALPHA0; SIZE1 = SIZE;
               end;
        else ALPHA2 = ALPHA0;
   end;


ALPHA0=ALPHA1; SIZE0=SIZE1;



KX_Y_final =  XCRIT(N1,N2,ALPHA0,TEPS);
U_ALC = probit(1-ALPHA0);
  ERR_IND = 0;
     do Y_ = 1 to N2+1;
     do X_ = KX_Y_final[Y_]+1 to N1+1  ;
     if TEPS[X_,Y_]  <= U_ALC  then do; ERR_IND = 1; end;
  end;
end;



print N1 N2 EPS ALPHA SW ;
print ALPHA0 SIZE0 SIZE_UNC  ERR_IND;


quit;
