workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

m <- "150"               
n <- "150"               
maxh <- "25"             
rho1 <- ".4286"          
rho2 <- "2.3333"        
alpha <- "0.05E0"        
sw <- "0.001E0"          
tolrd <- "1.0E-6"        
tol <- "1.0E-3"          

################################################

setwd(workdir)
out <- c(m,n,maxh,rho1,rho2,alpha,sw,tolrd,tol)
write(out,file="aeq3_inp",ncolumns=1)
system("R CMD BATCH bi2aeq3.R bi2aeq3.log")
file.show("aeq3_inp")
file.show("aeq3_out")
