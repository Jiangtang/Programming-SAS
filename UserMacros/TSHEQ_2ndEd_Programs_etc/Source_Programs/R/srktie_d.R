n <- 24
alpha <- 0.05
eps1 <- 0.2602
eps2 <- 0.2602

d <- scan("<mydirectory>/Examples/expl5_5_srktie.raw",what=numeric(n),nlines=2,multi.line=TRUE,skip=0)

u_pl <- 0
for (i in 1:(n-1))
    for (j in (i+1):n)
       u_pl <- u_pl + trunc(0.5*(sign(d[i]+d[j]) + 1))

u_pl <- u_pl*2/n/(n-1)

u_0 <- 0
for (i in 1:(n-1))
    for (j in (i+1):n)
       u_0 <- u_0 + 1 - (sign(abs(d[i]+d[j])))

u_0 <- u_0*2/n/(n-1)

qh_pl <- 0
for (i in 1:(n-2))
    for (j in (i+1):(n-1))
        for (k in (j+1):n)
            qh_pl <- qh_pl + trunc(0.5*(sign(min(d[i]+d[j],d[i]+d[k])) + 1)) +
                     trunc(0.5*(sign(min(d[j]+d[i],d[j]+d[k])) + 1)) +
                     trunc(0.5*(sign(min(d[k]+d[i],d[k]+d[j])) + 1))

qh_pl <- qh_pl*2/n/(n-1)/(n-2)
       
qh_0 <- 0
for (i in 1:(n-2))
    for (j in (i+1):(n-1))
        for (k in (j+1):n)
            qh_0 <- qh_0 + 1 - sign(max(abs(d[i]+d[j]),abs(d[i]+d[k]))) +
                           1 - sign(max(abs(d[i]+d[j]),abs(d[j]+d[k]))) +
                           1 - sign(max(abs(d[i]+d[k]),abs(d[j]+d[k])))

qh_0 <- qh_0*2/n/(n-1)/(n-2)

qh_0pl <- 0
for (i in 1:(n-2))
    for (j in (i+1):(n-1))
        for (k in (j+1):n)
            qh_0pl <- qh_0pl + trunc(0.5*(sign(d[i]+d[j])+1)) * (1-sign(abs(d[i]+d[k]))) +
                               trunc(0.5*(sign(d[i]+d[j])+1)) * (1-sign(abs(d[j]+d[k]))) +
                               trunc(0.5*(sign(d[i]+d[k])+1)) * (1-sign(abs(d[j]+d[k]))) +
                               trunc(0.5*(sign(d[i]+d[k])+1)) * (1-sign(abs(d[i]+d[j]))) +
                               trunc(0.5*(sign(d[j]+d[k])+1)) * (1-sign(abs(d[i]+d[j]))) +
                               trunc(0.5*(sign(d[j]+d[k])+1)) * (1-sign(abs(d[i]+d[k])))

qh_0pl <- qh_0pl/n/(n-1)/(n-2)

ssq_pl <- (4*(n-2)/(n-1)) * (qh_pl-u_pl**2) + (2/(n-1))*u_pl*(1-u_pl)
ssq_0 <- (4*(n-2)/(n-1)) * (qh_0-u_0**2) + (2/(n-1))*u_0*(1-u_0)
ss_0pl <- (4*(n-2)/(n-1)) * (qh_0pl-u_0*u_pl) + (2/(n-1))*u_0*u_pl

tauhsqas <- ssq_pl/(1-u_0)**2 + u_pl**2*ssq_0/(1-u_0)**3 + 2*u_pl*ss_0pl/(1-u_0)**3
uas_pl <- u_pl/(1-u_0)
eqctr <- (1-eps1+eps2)/2
tauhas <- sqrt(tauhsqas)

crit <- sqrt(qchisq(alpha,1,n*(eps1+eps2)**2/4/tauhsqas))
if (sqrt(n)*abs((uas_pl-eqctr)/tauhas) >= crit) rej <- 0
if (sqrt(n)*abs((uas_pl-eqctr)/tauhas) < crit) rej <- 1
if (is.na(tauhas) || is.na(crit)) rej <- 0

cat("  N =",n," ALPHA =",alpha,"  EPS1 =",eps1,"  EPS2 =",eps2,
    "  U_PL =",u_pl,"  U_0 =",u_0,"  UAS_PL =",uas_pl,"  TAUHAS =",tauhas,
    "  CRIT =",crit,"  REJ =",rej)
