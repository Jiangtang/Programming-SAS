alpha <- 0.024902
n <- 50
del0 <- 0.20
p10 <- 0.30
p01 <- 0.30

kl <- rep(NA,n)
ku <- rep(NA,n)

u_al <- qnorm(alpha)
error <- "NONE"
INDIW <- 0
pow <- 0

for (v in 1:(n-1))
   {  u <- -1
      t <- 10
      crit <- 0
     while (u <= v-1 && t >= crit)
          {  u <- u + 1
             t <- sqrt(n) * abs((2*u-v)/n) / sqrt(v/n-((2*u-v)/n)**2)
             nc <- n*del0**2 / (v/n-((2*u-v)/n)**2)
             if (nc > 100)
                crit <- sqrt(nc) + u_al   else
                                        crit <- sqrt( qchisq(alpha,1,nc) )
           }
      kl[v] <- u
      ku[v] <- v-kl[v]
      
    if (kl[v] <= ku[v])
     {
      for (u in kl[v]:ku[v])
         {  t <- sqrt(n) * abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
            nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
            if (nc > 100)
               crit <- sqrt(nc) + u_al   else
                                        crit <- sqrt( qchisq(alpha,1,nc) )
            if (t >= crit) 
              { INDIW <- 1
                error <- "!!!!!"
                break  }
          }  }
    if (INDIW == 1) break
    }

if (INDIW == 0)
{  v <- n
   u <- 0
   t <- 10
   crit <- 0

   while (u <= v-2 && t >= crit)
       {  u <- u + 1
          t <- sqrt(n) * abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
          nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
          if (nc > 100)
             crit <- sqrt(nc) + u_al   else
                                      crit <- sqrt( qchisq(alpha,1,nc) )
       }
   kl[v] <- u
   ku[v] <- v-kl[v]

    if (kl[v] <= ku[v])
   {
   for (u in kl[v]:ku[v])
      { t <- sqrt(n) * abs((2*u-v)/n) / sqrt(v/n - ((2*u-v)/n)**2)
        nc <- n*del0**2 / (v/n - ((2*u-v)/n)**2)
        if (nc > 100)
           crit <- sqrt(nc) + u_al   else
                                    crit <- sqrt( qchisq(alpha,1,nc) ) 
        if (t >= crit)
          { INDIW <- 1
            error <- "!!!!!"
            break  }
       }  }
    if (INDIW == 0) 
{
pow <- 0
eta <- p10 + p01
PI <- p10/eta

for (v in 1:n)
   {  if (ku[v] >= v) rej_v <- 1    else
      if (kl[v] <= ku[v]) rej_v <- pbinom(ku[v],v,PI) - pbinom(kl[v]-1,v,PI)    else
        rej_v <- 0 
      probv <- pbinom(v,n,eta) - pbinom(v-1,n,eta)
      pow <- pow + rej_v * probv
    }
       }       }

cat(" ALPHA =",alpha,"   N =",n,"   DEL0 =",del0,"   P10 =",p10,"   P01 =",p01,
 "   POW =",pow,"\n","ERROR =",error)
           
     
