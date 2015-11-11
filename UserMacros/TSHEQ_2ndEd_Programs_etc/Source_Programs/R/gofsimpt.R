alpha <- 0.05
n <- 100
k <- 6
eps <- 0.15

pih <- rep(NA,k)

x <- scan("<mydirectory>/Examples/expl_9_1.inp",what=numeric(6),nlines=1,multi.line=FALSE,skip=0)
pio <- scan("<mydirectory>/Examples/expl_9_1.inp",what=numeric(6),nlines=1,multi.line=FALSE,skip=1)

for (J in 1:k) pih[J] <- x[J] / n

dsqpih_0 <- 0
vnsq_1 <- 0

for (J in 1:k)
   { dsqpih_0 <- dsqpih_0 + (pih[J] - pio[J])**2
     vnsq_1 <- vnsq_1 + (pih[J] - pio[J])**2 * pih[J]
   }

vnsq_2 <- 0

for (J1 in 1:k)
    for (J2 in 1:k)
        vnsq_2 <- vnsq_2 + (pih[J1]-pio[J1])*(pih[J2]-pio[J2])*pih[J1]*pih[J2]

vnsq <- (4/n) * (vnsq_1 - vnsq_2)
vn_n <- sqrt(vnsq)
epsaksq <- eps**2
crit <- epsaksq - qnorm(1-alpha)*vn_n
rej <- 0

if (is.na(dsqpih_0) == FALSE && dsqpih_0 < crit)  rej <- 1

cat(" ALPHA =",alpha,"  EPS =",eps,"  N =",n,"   X(1,K) =",x,"  PIO(1,K) =",pio,
    "   DSQPIH_0 =",dsqpih_0,"  VN_N =",vn_n,"  CRIT =",crit,"  REJ =",rej)

 

