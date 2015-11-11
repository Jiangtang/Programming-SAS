alpha <- 0.05
n <- 50
del0 <- 0.05
sw <- 0.0005
tol <- 0.0001
maxh <- 10

k <- rep(NA,n)
kpr <- rep(NA,n)
indcs <- 0

u_alc <- qnorm(1-alpha)

for (v in 1:n)
   { u <- v
     t <- 10
     while (u >= 1 && t > u_alc)
          { u <- u-1
            t <- sqrt(n)*((2*u-v)/n + del0) / sqrt(v/n - ((2*u-v)/n)**2)
          }
     k[v] <- u+1
   }

size <- 0
eta_ <- del0
eta <- del0+sw

while (eta <= 1-sw)
     { pi_0 <- 1/2 - del0/(2*eta)
       rej_ <- 0
       for (v in 1:n)
          { if (k[v] == 0)
              rej_v <- 1     else
              rej_v <- 1-pbinom(k[v]-1,v,pi_0)
            probv <- pbinom(v,n,eta) - pbinom(v-1,n,eta)
            rej_ <- rej_ + rej_v * probv
          }
       if (size >= rej_)
         eta <- eta + sw       else
         { size <- rej_
           eta_ <- eta
           eta <- eta + sw
         } 
     }

size_unc <- size
eta_unc <- eta_

if (size > alpha)                                   
  { alpha1 <- 0
    size1 <- 0
    alpha2 <- alpha
    nh <- 0

    repeat                                          
    { alpha0 <- (alpha1+alpha2) / 2
      nh <- nh +1
      u_al0_c <- qnorm(1-alpha0)
      for (v in 1:n)
         kpr[v] <- k[v]
      ind <- 0
      for (v in 1:n)
         { u <- v
           t <- 10
           while (u >= 1 && t > u_al0_c)
                { u <- u-1
                  t <- sqrt(n) * ((2*u-v)/n + del0) / sqrt(v/n - ((2*u-v)/n)**2)
                }
           k[v] <- u+1
           ind <- ind + sign(abs(k[v] - kpr[v]))
         }
      if (ind == 0 && indcs == 1)
        { alpha2 <- alpha0
          indcs <- 1
        }                            else
      if (ind == 0 && indcs == 2)
        { alpha1 <- alpha0
          size1 <- size
          indcs <- 2
        }                            else
      { size <- 0
        eta_ <- del0
        eta <- del0 + sw
        while (eta <= 1-sw)
             { pi_0 <- 1/2 - del0/(2*eta)
               rej_ <- 0
               for (v in 1:n)
                  { if (k[v] == 0)
                      rej_v <- 1      else
                      rej_v <- 1-pbinom(k[v]-1,v,pi_0)
                    probv <- pbinom(v,n,eta) - pbinom(v-1,n,eta)
                    rej_ <- rej_ + rej_v*probv
                  }
               if (size >= rej_)
                  eta <- eta+sw      else
                  { size <- rej_
                    eta_ <- eta
                    eta <- eta+sw
                  }
             }
         if (size >= alpha-tol && size <= alpha)
             break                               
         if (size > alpha && nh < maxh)
           { alpha2 <- alpha0
             indcs <- 1
           }                                    
         if (size < alpha-tol && nh < maxh)
           { alpha1 <- alpha0
             size1 <- size
             indcs <- 2
           }
         if (nh >= maxh)
           { alpha0 <- alpha1
             size0 <- size1
             break
           }
      }
    }                                                    
  }                                                 

cat(" ALPHA =",alpha,"  N =",n,"  DEL0 =",del0,"  SW =",sw,"  ALPHA0 =",alpha0,
    "  SIZE_unc =",size_unc," SIZE0 =",size0,"  NH =",nh)             
