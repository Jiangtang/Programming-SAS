alpha <- 0.05
tol <- 1.0e-10
itmax <- 50
ny1 <- 40
ny2 <- 45
rho1 <- 0.5625
rho2 <- 1.7689

err <- -alpha
c1 <- sqrt(rho1 * rho2)

while (err < 0)
  {  c1 <- c1 - 0.05
     h <- alpha + pf(c1/rho2,ny1,ny2)
     c2 <- qf(h,ny1,ny2)*rho2
     err <- pf(c2/rho1,ny1,ny2) - pf(c1/rho1,ny1,ny2) - alpha
   }

c1L <- c1
c1R <- c1 + 0.05
it <- 0

while (abs(err) >= tol && it <= itmax)
  {  it <- it + 1
     c1 <- (c1L + c1R) / 2
     h <- alpha + pf(c1/rho2,ny1,ny2)
     c2 <- qf(h,ny1,ny2) * rho2
     err <- pf(c2/rho1,ny1,ny2) - pf(c1/rho1,ny1,ny2) - alpha
     if (err <= 0) 
        c1R <- c1   else
                     c1L <- c1
  }

pow0 <- pf(c2,ny1,ny2) - pf(c1,ny1,ny2)

cat(" ALPHA =",alpha,"   NY1 =",ny1,"   NY2 =",ny2,"   RHO1 =",rho1,"   RHO2 =",rho2,
 "   IT =",it,"\n","C1 =",c1,"   C2 =",c2,"   ERR =",err,"   POW0 =",pow0)
     
