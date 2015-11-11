alpha <- 0.05
n <- 133
s <- 65
del0 <- 1-1/1.96

nb <- trunc(s/2) - max(0,s-n) + 1
thet <- (1-del0)*4

b <- rep(NA,nb)
prb <- rep(NA,nb)
prb_gt <- rep(NA,nb+1)

for (k in 1:nb)
   b[k] <- s-2*trunc(s/2) + 2*(k-1)

bhw <- s*(1-s/(2*n))

if (nb == 1)                                       
  { kc <- 1
    c <- b[1]
    gam <- alpha
  }                 else
  { k <- 1
    while (b[k] <= bhw)
         k <- k+1
    k1 <- min(k+1,nb)

    k <- 1
    cl <- lgamma(n+1) - lgamma((s-b[k])/2 + 1) - lgamma(b[k]+1) - lgamma(n - b[k]/2 - s/2 + 1)
    argexp_u <- cl +(b[k]/2)*log(thet)

    for (k in 2:nb)
       { cl <- lgamma(n+1) - lgamma((s-b[k])/2 + 1) - lgamma(b[k]+1) - lgamma(n - b[k]/2 - s/2 + 1)
         argexp_u <- max(argexp_u,cl + (b[k]/2)*log(thet))
       }   
    
    shiftl <- min(0, 700-argexp_u)

    for (k in 1:nb)
       { cl <- lgamma(n+1) - lgamma((s-b[k])/2 + 1) - lgamma(b[k]+1) - lgamma(n - b[k]/2 - s/2 + 1)
         prb[k] <- exp(cl + (b[k]/2)*log(thet) + shiftl)         
       }

    prb_gt[nb+1] <- 0
    for (k in 1:nb)
       { kk <- nb-k
         prb_gt[kk+1] <- prb[kk+1] + prb_gt[kk+1+1]
       }   
    for (k in 1:nb)
       prb_gt[k+1] <- prb_gt[k+1] / prb_gt[0+1]
    prb_gt[0+1] <- 1
    k <- nb+1

    repeat                                            
       { k <- k-1
         size <- prb_gt[k+1]
         if (size > alpha)    break
       }
    kc <- k+1
    c <- b[kc]
    gam <- (alpha - prb_gt[kc+1]) / (prb_gt[k+1] - prb_gt[kc+1])
       
  }

cat ("  N = ",n,"  S = ",s,"  ALPHA = ",alpha,"  DEL0 = ",del0,"  C = ",c,
     "  GAM = ",gam)

