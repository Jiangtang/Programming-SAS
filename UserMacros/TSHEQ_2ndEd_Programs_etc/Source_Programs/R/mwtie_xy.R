alpha <- 0.05
m <- 204
n <- 258
eps1_ <- 0.10
eps2_ <- 0.10

eqctr <- 0.5 + (eps2_-eps1_)/2
eqleng <- eps1_+eps2_

x <- scan("<mydirectory>/Examples/expl_6_2.raw",what=numeric(m),nlines=6,multi.line=TRUE,skip=0)
y <- scan("<mydirectory>/Examples/expl_6_2.raw",what=numeric(m),nlines=7,multi.line=TRUE,skip=6)

wxy <- 0
pih0 <- 0
pihxyy0 <- 0
pihxyy1 <- 0
pihxyy2 <- 0
pihxxy0 <- 0
pihxxy1 <- 0
pihxxy2 <- 0

for (i in 1:m)
    for (j in 1:n)
       { pih0 <- pih0 + 1 - sign(abs(x[i]-y[j]))
         wxy <- wxy + trunc(0.5*(sign(x[i]-y[j])+1))
       }

for (i in 1:m)
    for (j1 in 1:(n-1))
        for (j2 in (j1+1):n)
           { pihxyy0 <- pihxyy0 + 1 - sign(max(abs(x[i]-y[j1]),abs(x[i]-y[j2])))
             pihxyy1 <- pihxyy1 + trunc(0.5*(sign(x[i]-max(y[j1],y[j2])) + 1))
             pihxyy2 <- pihxyy2 + trunc(0.5*(sign(x[i]-y[j1])+1)) * (1 - sign(abs(x[i]-y[j2])))
             pihxyy2 <- pihxyy2 + trunc(0.5*(sign(x[i]-y[j2])+1)) * (1 - sign(abs(x[i]-y[j1])))
           }

for (i1 in 1:(m-1))
    for (i2 in (i1+1):m)
        for (j in 1:n)
           { pihxxy0 <- pihxxy0 + 1 - sign(max(abs(x[i1]-y[j]),abs(x[i2]-y[j])))
             pihxxy1 <- pihxxy1 + trunc(0.5*(sign(min(x[i1],x[i2]) - y[j]) + 1))
             pihxxy2 <- pihxxy2 + trunc(0.5*(sign(x[i1]-y[j])+1)) * (1 - sign(abs(x[i2]-y[j])))
             pihxxy2 <- pihxxy2 + trunc(0.5*(sign(x[i2]-y[j])+1)) * (1 - sign(abs(x[i1]-y[j])))
           }

wxy <- wxy / (m*n)
pih0 <- pih0 / (m*n)
wxy_tie <- wxy/(1-pih0)
pihxxy0 <- pihxxy0*2/(m*(m-1)*n)
pihxyy0 <- pihxyy0*2/(n*(n-1)*m)
pihxxy1 <- pihxxy1*2/(m*(m-1)*n)
pihxyy1 <- pihxyy1*2/(n*(n-1)*m)
pihxxy2 <- pihxxy2/(m*(m-1)*n)
pihxyy2 <- pihxyy2/(n*(n-1)*m)

varhpih0 <- (pih0 - (m+n-1)*pih0**2 + (m-1)*pihxxy0 + (n-1)*pihxyy0) / (m*n)
varhgamh <- (wxy - (m+n-1)*wxy**2 + (m-1)*pihxxy1 + (n-1)*pihxyy1) / (m*n)
covh <- ((m-1)*pihxxy2 + (n-1)*pihxyy2 - (m+n-1)*wxy*pih0) / (m*n)
sigmah <- sqrt((1 - pih0)**(-2)*varhgamh + wxy**2*(1-pih0)**(-4)*varhpih0 +
               2*wxy*(1-pih0)**(-3)*covh)
crit <- sqrt(qchisq(alpha,1,(eqleng/2/sigmah)**2))

if (abs((wxy_tie-eqctr)/sigmah) >= crit) rej <- 0
if (abs((wxy_tie-eqctr)/sigmah) < crit) rej <- 1
if (is.na(sigmah) || is.na(crit)) rej <- 0

cat(" ALPHA =",alpha,"  M =",m,"  N =",n,"  EPS1_ =",eps1_,"  EPS2_ =",eps2_,
    "  WXY_TIE =",wxy_tie,"  SIGMAH =",sigmah,"  CRIT =",crit,"  REJ =",rej)  
         
