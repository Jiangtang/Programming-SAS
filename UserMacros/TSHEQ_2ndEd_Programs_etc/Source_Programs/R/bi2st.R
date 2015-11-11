library(BiasedUrn)
alpha <- .05
m <- 225
n <- 119
s <- 171
rho1 <- .6667
rho2 <- 3/2

nn <- m + n
k <- trunc(s*m/nn)
indiS7 <- 0
indiS6 <- 0

if (2*k < s || rho1 != 1/rho2)
   cat("dummy") else
{ hrho1k <- pFNCHypergeo(k,m,n,s,rho1) - pFNCHypergeo(max(0,k-1),m,n,s,rho1)
  if (hrho1k >= alpha)
  { c1 <- k                                            
    c2 <- k
    gam1 <- alpha/hrho1k
    gam2 <- gam1
    indiS7 <- 1  }  }                    

if (indiS7 == 0)
{
 k1 <- min(k+2,s,m)                      

repeat
{
 k2 <- k1 - 1                                 
 hrho1c1 <- pFNCHypergeo(k1-1,m,n,s,rho1) 
 alpha1 <- 0
 hrho2c1 <- pFNCHypergeo(k1-1,m,n,s,rho2)
 alpha2 <- 0

 while ((max(alpha1,alpha2) <= alpha) &  k2 <= min(s,m) + 2)
   {  alpha1 <- pFNCHypergeo(min(s,m,k2),m,n,s,rho1) - hrho1c1
      alpha2 <- pFNCHypergeo(min(s,m,k2),m,n,s,rho2) - hrho2c1
      k2 <- k2 + 1  }

 k2 <- k2 - 2
if(k2 < k1)
 { INCL <- 1                              
   INCR <- 1 } else

 { k1 <- k1 + 1
   INCL <- 0 
   INCR <- 1 }

repeat                                        
 {
alpha1 <- pFNCHypergeo(min(s,m,k2),m,n,s,rho1) - pFNCHypergeo(max(0,s-n,k1-1),m,n,s,rho1)               
alpha2 <- pFNCHypergeo(min(s,m,k2),m,n,s,rho2) - pFNCHypergeo(max(0,s-n,k1-1),m,n,s,rho2)
delalph1 <- alpha - alpha1
delalph2 <- alpha - alpha2
exhyp11 <- pFNCHypergeo(k1-1,m,n,s,rho1) - pFNCHypergeo(max(0,s-n,k1-2),m,n,s,rho1) * 
           sign(1+sign((k1-2)-max(0,s-n)))
exhyp12 <- pFNCHypergeo(min(s,m,k2+1),m,n,s,rho1) - 
           pFNCHypergeo(min(s,m,k2),m,n,s,rho1)
exhyp21 <- pFNCHypergeo(k1-1,m,n,s,rho2) - pFNCHypergeo(max(0,s-n,k1-2),m,n,s,rho2) * 
           sign(1+sign((k1-2)-max(0,s-n)))
exhyp22 <- pFNCHypergeo(min(s,m,k2+1),m,n,s,rho2) - 
           pFNCHypergeo(min(s,m,k2),m,n,s,rho2)

det <- exhyp11*exhyp22 - exhyp12*exhyp21
gam1 <- (exhyp22*delalph1 - exhyp12*delalph2) / det
gam2 <- (exhyp11*delalph2 - exhyp21*delalph1) / det 


if ((min(gam1,gam2)<0 || max(gam1,gam2) >= 1) && INCL == 0 && INCR == 1)
   { k1 <- k1 - 1
     k2 <- k2 - 1                                         
     INCL <- 1
     INCR <- 0  } else   
if ((min(gam1,gam2)<0 || max(gam1,gam2) >= 1) && INCL == 1 && INCR == 0)
   { k2 <- k2 +1
     INCL <- 1
     INCR <- 1  } else                                     
if ((min(gam1,gam2)<0 || max(gam1,gam2) >= 1) && INCL == 1 && INCR == 1)
   { k1 <- k1 - 1
     break    }   else                                          
   { indiS6 <- 1
     break    }   }             

if (indiS6 == 1)
    break          }            

c1 <- k1 - 1
c2 <- k2 + 1                                            

                         }      

cat(" alpha =",alpha,"   m =",m,"   n =",n,"   s=",s,"   RHO1 =",rho1,
    "   RHO2 =",rho2,"\n","GAM1 =",gam1,"   GAM2 =",gam2,"   C1 =",c1,"   C2 =",c2)



