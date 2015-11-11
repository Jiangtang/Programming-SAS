alpha <- 0.05
n <- 20
qpl1 <- 0.2398
qpl2 <- 0.7602
qplct <- (qpl1+qpl2)/2
eps <- (qpl2-qpl1)/2

d <- scan("<mydirectory>/Examples/ex5_4_sgnrk.raw",what=numeric(n),nlines=20,multi.line=TRUE,skip=0)

u <- 0

for (i in 1:(n-1))
    for (j in (i+1):n)
       u <- u + trunc(0.5*(sign(d[i]+d[j])+1))

zeta <- 0

for (i in 1:(n-2))
    for (j in (i+1):(n-1))
        for (k in (j+1):n)
           zeta <- zeta + trunc(0.5*(sign(min(d[i]+d[j],d[i]+d[k])) + 1)) +
                          trunc(0.5*(sign(min(d[j]+d[i],d[j]+d[k])) + 1)) +
                          trunc(0.5*(sign(min(d[k]+d[i],d[k]+d[j])) + 1))

u <- u*2/n/(n-1)
zeta <- zeta*2/n/(n-1)/(n-2) - u**2
sigmah <- sqrt( (4*(n-2)*zeta + 2*u*(1-u) ) /n/(n-1) )
crit <- sqrt(qchisq(0.05,1,(eps/sigmah)**2))

if (abs((u-qplct)/sigmah) >= crit) rej <- 0    else
                                   rej <- 1
if (is.na(sigmah) || is.na(crit))  rej <- 0

cat(" ALPHA =",alpha,"  N =",n,"  QPL1_ =",qpl1,"  QPL2_ =",qpl2,
    "  U =",u,"  SIGMAH =",sigmah,"  CRIT =",crit,"  REJ =",rej)
