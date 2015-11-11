w <- 0.1
n <- 24
alpha <- 0.05
eps1 <- 0.2602
eps2 <- 0.2602

d <- scan("<mydirectory>/Examples/expl5_5_srktie.raw",what=numeric(n),nlines=2,multi.line=TRUE,skip=0)

dmin <- min(d)
dmax <- max(d)
wr <- max(abs(dmin),abs(dmax))
r <- wr/w
vs <- r+1                          

m <-rep(NA,2*r+1)

for (k in -r:r)
   {
    dk <- k*w
    m[k+vs] <- 0
    for (i in 1:n)
        if (abs(d[i]-dk) < 10**(-10)) m[k+vs] = m[k+vs] + 1
   }


smp0 <- 0
for (k in 1:r)
    smp0 <- smp0 + m[k+vs] * m[-k+vs]

smp0_1 <- 0
for (k in 1:r)
    smp0_1 <- smp0_1 + m[k+vs] * (m[-k+vs]+m[0+vs])

smp0_2 <- 0
for (k in -r:r)
    smp0_2 <- smp0_2 + m[k+vs] * m[-k+vs]**2

smp1 <- 0
for (k in 1:r)
    for (l in (-k+1):(k-1))
        smp1 <- smp1 + m[k+vs] * m[l+vs]

smq <- 0
for (k in 1:r)
    smq <- smq + m[k+vs]**2

sm <- 0
for (k in 1:r)
    sm <- sm + m[k+vs]

smpq <- 0
smp0pl <- 0

for (k in (-r+1):r)
    { sm_k <- 0
      for (l in (-k+1):r)
          sm_k <- sm_k + m[l+vs]
      smpq <- smpq + m[k+vs] * sm_k**2
      smp0pl <- smp0pl + m[k+vs]*m[-k+vs]*sm_k
     }

smp2 <- 0
for (k in 1:r)
    for (l in (-k+1):r)
        smp2 <- smp2 + m[k+vs]*m[l+vs]

u_pl <- (2*smp1+smq-sm) / (n*(n-1))
u_0 <- (2*smp0+m[0+vs]*(m[0+vs]-1)) / (n*(n-1))
qh_pl <- (smpq - 2*smp1 - smq + 2*sm - 2*smp2) / (n*(n-1) * (n-2))
qh_0 <- (smp0_2 - 2*smp0 - 3*m[0+vs]**2 + 2*m[0+vs]) / (n*(n-1)*(n-2))
qh_0pl <- (smp0pl - smp0 - sm*m[0+vs]) / (n*(n-1)*(n-2))
ssq_pl <- (4*(n-2)/(n-1)) * (qh_pl-u_pl**2) + (2/(n-1)) * u_pl * (1-u_pl)
ssq_0 <- (4*(n-2)/(n-1)) * (qh_0-u_0**2) + (2/(n-1)) * u_0 * (1-u_0)
ss_0pl <- (4*(n-2)/(n-1)) * (qh_0pl-u_0*u_pl) + (2/(n-1)) * u_0 * u_pl

tauhsqas <- ssq_pl/(1-u_0)**2 + u_pl**2 * ssq_0/(1-u_0)**3 +
            2*u_pl*ss_0pl / (1-u_0)**3

uas_pl <- u_pl / (1-u_0)
eqctr <- (1-eps1+eps2) / 2
tauhas <- sqrt(tauhsqas)

crit <- sqrt(qchisq(alpha,1,n*(eps1+eps2)**2/4/tauhsqas))
if (sqrt(n)*abs((uas_pl-eqctr)/tauhas) >= crit) rej <- 0
if (sqrt(n)*abs((uas_pl-eqctr)/tauhas) < crit)  rej <- 1
if (is.na(tauhas) || is.na(crit)) rej <- 0

cat("  N =",n," ALPHA =",alpha,"  EPS1 =",eps1,"  EPS2 =",eps2,
    "  U_PL =",u_pl,"  U_0 =",u_0,"  UAS_PL =",uas_pl,"  TAUHAS =",tauhas,
    "  CRIT =",crit,"  REJ =",rej)
