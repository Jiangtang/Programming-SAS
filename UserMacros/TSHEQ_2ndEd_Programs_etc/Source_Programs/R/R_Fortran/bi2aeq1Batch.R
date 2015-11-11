workdir <- "<mydirectory>/Source_Programs/R/R_Fortran"

m <- "225"               
n <- "119"               
rho1 <- ".6667"          
rho2 <- "1.5"            
alpha <- "0.05"          
p1 <- "0.4800"           
p2 <- "0.5294"             

########################################################################

setwd(workdir)
out <- c(m,n,rho1,rho2,alpha,p1,p2)
write(out,file="aeq_inp",ncolumns=1)
system("R CMD BATCH bi2aeq1.R bi2aeq1.log")
file.show("aeq1_inp")
file.show("aeq1_out")
