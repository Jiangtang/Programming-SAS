alpha <- 0.05
n <- 50
del0 <- 0.20
sw <- 0.0005
tol <- 0.0005
maxh <- 10

kl <- rep(NA,n)
ku <- rep(NA,n)
klpr <- rep(NA,n)

indcs <- NA
size0 <- NA
itmin <- ceiling(del0/sw)
itmax <- 1/sw
error <- "NONE"
INDIK <- 0

u_al <- qnorm(alpha)

for (v in 1:(n-1))
   { u <- -1
     t <- 10
     crit <- 0
     while (u <= (v-1) && t >= crit)
          { u <- u + 1
            t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
            nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
            if (nc > 100)
               crit <- sqrt(nc) + u_al  else
               crit <- sqrt(qchisq(alpha,1,nc))
          }
      kl[v] <- u
      ku[v] <- v-kl[v]
      for (u in kl[v]:ku[v])
         { t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
           nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
           if (nc > 100)
               crit <- sqrt(nc) + u_al  else
               crit <- sqrt(qchisq(alpha,1,nc))
           if (t >= crit)
             { error <- "!!!!!"
               break }
           }  
       if (error == "!!!!!") break  
    }

if (error == "NONE")
{
v <- n
u <- 0
t <- 10
crit <- 0

while (u <= (v-2) && t >= crit)
 {  u <- u + 1
    t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
    nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
    if (nc > 100)
       crit <- sqrt(nc) + u_al   else
       crit <- sqrt(qchisq(alpha,1,nc))
  }
  kl[v] <- u
  ku[v] <- v-kl[v]
  for (u in kl[v]:ku[v])
     { t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
       nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
       if (nc > 100)
          crit <- sqrt(nc) + u_al   else
          crit <- sqrt(qchisq(alpha,1,nc))
       if (t >= crit)
         { error <- "!!!!!"
           break }
      }
}

if (error == "NONE")
{
size <- 0
for (it in itmin:itmax)
   { eta <- it*sw
     rej_ <- 0
     for (v in 1:n)
        { if (ku[v] >= v)
             rej_v <- 1    else
             if (kl[v] <= ku[v]) 
               { pi <- (eta+del0)/(2*eta)
                 if (pi >= 1)
                    rej_v <- 0  else
                    rej_v <- pbinom(ku[v],v,pi) - pbinom(kl[v]-1,v,pi)
                }    else
               rej_v <- 0
           probv <- pbinom(v,n,eta) - pbinom(v-1,n,eta)                        
           rej_ <- rej_ + rej_v*probv
         }
      size <- max(size,rej_)
    }

if (size <= alpha) INDIK = 1
}

if (error == "NONE" && INDIK == 0) 
{                                                 
alpha1 <- 0
size1 <- 0
alpha2 <- alpha
nh <- 0

#for (i in 1:maxh)                                   
repeat
{
alpha0 <- (alpha1+alpha2)/2                        
nh <- nh+1
u_al0 <- qnorm(alpha0)
for (v in 1:n) 
     klpr[v] <- kl[v]
ind <- 0
for (v in 1:(n-1))
   { u <- -1
     t <- 10
     crit <- 0
     while (u <= (v-1) && t >= crit)
          { u <- u+1
            t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
            nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
            if (nc > 100)
                crit <- sqrt(nc) + u_al0  else
                crit <- sqrt(qchisq(alpha0,1,nc))
           }
     kl[v] <- u
     ind <- ind + sign(abs(kl[v]-klpr[v]))
     ku[v] <- v-kl[v]
   }

v <- n
u <- 0
t <- 10
crit <- 0

while (u <= (v-2) && t >= crit)
     { u <- u + 1
       t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
       nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
       if (nc > 100)
          crit <- sqrt(nc) + u_al0   else
          crit <- sqrt(qchisq(alpha0,1,nc))
      }

kl[v] <- u
ind <- ind + sign(abs(kl[v]-klpr[v]))
ku[v] <- v-kl[v]


if (ind == 0 && indcs == 1)
  { alpha2 <- alpha0
    indcs <- 1 }  else
if (ind == 0 && indcs == 2)
  { alpha1 <- alpha0
    size1 <- size
    indcs <- 2 }  else
  {                                                
    for (v in  1:n)
     {   for (u in kl[v]:ku[v])
         if(ku[v] > 0)
       { t <- sqrt(n)*abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
         nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
         if (nc > 100)
            crit <- sqrt(nc) + u_al   else
            crit <- sqrt(qchisq(alpha,1,nc))
         if (t >= crit)
           { error <- "!!!!!"
             break  }
        } 
        if (error == "!!!!!")
           break
     }

     if (error == "!!!!!") break     else
       { 
         size <- 0
         for (it in itmin:itmax)
            { eta <- it*sw
              rej_ <- 0
              for (v in 1:n)
                 { if (ku[v] >= v)
                      rej_v <- 1   else
                   if (kl[v] <= ku[v])
                     { pi <- (eta+del0) / (2*eta)
                       if (pi >= 1)
                          rej_v <- 0   else
                          rej_v <- pbinom(ku[v],v,pi) - pbinom(kl[v]-1,v,pi)
                      }   else
                        rej_v <- 0
                    probv <- pbinom(v,n,eta) - pbinom(v-1,n,eta)
                    rej_ <- rej_ + rej_v*probv
                  }
               size <- max(size,rej_)
              }
          if (size >= (alpha-tol) && size <= alpha) break
          if (size > alpha && nh < maxh)
            { alpha2 <- alpha0
              indcs <- 1 }
          if (size < (alpha-tol) && nh < maxh)
            { alpha1 <- alpha0
              size1 <- size
              indcs <- 2 }
          if (nh == maxh)
            { alpha0 <- alpha1
              size0 <- size1
              break  }        
         }
         
   }                                     

}                                        

}                                        


cat(" ALPHA =",alpha,"  N =",n,"  DEL0 =",del0,"  SW =",sw,"  ALPHA0 =",alpha0,
    "  SIZE0 =",size0,"  NH =",nh,"  ERROR =",error)



