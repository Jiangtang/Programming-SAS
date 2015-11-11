proc iml;

X1 = 34; X2= 118; X3 = 96;
alpha = .05;
print X1 X2 X3  alpha;

SW = .1; TOL = 10**(-4); ITMAX = 25;


start asympt_confbs(X1,X2,X3,alpha);
n=X1+X2+X3;
ConfAsy = J(1,3);
pi1h = X1/n; pi2h = X2/n; pi3h = X3/n;
thet_h = pi2h**2/(pi1h*pi3h);
stderr= sqrt((1/n)*((1-pi2h)/(pi1h*pi3h) + 4/pi2h));
om_h = sqrt(thet_h)/2;
C_l = log(thet_h) - probit(1-alpha)*stderr;
C_r = log(thet_h) + probit(1-alpha)*stderr;
C_l_scaled = exp(.5*(C_l - log(4)));
C_r_scaled = exp(.5*(C_r - log(4)));
goto S1;
S1: ConfAsy[1,1] = C_l_scaled; ConfAsy[1,2] = om_h;
ConfAsy[1,3] = C_r_scaled;
return(ConfAsy);
finish;


start ex_prob_ge(X1,X2,X3,thet);
S = 2*X1 + X2; n=X1+X2+X3;
NB=int(S/2)-max(0,S-N)+1;

B = J(1,NB);  PRB = J(1,NB);

do K=1 to NB; B[1,K] =S-2*int(S/2)+2*(K-1); end;

K=1; do while (B[1,K] <= X2); K=K+1; end;
KX2= K-1;


   K = 1;
        CL=lgamma(N+1)-lgamma((S-B[1,K])/2+1) -lgamma(B[1,K]+1) -
           lgamma(N-B[1,K]/2- S/2+1);
        ARGEXP_U = CL+(B[1,K]/2)*log(THET);

        do K=2 to NB;
        CL=lgamma(N+1)-lgamma((S-B[1,K])/2+1) -lgamma(B[1,K]+1) -
           lgamma(N-B[1,K]/2- S/2+1);
        ARGEXP_U = max(ARGEXP_U,  CL+(B[1,K]/2)*log(THET));
        end;

        SHIFTL = min(0 , 700 - ARGEXP_U);

        do K=1 to NB;
        CL=lgamma(N+1)-lgamma((S-B[1,K])/2+1) -lgamma(B[1,K]+1) -
           lgamma(N-B[1,K]/2- S/2+1);


        PRB[1,K]= exp(CL+(B[1,K]/2)*log(THET) + SHIFTL);

        end;

      do K=2 to NB;
      PRB[1,K]= PRB[1,K]+PRB[1,K-1];
      end;

      do K=1 to NB;
      PRB[1,K]=PRB[1,K]/PRB[1,NB];
      end;

prob_ge = 1- PRB[1,KX2-1];

return(prob_ge);
finish;

start ex_prob_le(X1,X2,X3,thet);
S = 2*X1 + X2; n=X1+X2+X3;
NB=int(S/2)-max(0,S-N)+1;

B = J(1,NB);  PRB = J(1,NB);

do K=1 to NB; B[1,K] =S-2*int(S/2)+2*(K-1); end;

K=1; do while (B[1,K] <= X2); K=K+1; end;
KX2= K-1;


   K = 1;
        CL=lgamma(N+1)-lgamma((S-B[1,K])/2+1) -lgamma(B[1,K]+1) -
           lgamma(N-B[1,K]/2- S/2+1);
        ARGEXP_U = CL+(B[1,K]/2)*log(THET);

        do K=2 to NB;
        CL=lgamma(N+1)-lgamma((S-B[1,K])/2+1) -lgamma(B[1,K]+1) -
           lgamma(N-B[1,K]/2- S/2+1);
        ARGEXP_U = max(ARGEXP_U,  CL+(B[1,K]/2)*log(THET));
        end;

        SHIFTL = min(0 , 700 - ARGEXP_U);

        do K=1 to NB;
        CL=lgamma(N+1)-lgamma((S-B[1,K])/2+1) -lgamma(B[1,K]+1) -
           lgamma(N-B[1,K]/2- S/2+1);


        PRB[1,K]= exp(CL+(B[1,K]/2)*log(THET) + SHIFTL);

        end;

      do K=2 to NB;
      PRB[1,K]= PRB[1,K]+PRB[1,K-1];
      end;

      do K=1 to NB;
      PRB[1,K]=PRB[1,K]/PRB[1,NB];
      end;

prob_le = PRB[1,KX2];

return(prob_le);
finish;

start exact_confb_l(X1,X2,X3,alpha, SW, TOL, ITMAX, thet0);
thet= thet0; IT = 0;
prob_ge = ex_prob_ge(X1,X2,X3, thet);

if (prob_ge < alpha) then goto S1;
if (prob_ge > alpha) then goto S2;
else goto S9;

S1: do while (prob_ge < alpha); thet = thet + sw;
    prob_ge = ex_prob_ge(X1,X2,X3, thet); end;
    thet1 = thet-SW; thet2 = thet; goto S0;
S2: do while (prob_ge > alpha); thet = thet - sw;
    prob_ge = ex_prob_ge(X1,X2,X3, thet); end;
    thet1 = thet; thet2 = thet+SW; goto S0;

S0: thet = (thet1+thet2)/2; IT = IT+1;
    prob_ge = ex_prob_ge(X1,X2,X3, thet);

if (prob_ge < alpha -TOL) & (IT < ITMAX) then goto A;
if (prob_ge > alpha +TOL) & (IT < ITMAX) then goto B;
else goto C;

A: thet1 = thet; goto S0;
B: thet2 = thet; goto S0;
C: thet = (thet1+thet2)/2;

S9: C_l_exact = sqrt(thet)/2;   prob_ge = ex_prob_ge(X1,X2,X3, thet);

exactres_l = J(1,3);
exactres_l[1,1] = C_l_exact;
exactres_l[1,2] = prob_ge;
exactres_l[1,3] = it;

return(exactres_l);
finish;

start exact_confb_r(X1,X2,X3,alpha, SW, TOL, ITMAX, thet0);
thet= thet0; IT = 0;
prob_le = ex_prob_le(X1,X2,X3, thet);

if (prob_le < alpha) then goto S1;
if (prob_le > alpha) then goto S2;
else goto S9;

S1: do while (prob_le < alpha); thet = thet - sw;
    prob_le = ex_prob_le(X1,X2,X3, thet); end;
    thet1 = thet; thet2 = thet+SW; goto S0;
S2: do while (prob_le > alpha); thet = thet + sw;
    prob_le = ex_prob_le(X1,X2,X3, thet); end;
    thet1 = thet-SW; thet2 = thet; goto S0;

S0: thet = (thet1+thet2)/2; IT = IT+1;
    prob_le = ex_prob_le(X1,X2,X3, thet);

if (prob_le < alpha -TOL) & (IT < ITMAX) then goto A;
if (prob_le > alpha +TOL) & (IT < ITMAX) then goto B;
else goto C;

A: thet2 = thet; goto S0;
B: thet1 = thet; goto S0;
C: thet = (thet1+thet2)/2;

S9: C_r_exact = sqrt(thet)/2;   prob_le = ex_prob_le(X1,X2,X3, thet);

exactres_r = J(1,3);
exactres_r[1,1] = C_r_exact;
exactres_r[1,2] = prob_le;
exactres_r[1,3] = it;

return(exactres_r);
finish;



ConfAsy = asympt_confbs(X1,X2,X3,alpha);


thet0 = 4*ConfAsy[1,1]**2;
exactres_l =  exact_confb_l(X1,X2,X3,alpha,  SW,TOL,ITMAX, thet0);
C_l_exact = exactres_l[1,1];
prob_ge = exactres_l[1,2];
IT = exactres_l[1,3];
print C_l_exact ;

thet0 = 4*ConfAsy[1,3]**2;
exactres_r =  exact_confb_r(X1,X2,X3,alpha,  SW,TOL,ITMAX, thet0);
C_r_exact = exactres_r[1,1];
prob_le = exactres_r[1,2];
IT = exactres_r[1,3];
print C_r_exact ;



quit;
