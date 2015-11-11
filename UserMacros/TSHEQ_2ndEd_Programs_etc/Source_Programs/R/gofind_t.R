alpha <- 0.05
r <- 2
s <- 4
eps <- 0.15

pih <- matrix(rep(NA,(r*s)),nrow=r)
pihrow <- rep(NA,r)
pihcol <- rep(NA,s)
gradh <- matrix(rep(NA,(r*s)),nrow=r)
covh <- array(rep(NA,(r*s*r*s)),dim=c(r,s,r,s))

xv <- scan("<mydirectory>/Examples/gofind_t.inp",what=numeric(8),nlines=1,multi.line=FALSE,skip=0)

x <- matrix(xv,nrow=2,byrow=TRUE)

n <- 0

for (i in 1:r)
    for (j in 1:s)
        n <- n + x[i,j]

for (i in 1:r)
    for (j in 1:s)
        pih[i,j] <- x[i,j] / n

for (i in 1:r)
   { pihrow[i] <- 0
     for (j in 1:s)
         pihrow[i] <- pihrow[i] + pih[i,j]
   }

for (j in 1:s)
   { pihcol[j] <- 0
     for (i in 1:r)
        pihcol[j] <- pihcol[j] + pih[i,j]
   }

dsq_obs <- 0

for (i in 1:r)
    for (j in 1:s)
       dsq_obs <- dsq_obs + (pih[i,j] - pihrow[i]*pihcol[j])**2

for (i1 in 1:r)
    for (j1 in 1:s)
        for (i2 in 1:r)
            for (j2 in 1:s)
               covh[i1,j1,i2,j2] <- -pih[i1,j1] * pih[i2,j2]

for (i in 1:r)
    for (j in 1:s)
        covh[i,j,i,j] <- pih[i,j] * (1-pih[i,j])

for (i in 1:r)
    for (j in 1:s)
       { sumj <- 0
         for (jj in 1:s)
            sumj <- sumj + (pih[i,jj]-pihrow[i]*pihcol[jj]) * pihcol[jj]
         sumi <- 0
         for (ii in 1:r)
            sumi <- sumi + (pih[ii,j]-pihrow[ii]*pihcol[j]) * pihrow[ii]
         gradh[i,j] <- 2*((pih[i,j] - pihrow[i]*pihcol[j]) - sumj - sumi)
       }

vnsq <- 0

for (i1 in 1:r)
    for (j1 in 1:s)
        for (i2 in 1:r)
            for (j2 in 1:s)
               vnsq <- vnsq + gradh[i1,j1]*covh[i1,j1,i2,j2]*gradh[i2,j2]

vn <- sqrt(vnsq)
crit <- eps**2 - qnorm(1-alpha)*vn/sqrt(n)
rej <- 0

if (is.na(dsq_obs) == FALSE && dsq_obs < crit) rej <- 1

cat(" N =",n,"  ALPHA =",alpha,"  EPS =",eps,"  R =",r,"  S =",s,"  X(r,s) :",
    x[1,],x[2,],"  DSQ_OBS =",dsq_obs,"  VN =",vn,"  CRIT =",crit,"  REJ =",rej)






